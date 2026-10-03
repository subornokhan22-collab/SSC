# Tutor's Desk subscription architecture

The migration `supabase/migrations/20261003000001_subscription_architecture.sql` adds the server-authoritative plan matrix, subject selections, AI daily usage, transaction idempotency, and RLS.

## Apply the database migration

Run the migrations in order in the Supabase SQL editor or deploy them with the Supabase CLI. Do not edit a user's subscription from the Flutter client.

## Rupantor Pay Edge Function

Deploy:

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

## AI limits

`mimi` calls `claim_ai_request` before the provider call. The RPC computes the date in `Asia/Dhaka`, locks the daily row, and rejects requests over the plan limit. Provider failures call `refund_ai_request`; the client counter is display-only. The disposable regression test in `supabase/tests/subscription_architecture_test.sql` covers the RLS, idempotent activation, expiry, and same-day upgrade paths.

Set the server AI configuration as Edge Function secrets too:

```sh
supabase secrets set \
  GEMINI_API_KEY=... \
  GEMINI_GENERATOR_MODEL=gemini-3.8-flash \
  GEMINI_VALIDATOR_MODEL=gemini-3.5-flash
```

The gateway sends no deprecated temperature/top-p/top-k sampling parameters to Gemini 3.8. Never put a Rupantor or Gemini secret in the APK.

## Admin

The migration creates `admin_subscription_overview()` for the existing question-admin studio and allows question admins to manage the active rows in `subscription_plans`. It exposes teacher, plan, expiry, provider transaction, and AI-used/today fields without granting broad profile access.

Existing bKash rows remain historical records. They are not rewritten or treated as new Rupantor transactions.
