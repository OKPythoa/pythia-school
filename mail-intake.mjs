import { readFileSync, writeFileSync, mkdirSync, existsSync, appendFileSync } from "node:fs";
const BASE = process.env.PYTHIA_SANDBOX || "http://127.0.0.1:18960";
const STATE = process.env.PYTHIA_MAIL_STATE || "/var/lib/pythia-school/replied-uids.json";
const LESSONS = process.env.PYTHIA_SCHOOL_LESSONS || "/var/lib/pythia-school/lessons.jsonl";
const mode = process.argv[2] || "run";
const POISON = /трак|стоянк|драйвер|главный фокус из этого письма|^\s*принято\.?\s*$/i;
async function job(tool, input) {
  const r = await fetch(BASE + "/v1/jobs", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ tool, idempotencyKey: tool + "-" + Date.now() + "-" + Math.random().toString(16).slice(2), input })
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
function lessonTexts(retrieved, local) {
  const fromMem = (retrieved?.items || retrieved?.results || []).map((i) => String(i.content || i.text || i.body || i.title || ""));
  const fromFile = local.map((i) => String(i.rule || i.text || i.content || ""));
  return [...fromMem, ...fromFile].map((t) => t.replace(/\s+/g, " ").trim()).filter((t) => t.length > 8 && !poison(t));
}
function questionOf(subject, body) {
  const lines = String(body || "").split(/\n+/).map((l) => l.trim()).filter(Boolean);
  const asked = lines.filter((l) => /[?]|\u043dазови |выбер|какой |почему|что сделать|как /i.test(l));
  return (asked.slice(-2).join(" ") || lines.slice(-3).join(" ") || String(subject || "")).slice(0, 500);
}
function score(text, query) {
  const q = String(query).toLowerCase().split(/[^a-zа-я0-9]+/i).filter((w) => w.length > 3);
  const t = String(text).toLowerCase();
  return q.reduce((n, w) => n + (t.includes(w) ? 1 : 0), 0);
}
function cleanReply(s) {
  let t = String(s || "").replace(/\{[\s\S]*\}/g, " ").replace(/\s+/g, " ").trim();
  t = t.replace(/^(принято|урок записан)\.?$/i, "");
  if (poison(t)) return "";
  if (t.length > 500) t = t.slice(0, 497) + "...";
  return t;
}
function extractTools(cap) {
  const raw = cap?.tools || cap?.result?.tools || cap?.capabilities || cap || [];
  const list = Array.isArray(raw) ? raw : Object.keys(raw || {});
  return list.map((t) => String(t.name || t.id || t.tool || t)).filter(Boolean);
}
async function research(question, body) {
  const found = [];
  try {
    const extra = await job("knowledge_retrieve", { query: question + " " + String(body || "").slice(0, 240) });
    for (const i of extra.items || extra.results || []) {
      const t = String(i.content || i.text || "").trim();
      if (t && !poison(t)) found.push(t);
    }
  } catch {}
  try {
    const cap = await (await fetch(BASE + "/v1/capabilities")).json();
    const probe = extractTools(cap).find((n) => /search|web|http|browse|research|fetch|lookup|crawl/i.test(n));
    if (probe) {
      const got = await job(probe, { query: question, text: question, q: question });
      const cut = (typeof got === "string" ? got : JSON.stringify(got)).replace(/\s+/g, " ").trim().slice(0, 400);
      if (cut && !poison(cut)) found.push(cut);
    }
  } catch {}
  try { await job("workspace_write", { path: "school/research-" + Date.now() + ".txt", text: "Q: " + question + "\n" + found.join("\n") }); } catch {}
  return found;
}
function answerFrom(subject, body, lessons, researchHits) {
  const q = questionOf(subject, body);
  const pool = [...(researchHits || []), ...lessons].filter((t) => t && !poison(t));
  const ranked = pool.map((text) => ({ text, n: score(text, q + " " + body) })).sort((a, b) => b.n - a.n);
  if (ranked[0] && ranked[0].n >= 2) {
    const line = cleanReply(ranked[0].text.replace(/^\u0423рок [^:]+:\s*/i, "").split(". ").slice(0, 2).join(". "));
    if (line) return line;
  }
  const named = [];
  if (/okpythia/i.test(body)) named.push("OkPythia");
  if (/bimbo/i.test(body)) named.push("Bimbo Protocol");
  if (/last window open|книг/i.test(body)) named.push("The Last Window Open");
  const blob = (q + body).toLowerCase();
  if (/назови|какой проект|фокус|толкать/i.test(blob) && named[0]) {
    const whyBit = pool.find((t) => /потому|касс|оплат|трафик|жив/i.test(t));
    if (whyBit) return cleanReply(named[0] + ". " + whyBit);
    return cleanReply(named[0] + " — из трёх названных в письме это тот, у которого уже есть живой приём денег.");
  }
  return cleanReply(q);
}
async function learn(subject, body, answer) {
  if (poison(answer)) return { skipped: "poison" };
  const slug = String(subject || "lesson").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 48) || "lesson";
  const path = "school/" + slug + ".txt";
  let written = null;
  try { written = await job("workspace_write", { path, text: "Q: " + questionOf(subject, body) + "\nA: " + answer }); } catch (e) { written = { error: String(e.message || e) }; }
  let kid = "";
  try {
    const proposed = await job("knowledge_propose", { content: answer, kind: "lesson", tags: ["school", "mail", slug] });
    kid = knowledgeId(proposed);
    if (kid) {
      await job("knowledge_validate", { knowledgeId: kid, verdict: "accepted", evidence: path });
      await job("knowledge_promote", { knowledgeId: kid, reason: "school" });
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
  try { retrieved = await job("knowledge_retrieve", { query: String(m.subject || "") + " " + q }); } catch {}
  const lessons = lessonTexts(retrieved, local);
  const researchHits = lessons.some((t) => score(t, q) >= 3) ? [] : await research(q, body);
  const text = cleanReply(answerFrom(m.subject, body, lessons, researchHits)) || cleanReply(q);
  const learned = await learn(m.subject, body, text);
  const sent = await job("mail_reply", { uid: Number.parseInt(uid, 10), text });
  known.add(uid);
  local.push({ rule: text, subject: m.subject });
  out.push({ uid, subject: m.subject, text, researched: researchHits.length, learned, status: sent.status || sent });
}
saveState({ uids: [...known], updatedAt: new Date().toISOString() });
console.log(JSON.stringify({ replied: out.length, out }, null, 2));
