const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');

const css = fs.readFileSync(path.join(__dirname, '..', 'studio.css'), 'utf8');
const englishUpload = fs.readFileSync(
  path.join(__dirname, '..', 'english-upload.js'),
  'utf8',
);
const palette = new Set(['#E3F2FD', '#90CAF9', '#2196F3', '#0D47A1']);

function authoredHexColors(source) {
  return new Set(
    source.match(/#[0-9a-f]{3,8}\b/gi)?.map((color) => color.toUpperCase()) || [],
  );
}

test('admin theme uses only the supplied four palette colors', () => {
  assert.deepEqual(authoredHexColors(css), palette);
});

test('admin theme resolves existing semantic tokens to the supplied palette', () => {
  assert.match(css, /--ink:\s*var\(--deep\)/);
  assert.match(css, /--line:\s*var\(--light\)/);
  assert.match(css, /--paper:\s*var\(--pale\)/);
  assert.match(css, /--indigo:\s*var\(--deep\)/);
  assert.doesNotMatch(css, /rgb[a]?\s*\(/i);
  assert.doesNotMatch(css, /\bhsl[a]?\s*\(/i);
});

test('admin image preview reads its canvas color from the palette token', () => {
  assert.match(englishUpload, /getPropertyValue\(["']--pale["']\)/);
  assert.doesNotMatch(englishUpload, /#[0-9a-f]{3,8}\b/i);
});
