'use strict';

const path = require('path');
const fs = require('fs');
const os = require('os');
const net = require('net');
const VIEWPORT = { width: 1280, height: 800 };
const BROWSERS = new Set(['chromium', 'edge', 'vivaldi', 'firefox']);

function parseArgs(argv) {
  const result = { headless: false, json: false, simulateCdpUnavailable: false, browser: 'chromium' };
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token === '--headless') result.headless = true;
    else if (token === '--json') result.json = true;
    else if (token === '--extension') result.extension = argv[++i];
    else if (token === '--playwright') result.playwright = argv[++i];
    else if (token === '--target-url') result.targetUrl = argv[++i];
    else if (token === '--screenshot') result.screenshotPath = argv[++i];
    else if (token === '--browser') result.browser = String(argv[++i] || '').toLowerCase();
    else if (token === '--browser-executable') result.browserExecutable = argv[++i];
    else if (token === '--browser-product') result.browserProduct = argv[++i];
    else if (token === '--browser-version') result.browserVersion = argv[++i];
    else if (token === '--click-selector') result.clickSelector = argv[++i];
    else if (token === '--visual-selector') result.visualSelector = argv[++i];
    else if (token === '--simulate-cdp-unavailable') result.simulateCdpUnavailable = true;
    else throw new Error('Unknown argument: ' + token);
  }
  if (!result.extension || !result.playwright) throw new Error('Both --extension and --playwright are required.');
  if (!BROWSERS.has(result.browser)) throw new Error('Browser must be one of: Chromium, Edge, Vivaldi, Firefox.');
  for (const [label, value] of [['Click selector', result.clickSelector], ['Visual selector', result.visualSelector]]) {
    if (value && (value.length > 500 || /[\0\r\n]/.test(value))) throw new Error(label + ' must be a single line of at most 500 characters.');
  }
  return result;
}

function safeDiagnostic(value) {
  return String(value || '').replace(/\b(token|secret|password|api[-_]?key)\s*[:=]\s*\S+/gi, '$1=[redacted]').slice(0, 500);
}

function safeUrl(value) {
  try { const url = new URL(value); url.username = ''; url.password = ''; url.search = ''; url.hash = ''; return url.href; }
  catch { return '[invalid-url]'; }
}

function emit(payload, json) {
  if (json) return process.stdout.write(JSON.stringify(payload) + '\n');
  process.stdout.write(`Extension loaded: ${payload.name} ${payload.version}\n`);
  process.stdout.write(`Browser: ${payload.browser.product} ${payload.browser.version}\n`);
  process.stdout.write(`Executable: ${payload.browser.executablePath}\nExtension id: ${payload.extensionId}\n`);
  process.stdout.write(`Isolated profile: ${payload.profile}\nBackground: ${payload.serviceWorker.status}\nPopup: ${payload.popup.status}\n`);
  process.stdout.write(`Content scripts: ${payload.contentScripts.status}\nScreenshot: ${payload.visual.screenshotStatus}${payload.visual.screenshotPath ? ` (${payload.visual.screenshotPath})` : ''}\n`);
  process.stdout.write(`Verdict: ${payload.verdict}\n${payload.headless ? 'Headless proof complete.' : 'Close the isolated browser window to stop the lab.'}\n`);
}

