const { test, expect } = require("@playwright/test");

test.beforeEach(async ({ page }) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Explore an offline demo" }).click();
  await expect(page.locator("#page-title")).toHaveText("Dashboard");
});

test("Add Questions is a paste screen, not a redirect into the bank", async ({
  page,
}) => {
  await page.getByRole("link", { name: "Add Questions", exact: false }).click();
  await expect(page).toHaveURL(/#add$/);
  await expect(page.locator("#page-title")).toHaveText("Add Questions");
  await expect(page.locator("#import-text")).toBeVisible();
  await expect(page.locator("#import-format")).toBeVisible();
  await expect(page.locator('[data-action="ai-format"]')).toContainText(
    "Reformat with AI",
  );
  // One paste box serves every format, English included.
  await expect(page.locator("#import-format option")).toHaveCount(3);
  // The manual form is still one click away.
  await page.locator('[data-action="new-question"]').click();
  await expect(page.locator("#editor")).toBeVisible();
});

test("All Questions lists bank and teacher rows and narrows by chapter", async ({
  page,
}) => {
  await page.getByRole("link", { name: "All Questions", exact: false }).click();
  await expect(page.locator("#page-title")).toHaveText("All Questions");
  await expect(page.locator("#subject-filter")).toBeVisible();
  await expect(page.locator("#chapter-filter")).toBeVisible();
  expect(await page.locator("tbody tr").count()).toBeGreaterThan(0);
  // Both sources are shown and told apart.
  await expect(page.locator(".badge.bank").first()).toBeVisible();
  await expect(page.locator(".badge.teacher").first()).toBeVisible();
  await page.locator("#chapter-filter").fill("no-such-chapter");
  await page.locator('[data-action="filter"]').click();
  await expect(page.getByText("Nothing matches.", { exact: false })).toBeVisible();
});

test("the editor renders the attached picture and flags a non-https URL", async ({
  page,
}) => {
  await page
    .getByRole("link", { name: "Question Bank", exact: false })
    .first()
    .click();
  await page.locator('[data-action="edit"]').first().click();
  const url = "https://example.com/figure.png";
  await page.locator('[data-field="image"]').fill(url);
  await expect(page.locator("#figure-preview")).toBeVisible();
  await expect(page.locator("#figure-preview")).toHaveAttribute("src", url);
  // The database rejects any other scheme, so say so instead of showing a
  // broken image the reader would read as a missing file.
  await page.locator('[data-field="image"]').fill("http://example.com/f.png");
  await expect(page.locator("#figure-preview")).toBeHidden();
  await expect(page.locator("#figure-note")).toContainText("https://");
});

test("a saved image appears beside the question on the dashboard", async ({
  page,
}) => {
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await page
    .getByRole("link", { name: "Question Bank", exact: false })
    .first()
    .click();
  await page.locator('[data-action="edit"]').first().click();
  const url = "https://example.com/figure.png";
  await page.locator('[data-field="image"]').fill(url);
  await page.getByRole("button", { name: "Save draft", exact: true }).click();
  await expect(page.getByText("Draft saved.", { exact: false })).toBeVisible();
  await page
    .getByRole("link", { name: "Dashboard", exact: false })
    .first()
    .click();
  await expect(page.locator(`img.thumb[src="${url}"]`)).toHaveCount(1);
  expect(errors).toEqual([]);
});

test("English papers are reached from the bank's content filter", async ({
  page,
}) => {
  await page
    .getByRole("link", { name: "Question Bank", exact: false })
    .first()
    .click();
  await page.locator("#source-filter").selectOption("english");
  await page.locator('[data-action="filter"]').click();
  await expect(page.locator("#paper-filter")).toBeVisible();
  await expect(
    page.getByRole("button", {
      name: "Upload English Paper (PDF / Image)",
      exact: true,
    }),
  ).toBeVisible();
});
