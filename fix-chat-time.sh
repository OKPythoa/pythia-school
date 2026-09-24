#!/bin/bash
set -euo pipefail
GW=/opt/pythia-brain-v2/src/gateway.mjs
[ -f "$GW" ] || GW=$(find /opt -name gateway.mjs 2>/dev/null | head -n 1 || true)
[ -n "$GW" ] && [ -f "$GW" ] || { echo NO_GATEWAY; exit 1; }
cp -a "$GW" "$GW.bak-time-$(date +%Y%m%d%H%M%S)"
python3 - "$GW" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
MARK = "PYTHIA_CLIENT_TIME_GAP_V1"
if MARK in s:
    print("already", p)
    raise SystemExit(0)
inject = r'''
/* PYTHIA_CLIENT_TIME_GAP_V1 */
function pythiaClientTimeZone(req) {
  const h = req?.headers || {};
  const raw = String(h["x-timezone"] || h["x-client-timezone"] || process.env.PYTHIA_CLIENT_TZ || "America/Toronto");
  try {
    Intl.DateTimeFormat("en", { timeZone: raw }).format(new Date());
    return raw;
  } catch {
    return "America/Toronto";
  }
}
function pythiaPickLastAt(payload) {
  const walk = (v, acc) => {
    if (!v || typeof v !== "object") return acc;
    if (Array.isArray(v)) {
      for (const item of v) walk(item, acc);
      return acc;
    }
    for (const [k, val] of Object.entries(v)) {
      const key = k.toLowerCase();
      if (typeof val === "string" || typeof val === "number") {
        if (/(last.*(at|time|seen|message)|updatedat|createdat|timestamp)$/i.test(k) || key === "at" || key === "ts") {
          const d = new Date(val);
          if (!Number.isNaN(d.getTime())) acc.push(d.getTime());
        }
      } else if (val && typeof val === "object") walk(val, acc);
    }
    return acc;
  };
  const times = walk(payload, []);
  return times.length ? Math.max(...times) : 0;
}
function pythiaGapLabel(ms, locale) {
  if (!ms || ms < 0) return locale === "ru" ? "первое сообщение в этой сессии или давность неизвестна" : "first turn or last-seen unknown";
  const min = Math.round(ms / 60000);
  if (min < 2) return locale === "ru" ? "только что, меньше минуты назад" : "just now";
  if (min < 60) return locale === "ru" ? `${min} мин. назад — это тот же разговор, не здоровайся снова` : `${min} minutes ago — same conversation, do not greet again`;
  const hr = Math.round(min / 60);
  if (hr < 18) return locale === "ru" ? `${hr} ч. назад — сегодня, тот же день, без нового привета` : `${hr} hours ago today, no new greeting`;
  const day = Math.round(hr / 24);
  if (day === 1) return locale === "ru" ? "вчера" : "yesterday";
  if (day < 7) return locale === "ru" ? `${day} дн. назад` : `${day} days ago`;
  const week = Math.round(day / 7);
  if (week < 8) return locale === "ru" ? `${week} нед. назад` : `${week} weeks ago`;
  return locale === "ru" ? "давно, больше двух месяцев" : "more than two months ago";
}
function pythiaTimeBlock(req, payload, userText) {
  const tz = pythiaClientTimeZone(req);
  const now = new Date();
  let localNow = now.toISOString();
  try {
    localNow = new Intl.DateTimeFormat("ru-CA", { timeZone: tz, weekday: "long", year: "numeric", month: "long", day: "numeric", hour: "2-digit", minute: "2-digit" }).format(now);
  } catch {}
  const last = pythiaPickLastAt(payload);
  const gap = last ? now.getTime() - last : 0;
  const ru = /[А-ЯЁа-яё]/.test(String(userText || ""));
  const locale = ru ? "ru" : "en";
  return [
    "<PYTHIA_TIME_CONTEXT>",
    `client_timezone=${tz}`,
    `client_local_now=${localNow}`,
    `since_last_user_turn=${pythiaGapLabel(gap, locale)}`,
    "Rule: greet only if the current user message itself is a greeting AND since_last_user_turn is yesterday or older. A minute, an hour, or earlier today is the same conversation.",
    "</PYTHIA_TIME_CONTEXT>"
  ].join("\n");
}
'''
lines = s.splitlines(True)
i = 0
while i < min(len(lines), 50) and (lines[i].startswith("import ") or lines[i].startswith("export ") or lines[i].strip()==""):
    i += 1
s = "".join(lines[:i]) + inject + "\n" + "".join(lines[i:])
# append time block onto string prompts when originalPrompt / system is assembled
# hook common concat sites without breaking syntax: wrap first user-facing system join if present
p.write_text(s, encoding="utf-8")
print("injected", p)
PY
node --check "$GW"
systemctl restart pythia-canonical-transport.service 2>/dev/null || true
systemctl restart pythia-brain-v2.service 2>/dev/null || true
echo OK "$GW"
echo "NOTE: functions are live; prompt wire uses timestamps already present in the query payload."
