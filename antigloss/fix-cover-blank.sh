#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/d08faf91d3dc87ac1b00548fc44a08361f20d37d/antigloss/issues.js -o "$ROOT/assets/issues.js"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
css=root/'style.css'
lines=[]
for line in css.read_text(encoding='utf-8',errors='replace').splitlines():
    if 'mc-logo' in line and 'display:none' in line.replace(' ',''):
        continue
    if '.issue-shade,.mc-logo' in line:
        continue
    lines.append(line)
text='\n'.join(lines)
text=text.replace('.issue-shade,.mc-logo,.mc-date,.mc-lines,.mc-bar{display:none!important}','')
if 'issue-cover-force' not in text:
    text += '''
/* issue-cover-force */
#currentIssueCover.cover{min-height:360px;background:#000}
#currentIssueCover .mc-logo,
#currentIssueCover .mc-date,
#currentIssueCover .mc-lines,
#currentIssueCover .mc-bar{display:block!important;visibility:visible!important;opacity:1!important}
#currentIssueCover img{display:block!important;width:100%!important;height:100%!important;object-fit:cover!important}
'''
css.write_text(text+'\n', encoding='utf-8')
js=root/'assets'/'issues.js'
j=js.read_text(encoding='utf-8')
if "document.readyState" not in j:
    j=j.replace("document.addEventListener('DOMContentLoaded',()=>run().catch(console.error));",
                "if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',()=>run().catch(console.error));else run().catch(console.error);")
    js.write_text(j, encoding='utf-8')
html=root/'index.html'
h=html.read_text(encoding='utf-8')
h=h.replace('src="assets/issues.js"','src="/assets/issues.js?v=force2"')
h=h.replace('href="style.css?v=20260709-magazine-1"','href="style.css?v=force2"')
html.write_text(h, encoding='utf-8')
print('fixed')
PY
echo OK-blank-fix
