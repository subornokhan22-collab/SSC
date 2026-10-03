-- Disposable PostgreSQL regression test for the subscription migration.
-- This models the small portion of the Supabase baseline used by the migration.
\set ON_ERROR_STOP on
begin;

create extension if not exists pgcrypto;
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create schema auth;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;
create function auth.role() returns text language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claim.role', true), ''), current_user);
$$;
create table auth.users(id uuid primary key, email text);
create table public.question_admins(user_id uuid primary key);
create table public.profiles(
  id uuid primary key,
  email text,
  name text,
  role text not null default 'teacher',
  is_pro boolean not null default false,
  pro_until timestamptz,
  pro_plan text,
  pro_updated_at timestamptz
);

alter table public.profiles enable row level security;
grant usage on schema public, auth to anon, authenticated, service_role;
grant select, insert, update on public.profiles to authenticated, service_role;
create policy profiles_select_own on public.profiles for select
  to authenticated using (id = auth.uid());
create policy profiles_insert_own on public.profiles for insert
  to authenticated with check (id = auth.uid());
create policy profiles_update_own on public.profiles for update
  to authenticated using (id = auth.uid()) with check (id = auth.uid());

create function public.is_question_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.question_admins where user_id = auth.uid());
$$;

\ir ../migrations/20261003000001_subscription_architecture.sql

create function public.test_assert(ok boolean, message text) returns void
language plpgsql as $$
begin
  if ok is distinct from true then raise exception 'FAIL: %', message; end if;
end $$;

select public.test_assert(
  (select array_agg(id order by sort_order) = array['free','basic','pro','professional']::text[]
   from public.subscription_plans),
  'stable server plan matrix');

insert into auth.users(id, email)
values ('11111111-1111-4111-8111-111111111111', 'teacher@example.com');
insert into public.profiles(id, email, name, role)
values ('11111111-1111-4111-8111-111111111111', 'teacher@example.com', 'Teacher', 'teacher');
begin;
select set_config('request.jwt.claim.sub', '11111111-1111-4111-8111-111111111111', true);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

-- A client may edit profile identity, but cannot self-activate or alter the
-- server-authoritative plan, dates, payment provider, or AI counters.
update public.profiles set name = 'Renamed' where id = auth.uid();
update public.profiles
   set subscription_plan = 'professional',
       subscription_expires_at = now() + interval '1 year'
 where id = auth.uid();
select public.test_assert(
  (select subscription_plan = 'free' and subscription_expires_at is null
   from public.profiles where id = auth.uid()),
  'client subscription authority edit reverted');

-- Client roles can read their own plan/transaction/usage state, but cannot
-- write any authority rows.
select public.test_assert((select count(*) = 4 from public.subscription_plans),
  'authenticated can read plan matrix');
do $$
begin
  begin
    insert into public.subscription_transactions(user_id, plan_id, amount_bdt, provider_transaction_id)
    values (auth.uid(), 'pro', 1, 'client-forged');
    raise exception 'FAIL: client inserted transaction';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.ai_usage_daily(user_id, usage_date, request_count)
    values (auth.uid(), (now() at time zone 'Asia/Dhaka')::date, 999);
    raise exception 'FAIL: client inserted AI usage';
  exception when insufficient_privilege then null;
  end;
end $$;

-- Service-side activation is idempotent and extends from an active expiry.
reset role;
select set_config('request.jwt.claim.role', 'service_role', true);
select set_config('request.jwt.claim.sub', '', true);
update public.profiles set subscription_plan = 'pro',
  subscription_status = 'active',
  subscription_started_at = now() - interval '1 day',
  subscription_expires_at = now() + interval '10 days'
where id = '11111111-1111-4111-8111-111111111111';
insert into public.subscription_transactions(
  user_id, plan_id, amount_bdt, provider_transaction_id, status
) values (
  '11111111-1111-4111-8111-111111111111', 'pro', 200, 'fixture-transaction-1', 'pending'
);
select public.activate_subscription_transaction('fixture-transaction-1');
select public.test_assert(
  (select status = 'paid' and provider_transaction_id = 'fixture-transaction-1'
   from public.subscription_transactions where provider_transaction_id = 'fixture-transaction-1'),
  'verified transaction completed');
select public.test_assert(
  (select subscription_expires_at > now() + interval '39 days'
   from public.profiles where id = '11111111-1111-4111-8111-111111111111'),
  'activation extends from current active expiry');
select public.activate_subscription_transaction('fixture-transaction-1');
select public.test_assert(
  (select count(*) = 1 from public.subscription_transactions
   where provider_transaction_id = 'fixture-transaction-1' and status = 'paid'),
  'repeated activation remains idempotent');

insert into public.subscription_transactions(
  user_id, plan_id, amount_bdt, provider_transaction_id, status
) values
  ('11111111-1111-4111-8111-111111111111', 'basic', 100, 'fixture-cancelled', 'pending'),
  ('11111111-1111-4111-8111-111111111111', 'professional', 400, 'fixture-invalid', 'pending');
select public.activate_subscription_transaction('fixture-cancelled', 'cancelled');
select public.activate_subscription_transaction('fixture-invalid', 'invalid');
select public.test_assert(
  (select status = 'cancelled' from public.subscription_transactions
   where provider_transaction_id = 'fixture-cancelled'),
  'cancelled payment does not activate');
select public.test_assert(
  (select status = 'failed' from public.subscription_transactions
   where provider_transaction_id = 'fixture-invalid'),
  'invalid payment does not activate');
select public.test_assert(
  (select subscription_plan = 'pro' from public.profiles
   where id = '11111111-1111-4111-8111-111111111111'),
  'failed payments leave the active subscription unchanged');

-- The atomic daily claim is keyed to the Asia/Dhaka date and preserves usage
-- when the same account upgrades from Pro to Professional.
select * from public.claim_ai_request('11111111-1111-4111-8111-111111111111');
select public.test_assert(
  (select request_count = 1 from public.ai_usage_daily
   where user_id = '11111111-1111-4111-8111-111111111111'),
  'AI claim increments exactly once');
update public.profiles set subscription_plan = 'professional'
where id = '11111111-1111-4111-8111-111111111111';
select * from public.claim_ai_request('11111111-1111-4111-8111-111111111111');
select public.test_assert(
  (select request_count = 2 from public.ai_usage_daily
   where user_id = '11111111-1111-4111-8111-111111111111'),
  'same-day upgrade carries usage forward');

rollback;
