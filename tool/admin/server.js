#!/usr/bin/env node
/**
 * Question admin panel — a small local web app for adding questions
 * without hand-editing JSON.
 *
 * Run:  node tool/admin/server.js
 * Then open the printed URL.
 *
 * It reads and writes assets/questions/*.json directly, keeping the same
 * shape tool/extract_questions.py produces, so the Flutter app picks new
 * questions up on the next build with no other changes.
 *
 * Deliberately dependency-free (node stdlib only) so it works offline and
 * needs no npm install.
 */

'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const https = require('https');

const REPO = path.resolve(__dirname, '..', '..');
const DIR = path.join(REPO, 'assets', 'questions');
const FIG_DIR = path.join(REPO, 'assets', 'question_figures');
const MANIFEST = path.join(DIR, 'manifest.json');
const PORT = process.env.PORT || 5055;

// Which file new questions go into, per subject + type. Mirrors the banks
// created by the migration.
const BANKS = {
  physics: { mcq: 'physics_mcqs', saq: 'physics_saqs', cq: 'physics_cqs' },
  chemistry: { mcq: 'chemistry_mcqs', saq: 'chemistry_saqs', cq: 'chemistry_cqs' },
  biology: { mcq: 'biology_mcqs', saq: 'biology_saqs', cq: 'biology_cqs' },
  general_math: {
    mcq: 'general_math_mcqs',
    saq: 'general_math_saqs',
    cq: 'general_math_cqs',
  },
  ict: { mcq: 'ict_mcqs' },
  bangla_1st: { mcq: 'bangla_1st_mcqs', saq: 'bangla_1st_saqs', cq: 'bangla_1st_cqs' },
  bangla_2nd: { mcq: 'bangla_2nd_mcqs' },
  bgs: { mcq: 'bgs_mcqs', saq: 'bgs_saqs', cq: 'bgs_cqs' },
  // Subjects without a dedicated bank fall back to the shared core files.
  higher_math: { mcq: 'core_mcqs', saq: 'core_saqs', cq: 'core_cqs' },
  accounting: { mcq: 'core_mcqs', saq: 'core_saqs', cq: 'core_cqs' },
  finance: { mcq: 'core_mcqs', saq: 'core_saqs', cq: 'core_cqs' },
};

const SUBJECT_NAMES = {
  physics: 'পদার্থবিজ্ঞান (Physics)',
  chemistry: 'রসায়ন (Chemistry)',
  biology: 'জীববিজ্ঞান (Biology)',
  general_math: 'সাধারণ গণিত (General Math)',
  higher_math: 'উচ্চতর গণিত (Higher Math)',
  ict: 'তথ্য ও যোগাযোগ প্রযুক্তি (ICT)',
  bangla_1st: 'বাংলা ১ম পত্র',
  bangla_2nd: 'বাংলা ২য় পত্র',
  bgs: 'বাংলাদেশ ও বিশ্বপরিচয় (BGS)',
  accounting: 'হিসাববিজ্ঞান (Accounting)',
  finance: 'ফিন্যান্স (Finance)',
};

const ID_PREFIX = {
  physics: 'phy',
  chemistry: 'chem',
  biology: 'bio',
  general_math: 'gm',
  higher_math: 'hm',
  ict: 'ict',
  bangla_1st: 'b1',
  bangla_2nd: 'b2',
  bgs: 'bgs',
  accounting: 'acc',
  finance: 'fin',
};

// ── data helpers ──────────────────────────────────────────────────────

function bankFile(name) {
  return path.join(DIR, `${name}.json`);
}

