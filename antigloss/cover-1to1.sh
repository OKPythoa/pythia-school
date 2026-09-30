#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/c7178b935e9db294974c752c9ae764e2c4bdd57d/antigloss/issues.js -o "$ROOT/assets/issues.js"
python3 - <<'PY'
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/style.css')
t=p.read_text(encoding='utf-8')
block='''
/* issue-cover-1to1 */
.cover{width:100%!important;max-width:none!important;aspect-ratio:3/4!important;height:auto!important;min-height:0!important;padding:0!important;margin:0 auto!important;overflow:hidden!important;background:#000!important;border:0!important}
.magazine-cover,.issue-frame{display:block!important;width:100%!important;height:100%!important;position:relative!important}
.issue-frame img{width:100%!important;height:100%!important;object-fit:cover!important;object-position:center 12%!important;display:block!important}
.issue-shade,.issue-brand,.issue-kicker,.issue-name{display:none!important}
.mc-logo{position:absolute!important;top:2.2%!important;left:2%!important;right:2%!important;text-align:center!important;z-index:3}
.mc-logo i{display:block!important;font-style:normal!important;font-family:Georgia,"Times New Roman",serif!important;font-size:2.6%!important;font-size:11px!important;letter-spacing:.48em!important;text-transform:uppercase!important;color:#fff!important;text-shadow:0 1px 8px #000}
.mc-logo b{display:block!important;margin-top:1px!important;font-family:Georgia,"Times New Roman",serif!important;font-weight:700!important;font-size:13vw!important;line-height:.78!important;letter-spacing:-.03em!important;text-transform:uppercase!important;color:#b01018!important;text-shadow:0 2px 12px rgba(0,0,0,.35)}
.mc-date{position:absolute!important;top:2.4%!important;right:3.2%!important;left:auto!important;font-size:8px!important;letter-spacing:.14em!important;text-transform:uppercase!important;color:#fff!important;z-index:4}
.mc-lines{position:absolute!important;left:5.5%!important;bottom:16%!important;width:58%!important;display:flex!important;flex-direction:column!important;gap:0!important;text-align:left!important;z-index:3}
.mc-lines span{display:block!important;font-family:Georgia,"Times New Roman",serif!important;font-weight:700!important;font-size:clamp(16px,5.1vw,24px)!important;line-height:.88!important;letter-spacing:.01em!important;text-transform:uppercase!important;color:#fff!important;text-align:left!important;text-shadow:0 2px 10px rgba(0,0,0,.7)}
.mc-bar{position:absolute!important;right:4%!important;bottom:3.8%!important;width:34%!important;background:#fff!important;color:#111!important;padding:3.5% 3% 2.5%!important;z-index:4}
.mc-bar b{display:block!important;font-size:6px!important;letter-spacing:.16em!important;text-align:center!important;margin-bottom:3px!important}
.mc-bar span{display:flex!important;height:26px!important}
.mc-bar i{flex:1!important;height:100%!important}
.mc-bar i.on{background:#111!important}
.mc-bar i.off{background:#fff!important}
'''
if 'issue-cover-1to1' not in t:
    p.write_text(t+block, encoding='utf-8')
    print('css appended')
else:
    print('css exists')
PY
echo OK-1to1
