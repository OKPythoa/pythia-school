#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'ad-hug' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* ad-hug */
.ad-wrap{width:min(calc(100% - 48px),var(--max));margin:12px auto;padding:0}
.adslot,.adslot-wide{display:block;height:auto!important;min-height:0!important;max-height:none!important;padding:0;background:transparent;border:0}
.adslot-wide:before{display:none}
.adslot-wide a{display:block;line-height:0}
.adslot-wide img{display:block;width:100%!important;height:auto!important;max-height:none!important;object-fit:contain!important;filter:none!important}
CSS
echo OK-ad-hug
