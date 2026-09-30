#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'ad-frame-magazine' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* ad-frame-magazine */
.ad-wrap{
  width:min(calc(100% - 48px),var(--max));
  margin:0 auto;
  padding:22px 0 6px;
  border-top:1px solid rgba(255,255,255,.12);
}
.adslot-wide{
  min-height:0;
  height:128px;
  max-height:128px;
  background:#050607;
  border:1px solid rgba(255,255,255,.12);
}
.adslot-wide img{
  width:100%;
  height:100%;
  object-fit:cover;
  object-position:center;
  filter:saturate(.62) brightness(.86);
}
.adslot-wide:before{
  color:rgba(244,241,236,.42);
  letter-spacing:.18em;
}
@media(max-width:680px){
  .adslot-wide{height:96px;max-height:96px}
}
CSS
echo OK-ad-frame
