#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'card-coal' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* card-coal */
.card,.cards .card,.articlegrid .card{
  background:#111!important;
  border:1px solid rgba(255,255,255,.1)!important;
}
.card .thumb{
  aspect-ratio:16/9;
  overflow:hidden;
  background:#111;
}
.card .thumb img{
  width:100%;
  height:100%;
  object-fit:cover;
  display:block;
}
CSS
echo OK-card-coal
