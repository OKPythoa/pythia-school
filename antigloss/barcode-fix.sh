#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
python3 - <<'PY'
from pathlib import Path
css=Path('/home/admin/domains/theantigloss.com/public_html/style.css')
t=css.read_text(encoding='utf-8')
block='''
/* mc-bar-upc */
#currentIssueCover .mc-bar{
  position:absolute;right:4%;bottom:3.5%;width:38%;
  background:#fff;color:#111;padding:6px 6px 5px;z-index:6;
  box-sizing:border-box;
}
#currentIssueCover .mc-bar em{
  display:block;font-style:normal;font-family:Arial,Helvetica,sans-serif;
  font-size:7px;letter-spacing:.16em;text-align:center;margin:0 0 4px;color:#111;
}
#currentIssueCover .mc-bar span{
  display:block;height:32px;width:100%;
  background-color:#fff;
  background-image:repeating-linear-gradient(
    90deg,
    #111 0 1px,
    #fff 1px 2px,
    #111 2px 4px,
    #fff 4px 5px,
    #111 5px 6px,
    #fff 6px 8px,
    #111 8px 11px,
    #fff 11px 12px,
    #111 12px 13px,
    #fff 13px 15px
  );
  background-size:15px 100%;
}
#currentIssueCover .mc-bar i{display:none!important}
'''
if 'mc-bar-upc' not in t:
    t += block
else:
    pass
css.write_text(t, encoding='utf-8')
print('barcode css')
PY
echo OK-barcode
