// ShipGlows local API proxy. Serves Vercel-style Node handlers under /api/* on the same origin as the
// Flutter web server, and forwards every other request (HTTP and WebSocket upgrades) to that server.
// Zero dependencies. Started by ShipGlows.FlutterSupervisor.ps1 under the declared Doppler scope.
// Usage: node ShipGlows.ApiProxy.cjs --listen 127.0.0.1:<port> --flutter 127.0.0.1:<port> --root <api dir>
'use strict';

const fs = require('node:fs');
const http = require('node:http');
const net = require('node:net');
const path = require('node:path');
const querystring = require('node:querystring');
const { pathToFileURL } = require('node:url');

const MAX_BODY_BYTES = 1024 * 1024;
const PUBLIC_NAME_PATTERN = /^[A-Z][A-Z0-9_]{0,95}$/;
const HANDLER_EXTENSIONS = ['.js', '.cjs', '.mjs'];

let logFile = null;

// Requests and handler failures go to stdout and, when --log is given, to the session's api.log.
function report(line) {
  console.log(line);
  if (!logFile) return;
  try { fs.appendFileSync(logFile, `${new Date().toISOString()} ${line}\n`); } catch { /* best effort */ }
}

function parseOptions(argv) {
  const options = {};
  for (let index = 0; index < argv.length; index += 2) {
    const name = argv[index];
    const value = argv[index + 1];
    if (!name || !name.startsWith('--') || value === undefined) throw new Error(`Invalid argument: ${name}`);
    options[name.slice(2)] = value;
  }
  for (const required of ['listen', 'flutter', 'root']) {
    if (!options[required]) throw new Error(`Missing --${required}`);
  }
  return options;
}

function parseEndpoint(value) {
  const separator = value.lastIndexOf(':');
  const port = Number(value.slice(separator + 1));
  if (separator < 0 || !Number.isInteger(port) || port < 1024 || port > 65535) throw new Error(`Invalid endpoint: ${value}`);
  return { host: value.slice(0, separator), port };
}

// Public Flutter defines (already resolved for this web origin) reach the handlers as process env.
// Doppler secrets are injected before this process starts, so these values win on name clashes.
function applyPublicEnvironment() {
  const raw = process.env.SHIPGLOWS_API_PUBLIC_ENV;
  delete process.env.SHIPGLOWS_API_PUBLIC_ENV;
  if (!raw) return 0;
  let applied = 0;
  for (const [name, value] of Object.entries(JSON.parse(raw))) {
    if (!PUBLIC_NAME_PATTERN.test(name) || typeof value !== 'string') continue;
    process.env[name] = value;
    applied += 1;
  }
  return applied;
}

function isFile(candidate) {
  try { return fs.statSync(candidate).isFile(); } catch { return false; }
}

function isDirectory(candidate) {
  try { return fs.statSync(candidate).isDirectory(); } catch { return false; }
}

// A missing api/ directory is a normal state (vercel.json functions without a root): every /api path 404s.
function readDirectory(directory) {
  try { return fs.readdirSync(directory, { withFileTypes: true }); } catch { return []; }
}

function findHandlerFile(basePath) {
  for (const extension of HANDLER_EXTENSIONS) {
    if (isFile(basePath + extension)) return basePath + extension;
  }
  return null;
}

// Vercel file routing: static segments first, then [param] and [...catchAll] segments.
function matchRoute(directory, segments, params) {
  if (segments.length === 0) {
    const index = findHandlerFile(path.join(directory, 'index'));
    return index ? { file: index, params } : null;
  }
  const [head, ...rest] = segments;
  if (rest.length === 0) {
    const file = findHandlerFile(path.join(directory, head));
    if (file) return { file, params };
  }
  const subdirectory = path.join(directory, head);
  if (isDirectory(subdirectory)) {
    const match = matchRoute(subdirectory, rest, params);
    if (match) return match;
  }
  for (const entry of readDirectory(directory)) {
    const catchAll = entry.name.match(/^\[\.\.\.([A-Za-z0-9_]+)\]\.(js|cjs|mjs)$/);
    if (catchAll && entry.isFile()) {
      return { file: path.join(directory, entry.name), params: { ...params, [catchAll[1]]: segments } };
    }
    const single = entry.name.match(/^\[([A-Za-z0-9_]+)\]\.(js|cjs|mjs)$/);
    if (single && entry.isFile() && rest.length === 0) {
      return { file: path.join(directory, entry.name), params: { ...params, [single[1]]: head } };
    }
    const dynamicDirectory = entry.name.match(/^\[([A-Za-z0-9_]+)\]$/);
    if (dynamicDirectory && entry.isDirectory()) {
      const match = matchRoute(path.join(directory, entry.name), rest, { ...params, [dynamicDirectory[1]]: head });
      if (match) return match;
    }
  }
  return null;
}

