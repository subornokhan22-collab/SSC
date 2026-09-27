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

test("a dropped file reaches the importer, not just the styling", async ({
  page,
}) => {
  await page.getByRole("link", { name: "Import Center", exact: false }).click();
  const zone = page.locator(".dropzone").first();
  await expect(zone).toBeVisible();
  await expect(zone.locator('input[type="file"]')).toHaveCount(1);

  // A DataTransfer cannot be built from a plain object, so the drag events are
  // constructed in the page, where DataTransfer actually exists.
  await zone.evaluate((el) =>
    el.dispatchEvent(
      new DragEvent("dragover", {
        bubbles: true,
        dataTransfer: new DataTransfer(),
      }),
    ),
  );
  await expect(zone).toHaveAttribute("data-drag", "over");

  const csv = "stem,answer\nA force?,B";
  await zone.evaluate((el, text) => {
    const transfer = new DataTransfer();
    transfer.items.add(new File([text], "dropped.csv", { type: "text/csv" }));
    el.dispatchEvent(
      new DragEvent("drop", { bubbles: true, dataTransfer: transfer }),
    );
  }, csv);

  // The proof that matters: the dropped bytes reach the existing handler and
  // land in the importer, rather than only repainting the border.
  await expect(page.locator("#import-text")).toHaveValue(csv);
  await expect(zone).toHaveAttribute("data-drag", "");
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
