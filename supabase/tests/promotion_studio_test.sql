\set ON_ERROR_STOP on

do $$begin
  if not exists(select 1 from pg_roles where rolname='anon') then create role anon; end if;
  if not exists(select 1 from pg_roles where rolname='authenticated') then create role authenticated; end if;
end$$;
create schema auth;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
create table auth.users(id uuid primary key, email text);
create table public.profiles(id uuid primary key, is_pro boolean not null default false);
create schema storage;
create table storage.buckets(id text primary key, name text not null, public boolean not null default false);
create table storage.objects(id text primary key, bucket_id text not null);
grant usage on schema auth, public, storage to anon, authenticated;
grant select on public.profiles to anon, authenticated;
\ir ../migrations/20260925000001_content_manager.sql
\ir ../migrations/20260929000002_promotion_studio.sql

create function public.test_assert(ok boolean, message text) returns void
language plpgsql as $$begin
  if ok is distinct from true then raise exception 'FAIL: %', message; end if;
end$$;
create function public.test_reject(query text) returns void
language plpgsql as $$begin
  begin execute query;
  exception when others then return;
  end;
  raise exception 'FAIL: query unexpectedly accepted: %', query;
end$$;

insert into auth.users values
  ('11111111-1111-4111-8111-111111111111', 'admin'),
  ('22222222-2222-4222-8222-222222222222', 'teacher');
insert into profiles values ('11111111-1111-4111-8111-111111111111', false),
  ('22222222-2222-4222-8222-222222222222', false);
insert into question_admins(user_id) values ('11111111-1111-4111-8111-111111111111');

set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-4111-8111-111111111111', true);
insert into paid_plan_offers(id, plan_id, title, price, starts_at, ends_at, is_active)
values ('future', 'monthly', 'Future', 299, now() + interval '1 day', now() + interval '2 days', true);
select test_reject($q$insert into prizes(id,title,starts_at,ends_at,is_active)
  values ('bad_order','Bad',now() + interval '2 days',now() + interval '1 day',false)$q$);
select test_reject($q$insert into app_offer_ads(id,title,starts_at,ends_at,is_active)
  values ('expired','Expired',now() - interval '2 days',now() - interval '1 day',true)$q$);
select test_reject($q$update paid_plan_offers set ends_at=now() - interval '1 minute' where id='future'$q$);

set local role anon;
select set_config('request.jwt.claim.sub', '', true);
select test_assert((select count(*) = 0 from paid_plan_offers), 'future offer is hidden by the public time-window policy');

rollback;
