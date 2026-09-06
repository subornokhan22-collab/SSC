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

// Every chapter that already has questions, per subject, in textbook order.
// Typing these Bengali names by hand is error-prone, and a mismatched name
// means the question silently never shows under any chapter.
const CHAPTERS = {
 "accounting": [
  "অধ্যায় ২: লেনদেন"
 ],
 "bangla_1st": [
  "গদ্য: মানুষ মুহম্মদ (স.)",
  "গদ্য: প্রত্যুপকার",
  "গদ্য: মমতাদি",
  "কবিতা: সেইদিন এই মাঠ",
  "কবিতা: উমর ফারুক",
  "গদ্য: আম-আঁটির ভেঁপু",
  "কবিতা: আমি কোনো আগন্তুক নই",
  "গদ্য: অভাগীর স্বর্গ",
  "কবিতা: রানার",
  "কবিতা: বন্দনা",
  "নাটক: বহিপীর",
  "কবিতা: তোমাকে পাওয়ার জন্য, হে স্বাধীনতা",
  "উপন্যাস: ১৯৭১",
  "গদ্য: উপেক্ষিত শক্তির উদ্বোধন",
  "গদ্য: নিমগাছ",
  "গদ্য: আমাদের নতুন গৌরবগাথা",
  "গদ্য: ফুলের বিবাহ",
  "গদ্য: পল্লিসাহিত্য",
  "কবিতা: বৃষ্টি",
  "গদ্য: প্রবাস বন্ধু",
  "কবিতা: বোশেখ",
  "গদ্য: বই পড়া",
  "কবিতা: প্রাণ",
  "কবিতা: ঝরনার গান",
  "কবিতা: আমার দেশ",
  "গদ্য: নিরীহ বাঙালি",
  "কবিতা: যাব আমি তোমার দেশে",
  "কবিতা: কপোতাক্ষ নদ",
  "কবিতা: অন্ধবধূ",
  "কবিতা: জীবন বিনিময়",
  "গদ্য: একুশের গল্প",
  "গদ্য: শুভা"
 ],
 "bangla_2nd": [
  "পরিচ্ছেদ ৬: স্বরধ্বনি",
  "পরিচ্ছেদ ২১: বিশেষ্য",
  "পরিচ্ছেদ ২৪: যোজক",
  "পরিচ্ছেদ ১৩: সন্ধি",
  "পরিচ্ছেদ ৩: বাংলা ভাষারীতি ও বিভাজন",
  "পরিচ্ছেদ ১৯: সর্বনাম",
  "পরিচ্ছেদ ২০: বিশেষণ",
  "পরিচ্ছেদ ৩৭: উক্তি",
  "পরিচ্ছেদ ২৮: বিভক্তি",
  "পরিচ্ছেদ ৯: ধ্বনিপরিবর্তন",
  "পরিচ্ছেদ ৪: বাগ্‌যন্ত্র",
  "পরিচ্ছেদ ১৭: সংখ্যাবাচক শব্দ",
  "পরিচ্ছেদ ১৪: দ্বিরুক্ত শব্দ",
  "পরিচ্ছেদ ৭: ব্যঞ্জনধ্বনি",
  "পরিচ্ছেদ ১৬: নরবাচক ও নারীবাচক শব্দ",
  "পরিচ্ছেদ ৩০: ক্রিয়ার কাল",
  "পরিচ্ছেদ ৪১: প্রতিশব্দ",
  "পরিচ্ছেদ ৩৪: সরল, জটিল ও যৌগিক বাক্য",
  "পরিচ্ছেদ ৩২: বাক্যের বর্গ",
  "পরিচ্ছেদ ৪২: বিপরীত শব্দ",
  "পরিচ্ছেদ ৩৬: বাচ্য",
  "পরিচ্ছেদ ৪৩: শব্দজোড়",
  "পরিচ্ছেদ ২৭: শব্দ",
  "পরিচ্ছেদ ২৯: ক্রিয়া-বিভক্তি",
  "পরিচ্ছেদ ৮: বর্ণের উচ্চারণ",
  "পরিচ্ছেদ ১৫: শব্দের শ্রেণিবিভাগ",
  "পরিচ্ছেদ ৩১: বাক্যের অংশ ও শ্রেণিবিভাগ",
  "পরিচ্ছেদ ২৫: আবেগ",
  "পরিচ্ছেদ ১৮: পদাশ্রিত নির্দেশক",
  "পরিচ্ছেদ ২৩: অব্যয়",
  "পরিচ্ছেদ ৩৮: যতিচিহ্ন",
  "পরিচ্ছেদ ৩৯: বাগধারা",
  "পরিচ্ছেদ ১: ভাষা ও বাংলা ভাষা",
  "পরিচ্ছেদ ১০: উপসর্গ দিয়ে শব্দ গঠন",
  "পরিচ্ছেদ ৩৩: উদ্দেশ্য ও বিধেয়",
  "পরিচ্ছেদ ২: বাংলা ব্যাকরণ",
  "পরিচ্ছেদ ১১: প্রত্যয় দিয়ে শব্দ গঠন",
  "পরিচ্ছেদ ২৬: অনুসর্গ",
  "পরিচ্ছেদ ৩৫: কারক",
  "পরিচ্ছেদ ১২: সমাস দিয়ে শব্দ গঠন",
  "পরিচ্ছেদ ৫: ধ্বনি ও বর্ণ",
  "পরিচ্ছেদ ৪০: প্রবাদ",
  "পরিচ্ছেদ ২২: ক্রিয়া"
 ],
 "bgs": [
  "অধ্যায় ১: পূর্ব বাংলার আন্দোলন ও জাতীয়তাবাদের উত্থান (১৯৪৭-১৯৭০)",
  "অধ্যায় ২: বাংলাদেশের স্বাধীনতা",
  "অধ্যায় ৩: সৌরজগৎ ও ভূমণ্ডল",
  "অধ্যায় ৪: বাংলাদেশের ভূপ্রকৃতি ও জলবায়ু",
  "অধ্যায় ৫: বাংলাদেশের নদ-নদী ও প্রাকৃতিক সম্পদ",
  "অধ্যায় ৬: রাষ্ট্র, নাগরিকতা ও আইন",
  "অধ্যায় ৭: বাংলাদেশ সরকারের বিভিন্ন অঙ্গ ও প্রশাসন ব্যবস্থা",
  "অধ্যায় ৮: বাংলাদেশের গণতন্ত্র ও নির্বাচন ব্যবস্থা",
  "অধ্যায় ৯: জাতিসংঘ ও বাংলাদেশ",
  "অধ্যায় ১০: জাতীয় সম্পদ ও অর্থনৈতিক ব্যবস্থা",
  "অধ্যায় ১১: অর্থনৈতিক নির্দেশকসমূহ ও বাংলাদেশের অর্থনীতির প্রকৃতি",
  "অধ্যায় ১২: বাংলাদেশ সরকারের অর্থ ও ব্যাংক ব্যবস্থা",
  "অধ্যায় ১৩: বাংলাদেশের পরিবার কাঠামো ও সামাজিকীকরণ",
  "অধ্যায় ১৪: বাংলাদেশের সামাজিক পরিবর্তন",
  "অধ্যায় ১৫: বাংলাদেশের সামাজিক সমস্যা ও প্রতিকার"
 ],
 "biology": [
  "অধ্যায় ১: জীবন পাঠ",
  "অধ্যায় ২: জীবকোষ ও টিস্যু",
  "অধ্যায় ৩: কোষ বিভাজন",
  "অধ্যায় ৪: জীবনীশক্তি",
  "অধ্যায় ৫: খাদ্য, পুষ্টি এবং পরিপাক",
  "অধ্যায় ৬: জীবে পরিবহন",
  "অধ্যায় ৭: গ্যাসীয় বিনিময়",
  "অধ্যায় ৮: রেচন প্রক্রিয়া",
  "অধ্যায় ৯: দৃঢ়তা প্রদান ও চলন",
  "অধ্যায় ১০: সমন্বয়",
  "অধ্যায় ১১: জীবের প্রজনন",
  "অধ্যায় ১২: জীবের বংশগতি ও জৈব অভিব্যক্তি",
  "অধ্যায় ১৩: জীবের পরিবেশ",
  "অধ্যায় ১৪: জীবপ্রযুক্তি"
 ],
 "chemistry": [
  "অধ্যায় ১: রসায়নের ধারণা",
  "অধ্যায় ২: পদার্থের অবস্থা",
  "অধ্যায় ৩: পদার্থের গঠন",
  "অধ্যায় ৪: পর্যায় সারণি",
  "অধ্যায় ৫: রাসায়নিক বন্ধন",
  "অধ্যায় ৬: মোলের ধারণা ও রাসায়নিক গণনা",
  "অধ্যায় ৭: রাসায়নিক বিক্রিয়া",
  "অধ্যায় ৮: রসায়ন ও শক্তি",
  "অধ্যায় ৯: এসিড-ক্ষারক সমতা",
  "অধ্যায় ১০: খনিজ সম্পদ: ধাতু-অধাতু",
  "অধ্যায় ১১: খনিজ সম্পদ: জীবাশ্ম",
  "অধ্যায় ১২: আমাদের জীবনে রসায়ন"
 ],
 "finance": [
  "অধ্যায় ১: অর্থায়ন"
 ],
 "general_math": [
  "অধ্যায় ১: বাস্তব সংখ্যা",
  "অধ্যায় ২: সেট ও ফাংশন",
  "অধ্যায় ৩: বীজগাণিতিক রাশি",
  "অধ্যায় ৪: সূচক ও লগারিদম",
  "অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ",
  "অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ",
  "অধ্যায় ৭: ব্যবহারিক জ্যামিতি",
  "অধ্যায় ৮: বৃত্ত",
  "অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত",
  "অধ্যায় ১০: দূরত্ব ও উচ্চতা",
  "অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত",
  "অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ",
  "অধ্যায় ১৩: সসীম ধারা",
  "অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা",
  "অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য",
  "অধ্যায় ১৬: পরিমিতি",
  "অধ্যায় ১৭: পরিসংখ্যান"
 ],
 "higher_math": [
  "অধ্যায় ১: সেট ও ফাংশন",
  "অধ্যায় ২: বীজগাণিতিক রাশি",
  "অধ্যায় ৭: অসীম ধারা"
 ],
 "ict": [
  "অধ্যায় ১: তথ্য ও যোগাযোগ প্রযুক্তি ও আমাদের বাংলাদেশ",
  "অধ্যায় ২: কম্পিউটার রক্ষণাবেক্ষণ ও সাইবার নিরাপত্তা",
  "অধ্যায় ৩: ইন্টারনেট ও ওয়েব পরিচিতি",
  "অধ্যায় ৪: আমার লেখালেখি ও হিসাব",
  "অধ্যায় ৫: মাল্টিমিডিয়া ও গ্রাফিক্স",
  "অধ্যায় ৬: প্রোগ্রামিংয়ের মাধ্যমে সমস্যার সমাধান"
 ],
 "physics": [
  "অধ্যায় ১ ও ২: পরিমাপ ও গতি",
  "অধ্যায় ১: ভৌত রাশি এবং তাদের পরিমাপ",
  "অধ্যায় ২: গতি",
  "অধ্যায় ২ ও ৫: গতি ও স্থিতিস্থাপকতা",
  "অধ্যায় ৩: বল",
  "অধ্যায় ৪: কাজ, ক্ষমতা ও শক্তি",
  "অধ্যায় ৫: পদার্থের অবস্থা ও চাপ",
  "অধ্যায় ৬: বস্তুর ওপর তাপের প্রভাব",
  "অধ্যায় ৭: তরঙ্গ ও শব্দ",
  "অধ্যায় ৮: আলোর প্রতিফলন",
  "অধ্যায় ৯: আলোর প্রতিসরণ",
  "অধ্যায় ১০: স্থির বিদ্যুৎ",
  "অধ্যায় ১১: চল বিদ্যুৎ",
  "অধ্যায় ১২: বিদ্যুতের চৌম্বক ক্রিয়া",
  "অধ্যায় ১৩: তেজস্ক্রিয়তা ও ইলেকট্রনিকস"
 ]
};

