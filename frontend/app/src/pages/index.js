import { renderShell, renderNotice } from '../components/layout.js';
import { mount, escapeHtml } from './common.js';

renderShell({
  page: 'index',
  tag: 'Frontend App',
  content: '<div class="hero"><h2>로딩 중</h2></div>'
});

mount(`
  <article class="hero">
    <h2>SpeakFlow P1 프론트</h2>
    <p>실제 프론트 구조입니다. 이 앱은 backend API만 사용하며, DB에 없는 값은 화면에 표시하지 않습니다.</p>
    <div class="grid-3">
      <article class="card">
        <h3>인증</h3>
        <p>회원가입, 로그인, 세션 갱신, 로그아웃</p>
        <div class="btn-row"><a class="link-btn primary" href="/signup">회원가입</a><a class="link-btn" href="/login">로그인</a></div>
      </article>
      <article class="card">
        <h3>탐색</h3>
        <p>카테고리 조회, 강의 목록 조회, 강의 상세 조회</p>
        <div class="btn-row"><a class="link-btn primary" href="/categories">카테고리</a><a class="link-btn" href="/courses">강의 목록</a></div>
      </article>
      <article class="card">
        <h3>학습</h3>
        <p>수강 신청, 강의 시청, 진도 저장, 내 강의/진도 조회</p>
        <div class="btn-row"><a class="link-btn primary" href="/my-courses">내 강의</a><a class="link-btn" href="/progress">진도 관리</a></div>
      </article>
    </div>
  </article>
  ${renderNotice('backend API가 켜져 있어야 실제 데이터가 렌더링됩니다.', 'success')}
  <article class="card">
    <h3>사용 경로</h3>
    <ul class="list-clean">
      <li>회원가입 또는 로그인</li>
      <li>카테고리에서 강의 탐색</li>
      <li>강의 상세에서 수강 신청</li>
      <li>내 강의와 진도 화면에서 학습 상태 확인</li>
    </ul>
  </article>
`);
