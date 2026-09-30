#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/d08faf91d3dc87ac1b00548fc44a08361f20d37d/antigloss/issues.js -o "$ROOT/assets/issues.js"
python3 - <<'PY'
from pathlib import Path
root=Path('/home/admin/domains/theantigloss.com/public_html')
css=root.joinpath('style.css')
t=css.read_text(encoding='utf-8')
kill='.issue-shade,.mc-logo,.mc-date,.mc-lines,.mc-bar{display:none!important}'
t=t.replace(kill,'')
if 'issue-cover-visible' not in t:
    t += '''
/* issue-cover-visible */
.cover{width:100%!important;aspect-ratio:3/4!important;padding:0!important;overflow:hidden!important;background:#000!important}
.magazine-cover,.issue-frame{display:block!important;width:100%!important;height:100%!important;position:relative!important}
.issue-frame img{width:100%!important;height:100%!important;object-fit:cover!important;object-position:center 16%!important;display:block!important}
.mc-logo,.mc-date,.mc-lines,.mc-bar{display:block!important}
.mc-logo{position:absolute!important;top:2%!important;left:1%!important;right:1%!important;text-align:center!important;z-index:5!important}
.mc-logo i{display:block!important;font-style:normal!important;font-family:Georgia,serif!important;font-size:11px!important;letter-spacing:.5em!important;text-transform:uppercase!important;color:#fff!important}
.mc-logo b{display:block!important;font-family:Georgia,serif!important;color:#b01018!important;font-size:clamp(28px,8.8vw,46px)!important;line-height:.76!important;text-transform:uppercase!important}
.mc-date{position:absolute!important;top:2%!important;right:3%!important;z-index:5!important;font-size:8px!important;letter-spacing:.14em!important;text-transform:uppercase!important;color:#fff!important}
.mc-lines{position:absolute!important;left:6%!important;bottom:17%!important;width:62%!important;z-index:5!important}
.mc-lines span{display:block!important;font-family:Georgia,serif!important;font-weight:700!important;font-size:clamp(16px,5vw,24px)!important;line-height:.86!important;text-transform:uppercase!important;color:#fff!important;text-shadow:0 2px 10px #000!important}
.mc-bar{position:absolute!important;right:4%!important;bottom:3.5%!important;width:36%!important;background:#fff!important;color:#111!important;padding:5px!important;z-index:5!important}
.mc-bar em{display:block!important;font-style:normal!important;font-size:6px!important;letter-spacing:.16em!important;text-align:center!important}
.mc-bar span{display:flex!important;height:28px!important}
.mc-bar i{flex:1!important;height:100%!important}
.mc-bar i.on{background:#111!important}
.mc-bar i.off{background:#fff!important}
'''
css.write_text(t, encoding='utf-8')
idx=root.joinpath('index.html')
html=idx.read_text(encoding='utf-8')
html=html.replace('src="assets/issues.js"','src="/assets/issues.js?v=20260930v"')
html=html.replace("src='assets/issues.js'",'src="/assets/issues.js?v=20260930v"')
idx.write_text(html, encoding='utf-8')
print('unhidden + cachebust')
PY
echo OK-visible
