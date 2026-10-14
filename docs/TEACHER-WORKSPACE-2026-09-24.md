# Teacher workspace implementation — 24 September 2026

Branch: `arena/01a0ce12-ssc` · PR: https://github.com/subornokhan22-collab/SSC/pull/6

This builds on the recovered Phase 1 originals; their provenance remains in
`RECOVERY-2026-09-24.md`. These are new implementation changes, not reconstructed
recovery files.

## Working paths

- **Home / My Papers / Scan / AI Tools** navigation. Home has one Create/resume
  action, a quick Physics Model Test, and the four most recent saved/uploaded
  papers. Secondary tools mount lazily; opening Home does not ask for library
  backup permissions. Settings remains a secondary action.
- **Create Paper** owns all four former builder entry points: Subject → Chapters
  & format → Counts → Review → Preview. Quick Physics starts at question review.
- `PaperController` owns selection, shared async/error state, MCQ/SAQ/CQ edits,
  replacement within a chapter, removal in custom papers, and a 60-change
  undo/redo history. Fixed board papers cannot lose questions through deletion.
- A debounced, serialized device draft stores the actual questions and figures,
  not merely selection settings. Undo, redo, answer-key changes and edits persist.
  A corrupt draft is not silently overwritten on opening/closing the screen.
- Preview renders with the existing Bengali/English print engine. Swiping and
  pinch-to-zoom inspect the same page images embedded in the exported PDF.
  An optional MCQ answer-key page is off by default for the student copy.
- Pro is offered when saving/exporting/printing, not at entry to paper creation.
  Existing saved/uploaded papers remain viewable and printable.
- Saved-paper and uploaded-PDF previews share one viewer. The missing-separator
  legacy library index is copied to the correct location, retaining the legacy
  file for recovery. An unencodable page aborts a save rather than losing a page.
- **OMR**: choose paper/key → capture → review → grade/save. Review shows measured
  per-option ink and the ink gap, highlights uncertain reads and supports manual
  answer, roll and registration corrections. It does not invent confidence
  probabilities. Corrections update grades, overlays, scorecards and history;
  saving another review replaces the same record, not a duplicate student.
  Gallery batches require a review of each readable sheet before saving it.
- **AI Tools** defaults to Create / Improve / Check / Explain. The previous chat
  with photo/audio/PDF attachments is retained as a secondary menu destination.
  Structured generation supports 1–10 MCQs, subject/chapter constraints and
  easy/mixed/hard requests. Questions can be edited, replaced, removed, added to
  a paper, or used to replace an MCQ via **Improve with AI** in the review step.

## AI validation contract

`mimi/teacher_tools.ts` provides bounded request validation, a forced JSON schema,
strict count/options/key/chapter checks, and an independent answer-solving pass.
The validator receives the stems and options without the proposed answer keys or
explanations. A mismatch, incomplete check or ambiguous answer rejects the batch.
The accepted explanation comes from the independent solver's reasoning.

SSE phases are emitted when the server actually enters a stage. The app performs
another schema check and similarity comparisons against the local bank, current
paper, other questions in the batch and the last 300 generated questions stored
for the account on that device. Similar questions remain visible for correction
but cannot be added until resolved. Editing removes the **AI checked** label.
That label means a second model pass ran; it is not official board verification
or a guarantee of correctness. Teacher review remains required.

Generation uses only the authenticated server path, never a silent unvalidated
fallback to a device API key. Legacy attachment chat retains its existing path.

## Design and architecture

Paper + Ink + Indigo semantic tokens, Hind Siliguri UI and Noto Serif Bengali
paper fonts; static background, quiet cards and solid primary actions. Removed
the animated home, animated welcome, looping global background and button shine.
Loading indicators, press feedback and navigation transitions remain. Legacy
attachment chat and some secondary screens have not been fully restyled.

Ordinary ChangeNotifier controllers; no new state-management dependency.
Named routes cover primary creation/settings/plans/AI destinations. Bank loading,
remote merges, generated paper review and edits share validation boundaries.
Invalid remote rows cannot replace a healthy local row. MCQ deduplication during
composition avoids the six known duplicate stems without deleting provenance
from the bundled bank. Each CQ renders its own three- or four-part mark pattern.

## Honest scope / remaining work

- **Bundled bank availability is unchanged:** Physics, Chemistry, Biology and
  General Math have substantial banks; Higher Math has only a small legacy set.
  The English mixers provide existing complete English sections. ICT, Bangla and
  other catalogue subjects do not have complete bundled MCQ/CQ/SAQ banks in this
  checkout. Their catalogues/pattern engines are retained, but shortages are
  explicit errors; the app does not invent a complete offline board paper.
- Structured **AI generation currently produces MCQs**. Check/Explain can review
  supplied written-question text, but schema-forced CQ generation with independently
  checked subpart marking is not implemented. Bangla/English full written sections
  retain their existing renderer rather than a new per-section visual editor.
- New paper and AI task flows are controller-backed; the secondary legacy
  attachment-chat and OMR camera/analytics implementations retain some monolithic
  code. This is not a claim that every legacy screen has been refactored.
- No production Supabase deployment, SQL migration/audit or signing-secret change
  was performed. Deploy `mimi` and configure `GEMINI_API_KEY` for the new commands.
  Optional `GEMINI_GENERATOR_MODEL` / `GEMINI_VALIDATOR_MODEL` select available
  models; both default to `gemini-2.5-flash`, with independent requests. Persistent
  service quotas and production monitoring should be configured before broad use.
- CI quality gates cover analysis, tests, formatting, bank health and APK build.
  Device checks of camera/ML Kit, Bengali rendering, system PDF sharing/printing,
  storage permissions and live authenticated AI remain release smoke tests.

## Verification

Local: all 18 gateway/teacher-tool Node tests pass; standalone teacher-tool Deno
check passes; Dart sources parse through the dart_style WASM formatter; bank
health reports zero hard errors and six existing duplicate-stem warnings.
Flutter/Dart execution and Android APK compilation are verified through GitHub
Actions because this editor sandbox has no Flutter SDK. See the final PR check
for the verified head and downloadable APK rather than an earlier intermediate
run. Test coverage includes paper marks/distribution, shortage errors, complete
snapshot round trips, undo/redo/autosave, corrupted drafts, written-question
removal, async disposal, AI badge/duplicate boundaries and OMR history corrections.
