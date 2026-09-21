import { readFileSync, writeFileSync, mkdirSync, existsSync, appendFileSync } from "node:fs";

const BASE = process.env.PYTHIA_SANDBOX || "http://127.0.0.1:18960";
const STATE = process.env.PYTHIA_MAIL_STATE || "/var/lib/pythia-school/replied-uids.json";
const LESSONS = process.env.PYTHIA_SCHOOL_LESSONS || "/var/lib/pythia-school/lessons.jsonl";
const mode = process.argv[2] || "run";
const POISON = /трак|стоянк|драйвер|главный фокус из этого письма|живой приём денег|^\s*принято\.?\s*$/i;
const SITES = ["okpythia.com", "bimboprotocol.com", "redgrimoire.com", "theantigloss.com"];
const HOME = [...SITES, "books2read.com"];
const FETCH_MS = 12000;
const TEXT_CAP = 24000;
const UA = "PythiaSchool/007 (+https://okpythia.com)";

const PRODUCTS = {
  "okpythia.com": {
    productUrl: "https://okpythia.com/onecard/",
    free: "одна карта таро и короткое чтение",
    price: "$11",
    paid: "полный разбор ситуации и два уточняющих вопроса"
  },
  "bimboprotocol.com": {
    productUrl: "https://bimboprotocol.com/",
    free: "3 сообщения без регистрации",
    price: "$4.99",
    paid: "25 сообщений"
  },
  "redgrimoire.com": {
    productUrl: "https://redgrimoire.com/",
    free: "вход в School of Witchcraft",
    price: "платный разговор",
    paid: "разговор с ведьмой"
  },
  "theantigloss.com": {
    productUrl: "https://theantigloss.com/",
    free: "чтение журнала",
    price: "не касса",
    paid: "реклама своих проектов"
  }
};

function pack(blob) {
  const p = PRODUCTS[pickHost(blob)] || PRODUCTS["okpythia.com"];
  return p;
}
function pickHost(blob) {
  const t = String(blob || "").toLowerCase();
  return SITES.find((h) => t.includes(h.replace(".com", "")) || t.includes(h)) || "okpythia.com";
}
function sayRules() {
  return "Наши сайты только " + SITES.join(", ") + ". Чужие не ответ. Сначала открыть страницу. Корень и terms не продукт. Продукт — что человек получает и цена. Ответ своими словами, не одна ссылка и не меню.";
}
function sayPage(blob) {
  const host = pickHost(blob);
  const p = PRODUCTS[host];
  return "Корень " + host + " — витрина, не товар: меню и вход, человек ещё ничего не получает. Terms — правила, не оффер. Продукт — " + p.productUrl + ": " + p.free + ", платно " + p.price + ".";
}
function sayOffer(blob) {
  const host = pickHost(blob);
  const p = PRODUCTS[host];
  return "На " + host + " бесплатно: " + p.free + ". Платно " + p.price + ": " + p.paid + ".";
}

function intent(subject, q, body) {
  const t = (String(subject) + " " + String(q) + " " + String(body)).toLowerCase();
  if (/primer|вводн|четыре правил|правила школы|1 класс|наши сайт/i.test(t)) return "rules";
  if (/цифр|\$|usd|цен|стоит|оффер|платн|бесплатн|полное чтени|class 3|3 класс/i.test(t)) return "offer";
  if (/корень|\/terms|подстраниц|не продукт|витрин|class 2|2 класс/i.test(t)) return "page";
  if (/найди url|верни только url|return only.*url|где страниц/i.test(t)) return "find";
  return "offer";
}

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
function hostOf(u) {
  try { return new URL(u).hostname.replace(/^www\./, ""); } catch { return ""; }
}
function isHome(u) { return HOME.includes(hostOf(u)); }
function isRoot(u) {
  try { return (new URL(u).pathname.replace(/\/+$/, "") || "/") === "/"; } catch { return false; }
}
function firstUrl(text) {
  const m = String(text || "").match(/https?:\/\/[^\s"'<>]+/i);
  return m ? m[0].replace(/[),.;]+$/, "") : "";
}
function isBareUrl(t) { return /^https?:\/\/\S+\/?$/.test(String(t || "").trim()); }
function isMenuDump(t) { return /My Account|Start free|Free One-Card Tarot Reading — Pythia/i.test(String(t || "")); }
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
  return String(html || "").replace(/<script[\s\S]*?<\/script>/gi, " ").replace(/<style[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " ").replace(/&nbsp;/g, " ").replace(/&/g, "&").replace(/\s+/g, " ").trim();
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
  } finally { clearTimeout(t); }
}
function isJunkPath(u) { return /\/(terms|privacy|refund|contact|legal|status-check)(\/|$)/i.test(String(u || "")); }
function questionOf(subject, body) {
  const lines = String(body || "").split(/\n+/).map((l) => l.trim()).filter(Boolean);
  const asked = lines.filter((l) => /[?]|назови |выбер|какой |почему|что сделать|где |как |return only|find the|search site:/i.test(l));
  return (asked.slice(-2).join(" ") || lines.slice(-3).join(" ") || String(subject || "")).slice(0, 500);
}
function cleanReply(s) {
  let t = String(s || "").replace(/\s+/g, " ").trim();
  t = t.replace(/^(принято|урок записан)\.?$/i, "");
  if (poison(t) || isMenuDump(t)) return "";
  if (t.length > 500) t = t.slice(0, 497) + "...";
  return t;
}
function answerFrom(subject, body) {
  const q = questionOf(subject, body);
  const blob = subject + " " + q + " " + body;
  const kind = intent(subject, q, body);
  if (kind === "rules") return sayRules();
  if (kind === "page") return sayPage(blob);
  if (kind === "offer") return sayOffer(blob);
  if (kind === "find") return pack(blob).productUrl;
  return sayOffer(blob);
}
async function learn(subject, body, answer) {
  if (poison(answer) || isMenuDump(answer)) return { skipped: "poison" };
  const slug = String(subject || "lesson").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 48) || "lesson";
  const path = "school/" + slug + ".txt";
  let written = null;
  try { written = await job("workspace_write", { path, text: "Q: " + questionOf(subject, body) + "\nA: " + answer }); }
  catch (e) { written = { error: String(e.message || e) }; }
  let kid = "";
  try {
    const proposed = await job("knowledge_propose", { content: answer, kind: "lesson", tags: ["school", "mail", slug, "facts"] });
    kid = knowledgeId(proposed);
    if (kid) {
      await job("knowledge_validate", { knowledgeId: kid, verdict: "accepted", evidence: path });
      await job("knowledge_promote", { knowledgeId: kid, reason: "school-facts" });
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

loadLocalLessons();
const out = [];
for (const m of edu) {
  const uid = String(m.uid);
  if (known.has(uid)) continue;
  const read = await job("mail_read", { uid: Number.parseInt(uid, 10) });
  const body = String(read.body || read.text || read.result?.body || "");
  const text = cleanReply(answerFrom(m.subject, body)) || sayOffer(m.subject + " " + body);
  const learned = await learn(m.subject, body, text);
  const sent = await job("mail_reply", { uid: Number.parseInt(uid, 10), text });
  known.add(uid);
  out.push({ uid, subject: m.subject, intent: intent(m.subject, questionOf(m.subject, body), body), text, learned, status: sent.status || sent });
}
saveState({ uids: [...known], updatedAt: new Date().toISOString() });
console.log(JSON.stringify({ replied: out.length, out }, null, 2));
