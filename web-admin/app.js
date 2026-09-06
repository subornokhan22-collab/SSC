'use strict';
/* Tutor's Desk question admin — hosted version.
 *
 * Talks straight to Supabase from the browser. There is no backend of our
 * own, so this can be hosted as static files anywhere and the URL never
 * expires.
 *
 * Everything published here is read by the app's QuestionSync on next
 * launch, so questions reach tutors without an app update.
 */

const SUPABASE_URL = 'https://vxexidxdoghdmzvkvgqk.supabase.co';
const SUPABASE_ANON =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4ZXhpZHhkb2doZG16dmt2Z3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5ODYzMTcsImV4cCI6MjEwMTU2MjMxN30.hp1ZatmQpCXDFClWlOQEpSJhUwh8bfvspWYKXnXcMY4';

const BUCKET = 'question-figures';
const $ = (id) => document.getElementById(id);

const SUBJECTS = {
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
  physics: 'phy', chemistry: 'chem', biology: 'bio', general_math: 'gm',
  higher_math: 'hm', ict: 'ict', bangla_1st: 'b1', bangla_2nd: 'b2',
  bgs: 'bgs', accounting: 'acc', finance: 'fin',
};

let TOKEN = localStorage.getItem('sb_token') || '';
let USER_ID = localStorage.getItem('sb_uid') || '';
let FIGURE = null;
let BATCH = [];
let RAW_BATCH = [];
let IMAGES = [];

