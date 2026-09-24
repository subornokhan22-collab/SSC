-- ─────────────────────────────────────────────────────────────────────
-- Tutor's Desk — RLS audit (READ-ONLY, safe to run any time)
--
-- Run in the SQL editor, copy the output and share it. It reports:
--   1. every table + whether RLS is enabled
--   2. every policy on the security-sensitive tables
--   3. who the question admins are
--   4. roles that bypass RLS (only Supabase's own should appear)
-- ─────────────────────────────────────────────────────────────────────

\pset pager off

select '── 1. tables & RLS status' as section;
select tablename,
       rowsecurity as rls_enabled,
       (select count(*) from pg_policies p
         where p.schemaname = 'public' and p.tablename = t.tablename) as policy_count
from pg_tables t
where schemaname = 'public'
order by tablename;

select '── 2. policies on security-sensitive tables' as section;
select tablename, policyname, permissive, roles::text as role_names,
       cmd, coalesce(qual, with_check)::text as using_or_check
from pg_policies
where schemaname = 'public'
  and tablename in ('profiles', 'questions', 'question_admins')
order by tablename, policyname;

select '── storage policies (question-figures bucket)' as section;
select tablename, policyname, permissive, roles::text as role_names,
       cmd, coalesce(qual, with_check)::text as using_or_check
from pg_policies
where schemaname = 'storage'
order by tablename, policyname;

select '── 3. question admins (who can publish official questions)' as section;
select a.user_id, a.note, u.email
from public.question_admins a
left join auth.users u on u.id = a.user_id;

select '── 4. roles that bypass RLS (should be Supabase-managed only)' as section;
select rolname, rolsuper, rolbypassrls, rolcanlogin
from pg_roles
where rolbypassrls or rolsuper
order by rolname;

select '── 5. Pro entitlements right now (who is Pro, until when)' as section;
select id, email, name, is_pro, pro_until, pro_plan, pro_updated_at
from public.profiles
order by pro_updated_at desc nulls last;

select '── 6. entitlement freeze trigger present?' as section;
select tgname, tgtype
from pg_trigger
where tgrelid = 'public.profiles'::regclass
  and not tgisinternal;
