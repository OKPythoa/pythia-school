#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
SRC="$ROOT/assets/issues/2026-09.png"
OUT="$ROOT/assets/og-home.jpg"
if [[ ! -f "$SRC" ]]; then SRC="$ROOT/assets/issues/2026-09.jpg"; fi
if command -v convert >/dev/null 2>&1; then
  convert "$SRC" -resize 1200x630^ -gravity center -extent 1200x630 -quality 85 "$OUT"
elif command -v magick >/dev/null 2>&1; then
  magick "$SRC" -resize 1200x630^ -gravity center -extent 1200x630 -quality 85 "$OUT"
else
  php -r '
  $src=$argv[1]; $out=$argv[2];
  $im=@imagecreatefrompng($src);
  if(!$im) $im=@imagecreatefromjpeg($src);
  if(!$im){fwrite(STDERR,"no image\n"); exit(1);}
  $w=imagesx($im); $h=imagesy($im);
  $card=imagecreatetruecolor(1200,630);
  $bg=imagecolorallocate($card,8,9,10);
  imagefilledrectangle($card,0,0,1200,630,$bg);
  $scale=max(1200/$w, 630/$h);
  $nw=(int)round($w*$scale); $nh=(int)round($h*$scale);
  $x=(int)((1200-$nw)/2); $y=(int)((630-$nh)/2);
  imagecopyresampled($card,$im,$x,$y,0,0,$nw,$nh,$w,$h);
  imagejpeg($card,$out,85);
  ' "$SRC" "$OUT"
fi
chown admin:admin "$OUT" || true
chmod 644 "$OUT"
ls -l "$OUT"
python3 - <<'PY'
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/index.html')
t=p.read_text(encoding='utf-8')
for old in [
    'https://theantigloss.com/api/og-cover.php',
    'https://theantigloss.com/assets/issues/2026-09.png',
]:
    t=t.replace(old,'https://theantigloss.com/assets/og-home.jpg')
t=t.replace('<meta property="og:image:type" content="image/png">','<meta property="og:image:type" content="image/jpeg">')
t=t.replace('content="1800"','content="630"')
t=t.replace('<meta property="og:url" content="https://theantigloss.com/">','<meta property="og:url" content="https://theantigloss.com/index.html">')
if 'og-home.jpg' not in t:
    raise SystemExit('og tag missing')
p.write_text(t, encoding='utf-8')
print('index points to og-home.jpg')
PY
echo OK-og-card
