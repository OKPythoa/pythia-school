#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'issue-cover-match' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-match */
.mc-logo{top:8px!important;left:2%!important;right:2%!important}
.mc-logo i{font-size:10px!important;letter-spacing:.5em!important}
.mc-logo b{font-size:clamp(28px,9.2vw,48px)!important;letter-spacing:-.02em!important;line-height:.8!important}
.mc-date{top:8px!important;right:8px!important}
.mc-lines{left:6%!important;bottom:22%!important;width:62%!important;align-items:flex-start!important;text-align:left!important}
.mc-lines span{font-size:clamp(15px,4.6vw,22px)!important;line-height:.9!important;text-align:left!important}
.mc-bar{right:6px!important;bottom:8px!important;width:38%!important}
CSS
echo OK-match-mock
