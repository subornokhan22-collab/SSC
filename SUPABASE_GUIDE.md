# Tutor's Desk Supabase guide

This is the end-to-end Supabase setup guide for this repository. It covers authentication, migrations, RLS, subscription entitlements, paper limits, AI, content administration, Storage, Rupantor Pay, testing, and rollback.

Related provider notes:

- [`SUPABASE_RUPANTOR_SETUP.md`](SUPABASE_RUPANTOR_SETUP.md) — detailed Rupantor checkout, verification, webhook, and reconciliation contract.
- [`SUPABASE_BKASH_SETUP.md`](SUPABASE_BKASH_SETUP.md) — legacy bKash history only. Do not add new bKash credentials.

> Never put a Supabase `service_role` key, Rupantor credential, or Gemini key in Flutter, Git, an APK, or a browser bundle. The Flutter app may use only the Supabase project URL and anon public key.

## 1. Install the CLI and prepare the project

Install the Supabase CLI using one of the supported methods. On macOS/Linux with Homebrew:

```sh
brew install supabase/tap/supabase
```

For a project-local installation (useful in CI or on a machine without Homebrew):

```sh
npm install --save-dev supabase
npx supabase --version
```

Use the same CLI version in CI and deployment where possible. If installed locally with npm, replace `supabase` in the commands below with `npx supabase`.

Authenticate and verify that the repository and project are the intended pair:

```sh
supabase --version
supabase login
supabase projects list
```

This checkout does not require a locally generated Supabase project to edit the migrations. If `supabase/config.toml` is not present, initialize the local CLI metadata once:

```sh
supabase init
supabase link --project-ref <project-ref>
```

Use the project reference from **Supabase Dashboard → Project Settings → General**. Do not paste a service key into a command that will be saved in shell history.

## 2. Configure the Flutter client

The client configuration is in [`lib/services/supabase_config.dart`](lib/services/supabase_config.dart):

```dart
static const String url = 'https://<project-ref>.supabase.co';
static const String anonKey = '<anon-public-key>';
```

The anon key is intentionally a public client key. RLS and server-side functions are the security boundary. Confirm that the app can reach the project, but do not use the service-role key here.

`AuthService` uses email/password authentication. Sign-up can require one Supabase email confirmation code; sign-in uses email and password. In the Dashboard:

1. Open **Authentication → Providers → Email**.
2. Enable Email if it is disabled.
3. Choose whether new accounts require email confirmation. If confirmation is enabled, configure a working SMTP provider before production use.
4. Add the app's password-reset/deep-link URLs under **Authentication → URL Configuration** when password recovery is enabled.
5. Do not make public profile or subscription columns writable from the client.

The profile trigger and policies in the migrations create teacher-safe profile rows and protect subscription authority columns.

## 3. Apply migrations in order

Run the repository migrations in filename order. The complete sequence is:

```text
supabase/migrations/20260921000000_bkash.sql
supabase/migrations/20260923000001_harden_profiles.sql
supabase/migrations/20260925000001_content_manager.sql
supabase/migrations/20260929000002_promotion_studio.sql
supabase/migrations/20261003000001_subscription_architecture.sql
supabase/migrations/20261004000001_free_plan_hardening.sql
```

For a linked project:

```sh
supabase db push
```

The final two migrations are especially important:

- `20261003000001_subscription_architecture.sql` creates the server plan matrix, subscription transactions, user subjects, AI daily usage, profiles protection, and baseline RLS.
- `20261004000001_free_plan_hardening.sql` adds effective entitlements, the server paper reservation/refund flow, Dhaka-month Free limits, subject RPCs, AI burst/event controls, promotion hardening, and admin overview support.

The current policy matrix is server data:

| Plan | Subjects | Papers | Paper format | Watermark |
|---|---:|---:|---|---|
| Free | 1 | 2 per Asia/Dhaka month | Model Test only | Yes |
| Basic | 3 | Unlimited | All discoverable formats | Yes |
| Pro | 5 | Unlimited | All discoverable formats | No |
| Professional | Unlimited | Unlimited | All discoverable formats | No |

All plans retain the server safety ceiling of **100 MCQ, 30 SAQ, 15 CQ, and 145 total questions**.

