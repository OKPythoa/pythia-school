#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'magazine-skin-v1' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* magazine-skin-v1 */
body{background:#070708;color:#ece7df}
.topbar{border-bottom:1px solid rgba(201,21,32,.85);background:#070708}
.nav a.active:after,.nav a:hover:after{background:#c91520;height:1px;bottom:-18px}
.hero{background:#070708;border-bottom:1px solid rgba(255,255,255,.08)}
.herotext h1{font-weight:500;letter-spacing:-.03em}
.ad-wrap{width:min(calc(100% - 48px),var(--max));margin:0 auto;padding:18px 0 4px;border-top:1px solid rgba(255,255,255,.08)}
.adslot-wide{min-height:0!important;height:110px!important;max-height:110px!important;background:#070708;border:1px solid rgba(255,255,255,.1)}
.adslot-wide img{object-fit:cover;filter:saturate(.45) brightness(.78) contrast(1.05)}
.cards .card,.articlegrid .card{background:#0b0c0e;border:1px solid rgba(255,255,255,.1)}
.card .cat{color:#c91520;letter-spacing:.12em}
.side{border-left:1px solid rgba(255,255,255,.1);background:transparent}
.side h2,.side .section-title{letter-spacing:.14em}
#currentIssueCover.cover{border:1px solid rgba(255,255,255,.16);background:#000}
.redbtn{background:#c91520;border:0;letter-spacing:.08em}
.subbtn{border:1px solid rgba(255,255,255,.2);background:transparent}
@media(max-width:680px){.adslot-wide{height:84px!important;max-height:84px!important}}
CSS
echo OK-magazine-skin
