# RLS audit checklist (Phase 1, items #3/#4/#6/#7)

~10 minutes in the Supabase dashboard. Three steps, in order.

## 1. Run the hardening migration (once)

1. Open the SQL editor: <https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/sql/new>
2. Paste the whole file **`supabase/migrations/20260923000001_harden_profiles.sql`**
3. Press **Run**

What it does: enables RLS on `profiles`, replaces whatever policies exist there
with the minimal own-row set, and adds a trigger that freezes
`is_pro` / `pro_until` / `pro_plan` for any write made with a user token.
Pro activation keeps working — the bKash edge function writes those columns
with the service-role key, which the trigger lets through (it is the only
path that may change Pro).

## 2. Run the audit (read-only, any time)

Paste **`supabase/audit_rls.sql`** and Run, then copy the output. Check:

- [ ] Section 1: `profiles`, `questions`, `question_admins` → `rls_enabled = true`
- [ ] Section 2: `profiles` shows exactly `profiles_select_own`,
      `profiles_insert_own`, `profiles_update_own` (and nothing permissive
      like `using (true)`)
- [ ] Section 3: only your own account is a question admin
- [ ] Section 4: bypass-RLS roles are Supabase-managed only
      (`postgres`, `supabase_admin`, `service_role`…) — no custom role
- [ ] Section 6: the `profiles_protect_pro` trigger exists

## 3. Prove it with an end-user session

Do not test this by merely signing into the SQL Editor: its privileged
connection is not the app user's JWT, and `auth.uid()` can be null there.
Use a disposable signed-in account through a Supabase client carrying that
user's access token (never the service-role key). Verify that:

- Updating that account's name/phone succeeds.
- Writing `is_pro`, `pro_until`, or `pro_plan` leaves the values unchanged.
- Selecting/updating another account's profile returns no rows.
- Inserting a profile for another user fails.
- A backend service-role update still activates Pro for the paid account.

CI runs `supabase/tests/profiles_rls_test.sql` against a disposable PostgreSQL
database to cover these cases and migration idempotency. It does not access
production. The live checks above are still needed for your deployed schema.

## Keep in mind

- The anon key in `lib/services/supabase_config.dart` is public by design —
  security depends entirely on RLS, which is why this audit matters.
- If a step fails, paste the error here; do **not** run anything that
  deletes data.
