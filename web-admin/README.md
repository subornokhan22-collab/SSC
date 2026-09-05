# Hosted question admin

A permanent web panel for publishing questions. Two static files talking
straight to Supabase — no server of our own, so it can be hosted free and
the URL never expires.

**Questions published here reach the app without an app update.**

---

## Setup — about 15 minutes, once

### 1. Create the table

Open the SQL editor:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/sql/new>

Paste the whole of **`schema.sql`** and press **Run**. Safe to run twice.

That creates the `questions` table, its indexes, row-level security, and a
public `question-figures` bucket for pictures.

### 2. Put the panel online

Any static host works. The simplest is Netlify Drop:

1. Go to <https://app.netlify.com/drop>
2. Drag the **`web-admin`** folder onto the page
3. You get a permanent URL like `https://something.netlify.app`

Alternatives: Cloudflare Pages, GitHub Pages, Vercel — all free, all fine.
There is no build step; these are plain files.

### 3. Use it

Open the URL on any device and sign in with **the same email and password
you use in the app**. Publish a question, then reopen the app — it appears.

---

## How the app picks questions up

```
web panel  ──► Supabase questions table
                        │  (only rows newer than last sync)
                        ▼
app launch ──► cached locally ──► merged into the bundled bank
```

* The 15,392 bundled questions still load instantly and work offline.
* On launch the app asks "anything newer than X?" — normally a tiny request
  that returns nothing.
* Anything new is cached, so it survives being offline afterwards.
* Every failure is silent. A paper never fails to generate because the
  network is down.
* A published row whose id matches a bundled one replaces it, so you can
  correct a wrong answer without creating a duplicate.

---

## Security

Row-level security is on from day one:

| Row | Who can read | Who can write |
|---|---|---|
| `owner_id IS NULL` | everyone | admin panel only |
| `owner_id = a user` | that tutor | that tutor |

Everything you publish is written with `owner_id = null`, i.e. official
content for all tutors. The `owner_id` column exists so per-teacher question
banks can be added later without a migration.

The anon key in `app.js` is safe to publish — it is designed to be public,
and RLS is what actually protects the data.

---

## Notes

* **Chapter names must match exactly** what the app uses, e.g.
  `অধ্যায় ৩: কোষ বিভাজন`. The field offers previous entries as suggestions.
* **Check the ✓ marks** on AI-formatted questions before publishing. If your
  source does not mark the answer, the first option is selected rather than
  guessed.
* Images go to Supabase Storage and are referenced by URL, so they are
  fetched on demand rather than bloating the APK.
* Deleting a question here removes it from the server, but a question that
  shipped inside the APK stays until the next release.

---

## The other two routes

* **`tool/admin/`** — the local Node panel. Writes to repo files, needs a
  computer and an app release to publish. Better for bulk work offline.
* **`docs/ADD-QUESTIONS-FROM-PHONE.md`** — GitHub's web editor, no tooling
  at all, also needs a release.

This hosted panel is the only one that publishes without a release.
