# Getting questions out of Dart source

**Status:** proposal, nothing built yet
**Decisions locked in:** central bank now but designed so teachers can add their own later; a web admin panel for authoring.

---

## 1. Where we are

| | |
|---|---|
| Questions hardcoded | **15,392** (12,183 MCQ · 2,100 SAQ · 1,109 CQ) |
| Lines in `lib/data/` | **254,539** of 266,631 — **95% of the codebase is data** |
| Largest file | `bangla_2nd_grammar_mcqs.dart`, 72,724 lines |
| Release APK | 75 MB |
| Subjects with content | 8 of 20 declared |

Per subject: bangla_2nd 4,300 · bangla_1st 2,680 · bgs 1,950 · general_math 1,360 · ict 1,200 · physics 1,140 · biology 1,120 · chemistry 964.

Every question is a `const Question(...)` literal spread into `allMCQs` in `questions_data.dart`.

**The cost:** fixing one wrong answer key means editing Dart, recompiling, pushing, ~9 min of CI, and shipping a 75 MB APK to every user. Content changes are locked to the release cycle. That is the actual problem — file size is only a symptom.

### What makes this migration safe

I checked the risky assumptions before writing this:

- **Zero string interpolation** in any question literal — no `${...}`, so the files are pure data and can be machine-parsed reliably.
- **All 16,032 IDs are unique** — no dedup needed, IDs become primary keys as-is.
- **Zero `QuestionFigure` uses** — the image path is declared but unused, so nothing binary to migrate.
- **Only one external `const` consumer** (`extraMCQs`, itself data). Nothing else depends on `allMCQs` being a compile-time constant, so it can become a runtime `List` without breaking call sites.

That last point is what makes Step 1 a drop-in.

### What does *not* fit the standard shape

Beyond `Question` / `ShortQuestion` / `CreativeQuestion` there are bespoke types:

`LiteratureQuestion`, `Bangla2WrittenQuestion`, `EF1McqItem`, `EBMatchRow`, `EBTransformItem`, `EnglishBoardSet`, `EnglishFirstSet`, `FirstPaperAns`, `SecondPaperAns`.

The English files (`english_board_data.dart`, `english_first_data.dart`) are **not pure data** — they contain mixer classes (`EnglishBoardMixer`, `MixedSecondPaper`) with real logic. **These stay in Dart.** Trying to migrate them is how this project turns into a rewrite. Scope Step 1 to the three standard types only: that is 15,392 of the questions and the overwhelming majority of the bulk.

---

## 2. Storage vs. authoring

Two separate problems that get conflated:

1. **Storage** — where questions live
2. **Authoring** — how you type a new one in

Moving to JSON solves storage only; you would still recompile and re-release to publish. Supabase solves both, and it is already in the stack (auth, `profiles`, config wired).

**Target architecture** — the model Anki and Duolingo use:

```
Supabase `questions` table      ← source of truth, edited from the web panel
        │  delta sync (only rows newer than last pull)
        ▼
Local cache on device           ← what the app actually reads
        ▲
Bundled JSON snapshot           ← offline seed, ships in the APK
```

First launch reads the bundled snapshot instantly — works offline, no regression against today's behaviour. In the background the app asks "anything newer than version N?" and pulls only the delta.

**`allMCQs` / `allSAQs` / `allCQs` keep their exact names and types.** `custom_paper_screen.dart`, `question_paper_screen.dart` and every pattern generator are untouched. This is the single most important constraint in the whole plan.

---

## 3. Schema

```sql
create table questions (
  id           text primary key,        -- 'phy_c01_mcq_001' — reuse existing IDs
  type         text not null,           -- 'mcq' | 'saq' | 'cq'
  subject_id   text not null,
  chapter      text not null,
  payload      jsonb not null,          -- type-specific fields
  source       text not null default 'ai',
  source_label text,
  owner_id     uuid references auth.users(id),   -- null = official bank
  is_active    boolean not null default true,
  updated_at   timestamptz not null default now(),
  constraint questions_type_check check (type in ('mcq','saq','cq'))
);

create index on questions (subject_id, chapter) where is_active;
create index on questions (updated_at);
create index on questions (owner_id);
```

