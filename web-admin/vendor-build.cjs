const esbuild = require("esbuild");
const fs = require("fs");
fs.mkdirSync("vendor", { recursive: true });
esbuild.buildSync({
  stdin: {
    contents: "export {createClient} from '@supabase/supabase-js';",
    resolveDir: process.cwd(),
  },
  bundle: true,
  format: "esm",
  minify: true,
  outfile: "vendor/supabase.mjs",
});
fs.copyFileSync("node_modules/pdfjs-dist/build/pdf.mjs", "vendor/pdf.mjs");
fs.copyFileSync(
  "node_modules/pdfjs-dist/build/pdf.worker.mjs",
  "vendor/pdf.worker.mjs",
);
fs.copyFileSync("node_modules/pdfjs-dist/LICENSE", "vendor/PDFJS-LICENSE");
fs.copyFileSync(
  "../assets/fonts/HindSiliguri-Regular.ttf",
  "vendor/HindSiliguri-Regular.ttf",
);
for (const packageName of [
  "supabase-js",
  "auth-js",
  "postgrest-js",
  "realtime-js",
  "storage-js",
  "functions-js",
]) {
  const path = "node_modules/@supabase/" + packageName + "/LICENSE";
  if (fs.existsSync(path))
    fs.copyFileSync(path, "vendor/" + packageName + "-LICENSE");
}

fs.writeFileSync(
  "schema.sql",
  "-- GENERATED bootstrap: canonical migration + Supabase Storage policies.\n-- Existing admin memberships are retained; no email address gains access here.\n" +
    fs.readFileSync(
      "../supabase/migrations/20260925000001_content_manager.sql",
      "utf8",
    ) +
    "\n" +
    fs.readFileSync("../supabase/content_storage.sql", "utf8"),
);
