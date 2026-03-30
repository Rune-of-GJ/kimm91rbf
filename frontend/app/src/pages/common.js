export function qs(name) {
  return new URLSearchParams(window.location.search).get(name);
}

export function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

export function boolClass(value) {
  return value ? 'status-true' : 'status-false';
}

export function boolText(value) {
  return value ? 'true' : 'false';
}

export function formatDate(value) {
  if (!value) return 'null';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return String(value);
  return date.toLocaleString('ko-KR');
}

export function mount(html) {
  const target = document.querySelector('#app-content');
  target.innerHTML = html;
}
