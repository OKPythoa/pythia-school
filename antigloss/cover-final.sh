#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/5fd2e0aef591df8a158c22fc6f6c027e44c597e8/antigloss/issues.js -o "$ROOT/assets/issues.js"
chown admin:admin "$ROOT/assets/issues.js" || true
grep -q 'issue-cover-final' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-final */
.cover{width:100%!important;max-width:none!important;aspect-ratio:3/4!important;height:auto!important;min-height:400px!important;padding:0!important;overflow:hidden!important;background:#000}
.magazine-cover,.issue-frame{display:block;height:100%;position:relative}
.issue-frame img{width:100%;height:100%;object-fit:cover;object-position:center 20%;display:block}
.issue-shade,.issue-brand,.issue-kicker,.issue-name{display:none!important}
.mc-logo{position:absolute;top:18px;left:4%;right:4%;text-align:center;font-family:Georgia,"Times New Roman",serif;font-size:28px;line-height:1;letter-spacing:.04em;text-transform:uppercase;color:#fff;white-space:nowrap;text-shadow:0 2px 16px rgba(0,0,0,.7)}
.mc-logo b{color:#c91520;font-weight:700}
.mc-date{position:absolute;top:8px;right:8px;font-size:8px;letter-spacing:.14em;text-transform:uppercase;color:#fff;text-shadow:0 1px 8px #000}
.mc-lines{position:absolute;left:8%;bottom:12%;width:72%;display:flex;flex-direction:column;gap:2px}
.mc-lines span{display:block;font-family:Georgia,"Times New Roman",serif;font-size:20px;line-height:.95;font-weight:700;color:#fff;text-transform:uppercase;text-shadow:0 2px 10px #000}
CSS
echo OK-cover-final
