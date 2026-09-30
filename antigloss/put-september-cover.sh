#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
mkdir -p "$ROOT/assets/issues"
curl -fsSL https://litter.catbox.moe/78r8hq.jpg -o "$ROOT/assets/issues/2026-09.jpg"
test "$(wc -c < "$ROOT/assets/issues/2026-09.jpg")" -gt 600000
chown admin:admin "$ROOT/assets/issues/2026-09.jpg" || true
chmod 644 "$ROOT/assets/issues/2026-09.jpg"
python3 - <<'PY'
import json
from pathlib import Path
p=Path('/home/admin/domains/theantigloss.com/public_html/content/issues.json')
data={'magazine':'The AntiGloss','issues':[]}
if p.exists():
    try:
        data=json.loads(p.read_text(encoding='utf-8'))
        if not isinstance(data, dict): data={'magazine':'The AntiGloss','issues':[]}
    except Exception:
        data={'magazine':'The AntiGloss','issues':[]}
issues=data.get('issues') or []
found=False
for it in issues:
    if isinstance(it, dict) and it.get('month')=='2026-09':
        it['cover']='/assets/issues/2026-09.jpg'
        it['updatedAt']='2026-09-30T01:46:00Z'
        found=True
        break
if not found:
    issues.append({'month':'2026-09','cover':'/assets/issues/2026-09.jpg','updatedAt':'2026-09-30T01:46:00Z'})
data['issues']=issues
p.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
print('issues.json ok')
PY
chown admin:admin "$ROOT/content/issues.json" || true
cat > "$ROOT/assets/issues.js" <<'JS'
(() => {
  const MONTHS=['January','February','March','April','May','June','July','August','September','October','November','December'];
  const esc=s=>String(s||'').replace(/[&<>"']/g,m=>({'&':'&','<':'<','>':'>','"':'"',"'":'&#39;'}[m]));
  function parseArticleDate(value){const d=new Date(value);return Number.isNaN(d.getTime())?null:d;}
  function monthKey(date){return date.getFullYear()+'-'+String(date.getMonth()+1).padStart(2,'0');}
  function issueNumber(a,b){return (b.getFullYear()-a.getFullYear())*12+b.getMonth()-a.getMonth()+1;}
  async function loadJSON(url){const r=await fetch(url,{cache:'no-store'});if(!r.ok)return null;return r.json();}
  async function run(){
    const cover=document.getElementById('currentIssueCover');
    if(!cover) return;
    const [feed,pack]=await Promise.all([loadJSON('/content/articles.json'),loadJSON('/content/issues.json')]);
    const articles=Array.isArray(feed)?feed:(feed&&feed.articles)||[];
    const dated=articles.map(a=>({d:parseArticleDate(a.date)})).filter(x=>x.d).sort((x,y)=>x.d-y.d);
    const now=new Date();
    const key=monthKey(now);
    const first=dated[0]?dated[0].d:new Date(now.getFullYear(),now.getMonth(),1);
    const n=String(issueNumber(first,now)).padStart(2,'0');
    const rec=((pack&&pack.issues)||[]).find(i=>i&&i.month===key);
    const src=rec&&rec.cover?String(rec.cover):'';
    const href='issue.html?month='+encodeURIComponent(key);
    cover.innerHTML=src?('<a class="magazine-cover" href="'+href+'"><img class="mc-photo" src="'+esc(src)+'?v=20260930m" alt="The AntiGloss"></a>'):('');
    const btn=document.getElementById('currentIssueButton');
    const num=document.getElementById('currentIssueNumber');
    const date=document.getElementById('currentIssueDate');
    if(num) num.hidden=true;
    if(date) date.hidden=true;
    if(btn){btn.href=href;btn.textContent='Read Issue '+n;}
    const arch=document.getElementById('issueArchive');
    if(arch){
      const months=[];let c=new Date(first.getFullYear(),first.getMonth(),1);const end=new Date(now.getFullYear(),now.getMonth(),1);
      while(c<=end){months.push(new Date(c));c.setMonth(c.getMonth()+1);}
      arch.innerHTML=months.reverse().map(d=>'<a href="issue.html?month='+encodeURIComponent(monthKey(d))+'">Issue '+String(issueNumber(first,d)).padStart(2,'0')+'</a>').join('');
    }
  }
  document.addEventListener('DOMContentLoaded',()=>run().catch(console.error));
})();
JS
grep -q 'issue-cover-photoonly' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-photoonly */
.cover{width:100%;aspect-ratio:3/4;padding:0;overflow:hidden;background:#000}
.magazine-cover{display:block;height:100%}
.mc-photo{width:100%;height:100%;object-fit:cover;object-position:center top;display:block}
.issue-shade,.mc-logo,.mc-date,.mc-lines,.mc-bar{display:none!important}
CSS
echo OK-september-cover
