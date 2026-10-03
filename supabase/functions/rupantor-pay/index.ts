// Tutor's Desk — Rupantor Pay payment adapter.
//
// Flutter sends only a stable plan id. Prices are loaded from
// public.subscription_plans and activation happens only after an independent
// Rupantor verification call. Provider credentials stay in Edge Function
// secrets:
//   RUPANTOR_CREATE_URL, RUPANTOR_VERIFY_URL
//   RUPANTOR_API_KEY, RUPANTOR_CLIENT
//   RUPANTOR_SUCCESS_URL, RUPANTOR_CANCEL_URL, RUPANTOR_APP_REDIRECT_URL
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const supa = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

type JsonObject = Record<string, unknown>;

type Transaction = {
  id: string;
  status: string;
  user_id: string;
  plan_id: string;
  amount_bdt: number;
  provider_transaction_id: string | null;
  metadata: JsonObject;
};

function json(body: JsonObject, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

function error(message: string, status = 400, code = "PAYMENT_ERROR") {
  return json({ ok: false, error: message, code }, status);
}

function firstString(body: JsonObject, keys: string[]) {
  for (const key of keys) {
    const value = body[key];
    if (value != null && String(value).trim()) return String(value).trim();
  }
  return null;
}

function firstNumber(body: JsonObject, keys: string[]) {
  for (const key of keys) {
    const value = body[key];
    const number = typeof value === "number"
      ? value
      : Number(String(value ?? "").replace(/,/g, "").trim());
    if (Number.isFinite(number)) return number;
  }
  return null;
}

function providerTransactionId(body: JsonObject) {
  // These names are the documented Rupantor notification/verification fields.
  // Do not broaden this list without confirming a provider contract update.
  return firstString(body, ["transaction_id"]);
}

function providerAmount(body: JsonObject) {
  return firstNumber(body, ["amount"]);
}

function providerCurrency(body: JsonObject) {
  return firstString(body, ["currency"])?.toUpperCase() ?? null;
}

function paymentStatus(body: JsonObject) {
  return String(body.status ?? "").trim().toLowerCase();
}

function paidStatus(body: JsonObject) {
  return ["paid", "success", "successful", "completed", "complete", "captured"].includes(
    paymentStatus(body),
  );
}

function failedStatus(body: JsonObject) {
  return [
    "failed",
    "failure",
    "cancelled",
    "canceled",
    "invalid",
    "rejected",
    "expired",
  ].includes(paymentStatus(body));
}

function providerHeaders(): HeadersInit {
  const apiKey = Deno.env.get("RUPANTOR_API_KEY") ?? "";
  const client = Deno.env.get("RUPANTOR_CLIENT") ?? "";
  return {
    "Content-Type": "application/json",
    "X-API-KEY": apiKey,
    "X-CLIENT": client,
  };
}

async function providerRequest(
  url: string,
  body: JsonObject,
): Promise<JsonObject> {
  if (!url) throw new Error("Rupantor Pay endpoint is not configured.");
  const response = await fetch(url, {
    method: "POST",
    headers: providerHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(25_000),
  });
  let result: JsonObject = {};
  try {
    const parsed = await response.json();
    if (parsed && typeof parsed === "object") result = parsed as JsonObject;
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
  const { data, error: planError } = await supa
    .from("subscription_plans")
    .select(
      "id,name,price_bdt,duration_days,subject_limit,no_watermark,ai_assistant,ai_daily_limit,omr_scanner",
    )
    .eq("id", id)
    .eq("is_active", true)
    .maybeSingle();
  if (planError) throw new Error("Could not load the server plan.");
  return data;
}

function metadataOrderId(value: unknown) {
  if (value && typeof value === "object") {
    return firstString(value as JsonObject, ["order_id", "orderId"]);
  }
  if (typeof value === "string") {
    try {
      return metadataOrderId(JSON.parse(value));
    } catch (_) {}
  }
  return null;
}

async function transactionByProviderId(providerId: string): Promise<Transaction | null> {
  const { data } = await supa
    .from("subscription_transactions")
    .select("id,status,user_id,plan_id,amount_bdt,provider_transaction_id,metadata")
    .eq("provider_transaction_id", providerId)
    .maybeSingle();
  return data as Transaction | null;
}

async function transactionByOrderId(orderId: string): Promise<Transaction | null> {
  const { data } = await supa
    .from("subscription_transactions")
    .select("id,status,user_id,plan_id,amount_bdt,provider_transaction_id,metadata")
    .filter("metadata->>order_id", "eq", orderId)
    .maybeSingle();
  return data as Transaction | null;
}

async function transactionForUser(
  userId: string,
  reference: string,
): Promise<Transaction | null> {
  const provider = await transactionByProviderId(reference);
  if (provider?.user_id === userId) return provider;
  const order = await transactionByOrderId(reference);
  return order?.user_id === userId ? order : null;
}

async function linkProviderTransaction(
  tx: Transaction,
  providerId: string,
  providerResponse?: JsonObject,
) {
  const metadata: JsonObject = {
    ...(tx.metadata ?? {}),
    ...(providerResponse ? { provider_response: providerResponse } : {}),
  };
  await supa
    .from("subscription_transactions")
    .update({ provider_transaction_id: providerId, metadata })
    .eq("id", tx.id)
    .is("provider_transaction_id", null);
}

async function verifyAndActivate(
  providerId: string,
  status: string,
  amount: number | null,
  currency: string | null,
) {
  const { data, error: rpcError } = await supa.rpc(
    "activate_subscription_transaction",
    {
      p_provider_transaction_id: providerId,
      p_status: status,
      p_provider_amount: amount,
      p_provider_currency: currency,
    },
  );
  if (rpcError) throw new Error("Could not apply the verified subscription.");
  return data as JsonObject;
}

async function verifyProvider(providerId: string) {
  // This is the documented Rupantor verification contract. Never activate
  // from a redirect or webhook status alone.
  return providerRequest(Deno.env.get("RUPANTOR_VERIFY_URL") ?? "", {
    transaction_id: providerId,
  });
}

async function finalizeProviderTransaction(providerId: string) {
  const tx = await transactionByProviderId(providerId);
  if (!tx) return { ok: false, status: "unknown" };
  if (tx.status === "paid") return { ok: true, status: "active" };
  if (tx.status !== "pending") return { ok: false, status: tx.status };

  const verified = await verifyProvider(providerId);
  if (paidStatus(verified)) {
    const result = await verifyAndActivate(
      providerId,
      "paid",
      providerAmount(verified),
      providerCurrency(verified),
    );
    return {
      ok: result.ok === true,
      status: result.status ?? "pending",
    };
  }
  if (failedStatus(verified)) {
    await verifyAndActivate(providerId, paymentStatus(verified) || "failed", null, null);
    return { ok: false, status: "failed" };
  }
  return { ok: true, status: "pending" };
}

async function handleProviderNotification(payload: JsonObject) {
  const providerId = providerTransactionId(payload);
  if (!providerId) return error("Payment notification has no transaction id.");

  let tx = await transactionByProviderId(providerId);
  if (!tx) {
    const orderId = firstString(payload, ["order_id"]) ??
      metadataOrderId(payload.meta_data);
    if (orderId) {
      tx = await transactionByOrderId(orderId);
      if (tx) await linkProviderTransaction(tx, providerId, payload);
    }
  }
  if (!tx) return error("Unknown payment transaction.", 404, "UNKNOWN_TRANSACTION");

  // The notification is only a wake-up signal. Verification supplies the
  // trusted status, amount and currency before the database can activate it.
  const result = await finalizeProviderTransaction(providerId);
  return json({ ok: result.ok, status: result.status });
}

function redirectResponse(status: string, providerId: string | null) {
  const target = Deno.env.get("RUPANTOR_APP_REDIRECT_URL");
  if (!target) return json({ ok: status === "active", status, transactionId: providerId });
  try {
    const url = new URL(target);
    url.searchParams.set("payment_status", status);
    if (providerId) url.searchParams.set("transaction_id", providerId);
    return Response.redirect(url, 303);
  } catch (_) {
    return json({ ok: status === "active", status, transactionId: providerId });
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });

  // Rupantor may deliver completion data to the configured success/cancel
  // URL as query parameters. Treat the redirect exactly like a webhook:
  // independently verify it, then redirect to the app if configured.
  if (req.method === "GET") {
    const query = Object.fromEntries(new URL(req.url).searchParams.entries());
    const providerId = providerTransactionId(query);
    if (!providerId) return error("Payment redirect has no transaction id.");
    try {
      const response = await handleProviderNotification(query);
      let body: JsonObject = {};
      try { body = await response.json(); } catch (_) {}
      return redirectResponse(String(body.status ?? "pending"), providerId);
    } catch (_) {
      return redirectResponse("pending", providerId);
    }
  }
  if (req.method !== "POST") return error("POST only.", 405, "BAD_REQUEST");

  let payload: JsonObject;
  try {
    const body = await req.json();
    if (!body || typeof body !== "object" || Array.isArray(body)) {
      return error("Invalid JSON body.");
    }
    payload = body as JsonObject;
  } catch (_) {
    return error("Invalid JSON body.");
  }

  // Provider notifications do not carry a Supabase JWT and are intentionally
  // not authenticated by an undocumented signature header. Their only trust
  // boundary is the independent verify-payment call above.
  const action = String(payload.action ?? "");
  if (action !== "initiate" && action !== "verify") {
    try { return await handleProviderNotification(payload); } catch (_) {
      return error("Payment verification failed.", 502, "PROVIDER_ERROR");
    }
  }

  const user = await authenticatedUser(req);
  if (!user) return error("Sign in before starting a subscription.", 401, "UNAUTHORIZED");

  try {
    if (action === "initiate") {
      const planId = String(payload.plan ?? "");
      const plan = await planFor(planId);
      if (!plan) return error("Unknown or inactive plan.", 400, "UNKNOWN_PLAN");
      if (!Deno.env.get("RUPANTOR_CREATE_URL")) {
        return error("Rupantor Pay is not configured on the server.", 503, "NOT_CONFIGURED");
      }

      const orderId = crypto.randomUUID();
      const { data: pending, error: insertError } = await supa
        .from("subscription_transactions")
        .insert({
          user_id: user.id,
          plan_id: planId,
          provider: "rupantorpay",
          amount_bdt: Number(plan.price_bdt),
          status: "pending",
          metadata: { order_id: orderId, plan_id: planId },
        })
        .select("id")
        .single();
      if (insertError || !pending) return error("Could not create a payment record.", 500);

      let provider: JsonObject;
      try {
        provider = await providerRequest(Deno.env.get("RUPANTOR_CREATE_URL")!, {
          fullname: user.user_metadata?.name ?? "Tutor",
          email: user.email ?? "",
          amount: Number(plan.price_bdt),
          success_url: Deno.env.get("RUPANTOR_SUCCESS_URL") ?? "",
          cancel_url: Deno.env.get("RUPANTOR_CANCEL_URL") ?? "",
          webhook_url: `${Deno.env.get("SUPABASE_URL") ?? ""}/functions/v1/rupantor-pay`,
          meta_data: { order_id: orderId, plan_id: planId },
        });
      } catch (_) {
        await supa.from("subscription_transactions").update({ status: "failed" }).eq("id", pending.id);
        return error("Rupantor Pay could not start the payment.", 502, "PROVIDER_ERROR");
      }

      const checkoutUrl = firstString(provider, ["payment_url"]);
      if (!checkoutUrl) {
        await supa.from("subscription_transactions").update({
          status: "failed",
          metadata: { order_id: orderId, plan_id: planId, provider_response: provider },
        }).eq("id", pending.id);
        return error("Rupantor Pay returned an incomplete payment link.", 502, "PROVIDER_RESPONSE");
      }

      await supa.from("subscription_transactions").update({
        metadata: { order_id: orderId, plan_id: planId, provider_response: provider },
      }).eq("id", pending.id);
      // The checkout response contains only payment_url. The client polls
      // with this internal order id until the webhook/redirect supplies the
      // provider transaction id and verification completes.
      return json({ ok: true, orderId, checkoutUrl, status: "pending" });
    }

    const reference = String(payload.transactionId ?? payload.orderId ?? payload.transaction_id ?? "");
    if (!reference) return error("Missing payment reference.");
    const tx = await transactionForUser(user.id, reference);
    if (!tx) return error("Unknown payment.", 404, "UNKNOWN_TRANSACTION");
    if (tx.status === "paid") return json({ ok: true, status: "active" });
    if (tx.status !== "pending") return json({ ok: false, status: tx.status });
    if (!tx.provider_transaction_id) return json({ ok: true, status: "pending" });

    const result = await finalizeProviderTransaction(tx.provider_transaction_id);
    return json({ ok: result.ok, status: result.status });
  } catch (_) {
    return error("The payment request could not be completed.", 502, "PROVIDER_ERROR");
  }
});
