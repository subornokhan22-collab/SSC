-- Tutor's Desk — bKash payment support
-- Run once in: Supabase dashboard → SQL Editor → New query → paste → Run.

-- 1) Subscription columns on the existing profiles table.
alter table public.profiles
  add column if not exists pro_until timestamptz;
alter table public.profiles
  add column if not exists pro_plan text;
alter table public.profiles
  add column if not exists pro_updated_at timestamptz;

-- 2) Payments initiated by the app (written by the "bkash" edge function,
--    which uses the service role). No client policies = nobody can read or
--    write these rows from the app; only the function can.
create table if not exists public.bkash_payments (
  id bigint generated always as identity primary key,
  trxid text not null unique,
  email text not null default '',
  user_id uuid not null,
  plan text not null,
  amount numeric not null,
  created_at timestamptz not null default now()
);

alter table public.bkash_payments enable row level security;
