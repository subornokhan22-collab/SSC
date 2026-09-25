import { createClient } from "./vendor/supabase.mjs";
const C = window.ContentCore,
  $ = (id) => document.getElementById(id),
  esc = (s) =>
    String(s ?? "").replace(
      /[&<>"']/g,
      (c) =>
        ({
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          '"': "&quot;",
          "'": "&#39;",
        })[c],
    );
const URL = "https://vxexidxdoghdmzvkvgqk.supabase.co";
const KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4ZXhpZHhkb2doZG16dmt2Z3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5ODYzMTcsImV4cCI6MjEwMTU2MjMxN30.hp1ZatmQpCXDFClWlOQEpSJhUwh8bfvspWYKXnXcMY4";
// Official SDK owns refresh. No JWT or refresh token is persisted to web storage.
for (const key of ["sb_token", "sb_refresh", "sb_uid"])
  localStorage.removeItem(key);
const client = createClient(URL, KEY, {
  auth: {
    persistSession: false,
    autoRefreshToken: true,
    detectSessionInUrl: false,
  },
});
let catalog = await (await fetch("./catalog.json")).json();
const state = {
  demo: false,
  user: null,
  tab: "dashboard",
  page: 0,
  query: "",
  subject: "",
  status: "",
  paperType: "",
  board: "",
  year: "",
  selected: new Set(),
  rows: [],
  total: 0,
  busy: false,
  routeVersion: 0,
};
const nav = [
  ["dashboard", "⌂", "Dashboard"],
  ["questions", "▤", "Question Bank"],
  ["add", "+", "Add Question"],
  ["import", "⇥", "Import Center"],
  ["english", "En", "English Papers"],
  ["figures", "▧", "Figures"],
  ["validation", "✓", "Validation"],
  ["archived", "↶", "Archived"],
  ["activity", "◷", "Activity"],
  ["settings", "⚙", "Settings"],
];
let demoRows = Array.from({ length: 8 }, (_, i) => ({
  id: `demo_physics_${i + 1}`,
  type: "mcq",
  subject_id: "physics",
  chapter: catalog.CHAPTERS.physics[i % 3],
  payload: {
    questionText: [
      "What is the SI unit of force?",
      "Which quantity measures distance per unit time?",
      "What is the SI unit of energy?",
      "Which instrument measures electric current?",
    ][i % 4],
    options: ["Newton", "Metre", "Second", "Kilogram"],
    correctIndex: 0,
    explanation:
      "Demonstration content only. Replace with reviewed source material.",
  },
  source: "original",
  review_status: i < 4 ? "published" : i < 6 ? "review" : "draft",
  is_active: true,
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
  metadata: { difficulty: "medium" },
}));
let demoEnglish = [],
  demoActivity = [];
function notify(message, error = false) {
  $("notice").hidden = false;
  $("notice").className = error ? "error" : "";
  $("notice").textContent = message;
}
async function task(fn) {
  if (state.busy) return;
  state.busy = true;
  document.querySelectorAll("button").forEach((b) => (b.disabled = true));
  try {
    return await fn();
  } catch (e) {
    notify(e.message || String(e), true);
    if ($("editor").open)
      $("editor-errors").textContent = e.message || String(e);
  } finally {
    state.busy = false;
    document.querySelectorAll("button").forEach((b) => (b.disabled = false));
  }
}
function download(name, data, type = "application/json") {
  const url = window.URL.createObjectURL(
    new Blob(
      [
        data instanceof Blob || typeof data === "string"
          ? data
          : JSON.stringify(data, null, 2),
      ],
      { type },
    ),
  );
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  a.click();
  setTimeout(() => window.URL.revokeObjectURL(url), 1000);
}
const tableFor = (english) => (english ? "english_papers" : "questions");
async function all(table, includePrivate = false) {
  if (state.demo)
    return structuredClone(
      table === "questions"
        ? demoRows
        : table === "english_papers"
          ? demoEnglish
          : table === "admin_activity"
            ? demoActivity
            : [],
    );
  const rows = [];
  for (let start = 0; ; start += 500) {
    let query = client.from(table).select("*");
    if (table === "questions" && !includePrivate)
      query = query.is("owner_id", null);
    const { data, error } = await query
      .order(table === "admin_activity" ? "created_at" : "id")
      .range(start, start + 499);
    if (error) throw error;
    rows.push(...data);
    if (data.length < 500) break;
  }
  return rows;
}
function writable(row) {
  const copy = structuredClone(row);
  for (const key of [
    "search_text",
    "created_by",
    "created_at",
    "archived_at",
    "updated_at",
  ])
    delete copy[key];
  return copy;
}
async function save(table, row, previous) {
  const body = writable(row);
  if (!/^[a-zA-Z0-9_-]+$/.test(body.id || ""))
    throw Error("Enter a stable record ID using letters, digits, _ or -.");
  if (state.demo) {
    const pool = table === "questions" ? demoRows : demoEnglish;
    const i = pool.findIndex((x) => x.id === body.id);
    if (!previous && i >= 0)
      throw Error("This ID already exists. Choose a new ID.");
    body.created_at = previous?.created_at || new Date().toISOString();
    body.updated_at = new Date().toISOString();
    if (i >= 0) pool[i] = body;
    else pool.unshift(body);
    demoActivity.unshift({
      record_id: body.id,
      entity: table,
      action: body.review_status,
      created_at: body.updated_at,
      admin_id: "Offline demo",
    });
    return;
  }
  let q = previous
    ? client
        .from(table)
        .update(body)
        .eq("id", previous.id)
        .eq("updated_at", previous.updated_at)
    : client.from(table).insert(body);
  const { data, error } = await q.select();
  if (error) throw error;
  if (!data?.length)
    throw Error(
      "This record changed in another session. Reload before editing.",
    );
}
async function enter(demo = false) {
  state.demo = demo;
  $("login").hidden = true;
  $("app").hidden = false;
  $("mode").textContent = demo ? "OFFLINE DEMO · NOT LIVE" : "ADMIN SESSION";
  $("connection").textContent = demo
    ? "Demo data · never published"
    : "Supabase · authenticated";
  try {
    if (!demo) {
      const rows = await all("content_subjects");
      for (const r of rows) {
        catalog.SUBJECTS[r.id] = r.name;
        catalog.CHAPTERS[r.id] = r.chapters;
      }
    }
  } catch (e) {
    notify(
      "Apply the content-manager migration before publishing: " + e.message,
      true,
    );
  }
  route();
}
$("login-form").onsubmit = (e) => {
  e.preventDefault();
  task(async () => {
    const { data, error } = await client.auth.signInWithPassword({
      email: $("email").value.trim(),
      password: $("password").value,
    });
    $("password").value = "";
    if (error) {
      $("login-error").textContent = error.message;
      return;
    }
    const check = await client.rpc("is_question_admin");
    if (check.error || !check.data) {
      await client.auth.signOut();
      $("login-error").textContent =
        "This account is not a content administrator.";
      return;
    }
    state.user = data.user;
    await enter();
  });
};
$("demo").onclick = () => enter(true);
$("signout").onclick = async () => {
  await client.auth.signOut();
  location.reload();
};
$("quick-add").onclick = () => openEditor(newQuestion());
$("nav").innerHTML = nav
  .map(
    ([id, icon, label]) =>
      `<a href="#${id}" data-nav="${id}"><span class="icon">${icon}</span>${label}</a>`,
  )
  .join("");
window.addEventListener("hashchange", route);
async function route() {
  if ($("app").hidden) return;
  const tab = location.hash.slice(1) || "dashboard";
  if (tab === "add") {
    openEditor(newQuestion());
    location.hash = "questions";
    return;
  }
  state.tab = nav.some((n) => n[0] === tab) ? tab : "dashboard";
  state.page = 0;
  state.query = "";
  state.subject = "";
  state.status = "";
  state.paperType = "";
  state.board = "";
  state.year = "";
  state.selected.clear();
  document
    .querySelectorAll("[data-nav]")
    .forEach((a) => a.classList.toggle("active", a.dataset.nav === state.tab));
  $("page-title").textContent = nav.find((n) => n[0] === state.tab)[2];
  await render();
}
async function render() {
  const version = ++state.routeVersion;
  $("main").innerHTML = '<div class="loading">Loading your content…</div>';
  try {
    const html = await {
      dashboard: dashboard,
      questions: listView,
      english: listView,
      archived: listView,
      import: importView,
      validation: validationView,
      figures: figuresView,
      activity: activityView,
      settings: settingsView,
    }[state.tab]();
    if (version !== state.routeVersion) return;
    $("main").innerHTML = html;
    bind();
  } catch (e) {
    if (version !== state.routeVersion) return;
    $("main").innerHTML =
      '<div class="card empty"><h2>Could not load this workspace</h2><p>' +
      esc(e.message) +
      '</p><p>Check your connection and apply the content-manager SQL migration if this is the first use.</p><button data-action="reload" class="ghost">Try again</button></div>';
    bind();
  }
}
async function count(table, filter) {
  if (state.demo)
    return (table === "questions" ? demoRows : demoEnglish).filter(
      filter || (() => true),
    ).length;
  let q = client.from(table).select("id", { count: "exact", head: true });
  if (table === "questions") q = q.is("owner_id", null);
  if (filter === "published")
    q = q.eq("is_active", true).eq("review_status", "published");
  if (filter === "review")
    q = q.eq("is_active", true).eq("review_status", "review");
  const { count, error } = await q;
  if (error) throw error;
  return count;
}
async function dashboard() {
  let counts, recent;
  if (state.demo) {
    counts = [
      demoRows.filter((r) => r.is_active && r.review_status === "published")
        .length,
      demoRows.filter((r) => r.review_status === "review").length,
      demoEnglish.length,
      Object.keys(catalog.SUBJECTS).length,
    ];
    recent = demoRows.slice(0, 5);
  } else {
    counts = await Promise.all([
      count("questions", "published"),
      count("questions", "review"),
      count("english_papers"),
      Promise.resolve(Object.keys(catalog.SUBJECTS).length),
    ]);
    const r = await client
      .from("questions")
      .select("*")
      .is("owner_id", null)
      .order("updated_at", { ascending: false })
      .limit(5);
    if (r.error) throw r.error;
    recent = r.data;
  }
  return `<div class="intro"><div><h2>Good content starts with a careful review.</h2><p class="muted">Here’s what’s happening in your content studio.</p></div><span class="badge">SSC question bank</span></div><div class="stats">${counts.map((n, i) => `<div class="stat"><span>${["Published questions", "Awaiting review", "English board papers", "Subjects"][i]}</span><strong>${n.toLocaleString()}</strong><small>${[state.demo ? "Demo records only, not your live bank" : "Live server content, not bundled APK totals", "Ready for a human check", "Reading, grammar & writing", "Chapter catalogs available"][i]}</small></div>`).join("")}</div><div class="columns"><section class="card"><div class="card-head"><h2>Recently updated</h2><a href="#questions">View question bank →</a></div>${recent.length ? `<table><thead><tr><th>QUESTION</th><th>TYPE</th><th>STATUS</th></tr></thead><tbody>${recent.map((r) => `<tr><td><div class="truncate">${esc(C.text(r))}</div><small>${esc(r.chapter)}</small></td><td>${r.type.toUpperCase()}</td><td>${badge(r.review_status)}</td></tr>`).join("")}</tbody></table>` : '<p class="empty">Your first saved draft will appear here.</p>'}</section><section class="card"><h2>Quick actions</h2>${[
    ["+", "Add a question", "Start with a draft", "add"],
    [
      "⇥",
      "Import a question bank",
      "CSV, JSON or pasted source text",
      "import",
    ],
    [
      "En",
      "Import an English paper",
      "A complete board paper, not one MCQ",
      "english",
    ],
    [
      "✓",
      "Check bank health",
      "Find missing fields and duplicates",
      "validation",
    ],
  ]
    .map(
      ([icon, title, sub, tab]) =>
        `<a class="quick" href="#${tab}"><span class="quick-icon">${icon}</span><span><strong>${title}</strong><p>${sub}</p></span><span class="arrow">↗</span></a>`,
    )
    .join(
      "",
    )}</section></div><div class="banner"><span class="quick-icon">En</span><div><h3>A dedicated home for English papers</h3><p>Keep passages, tables and writing tasks together. Missing answers stay clearly marked.</p></div><button class="ghost" data-action="new-english">Open English editor →</button></div>`;
}
const badge = (s) => `<span class="badge ${esc(s)}">${esc(s)}</span>`;
function options(object, value, allLabel = "All") {
  return (
    `<option value="">${allLabel}</option>` +
    Object.entries(object)
      .map(
        ([k, v]) =>
          `<option value="${esc(k)}" ${k === value ? "selected" : ""}>${esc(v)}</option>`,
      )
      .join("")
  );
}
function englishMode() {
  return (
    state.tab === "english" ||
    (state.tab === "archived" && state.paperType === "english")
  );
}
async function listView() {
  const english = englishMode(),
    archived = state.tab === "archived";
  let rows, total;
  if (state.demo) {
    rows = (english ? demoEnglish : demoRows).filter(
      (r) =>
        r.is_active !== archived &&
        (!state.subject || r.subject_id === state.subject) &&
        (!state.status || r.review_status === state.status) &&
        (!state.query ||
          JSON.stringify(r)
            .toLowerCase()
            .includes(state.query.toLowerCase())) &&
        (!state.board || r.board === state.board) &&
        (!state.year || r.year === Number(state.year)) &&
        (!state.paperType || archived || r.paper_type === state.paperType),
    );
    total = rows.length;
    rows = rows.slice(state.page * 25, state.page * 25 + 25);
  } else {
    let q = client
      .from(tableFor(english))
      .select("*", { count: "exact" })
      .eq("is_active", !archived);
    if (!english) q = q.is("owner_id", null);
    if (state.query)
      q = q.ilike(
        "search_text",
        "%" + state.query.replace(/[\\%_]/g, "\\$&") + "%",
      );
    if (state.status) q = q.eq("review_status", state.status);
    if (!english && state.subject) q = q.eq("subject_id", state.subject);
    if (english && !archived && state.paperType)
      q = q.eq("paper_type", state.paperType);
    if (english && state.board)
      q = q.ilike("board", state.board.replace(/[\\%_]/g, "\\$&"));
    if (english && state.year) q = q.eq("year", Number(state.year));
    const r = await q.order("id").range(state.page * 25, state.page * 25 + 24);
    if (r.error) throw r.error;
    rows = r.data;
    total = r.count;
  }
  state.rows = rows;
  state.total = total;
  return `<div class="intro"><p class="muted">${english ? "Complete English board sets with their own structure and app sync." : archived ? "Archived content stays recoverable. Restore it or back it up before permanent deletion." : "Draft → Review → Published. Every change has an audit trail."}</p>${english ? '<button class="primary" data-action="new-english">+ Import / add English paper</button>' : ""}</div><div class="filters"><label class="search">SEARCH ALL CONTENT<input id="search" value="${esc(state.query)}" placeholder="Question, CQ subpart, answer, ID…"></label>${archived ? `<label>CONTENT<select id="archive-type">${options({ questions: "Questions", english: "English papers" }, state.paperType, "Questions")}</select></label>` : ""}${english ? `<label>PAPER<select id="paper-filter">${options({ first: "English 1st", second: "English 2nd" }, archived ? "" : state.paperType)}</select></label><label>BOARD<input id="board-filter" value="${esc(state.board)}" placeholder="e.g. Dhaka"></label><label>YEAR<input id="year-filter" type="number" value="${esc(state.year)}" placeholder="All years"></label>` : `<label>SUBJECT<select id="subject-filter">${options(catalog.SUBJECTS, state.subject, "All subjects")}</select></label>`}<label>WORKFLOW<select id="status-filter">${options({ draft: "Draft", review: "In review", published: "Published" }, state.status, "All statuses")}</select></label><button class="ghost" data-action="filter">Apply</button></div><div class="toolbar"><button class="ghost small" data-action="export-all">Export all ${english ? "English papers" : "questions"}</button><button class="ghost small" data-action="export-subject">Export subject / chapter</button><button class="ghost small" data-action="export-selected">Export selected</button><button class="ghost small" data-action="paper-preview">Preview selected paper</button><button class="ghost small" data-action="bulk-publish">Publish selected reviewed</button><button class="ghost small" data-action="bulk-archive">Back up & ${archived ? "restore" : "archive"} selected</button><span class="muted">${state.selected.size} selected</span></div><div class="table-wrap"><table><thead><tr><th><input id="select-page" type="checkbox" aria-label="Select this page"></th><th>${english ? "BOARD PAPER" : "QUESTION / CHAPTER"}</th><th>${english ? "YEAR" : "TYPE"}</th><th>STATUS</th><th>ACTIONS</th></tr></thead><tbody>${rows.map((r) => `<tr><td><input type="checkbox" data-select="${esc(r.id)}" ${state.selected.has(r.id) ? "checked" : ""} aria-label="Select ${esc(r.id)}"></td><td class="title-cell"><div class="truncate">${esc(english ? r.board + " · English " + (r.paper_type === "first" ? "1st" : "2nd") : C.text(r))}</div><small>${esc(r.id)}${english ? "" : " · " + esc(r.chapter)}</small></td><td>${english ? r.year : esc(r.type.toUpperCase())}</td><td>${badge(r.review_status)}</td><td class="actions">${archived ? `<button class="ghost small" data-row="${esc(r.id)}" data-action="restore">Restore</button><button class="danger small" data-row="${esc(r.id)}" data-action="delete">Delete permanently</button>` : `<button class="ghost small" data-row="${esc(r.id)}" data-action="edit">Edit</button><button class="ghost small" data-row="${esc(r.id)}" data-action="duplicate">Duplicate</button><button class="ghost small" data-row="${esc(r.id)}" data-action="preview">Preview</button><button class="ghost small" data-row="${esc(r.id)}" data-action="${r.review_status === "draft" ? "review" : "publish"}">${r.review_status === "draft" ? "Submit for review" : r.review_status === "review" ? "Publish" : "Review again"}</button><button class="link small" data-row="${esc(r.id)}" data-action="archive">Archive</button>`}</td></tr>`).join("")}</tbody></table>${rows.length ? "" : '<div class="empty">No matching content. Try another filter or create a draft.</div>'}</div><div class="pager"><span>${total.toLocaleString()} matching records · Showing ${rows.length ? state.page * 25 + 1 : 0}–${state.page * 25 + rows.length}</span><span><button class="ghost small" data-action="prev">← Previous</button> <span>Page ${state.page + 1} of ${Math.max(1, Math.ceil(total / 25))}</span> <button class="ghost small" data-action="next">Next →</button></span></div>`;
}
function newQuestion() {
  return {
    id: "q_" + crypto.randomUUID().slice(0, 12),
    type: "mcq",
    subject_id: "physics",
    chapter: catalog.CHAPTERS.physics[0],
    payload: {
      questionText: "",
      options: ["", "", "", ""],
      correctIndex: null,
      explanation: "",
    },
    source: "original",
    source_label: "",
    metadata: {
      difficulty: "medium",
      topic: "",
      tags: [],
      source_board: "",
      source_year: null,
      verified: false,
    },
    review_status: "draft",
    is_active: true,
    owner_id: null,
  };
}
let editing = null,
  previous = null,
  editingEnglish = false,
  parseErrors = new Map();
function input(label, key, value, type = "text") {
  return `<label>${esc(label)}<input data-field="${key}" type="${type}" value="${esc(value)}"></label>`;
}
function area(label, key, value, json = false) {
  return `<label class="wide">${esc(label)}${json ? " · JSON structure" : ""}<textarea data-field="${key}" ${json ? 'data-json="true"' : ""}>${esc(json ? JSON.stringify(value, null, 2) : value)}</textarea></label>`;
}
function englishField(k, t, d) {
  const label = C.fieldLabel(k, editing.paper_type),
    v = d[k];
  if (["text", "optional"].includes(t))
    return area(label, "data." + k, v || "");
  if (["lines", "optionalLines"].includes(t))
    return area(
      label + " · one item per line",
      "data." + k,
      (v || []).join("\n"),
    ).replace("<textarea ", '<textarea data-lines="true" ');
  if (t === "indices") return area(label, "data." + k, v || [], true);
  if (!Array.isArray(d[k]) || !d[k].length)
    d[k] =
      t === "mcqs"
        ? Array.from({ length: 7 }, () => ({
            stem: "",
            options: ["", "", "", ""],
          }))
        : t === "transformations"
          ? Array.from({ length: 10 }, () => ({ sentence: "", direction: "" }))
          : t === "matching"
            ? Array.from({ length: 5 }, () => ({ a: "", b: "", c: "" }))
            : Array.from({ length: 2 }, () => ["", "", ""]);
  let html = '<section class="wide structured"><h3>' + esc(label) + "</h3>";
  for (const [i, row] of d[k].entries()) {
    html += '<div class="form-grid">';
    if (t === "mcqs") {
      html += area(
        "Item " + (i + 1) + " · question",
        "data." + k + "." + i + ".stem",
        row.stem,
      );
      for (let j = 0; j < 4; j++)
        html += input(
          "Option " + (j + 1),
          "data." + k + "." + i + ".options." + j,
          row.options?.[j] || "",
        );
    } else if (t === "transformations")
      html +=
        input(
          "Sentence " + (i + 1),
          "data." + k + "." + i + ".sentence",
          row.sentence,
        ) +
        input("Direction", "data." + k + "." + i + ".direction", row.direction);
    else if (t === "matching")
      for (const col of ["a", "b", "c"])
        html += input(
          "Row " + (i + 1) + " · " + col.toUpperCase(),
          "data." + k + "." + i + "." + col,
          row[col],
        );
    else if (Array.isArray(row))
      for (let j = 0; j < row.length; j++)
        html += input(
          "Row " + (i + 1) + " · column " + (j + 1),
          "data." + k + "." + i + "." + j,
          row[j],
        );
    html += "</div>";
  }
  if (t === "table" || t === "matching")
    html +=
      '<button type="button" class="ghost small" data-grow="' +
      k +
      '">+ Add row</button> ' +
      (t === "table"
        ? '<button type="button" class="ghost small" data-column="' +
          k +
          '">+ Add column</button>'
        : "");
  return html + "</section>";
}
function openEditor(row, old = null) {
  editing = structuredClone(row);
  previous = old ? structuredClone(old) : null;
  editingEnglish = !!row.paper_type;
  parseErrors.clear();
  $("editor-errors").textContent = "";
  $("editor-title").textContent =
    (old ? "Edit " : "New ") +
    (editingEnglish ? "English board paper" : "question");
  drawEditor();
  $("editor").showModal();
}
function drawEditor() {
  const r = editing,
    p = r.payload || {},
    d = r.data || {};
  let html = '<div class="form-grid">' + input("Stable record ID", "id", r.id);
  if (editingEnglish) {
    html +=
      `<label>Paper type<select data-field="paper_type"><option value="first" ${r.paper_type === "first" ? "selected" : ""}>English 1st · Reading & Writing</option><option value="second" ${r.paper_type === "second" ? "selected" : ""}>English 2nd · Grammar & Composition</option></select></label>` +
      input("Board", "board", r.board) +
      input("Year", "year", r.year, "number") +
      input("Source label", "source_label", r.source_label || "") +
      '<div class="wide warn" style="padding:14px">Schema v1 follows the existing board-book pattern. First paper has 11 sections; second has 12. Answers are optional but must come from your source.</div>';
    for (const [k, t] of Object.entries(
      r.paper_type === "first" ? C.firstFields : C.secondFields,
    ))
      html += englishField(k, t, d);
    html +=
      '<h3 class="wide section-label">Source-provided answers · leave blank when not supplied</h3>';
    for (let i = 1; i <= (r.paper_type === "first" ? 11 : 12); i++)
      html += area(
        "Q" + i + " answer (source only)",
        "answer.q" + i,
        d.answers?.["q" + i] || "",
      );
  } else {
    html += `<label>Type<select data-field="type">${["mcq", "saq", "cq"].map((t) => `<option ${r.type === t ? "selected" : ""}>${t}</option>`).join("")}</select></label><label>Subject<select data-field="subject_id">${options(Object.fromEntries(Object.entries(catalog.SUBJECTS).filter(([k]) => !k.startsWith("english_"))), r.subject_id, "Choose")}</select></label><label>Chapter<input data-field="chapter" list="chapters" value="${esc(r.chapter)}"><datalist id="chapters">${(catalog.CHAPTERS[r.subject_id] || []).map((ch) => `<option value="${esc(ch)}">`).join("")}</datalist></label>`;
    if (r.type === "cq") {
      for (const k of [
        "stem",
        "questionK",
        "questionKh",
        "questionG",
        "questionGh",
      ])
        html += area(
          {
            stem: "উদ্দীপক",
            questionK: "ক",
            questionKh: "খ",
            questionG: "গ",
            questionGh: "ঘ (blank for three-part maths)",
          }[k],
          "payload." + k,
          p[k] || "",
        );
      html += area("CQ marks", "payload.marks", p.marks || [1, 2, 3, 4], true);
    } else {
      html += area(
        "Question text",
        "payload.questionText",
        p.questionText || "",
      );
      if (r.type === "mcq") {
        for (let i = 0; i < 4; i++)
          html += input(
            "Option " + ["ক", "খ", "গ", "ঘ"][i],
            "option." + i,
            p.options?.[i] || "",
          );
        html += `<label>Correct answer<select data-field="payload.correctIndex"><option value="">Answer not supplied</option>${[0, 1, 2, 3].map((i) => `<option value="${i}" ${p.correctIndex === i ? "selected" : ""}>${["ক", "খ", "গ", "ঘ"][i]}</option>`).join("")}</select></label>`;
      } else html += area("Answer", "payload.answer", p.answer || "");
      html += area("Explanation", "payload.explanation", p.explanation || "");
    }
    html +=
      input("Image URL (optional)", "image", r.figure?.imagePath || "") +
      input("Source label", "source_label", r.source_label || "") +
      `<label>Provenance<select data-field="source">${["original", "board", "ai", "internet"].map((v) => `<option ${r.source === v ? "selected" : ""}>${v}</option>`).join("")}</select></label><label><input type="checkbox" data-field="metadata.verified" ${r.metadata?.verified ? "checked" : ""}> Verified against the source by the reviewer</label>` +
      `<label>Difficulty<select data-field="metadata.difficulty">${["easy", "medium", "hard"].map((v) => `<option ${r.metadata?.difficulty === v ? "selected" : ""}>${v}</option>`).join("")}</select></label>` +
      input("Topic", "metadata.topic", r.metadata?.topic || "") +
      input(
        "Source board",
        "metadata.source_board",
        r.metadata?.source_board || "",
      ) +
      input(
        "Source year",
        "metadata.source_year",
        r.metadata?.source_year || "",
        "number",
      ) +
      area("Tags", "metadata.tags", r.metadata?.tags || [], true);
  }
  html += "</div>";
  $("editor-fields").innerHTML = html;
  if (previous) {
    document.querySelector('[data-field="id"]').disabled = true;
    if (editingEnglish)
      document.querySelector('[data-field="paper_type"]').disabled = true;
  }
  document.querySelectorAll("[data-grow]").forEach(
    (b) =>
      (b.onclick = () => {
        const rows = editing.data[b.dataset.grow];
        rows.push(
          Array.isArray(rows[0])
            ? Array(rows[0].length).fill("")
            : { a: "", b: "", c: "" },
        );
        drawEditor();
      }),
  );
  document.querySelectorAll("[data-column]").forEach(
    (b) =>
      (b.onclick = () => {
        editing.data[b.dataset.column].forEach((row) => row.push(""));
        drawEditor();
      }),
  );
  document.querySelectorAll("[data-field]").forEach(
    (el) =>
      (el.oninput = () => {
        const key = el.dataset.field;
        let value = el.type === "checkbox" ? el.checked : el.value;
        if (el.dataset.lines)
          value = value
            .split("\n")
            .map((s) => s.trim())
            .filter(Boolean);
        if (el.dataset.json) {
          try {
            value = JSON.parse(value);
            parseErrors.delete(key);
          } catch {
            parseErrors.set(key, "Invalid JSON in " + key);
            $("editor-errors").textContent = [...parseErrors.values()].join(
              "\n",
            );
            return;
          }
        }
        if (key === "paper_type") {
          if (!confirm("Change pattern? This resets the structured fields.")) {
            el.value = editing.paper_type;
            return;
          }
          editing = {
            ...C.englishTemplate(value),
            id: editing.id,
            board: editing.board,
            year: editing.year,
          };
          drawEditor();
          return;
        }
        if (key === "type") {
          editing.type = value;
          editing.payload =
            value === "cq"
              ? {
                  stem: "",
                  questionK: "",
                  questionKh: "",
                  questionG: "",
                  questionGh: "",
                  marks: [1, 2, 3, 4],
                }
              : value === "saq"
                ? { questionText: "", answer: "", explanation: "" }
                : {
                    questionText: "",
                    options: ["", "", "", ""],
                    correctIndex: null,
                    explanation: "",
                  };
          drawEditor();
          return;
        }
        if (key === "image") {
          editing.figure = value
            ? { kind: "image", imagePath: value, aspect: 1.4 }
            : null;
          return;
        }
        const [a, b, ...rest] = key.split(".");
        if (a === "option") {
          editing.payload.options ??= ["", "", "", ""];
          editing.payload.options[Number(b)] = value;
        } else if (a === "answer") {
          editing.data.answers ??= {};
          editing.data.answers[b] = value.trim() ? value : null;
        } else if (b) {
          editing[a] ??= {};
          if (rest.length) {
            let target = editing[a][b];
            for (const part of rest.slice(0, -1)) target = target[part];
            target[rest.at(-1)] = value;
          } else
            editing[a][b] =
              b === "correctIndex" || b === "source_year"
                ? value === ""
                  ? null
                  : Number(value)
                : value;
        } else editing[a] = a === "year" ? Number(value) : value;
        if (key === "subject_id") {
          editing.chapter = catalog.CHAPTERS[value]?.[0] || "";
          drawEditor();
        }
      }),
  );
}
function editorReport() {
  if (parseErrors.size) throw Error([...parseErrors.values()].join("\n"));
  return editingEnglish
    ? C.validateEnglish(editing)
    : { errors: C.validateQuestion(editing), warnings: [] };
}
$("editor").addEventListener("cancel", (e) => {
  if (!confirm("Discard unsaved editor changes?")) e.preventDefault();
});
$("close-editor").onclick = () => {
  if (confirm("Close editor? Unsaved changes will be lost."))
    $("editor").close();
};
$("editor-form").onsubmit = (e) => {
  e.preventDefault();
  task(async () => {
    if (parseErrors.size) throw Error([...parseErrors.values()].join("\n"));
    editing.review_status = "draft";
    if (editingEnglish)
      editing.subject =
        editing.paper_type === "first" ? "english_1st" : "english_2nd";
    await save(tableFor(editingEnglish), editing, previous);
    $("editor").close();
    notify("Draft saved. Validate and submit it for review before publishing.");
    await render();
  });
};
$("ai-review-editor").onclick = () =>
  task(async () => {
    if (state.demo) throw Error("AI review requires a live admin session.");
    const { data, error } = await client.functions.invoke("admin-content", {
      body: {
        action: "review",
        format: editingEnglish ? editing.paper_type : "questions",
        text: JSON.stringify(editing),
      },
    });
    if (error || data?.error) throw Error(data?.error || error.message);
    $("editor-errors").textContent =
      "AI suggestions — verify against your source; nothing was changed.\n" +
      data.result.summary +
      "\n" +
      data.result.findings.map((f) => f.field + ": " + f.message).join("\n");
  });
$("preview-editor").onclick = () => {
  try {
    const report = editorReport();
    $("editor-errors").textContent = [
      ...report.errors,
      ...report.warnings,
    ].join("\n");
    showPreview([editing], editingEnglish, report);
  } catch (e) {
    $("editor-errors").textContent = e.message;
  }
};
function rich(value) {
  if (Array.isArray(value)) {
    if (Array.isArray(value[0]))
      return (
        "<table>" +
        value
          .map(
            (row) =>
              "<tr>" +
              row.map((cell) => "<td>" + esc(cell) + "</td>").join("") +
              "</tr>",
          )
          .join("") +
        "</table>"
      );
    return (
      "<ol>" +
      value
        .map(
          (item) =>
            "<li>" +
            (typeof item === "object"
              ? Object.entries(item)
                  .map(([k, v]) => `<strong>${esc(k)}</strong> ${rich(v)}`)
                  .join("<br>")
              : esc(item)) +
            "</li>",
        )
        .join("") +
      "</ol>"
    );
  }
  return "<p>" + esc(value) + "</p>";
}
function questionPreview(r, i = 0, answers = false) {
  const p = r.payload || {};
  return `<div class="q"><strong>${i + 1}. ${esc(C.text(r))}</strong>${r.figure?.kind === "image" && /^https:\/\//.test(r.figure.imagePath) ? `<p><img src="${esc(r.figure.imagePath)}" alt="Question figure"></p>` : ""}${
    r.type === "mcq"
      ? `<div class="options">${(p.options || []).map((s, i) => "<span>" + ["ক", "খ", "গ", "ঘ"][i] + ") " + esc(s) + "</span>").join("")}</div>${answers ? "<p><strong>Answer:</strong> " + esc(Number.isInteger(p.correctIndex) ? ["ক", "খ", "গ", "ঘ"][p.correctIndex] : "Not supplied") + "<br>" + esc(p.explanation) + "</p>" : ""}`
      : r.type === "cq"
        ? ["questionK", "questionKh", "questionG", "questionGh"]
            .filter((k) => p[k])
            .map(
              (k, i) =>
                "<p>" +
                ["ক", "খ", "গ", "ঘ"][i] +
                ") " +
                esc(p[k]) +
                " [" +
                esc(p.marks?.[i]) +
                "]</p>",
            )
            .join("")
        : answers
          ? "<p>Answer: " + esc(p.answer) + "</p>"
          : ""
  }</div>`;
}
function englishPreview(r, answers = true) {
  const d = r.data || {},
    first = r.paper_type === "first";
  const section = (n, title, marks, body) =>
    `<section class="q" data-question="${n}"><strong>${n}. ${esc(title)} [${marks}]</strong>${body}</section>`;
  const paragraph = (k) => rich(d[k] || ""),
    list = (k) => rich(d[k] || []);
  let body = "";
  if (first) {
    body =
      "<h3>Part A · Reading · 70 marks</h3>" +
      paragraph("passage1Intro") +
      paragraph("passage1Unit") +
      paragraph("passage1");
    body += section(
      1,
      d.q1Instr || "Choose the correct answer.",
      7,
      '<ol type="a">' +
        (d.q1 || [])
          .map(
            (q) =>
              `<li><p>${esc(q?.stem)}</p><div class="options">${(q?.options || []).map((o, i) => "<span>" + ["i", "ii", "iii", "iv"][i] + ". " + esc(o) + "</span>").join("")}</div></li>`,
          )
          .join("") +
        "</ol>",
    );
    body += section(2, "Answer the following questions.", 10, list("q2"));
    body += section(
      3,
      d.q3Instr || "Complete the cloze passage.",
      5,
      paragraph("q3Source") + paragraph("q3Unit") + paragraph("q3Cloze"),
    );
    body += paragraph("passage2Intro") + paragraph("passage2");
    body += section(4, d.q4Instr || "Complete the table.", 5, list("q4Table"));
    body += section(
      5,
      "Write a summary of the above passage in your own words.",
      10,
      "",
    );
    const columns = [d.q6A || [], d.q6B || [], d.q6C || []];
    const table = [
      ["A", "B", "C"],
      ...Array.from(
        { length: Math.max(...columns.map((c) => c.length)) },
        (_, i) => columns.map((c) => c[i] || ""),
      ),
    ];
    body += section(
      6,
      "Match the parts of sentences in columns A, B and C.",
      5,
      rich(table),
    );
    body += section(
      7,
      "Put the following parts in the correct order to make a story.",
      8,
      list("q7"),
    );
    body += section(
      8,
      "Answer any five questions from the poems.",
      10,
      list("q8"),
    );
    body += section(
      9,
      "Answer any five questions from the stories.",
      10,
      list("q9"),
    );
    body += "<h3>Part B · Writing · 30 marks</h3>";
    body += section(
      10,
      d.q10Instr || "Complete the story.",
      15,
      paragraph("q10Starter"),
    );
    body += section(11, "Write a dialogue.", 15, paragraph("q11"));
  } else {
    body = list("headerExtra") + "<h3>Part A · Grammar · 60 marks</h3>";
    body += section(
      1,
      "Fill in the gaps with words from the box.",
      10,
      rich([d.q1Box || []]) + paragraph("q1Passage"),
    );
    body += section(
      2,
      "Make five sentences using the substitution table.",
      5,
      rich(
        (d.q2 || []).map((row) => [row?.a || "", row?.b || "", row?.c || ""]),
      ),
    );
    body += section(
      3,
      "Complete the text with the right forms of the verbs.",
      10,
      rich([d.q3Box || []]) + paragraph("q3Passage"),
    );
    body += section(
      4,
      "Change the sentences as directed.",
      10,
      rich(
        (d.q4 || []).map(
          (q) => (q?.sentence || "") + " (" + (q?.direction || "") + ")",
        ),
      ),
    );
    body += section(5, "Add tag questions.", 5, list("q5"));
    body += section(
      6,
      "Complete the text using prefixes or suffixes.",
      5,
      paragraph("q6Passage"),
    );
    body += section(
      7,
      "Complete the text with suitable prepositions.",
      5,
      paragraph("q7Passage"),
    );
    body += section(
      8,
      "Complete the text using suitable connectors.",
      5,
      paragraph("q8Passage"),
    );
    body += section(
      9,
      "Use capitals and punctuation marks where necessary.",
      5,
      paragraph("q9Text"),
    );
    body += "<h3>Part B · Composition · 40 marks</h3>";
    body +=
      section(10, "Write a paragraph.", 10, paragraph("q10")) +
      section(11, "Write a letter / application.", 10, paragraph("q11")) +
      section(12, "Write a composition.", 20, paragraph("q12"));
  }
  return `<article class="paper"><h2>English ${first ? "First" : "Second"} Paper</h2><h3>${esc(r.board)} Board · ${esc(r.year)}</h3><p style="text-align:center">Full marks: 100 · Time: 3 hours · Source-pattern preview</p>${body}${
    answers
      ? "<hr><h3>Source-provided answers</h3>" +
        Object.entries(d.answers || {})
          .map(
            ([k, v]) =>
              "<p><strong>" +
              esc(k.toUpperCase()) +
              ":</strong> " +
              esc(v || "Answer not supplied") +
              "</p>",
          )
          .join("")
      : ""
  }</article>`;
}
let previewState = null;
function paintPreview() {
  const { rows, english, report, answers } = previewState;
  $("preview-mode").textContent = answers
    ? "Switch to student view"
    : "Switch to teacher view";
  $("preview-heading").textContent = answers
    ? "Teacher paper preview"
    : "Student paper preview";
  $("preview-content").innerHTML =
    (report
      ? `<div class="${report.errors.length ? "warn" : "ok"}" style="padding:14px">${report.errors.length ? report.errors.length + " blocking issue(s)" : "Structure valid"} · ${report.warnings.length} answer warning(s)</div>`
      : "") +
    (english
      ? rows.map((r) => englishPreview(r, answers)).join("")
      : `<article class="paper"><h2>Tutor’s Desk · Question paper preview</h2><p style="text-align:center">${rows.length} selected questions · ${answers ? "Teacher review" : "Student"} copy</p>${rows.map((r, i) => questionPreview(r, i, answers)).join("")}</article>`);
}
function showPreview(rows, english = false, report = null) {
  previewState = { rows, english, report, answers: true };
  paintPreview();
  $("preview").showModal();
}
$("preview-mode").onclick = () => {
  previewState.answers = !previewState.answers;
  paintPreview();
};
$("close-preview").onclick = () => $("preview").close();
$("print-preview").onclick = () => window.print();
async function importView() {
  return `<p class="muted">Bring your material in. Review every record before it reaches a teacher.</p><div class="import-grid">${[
    [
      "paste",
      "✎",
      "Paste source text",
      "Structure text with AI; missing answers stay missing.",
    ],
    [
      "json",
      "{ }",
      "Import JSON",
      "Your question-bank export or an English board set.",
    ],
    [
      "csv",
      "▦",
      "Import CSV",
      "A spreadsheet with questions, options and answers.",
    ],
    [
      "english",
      "En",
      "English board paper",
      "Paste text, upload a PDF or edit a complete set.",
    ],
    [
      "figures",
      "▧",
      "Question figures",
      "Inspect, process and upload diagrams.",
    ],
  ]
    .map(
      ([id, icon, title, sub]) =>
        `<button class="card" data-action="import-${id}" style="text-align:left"><span class="quick-icon">${icon}</span><h2>${title}</h2><p>${sub}</p></button>`,
    )
    .join(
      "",
    )}</div><section class="card" style="margin-top:24px"><h2>Import workspace</h2><p class="muted">JSON and CSV are deterministic. AI cleanup is optional and always produces drafts.</p><input type="file" id="import-file" accept=".json,.csv,.pdf,text/plain"><div class="form-grid"><label>Format<select id="import-format"><option value="questions">Generic questions (JSON / CSV)</option><option value="first">English 1st Paper</option><option value="second">English 2nd Paper</option></select></label><label>Default subject<select id="import-subject">${options(catalog.SUBJECTS, "physics", "Choose")}</select></label></div><textarea id="import-text" rows="12" placeholder="Paste JSON, CSV, or the source paper text here…"></textarea><div class="toolbar"><button class="primary" data-action="parse-import">Parse & review</button><button class="ghost" data-action="ai-format">Structure with AI</button><button class="link" data-action="csv-template">Download CSV template</button></div><div id="import-report"></div><div id="import-results"></div></section>`;
}
let importRows = [];
async function parseImport(ai = false) {
  const raw = $("import-text").value.trim(),
    format = $("import-format").value;
  if (!raw) throw Error("Add source text or upload a file first.");
  if (raw.length > 5000000)
    throw Error("Import is too large. Split it into smaller files.");
  if (ai) {
    if (state.demo)
      throw Error(
        "AI requires an authenticated server session; demo mode never contacts an AI service.",
      );
    const { data, error } = await client.functions.invoke("admin-content", {
      body: {
        action: "structure",
        format,
        subject_id: $("import-subject").value,
        text: raw,
      },
    });
    if (error) throw Error(data?.error || error.message);
    if (data?.error) throw Error(data.error);
    $("import-text").value = JSON.stringify(data.result, null, 2);
    return parseImport(false);
  }
  if (format !== "questions") {
    let row;
    try {
      row = JSON.parse(raw);
    } catch {
      row = C.draftFromText(raw, format);
    }
    if (!row.paper_type)
      row = { ...C.draftFromText(row.source_text || "", format), data: row };
    openEditor(row);
    return;
  }
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    parsed = C.csvQuestions(raw);
  }
  importRows = Array.isArray(parsed)
    ? parsed
    : Array.isArray(parsed.records)
      ? parsed.records
      : parsed.paper_type
        ? [parsed]
        : [parsed];
  if (importRows.some((r) => r.paper_type)) {
    if (importRows.length !== 1)
      throw Error(
        "Review English papers individually. Import one complete set at a time.",
      );
    openEditor(importRows[0]);
    return;
  }
  if (importRows.length > 500)
    throw Error("Import at most 500 rows per review batch.");
  importRows = importRows.map((r, i) => ({
    ...r,
    id: r.id || "import_" + Date.now() + "_" + i,
    subject_id: r.subject_id || r.subjectId || $("import-subject").value,
    payload: r.payload || r,
    review_status: "draft",
    is_active: true,
    owner_id: null,
    metadata: r.metadata || {},
  }));
  const ids = new Set(),
    errors = [];
  for (const r of importRows) {
    if (ids.has(r.id)) errors.push(r.id + ": duplicate ID in this import");
    ids.add(r.id);
    errors.push(...C.validateQuestion(r).map((e) => r.id + ": " + e));
  }
  const existing = await all("questions"),
    existingIds = new Set(existing.map((r) => r.id));
  for (const r of importRows)
    if (existingIds.has(r.id))
      errors.push(r.id + ": already exists; use Edit instead of overwriting");
  const duplicateCount = (
    await duplicateScan([...importRows, ...existing], 1)
  ).filter((h) => importRows.includes(h.a) || importRows.includes(h.b)).length;
  $("import-report").textContent =
    `${importRows.length} records · ${errors.length} validation issues · ${duplicateCount} exact duplicate pairs. Imported records remain drafts.`;
  $("import-results").innerHTML =
    errors.map((e) => '<p class="warn">' + esc(e) + "</p>").join("") +
    `<div class="toolbar"><button class="ghost" data-action="preview-import">Preview all</button><button class="primary" data-action="save-import">Save ${importRows.length} drafts</button></div>` +
    importRows
      .slice(0, 10)
      .map((r, i) => questionPreview(r, i, true))
      .join("");
  bindActions($("import-results"));
  // Invalid answers can be saved as drafts for repair, but cannot enter review.
  if (
    errors.some(
      (e) => e.includes("duplicate ID") || e.includes("already exists"),
    )
  )
    importRows = [];
}
async function validationView() {
  return `<div class="card"><h2>Question bank health</h2><p class="muted">Checks all server records, including drafts and archived records. Nothing is deleted automatically.</p><div class="toolbar"><button class="primary" data-action="health">Run bank check</button><button class="ghost" data-action="duplicates">Find similar questions</button><button class="ghost" data-action="storage-health">Check storage references</button></div><div id="health-results" class="empty">Choose a check to see actionable issues.</div></div>`;
}
let healthRows = [],
  healthEnglish = [];
