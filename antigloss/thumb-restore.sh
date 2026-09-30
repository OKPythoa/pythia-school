#!/bin/bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/style.css')
t=p.read_text(encoding='utf-8')
t=t.replace('.thumb{
  background:#111;
}','.thumb{
  background-color:#111;
}')
t=t.replace('background:#111!important;','background-color:#111!important;')
# do not let shorthand kill issue page thumbs
if 'thumb-restore' not in t:
    t += '''
/* thumb-restore */
.thumb{
  width:100%!important;
  height:180px!important;
  background-color:#111;
  background-size:cover!important;
  background-position:center!important;
  background-repeat:no-repeat!important;
}
.thumb img{
  width:100%!important;
  height:100%!important;
  object-fit:cover!important;
}
'''
p.write_text(t, encoding='utf-8')
print('restored')
PY
echo OK-restore
