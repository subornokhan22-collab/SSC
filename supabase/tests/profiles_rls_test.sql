-- DISPOSABLE DATABASE ONLY. CI uses an empty PostgreSQL service, not Supabase.
-- Run from any cwd: psql "$TEST_DATABASE_URL" -v ON_ERROR_STOP=1 -f this-file.sql
\set ON_ERROR_STOP on
begin;

create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create schema auth;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;
create table auth.users (id uuid primary key, email text);
create table public.profiles (
  id uuid primary key,
  email text,
  name text,
  is_pro boolean default false,
  pro_until timestamptz,
  pro_plan text,
  pro_updated_at timestamptz
);
create table public.question_admins (user_id uuid primary key, note text);
create table public.questions (id text primary key);
alter table public.question_admins enable row level security;
alter table public.questions enable row level security;

create policy old_permissive_policy on public.profiles for all using (true);
grant usage on schema public, auth to anon, authenticated, service_role;
grant select, insert, update on public.profiles to anon, authenticated, service_role;

\ir ../migrations/20260923000001_harden_profiles.sql
-- A second application must replace policies and the trigger without error.
\ir ../migrations/20260923000001_harden_profiles.sql

create function public.test_assert(ok boolean, message text) returns void
language plpgsql as $$
begin
  if ok is distinct from true then raise exception 'FAIL: %', message; end if;
end $$;

select public.test_assert((select count(*) = 3 from pg_policies
  where schemaname = 'public' and tablename = 'profiles'), 'exactly three policies');
select public.test_assert(not exists(select 1 from pg_policies
  where policyname = 'old_permissive_policy'), 'old permissive policy removed');

-- Seed a second account using the privileged connection.
insert into public.profiles(id, name, is_pro, pro_plan)
values ('22222222-2222-4222-8222-222222222222', 'Other teacher', true, 'yearly');

set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-4111-8111-111111111111', true);

-- First signup cannot insert premium entitlements.
insert into public.profiles(id, name, is_pro, pro_until, pro_plan)
values (auth.uid(), 'Teacher', true, now() + interval '1 year', 'yearly');
select public.test_assert((select not is_pro and pro_until is null and pro_plan is null
  from public.profiles where id = auth.uid()), 'insert entitlements reset');
select public.test_assert((select count(*) = 1 from public.profiles), 'own-row SELECT only');

-- Editable profile fields still work while entitlement changes are reverted.
update public.profiles set name = 'Renamed', is_pro = true,
  pro_until = now() + interval '1 year', pro_plan = 'yearly' where id = auth.uid();
select public.test_assert((select name = 'Renamed' and not is_pro and
  pro_until is null and pro_plan is null from public.profiles where id = auth.uid()),
  'profile edits allowed, self-upgrade blocked');

-- RLS hides the other user's row from UPDATE, too.
with touched as (
  update public.profiles set name = 'Hacked'
  where id = '22222222-2222-4222-8222-222222222222' returning id
)
select public.test_assert((select count(*) = 0 from touched), 'cross-user UPDATE blocked');

do $$
begin
  begin
    insert into public.profiles(id) values ('33333333-3333-4333-8333-333333333333');
    raise exception 'FAIL: cross-user INSERT succeeded';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.profiles set id = '33333333-3333-4333-8333-333333333333'
    where id = auth.uid();
    raise exception 'FAIL: moving profile to another user succeeded';
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;
select set_config('request.jwt.claim.sub', '', true);
set local role anon;
select public.test_assert((select count(*) = 0 from public.profiles), 'anonymous reads blocked');
do $$
begin
  begin
    insert into public.profiles(id) values ('44444444-4444-4444-8444-444444444444');
    raise exception 'FAIL: anonymous INSERT succeeded';
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;
set local role service_role;
update public.profiles set is_pro = true, pro_plan = 'monthly',
  pro_until = '2030-01-01T00:00:00Z' where id = '11111111-1111-4111-8111-111111111111';
select public.test_assert((select is_pro and pro_plan = 'monthly' from public.profiles
  where id = '11111111-1111-4111-8111-111111111111'), 'service role can grant Pro');

reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-4111-8111-111111111111', true);
update public.profiles set name = 'Paid teacher', is_pro = false, pro_until = null, pro_plan = null
where id = auth.uid();
select public.test_assert((select name = 'Paid teacher' and is_pro and
  pro_plan = 'monthly' and pro_until = '2030-01-01T00:00:00Z' from public.profiles
  where id = auth.uid()), 'user cannot alter existing paid entitlement');

reset role;
select set_config('request.jwt.claim.sub', '', true);
select public.test_assert((select name = 'Other teacher' from public.profiles
  where id = '22222222-2222-4222-8222-222222222222'), 'other profile unchanged');
-- Also validate that the audit is executable SQL against the expected schema.
\ir ../audit_rls.sql
rollback;
\echo 'Profile RLS regression tests passed (all fixture changes rolled back).'
