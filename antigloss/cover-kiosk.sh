#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'issue-cover-kiosk' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-kiosk */
.cover{max-width:none;width:100%;aspect-ratio:3/4;height:auto;min-height:340px;padding:0;border:1px solid rgba(255,255,255,.2)}
.issue-frame,.magazine-cover{height:100%}
.issue-shade{background:none!important}
.issue-brand{top:14px!important;left:10px!important;right:10px!important;text-align:center!important;font-size:22px!important;letter-spacing:.08em!important;line-height:1!important}
.issue-brand b{display:inline!important;color:#c91520!important;font-size:inherit!important}
.issue-line{top:8px!important;right:8px!important;left:auto!important;max-width:none!important;font-size:8px!important;letter-spacing:.14em!important}
.issue-tease{left:12px!important;right:28%!important;bottom:16px!important;font-size:15px!important;line-height:1.12!important;font-family:Georgia,"Times New Roman",serif!important;-webkit-line-clamp:3}
CSS
echo OK-kiosk
