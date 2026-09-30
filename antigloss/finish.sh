#!/bin/bash
set -euo pipefail
ROOT="${ROOT:-/home/admin/domains/theantigloss.com/public_html}"
python3 - "$ROOT/admin/ads.html" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
t = p.read_text(encoding="utf-8")
if 'id="issueCoverBox"' not in t:
    needle = '  <div class="section-head"><h2>Requests</h2>'
    if needle not in t:
        raise SystemExit("ads admin marker missing")
    box = '''  <div class="section-head"><h2>Issue cover</h2><span class="muted">Same cover as article admin. Month/number automatic.</span></div>
  <div id="issueCoverBox" class="item" style="grid-template-columns:1fr">
    <div>
      <select id="issueMonth"></select>
      <input id="issueCoverFile" type="file" accept="image/jpeg,image/png,image/webp">
      <p><button type="button" class="red" id="issueCoverSave">Save cover</button></p>
      <div class="preview compact" id="issueCoverPreview"></div>
      <div id="issueCoverList" class="muted"></div>
    </div>
  </div>
'''
    t = t.replace(needle, box + needle, 1)
js = r'''
function fillIssueMonths(){const sel=document.getElementById("issueMonth");if(!sel||sel.options.length)return;const now=new Date();for(let i=0;i<24;i++){const d=new Date(now.getFullYear(),now.getMonth()-i,1);const v=d.getFullYear()+"-"+String(d.getMonth()+1).padStart(2,"0");sel.insertAdjacentHTML("beforeend","<option value=\""+v+"\">"+v+"</option>");}}
async function refreshIssueCovers(){const list=document.getElementById("issueCoverList");if(!list)return;try{const data=await(await fetch("/content/issues.json?ts="+Date.now())).json();list.innerHTML=(data.issues||[]).map(i=> (i.month||"")+" — "+(i.cover?"cover set":"title only") ).join("<br>")||"No uploaded covers yet.";}catch(e){list.textContent="Cover list unavailable.";}}
async function saveIssueCover(){try{if(!authKey())throw new Error("password required");const month=document.getElementById("issueMonth").value;const file=document.getElementById("issueCoverFile").files[0];if(!file)throw new Error("choose a cover image");const form=new FormData();form.append("key",authKey());form.append("month",month);form.append("image",file);msg("Saving cover...");const data=await(await fetch("/api/save_issue_cover.php",{method:"POST",body:form})).json();if(!data.success)throw new Error(data.error||"save failed");msg("Cover saved for "+data.month,true);await refreshIssueCovers();}catch(e){msg("Cover error: "+e.message)}}
document.getElementById("issueCoverSave")&&document.getElementById("issueCoverSave").addEventListener("click",saveIssueCover);
fillIssueMonths();refreshIssueCovers();
'''
if 'function fillIssueMonths' not in t and "$('load').onclick=load;" in t:
    t = t.replace("$('load').onclick=load;", js + "\n$('load').onclick=load;")
old = "${ad.image?'Replace banner':'Upload banner'}</button></div></div></div>`"
new = "${ad.image?'Replace banner':'Upload banner'}</button><button type=\"button\" onclick=\"deleteAd('${esc(ad.id)}')\">Delete ad</button></div></div></div>`"
if 'deleteAd(' not in t and old in t:
    t = t.replace(old, new, 1)
fn = '''
async function deleteAd(id){
  try{
    if(!confirm("Remove this ad from rotation? Banner file stays on disk."))return;
    if(!authKey())throw new Error("Enter the publish password.");
    saveKey();
    msg("Deleting...");
    const response=await fetch("/api/delete_ad.php",{method:"POST",headers:{"Content-Type":"application/json","X-Antigloss-Publish-Key":authKey()},body:JSON.stringify({id})});
    const data=await response.json();
    if(!data.success)throw new Error(data.error||"delete failed");
    msg("Deleted "+id,true);
    await load();
  }catch(error){msg("Error: "+error.message)}
}
'''
if "async function deleteAd" not in t:
    t = t.replace("$('load').onclick=load;", fn + "\n$('load').onclick=load;")
p.write_text(t, encoding="utf-8")
print("ads admin patched")
PY

if ! grep -q 'id="issueArchive"' "$ROOT/index.html"; then
  python3 - "$ROOT/index.html" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
t = p.read_text(encoding="utf-8")
needle = '<a class="subbtn" href="advertise.html">Advertise</a>'
if needle not in t:
    raise SystemExit("index marker missing")
p.write_text(t.replace(needle, needle + '\n  <div id="issueArchive" class="issue-archive"></div>', 1), encoding="utf-8")
print("index archive strip added")
PY
fi

if ! grep -q 'magazine-cover' "$ROOT/style.css"; then
  cat >> "$ROOT/style.css" <<'CSS'
.cover{padding:0;overflow:hidden}
.magazine-cover{display:flex;flex-direction:column;height:100%;color:#fff;text-decoration:none}
.issue-masthead{font-family:Georgia,serif;font-size:13px;letter-spacing:.18em;text-transform:uppercase;padding:10px 10px 0;color:#fff}
.issue-frame{flex:1;margin:10px;border:1px solid rgba(255,255,255,.18);overflow:hidden;background:linear-gradient(180deg,#1a1a1a,#070809)}
.issue-frame img{width:100%;height:100%;object-fit:cover;display:block}
.issue-type{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:16px}
.issue-type b{font-family:Georgia,serif;font-size:22px;letter-spacing:.06em;text-transform:uppercase}
.issue-type i{margin-top:10px;font-style:normal;color:rgba(255,255,255,.7);font-size:12px;letter-spacing:.12em;text-transform:uppercase}
.issue-meta{padding:0 12px 12px}
.issue-meta strong,.issue-meta span{display:block}
.issue-archive{margin-top:14px;font-size:12px;line-height:1.7}
.issue-archive a{display:inline-block;margin-right:10px;color:rgba(255,255,255,.55)}
CSS
fi
echo "OK covers+delete+politics"
