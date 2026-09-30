#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/dec453c6729c08f04c7d93010583df81307a081f/antigloss/featured.js -o "$ROOT/assets/featured.js"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
idx=root/'index.html'
t=idx.read_text(encoding='utf-8')
if 'featured.js' not in t:
    t=t.replace('</head>','<script src="/assets/featured.js?v=2"></script></head>',1)
    idx.write_text(t, encoding='utf-8')
js=root/'assets'/'site.js'
s=js.read_text(encoding='utf-8')
s=s.replace('articles.slice(0,8)','articles.slice(1,9)')
js.write_text(s, encoding='utf-8')
css=root/'style.css'
c=css.read_text(encoding='utf-8')
if 'featured-once' not in c:
    c += '''
/* featured-once */
.feat-kicker{margin:0 0 12px;color:#c91520;font-size:11px;font-weight:800;letter-spacing:.16em;text-transform:uppercase}
.herotext h1{font-size:clamp(34px,4.6vw,58px);line-height:.96;max-width:14ch;font-weight:500}
.herotext h1 a{color:#f4f1ec;text-decoration:none}
.heroimg{background-size:cover;background-position:center 20%}
.adslot-wide{display:block;width:100%;height:200px;min-height:200px;max-height:200px}
.adslot-wide img{width:100%;height:100%;object-fit:cover}
'''
    css.write_text(c, encoding='utf-8')
print('featured-once')
PY
echo OK-featured-once
