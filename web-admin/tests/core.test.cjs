const { test } = require("node:test"),
  assert = require("node:assert/strict"),
  C = require("../content-core.js");
const first = require("./fixtures/english-first.json"),
  second = require("./fixtures/english-second.json");
test("both real English model structures validate without fabricated answers", () => {
  for (const p of [first, second]) {
    const r = C.validateEnglish(p);
    assert.deepEqual(r.errors, []);
    assert.equal(r.warnings.length, p.paper_type === "first" ? 11 : 12);
  }
});
test("broken nested fields are review blockers, not crashes", () => {
  for (const [field, value] of [
    ["q1", [null]],
    ["q4Table", [[5]]],
    ["q4BoldRows", [-1]],
    ["answers", []],
  ]) {
    const p = structuredClone(first);
    p.data[field] = value;
    assert.ok(C.validateEnglish(p).errors.length);
  }
});
test("CSV B maps to second option, blank does not become A", () => {
  const h =
    "subject,chapter,type,question,option_a,option_b,option_c,option_d,answer,explanation\n";
  const row = 'physics,Chapter 1,mcq,"What, exactly?",A,B,C,D,';
  const q = C.csvQuestions(h + row + "B,Source");
  assert.equal(q[0].payload.correctIndex, 1);
  assert.deepEqual(C.validateQuestion(q[0]), []);
  assert.equal(C.csvQuestions(h + row + ",")[0].payload.correctIndex, -1);
  assert.ok(
    C.validateQuestion(C.csvQuestions(h + row + ",")[0]).some((e) =>
      e.includes("Answer not supplied"),
    ),
  );
});
test("CSV quotes, newlines and malformed column counts", () => {
  assert.deepEqual(C.parseCSV('a,b\n"one\ntwo","x""y"'), [
    { a: "one\ntwo", b: 'x"y' },
  ]);
  assert.throws(() => C.parseCSV("a,b\none"));
  assert.throws(() => C.parseCSV('a,b\n"one,two'));
});
test("CQ part/marks consistency and explicit answer rules", () => {
  const row = {
    id: "x",
    type: "cq",
    subject_id: "physics",
    chapter: "Chapter 1",
    payload: {
      stem: "Source",
      questionK: "K",
      questionKh: "Kh",
      questionG: "G",
      marks: [2, 4, 4],
    },
  };
  assert.deepEqual(C.validateQuestion(row), []);
  row.payload.questionGh = "Gh";
  assert.ok(C.validateQuestion(row).length);
  row.payload.marks = [1, 2, 3, 4];
  assert.deepEqual(C.validateQuestion(row), []);
});
test("duplicate suggestions stay within subject and type", () => {
  const make = (id, subject_id = "physics") => ({
    id,
    subject_id,
    type: "saq",
    payload: { questionText: "One source question" },
  });
  assert.equal(
    C.duplicates([make("a"), make("b"), make("c", "biology")]).length,
    1,
  );
});
test("text detection preserves source, no pretend complete paper or answers", () => {
  const text = "Dhaka Board 2024\n1. A source passage\n10. Write a paragraph";
  const p = C.draftFromText(text, "second");
  assert.equal(p.board, "Dhaka");
  assert.equal(p.data.source_text, text);
  assert.equal(p.data.answers.q1, null);
  assert.ok(C.validateEnglish(p).errors.length);
});
