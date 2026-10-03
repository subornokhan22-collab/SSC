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
// parser for the server stream).
// Failure: JSON { ok: false, error, code } with code one of
//   UNAUTHORIZED · BAD_REQUEST · NOT_CONFIGURED · KEY_INVALID ·
//   AI_DAILY_LIMIT · AI_BURST_LIMIT · GEMINI_RATE_LIMIT · GEMINI_QUOTA ·
//   PAYLOAD_TOO_LARGE · MODEL_UNAVAILABLE · GEMINI_ERROR
// ─────────────────────────────────────────────────────────────────────

import { createClient } from "npm:@supabase/supabase-js@2.45.4";
import { readJsonObject, RequestBodyError } from "./request_body.ts";
import { toolRequest, runTeacherTool, ToolError } from "./teacher_tools.ts";
import { teacherAttachments } from "./attachments.ts";
import { ProviderError, readProviderError, providerTransportError } from "./provider_errors.ts";

const GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta";

// Model ids are deployment configuration, not a client-side fallback list.
// Set GEMINI_GENERATOR_MODEL and GEMINI_VALIDATOR_MODEL as Edge Function
// secrets/configuration before deploying this function.
const MAX_ATTACHMENTS = 3;
const MAX_HISTORY_ITEMS = 8;
const MAX_TEXT_CHARS = 12000;

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

async function claimAiRequest(userId: string) {
  const { data, error } = await supa.rpc("claim_ai_request", {
    p_user_id: userId,
  });
  if (error || !data?.[0]) throw new Error("AI entitlement service unavailable.");
  return data[0] as {
    allowed: boolean;
    request_count: number;
    daily_limit: number;
    usage_date: string;
    reason: string;
  };
}

async function refundAiRequest(userId: string, usageDate: string) {
  await supa.rpc("refund_ai_request", {
    p_user_id: userId,
    p_usage_date: usageDate,
  });
}

async function effectivePlan(userId: string) {
  const { data } = await supa.rpc("effective_entitlement", {
    p_user_id: userId,
  });
  return data?.[0]?.plan_id?.toString() ?? "unknown";
}

