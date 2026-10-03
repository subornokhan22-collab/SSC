// Tutor's Desk — Rupantor Pay payment adapter.
//
// Provider credentials and endpoint names are intentionally server-only.
// Configure the exact Rupantor Pay API URLs/field contract from the provider
// documentation in Edge Function secrets:
//   RUPANTOR_CREATE_URL, RUPANTOR_VERIFY_URL, RUPANTOR_API_KEY
//   RUPANTOR_API_SECRET, RUPANTOR_WEBHOOK_SECRET
//   RUPANTOR_SUCCESS_URL, RUPANTOR_CANCEL_URL
//
// Flutter supplies only a stable plan id. Prices and limits are loaded from
// public.subscription_plans, and activation happens only after verification.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const supa = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-rupantor-signature",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

function error(message: string, status = 400, code = "PAYMENT_ERROR") {
  return json({ ok: false, error: message, code }, status);
}

function firstString(body: Record<string, unknown>, keys: string[]) {
  for (const key of keys) {
    const value = body[key];
    if (value != null && String(value).trim()) return String(value).trim();
  }
  return null;
}

function providerHeaders(): HeadersInit {
  const key = Deno.env.get("RUPANTOR_API_KEY") ?? "";
  const secret = Deno.env.get("RUPANTOR_API_SECRET") ?? "";
  return {
    "Content-Type": "application/json",
    ...(key ? { "Authorization": `Bearer ${key}`, "x-api-key": key } : {}),
    ...(secret ? { "x-api-secret": secret } : {}),
  };
}

function paidStatus(body: Record<string, unknown>): boolean {
  const status = String(
    body.status ?? body.payment_status ?? body.paymentStatus ?? body.result ?? "",
  ).toLowerCase();
  return ["paid", "success", "successful", "completed", "complete", "captured"].includes(status) ||
    body.paid === true || body.success === true;
}

function failedStatus(body: Record<string, unknown>): boolean {
  const status = String(
    body.status ?? body.payment_status ?? body.paymentStatus ?? body.result ?? "",
  ).toLowerCase();
  return ["failed", "failure", "cancelled", "canceled", "invalid", "rejected", "expired"].includes(status) ||
    body.success === false;
}

async function providerRequest(
  url: string,
  body: Record<string, unknown>,
  method = "POST",
): Promise<Record<string, unknown>> {
  if (!url) throw new Error("Rupantor Pay endpoint is not configured.");
  const response = await fetch(url, {
    method,
    headers: providerHeaders(),
    body: method === "GET" ? undefined : JSON.stringify(body),
    signal: AbortSignal.timeout(25_000),
  });
  let result: Record<string, unknown> = {};
  try {
    const parsed = await response.json();
    if (parsed && typeof parsed === "object") result = parsed as Record<string, unknown>;
  } catch (_) {}
  if (!response.ok) {
    throw new Error(`Rupantor Pay returned HTTP ${response.status}.`);
  }
  return result;
}

async function authenticatedUser(req: Request) {
  const header = req.headers.get("Authorization") ?? "";
  const token = header.replace(/^Bearer\s+/i, "");
  if (!token) return null;
  const { data, error: authError } = await supa.auth.getUser(token);
  if (authError || !data.user) return null;
  return data.user;
}

async function planFor(id: string) {
  if (!["basic", "pro", "professional"].includes(id)) return null;
  const { data } = await supa
    .from("subscription_plans")
    .select("id,name,price_bdt,duration_days,subject_limit,no_watermark,ai_assistant,ai_daily_limit,omr_scanner")
    .eq("id", id)
    .eq("is_active", true)
    .maybeSingle();
  return data;
}

async function verifyAndActivate(providerTransactionId: string, providerStatus?: string) {
  const status = providerStatus ?? "paid";
  const { data, error: rpcError } = await supa.rpc(
    "activate_subscription_transaction",
    {
      p_provider_transaction_id: providerTransactionId,
      p_status: status,
    },
  );
  if (rpcError) throw new Error("Could not apply the verified subscription.");
  return data as Record<string, unknown>;
}

