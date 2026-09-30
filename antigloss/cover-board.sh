#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/e973f0d09886a4f0c4f4b88fd258c68d51078474/antigloss/cover-admin.js -o "$ROOT/assets/cover-admin.js"
chown admin:admin "$ROOT/assets/cover-admin.js" || true
chmod 644 "$ROOT/assets/cover-admin.js"
python3 - <<'PY'
from pathlib import Path
p=Path("/home/admin/domains/theantigloss.com/public_html/admin/index.html")
t=p.read_text(encoding="utf-8")
if "cover-admin.js" not in t:
    t=t.replace("</body>", '<script src="/assets/cover-admin.js?v=20260930c"></script>\n</body>', 1)
    p.write_text(t, encoding="utf-8")
    print("script tag added")
else:
    print("script tag exists")
PY
grep -q 'cover-thumb' "$ROOT/admin/index.html" || python3 - <<'PY'
from pathlib import Path
p=Path("/home/admin/domains/theantigloss.com/public_html/admin/index.html")
t=p.read_text(encoding="utf-8")
css='''
.cover-row{display:grid;grid-template-columns:72px 1fr;gap:10px;padding:10px 0;border-bottom:1px solid var(--line)}
.cover-thumb{width:72px;height:96px;background:#111 center/cover no-repeat;border:1px solid var(--line)}
.cover-thumb.empty{background:#111}
.cover-meta{display:flex;flex-direction:column;gap:6px}
.cover-meta select,.cover-meta input{width:100%}
'''
t=t.replace("</style>", css+"\n</style>", 1)
p.write_text(t, encoding="utf-8")
print("cover css added")
PY
echo OK-cover-board
