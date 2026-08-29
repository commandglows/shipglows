'use strict';

const path = require('path');
const fs = require('fs');

function parseArgs(argv) {
  const result = { headless: false, json: false };
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (token === '--headless') result.headless = true;
    else if (token === '--json') result.json = true;
    else if (token === '--extension') result.extension = argv[++index];
    else if (token === '--playwright') result.playwright = argv[++index];
    else throw new Error('Unknown argument: ' + token);
  }
  if (!result.extension || !result.playwright) throw new Error('Both --extension and --playwright are required.');
  return result;
}

function emit(payload, asJson) {
  if (asJson) process.stdout.write(JSON.stringify(payload) + '\n');
  else {
    process.stdout.write('Extension loaded: ' + payload.name + ' ' + payload.version + '\n');
    process.stdout.write('Extension id: ' + payload.extensionId + '\n');
    process.stdout.write('Isolated profile: ' + payload.profile + '\n');
    process.stdout.write('Service worker: ' + payload.serviceWorker.status + '\n');
    process.stdout.write('Popup: ' + payload.popup.status + '\n');
    process.stdout.write('Verdict: ' + payload.verdict + '\n');
    process.stdout.write(payload.headless ? 'Headless proof complete.\n' : 'Close the Chromium window to stop the lab.\n');
  }
}

function safeDiagnostic(value) {
  return String(value || '')
    .replace(/\b(token|secret|password|api[-_]?key)\s*[:=]\s*\S+/gi, '$1=[redacted]')
    .slice(0, 500);
}

async function observeServiceWorker(session, extensionId, manifest) {
  const declared = Boolean(manifest.background && manifest.background.service_worker);
  const deadline = Date.now() + 3000;
  let workers = [];
  do {
    const targets = await session.send('Target.getTargets');
    workers = targets.targetInfos.filter((target) => target.type === 'service_worker' && target.url.startsWith('chrome-extension://' + extensionId + '/'));
    if (workers.length || !declared) break;
    await new Promise((resolve) => setTimeout(resolve, 100));
  } while (Date.now() < deadline);
  return { declared, status: !declared ? 'not-declared' : workers.length ? 'observed' : 'declared-not-awake', count: workers.length };
}

async function inspectPopup(session, extensionId, extensionPath, manifest) {
  const relative = manifest.action && manifest.action.default_popup;
  if (!relative) return { declared: false, status: 'not-declared', title: '', errors: [] };
  const file = path.resolve(extensionPath, relative);
  const root = extensionPath.endsWith(path.sep) ? extensionPath : extensionPath + path.sep;
  if (!file.startsWith(root) || !fs.existsSync(file)) return { declared: true, status: 'missing-file', title: '', errors: [] };
  let targetId;
  try {
    const created = await session.send('Target.createTarget', { url: 'chrome-extension://' + extensionId + '/' + relative.replace(/\\/g, '/') });
    targetId = created.targetId;
    await new Promise((resolve) => setTimeout(resolve, 250));
    const target = await session.send('Target.getTargetInfo', { targetId });
    const reached = target.targetInfo.url.startsWith('chrome-extension://' + extensionId + '/');
    return { declared: true, status: reached ? 'target-created-unverified' : 'target-blocked', title: safeDiagnostic(target.targetInfo.title), errors: [] };
  } catch (error) {
    return { declared: true, status: 'target-failed', title: '', errors: [safeDiagnostic(error.message)] };
  } finally { if (targetId) await session.send('Target.closeTarget', { targetId }).catch(() => {}); }
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const extensionPath = path.resolve(options.extension);
  const manifest = require(path.join(extensionPath, 'manifest.json'));
  const playwright = require(path.resolve(options.playwright));
  const context = await playwright.chromium.launchPersistentContext('', { channel: 'chromium', headless: options.headless });
  try {
    const session = await context.browser().newBrowserCDPSession();
    let loaded;
    try { loaded = await session.send('Extensions.loadUnpacked', { path: extensionPath, enableInIncognito: false }); }
    catch (error) { throw new Error('Managed Chromium does not expose Extensions.loadUnpacked: ' + error.message); }
    const extensionId = loaded.id || loaded.extensionId;
    if (!extensionId) throw new Error('Chromium loaded the extension without returning an extension id.');
    const popup = await inspectPopup(session, extensionId, extensionPath, manifest);
    const serviceWorker = await observeServiceWorker(session, extensionId, manifest);
    const diagnosticFailure = popup.status === 'missing-file' || popup.status === 'target-blocked' || popup.status === 'target-failed';
    emit({ ok: true, verdict: diagnosticFailure ? 'loaded-with-diagnostic-errors' : 'loaded', name: manifest.name, version: manifest.version, manifestVersion: manifest.manifest_version, extensionId, extensionPath, profile: 'temporary', headless: options.headless, serviceWorker, popup }, options.json);
    if (options.headless) return;
    await new Promise((resolve) => context.once('close', resolve));
  } finally { await context.close().catch(() => {}); }
}

main().catch((error) => {
  process.stderr.write(JSON.stringify({ ok: false, error: error.message }) + '\n');
  process.exitCode = 1;
});
