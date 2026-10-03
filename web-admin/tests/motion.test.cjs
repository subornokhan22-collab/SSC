const { test } = require("node:test"),
  assert = require("node:assert/strict"),
  C = require("../content-core.js");

test("count-up eases towards the real total and never overshoots", () => {
  assert.equal(C.countUpFrame(120, 0), 0);
  const mid = C.countUpFrame(120, 350);
  assert.ok(mid > 0 && mid < 120, `expected a frame between 0 and 120, got ${mid}`);
  assert.equal(C.countUpFrame(120, 700), 120);
  assert.equal(C.countUpFrame(120, 99999), 120);
  assert.equal(C.countUpFrame(0, 100), 0);
  // A frame that arrives before the clock starts must not display a negative.
  assert.equal(C.countUpFrame(120, -50), 0);
});

test("a count-up with no duration lands on the value the server returned", () => {
  assert.equal(C.countUpFrame(48, 0, 0), 48);
  assert.equal(C.countUpFrame(48, 5000, 0), 48);
});

test("reduced motion is a real preference, not a decoration", () => {
  assert.equal(C.motionReduced("system", true), true);
  assert.equal(C.motionReduced("system", false), false);
  // An explicit choice beats the system in both directions.
  assert.equal(C.motionReduced("reduced", false), true);
  assert.equal(C.motionReduced("full", true), false);
  // Unknown or missing values fall back to the system rather than guessing.
  assert.equal(C.motionReduced("nonsense", true), true);
  assert.equal(C.motionReduced("nonsense", false), false);
  assert.equal(C.motionReduced(undefined, false), false);
});
