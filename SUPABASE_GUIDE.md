# Tutor's Desk Supabase setup — start to finish

Follow this guide from **Step 1 to Step 12**. Do not skip a step when setting up a new project. It configures the backend used by the Flutter app: login, plans, subject limits, Model Test limits, AI, content administration, and Rupantor Pay.

Existing detailed notes:

- [`SUPABASE_RUPANTOR_SETUP.md`](SUPABASE_RUPANTOR_SETUP.md) — Rupantor checkout, verification, webhook, idempotency, and acceptance tests.
- [`SUPABASE_BKASH_SETUP.md`](SUPABASE_BKASH_SETUP.md) — legacy bKash history. Do not add new bKash credentials.

## What you need before starting

You need:

- A Supabase account and one project, or permission to use the existing project.
- This repository checked out on the computer where you will deploy.
- Node.js/npm for the CLI tests.
- The Flutter app's actual redirect/deep-link scheme, if password reset and payment return-to-app are enabled.
- A Gemini server key and Rupantor provider credentials only when you are ready to enable those services.

Keep these values in a password manager or secure environment, not in this file:

| Value | Where it is used | Is it safe in Flutter? |
|---|---|---|
| Project URL | Flutter and server functions | Yes |
| Supabase anon public key | Flutter | Yes; RLS still protects data |
| Supabase `service_role` key | Edge Functions only | **No** |
| Gemini key | `mimi` and `admin-content` secrets | **No** |
| Rupantor API key/client | `rupantor-pay` secret | **No** |

> Never commit provider credentials, API keys, database passwords, or a Supabase `service_role` key. If a secret is exposed, rotate it immediately.

---

## Step 1 — Install the Supabase CLI

Use one installation method.

### macOS or Linux with Homebrew

```sh
brew install supabase/tap/supabase
supabase --version
```

### npm installation without changing this Flutter repository

If Homebrew is unavailable, install the CLI in a separate tools directory so npm does not add files to this repository:

```sh
mkdir -p "$HOME/supabase-cli"
cd "$HOME/supabase-cli"
npm init -y
npm install supabase
npx supabase --version
```

For the remaining steps, run `npx --prefix "$HOME/supabase-cli" supabase ...` instead of `supabase ...`. For example:

```sh
npx --prefix "$HOME/supabase-cli" supabase login
```

Log in. The CLI opens an authentication flow; do not paste a token into this guide or commit it:

```sh
supabase login
supabase projects list
```

---

## Step 2 — Create or choose the Supabase project

If the project already exists, use it. Otherwise:

1. Open the Supabase Dashboard.
2. Create a new project.
3. Choose a strong database password and store it securely.
4. Wait until the project is ready.
5. Open **Project Settings → General** and copy the **Project reference ID**.
6. Open **Project Settings → API** and copy the **Project URL** and **anon public key**.

Do not copy the `service_role` key into the Flutter app. You will not need it in a normal CLI deployment; Supabase makes it available to Edge Functions server-side.

---

## Step 3 — Connect this repository to the project

Open a terminal at the repository root:

```sh
cd /path/to/SSC
```

This checkout may not contain `supabase/config.toml` yet. Create local CLI metadata once, then link the project:

```sh
supabase init
supabase link --project-ref <project-ref>
supabase migration list
```

Replace `<project-ref>` with the reference ID from Step 2. If `supabase migration list` reports a migration-history mismatch, stop and inspect it. Do not force-push or manually mark migrations as applied until the existing database has been reviewed.

---

## Step 4 — Apply the database migrations

This repository must be applied in this exact order:

```text
1. supabase/migrations/20260921000000_bkash.sql
2. supabase/migrations/20260923000001_harden_profiles.sql
3. supabase/migrations/20260925000001_content_manager.sql
4. supabase/migrations/20260929000002_promotion_studio.sql
5. supabase/migrations/20261003000001_subscription_architecture.sql
6. supabase/migrations/20261004000001_free_plan_hardening.sql
```

Apply all pending migrations:

```sh
supabase db push
supabase migration list
```

