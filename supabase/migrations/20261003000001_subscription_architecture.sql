-- Tutor's Desk — centralized subscriptions, Rupantor Pay transactions, and AI limits.
-- Apply after the existing profiles/bKash migrations. Safe to run more than once.
begin;

-- 1. New server-authoritative profile fields. Legacy is_pro/pro_until/pro_plan
-- remain for migration/history and are never used by new feature code.
alter table public.profiles
  add column if not exists subscription_plan text not null default 'free',
  add column if not exists subscription_status text not null default 'active',
  add column if not exists subscription_started_at timestamptz,
  add column if not exists subscription_expires_at timestamptz,
  add column if not exists subscription_provider text,
  add column if not exists subscription_transaction_id text,
  add column if not exists subscription_updated_at timestamptz;

update public.profiles
set subscription_plan = case
      when coalesce(is_pro, false) and lower(coalesce(pro_plan, '')) = 'professional'
        then 'professional'
      when coalesce(is_pro, false) then 'pro'
      else 'free'
    end,
    subscription_status = case
      when coalesce(is_pro, false)
       and (pro_until is null or pro_until > now()) then 'active'
      when coalesce(is_pro, false) then 'expired'
      else 'active'
    end,
    subscription_started_at = coalesce(subscription_started_at, pro_updated_at),
    subscription_expires_at = coalesce(subscription_expires_at, pro_until),
    subscription_updated_at = coalesce(subscription_updated_at, pro_updated_at)
where subscription_plan = 'free'
  and (coalesce(is_pro, false) or pro_plan is not null or pro_until is not null);

alter table public.profiles drop constraint if exists profiles_subscription_plan_check;
alter table public.profiles add constraint profiles_subscription_plan_check
  check (subscription_plan in ('free', 'basic', 'pro', 'professional'));
alter table public.profiles drop constraint if exists profiles_subscription_status_check;
alter table public.profiles add constraint profiles_subscription_status_check
  check (subscription_status in ('active', 'pending', 'cancelled', 'failed', 'expired'));

-- Migrate the existing promotional offer identifiers without rewriting their
-- historical prices; they remain marketing records, not payment authority.
do $$
declare c record;
begin
  if to_regclass('public.paid_plan_offers') is not null then
    for c in
      select conname
      from pg_constraint
      where conrelid = 'public.paid_plan_offers'::regclass
        and contype = 'c'
        and pg_get_constraintdef(oid) ilike '%plan_id%'
    loop
      execute format('alter table public.paid_plan_offers drop constraint %I', c.conname);
    end loop;
    update public.paid_plan_offers set plan_id = 'basic' where plan_id = 'monthly';
    update public.paid_plan_offers set plan_id = 'pro' where plan_id = 'yearly';
    update public.paid_plan_offers set plan_id = 'professional' where plan_id = 'lifetime';
    alter table public.paid_plan_offers add constraint paid_plan_offers_plan_id_check
      check (plan_id in ('basic', 'pro', 'professional'));
  end if;
end $$;

-- 2. Dynamic plan matrix. Prices and limits are never trusted from Flutter.
create table if not exists public.subscription_plans (
  id text primary key check (id in ('free', 'basic', 'pro', 'professional')),
  name text not null,
  price_bdt integer not null default 0 check (price_bdt >= 0),
  duration_days integer check (duration_days is null or duration_days > 0),
  subject_limit integer check (subject_limit is null or subject_limit > 0),
  no_watermark boolean not null default false,
  ai_assistant boolean not null default false,
  ai_daily_limit integer not null default 0 check (ai_daily_limit >= 0),
  omr_scanner boolean not null default false,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.subscription_plans
  (id, name, price_bdt, duration_days, subject_limit, no_watermark,
   ai_assistant, ai_daily_limit, omr_scanner, is_active, sort_order)
values
  ('free', 'Free', 0, null, 1, false, false, 0, false, true, 0),
  ('basic', 'Basic', 100, 30, 3, false, false, 0, false, true, 1),
  ('pro', 'Pro', 200, 30, 5, true, true, 20, false, true, 2),
  ('professional', 'Professional', 400, 30, null, true, true, 50, true, true, 3)
on conflict (id) do update set
  name = excluded.name,
  price_bdt = excluded.price_bdt,
  duration_days = excluded.duration_days,
  subject_limit = excluded.subject_limit,
  no_watermark = excluded.no_watermark,
  ai_assistant = excluded.ai_assistant,
  ai_daily_limit = excluded.ai_daily_limit,
  omr_scanner = excluded.omr_scanner,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- 3. Payment attempts and verified transactions. Provider IDs are unique so
-- repeated webhooks cannot extend a subscription twice.
create table if not exists public.subscription_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_id text not null references public.subscription_plans(id),
  provider text not null default 'rupantorpay',
  provider_transaction_id text unique,
  amount_bdt integer not null check (amount_bdt >= 0),
  status text not null default 'pending'
    check (status in ('pending', 'paid', 'failed', 'cancelled', 'invalid')),
  created_at timestamptz not null default now(),
  verified_at timestamptz,
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);
create index if not exists subscription_transactions_user_date
  on public.subscription_transactions(user_id, created_at desc);

