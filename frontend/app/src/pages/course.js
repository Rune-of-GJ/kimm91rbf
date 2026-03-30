import { enrollCourse, fetchCourse } from '../api/catalog.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, qs, escapeHtml, boolClass, boolText } from './common.js';

renderShell({ page: 'course', tag: '강의 상세', content: '' });
mount('<article class="hero"><h2>강의 상세 로딩 중</h2></article>');

async function renderPage() {
  const courseId = qs('id');
  if (!courseId) {
    mount('<article class="hero"><h2>강의 상세</h2><div class="empty">course id가 필요합니다. 예: /course?id=1</div></article>');
    return;
  }

  try {
    const course = await fetchCourse(courseId);
    const curriculum = course.curriculum.map(lecture => `
      <tr>
        <td>${lecture.order_no}</td>
        <td><a href="/lecture?id=${lecture.id}&course_id=${course.id}">${escapeHtml(lecture.title)}</a></td>
        <td>${escapeHtml(lecture.duration)}</td>
      </tr>
    `).join('');

    mount(`
      <article class="hero">
        <h2>${escapeHtml(course.title)}</h2>
        <p>${escapeHtml(course.description)}</p>
        <div class="badge-row">
          <span class="badge">강사: ${escapeHtml(course.instructor_name)}</span>
          <span class="badge">카테고리: ${escapeHtml(course.category_name)}</span>
          <span class="badge">수강 여부: ${escapeHtml(boolText(course.enrolled))}</span>
        </div>
        <div class="btn-row">
          <button class="btn accent" type="button" id="enroll-btn">수강 신청</button>
          <a class="link-btn" href="/courses?category_id=${course.category_id}&category_name=${encodeURIComponent(course.category_name)}">목록으로</a>
        </div>
        <div id="course-message"></div>
      </article>
      <div class="grid-2">
        <article class="card">
          <h3>강의 정보</h3>
          <div class="meta">
            <div><span>start_date</span><code>${escapeHtml(course.availability.start_date ?? 'null')}</code></div>
            <div><span>end_date</span><code>${escapeHtml(course.availability.end_date ?? 'null')}</code></div>
            <div><span>enrollment_deadline</span><code>${escapeHtml(course.availability.enrollment_deadline ?? 'null')}</code></div>
            <div><span>max_access_days</span><code>${escapeHtml(course.availability.max_access_days ?? 'null')}</code></div>
            <div><span>available</span><code class="${boolClass(course.availability.available)}">${boolText(course.availability.available)}</code></div>
            <div><span>enrollment_open</span><code class="${boolClass(course.availability.enrollment_open)}">${boolText(course.availability.enrollment_open)}</code></div>
          </div>
        </article>
        <article class="card">
          <h3>커리큘럼</h3>
          <table class="table">
            <tr><th>order_no</th><th>title</th><th>duration</th></tr>
            ${curriculum}
          </table>
        </article>
      </div>
    `);

    document.querySelector('#enroll-btn').addEventListener('click', async () => {
      const message = document.querySelector('#course-message');
      try {
        await enrollCourse(course.id);
        message.innerHTML = renderNotice('수강 신청이 처리되었습니다.', 'success');
      } catch (error) {
        message.innerHTML = renderNotice(escapeHtml(error.message));
      }
    });
  } catch (error) {
    mount(`
      <article class="hero">
        <h2>강의 상세</h2>
        ${renderNotice(escapeHtml(error.message))}
      </article>
    `);
  }
}

renderPage();
