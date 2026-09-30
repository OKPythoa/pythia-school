(() => {
  function esc(s) {
    return String(s || '').replace(/&/g, '&').replace(/</g, '<').replace(/>/g, '>').replace(/"/g, '"');
  }
  function urlOf(a) {
    return a.url || ('articles/' + (a.slug || '') + '.html');
  }
  function hideDup() {
    const latest = document.getElementById('latestCards');
    if (!latest || !window.AG_FEATURED_SLUG) return;
    latest.querySelectorAll('a.card').forEach(function (card) {
      const href = card.getAttribute('href') || '';
      if (href.indexOf(window.AG_FEATURED_SLUG) !== -1) card.remove();
    });
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
      '<p class="feat-kicker">' + esc(a.category || 'Featured') + '</p>' +
      '<h2 class="feat-title"><a href="' + href + '">' + esc(a.title || '') + '</a></h2>' +
      '<p class="feat-dek">' + esc(a.dek || a.excerpt || '') + '</p>' +
      '<p class="feat-meta">' + esc(a.date || '') + (a.readTime ? ' • ' + esc(a.readTime) : '') + '</p>' +
      '<a class="outline" href="' + href + '">Read story</a>';
    imgBox.style.backgroundImage = 'none';
    imgBox.innerHTML = url ? ('<a href="' + href + '"><img src="' + esc(url) + '" alt=""></a>') : '';
    hideDup();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function () { run().catch(console.error); });
  else run().catch(console.error);
  window.addEventListener('load', hideDup);
})();
