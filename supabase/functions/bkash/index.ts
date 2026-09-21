// ─────────────────────────────────────────────────────────────────────
// Tutor's Desk — bKash payment edge function
//
// Deployed on Supabase (see SUPABASE_BKASH_SETUP.md). Two actions:
//
//   { action: "initiate", plan, phone, buyerName, buyerEmail }
//     → starts a bKash Collect payment for the exact plan amount and
//       returns { ok, trxId, checkoutUrl, amount }.
//
//   { action: "verify", trxId }
//     → runs bKash's inquiry API. When bKash reports "Success" the
//       caller's profile is marked Pro (is_pro, pro_until, pro_plan)
//       and the reply is { ok, status: "active" }.
//       Otherwise { ok, status: "pending" | "failed" }.
//
// Secrets (set in Supabase → Edge Functions → Secrets):
//   BKAASH_MERCHANT_ID, BKAASH_PUBLIC_KEY, BKAASH_PRIVATE_KEY,
//   BKAASH_ACCESS_TOKEN, BKAASH_NOTIFY_URL
//
// ─────────────────────────────────────────────────────────────────────

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

// ⚠️ PLAN PRICES — must match lib/services/bkash_service.dart
const PLANS: Record<string, { amount: number; periodDays: number | null; label: string }> = {
  monthly: { amount: 299, periodDays: 30, label: "Pro Monthly" },
  yearly: { amount: 2499, periodDays: 365, label: "Pro Yearly" },
  lifetime: { amount: 799, periodDays: null, label: "Pro One-time" },
};

// Production gateway. For bKash SANDBOX testing set the edge-function
// secret BKAASH_BASE_URL to https://sandboxipgs.bka.sh/collectiongateway/api/v2.2
const BKASH_BASE =
  Deno.env.get("BKAASH_BASE_URL") ??
  "https://ipgs.bka.sh/collectiongateway/api/v2.2";

function corsHeaders(): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(), "Content-Type": "application/json" },
  });
}

/// bKash signs the exact JSON request body: base64(HMAC-SHA512(body, privateKey)).
async function bkaashSignature(body: string): Promise<string> {
  const secret = Deno.env.get("BKAASH_PRIVATE_KEY") ?? "";
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-512" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  const bytes = new Uint8Array(sig);
  let bin = "";
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin);
}

