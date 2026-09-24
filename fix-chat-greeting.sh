#!/bin/bash
set -euo pipefail
GW=/opt/pythia-brain-v2/src/gateway.mjs
if [ ! -f "$GW" ]; then
  GW=$(find /opt -name gateway.mjs 2>/dev/null | head -n 1 || true)
fi
[ -n "$GW" ] && [ -f "$GW" ] || { echo NO_GATEWAY; exit 1; }
cp -a "$GW" "$GW.bak-greeting-$(date +%Y%m%d%H%M%S)"
python3 - "$GW" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
MARK = "PYTHIA_STRIP_SESSION_GREETING_V1"
if MARK in s:
    print("already", p)
    raise SystemExit(0)
inject = r'''
/* PYTHIA_STRIP_SESSION_GREETING_V1 */
function pythiaStripSessionGreeting(text) {
  let t = String(text ?? "");
  const lead = /^\s*(?:привет|здравствуй(?:те)?|добр(?:ое\s+утро|ый\s+день|ый\s+вечер)|hello|hi|hey)\s*[!!.?\u2026\u263a\u1f60a\u1f642]*\s*/iu;
  for (let i = 0; i < 3; i++) {
    const next = t.replace(lead, "");
    if (next === t) break;
    t = next;
  }
  t = t.replace(/^\s+/, "");
  if (!t) return String(text ?? "");
  if (/^[а-яё]/u.test(t)) t = t.charAt(0).toLocaleUpperCase("ru") + t.slice(1);
  return t;
}
function pythiaWalkStripGreeting(value) {
  if (typeof value === "string") return pythiaStripSessionGreeting(value);
  if (!value || typeof value !== "object") return value;
  if (Array.isArray(value)) return value.map(pythiaWalkStripGreeting);
  const out = Array.isArray(value) ? [] : { ...value };
  for (const key of Object.keys(value)) {
    const v = value[key];
    if (["finalText", "final_text", "response", "text", "answer", "content", "message"].includes(key) && typeof v === "string") {
      out[key] = pythiaStripSessionGreeting(v);
    } else if (v && typeof v === "object") {
      out[key] = pythiaWalkStripGreeting(v);
    } else {
      out[key] = v;
    }
  }
  return out;
}
'''
# wrap JSON.stringify used for replies if present
if "JSON.stringify" in s:
    s = s.replace("JSON.stringify(", "JSON.stringify(pythiaWalkStripGreeting(")
    # that may over-wrap; only first few is dangerous. Safer: wrap res.end payloads via stringify of objects we already walk at return sites.
# Revert blind stringify wrap — too wide. Inject helper only + wrap explicit final fields via assignment hook at file top after imports.
s = p.read_text(encoding="utf-8")
if MARK in s:
    print("already", p)
    raise SystemExit(0)
# insert after first import block or at top
if s.startswith("import "):
    lines = s.splitlines(True)
    i = 0
    while i < len(lines) and (lines[i].startswith("import ") or lines[i].startswith("const ") and "require" in lines[i] or lines[i].strip() == ""):
        i += 1
        if i > 40:
            break
    s = "".join(lines[:i]) + inject + "\n" + "".join(lines[i:])
else:
    s = inject + "\n" + s
# wrap common return object fields by post-processing HTTP json writes
# Node http: res.end(JSON.stringify(
needle = "res.end(JSON.stringify("
if needle in s:
    s = s.replace(needle, "res.end(JSON.stringify(pythiaWalkStripGreeting(")
needle2 = "res.write(JSON.stringify("
if needle2 in s:
    s = s.replace(needle2, "res.write(JSON.stringify(pythiaWalkStripGreeting(")
# also typical return { kind: "final"
if "kind: \"final\"" in s or "kind: 'final'" in s:
    s = s.replace(
        "function pythiaWalkStripGreeting(value) {",
        "function pythiaWalkStripGreeting(value) {",
    )
p.write_text(s, encoding="utf-8")
print("patched", p)
PY
# second pass: if no res.end hook landed, wrap module export send helpers via node syntax check only
node --check "$GW"
systemctl restart pythia-canonical-transport.service 2>/dev/null || true
systemctl restart pythia-brain-v2.service 2>/dev/null || true
echo OK "$GW"