// ── helpers ───────────────────────────────────────────────────────────
function escapeHtml(s){
  return String(s).replace(/[&<>"']/g, c =>
    ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

function showMsg(kind, text, items){
  const m = $('msg');
  m.className = 'msg ' + kind;
  m.innerHTML = text + (items && items.length
    ? '<ul>' + items.map(i => `<li>${escapeHtml(i)}</li>`).join('') + '</ul>' : '');
  m.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
}

/** Every REST call to Supabase goes through here. */
async function sb(path, opts = {}){
  const r = await fetch(SUPABASE_URL + path, {
    ...opts,
    headers: {
      apikey: SUPABASE_ANON,
      Authorization: 'Bearer ' + (TOKEN || SUPABASE_ANON),
      'Content-Type': 'application/json',
      ...(opts.headers || {}),
    },
  });
  const text = await r.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch (_) { data = text; }
  if (!r.ok){
    const msg = (data && (data.message || data.error_description || data.error || data.msg))
              || ('HTTP ' + r.status);
    throw new Error(msg);
  }
  return data;
}

// ── auth ──────────────────────────────────────────────────────────────
$('signin').onclick = async () => {
  const email = $('email').value.trim();
  const password = $('pass').value;
  if (!email || !password){
    $('loginMsg').className = 'msg err';
    $('loginMsg').textContent = 'Enter your email and password.';
    return;
  }
  $('signin').disabled = true;
  $('loginBusy').textContent = 'Signing in…';
  try {
    const d = await sb('/auth/v1/token?grant_type=password', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    TOKEN = d.access_token;
    USER_ID = d.user && d.user.id;
    localStorage.setItem('sb_token', TOKEN);
    localStorage.setItem('sb_uid', USER_ID);
    enterApp();
  } catch (e) {
    $('loginMsg').className = 'msg err';
    $('loginMsg').textContent = String(e.message || e);
  } finally {
    $('signin').disabled = false;
    $('loginBusy').textContent = '';
  }
};

$('signout').onclick = () => {
  TOKEN = ''; USER_ID = '';
  localStorage.removeItem('sb_token');
  localStorage.removeItem('sb_uid');
  location.reload();
};

async function enterApp(){
  $('login').classList.add('hide');
  $('app').classList.remove('hide');
  buildSubjects();
  syncTypes();
  renderOptions();
  await loadList();
}

// ── form plumbing ─────────────────────────────────────────────────────
function buildSubjects(){
  for (const [id, name] of Object.entries(SUBJECTS)){
    const o = document.createElement('option');
    o.value = id; o.textContent = name;
    $('subject').appendChild(o);
    const o2 = o.cloneNode(true);
    $('f-subject').appendChild(o2);
  }
}

function renderOptions(n = 4){
  const box = $('options');
  box.innerHTML = '';
  const letters = ['ক','খ','গ','ঘ','ঙ','চ'];
  for (let i = 0; i < n; i++){
    const row = document.createElement('div');
    row.className = 'opt';
    row.innerHTML =
      `<input type="radio" name="correct" value="${i}" ${i === 0 ? 'checked' : ''}>`
      + `<span class="tag">${letters[i]}</span>`
      + `<input type="text" class="opt-text" placeholder="Option ${letters[i]}">`;
    box.appendChild(row);
  }
}

function syncTypes(){
  const t = $('type');
  if (!t.options.length){
    for (const [v, label] of [['mcq','MCQ (বহুনির্বাচনি)'],['saq','SAQ (সংক্ষিপ্ত)'],['cq','CQ (সৃজনশীল)']]){
      const o = document.createElement('option');
      o.value = v; o.textContent = label;
      t.appendChild(o);
    }
  }
  syncFields();
}

function syncFields(){
  const t = $('type').value;
  $('f-question').classList.toggle('hide', t === 'cq');
  $('f-mcq').classList.toggle('hide', t !== 'mcq');
  $('f-saq').classList.toggle('hide', t !== 'saq');
  $('f-cq').classList.toggle('hide', t !== 'cq');
  $('f-expl').classList.toggle('hide', t === 'cq');
}

function clearForm(){
  $('questionText').value = '';
  $('answer').value = '';
  $('explanation').value = '';
  $('stem').value = '';
  for (const k of ['questionK','questionKh','questionG','questionGh']) $(k).value = '';
  renderOptions();
  $('figClear').click();
}

// ── images ────────────────────────────────────────────────────────────
/** Grayscale + contrast stretch, then trim uniform margins. */
function processImage(img, { mono = true, trim = true } = {}){
  const MAX = 1400;
  let w = img.naturalWidth, h = img.naturalHeight;
  if (Math.max(w, h) > MAX){ const k = MAX / Math.max(w, h); w = Math.round(w*k); h = Math.round(h*k); }
  const c = document.createElement('canvas');
  c.width = w; c.height = h;
  const g = c.getContext('2d');
  g.fillStyle = '#fff'; g.fillRect(0, 0, w, h);
  g.drawImage(img, 0, 0, w, h);

  if (mono){
    const d = g.getImageData(0, 0, w, h), p = d.data;
    // Not a 1-bit threshold: that destroys thin lines and Bengali matras.
    for (let i = 0; i < p.length; i += 4){
      const v = 0.299*p[i] + 0.587*p[i+1] + 0.114*p[i+2];
      let o = (v - 128) * 1.45 + 128;
      o = o < 0 ? 0 : o > 255 ? 255 : o;
      if (o > 224) o = 255;
      if (o < 42)  o = 0;
      p[i] = p[i+1] = p[i+2] = o; p[i+3] = 255;
    }
    g.putImageData(d, 0, 0);
  }
  if (!trim) return c;

  const q = g.getImageData(0, 0, w, h).data;
  const LIGHT = 232;
  let top = 0, bot = h - 1, left = 0, right = w - 1;
  const rowBlank = (y) => { for (let x = 0; x < w; x++) if (q[(y*w+x)*4] < LIGHT) return false; return true; };
  const colBlank = (x) => { for (let y = 0; y < h; y++) if (q[(y*w+x)*4] < LIGHT) return false; return true; };
  while (top < bot && rowBlank(top)) top++;
  while (bot > top && rowBlank(bot)) bot--;
  while (left < right && colBlank(left)) left++;
  while (right > left && colBlank(right)) right--;
  const pad = 12;
  top = Math.max(0, top - pad); left = Math.max(0, left - pad);
  bot = Math.min(h - 1, bot + pad); right = Math.min(w - 1, right + pad);
  const cw = right - left + 1, ch = bot - top + 1;
  if (cw < 40 || ch < 40 || (cw === w && ch === h)) return c;
  const c2 = document.createElement('canvas');
  c2.width = cw; c2.height = ch;
  c2.getContext('2d').drawImage(c, left, top, cw, ch, 0, 0, cw, ch);
  return c2;
}

/** Uploads to Supabase Storage and returns a public URL. */
async function uploadCanvas(c, name){
  const blob = await new Promise(r => c.toBlob(r, 'image/png'));
  const safe = name.toLowerCase().replace(/[^a-z0-9._-]+/g, '_').replace(/\.[^.]+$/, '');
  const file = `${safe}-${Date.now()}.png`;
  const r = await fetch(`${SUPABASE_URL}/storage/v1/object/${BUCKET}/${file}`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_ANON,
      Authorization: 'Bearer ' + TOKEN,
      'Content-Type': 'image/png',
    },
    body: blob,
  });
  if (!r.ok) throw new Error('Image upload failed: ' + (await r.text()).slice(0, 120));
  return {
    imagePath: `${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${file}`,
    aspect: Number((c.width / c.height).toFixed(4)),
    width: c.width, height: c.height,
  };
}

$('figFile').onchange = async () => {
  const f = $('figFile').files[0];
  if (!f) return;
  $('saving').textContent = 'Processing…';
  try {
    const img = new Image();
    img.src = URL.createObjectURL(f);
    await img.decode();
    const c = processImage(img, { mono: $('figMono').checked, trim: $('figTrim').checked });
    FIGURE = await uploadCanvas(c, f.name);
    $('figPreview').src = FIGURE.imagePath;
    $('figInfo').textContent = `${FIGURE.width}x${FIGURE.height}px`;
    $('figPreviewWrap').classList.remove('hide');
  } catch (e) {
    showMsg('err', '<b>Could not upload:</b>', [String(e.message || e)]);
  } finally {
    $('saving').textContent = '';
  }
};

$('figClear').onclick = () => {
  FIGURE = null;
  $('figFile').value = '';
  $('figCaption').value = '';
  $('figPreviewWrap').classList.add('hide');
};

// ── publishing ────────────────────────────────────────────────────────
function nextId(subjectId, type, chapter){
  const prefix = ID_PREFIX[subjectId] || subjectId.slice(0, 3);
  const m = /([০-৯0-9]+)/.exec(chapter || '');
  const bn = { '০':0,'১':1,'২':2,'৩':3,'৪':4,'৫':5,'৬':6,'৭':7,'৮':8,'৯':9 };
  let n = 0;
  if (m){ for (const ch of m[1]) n = n * 10 + (bn[ch] ?? Number(ch)); }
  const cc = n ? String(n).padStart(2, '0') : 'x';
  // A timestamp suffix keeps ids unique without asking the server first.
  return `${prefix}_web${cc}_${type}_${Date.now().toString(36)}`;
}

function buildRow(q, common){
  const payload = {};
  if (q.type === 'mcq'){
    payload.questionText = q.questionText;
    payload.options = q.options;
    payload.correctIndex = q.correctIndex;
    if (q.explanation) payload.explanation = q.explanation;
  } else if (q.type === 'saq'){
    payload.questionText = q.questionText;
    payload.answer = q.answer;
    if (q.explanation) payload.explanation = q.explanation;
  } else {
    payload.stem = q.stem;
    payload.questionK = q.questionK;
    payload.questionKh = q.questionKh;
    payload.questionG = q.questionG;
    payload.questionGh = q.questionGh || '';
    payload.marks = q.marks && q.marks.length ? q.marks : (q.questionGh ? [1,2,3,4] : [2,4,4]);
  }
  const row = {
    id: nextId(common.subjectId, q.type, common.chapter),
    type: q.type,
    subject_id: common.subjectId,
    chapter: common.chapter,
    payload,
    source: 'original',
    owner_id: null,          // official content, visible to every tutor
    is_active: true,
  };
  if (q.figure) row.figure = q.figure;
  return row;
}

function validate(q, common){
  const e = [];
  if (!common.subjectId) e.push('Choose a subject.');
  if (!String(common.chapter || '').trim()) e.push('Chapter is required.');
  if (JSON.stringify(q).includes('\uFFFD'))
    e.push('The text contains corrupted characters — re-paste it.');
  if (q.type === 'mcq'){
    if (!String(q.questionText || '').trim()) e.push('Question text is required.');
    const o = (q.options || []).map(x => String(x || '').trim()).filter(Boolean);
    if (o.length < 2) e.push('At least two options are required.');
    if (new Set(o).size !== o.length) e.push('Options must be distinct.');
    if (!Number.isInteger(q.correctIndex) || q.correctIndex < 0 || q.correctIndex >= o.length)
      e.push('Select which option is correct.');
  } else if (q.type === 'saq'){
    if (!String(q.questionText || '').trim()) e.push('Question text is required.');
    if (!String(q.answer || '').trim()) e.push('Answer is required.');
  } else {
    if (!String(q.stem || '').trim()) e.push('Stem is required.');
    if (!String(q.questionK || '').trim()) e.push('Question ক is required.');
  }
  return e;
}

async function publish(rows){
  try {
    return await sb('/rest/v1/questions', {
      method: 'POST',
      headers: { Prefer: 'return=representation' },
      body: JSON.stringify(rows),
    });
  } catch (e) {
    // Row-level security rejects a non-admin trying to publish official
    // content. The raw Postgres wording is opaque, so say what to do.
    const m = String(e.message || e);
    if (/row-level security|violates row-level|42501|permission denied/i.test(m)) {
      throw new Error(
        'This account is not on the publisher list, so it cannot add questions '
        + 'that every tutor sees. Run the "Make yourself an admin" block at the '
        + 'bottom of schema.sql with your email, then sign out and back in.'
      );
    }
    throw e;
  }
}

$('save').onclick = async () => {
  const type = $('type').value;
  const common = { subjectId: $('subject').value, chapter: $('chapter').value.trim() };
  const q = { type };
  if (type === 'mcq'){
    q.questionText = $('questionText').value.trim();
    q.options = [...document.querySelectorAll('.opt-text')].map(i => i.value.trim());
    const picked = document.querySelector('input[name=correct]:checked');
    q.correctIndex = picked ? Number(picked.value) : -1;
    q.explanation = $('explanation').value.trim();
  } else if (type === 'saq'){
    q.questionText = $('questionText').value.trim();
    q.answer = $('answer').value.trim();
    q.explanation = $('explanation').value.trim();
  } else {
    q.stem = $('stem').value.trim();
    for (const k of ['questionK','questionKh','questionG','questionGh']) q[k] = $(k).value.trim();
    q.marks = $('marks').value.split(/[^0-9]+/).filter(Boolean).map(Number);
  }
  if (FIGURE){
    q.figure = { kind: 'image', imagePath: FIGURE.imagePath, aspect: FIGURE.aspect };
    const cap = $('figCaption').value.trim();
    if (cap) q.figure.caption = cap;
  }

  const errs = validate(q, common);
  if (errs.length){ showMsg('err', '<b>Could not publish:</b>', errs); return; }

  $('save').disabled = true;
  $('saving').textContent = 'Publishing…';
  try {
    const out = await publish([buildRow(q, common)]);
    showMsg('ok', `Published <b>${escapeHtml(out[0].id)}</b>. It reaches the app on next launch.`);
    clearForm();
    await loadList();
  } catch (e) {
    showMsg('err', '<b>Could not publish:</b>', [String(e.message || e)]);
  } finally {
    $('save').disabled = false;
    $('saving').textContent = '';
  }
};

$('clear').onclick = clearForm;

// ── Gemini ────────────────────────────────────────────────────────────
const GEMINI_MODELS = [
  'gemini-flash-latest', 'gemini-flash-lite-latest',
  'gemini-2.0-flash', 'gemini-2.0-flash-lite',
];
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

function buildPrompt(type, raw){
  const shape = {
    mcq: '{"type":"mcq","questionText":"...","options":["..","..","..",".."],"correctIndex":0,"explanation":"..."}',
    saq: '{"type":"saq","questionText":"...","answer":"...","explanation":"..."}',
    cq:  '{"type":"cq","stem":"...","questionK":"...","questionKh":"...","questionG":"...","questionGh":"...","marks":[1,2,3,4]}',
  }[type];
  return [
    'You are formatting Bangla SSC exam questions for a database.',
    'The input is raw text pasted from a PDF and may be messy.',
    '',
    'Return ONLY a JSON array. No markdown, no commentary, no code fences.',
    'Each element must match exactly this shape:', shape, '',
    'Rules:',
    '- Split the input into as many separate questions as it contains.',
    '- Keep the Bangla text exactly as written; fix only spacing and line breaks.',
    '- Never invent questions, options or answers that are not in the input.',
    '- correctIndex is 0-based. If the answer is not marked, use 0.',
    '- If a cq has only three parts, leave questionGh empty and use marks [2,4,4].',
    '', 'INPUT:', raw,
  ].join('\n');
}

function extractArray(text){
  let t = String(text || '').replace(/^\s*```(?:json)?/i, '').replace(/```\s*$/, '').trim();
  const a = t.indexOf('['), b = t.lastIndexOf(']');
  if (a >= 0 && b > a) t = t.slice(a, b + 1);
  let p = JSON.parse(t);
  return Array.isArray(p) ? p : [p];
}

function normalizeQuestion(raw, type){
  const q = { ...(raw || {}) };
  for (const k of ['payload','question','data','fields'])
    if (q[k] && typeof q[k] === 'object' && !Array.isArray(q[k])) Object.assign(q, q[k]);
  const pick = (...n) => { for (const x of n){ const v = q[x]; if (typeof v === 'string' && v.trim()) return v.trim(); } return ''; };
  const out = { type: q.type || type };

  if (out.type === 'cq'){
    out.stem = pick('stem','uddipok','passage','questionText','question','text');
    out.questionK = pick('questionK','k','ka');
    out.questionKh = pick('questionKh','kh','kha');
    out.questionG = pick('questionG','g','ga');
    out.questionGh = pick('questionGh','gh','gha');
    let m = q.marks;
    if (typeof m === 'string') m = m.split(/[^0-9]+/).filter(Boolean).map(Number);
    out.marks = Array.isArray(m) && m.length ? m.map(Number) : (out.questionGh ? [1,2,3,4] : [2,4,4]);
    return out;
  }
  out.questionText = pick('questionText','question','text','stem','prompt');
  if (out.type === 'saq'){
    out.answer = pick('answer','ans','correctAnswer','solution');
    const ex = pick('explanation','reason'); if (ex) out.explanation = ex;
    return out;
  }
  let opts = q.options || q.choices || q.answers;
  if (!Array.isArray(opts)){
    const found = [];
    for (const L of ['ক','খ','গ','ঘ','a','b','c','d','A','B','C','D']){
      for (const key of ['option'+L,'opt'+L,L])
        if (typeof q[key] === 'string' && q[key].trim()){ found.push(q[key].trim()); break; }
    }
    opts = found;
  }
  opts = (opts||[]).map(o => typeof o === 'string' ? o.trim()
      : String((o && (o.text ?? o.value ?? o.option ?? o.label)) ?? '').trim())
    .filter(Boolean)
    .map(o => o.replace(/^[\(\[]\s*[ক-ঘa-dA-D1-4]\s*[\)\]]\s*/, '')
                .replace(/^[ক-ঘa-dA-D1-4]\s*[\)\].:]\s+/, '').trim());
  out.options = opts;

  let ci = q.correctIndex ?? q.correct ?? q.answerIndex ?? q.answer;
  if (typeof ci === 'string'){
    const map = {'ক':0,'খ':1,'গ':2,'ঘ':3,'a':0,'b':1,'c':2,'d':3,'A':0,'B':1,'C':2,'D':3,'1':0,'2':1,'3':2,'4':3};
    const t = ci.trim();
    ci = (t in map) ? map[t] : Math.max(0, opts.indexOf(t));
  }
  ci = Number(ci);
  out.correctIndex = Number.isInteger(ci) && ci >= 0 && ci < opts.length ? ci : 0;
  const ex = pick('explanation','reason'); if (ex) out.explanation = ex;
  return out;
}

