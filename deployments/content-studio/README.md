# Content Studio — GitHub download files

Release deliverables live in GitHub, not only in chat attachments. The website and SQL snapshot comes from approved application commit `b5711ca46236253fdf494c1a83f744e53dc3c5ac`. The `mimi` bundle additionally includes `ai-tools-language-v5`, retaining photo/PDF intake and scientific formatting, enforcing subject-language prose, and using one-tap file submission; its canonical source and regression tests are versioned alongside this package.

## Downloads

- [Complete update package](content-studio-update.zip) — download and extract this on your phone.
- [Website-only ZIP for Netlify](content-studio-netlify.zip) — deploy this ZIP, **not** the complete update package.
- [Supabase database update](database-update.sql) — paste the entire file into the SQL Editor.
- [Website English-import AI function](admin-content.ts) — use as `index.ts` for the function named `admin-content`.
- [APK AI Tools function](mimi.ts) — use as `index.ts` for the **separate** function named `mimi`. Both functions are required if you use both features.
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

The v2 repair (retained in the current v3 bundle) constructs stream delimiters with an escaped newline string, so source indentation no longer changes the event framing. Replace the **entire** existing `mimi/index.ts` with this updated file and Deploy updates. Do not append it to the old code. Keep the current secret and `admin-content`; no new SQL, Netlify upload or APK installation is needed for this repair.

Tests execute the bundle after simulated editor indentation and parse line prefixes like the existing APK. The v2 release passed 28 local server tests using mocked authentication and model responses, not a live Gemini account. If the same error remains after deployment, inspect the latest `mimi` invocation and logs immediately after an APK retry. Share status/duration and error text with tokens, request headers and private keys hidden. Do not disable authentication.

## APK “The AI service is unavailable” while Invocations shows 200

The teacher-tools stream sends HTTP 200 **before** Gemini finishes. A later provider failure is an `event: error` within that stream, so 200 is not proof that generation succeeded. The older code collapsed every non-429 provider HTTP failure into this generic message. The September 25 follow-up APK screenshot confirms the app now parses this error event, but neither that message nor the invocation's 200 identifies Gemini's actual status/cause.

Replace only `mimi/index.ts` with the current [mimi.ts](mimi.ts), marked **`mimi-provider-diagnostics-v3`**, then Deploy updates and retry once. The existing APK will display a fixed diagnostic such as `[GEMINI_MODEL_UNAVAILABLE; HTTP 404; generator]`. This is a diagnostic improvement, **not a verified fix to the user's Gemini account or model access**. No private project credentials are available to us and no live model call has been tested.

- `GEMINI_KEY_INVALID` / `GEMINI_KEY_BLOCKED`: Google reports invalid/expired or leaked/blocked credentials. Review or replace the project secret privately in Supabase with a Google AI Studio key, never in source or chat.
- `GEMINI_KEY_RESTRICTED` / `GEMINI_ACCESS_DENIED`: check that key's Google project permissions and application/API restrictions; do not disable Supabase authentication.
- `GEMINI_API_DISABLED`: check Generative Language API enablement in the Google project owning the key.
- `GEMINI_MODEL_UNAVAILABLE`: check the indicated `GEMINI_GENERATOR_MODEL` or `GEMINI_VALIDATOR_MODEL` setting against models available to that key. This update does not change the default model or silently switch models.
- `GEMINI_SCHEMA_REJECTED` / `GEMINI_REQUEST_REJECTED`: investigate the server request/model compatibility; do not assume the key is invalid.
- `GEMINI_QUOTA`: review Google AI Studio limits before retrying repeatedly.
- `GEMINI_REGION_UNSUPPORTED` / `GEMINI_BILLING_REQUIRED`: review Google's project/region/plan requirements. Do not buy a plan on the basis of the old generic message.
- `GEMINI_UPSTREAM_ERROR`, `GEMINI_NETWORK`, `GEMINI_TIMEOUT`: provider HTTP failure, server connectivity failure or timeout, respectively.

Supabase **Logs** now records a `mimi_provider_error` warning with only our fixed code, numeric `upstreamStatus` and `generator`/`validator` stage. The APK displays these through the existing error-message field. Provider bodies are bounded to 16 KiB for classification; raw messages, credentials, model names from environment settings, prompts and generated content are never included in the new diagnostics/logs. Unrecognized failures fall back to status-based diagnostics rather than guessing a cause. Chat and website-import error handling are unchanged.

All **56 local server tests** passed, including classification, oversized/malformed error bodies, network failures, safe logging, checker-stage failures and mobile-indented SSE. These tests use mocked authentication/provider services. Existing authentication, independent answer checking and publication rules remain in place. Send only the new APK error code/message if it still fails; do not send API keys or request headers.

## Current release: subject language, English digits and one-tap attachments

Use the current bundle marked **ai-tools-language-v5** and the new APK from this branch's successful CI build. Deploy the backend first; old text-only APK requests remain compatible. The new APK refuses attachment results from an older backend that cannot acknowledge attachment support.

The separate MiMi chat screen is removed, but **keep the existing `mimi` Supabase function**: it is the compatibility route for AI Tools. Keep your already-working API key and model overrides. No SQL or Netlify update is needed.

Camera/gallery photos and PDFs now attach directly to all four tools (3 files / 3 MiB total after photo resizing), with one-tap tool submission, photo preview and removal (no extra consent checkbox or provider banner). Originals stay local for the session and are not embedded as paper figures. English digits and common Unicode powers/subscripts are applied before checking and carried into paper export. Unknown math is preserved, not silently truncated.

See [the complete release/verification notes](../../docs/AI-TOOLS-ATTACHMENTS-2026-09-25.md). Historical v2/v3 sections above describe previous repairs; the current v5 bundle includes them. For current deployment, do not paste an older revision linked in prior chat messages.

**Language correction:** Non-English subjects answer in Bengali; only numerals use English digits. English First/Second answer in English. This applies to all four modes and the independent checker, with a language guard and at most one corrective retry. Files remain local until the user taps the tool action. Deploy v5 for the response-language correction and install the new APK to remove the checkbox; keep working model/key settings unchanged. Previously saved English content is not automatically rewritten. See the linked release notes for limits and smoke tests.
