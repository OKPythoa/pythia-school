(() => {
  function esc(s) {
    return String(s || '').replace(/&/g, '&').replace(/</g, '<').replace(/>/g, '>').replace(/"/g, '"');
  }
  function urlOf(a) {
    return a.url || ('articles/' + (a.slug || '') + '.html');
  }
  async function run() {
    const hero = document.querySelector('.hero');
    const text = document.querySelector('.herotext');
    const imgBox = document.querySelector('.heroimg');
    if (!hero || !text || !imgBox) return;
    const r = await fetch('/content/articles.json?ts=' + Date.now());
    const data = await r.json();
    const list = Array.isArray(data) ? data : (data.articles || []);
    const a = list[0];
    if (!a) return;
    window.AG_FEATURED_SLUG = String(a.slug || '');
    const src = a.heroImage || a.cardImage || '';
    const href = esc(urlOf(a));
    const url = src ? (src.charAt(0) === '/' || src.indexOf('http') === 0 ? src : '/' + src) : '';
    hero.classList.add('hero-featured');
    text.innerHTML =
      '<p class="feat-kicker">Featured story</p>' +
      '<p class="feat-dek">' + esc(a.dek || a.excerpt || '') + '</p>' +
      '<a class="outline" href="' + href + '">Read story</a>';
    imgBox.style.backgroundImage = 'none';
    imgBox.innerHTML = url ? ('<a href="' + href + '"><img src="' + esc(url) + '" alt="' + esc(a.title || '') + '"></a>') : '';
    const latest = document.getElementById('latestCards');
    if (latest) {
      latest.querySelectorAll('a.card').forEach(function (card) {
        const hrefCard = card.getAttribute('href') || '';
        if (window.AG_FEATURED_SLUG && hrefCard.indexOf(window.AG_FEATURED_SLUG) !== -1) card.remove();
      });
    }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { run().catch(console.error); });
  else run().catch(console.error);
  window.addEventListener('load', function () {
    const latest = document.getElementById('latestCards');
    if (!latest || !window.AG_FEATURED_SLUG) return;
    latest.querySelectorAll('a.card').forEach(function (card) {
      const hrefCard = card.getAttribute('href') || '';
      if (hrefCard.indexOf(window.AG_FEATURED_SLUG) !== -1) card.remove();
    });
  });
})();
