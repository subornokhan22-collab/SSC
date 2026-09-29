const { test, expect } = require("@playwright/test");
test("supported SDK uses server counts, paginates and keeps session out of localStorage", async ({
  page,
}) => {
  const calls = [];
  const uid = "11111111-1111-4111-8111-111111111111";
  const token = [
    { alg: "HS256", typ: "JWT" },
    {
      sub: uid,
      exp: Math.floor(Date.now() / 1000) + 3600,
      role: "authenticated",
    },
    "test-signature",
  ]
    .map((x) =>
      typeof x === "string"
        ? x
        : Buffer.from(JSON.stringify(x)).toString("base64url"),
    )
    .join(".");
  const row = {
    id: "live_test",
    type: "mcq",
    subject_id: "physics",
    chapter: "Chapter 1",
    payload: {
      questionText: "A server record",
      options: ["One", "Two", "Three", "Four"],
      correctIndex: 1,
      explanation: "Source",
    },
    review_status: "published",
    is_active: true,
    owner_id: null,
    updated_at: "2026-09-25T00:00:00Z",
    metadata: {},
  };
  await page.route("https://*.supabase.co/**", async (route) => {
    const req = route.request(),
      url = new URL(req.url());
    calls.push({
      method: req.method(),
      url: url.toString(),
      body: req.postData(),
    });
    const respond = (body, status = 200, headers = {}) =>
      route.fulfill({
        status,
        contentType: "application/json",
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Expose-Headers": "content-range",
          ...headers,
        },
        body: JSON.stringify(body),
      });
    if (req.method() === "OPTIONS")
      return respond({}, 200, {
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Methods": "GET,POST,PATCH,HEAD,OPTIONS",
      });
    if (url.pathname === "/auth/v1/token")
      return respond({
        access_token: token,
        refresh_token: "test-refresh",
        token_type: "bearer",
        expires_in: 3600,
        user: { id: uid, aud: "authenticated", email: "admin@example.test" },
      });
    if (url.pathname === "/rest/v1/rpc/is_question_admin") return respond(true);
    if (url.pathname === "/rest/v1/content_subjects") return respond([]);
    if (req.method() === "HEAD")
      return respond(null, 200, {
        "content-range":
          "0-0/" +
          (url.searchParams.get("review_status") === "eq.published"
            ? 80
            : url.searchParams.get("review_status") === "eq.review"
              ? 7
              : 3),
      });
    if (url.pathname === "/rest/v1/questions" && req.method() === "PATCH") {
      expect(url.searchParams.get("updated_at")).toBe(
        "eq.2026-09-25T00:00:00Z",
      );
      const body = JSON.parse(req.postData());
      expect(body.review_status).toBe("draft");
      expect(body.created_by).toBeUndefined();
      expect(body.payload.questionText).toBe("A changed server record");
      return respond([{ ...row, ...body }]);
    }
    if (url.pathname === "/rest/v1/questions") {
      expect(url.searchParams.get("owner_id")).toBe("is.null");
      return respond([row], 200, { "content-range": "0-0/80" });
    }
    return respond({ message: "Unmocked endpoint" }, 500);
  });
  await page.goto("/");
  await page.locator("#email").fill("admin@example.test");
  await page.locator("#password").fill("test-only-password");
  await page
    .getByRole("button", { name: "Sign in to content studio", exact: false })
    .click();
  await expect(page.locator(".stats .stat").first()).toContainText("80");
  expect(await page.evaluate(() => Object.keys(localStorage))).toEqual([]);
  await page
    .getByRole("link", { name: "Question Bank", exact: false })
    .first()
    .click();
  await expect(page.locator(".pager")).toContainText("80 matching records");
  await page.locator('[data-action="next"]').click();
  await expect(page.locator(".pager")).toContainText("Page 2 of 4");
  expect(
    calls.some((c) => new URL(c.url).searchParams.get("offset") === "25"),
  ).toBe(true);
  await page.locator("#search").fill("physics_ch%");
  await page.locator('[data-action="filter"]').click();
  await expect
    .poll(() =>
      calls.some(
        (c) =>
          new URL(c.url).searchParams.get("search_text") ===
          String.raw`ilike.%physics\_ch\%%`,
      ),
    )
    .toBe(true);
  await page.locator('[data-action="edit"]').click();
  await page
    .locator('[data-field="payload.questionText"]')
    .fill("A changed server record");
  await page.getByRole("button", { name: "Save draft", exact: true }).click();
  await expect(page.locator("#notice")).toContainText("Draft saved");
  expect(calls.some((c) => c.method === "PATCH")).toBe(true);
});
