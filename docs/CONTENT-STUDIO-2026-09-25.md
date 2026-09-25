# Content Studio handoff · 25 September 2026

The accepted teacher workspace remains intact. This change adds the content-management counterpart plus the app synchronization it requires.

## Delivered in code

- Hosted dashboard; actual server counts; search across serialized question/English content; server pagination.
- Generic draft editor, duplication, review/publish, archive/restore, confirmed delete and JSON backups/exports.
- Dedicated English first/second editors, structured nested inputs, board/year filters, text/PDF/JSON ingestion, missing-answer warnings, full-paper review.
- Optional authenticated admin-only AI structuring/review function, separate from the teacher AI gateway.
- Shared hosted/local validation, CSV mapping, Unicode/key/CQ/table checks; health issue → editor; human-reviewed similarity suggestions in a worker.
- Figure processing/upload/reference inspection and guarded cleanup; append-only question/English/catalog audit; editable subject/chapter catalog.
- Official SDK memory-only auth, CSP, escaped source rendering, server workflow/RLS checks and optimistic update checks.
- App: separate English sync/models/adapter integration and persisted board/year selection; complete paginated generic-bank reconciliation; catalog sync; offline fallback.

## Verification and deployment boundary

Node validation/import and real Chromium demo flows are covered. Disposable PostgreSQL-compatible tests exercise actual migration SQL, reruns, role policies, publication gates, malformed nested English, archive/restore and audit writes. GitHub Actions additionally runs PostgreSQL 16, Deno typecheck, Flutter analysis/tests/format, bank health and APK build. Consult the current Actions run for the actual status; do not infer Flutter success from local WASM formatting.

Deployment and manual rollout instructions, safe backup semantics, limitations, and source/answer behavior are in `web-admin/README.md`. The previous production configuration and accepted APK are not automatically replaced by a code push.

## Finalized direct paper upload

English Papers now has **Upload English Paper (PDF / Image)**. One PDF of up to ten pages or up to ten JPG/PNG/WebP photos can be previewed, ordered (photos), and turned into a reviewable draft. Selectable PDF text is read locally. Photos/scans can be transcribed through the authenticated AI function after explicit consent; demo mode never sends files to AI. Source files are session-local, while structured content and filenames are saved. Answer fields remain empty unless manually supplied later.

The uploader requires the **updated** `admin-content` function (including `attachments.ts`), its existing shared request parser and JSON schema, plus the `GEMINI_API_KEY` server secret for AI. This upload follow-up adds no new database migration or Dart changes. Full OCR accuracy, English inline-image embedding, and English answer-key rendering in the app are not claimed. Browser tests mock AI responses; actual extraction quality must be smoke-tested after deployment.

### Operator handoff

1. Confirm the current admin website URL/hosting provider and whether the content-manager migration has already been applied. No credentials are needed in chat.
2. Back up the database, storage originals and current hosted admin before deployment. Preserve/export important phone papers before any APK replacement; do not uninstall to work around a signing mismatch without a backup.
3. Apply the content-manager migration if not already applied; configure Storage for a new installation. Confirm existing admin membership.
4. Deploy the updated Edge Function and set its secret in Supabase, never in browser code or chat.
5. Deploy the complete static `web-admin` runtime, including `english-upload.js` and `vendor/`. If merging PR #6 auto-deploys the website, complete the database/function setup before merging.
6. Test one PDF and one clear photographed paper, inspect the resulting drafts, and publish only reviewed material. Use a companion APK with English sync and verify online generation followed by offline use.
