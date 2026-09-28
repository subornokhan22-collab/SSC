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
  // One paste box serves every format, with a subject-wise chapter ribbon.
  await expect(page.locator("#import-format option")).toHaveCount(3);
  await expect(page.locator("#import-subject")).toBeVisible();
  await expect(page.locator("#import-chapter")).toBeVisible();
  await page.locator("#import-subject").selectOption("biology");
  await expect(page.locator("#import-chapter option")).toHaveCount(15);
  await page.locator("#import-chapter-chips [data-chapter-chip]").first().click();
  await expect(page.locator("#import-chapter")).not.toHaveValue("");
  // The manual form is still one click away and carries the same ribbon.
  await page.locator('[data-action="new-question"]').click();
  await expect(page.locator("#editor")).toBeVisible();
  await expect(page.locator("#editor .subject-chapter-ribbon")).toBeVisible();
  await page.locator('#editor [data-field="subject_id"]').selectOption("chemistry");
  await expect(
    page.locator("#editor .subject-chapter-ribbon [data-chapter-chip]"),
  ).toHaveCount(12);
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

test("Offers & Promotions manages plans, notifications and popup photos", async ({
  page,
}) => {
  await page
    .getByRole("link", { name: "Offers & Promotions", exact: false })
    .click();
  await expect(page.locator("#page-title")).toHaveText("Offers & Promotions");
  await expect(page.locator('[data-promotion-form="offers"]')).toBeVisible();
  await expect(page.locator('[data-promotion-form="notifications"]')).toBeVisible();
  await expect(page.locator('[data-promotion-form="ads"]')).toBeVisible();
  await page.locator("#promo-ad-title").fill("September Pro offer");
  await page
    .locator("#promo-ad-image")
    .fill("https://example.com/promo.jpg");
  await page.locator('[data-action="promo-save-ads"]').click();
  await expect(page.locator(".promotion-list")).toContainText(
    "September Pro offer",
  );
  await page.locator("#promo-notification-title").fill("New offer");
  await page.locator("#promo-notification-message").fill("A new plan is available.");
  page.on("dialog", (dialog) => dialog.accept());
  await page.locator('[data-action="promo-send-notifications"]').click();
  await expect(page.locator('[data-promotion-form="notifications"]')).toBeVisible();
  await expect(page.locator('[data-promotion-form="notifications"] + .promotion-list')).toContainText("Sent");
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
