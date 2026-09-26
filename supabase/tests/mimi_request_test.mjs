import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readJsonObject, RequestBodyError } from '../functions/mimi/request_body.ts';

const request = (body, headers = {}) => new Request('https://example.test/mimi', {
  method: 'POST', body, headers,
});

for (const value of [null, [], 'text', 42, true]) {
  test(`rejects non-object JSON: ${JSON.stringify(value)}`, async () => {
    await assert.rejects(readJsonObject(request(JSON.stringify(value))), {
      status: 400, code: 'BAD_REQUEST',
    });
  });
}

test('accepts a chat object and preserves Bengali text', async () => {
  const body = { action: 'chat', text: 'কোষ বিভাজন কী?' };
  assert.deepEqual(await readJsonObject(request(JSON.stringify(body))), body);
});

test('rejects malformed JSON and missing body', async () => {
  await assert.rejects(readJsonObject(request('{')), RequestBodyError);
  await assert.rejects(readJsonObject(request(undefined)), RequestBodyError);
});

test('rejects an oversized declared length', async () => {
  await assert.rejects(readJsonObject(request('{}', { 'Content-Length': '100' }), 20), {
    status: 413, code: 'PAYLOAD_TOO_LARGE',
  });
});

test('rejects oversized bytes even with a false small Content-Length', async () => {
  await assert.rejects(readJsonObject(request('{"text":"long"}', { 'Content-Length': '2' }), 10), {
    status: 413, code: 'PAYLOAD_TOO_LARGE',
  });
});

test('counts UTF-8 bytes rather than characters', async () => {
  const body = '{"text":"কখগ"}';
  await assert.rejects(readJsonObject(request(body), body.length), { status: 413 });
});

test('accepts exactly the byte limit', async () => {
  assert.deepEqual(await readJsonObject(request('{}'), 2), {});
});

test('cancels a chunked stream when it crosses the limit without Content-Length', async () => {
  let cancelled = false;
  const stream = new ReadableStream({
    pull(controller) { controller.enqueue(new Uint8Array(8)); },
    cancel() { cancelled = true; },
  });
  const req = new Request('https://example.test/mimi', {
    method: 'POST', body: stream, duplex: 'half',
  });
  await assert.rejects(readJsonObject(req, 10), { status: 413 });
  assert.equal(cancelled, true);
});
