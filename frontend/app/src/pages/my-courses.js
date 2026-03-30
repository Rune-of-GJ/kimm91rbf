import { fetchMyCourses } from '../api/progress.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, escapeHtml } from './common.js';

renderShell({ page: 'my-courses', tag: '내 강의', content: '' });
mount('<article class="hero"><h2>내 강의 로딩 중</h2></article>');

async function init() {
  try {
    const courses = await fetchMyCourses();
    const content = courses.length === 0 ? '<article class="empty">수강 중인 강의가 없습니다.</article>' : courses.map(course => `
      <article class="card">
        <h3>${escapeHtml(course.title)}</h3>
        <p>${escapeHtml(course.description)}</p>
        <div class="meta">
          <div><span>instructor_name</span><code>${escapeHtml(course.instructor_name)}</code></div>
          <div><span>category_id</span><code>${escapeHtml(course.category_id)}</code></div>
          <div><span>total_lectures</span><code>${escapeHtml(course.total_lectures)}</code></div>
          <div><span>watched_lectures</span><code>${escapeHtml(course.watched_lectures)}</code></div>
          <div><span>progress_rate</span><code>${escapeHtml(course.progress_rate)}</code></div>
        </div>
        <div class="progress"><span style="width:${Number(course.progress_rate) || 0}%;"></span></div>
        <div class="btn-row">
          <a class="link-btn primary" href="/course?id=${course.id}">상세 보기</a>
          <a class="link-btn" href="/progress">진도 보기</a>
        </div>
      </article>
    `).join('');

    mount(`
      <article class="hero">
        <h2>내 강의 목록</h2>
        <p>API 응답 기준: title, description, instructor_name, total_lectures, watched_lectures, progress_rate</p>
      </article>
      <section class="stack">${content}</section>
    `);
  } catch (error) {
    mount(`
      <article class="hero">
        <h2>내 강의 목록</h2>
        ${renderNotice(escapeHtml(error.message))}
      </article>
    `);
  }
}

init();