async function interact(page, clickSelector, visualSelector) {
  let click = { state: clickSelector ? 'not-run' : 'not-requested', selector: clickSelector || '' };
  if (clickSelector) {
    try {
      const target = page.locator(clickSelector); const count = await target.count();
      if (count !== 1) throw new Error(`selector matched ${count} elements; exactly one is required`);
      await target.click({ timeout: 5000 }); await page.waitForTimeout(150);
      click = { state: 'passed', selector: clickSelector };
    } catch (error) { click = { state: 'failed', selector: clickSelector, error: safeDiagnostic(error.message) }; }
  }
  let dom = { state: visualSelector ? 'not-captured' : 'not-requested', selector: visualSelector || '' };
  if (visualSelector) {
    try {
      const target = page.locator(visualSelector); const count = await target.count();
      if (count !== 1) throw new Error(`selector matched ${count} elements; exactly one is required`);
      dom = await target.evaluate((element, selector) => {
        const bounds = element.getBoundingClientRect(); const style = getComputedStyle(element);
        return { state: 'captured', selector, tagName: element.tagName.toLowerCase(), visible: Boolean(bounds.width && bounds.height && style.visibility !== 'hidden' && style.display !== 'none'), text: String(element.innerText || element.textContent || '').trim().slice(0, 1000), bounds: { x: bounds.x, y: bounds.y, width: bounds.width, height: bounds.height }, computedStyle: { color: style.color, backgroundColor: style.backgroundColor, fontFamily: style.fontFamily, fontSize: style.fontSize, display: style.display, overflow: style.overflow, visibility: style.visibility } };
      }, visualSelector);
    } catch (error) { dom = { state: 'failed', selector: visualSelector, error: safeDiagnostic(error.message) }; }
  }
  return { click, dom };
}

async function screenshot(page, outputPath) {
  if (!outputPath) return null;
  try { await page.screenshot({ path: outputPath, type: 'png' }); return { status: 'captured', path: path.resolve(outputPath) }; }
  catch (error) { return { status: 'failed', path: '', error: safeDiagnostic(error.message) }; }
}

function wireDiagnostics(page, errors, observed, scheme) {
  page.on('pageerror', error => errors.push(safeDiagnostic(error.message)));
  page.on('console', message => { if (message.type() === 'error') errors.push(safeDiagnostic(message.text())); });
  page.on('requestfailed', request => errors.push(safeDiagnostic(`Request failed: ${safeUrl(request.url())} (${request.failure()?.errorText || 'unknown'})`)));
  page.on('request', request => { if (request.url().startsWith(`${scheme}://`)) observed.add(request.url()); });
}

async function inspectTarget(context, cdp, extensionId, manifest, options, scheme) {
  const declarations = Array.isArray(manifest.content_scripts) ? manifest.content_scripts : [];
  if (!options.targetUrl) return { result: { declared: declarations.length > 0, status: declarations.length ? 'not-requested' : 'not-declared', targetUrl: '', observedScripts: [], errors: [] } };
  let target; try { target = new URL(options.targetUrl); } catch { throw new Error('Content-script target must be an absolute http:// or https:// URL.'); }
  if (!['http:', 'https:'].includes(target.protocol)) throw new Error('Content-script target must use http:// or https://.');
  const page = await context.newPage(); const errors = []; const observed = new Set(); let debug = null;
  wireDiagnostics(page, errors, observed, scheme);
  if (cdp) { debug = await context.newCDPSession(page); debug.on('Debugger.scriptParsed', e => { if (e.url.startsWith(`${scheme}://${extensionId}/`)) observed.add(e.url); }); await debug.send('Debugger.enable'); }
  try {
    await page.goto(target.href, { waitUntil: 'domcontentloaded', timeout: 10000 }); await page.waitForTimeout(500);
    const interaction = await interact(page, options.clickSelector, options.visualSelector); const image = await screenshot(page, options.screenshotPath);
    const scripts = [...observed].slice(0, 20);
    const status = !declarations.length ? 'not-declared' : options.browser === 'firefox' ? (errors.length ? 'observation-unavailable-with-errors' : 'observation-unavailable') : scripts.length ? (errors.length ? 'observed-with-errors' : 'observed') : 'not-observed';
    return { result: { declared: declarations.length > 0, status, targetUrl: safeUrl(target.href), observedScripts: scripts, errors: errors.slice(0, 10) }, image, ...interaction };
  } catch (error) { return { result: { declared: declarations.length > 0, status: 'navigation-failed', targetUrl: safeUrl(target.href), observedScripts: [...observed].slice(0, 20), errors: [safeDiagnostic(error.message)] } }; }
  finally { if (debug) await debug.detach().catch(() => {}); await page.close().catch(() => {}); }
}