-- 4. Subjects are owned by the teacher, not inferred from open papers.
create table if not exists public.user_subjects (
  user_id uuid not null references auth.users(id) on delete cascade,
  subject_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, subject_id)
);

-- 5. One Bangladesh-local calendar row per teacher/day.
create table if not exists public.ai_usage_daily (
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_date date not null,
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, usage_date)
);

-- 6. Only the service role can mutate subscription/AI authority. Teachers can
-- read their own safe state and manage their own subject selections.
alter table public.subscription_plans enable row level security;
alter table public.subscription_transactions enable row level security;
alter table public.user_subjects enable row level security;
alter table public.ai_usage_daily enable row level security;

drop policy if exists subscription_plans_public_read on public.subscription_plans;
create policy subscription_plans_public_read on public.subscription_plans
  for select to anon, authenticated using (is_active);
drop policy if exists subscription_plans_admin on public.subscription_plans;
create policy subscription_plans_admin on public.subscription_plans
  for all to authenticated
  using (public.is_question_admin()) with check (public.is_question_admin());

drop policy if exists subscription_transactions_read_own on public.subscription_transactions;
create policy subscription_transactions_read_own on public.subscription_transactions
  for select to authenticated using (user_id = auth.uid());

drop policy if exists user_subjects_read_own on public.user_subjects;
create policy user_subjects_read_own on public.user_subjects
  for select to authenticated using (user_id = auth.uid());
drop policy if exists user_subjects_insert_own on public.user_subjects;
create policy user_subjects_insert_own on public.user_subjects
  for insert to authenticated with check (user_id = auth.uid());
drop policy if exists user_subjects_update_own on public.user_subjects;
create policy user_subjects_update_own on public.user_subjects
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists user_subjects_delete_own on public.user_subjects;
create policy user_subjects_delete_own on public.user_subjects
  for delete to authenticated using (user_id = auth.uid());

drop policy if exists ai_usage_daily_read_own on public.ai_usage_daily;
create policy ai_usage_daily_read_own on public.ai_usage_daily
  for select to authenticated using (user_id = auth.uid());

-- Protect every new authority column from anon/authenticated profile writes.
create or replace function public.protect_subscription_entitlements()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is not null then
    if tg_op = 'INSERT' then
      new.subscription_plan := 'free';
      new.subscription_status := 'active';
      new.subscription_started_at := null;
      new.subscription_expires_at := null;
      new.subscription_provider := null;
      new.subscription_transaction_id := null;
      new.subscription_updated_at := null;
    else
      new.subscription_plan := old.subscription_plan;
      new.subscription_status := old.subscription_status;
      new.subscription_started_at := old.subscription_started_at;
      new.subscription_expires_at := old.subscription_expires_at;
      new.subscription_provider := old.subscription_provider;
      new.subscription_transaction_id := old.subscription_transaction_id;
      new.subscription_updated_at := old.subscription_updated_at;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists profiles_protect_subscription on public.profiles;
create trigger profiles_protect_subscription
before insert or update on public.profiles
for each row execute function public.protect_subscription_entitlements();

