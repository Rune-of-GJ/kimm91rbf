import { fetchCourseLectures, fetchLecture } from '../api/catalog.js';
import { updateLectureProgress } from '../api/progress.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, qs, escapeHtml, boolClass, boolText } from './common.js';

renderShell({ page: 'lecture', tag: '강의 시청', content: '' });
mount('<article class="hero"><h2>강의 로딩 중</h2></article>');

async function init() {
  const lectureId = qs('id');
  const courseId = qs('course_id');

  if (!lectureId) {
    mount('<article class="hero"><h2>강의 시청</h2><div class="empty">lecture id가 필요합니다. 예: /lecture?id=1&course_id=1</div></article>');
    return;
  }

  try {
    const lecture = await fetchLecture(lectureId);
    const lectures = courseId ? await fetchCourseLectures(courseId) : [lecture];
    const rows = lectures.map(item => `
      <tr>
        <td>${item.order_no}</td>
        <td><a href="/lecture?id=${item.id}&course_id=${item.course_id}">${escapeHtml(item.title)}</a></td>
        <td class="${boolClass(item.watched)}">${boolText(item.watched)}</td>
      </tr>
    `).join('');

    mount(`
      <article class="hero">
        <h2>${escapeHtml(lecture.title)}</h2>
        <p>강의 응답 필드: course_id, title, video_url, order_no, duration, watched</p>
        <div class="badge-row">
          <span class="badge">course_id: ${escapeHtml(lecture.course_id)}</span>
          <span class="badge">order_no: ${escapeHtml(lecture.order_no)}</span>
          <span class="badge">watched: ${escapeHtml(boolText(lecture.watched))}</span>
        </div>
      </article>
      <article class="card" style="margin-top:12px;">
        <h3>영상 정보</h3>
        <div class="video"><div><div>YOUTUBE VIDEO</div><div class="small-note">${escapeHtml(lecture.video_url)}</div></div></div>
        <div class="meta">
          <div><span>video_url</span><code>${escapeHtml(lecture.video_url)}</code></div>
          <div><span>duration</span><code>${escapeHtml(lecture.duration)}</code></div>
        </div>
        <div class="btn-row">
          <a class="link-btn" href="${escapeHtml(lecture.video_url)}" target="_blank" rel="noreferrer">YouTube 열기</a>
          <button class="btn good" type="button" id="watch-btn">시청 완료 저장</button>
        </div>
        <div id="lecture-message"></div>
      </article>
      <article class="card" style="margin-top:12px;">
        <h3>같은 코스의 강의 목록</h3>
        <table class="table">
          <tr><th>order_no</th><th>title</th><th>watched</th></tr>
          ${rows}
        </table>
      </article>
    `);

    document.querySelector('#watch-btn').addEventListener('click', async () => {
      const message = document.querySelector('#lecture-message');
      try {
        await updateLectureProgress(lecture.id, true);
        message.innerHTML = renderNotice('시청 완료가 저장되었습니다.', 'success');
      } catch (error) {
        message.innerHTML = renderNotice(escapeHtml(error.message));
      }
    });
  } catch (error) {
    mount(`
      <article class="hero">
        <h2>강의 시청</h2>
        ${renderNotice(escapeHtml(error.message))}
      </article>
    `);
  }
}

init();