async function callGemini(model, key, prompt){
  const r = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${encodeURIComponent(key)}`,
    { method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }],
                             generationConfig: { temperature: 0.1, maxOutputTokens: 8192 } }) });
  const d = await r.json().catch(() => ({}));
  if (!r.ok){
    const e = new Error((d.error && d.error.message) || ('HTTP ' + r.status));
    e.transient = [429, 500, 503].includes(r.status);
    throw e;
  }
  const c = (d.candidates || [])[0];
  const text = c && c.content ? (c.content.parts || []).map(p => p.text || '').join('') : '';
  if (!text.trim()) throw new Error('Gemini sent an empty reply — try a smaller batch.');
  return extractArray(text);
}

$('apiKey').value = localStorage.getItem('gemKey') || '';
$('apiKey').onchange = () => localStorage.setItem('gemKey', $('apiKey').value.trim());

$('testKey').onclick = async () => {
  const key = $('apiKey').value.trim();
  if (!key){ showMsg('err', '<b>Paste your API key first.</b>'); return; }
  try {
    const r = await fetch('https://generativelanguage.googleapis.com/v1beta/models?key=' + encodeURIComponent(key));
    const d = await r.json().catch(() => ({}));
    if (r.ok) showMsg('ok', `<b>Connected.</b> ${(d.models || []).length} models available.`);
    else showMsg('err', '<b>Google rejected the key:</b>', [(d.error && d.error.message) || ('HTTP ' + r.status)]);
  } catch (e) {
    showMsg('err', '<b>Could not reach Google.</b>', [String(e.message || e)]);
  }
};

$('formatBtn').onclick = async () => {
  const type = $('type').value;
  const key = $('apiKey').value.trim();
  const raw = $('rawText').value.trim();
  if (!key){ showMsg('err', '<b>Add your Gemini API key first.</b>'); return; }
  if (!raw){ showMsg('err', '<b>Paste some question text first.</b>'); return; }

  $('formatBtn').disabled = true;
  $('fmtStatus').textContent = 'Asking Gemini…';
  const prompt = buildPrompt(type, raw);
  let last = null;
  try {
    for (const model of GEMINI_MODELS){
      for (let attempt = 0; attempt < 2; attempt++){
        try {
          $('fmtStatus').textContent = `Asking ${model}…`;
          RAW_BATCH = await callGemini(model, key, prompt);
          BATCH = RAW_BATCH.map(q => normalizeQuestion(q, type));
          renderBatch();
          showMsg('ok', `Found <b>${BATCH.length}</b> question(s). Check them, then Publish all.`);
          return;
        } catch (e) {
          last = e;
          if (!e.transient) throw e;
          if (attempt === 0) await sleep(1200);
        }
      }
    }
    throw new Error('All Gemini models are busy (' + (last && last.message) + ').');
  } catch (e) {
    showMsg('err', '<b>Could not format:</b>', [String(e.message || e)]);
  } finally {
    $('formatBtn').disabled = false;
    $('fmtStatus').textContent = '';
  }
};

function renderBatch(){
  $('batchList').innerHTML = BATCH.map((q, i) => {
    const t = escapeHtml(q.questionText || q.stem || '');
    let sub = '';
    if (q.options && q.options.length)
      sub = q.options.map((o, n) => `${n === q.correctIndex ? '<b>&#10003; </b>' : ''}${escapeHtml(o)}`).join(' &bull; ');
    else if (q.answer) sub = escapeHtml(q.answer);
    else if (q.questionK){
      const L = ['ক','খ','গ','ঘ'];
      sub = [q.questionK,q.questionKh,q.questionG,q.questionGh]
        .map((x, n) => x ? `${L[n]}) ${escapeHtml(x)}` : '').filter(Boolean).join('<br>');
    }
    const body = (!t && !sub)
      ? `<div class="o" style="color:var(--danger)">Could not read this one:</div>
         <pre style="font-size:11px;white-space:pre-wrap">${escapeHtml(JSON.stringify(RAW_BATCH[i] ?? q)).slice(0,600)}</pre>`
      : `<div class="t"><b>${i+1}.</b> ${t}</div><div class="o">${sub}</div>`;
    return `<div class="qprev">${body}</div>`;
  }).join('');
  $('batchOut').classList.remove('hide');
}

$('batchCancel').onclick = () => { BATCH = []; $('batchOut').classList.add('hide'); };

$('batchSave').onclick = async () => {
  const common = { subjectId: $('subject').value, chapter: $('chapter').value.trim() };
  const rows = [], bad = [];
  BATCH.forEach((q, i) => {
    const e = validate(q, common);
    if (e.length) bad.push(`#${i+1} ${e[0]}`);
    else rows.push(buildRow(q, common));
  });
  if (!rows.length){ showMsg('err', '<b>Nothing valid to publish:</b>', bad); return; }

  $('batchSave').disabled = true;
  $('fmtStatus').textContent = 'Publishing…';
  try {
    const out = await publish(rows);
    let m = `Published <b>${out.length}</b> question(s).`;
    if (bad.length) m += `<br>${bad.length} skipped: ${bad.map(escapeHtml).join('; ')}`;
    showMsg('ok', m);
    BATCH = []; $('batchOut').classList.add('hide'); $('rawText').value = '';
    await loadList();
  } catch (e) {
    showMsg('err', '<b>Could not publish:</b>', [String(e.message || e)]);
  } finally {
    $('batchSave').disabled = false;
    $('fmtStatus').textContent = '';
  }
};