function nearestPackageType(file) {
  let directory = path.dirname(file);
  for (;;) {
    const manifest = path.join(directory, 'package.json');
    if (isFile(manifest)) {
      try { return JSON.parse(fs.readFileSync(manifest, 'utf8')).type ?? 'commonjs'; } catch { return 'commonjs'; }
    }
    const parent = path.dirname(directory);
    if (parent === directory) return 'commonjs';
    directory = parent;
  }
}

function isEsmFile(file) {
  if (file.endsWith('.mjs')) return true;
  if (file.endsWith('.cjs')) return false;
  return nearestPackageType(file) === 'module';
}

// Handlers reload on every request so edits apply without restarting the proxy (development only).
async function loadHandler(file, root) {
  let loaded;
  if (isEsmFile(file)) {
    loaded = await import(`${pathToFileURL(file).href}?v=${fs.statSync(file).mtimeMs}`);
  } else {
    for (const key of Object.keys(require.cache)) {
      if (key.startsWith(root + path.sep)) delete require.cache[key];
    }
    loaded = require(file);
  }
  const handler = typeof loaded === 'function' ? loaded : loaded?.default;
  return typeof handler === 'function' ? handler : null;
}

function sendJson(res, status, body) {
  if (res.headersSent) return res.end();
  res.statusCode = status;
  res.setHeader('content-type', 'application/json; charset=utf-8');
  res.end(JSON.stringify(body));
}

// Vercel's Node runtime helpers: req.query, req.cookies, req.body and res.status/json/send/redirect.
function parseCookies(header) {
  const cookies = {};
  for (const pair of (header || '').split(';')) {
    const separator = pair.indexOf('=');
    if (separator < 1) continue;
    const name = pair.slice(0, separator).trim();
    try { cookies[name] = decodeURIComponent(pair.slice(separator + 1).trim()); } catch { cookies[name] = pair.slice(separator + 1).trim(); }
  }
  return cookies;
}

function buildQuery(searchParams, routeParams) {
  const query = {};
  for (const key of new Set(searchParams.keys())) {
    const values = searchParams.getAll(key);
    query[key] = values.length > 1 ? values : values[0];
  }
  return { ...query, ...routeParams };
}

function parseBody(req, buffer) {
  if (buffer.length === 0) return undefined;
  const contentType = String(req.headers['content-type'] || '');
  const text = buffer.toString('utf8');
  if (contentType.includes('application/json')) return JSON.parse(text);
  if (contentType.includes('application/x-www-form-urlencoded')) return querystring.parse(text);
  return text;
}

function readBody(req) {
  if (req.method === 'GET' || req.method === 'HEAD') return Promise.resolve(Buffer.alloc(0));
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > MAX_BODY_BYTES) {
        req.destroy();
        reject(Object.assign(new Error('Request body too large'), { status: 413 }));
        return;
      }
      chunks.push(chunk);
    });
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

function augmentResponse(res) {
  res.status = (code) => {
    res.statusCode = code;
    return res;
  };
  res.json = (body) => {
    if (!res.hasHeader('content-type')) res.setHeader('content-type', 'application/json; charset=utf-8');
    res.end(JSON.stringify(body));
    return res;
  };
  res.send = (body) => {
    if (typeof body === 'string' || Buffer.isBuffer(body)) {
      res.end(body);
      return res;
    }
    return res.json(body);
  };
  res.redirect = (statusOrLocation, location) => {
    const status = typeof statusOrLocation === 'number' ? statusOrLocation : 307;
    res.statusCode = status;
    res.setHeader('location', typeof statusOrLocation === 'number' ? location : statusOrLocation);
    res.end();
    return res;
  };
  return res;
}

