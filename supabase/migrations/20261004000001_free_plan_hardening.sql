-- Tutor's Desk — server-authoritative Free allowances and subject selection.
-- Apply after 20261003000001_subscription_architecture.sql.
begin;

-- The complete policy matrix lives in subscription_plans. Free is deliberately
-- usable but finite; paid plans have no monthly paper ceiling.
alter table public.subscription_plans
  add column if not exists monthly_paper_limit integer
    check (monthly_paper_limit is null or monthly_paper_limit > 0);

update public.subscription_plans
set monthly_paper_limit = case when id = 'free' then 2 else null end,
    updated_at = now();

alter table public.subscription_plans
  drop constraint if exists subscription_plans_monthly_limit_matrix;
alter table public.subscription_plans
  add constraint subscription_plans_monthly_limit_matrix
  check ((id = 'free' and monthly_paper_limit = 2)
      or (id <> 'free' and monthly_paper_limit is null));

-- A short-window limit protects the provider even when a paid teacher has a
-- generous daily allowance. It is policy data, not a client-side constant.
alter table public.subscription_plans
  add column if not exists ai_burst_limit integer not null default 0
    check (ai_burst_limit >= 0);
update public.subscription_plans
set ai_burst_limit = case
  when id = 'pro' then 5
  when id = 'professional' then 8
  else 0
end,
updated_at = now();

-- One short-window row per teacher. The daily row remains the enforcement
-- counter used for display and daily policy.
create table if not exists public.ai_usage_burst (
  user_id uuid not null references auth.users(id) on delete cascade,
  window_start timestamptz not null,
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, window_start)
);
create index if not exists ai_usage_burst_user_time
  on public.ai_usage_burst(user_id, window_start desc);

create table if not exists public.ai_usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id text not null,
  plan_id text not null,
  action text not null,
  model text,
  input_tokens integer,
  output_tokens integer,
  total_tokens integer,
  status text not null check (status in ('started', 'succeeded', 'failed')),
  error_code text,
  created_at timestamptz not null default now(),
  unique (user_id, request_id)
);
create index if not exists ai_usage_events_user_time
  on public.ai_usage_events(user_id, created_at desc);

-- One calendar-month counter per account. usage_month is always the first day
-- of the Asia/Dhaka month that was claimed.
create table if not exists public.paper_usage_monthly (
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_month date not null
    check (usage_month = date_trunc('month', usage_month)::date),
  paper_count integer not null default 0 check (paper_count >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, usage_month)
);

-- A reservation makes retries idempotent and lets a failed local composition
-- return one claim without allowing a second successful completion to consume
-- it twice. The app never writes this table directly.
create table if not exists public.paper_creation_reservations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_month date not null
    check (usage_month = date_trunc('month', usage_month)::date),
  client_request_id text,
  status text not null default 'reserved'
    check (status in ('reserved', 'consumed', 'refunded')),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  expires_at timestamptz not null default (now() + interval '30 minutes'),
  unique (user_id, client_request_id)
);
create index if not exists paper_creation_reservations_user_status
  on public.paper_creation_reservations(user_id, status, created_at);

alter table public.paper_usage_monthly enable row level security;
alter table public.paper_creation_reservations enable row level security;
alter table public.ai_usage_burst enable row level security;
alter table public.ai_usage_events enable row level security;
revoke all on public.ai_usage_burst, public.ai_usage_events from public, anon, authenticated;

drop policy if exists paper_usage_monthly_read_own on public.paper_usage_monthly;
create policy paper_usage_monthly_read_own on public.paper_usage_monthly
  for select to authenticated using (user_id = auth.uid());
drop policy if exists paper_creation_reservations_read_own on public.paper_creation_reservations;
create policy paper_creation_reservations_read_own on public.paper_creation_reservations
  for select to authenticated using (user_id = auth.uid());
revoke insert, update, delete on public.paper_usage_monthly from public, anon, authenticated;
revoke insert, update, delete on public.paper_creation_reservations from public, anon, authenticated;
grant select on public.paper_usage_monthly, public.paper_creation_reservations to authenticated;

