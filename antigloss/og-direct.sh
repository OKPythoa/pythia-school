#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
python3 - <<'PY'
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/index.html')
t=p.read_text(encoding='utf-8')
t=t.replace('https://theantigloss.com/api/og-cover.php','https://theantigloss.com/assets/issues/2026-09.png')
if 'og:image:width' not in t:
    t=t.replace(
        '<meta property="og:image:type" content="image/png">',
        '<meta property="og:image:type" content="image/png">\n<meta property="og:image:width" content="1200">\n<meta property="og:image:height" content="1800">'
    )
p.write_text(t, encoding='utf-8')
print('og image -> png')
PY
echo OK-og-direct
