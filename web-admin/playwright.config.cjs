const { defineConfig } = require("@playwright/test");
module.exports = defineConfig({
  testDir: "./tests",
  testMatch: "**/*.spec.cjs",
  use: {
    baseURL: "http://127.0.0.1:4173",
    headless: true,
    launchOptions: {
      executablePath: process.env.CHROMIUM_EXECUTABLE || undefined,
      args: ["--no-sandbox", "--disable-dev-shm-usage"],
    },
    viewport: { width: 1365, height: 950 },
  },
  webServer: process.env.CMS_EXISTING_SERVER
    ? undefined
    : {
        command: "python3 -m http.server 4173 --bind 0.0.0.0",
        port: 4173,
        reuseExistingServer: !process.env.CI,
      },
  reporter: "list",
});
