(() => {
  function esc(s) {
    return String(s || '').replace(/&/g, '&').replace(/</g, '<').replace(/>/g, '>').replace(/"/g, '"');
  }
  function urlOf(a) {
    return a.url || ('articles/' + (a.slug || '') + '.html');
  }
  async function run() {
    const text = document.querySelector('.herotext');
    const imgBox = document.querySelector('.heroimg');
    if (!text || !imgBox) return;
    const r = await fetch('/content/articles.json?ts=' + Date.now());
    const data = await r.json();
    const list = Array.isArray(data) ? data : (data.articles || []);
    const a = list[0];
    if (!a) return;
    const src = a.heroImage || a.cardImage || '';
    const href = esc(urlOf(a));
    text.innerHTML =
      '<p class="feat-kicker">Featured story</p>' +
      '<p class="feat-dek">' + esc(a.dek || a.excerpt || '') + '</p>' +
      '<a class="outline" href="' + href + '">Read story</a>';
    if (src) {
      const url = src.charAt(0) === '/' || src.indexOf('http') === 0 ? src : '/' + src;
      imgBox.style.backgroundImage = 'none';
      imgBox.innerHTML = '<a href="' + href + '"><img src="' + esc(url) + '" alt=""></a>';
    }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { run().catch(console.error); });
  else run().catch(console.error);
})();
