#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/fd4f128f91f064ad2e81d3ab00e48c3ec273f227/antigloss/issues.js -o "$ROOT/assets/issues.js"
chown admin:admin "$ROOT/assets/issues.js" || true
grep -q 'issue-cover-approved' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-approved */
.cover{width:100%!important;max-width:none!important;aspect-ratio:3/4!important;height:auto!important;min-height:420px!important;padding:0!important;overflow:hidden!important;background:#000;border:0}
.magazine-cover,.issue-frame{display:block;height:100%;position:relative}
.issue-frame img{width:100%;height:100%;object-fit:cover;object-position:center 18%;display:block}
.issue-shade,.issue-brand,.issue-kicker,.issue-name{display:none!important}
.mc-logo{position:absolute;top:10px;left:3%;right:3%;text-align:center;font-family:Georgia,"Times New Roman",serif;line-height:.85;color:#fff;text-shadow:0 2px 14px rgba(0,0,0,.55)}
.mc-logo i{display:block;font-style:normal;font-size:11px;letter-spacing:.45em;text-transform:uppercase}
.mc-logo b{display:block;color:#b10e18;font-size:34px;letter-spacing:.01em;text-transform:uppercase;font-weight:700}
.mc-date{position:absolute;top:10px;right:8px;font-size:8px;letter-spacing:.12em;text-transform:uppercase;color:#fff;text-shadow:0 1px 8px #000}
.mc-lines{position:absolute;left:7%;bottom:18%;width:70%;display:flex;flex-direction:column;gap:1px}
.mc-lines span{display:block;font-family:Georgia,"Times New Roman",serif;font-size:18px;line-height:.92;font-weight:700;color:#fff;text-transform:uppercase;text-shadow:0 2px 10px #000}
.mc-bar{position:absolute;right:8px;bottom:10px;width:42%;background:#fff;color:#111;padding:4px 5px 3px}
.mc-bar b{display:block;font-size:7px;letter-spacing:.12em;margin-bottom:2px}
.mc-bar span{display:flex;height:28px;align-items:stretch}
.mc-bar i{display:block;flex:1;height:100%}
.mc-bar i.on{background:#111}
.mc-bar i.off{background:#fff}
CSS
echo OK-approved-cover
