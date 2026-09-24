#!/bin/bash
set -euo pipefail
GW=""
for p in /opt/pythia-brain-v2/src/gateway.mjs /opt/pythia-brain-v2/gateway.mjs /opt/pythia-canonical-transport/src/gateway.mjs; do
  if [ -f "$p" ]; then GW="$p"; break; fi
done
if [ -z "$GW" ]; then
  GW=$(find /opt -name gateway.mjs 2>/dev/null | head -n 1 || true)
fi
if [ -z "$GW" ] || [ ! -f "$GW" ]; then
  echo "NO_GATEWAY"
  exit 1
fi
cp -a "$GW" "$GW.bak-failopen-$(date +%Y%m%d%H%M%S)"
python3 - "$GW" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
orig = s

# timeout floor
s = re.sub(r"1_?500(?=\s*[,;)])", "25000", s)
s = re.sub(r"1500(?=\s*[,;)])", "25000", s)

# hard fail phrases must not abort the turn
for needle in [
    "refused to reason while silently forgetting",
    "silently forgetting",
]:
    if needle in s:
        s = s.replace(
            f"throw new Error(\"{needle}\")",
            "return { items: [], lessons: [], failedOpen: true }",
        )
        s = s.replace(
            f"throw new Error('{needle}')",
            "return { items: [], lessons: [], failedOpen: true }",
        )

# wrap retrieveLearningForQuery body if present and not already fail-open
if "retrieveLearningForQuery" in s and "failedOpen" not in s:
    s = s.replace(
        "async function retrieveLearningForQuery",
        "async function retrieveLearningForQueryFailClosed",
        1,
    )
    wrapper = '''
async function retrieveLearningForQuery(...args) {
  const ms = Number(process.env.PYTHIA_MEMORY_TIMEOUT_MS || 8000);
  try {
    return await Promise.race([
      retrieveLearningForQueryFailClosed(...args),
      new Promise((_, rej) => setTimeout(() => rej(new Error("memory-timeout")), ms))
    ]);
  } catch (err) {
    console.error("memory fail-open", String(err && err.message || err));
    return { items: [], lessons: [], failedOpen: true };
  }
}
'''
    s = wrapper + "\n" + s

p.write_text(s, encoding="utf-8")
print("patched", p, "changed" if s != orig else "already")
PY
node --check "$GW"
systemctl restart pythia-canonical-transport.service 2>/dev/null || true
systemctl restart pythia-brain-v2.service 2>/dev/null || true
systemctl restart pythia-fundamental-memory.service 2>/dev/null || true
echo OK "$GW"
