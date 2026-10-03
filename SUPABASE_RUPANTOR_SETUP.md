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
  RUPANTOR_CREATE_URL=https://provider.example/create \
  RUPANTOR_VERIFY_URL=https://provider.example/verify \
  RUPANTOR_API_KEY=... \
  RUPANTOR_API_SECRET=... \
  RUPANTOR_WEBHOOK_SECRET=... \
  RUPANTOR_SUCCESS_URL=https://your-app.example/payment/success \
  RUPANTOR_CANCEL_URL=https://your-app.example/payment/cancel
```

The adapter sends the price loaded from `subscription_plans`, never a price supplied by Flutter. If Rupantor Pay uses different request or response field names, update only `supabase/functions/rupantor-pay/index.ts` to match its current documentation; credentials must remain Edge Function secrets.

## AI limits

`mimi` calls `claim_ai_request` before the provider call. The RPC computes the date in `Asia/Dhaka`, locks the daily row, and rejects requests over the plan limit. Provider failures call `refund_ai_request`; the client counter is display-only. The disposable regression test in `supabase/tests/subscription_architecture_test.sql` covers the RLS, idempotent activation, expiry, and same-day upgrade paths.

Set `GEMINI_API_KEY` as an Edge Function secret as before. Never put a Rupantor or Gemini secret in the APK.

## Admin

The migration creates `admin_subscription_overview()` for the existing question-admin studio and allows question admins to manage the active rows in `subscription_plans`. It exposes teacher, plan, expiry, provider transaction, and AI-used/today fields without granting broad profile access.

Existing bKash rows remain historical records. They are not rewritten or treated as new Rupantor transactions.