let TOKEN = localStorage.getItem('sb_token') || '';
let REFRESH = localStorage.getItem('sb_refresh') || '';
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
/** Swaps the stored refresh token for a fresh access token.
 *  Supabase access tokens last about an hour, so without this every session
 *  died with "JWT expired" and had to be signed in again by hand. */
async function renewToken(){
  if (!REFRESH) return false;
  const r = await fetch(SUPABASE_URL + '/auth/v1/token?grant_type=refresh_token', {
    method: 'POST',
    headers: { apikey: SUPABASE_ANON, 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: REFRESH }),
  });
  if (!r.ok) return false;
  const d = await r.json().catch(() => null);
  if (!d || !d.access_token) return false;
  TOKEN = d.access_token;
  REFRESH = d.refresh_token || REFRESH;
  localStorage.setItem('sb_token', TOKEN);
  localStorage.setItem('sb_refresh', REFRESH);
  return true;
}

async function sbOnce(path, opts){
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
  return { ok: r.ok, status: r.status, data };
}

async function sb(path, opts = {}){
  let res = await sbOnce(path, opts);

  // An expired token is recoverable: renew and replay the call once, so the
  // work is not lost and no re-login is needed.
  const msg0 = res.data && (res.data.message || res.data.error_description || res.data.msg);
  if (!res.ok && (res.status === 401 || /jwt expired|invalid jwt/i.test(String(msg0 || '')))){
    if (await renewToken()) res = await sbOnce(path, opts);
  }

  if (!res.ok){
    const d = res.data;
    let msg = (d && (d.message || d.error_description || d.error || d.msg))
            || ('HTTP ' + res.status);
    if (/jwt expired|invalid jwt/i.test(msg) || res.status === 401){
      msg = 'Your session expired and could not be renewed. Sign in again.';
    }
    throw new Error(msg);
  }
  return res.data;
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
    REFRESH = d.refresh_token || '';
    localStorage.setItem('sb_token', TOKEN);
    localStorage.setItem('sb_refresh', REFRESH);
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
  TOKEN = ''; REFRESH = ''; USER_ID = '';
  localStorage.removeItem('sb_token');
  localStorage.removeItem('sb_refresh');
  localStorage.removeItem('sb_uid');
  location.reload();
};