function readBank(name) {
  const p = bankFile(name);
  if (!fs.existsSync(p)) return [];
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

function writeBank(name, rows) {
  rows.sort((a, b) => a.id.localeCompare(b.id));
  fs.writeFileSync(
    bankFile(name),
    JSON.stringify(rows) + '\n',
    'utf8',
  );
}

function allRows() {
  const manifest = JSON.parse(fs.readFileSync(MANIFEST, 'utf8'));
  const out = [];
  for (const f of manifest.files) {
    const rows = JSON.parse(fs.readFileSync(path.join(DIR, f), 'utf8'));
    for (const r of rows) out.push(r);
  }
  return out;
}

function refreshManifest() {
  const files = fs
    .readdirSync(DIR)
    .filter((f) => f.endsWith('.json') && f !== 'manifest.json')
    .sort();
  const counts = {};
  let total = 0;
  for (const f of files) {
    const n = JSON.parse(fs.readFileSync(path.join(DIR, f), 'utf8')).length;
    counts[f] = n;
    total += n;
  }
  fs.writeFileSync(
    MANIFEST,
    JSON.stringify({ version: 1, files, counts, total }, null, 2) + '\n',
    'utf8',
  );
  return total;
}

/** Chapters actually present per subject, plus every known id. */
function index() {
  const chapters = {};
  const ids = new Set();
  const stems = new Map();
  for (const r of allRows()) {
    (chapters[r.subjectId] ||= new Set()).add(r.chapter);
    ids.add(r.id);
    const text = r.payload.questionText || r.payload.stem || '';
    stems.set(text.trim(), r.id);
  }
  const sorted = {};
  for (const [k, v] of Object.entries(chapters)) {
    sorted[k] = [...v].sort((a, b) => chapterNo(a) - chapterNo(b));
  }
  return { chapters: sorted, ids, stems };
}

const BN = { '০': 0, '১': 1, '২': 2, '৩': 3, '৪': 4, '৫': 5, '৬': 6, '৭': 7, '৮': 8, '৯': 9 };

function chapterNo(s) {
  const m = /(?:অধ্যায়|chapter)\s*([০-৯0-9]+)/i.exec(s);
  if (!m) return 9999;
  let v = 0;
  for (const c of m[1]) {
    const d = BN[c] ?? Number(c);
    if (Number.isNaN(d)) return 9999;
    v = v * 10 + d;
  }
  return v;
}

/** Next free id, e.g. phy_c03_mcq_014 — matches the existing convention. */
function nextId(subjectId, type, chapter, ids) {
  const prefix = ID_PREFIX[subjectId] || subjectId.slice(0, 3);
  const n = chapterNo(chapter);
  const ch = n === 9999 ? 'x' : String(n).padStart(2, '0');
  const base = `${prefix}_adm${ch}_${type}_`;
  let i = 1;
  while (ids.has(base + String(i).padStart(3, '0'))) i++;
  return base + String(i).padStart(3, '0');
}

// ── figure images ─────────────────────────────────────────────────────

/** Reads width/height out of a PNG or JPEG header. No dependencies. */
function imageSize(buf) {
  // PNG: 8-byte signature, then IHDR with width/height as big-endian uint32.
  if (buf.length > 24 && buf.readUInt32BE(0) === 0x89504e47) {
    return { w: buf.readUInt32BE(16), h: buf.readUInt32BE(20), type: 'png' };
  }
  // JPEG: walk the segment markers to the first SOFn frame header.
  if (buf.length > 4 && buf[0] === 0xff && buf[1] === 0xd8) {
    let i = 2;
    while (i < buf.length - 9) {
      if (buf[i] !== 0xff) { i++; continue; }
      const marker = buf[i + 1];
      const len = buf.readUInt16BE(i + 2);
      // SOF0..SOF15, excluding the non-frame markers DHT/JPG/DAC.
      if (marker >= 0xc0 && marker <= 0xcf &&
          marker !== 0xc4 && marker !== 0xc8 && marker !== 0xcc) {
        return { h: buf.readUInt16BE(i + 5), w: buf.readUInt16BE(i + 7), type: 'jpg' };
      }
      i += 2 + len;
    }
  }
  return null;
}

function safeName(name) {
  return String(name || '')
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 60) || 'figure';
}

// ── validation ────────────────────────────────────────────────────────