async function inspectPopup(context, runtimeId, extensionPath, manifest, options, scheme) {
  const action = manifest.action || manifest.browser_action; const relative = action && action.default_popup;
  if (!relative) return { result: { declared: false, status: 'not-declared', title: '', errors: [] } };
  const file = path.resolve(extensionPath, relative); const root = extensionPath.endsWith(path.sep) ? extensionPath : extensionPath + path.sep;
  if (!file.startsWith(root) || !fs.existsSync(file)) return { result: { declared: true, status: 'missing-file', title: '', errors: [] } };
  const page = await context.newPage(); const errors = []; wireDiagnostics(page, errors, new Set(), scheme);
  try {
    const popupUrl = `${scheme}://${runtimeId}/${relative.replace(/\\/g, '/')}`;
    try { await page.goto(popupUrl, { waitUntil: 'domcontentloaded', timeout: 5000 }); }
    catch (error) { if (scheme !== 'moz-extension' || page.url() !== popupUrl) throw error; }
    await page.waitForTimeout(250);
    const interaction = await interact(page, options.clickSelector, options.visualSelector); const image = await screenshot(page, options.screenshotPath);
    return { result: { declared: true, status: errors.length ? 'opened-with-errors' : 'opened', title: safeDiagnostic(await page.title()), errors: errors.slice(0, 10) }, image, ...interaction };
  } catch (error) { return { result: { declared: true, status: 'open-failed', title: '', errors: [safeDiagnostic(error.message)] } }; }
  finally { await page.close().catch(() => {}); }
}

async function observeWorker(context, cdp, extensionId, manifest) {
  const declared = Boolean(manifest.background && manifest.background.service_worker); const deadline = Date.now() + 3000; let workers = [];
  do {
    const targets = cdp ? await cdp.send('Target.getTargets') : { targetInfos: [] };
    workers = context.serviceWorkers().filter(worker => worker.url().startsWith(`chrome-extension://${extensionId}/`));
    if (!workers.length) workers = targets.targetInfos.filter(target => target.type === 'service_worker' && target.url.startsWith(`chrome-extension://${extensionId}/`));
    if (workers.length || !declared) break; await new Promise(resolve => setTimeout(resolve, 100));
  } while (Date.now() < deadline);
  return { declared, status: !declared ? 'not-declared' : workers.length ? 'observed' : 'declared-not-awake', count: workers.length };
}

function freePort() {
  return new Promise((resolve, reject) => { const server = net.createServer(); server.unref(); server.on('error', reject); server.listen(0, '127.0.0.1', () => { const port = server.address().port; server.close(() => resolve(port)); }); });
}

async function connectBidi(port) {
  let socket; const deadline = Date.now() + 5000;
  while (Date.now() < deadline) {
    try { socket = new WebSocket(`ws://127.0.0.1:${port}/session`); await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject; }); break; }
    catch { await new Promise(resolve => setTimeout(resolve, 100)); }
  }
  if (!socket || socket.readyState !== WebSocket.OPEN) throw new Error('Managed Firefox WebDriver BiDi endpoint did not become ready.');
  let id = 0; const pending = new Map();
  socket.onmessage = event => { const message = JSON.parse(event.data); if (!message.id || !pending.has(message.id)) return; const promise = pending.get(message.id); pending.delete(message.id); message.type === 'success' ? promise.resolve(message.result) : promise.reject(new Error(safeDiagnostic(message.message || message.error))); };
  const command = (method, params = {}) => new Promise((resolve, reject) => { const requestId = ++id; pending.set(requestId, { resolve, reject }); socket.send(JSON.stringify({ id: requestId, method, params })); });
  return { socket, command };
}

