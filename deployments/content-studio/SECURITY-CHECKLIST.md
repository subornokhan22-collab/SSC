# Content Studio security checklist

The website-only `content-studio-netlify.zip` intentionally contains only the
browser runtime. It contains the public Supabase anon key, never a service-role
key. The complete `content-studio-update.zip` includes the database update and
single-file Edge Function bundles needed to verify and deploy the server side.

## Authorization

- `public.is_question_admin()` is a `security definer` function with a fixed
  `search_path`; it checks membership in `public.question_admins` using
  `auth.uid()`.
- Questions, English papers, promotion tables, promotion image writes and
  activity reads require the administrator policy unless the table explicitly
  exposes public published content.
- The browser cannot grant itself administrator membership or write
  `admin_activity` directly.
- `owner_id` is checked by RLS and is immutable after insert. A user cannot
  assign another user's owner ID. Official questions can be published only by
  an administrator; private teacher-owned records are never public.

## Workflow and ownership

- New content starts as `draft` through the database trigger, then must move
  through `review` before `published`.
- IDs and ownership are immutable. Published content cannot be edited in place;
  a changed published record must return to draft and pass review again.
- Public reads require `is_active = true` and `review_status = 'published'`.
- Permanent deletion of official content requires prior archiving. Private
  teacher-owned records remain subject to their owner policy.

## Validation and audit

- Database triggers validate MCQ/SAQ/CQ payloads, English paper shape, figures,
  duplicate published questions, Unicode corruption and promotion windows.
- `search_text` is a generated database column, so inserts and updates cannot
  forget to maintain it.
- `admin_activity` is written by a security-definer trigger and has no browser
  insert/update/delete grant. Private owner records are excluded from public
  audit snapshots.
- `question_tombstones` exposes only retired official IDs; payloads and private
  user IDs are not copied there.

## Payments and promotions

- The `bkash` Edge Function authenticates the caller, resolves the active plan
  again server-side, verifies the bKash transaction, and is the only path that
  updates `profiles.is_pro`.
- Promotion RLS filters offers, prizes and popup ads by active time window and
  filters notifications by sent time and audience. The app also requests only
  active rows.
- The promotion management UI validates start/end order, rejects activation of
  expired rows, and permanently deletes records only after an explicit DELETE
  confirmation. In-app notifications are not Android system push.

Apply `database-update.sql` before deploying the website or using the promotion
workspace. Never paste a service-role key, bKash secret or Gemini key into the
browser or into source control.
