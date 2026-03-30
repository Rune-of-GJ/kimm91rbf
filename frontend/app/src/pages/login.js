import { login, logout, refreshSession } from '../api/auth.js';
import { renderShell, renderNotice } from '../components/layout.js';
import { mount, escapeHtml } from './common.js';

renderShell({ page: 'login', tag: '로그인', content: '' });
mount(`
  <article class="form-card">
    <h2>로그인</h2>
    <p class="small-note">세션 기반 인증입니다.</p>
    <form id="login-form">
      <div class="field"><label for="email">이메일</label><input id="email" name="email" type="email" required /></div>
      <div class="field"><label for="password">비밀번호</label><input id="password" name="password" type="password" required /></div>
      <div class="btn-row">
        <button class="btn primary" type="submit">로그인</button>
        <button class="btn" type="button" id="refresh-btn">세션 갱신</button>
        <button class="btn" type="button" id="logout-btn">로그아웃</button>
      </div>
    </form>
    <div id="login-message"></div>
    <div id="session-state" class="card" style="margin-top:12px;"></div>
  </article>
`);

const form = document.querySelector('#login-form');
const message = document.querySelector('#login-message');
const sessionState = document.querySelector('#session-state');

async function renderSession() {
  try {
    const result = await refreshSession();
    sessionState.innerHTML = `
      <h3>현재 세션</h3>
      <div class="meta">
        <div><span>email</span><code>${escapeHtml(result.user.email)}</code></div>
        <div><span>name</span><code>${escapeHtml(result.user.name)}</code></div>
        <div><span>role</span><code>${escapeHtml(result.user.role)}</code></div>
        <div><span>token_type</span><code>${escapeHtml(result.token_type)}</code></div>
        <div><span>expires_in</span><code>${escapeHtml(result.expires_in)}</code></div>
      </div>
    `;
  } catch {
    sessionState.innerHTML = '<h3>현재 세션</h3><p>로그인 상태가 아닙니다.</p>';
  }
}

form.addEventListener('submit', async event => {
  event.preventDefault();
  message.innerHTML = '';
  const payload = Object.fromEntries(new FormData(form).entries());
  try {
    const result = await login(payload);
    message.innerHTML = renderNotice(`${escapeHtml(result.user.name)} 로그인 성공`, 'success');
    await renderSession();
  } catch (error) {
    message.innerHTML = renderNotice(escapeHtml(error.message));
  }
});

document.querySelector('#refresh-btn').addEventListener('click', async () => {
  message.innerHTML = '';
  try {
    const result = await refreshSession();
    message.innerHTML = renderNotice(`${escapeHtml(result.user.email)} 세션이 유효합니다.`, 'success');
    await renderSession();
  } catch (error) {
    message.innerHTML = renderNotice(escapeHtml(error.message));
    await renderSession();
  }
});

document.querySelector('#logout-btn').addEventListener('click', async () => {
  message.innerHTML = '';
  try {
    await logout();
    message.innerHTML = renderNotice('로그아웃 완료', 'success');
    await renderSession();
  } catch (error) {
    message.innerHTML = renderNotice(escapeHtml(error.message));
  }
});

renderSession();

