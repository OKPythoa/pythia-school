import { readFileSync, writeFileSync, mkdirSync, existsSync, appendFileSync } from "node:fs";

const BASE = process.env.PYTHIA_SANDBOX || "http://127.0.0.1:18960";
const STATE = process.env.PYTHIA_MAIL_STATE || "/var/lib/pythia-school/replied-uids.json";
const LESSONS = process.env.PYTHIA_SCHOOL_LESSONS || "/var/lib/pythia-school/lessons.jsonl";
const mode = process.argv[2] || "run";
const POISON = /трак|стоянк|драйвер|главный фокус из этого письма|живой приём денег|^\s*принято\.?\s*$/i;
const HOME = [
  "okpythia.com",
  "bimboprotocol.com",
  "redgrimoire.com",
  "theantigloss.com",
  "books2read.com"
];
const FETCH_MS = 12000;
const TEXT_CAP = 24000;
const UA = "PythiaSchool/007 (+https://okpythia.com)";

async function job(tool, input) {
  const r = await fetch(BASE + "/v1/jobs", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      tool,
      idempotencyKey: tool + "-" + Date.now() + "-" + Math.random().toString(16).slice(2),
      input
    })
  });
  const created = await r.json();
  const id = created.id || created.jobId || created.job?.id;
  if (!id) throw new Error("no job id " + JSON.stringify(created));
  for (let i = 0; i < 50; i++) {
    await new Promise((x) => setTimeout(x, 400));
    const j = await (await fetch(BASE + "/v1/jobs/" + id)).json();
    const st = j.status || j.job?.status;
    if (st === "completed" || st === "ok") return j.result ?? j.job?.result ?? j;
    if (st === "failed" || st === "error") throw new Error(tool + " " + JSON.stringify(j.error || j));
  }
  throw new Error(tool + " timeout");
}

function loadState() {
  if (!existsSync(STATE)) return { uids: [] };
  try { return JSON.parse(readFileSync(STATE, "utf8")); } catch { return { uids: [] }; }
}
function saveState(state) {
  mkdirSync("/var/lib/pythia-school", { recursive: true });
  writeFileSync(STATE, JSON.stringify(state, null, 2));
}
function loadLocalLessons() {
  if (!existsSync(LESSONS)) return [];
  return readFileSync(LESSONS, "utf8").split("\n").filter(Boolean).map((line) => {
    try { return JSON.parse(line); } catch { return { text: line }; }
  });
}
function appendLesson(row) {
  mkdirSync("/var/lib/pythia-school", { recursive: true });
  appendFileSync(LESSONS, JSON.stringify(row) + "\n");
}
function knowledgeId(x) { return x?.item?.id || x?.id || x?.knowledgeId || x?.result?.id || ""; }
function poison(t) { return POISON.test(String(t || "")); }
function hostOf(u) {
  try { return new URL(u).hostname.replace(/^www\./, ""); } catch { return ""; }
}
function isHome(u) { return HOME.includes(hostOf(u)); }
function isRoot(u) {
  try {
    const p = new URL(u).pathname.replace(/\/+$/, "") || "/";
    return p === "/";
  } catch { return false; }
}
function firstUrl(text) {
  const m = String(text || "").match(/https?:\/\/[^\s"'<>]+/i);
  return m ? m[0].replace(/[),.;]+$/, "") : "";
}
function extractUrls(text) {
  const out = [];
  const re = /https?:\/\/[^\s"'<>]+/gi;
  let m;
  while ((m = re.exec(String(text || "")))) {
    const u = m[0].replace(/[),.;]+$/, "");
    if (!out.includes(u)) out.push(u);
  }
  return out;
}
function stripHtml(html) {
  return String(html || "")
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/\s+/g, " ")
    .trim();
}
function linksFrom(html, base) {
  const links = [];
  const re = /href\s*=\s*["']([^"']+)["']/gi;
  let m;
  while ((m = re.exec(String(html || "")))) {
    try {
      const abs = new URL(m[1], base).href.split("#")[0];
      if (abs.startsWith("http") && !links.includes(abs)) links.push(abs);
    } catch {}
  }
  return links;
}

async function httpFetch(url) {
  const ac = new AbortController();
  const t = setTimeout(() => ac.abort(), FETCH_MS);
  try {
    const r = await fetch(url, { signal: ac.signal, redirect: "follow", headers: { "user-agent": UA, accept: "text/html,text/plain,*/*" } });
    const raw = await r.text();
    const html = raw.slice(0, TEXT_CAP);
    const text = stripHtml(html).slice(0, 8000);
    const title = (html.match(/<title[^>]*>([\s\S]*?)<\/title>/i) || [, ""])[1].replace(/\s+/g, " ").trim();
    return { url: r.url || url, status: r.status, title, text, links: linksFrom(html, r.url || url) };
  } finally {
    clearTimeout(t);
  }
}

