-- Tutor's Desk — Offers, prizes, in-app announcements and offer ads.
-- Run after 20260925000001_content_manager.sql and the bKash migration.
-- This does not create an administrator or expose payment secrets.
begin;

create table if not exists public.paid_plan_offers (
  id text primary key check (id ~ '^[a-zA-Z0-9_-]+$'),
  plan_id text not null check (plan_id in ('monthly', 'yearly', 'lifetime')),
  title text not null,
  description text not null default '',
  price numeric(10,2) not null check (price >= 0),
  currency text not null default 'BDT' check (currency in ('BDT', 'USD')),
  period_days integer check (period_days is null or period_days > 0),
  badge text not null default '',
  is_active boolean not null default false,
  starts_at timestamptz,
  ends_at timestamptz,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at > starts_at)
);

create table if not exists public.prizes (
  id text primary key check (id ~ '^[a-zA-Z0-9_-]+$'),
  title text not null,
  description text not null default '',
  value_text text not null default '',
  image_url text not null default '',
  stock integer check (stock is null or stock >= 0),
  is_active boolean not null default false,
  starts_at timestamptz,
  ends_at timestamptz,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at > starts_at)
);

create table if not exists public.app_notifications (
  id text primary key check (id ~ '^[a-zA-Z0-9_-]+$'),
  title text not null,
  message text not null,
  audience text not null default 'all' check (audience in ('all', 'free', 'pro')),
  action_label text not null default '',
  action_url text not null default '',
  is_active boolean not null default false,
  scheduled_at timestamptz,
  sent_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_offer_ads (
  id text primary key check (id ~ '^[a-zA-Z0-9_-]+$'),
  title text not null,
  body text not null default '',
  image_url text not null default '',
  button_text text not null default 'View offer',
  button_url text not null default '/plans',
  offer_id text references public.paid_plan_offers(id) on delete set null,
  audience text not null default 'all' check (audience in ('all', 'free', 'pro')),
  is_active boolean not null default false,
  starts_at timestamptz,
  ends_at timestamptz,
  priority integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_at is null or starts_at is null or ends_at > starts_at)
);

create index if not exists paid_plan_offers_live on public.paid_plan_offers(is_active, sort_order);
create index if not exists prizes_live on public.prizes(is_active, sort_order);
create index if not exists app_notifications_live on public.app_notifications(is_active, sent_at, scheduled_at);
create index if not exists app_offer_ads_live on public.app_offer_ads(is_active, priority);

create or replace function public.touch_promotion_updated_at()
returns trigger language plpgsql set search_path=public as $$
begin
  new.updated_at = now();
  if tg_table_name = 'app_notifications' and new.is_active and new.sent_at is null then
    new.sent_at = case when new.scheduled_at is null or new.scheduled_at <= now() then now() else null end;
  end if;
  return new;
end $$;

-- Active promotional content must have a valid live window. RLS hides expired
-- rows from the app, but this trigger also prevents an administrator from
-- accidentally publishing an already-expired offer, prize or popup ad.
create or replace function public.validate_promotion_window()
returns trigger language plpgsql set search_path=public as $$
begin
  if new.starts_at is not null and new.ends_at is not null
     and new.starts_at >= new.ends_at then
    raise exception 'Promotion end time must be after start time';
  end if;
  if new.is_active and new.ends_at is not null and new.ends_at <= now() then
    raise exception 'An expired promotion cannot be activated';
  end if;
  return new;
end $$;

drop trigger if exists promotion_window_validate on public.paid_plan_offers;
create trigger promotion_window_validate before insert or update on public.paid_plan_offers
for each row execute function public.validate_promotion_window();
drop trigger if exists promotion_window_validate on public.prizes;
create trigger promotion_window_validate before insert or update on public.prizes
for each row execute function public.validate_promotion_window();
drop trigger if exists promotion_window_validate on public.app_offer_ads;
create trigger promotion_window_validate before insert or update on public.app_offer_ads
for each row execute function public.validate_promotion_window();

