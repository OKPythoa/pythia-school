#!/bin/bash
set -euo pipefail
ROOT=/home/admin/domains/theantigloss.com/public_html
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/0acbb2092732bcca1f2391ab1fd7cda169fb0bb8/antigloss/save_issue_cover.php -o "$ROOT/api/save_issue_cover.php"
curl -fsSL https://raw.githubusercontent.com/OKPythoa/pythia-school/4105979c6c485fad2376f15a8805545602d9b9bf/antigloss/issues.js -o "$ROOT/assets/issues.js"
chmod 644 "$ROOT/api/save_issue_cover.php" "$ROOT/assets/issues.js"
chown admin:admin "$ROOT/api/save_issue_cover.php" "$ROOT/assets/issues.js" "$ROOT/content/issues.json" "$ROOT/assets/issues" || true

python3 - <<'PY'
from pathlib import Path
for rel in ("admin/index.html", "admin/ads.html"):
    p = Path("/home/admin/domains/theantigloss.com/public_html") / rel
    t = p.read_text(encoding="utf-8")
    if 'id="issueTease"' not in t and 'id="issueCoverFile"' in t:
        t = t.replace(
            '<input id="issueCoverFile" type="file" accept="image/jpeg,image/png,image/webp">',
            '<input id="issueCoverFile" type="file" accept="image/jpeg,image/png,image/webp">\n        <label>Cover story</label>\n        <select id="issueTease"><option value="">No cover line</option></select>',
            1,
        )
        p.write_text(t, encoding="utf-8")
        print("tease select added", rel)
    else:
        print("tease select ok", rel)
PY

grep -q 'function fillIssueStories' "$ROOT/admin/index.html" || python3 - <<'PY'
from pathlib import Path
js = r'''
async function fillIssueStories(){
  const sel=document.getElementById("issueTease"); const monthEl=document.getElementById("issueMonth");
  if(!sel||!monthEl) return;
  const month=monthEl.value;
  const keep=sel.value;
  try{
    const feed=await (await fetch("/content/articles.json?ts="+Date.now())).json();
    const articles=Array.isArray(feed)?feed:(feed.articles||[]);
    const rows=articles.filter(a=>String(a.date||"").slice(0,7)===month);
    sel.innerHTML='<option value="">No cover line</option>'+rows.map(a=>'<option value="'+String(a.slug||a.id||"").replace(/"/g,"")+'">'+String(a.title||"untitled").replace(/[<>]/g,"")+'</option>').join("");
    const rec=((await (await fetch("/content/issues.json?ts="+Date.now())).json()).issues||[]).find(i=>i.month===month);
    if(rec && rec.slug && [...sel.options].some(o=>o.value===rec.slug)) sel.value=rec.slug;
    else if(keep && [...sel.options].some(o=>o.value===keep)) sel.value=keep;
  }catch(e){}
}
const _saveIssueCover = window.saveIssueCover;
window.saveIssueCover = async function(){
  const key=(document.getElementById("key")||{}).value|| (typeof authKey==="function"?authKey():"");
  const month=(document.getElementById("issueMonth")||{}).value;
  const file=document.getElementById("issueCoverFile") && document.getElementById("issueCoverFile").files[0];
  const teaseSel=document.getElementById("issueTease");
  const tease=teaseSel && teaseSel.selectedIndex>0 ? teaseSel.options[teaseSel.selectedIndex].text : "";
  const slug=teaseSel ? teaseSel.value : "";
  const form=new FormData();
  form.append("key", String(key||"").trim());
  form.append("month", month||"");
  form.append("tease", tease);
  form.append("slug", slug);
  if(file) form.append("image", file);
  const data=await (await fetch("/api/save_issue_cover.php",{method:"POST",body:form})).json();
  if(!data.success) throw new Error(data.error||"save failed");
  return data;
};
document.getElementById("issueMonth") && document.getElementById("issueMonth").addEventListener("change", fillIssueStories);
fillIssueStories();
'''
for rel in ("admin/index.html", "admin/ads.html"):
    p=Path("/home/admin/domains/theantigloss.com/public_html")/rel
    t=p.read_text(encoding="utf-8")
    if "function fillIssueStories" in t: continue
    t=t.replace("</script>", js+"\n</script>", 1)
    p.write_text(t, encoding="utf-8")
    print("story js", rel)
PY

grep -q 'issue-cover-story' "$ROOT/style.css" || cat >> "$ROOT/style.css" <<'CSS'
/* issue-cover-story */
.issue-shade{background:none}
.issue-brand{top:10px;left:8px;right:52px;text-align:left;font-size:15px;letter-spacing:.04em}
.issue-line{top:10px;right:7px;font-size:7px;letter-spacing:.1em;max-width:46px;line-height:1.2}
.issue-tease{left:8px;right:12px;bottom:12px;font-size:12px;line-height:1.2;font-family:Georgia,"Times New Roman",serif;display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden}
CSS
echo OK-cover-story
