-- Optional Supabase Storage setup. Run after the content-manager migration.
-- ── Figure images ─────────────────────────────────────────────────────
-- A public bucket for question pictures. Public read is fine: these are
-- exam diagrams, and the app fetches them without signing in.

insert into storage.buckets (id, name, public)
values ('question-figures', 'question-figures', true)
on conflict (id) do nothing;

-- Anyone (including the app, signed out) may read a figure.
drop policy if exists figures_public_read on storage.objects;
create policy figures_public_read on storage.objects
  for select using (bucket_id = 'question-figures');

-- Uploading needs its own policy: a select policy does not grant insert, so
-- without this every upload fails with
--   403 "new row violates row-level security policy".
-- Limited to publishers, matching who may publish official questions.
drop policy if exists figures_admin_write on storage.objects;
create policy figures_admin_write on storage.objects
  for insert to authenticated
  with check (bucket_id = 'question-figures' and public.is_question_admin());

drop policy if exists figures_admin_update on storage.objects;
create policy figures_admin_update on storage.objects
  for update to authenticated
  using (bucket_id = 'question-figures' and public.is_question_admin());

drop policy if exists figures_admin_delete on storage.objects;
create policy figures_admin_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'question-figures' and public.is_question_admin());