If the project already has these migrations, `db push` should report that there is nothing new to apply. If a migration fails, stop there and fix the database issue; do not skip that migration or edit an already-applied migration.

The first migration is retained for database history and compatibility. It does **not** mean that you should deploy a bKash payment function. Rupantor Pay is the active payment provider.

The last two migrations create the important server rules:

- The plan and price matrix is stored in the database.
- The server, not Flutter, decides whether a subscription is active.
- Free users may select exactly 1 subject.
- Basic users may select any 3 subjects.
- Pro users may select any 5 subjects.
- Professional users have unlimited subject selection.
- Free users may generate exactly 2 Model Tests per Asia/Dhaka calendar month.
- Free users cannot use paid paper formats.
- A paper can be reserved, completed, or refunded on the server.
- AI usage and payment activation are server-controlled and idempotent.

---

## Step 5 — Check that the plan rules are correct

In the Supabase Dashboard, open **SQL Editor → New query** and run:

```sql
select id, name, price_bdt, duration_days,
       subject_limit, monthly_paper_limit,
       no_watermark, ai_assistant, ai_daily_limit,
       omr_scanner, is_active
from public.subscription_plans
order by sort_order;
```

Confirm these values:

| Plan | Subjects | Monthly papers | Watermark |
|---|---:|---:|---|
| Free | 1 | 2 | Yes |
| Basic | 3 | Unlimited | Yes |
| Pro | 5 | Unlimited | No |
| Professional | Unlimited | Unlimited | No |

The Free row must have `subject_limit = 1` and `monthly_paper_limit = 2`. Paid rows must have a null `monthly_paper_limit`. Prices and entitlements must be changed through the server/admin process, never from Flutter.

The server also rejects a paper above **100 MCQ, 30 SAQ, 15 CQ, or 145 total questions**.

---

## Step 6 — Configure email login, signup code, and password reset

In the Dashboard:

1. Open **Authentication → Providers → Email**.
2. Enable Email provider.
3. Enable **Confirm email** for production. This is what makes the signup confirmation-code flow work.
4. Configure SMTP under the Authentication email settings. The built-in email service is rate-limited and is suitable only for small testing.
5. Open **Authentication → URL Configuration**.
6. Set the Site URL and add the real redirect URL handled by the Flutter app. Do not invent a redirect URI; use the URI registered by the app.
7. Save the email templates and send a test email.

The app flow in [`lib/services/auth_service.dart`](lib/services/auth_service.dart) is:

1. User signs up with email and password.
2. Supabase sends one signup confirmation code.
3. User enters the code in the app.
4. User signs in later with email and password; sign-in does not require another code.
5. Forgot-password sends a Supabase reset link.

The app requires passwords of at least 8 characters. Test both a new signup and a password reset before continuing.

---

## Step 7 — Put the safe Supabase values in Flutter

Open [`lib/services/supabase_config.dart`](lib/services/supabase_config.dart) and set only the project URL and anon public key:

```dart
static const String url = 'https://<project-ref>.supabase.co';
static const String anonKey = '<anon-public-key-from-project-settings>';
```

Get both values from **Project Settings → API**. The anon key is designed to be present in the app. The following values must never be placed in this file:

- `service_role` key
- Gemini API key
- Rupantor API key or client secret
- Database password

Then run the app:

```sh
flutter pub get
flutter analyze
flutter run
```

Create a test account, enter the signup code, sign out, and sign in again. If login fails, check the project URL, anon key, Email provider, and email confirmation setting before changing database policies.

---

## Step 8 — Add server-only secrets

Do this in **Dashboard → Edge Functions → Secrets**. Add the values without committing them anywhere.

### Required Gemini secrets

| Secret | Value |
|---|---|
| `GEMINI_API_KEY` | Gemini server API key |
| `GEMINI_GENERATOR_MODEL` | Approved model ID for generation |
| `GEMINI_VALIDATOR_MODEL` | Approved model ID for independent validation |

Both model names are server configuration. Use model IDs enabled for the Gemini key; do not put model fallbacks or keys in Flutter.

### Required Rupantor secrets

