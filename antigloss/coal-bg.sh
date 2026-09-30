#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'coal-bg' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* coal-bg */
:root{--bg:#111111;--panel:#111111}
html,body{background:#111!important}
.topbar,.hero,.hero-featured,.main,.side,.ad-wrap,.foot,
.heroinner,.herotext,.heroimg,.cards .card,.articlegrid .card{
  background:#111!important;
  background-image:none!important;
}
.hero{border-bottom:1px solid rgba(255,255,255,.1)}
.hero-featured .heroimg img{background:#111!important}
.adslot,.adslot-wide{background:#111!important}
CSS
echo OK-coal
