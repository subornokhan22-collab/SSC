# AI Tools: English digits, scientific notation and attachments

## User-approved scope

- Use English numerals (0–9), retaining Bengali prose for every non-English subject. English First/Second use English prose. This applies to generated questions, checked explanations and review feedback, not just prompts.
- Camera/gallery photos and PDFs directly in Create, Improve, Check and Explain.
- Remove the separate MiMi chat screen and device-key chat client. No audio intake.
- Retain the existing authenticated `mimi` endpoint for AI Tools and older APK compatibility. **Do not delete the Supabase function.**

## Release order (after green CI)

1. Replace the existing Supabase **mimi → index.ts** with `deployments/content-studio/mimi.ts`, header **ai-tools-language-v5**, and deploy.
2. Keep `GEMINI_API_KEY` and both **working** model overrides unchanged. A successful request was reported before this update; do not reset settings to the older default model. No database or Netlify update is required.
3. Install the new APK from this branch's successful GitHub Actions build. Do not uninstall the existing app or erase local papers to work around an installation/signing error; signing/upgrade compatibility is not assumed.
4. Test one generated question, then a legible photo and a small PDF. Review answers before adding to a paper. Check the exported PDF too.

Old APK text-only AI Tools remains compatible with the new gateway. A new APK detects an old gateway when sending files and refuses results that might have ignored the attachments; it asks for the backend update instead. The gateway advertises `X-Teacher-Attachments-Version: 1`.

## Formatting

The server normalizes question text/options **before** independent answer checking. The returned explanation, review findings and client-visible content use the same rules, covered by shared fixtures. Option uniqueness preserves signs, powers and scientific symbols (so `-1`, `+1`, `10²` and `10³` remain distinct). Exact chapter IDs/labels and numeric answer indices remain unchanged. Edited questions still lose their AI-checked status.

Examples: `১ → 1`, `m/s^২ → m/s²`, `10^{-৩} → 10⁻³`, `CO_{২} → CO₂`, simple `\frac{1}{2} → (1)/(2)`. Known wrappers/commands are converted to plain Unicode; this is **not** a full LaTeX engine. Unknown exponent characters/expressions are preserved rather than silently dropped. The existing PDF renderer now uses this formatter, fixing its prior loss of unsupported exponent characters. DejaVu Sans is registered as a scientific-symbol fallback for AI results.

## Attachment behavior and limits

- Up to **3 files**, **3 MiB combined** after photo resizing. Camera/gallery images are re-encoded as JPEG (longest side <=1600 pixels, quality 82). The client bounds original image input to 15 MiB and decoded dimensions to 40 MP.
- JPEG, PNG, WebP and PDF only; no SVG, audio or remote file URLs. Backend independently checks type, signature, base64, file count and combined decoded size before invoking Gemini. The existing total HTTP body bound also remains in place.
- Files stay in session memory. Selecting a file does **not** upload it. There is no extra checkbox or Gemini/Supabase banner. Selecting files stays local; tapping Create / Improve / Check / Explain submits them with the request. The controller sets the existing wire acknowledgement at that explicit submit action, so old attachment-capable backends remain compatible. Avoid private/student-identifying material.
- Photos have an in-app zoomable preview. PDFs show filename/size, **not page previews**; use short, unencrypted, legible PDFs. No page-count validation is claimed.
- Removing attachments is disabled during processing. Input can be text, files, or both for Improve/Check/Explain.
- Originals are not stored in Supabase, paper drafts, AI history or exports by this feature. Generated text goes through the existing reviewed workflow; it is not auto-published. Files are reference material, **not automatically embedded question figures**.
- Files go only to the source-reading generation/review pass. The separate answer checker sees the normalized question and options, not source answer keys or the generator's key/explanation. The prompt requires generated questions to stand alone without missing figures.
- Provider error diagnostics, mobile-safe streaming and authentication remain intact. No silent model fallback, key changes or quota bypass.

## Verification and limitations

77 local Node server tests pass, including the actual dashboard bundle with mock auth/model calls, file rejection/submission acknowledgement, source-only attachment forwarding, normalization-before-checking, independent checker rejection, privacy-safe diagnostics and SSE framing. Flutter tests cover shared formatter fixtures, image resizing, byte/type/count limits, one-tap submission without a checkbox/banner, client protocol/auth and attachment removal/busy UI.

Flutter SDK downloads were blocked by workspace TLS, so Flutter analysis/tests and the Android APK build are verified via GitHub Actions, not claimed as locally executed. Native Android camera/gallery/file-provider behavior and live Gemini reading accuracy require the on-device smoke test above. A generated question's AI-checked label is not a guarantee of correctness.

## Language and one-tap correction — 2026-09-26

Language is chosen only from the selected subject: `english_1st` / `english_2nd` use English; all others use Bengali. The numeral instruction explicitly concerns only 0–9 and must not change prose language. It is repeated in the generator, independent checker and Check/Explain review prompts, including corrective retries. Scientific units/symbols/proper names may remain Latin. Metadata and JSON keys/enums are not translated.

A script/prose guard rejects obvious wrong-language question stems, long prose options, summaries/findings and final checker reasons. This is a bounded heuristic, not a perfect language detector or a translator. Formula/unit-only options and review details remain valid. On detected drift the server permits **one extra model call across the entire operation**, with a stricter language reminder. Questions are language-corrected **before** independent solving; checker-reason correction re-runs the same blind checker rather than translating verified answers afterward. If drift continues, no checked result is returned. Provider/schema/answer-check errors do not trigger this retry. All model passes share a 120-second budget (at most 75 seconds per call), so adding a repair does not multiply the Edge Function runtime limit.

The APK no longer requires an `attachmentConsent` parameter/checkbox. Running a tool is the submission action; selecting/removing files does not upload. The internal JSON acknowledgement remains for wire compatibility and is set automatically by the controller only on execution. Server auth, file bounds/type checks, no-persistence behavior and capability-header checks are unchanged.

Deploy the v5 backend and install the new APK: the backend fixes newly generated response language, while the APK removes the manual checkbox. Old saved English answers are not silently translated or rewritten; regenerate or edit them. Smoke-test Physics/Chemistry with Bengali prose + English digits, both English subjects with English prose, and an attached photo/PDF submitted by one Run tap. No key/model, database or website changes are required.
