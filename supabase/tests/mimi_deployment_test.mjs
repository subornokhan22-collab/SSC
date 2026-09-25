import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import vm from "node:vm";
const bundled = readFileSync(
  new URL("../../deployments/content-studio/mimi.ts", import.meta.url),
  "utf8",
);
function gateway({
  signedIn = true,
  key = "fixture-key",
  checkerAgrees = true,
  simulateEditorIndentation = false,
} = {}) {
  let handler;
  const calls = [];
  const q = {
    chapter: "Chapter 6",
    questionText: "Which option is correct?",
    options: ["One", "Two", "Three", "Four"],
    correctIndex: 1,
    explanation: "Generator source",
    difficulty: "hard",
  };
  const source = bundled.replace(
    /^import \{ createClient \} from "https:\/\/esm.sh\/@supabase\/supabase-js@2\.45\.4";\s*$/m,
    "",
  );
  assert.ok(
    !/^import\s/m.test(source),
    "All local dependencies must be bundled",
  );
  // Some phone editors add leading whitespace to every pasted source line.
  // In a multiline template literal, that whitespace becomes response bytes.
  const pastedSource = simulateEditorIndentation
    ? source.replace(/^/gm, "    ")
    : source;
  vm.runInNewContext(pastedSource, {
    Deno: {
      env: {
        get: (name) =>
          name === "GEMINI_API_KEY"
            ? key
            : name === "SUPABASE_URL"
              ? "https://example.invalid"
              : name === "SUPABASE_SERVICE_ROLE_KEY"
                ? "fixture"
                : undefined,
      },
      serve: (fn) => (handler = fn),
    },
    createClient: () => ({
      auth: {
        getUser: async () => ({
          data: { user: signedIn ? { id: "fixture-user" } : null },
          error: null,
        }),
      },
    }),
    fetch: async (url, options) => {
      const body = JSON.parse(options.body);
      calls.push({ url, body });
      const data =
        calls.length === 1
          ? { questions: [q] }
          : {
              checks: [
                {
                  index: 0,
                  correctIndex: checkerAgrees ? 1 : 2,
                  valid: checkerAgrees,
                  reason: "Independent source",
                },
              ],
            };
      return new Response(
        JSON.stringify({
          candidates: [
            {
              finishReason: "STOP",
              content: { parts: [{ text: JSON.stringify(data) }] },
            },
          ],
        }),
      );
    },
    Response,
    Request,
    ReadableStream,
    TextEncoder,
    TextDecoder,
    AbortController,
    AbortSignal,
    Uint8Array,
    console,
  });
  return { handler, calls };
}
function req(
  auth = true,
  body = {
    action: "generate",
    subjectId: "chemistry",
    chapters: ["Chapter 6"],
    difficulty: "hard",
    count: 1,
    text: "",
    instruction: "",
  },
) {
  return new Request("https://example.invalid/functions/v1/mimi", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(auth ? { Authorization: "Bearer fixture-user-jwt" } : {}),
    },
    body: JSON.stringify(body),
  });
}
test("dashboard mimi bundle requires a verified signed-in user", async () => {
  for (const options of [{}, { signedIn: false }]) {
    const g = gateway(options),
      r = await g.handler(req(options.signedIn === false));
    assert.equal(r.status, 401);
    assert.equal(g.calls.length, 0);
  }
});
test("dashboard mimi bundle reports missing shared Gemini secret", async () => {
  const g = gateway({ key: "" }),
    r = await g.handler(req());
  assert.equal(r.status, 503);
  assert.equal((await r.json()).code, "NOT_CONFIGURED");
});
test("dashboard mimi bundle supports APK generate SSE and independent checking", async () => {
  const g = gateway(),
    r = await g.handler(req());
  assert.equal(r.status, 200);
  assert.match(r.headers.get("Content-Type"), /text\/event-stream/);
  const output = await r.text();
  assert.match(output, /event: phase/);
  assert.match(output, /event: result/);
  assert.match(output, /"checked":true/);
  assert.equal(g.calls.length, 2);
  const checkerInput = JSON.parse(g.calls[1].body.contents[0].parts[0].text);
  assert.equal(checkerInput[0].correctIndex, undefined);
  assert.equal(checkerInput[0].explanation, undefined);
});
test("dashboard mimi bundle refuses rejected answers instead of returning a checked result", async () => {
  const g = gateway({ checkerAgrees: false }),
    r = await g.handler(req()),
    text = await r.text();
  assert.match(text, /event: error/);
  assert.doesNotMatch(text, /event: result/);
});

// Match TeacherAiClient's line-prefix handling, not just substring matches.
function apkEvents(text) {
  let event = "";
  const events = [];
  for (const line of text.split(/\r?\n/)) {
    if (line.startsWith("event:")) event = line.slice(6).trim();
    if (line.startsWith("data:")) {
      events.push({ event, data: JSON.parse(line.slice(5).trim()) });
    }
  }
  return events;
}
for (const checkerAgrees of [true, false]) {
  test(`dashboard SSE survives phone editor indentation (${checkerAgrees ? "result" : "error"})`, async () => {
    const g = gateway({ simulateEditorIndentation: true, checkerAgrees });
    const r = await g.handler(req());
    const text = await r.text();
    const events = apkEvents(text);
    assert.ok(
      events.some((e) => e.event === "phase"),
      "APK must receive progress",
    );
    if (checkerAgrees) {
      const results = events.filter((e) => e.event === "result");
      assert.equal(results.length, 1, "APK must receive a complete result");
      assert.equal(results[0].data.checked, true);
      assert.equal(results[0].data.kind, "questions");
    } else {
      assert.ok(
        events.some(
          (e) =>
            e.event === "error" && e.data.message.includes("independent check"),
        ),
      );
      assert.ok(!events.some((e) => e.event === "result"));
    }
    assert.doesNotMatch(text, /^[ \t]+(?:event|data):/m);
    assert.ok(
      text.endsWith("\n\n"),
      "SSE must end with an empty separator line",
    );
  });
}
