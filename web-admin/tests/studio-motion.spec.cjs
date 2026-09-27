const { test, expect } = require("@playwright/test");

test.beforeEach(async ({ page }) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Explore an offline demo" }).click();
  await expect(page.locator("#page-title")).toHaveText("Dashboard");
});

test("dashboard counters settle on the value the server returned", async ({
  page,
}) => {
  const stat = page.locator(".stat strong[data-count]").first();
  const target = Number(await stat.getAttribute("data-count"));
  // The animation must finish exactly on the real total, not near it.
  await expect
    .poll(async () =>
      Number((await stat.textContent()).replace(/,/g, "")),
    )
    .toBe(target);
});

test("narrow screens get a drawer that opens, navigates and closes", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  const toggle = page.locator("#menu-toggle");
  await expect(toggle).toBeVisible();
  await expect(toggle).toHaveAttribute("aria-expanded", "false");
  await toggle.click();
  await expect(toggle).toHaveAttribute("aria-expanded", "true");
  await expect(page.locator("body")).toHaveAttribute("data-drawer", "open");
  await page.getByRole("link", { name: "Validation", exact: false }).click();
  await expect(page.locator("#page-title")).toHaveText("Validation");
  await expect(page.locator("body")).toHaveAttribute("data-drawer", "closed");
});

test("Ctrl+K opens the command centre and jumps to a workspace", async ({
  page,
}) => {
  await page.keyboard.press("Control+k");
  await expect(page.locator("#command")).toBeVisible();
  await page.locator("#command-input").fill("Validation");
  await page.keyboard.press("Enter");
  await expect(page.locator("#page-title")).toHaveText("Validation");
});

test("a file input becomes a drop target that answers to a hover", async ({
  page,
}) => {
  await page.getByRole("link", { name: "Import Center", exact: false }).click();
  const zone = page.locator(".dropzone").first();
  await expect(zone).toBeVisible();
  await expect(zone.locator('input[type="file"]')).toHaveCount(1);
  await zone.dispatchEvent("dragover", { dataTransfer: { types: ["Files"] } });
  await expect(zone).toHaveAttribute("data-drag", "over");
});

test("a task locks its own area and leaves unrelated buttons alone", async ({
  page,
}) => {
  // A button disabled for a reason of its own must survive a task elsewhere:
  // finishing a task used to re-enable every button on the page.
  await page.evaluate(() => {
    document.querySelector("#quick-add").disabled = true;
  });
  await page.getByRole("link", { name: "Validation", exact: false }).click();
  await page.locator('[data-action="health"]').click();
  await expect(page.locator("#health-results")).toContainText("8 questions");
  await expect(page.locator("#quick-add")).toBeDisabled();
  await expect(page.locator("#signout")).toBeEnabled();
});

test("the motion switch really stops motion", async ({ page }) => {
  await page.getByRole("link", { name: "Settings", exact: false }).click();
  await expect(page.locator("#motion-pref")).toBeVisible();
  await page.locator("#motion-pref").selectOption("reduced");
  await expect(page.locator("html")).toHaveAttribute("data-motion", "reduced");
  await expect(page.locator("#motion-state")).toContainText("Reduced");
  const duration = await page
    .locator("#quick-add")
    .evaluate((el) => getComputedStyle(el).transitionDuration);
  expect(parseFloat(duration)).toBeLessThan(0.01);
  // The choice persists across a reload, so the setting is not decorative.
  await page.reload();
  await page.getByRole("button", { name: "Explore an offline demo" }).click();
  await expect(page.locator("html")).toHaveAttribute("data-motion", "reduced");
});
