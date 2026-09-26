import { ToolError } from "./teacher_tools.ts";

export type ProviderStage = "generator" | "validator";

// Only our fixed messages/codes leave the function. Provider error bodies can
// echo credentials, project IDs or user text; never return or log them verbatim.
export class ProviderError extends ToolError {
  readonly code: string;
  readonly upstreamStatus: number | null;
  readonly stage: ProviderStage;

  constructor(
    code: string,
    message: string,
    status: number | null,
    stage: ProviderStage,
  ) {
    super(
      `${message} [${code}; ${status === null ? "network" : "HTTP " + status}; ${stage}]`,
    );
    this.code = code;
    this.upstreamStatus = status;
    this.stage = stage;
  }
}

export function classifyProviderError(
  status: number,
  body: unknown,
  stage: ProviderStage,
): ProviderError {
  const error = (
    body as { error?: { message?: unknown; details?: unknown } } | null
  )?.error;
  const message = typeof error?.message === "string" ? error.message : "";
  const reasons = Array.isArray(error?.details)
    ? error.details
        .map((d) => (typeof d?.reason === "string" ? d.reason : ""))
        .join(" ")
    : "";
  const hints = reasons + " " + message;
  let code: string;
  let explanation: string;
  if (status === 429) {
    code = "GEMINI_QUOTA";
    explanation =
      "Gemini quota or rate limit reached. Check this key's limits in Google AI Studio before retrying.";
  } else if (status >= 500) {
    code = "GEMINI_UPSTREAM_ERROR";
    explanation = "Gemini returned a server error. Please retry later.";
  } else if (
    /API_KEY_LEAKED|API_KEY_BLOCKED|key.{0,50}(?:reported as leaked|has been blocked)/i.test(
      hints,
    )
  ) {
    code = "GEMINI_KEY_BLOCKED";
    explanation =
      "Gemini reports that the server API key is leaked or blocked. Replace GEMINI_API_KEY with a new Google AI Studio key.";
  } else if (
    /API_KEY_INVALID|API_KEY_EXPIRED|API key not valid|API key expired/i.test(
      hints,
    )
  ) {
    code = "GEMINI_KEY_INVALID";
    explanation =
      "Gemini rejected the server API key as invalid or expired. Update GEMINI_API_KEY in Supabase Secrets.";
  } else if (
    /API_KEY_(?:SERVICE|HTTP_REFERRER|IP_ADDRESS|ANDROID_APP|IOS_APP)_BLOCKED/i.test(
      hints,
    )
  ) {
    code = "GEMINI_KEY_RESTRICTED";
    explanation =
      "This API key's restrictions block the server request. Review its application and Generative Language API restrictions in Google Cloud.";
  } else if (
    /SERVICE_DISABLED|accessNotConfigured|Generative Language API.{0,180}(?:disabled|not been used)/i.test(
      hints,
    )
  ) {
    code = "GEMINI_API_DISABLED";
    explanation =
      "The Generative Language API is disabled or not enabled for this key's Google project. Check that project's API settings.";
  } else if (
    /BILLING_DISABLED|BILLING_NOT_ACTIVE|billing.{0,40}(?:disabled|not enabled)/i.test(
      hints,
    )
  ) {
    code = "GEMINI_BILLING_REQUIRED";
    explanation =
      "Gemini requires billing for this request/project. Review Google AI Studio availability and plan requirements before making changes.";
  } else if (
    /location is not supported|not (?:available|supported) in your (?:country|region)/i.test(
      hints,
    )
  ) {
    code = "GEMINI_REGION_UNSUPPORTED";
    explanation =
      "Gemini reports unsupported location or regional availability. Check availability for the Supabase server region and Google project.";
  } else if (status === 401 || status === 403) {
    code = "GEMINI_ACCESS_DENIED";
    explanation =
      "Gemini denied access. Check the server key's Google project permissions and API restrictions.";
  } else if (status === 404) {
    code = "GEMINI_MODEL_UNAVAILABLE";
    const setting =
      stage === "validator"
        ? "GEMINI_VALIDATOR_MODEL"
        : "GEMINI_GENERATOR_MODEL";
    explanation =
      "The configured Gemini model was not found or is unavailable to this key. Check " +
      setting +
      " against models available in Google AI Studio.";
  } else if (
    status === 400 &&
    /response_?schema|response schema/i.test(hints)
  ) {
    code = "GEMINI_SCHEMA_REJECTED";
    explanation =
      "Gemini rejected the structured response schema. This needs a server-code or model-compatibility fix; do not change your API key.";
  } else if (status === 400) {
    code = "GEMINI_REQUEST_REJECTED";
    explanation =
      "Gemini rejected the AI Tools request or configuration. Share this diagnostic code with the app maintainer; do not replace your key just for this error.";
  } else {
    code = "GEMINI_HTTP_ERROR";
    explanation =
      "Gemini could not process this request. Share this diagnostic code with the app maintainer.";
  }
  return new ProviderError(code, explanation, status, stage);
}

export async function readProviderError(
  response: Response,
  stage: ProviderStage,
): Promise<ProviderError> {
  // Error bodies are untrusted too. Bound memory, and fall back to status-only
  // classification for malformed, oversized, HTML or unreadable responses.
  const reader = response.body?.getReader();
  let body: unknown;
  if (reader) {
    try {
      const decoder = new TextDecoder();
      let text = "";
      let bytes = 0;
      while (true) {
        const chunk = await reader.read();
        if (chunk.done) break;
        bytes += chunk.value.byteLength;
        if (bytes > 16384) {
          await reader.cancel();
          return classifyProviderError(response.status, undefined, stage);
        }
        text += decoder.decode(chunk.value, { stream: true });
      }
      body = JSON.parse(text + decoder.decode());
    } catch {
      // Do not surface the raw body or exception (which may contain a URL/key).
    } finally {
      reader.releaseLock();
    }
  }
  return classifyProviderError(response.status, body, stage);
}

export function providerTransportError(
  error: unknown,
  stage: ProviderStage,
): ProviderError {
  const name = (error as { name?: unknown } | null)?.name;
  if (name === "TimeoutError" || name === "AbortError") {
    return new ProviderError(
      "GEMINI_TIMEOUT",
      "The server timed out waiting for Gemini. Retry with fewer questions.",
      null,
      stage,
    );
  }
  return new ProviderError(
    "GEMINI_NETWORK",
    "The server could not reach Gemini. Please retry later.",
    null,
    stage,
  );
}