**Why `payload` as JSONB:** the three types have different shapes (MCQ needs `options`/`correctIndex`, CQ needs four sub-questions and a marks array). One flexible column beats either three tables or a wide sparse table, and adding a field later — difficulty, year, image URL — needs **no migration**.

```jsonc
// mcq
{ "questionText": "...", "options": ["...","...","...","..."],
  "correctIndex": 1, "explanation": "..." }

// saq
{ "questionText": "...", "answer": "...", "explanation": "..." }

// cq
{ "stem": "...", "questionK": "...", "questionKh": "...",
  "questionG": "...", "questionGh": "...", "marks": [1,2,3,4] }
```

### Row-level security — included from day one

You chose "central bank now, teachers later." `owner_id` and these policies cost nothing today and mean the teacher feature is a UI change, not a migration. Retrofitting RLS onto a populated shared table is genuinely painful; this is the one piece worth building before it is needed.

```sql
alter table questions enable row level security;

-- everyone signed in reads the official bank plus their own
create policy read_official_and_own on questions for select
  using (owner_id is null or owner_id = auth.uid());

-- teachers may only write rows they own
create policy write_own on questions for insert
  with check (owner_id = auth.uid());
create policy update_own on questions for update
  using (owner_id = auth.uid());
```

The official bank (`owner_id is null`) is then writable only via the service key, i.e. the admin panel — a tutor can never edit or delete official content.

---

## 4. Rollout

Three independently shippable steps. Each is safe alone; stop after any one.

### Step 1 — Dart → JSON assets *(no backend, no behaviour change)*

1. A `tool/export_questions.dart` script parses `lib/data/**` with the `analyzer` package (reads the real AST — no regex against 254k lines of Bangla) and writes `assets/questions/{subject}_{type}.json`.
2. A `QuestionBank` loader deserialises the JSON at startup and exposes `allMCQs` / `allSAQs` / `allCQs` with identical names and types.
3. Delete the migrated `lib/data` files. Keep English + Bangla-2nd written, which hold logic.

**Verification gate — the migration is only accepted if:**
- exported count is exactly 15,392, per-subject counts match the table above
- all 16,032 IDs still unique, zero collisions
- a golden test generates a paper from a fixed seed before and after, and the two PDFs are byte-identical

**Gain:** ~250k lines deleted, big drop in compile time and APK size, readable git diffs, no more Dart-escaping Bangla text. Fully offline. Zero risk to users.

### Step 2 — Supabase sync *(publish without a release)*

1. Create the table, apply RLS, upload the Step 1 JSON.
2. Add `syncQuestions()`: send the highest local `updated_at`, receive newer rows, upsert into the local cache.
3. Bundled JSON stays as the offline seed. If the network is down or Supabase is unreachable, the app behaves exactly as it does after Step 1.

Sync runs on launch, non-blocking, failures silent — the app must never wait on the network to build a paper. Cache in SQLite or a JSON file; `shared_preferences` is the wrong tool for 15k rows.

### Step 3 — Web admin panel

Table view with subject/chapter/type filters and search, an editor form, CSV import/export for bulk work, and a soft-delete toggle via `is_active` (never hard-delete — papers may reference a question).

Practical notes: authenticate with Supabase Auth against an `is_admin` flag on `profiles`; a plain Next.js or SvelteKit app on Vercel talking to Supabase directly is enough. CSV import is what makes bulk Bangla entry actually pleasant — draft in Sheets, paste, import.

**Add a `bumpVersion` action** that touches `updated_at` on changed rows so clients pull promptly.

---

## 5. Unrelated things I noticed

- **`lib/data/chemistry/chemistry_bank_test.dart` is an empty file** sitting inside `lib/`. Almost certainly a stray; safe to delete.
- **GitHub releases are still titled "A-Learning APK"** — leftover from the rename, lives in the workflow file.
- **12 of 20 subjects have no questions** (higher_math, english_1st/2nd, religion, agriculture, accounting, finance, …). Worth deciding whether they should be hidden in the picker until populated, so teachers do not hit dead ends.

---

## 6. Recommendation

Do **Step 1 now** even if Steps 2 and 3 wait. It is self-contained, needs no backend decisions, carries no risk to existing users, and removes 95% of the codebase from the compile path. Everything after it becomes easier — including deciding whether you want Supabase at all.

The only genuinely irreversible decision is the schema, and the one part worth building before it is needed is `owner_id` + RLS.
