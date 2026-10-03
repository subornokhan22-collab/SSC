import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import test from "node:test";

const migration = readFileSync(
  "supabase/migrations/20261003000001_subscription_architecture.sql",
  "utf8",
);
const payment = readFileSync("supabase/functions/rupantor-pay/index.ts", "utf8");
const mimi = readFileSync("supabase/functions/mimi/index.ts", "utf8");


test("Rupantor is the only deployable payment function", () => {
  assert.equal(existsSync("supabase/functions/bkash/index.ts"), false);
  assert.match(payment, /subscription_plans/);
  assert.match(payment, /activate_subscription_transaction/);
  assert.match(payment, /fullname:/);
  assert.match(payment, /meta_data:/);
  assert.match(payment, /X-API-KEY/);
  assert.match(payment, /X-CLIENT/);
  assert.match(payment, /payment_url/);
  assert.doesNotMatch(payment, /x-rupantor-signature/);
  assert.doesNotMatch(payment, /RUPANTOR_WEBHOOK_SECRET/);
  assert.doesNotMatch(payment, /299|2499|799|monthly|yearly|lifetime/);
});

test("Rupantor activation verifies status, currency, and amount", () => {
  assert.match(payment, /RUPANTOR_VERIFY_URL/);
  assert.match(payment, /transaction_id/);
  assert.match(payment, /p_provider_amount/);
  assert.match(payment, /p_provider_currency/);
  assert.match(migration, /upper\(trim\(coalesce\(p_provider_currency/);
  assert.match(migration, /abs\(p_provider_amount - tx\.amount_bdt\)/);
});

test("payment activation is server-authoritative and idempotent", () => {
  assert.match(migration, /provider_transaction_id text unique/);
  assert.match(migration, /if tx\.status = 'paid'/);
  assert.match(migration, /base_time := greatest/);
  assert.match(migration, /subscription_plan = tx\.plan_id/);
});

test("AI usage uses atomic Dhaka-day RPCs with refunds", () => {
  assert.match(migration, /now\(\) at time zone 'Asia\/Dhaka'/);
  assert.match(migration, /for update/);
  assert.match(migration, /claim_ai_request/);
  assert.match(migration, /refund_ai_request/);
  assert.match(mimi, /claim_ai_request/);
  assert.match(mimi, /refundAiRequest/);
});

test("client roles cannot write subscription or AI authority tables", () => {
  assert.match(migration, /revoke all on function public\.claim_ai_request/);
  assert.match(migration, /revoke all on function public\.refund_ai_request/);
  assert.match(migration, /create policy ai_usage_daily_read_own/);
  assert.match(migration, /create policy subscription_transactions_read_own/);
});
