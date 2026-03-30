import { signup } from '../api/auth.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, escapeHtml } from './common.js';

renderShell({ page: 'signup', tag: '회원가입', content: '' });
mount(`
  <article class="form-card">
    <h2>회원가입</h2>
    <p class="small-note">요청 필드: name, email, password</p>
    <form id="signup-form">
      <div class="field"><label for="name">이름</label><input id="name" name="name" required /></div>
      <div class="field"><label for="email">이메일</label><input id="email" name="email" type="email" required /></div>
      <div class="field"><label for="password">비밀번호</label><input id="password" name="password" type="password" minlength="8" required /></div>
      <div class="btn-row"><button class="btn primary" type="submit">회원가입</button></div>
    </form>
    <div id="signup-message"></div>
  </article>
`);

const form = document.querySelector('#signup-form');
const message = document.querySelector('#signup-message');
form.addEventListener('submit', async event => {
  event.preventDefault();
  message.innerHTML = '';
  const formData = new FormData(form);
  try {
    const result = await signup(Object.fromEntries(formData.entries()));
    message.innerHTML = renderNotice(`${escapeHtml(result.user.email)} 계정이 생성되었습니다.`, 'success');
    form.reset();
  } catch (error) {
    message.innerHTML = renderNotice(escapeHtml(error.message));
  }
});
