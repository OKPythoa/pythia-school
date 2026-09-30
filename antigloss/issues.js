(() => {
  const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const SHORT = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
  const esc = s => String(s||'').replace(/[&<>"']/g, m => ({'&':'&','<':'<','>':'>','"':'"',"'":'&#39;'}[m]));
  function parseArticleDate(value){ const d=new Date(value); return Number.isNaN(d.getTime())?null:d; }
  function monthKey(date){ return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}`; }
  function monthLabel(date){ return `${SHORT[date.getMonth()]} ${date.getFullYear()}`; }
  function issueNumber(firstDate,targetDate){
    return (targetDate.getFullYear()-firstDate.getFullYear())*12 + targetDate.getMonth()-firstDate.getMonth()+1;
  }
  function coverLine(text){
    const raw=String(text||'').trim();
    if(!raw) return '';
    const first=raw.split(/[.!?]/)[0].trim();
    const words=first.split(/\s+/).slice(0,5).join(' ');
    return words;
  }
  async function loadJSON(url){
    const response=await fetch(url,{cache:'no-store'});
    if(!response.ok) return null;
    return response.json();
  }
  function issueRecord(issues, key){
    const list = Array.isArray(issues?.issues) ? issues.issues : [];
    return list.find(item => item && item.month === key) || null;
  }
  function paintCover(el, {key, label, image, tease}){
    const href=`issue.html?month=${encodeURIComponent(key)}`;
    const art = image ? `<img src="${esc(image)}" alt="">` : `<div class="issue-type"></div>`;
    const line = tease ? `<div class="issue-tease">${esc(coverLine(tease))}</div>` : '';
    el.innerHTML = `<a class="magazine-cover" href="${href}">
      <div class="issue-frame">${art}
        <div class="issue-shade">
          <div class="issue-kicker">The</div>
          <div class="issue-name">AntiGloss</div>
          <div class="issue-line">${esc(label)}</div>
          ${line}
        </div>
      </div>
    </a>`;
  }
  async function renderCurrentIssue(){
    const cover=document.getElementById('currentIssueCover');
    if(!cover) return;
    try{
      const [feed, issues] = await Promise.all([
        loadJSON('/content/articles.json'),
        loadJSON('/content/issues.json')
      ]);
      const articles = Array.isArray(feed) ? feed : (feed?.articles || []);
      const dated=articles.map(article=>({article,date:parseArticleDate(article.date)})).filter(x=>x.date).sort((a,b)=>a.date-b.date);
      const now=new Date();
      const key=monthKey(now);
      const firstDate=dated[0]?.date || new Date(now.getFullYear(), now.getMonth(), 1);
      const number=issueNumber(firstDate, now);
      const padded=String(number).padStart(2,'0');
      const rec=issueRecord(issues, key);
      const image=rec && rec.cover ? String(rec.cover) : '';
      const tease=rec && rec.tease ? String(rec.tease).trim() : '';
      const numEl=document.getElementById('currentIssueNumber');
      const dateEl=document.getElementById('currentIssueDate');
      const button=document.getElementById('currentIssueButton');
      if(numEl) numEl.hidden = true;
      if(dateEl) dateEl.hidden = true;
      if(button){
        button.href=`issue.html?month=${encodeURIComponent(key)}`;
        button.textContent=`Read Issue ${padded}`;
      }
      paintCover(cover, {key, label: monthLabel(now), image, tease});
      const archiveHost=document.getElementById('issueArchive');
      if(archiveHost){
        const months=[];
        let cursor=new Date(firstDate.getFullYear(), firstDate.getMonth(), 1);
        const end=new Date(now.getFullYear(), now.getMonth(), 1);
        while(cursor<=end){
          months.push(new Date(cursor));
          cursor.setMonth(cursor.getMonth()+1);
        }
        archiveHost.innerHTML = months.reverse().map(d=>{
          const k=monthKey(d);
          const n=String(issueNumber(firstDate,d)).padStart(2,'0');
          return `<a href="issue.html?month=${encodeURIComponent(k)}">Issue ${n}</a>`;
        }).join('');
      }
    }catch(error){
      console.error('Current issue:', error);
    }
  }
  document.addEventListener('DOMContentLoaded', renderCurrentIssue);
})();
