#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/4385b4d3c696ee7f224de004a50f9492c73a7230/antigloss/cover-admin.js -o "$ROOT/assets/cover-admin.js"
chown admin:admin "$ROOT/assets/cover-admin.js" || true
python3 - <<'PY'
from pathlib import Path
p=Path("/home/admin/domains/theantigloss.com/public_html/admin/index.html")
t=p.read_text(encoding="utf-8")
if "coverBoard-scroll" not in t:
    css='''
#coverBoard{max-height:640px;overflow:auto;padding-right:4px}
'''
    t=t.replace("</style>", "/* coverBoard-scroll */"+css+"\n</style>", 1)
    p.write_text(t, encoding="utf-8")
    print("scroll added")
else:
    print("scroll exists")
# bust cache on script tag
if "cover-admin.js" in t:
    import re
    t=Path("/home/admin/domains/theantigloss.com/public_html/admin/index.html").read_text(encoding="utf-8")
    t=re.sub(r'cover-admin\.js\?v=[^"]+','cover-admin.js?v=20260930d', t)
    Path("/home/admin/domains/theantigloss.com/public_html/admin/index.html").write_text(t, encoding="utf-8")
    print("cache bust")
PY
echo OK-stories-scroll
