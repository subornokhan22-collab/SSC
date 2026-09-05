-- Tutor's Desk — questions table
--
-- Run this once in the Supabase SQL editor:
--   https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/sql/new
-- Paste the whole file, press Run. It is safe to run twice.

create table if not exists public.questions (
  id           text primary key,          -- e.g. bio_adm03_mcq_001
  type         text not null check (type in ('mcq','saq','cq')),
  subject_id   text not null,
  chapter      text not null,
  payload      jsonb not null,            -- type-specific fields
  figure       jsonb,                     -- optional image/table/diagram
  source       text not null default 'original',
  source_label text,
  owner_id     uuid references auth.users(id) on delete set null,
  is_active    boolean not null default true,
  updated_at   timestamptz not null default now()
);

-- The app asks "anything newer than X?", so updated_at must be indexed.
create index if not exists questions_updated_idx on public.questions (updated_at);
create index if not exists questions_subject_idx on public.questions (subject_id, chapter);
create index if not exists questions_owner_idx   on public.questions (owner_id);

-- Keep updated_at honest on edits, so the delta sync notices them.
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists questions_touch on public.questions;
create trigger questions_touch before update on public.questions
  for each row execute function public.touch_updated_at();

-- ── Row level security ────────────────────────────────────────────────
-- owner_id IS NULL  = official content, readable by everyone.
-- owner_id = a user = that tutor's own questions, private to them.
-- Included from day one so per-teacher questions later need no migration.

alter table public.questions enable row level security;

drop policy if exists questions_read on public.questions;
create policy questions_read on public.questions
  for select
  using (owner_id is null or owner_id = auth.uid());

drop policy if exists questions_insert_own on public.questions;
create policy questions_insert_own on public.questions
  for insert to authenticated
  with check (owner_id = auth.uid());

drop policy if exists questions_update_own on public.questions;
create policy questions_update_own on public.questions
  for update to authenticated
  using (owner_id = auth.uid());

drop policy if exists questions_delete_own on public.questions;
create policy questions_delete_own on public.questions
  for delete to authenticated
  using (owner_id = auth.uid());

-- Official rows (owner_id null) are deliberately writable only with the
-- service key — that is, from the admin panel, never from the app.

-- ── Figure images ─────────────────────────────────────────────────────
-- A public bucket for question pictures. Public read is fine: these are
-- exam diagrams, and the app fetches them without signing in.

insert into storage.buckets (id, name, public)
values ('question-figures', 'question-figures', true)
on conflict (id) do nothing;

drop policy if exists figures_public_read on storage.objects;
create policy figures_public_read on storage.objects
  for select using (bucket_id = 'question-figures');
