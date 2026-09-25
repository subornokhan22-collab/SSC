-- GENERATED bootstrap: canonical migration + Supabase Storage policies.
-- Existing admin memberships are retained; no email address gains access here.
-- Content management, English papers and server-side review/audit boundaries.
-- Does not grant any new administrator membership. Existing admins are retained.
begin;
create table if not exists public.question_admins(user_id uuid primary key references auth.users(id) on delete cascade,note text);
alter table public.question_admins enable row level security;
create or replace function public.is_question_admin() returns boolean language sql stable security definer set search_path=public,pg_catalog as $$ select exists(select 1 from public.question_admins where user_id=auth.uid()) $$;
drop policy if exists admins_read_self on public.question_admins;
create policy admins_read_self on public.question_admins for select to authenticated using(user_id=auth.uid());
create table if not exists public.questions(id text primary key,type text not null check(type in('mcq','saq','cq')),subject_id text not null,chapter text not null,payload jsonb not null,figure jsonb,source text not null default 'original',source_label text,owner_id uuid references auth.users(id) on delete cascade,is_active boolean not null default true,updated_at timestamptz not null default now());
alter table public.questions drop constraint if exists questions_owner_id_fkey;
alter table public.questions add constraint questions_owner_id_fkey foreign key(owner_id) references auth.users(id) on delete cascade;
alter table public.questions add column if not exists review_status text not null default 'published' check(review_status in('draft','review','published'));
alter table public.questions alter column review_status set default 'draft';
alter table public.questions add column if not exists created_at timestamptz not null default now();
alter table public.questions add column if not exists created_by uuid references auth.users(id) on delete set null;
alter table public.questions add column if not exists archived_at timestamptz;
alter table public.questions add column if not exists metadata jsonb not null default '{}'::jsonb;
alter table public.questions add column if not exists search_text text generated always as(lower(id||' '||subject_id||' '||chapter||' '||coalesce(source_label,'')||' '||payload::text||' '||metadata::text)) stored;
create table if not exists public.english_papers(
 id text primary key,paper_type text not null check(paper_type in('first','second')),board text not null,year integer not null check(year between 2000 and 2100),subject text not null check(subject in('english_1st','english_2nd')),data jsonb not null,
 source text not null default 'board',source_label text,review_status text not null default 'draft' check(review_status in('draft','review','published')),is_active boolean not null default true,created_by uuid references auth.users(id) on delete set null,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),archived_at timestamptz,
 search_text text generated always as(lower(id||' '||board||' '||year::text||' '||coalesce(source_label,'')||' '||source||' '||data::text)) stored,
 check(subject=case paper_type when 'first' then 'english_1st' else 'english_2nd' end)
);
create table if not exists public.content_subjects(id text primary key,name text not null,chapters jsonb not null default '[]' check(jsonb_typeof(chapters)='array'),updated_at timestamptz not null default now());
create table if not exists public.admin_activity(id bigint generated always as identity primary key,admin_id uuid,action text not null,entity text not null,record_id text not null,created_at timestamptz not null default now(),metadata jsonb not null);
create index if not exists admin_activity_date on public.admin_activity(created_at desc);
create index if not exists english_papers_filters on public.english_papers(paper_type,board,year,review_status,is_active);
create index if not exists questions_cms_filters on public.questions(subject_id,review_status,is_active,id);

