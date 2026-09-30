#!/bin/bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
p = Path('/home/admin/domains/theantigloss.com/public_html/style.css')
lines = p.read_text(encoding='utf-8').splitlines(True)
drop = {
    'ad-frame-magazine', 'hero-banner-fix', 'hero-ad-fit', 'ad-hug',
    'ad-original', 'ad-kit-sizes', 'featured-stack'
}
out = []
skip = False
for line in lines:
    if line.startswith('/* ') and '*/' in line:
        name = line.strip()[2:].split('*/')[0].strip()
        skip = name in drop
        if skip:
            continue
    if skip:
        continue
    out.append(line)
text = ''.join(out)
if 'ads-untouch' not in text:
    text += '''
/* ads-untouch */
.ad-wrap{width:min(calc(100% - 48px),var(--max));margin:16px auto 0;padding:0}
.adslot{position:relative;display:flex;align-items:center;justify-content:center;overflow:hidden;border:1px solid rgba(255,255,255,.18)}
.adslot-wide{min-height:250px;height:250px;max-height:250px;width:100%}
.adslot-feed{min-height:120px;margin:18px 0}
.adslot-article{min-height:90px;margin:38px 0}
.adslot a{display:block;width:100%;height:100%}
.adslot img{display:block;width:100%;height:100%;object-fit:cover;filter:none}
@media(max-width:680px){.adslot-wide{min-height:150px;height:150px;max-height:150px}}
'''
p.write_text(text, encoding='utf-8')
print('ads restored original')
PY
echo OK-untouch