function validate(body, idx) {
  const errors = [];
  const { type, subjectId, chapter } = body;

  // Refuse text that already contains U+FFFD. That character only appears
  // when bytes were decoded wrongly somewhere upstream, and saving it bakes
  // permanent mojibake into the bank.
  if (JSON.stringify(body).includes('\uFFFD')) {
    errors.push(
      'The text contains corrupted characters (\uFFFD). Re-paste it — do not save.',
    );
  }

  if (!BANKS[subjectId]) errors.push(`Unknown subject "${subjectId}".`);
  else if (!BANKS[subjectId][type]) {
    errors.push(
      `${SUBJECT_NAMES[subjectId] || subjectId} has no ${type.toUpperCase()} bank.`,
    );
  }
  if (!chapter || !chapter.trim()) errors.push('Chapter is required.');

  const payload = {};
  if (type === 'mcq') {
    const q = (body.questionText || '').trim();
    if (!q) errors.push('Question text is required.');
    const options = (body.options || []).map((o) => (o || '').trim());
    if (options.filter(Boolean).length < 2) {
      errors.push('At least two options are required.');
    }
    if (options.some((o) => !o)) errors.push('Options cannot be blank.');
    const uniq = new Set(options.filter(Boolean));
    if (uniq.size !== options.filter(Boolean).length) {
      errors.push('Options must be distinct.');
    }
    const ci = Number(body.correctIndex);
    if (!Number.isInteger(ci) || ci < 0 || ci >= options.length) {
      errors.push('Select which option is correct.');
    }
    if (idx.stems.has(q)) {
      errors.push(`This question already exists (${idx.stems.get(q)}).`);
    }
    payload.questionText = q;
    payload.options = options;
    payload.correctIndex = ci;
    if ((body.explanation || '').trim()) {
      payload.explanation = body.explanation.trim();
    }
  } else if (type === 'saq') {
    const q = (body.questionText || '').trim();
    const a = (body.answer || '').trim();
    if (!q) errors.push('Question text is required.');
    if (!a) errors.push('Answer is required.');
    if (idx.stems.has(q)) {
      errors.push(`This question already exists (${idx.stems.get(q)}).`);
    }
    payload.questionText = q;
    payload.answer = a;
    if ((body.explanation || '').trim()) {
      payload.explanation = body.explanation.trim();
    }
  } else if (type === 'cq') {
    const stem = (body.stem || '').trim();
    if (!stem) errors.push('Stem (উদ্দীপক) is required.');
    if (idx.stems.has(stem)) {
      errors.push(`This stem already exists (${idx.stems.get(stem)}).`);
    }
    payload.stem = stem;
    for (const [key, label] of [
      ['questionK', 'ক'],
      ['questionKh', 'খ'],
      ['questionG', 'গ'],
      ['questionGh', 'ঘ'],
    ]) {
      const v = (body[key] || '').trim();
      if (!v && key !== 'questionGh') {
        errors.push(`Question ${label} is required.`);
      }
      payload[key] = v;
    }
    const marks = String(body.marks || '1,2,3,4')
      .split(',')
      .map((m) => Number(m.trim()))
      .filter((m) => Number.isInteger(m) && m > 0);
    if (!marks.length) errors.push('Marks must be numbers, e.g. 1,2,3,4');
    payload.marks = marks;
  } else {
    errors.push(`Unknown question type "${type}".`);
  }

  return { errors, payload };
}

// ── request handling ──────────────────────────────────────────────────

function json(res, code, obj) {
  const b = Buffer.from(JSON.stringify(obj), 'utf8');
  res.writeHead(code, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': b.length,
  });
  res.end(b);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    // Collect raw bytes and decode ONCE at the end.
    //
    // `data += chunk` converts each chunk to a string on its own, so a
    // multi-byte character split across a chunk boundary is decoded as two
    // invalid fragments and replaced with U+FFFD. Bengali letters are three
    // bytes each, which turned ক্রোমোজোম into ক্<3x U+FFFD>োমোজোম.
    const chunks = [];
    let n = 0;
    req.on('data', (c) => {
      n += c.length;
      if (n > 5e6) { reject(new Error('body too large')); return; }
      chunks.push(c);
    });
    req.on('end', () => {
      try {
        const text = Buffer.concat(chunks).toString('utf8');
        resolve(text ? JSON.parse(text) : {});
      } catch (e) {
        reject(e);
      }
    });
    req.on('error', reject);
  });
}