| Secret | Value |
|---|---|
| `RUPANTOR_CREATE_URL` | Rupantor payment-create endpoint |
| `RUPANTOR_VERIFY_URL` | Rupantor payment-verify endpoint |
| `RUPANTOR_API_KEY` | Rupantor server API key |
| `RUPANTOR_CLIENT` | Rupantor client value |
| `RUPANTOR_SUCCESS_URL` | `https://<project-ref>.supabase.co/functions/v1/rupantor-pay` |
| `RUPANTOR_CANCEL_URL` | `https://<project-ref>.supabase.co/functions/v1/rupantor-pay` |
| `RUPANTOR_APP_REDIRECT_URL` | The Flutter payment result deep link |

The deployed functions receive `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` server-side from Supabase. Never copy that service-role value into the app or into Git.

If you prefer the CLI, set secret values from protected environment variables rather than writing real values into shell history:

```sh
supabase secrets set \
  GEMINI_API_KEY="$GEMINI_API_KEY" \
  GEMINI_GENERATOR_MODEL="$GEMINI_GENERATOR_MODEL" \
  GEMINI_VALIDATOR_MODEL="$GEMINI_VALIDATOR_MODEL" \
  RUPANTOR_CREATE_URL="$RUPANTOR_CREATE_URL" \
  RUPANTOR_VERIFY_URL="$RUPANTOR_VERIFY_URL" \
  RUPANTOR_API_KEY="$RUPANTOR_API_KEY" \
  RUPANTOR_CLIENT="$RUPANTOR_CLIENT" \
  RUPANTOR_SUCCESS_URL="https://<project-ref>.supabase.co/functions/v1/rupantor-pay" \
  RUPANTOR_CANCEL_URL="https://<project-ref>.supabase.co/functions/v1/rupantor-pay" \
  RUPANTOR_APP_REDIRECT_URL="$RUPANTOR_APP_REDIRECT_URL"
```

Do not run the command with the literal placeholder values. Check only secret names, never secret values:

```sh
supabase secrets list
```

---

## Step 9 — Deploy the three Edge Functions

Run these commands after migrations and secrets are ready:

```sh
supabase functions deploy mimi
supabase functions deploy admin-content
supabase functions deploy rupantor-pay --no-verify-jwt
```

What each function does:

- `mimi` requires a signed-in user and accounts for AI usage before calling Gemini.
- `admin-content` requires a signed-in user who is listed in `public.question_admins`.
- `rupantor-pay` starts checkout, receives provider callbacks, independently verifies payment, and activates a subscription only after verification.

`rupantor-pay` needs `--no-verify-jwt` because Rupantor's webhook and redirect do not contain a Supabase JWT. This does **not** make payments trusted: the function validates authenticated `initiate`/`verify` actions and calls Rupantor's verify endpoint before activation.

If a function fails, inspect logs:

```sh
supabase functions logs mimi
supabase functions logs admin-content
supabase functions logs rupantor-pay
```

---

## Step 10 — Set up content administration and Storage

### Add a content administrator

First create the administrator's account through the normal signup flow. In the SQL Editor, find the user ID:

```sql
select id, email
from auth.users
where email = '<admin-email-used-for-signup>';
```

Then insert that UUID in a controlled SQL session:

```sql
insert into public.question_admins(user_id, note)
values ('<auth-user-uuid>', 'content administrator');
```

Do not expose an app button or public API that inserts into `question_admins`.

### Enable question figures, if needed

The question-figure bucket is optional. If the app needs it, run this from a secure database connection after the content-manager migration:

```sh
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/content_storage.sql
```

It creates the public `question-figures` read bucket but limits upload, update, and delete to question administrators. Run the read-only RLS audit whenever needed:

```sh
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/audit_rls.sql
```

Never disable RLS to work around an application error.

---

## Step 11 — Perform a complete smoke test

Use a disposable test teacher account first.

### Database checks

In SQL Editor, verify:

```sql
-- Plan matrix
select id, subject_limit, monthly_paper_limit, is_active
from public.subscription_plans
order by sort_order;

-- Replace the UUID with the disposable test user's auth.users.id
select *
from public.effective_entitlement('<test-user-uuid>');
```

