#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'feat-no-white' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* feat-no-white */
.hero-featured .heroinner{grid-template-columns:1fr;min-height:0!important}
.heroimg,.hero-featured .heroimg{
  min-height:0!important;
  height:auto!important;
  background:transparent!important;
  overflow:visible!important;
}
.hero-featured .heroimg a{display:block;background:transparent}
.hero-featured .heroimg img{
  display:block;
  width:100%;
  height:auto!important;
  max-height:none!important;
  object-fit:contain!important;
  background:transparent!important;
}
CSS
echo OK-no-white