async function bkaashCall(path: string, payload: object): Promise<Record<string, unknown>> {
  const body = JSON.stringify(payload);
  const sig = await bkaashSignature(body);
  const res = await fetch(`${BKASH_BASE}/${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": Deno.env.get("BKAASH_PUBLIC_KEY") ?? "",
      "Authorization": `Bearer ${Deno.env.get("BKAASH_ACCESS_TOKEN") ?? ""}`,
      "x-signature": sig,
    },
    body,
  });
  let data: Record<string, unknown> = {};
  try {
    data = (await res.json()) as Record<string, unknown>;
  } catch (_) {
    data = { ResponseCode: String(res.status), Message: "non-JSON response" };
  }
  return data;
}

function nowIso(): string {
  return new Date().toISOString();
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders() });
  }
  if (req.method !== "POST") return json({ ok: false, error: "POST only" }, 405);

  const supa = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // The app invokes with the user's JWT — bind the payment to that account.
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "");
  const { data: userData, error: authError } = await supa.auth.getUser(token);
  const user = userData?.user;
  if (!user || authError) {
    return json({ ok: false, error: "Sign in with your Tutor's Desk account first." }, 401);
  }

  let payload: Record<string, unknown>;
  try {
    payload = (await req.json()) as Record<string, unknown>;
  } catch (_) {
    return json({ ok: false, error: "Invalid JSON body." }, 400);
  }

  const action = payload.action as string | undefined;
  if (action !== "initiate" && action !== "verify") {
    return json({ ok: false, error: "Unknown action." }, 400);
  }

  try {
    if (action === "initiate") {
      const planId = payload.plan as string | undefined;
      const plan = planId ? PLANS[planId] : undefined;
      if (!plan) return json({ ok: false, error: "Unknown plan." }, 400);

      const phone = String(payload.phone ?? "").replace(/\D/g, "");
      if (!/^01\d{9}$/.test(phone)) {
        return json({ ok: false, error: "Enter the bKash number (01XXXXXXXXX)." }, 400);
      }
      const name = String(payload.buyerName ?? "").slice(0, 60) || "Tutor";
      const email = String(payload.buyerEmail ?? "") || user.email || "unknown@example.com";

      const body = JSON.stringify({
        amount: String(plan.amount),
        currency: "BDT",
        productName: `Tutor's Desk ${plan.label}`,
        merchantUserName: Deno.env.get("BKAASH_MERCHANT_ID") ?? "",
        deviceId: "WEB",
        buyerName: name,
        buyerEmail: email,
        buyerPhone: phone,
        notifyUrl: Deno.env.get("BKAASH_NOTIFY_URL") ?? "",
        executeTime: nowIso(),
        executeSessionId: crypto.randomUUID(),
        description: `Tutor's Desk — ${plan.label}`,
      });
      const sig = await bkaashSignature(body);
      const res = await fetch(`${BKASH_BASE}/paymentCollection`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": Deno.env.get("BKAASH_PUBLIC_KEY") ?? "",
          "Authorization": `Bearer ${Deno.env.get("BKAASH_ACCESS_TOKEN") ?? ""}`,
          "x-signature": sig,
        },
        body,
      });
      let b: Record<string, unknown> = {};
      try { b = (await res.json()) as Record<string, unknown>; } catch (_) {}

      const code = String(b.ResponseCode ?? "");
      if (code !== "000") {
        return json(
          { ok: false, error: `bKash declined to start payment: ${String(b.ResponseMsg ?? code)}` },
          400,
        );
      }
      const trxId = String(b.TrxID ?? "");
      const checkoutUrl = String(b.CheckoutURL ?? "");
      if (!trxId || !checkoutUrl) {
        return json({ ok: false, error: "bKash response was incomplete — try again." }, 502);
      }

      // Remember this TrxID so verify() only honours payments WE started.
      await supa.from("bkash_payments").insert({
        trxid: trxId,
        email: user.email ?? "",
        user_id: user.id,
        plan: planId!,
        amount: plan.amount,
      });

      return json({ ok: true, trxId, checkoutUrl, amount: plan.amount });
    }

    // ── verify ──
    const trxId = String(payload.trxId ?? "");
    if (!trxId) return json({ ok: false, error: "Missing trxId." }, 400);

    const { data: pending } = await supa
      .from("bkash_payments")
      .select("plan")
      .eq("trxid", trxId)
      .maybeSingle();
    const planId = pending?.plan as string | undefined;
    const plan = planId ? PLANS[planId] : undefined;
    if (!plan) {
      return json({ ok: false, error: "Unknown payment — it was not started from this app." }, 400);
    }

    const inquiry = await bkaashCall("paymentInquiry", { TrxID: trxId });
    const status = String(inquiry.PaymentStatus ?? "").toLowerCase();

    if (status === "success") {
      let until: string | null = null;
      if (plan.periodDays != null) {
        until = new Date(Date.now() + plan.periodDays * 86400000).toISOString();
      }
      await supa
        .from("profiles")
        .update({ is_pro: true, pro_until: until, pro_plan: planId, pro_updated_at: nowIso() })
        .eq("id", user.id);

      return json({ ok: true, status: "active" });
    }
    if (status === "failed" || status === "rejected" || status === "reversed") {
      return json({ ok: true, status: "failed" });
    }
    return json({ ok: true, status: "pending" });
  } catch (e) {
    return json({ ok: false, error: `Payment error: ${String(e)}` }, 500);
  }
});