async function runHealth(kind) {
  healthRows = await all("questions");
  healthEnglish = await all("english_papers");
  const target = $("health-results");
  target.className = "";
  if (kind === "health") {
    const report = C.health(healthRows, healthEnglish, catalog.CHAPTERS);
    target.innerHTML =
      `<h3>${report.questions} questions · ${report.english} English papers · ${report.issues.length} issues</h3>` +
      report.issues
        .map(
          (x) =>
            `<div class="issue"><span><strong>${esc(x.id)}</strong><br>${esc(x.message)}</span><button class="ghost small" data-fix="${esc(x.id)}" data-english="${!!x.english}">Fix</button></div>`,
        )
        .join("");
  } else if (kind === "duplicates") {
    const pairs = await duplicateScan(healthRows.filter((r) => r.is_active));
    target.innerHTML =
      `<p>${pairs.length} similar pairs. Similarity is a text signal, not proof of duplication. Review before archiving.</p>` +
      pairs
        .slice(0, 200)
        .map(
          ({ a, b, score }) =>
            `<div class="card" style="margin:12px 0"><span class="badge review">${Math.round(score * 100)}% token similarity</span><p>${esc(C.text(a))}</p><p>${esc(C.text(b))}</p><button class="ghost small" data-fix="${esc(a.id)}">Review ${esc(a.id)}</button> <button class="ghost small" data-fix="${esc(b.id)}">Review ${esc(b.id)}</button></div>`,
        )
        .join("");
  } else {
    await storageHealth(target);
  }
  target.querySelectorAll("[data-fix]").forEach(
    (b) =>
      (b.onclick = () => {
        const r = (
          b.dataset.english === "true" ? healthEnglish : healthRows
        ).find((r) => r.id === b.dataset.fix);
        if (r) openEditor(r, r);
      }),
  );
}
async function activityView() {
  const rows = (await all("admin_activity")).sort((a, b) =>
    b.created_at.localeCompare(a.created_at),
  );
  return `<p class="muted">Server-generated change history. Content administrators cannot rewrite audit entries.</p><div class="table-wrap"><table><thead><tr><th>WHEN</th><th>ADMIN</th><th>ACTION</th><th>CONTENT</th></tr></thead><tbody>${rows
    .slice(0, 200)
    .map(
      (r) =>
        `<tr><td>${esc(new Date(r.created_at).toLocaleString())}</td><td>${esc(r.admin_id || "Service / migration")}</td><td>${esc(r.action)}</td><td>${esc(r.record_id)}<small>${esc(r.entity)}</small></td></tr>`,
    )
    .join(
      "",
    )}</tbody></table></div><p class="muted">Showing the latest ${Math.min(200, rows.length)} of ${rows.length} audit entries.</p>`;
}
async function settingsView() {
  return `<div class="columns"><section class="card"><h2>Subject & chapter catalog</h2><button class="ghost small" data-action="add-subject">+ Add subject</button><p class="muted">Save a subject’s chapter list without editing JavaScript. Existing question chapter labels are not silently renamed.</p><label>Subject<select id="catalog-subject">${options(catalog.SUBJECTS, "physics", "Choose")}</select></label><label>Display name<input id="catalog-name" value="${esc(catalog.SUBJECTS.physics)}"></label><label>Chapters · one per line<textarea id="catalog-chapters" rows="12">${esc(catalog.CHAPTERS.physics.join("\n"))}</textarea></label><button class="primary" data-action="save-catalog">Save catalog</button></section><section class="card"><h2>Content rules</h2><p class="muted">Required safeguards are enforced on the server; they cannot be disabled from this browser.</p>${["Require subject and chapter", "Prevent duplicate record IDs", "Require four distinct MCQ options", "Require an explicit MCQ answer and explanation", "Validate CQ parts and marks", "Block corrupted Unicode", "Keep English answers absent when not supplied", "Require Draft → Review → Published", "Record changes in a server audit trail"].map((t) => '<p class="ok" style="padding:10px">✓ ' + t + "</p>").join("")}<p class="muted">Session tokens stay in memory. A refresh of this page requires sign-in again. Only the public anon key is shipped; never add a service-role key to these files.</p></section></div>`;
}
async function figuresView() {
  return `<section class="card"><h2>Prepare a question figure</h2><p class="muted">PNG / JPEG / WebP only. Uploads use unique object names; replacing a figure does not overwrite another question’s image.</p><input id="figure-file" type="file" accept="image/png,image/jpeg,image/webp"><div class="toolbar"><label><input id="mono" type="checkbox" checked>Grayscale & contrast</label><button class="ghost" data-action="process-figure">Process</button><button class="primary" data-action="upload-figure">Upload processed figure</button><button class="ghost" data-action="storage-health">Storage health</button></div><div class="figure-grid"><div><h3>Original</h3><img id="figure-original" alt="Original preview"><p id="figure-meta"></p></div><div><h3>Processed / final</h3><canvas id="figure-canvas" style="max-width:100%"></canvas><p id="processed-meta"></p></div></div><div id="figure-output"></div><div id="health-results"></div></section>`;
}
let originalImage = null;
async function processFigure() {
  if (!originalImage) throw Error("Choose an image first.");
  const canvas = $("figure-canvas"),
    scale = Math.min(
      1,
      1654 / originalImage.width,
      2339 / originalImage.height,
    );
  canvas.width = Math.round(originalImage.width * scale);
  canvas.height = Math.round(originalImage.height * scale);
  const ctx = canvas.getContext("2d");
  ctx.fillStyle = "white";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.drawImage(originalImage, 0, 0, canvas.width, canvas.height);
  if ($("mono").checked) {
    const pixels = ctx.getImageData(0, 0, canvas.width, canvas.height);
    for (let i = 0; i < pixels.data.length; i += 4) {
      const g = Math.max(
        0,
        Math.min(
          255,
          (0.299 * pixels.data[i] +
            0.587 * pixels.data[i + 1] +
            0.114 * pixels.data[i + 2] -
            128) *
            1.15 +
            128,
        ),
      );
      pixels.data[i] = pixels.data[i + 1] = pixels.data[i + 2] = g;
    }
    ctx.putImageData(pixels, 0, 0);
  }
  const blob = await new Promise((r) => canvas.toBlob(r, "image/png"));
  $("processed-meta").textContent =
    `${canvas.width} × ${canvas.height} · PNG · ${(blob.size / 1024).toFixed(0)} KB`;
  return blob;
}
async function storageHealth(target) {
  if (state.demo) {
    target.textContent =
      "Storage checks require a live admin session. Demo mode has no storage bucket.";
    return;
  }
  const rows = await all("questions", true),
    english = await all("english_papers");
  const referenced = new Set();
  const marker = "/storage/v1/object/public/question-figures/";
  for (const row of [...rows, ...english]) {
    const raw = JSON.stringify(row);
    for (const match of raw.matchAll(/https:\/\/[^"\s]+/g)) {
      const path = match[0].split(marker)[1];
      if (path) referenced.add(decodeURIComponent(path.split("?")[0]));
    }
  }
  const files = [];
  async function walk(prefix = "") {
    for (let offset = 0; ; offset += 100) {
      const { data, error } = await client.storage
        .from("question-figures")
        .list(prefix, {
          limit: 100,
          offset,
          sortBy: { column: "name", order: "asc" },
        });
      if (error) throw error;
      for (const item of data) {
        const path = prefix ? prefix + "/" + item.name : item.name;
        if (item.id) files.push(path);
        else await walk(path);
      }
      if (data.length < 100) break;
    }
  }
  await walk();
  const unused = files.filter((f) => !referenced.has(f)),
    missing = [...referenced].filter((f) => !files.includes(f));
  target.innerHTML =
    `<h3>Storage health</h3><p>${files.length - unused.length} used · ${unused.length} unreferenced server files · ${missing.length} missing references</p><p class="warn">Bundled APK figures and external clients may still use an apparently unreferenced file. Download a backup and verify before deleting.</p>` +
    missing.map((p) => '<p class="warn">Missing: ' + esc(p) + "</p>").join("") +
    unused
      .map(
        (path) =>
          `<div class="issue"><span>${esc(path)}</span><button class="danger small" data-unused="${esc(path)}">Review / delete</button></div>`,
      )
      .join("");
  target.querySelectorAll("[data-unused]").forEach(
    (b) =>
      (b.onclick = () =>
        task(async () => {
          if (
            prompt(
              "Type the complete filename to delete after checking bundled APK references:\n" +
                b.dataset.unused,
            ) !== b.dataset.unused
          )
            return;
          const current = await all("questions", true);
          if (
            JSON.stringify(current).includes(b.dataset.unused) ||
            JSON.stringify(await all("english_papers")).includes(
              b.dataset.unused,
            )
          )
            throw Error("This image is now referenced. It was not deleted.");
          const { data, error } = await client.storage
            .from("question-figures")
            .download(b.dataset.unused);
          if (error) throw error;
          download(b.dataset.unused.split("/").pop(), data, "image/png");
          const removed = await client.storage
            .from("question-figures")
            .remove([b.dataset.unused]);
          if (removed.error) throw removed.error;
          await storageHealth(target);
        })),
  );
}
function bindActions(root = $("main")) {
  root
    .querySelectorAll("[data-action]")
    .forEach(
      (b) =>
        (b.onclick = () => task(() => action(b.dataset.action, b.dataset.row))),
    );
}
function bind() {
  bindActions();
  document.querySelectorAll("[data-select]").forEach(
    (el) =>
      (el.onchange = () => {
        if (el.checked) state.selected.add(el.dataset.select);
        else state.selected.delete(el.dataset.select);
      }),
  );
  if ($("select-page"))
    $("select-page").onchange = (e) => {
      document.querySelectorAll("[data-select]").forEach((el) => {
        el.checked = e.target.checked;
        el.onchange();
      });
    };
  if ($("search"))
    $("search").onkeydown = (e) => {
      if (e.key === "Enter") task(() => action("filter"));
    };
  if ($("catalog-subject"))
    $("catalog-subject").onchange = () => {
      const id = $("catalog-subject").value;
      $("catalog-name").value = catalog.SUBJECTS[id] || "";
      $("catalog-chapters").value = (catalog.CHAPTERS[id] || []).join("\n");
    };
  if ($("import-file"))
    $("import-file").onchange = (e) =>
      task(async () => {
        const file = e.target.files[0];
        if (!file) return;
        if (file.size > 20 * 1024 * 1024)
          throw Error("Choose a file smaller than 20 MB.");
        if (file.name.toLowerCase().endsWith(".pdf")) {
          const pdfjs = await import("./vendor/pdf.mjs");
          pdfjs.GlobalWorkerOptions.workerSrc = new window.URL(
            "./vendor/pdf.worker.mjs",
            import.meta.url,
          ).href;
          const pdf = await pdfjs.getDocument({
            data: await file.arrayBuffer(),
            isEvalSupported: false,
          }).promise;
          if (pdf.numPages > 60)
            throw Error("Import at most 60 PDF pages at a time.");
          const pages = [];
          for (let i = 1; i <= pdf.numPages; i++) {
            const page = await pdf.getPage(i),
              text = await page.getTextContent();
            pages.push(
              text.items.map((x) => x.str + (x.hasEOL ? "\n" : " ")).join(""),
            );
          }
          $("import-text").value = pages.join("\n\n");
          notify(
            "PDF text extracted locally. Tables and scanned/image-only pages need manual transcription or source images; nothing is invented.",
          );
          await pdf.destroy();
        } else $("import-text").value = await file.text();
      });
  if ($("figure-file"))
    $("figure-file").onchange = (e) =>
      task(async () => {
        const file = e.target.files[0];
        if (!file) return;
        if (
          file.size > 15 * 1024 * 1024 ||
          !["image/png", "image/jpeg", "image/webp"].includes(file.type)
        )
          throw Error("Choose a PNG, JPEG or WebP below 15 MB.");
        const url = window.URL.createObjectURL(file);
        const img = new Image();
        img.src = url;
        await img.decode();
        if (img.width * img.height > 40000000)
          throw Error("Image exceeds 40 megapixels. Resize it first.");
        originalImage = img;
        $("figure-original").src = url;
        $("figure-meta").textContent =
          `${img.width} × ${img.height} · ${file.type} · ${(file.size / 1024).toFixed(0)} KB`;
        await processFigure();
      });
}
async function action(name, id) {
  const english = englishMode(),
    table = tableFor(english),
    row = state.rows.find((r) => r.id === id);
  if (name === "reload") return render();
  if (name === "new-english") {
    openEditor(C.englishTemplate());
    return;
  }
  if (name === "filter") {
    state.query = $("search").value.trim();
    state.subject = $("subject-filter")?.value || "";
    state.status = $("status-filter").value;
    state.paperType =
      $("archive-type")?.value || $("paper-filter")?.value || "";
    state.board = $("board-filter")?.value || "";
    state.year = $("year-filter")?.value || "";
    state.page = 0;
    state.selected.clear();
    return render();
  }
  if (name === "prev" || name === "next") {
    state.page = Math.max(
      0,
      Math.min(
        Math.ceil(state.total / 25) - 1,
        state.page + (name === "next" ? 1 : -1),
      ),
    );
    state.selected.clear();
    return render();
  }
  if (name === "edit") return openEditor(row, row);
  if (name === "duplicate") {
    const copy = structuredClone(row);
    copy.id += "_" + crypto.randomUUID().slice(0, 6);
    copy.review_status = "draft";
    return openEditor(copy);
  }
  if (name === "preview") return showPreview([row], english);
  if (name === "paper-preview") {
    const selected = state.rows.filter((r) => state.selected.has(r.id));
    if (!selected.length)
      throw Error("Select questions or English papers first.");
    return showPreview(selected, english);
  }
  if (name === "review" || name === "publish") {
    const report = english
      ? C.validateEnglish(row)
      : { errors: C.validateQuestion(row), warnings: [] };
    if (report.errors.length) throw Error(report.errors.join("\n"));
    let next =
      name === "review"
        ? "review"
        : row.review_status === "published"
          ? "draft"
          : "published";
    if (
      next === "published" &&
      !confirm(
        `Publish ${row.id}?\n${report.warnings.join("\n")}\nI have reviewed the source, wording and answers.`,
      )
    )
      return;
    await save(table, { ...row, review_status: next }, row);
    notify(
      next === "published"
        ? "Published. The updated app receives this content on its next successful sync."
        : "Workflow updated.",
    );
    return render();
  }
  if (["archive", "restore", "delete"].includes(name)) {
    if (
      !confirm(`${name === "delete" ? "Permanently delete" : name} ${row.id}?`)
    )
      return;
    if (name === "delete") {
      if (
        prompt(
          "Type DELETE to confirm permanent removal. A backup will download first.",
        ) !== "DELETE"
      )
        return;
      download("backup-" + row.id + ".json", row);
      if (state.demo) {
        if (english) demoEnglish = demoEnglish.filter((r) => r.id !== id);
        else demoRows = demoRows.filter((r) => r.id !== id);
      } else {
        const { error } = await client
          .from(table)
          .delete()
          .eq("id", row.id)
          .eq("updated_at", row.updated_at)
          .eq("is_active", false);
        if (error) throw error;
      }
    } else await save(table, { ...row, is_active: name === "restore" }, row);
    return render();
  }
  if (name.startsWith("export-")) {
    let rows = await all(table);
    if (name === "export-selected") {
      rows = rows.filter((r) => state.selected.has(r.id));
      if (!rows.length) throw Error("Select records first.");
    }
    if (name === "export-subject") {
      if (!english && !state.subject)
        throw Error("Choose a subject filter first.");
      if (!english) rows = rows.filter((r) => r.subject_id === state.subject);
      const chapter = prompt(
        "Optional exact chapter name (leave blank for the whole subject):",
        "",
      );
      if (chapter === null) return;
      if (chapter) rows = rows.filter((r) => r.chapter === chapter);
    }
    download(`${table}-${new Date().toISOString().slice(0, 10)}.json`, {
      schema_version: 1,
      exported_at: new Date().toISOString(),
      records: rows,
    });
    return;
  }
  if (name === "bulk-publish") {
    const rows = state.rows.filter((r) => state.selected.has(r.id));
    if (!rows.length) throw Error("Select the approved records on this page.");
    for (const r of rows) {
      if (r.review_status !== "review" || !r.is_active)
        throw Error("Select only active records that are in review.");
      const report = english
        ? C.validateEnglish(r)
        : { errors: C.validateQuestion(r) };
      if (report.errors.length)
        throw Error(r.id + ": " + report.errors.join(" / "));
    }
    if (
      !confirm(
        `Publish exactly these ${rows.length} reviewed records?\n${rows.map((r) => r.id).join("\n")}\nI checked the source and all missing-answer warnings.`,
      )
    )
      return;
    let done = 0;
    try {
      for (const r of rows) {
        await save(table, { ...r, review_status: "published" }, r);
        done++;
      }
    } catch (e) {
      throw Error(
        `${done}/${rows.length} published. Refresh before retrying. ${e.message}`,
      );
    }
    state.selected.clear();
    notify(`${done} reviewed records published.`);
    return render();
  }
  if (name === "bulk-archive") {
    const rows = state.rows.filter((r) => state.selected.has(r.id));
    if (!rows.length) throw Error("Select records on this page first.");
    if (
      !confirm(
        `Download a backup, then ${state.tab === "archived" ? "restore" : "archive"} ${rows.length} records?`,
      )
    )
      return;
    download("backup-" + Date.now() + ".json", rows);
    let done = 0;
    try {
      for (const r of rows) {
        await save(table, { ...r, is_active: state.tab === "archived" }, r);
        done++;
      }
    } catch (e) {
      throw Error(
        `${done}/${rows.length} changed before an error. Your backup contains every selected row. ${e.message}`,
      );
    }
    state.selected.clear();
    return render();
  }
  if (name.startsWith("import-")) {
    const kind = name.slice(7);
    if (kind === "figures") {
      location.hash = "figures";
      return;
    }
    if (kind === "english") $("import-format").value = "first";
    else $("import-format").value = "questions";
    if (kind === "csv" || kind === "json") $("import-file").click();
    else $("import-text").focus();
    return;
  }
  if (name === "parse-import" || name === "ai-format")
    return parseImport(name === "ai-format");
  if (name === "preview-import") return showPreview(importRows);
  if (name === "save-import") {
    if (!importRows.length)
      throw Error("No importable rows. Fix duplicate IDs and parse again.");
    if (
      !confirm(
        `Save ${importRows.length} drafts? Nothing will be published yet.`,
      )
    )
      return;
    if (state.demo) {
      for (const row of importRows) await save("questions", row, null);
    } else {
      const { error } = await client
        .from("questions")
        .insert(importRows.map(writable));
      if (error) throw error;
    }
    notify(
      `${importRows.length} drafts saved. Open Question Bank to repair issues and submit for review.`,
    );
    importRows = [];
    $("import-results").innerHTML = "";
    return;
  }
  if (name === "csv-template")
    return download(
      "question-template.csv",
      "id,subject,chapter,type,question,option_a,option_b,option_c,option_d,answer,explanation\n",
      "text/csv",
    );
  if (name === "health" || name === "duplicates") return runHealth(name);
  if (name === "storage-health") return runHealth(name);
  if (name === "process-figure") return processFigure();
  if (name === "upload-figure") {
    const blob = await processFigure();
    if (state.demo) throw Error("Uploads are disabled in offline demo.");
    const path = "studio/" + crypto.randomUUID() + ".png";
    const { error } = await client.storage
      .from("question-figures")
      .upload(path, blob, { contentType: "image/png", upsert: false });
    if (error) throw error;
    const { data } = client.storage.from("question-figures").getPublicUrl(path);
    $("figure-output").innerHTML =
      '<label>Final figure URL · paste into a question to add / replace its image<input readonly value="' +
      esc(data.publicUrl) +
      '"></label>';
    return;
  }
  if (name === "add-subject") {
    const id = prompt(
      "Stable subject ID (lowercase letters, digits, underscores):",
    );
    if (!id) return;
    if (!/^[a-z][a-z0-9_]+$/.test(id) || catalog.SUBJECTS[id])
      throw Error("Use a new lowercase subject ID.");
    const label = prompt("Subject display name:");
    if (!label) return;
    catalog.SUBJECTS[id] = label;
    catalog.CHAPTERS[id] = [];
    $("catalog-subject").innerHTML = options(catalog.SUBJECTS, id, "Choose");
    $("catalog-name").value = label;
    $("catalog-chapters").value = "";
    notify(
      "Add the chapter list, then Save catalog. Custom subjects use custom paper counts, not a new official board pattern.",
    );
    return;
  }
  if (name === "save-catalog") {
    const id = $("catalog-subject").value,
      name = $("catalog-name").value.trim(),
      chapters = [
        ...new Set(
          $("catalog-chapters")
            .value.split("\n")
            .map((s) => s.trim())
            .filter(Boolean),
        ),
      ];
    if (!id || !name) throw Error("Choose a subject and display name.");
    if (!state.demo) {
      const { error } = await client
        .from("content_subjects")
        .upsert({ id, name, chapters });
      if (error) throw error;
    }
    catalog.SUBJECTS[id] = name;
    catalog.CHAPTERS[id] = chapters;
    notify(
      "Chapter catalog saved. Existing questions retain their current chapter names.",
    );
    return;
  }
}

function duplicateScan(rows, threshold = 0.8) {
  return new Promise((resolve, reject) => {
    const worker = new Worker("validation-worker.js");
    worker.onmessage = ({ data }) => {
      worker.terminate();
      if (data.error) {
        reject(Error(data.error));
        return;
      }
      const byId = new Map(rows.map((r) => [r.id, r]));
      resolve(
        data.hits.map((h) => ({ ...h, a: byId.get(h.a), b: byId.get(h.b) })),
      );
    };
    worker.onerror = (e) => {
      worker.terminate();
      reject(Error(e.message));
    };
    worker.postMessage({ rows, threshold });
  });
}
