# Tutor's Desk subscription architecture

The migration `supabase/migrations/20261003000001_subscription_architecture.sql` adds the server-authoritative plan matrix, subject selections, AI daily usage, transaction idempotency, and RLS.

## Apply the database migration

Run the migrations in order in the Supabase SQL editor or deploy them with the Supabase CLI. Do not edit a user's subscription from the Flutter client.

For a linked Supabase project, the deployment sequence is:

```sh
supabase link --project-ref <project-ref>
supabase db push
supabase functions deploy rupantor-pay
supabase functions deploy mimi
```

`20261004000001_free_plan_hardening.sql` adds the server-controlled Free allowance (2 Model Test papers per Asia/Dhaka calendar month), controlled subject-selection RPCs, effective-entitlement resolution, AI burst/event tables, and promotion audience migration. Run it only after `20261003000001_subscription_architecture.sql`.

Before enabling payments, verify in the Supabase SQL editor that `subscription_plans` has the intended live prices, that `free.monthly_paper_limit = 2`, and that `basic`, `pro`, and `professional` have a null monthly paper limit. Never edit those values from Flutter.

## Rupantor Pay Edge Function

Deploy after applying the migration:

```sh
supabase functions deploy rupantor-pay
supabase functions deploy mimi
```

Configure the exact field contract and endpoints supplied by Rupantor Pay:

```sh
supabase secrets set \
  RUPANTOR_CREATE_URL=https://provider.example/api/payment/create-payment \
  RUPANTOR_VERIFY_URL=https://provider.example/api/payment/verify-payment \
  RUPANTOR_API_KEY=... \
  RUPANTOR_CLIENT=... \
  RUPANTOR_SUCCESS_URL=https://<project-ref>.supabase.co/functions/v1/rupantor-pay \
  RUPANTOR_CANCEL_URL=https://<project-ref>.supabase.co/functions/v1/rupantor-pay \
  RUPANTOR_APP_REDIRECT_URL=tutorsdesk://payment/result
```

The adapter sends the documented checkout fields (`fullname`, `email`, `amount`, `success_url`, `cancel_url`, `webhook_url`, and `meta_data`) with the documented `X-API-KEY` and `X-CLIENT` headers. Checkout returns a `payment_url`; the internal order id is kept until the provider supplies `transaction_id` through a webhook or completion redirect. The function then calls `verify-payment` and checks `COMPLETED`, `BDT`, and the exact server plan amount before activation. Credentials must remain Edge Function secrets; never put them in Flutter.

### Rupantor provider acceptance test

Use a sandbox or a low-value real test before switching traffic:

1. Start checkout as an authenticated test teacher and confirm one `pending` row exists before the provider page opens.
2. Confirm the provider receives the exact field names and both `X-API-KEY` and `X-CLIENT` headers.
3. Confirm the checkout response is accepted when it contains `payment_url` but no transaction id.
4. Complete payment and confirm the webhook or redirect includes the documented `transaction_id` and the original `meta_data.order_id`; do not treat an undocumented alias as valid.
5. Confirm the adapter calls `POST /api/payment/verify-payment` and does not activate from webhook status alone.
6. Test a wrong amount, non-BDT currency, unknown transaction id, duplicate webhook, cancelled payment, and a second verification. None may grant or extend a plan.
7. Confirm exactly one `subscription_transactions.provider_transaction_id` exists and the profile changes only after verified activation.

Do not add a provider signature header unless Rupantor documents and supports it for this account. The current adapter intentionally uses independent verification instead.

## AI limits

`mimi` calls `claim_ai_request` before the provider call. The RPC computes the date in `Asia/Dhaka`, locks the daily row, and rejects requests over the plan limit. Provider failures call `refund_ai_request`; the client counter is display-only. The disposable regression test in `supabase/tests/subscription_architecture_test.sql` covers the RLS, idempotent activation, expiry, and same-day upgrade paths.

Set the server AI configuration as Edge Function secrets too:

```sh
supabase secrets set \
  GEMINI_API_KEY=... \
  GEMINI_GENERATOR_MODEL=gemini-3.8-flash \
  GEMINI_VALIDATOR_MODEL=gemini-3.5-flash
```

The gateway sends no deprecated temperature/top-p/top-k sampling parameters to Gemini 3.8. The database also applies a short burst limit in addition to the daily allowance and records fixed-code AI usage events for operations. Never put a Rupantor or Gemini secret in the APK.

## Admin

The migration creates `admin_subscription_overview()` for the existing question-admin studio and allows question admins to manage the active rows in `subscription_plans`. It exposes teacher, plan, expiry, provider transaction, and AI-used/today fields without granting broad profile access.

Existing bKash rows remain historical records. They are not rewritten or treated as new Rupantor transactions.
