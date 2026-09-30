#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'ad-original' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* ad-original */
.ad-wrap{
  width:min(calc(100% - 48px),var(--max))!important;
  margin:16px auto 0!important;
  padding:0!important;
}
.adslot.adslot-wide,.adslot-wide{
  display:flex!important;
  align-items:center!important;
  justify-content:center!important;
  width:100%!important;
  height:250px!important;
  min-height:250px!important;
  max-height:250px!important;
  overflow:hidden!important;
  border:1px solid rgba(255,255,255,.18)!important;
  background:#111!important;
}
.adslot-wide:before{
  position:absolute!important;
  display:block!important;
  padding:0!important;
}
.adslot-wide a{display:block;width:100%;height:100%}
.adslot-wide img{
  display:block!important;
  width:100%!important;
  height:100%!important;
  max-height:none!important;
  object-fit:cover!important;
  filter:none!important;
}
@media(max-width:680px){
  .adslot-wide{height:150px!important;min-height:150px!important;max-height:150px!important}
}
CSS
echo OK-ad-original
