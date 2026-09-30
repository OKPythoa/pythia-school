#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
css=root/'style.css'
c=css.read_text(encoding='utf-8')
if 'thumb-full' not in c:
    c += '''
/* thumb-full */
.thumb,.card .thumb{
  width:100%!important;
  height:180px!important;
  aspect-ratio:auto!important;
  overflow:hidden!important;
  background:#111!important;
}
.thumb img,.card .thumb img{
  width:100%!important;
  height:100%!important;
  object-fit:cover!important;
  display:block!important;
}
'''
    css.write_text(c, encoding='utf-8')
for name in ('issue.html','latest.html','index.html','fashion.html','culture.html','society.html','image.html','relationships.html'):
    p=root/name
    if not p.exists():
        continue
    t=p.read_text(encoding='utf-8')
    t=t.replace('style.css?v=20260813-issues-1','style.css?v=coal2')
    t=t.replace('style.css?v=20260709-magazine-1','style.css?v=coal2')
    t=t.replace('style.css?v=force2','style.css?v=coal2')
    if 'style.css' in t and 'style.css?v=coal2' not in t:
        t=t.replace('href="style.css"','href="style.css?v=coal2"')
    p.write_text(t, encoding='utf-8')
print('thumbs full')
PY
echo OK-thumbs