function readRaw(req, limit = 12e6) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let n = 0;
    req.on('data', (c) => {
      n += c.length;
      if (n > limit) { reject(new Error('Image too large (max 12 MB)')); return; }
      chunks.push(c);
    });
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  const u = url.parse(req.url, true);

  try {
    if (req.method === 'GET' && (u.pathname === '/' || u.pathname === '/index.html')) {
      const html = fs.readFileSync(path.join(__dirname, 'index.html'));
      res.writeHead(200, {
        'Content-Type': 'text/html; charset=utf-8',
        'Content-Length': html.length,
      });
      return res.end(html);
    }

    if (req.method === 'GET' && u.pathname === '/api/meta') {
      const idx = index();
      const subjects = Object.keys(BANKS).map((id) => ({
        id,
        name: SUBJECT_NAMES[id] || id,
        types: Object.keys(BANKS[id]),
        chapters: idx.chapters[id] || [],
      }));
      const manifest = JSON.parse(fs.readFileSync(MANIFEST, 'utf8'));
      // Every chapter that actually has questions, for the Bank filter.
      const allChapters = {};
      for (const [sid, set] of Object.entries(idx.chapters)) {
        allChapters[sid] = set;
      }
      return json(res, 200, { subjects, chapters: allChapters, total: manifest.total });
    }

    if (req.method === 'GET' && u.pathname === '/api/questions') {
      const { subject, type, chapter, q, limit, sort } = u.query;
      let rows = allRows();
      if (subject) rows = rows.filter((r) => r.subjectId === subject);
      if (type) rows = rows.filter((r) => r.type === type);
      if (chapter) rows = rows.filter((r) => r.chapter === chapter);
      if (q) {
        const needle = String(q).toLowerCase();
        rows = rows.filter((r) => {
          const t = (r.payload.questionText || r.payload.stem || '').toLowerCase();
          return t.includes(needle) || r.id.toLowerCase().includes(needle);
        });
      }

      // Newest first by default. Only questions added through this panel carry
      // addedAt; the 15,392 exported from Dart have none, so they sort after
      // anything you have just written — which is what you want to see.
      if (sort !== 'id') {
        rows = rows.slice().sort((a, b) => {
          const x = a.addedAt || '';
          const y = b.addedAt || '';
          if (x && y) return y.localeCompare(x);
          if (x) return -1;
          if (y) return 1;
          return a.id.localeCompare(b.id);
        });
      }

      const total = rows.length;
      const n = Math.min(Number(limit) || 50, 200);
      return json(res, 200, {
        total,
        rows: rows.slice(0, n).map((r) => ({
          id: r.id,
          type: r.type,
          subjectId: r.subjectId,
          chapter: r.chapter,
          source: r.source,
          addedAt: r.addedAt || null,
          text: r.payload.questionText || r.payload.stem || '',
        })),
      });
    }

    if (req.method === 'POST' && u.pathname === '/api/questions') {
      const body = await readBody(req);
      const idx = index();
      const { errors, payload } = validate(body, idx);
      if (errors.length) return json(res, 400, { errors });

      const bank = BANKS[body.subjectId][body.type];
      const id = (body.id || '').trim() || nextId(body.subjectId, body.type, body.chapter, idx.ids);
      if (idx.ids.has(id)) return json(res, 400, { errors: [`Id "${id}" is taken.`] });

      const bankVar = readBank(bank)[0]?.bank || bank;
      const row = {
        id,
        type: body.type,
        bank: bankVar,
        subjectId: body.subjectId,
        chapter: body.chapter.trim(),
        source: body.source || 'original',
        addedAt: new Date().toISOString(),
        payload,
      };
      if ((body.sourceLabel || '').trim()) row.sourceLabel = body.sourceLabel.trim();
      // Whole-question picture (figure, equations and all).
      if (body.figure && body.figure.imagePath) {
        row.figure = {
          kind: 'image',
          imagePath: String(body.figure.imagePath),
          aspect: Number(body.figure.aspect) || 1.4,
        };
        if ((body.figure.caption || '').trim()) {
          row.figure.caption = body.figure.caption.trim();
        }
      }

      const rows = readBank(bank);
      rows.push(row);
      writeBank(bank, rows);
      const total = refreshManifest();

      return json(res, 200, { ok: true, id, bank, total });
    }

    if (req.method === 'POST' && u.pathname === '/api/figure') {
      const buf = await readRaw(req);
      const size = imageSize(buf);
      if (!size) {
        return json(res, 400, {
          errors: ['Only PNG or JPEG images are supported.'],
        });
      }
      fs.mkdirSync(FIG_DIR, { recursive: true });
      const base = safeName(u.query.name || 'figure').replace(/\.(png|jpe?g)$/i, '');
      const ext = size.type === 'png' ? 'png' : 'jpg';
      let file = `${base}.${ext}`;
      let i = 2;
      while (fs.existsSync(path.join(FIG_DIR, file))) file = `${base}-${i++}.${ext}`;
      fs.writeFileSync(path.join(FIG_DIR, file), buf);
      return json(res, 200, {
        ok: true,
        imagePath: file,
        aspect: Number((size.w / size.h).toFixed(4)),
        width: size.w,
        height: size.h,
        bytes: buf.length,
      });
    }

    if (req.method === 'GET' && u.pathname.startsWith('/figure/')) {
      const name = safeName(decodeURIComponent(u.pathname.slice('/figure/'.length)));
      const p2 = path.join(FIG_DIR, name);
      if (!fs.existsSync(p2)) return json(res, 404, { errors: ['not found'] });
      const b = fs.readFileSync(p2);
      res.writeHead(200, {
        'Content-Type': name.endsWith('.png') ? 'image/png' : 'image/jpeg',
        'Content-Length': b.length,
      });
      return res.end(b);
    }

    // Formats raw pasted text into structured questions using Gemini.
    // The key is sent per-request from the browser and never stored here.
    if (req.method === 'POST' && u.pathname === '/api/format') {
      const body = await readBody(req);
      const key = (body.apiKey || '').trim();
      const raw = (body.text || '').trim();
      const type = body.type || 'mcq';
      if (!key) return json(res, 400, { errors: ['Add your Gemini API key first.'] });
      if (!raw) return json(res, 400, { errors: ['Paste some question text first.'] });

      const shape = {
        mcq: '{"type":"mcq","questionText":"...","options":["..","..","..",".."],"correctIndex":0,"explanation":"..."}',
        saq: '{"type":"saq","questionText":"...","answer":"...","explanation":"..."}',
        cq: '{"type":"cq","stem":"...","questionK":"...","questionKh":"...","questionG":"...","questionGh":"...","marks":[1,2,3,4]}',
      }[type];

      const prompt = [
        'You are formatting Bangla SSC exam questions for a database.',
        'The input is raw text pasted from a PDF or book and may be messy:',
        'broken lines, stray numbering, inconsistent option markers (ক) ক. ক- etc.',
        '',
        'Return ONLY a JSON array. No markdown, no commentary, no code fences.',
        'Each element must match exactly this shape:',
        shape,
        '',
        'Rules:',
        '- Split the input into as many separate questions as it contains.',
        '- Keep the Bangla text exactly as written; fix only spacing and line breaks.',
        '- Never invent questions, options or answers that are not in the input.',
        '- correctIndex is 0-based. If the answer is not marked in the input, use 0.',
        '- For cq, ক/খ/গ/ঘ map to questionK/questionKh/questionG/questionGh.',
        '- If a cq has only three parts, leave questionGh as "" and use marks [2,4,4].',
        '- Drop anything that is not part of a question.',
        '',
        'INPUT:',
        raw,
      ].join('\n');

      const payload = JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.1, maxOutputTokens: 8192 },
      });

      const out = await new Promise((resolve) => {
        const r = https.request(
          {
            hostname: 'generativelanguage.googleapis.com',
            path: `/v1beta/models/gemini-flash-latest:generateContent?key=${encodeURIComponent(key)}`,
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Content-Length': Buffer.byteLength(payload),
            },
          },
          (r2) => {
            let d = '';
            r2.on('data', (c) => (d += c));
            r2.on('end', () => resolve({ status: r2.statusCode, body: d }));
          },
        );
        r.on('error', (e) => resolve({ status: 0, body: String(e) }));
        r.write(payload);
        r.end();
      });

      if (out.status !== 200) {
        let msg = `Gemini returned ${out.status}`;
        try {
          const j = JSON.parse(out.body);
          if (j.error && j.error.message) msg = j.error.message;
        } catch (_) {
          if (out.status === 0) {
            // The machine running this server has no route to Google. That is
            // not the user's connection — the browser calls Gemini directly
            // now, and this proxy is only a fallback.
            msg = 'This server cannot reach Gemini. The browser normally '
                + 'calls Google directly; if you see this, both routes are '
                + 'blocked on this network.';
          }
        }
        return json(res, 400, { errors: [msg] });
      }

      let text = '';
      try {
        const j = JSON.parse(out.body);
        text = j.candidates[0].content.parts.map((p) => p.text || '').join('');
      } catch (_) {
        return json(res, 400, { errors: ['Gemini sent an unexpected response.'] });
      }

      // Models often wrap JSON in ```json fences despite instructions.
      text = text.replace(/^\s*```(?:json)?/i, '').replace(/```\s*$/, '').trim();
      const a = text.indexOf('['), b = text.lastIndexOf(']');
      if (a >= 0 && b > a) text = text.slice(a, b + 1);

      let parsed;
      try {
        parsed = JSON.parse(text);
      } catch (_) {
        return json(res, 400, {
          errors: ['Could not read the formatted result. Try a smaller batch.'],
        });
      }
      if (!Array.isArray(parsed)) parsed = [parsed];
      return json(res, 200, { ok: true, questions: parsed });
    }

    // Saves several prepared questions in one go.
    if (req.method === 'POST' && u.pathname === '/api/questions/batch') {
      const body = await readBody(req);
      const list = Array.isArray(body.questions) ? body.questions : [];
      if (!list.length) return json(res, 400, { errors: ['Nothing to save.'] });

      const saved = [], failed = [];
      for (let i = 0; i < list.length; i++) {
        const item = { ...body.common, ...list[i] };
        const idx = index();                       // re-read so ids stay unique
        const { errors, payload } = validate(item, idx);
        if (errors.length) { failed.push({ n: i + 1, errors }); continue; }

        const bank = BANKS[item.subjectId][item.type];
        const id = nextId(item.subjectId, item.type, item.chapter, idx.ids);
        const rows = readBank(bank);
        const row = {
          id,
          type: item.type,
          bank: rows[0] ? rows[0].bank : bank,
          subjectId: item.subjectId,
          chapter: String(item.chapter).trim(),
          source: item.source || 'original',
          addedAt: new Date().toISOString(),
          payload,
        };
        if ((item.sourceLabel || '').trim()) row.sourceLabel = item.sourceLabel.trim();
        if (item.figure && item.figure.imagePath) {
          row.figure = {
            kind: 'image',
            imagePath: String(item.figure.imagePath),
            aspect: Number(item.figure.aspect) || 1.4,
          };
          if ((item.figure.caption || '').trim()) {
            row.figure.caption = item.figure.caption.trim();
          }
        }
        rows.push(row);
        writeBank(bank, rows);
        saved.push(id);
      }
      const total = refreshManifest();
      return json(res, 200, { ok: true, saved, failed, total });
    }

    if (req.method === 'DELETE' && u.pathname.startsWith('/api/questions/')) {
      const id = decodeURIComponent(u.pathname.split('/').pop());
      const manifest = JSON.parse(fs.readFileSync(MANIFEST, 'utf8'));
      for (const f of manifest.files) {
        const name = f.replace(/\.json$/, '');
        const rows = readBank(name);
        const i = rows.findIndex((r) => r.id === id);
        if (i >= 0) {
          rows.splice(i, 1);
          writeBank(name, rows);
          const total = refreshManifest();
          return json(res, 200, { ok: true, total });
        }
      }
      return json(res, 404, { errors: [`No question with id "${id}".`] });
    }

    json(res, 404, { errors: ['Not found'] });
  } catch (e) {
    json(res, 500, { errors: [String(e && e.message ? e.message : e)] });
  }
});

server.listen(PORT, '0.0.0.0', () => {
  const total = JSON.parse(fs.readFileSync(MANIFEST, 'utf8')).total;
  console.log(`Question admin panel running on http://0.0.0.0:${PORT}`);
  console.log(`${total} questions loaded from assets/questions/`);
});
