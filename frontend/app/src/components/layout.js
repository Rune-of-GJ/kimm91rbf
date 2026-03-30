const navItems = [
  ['index', '/', '홈'],
  ['signup', '/signup', '회원가입'],
  ['login', '/login', '로그인'],
  ['categories', '/categories', '카테고리'],
  ['courses', '/courses', '강의 목록'],
  ['course', '/course', '강의 상세'],
  ['my-courses', '/my-courses', '내 강의'],
  ['lecture', '/lecture', '강의 시청'],
  ['progress', '/progress', '진도 관리']
];

export function renderShell({ page, tag, content }) {
  const menu = navItems.map(([id, href, label]) => {
    const active = id === page ? 'active' : '';
    return `<a class="${active}" href="${href}">${label}</a>`;
  }).join('');

  document.body.innerHTML = `
    <main class="shell">
      <header class="topbar">
        <h1 class="brand">SPEAKFLOW P1</h1>
        <span class="tag">${tag}</span>
      </header>
      <section class="layout">
        <aside class="sidebar">
          <p class="menu-title">Pages</p>
          <nav class="menu">${menu}</nav>
        </aside>
        <section class="content" id="app-content">${content}</section>
      </section>
    </main>
  `;
}

export function renderNotice(message, type = 'error') {
  return `<div class="notice ${type}">${message}</div>`;
}
