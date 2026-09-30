#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/6a053e2088f411c5e873dad8b0170cb52190fcc3/antigloss/featured.js -o "$ROOT/assets/featured.js"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
idx=root/'index.html'
t=idx.read_text(encoding='utf-8')
t=t.replace('/assets/featured.js?v=1','/assets/featured.js?v=3')
t=t.replace('/assets/featured.js?v=2','/assets/featured.js?v=3')
if 'featured.js' not in t:
    t=t.replace('</head>','<script src="/assets/featured.js?v=3"></script></head>',1)
idx.write_text(t, encoding='utf-8')
css=root/'style.css'
c=css.read_text(encoding='utf-8')
if 'hero-ad-fit' not in c:
    c += '''
/* hero-ad-fit */
.heroinner{min-height:0;align-items:center}
.herotext{padding:28px 0}
.feat-kicker{margin:0 0 12px;color:#c91520;font-size:11px;font-weight:800;letter-spacing:.16em;text-transform:uppercase}
.feat-dek{max-width:34ch;color:rgba(244,241,236,.78);font-size:16px;line-height:1.45}
.heroimg{min-height:0!important;background:none!important;display:flex;align-items:center;justify-content:center}
.heroimg a{display:block;width:100%}
.heroimg img{display:block;width:100%;height:auto;max-height:58vh;object-fit:contain}
.ad-wrap{width:min(calc(100% - 48px),var(--max));margin:0 auto;padding:16px 0}
.adslot-wide{display:block!important;width:100%!important;height:auto!important;min-height:0!important;max-height:none!important;background:#070708}
.adslot-wide a{display:block;width:100%;height:auto}
.adslot-wide img{width:100%!important;height:auto!important;max-height:160px;object-fit:contain!important;filter:none!important}
'''
    css.write_text(c, encoding='utf-8')
print('fit')
PY
echo OK-fit
