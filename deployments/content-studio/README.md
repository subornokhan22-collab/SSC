# Content Studio — GitHub download files

Release deliverables live in GitHub, not only in chat attachments. The website and SQL snapshot comes from approved application commit `b5711ca46236253fdf494c1a83f744e53dc3c5ac`. The `mimi` bundle additionally includes the `mimi-sse-mobile-v2` stream-framing repair; its canonical source and regression tests are versioned alongside this package.

## Downloads

- [Complete update package](content-studio-update.zip) — download and extract this on your phone.
- [Website-only ZIP for Netlify](content-studio-netlify.zip) — deploy this ZIP, **not** the complete update package.
- [Supabase database update](database-update.sql) — paste the entire file into the SQL Editor.
- [Website English-import AI function](admin-content.ts) — use as `index.ts` for the function named `admin-content`.
- [APK AI Tools/chat function](mimi.ts) — use as `index.ts` for the **separate** function named `mimi`. Both functions are required if you use both features.
- [Short dashboard instructions](START-HERE.txt).
- [Detailed instructions included with this release](SOURCE-README.md).
- [File checksums](SHA256SUMS).

On GitHub, open a file and use **Download raw file**. For SQL or TypeScript, use **Raw** / **Copy raw file** to obtain the actual code, not the GitHub HTML page.

## Deployment order

1. Review backup options, then apply the SQL migration. It changes schema and permissions; it is not itself a backup. Stop if it reports an error.
2. Deploy **both** AI functions: `admin-content` for website photo/scan extraction and `mimi` for APK AI Tools/chat. They share the same existing `GEMINI_API_KEY` project secret. Each generated single-file function bundles its local dependencies and still imports the Supabase SDK over HTTPS.
3. Deploy the website ZIP to the existing Netlify site.
4. Test PDF/image intake, human review, publication and sync with a compatible APK.

Preparing or uploading these files to GitHub does **not** deploy Supabase or Netlify. The website ZIP must have `index.html` at the deployed root; keep `vendor/` intact. No private credentials or database backups are included. The browser's Supabase anon key is intentionally public and is not an administrator credential.

## Future delivery convention

- Upload release code, setup scripts, instructions and deployment ZIPs to GitHub with each approved update. Do not leave the only copy in a chat attachment.
- Refresh this directory's packages, source revision, instructions and checksums together whenever their contents change. These files are a versioned release snapshot, not automatically regenerated from later source edits.
- Keep passwords, private API keys, signing keys, private database backups, dependency directories and temporary test files out of Git.
- Large APK binaries belong in GitHub Actions artifacts or GitHub Releases rather than repeatedly copying them into Git history. Include their download links in the handoff.

Canonical sources: [website](../../web-admin/), [migration](../../supabase/migrations/20260925000001_content_manager.sql), [AI function](../../supabase/functions/admin-content/). Current development instructions: [web-admin/README.md](../../web-admin/README.md).

## APK “AI server error (404)”

The app calls `/functions/v1/mimi`, not `/functions/v1/admin-content`. An HTTP 404 at that route usually means `mimi` is missing or deployed under a different name/project. Creating a secret or deploying only `admin-content` does not create the APK function.

In the project configured in the app (`vxexidxdoghdmzvkvgqk`), open Edge Functions and create/update **mimi**. Replace its `index.ts` with all of [mimi.ts](mimi.ts), then Deploy. Keep `admin-content` as a separate function. Reuse the existing `GEMINI_API_KEY`; do not paste it into the function or chat. This deployment repair does not require another APK or SQL migration.

The bundle is tested with mocked authentication/model services for signed-in access, missing-key handling, generation SSE, independent answer checking and rejection of invalid answers. It has not been deployed to your project by uploading it here. A live unauthenticated endpoint probe was unavailable from the build workspace; if the named function already exists and still returns 404, verify the project/function URL and check its Supabase logs.

Developer regeneration command (users can use the dashboard file directly):
```sh
npx --yes --package esbuild@0.25.10 esbuild supabase/functions/mimi/index.ts --bundle --platform=neutral --target=es2022 --format=esm '--external:https://*' --outfile=deployments/content-studio/mimi.ts
```
Add the generated-file `// @ts-nocheck` header for the dashboard `index.ts` editor, retain the canonical-source notice, rerun `supabase/tests/mimi_deployment_test.mjs`, and refresh the package/checksums.

## APK “The server returned no complete result” after mobile paste

This means the APK received HTTP 200 but did not parse a terminal `result` or `error` event. It does **not** mean a separate function named `teacher-tools` must be created. The APK endpoint remains `mimi`.

The older bundled emitter contained literal newlines inside a template string. If a phone editor adds leading indentation during paste, it also changes the bytes inside that string: `data:` becomes space-prefixed, and the APK ignores it. This failure was reproduced locally for both successful results and model-check errors. A screenshot showing deeply accumulated indentation is consistent with that cause, but does not verify the full deployed response.

The refreshed `mimi.ts` has the header **`Bundle revision: mimi-sse-mobile-v2`**. It constructs stream delimiters with an escaped newline string, so source indentation no longer changes the event framing. Replace the **entire** existing `mimi/index.ts` with this updated file and Deploy updates. Do not append it to the old code. Keep the current secret and `admin-content`; no new SQL, Netlify upload or APK installation is needed for this repair.

Tests execute the bundle after simulated editor indentation and parse line prefixes like the existing APK. All 28 local server tests passed, using mocked authentication and model responses, not a live Gemini account. If the same error remains after deployment, inspect the latest `mimi` invocation and logs immediately after an APK retry. Share status/duration and error text with tokens, request headers and private keys hidden. Do not disable authentication.
