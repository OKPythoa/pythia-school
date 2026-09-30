(() => {
  const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const esc = s => String(s||'').replace(/[&<>"']/g, m => ({'&':'&','<':'<','>':'>','"':'"',"'":'&#39;'}[m]));
  function parseArticleDate(value){ const d=new Date(value); return Number.isNaN(d.getTime())?null:d; }
  function monthKey(date){ return `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}`; }
  function monthLabel(date){ return `${MONTHS[date.getMonth()]} ${date.getFullYear()}`; }
  function issueNumber(firstDate,targetDate){
    return (targetDate.getFullYear()-firstDate.getFullYear())*12 + targetDate.getMonth()-firstDate.getMonth()+1;
  }
  async function loadJSON(url){
    const response=await fetch(url,{cache:'no-store'});
    if(!response.ok) return null;
    return response.json();
  }
  function coverFor(issues, key){
    const list = Array.isArray(issues?.issues) ? issues.issues : [];
    const hit = list.find(item => item && item.month === key && item.cover);
    return hit ? String(hit.cover) : '';
  }
  function paintCover(el, {key, number, label, image}){
    const padded=String(number).padStart(2,'0');
    const href=`issue.html?month=${encodeURIComponent(key)}`;
    const art = image
      ? `<div class="issue-frame"><img src="${esc(image)}" alt="Issue ${padded} cover"></div>`
      : `<div class="issue-frame issue-type"><b>The AntiGloss</b><i>${esc(label)}</i></div>`;
    el.innerHTML = `<a class="magazine-cover" href="${href}">
      <div class="issue-masthead">The AntiGloss</div>
      ${art}
      <div class="issue-meta"><strong>Issue ${padded}</strong><span>${esc(label)}</span></div>
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
      const label=monthLabel(now);
      const numEl=document.getElementById('currentIssueNumber');
      const dateEl=document.getElementById('currentIssueDate');
      const button=document.getElementById('currentIssueButton');
      if(numEl) numEl.textContent=`Issue ${padded}`;
      if(dateEl) dateEl.textContent=label;
      if(button){
        button.href=`issue.html?month=${encodeURIComponent(key)}`;
        button.textContent=`▣ Read Issue ${padded}`;
      }
      paintCover(cover, {key, number, label, image: coverFor(issues, key)});
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
          return `<a href="issue.html?month=${encodeURIComponent(k)}">Issue ${n} · ${monthLabel(d)}</a>`;
        }).join(' ');
      }
    }catch(error){
      console.error('Current issue:', error);
    }
  }
  document.addEventListener('DOMContentLoaded', renderCurrentIssue);
})();
