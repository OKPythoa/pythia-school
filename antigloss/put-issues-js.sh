#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/5d63eadf474eedaaadcd839bd8c2427bc2c14a99/antigloss/issues.js -o "$ROOT/assets/issues.js"
chown admin:admin "$ROOT/assets/issues.js" || true
python3 - <<'PY'
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/index.html')
h=p.read_text(encoding='utf-8')
for old in ['src="assets/issues.js"','src="/assets/issues.js"','src="/assets/issues.js?v=20260930v"','src="/assets/issues.js?v=force2"']:
    h=h.replace(old,'src="/assets/issues.js?v=ok1"')
p.write_text(h, encoding='utf-8')
print('js bytes', Path('/home/admin/domains/theantigloss.com/public_html/assets/issues.js').stat().st_size)
PY
echo OK-js
