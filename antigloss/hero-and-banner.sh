#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/dec453c6729c08f04c7d93010583df81307a081f/antigloss/featured.js -o "$ROOT/assets/featured.js"
chown admin:admin "$ROOT/assets/featured.js" || true
python3 - <<'PY'
from pathlib import Path
idx=Path('/home/admin/domains/theantigloss.com/public_html/index.html')
t=idx.read_text(encoding='utf-8')
if 'assets/featured.js' not in t:
    t=t.replace('<script src="assets/site.js','<script src="/assets/featured.js?v=1"></script>\n<script src="assets/site.js',1)
    if 'assets/featured.js' not in t:
        t=t.replace('</head>','<script src="/assets/featured.js?v=1"></script></head>',1)
    idx.write_text(t, encoding='utf-8')
    print('script tagged')
else:
    print('script exists')
css=Path('/home/admin/domains/theantigloss.com/public_html/style.css')
s=css.read_text(encoding='utf-8')
if 'hero-banner-fix' not in s:
    s += '''
/* hero-banner-fix */
.feat-kicker{margin:0 0 10px;color:#c91520;font-size:11px;font-weight:800;letter-spacing:.16em;text-transform:uppercase}
.herotext h1{font-size:clamp(36px,5vw,64px);line-height:.95;max-width:16ch}
.herotext h1 a{color:inherit}
.ad-wrap{width:min(calc(100% - 48px),var(--max))!important;margin:0 auto!important;padding:20px 0 8px!important}
.adslot-wide{display:block!important;width:100%!important;height:200px!important;min-height:200px!important;max-height:200px!important}
.adslot-wide a{display:block;width:100%;height:100%}
.adslot-wide img{width:100%!important;height:100%!important;object-fit:cover!important;filter:saturate(.7) brightness(.9)!important}
@media(max-width:680px){.adslot-wide{height:140px!important;min-height:140px!important;max-height:140px!important}}
'''
    css.write_text(s, encoding='utf-8')
    print('css added')
else:
    print('css exists')
PY
echo OK-hero-banner
