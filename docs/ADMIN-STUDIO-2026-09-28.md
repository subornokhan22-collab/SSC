# Admin studio — 2026-09-28

Follows `ADMIN-STUDIO-2026-09-27.md`. This pass changes how content gets into
the bank, not how the studio looks.

## What changed

**Add Questions is a paste screen.** It used to open a blank single-question
form and bounce the reader back to the bank. It now carries the same workspace
the Import Center uses: one textarea, a format selector, a subject, and a
"Reformat with AI & review" button. Mixed CQ, MCQ and short questions can be
pasted as one block with no pre-formatting, and a whole English paper goes
through the same box. AI output always lands as drafts in the review list — the
existing "Save N drafts? Nothing will be published yet." confirmation is
unchanged, and publishing still needs a human pass. The single-question form is
one click away under "Or start from a blank form".

**One upload route for every subject.** The English-only tab is gone. English
papers are reached from the Question Bank's new content-type filter
(`CONTENT → English papers`), which keeps the board/year/paper filters, and the
upload card in the Import Center is now "Upload paper files" rather than
"English board paper". The paper's internal format — schema v1, 11 sections for
first paper, 12 for second — is untouched. `#english` bookmarks are redirected
to the bank instead of falling through to the dashboard.

**Images on questions.** The editor's "Image URL" text box became an attachment
control: pick a PNG/JPEG/WebP file (uploaded to the existing `question-figures`
bucket under `questions/<uuid>.<ext>`) or paste a URL, with the picture rendered
beside the field. Three failure modes that used to look identical now say what
they are:

- no image → "No image attached."
- a URL that is not `https://` → named as such, because the database trigger
  rejects it (`Figure URL must use HTTPS`);
- a URL that returns a page instead of a file (Drive/Dropbox share links) → the
  `onerror` handler explains that a direct file link is needed.

Attached images also render as thumbnails in the Question Bank rows and in the
dashboard's "Recently updated" list.

**Subject → chapter ribbon.** The blank question editor and both paste entry
routes now share a visible subject-wise chapter ribbon. Choosing a subject
loads its chapter chips; a selected paste chapter is sent to AI and becomes the
default for imported rows whose source does not name a chapter. The chapter
field remains editable for a new or source-specific chapter name.

**All Questions tab.** Every question the app can serve — the reviewed bank and
what teachers generated in the app — filtered by subject and chapter, with a
search box, a Bank/Teacher badge, and thumbnails. Chapter suggestions come from
a live query once a subject is chosen. No migration was needed: the existing
`questions_read` policy already grants `public.is_question_admin()` every row.

## Why the AI prompt changed too

`admin-content`'s `structure` action already returned mixed types, but nothing
told the model how to tell them apart. The non-English branch of the system
instruction now spells out the rule: CQ = stem plus printed ক/খ/গ/ঘ subparts and
marks, MCQ = exactly the printed options, short = `questionText` and an answer
only when the source supplies one. The anti-fabrication clauses (evidence-quoted
`correctIndex`, source-only explanations, no LaTeX) are unchanged.

The deployed single-file bundle in `deployments/content-studio/admin-content.ts`
carries the same change. It is generated JavaScript and esbuild is not
installable in this sandbox, so the identical string was patched into the bundle
and both copies were checked to contain it; the bundle still parses.

## Verification

- `node --test web-admin/tests/*.test.cjs` → 10 passed, 0 failed.
- `node --check` on `studio.js` and on the patched bundle → both parse.
- `sha256sum -c deployments/content-studio/SHA256SUMS` → 8 of 8 OK.
- New browser tests in `web-admin/tests/studio-content.spec.cjs` (5): the Add
  Questions screen is a real tab with a paste box and three formats; All
  Questions lists bank and teacher rows and narrows by chapter; the editor shows
  the picture and flags a non-https URL; a saved image appears on the dashboard;
  English papers are reachable from the content filter.
- `web-admin/tests/english-upload.spec.cjs` now reaches the uploader through the
  content filter instead of the removed tab.
- Playwright cannot run in this sandbox (no `node_modules`, no network for
  `npm ci`), so the browser tests run in CI; results are reported on PR 6.

## Follow-up: the earlier generic Edge Function error

The attached screenshot was from the older website bundle. When AI review
returned a non-2xx response, the Supabase browser SDK exposed only its generic
message, `Edge Function returned a non-2xx status code`, so the actual reason
was hidden. The website now reads the safe response body from the SDK error
context and displays the function name, HTTP status and returned reason. The
`admin-content` function also includes a short non-secret Gemini error detail
when the upstream request is rejected. This does not hide authentication,
quota or configuration failures behind one message anymore.

To receive this fix, redeploy both `content-studio-netlify.zip` and the
`admin-content` function from the matching `content-studio-update.zip`.

## Still open

- The chapter list on All Questions reads up to 1,000 rows for the selected
  subject and de-duplicates client-side. Fine at current volume; a distinct
  query or an index would be the fix if a subject grows past that.
- Upload progress with cancellation, and a distinct save/publish success state,
  remain unimplemented from the previous pass.
- AI classification quality is not asserted by any automated test — it depends
  on a live model call. It has to be checked against real pasted papers.
