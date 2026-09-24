// ─────────────────────────────────────────────────────────────────────
// Tutor's Desk — MiMi AI gateway (server-side Gemini)
//
// The app no longer needs a per-device Gemini key for everyday use:
//   app ──user JWT──▶ this function ──GEMINI_API_KEY──▶ Gemini
//
// Secrets (Supabase → Edge Functions → Secrets):
//   GEMINI_API_KEY        your Gemini key from aistudio.google.com
//
// Deploy:
//   supabase functions deploy mimi
//   supabase secrets set GEMINI_API_KEY=...
//
// Contract (POST /functions/v1/mimi):
//   { action: "chat",
//     system?: string,
//     history?: [{ role: "user"|"model", text: string }],
//     text?: string,
//     attachments?: [{ mime: string, data: base64 }] }
//
// Success: 200, text/event-stream — the raw Gemini alt=sse stream
// (identical line format to the direct API, so the app reuses one
// parser for server and device-key paths).
// Failure: JSON { ok: false, error, code } with code one of
//   UNAUTHORIZED · BAD_REQUEST · NOT_CONFIGURED · KEY_INVALID ·
//   QUOTA · PAYLOAD_TOO_LARGE · MODEL_UNAVAILABLE · GEMINI_ERROR
// ─────────────────────────────────────────────────────────────────────

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { readJsonObject, RequestBodyError } from "./request_body.ts";

const GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta";

// Stable flash models, best-first. Mirrors the app's fallback list so
// server and device-key paths degrade the same way.
const MODELS = [
  "gemini-3.6-flash",
  "gemini-3.8-flash",
  "gemini-3.7-flash",
  "gemini-3.5-flash",
  "gemini-2.5-flash",
];

// Kept in sync with the app's limits after resize; anything above the
// edge-function payload budget is routed by the app to a device key.
const MAX_ATTACHMENTS = 3;

const DEFAULT_SYSTEM =
  "You are MiMi, an expert SSC tutor for the Bangladesh Education Board (NCTB curriculum, SSC 2027). Answer exam-ready, in the board's style.";

function corsHeaders(): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

function fail(error: string, status = 400, code = "ERROR"): Response {
  return new Response(
    JSON.stringify({ ok: false, error, code }),
    {
      status,
      headers: { ...corsHeaders(), "Content-Type": "application/json" },
    },
  );
}

const supa = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
);

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders() });
  }
  if (req.method !== "POST") return fail("POST only.", 405, "BAD_REQUEST");

  // Never an open proxy: a signed-in Tutor's Desk account is required.
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = /^Bearer\s+(\S+)$/i.exec(authHeader)?.[1];
  if (!token) return fail("Sign in to use MiMi.", 401, "UNAUTHORIZED");
  try {
    const { data: userData, error: authError } = await supa.auth.getUser(token);
    if (!userData?.user || authError) {
      return fail("Sign in to use MiMi.", 401, "UNAUTHORIZED");
    }
  } catch {
    return fail("Could not verify your session. Try again.", 503, "AUTH_UNAVAILABLE");
  }

  const key = Deno.env.get("GEMINI_API_KEY") ?? "";
  if (!key) {
    return fail(
      "The server AI key is not configured yet (GEMINI_API_KEY secret).",
      503,
      "NOT_CONFIGURED",
    );
  }

  let payload: Record<string, unknown>;
  try {
    payload = await readJsonObject(req);
  } catch (error) {
    if (error instanceof RequestBodyError) {
      return fail(error.message, error.status, error.code);
    }
    return fail("Could not read request body.", 400, "BAD_REQUEST");
  }
  if (payload.action !== "chat") return fail("Unknown action.", 400, "BAD_REQUEST");

  if (payload.attachments !== undefined && !Array.isArray(payload.attachments)) {
    return fail("Attachments must be an array.", 400, "BAD_REQUEST");
  }
  if (payload.history !== undefined && !Array.isArray(payload.history)) {
    return fail("History must be an array.", 400, "BAD_REQUEST");
  }
  const attachments = Array.isArray(payload.attachments)
    ? payload.attachments
    : [];
  if (attachments.length > MAX_ATTACHMENTS) {
    return fail(`Too many attachments (max ${MAX_ATTACHMENTS}).`, 400, "BAD_REQUEST");
  }

  const parts: Array<Record<string, unknown>> = [];
  for (const a of attachments) {
    const data = a?.data;
    const mime = a?.mime;
    if (typeof data !== "string" || data.length === 0 ||
        typeof mime !== "string" || mime.length === 0) {
      return fail("Malformed attachment.", 400, "BAD_REQUEST");
    }
    parts.push({ inline_data: { mime_type: mime, data } });
  }
  const text = typeof payload.text === "string" ? payload.text : "";
  if (text) parts.push({ text });
  if (parts.length === 0) return fail("Add a question or an attachment first.", 400, "BAD_REQUEST");

  const history = (Array.isArray(payload.history) ? payload.history : [])
    .slice(-8)
    .map((h) => ({
      role: h?.role === "model" ? "model" : "user",
      text: typeof h?.text === "string" && h.text.length > 0 ? h.text : " ",
    }));

  const geminiBody = JSON.stringify({
    systemInstruction: {
      parts: [{ text: typeof payload.system === "string" && payload.system ? payload.system : DEFAULT_SYSTEM }],
    },
    contents: [
      ...history.map((h) => ({ role: h.role, parts: [{ text: h.text }] })),
      { role: "user", parts },
    ],
    generationConfig: { temperature: 0.4, maxOutputTokens: 8192 },
  });

  let lastMsg = "No Gemini model available on the server.";
  for (const model of MODELS) {
    let resp: Response;
    try {
      resp = await fetch(
        `${GEMINI_BASE}/models/${model}:streamGenerateContent?alt=sse&key=${key}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: geminiBody,
          signal: AbortSignal.timeout(180_000),
        },
      );
    } catch (_) {
      return fail("Could not reach Gemini from the server.", 502, "GEMINI_ERROR");
    }

    if (resp.ok) {
      // Pass the SSE stream straight through — same wire format as the
      // direct API, so the app parses it with one code path.
      return new Response(resp.body, {
        status: 200,
        headers: { "Content-Type": "text/event-stream", ...corsHeaders() },
      });
    }

    let msg = `Gemini error (code ${resp.status}).`;
    try {
      const j = JSON.parse(await resp.text()) as { error?: { message?: string } };
      if (j.error?.message) msg = j.error.message.split("\n")[0].trim();
    } catch (_) {}

    const code =
      resp.status === 404 || /not found/i.test(msg)
        ? "MODEL_UNAVAILABLE"
        : /API key not valid|API_KEY_INVALID/.test(msg)
          ? "KEY_INVALID"
          : /quota|RESOURCE_EXHAUSTED|limit exceeded|billing/i.test(msg)
            ? "QUOTA"
            : /PAYLOAD_TOO_LARGE|too large/i.test(msg)
              ? "PAYLOAD_TOO_LARGE"
              : "GEMINI_ERROR";
    lastMsg = msg;
    if (code === "MODEL_UNAVAILABLE") continue; // try the next model
    return fail(msg, resp.status >= 500 ? 502 : 400, code);
  }
  return fail(lastMsg, 502, "MODEL_UNAVAILABLE");
});