Verify the live matrix after migration:

```sql
select id, name, price_bdt, duration_days, subject_limit,
       monthly_paper_limit, no_watermark, ai_assistant,
       ai_daily_limit, omr_scanner, is_active
from public.subscription_plans
order by sort_order;
```

The expected Free row has `subject_limit = 1` and `monthly_paper_limit = 2`. Paid plans have a null monthly paper limit. Prices and entitlements must be changed in the database/admin process, never in Flutter.

## 4. RLS and authority model

The app authenticates with the anon key and the user's JWT. It does not directly write authority tables.

Important server boundaries:

- `effective_entitlement(user_id)` resolves active, unexpired paid plans; cancelled, failed, pending, and expired plans fall back to Free.
- `select_user_subject(subject_id)` and `remove_user_subject(subject_id)` are the only supported subject mutations.
- `claim_paper_creation(...)` is the only paper allowance claim path. It locks the Dhaka-month usage row and returns a reservation.
- `complete_paper_creation(reservation_id)` consumes a successful reservation.
- `refund_paper_creation(reservation_id)` returns a failed composition reservation.
- `claim_ai_request(user_id)` and `refund_ai_request(...)` control AI usage server-side.
- Paid subscription activation is performed only by verified payment logic using the service role.

Run the read-only audit at any time:

```sh
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/audit_rls.sql
```

The audit reports RLS status, policies, question admins, and Storage policies. Do not disable RLS to make a client error disappear.

## 5. Content and Storage setup

After `20260925000001_content_manager.sql` is applied, run the optional Storage setup if the question-figure bucket is required:

```sh
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/content_storage.sql
```

This creates the public `question-figures` bucket for reading diagrams and restricts upload/update/delete to authenticated question administrators. The app's content functions are:

```sh
supabase functions deploy admin-content
```

`admin-content` requires a valid user JWT and checks `public.question_admins` before allowing content operations. Gemini is used only for server-side review/structure helpers; the administrator remains responsible for publishing content.

To grant an administrator, use a controlled SQL session or the existing admin process. Do not expose a public endpoint that inserts into `question_admins`:

```sql
insert into public.question_admins(user_id, note)
values ('<auth-user-uuid>', 'content administrator');
```

## 6. Edge Function deployment and secrets

The repository contains three active Edge Functions:

| Function | Purpose | Deployment |
|---|---|---|
| `mimi` | Authenticated teacher AI and AI usage accounting | `supabase functions deploy mimi` |
| `admin-content` | Authenticated question/English content administration | `supabase functions deploy admin-content` |
| `rupantor-pay` | Checkout, provider notification, independent verification, activation | `supabase functions deploy rupantor-pay --no-verify-jwt` |

`rupantor-pay` must accept provider GET/POST redirects and notifications that do not contain a Supabase JWT. Its `initiate` and authenticated `verify` actions still validate the user JWT inside the function. Do not remove the independent provider verification call.

Set secrets from a secure shell or the Dashboard's **Edge Functions → Secrets** page:

```sh
supabase secrets set \
  GEMINI_API_KEY='<gemini-server-key>' \
  GEMINI_GENERATOR_MODEL='<approved-generator-model>' \
  GEMINI_VALIDATOR_MODEL='<approved-validator-model>' \
  RUPANTOR_CREATE_URL='https://provider.example/api/payment/create-payment' \
  RUPANTOR_VERIFY_URL='https://provider.example/api/payment/verify-payment' \
  RUPANTOR_API_KEY='<rupantor-api-key>' \
  RUPANTOR_CLIENT='<rupantor-client-id>' \
  RUPANTOR_SUCCESS_URL='https://<project-ref>.supabase.co/functions/v1/rupantor-pay' \
  RUPANTOR_CANCEL_URL='https://<project-ref>.supabase.co/functions/v1/rupantor-pay' \
  RUPANTOR_APP_REDIRECT_URL='tutorsdesk://payment/result'
```

