(() => {
  const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  const box = document.getElementById('issueCoverBox');
  if (!box) return;
  box.innerHTML = `<div class="section-title"><h3>Issue covers</h3></div>
    <p class="small">Four latest issues in view. Scroll for older. Cover image + cover story per month.</p>
    <div id="coverBoard"></div>`;
  const board = document.getElementById('coverBoard');
  function keyFrom(d){return d.getFullYear()+'-'+String(d.getMonth()+1).padStart(2,'0')}
  function labelFrom(key){const [y,m]=key.split('-').map(Number);return MONTHS[m-1]+' '+y}
  function articleKey(article){
    const raw=String(article.date||'');
    if(/^\d{4}-\d{2}/.test(raw)) return raw.slice(0,7);
    const d=new Date(raw);
    if(Number.isNaN(d.getTime())) return '';
    return keyFrom(d);
  }
  async function loadJSON(url){const r=await fetch(url,{cache:'no-store'});if(!r.ok) return null;return r.json()}
  function auth(){const el=document.getElementById('key');return ((el&&el.value)||'').trim()}
  async function render(){
    const [feed, pack] = await Promise.all([
      loadJSON('/content/articles.json?ts='+Date.now()),
      loadJSON('/content/issues.json?ts='+Date.now())
    ]);
    const articles = Array.isArray(feed)?feed:(feed&&feed.articles)||[];
    const issues = (pack&&pack.issues)||[];
    const months=[];
    const now=new Date();
    for(let i=0;i<12;i++){
      const d=new Date(now.getFullYear(), now.getMonth()-i, 1);
      months.push(keyFrom(d));
    }
    board.innerHTML = months.map(month=>{
      const rec=issues.find(x=>x && x.month===month)||{};
      const rows=articles.filter(a=>articleKey(a)===month);
      const opts=['<option value="">Cover story</option>'].concat(rows.map(a=>{
        const slug=String(a.slug||a.id||'');
        const sel=rec.slug&&rec.slug===slug?' selected':'';
        return `<option value="${slug}"${sel}>${String(a.title||'untitled').replace(/[<>]/g,'')}</option>`;
      })).join('');
      const img=rec.cover?`<div class="cover-thumb" style="background-image:url('${rec.cover}?ts=${Date.now()}')"></div>`:`<div class="cover-thumb empty"></div>`;
      return `<div class="cover-row" data-month="${month}">
        ${img}
        <div class="cover-meta">
          <strong>${labelFrom(month)}</strong>
          <input type="file" accept="image/jpeg,image/png,image/webp">
          <select>${opts}</select>
          <button type="button" class="cover-save">Save</button>
        </div>
      </div>`;
    }).join('');
    board.querySelectorAll('.cover-save').forEach(btn=>btn.addEventListener('click', saveRow));
  }
  async function saveRow(ev){
    const row=ev.currentTarget.closest('.cover-row');
    const month=row.getAttribute('data-month');
    const file=row.querySelector('input[type=file]').files[0];
    const sel=row.querySelector('select');
    const tease=sel.selectedIndex>0?sel.options[sel.selectedIndex].text:'';
    const slug=sel.value||'';
    const status=document.getElementById('sideStatus')||document.getElementById('status');
    const say=t=>{if(status) status.textContent=t};
    try{
      if(!auth()) throw new Error('publish password required');
      const form=new FormData();
      form.append('key', auth());
      form.append('month', month);
      form.append('tease', tease);
      form.append('slug', slug);
      if(file) form.append('image', file);
      say('Saving '+month+'...');
      const data=await (await fetch('/api/save_issue_cover.php',{method:'POST',body:form})).json();
      if(!data.success) throw new Error(data.error||'save failed');
      say('Saved '+month);
      await render();
    }catch(e){say('Cover error: '+e.message)}
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', ()=>render().catch(console.error));
  else render().catch(console.error);
})();
