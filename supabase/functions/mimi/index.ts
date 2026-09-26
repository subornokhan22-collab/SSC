// ─────────────────────────────────────────────────────────────────────
// Tutor's Desk — AI Tools AI gateway (server-side Gemini)
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
import { toolRequest, runTeacherTool, ToolError } from "./teacher_tools.ts";
import { ProviderError, readProviderError, providerTransportError } from "./provider_errors.ts";

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
  "You are AI Tools, an expert SSC tutor for the Bangladesh Education Board (NCTB curriculum, SSC 2027). Answer exam-ready, in the board's style.";

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
  if (!token) return fail("Sign in to use AI Tools.", 401, "UNAUTHORIZED");
  try {
    const { data: userData, error: authError } = await supa.auth.getUser(token);
    if (!userData?.user || authError) {
      return fail("Sign in to use AI Tools.", 401, "UNAUTHORIZED");
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
  if (["generate", "improve", "check", "explain"].includes(String(payload.action))) {
    let command;
    try { command = toolRequest(payload); } catch (e) {
      return fail(e instanceof ToolError || e instanceof RequestBodyError ? e.message : "Invalid teacher command.", e instanceof RequestBodyError ? e.status : 400, "BAD_REQUEST");
    }
    const encoder = new TextEncoder();
    const cancellation = new AbortController();
    // A language repair must not multiply the total Edge Function time budget.
    const commandDeadline = Date.now() + 120000;
    req.signal.addEventListener("abort", () => cancellation.abort(), {once:true});
    const stream = new ReadableStream({
      async start(controller) {
        const send = (event:string, data:unknown) => {
          // Keep delimiters in an escaped string: bundlers may emit template
          // newlines literally, which phone-editor auto-indent can corrupt.
          const frame = ["event: " + event, "data: " + JSON.stringify(data), "", ""].join("\n");
          if (!cancellation.signal.aborted) controller.enqueue(encoder.encode(frame));
        };
        try {
          const result = await runTeacherTool(command, async (system, input, schema, validator=false) => {
            const model = Deno.env.get(validator ? "GEMINI_VALIDATOR_MODEL" : "GEMINI_GENERATOR_MODEL") || "gemini-2.5-flash";
            if (!/^[a-zA-Z0-9._-]+$/.test(model)) throw new ToolError("The server model configuration is invalid.");
            const stage = validator ? "validator" : "generator";
            const remaining = commandDeadline - Date.now();
            if (remaining <= 0) throw providerTransportError({name:"TimeoutError"}, stage);
            let resp: Response;
            try {
              resp = await fetch(`${GEMINI_BASE}/models/${model}:generateContent`, {
                method:"POST", headers:{"Content-Type":"application/json", "x-goog-api-key":key},
                signal:AbortSignal.any([cancellation.signal,AbortSignal.timeout(Math.min(75000, remaining))]),
                body:JSON.stringify({systemInstruction:{parts:[{text:system}]},contents:[{role:"user",parts:[{text:input}, ...(!validator ? (command.attachments ?? []).map(a=>({inline_data:{mime_type:a.mimeType,data:a.data}})) : [])]}],generationConfig:{temperature:validator?0:0.4,maxOutputTokens:16384,responseMimeType:"application/json",responseSchema:schema}}),
              });
            } catch (error) {
              if (cancellation.signal.aborted) throw error;
              throw providerTransportError(error, stage);
            }
            if (!resp.ok) throw await readProviderError(resp, stage);
            const body=await resp.json();
            const candidate=body.candidates?.[0];
            if(candidate?.finishReason!=="STOP")throw new ToolError("The AI response was blocked or cut short. Try fewer questions.");
            const text=(candidate.content?.parts??[]).map((p:{text?:string})=>p.text??"").join("");
            try{return JSON.parse(text);}catch{throw new ToolError("The AI response did not match the required JSON schema.");}
          }, phase=>send("phase",{message:phase}));
          send("result",result);
        } catch(e) {
          const diagnostic = e instanceof ProviderError
            ? {code:e.code, upstreamStatus:e.upstreamStatus, stage:e.stage}
            : {};
          if (e instanceof ProviderError && !cancellation.signal.aborted) {
            // Fixed fields only: never log keys, headers, prompts, model output,
            // raw provider messages or environment-controlled model names.
            console.warn(JSON.stringify({event:"mimi_provider_error", ...diagnostic}));
          }
          send("error",{message:e instanceof ToolError?e.message:"The AI request could not finish. Check your connection and retry.", ...diagnostic});
        } finally { if(!cancellation.signal.aborted)controller.close(); }
      },
      cancel(){cancellation.abort();},
    });
    return new Response(stream,{headers:{...corsHeaders(),"Content-Type":"text/event-stream","Cache-Control":"no-cache","X-Teacher-Attachments-Version":"1"}});
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