Supabase supplies `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to deployed functions. If a self-hosted setup does not supply them automatically, configure them as server-only secrets. Never print or commit their values.

### AI requirements

`mimi` claims AI usage before calling Gemini and refunds failed provider work. Configure a model that is enabled for the Gemini key. The model names are deployment configuration, not Flutter constants. A missing or invalid `GEMINI_API_KEY` must produce a server error, not a client-side key fallback.

### Rupantor requirements

Use the documented Rupantor fields and headers only. The function expects checkout to return `payment_url`; it retains the internal `order_id` until a documented `transaction_id` arrives through notification or redirect. It then calls the verify endpoint and checks the transaction status, exact server plan amount, and BDT currency before activation.

For the full acceptance checklist, wrong-amount tests, duplicate-notification tests, and reconciliation procedure, follow [`SUPABASE_RUPANTOR_SETUP.md`](SUPABASE_RUPANTOR_SETUP.md).

## 7. Local and CI tests

JavaScript/Edge contract tests can run without project credentials:

```sh
node --test supabase/tests/*_test.mjs
```

The SQL regression tests require a disposable PostgreSQL database. Never run the fixture files against production because they create temporary roles/data and end with a rollback:

```sh
createdb tutors_desk_test
psql "$SUPABASE_DB_URL" -d tutors_desk_test \
  -v ON_ERROR_STOP=1 \
  -f supabase/tests/subscription_architecture_test.sql
```

The subscription fixture verifies subject limits, RLS writes, Free Model-Test-only paper claims, the two-paper Dhaka-month quota, refund/retry behavior, AI daily claims, and idempotent paid activation. CI also runs the profile, content, promotion, admin, and provider contract fixtures.

For a local Supabase stack, use the CLI's local database only after reviewing the migration effects:

```sh
supabase start
supabase db reset
```

Do not use `db reset` on a linked production project.

## 8. Deployment verification checklist

After applying migrations and deploying functions:

1. Create a disposable teacher account and confirm the profile has `role = 'teacher'` and a Free effective entitlement.
2. Select one Free subject; confirm a second subject is denied by `select_user_subject` and remains visible in the app with a lock icon.
3. On Basic and Pro fixtures, select exactly 3 and 5 subjects respectively; confirm the next subject is denied. Confirm Professional has no subject ceiling.
4. Claim two Free `model_test` papers in the same Asia/Dhaka month; confirm the third is denied.
5. Attempt a Free `chapter`, `custom`, or `mcq` claim; confirm `format_locked` and no usage increment.
6. Compose a failed paper and confirm its reservation can be refunded and retried exactly once.
7. Call `mimi` with a teacher JWT and confirm the daily/burst counters are updated. Confirm an invalid or missing Gemini secret fails safely.
8. Initiate a low-value Rupantor sandbox payment. Confirm the transaction is pending before checkout, provider verification occurs, and only one paid activation is recorded.
9. Run `supabase/audit_rls.sql` and check that no client role has direct authority-table write access.
10. Check Edge Function logs and database transaction rows for errors before enabling real payment traffic.

## 9. Rollback and operational rules

- Do not edit an already-applied migration. Add a new timestamped migration that reverses or corrects the behavior.
- Do not manually edit `profiles.subscription_plan`, `profiles.subscription_status`, expiry, provider transaction, or AI counters from the client.
- To pause payments, disable the Rupantor checkout secret/endpoint or disable the function after recording the operational decision; do not mark transactions paid manually.
- To repair a verified transaction, use the service-side activation/reconciliation path and preserve the provider transaction idempotency key.
- If an Edge Function deploy is bad, redeploy the previous reviewed commit and inspect transaction/RPC logs. Do not roll back by disabling RLS.
- Keep a database backup and migration record before production changes.

## 10. Useful commands

```sh
# Check linked project and migration status
supabase projects list
supabase migration list

# Apply pending migrations
supabase db push

# Deploy functions
supabase functions deploy mimi
supabase functions deploy admin-content
supabase functions deploy rupantor-pay --no-verify-jwt

# Inspect recent function logs
supabase functions logs mimi
supabase functions logs admin-content
supabase functions logs rupantor-pay

# Set or list secret names; never echo secret values
supabase secrets list
```

The source of truth is the SQL migrations and Edge Functions in this repository. Treat dashboard edits as temporary/manual operations and record any production change as a migration or reviewed deployment change.
