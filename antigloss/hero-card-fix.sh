#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/40aa6aeff179990f533e4165dfab004601152ab0/antigloss/featured.js -o "$ROOT/assets/featured.js"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
idx=root/'index.html'
t=idx.read_text(encoding='utf-8')
for i in range(1,8):
    t=t.replace('featured.js?v='+str(i),'featured.js?v=6')
if 'featured.js' not in t:
    t=t.replace('</head>','<script src="/assets/featured.js?v=6"></script></head>',1)
idx.write_text(t, encoding='utf-8')
css=root/'style.css'
c=css.read_text(encoding='utf-8')
if 'hero-card-fix' not in c:
    c += '''
/* hero-card-fix */
.hero-featured .heroinner{
  display:grid!important;
  grid-template-columns:minmax(240px,38%) minmax(0,62%)!important;
  grid-template-areas:"copy art"!important;
  gap:28px!important;
  align-items:center!important;
  min-height:0!important;
  padding:22px 0!important;
}
.hero-featured .herotext{grid-area:copy!important;display:block!important;padding:8px 0!important}
.hero-featured .heroimg{grid-area:art!important;min-height:0!important;height:auto!important;max-height:none!important;overflow:hidden!important;background:transparent!important}
.hero-featured .heroimg img{width:100%!important;height:auto!important;max-height:340px!important;object-fit:contain!important;display:block!important}
.feat-kicker,.feat-title,.feat-dek,.feat-meta{display:block!important}
'''
    css.write_text(c, encoding='utf-8')
print('hero-card-fix')
PY
echo OK-hero-card
