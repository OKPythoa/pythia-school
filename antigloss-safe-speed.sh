#!/bin/bash
# AntiGloss speed: copies only. Never deletes PNG/HTML.
set -euo pipefail
ROOT="${ROOT:-/home/admin/domains/theantigloss.com/public_html}"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
BAK="$ROOT/.bak-speed-$STAMP"
ART="$ROOT/assets/articles"
CARDS="$ART/cards"
LITE="$ART/lite"

test -d "$ROOT" || { echo "no $ROOT"; exit 1; }
test -f "$ROOT/content/articles.json" || { echo "no articles.json"; exit 1; }

mkdir -p "$BAK" "$CARDS" "$LITE"
cp -a "$ROOT/content/articles.json" "$BAK/articles.json"
cp -a "$ROOT/assets/site.js" "$BAK/site.js"
cp -a "$ROOT/latest.html" "$BAK/latest.html"
echo "backup $BAK"

have_convert=0
if command -v magick >/dev/null 2>&1; then CONV=(magick); have_convert=1
elif command -v convert >/dev/null 2>&1; then CONV=(convert); have_convert=1
fi

made=0
skip=0
fail=0
shopt -s nullglob
for src in "$ART"/*.png "$ART"/*.jpg "$ART"/*.jpeg "$ART"/*.webp; do
  [ -f "$src" ] || continue
  base="$(basename "$src")"
  stem="${base%.*}"
  card="$CARDS/${stem}.jpg"
  lite="$LITE/${stem}.jpg"
  if [ "$have_convert" = 1 ]; then
    if [ ! -s "$card" ]; then
      "${CONV[@]}" "$src" -resize '800x450^' -gravity center -extent 800x450 -strip -quality 72 "$card" && made=$((made+1)) || fail=$((fail+1))
    else skip=$((skip+1)); fi
    if [ ! -s "$lite" ]; then
      "${CONV[@]}" "$src" -resize '1600x900>' -strip -quality 78 "$lite" || true
    fi
  else
    echo "NO ImageMagick — thumbs not built"
    break
  fi
done
echo "thumbs made=$made skip=$skip fail=$fail convert=$have_convert"

python3 - "$ROOT" <<'PY'
import json, os, sys
root = sys.argv[1]
path = os.path.join(root, "content/articles.json")
with open(path, encoding="utf-8") as f:
    data = json.load(f)
arts = data["articles"] if isinstance(data, dict) and "articles" in data else data
changed = 0
for a in arts:
    if not isinstance(a, dict):
        continue
    hero = a.get("heroImage") or a.get("cardImage") or a.get("image") or ""
    name = os.path.splitext(os.path.basename(hero))[0]
    card_rel = f"assets/articles/cards/{name}.jpg"
    if os.path.isfile(os.path.join(root, card_rel)):
        if a.get("cardImage") != card_rel:
            a["cardImage"] = card_rel
            changed += 1
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")
print("articles.json cardImage updated", changed)
PY

cat > "$ROOT/assets/site.js" <<'JS'
const AntiGlossSite=(()=>{
  const PAGE=18;
  const esc=s=>String(s||'').replace(/[&<>"']/g,m=>({'&':'&','<':'<','>':'>','"':'"',"'":'&#39;'}[m]));
  const norm=s=>String(s||'').trim().toLowerCase();
  function isSvg(value){
    const src=String(value||'').trim();
    if(!src)return false;
    return /(^|[/?#&=])[^?#&]*\.svg(?:$|[?#&])/i.test(src)||/^data:image\/svg\+xml/i.test(src);
  }
  function feedArray(data){if(Array.isArray(data))return data;if(data&&Array.isArray(data.articles))return data.articles;return[];}
  function imageOf(a){
    const candidates=[a?.cardImage,a?.heroImage,a?.image];
    return candidates.find(src=>src&&!isSvg(src))||'';
  }
  function urlOf(a){return a.url||('articles/'+(a.slug||'')+'.html');}
  function card(a){
    const img=imageOf(a);
    const w=esc(a.imageWidth||800);
    const h=esc(a.imageHeight||450);
    const thumb=img
      ? `<div class="thumb"><img src="${esc(img)}" alt="" loading="lazy" decoding="async" width="${w}" height="${h}"></div>`
      : `<div class="thumb"></div>`;
    return `<a class="card" href="${esc(urlOf(a))}">${thumb}<div class="cardbody"><p class="cat">${esc(a.category||'Editorial')}</p><h3>${esc(a.title||'Untitled')}</h3><p class="dek">${esc(a.dek||a.excerpt||'')}</p><p class="meta">${esc(a.date||'July 2026')} • ${esc(a.readTime||a.read_time||'Read')}</p></div></a>`;
  }
  function empty(label){return `<div class="panel"><h3>No articles yet</h3><p>${esc(label||'This section is waiting for its first proper dispatch.')}</p></div>`;}
  function renderPaged(grid, list){
    let shown=Math.min(PAGE, list.length);
    const host=grid.parentNode;
    function paint(){
      grid.innerHTML=list.slice(0,shown).map(card).join('')||empty('No published pieces in this section yet.');
      let wrap=host.querySelector('.feed-more');
      if(shown<list.length){
        if(!wrap){
          wrap=document.createElement('p');
          wrap.className='feed-more';
          wrap.style.cssText='text-align:center;margin:2.5rem 0 1rem';
          const b=document.createElement('button');
          b.type='button';
          b.className='redbtn';
          b.textContent='Show older articles';
          b.addEventListener('click',()=>{shown=Math.min(shown+PAGE,list.length);paint();});
          wrap.appendChild(b);
          grid.after(wrap);
        }
      } else if(wrap) wrap.remove();
    }
    paint();
  }
  async function load(){
    let articles=[];try{const r=await fetch('/content/articles.json?ts='+Date.now());articles=feedArray(await r.json());}catch(e){}
    const latest=document.getElementById('latestCards');
    if(latest)latest.innerHTML=articles.slice(0,8).map(card).join('')||['Society','Relationships','Culture','Image'].map(c=>card({category:c,title:'Coming Soon',dek:'Article title and image will be added here.',date:'July 2026',readTime:'Preview',url:'latest.html'})).join('');
    const grid=document.getElementById('articleGrid');
    if(grid){
      const cat=norm(document.body.dataset.category||grid.dataset.category||'all');
      const list=cat==='all'?articles:articles.filter(a=>norm(a.category)===cat);
      renderPaged(grid, list);
    }
    const count=document.getElementById('articleCount');if(count)count.textContent=String(articles.length);
  }
  document.addEventListener('DOMContentLoaded',load);return{load};
})();
JS

if [ -f "$ROOT/assets/listen.js" ]; then
  cp -a "$ROOT/assets/listen.js" "$BAK/listen.js"
  if ! grep -q 'AntiGlossLiteHero' "$ROOT/assets/listen.js"; then
    cat >> "$ROOT/assets/listen.js" <<'JS'

;(function AntiGlossLiteHero(){
  document.querySelectorAll('img[src*="/assets/articles/"]').forEach(function(img){
    var src=img.getAttribute('src')||'';
    if(!/\.png(\?|$)/i.test(src)) return;
    var lite=src.replace(/\/assets\/articles\/([^/?#]+)\.png/i,'/assets/articles/lite/$1.jpg');
    var probe=new Image();
    probe.onload=function(){ img.src=lite; };
    probe.src=lite;
  });
})();
JS
  fi
fi

for f in "$ROOT/latest.html" "$ROOT/index.html" "$ROOT/fashion.html" "$ROOT/culture.html" "$ROOT/relationships.html" "$ROOT/society.html" "$ROOT/image.html"; do
  [ -f "$f" ] || continue
  cp -a "$f" "$BAK/$(basename "$f")"
  sed -i 's/assets\/site.js?v=[^"]*/assets\/site.js?v=20260929-speed-1/g; s/assets\/site.js"/assets\/site.js?v=20260929-speed-1"/g' "$f"
done

if [ -f "$ROOT/style.css" ] && ! grep -q 'thumb img' "$ROOT/style.css"; then
  cp -a "$ROOT/style.css" "$BAK/style.css"
  printf '\n.thumb img{width:100%%;height:100%%;object-fit:cover;display:block;}\n' >> "$ROOT/style.css"
fi

echo "OK originals untouched. restore: cp -a $BAK/articles.json $ROOT/content/articles.json && cp -a $BAK/site.js $ROOT/assets/site.js"
ls -ld "$CARDS" "$LITE" | cat
ls "$CARDS" | wc -l
