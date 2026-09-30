/* Shared, dependency-free validation: hosted UI, local import tool and Node tests. */
(function (root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  else root.ContentCore = api;
})(globalThis, () => {
  "use strict";
  const firstFields = {
    passage1Intro: "text",
    passage1Unit: "optional",
    passage1: "text",
    q1Instr: "text",
    q1: "mcqs",
    q2: "lines",
    q3Instr: "text",
    q3Source: "optional",
    q3Unit: "optional",
    q3Cloze: "text",
    passage2Intro: "text",
    passage2: "text",
    q4Instr: "text",
    q4Table: "table",
    q4BoldRows: "indices",
    q6A: "lines",
    q6B: "lines",
    q6C: "lines",
    q7: "lines",
    q8: "lines",
    q9: "lines",
    q10Instr: "text",
    q10Starter: "text",
    q11: "text",
  };
  const secondFields = {
    headerExtra: "optionalLines",
    q1Box: "lines",
    q1Passage: "text",
    q2: "matching",
    q3Box: "lines",
    q3Passage: "text",
    q4: "transformations",
    q5: "lines",
    q6Passage: "text",
    q7Passage: "text",
    q8Passage: "text",
    q9Text: "text",
    q10: "text",
    q11: "text",
    q12: "text",
  };

  // Keep the board-paper contract in one versioned configuration object. The
  // editor, validator, uploader and provenance tracker all read this map so a
  // future board pattern adds a schema instead of scattering new counts across
  // the UI code.
  const ENGLISH_SCHEMAS = Object.freeze({
    first: Object.freeze({
      version: 1,
      questionCount: 11,
      fixedCounts: Object.freeze({ q1: 7, q2: 5, q7: 8 }),
      fields: firstFields,
    }),
    second: Object.freeze({
      version: 1,
      questionCount: 12,
      fixedCounts: Object.freeze({ q4: 10, q5: 5 }),
      fields: secondFields,
    }),
  });
  const englishSchema = (paper_type) =>
    ENGLISH_SCHEMAS[paper_type] || ENGLISH_SCHEMAS.first;
  function englishProvenance(paper_type, source, data = {}) {
    const schema = englishSchema(paper_type),
      provenance = {};
    const present = (value) =>
      Array.isArray(value)
        ? value.length > 0
        : typeof value === "string"
          ? value.trim().length > 0
          : value != null;
    for (const key of Object.keys(schema.fields))
      if (present(data[key]))
        provenance[key] = { source, verified: false };
    for (let i = 1; i <= schema.questionCount; i++)
      if (present(data.answers?.["q" + i]))
        provenance["answers.q" + i] = { source, verified: false };
    return provenance;
  }
  const labels = {
    passage1Intro: "Reading passage instruction",
    passage1Unit: "Unit / lesson reference",
    passage1: "Reading passage (Q1–Q2)",
    q1Instr: "Q1 instruction",
    q1: "Q1 · Reading comprehension MCQs (7)",
    q2: "Q2 · Comprehension questions (5)",
    q3Instr: "Q3 instruction",
    q3Source: "Q3 source passage / note",
    q3Unit: "Q3 unit / lesson",
    q3Cloze: "Q3 · Cloze passage",
    passage2Intro: "Unseen passage instruction (Q4–Q5)",
    passage2: "Unseen passage",
    q4Instr: "Q4 table instruction",
    q4Table: "Q4 · Information-transfer table",
    q4BoldRows: "Q4 · Bold row indexes (zero-based)",
    q6A: "Q6 · Matching column A",
    q6B: "Q6 · Matching column B",
    q6C: "Q6 · Matching column C",
    q7: "Q7 · Story rearrangement (8)",
    q8: "Q8 · Poem questions",
    q9: "Q9 · Story questions",
    q10Instr: "Q10 · Completing a story: instruction",
    q10Starter: "Q10 · Story starter",
    q11: "Q11 · Dialogue",
    headerExtra: "Additional header lines",
    q1Box: "Q1 · Word box",
    q1Passage: "Q1 · Gap-filling passage",
    q3Box: "Q3 · Verb box",
    q3Passage: "Q3 · Right forms of verbs",
    q4: "Q4 · Sentence transformations (10)",
    q5: "Q5 · Tag questions (5)",
    q6Passage: "Q6 · Prefixes / suffixes (roots in {braces})",
    q7Passage: "Q7 · Prepositions",
    q8Passage: "Q8 · Connectors",
    q9Text: "Q9 · Capitals and punctuation",
    q10: "Q10 · Paragraph",
    q12: "Q12 · Composition",
  };
  const fieldLabel = (key, type) =>
    type === "second" && key === "q2"
      ? "Q2 · Substitution table (a / b / c)"
      : type === "second" && key === "q11"
        ? "Q11 · Letter / application"
        : labels[key] || key;
  const normalize = (s) =>
    String(s ?? "")
      .normalize("NFC")
      .toLowerCase()
      .replace(/[^a-z0-9\u0980-\u09ff]+/g, " ")
      .trim();
  const text = (row) =>
    row.type === "cq" ? row.payload?.stem : row.payload?.questionText;
  function validateQuestion(row) {
    const e = [],
      p = row.payload || {};
    for (const k of ["id", "subject_id", "chapter"])
      if (typeof row[k] !== "string" || !row[k].trim())
        e.push(`${k} is required`);
    if (["english_1st", "english_2nd"].includes(row.subject_id))
      e.push("Use English Papers, not the generic question bank");
    if (JSON.stringify(row).includes("\ufffd"))
      e.push("Corrupted Unicode detected");
    if (row.type === "mcq") {
      if (typeof p.questionText !== "string" || !p.questionText.trim())
        e.push("Question text is required");
      if (
        !Array.isArray(p.options) ||
        p.options.length !== 4 ||
        p.options.some((o) => typeof o !== "string" || !o.trim())
      )
        e.push("Exactly four non-empty options are required");
      else if (new Set(p.options.map(normalize)).size !== 4)
        e.push("Options must be distinct");
      if (
        !Number.isInteger(p.correctIndex) ||
        p.correctIndex < 0 ||
        p.correctIndex > 3
      )
        e.push("Answer not supplied: choose the correct option");
      if (typeof p.explanation !== "string" || !p.explanation.trim())
        e.push("Explanation is required");
    } else if (row.type === "saq") {
      if (
        typeof p.questionText !== "string" ||
        !p.questionText.trim() ||
        typeof p.answer !== "string" ||
        !p.answer.trim()
      )
        e.push("Short-answer text and answer are required");
    } else if (row.type === "cq") {
      if (
        ["stem", "questionK", "questionKh", "questionG"].some(
          (k) => typeof p[k] !== "string" || !p[k].trim(),
        )
      )
        e.push("CQ stimulus and ক/খ/গ are required");
      const marks = JSON.stringify(p.marks);
      if (!(
        (marks === "[2,4,4]" && !p.questionGh) ||
        (marks === "[1,2,3,4]" &&
          typeof p.questionGh === "string" &&
          p.questionGh.trim())
      ))
        e.push("CQ must have 2/4/4 or 1/2/3/4 marks and matching parts");
    } else e.push("Unknown question type");
    if (
      row.figure?.kind === "image" &&
      !/^https:\/\//.test(row.figure.imagePath || "")
    )
      e.push("Figure must have a valid HTTPS image URL");
    return e;
  }
  function englishTemplate(paper_type = "first") {
    const type = ENGLISH_SCHEMAS[paper_type] ? paper_type : "first",
      schema = englishSchema(type),
      fields = schema.fields;
    const data = { schema_version: schema.version, answers: {} };
    for (const [k, t] of Object.entries(fields))
      data[k] = ["text", "optional"].includes(t) ? "" : [];
    for (let i = 1; i <= schema.questionCount; i++)
      data.answers["q" + i] = null;
    return {
      id: "",
      paper_type: type,
      board: "",
      year: new Date().getFullYear(),
      subject: type === "first" ? "english_1st" : "english_2nd",
      data,
      source: "board",
      source_label: "",
      review_status: "draft",
      is_active: true,
    };
  }
  function validateEnglish(row) {
    const errors = [],
      warnings = [];
    if (!["first", "second"].includes(row.paper_type))
      errors.push("Choose First or Second Paper");
    if (!/^[a-zA-Z0-9_-]+$/.test(row.id || ""))
      errors.push("Use a stable ID containing letters, digits, _ or -");
    if (!String(row.board || "").trim()) errors.push("Board is required");
    if (!Number.isInteger(row.year) || row.year < 2000 || row.year > 2100)
      errors.push("Year must be 2000–2100");
    if (
      row.subject !==
      (row.paper_type === "first" ? "english_1st" : "english_2nd")
    )
      errors.push("Subject does not match the paper type");
    const d = row.data || {},
      schema = englishSchema(row.paper_type);
    if (!d.answers || Array.isArray(d.answers) || typeof d.answers !== "object")
      errors.push("Source-answer map is required");
    if (d.schema_version !== schema.version)
      errors.push(`Unsupported English schema version (expected ${schema.version})`);
    for (const [k, t] of Object.entries(schema.fields)) {
      const v = d[k];
      if (["text", "optional"].includes(t)) {
        if (typeof v !== "string" || (t === "text" && !v.trim()))
          errors.push(`${k}: text is required`);
      } else if (!Array.isArray(v)) errors.push(`${k}: must be an array`);
      else if (t === "indices") {
        if (
          v.some(
            (i) =>
              !Number.isInteger(i) || i < 0 || i >= (d.q4Table || []).length,
          )
        )
          errors.push(`${k}: invalid table row index`);
      } else if (t === "optionalLines") {
        if (v.some((x) => typeof x !== "string"))
          errors.push(`${k}: invalid header`);
      } else if (!v.length) errors.push(`${k}: content is missing`);
      else if (
        t === "lines" &&
        v.some((x) => typeof x !== "string" || !x.trim())
      )
        errors.push(`${k}: empty item`);
      else if (
        t === "mcqs" &&
        v.some(
          (x) =>
            typeof x?.stem !== "string" ||
            !x.stem.trim() ||
            !Array.isArray(x.options) ||
            x.options.length !== 4 ||
            x.options.some((o) => typeof o !== "string" || !o.trim()),
        )
      )
        errors.push("Q1 needs stems and four options each");
      else if (
        t === "table" &&
        (v.some(
          (r) =>
            !Array.isArray(r) ||
            r.length !== v[0].length ||
            r.some((c) => typeof c !== "string"),
        ) ||
          !v.flat().some((c) => c.trim()))
      )
        errors.push("Q4 table must be a non-empty rectangular string grid");
      else if (
        t === "matching" &&
        v.some((r) => ["a", "b", "c"].some((c) => typeof r?.[c] !== "string"))
      )
        errors.push("Q2 rows need a, b, c strings (empty cells allowed)");
      else if (
        t === "transformations" &&
        v.some(
          (r) =>
            typeof r?.sentence !== "string" ||
            !r.sentence.trim() ||
            typeof r?.direction !== "string" ||
            !r.direction.trim(),
        )
      )
        errors.push("Q4 needs sentence and direction");
    }
    for (const [k, n] of Object.entries(schema.fixedCounts))
      if (!Array.isArray(d[k]) || d[k].length !== n)
        errors.push(`${k}: expected ${n} items for this board-paper pattern`);
    for (let i = 1; i <= schema.questionCount; i++) {
      const a = d.answers?.["q" + i];
      if (a == null || a === "") warnings.push(`Q${i}: answer not supplied`);
      else if (typeof a !== "string")
        errors.push(`Q${i}: answer must be source text or null`);
    }
    if (JSON.stringify(d).includes("\ufffd"))
      errors.push("Corrupted Unicode detected");
    return { errors, warnings };
  }
  function parseCSV(input) {
    const rows = [];
    let row = [],
      value = "",
      quoted = false;
    for (let i = 0; i < input.length; i++) {
      const c = input[i];
      if (c === '"') {
        if (quoted && input[i + 1] === '"') {
          value += '"';
          i++;
        } else quoted = !quoted;
      } else if (c === "," && !quoted) {
        row.push(value);
        value = "";
      } else if ((c === "\n" || c === "\r") && !quoted) {
        if (c === "\r" && input[i + 1] === "\n") i++;
        row.push(value);
        if (row.some((v) => v.trim())) rows.push(row);
        row = [];
        value = "";
      } else value += c;
    }
    if (quoted) throw Error("Unclosed CSV quote");
    row.push(value);
    if (row.some((v) => v.trim())) rows.push(row);
    if (rows.length < 2) throw Error("CSV needs a header and data");
    const header = rows.shift().map((s) => s.trim().replace(/^\ufeff/, ""));
    return rows.map((values, index) => {
      if (values.length !== header.length)
        throw Error(`CSV row ${index + 2}: wrong column count`);
      return Object.fromEntries(header.map((k, i) => [k, values[i]]));
    });
  }
  function csvQuestions(source) {
    return parseCSV(source).map((r, i) => {
      const type = r.type || "mcq",
        answer = String(r.answer || "")
          .trim()
          .toUpperCase();
      let payload;
      if (type === "mcq")
        payload = {
          questionText: r.question,
          options: ["a", "b", "c", "d"].map((k) => r["option_" + k] || ""),
          correctIndex: ["A", "B", "C", "D"].indexOf(answer),
          explanation: r.explanation || "",
        };
      else if (type === "saq")
        payload = {
          questionText: r.question,
          answer: r.answer || "",
          explanation: r.explanation || "",
        };
      else
        payload = {
          stem: r.question,
          questionK: r.question_k,
          questionKh: r.question_kh,
          questionG: r.question_g,
          questionGh: r.question_gh || "",
          marks: r.question_gh ? [1, 2, 3, 4] : [2, 4, 4],
        };
      return {
        id: r.id || `import_${Date.now()}_${i}`,
        type,
        subject_id: r.subject,
        chapter: r.chapter,
        payload,
        source: r.source || "original",
        review_status: "draft",
        is_active: true,
      };
    });
  }
  function similarity(a, b) {
    const x = new Set(normalize(a).split(" ").filter(Boolean)),
      y = new Set(normalize(b).split(" ").filter(Boolean));
    const union = new Set([...x, ...y]);
    return union.size ? [...x].filter((t) => y.has(t)).length / union.size : 0;
  }
  function duplicates(rows, threshold = 0.8) {
    const hits = [],
      groups = new Map();
    for (const row of rows) {
      const key = row.subject_id + "|" + row.type;
      const group = groups.get(key) || [];
      const normalized = normalize(text(row));
      if (normalized)
        group.push({
          row,
          key: normalized,
          tokens: new Set(normalized.split(" ")),
        });
      groups.set(key, group);
    }
    for (const group of groups.values())
      for (let i = 0; i < group.length; i++)
        for (let j = i + 1; j < group.length; j++) {
          const x = group[i],
            y = group[j];
          if (
            Math.min(x.tokens.size, y.tokens.size) /
              Math.max(x.tokens.size, y.tokens.size) <
            threshold
          )
            continue;
          const intersection = [...x.tokens].filter((t) =>
            y.tokens.has(t),
          ).length;
          const score =
            intersection / (x.tokens.size + y.tokens.size - intersection);
          if (score >= threshold) hits.push({ a: x.row, b: y.row, score });
        }
    return hits;
  }

  function health(rows, english = [], chapters = {}) {
    const issues = [],
      ids = new Set();
    for (const row of rows) {
      if (ids.has(row.id)) issues.push({ id: row.id, message: "Duplicate ID" });
      ids.add(row.id);
      if (
        chapters[row.subject_id]?.length &&
        !chapters[row.subject_id].includes(row.chapter)
      )
        issues.push({
          id: row.id,
          message: "Chapter is not in the current subject catalog",
        });
      for (const message of validateQuestion(row))
        issues.push({ id: row.id, message });
    }
    for (const p of english)
      for (const message of validateEnglish(p).errors)
        issues.push({ id: p.id, english: true, message });
    return { questions: rows.length, english: english.length, issues };
  }
  function draftFromText(raw, type) {
    const row = englishTemplate(type);
    row.year =
      Number(raw.match(/\b(20\d{2})\b/)?.[1]) || new Date().getFullYear();
    row.board =
      raw.match(
        /(Dhaka|Rajshahi|Cumilla|Comilla|Jashore|Jessore|Chattogram|Chittagong|Barishal|Sylhet|Dinajpur|Mymensingh)\s*(?:Board)?/i,
      )?.[1] || "";
    row.id = `english${type === "first" ? 1 : 2}_${row.board.toLowerCase() || "board"}_${row.year}`;
    const parts = [
      ...raw.matchAll(
        /^\s*(\d{1,2})[.)]\s+([\s\S]*?)(?=^\s*\d{1,2}[.)]\s+|$(?![\s\S]))/gm,
      ),
    ];
    const mapped =
      type === "first"
        ? { 3: "q3Cloze", 10: "q10Starter", 11: "q11" }
        : {
            1: "q1Passage",
            3: "q3Passage",
            6: "q6Passage",
            7: "q7Passage",
            8: "q8Passage",
            9: "q9Text",
            10: "q10",
            11: "q11",
            12: "q12",
          };
    for (const m of parts)
      if (mapped[m[1]]) row.data[mapped[m[1]]] = m[2].trim();
    row.data.source_text = raw;
    return row;
  }
  /**
   * One frame of the dashboard count-up: cubic ease-out, integer output, and it
   * can never overshoot the target or report a value the server did not return.
   */
  function countUpFrame(target, elapsedMs, durationMs = 700) {
    const goal = Number(target) || 0;
    if (!(durationMs > 0)) return goal;
    const t = Math.min(1, Math.max(0, (Number(elapsedMs) || 0) / durationMs));
    if (t >= 1) return goal;
    const eased = 1 - Math.pow(1 - t, 3);
    return Math.min(goal, Math.round(goal * eased));
  }

  /**
   * Motion is off when the operating system asks for it or the teacher turned it
   * off in the studio. "reduced" and "full" are explicit choices and win over
   * the system; anything else follows the system.
   */
  function motionReduced(preference, systemPrefersReduced) {
    if (preference === "reduced") return true;
    if (preference === "full") return false;
    return Boolean(systemPrefersReduced);
  }

  /**
   * Supabase and browser APIs do not always throw native Error objects. Keep
   * every safe diagnostic field visible, but never show an empty "Error" or
   * stringify a response object into an unusable message.
   */
  function errorMessage(error, fallback = "The request failed. Try again.") {
    if (typeof error === "string") {
      const text = error.trim();
      return text && text.toLowerCase() !== "error" ? text : fallback;
    }
    const parts = [error?.message, error?.details, error?.hint, error?.code]
      .filter((value) => typeof value === "string" && value.trim())
      .map((value) => value.trim());
    const unique = [...new Set(parts)];
    return unique.length ? unique.join(" · ").slice(0, 1200) : fallback;
  }

  return {
    firstFields,
    secondFields,
    englishSchemas: ENGLISH_SCHEMAS,
    englishProvenance,
    fieldLabel,
    normalize,
    text,
    validateQuestion,
    englishTemplate,
    validateEnglish,
    parseCSV,
    csvQuestions,
    duplicates,
    health,
    draftFromText,
    countUpFrame,
    motionReduced,
    errorMessage,
  };
});
