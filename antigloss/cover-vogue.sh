#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/79037698eee9278eac598dac1711788762e46197/antigloss/issues.js -o "$ROOT/assets/issues.js"
chown admin:admin "$ROOT/assets/issues.js" || true
grep -q 'issue-cover-vogue' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-vogue */
.cover{width:100%;max-width:none;aspect-ratio:3/4;height:auto;min-height:380px;padding:0}
.magazine-cover,.issue-frame{height:100%}
.issue-frame img{object-fit:cover;object-position:center 18%}
.issue-shade{background:none!important}
.issue-kicker{position:absolute;top:10px;left:0;right:0;text-align:center;font-family:Georgia,serif;font-size:11px;letter-spacing:.42em;text-transform:uppercase;color:#fff;text-shadow:0 1px 8px #000}
.issue-name{position:absolute;top:22px;left:0;right:0;text-align:center;font-family:Georgia,"Times New Roman",serif;font-weight:700;font-size:34px;line-height:.82;letter-spacing:.02em;text-transform:uppercase;color:#c91520;text-shadow:0 2px 14px rgba(0,0,0,.55)}
.issue-brand{display:none!important}
.issue-line{top:62px!important;right:10px!important;left:auto!important;font-size:8px!important;letter-spacing:.16em!important}
.issue-tease{left:12px!important;right:18%!important;bottom:18px!important;font-size:18px!important;line-height:.95!important;font-weight:700;letter-spacing:.02em;text-transform:uppercase;font-family:Georgia,"Times New Roman",serif!important}
CSS
echo OK-vogue-cover