async function handleApiRequest(req, res, url, root) {
  const started = Date.now();
  let segments;
  try {
    segments = url.pathname.slice('/api'.length).split('/').filter(Boolean).map(decodeURIComponent);
  } catch {
    return sendJson(res, 400, { error: 'BAD_REQUEST', message: 'Malformed URL path.' });
  }
  if (segments.some((segment) => segment === '.' || segment === '..' || /[\\\0/]/.test(segment))) {
    return sendJson(res, 400, { error: 'BAD_REQUEST', message: 'Invalid URL path.' });
  }
  const match = matchRoute(root, segments, {});
  const handler = match ? await loadHandler(match.file, root) : null;
  if (!handler) {
    sendJson(res, 404, { error: 'NOT_FOUND', message: 'No API handler for this path.' });
    report(`[api] ${req.method} ${url.pathname} 404 ${Date.now() - started}ms`);
    return;
  }
  let buffer;
  try {
    buffer = await readBody(req);
  } catch (error) {
    return sendJson(res, error.status || 400, { error: 'BAD_REQUEST', message: error.message });
  }
  try {
    req.query = buildQuery(url.searchParams, match.params);
    req.cookies = parseCookies(req.headers.cookie);
    req.body = parseBody(req, buffer);
  } catch {
    return sendJson(res, 400, { error: 'BAD_REQUEST', message: 'Invalid request body.' });
  }
  try {
    await handler(req, augmentResponse(res));
  } catch (error) {
    report(`[api] ${req.method} ${url.pathname} handler error: ${error.message}`);
    sendJson(res, 500, { error: 'INTERNAL_ERROR', message: 'The API handler failed. See the session logs.' });
  }
  report(`[api] ${req.method} ${url.pathname} ${res.statusCode} ${Date.now() - started}ms`);
}

function forwardHttp(req, res, flutter) {
  const upstream = http.request(
    { host: flutter.host, port: flutter.port, method: req.method, path: req.url, headers: req.headers },
    (upstreamResponse) => {
      res.writeHead(upstreamResponse.statusCode || 502, upstreamResponse.headers);
      upstreamResponse.pipe(res);
    },
  );
  upstream.on('error', () => {
    if (res.headersSent) return res.destroy();
    res.writeHead(502, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('The Flutter web server is not reachable yet.');
  });
  req.pipe(upstream);
}

function forwardUpgrade(req, socket, head, flutter) {
  const upstream = net.connect(flutter.port, flutter.host, () => {
    const headerLines = [];
    for (let index = 0; index < req.rawHeaders.length; index += 2) {
      headerLines.push(`${req.rawHeaders[index]}: ${req.rawHeaders[index + 1]}`);
    }
    upstream.write(`${req.method} ${req.url} HTTP/${req.httpVersion}\r\n${headerLines.join('\r\n')}\r\n\r\n`);
    if (head && head.length > 0) upstream.write(head);
    socket.pipe(upstream).pipe(socket);
  });
  upstream.on('error', () => socket.destroy());
  socket.on('error', () => upstream.destroy());
  upstream.on('close', () => socket.destroy());
  socket.on('close', () => upstream.destroy());
}

function isApiPath(pathname) {
  return pathname === '/api' || pathname.startsWith('/api/');
}

function main() {
  const options = parseOptions(process.argv.slice(2));
  const listen = parseEndpoint(options.listen);
  const flutter = parseEndpoint(options.flutter);
  const root = fs.existsSync(options.root) ? fs.realpathSync(options.root) : path.resolve(options.root);
  logFile = options.log || null;
  const publicCount = applyPublicEnvironment();

  const server = http.createServer((req, res) => {
    const url = new URL(req.url, 'http://127.0.0.1');
    if (isApiPath(url.pathname)) {
      handleApiRequest(req, res, url, root).catch((error) => {
        report(`[api] ${req.method} ${url.pathname} proxy error: ${error.message}`);
        sendJson(res, 500, { error: 'INTERNAL_ERROR', message: 'The API proxy failed.' });
      });
      return;
    }
    forwardHttp(req, res, flutter);
  });

  server.on('upgrade', (req, socket, head) => {
    const url = new URL(req.url, 'http://127.0.0.1');
    if (isApiPath(url.pathname)) {
      socket.destroy();
      return;
    }
    forwardUpgrade(req, socket, head, flutter);
  });

  server.on('error', (error) => {
    report(`[api] listen failed on ${options.listen}: ${error.message}`);
    process.exit(1);
  });

  server.listen(listen.port, listen.host, () => {
    report(`[api] listening on ${options.listen}; flutter ${options.flutter}; api root ${root}; public env ${publicCount}`);
  });
}

main();