async function firefoxUuid(profilePath, addonId) {
  const prefsPath = path.join(profilePath, 'prefs.js'); const deadline = Date.now() + 3000;
  do {
    if (fs.existsSync(prefsPath)) {
      const line = fs.readFileSync(prefsPath, 'utf8').split(/\r?\n/).find(entry => entry.includes('extensions.webextensions.uuids'));
      const match = line && line.match(/user_pref\("extensions\.webextensions\.uuids",\s*"(.*)"\);/);
      if (match) { const mapping = JSON.parse(JSON.parse('"' + match[1] + '"')); if (mapping[addonId]) return mapping[addonId]; }
    }
    await new Promise(resolve => setTimeout(resolve, 100));
  } while (Date.now() < deadline);
  throw new Error('Managed Firefox installed the extension but did not expose its isolated runtime UUID.');
}

async function launchChromium(playwright, options, extensionPath, profilePath) {
  const args = [`--disable-extensions-except=${extensionPath}`, `--load-extension=${extensionPath}`];
  if (options.browser === 'vivaldi') args.push('--disable-vivaldi');
  const launch = { headless: options.headless, viewport: VIEWPORT, timeout: 15000, args };
  if (options.browserExecutable) launch.executablePath = path.resolve(options.browserExecutable); else launch.channel = 'chromium';
  const context = await playwright.chromium.launchPersistentContext(profilePath, launch);
  try {
    const cdp = options.simulateCdpUnavailable ? null : await context.browser().newBrowserCDPSession(); let extensionId = ''; const deadline = Date.now() + 5000;
    do { const worker = context.serviceWorkers()[0]; if (worker && worker.url().startsWith('chrome-extension://')) { extensionId = new URL(worker.url()).host; break; } await new Promise(resolve => setTimeout(resolve, 100)); } while (Date.now() < deadline);
    if (!extensionId) {
      if (!cdp) throw new Error('The isolated browser loaded the extension through flags, but its id could not be observed and the CDP fallback is unavailable. Ensure the Manifest V3 service worker starts, then retry.');
      let loaded; try { loaded = await cdp.send('Extensions.loadUnpacked', { path: extensionPath, enableInIncognito: false }); }
      catch (error) { throw new Error(`${options.browserProduct} could not load the extension through flags or Extensions.loadUnpacked: ${error.message}`); }
      extensionId = loaded.id || loaded.extensionId;
    }
    if (!extensionId) throw new Error(`${options.browserProduct} loaded the extension without returning an extension id.`);
    return { context, cdp, extensionId, runtimeId: extensionId, scheme: 'chrome-extension', runtimeVersion: context.browser().version() };
  } catch (error) { await context.close().catch(() => {}); throw error; }
}

async function launchFirefox(playwright, options, extensionPath, profilePath) {
  if (!options.browserExecutable) throw new Error('Managed Firefox executable is unavailable. Rerun the ShipGlows full installer.');
  const port = await freePort();
  const context = await playwright.firefox.launchPersistentContext(profilePath, { executablePath: path.resolve(options.browserExecutable), headless: options.headless, viewport: VIEWPORT, args: [`--remote-debugging-port=${port}`] });
  let bidi;
  try {
    bidi = await connectBidi(port); const session = await bidi.command('session.new', { capabilities: { alwaysMatch: { acceptInsecureCerts: false } } });
    let installed; try { installed = await bidi.command('webExtension.install', { extensionData: { type: 'path', path: extensionPath } }); }
    catch (error) { throw new Error(`Managed Firefox could not temporarily install this artifact: ${error.message}`); }
    const extensionId = installed.extension; const runtimeId = await firefoxUuid(profilePath, extensionId);
    return { context, cdp: null, extensionId, runtimeId, scheme: 'moz-extension', runtimeVersion: session.capabilities.browserVersion, bidi };
  } catch (error) {
    if (bidi) { await bidi.command('session.end', {}).catch(() => {}); bidi.socket.close(); }
    await context.close().catch(() => {}); throw error;
  }
}