async function recordAiEvent(
  userId: string,
  requestId: string,
  planId: string,
  action: string,
  status: "started" | "succeeded" | "failed",
  errorCode: string | null,
  model: string | null,
) {
  await supa.rpc("record_ai_usage_event", {
    p_user_id: userId,
    p_request_id: requestId,
    p_plan_id: planId,
    p_action: action,
    p_model: model,
    p_status: status,
    p_error_code: errorCode,
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders() });
  }
  if (req.method !== "POST") return fail("POST only.", 405, "BAD_REQUEST");

  // Never an open proxy: a signed-in Tutor's Desk account is required.
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = /^Bearer\s+(\S+)$/i.exec(authHeader)?.[1];
  if (!token) return fail("Sign in to use AI Tools.", 401, "UNAUTHORIZED");
  let authenticatedUserId: string;
  try {
    const { data: userData, error: authError } = await supa.auth.getUser(token);
    if (!userData?.user || authError) {
      return fail("Sign in to use AI Tools.", 401, "UNAUTHORIZED");
    }
    authenticatedUserId = userData.user.id;
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

  const action = String(payload.action ?? "");
  const toolActions = ["generate", "improve", "check", "explain"];
  if (!toolActions.includes(action) && action !== "chat") {
    return fail("Unknown action.", 400, "BAD_REQUEST");
  }
  let usage: {
    allowed: boolean;
    request_count: number;
    daily_limit: number;
    usage_date: string;
    reason: string;
  };
  try {
    usage = await claimAiRequest(authenticatedUserId);
  } catch (_) {
    return fail("The AI entitlement service is unavailable. Try again.", 503, "ENTITLEMENT_UNAVAILABLE");
  }
  if (!usage.allowed) {
    const limited = usage.reason === "daily_limit" || usage.reason === "burst_limit";
    return fail(
      usage.reason === "daily_limit"
        ? "Daily AI limit reached. Resets at midnight."
        : usage.reason === "burst_limit"
          ? "AI is temporarily busy. Try again shortly."
          : "AI Assistant requires an active Pro or Professional plan.",
      limited ? 429 : 403,
      usage.reason === "daily_limit"
        ? "AI_DAILY_LIMIT"
        : usage.reason === "burst_limit"
          ? "AI_BURST_LIMIT"
          : "AI_UPGRADE_REQUIRED",
    );
  }

  const requestId = crypto.randomUUID();
  const planId = await effectivePlan(authenticatedUserId);
  // Audit writes are best-effort and never block a paid AI request when the
  // logging RPC is temporarily unavailable.
  try {
    await recordAiEvent(
      authenticatedUserId,
      requestId,
      planId,
      action,
      "started",
      null,
      null,
    );
  } catch (_) {}
  if (toolActions.includes(action)) {
    let command;
    try { command = toolRequest(payload); } catch (e) {
      // Validation failures happen after the atomic claim only for backward
      // compatibility with the existing gateway order; never charge them.
      await refundAiRequest(authenticatedUserId, usage.usage_date);
      try {
        await recordAiEvent(
          authenticatedUserId,
          requestId,
          planId,
          action,
          "failed",
          "BAD_REQUEST",
          null,
        );
      } catch (_) {}
      return fail(e instanceof ToolError || e instanceof RequestBodyError ? e.message : "Invalid teacher command.", e instanceof RequestBodyError ? e.status : 400, "BAD_REQUEST");
    }
    const encoder = new TextEncoder();
    const cancellation = new AbortController();
    // A language repair must not multiply the total Edge Function time budget.
    const commandDeadline = Date.now() + 120000;
    req.signal.addEventListener("abort", () => cancellation.abort(), {once:true});
    let completed = false;
    let selectedModel: string | null = null;
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
            const model = Deno.env.get(
              validator ? "GEMINI_VALIDATOR_MODEL" : "GEMINI_GENERATOR_MODEL",
            )?.trim();
            if (!model) throw new ToolError(
              `The server ${validator ? "validator" : "generator"} model is not configured.`,
            );
            if (!/^[a-zA-Z0-9._-]+$/.test(model)) throw new ToolError("The server model configuration is invalid.");
            selectedModel = model;
            const stage = validator ? "validator" : "generator";
            const remaining = commandDeadline - Date.now();
            if (remaining <= 0) throw providerTransportError({name:"TimeoutError"}, stage);
            let resp: Response;
            try {
              resp = await fetch(`${GEMINI_BASE}/models/${model}:generateContent`, {
                method:"POST", headers:{"Content-Type":"application/json", "x-goog-api-key":key},
                signal:AbortSignal.any([cancellation.signal,AbortSignal.timeout(Math.min(75000, remaining))]),
                body:JSON.stringify({systemInstruction:{parts:[{text:system}]},contents:[{role:"user",parts:[{text:input}, ...(!validator ? (command.attachments ?? []).map(a=>({inline_data:{mime_type:a.mimeType,data:a.data}})) : [])]}],generationConfig:{maxOutputTokens:16384,responseMimeType:"application/json",responseSchema:schema}}),
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
          send("result",{...result, aiUsedToday: usage.request_count, aiRemainingToday: Math.max(0, usage.daily_limit - usage.request_count)});
          completed = true;
          try {
            await recordAiEvent(
              authenticatedUserId,
              requestId,
              planId,
              action,
              "succeeded",
              null,
              selectedModel,
            );
          } catch (_) {}
        } catch(e) {
          if (!completed) await refundAiRequest(authenticatedUserId, usage.usage_date);
          const diagnostic = e instanceof ProviderError
            ? {code:e.code, upstreamStatus:e.upstreamStatus, stage:e.stage}
            : {};
          if (e instanceof ProviderError && !cancellation.signal.aborted) {
            // Fixed fields only: never log keys, headers, prompts, model output,
            // raw provider messages or environment-controlled model names.
            console.warn(JSON.stringify({event:"mimi_provider_error", ...diagnostic}));
          }
          try {
            await recordAiEvent(
              authenticatedUserId,
              requestId,
              planId,
              action,
              "failed",
              e instanceof ProviderError ? e.code : "TOOL_ERROR",
              selectedModel,
            );
          } catch (_) {}
          send("error",{message:e instanceof ToolError?e.message:"The AI request could not finish. Check your connection and retry.", code:e instanceof ProviderError?e.code:"AI_ERROR", ...diagnostic});
        } finally { if(!cancellation.signal.aborted)controller.close(); }
      },
      cancel(){cancellation.abort();},
    });
    return new Response(stream,{headers:{...corsHeaders(),"Content-Type":"text/event-stream","Cache-Control":"no-cache","X-Teacher-Attachments-Version":"1","X-AI-Remaining":String(Math.max(0, usage.daily_limit - usage.request_count))}});
  }
  if (action !== "chat") return fail("Unknown action.", 400, "BAD_REQUEST");

  let attachments: Array<{ mimeType: string; data: string }> = [];
  try {
    const rawAttachments = Array.isArray(payload.attachments)
      ? payload.attachments.map((item) => {
          if (!item || typeof item !== "object" || Array.isArray(item)) {
            return item;
          }
          const row = item as Record<string, unknown>;
          return {
            mimeType: row.mimeType ?? row.mime,
            data: row.data,
          };
        })
      : payload.attachments;
    attachments = teacherAttachments(rawAttachments);
    if (attachments.length > MAX_ATTACHMENTS) {
      throw new RequestBodyError(`Too many attachments (max ${MAX_ATTACHMENTS}).`);
    }
  } catch (error) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(
        authenticatedUserId,
        requestId,
        planId,
        action,
        "failed",
        error instanceof RequestBodyError ? error.code : "BAD_REQUEST",
        null,
      );
    } catch (_) {}
    return fail(
      error instanceof RequestBodyError ? error.message : "Malformed attachments.",
      error instanceof RequestBodyError ? error.status : 400,
      error instanceof RequestBodyError ? error.code : "BAD_REQUEST",
    );
  }

  if (payload.history !== undefined && !Array.isArray(payload.history)) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", "BAD_REQUEST", null);
    } catch (_) {}
    return fail("History must be an array.", 400, "BAD_REQUEST");
  }
  const rawHistory = Array.isArray(payload.history) ? payload.history : [];
  if (rawHistory.length > MAX_HISTORY_ITEMS || rawHistory.some((item) => {
    if (!item || typeof item !== "object" || Array.isArray(item)) return true;
    const row = item as Record<string, unknown>;
    return !["user", "model"].includes(String(row.role)) ||
      typeof row.text !== "string" || row.text.length === 0 || row.text.length > MAX_TEXT_CHARS;
  })) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", "BAD_REQUEST", null);
    } catch (_) {}
    return fail("History contains an invalid or oversized message.", 400, "BAD_REQUEST");
  }
  const text = typeof payload.text === "string" ? payload.text : "";
  if (text.length > MAX_TEXT_CHARS) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", "BAD_REQUEST", null);
    } catch (_) {}
    return fail("The question is too long.", 400, "BAD_REQUEST");
  }
  if (typeof payload.system !== "undefined" &&
      (typeof payload.system !== "string" || payload.system.length > MAX_TEXT_CHARS)) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", "BAD_REQUEST", null);
    } catch (_) {}
    return fail("The AI instructions are too long.", 400, "BAD_REQUEST");
  }
  if (!text && attachments.length === 0) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", "BAD_REQUEST", null);
    } catch (_) {}
    return fail("Add a question or an attachment first.", 400, "BAD_REQUEST");
  }

  const parts: Array<Record<string, unknown>> = [];
  for (const a of attachments) {
    parts.push({ inline_data: { mime_type: a.mimeType, data: a.data } });
  }
  if (text) parts.push({ text });

  const history = rawHistory.map((h) => {
    const row = h as Record<string, unknown>;
    return { role: row.role as string, text: row.text as string };
  });

  const geminiBody = JSON.stringify({
    systemInstruction: {
      parts: [{ text: typeof payload.system === "string" && payload.system ? payload.system : DEFAULT_SYSTEM }],
    },
    contents: [
      ...history.map((h) => ({ role: h.role, parts: [{ text: h.text }] })),
      { role: "user", parts },
    ],
    generationConfig: { maxOutputTokens: 8192 },
  });

  const model = Deno.env.get("GEMINI_GENERATOR_MODEL")?.trim();
  if (!model || !/^[a-zA-Z0-9._-]+$/.test(model)) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", "MODEL_NOT_CONFIGURED", null);
    } catch (_) {}
    return fail("The server generator model is not configured.", 503, "MODEL_NOT_CONFIGURED");
  }

  let resp: Response;
  try {
    resp = await fetch(
      `${GEMINI_BASE}/models/${model}:streamGenerateContent?alt=sse&key=${key}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: geminiBody,
        // Keep the chat path within the same 120-second Edge Function budget
        // as structured tools; Flutter allows a small margin for stream drain.
        signal: AbortSignal.timeout(120_000),
      },
    );
  } catch (error) {
    const provider = providerTransportError(error, "generator");
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", provider.code, model);
    } catch (_) {}
    return fail(provider.message, provider.upstreamStatus === null ? 502 : 502, provider.code);
  }

  if (!resp.ok) {
    const provider = await readProviderError(resp, "generator");
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", provider.code, model);
    } catch (_) {}
    if (provider.upstreamStatus !== null && provider.upstreamStatus >= 500) {
      console.warn(JSON.stringify({
        event: "mimi_provider_error",
        code: provider.code,
        upstreamStatus: provider.upstreamStatus,
        stage: provider.stage,
      }));
    }
    return fail(
      provider.message,
      provider.upstreamStatus === 429
        ? 429
        : provider.upstreamStatus !== null && provider.upstreamStatus >= 500
          ? 502
          : 400,
      provider.code,
    );
  }

  if (!resp.body) {
    await refundAiRequest(authenticatedUserId, usage.usage_date);
    try {
      await recordAiEvent(authenticatedUserId, requestId, planId, action, "failed", "GEMINI_NETWORK", model);
    } catch (_) {}
    return fail("Gemini returned an empty response.", 502, "GEMINI_NETWORK");
  }

  // Monitor the upstream stream rather than blindly proxying it. This makes
  // stream success, transport failure, and client cancellation auditable and
  // refunds only requests that did not produce a complete response.
  const reader = resp.body.getReader();
  let settled = false;
  const settle = async (
    status: "succeeded" | "failed",
    errorCode: string | null,
  ) => {
    if (settled) return;
    settled = true;
    if (status === "failed") {
      await refundAiRequest(authenticatedUserId, usage.usage_date);
    }
    try {
      await recordAiEvent(
        authenticatedUserId,
        requestId,
        planId,
        action,
        status,
        errorCode,
        model,
      );
    } catch (_) {}
  };
  const encoder = new TextEncoder();
  const stream = new ReadableStream<Uint8Array>({
    async pull(controller) {
      try {
        const next = await reader.read();
        if (next.done) {
          await settle("succeeded", null);
          controller.close();
        } else {
          controller.enqueue(next.value);
        }
      } catch (error) {
        const provider = providerTransportError(error, "generator");
        await settle("failed", provider.code);
        try {
          controller.enqueue(encoder.encode(
            `event: error\ndata: ${JSON.stringify({ message: provider.message, code: provider.code })}\n\n`,
          ));
          controller.close();
        } catch (_) {}
      }
    },
    async cancel(reason) {
      try {
        await reader.cancel(reason);
      } finally {
        await settle("failed", "AI_CANCELLED");
      }
    },
  });
  return new Response(stream, {
    status: 200,
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "X-Teacher-Attachments-Version": "1",
      "X-AI-Remaining": String(Math.max(0, usage.daily_limit - usage.request_count)),
      ...corsHeaders(),
    },
  });
});
