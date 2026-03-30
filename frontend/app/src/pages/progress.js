import { fetchMyProgress } from '../api/progress.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, escapeHtml, formatDate, boolClass, boolText } from './common.js';

renderShell({ page: 'progress', tag: '진도 관리', content: '' });
mount('<article class="hero"><h2>진도 로딩 중</h2></article>');

async function init() {
  try {
    const courses = await fetchMyProgress();
    const content = courses.length === 0 ? '<article class="empty">저장된 진도가 없습니다.</article>' : courses.map(course => `
      <article class="card">
        <h3>${escapeHtml(course.course_title)}</h3>
        <div class="meta">
          <div><span>total_lectures</span><code>${escapeHtml(course.total_lectures)}</code></div>
          <div><span>watched_lectures</span><code>${escapeHtml(course.watched_lectures)}</code></div>
          <div><span>progress_rate</span><code>${escapeHtml(course.progress_rate)}</code></div>
        </div>
        <div class="progress"><span style="width:${Number(course.progress_rate) || 0}%;"></span></div>
        <table class="table">
          <tr><th>order_no</th><th>lecture_title</th><th>watched</th><th>watched_at</th></tr>
          ${course.lectures.map(lecture => `
            <tr>
              <td>${lecture.order_no}</td>
              <td>${escapeHtml(lecture.lecture_title)}</td>
              <td class="${boolClass(lecture.watched)}">${boolText(lecture.watched)}</td>
              <td>${escapeHtml(formatDate(lecture.watched_at))}</td>
            </tr>
          `).join('')}
        </table>
      </article>
    `).join('');

    mount(`
      <article class="hero">
        <h2>학습 진도 관리</h2>
        <p>코스별/강의별 진도 응답을 그대로 표시합니다.</p>
      </article>
      <section class="stack">${content}</section>
    `);
  } catch (error) {
    mount(`
      <article class="hero">
        <h2>학습 진도 관리</h2>
        ${renderNotice(escapeHtml(error.message))}
      </article>
    `);
  }
}

init();
