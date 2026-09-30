(() => {
  const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const esc = s => String(s||'').replace(/[&<>"']/g, m => ({'&':'&','<':'<','>':'>','"':'"',"'":'&#39;'}[m]));
  function parseArticleDate(value){ const d=new Date(value); return Number.isNaN(d.getTime())?null:d; }
  function monthKey(date){ return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}`; }
  function monthLabel(date){ return `${MONTHS[date.getMonth()]} ${date.getFullYear()}`; }
  function issueNumber(a,b){ return (b.getFullYear()-a.getFullYear())*12 + b.getMonth()-a.getMonth()+1; }
  function linesFrom(text){
    const raw=String(text||'').trim();
    if(!raw) return [];
    const first=raw.split(/[.!?]/)[0].trim();
    const words=first.split(/\s+/).filter(Boolean).slice(0,8);
    const out=[];
    for(let i=0;i<words.length;i+=2) out.push(words.slice(i,i+2).join(' '));
    return out.slice(0,4);
  }
  async function loadJSON(url){
    const r=await fetch(url,{cache:'no-store'});
    if(!r.ok) return null;
    return r.json();
  }
  function recFor(issues,key){
    return ((issues&&issues.issues)||[]).find(i=>i&&i.month===key)||null;
  }
  function barcode(issueNo){
    const bits='1101010110110101101011010110101101101011010110110101';
    const bars=[...bits].map(b=>`<i class="${b==='1'?'on':'off'}"></i>`).join('');
    return `<div class="mc-bar"><b>ISSUE ${esc(issueNo)}</b><span>${bars}</span></div>`;
  }
  function paint(el,{key,label,image,tease,issueNo}){
    const href=`issue.html?month=${encodeURIComponent(key)}`;
    const img=image?`<img src="${esc(image)}" alt="">`:'';
    const lines=linesFrom(tease).map(x=>`<span>${esc(x)}</span>`).join('');
    el.innerHTML=`<a class="magazine-cover" href="${href}">
      <div class="issue-frame">${img}
        <div class="mc-logo"><i>The</i> <b>AntiGloss</b></div>
        <div class="mc-date">${esc(label)}</div>
        <div class="mc-lines">${lines}</div>
        ${barcode(issueNo)}
      </div>
    </a>`;
  }
  async function run(){
    const cover=document.getElementById('currentIssueCover');
    if(!cover) return;
    const [feed,issues]=await Promise.all([loadJSON('/content/articles.json'),loadJSON('/content/issues.json')]);
    const articles=Array.isArray(feed)?feed:(feed&&feed.articles)||[];
    const dated=articles.map(a=>({a,d:parseArticleDate(a.date)})).filter(x=>x.d).sort((x,y)=>x.d-y.d);
    const now=new Date();
    const key=monthKey(now);
    const first=dated[0]?dated[0].d:new Date(now.getFullYear(),now.getMonth(),1);
    const n=String(issueNumber(first,now)).padStart(2,'0');
    const rec=recFor(issues,key);
    const btn=document.getElementById('currentIssueButton');
    const num=document.getElementById('currentIssueNumber');
    const date=document.getElementById('currentIssueDate');
    if(num) num.hidden=true;
    if(date) date.hidden=true;
    if(btn){btn.href=`issue.html?month=${encodeURIComponent(key)}`;btn.textContent=`Read Issue ${n}`;}
    paint(cover,{key,label:monthLabel(now),image:rec&&rec.cover||'',tease:rec&&rec.tease||'',issueNo:n});
    const arch=document.getElementById('issueArchive');
    if(arch){
      const months=[]; let c=new Date(first.getFullYear(),first.getMonth(),1); const end=new Date(now.getFullYear(),now.getMonth(),1);
      while(c<=end){months.push(new Date(c)); c.setMonth(c.getMonth()+1);}
      arch.innerHTML=months.reverse().map(d=>`<a href="issue.html?month=${encodeURIComponent(monthKey(d))}">Issue ${String(issueNumber(first,d)).padStart(2,'0')}</a>`).join('');
    }
  }
  document.addEventListener('DOMContentLoaded',()=>run().catch(console.error));
})();
