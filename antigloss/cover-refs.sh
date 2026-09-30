#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/e6db79d1d7c2b3e32b29674a23b5eb6c7e07477d/antigloss/issues.js -o "$ROOT/assets/issues.js"
grep -q 'issue-cover-refs' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-refs */
.cover{padding:0;overflow:hidden;border:1px solid rgba(255,255,255,.14)}
.issue-frame{position:relative;margin:0;height:100%}
.issue-frame img{width:100%;height:100%;object-fit:cover;object-position:center top;display:block}
.issue-shade{position:absolute;inset:0;display:block;padding:0;background:none;pointer-events:none}
.issue-brand{position:absolute;top:8px;left:6px;right:6px;text-align:center;font-family:Georgia,"Times New Roman",serif;font-size:17px;line-height:1;letter-spacing:.05em;text-transform:uppercase;text-shadow:0 1px 10px rgba(0,0,0,.65),0 0 2px #000}
.issue-brand b{display:inline;color:#c91520;font-size:inherit}
.issue-line{position:absolute;top:28px;right:8px;left:auto;bottom:auto;text-align:right;font-size:8px;letter-spacing:.12em;text-transform:uppercase;color:#fff;text-shadow:0 1px 6px #000}
.issue-tease{position:absolute;left:8px;right:18px;bottom:10px;font-family:Georgia,"Times New Roman",serif;font-size:11px;line-height:1.15;color:#fff;text-shadow:0 1px 8px #000}
CSS
echo OK-refs-cover
