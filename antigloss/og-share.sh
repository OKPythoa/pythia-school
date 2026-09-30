#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/2943a9966cf122ec178d1fdf229502dd6737ec42/antigloss/og-cover.php -o "$ROOT/api/og-cover.php"
chown admin:admin "$ROOT/api/og-cover.php" || true
chmod 644 "$ROOT/api/og-cover.php"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
tags='''<meta property="og:type" content="website">
<meta property="og:site_name" content="The AntiGloss">
<meta property="og:title" content="The AntiGloss">
<meta property="og:description" content="Alternative. Unapologetic. Real. An independent magazine about style, culture, image and status.">
<meta property="og:url" content="https://theantigloss.com/">
<meta property="og:image" content="https://theantigloss.com/api/og-cover.php">
<meta property="og:image:type" content="image/png">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="The AntiGloss">
<meta name="twitter:image" content="https://theantigloss.com/api/og-cover.php">
'''
for name in ('index.html','issue.html'):
    p=root/name
    if not p.exists():
        continue
    t=p.read_text(encoding='utf-8')
    if 'og-cover.php' in t or 'property="og:image"' in t:
        print(name,'og exists')
        continue
    if '<head>' in t:
        t=t.replace('<head>','<head>\n'+tags,1)
    elif '<head ' in t:
        i=t.find('>')
        # after first head tag close
        i=t.find('>', t.find('<head'))+1
        t=t[:i]+'\n'+tags+t[i:]
    else:
        print(name,'no head')
        continue
    p.write_text(t, encoding='utf-8')
    print(name,'og inserted')
PY
echo OK-og
