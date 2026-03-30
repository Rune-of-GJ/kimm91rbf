import { fetchCategories } from '../api/catalog.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, escapeHtml } from './common.js';

renderShell({ page: 'categories', tag: '카테고리', content: '' });
mount('<article class="hero"><h2>카테고리 로딩 중</h2></article>');

async function init() {
  try {
    const categories = await fetchCategories();
    const cards = categories.map(category => `
      <article class="card">
        <h3>${escapeHtml(category.name)}</h3>
        <p>${escapeHtml(category.description || '')}</p>
        <div class="btn-row"><a class="link-btn primary" href="/courses?category_id=${category.id}&category_name=${encodeURIComponent(category.name)}">강의 보기</a></div>
      </article>
    `).join('');

    mount(`
      <article class="hero">
        <h2>강의 카테고리</h2>
        <p>카테고리 응답 필드: id, name, description</p>
      </article>
      <section class="grid-3">${cards}</section>
    `);
  } catch (error) {
    mount(`
      <article class="hero">
        <h2>강의 카테고리</h2>
        ${renderNotice(escapeHtml(error.message))}
      </article>
    `);
  }
}

init();
