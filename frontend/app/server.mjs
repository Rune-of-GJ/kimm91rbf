import { createReadStream, existsSync, statSync } from 'node:fs';
import { readFile } from 'node:fs/promises';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = __dirname;
const port = Number(process.env.FRONTEND_PORT || 4173);
const backendOrigin = process.env.BACKEND_ORIGIN || 'http://127.0.0.1:3000';

const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.ico': 'image/x-icon'
};

const pageMap = {
  '/': 'index.html',
  '/index.html': 'index.html',
  '/signup': 'signup.html',
  '/login': 'login.html',
  '/categories': 'categories.html',
  '/courses': 'courses.html',
  '/course': 'course.html',
  '/my-courses': 'my-courses.html',
  '/lecture': 'lecture.html',
  '/progress': 'progress.html'
};

function send(res, status, body, type = 'text/plain; charset=utf-8') {
  res.writeHead(status, { 'Content-Type': type });
  res.end(body);
}

function safeFilePath(requestPath) {
  const mapped = pageMap[requestPath] || requestPath.replace(/^\/+/, '');
  const target = path.resolve(root, mapped);
  if (!target.startsWith(root)) return null;
  return target;
}

async function serveStatic(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const filePath = safeFilePath(url.pathname);
  if (!filePath || !existsSync(filePath)) {
    send(res, 404, 'Not found');
    return;
  }

  const fileStat = statSync(filePath);
  if (fileStat.isDirectory()) {
    const indexPath = path.join(filePath, 'index.html');
    if (!existsSync(indexPath)) {
      send(res, 404, 'Not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    createReadStream(indexPath).pipe(res);
    return;
  }

  const ext = path.extname(filePath).toLowerCase();
  res.writeHead(200, { 'Content-Type': mimeTypes[ext] || 'application/octet-stream' });
  createReadStream(filePath).pipe(res);
}

async function proxyApi(req, res) {
  const targetUrl = new URL(req.url, backendOrigin);
  const body = ['GET', 'HEAD'].includes(req.method) ? undefined : await readRequestBody(req);
  const headers = new Headers();

  for (const [key, value] of Object.entries(req.headers)) {
    if (!value) continue;
    if (['host', 'connection', 'content-length'].includes(key.toLowerCase())) continue;
    headers.set(key, Array.isArray(value) ? value.join('; ') : value);
  }

  const response = await fetch(targetUrl, {
    method: req.method,
    headers,
    body,
    redirect: 'manual'
  });

  const responseHeaders = {};
  response.headers.forEach((value, key) => {
    if (key.toLowerCase() === 'set-cookie') return;
    responseHeaders[key] = value;
  });

  const setCookie = response.headers.getSetCookie?.() || [];
  if (setCookie.length > 0) {
    responseHeaders['set-cookie'] = setCookie;
  }

  res.writeHead(response.status, responseHeaders);
  const buffer = Buffer.from(await response.arrayBuffer());
  res.end(buffer);
}

function readRequestBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', chunk => chunks.push(chunk));
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  try {
    if ((req.url || '').startsWith('/api/')) {
      await proxyApi(req, res);
      return;
    }

    if ((req.url || '').startsWith('/up')) {
      await proxyApi(req, res);
      return;
    }

    await serveStatic(req, res);
  } catch (error) {
    send(res, 500, `Server error: ${error.message}`);
  }
});

server.listen(port, () => {
  console.log(`Frontend server running at http://127.0.0.1:${port}`);
  console.log(`Proxying API requests to ${backendOrigin}`);
});