// ── batch images ──────────────────────────────────────────────────────
$('imgFiles').onchange = async () => {
  const files = [...$('imgFiles').files];
  if (!files.length) return;
  IMAGES = []; $('imgGrid').innerHTML = '';
  $('imgBar').classList.remove('hide');
  const bar = $('imgBar').firstElementChild;
  for (let i = 0; i < files.length; i++){
    $('imgStatus').textContent = `Processing ${i+1} of ${files.length}…`;
    bar.style.width = ((i / files.length) * 100) + '%';
    try {
      const img = new Image();
      img.src = URL.createObjectURL(files[i]);
      await img.decode();
      const c = processImage(img, { mono: $('imgMono').checked, trim: $('imgTrim').checked });
      const up = await uploadCanvas(c, files[i].name);
      IMAGES.push(up);
      $('imgGrid').insertAdjacentHTML('beforeend',
        `<div class="thumb"><img src="${up.imagePath}"><div class="nm">${up.width}x${up.height}</div></div>`);
    } catch (e) {
      showMsg('err', `<b>${escapeHtml(files[i].name)} failed:</b>`, [String(e.message || e)]);
    }
  }
  bar.style.width = '100%';
  $('imgStatus').textContent = `${IMAGES.length} ready`;
  $('imgSave').disabled = IMAGES.length === 0;
};