async function handleWebhook(req: Request) {
  const configured = Deno.env.get("RUPANTOR_WEBHOOK_SECRET") ?? "";
  const supplied = req.headers.get("x-rupantor-signature") ?? "";
  if (!configured || supplied !== configured) return error("Invalid webhook signature.", 401, "UNAUTHORIZED");
  let payload: Record<string, unknown>;
  try { payload = await req.json(); } catch (_) { return error("Invalid webhook JSON."); }
  const providerId = firstString(payload, [
    "transaction_id", "transactionId", "payment_id", "paymentId", "txn_id", "txnId", "id",
  ]);
  if (!providerId) return error("Webhook has no transaction id.");
  const status = String(payload.status ?? payload.payment_status ?? payload.result ?? "").toLowerCase();
  if (!paidStatus(payload) && !failedStatus(payload)) return json({ ok: true, status: "pending" });
  const result = await verifyAndActivate(providerId, paidStatus(payload) ? "paid" : status);
  return json({ ok: result.ok === true, status: result.status ?? status });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });
  if (req.method !== "POST") return error("POST only.", 405, "BAD_REQUEST");

  // Provider webhooks do not carry a Supabase user JWT.
  if (req.headers.has("x-rupantor-signature")) {
    try { return await handleWebhook(req); } catch (_) { return error("Webhook processing failed.", 502); }
  }

  const user = await authenticatedUser(req);
  if (!user) return error("Sign in before starting a subscription.", 401, "UNAUTHORIZED");

  let payload: Record<string, unknown>;
  try { payload = await req.json(); } catch (_) { return error("Invalid JSON body."); }
  const action = String(payload.action ?? "");

  try {
    if (action === "initiate") {
      const planId = String(payload.plan ?? "");
      const plan = await planFor(planId);
      if (!plan) return error("Unknown or inactive plan.", 400, "UNKNOWN_PLAN");
      if (!Deno.env.get("RUPANTOR_CREATE_URL")) return error("Rupantor Pay is not configured on the server.", 503, "NOT_CONFIGURED");

      const orderId = crypto.randomUUID();
      const { data: pending, error: insertError } = await supa
        .from("subscription_transactions")
        .insert({
          user_id: user.id,
          plan_id: planId,
          provider: "rupantorpay",
          amount_bdt: Number(plan.price_bdt),
          status: "pending",
          metadata: { order_id: orderId },
        })
        .select("id")
        .single();
      if (insertError || !pending) return error("Could not create a payment record.", 500);

      let provider: Record<string, unknown>;
      try {
        provider = await providerRequest(Deno.env.get("RUPANTOR_CREATE_URL")!, {
          amount: Number(plan.price_bdt),
          currency: "BDT",
          order_id: orderId,
          customer_id: user.id,
          customer_name: user.user_metadata?.name ?? "Tutor",
          customer_email: user.email ?? "",
          success_url: Deno.env.get("RUPANTOR_SUCCESS_URL") ?? "",
          cancel_url: Deno.env.get("RUPANTOR_CANCEL_URL") ?? "",
          webhook_url: `${Deno.env.get("SUPABASE_URL") ?? ""}/functions/v1/rupantor-pay`,
        });
      } catch (_) {
        await supa.from("subscription_transactions").update({ status: "failed" }).eq("id", pending.id);
        return error("Rupantor Pay could not start the payment.", 502, "PROVIDER_ERROR");
      }
      const providerId = firstString(provider, [
        "transaction_id", "transactionId", "payment_id", "paymentId", "txn_id", "txnId", "id",
      ]);
      const checkoutUrl = firstString(provider, [
        "checkout_url", "checkoutUrl", "payment_url", "paymentUrl", "redirect_url", "redirectUrl", "url",
      ]);
      if (!providerId || !checkoutUrl) {
        await supa.from("subscription_transactions").update({ status: "failed", metadata: provider }).eq("id", pending.id);
        return error("Rupantor Pay returned an incomplete payment.", 502, "PROVIDER_RESPONSE");
      }
      const { error: updateError } = await supa
        .from("subscription_transactions")
        .update({ provider_transaction_id: providerId, metadata: provider })
        .eq("id", pending.id);
      if (updateError) return error("Could not save the provider transaction.", 500);
      return json({ ok: true, transactionId: providerId, checkoutUrl, status: "pending" });
    }

    if (action === "verify") {
      const providerId = String(payload.transactionId ?? payload.transaction_id ?? "");
      if (!providerId) return error("Missing transaction id.");
      const { data: tx } = await supa
        .from("subscription_transactions")
        .select("id,status,user_id")
        .eq("provider_transaction_id", providerId)
        .eq("user_id", user.id)
        .maybeSingle();
      if (!tx) return error("Unknown payment.", 404, "UNKNOWN_TRANSACTION");
      if (tx.status === "paid") return json({ ok: true, status: "active" });
      if (tx.status !== "pending") return json({ ok: false, status: tx.status });
      const provider = await providerRequest(
        Deno.env.get("RUPANTOR_VERIFY_URL") ?? "",
        { transaction_id: providerId, payment_id: providerId },
      );
      if (paidStatus(provider)) {
        const result = await verifyAndActivate(providerId, "paid");
        return json({ ok: result.ok === true, status: result.status ?? "active" });
      }
      if (failedStatus(provider)) {
        await supa.from("subscription_transactions").update({ status: "failed", metadata: provider }).eq("id", tx.id);
        return json({ ok: false, status: "failed" });
      }
      return json({ ok: true, status: "pending" });
    }

    return error("Unknown action.", 400, "BAD_REQUEST");
  } catch (_) {
    return error("The payment request could not be completed.", 502, "PROVIDER_ERROR");
  }
});
