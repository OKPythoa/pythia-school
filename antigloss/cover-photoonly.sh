#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
cat > "$ROOT/assets/issues.js" <<'JS'
(() => {
  const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const esc = s => String(s||'').replace(/[&<>"']/g, m => ({'&':'&','<':'<','>':'>','"':'"',"'":'&#39;'}[m]));
  function parseArticleDate(value){ const d=new Date(value); return Number.isNaN(d.getTime())?null:d; }
  function monthKey(date){ return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}`; }
  function issueNumber(a,b){ return (b.getFullYear()-a.getFullYear())*12 + b.getMonth()-a.getMonth()+1; }
  async function loadJSON(url){ const r=await fetch(url,{cache:'no-store'}); if(!r.ok) return null; return r.json(); }
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
    const href=`issue.html?month=${encodeURIComponent(key)}`;
    cover.innerHTML = src
      ? `<a class="magazine-cover" href="${href}"><img class="mc-photo" src="${esc(src)}" alt="The AntiGloss"></a>`
      : `<a class="magazine-cover" href="${href}"></a>`;
    const btn=document.getElementById('currentIssueButton');
    const num=document.getElementById('currentIssueNumber');
    const date=document.getElementById('currentIssueDate');
    if(num) num.hidden=true;
    if(date) date.hidden=true;
    if(btn){ btn.href=href; btn.textContent=`Read Issue ${n}`; }
    const arch=document.getElementById('issueArchive');
    if(arch){
      const months=[]; let c=new Date(first.getFullYear(),first.getMonth(),1); const end=new Date(now.getFullYear(),now.getMonth(),1);
      while(c<=end){ months.push(new Date(c)); c.setMonth(c.getMonth()+1); }
      arch.innerHTML=months.reverse().map(d=>`<a href="issue.html?month=${encodeURIComponent(monthKey(d))}">Issue ${String(issueNumber(first,d)).padStart(2,'0')}</a>`).join('');
    }
  }
  document.addEventListener('DOMContentLoaded',()=>run().catch(console.error));
})();
JS
grep -q 'issue-cover-photoonly' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-photoonly */
.cover{width:100%;aspect-ratio:3/4;padding:0;overflow:hidden;background:#000}
.magazine-cover{display:block;height:100%}
.mc-photo{width:100%;height:100%;object-fit:cover;display:block}
.issue-shade,.mc-logo,.mc-date,.mc-lines,.mc-bar{display:none!important}
CSS
echo OK-photo-is-cover