$('imgClear').onclick = () => {
  IMAGES = []; $('imgFiles').value = ''; $('imgGrid').innerHTML = '';
  $('imgBar').classList.add('hide'); $('imgSave').disabled = true; $('imgStatus').textContent = '';
};

$('imgSave').onclick = async () => {
  const common = { subjectId: $('subject').value, chapter: $('chapter').value.trim() };
  const type = $('type').value;
  const stem = $('imgText').value.trim() || 'চিত্রটি লক্ষ কর।';
  const rows = IMAGES.map(im => {
    const q = { type, figure: { kind: 'image', imagePath: im.imagePath, aspect: im.aspect } };
    if (type === 'mcq'){ q.questionText = stem; q.options = ['ক','খ','গ','ঘ']; q.correctIndex = 0; }
    else if (type === 'saq'){ q.questionText = stem; q.answer = 'উত্তর ছবিতে দেওয়া আছে।'; }
    else { q.stem = stem; q.questionK = 'ক'; q.questionKh = 'খ'; q.questionG = 'গ'; q.questionGh = 'ঘ'; q.marks = [1,2,3,4]; }
    return buildRow(q, common);
  });
  if (!common.chapter){ showMsg('err', '<b>Chapter is required.</b>'); return; }

  $('imgSave').disabled = true;
  $('imgStatus').textContent = 'Publishing…';
  try {
    const out = await publish(rows);
    showMsg('ok', `Published <b>${out.length}</b> image question(s).`);
    $('imgClear').click();
    await loadList();
  } catch (e) {
    showMsg('err', '<b>Could not publish:</b>', [String(e.message || e)]);
  } finally {
    $('imgSave').disabled = false;
    $('imgStatus').textContent = '';
  }
};