-- Central effective policy. A paid row is effective only while its status is
-- active and its expiry is in the future (or has no expiry). Cancelled,
-- failed, pending, and expired rows resolve to the Free plan immediately.
create or replace function public.effective_entitlement(p_user_id uuid)
returns table(
  plan_id text,
  subject_limit integer,
  monthly_paper_limit integer,
  no_watermark boolean,
  ai_assistant boolean,
  ai_daily_limit integer,
  omr_scanner boolean
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  effective_plan text := 'free';
  selected public.subscription_plans%rowtype;
begin
  if auth.uid() is not null and auth.uid() <> p_user_id
     and not public.is_question_admin() then
    raise exception 'Not allowed';
  end if;
  select case
    when p.subscription_plan <> 'free'
      and p.subscription_status = 'active'
      and (p.subscription_expires_at is null or p.subscription_expires_at > now())
      then p.subscription_plan
    else 'free'
  end
  into effective_plan
  from public.profiles p
  where p.id = p_user_id;

  select * into selected
  from public.subscription_plans
  where id = effective_plan and is_active;

  if not found then
    select * into selected
    from public.subscription_plans
    where id = 'free' and is_active;
  end if;

  return query select selected.id, selected.subject_limit,
    selected.monthly_paper_limit, selected.no_watermark,
    selected.ai_assistant, selected.ai_daily_limit, selected.omr_scanner;
end $$;

-- Subject inserts are controlled by the database, not by a Flutter pre-check.
-- The profile row lock serializes concurrent requests from modified clients.
create or replace function public.select_user_subject(p_subject_id text)
returns table(
  allowed boolean,
  already_selected boolean,
  subject_count integer,
  subject_limit integer,
  plan_id text,
  reason text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  teacher uuid := auth.uid();
  limit_value integer;
  selected_count integer;
  effective_plan text;
  subject_exists boolean;
begin
  if teacher is null then raise exception 'Authentication required'; end if;
  if p_subject_id is null or length(trim(p_subject_id)) = 0 or length(p_subject_id) > 80 then
    raise exception 'Invalid subject';
  end if;

  perform 1 from public.profiles where id = teacher for update;
  if not found then raise exception 'Profile not found'; end if;

  select e.subject_limit, e.plan_id into limit_value, effective_plan
  from public.effective_entitlement(teacher) e;
  select exists(
    select 1 from public.user_subjects
    where user_id = teacher and subject_id = trim(p_subject_id)
  ) into subject_exists;
  select count(*)::integer into selected_count
  from public.user_subjects where user_id = teacher;

  if subject_exists then
    return query select true, true, selected_count, limit_value, effective_plan, 'already_selected';
    return;
  end if;
  if limit_value is not null and selected_count >= limit_value then
    return query select false, false, selected_count, limit_value, effective_plan, 'subject_limit';
    return;
  end if;

  insert into public.user_subjects(user_id, subject_id)
  values (teacher, trim(p_subject_id));
  selected_count := selected_count + 1;
  return query select true, false, selected_count, limit_value, effective_plan, 'ok';
end $$;

create or replace function public.remove_user_subject(p_subject_id text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  delete from public.user_subjects
  where user_id = auth.uid() and subject_id = trim(p_subject_id);
  return found;
end $$;

-- Atomic monthly paper claim. The user id is always taken from auth.uid(); a
-- client cannot claim against another account or supply a plan/limit. Counts
-- are optional for legacy reconciliation calls, but online paper creation
-- supplies them so the same safety ceiling is enforced server-side.
drop function if exists public.claim_paper_creation(text);
drop function if exists public.claim_paper_creation(text, integer, integer, integer);
create or replace function public.claim_paper_creation(
  p_request_id text default null,
  p_exam_format text default 'model_test',
  p_mcq_count integer default null,
  p_saq_count integer default null,
  p_cq_count integer default null
)
returns table(
  allowed boolean,
  reservation_id uuid,
  paper_count integer,
  monthly_limit integer,
  usage_month date,
  plan_id text,
  reason text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  teacher uuid := auth.uid();
  month_start date := date_trunc('month', now() at time zone 'Asia/Dhaka')::date;
  e record;
  existing public.paper_creation_reservations%rowtype;
  usage public.paper_usage_monthly%rowtype;
  new_reservation uuid;
begin
  if teacher is null then raise exception 'Authentication required'; end if;
  if p_request_id is not null and length(p_request_id) > 160 then
    raise exception 'Invalid paper request id';
  end if;

  -- A crashed app must not permanently consume a reservation after its short
  -- lease. Only reserved rows are released; completed work remains counted.
  for existing in
    select * from public.paper_creation_reservations
    where user_id = teacher and status = 'reserved' and expires_at <= now()
    for update
  loop
    update public.paper_creation_reservations
    set status = 'refunded', completed_at = now()
    where id = existing.id;
    update public.paper_usage_monthly as pu
    set paper_count = greatest(pu.paper_count - 1, 0), updated_at = now()
    where pu.user_id = teacher and pu.usage_month = existing.usage_month;
  end loop;

  select * into e from public.effective_entitlement(teacher);
  if not found then raise exception 'Subscription policy unavailable'; end if;

  -- Free papers are deliberately limited to the Model Test experience. The
  -- format is supplied by the client for policy evaluation, but the plan and
  -- allowance are always resolved from the locked server entitlement.
  if e.plan_id = 'free' and lower(trim(coalesce(p_exam_format, ''))) <> 'model_test' then
    return query select false, null::uuid, 0, e.monthly_paper_limit,
      month_start, e.plan_id, 'format_locked';
    return;
  end if;

  if p_mcq_count is not null or p_saq_count is not null or p_cq_count is not null then
    if p_mcq_count is null or p_saq_count is null or p_cq_count is null
       or p_mcq_count < 0 or p_saq_count < 0 or p_cq_count < 0
       or p_mcq_count > 100 or p_saq_count > 30 or p_cq_count > 15
       or p_mcq_count + p_saq_count + p_cq_count > 145 then
      return query select false, null::uuid, 0, e.monthly_paper_limit,
        month_start, e.plan_id, 'safety_limit';
      return;
    end if;
  end if;

  -- Paid plans are unlimited for this policy and need no reservation row.
  if e.monthly_paper_limit is null then
    return query select true, null::uuid, 0, null::integer, month_start, e.plan_id, 'unlimited';
    return;
  end if;

  if p_request_id is not null then
    select * into existing
    from public.paper_creation_reservations
    where user_id = teacher and client_request_id = p_request_id
    for update;
    if found and existing.status in ('reserved', 'consumed') then
      select coalesce(pu.paper_count, 0) into usage.paper_count
      from public.paper_usage_monthly as pu
      where pu.user_id = teacher and pu.usage_month = existing.usage_month;
      return query select true, existing.id, coalesce(usage.paper_count, 0),
        e.monthly_paper_limit, existing.usage_month, e.plan_id, 'already_claimed';
      return;
    end if;
    if found and existing.status = 'refunded' then
      -- A timed-out/refunded request id may be retried without hitting the
      -- reservation unique key or receiving the old refund as a success.
      update public.paper_creation_reservations
      set client_request_id = null
      where id = existing.id;
    end if;
  end if;

  insert into public.paper_usage_monthly(user_id, usage_month, paper_count)
  values (teacher, month_start, 0)
  on conflict on constraint paper_usage_monthly_pkey do nothing;
  select pu.* into usage from public.paper_usage_monthly as pu
  where pu.user_id = teacher and pu.usage_month = month_start
  for update;

  if usage.paper_count >= e.monthly_paper_limit then
    return query select false, null::uuid, usage.paper_count,
      e.monthly_paper_limit, month_start, e.plan_id, 'monthly_limit';
    return;
  end if;

  update public.paper_usage_monthly as pu
  set paper_count = pu.paper_count + 1, updated_at = now()
  where pu.user_id = teacher and pu.usage_month = month_start
  returning pu.* into usage;

  insert into public.paper_creation_reservations(
    user_id, usage_month, client_request_id
  ) values (teacher, month_start, nullif(trim(p_request_id), ''))
  returning id into new_reservation;

  return query select true, new_reservation, usage.paper_count,
    e.monthly_paper_limit, month_start, e.plan_id, 'ok';
end $$;

create or replace function public.complete_paper_creation(p_reservation_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  update public.paper_creation_reservations
  set status = 'consumed', completed_at = now()
  where id = p_reservation_id and user_id = auth.uid() and status = 'reserved';
  return found;
end $$;

create or replace function public.refund_paper_creation(p_reservation_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare reservation public.paper_creation_reservations%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select * into reservation from public.paper_creation_reservations
  where id = p_reservation_id and user_id = auth.uid() and status = 'reserved'
  for update;
  if not found then return false; end if;
  update public.paper_creation_reservations
  set status = 'refunded', completed_at = now()
  where id = reservation.id;
  update public.paper_usage_monthly
  set paper_count = greatest(paper_count - 1, 0), updated_at = now()
  where user_id = reservation.user_id and usage_month = reservation.usage_month;
  return true;
end $$;

-- Remove direct DML paths. The client can only read its own rows and call the
-- controlled functions above.
drop policy if exists user_subjects_insert_own on public.user_subjects;
drop policy if exists user_subjects_update_own on public.user_subjects;
drop policy if exists user_subjects_delete_own on public.user_subjects;
revoke insert, update, delete on public.user_subjects from public, anon, authenticated;

revoke all on function public.effective_entitlement(uuid) from public, anon;
revoke all on function public.select_user_subject(text) from public, anon;
revoke all on function public.remove_user_subject(text) from public, anon;
revoke all on function public.claim_paper_creation(text, text, integer, integer, integer) from public, anon;
revoke all on function public.complete_paper_creation(uuid) from public, anon;
revoke all on function public.refund_paper_creation(uuid) from public, anon;
grant execute on function public.select_user_subject(text) to authenticated;
grant execute on function public.remove_user_subject(text) to authenticated;
grant execute on function public.claim_paper_creation(text, text, integer, integer, integer) to authenticated;
grant execute on function public.complete_paper_creation(uuid) to authenticated;
grant execute on function public.refund_paper_creation(uuid) to authenticated;
grant execute on function public.effective_entitlement(uuid) to authenticated, service_role;

-- Reuse the same effective policy for AI. This prevents a cancelled or
-- pending paid profile from retaining its AI quota through a stale branch.
create or replace function public.claim_ai_request(p_user_id uuid)
returns table(allowed boolean, request_count integer, daily_limit integer,
              usage_date date, reason text)
language plpgsql
security definer
set search_path = public
as $$
declare
  day date := (now() at time zone 'Asia/Dhaka')::date;
  current_count integer;
  burst_count integer;
  burst_limit integer;
  burst_window timestamptz := date_trunc('minute', now());
  e record;
begin
  if auth.uid() is not null and auth.uid() <> p_user_id then
    raise exception 'Not allowed';
  end if;
  select * into e from public.effective_entitlement(p_user_id);
  if not found then
    return query select false, 0, 0, day, 'upgrade_required';
    return;
  end if;
  select coalesce(sp.ai_burst_limit, 0) into burst_limit
  from public.subscription_plans sp where sp.id = e.plan_id;

  insert into public.ai_usage_daily(user_id, usage_date, request_count)
  values (p_user_id, day, 0)
  on conflict on constraint ai_usage_daily_pkey do nothing;
  select u.request_count into current_count
  from public.ai_usage_daily u
  where u.user_id = p_user_id and u.usage_date = day
  for update;

  if e.ai_daily_limit <= 0 then
    return query select false, current_count, e.ai_daily_limit, day, 'upgrade_required';
    return;
  end if;
  if current_count >= e.ai_daily_limit then
    return query select false, current_count, e.ai_daily_limit, day, 'daily_limit';
    return;
  end if;

  if burst_limit > 0 then
    insert into public.ai_usage_burst(user_id, window_start, request_count)
    values (p_user_id, burst_window, 0)
    on conflict (user_id, window_start) do nothing;
    select b.request_count into burst_count
    from public.ai_usage_burst b
    where b.user_id = p_user_id and b.window_start = burst_window
    for update;
    if burst_count >= burst_limit then
      return query select false, current_count, e.ai_daily_limit, day, 'burst_limit';
      return;
    end if;
    update public.ai_usage_burst b
    set request_count = b.request_count + 1, updated_at = now()
    where b.user_id = p_user_id and b.window_start = burst_window;
  end if;

  update public.ai_usage_daily u
  set request_count = u.request_count + 1, updated_at = now()
  where u.user_id = p_user_id and u.usage_date = day
  returning u.request_count into current_count;
  return query select true, current_count, e.ai_daily_limit, day, 'ok';
end $$;

create or replace function public.record_ai_usage_event(
  p_user_id uuid,
  p_request_id text,
  p_plan_id text,
  p_action text,
  p_model text default null,
  p_input_tokens integer default null,
  p_output_tokens integer default null,
  p_total_tokens integer default null,
  p_status text default 'failed',
  p_error_code text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_status not in ('started', 'succeeded', 'failed') then
    raise exception 'Invalid AI event status';
  end if;
  insert into public.ai_usage_events(
    user_id, request_id, plan_id, action, model, input_tokens,
    output_tokens, total_tokens, status, error_code
  ) values (
    p_user_id, p_request_id, p_plan_id, p_action, p_model, p_input_tokens,
    p_output_tokens, p_total_tokens, p_status, p_error_code
  )
  on conflict (user_id, request_id) do update set
    plan_id = excluded.plan_id,
    action = excluded.action,
    model = excluded.model,
    input_tokens = excluded.input_tokens,
    output_tokens = excluded.output_tokens,
    total_tokens = excluded.total_tokens,
    status = excluded.status,
    error_code = excluded.error_code;
end $$;
revoke all on function public.record_ai_usage_event(uuid, text, text, text, text, integer, integer, integer, text, text)
  from public, anon, authenticated;
grant execute on function public.record_ai_usage_event(uuid, text, text, text, text, integer, integer, integer, text, text)
  to service_role;

-- The admin read model also exposes the current paper allowance.
drop function if exists public.admin_subscription_overview();
create or replace function public.admin_subscription_overview()
returns table(
  teacher_id uuid,
  email text,
  teacher_name text,
  plan text,
  status text,
  started_at timestamptz,
  expires_at timestamptz,
  provider text,
  transaction_id text,
  ai_used_today integer,
  ai_daily_limit integer,
  papers_used_month integer,
  monthly_paper_limit integer
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_question_admin() then raise exception 'Administrator access required'; end if;
  return query
  select p.id, p.email, p.name, e.plan_id, p.subscription_status,
         p.subscription_started_at, p.subscription_expires_at,
         p.subscription_provider, p.subscription_transaction_id,
         coalesce(ai.request_count, 0), e.ai_daily_limit,
         coalesce(paper.paper_count, 0), e.monthly_paper_limit
  from public.profiles p
  cross join lateral public.effective_entitlement(p.id) e
  left join public.ai_usage_daily ai
    on ai.user_id = p.id
   and ai.usage_date = (now() at time zone 'Asia/Dhaka')::date
  left join public.paper_usage_monthly paper
    on paper.user_id = p.id
   and paper.usage_month = date_trunc('month', now() at time zone 'Asia/Dhaka')::date
  order by p.email;
end $$;
revoke all on function public.admin_subscription_overview() from public, anon;
grant execute on function public.admin_subscription_overview() to authenticated;

-- Promotion targeting now matches the four server plan ids. Existing `pro`
-- audience rows meant "any paid user" in the old studio, so preserve their
-- reach under the explicit `paid` audience.
do $$
declare r record;
begin
  if to_regclass('public.app_notifications') is null
     or to_regclass('public.app_offer_ads') is null then
    return;
  end if;
  for r in
    select conrelid::regclass as table_name, conname
    from pg_constraint
    where conrelid in ('public.app_notifications'::regclass, 'public.app_offer_ads'::regclass)
      and contype = 'c'
      and pg_get_constraintdef(oid) ilike '%audience%'
  loop
    execute format('alter table %s drop constraint %I', r.table_name, r.conname);
  end loop;
  update public.app_notifications set audience = 'paid' where audience = 'pro';
  update public.app_offer_ads set audience = 'paid' where audience = 'pro';
  alter table public.app_notifications add constraint app_notifications_audience_check
    check (audience in ('all', 'free', 'basic', 'pro', 'professional', 'paid'));
  alter table public.app_offer_ads add constraint app_offer_ads_audience_check
    check (audience in ('all', 'free', 'basic', 'pro', 'professional', 'paid'));
end $$;

do $policy$
begin
  if to_regclass('public.app_notifications') is not null then
    execute $sql$
      drop policy if exists app_notifications_user_read on public.app_notifications;
      create policy app_notifications_user_read on public.app_notifications
      for select to authenticated
      using (
        is_active and sent_at is not null and sent_at <= now()
        and (scheduled_at is null or scheduled_at <= now())
        and exists (
          select 1 from public.effective_entitlement(auth.uid()) e
          where audience = 'all'
            or audience = e.plan_id
            or (audience = 'paid' and e.plan_id <> 'free')
        )
      )
    $sql$;
  end if;
  if to_regclass('public.app_offer_ads') is not null then
    execute $sql$
      drop policy if exists app_offer_ads_public_read on public.app_offer_ads;
      create policy app_offer_ads_public_read on public.app_offer_ads
      for select to anon, authenticated
      using (
        is_active and (starts_at is null or starts_at <= now())
        and (audience = 'all' or (auth.uid() is not null and exists (
          select 1 from public.effective_entitlement(auth.uid()) e
          where audience = e.plan_id
            or (audience = 'paid' and e.plan_id <> 'free')
        )))
      )
    $sql$;
  end if;
end
$policy$;

commit;