async function main() {
  const options = parseArgs(process.argv.slice(2)); const extensionPath = path.resolve(options.extension);
  const manifest = JSON.parse(fs.readFileSync(path.join(extensionPath, 'manifest.json'), 'utf8')); const playwright = require(path.resolve(options.playwright));
  const profilePath = fs.mkdtempSync(path.join(os.tmpdir(), 'shipglows-extension-lab-')); let runtime;
  try {
    runtime = options.browser === 'firefox' ? await launchFirefox(playwright, options, extensionPath, profilePath) : await launchChromium(playwright, options, extensionPath, profilePath);
    const popupOptions = options.targetUrl ? { ...options, screenshotPath: '', clickSelector: '', visualSelector: '' } : options;
    const targetOptions = options.targetUrl ? options : { ...options, screenshotPath: '', clickSelector: '', visualSelector: '' };
    const popup = options.browser === 'firefox' && options.targetUrl
      ? { result: { declared: Boolean((manifest.action || manifest.browser_action)?.default_popup), status: 'not-probed', title: '', errors: [] } }
      : await inspectPopup(runtime.context, runtime.runtimeId, extensionPath, manifest, popupOptions, runtime.scheme);
    const worker = options.browser === 'firefox' ? { declared: Boolean(manifest.background && (manifest.background.scripts || manifest.background.service_worker)), status: 'installed-via-bidi', count: 1 } : await observeWorker(runtime.context, runtime.cdp, runtime.extensionId, manifest);
    const content = await inspectTarget(runtime.context, runtime.cdp, runtime.runtimeId, manifest, targetOptions, runtime.scheme);
    const image = content.image || popup.image; const click = content.click || popup.click || { state: options.clickSelector ? 'not-run' : 'not-requested', selector: options.clickSelector || '' }; const dom = content.dom || popup.dom || { state: options.visualSelector ? 'not-captured' : 'not-requested', selector: options.visualSelector || '' };
    const visual = { screenshotStatus: !options.screenshotPath ? 'not-requested' : image ? image.status : 'not-captured', screenshotPath: image && image.status === 'captured' ? image.path : '', viewport: VIEWPORT, dom };
    if (image && image.error) visual.error = image.error;
    const browser = { requested: options.browser, engine: options.browser === 'firefox' ? 'firefox' : 'chromium', product: options.browserProduct || (options.browser === 'chromium' ? 'Chromium' : options.browser), version: options.browserVersion && options.browserVersion !== 'managed' ? options.browserVersion : runtime.runtimeVersion, runtimeVersion: runtime.runtimeVersion, executablePath: options.browserExecutable ? path.resolve(options.browserExecutable) : playwright.chromium.executablePath(), isolatedProfile: true };
    const failed = ['missing-file', 'open-failed', 'opened-with-errors'].includes(popup.result.status) || ['observed-with-errors', 'observation-unavailable-with-errors', 'not-observed', 'navigation-failed'].includes(content.result.status) || ['failed', 'not-captured'].includes(visual.screenshotStatus) || click.state === 'failed' || dom.state === 'failed';
    emit({ ok: true, verdict: failed ? 'loaded-with-diagnostic-errors' : 'loaded', name: manifest.name, version: manifest.version, manifestVersion: manifest.manifest_version, extensionId: runtime.extensionId, extensionPath, profile: 'temporary', headless: options.headless, browser, serviceWorker: worker, popup: popup.result, contentScripts: content.result, click, visual }, options.json);
    if (!options.headless) await new Promise(resolve => runtime.context.once('close', resolve));
  } finally {
    if (runtime && runtime.bidi) { await runtime.bidi.command('session.end', {}).catch(() => {}); runtime.bidi.socket.close(); }
    if (runtime) await runtime.context.close().catch(() => {});
    fs.rmSync(profilePath, { recursive: true, force: true });
  }
}

main().catch(error => { process.stderr.write(JSON.stringify({ ok: false, error: safeDiagnostic(error.message) }) + '\n'); process.exitCode = 1; });
