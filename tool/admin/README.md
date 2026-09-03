# Question Admin Panel

A small web page for adding questions to the bank without editing JSON or
Dart by hand.

## Running it

```bash
node tool/admin/server.js
```

Then open <http://localhost:5055>. No `npm install` — it uses only the Node
standard library, so it works offline.

## What it does

- **Add** MCQ, SAQ and CQ questions through a form, with the subject,
  type and chapter chosen from dropdowns built out of the questions
  already in the bank.
- **Browse and search** all 15,392 questions, filtered by subject and type.
- **Delete** a question by id.

Saving writes straight into `assets/questions/*.json` and updates
`manifest.json`. The Flutter app reads those files on the next build, so a
new question ships with the next release.

## What it checks before saving

- question text / answer / stem is not blank
- MCQs have at least two distinct, non-empty options and a valid answer key
- the question text is not already in the bank (catches accidental repeats)
- ids are unique, and generated automatically in the existing house style
  (`phy_adm03_mcq_001` — subject prefix, chapter number, type, counter)

If anything fails the save is refused and the reasons are listed; nothing
is written.

## Notes

- New questions default to `source: original`. Set a source label such as
  `ঢাকা বোর্ড ২০২৪` when entering board questions.
- General maths CQs use the three-part `2,4,4` mark scheme and leave `ঘ`
  blank; the form allows this.
- `tool/extract_questions.py` and this panel write the same manifest
  format, so they can be used interchangeably.

## Publishing

The panel edits files in the repo. To get questions to users:

```bash
git add assets/questions && git commit -m "content: add questions" && git push
```

CI builds the APK. Making questions appear **without** an app release is
Step 2 in `docs/question-bank-migration.md` (Supabase sync), which is not
built yet.
