# Question Admin Panel

A local web app for adding questions to the bank without editing JSON or
Dart by hand.

## Running it

```bash
node tool/admin/server.js
```

Open <http://localhost:5055>. No `npm install` — it uses only the Node
standard library, so it works offline.

## The three tabs

### Single
One question at a time. Subject, chapter and type come from dropdowns built
out of the questions already in the bank. Supports MCQ, SAQ and CQ, plus an
optional image.

### Paste many
Paste a block of raw text — straight from a PDF, with broken lines, stray
numbering and inconsistent `(ক)` / `ক.` / `ক)` markers — and Gemini turns it
into structured questions.

- The API key is stored in your browser only and sent straight to Google;
  it never reaches this server.
- Four models are tried in turn (`gemini-flash-latest`, then the lite and
  pinned 2.0 variants), twice each, so a busy model does not block you.
  A bad key fails immediately rather than retrying.
- Whatever field names the model replies with are normalised before use.
- Nothing is written until you review the preview and press **Save all**.

**Always check the ✓ marks.** If your source does not mark the answer, the
first option is selected rather than guessed.

### Images
Select several pictures at once. Each becomes its own question, for material
with figures or diagrams that cannot be typed.

- **High-contrast black & white** — papers print in mono, so a colour scan
  becomes grey mush. This is a contrast stretch, not a 1-bit threshold, so
  thin diagram lines and Bengali matras survive.
- **Trim blank background edges** — crops the uniform margin around a scan,
  removing desk and shadow borders. It is a margin trim, not subject
  segmentation: it will not cut a figure out of a busy photograph.

## The Bank list

Browse everything in the bank, filtered by subject, chapter, type or a text
search, and delete anything by id.

Questions are shown **newest first** by default, with a green **NEW** badge
on anything added in the last 24 hours. Untick *Newest first* to sort by id
instead. Only questions added through this panel carry an `addedAt` stamp,
so the originals sort after your own work.

## What it checks before saving

- question text, answer or stem is not blank
- MCQs have at least two distinct, non-empty options and a valid answer key
- the question text is not already in the bank
- ids are unique and generated in the existing house style, e.g.
  `bio_adm03_mcq_001` — subject prefix, chapter number, type, counter

A batch validates each entry separately: bad rows come back with reasons
while the good ones still save.

## Publishing

The panel edits files in the repo. To get questions to users:

```bash
git add assets/questions assets/question_figures
git commit -m "content: add questions"
git push
```

CI builds the APK. Making questions appear **without** an app release is
Step 2 in `docs/question-bank-migration.md` (Supabase sync), which is not
built yet.

## No computer?

See `docs/ADD-QUESTIONS-FROM-PHONE.md` — questions can be added from a
phone through GitHub's web editor, with no tooling at all.
