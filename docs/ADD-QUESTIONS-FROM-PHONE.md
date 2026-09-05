# Adding questions from your phone

The admin panel needs a computer — it runs a local web server that reads and
writes files in the repo, which a phone cannot do. If you only have a phone,
use GitHub's own web editor instead. No apps, no setup.

There is a dedicated file for this: **`assets/questions/my_questions.json`**.
It starts empty, it is separate from the 15,392 exported questions, and the
app loads it exactly like every other bank file.

---

## Adding a question

**1.** Open this on your phone:

<https://github.com/subornokhan22-collab/SSC/edit/arena/01a06614-ssc/assets/questions/my_questions.json>

**2.** You will see:

```json
[]
```

**3.** Replace it with your question, between the square brackets:

```json
[
{"id":"my_001","type":"mcq","bank":"myQuestions","subjectId":"physics",
 "chapter":"অধ্যায় ৩: বল","source":"original",
 "payload":{"questionText":"নিউটনের দ্বিতীয় সূত্র অনুসারে বল কিসের সমান?",
 "options":["ভর × ত্বরণ","ভর × বেগ","ভর ÷ ত্বরণ","ভর + ত্বরণ"],
 "correctIndex":0,"explanation":"F = ma"}}
]
```

**4.** Tap **Commit changes**.

That is it. The next build includes it.

### Adding more

Separate each question with a comma:

```json
[
{"id":"my_001", ...},
{"id":"my_002", ...}
]
```

The last one has no comma after it. A stray or missing comma is the single
most common mistake — see "If something goes wrong" below.

---

## The three question types

**MCQ** — `correctIndex` is 0 for the first option, 1 for the second, and so
on:

```json
{"id":"my_001","type":"mcq","bank":"myQuestions","subjectId":"physics",
 "chapter":"অধ্যায় ৩: বল","source":"original",
 "payload":{"questionText":"প্রশ্ন?","options":["ক","খ","গ","ঘ"],
 "correctIndex":0,"explanation":"কারণ..."}}
```

**SAQ** — short answer:

```json
{"id":"my_002","type":"saq","bank":"myQuestions","subjectId":"bgs",
 "chapter":"অধ্যায় ১: আমাদের মুক্তিযুদ্ধ","source":"original",
 "payload":{"questionText":"প্রশ্ন?","answer":"উত্তর।","explanation":""}}
```

**CQ** — creative. `marks` is `[1,2,3,4]` normally, or `[2,4,4]` for general
maths, where `questionGh` is left empty:

```json
{"id":"my_003","type":"cq","bank":"myQuestions","subjectId":"biology",
 "chapter":"অধ্যায় ৪: জীবনী শক্তি","source":"original",
 "payload":{"stem":"উদ্দীপক...","questionK":"ক প্রশ্ন","questionKh":"খ প্রশ্ন",
 "questionG":"গ প্রশ্ন","questionGh":"ঘ প্রশ্ন","marks":[1,2,3,4]}}
```

### Rules that matter

- **`id` must be unique** across the whole bank. Prefix yours with `my_` and
  nothing will ever collide.
- **`bank` must be `"myQuestions"`** for everything in this file.
- **`subjectId`** must be one of: `physics`, `chemistry`, `biology`,
  `general_math`, `higher_math`, `ict`, `bangla_1st`, `bangla_2nd`, `bgs`,
  `accounting`, `finance`.
- **`chapter`** must match an existing chapter name exactly, or the question
  will not appear under any chapter.
- Use straight double quotes `"` — not curly quotes. Phone keyboards
  sometimes substitute these; if they do, turn off smart punctuation.

---

## Adding a picture (heart diagram, printed question, etc.)

**1.** Upload the image through GitHub:

<https://github.com/subornokhan22-collab/SSC/upload/arena/01a06614-ssc/assets/question_figures>

Tap **choose your files**, pick the picture, then **Commit changes**.

**2.** Reference it from the question, adding a `figure` block:

```json
{"id":"my_004","type":"mcq","bank":"myQuestions","subjectId":"biology",
 "chapter":"অধ্যায় ৫: খাদ্য, পুষ্টি ও পরিপাক","source":"original",
 "figure":{"kind":"image","imagePath":"heart.png","aspect":1.5,
 "caption":"চিত্র: মানব হৃৎপিণ্ড"},
 "payload":{"questionText":"চিত্রে চিহ্নিত অংশটি কী?",
 "options":["ডান অলিন্দ","বাম নিলয়","ফুসফুসীয় ধমনি","মহাধমনি"],
 "correctIndex":1}}
```

`aspect` is **width ÷ height**. For a 1200×800 picture that is `1.5`. It does
not need to be exact — it only reserves space on the page — but a wrong value
will stretch the picture.

Uploading from a phone skips the panel's automatic black-and-white
conversion, so prepare the image first: papers print in mono, and a colour
photo becomes grey mush. Crop tightly, and if your gallery app has a
"document" or "black and white" filter, apply it before uploading.

---

## Publishing

Committing is publishing — GitHub starts a build automatically and a new APK
appears under Releases in about 9 minutes.

---

## If something goes wrong

The loader is deliberately forgiving. A broken file, a broken question, or a
missing picture is skipped, and everything else still loads — you will never
lose the whole bank to one typo.

That also means a mistake is quiet. **If a question you added does not appear
in the app, the JSON is malformed.** Paste the file into
<https://jsonlint.com> on your phone; it will point at the line.

The usual causes, in order:

1. A missing or extra comma between questions
2. Curly quotes `"` instead of straight quotes `"`
3. A `chapter` name that does not match an existing one exactly

To undo any commit, open the file's **History** on GitHub and revert it.

---

## When to use the computer panel instead

`node tool/admin/server.js` is better when you have a laptop available. It
gives you dropdowns instead of typing subject and chapter names, checks for
duplicates against all 15,392 questions, validates before saving, generates
ids automatically, and converts images to black and white for you.

Use the phone route for one or two questions; use the panel for a batch.
