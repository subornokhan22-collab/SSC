const { test, expect } = require("@playwright/test");
const fixture = require("./fixtures/english-first.json");
function pdf() {
  const text =
    "BT /F1 12 Tf 50 790 Td (Dhaka Board 2024) Tj 0 -25 Td (10. Complete the story about a school.) Tj ET";
  const objects = [
    "<< /Type /Catalog /Pages 2 0 R >>",
    "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
    "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
    `<< /Length ${text.length} >>\nstream\n${text}\nendstream`,
  ];
  let out = "%PDF-1.4\n",
    offsets = [];
  for (let i = 0; i < objects.length; i++) {
    offsets.push(Buffer.byteLength(out));
    out += `${i + 1} 0 obj\n${objects[i]}\nendobj\n`;
  }
  const offset = Buffer.byteLength(out);
  out +=
    "xref\n0 6\n0000000000 65535 f \n" +
    offsets.map((x) => String(x).padStart(10, "0") + " 00000 n \n").join("") +
    `trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n${offset}\n%%EOF`;
  return Buffer.from(out);
}
async function image(page, name = "page.png") {
  const data = await page.evaluate(() => {
    const c = document.createElement("canvas");
    c.width = 300;
    c.height = 420;
    const x = c.getContext("2d");
    x.fillStyle = "white";
    x.fillRect(0, 0, 300, 420);
    x.fillStyle = "black";
    x.fillText("Dhaka Board 2024", 20, 30);
    return c.toDataURL("image/png").split(",")[1];
  });
  return { name, mimeType: "image/png", buffer: Buffer.from(data, "base64") };
}
async function open(page) {
  await page
    .getByRole("link", { name: "English Papers", exact: false })
    .click();
  await page
    .getByRole("button", {
      name: "Upload English Paper (PDF / Image)",
      exact: true,
    })
    .click();
  await expect(page.locator("#english-upload")).toBeVisible();
}
test("direct PDF upload previews pages, detects metadata and opens a draft", async ({
  page,
}) => {
  await page.goto("/");
  await page.click("#demo");
  await open(page);
  await page
    .locator("#english-source-files")
    .setInputFiles({
      name: "board.pdf",
      mimeType: "application/pdf",
      buffer: pdf(),
    });
  await expect(page.locator("#upload-status")).toContainText(
    "PDF text extracted locally",
  );
  await expect(page.locator("#source-page")).toHaveText("Page 1 of 1");
  await expect(page.locator("#upload-board")).toHaveValue("Dhaka");
  await expect(page.locator("#upload-year")).toHaveValue("2024");
  await expect(page.locator("#upload-ai")).toBeDisabled();
  await page.click("#upload-manual");
  await expect(page.locator("#editor")).toBeVisible();
  await expect(page.locator('[data-field="data.q10Starter"]')).toHaveValue(
    "Complete the story about a school.",
  );
  await expect(page.locator('[data-field="answer.q1"]')).toHaveValue("");
});
test("photo preview and ordering work in demo, with no fake OCR or network upload", async ({
  page,
}) => {
  let external = 0;
  page.on("request", (r) => {
    if (r.url().includes("supabase.co")) external++;
  });
  await page.goto("/");
  await page.click("#demo");
  await open(page);
  await page
    .locator("#english-source-files")
    .setInputFiles([
      await image(page, "first.png"),
      await image(page, "second.png"),
    ]);
  await expect(page.locator("#upload-status")).toContainText(
    "needs image reading",
  );
  await expect(page.locator("#source-filename")).toHaveText("first.png");
  await page.click("#source-next");
  await expect(page.locator("#source-filename")).toHaveText("second.png");
  await page.click("#source-up");
  await expect(page.locator("#source-page")).toHaveText("Page 1 of 2");
  await expect(page.locator("#source-filename")).toHaveText("second.png");
  await expect(page.locator("#upload-ai")).toBeDisabled();
  expect(external).toBe(0);
  await page
    .locator("#english-source-files")
    .setInputFiles({
      name: "bad.svg",
      mimeType: "image/svg+xml",
      buffer: Buffer.from("<svg/>"),
    });
  await expect(page.locator("#upload-status")).toContainText(
    "Supported files: PDF, JPG, PNG and WebP",
  );
});
test("authenticated image extraction sends bounded pages and only opens a reviewable draft", async ({
  page,
}) => {
  const uid = "11111111-1111-4111-8111-111111111111";
  const jwt = [
    { alg: "HS256", typ: "JWT" },
    {
      sub: uid,
      exp: Math.floor(Date.now() / 1000) + 3600,
      role: "authenticated",
    },
    "test",
  ]
    .map((v) =>
      typeof v === "string"
        ? v
        : Buffer.from(JSON.stringify(v)).toString("base64url"),
    )
    .join(".");
  let upload = null,
    writes = 0;
  await page.route("https://*.supabase.co/**", async (route) => {
    const r = route.request(),
      p = new URL(r.url()).pathname;
    const send = (body, headers = {}) =>
      route.fulfill({
        status: 200,
        contentType: "application/json",
        headers: {
          "access-control-allow-origin": "*",
          "access-control-expose-headers": "content-range",
          ...headers,
        },
        body: JSON.stringify(body),
      });
    if (r.method() === "OPTIONS")
      return send(
        {},
        {
          "access-control-allow-headers": "*",
          "access-control-allow-methods": "GET,POST,HEAD,OPTIONS",
        },
      );
    if (p === "/auth/v1/token")
      return send({
        access_token: jwt,
        refresh_token: "test",
        expires_in: 3600,
        token_type: "bearer",
        user: { id: uid, email: "admin@example.test", aud: "authenticated" },
      });
    if (p.endsWith("/rpc/is_question_admin")) return send(true);
    if (p === "/functions/v1/admin-content") {
      upload = JSON.parse(r.postData());
      return send({
        result: {
          ...fixture.data,
          answers: { q1: "Do not trust model-provided answers" },
        },
      });
    }
    if (r.method() !== "GET" && r.method() !== "HEAD") writes++;
    return send([], { "content-range": "0-0/0" });
  });
  await page.goto("/");
  await page.fill("#email", "admin@example.test");
  await page.fill("#password", "test-password");
  await page.click("#login-form button");
  await expect(page.locator(".stats")).toBeVisible();
  await open(page);
  await page.locator("#english-source-files").setInputFiles(await image(page));
  await expect(page.locator("#upload-ai")).toBeEnabled();
  await page.fill("#upload-board", "Dhaka");
  await page.fill("#upload-year", "2024");
  page.on("dialog", (d) => d.accept());
  await page.click("#upload-ai");
  await expect(page.locator("#editor")).toBeVisible();
  expect(upload.format).toBe("first");
  expect(upload.attachments).toHaveLength(1);
  expect(upload.attachments[0].mimeType).toBe("image/jpeg");
  await expect(page.locator('[data-field="data.q1.0.stem"]')).toHaveValue(
    "Source question 0",
  );
  await expect(page.locator('[data-field="answer.q1"]')).toHaveValue("");
  expect(writes).toBe(0);
});
