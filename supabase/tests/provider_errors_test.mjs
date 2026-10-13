import { test } from "node:test";
import assert from "node:assert/strict";
import {
  classifyProviderError,
  readProviderError,
  providerTransportError,
} from "../functions/mimi/provider_errors.ts";

const privateText = "PRIVATE_KEY_AND_PROMPT_DO_NOT_EXPOSE";
const cases = [
  [400, "API_KEY_INVALID", "", "GEMINI_KEY_INVALID"],
  [400, "API_KEY_EXPIRED", "", "GEMINI_KEY_INVALID"],
  [403, "", "Your API key was reported as leaked.", "GEMINI_KEY_BLOCKED"],
  [403, "API_KEY_HTTP_REFERRER_BLOCKED", "", "GEMINI_KEY_RESTRICTED"],
  [403, "API_KEY_SERVICE_BLOCKED", "", "GEMINI_KEY_RESTRICTED"],
  [403, "SERVICE_DISABLED", "", "GEMINI_API_DISABLED"],
  [400, "BILLING_DISABLED", "", "GEMINI_BILLING_REQUIRED"],
  [
    400,
    "",
    "User location is not supported for the API use.",
    "GEMINI_REGION_UNSUPPORTED",
  ],
  [401, "", "", "GEMINI_ACCESS_DENIED"],
  [403, "", "", "GEMINI_ACCESS_DENIED"],
  [404, "", "model not found", "GEMINI_MODEL_UNAVAILABLE"],
  [400, "", "Invalid responseSchema", "GEMINI_SCHEMA_REJECTED"],
  [400, "", "Invalid argument", "GEMINI_REQUEST_REJECTED"],
  [429, "", "quota", "GEMINI_QUOTA"],
  [503, "", "overloaded", "GEMINI_UPSTREAM_ERROR"],
  [418, "", "unexpected", "GEMINI_HTTP_ERROR"],
];
for (const [status, reason, message, code] of cases) {
  test(`Gemini diagnostics classify ${status}/${reason || message || "no detail"} without leaking provider text`, () => {
    const result = classifyProviderError(
      status,
      {
        error: {
          message: message + " " + privateText,
          details: [{ reason, metadata: { key: privateText } }],
        },
      },
      "generator",
    );
    assert.equal(result.code, code);
    assert.equal(result.upstreamStatus, status);
    assert.equal(result.stage, "generator");
    assert.ok(result.message.includes(`HTTP ${status}`));
    assert.ok(!result.message.includes(privateText));
    assert.ok(!JSON.stringify(result).includes(privateText));
  });
}

test("model failures identify only the applicable server setting", () => {
  const result = classifyProviderError(404, {}, "validator");
  assert.match(result.message, /GEMINI_VALIDATOR_MODEL/);
  assert.doesNotMatch(result.message, /GEMINI_GENERATOR_MODEL/);
});

test("invalid, null and HTML error responses fall back to HTTP status", async () => {
  for (const text of [
    "null",
    "{}",
    '"string"',
    '{"error":null}',
    "<html>" + privateText,
  ]) {
    const result = await readProviderError(
      new Response(text, { status: 403 }),
      "generator",
    );
    assert.equal(result.code, "GEMINI_ACCESS_DENIED");
    assert.ok(!result.message.includes(privateText));
  }
});

test("provider body limit cancels an oversized stream without echoing it", async () => {
  let cancelled = false;
  const stream = new ReadableStream({
    start(controller) {
      controller.enqueue(new Uint8Array(16385));
    },
    cancel() {
      cancelled = true;
    },
  });
  const result = await readProviderError(
    new Response(stream, { status: 400 }),
    "generator",
  );
  assert.equal(result.code, "GEMINI_REQUEST_REJECTED");
  assert.equal(cancelled, true);
});

test("unreadable provider bodies still give a safe status-based diagnosis", async () => {
  const stream = new ReadableStream({
    start(controller) {
      controller.error(new Error(privateText));
    },
  });
  const result = await readProviderError(
    new Response(stream, { status: 503 }),
    "validator",
  );
  assert.equal(result.code, "GEMINI_UPSTREAM_ERROR");
  assert.ok(!result.message.includes(privateText));
});

test("transport failures distinguish timeout from network without logging URLs or keys", () => {
  for (const name of ["TimeoutError", "AbortError", "TypeError"]) {
    const error = new Error(privateText);
    error.name = name;
    const result = providerTransportError(error, "validator");
    assert.equal(
      result.code,
      name === "TypeError" ? "GEMINI_NETWORK" : "GEMINI_TIMEOUT",
    );
    assert.equal(result.upstreamStatus, null);
    assert.ok(!result.message.includes(privateText));
  }
});