drop trigger if exists paid_plan_offers_touch on public.paid_plan_offers;
create trigger paid_plan_offers_touch before update on public.paid_plan_offers
for each row execute function public.touch_promotion_updated_at();
drop trigger if exists prizes_touch on public.prizes;
create trigger prizes_touch before update on public.prizes
for each row execute function public.touch_promotion_updated_at();
drop trigger if exists app_notifications_touch on public.app_notifications;
create trigger app_notifications_touch before insert or update on public.app_notifications
for each row execute function public.touch_promotion_updated_at();
drop trigger if exists app_offer_ads_touch on public.app_offer_ads;
create trigger app_offer_ads_touch before update on public.app_offer_ads
for each row execute function public.touch_promotion_updated_at();

alter table public.paid_plan_offers enable row level security;
alter table public.prizes enable row level security;
alter table public.app_notifications enable row level security;
alter table public.app_offer_ads enable row level security;

do $$
declare r record;
begin
  for r in select tablename, policyname from pg_policies
    where schemaname = 'public'
      and tablename in ('paid_plan_offers','prizes','app_notifications','app_offer_ads')
  loop
    execute format('drop policy if exists %I on public.%I', r.policyname, r.tablename);
  end loop;
end $$;

create policy paid_plan_offers_admin on public.paid_plan_offers for all to authenticated
  using (public.is_question_admin()) with check (public.is_question_admin());
create policy paid_plan_offers_public_read on public.paid_plan_offers for select to anon, authenticated
  using (is_active and (starts_at is null or starts_at <= now()) and (ends_at is null or ends_at > now()));

create policy prizes_admin on public.prizes for all to authenticated
  using (public.is_question_admin()) with check (public.is_question_admin());
create policy prizes_public_read on public.prizes for select to anon, authenticated
  using (is_active and (starts_at is null or starts_at <= now()) and (ends_at is null or ends_at > now()));

create policy app_notifications_admin on public.app_notifications for all to authenticated
  using (public.is_question_admin()) with check (public.is_question_admin());
create policy app_notifications_user_read on public.app_notifications for select to authenticated
  using (
    is_active and sent_at is not null and sent_at <= now()
    and (scheduled_at is null or scheduled_at <= now())
    and (
      audience = 'all'
      or (audience = 'free' and exists (select 1 from public.profiles p where p.id = auth.uid() and not coalesce(p.is_pro, false)))
      or (audience = 'pro' and exists (select 1 from public.profiles p where p.id = auth.uid() and coalesce(p.is_pro, false)))
    )
  );

create policy app_offer_ads_admin on public.app_offer_ads for all to authenticated
  using (public.is_question_admin()) with check (public.is_question_admin());
create policy app_offer_ads_public_read on public.app_offer_ads for select to anon, authenticated
  using (is_active and (starts_at is null or starts_at <= now()) and (ends_at is null or ends_at > now()));

grant select on public.paid_plan_offers, public.prizes, public.app_offer_ads to anon, authenticated;
grant select on public.app_notifications to authenticated;
grant insert, update, delete on public.paid_plan_offers, public.prizes, public.app_notifications, public.app_offer_ads to authenticated;

-- A separate public bucket keeps promotional images out of question figures.
insert into storage.buckets (id, name, public)
values ('promotion-assets', 'promotion-assets', true)
on conflict (id) do update set public = true;

drop policy if exists promotion_assets_public_read on storage.objects;
create policy promotion_assets_public_read on storage.objects for select
using (bucket_id = 'promotion-assets');
drop policy if exists promotion_assets_admin_write on storage.objects;
create policy promotion_assets_admin_write on storage.objects for insert to authenticated
with check (bucket_id = 'promotion-assets' and public.is_question_admin());
drop policy if exists promotion_assets_admin_update on storage.objects;
create policy promotion_assets_admin_update on storage.objects for update to authenticated
using (bucket_id = 'promotion-assets' and public.is_question_admin())
with check (bucket_id = 'promotion-assets' and public.is_question_admin());
drop policy if exists promotion_assets_admin_delete on storage.objects;
create policy promotion_assets_admin_delete on storage.objects for delete to authenticated
using (bucket_id = 'promotion-assets' and public.is_question_admin());

commit;
