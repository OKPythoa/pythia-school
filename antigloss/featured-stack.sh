#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/fd280bc5cacf238b53080e105ad096dbd137537f/antigloss/featured.js -o "$ROOT/assets/featured.js"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
idx=root/'index.html'
t=idx.read_text(encoding='utf-8')
for old in ['featured.js?v=1','featured.js?v=2','featured.js?v=3']:
    t=t.replace(old,'featured.js?v=4')
if 'featured.js' not in t:
    t=t.replace('</head>','<script src="/assets/featured.js?v=4"></script></head>',1)
idx.write_text(t, encoding='utf-8')
js=root/'assets'/'site.js'
s=js.read_text(encoding='utf-8')
s=s.replace('articles.slice(0,8)','articles.slice(1,9)')
js.write_text(s, encoding='utf-8')
css=root/'style.css'
c=css.read_text(encoding='utf-8')
if 'featured-stack' not in c:
    c += '''
/* featured-stack */
.hero-featured .heroinner{display:grid;grid-template-columns:1fr;grid-template-areas:"art" "copy";min-height:0;gap:16px;padding:18px 0 8px}
.hero-featured .heroimg{grid-area:art;min-height:0!important;background:none!important}
.hero-featured .herotext{grid-area:copy;padding:0 0 8px;max-width:720px}
.hero-featured .heroimg img{width:100%;height:auto;max-height:62vh;object-fit:contain;display:block}
.feat-kicker{margin:0 0 8px;color:#c91520;font-size:11px;font-weight:800;letter-spacing:.16em;text-transform:uppercase}
.feat-dek{margin:0 0 14px;max-width:60ch;color:rgba(244,241,236,.8);font-size:16px;line-height:1.45}
.ad-wrap{width:min(calc(100% - 48px),var(--max));margin:8px auto 0;padding:0}
.adslot.adslot-wide,.adslot-wide{display:block!important;width:100%!important;height:auto!important;min-height:0!important;max-height:none!important;padding:0!important;background:transparent!important;border:1px solid rgba(255,255,255,.1)!important}
.adslot-wide:before{position:static;display:block;padding:6px 0 4px}
.adslot-wide a{display:block;width:100%;line-height:0}
.adslot-wide img{display:block!important;width:100%!important;height:auto!important;max-height:none!important;object-fit:contain!important}
'''
    css.write_text(c, encoding='utf-8')
print('stacked')
PY
echo OK-stack