// ── published list ────────────────────────────────────────────────────
async function loadList(){
  const p = new URLSearchParams();
  p.set('select', 'id,type,subject_id,chapter,payload,updated_at');
  p.set('order', 'updated_at.desc');
  p.set('limit', '50');
  if ($('f-subject').value) p.set('subject_id', 'eq.' + $('f-subject').value);
  if ($('f-type').value) p.set('type', 'eq.' + $('f-type').value);
  const q = $('f-search').value.trim();
  if (q) p.set('or', `(id.ilike.*${q}*,payload->>questionText.ilike.*${q}*)`);

  try {
    const rows = await sb('/rest/v1/questions?' + p.toString(), {
      headers: { Prefer: 'count=exact' },
    });
    $('s-total').textContent = rows.length >= 50 ? '50+' : String(rows.length);
    $('s-shown').textContent = String(rows.length);
    $('list').innerHTML = rows.map(r => {
      const text = (r.payload && (r.payload.questionText || r.payload.stem)) || '';
      return `<div class="q">
        <div class="meta">
          <span class="pill ${r.type}">${r.type}</span>
          <span class="id">${escapeHtml(r.id)}</span>
          <span style="flex:1"></span>
          <button class="danger" data-del="${escapeHtml(r.id)}">delete</button>
        </div>
        <div class="text">${escapeHtml(text).slice(0, 200)}</div>
        <div class="id" style="margin-top:4px">${escapeHtml(r.chapter || '')}</div>
      </div>`;
    }).join('') || '<p class="hint">Nothing published yet.</p>';

    for (const b of document.querySelectorAll('[data-del]')){
      b.onclick = async () => {
        if (!confirm('Delete ' + b.dataset.del + '?')) return;
        try {
          await sb('/rest/v1/questions?id=eq.' + encodeURIComponent(b.dataset.del), { method: 'DELETE' });
          await loadList();
        } catch (e) { showMsg('err', '<b>Delete failed:</b>', [String(e.message || e)]); }
      };
    }
  } catch (e) {
    $('list').innerHTML = `<p class="hint" style="color:var(--danger)">${escapeHtml(String(e.message || e))}</p>`;
  }
}

// ── init ──────────────────────────────────────────────────────────────
for (const b of document.querySelectorAll('.tab')){
  b.onclick = () => {
    for (const x of document.querySelectorAll('.tab')) x.classList.toggle('on', x === b);
    for (const n of ['single','batch','images']) $('pane-' + n).classList.toggle('hide', n !== b.dataset.tab);
    $('msg').className = 'msg';
  };
}
$('type').onchange = syncFields;
$('f-subject').onchange = loadList;
$('f-type').onchange = loadList;
let t = null;
$('f-search').oninput = () => { clearTimeout(t); t = setTimeout(loadList, 250); };
$('pass').onkeydown = (e) => { if (e.key === 'Enter') $('signin').click(); };

if (TOKEN) enterApp();
