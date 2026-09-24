# 40-point review — implementation tracker

Full review: "SSC-main.zip inspection" (40 items, 5 phases). Owner approved all 40,
done phase by phase, every phase ending with a green CI build.

Legend: ✅ done (ref) · 🔄 in progress · ⏳ queued · 🔒 needs user action · ⏸ deferred (reason)

> Recovery update (2026-09-24): original files restored on `arena/01a0ce12-ssc`;
> Phase 1 CI passed at `65dec3b` (run 35976648526); Phase 2 has started.
> Integration corrections and verification are tracked in `docs/RECOVERY-2026-09-24.md`.
> Production RLS/function/signing setup remains unverified.

Historical status: 2026-09-23, **Phase 1 code complete** (7 local commits, see
docs/HANDOFF-2026-09-23.md — they still need to land on main in the next
session; the session that made them closed when PR #5 merged). CI gates
(analyze + test) live since run 35816456766; first fully green build
35817330320.

---

## Phase 1 — correctness / security (🔄)

| # | Item | Status | Notes |
|---|------|--------|-------|
| 31 | Release signing | 🔒 | CI + gradle wiring verified correct (PKCS12 keystore, debug fallback). Owner: follow docs/RELEASE-SIGNING.md (4 secrets + one-time reinstall). |
| 33 | Automated quality gates | ✅ | analyze + test gates since 35816456766; now also: `dart format` report step (flips to hard gate in Phase 2 after one format pass) and the bank-health gate (#35). |
| 9 | Automated flutter analyze | ✅ | Same as 33. |
| 1 | Server-side Gemini architecture | ✅ (code) / 🔒 (deploy) | Edge function `supabase/functions/mimi/` (SSE pass-through, model fallback, error codes) + app server-first routing with device-key fallback; key entry demoted to the ⚙ advanced dialog. Owner: `supabase functions deploy mimi` + set `GEMINI_API_KEY` secret. |
| 3 | Supabase RLS audit | ✅ (code) / 🔒 (run) | `supabase/migrations/…_harden_profiles.sql` (drop permissive profiles policies, own-row select/update, trigger that freezes is_pro/pro_until/pro_plan for any user-context write; service role unaffected → bKash function still works). `supabase/audit_rls.sql` = read-only report the owner runs in the SQL editor. docs/RLS-CHECKLIST.md. |
| 4 | Pro entitlement security | ✅ (code) / 🔒 (run) | Covered by the same migration (client already only *reads* entitlements — verified: auth_service never writes is_pro; only bKash edge fn, via service role, does). PaperLicense stays a cache. |
| 6 | AI answer validation | ✅ | `lib/services/ai/question_schema_validator.dart`: count, 4 distinct options, correct ∈ 0..3, non-empty fields, no placeholder/LaTeX, explanation↔key consistency flags. Wired into any AI question path; tests included. (No in-app AI question *generator* currently ships — MiMi is a tutor chat; the generator returns in Phase 5 built on this validator.) |
| 7 | Duplicate detection | ✅ | `lib/services/ai/duplicate_detector.dart`: normalized token similarity vs local bank + previous AI questions. Tests included. |
| 8 | Async lifecycle safety | ✅ | Repo-wide audit; 5 unguarded awaits fixed (MiMi audio/PDF pickers, OMR photo picker, OMR key save/restore, saved-paper pick). |
| 34 | Test expansion | 🔄 | Added: ai_validator_test, ai_duplicate_test, paper distribution/marks tests, OMR already covered (blank/double-mark/rotation). Auth tests: no live network in CI — structured around fakes where possible. |
| 35 | Question-bank health report | ✅ | `tool/bank_health.py` on every build (artifact `bank-health`). First run already caught **6 real duplicate stems** in the shipped bank (5 general_math, 1 physics) — dedupe in Phase 3/4. Report: totals, bad keys, dup ids/stems, invalid options, empty explanations, CQ part/marks consistency (3-part 2-4-4 math + 4-part 1-2-3-4 both legal), chapter distribution. | the "Question Bank Health" summary (totals, missing answers, dup IDs, dup questions, invalid indexes, empty explanations, missing chapters) as an annotation + artifact. |
| 32 | Release only when tagged | ✅ | Branch builds → Actions artifact (run → Artifacts); formal release only from `v*` tags; diag logs → artifacts too. **Download flow changes:** branch APKs come from the Actions run page, releases from tags. |
| 10 | AI loading UX | ⏳ | Phased steps (Reading chapter → Applying SSC pattern → Generating → Checking answers) once the generator lands (Phase 5); MiMi chat already streams + has the animated orb. |
| 36 | "Board-verified" wording | ✅ | Already fixed in a prior session (teacher_home_screen: "board-style"); verified absent from lib/. |
| 2 | AI parser (fragile indexOf slice) | ✅ (superseded) | The old `ai_question_generator.dart` JSON-slice parser was removed in a prior session (nothing ships it). Superseded by #6/#34: the Phase 5 generator uses schema-forced output + this validator instead of string slicing. |
| 5 | AI questions duplicate each other | ✅(part) | Detector built + tested now (#7); wired into the generator in Phase 5 (#14/#38). |

## Phase 2 — architecture (🔄)

| # | Item | Status |
|---|------|--------|
| 8b | Split huge screens (custom_paper 1.4k, question_paper, ai_tutor 1.7k) | ⏳ controllers/ + widgets/ per screen, ChangeNotifier, no framework |
| 12/13 | Paper controller + AI controller | ⏳ (folded into 8b) |
| 14 | Centralize loading/error states | ⏳ (existing red problem-dialog pattern → shared hook) |
| 15 | Centralize navigation | ⏳ named routes |
| 16 | Design tokens (colors/typography/spacing in one file) | 🔄 foundation in `lib/theme/design_tokens.dart`; theme, presets and shared button migrated; screen adoption remains |
| 17 | Centralize question validation | ⏳ (validator already central for AI; extend to bank load) |

## Phase 3 — UX (⏳)

| # | Item | Status |
|---|------|--------|
| 13 | Merge four paper builders → one "Create Paper" | ⏳ |
| 28 | Recent papers (home) | ⏳ |
| 29 | Draft autosave ("Auto-saved 10:42 PM") | ⏳ |
| 27 | Undo/redo (delete, replace, counts, chapters, answers) | ⏳ |
| 17 | Smart defaults (one-tap Physics Model Test) | ⏳ |
| 23 | Simplify onboarding screen | ⏳ |
| 24 | Defer Pro upsell → contextual unlock dialog | ⏳ |
| 25 | OMR as its own polished 4-step workflow | ⏳ |
| 26 | OMR confidence visualization + tap-to-correct review | ⏳ |
| 12 | Home: fewer choices (Create Paper / Scan OMR / AI / Recent) | ⏳ (with 13/28/37) |
| 37 | Restructure around 5 primary actions + 4-tab nav | ⏳ (with 12/13) |
| 16 | Visual question builder (5 steps + progress) | ⏳ (with 13) |
| 18 | PDF preview as hero | ⏳ (with 13) |
| 14 | AI integrated where it helps (question selection: bank 20 + AI 10, ✨ Improve with AI) | ⏳ (with Phase 5) |

## Phase 4 — visual polish (⏳)

Supersedes the earlier "futuristic MiMi" spec (owner approved all 40 on 2026-09-23).

| # | Item | Status |
|---|------|--------|
| 20 | Paper + Ink + Indigo design language | ⏳ |
| 21 | Palette → 7 colors (#3157D5 / #172033 / #F7F8FA / #E4E7EC / #16845B / #C27A00 / #D64545) | ⏳ |
| 22 | Typography: Hind Siliguri (UI) + Noto Serif Bengali (paper preview) | ⏳ |
| 11 | Cut decorative animation ~60–70% (keep: press feedback, transitions, loading, AI-gen, success) | ⏳ |
| 26b | Reduce gradients | ⏳ (with 11) |
| 19 | Strip marketing copy from functional screens; keep AI visible but unglamorous | ⏳ |
| 31b | Spacing pass + empty/loading/error states + subtle transitions | ⏳ |
| 40 | Real teacher terminology (Question Paper, Model Test, Board Pattern, উদ্দীপক ক খ গ ঘ, Answer Key, Marks); kill "AI MAGIC" vocabulary | ⏳ |

## Phase 5 — AI (⏳)

| # | Item | Status |
|---|------|--------|
| 1b/34 | Backend AI generation (edge fn `mimi` action=generate, schema-forced JSON) | ⏳ |
| 3 | Validator model second pass ("✓ AI checked" only when it ran) | ⏳ |
| 4 | SSC-constrained prompt (NCTB chapter boundaries, difficulty, distractor quality, CQ structure, mark allocation) fed from local bank metadata | ⏳ |
| 5 | Duplicate gate on generated output (bank + previous + current paper) | ⏳ (detector ready) |
| 38 | Teacher-command AI interface (Create / Improve / Check / Explain — no chat bubbles by default) | ⏳ |
| 39 | AI response design (counts, ✓ valid, ⚠ similar, difficulty bar, per-question Review/Replace/Edit) | ⏳ |
| 10 | Phased generation loading UX | ⏳ |
| 14 | ✨ Improve with AI (harder / replace duplicates / balance difficulty / from chapter) | ⏳ |

---

## User action checklist (accumulated)

1. 🔒 **Release signing** — add 4 repo secrets (docs/RELEASE-SIGNING.md).
2. 🔒 **RLS hardening** — run `supabase/migrations/20260923000001_harden_profiles.sql` in the SQL editor, then run `supabase/audit_rls.sql` and share the output (docs/RLS-CHECKLIST.md).
3. 🔒 **Gemini server key** — Supabase → Edge Functions → Secrets → `GEMINI_API_KEY` (Phase 1, commit 4). Until set, MiMi falls back to the device key if one is stored, else shows "AI not configured".
