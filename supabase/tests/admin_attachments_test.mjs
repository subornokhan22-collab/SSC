import { test } from "node:test";
import assert from "node:assert/strict";
import {
  validateAttachments,
  MAX_IMAGE_BYTES,
} from "../functions/admin-content/attachments.ts";
const png = {
  mimeType: "image/png",
  data: Buffer.from("\x89PNG\r\n\x1a\nfixture", "latin1").toString("base64"),
};
test("paper source validator accepts allowed signatures and no attachments", () => {
  assert.deepEqual(validateAttachments(undefined), []);
  assert.deepEqual(validateAttachments([png]), [png]);
});
test("rejects file URLs, SVG, PDFs and spoofed image content", () => {
  for (const value of [
    [{ url: "https://example.com/page.png" }],
    [{ mimeType: "image/svg+xml", data: png.data }],
    [{ mimeType: "application/pdf", data: png.data }],
    [
      {
        ...png,
        data: Buffer.from("<script>alert(1)</script>").toString("base64"),
      },
    ],
  ])
    assert.throws(() => validateAttachments(value));
});
test("rejects invalid base64, non-arrays and excessive page counts", () => {
  for (const value of [
    null,
    {},
    [null],
    Array(11).fill(png),
    [{ ...png, data: "abcd%%%%" }],
    [{ ...png, data: "a" }],
  ])
    assert.throws(() => validateAttachments(value));
});
test("bounds aggregate decoded bytes, not only each page", () => {
  const data = Buffer.alloc(Math.floor(MAX_IMAGE_BYTES / 2) + 12);
  Buffer.from("\x89PNG\r\n\x1a\n", "latin1").copy(data);
  const image = { mimeType: "image/png", data: data.toString("base64") };
  assert.throws(
    () => validateAttachments([image, image]),
    (error) => error.status === 413,
  );
});
