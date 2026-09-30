(() => {
  function esc(s) {
    return String(s || '').replace(/&/g, '&').replace(/</g, '<').replace(/>/g, '>').replace(/"/g, '"');
  }
  function urlOf(a) {
    return a.url || ('articles/' + (a.slug || '') + '.html');
  }
  async function run() {
    const text = document.querySelector('.herotext');
    const img = document.querySelector('.heroimg');
    if (!text || !img) return;
    const r = await fetch('/content/articles.json?ts=' + Date.now());
    const data = await r.json();
    const list = Array.isArray(data) ? data : (data.articles || []);
    const a = list[0];
    if (!a) return;
    const src = a.heroImage || a.cardImage || '';
    text.innerHTML =
      '<p class="feat-kicker">Featured story</p>' +
      '<h1><a href="' + esc(urlOf(a)) + '">' + esc(a.title || '') + '</a></h1>' +
      '<p>' + esc(a.dek || a.excerpt || '') + '</p>' +
      '<a class="outline" href="' + esc(urlOf(a)) + '">Read story</a>';
    if (src) {
      const url = src.charAt(0) === '/' || src.indexOf('http') === 0 ? src : '/' + src;
      img.style.backgroundImage =
        'linear-gradient(90deg,rgba(7,7,8,.72),rgba(7,7,8,.12) 42%,rgba(7,7,8,0) 70%),url(\'' + url + '\')';
      img.style.backgroundSize = 'cover';
      img.style.backgroundPosition = 'center';
    }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { run().catch(console.error); });
  else run().catch(console.error);
})();
