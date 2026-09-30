#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'ad-kit-sizes' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* ad-kit-sizes */
.ad-wrap{width:min(calc(100% - 48px),var(--max));margin:16px auto 0;padding:0}
[data-ad-slot="homepage_top"],
[data-ad-slot="article_bottom"]{
  display:block!important;
  width:min(970px,100%)!important;
  max-width:970px!important;
  height:auto!important;
  min-height:0!important;
  max-height:none!important;
  aspect-ratio:970/250!important;
  margin-left:auto!important;
  margin-right:auto!important;
  overflow:hidden;
  background:#111!important;
}
[data-ad-slot="homepage_feed"],
[data-ad-slot="article_mid"]{
  display:block!important;
  width:min(728px,100%)!important;
  max-width:728px!important;
  height:auto!important;
  min-height:0!important;
  max-height:none!important;
  aspect-ratio:728/90!important;
  margin-left:auto!important;
  margin-right:auto!important;
  overflow:hidden;
  background:#111!important;
}
[data-ad-slot="homepage_side"]{
  display:block!important;
  width:min(300px,100%)!important;
  max-width:300px!important;
  aspect-ratio:300/600!important;
  height:auto!important;
  min-height:0!important;
  max-height:none!important;
}
[data-ad-slot] a{display:block;width:100%;height:100%}
[data-ad-slot] img{
  display:block!important;
  width:100%!important;
  height:100%!important;
  max-height:none!important;
  object-fit:contain!important;
  filter:none!important;
}
CSS
echo OK-kit
