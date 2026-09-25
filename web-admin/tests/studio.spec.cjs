const { test, expect } = require("@playwright/test");
const fs = require("node:fs");
test.beforeEach(async ({ page }) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Explore an offline demo" }).click();
  await expect(page.locator("#page-title")).toHaveText("Dashboard");
});
test("dashboard, filters, draft edit, review, archive and restore", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await page
    .getByRole("link", { name: "Question Bank", exact: false })
    .first()
    .click();
  await page.locator('[data-action="edit"]').first().click();
  await page
    .locator('[data-field="payload.questionText"]')
    .fill("A unique reviewed source question?");
  await page.getByRole("button", { name: "Save draft", exact: true }).click();
  await expect(page.getByText("Draft saved.", { exact: false })).toBeVisible();
  await page.locator('[data-action="review"]').first().click();
  page.on("dialog", (d) => d.accept());
  await page.locator('[data-action="archive"]').first().click();
  await page.getByRole("link", { name: "Archived", exact: false }).click();
  await expect(page.locator('[data-action="restore"]')).toHaveCount(1);
  await page.locator('[data-action="restore"]').click();
  await expect(
    page.getByText("No matching content.", { exact: false }),
  ).toBeVisible();
  expect(errors).toEqual([]);
});
test("full English JSON enters the separate editor and publishes after review", async ({
  page,
}) => {
  await page.getByRole("link", { name: "Import Center", exact: false }).click();
  const row = JSON.parse(
    fs.readFileSync(require.resolve("./fixtures/english-first.json")),
  );
  await page.locator("#import-format").selectOption("first");
  await page.locator("#import-text").fill(JSON.stringify(row));
  await page.locator('[data-action="parse-import"]').click();
  await expect(page.locator("#editor-title")).toHaveText(
    "New English board paper",
  );
  await expect(page.locator('[data-field="data.q1.0.stem"]')).toHaveValue(
    "Source question 0",
  );
  await page.getByRole("button", { name: "Preview & validate" }).click();
  await expect(page.locator("#preview-content")).toContainText(
    "Structure valid",
  );
  await expect(page.locator("#preview-content")).toContainText(
    "Answer not supplied",
  );
  await expect(page.locator("#preview-content [data-question]")).toHaveCount(
    11,
  );
  await expect(page.locator("#preview-content")).toContainText(
    "Write a summary",
  );
  await page.locator("#preview-mode").click();
  await expect(page.locator("#preview-heading")).toHaveText(
    "Student paper preview",
  );
  await expect(page.locator("#preview-content")).not.toContainText(
    "Source-provided answers",
  );
  await page.locator("#close-preview").click();
  await page.getByRole("button", { name: "Save draft", exact: true }).click();
  await page
    .getByRole("link", { name: "English Papers", exact: false })
    .click();
  await expect(page.locator("#main tbody")).toContainText("Dhaka");
  await page.locator('[data-action="review"]').click();
  page.on("dialog", (d) => d.accept());
  await page.locator('[data-action="publish"]').click();
  await expect(page.locator("#main tbody .badge")).toHaveText("published");
});
test("missing CSV answer remains a blocked draft and XSS is inert", async ({
  page,
}) => {
  await page.getByRole("link", { name: "Import Center", exact: false }).click();
  await page
    .locator("#import-text")
    .fill(
      "subject,chapter,type,question,option_a,option_b,option_c,option_d,answer,explanation\nphysics,Chapter 1,mcq,<img src=x onerror=alert(1)>,One,Two,Three,Four,,Source",
    );
  await page.locator('[data-action="parse-import"]').click();
  await expect(page.locator("#import-results")).toContainText(
    "Answer not supplied",
  );
  expect(await page.locator("#import-results img").count()).toBe(0);
  await expect(page.locator("#import-results")).toContainText(
    "<img src=x onerror=alert(1)>",
  );
});
test("responsive navigation and health fix links", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.getByRole("link", { name: "Validation", exact: false }).click();
  await page.locator('[data-action="health"]').click();
  await expect(page.locator("#health-results")).toContainText("8 questions");
  await page.getByRole("link", { name: "Dashboard", exact: false }).click();
  await page.screenshot({
    path: "test-results/mobile-dashboard.png",
    fullPage: true,
  });
});