async function siteCrawl(start, opts = {}) {
  const maxPages = Math.min(Number(opts.maxPages || 12), 20);
  const depthMax = Math.min(Number(opts.depth || 2), 3);
  const host = hostOf(start);
  const allowForeign = opts.allowForeign === true;
  const seen = new Set();
  const pages = [];
  const q = [{ url: start, depth: 0 }];
  while (q.length && pages.length < maxPages) {
    const cur = q.shift();
    if (!cur || seen.has(cur.url)) continue;
    if (!allowForeign && hostOf(cur.url) !== host) continue;
    seen.add(cur.url);
    let page;
    try { page = await httpFetch(cur.url); } catch { continue; }
    pages.push(page);
    if (cur.depth >= depthMax) continue;
    for (const href of page.links || []) {
      if (seen.has(href)) continue;
      if (!allowForeign && hostOf(href) !== host) continue;
      if (/\.(jpg|png|gif|svg|css|js|zip|pdf|woff2?)(\?|$)/i.test(href)) continue;
      q.push({ url: href, depth: cur.depth + 1 });
    }
  }
  return pages;
}

function questionOf(subject, body) {
  const lines = String(body || "").split(/\n+/).map((l) => l.trim()).filter(Boolean);
  const asked = lines.filter((l) => /[?]|назови |выбер|какой |почему|что сделать|где |как |return only|find the|search site:/i.test(l));
  return (asked.slice(-2).join(" ") || lines.slice(-3).join(" ") || String(subject || "")).slice(0, 500);
}
function score(text, query) {
  const q = String(query).toLowerCase().split(/[^a-zа-яё0-9]+/i).filter((w) => w.length > 3);
  const t = String(text).toLowerCase();
  return q.reduce((n, w) => n + (t.includes(w) ? 1 : 0), 0);
}
function cleanReply(s) {
  let t = String(s || "").replace(/\s+/g, " ").trim();
  t = t.replace(/^(принято|урок записан)\.?$/i, "");
  if (poison(t)) return "";
  if (t.length > 500) t = t.slice(0, 497) + "...";
  return t;
}
function wantsUrl(q, body) {
  return /url|ссылк|страниц|где |найти|onecard|one-card|one card|http/i.test(String(q) + String(body));
}
function pageScore(page, q) {
  const blob = ((page.url || "") + " " + (page.title || "") + " " + (page.text || "")).toLowerCase();
  let n = score(blob, q);
  if (/onecard|one-card|one card|tarot|таро/i.test(blob)) n += 8;
  if (isHome(page.url)) n += 6;
  if (isRoot(page.url) && /onecard|one-card|подстраниц|subpage/i.test(q)) n -= 12;
  if (/tragos\.ru|dtf\.ru/i.test(page.url || "")) n -= 20;
  return n;
}

async function sandboxResearch(question) {
  const found = [];
  try {
    const extra = await job("knowledge_retrieve", { query: question });
    for (const i of extra.items || extra.results || []) {
      const t = String(i.content || i.text || "").trim();
      if (t && !poison(t) && !/tragos\.ru/i.test(t)) found.push(t);
    }
  } catch {}
  try {
    const got = await job("research", { query: question, count: 8 });
    const src = got?.sources || got?.result?.sources || [];
    for (const s of src) {
      const url = String(s.url || s.link || "");
      const title = String(s.title || "");
      const snip = String(s.snippet || s.text || "");
      if (url) found.push(url + " " + title + " " + snip);
    }
    if (!src.length) {
      const cut = (typeof got === "string" ? got : JSON.stringify(got || {})).replace(/\s+/g, " ").trim().slice(0, 600);
      if (cut && !poison(cut)) found.push(cut);
    }
  } catch {}
  return found.filter((t) => t && !poison(t));
}

async function huntUrl(question, body) {
  const q = question + " " + String(body || "").slice(0, 280);
  const hits = await sandboxResearch(q);
  const seeds = [];
  for (const t of hits) for (const u of extractUrls(t)) if (!seeds.includes(u)) seeds.push(u);
  if (/okpythia/i.test(q + body)) {
    for (const u of ["https://okpythia.com/", "https://okpythia.com/onecard/", "https://okpythia.com/onecard"]) {
      if (!seeds.includes(u)) seeds.push(u);
    }
  }
  const fetched = [];
  for (const u of seeds.slice(0, 8)) {
    try { fetched.push(await httpFetch(u)); } catch {}
  }
  const ownStarts = fetched.filter((p) => isHome(p.url)).map((p) => p.url);
  if (!ownStarts.length && /okpythia/i.test(q + body)) ownStarts.push("https://okpythia.com/");
  const crawled = [];
  for (const start of ownStarts.slice(0, 2)) {
    try { crawled.push(...await siteCrawl(start, { depth: 2, maxPages: 14 })); } catch {}
  }
  const pages = [...fetched, ...crawled];
  const uniq = [];
  const seen = new Set();
  for (const p of pages) {
    const key = (p.url || "").split("?")[0];
    if (!key || seen.has(key)) continue;
    seen.add(key);
    uniq.push(p);
  }
  uniq.sort((a, b) => pageScore(b, q) - pageScore(a, q));
  const best = uniq.find((p) => pageScore(p, q) > 0 && !/tragos\.ru|dtf\.ru/i.test(p.url || ""));
  return { url: best?.url || "", pages: uniq.slice(0, 8).map((p) => p.url), research: hits.slice(0, 6) };
}

