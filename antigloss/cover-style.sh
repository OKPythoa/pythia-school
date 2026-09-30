#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/fc57017b6dd39740b754909d3016231bf9d578d7/antigloss/issues.js -o "$ROOT/assets/issues.js"
grep -q 'issue-brand' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
#currentIssueNumber,#currentIssueDate{display:none}
.cover{padding:0;overflow:hidden;background:#070809}
.magazine-cover{display:block;height:100%;color:#fff;text-decoration:none}
.issue-frame{position:relative;height:100%;overflow:hidden;background:#070809}
.issue-frame img{width:100%;height:100%;object-fit:cover;display:block}
.issue-shade{position:absolute;inset:0;display:flex;flex-direction:column;justify-content:space-between;padding:12px 12px 14px;background:linear-gradient(180deg,rgba(5,6,7,.72) 0%,rgba(5,6,7,0) 28%,rgba(5,6,7,.82) 100%)}
.issue-brand{font-family:Georgia,"Times New Roman",serif;font-size:15px;font-weight:700;letter-spacing:.04em;text-transform:uppercase;line-height:1}
.issue-brand b{color:#c91520;font-weight:700}
.issue-line{font-size:10px;letter-spacing:.16em;text-transform:uppercase;color:rgba(255,255,255,.86)}
.issue-type{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:12px;text-align:center;padding:16px}
.issue-archive{margin-top:12px;display:flex;flex-wrap:wrap;gap:8px 12px}
.issue-archive a{color:rgba(255,255,255,.5);font-size:11px;letter-spacing:.08em;text-transform:uppercase}
CSS
echo OK-cover-style
