import { fetchCourses } from '../api/catalog.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, qs, escapeHtml, boolClass, boolText } from './common.js';

renderShell({ page: 'courses', tag: '강의 목록', content: '' });
mount('<article class="hero"><h2>강의 목록 로딩 중</h2></article>');

async function init() {
  const categoryId = qs('category_id');
  const categoryName = qs('category_name') || '전체';

  try {
    const courses = await fetchCourses(categoryId);
    const content = courses.length === 0 ? '<article class="empty">표시할 강의가 없습니다.</article>' : courses.map(course => `
      <article class="card">
        <h3>${escapeHtml(course.title)}</h3>
        <p>${escapeHtml(course.description)}</p>
        <div class="meta">
          <div><span>instructor_name</span><code>${escapeHtml(course.instructor_name)}</code></div>
          <div><span>category_name</span><code>${escapeHtml(course.category_name)}</code></div>
          <div><span>lectures_count</span><code>${escapeHtml(course.lectures_count)}</code></div>
          <div><span>enrolled</span><code class="${boolClass(course.enrolled)}">${boolText(course.enrolled)}</code></div>
        </div>
        <div class="btn-row">
          <a class="link-btn primary" href="/course?id=${course.id}">상세 보기</a>
        </div>
      </article>
    `).join('');

    mount(`
      <article class="hero">
        <h2>${escapeHtml(categoryName)} 강의 목록</h2>
        <p>강의 목록 응답 필드만 표시합니다.</p>
      </article>
      <section class="stack">${content}</section>
    `);
  } catch (error) {
    mount(`
      <article class="hero">
        <h2>강의 목록</h2>
        ${renderNotice(escapeHtml(error.message))}
      </article>
    `);
  }
}

init();