function lessonTexts(retrieved, local) {
  const fromMem = (retrieved?.items || retrieved?.results || []).map((i) => String(i.content || i.text || i.body || i.title || ""));
  const fromFile = local.map((i) => String(i.rule || i.text || i.content || ""));
  return [...fromMem, ...fromFile].map((t) => t.replace(/\s+/g, " ").trim()).filter((t) => t.length > 8 && !poison(t) && !/tragos\.ru/i.test(t));
}

function answerFrom(subject, body, lessons, hunt) {
  const q = questionOf(subject, body);
  if (wantsUrl(q, body) && hunt?.url) return cleanReply(hunt.url);
  const pool = [...(hunt?.research || []), ...lessons].filter((t) => t && !poison(t));
  const ranked = pool.map((text) => ({ text, n: score(text, q) })).sort((a, b) => b.n - a.n);
  if (ranked[0] && ranked[0].n >= 2) {
    const line = cleanReply(ranked[0].text.split(". ").slice(0, 2).join(". "));
    const u = firstUrl(line);
    if (line && !(wantsUrl(q, body) && u && isRoot(u))) return line;
  }
  if (wantsUrl(q, body) && hunt?.url) return cleanReply(hunt.url);
  return cleanReply(q);
}

async function learn(subject, body, answer, fetched) {
  if (poison(answer)) return { skipped: "poison" };
  if (/tragos\.ru|dtf\.ru/i.test(answer)) return { skipped: "poison-url" };
  if (wantsUrl(questionOf(subject, body), body) && isRoot(answer) && /onecard|one-card|подстраниц|subpage/i.test(body)) {
    return { skipped: "homepage-not-product" };
  }
  if (wantsUrl(questionOf(subject, body), body) && firstUrl(answer) && !fetched) {
    return { skipped: "unfetched-url" };
  }
  const slug = String(subject || "lesson").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 48) || "lesson";
  const path = "school/" + slug + ".txt";
  let written = null;
  try { written = await job("workspace_write", { path, text: "Q: " + questionOf(subject, body) + "\nA: " + answer }); }
  catch (e) { written = { error: String(e.message || e) }; }
  let kid = "";
  try {
    const proposed = await job("knowledge_propose", { content: answer, kind: "lesson", tags: ["school", "mail", slug, "007"] });
    kid = knowledgeId(proposed);
    if (kid) {
      await job("knowledge_validate", { knowledgeId: kid, verdict: "accepted", evidence: path });
      await job("knowledge_promote", { knowledgeId: kid, reason: "school-007-fetched" });
    }
  } catch {}
  appendLesson({ at: new Date().toISOString(), subject, rule: answer, path, knowledgeId: kid || null });
  return { path, written, knowledgeId: kid || null };
}

const listed = await job("mail_list", { limit: 40 });
const msgs = listed.messages || listed.items || listed.mail || [];
const edu = msgs.filter((m) => /Pythia Education|BRIDGE Gate|Gate 10/i.test(String(m.subject || "")));
const state = loadState();
const known = new Set((state.uids || []).map(String));

if (mode === "seed") {
  for (const m of edu) known.add(String(m.uid));
  saveState({ uids: [...known], seededAt: new Date().toISOString() });
  console.log(JSON.stringify({ seeded: known.size }));
  process.exit(0);
}

const local = loadLocalLessons();
const out = [];
for (const m of edu) {
  const uid = String(m.uid);
  if (known.has(uid)) continue;
  const read = await job("mail_read", { uid: Number.parseInt(uid, 10) });
  const body = String(read.body || read.text || read.result?.body || "");
  const q = questionOf(m.subject, body);
  let retrieved = { items: [] };
  try { retrieved = await job("knowledge_retrieve", { query: q }); } catch {}
  const lessons = lessonTexts(retrieved, local);
  let hunt = { url: "", pages: [], research: [] };
  if (wantsUrl(q, body) || !lessons.some((t) => score(t, q) >= 3)) {
    try { hunt = await huntUrl(q, body); } catch (e) { hunt = { url: "", pages: [], research: ["hunt-error " + e.message] }; }
  }
  const text = cleanReply(answerFrom(m.subject, body, lessons, hunt)) || cleanReply(q);
  const learned = await learn(m.subject, body, text, Boolean(hunt.url));
  const sent = await job("mail_reply", { uid: Number.parseInt(uid, 10), text });
  known.add(uid);
  local.push({ rule: text, subject: m.subject });
  out.push({ uid, subject: m.subject, text, crawled: hunt.pages, learned, status: sent.status || sent });
}
saveState({ uids: [...known], updatedAt: new Date().toISOString() });
console.log(JSON.stringify({ replied: out.length, out }, null, 2));
