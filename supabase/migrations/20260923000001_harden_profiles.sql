-- ─────────────────────────────────────────────────────────────────────
-- Tutor's Desk — Phase 1 security hardening: profiles entitlement lock
--
-- Run in the Supabase SQL editor (safe to run twice):
--   https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/sql/new
--
-- What this does
--   1. Enables RLS on public.profiles (if not already).
--   2. DROPS every existing policy on profiles — whatever is there today
--      (including any permissive one) is replaced by the minimal set:
--        - a tutor may READ their own row
--        - a tutor may UPDATE their own row (name, phone, …)
--        - a tutor may INSERT their own row on first sign-in
--      No policy lets anyone read or touch another tutor's row.
--   3. Adds a trigger that FREEZES the entitlement columns
--      (is_pro, pro_until, pro_plan) for any write made with a user
--      token — even one's own row. The app client can no longer flip
--      itself to Pro, and a modified app cannot either.
--
-- Why Pro still works
--   The bKash edge function verifies the payment with bKash, then writes
--   the entitlement using the SERVICE ROLE key. Service-role writes run
--   without a user context (auth.uid() IS NULL), so the trigger leaves
--   them alone and RLS is bypassed by design for the service role.
--   That is the only path that may change Pro — exactly what we want.
-- ─────────────────────────────────────────────────────────────────────

alter table public.profiles enable row level security;

-- ── 1. Wipe whatever policies exist today ─────────────────────────────
do $$
declare
  p record;
begin
  for p in
    select polname
    from pg_policies
    where schemaname = 'public' and tablename = 'profiles'
  loop
    execute format('drop policy if exists %I on public.profiles', p.polname);
  end loop;
end $$;

-- ── 2. Minimal own-row policies ───────────────────────────────────────
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid());

create policy profiles_insert_own on public.profiles
  for insert to authenticated
  with check (id = auth.uid());

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- ── 3. Entitlement freeze for user-context writes ─────────────────────
-- Runs BEFORE every INSERT/UPDATE. A write made through the service
-- role has no user context (auth.uid() IS NULL) and passes untouched.
create or replace function public.protect_pro_entitlements()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is not null then
    if tg_op = 'INSERT' then
      new.is_pro := false;
      new.pro_until := null;
      new.pro_plan := null;
    elsif tg_op = 'UPDATE' then
      if (new.is_pro is distinct from old.is_pro)
          or (new.pro_until is distinct from old.pro_until)
          or (new.pro_plan is distinct from old.pro_plan) then
        new.is_pro := old.is_pro;
        new.pro_until := old.pro_until;
        new.pro_plan := old.pro_plan;
      end if;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists profiles_protect_pro on public.profiles;
create trigger profiles_protect_pro
  before insert or update on public.profiles
  for each row execute function public.protect_pro_entitlements();

-- ── 4. Sanity: nobody except the service role should have bypass ──────
-- (informational — the audit script reports this too)
-- The postgres/service_role roles are managed by Supabase itself.
