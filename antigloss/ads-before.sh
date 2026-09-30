#!/bin/bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
p = Path('/home/admin/domains/theantigloss.com/public_html/style.css')
lines = p.read_text(encoding='utf-8').splitlines(True)
kill = {
    'ad-frame-magazine','hero-banner-fix','hero-ad-fit','ad-hug',
    'ad-original','ad-kit-sizes','featured-stack','ads-untouch'
}
out=[]; skip=False
for line in lines:
    if line.startswith('/* ') and '*/' in line:
        name=line.strip()[2:].split('*/')[0].strip()
        skip = name in kill
        if skip:
            continue
    if skip:
        continue
    out.append(line)
text=''.join(out)
text += '''
/* ads-before */
.ad-wrap{width:min(calc(100% - 48px),var(--max))!important;margin:16px auto 0!important;padding:0!important}
.adslot.adslot-wide,.adslot-wide{
  display:block!important;
  width:100%!important;
  height:auto!important;
  min-height:0!important;
  max-height:none!important;
  aspect-ratio:auto!important;
  overflow:hidden;
  border:1px solid rgba(255,255,255,.18);
  background:#111!important;
}
.adslot-wide a{display:block;width:100%;height:auto;line-height:0}
.adslot-wide img{
  display:block!important;
  width:100%!important;
  height:auto!important;
  max-height:none!important;
  object-fit:contain!important;
  filter:none!important;
}
'''
p.write_text(text, encoding='utf-8')
print('ads-before')
PY
echo OK-before
