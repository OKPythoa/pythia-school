#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
grep -q 'issue-cover-newsstand' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-newsstand */
.cover{max-width:240px;padding:0;border:1px solid rgba(255,255,255,.22);background:#050607}
.magazine-cover,.issue-frame{height:100%}
.issue-frame{margin:0}
.issue-frame img{width:100%;height:100%;object-fit:cover;object-position:center top}
.issue-shade{padding:14px 10px 12px;background:linear-gradient(180deg,rgba(5,6,7,.88) 0%,rgba(5,6,7,.15) 38%,rgba(5,6,7,.08) 62%,rgba(5,6,7,.9) 100%)}
.issue-brand{display:block;text-align:center;font-family:Georgia,"Times New Roman",serif;font-size:22px;line-height:0.9;letter-spacing:.02em;text-transform:uppercase}
.issue-brand b{display:block;color:#c91520;font-size:26px;letter-spacing:.01em}
.issue-line{text-align:center;font-size:9px;letter-spacing:.22em;text-transform:uppercase;color:#f4f1ec}
CSS
echo OK-newsstand
