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
