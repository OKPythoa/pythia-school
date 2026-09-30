#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/fc57017b6dd39740b754909d3016231bf9d578d7/antigloss/issues.js -o /tmp/issues.js
# keep current issues.js structure; only CSS
grep -q 'issue-cover-iknow' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-iknow */
.cover{padding:0;overflow:hidden;border:1px solid rgba(255,255,255,.16);background:#111}
.issue-frame{margin:0;height:100%}
.issue-frame img{width:100%;height:100%;object-fit:cover;object-position:center top;display:block}
.issue-shade{position:absolute;inset:0;display:block;padding:10px 8px 0;background:linear-gradient(180deg,rgba(5,6,7,.42) 0%,rgba(5,6,7,0) 34%);pointer-events:none}
.issue-brand{display:block;text-align:center;font-family:Georgia,"Times New Roman",serif;font-size:15px;line-height:1;letter-spacing:.06em;text-transform:uppercase;text-shadow:0 1px 8px rgba(0,0,0,.55)}
.issue-brand b{display:inline;color:#c91520;font-size:inherit;letter-spacing:.06em}
.issue-line{position:absolute;top:8px;right:8px;left:auto;text-align:right;font-size:8px;letter-spacing:.14em;text-transform:uppercase;color:rgba(255,255,255,.88);text-shadow:0 1px 6px rgba(0,0,0,.7)}
CSS
echo OK-iknow-cover
