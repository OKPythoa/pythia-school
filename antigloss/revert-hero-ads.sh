#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
idx=root/'index.html'
t=idx.read_text(encoding='utf-8')
for s in [
    '<script src="/assets/featured.js?v=1"></script>\n',
    '<script src="/assets/featured.js?v=1"></script>',
    '<script src="assets/featured.js?v=1"></script>\n',
    '<script src="assets/featured.js"></script>',
]:
    t=t.replace(s,'')
idx.write_text(t, encoding='utf-8')
css=root/'style.css'
raw=css.read_text(encoding='utf-8')
markers=('ad-frame-magazine','magazine-skin-v1','hero-banner-fix')
lines=raw.splitlines(True)
out=[]
skip=False
for line in lines:
    if any('/* '+m in line or '/*'+m in line for m in markers):
        skip=True
        continue
    if skip and line.startswith('/* ') and '*/' in line:
        skip=False
        # new block starts, keep this line unless another marker
        if any(m in line for m in markers):
            skip=True
            continue
        out.append(line)
        continue
    if skip:
        continue
    out.append(line)
css.write_text(''.join(out), encoding='utf-8')
print('reverted hero/ads css+script')
PY
rm -f "$ROOT/assets/featured.js"
echo OK-reverted