-- Trusted activation is the only operation that can grant a paid plan.
-- Drop the earlier two-argument overload so a deployed migration cannot leave
-- a service-role activation path that skips provider amount verification.
drop function if exists public.activate_subscription_transaction(text, text);
create or replace function public.activate_subscription_transaction(
  p_provider_transaction_id text,
  p_status text default 'paid',
  p_provider_amount numeric default null,
  p_provider_currency text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  tx public.subscription_transactions%rowtype;
  plan public.subscription_plans%rowtype;
  profile public.profiles%rowtype;
  base_time timestamptz;
  new_expiry timestamptz;
begin
  select * into tx
  from public.subscription_transactions
  where provider_transaction_id = p_provider_transaction_id
  for update;
  if not found then return jsonb_build_object('ok', false, 'status', 'unknown'); end if;

  if lower(p_status) not in ('paid', 'success', 'completed') then
    update public.subscription_transactions
    set status = case when lower(p_status) = 'cancelled' then 'cancelled' else 'failed' end
    where id = tx.id and status = 'pending';
    return jsonb_build_object('ok', false, 'status', 'failed');
  end if;

  if tx.status = 'paid' then
    return jsonb_build_object('ok', true, 'status', 'active', 'user_id', tx.user_id,
      'plan', tx.plan_id, 'expires_at', tx.expires_at);
  end if;
  if tx.status <> 'pending' then
    return jsonb_build_object('ok', false, 'status', tx.status);
  end if;

  -- A paid provider response is not enough by itself. The verified response
  -- must match the currency and the server-authoritative plan amount exactly.
  if p_provider_amount is null
     or upper(trim(coalesce(p_provider_currency, ''))) <> 'BDT'
     or abs(p_provider_amount - tx.amount_bdt) > 0.001 then
    update public.subscription_transactions
    set status = 'invalid', verified_at = now()
    where id = tx.id and status = 'pending';
    return jsonb_build_object('ok', false, 'status', 'invalid');
  end if;

  select * into plan from public.subscription_plans where id = tx.plan_id and is_active;
  if not found then raise exception 'Inactive subscription plan'; end if;
  select * into profile from public.profiles where id = tx.user_id for update;
  if not found then raise exception 'Profile not found'; end if;

  base_time := greatest(coalesce(profile.subscription_expires_at, now()), now());
  new_expiry := case when plan.duration_days is null then null
    else base_time + make_interval(days => plan.duration_days) end;

  update public.subscription_transactions
  set status = 'paid', verified_at = now(), expires_at = new_expiry
  where id = tx.id;
  update public.profiles
  set subscription_plan = tx.plan_id,
      subscription_status = 'active',
      subscription_started_at = coalesce(profile.subscription_started_at, now()),
      subscription_expires_at = new_expiry,
      subscription_provider = tx.provider,
      subscription_transaction_id = tx.provider_transaction_id,
      subscription_updated_at = now(),
      -- Keep the old columns as migration history/compatibility only.
      is_pro = true,
      pro_plan = tx.plan_id,
      pro_until = new_expiry,
      pro_updated_at = now()
  where id = tx.user_id;

  return jsonb_build_object('ok', true, 'status', 'active', 'user_id', tx.user_id,
    'plan', tx.plan_id, 'expires_at', new_expiry);
end $$;

-- Atomically claim one AI request under the effective, non-expired plan.
create or replace function public.claim_ai_request(p_user_id uuid)
returns table(allowed boolean, request_count integer, daily_limit integer,
              usage_date date, reason text)
language plpgsql
security definer
set search_path = public
as $$
declare
  p public.profiles%rowtype;
  plan_row public.subscription_plans%rowtype;
  day date := (now() at time zone 'Asia/Dhaka')::date;
  current_count integer;
  effective_plan text;
begin
  if auth.uid() is not null and auth.uid() <> p_user_id then
    raise exception 'Not allowed';
  end if;
  select * into p from public.profiles where id = p_user_id;
  effective_plan := case
    when p.subscription_plan <> 'free'
      and p.subscription_status = 'active'
      and (p.subscription_expires_at is null or p.subscription_expires_at > now())
      then p.subscription_plan
    else 'free'
  end;
  select * into plan_row from public.subscription_plans where id = effective_plan;
  if not found then
    select * into plan_row from public.subscription_plans where id = 'free';
  end if;

  insert into public.ai_usage_daily(user_id, usage_date, request_count)
  values (p_user_id, day, 0)
  on conflict on constraint ai_usage_daily_pkey do nothing;
  select u.request_count into current_count
  from public.ai_usage_daily as u
  where u.user_id = p_user_id and u.usage_date = day
  for update;

  if plan_row.ai_daily_limit <= 0 then
    return query select false, current_count, plan_row.ai_daily_limit, day, 'upgrade_required';
    return;
  end if;
  if current_count >= plan_row.ai_daily_limit then
    return query select false, current_count, plan_row.ai_daily_limit, day, 'daily_limit';
    return;
  end if;
  update public.ai_usage_daily as u
  set request_count = u.request_count + 1, updated_at = now()
  where u.user_id = p_user_id and u.usage_date = day
  returning u.request_count into current_count;
  return query select true, current_count, plan_row.ai_daily_limit, day, 'ok';
end $$;

create or replace function public.refund_ai_request(
  p_user_id uuid,
  p_usage_date date default (now() at time zone 'Asia/Dhaka')::date
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare result integer;
begin
  update public.ai_usage_daily
  set request_count = greatest(request_count - 1, 0), updated_at = now()
  where user_id = p_user_id and usage_date = p_usage_date
  returning request_count into result;
  return coalesce(result, 0);
end $$;

-- Admin-only read model for the web studio. It avoids granting broad profile
-- access while exposing the operational fields needed by subscription staff.
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
  ai_daily_limit integer
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_question_admin() then raise exception 'Administrator access required'; end if;
  return query
  select p.id, p.email, p.name, p.subscription_plan, p.subscription_status,
         p.subscription_started_at, p.subscription_expires_at,
         p.subscription_provider, p.subscription_transaction_id,
         coalesce(u.request_count, 0), coalesce(sp.ai_daily_limit, 0)
  from public.profiles p
  left join public.subscription_plans sp on sp.id = p.subscription_plan
  left join public.ai_usage_daily u
    on u.user_id = p.id
   and u.usage_date = (now() at time zone 'Asia/Dhaka')::date
  order by p.email;
end $$;

grant execute on function public.admin_subscription_overview() to authenticated;

-- The promotion studio's old paid audience policy used the legacy is_pro
-- flag. Keep the policy name/API stable while making its decision use the
-- effective centralized entitlement instead.
do $$
begin
  if to_regclass('public.app_notifications') is not null then
    execute 'drop policy if exists app_notifications_user_read on public.app_notifications';
    execute $policy$
      create policy app_notifications_user_read on public.app_notifications
      for select to authenticated
      using (
        is_active and sent_at is not null and sent_at <= now()
        and (scheduled_at is null or scheduled_at <= now())
        and (
          audience = 'all'
          or (audience = 'free' and exists (
            select 1 from public.profiles p
            where p.id = auth.uid()
              and (p.subscription_plan = 'free'
                or p.subscription_status <> 'active'
                or (p.subscription_expires_at is not null
                  and p.subscription_expires_at <= now()))
          ))
          or (audience = 'pro' and exists (
            select 1 from public.profiles p
            where p.id = auth.uid()
              and p.subscription_plan <> 'free'
              and p.subscription_status = 'active'
              and (p.subscription_expires_at is null
                or p.subscription_expires_at > now())
          ))
        )
      )
    $policy$;
  end if;
end $$;

revoke all on function public.activate_subscription_transaction(text, text, numeric, text) from public, anon, authenticated;
revoke all on function public.claim_ai_request(uuid) from public, anon, authenticated;
revoke all on function public.refund_ai_request(uuid, date) from public, anon, authenticated;
grant execute on function public.activate_subscription_transaction(text, text, numeric, text) to service_role;
grant execute on function public.claim_ai_request(uuid) to service_role;
grant execute on function public.refund_ai_request(uuid, date) to service_role;

grant select on public.subscription_plans to anon, authenticated;
grant select on public.subscription_transactions, public.user_subjects, public.ai_usage_daily to authenticated;
grant insert, update, delete on public.user_subjects to authenticated;

commit;
