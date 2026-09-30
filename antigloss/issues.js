(() => {
  const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December'];
  function parseArticleDate(value) {
    const d = new Date(value);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  function monthKey(date) {
    return date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0');
  }
  function monthLabel(date) {
    return MONTHS[date.getMonth()] + ' ' + date.getFullYear();
  }
  function issueNumber(a, b) {
    return (b.getFullYear() - a.getFullYear()) * 12 + b.getMonth() - a.getMonth() + 1;
  }
  function linesFrom(text) {
    const first = String(text || '').split(/[.!?]/)[0].trim();
    const words = first.split(/\s+/).filter(Boolean);
    const out = [];
    for (let i = 0; i < Math.min(words.length, 8); i += 2) out.push(words.slice(i, i + 2).join(' '));
    return out;
  }
  function barcode(issueNo) {
    const bits = '11010011010110101101011011010110101101101011010110110101';
    let bars = '';
    for (let i = 0; i < bits.length; i++) bars += '<i class="' + (bits[i] === '1' ? 'on' : 'off') + '"></i>';
    return '<div class="mc-bar"><em>ISSUE ' + issueNo + '</em><span>' + bars + '</span></div>';
  }
  function paint(el, key, label, image, tease, issueNo) {
    const href = 'issue.html?month=' + encodeURIComponent(key);
    const img = image ? '<img src="' + image + '" alt="">' : '';
    const lines = linesFrom(tease).map(function (x) { return '<span>' + x + '</span>'; }).join('');
    el.innerHTML = '<a class="magazine-cover" href="' + href + '"><div class="issue-frame">' + img + '<div class="mc-logo"><i>The</i><b>AntiGloss</b></div><div class="mc-date">' + label + '</div><div class="mc-lines">' + lines + '</div>' + barcode(issueNo) + '</div></a>';
  }
  async function run() {
    const cover = document.getElementById('currentIssueCover');
    if (!cover) return;
    const feedRes = await fetch('/content/articles.json', { cache: 'no-store' });
    const packRes = await fetch('/content/issues.json', { cache: 'no-store' });
    const feed = await feedRes.json();
    const issues = await packRes.json();
    const articles = Array.isArray(feed) ? feed : (feed.articles || []);
    const dated = articles.map(function (a) { return parseArticleDate(a.date); }).filter(Boolean).sort(function (x, y) { return x - y; });
    const now = new Date();
    const key = monthKey(now);
    const first = dated[0] || new Date(now.getFullYear(), now.getMonth(), 1);
    const n = String(issueNumber(first, now)).padStart(2, '0');
    const rec = ((issues && issues.issues) || []).find(function (i) { return i && i.month === key; }) || null;
    const image = rec && rec.cover ? String(rec.cover) : '';
    const tease = rec && rec.tease ? String(rec.tease) : '';
    const btn = document.getElementById('currentIssueButton');
    const num = document.getElementById('currentIssueNumber');
    const date = document.getElementById('currentIssueDate');
    if (num) num.hidden = true;
    if (date) date.hidden = true;
    if (btn) { btn.href = 'issue.html?month=' + encodeURIComponent(key); btn.textContent = 'Read Issue ' + n; }
    paint(cover, key, monthLabel(now), image, tease, n);
    const arch = document.getElementById('issueArchive');
    if (arch) {
      const months = [];
      let c = new Date(first.getFullYear(), first.getMonth(), 1);
      const end = new Date(now.getFullYear(), now.getMonth(), 1);
      while (c <= end) { months.push(new Date(c)); c.setMonth(c.getMonth() + 1); }
      arch.innerHTML = months.reverse().map(function (d) {
        return '<a href="issue.html?month=' + encodeURIComponent(monthKey(d)) + '">Issue ' + String(issueNumber(first, d)).padStart(2, '0') + '</a>';
      }).join('');
    }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { run().catch(console.error); });
  else run().catch(console.error);
})();