The test user should start with a Free entitlement.

### App checks

1. Sign up, enter the confirmation code, sign in, and request a password reset.
2. Select one Free subject. The second subject must remain visible with a lock icon and be denied by the server.
3. As Basic, select any three subjects; as Pro, any five; as Professional, more than five.
4. Generate two Free Model Tests in the same Asia/Dhaka month. The third must be denied.
5. Try a Free paid format such as chapter/custom. It must remain visible but locked; it must not consume a paper allowance.
6. Try an oversized paper. The server must reject it above 100 MCQ, 30 SAQ, 15 CQ, or 145 total.
7. Call `mimi` while signed in. Confirm it uses the server Gemini key and enforces the server AI allowance.
8. Confirm a missing/invalid Gemini secret gives a safe server error and never exposes a key.
9. Confirm an ordinary app user cannot write plans, subscriptions, provider transactions, AI counters, or `question_admins` directly.

### Repository tests

These contract tests do not need live provider credentials:

```sh
node --test supabase/tests/*_test.mjs
```

SQL fixtures require a disposable PostgreSQL database. Get a connection string from a disposable local/test database, set it only in your current shell, and do **not** run fixtures against production:

```sh
export SUPABASE_DB_URL='postgresql://<test-user>:<test-password>@<test-host>:5432/<test-database>'
psql "$SUPABASE_DB_URL" \
  -v ON_ERROR_STOP=1 \
  -f supabase/tests/subscription_architecture_test.sql
```

For a local Docker-backed Supabase stack only:

```sh
supabase start
supabase db reset
```

`supabase db reset` destroys the local database. Never run it on the linked production project.

---

## Step 12 — Test Rupantor Pay, then go live

Use Rupantor sandbox credentials or a very low-value test first.

1. Start checkout as an authenticated test teacher.
2. Confirm one `pending` row is created before the provider page opens.
3. Confirm checkout returns a `payment_url` and the internal `order_id` is retained.
4. Confirm Rupantor sends the documented `transaction_id` through its webhook or redirect.
5. Confirm `rupantor-pay` calls the independent verify endpoint.
6. Confirm activation requires paid status, BDT currency, and the exact server plan amount.
7. Send the same webhook twice. It must create only one paid activation.
8. Test wrong amount, wrong currency, failed payment, unknown transaction, and cancelled payment. None may unlock paid access.
9. Confirm the Flutter payment result deep link works.
10. Only after all checks pass, replace sandbox values with production values and repeat a low-value production test.

The provider callback is not trusted by itself. The webhook is a wake-up signal; Rupantor verification is required before the database can activate the subscription. Read [`SUPABASE_RUPANTOR_SETUP.md`](SUPABASE_RUPANTOR_SETUP.md) for the full provider contract.

---

## What to do if something goes wrong

- **Migration failed:** stop, save the error, inspect the database, and fix it before continuing. Do not skip migrations.
- **Email code did not arrive:** check Confirm email, SMTP, spam, and email rate limits. Do not weaken RLS.
- **Flutter login fails:** check URL, anon key, provider settings, and redirect URLs. Never add the service-role key.
- **Function says not configured:** check secret names in the correct Supabase project, then redeploy the function.
- **Payment callback is rejected:** check the webhook URL, `--no-verify-jwt`, provider transaction ID, and verify endpoint. Never mark a transaction paid manually.
- **A deploy is broken:** redeploy the last reviewed function version and inspect logs and transaction rows.
- **A database change must be reversed:** do not edit an applied migration. Create a new timestamped corrective migration, back up first, and test it on a disposable project.
- **Payments need to pause:** disable checkout/endpoint access and record the incident. Do not bypass verification or RLS.

Before production traffic, confirm:

```sh
supabase migration list
supabase secrets list
supabase functions logs mimi
supabase functions logs admin-content
supabase functions logs rupantor-pay
```

The final security rule is simple: **Flutter can ask; the database and Edge Functions decide.**
