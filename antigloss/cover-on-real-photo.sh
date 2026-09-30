#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
python3 - <<'PY'
import json
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/content/issues.json')
data=json.loads(p.read_text(encoding='utf-8')) if p.exists() else {'issues':[]}
for it in data.get('issues') or []:
    if it.get('month')=='2026-09':
        it['cover']='/assets/issues/2026-09.png'
p.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
print('cover -> png')
PY
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/c7178b935e9db294974c752c9ae764e2c4bdd57d/antigloss/issues.js -o "$ROOT/assets/issues.js"
# force png in paint: already from issues.json
grep -q 'issue-cover-onreal' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-onreal */
.cover{width:100%!important;aspect-ratio:3/4!important;padding:0!important;overflow:hidden!important;background:#000}
.magazine-cover,.issue-frame{display:block;height:100%;position:relative}
.issue-frame img{width:100%;height:100%;object-fit:cover;object-position:center 15%;display:block}
.mc-logo{position:absolute;top:2%;left:2%;right:2%;text-align:center;z-index:3}
.mc-logo i{display:block;font-style:normal;font-family:Georgia,serif;font-size:11px;letter-spacing:.48em;text-transform:uppercase;color:#fff}
.mc-logo b{display:block;font-family:Georgia,serif;font-size:clamp(26px,8.6vw,44px);line-height:.78;letter-spacing:-.03em;text-transform:uppercase;color:#b01018}
.mc-date{position:absolute;top:2.2%;right:3%;font-size:8px;letter-spacing:.12em;text-transform:uppercase;color:#fff;z-index:4}
.mc-lines{position:absolute;left:6%;bottom:16%;width:60%;display:flex;flex-direction:column;z-index:3}
.mc-lines span{font-family:Georgia,serif;font-weight:700;font-size:clamp(15px,4.8vw,22px);line-height:.88;text-transform:uppercase;color:#fff;text-shadow:0 2px 10px #000}
.mc-bar{position:absolute;right:4%;bottom:4%;width:34%;background:#fff;color:#111;padding:4px;z-index:4}
.mc-bar b{display:block;font-size:6px;letter-spacing:.14em;text-align:center}
.mc-bar span{display:flex;height:26px}
.mc-bar i{flex:1}
.mc-bar i.on{background:#111}
.mc-bar i.off{background:#fff}
.mc-photo{display:none!important}
CSS
echo OK-real-photo-layout
