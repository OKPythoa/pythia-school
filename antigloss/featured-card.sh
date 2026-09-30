#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/40aa6aeff179990f533e4165dfab004601152ab0/antigloss/featured.js -o "$ROOT/assets/featured.js"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
idx=root/'index.html'
t=idx.read_text(encoding='utf-8')
for i in range(1,6):
    t=t.replace('featured.js?v='+str(i),'featured.js?v=5')
if 'featured.js' not in t:
    t=t.replace('</head>','<script src="/assets/featured.js?v=5"></script></head>',1)
idx.write_text(t, encoding='utf-8')
css=root/'style.css'
c=css.read_text(encoding='utf-8')
if 'featured-hcard' not in c:
    c += '''
/* featured-hcard */
.hero-featured{border-bottom:1px solid rgba(255,255,255,.1)}
.hero-featured .heroinner{
  display:grid;
  grid-template-columns:minmax(240px,38%) minmax(0,62%);
  grid-template-areas:"copy art";
  gap:28px;
  align-items:center;
  min-height:0!important;
  padding:22px 0;
}
.hero-featured .herotext{grid-area:copy;padding:8px 0;max-width:none}
.hero-featured .heroimg{grid-area:art;min-height:0!important;height:auto!important;background:transparent!important;overflow:hidden;border:1px solid rgba(255,255,255,.1)}
.hero-featured .heroimg a{display:block;line-height:0}
.hero-featured .heroimg img{display:block;width:100%;height:auto;max-height:340px;object-fit:contain;background:#070708}
.feat-kicker{margin:0 0 8px;color:#c91520;font-size:11px;font-weight:800;letter-spacing:.14em;text-transform:uppercase}
.feat-title{margin:0 0 10px;font-family:Georgia,"Times New Roman",serif;font-size:clamp(22px,2.4vw,32px);line-height:1.12;font-weight:500}
.feat-title a{color:#f4f1ec}
.feat-dek{margin:0 0 10px;color:rgba(244,241,236,.72);font-size:15px;line-height:1.45}
.feat-meta{margin:0 0 16px;color:rgba(244,241,236,.45);font-size:13px}
@media(max-width:800px){
  .hero-featured .heroinner{grid-template-columns:1fr;grid-template-areas:"art" "copy"}
}
'''
    css.write_text(c, encoding='utf-8')
print('hcard')
PY
echo OK-hcard