async function enterApp(){
  $('login').classList.add('hide');
  $('app').classList.remove('hide');
  buildSubjects();
  syncChapters();
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

/** Fills the chapter dropdown for the chosen subject. */
function syncChapters(){
  const list = CHAPTERS[$('subject').value] || [];
  const sel = $('chapter');
  const keep = sel.value;
  sel.innerHTML = list.length
    ? list.map(c => `<option value="${c.replace(/"/g, '&quot;')}">${c}</option>`).join('')
    : '<option value="">— no chapters yet for this subject —</option>';
  // Keep the choice when it still belongs to the new subject.
  sel.value = list.includes(keep) ? keep : (list[0] || '');
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
  const put = () => fetch(`${SUPABASE_URL}/storage/v1/object/${BUCKET}/${file}`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_ANON,
      Authorization: 'Bearer ' + TOKEN,
      'Content-Type': 'image/png',
    },
    body: blob,
  });
  let r = await put();
  // Uploads bypass sb(), so they need the same expired-token recovery.
  if (r.status === 401 && await renewToken()) r = await put();
  if (!r.ok){
    const body = await r.text();
    // A storage select policy does not grant insert; without the write policy
    // Supabase returns 403 "new row violates row-level security policy".
    if (/row-level security|Unauthorized|403/i.test(body)) {
      throw new Error(
        'Image uploads are not permitted for this account yet. Re-run '
        + 'schema.sql in the Supabase SQL editor — it now adds the storage '
        + 'write policy — then sign out and back in.'
      );
    }
    throw new Error('Image upload failed: ' + body.slice(0, 160));
  }
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
    // Trimmed: a trailing space makes a near-duplicate chapter that the app
    // treats as a different one.
    chapter: String(common.chapter || '').trim(),
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
  const chap = String(common.chapter || '').trim();
  if (!chap) e.push('Chapter is required.');
  else if (common.subjectId){
    const known = CHAPTERS[common.subjectId] || [];
    if (known.length && !known.includes(chap)){
      e.push(
        `"${chap}" is not a chapter of this subject. Pick one from the list, `
        + 'or the question will not appear under any chapter.'
      );
    }
  }
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
      // Each image gets its own question box, so a batch can carry different
      // wording per picture instead of one line repeated across all of them.
      $('imgGrid').insertAdjacentHTML('beforeend',
        `<div class="thumb">
           <img src="${up.imagePath}">
           <div class="nm">${up.width}x${up.height}</div>
           <textarea class="img-q" data-img="${IMAGES.length - 1}" rows="2"
             style="margin-top:6px;font-size:12px;min-height:44px"
             placeholder="Question for this image (optional)"></textarea>
         </div>`);
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
  // Per-image text when given, otherwise the shared default.
  const perImage = {};
  for (const box of document.querySelectorAll('.img-q')){
    const v = box.value.trim();
    if (v) perImage[box.dataset.img] = v;
  }
  const rows = IMAGES.map((im, i) => {
    const text = perImage[String(i)] || stem;
    const q = { type, figure: { kind: 'image', imagePath: im.imagePath, aspect: im.aspect } };
    if (type === 'mcq'){ q.questionText = text; q.options = ['ক','খ','গ','ঘ']; q.correctIndex = 0; }
    else if (type === 'saq'){ q.questionText = text; q.answer = 'উত্তর ছবিতে দেওয়া আছে।'; }
    else { q.stem = text; q.questionK = 'ক'; q.questionKh = 'খ'; q.questionG = 'গ'; q.questionGh = 'ঘ'; q.marks = [1,2,3,4]; }
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
$('subject').onchange = syncChapters;
$('f-subject').onchange = loadList;
$('f-type').onchange = loadList;
let t = null;
$('f-search').oninput = () => { clearTimeout(t); t = setTimeout(loadList, 250); };
$('pass').onkeydown = (e) => { if (e.key === 'Enter') $('signin').click(); };

if (TOKEN) enterApp();