create or replace function public.validate_content_row() returns trigger language plpgsql set search_path=public,pg_catalog as $$
declare p jsonb;k text;v jsonb;cell jsonb;required_text text[];required_arrays text[];fields text[];n integer;width integer;
begin
 if TG_OP='INSERT' then new.created_by=auth.uid();new.created_at=now();else new.created_by=old.created_by;new.created_at=old.created_at;if new.id<>old.id then raise exception 'Record IDs are immutable';end if;end if;
 if new.id !~ '^[a-zA-Z0-9_-]+$' then raise exception 'Invalid record ID';end if;
 new.updated_at=clock_timestamp();
 if new.is_active=false then new.archived_at=coalesce(new.archived_at,now());else new.archived_at=null;end if;
 if TG_OP='INSERT' and new.review_status<>'draft' then raise exception 'New content must start as a draft';end if;
 if new.review_status='published' and (TG_OP='INSERT' or old.review_status not in('review','published')) then raise exception 'Save draft, submit for review, then publish';end if;
 if TG_OP='UPDATE' and old.review_status in('review','published') and new.review_status<>'draft' then
   if TG_TABLE_NAME='questions' then
     if new.payload is distinct from old.payload or new.figure is distinct from old.figure or new.chapter is distinct from old.chapter or new.subject_id is distinct from old.subject_id or new.type is distinct from old.type or new.source_label is distinct from old.source_label or new.source is distinct from old.source or new.metadata is distinct from old.metadata then raise exception 'Save changed published content as a draft before review';end if;
   else
     if new.data is distinct from old.data or new.paper_type is distinct from old.paper_type or new.board is distinct from old.board or new.year is distinct from old.year or new.source_label is distinct from old.source_label or new.source is distinct from old.source then raise exception 'Save changed published content as a draft before review';end if;
   end if;
 end if;
 if new.review_status='draft' then return new;end if;
 -- Archiving an unchanged published legacy row must remain possible.
 if TG_OP='UPDATE' and not new.is_active and old.is_active and to_jsonb(new)-array['is_active','archived_at','updated_at','search_text'] = to_jsonb(old)-array['is_active','archived_at','updated_at','search_text'] then return new;end if;
 if TG_TABLE_NAME='questions' then
   p=new.payload;
   if jsonb_typeof(p) is distinct from 'object' then raise exception 'Question payload must be an object';end if;
   if btrim(new.chapter)='' or btrim(new.subject_id)='' or new.subject_id in('english_1st','english_2nd') then raise exception 'Chapter/subject required; English must use English Papers';end if;
   if new.type in('mcq','saq') and (jsonb_typeof(p->'questionText') is distinct from 'string' or coalesce(btrim(p->>'questionText'),'')='') then raise exception 'Question text is required';end if;
   if new.type='mcq' then
     if jsonb_typeof(p->'options') is distinct from 'array' or jsonb_array_length(p->'options')<>4 then raise exception 'MCQ requires four options';end if;
     for v in select value from jsonb_array_elements(p->'options') loop if jsonb_typeof(v)<>'string' or btrim(v#>>'{}')='' then raise exception 'Empty MCQ option';end if;end loop;
     if (select count(distinct lower(btrim(value))) from jsonb_array_elements_text(p->'options'))<>4 then raise exception 'MCQ options must be distinct';end if;
     if jsonb_typeof(p->'correctIndex') is distinct from 'number' or not coalesce((p->>'correctIndex')~'^[0-3]$',false) or jsonb_typeof(p->'explanation') is distinct from 'string' or coalesce(btrim(p->>'explanation'),'')='' then raise exception 'MCQ answer/explanation not supplied';end if;
   elsif new.type='saq' then if jsonb_typeof(p->'answer') is distinct from 'string' or coalesce(btrim(p->>'answer'),'')='' then raise exception 'Short answer not supplied';end if;
   elsif new.type='cq' then
     foreach k in array array['stem','questionK','questionKh','questionG'] loop if jsonb_typeof(p->k) is distinct from 'string' or coalesce(btrim(p->>k),'')='' then raise exception 'CQ missing %',k;end if;end loop;
     if not((p->'marks'='[2,4,4]'::jsonb and coalesce(p->>'questionGh','')='') or (p->'marks'='[1,2,3,4]'::jsonb and coalesce(btrim(p->>'questionGh'),'')<>'')) then raise exception 'CQ marks and parts do not match';end if;
   end if;
   if new.figure->>'kind'='image' and coalesce(new.figure->>'imagePath','') !~ '^https://' then raise exception 'Figure URL must use HTTPS';end if;
   if position(chr(65533) in p::text)>0 then raise exception 'Corrupted Unicode';end if;
   if new.review_status='published' and new.is_active then
     perform pg_advisory_xact_lock(hashtextextended(new.subject_id||new.type||regexp_replace(lower(coalesce(p->>'questionText',p->>'stem')),'\s+',' ','g'),0));
     if exists(select 1 from public.questions q where q.id<>new.id and q.subject_id=new.subject_id and q.type=new.type and q.is_active and q.review_status='published' and regexp_replace(lower(coalesce(q.payload->>'questionText',q.payload->>'stem')),'\s+',' ','g')=regexp_replace(lower(coalesce(p->>'questionText',p->>'stem')),'\s+',' ','g')) then raise exception 'An identical published question already exists';end if;
   end if;
 else
   p=new.data;
   if p->>'schema_version' is distinct from '1' or btrim(new.board)='' then raise exception 'English schema version 1 and board are required';end if;
   if new.paper_type='first' then
     required_text=array['passage1Intro','passage1','q1Instr','q3Instr','q3Cloze','passage2Intro','passage2','q4Instr','q10Instr','q10Starter','q11'];
     required_arrays=array['q1','q2','q4Table','q6A','q6B','q6C','q7','q8','q9'];n=11;
   else
     required_text=array['q1Passage','q3Passage','q6Passage','q7Passage','q8Passage','q9Text','q10','q11','q12'];
     required_arrays=array['q1Box','q2','q3Box','q4','q5'];n=12;
   end if;
   foreach k in array required_text loop if jsonb_typeof(p->k) is distinct from 'string' or coalesce(btrim(p->>k),'')='' then raise exception 'English field % is required',k;end if;end loop;
   foreach k in array required_arrays loop if jsonb_typeof(p->k) is distinct from 'array' or jsonb_array_length(p->k)=0 then raise exception 'English array % is required',k;end if;end loop;
   if new.paper_type='first' then
     if jsonb_array_length(p->'q1')<>7 or jsonb_array_length(p->'q2')<>5 or jsonb_array_length(p->'q7')<>8 then raise exception 'First paper requires 7 Q1 items, 5 Q2 items and 8 Q7 items';end if;
     for v in select value from jsonb_array_elements(p->'q1') loop
       if jsonb_typeof(v->'stem') is distinct from 'string' or coalesce(btrim(v->>'stem'),'')='' or jsonb_typeof(v->'options') is distinct from 'array' or jsonb_array_length(v->'options')<>4 then raise exception 'Invalid reading MCQ';end if;
       for cell in select value from jsonb_array_elements(v->'options') loop if jsonb_typeof(cell)<>'string' or btrim(cell#>>'{}')='' then raise exception 'Empty English MCQ option';end if;end loop;
     end loop;
     fields=array['q2','q6A','q6B','q6C','q7','q8','q9'];
     width=0;
     for v in select value from jsonb_array_elements(p->'q4Table') loop
       if jsonb_typeof(v)<>'array' or jsonb_array_length(v)=0 then raise exception 'Empty table row';end if;
       if width=0 then width=jsonb_array_length(v);elsif jsonb_array_length(v)<>width then raise exception 'Table columns must align';end if;
       for cell in select value from jsonb_array_elements(v) loop if jsonb_typeof(cell)<>'string' then raise exception 'Table cells must be text';end if;end loop;
     end loop;
     if not exists(select 1 from jsonb_array_elements(p->'q4Table') r cross join lateral jsonb_array_elements_text(r) c where btrim(c.value)<>'') then raise exception 'Information table is empty';end if;
     if p ? 'q4BoldRows' then
       if jsonb_typeof(p->'q4BoldRows')<>'array' then raise exception 'Invalid table bold rows';end if;
       for v in select value from jsonb_array_elements(p->'q4BoldRows') loop if jsonb_typeof(v)<>'number' or (v#>>'{}')!~'^[0-9]+$' or (v#>>'{}')::numeric>=jsonb_array_length(p->'q4Table') then raise exception 'Invalid table bold row';end if;end loop;
     end if;
   else
     if jsonb_array_length(p->'q4')<>10 or jsonb_array_length(p->'q5')<>5 then raise exception 'Second paper requires 10 transformations and 5 tag questions';end if;
     fields=array['q1Box','q3Box','q5'];
     for v in select value from jsonb_array_elements(p->'q2') loop foreach k in array array['a','b','c'] loop if jsonb_typeof(v->k) is distinct from 'string' then raise exception 'Substitution table cells must be text';end if;end loop;end loop;
     for v in select value from jsonb_array_elements(p->'q4') loop foreach k in array array['sentence','direction'] loop if jsonb_typeof(v->k) is distinct from 'string' or btrim(v->>k)='' then raise exception 'Transformation requires sentence and direction';end if;end loop;end loop;
   end if;
   foreach k in array fields loop for v in select value from jsonb_array_elements(p->k) loop if jsonb_typeof(v)<>'string' or btrim(v#>>'{}')='' then raise exception 'English list % requires text',k;end if;end loop;end loop;
   foreach k in array array['passage1Unit','q3Source','q3Unit'] loop if p ? k and jsonb_typeof(p->k)<>'string' then raise exception 'Optional text % must be text',k;end if;end loop;
   if p ? 'headerExtra' then if jsonb_typeof(p->'headerExtra')<>'array' then raise exception 'Header lines must be an array';end if;for v in select value from jsonb_array_elements(p->'headerExtra') loop if jsonb_typeof(v)<>'string' then raise exception 'Header lines must be text';end if;end loop;end if;
   if jsonb_typeof(p->'answers') is distinct from 'object' then raise exception 'Answer provenance map required (null means not supplied)';end if;
   for i in 1..n loop if coalesce(jsonb_typeof(p->'answers'->('q'||i)),'null') not in('null','string') then raise exception 'Answers must be source text or null';end if;end loop;
   if position(chr(65533) in p::text)>0 then raise exception 'Corrupted Unicode';end if;
 end if;
 return new;
end $$;
-- Supersedes the legacy timestamp trigger; otherwise it runs after validation.
drop trigger if exists questions_touch on public.questions;
drop trigger if exists content_validate on public.questions;
create trigger content_validate before insert or update on public.questions for each row execute function public.validate_content_row();
drop trigger if exists content_validate on public.english_papers;
create trigger content_validate before insert or update on public.english_papers for each row execute function public.validate_content_row();

create or replace function public.audit_content_change() returns trigger language plpgsql security definer set search_path=public,pg_catalog as $$
declare a text;oldrow jsonb;newrow jsonb;rid text;
begin
 oldrow=case when TG_OP='INSERT' then null else to_jsonb(old) end;newrow=case when TG_OP='DELETE' then null else to_jsonb(new) end;
 if TG_TABLE_NAME='questions' and (newrow->>'owner_id' is not null or oldrow->>'owner_id' is not null) then return coalesce(new,old);end if;
 rid=coalesce(newrow,oldrow)->>'id';a=lower(TG_OP);
 if TG_OP='UPDATE' then
   if oldrow->>'is_active'='true' and newrow->>'is_active'='false' then a='archive';
   elsif oldrow->>'is_active'='false' and newrow->>'is_active'='true' then a='restore';
   elsif oldrow->>'review_status' is distinct from newrow->>'review_status' then a=newrow->>'review_status';end if;
 end if;
 insert into public.admin_activity(admin_id,action,entity,record_id,metadata) values(auth.uid(),a,TG_TABLE_NAME,rid,jsonb_build_object('before',oldrow,'after',newrow));
 return coalesce(new,old);
end $$;
drop trigger if exists content_audit on public.questions;
create trigger content_audit after insert or update or delete on public.questions for each row execute function public.audit_content_change();
drop trigger if exists content_audit on public.english_papers;
create trigger content_audit after insert or update or delete on public.english_papers for each row execute function public.audit_content_change();

drop trigger if exists content_audit on public.content_subjects;
create trigger content_audit after insert or update or delete on public.content_subjects for each row execute function public.audit_content_change();

-- Public ID-only retirement markers also suppress shipped/bundled IDs.
-- The content payload and private-user IDs never enter this table.
create table if not exists public.question_tombstones(id text primary key,retired_at timestamptz not null default now());
alter table public.question_tombstones enable row level security;
drop policy if exists tombstones_public_read on public.question_tombstones;
create policy tombstones_public_read on public.question_tombstones for select using(true);
grant select on public.question_tombstones to anon,authenticated;
revoke insert,update,delete on public.question_tombstones from anon,authenticated;
create or replace function public.reconcile_question_retirement() returns trigger language plpgsql security definer set search_path=public,pg_catalog as $$
begin
 if TG_OP='DELETE' then
   if old.owner_id is null and (old.review_status='published' or not old.is_active) then insert into public.question_tombstones(id)values(old.id)on conflict(id)do update set retired_at=clock_timestamp();end if;return old;
 end if;
 if new.owner_id is null then
   if new.is_active and new.review_status='published' then delete from public.question_tombstones where id=new.id;
   elsif not new.is_active or (TG_OP='UPDATE' and old.owner_id is null and old.review_status='published') then insert into public.question_tombstones(id)values(new.id)on conflict(id)do update set retired_at=clock_timestamp();end if;
 end if;
 return new;
end$$;
drop trigger if exists question_retirement on public.questions;
create trigger question_retirement after insert or update or delete on public.questions for each row execute function public.reconcile_question_retirement();
insert into public.question_tombstones(id)select id from public.questions where owner_id is null and not is_active on conflict(id)do nothing;
create or replace function public.require_archived_delete() returns trigger language plpgsql set search_path=public,pg_catalog as $$begin if old.is_active and (to_jsonb(old)->>'owner_id') is null then raise exception 'Archive official content before permanent deletion';end if;return old;end$$;
drop trigger if exists content_delete_guard on public.questions;
create trigger content_delete_guard before delete on public.questions for each row execute function public.require_archived_delete();
drop trigger if exists content_delete_guard on public.english_papers;
create trigger content_delete_guard before delete on public.english_papers for each row execute function public.require_archived_delete();

-- Replace legacy policies: unpublished official content is never public.
alter table public.questions enable row level security;
alter table public.english_papers enable row level security;
alter table public.admin_activity enable row level security;
alter table public.content_subjects enable row level security;
do $$ declare r record;begin for r in select tablename,policyname from pg_policies where schemaname='public' and tablename in('questions','english_papers','admin_activity','content_subjects') loop execute format('drop policy %I on public.%I',r.policyname,r.tablename);end loop;end $$;
create policy questions_read on public.questions for select using(public.is_question_admin() or owner_id=auth.uid() or (owner_id is null and is_active and review_status='published'));
create policy questions_write on public.questions for all to authenticated using(public.is_question_admin() or owner_id=auth.uid()) with check(public.is_question_admin() or owner_id=auth.uid());
create policy english_read on public.english_papers for select using(public.is_question_admin() or (is_active and review_status='published'));
create policy english_write on public.english_papers for all to authenticated using(public.is_question_admin()) with check(public.is_question_admin());
create policy audit_read on public.admin_activity for select to authenticated using(public.is_question_admin());
create policy subjects_read on public.content_subjects for select using(true);
create policy subjects_write on public.content_subjects for all to authenticated using(public.is_question_admin()) with check(public.is_question_admin());
grant select on public.questions,public.english_papers,public.content_subjects to anon,authenticated;
grant insert,update,delete on public.questions,public.english_papers,public.content_subjects to authenticated;
grant select on public.admin_activity,public.question_admins to authenticated;
revoke insert,update,delete on public.admin_activity,public.question_admins from anon,authenticated;
commit;

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
