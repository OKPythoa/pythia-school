#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html/admin/index.html
python3 - <<'PY'
from pathlib import Path
p=Path("/home/admin/domains/theantigloss.com/public_html/admin/index.html")
t=p.read_text(encoding="utf-8")
if "coverBoard-grid" not in t:
    css='''
#coverBoard{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.cover-row{display:flex;flex-direction:column;gap:8px;padding:10px;border:1px solid var(--line);margin:0}
.cover-thumb{width:100%;height:auto;aspect-ratio:3/4}
'''
    t=t.replace("</style>", "/* coverBoard-grid */"+css+"\n</style>", 1)
    p.write_text(t, encoding="utf-8")
    print("grid 2-col")
else:
    print("already 2-col")
PY
