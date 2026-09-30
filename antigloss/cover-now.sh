#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/d08faf91d3dc87ac1b00548fc44a08361f20d37d/antigloss/issues.js -o "$ROOT/assets/issues.js"
chown admin:admin "$ROOT/assets/issues.js" || true
python3 - <<'PY'
import json
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/content/issues.json')
data=json.loads(p.read_text(encoding='utf-8')) if p.exists() else {'issues':[]}
for it in data.get('issues') or []:
    if it.get('month')=='2026-09':
        it['cover']='/assets/issues/2026-09.png'
p.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
print('png')
PY
grep -q 'issue-cover-now' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-now */
.cover{width:100%!important;aspect-ratio:3/4!important;padding:0!important;overflow:hidden!important;background:#000!important}
.magazine-cover,.issue-frame{display:block;width:100%;height:100%;position:relative}
.issue-frame img{width:100%;height:100%;object-fit:cover;object-position:center 18%;display:block}
.mc-logo{position:absolute;top:2%;left:1%;right:1%;text-align:center;z-index:3;pointer-events:none}
.mc-logo i{display:block;font-style:normal;font-family:Georgia,"Times New Roman",serif;font-size:10px;letter-spacing:.5em;text-transform:uppercase;color:#fff;text-shadow:0 1px 6px #000}
.mc-logo b{display:block;font-family:Georgia,"Times New Roman",serif;font-weight:700;font-size:clamp(28px,9vw,46px);line-height:.76;letter-spacing:-.04em;text-transform:uppercase;color:#b01018;text-shadow:0 2px 10px rgba(0,0,0,.35)}
.mc-date{position:absolute;top:2%;right:3%;z-index:4;font-size:8px;letter-spacing:.14em;text-transform:uppercase;color:#fff}
.mc-lines{position:absolute;left:6%;bottom:17%;width:62%;z-index:3;display:flex;flex-direction:column;pointer-events:none}
.mc-lines span{display:block;font-family:Georgia,"Times New Roman",serif;font-weight:700;font-size:clamp(16px,5vw,24px);line-height:.86;letter-spacing:.01em;text-transform:uppercase;color:#fff;text-shadow:0 2px 12px #000}
.mc-bar{position:absolute;right:4%;bottom:3.5%;width:36%;background:#fff;color:#111;padding:5px 5px 4px;z-index:4}
.mc-bar em{display:block;font-style:normal;font-size:6px;letter-spacing:.18em;text-align:center;margin-bottom:3px}
.mc-bar span{display:flex;height:28px;align-items:stretch}
.mc-bar i{flex:1 1 0;height:100%;display:block}
.mc-bar i.on{background:#111}
.mc-bar i.off{background:#fff}
CSS
echo OK-now
