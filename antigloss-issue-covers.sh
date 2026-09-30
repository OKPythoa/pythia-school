#!/bin/bash
# Additive: covers + ad delete + Politics. Does not delete article PNGs.
set -euo pipefail
ROOT="${ROOT:-/home/admin/domains/theantigloss.com/public_html}"
BASE="https://raw.githubusercontent.com/OKPythoa/pythia-school/main/antigloss"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
BAK="$ROOT/.bak-issues-$STAMP"
test -d "$ROOT" && test -f "$ROOT/assets/issues.js"
mkdir -p "$BAK" "$ROOT/assets/issues" "$ROOT/content" "$ROOT/api" "$ROOT/admin"
cp -a "$ROOT/assets/issues.js" "$BAK/issues.js"
cp -a "$ROOT/admin/ads.html" "$BAK/ads.html"
cp -a "$ROOT/admin/index.html" "$BAK/admin-index.html"
cp -a "$ROOT/index.html" "$BAK/index.html"
cp -a "$ROOT/style.css" "$BAK/style.css"
echo "backup $BAK"

if [ ! -f "$ROOT/content/issues.json" ]; then
  printf '%s\n' '{"magazine":"The AntiGloss","issues":[]}' > "$ROOT/content/issues.json"
fi

curl -fsSL "$BASE/save_issue_cover.php" -o "$ROOT/api/save_issue_cover.php"
curl -fsSL "$BASE/delete_ad.php" -o "$ROOT/api/delete_ad.php"
curl -fsSL "$BASE/issues.js" -o "$ROOT/assets/issues.js"
chmod 644 "$ROOT/api/save_issue_cover.php" "$ROOT/api/delete_ad.php" "$ROOT/assets/issues.js"

python3 - "$ROOT/admin/index.html" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
t = p.read_text(encoding="utf-8")
if 'id="issueCoverBox"' not in t:
    needle = '      <div class="section-title"><h3>All articles</h3>'
    if needle not in t:
        raise SystemExit("article admin marker missing")
    box = '''      <div id="issueCoverBox">
        <div class="section-title"><h3>Issue cover</h3></div>
        <p class="small">Cover for Current Issue. Month and number are automatic. This does not change article photos.</p>
        <label>Month</label>
        <select id="issueMonth"></select>
        <label>Cover image</label>
        <input id="issueCoverFile" type="file" accept="image/jpeg,image/png,image/webp">
        <div class="btns"><button type="button" id="issueCoverSave">Save cover</button></div>
        <div class="preview" id="issueCoverPreview" style="height:auto;aspect-ratio:3/4;max-width:224px"></div>
        <div id="issueCoverList" class="small"></div>
      </div>

'''
    t = t.replace(needle, box + needle, 1)
js = r'''
function fillIssueMonths(){const sel=document.getElementById("issueMonth");if(!sel||sel.options.length)return;const now=new Date();for(let i=0;i<24;i++){const d=new Date(now.getFullYear(),now.getMonth()-i,1);const v=d.getFullYear()+"-"+String(d.getMonth()+1).padStart(2,"0");sel.insertAdjacentHTML("beforeend","<option value=\""+v+"\">"+v+"</option>");}}
async function refreshIssueCovers(){const list=document.getElementById("issueCoverList");if(!list)return;try{const data=await(await fetch("/content/issues.json?ts="+Date.now())).json();list.innerHTML=(data.issues||[]).map(i=>"<div>"+(i.month||"")+" — "+(i.cover?"cover set":"title only")+"</div>").join("")||"No uploaded covers yet.";}catch(e){list.textContent="Cover list unavailable.";}}
async function saveIssueCover(){const key=(document.getElementById("key")||{}).value||"";const month=(document.getElementById("issueMonth")||{}).value;const file=document.getElementById("issueCoverFile")&&document.getElementById("issueCoverFile").files[0];const status=document.getElementById("sideStatus")||document.getElementById("status");const say=t=>{if(status)status.textContent=t;};try{if(!String(key).trim())throw new Error("publish password required");if(!file)throw new Error("choose a cover image");const form=new FormData();form.append("key",String(key).trim());form.append("month",month);form.append("image",file);say("Saving cover...");const data=await(await fetch("/api/save_issue_cover.php",{method:"POST",body:form})).json();if(!data.success)throw new Error(data.error||"save failed");const prev=document.getElementById("issueCoverPreview");if(prev&&data.cover)prev.style.backgroundImage="url("+data.cover+"?ts="+Date.now()+")";say("Cover saved for "+data.month);await refreshIssueCovers();}catch(e){say("Cover error: "+e.message);}}
document.getElementById("issueCoverSave")&&document.getElementById("issueCoverSave").addEventListener("click",saveIssueCover);
fillIssueMonths();refreshIssueCovers();
'''
if 'function fillIssueMonths' not in t:
    t = t.replace("loadArticles();\n</script>", "loadArticles();\n" + js + "\n</script>")
if ">Politics<" not in t and "<option>Society</option>" in t:
    t = t.replace("<option>Society</option>", "<option>Society</option>\n            <option>Politics</option>", 1)
p.write_text(t, encoding="utf-8")
print("article admin patched")
PY

echo OK-partial-need-ads-patch
