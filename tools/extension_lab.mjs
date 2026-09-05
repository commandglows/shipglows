#!/usr/bin/env node
// Isolated MV3 lifecycle proof. Never connects to or opens a personal profile.
import { createRequire } from 'node:module';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { createHash } from 'node:crypto';
import { mkdtemp, mkdir, readFile, writeFile, rm, realpath } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve, dirname } from 'node:path';
import { pathToFileURL } from 'node:url';

export const TRANSITIONS = ['reload', 'navigate', 'close', 'extension-reload'];
const delay = ms => new Promise(resolveDelay => setTimeout(resolveDelay, ms));
const execFileAsync = promisify(execFile);

export function sanitize(value) {
  return String(value ?? '').replace(/https?:\/\/[^\s"'<>]+/g, '[web-url]')
    .replace(/\b[A-Za-z]:[\\/](?![\\/])[^\s"'<>]+/g, '[local-path]')
    .replace(/\b(Bearer\s+)[\w.\-]+/gi, '$1[redacted]')
    .replace(/\b(Authorization\s*:\s*)(?:Basic|Bearer)\s+[^\s,;]+/gi, '$1[redacted]')
    .replace(/(["'](?:token|password|secret|authorization|cookie)["']\s*:\s*)["'][^"']*["']/gi, '$1"[redacted]"')
    .replace(/\b(token|password|secret|authorization|cookie)\s*[=:]\s*[^\s,;]+/gi, '$1=[redacted]')
    .slice(0, 1500);
}

export function createReport() {
  const report = {
    schemaVersion: 'shipglows.extension-lab.v1', profile: 'isolated-temporary',
    startedAt: new Date().toISOString(), verdict: 'partial',
    coverage: { page: false, isolatedWorld: false, serviceWorker: false,
      isolatedJournal: 'not-read', personalJournal: 'not-read' },
    scenarios: [], diagnostics: [], gaps: [], droppedEvents: 0,
    cleanup: 'pending',
  };
  return report;
}

export function addDiagnostic(report, source, message, details = {}) {
  if (report.diagnostics.length >= 500) { report.droppedEvents++; return; }
  report.diagnostics.push({ at: new Date().toISOString(), source,
    message: sanitize(message), ...details });
}

export function watchCollector(session, report, label, expectedClose) {
  session.on('close', () => {
    if (!expectedClose()) report.gaps.push(`${label}: collector disconnected`);
  });
}

export function finishReport(report) {
  if (report.droppedEvents && !report.gaps.includes('event-limit')) report.gaps.push('event-limit');
  for (const scenario of report.scenarios) {
    if (report.diagnostics.some(d => d.transition === scenario.transition && d.severity !== 'warning')) scenario.status = 'fail';
  }
  const failed = report.diagnostics.some(d => d.severity !== 'warning') || report.scenarios.some(s => s.status === 'fail');
  const incomplete = report.gaps.length || report.cleanup !== 'stopped'
    || TRANSITIONS.some(t => !report.scenarios.some(s => s.transition === t && s.status === 'pass' && s.pending === true))
    || !report.coverage.page || !report.coverage.isolatedWorld || !report.coverage.serviceWorker
    || report.coverage.isolatedJournal !== 'read'
    || !report.scenarios.find(s => s.transition === 'extension-reload')?.recovered;
  report.verdict = failed ? 'fail' : incomplete ? 'partial' : 'pass';
  report.finishedAt = new Date().toISOString();
  return report;
}

export function loadPlaywright(modulePath) {
  const require = createRequire(import.meta.url);
  return require(modulePath || 'playwright');
}

async function bounded(operation, ms, label) {
  let timer;
  try {
    return await Promise.race([operation, new Promise((_, reject) => {
      timer = setTimeout(() => reject(new Error(`${label} timed out`)), ms);
    })]);
  } finally { clearTimeout(timer); }
}

// Chrome's internal journal is opportunistic and version-dependent. A failed
// read is evidence missing, never an empty journal. This page is in our lab only.
export async function readIsolatedJournal(manager, extensionId, report, transition) {
  try {
    const info = await bounded(manager.evaluate(id => new Promise((resolveInfo, reject) => {
      if (!globalThis.chrome?.developerPrivate?.getExtensionInfo) return reject(new Error('journal API unavailable'));
      chrome.developerPrivate.getExtensionInfo(id, result => {
        if (chrome.runtime.lastError) reject(new Error(chrome.runtime.lastError.message));
        else resolveInfo(result);
      });
    }), extensionId), 5000, 'journal read');
    if (!info || !Array.isArray(info.runtimeErrors) || !Array.isArray(info.manifestErrors)) throw new Error('journal shape unavailable');
    if (!info.errorCollection?.isEnabled || !info.errorCollection?.isActive) throw new Error('journal collection inactive');
    report.coverage.isolatedJournal = 'read';
    for (const error of [...info.runtimeErrors, ...info.manifestErrors]) {
      const key = sanitize(`${report.journalEpoch || 0}:${error.id}:${error.message}`);
      const occurrences = error.occurrences ?? 1;
      if (report.diagnostics.some(d => d.journalKey === key && d.occurrences >= occurrences)) continue;
      addDiagnostic(report, 'isolated-journal', error.message, {
        transition, severity: error.severity === 'WARN' ? 'warning' : 'error',
        journalKey: key, line: error.stackTrace?.[0]?.lineNumber ?? null,
        occurrences, serviceWorker: error.isServiceWorker === true,
      });
    }
  } catch (error) {
    report.coverage.isolatedJournal = 'unavailable';
    const gap = `journal: ${sanitize(error.message)}`;
    if (!report.gaps.includes(gap)) report.gaps.push(gap);
  }
}

export async function runLab({ extensionPath, playwright, prepare, headless = true,
  settleMs = 400, timeoutMs = 10000 } = {}) {
  if (!extensionPath) throw new Error('An explicit unpacked extension path is required');
  const extension = await realpath(resolve(extensionPath));
  const manifestText = await readFile(join(extension, 'manifest.json'), 'utf8');
  const manifest = JSON.parse(manifestText);
  if (manifest.manifest_version !== 3 || !manifest.background?.service_worker) {
    throw new Error('This lab requires an MV3 extension with a service worker');
  }
  if (extension.includes(',')) throw new Error('Extension path cannot contain a comma');
  if (!Number.isInteger(timeoutMs) || timeoutMs < 100 || timeoutMs > 30000) throw new Error('timeoutMs must be 100..30000');
  if (!Number.isInteger(settleMs) || settleMs < 0 || settleMs > 5000) throw new Error('settleMs must be 0..5000');
  const report = createReport();
  report.artifact = { version: sanitize(manifest.version), manifestSha256: createHash('sha256').update(manifestText).digest('hex') };
  const profile = await mkdtemp(join(tmpdir(), 'sg-extension-lab-'));
  let context;
  let browserPid;
  let shuttingDown = false;
  const expectedPageCloses = new WeakSet();
  let currentTransition = 'startup';
  const pendingAttachments = new Set();
  const collect = (operation, label) => bounded(operation, timeoutMs, label);
  try {
    await mkdir(join(profile, 'Default'));
    await writeFile(join(profile, 'Default', 'Preferences'), JSON.stringify({ extensions: { ui: { developer_mode: true } } }));
    context = await playwright.chromium.launchPersistentContext(profile, {
      channel: 'chromium', headless, timeout: timeoutMs,
      args: [`--disable-extensions-except=${extension}`, `--load-extension=${extension}`],
    });
    context.setDefaultTimeout(timeoutMs);
    context.setDefaultNavigationTimeout(timeoutMs);
    context.on('console', message => {
      if (!['error', 'warning'].includes(message.type())) return;
      addDiagnostic(report, message.worker?.() ? 'worker-console' : 'page-console', message.text(),
        { transition: currentTransition, severity: message.type(), line: message.location().lineNumber });
    });
    context.on('weberror', webError => addDiagnostic(report, 'weberror', webError.error().message,
      { transition: currentTransition, severity: 'error' }));
    report.coverage.page = true;

    // Capture Runtime events in all execution worlds, including extension
    // content scripts that Playwright pageerror does not necessarily forward.
    const attached = new WeakMap();
    function attachPage(page) {
      if (attached.has(page)) return attached.get(page);
      const task = (async () => {
        const session = await collect(context.newCDPSession(page), 'page attachment');
        watchCollector(session, report, 'page', () => shuttingDown || expectedPageCloses.has(page) || page.isClosed());
        const worlds = new Map();
        session.on('Runtime.executionContextCreated', ({ context: world }) => {
          worlds.set(world.id, { world: world.auxData?.isDefault ? 'page' : 'isolated',
            origin: world.origin?.startsWith('chrome-extension://') ? world.origin : '[page-origin]' });
        });
        session.on('Runtime.exceptionThrown', ({ exceptionDetails: e }) => addDiagnostic(report,
          'isolated-world-exception', e.exception?.description || e.text,
          { transition: currentTransition, severity: 'error', executionContextId: e.executionContextId, line: e.lineNumber,
            ...(worlds.get(e.executionContextId) || { world: 'unknown' }) }));
        session.on('Runtime.executionContextDestroyed', () => {
          const scenario = report.scenarios.find(s => s.transition === currentTransition);
          if (scenario) scenario.destroyedContexts = (scenario.destroyedContexts || 0) + 1;
        });
        session.on('Runtime.executionContextsCleared', () => {
          const scenario = report.scenarios.find(s => s.transition === currentTransition);
          if (scenario) scenario.destroyedContexts += worlds.size;
          worlds.clear();
        });
        await collect(session.send('Runtime.enable'), 'page Runtime.enable');
        report.coverage.isolatedWorld = true;
      })().catch(error => report.gaps.push(`page collector: ${sanitize(error.message)}`));
      attached.set(page, task);
      pendingAttachments.add(task);
      task.finally(() => pendingAttachments.delete(task));
      return task;
    }
    context.on('page', page => { void attachPage(page); });
    for (const page of context.pages()) await attachPage(page);

    // Observe worker Runtime exceptions using a browser CDP session. Nested
    // sessions are owned by this lab and are detached by browser shutdown.
    const browserSession = await collect(context.browser().newBrowserCDPSession(), 'browser attachment');
    watchCollector(browserSession, report, 'browser', () => shuttingDown);
    const processes = await collect(browserSession.send('SystemInfo.getProcessInfo'), 'browser process identity');
    browserPid = processes.processInfo.find(p => p.type === 'browser')?.id;
    if (!Number.isInteger(browserPid) || browserPid <= 0 || browserPid === process.pid) throw new Error('Owned browser process identity unavailable');
    report.browserPid = browserPid;
    const workerSessions = new Set();
    const workerTargets = new Map();
    const workerAttached = new Set();
    let commandId = 0;
    const workerCommands = new Map();
    browserSession.on('Target.detachedFromTarget', ({ sessionId }) => {
      const targetId = workerTargets.get(sessionId);
      workerSessions.delete(sessionId);
      workerTargets.delete(sessionId);
      if (!targetId || shuttingDown) return;
      const check = (async () => {
        await delay(50);
        if (shuttingDown) return;
        const { targetInfos } = await collect(browserSession.send('Target.getTargets'), 'detached worker check');
        if (targetInfos.some(info => info.targetId === targetId)) report.gaps.push('worker: collector disconnected from live target');
      })().catch(error => { if (!shuttingDown) report.gaps.push(`worker detach check: ${sanitize(error.message)}`); });
      pendingAttachments.add(check);
      check.finally(() => pendingAttachments.delete(check));
    });
    browserSession.on('Target.receivedMessageFromTarget', ({ sessionId, message }) => {
      if (!workerSessions.has(sessionId)) return;
      const event = JSON.parse(message);
      if (event.id) {
        const done = workerCommands.get(event.id);
        if (done) { workerCommands.delete(event.id); event.error ? done.reject(new Error(event.error.message)) : done.resolve(); }
      }
      if (event.method === 'Runtime.exceptionThrown') {
        const e = event.params.exceptionDetails;
        addDiagnostic(report, 'worker-exception', e.exception?.description || e.text,
          { transition: currentTransition, severity: 'error', line: e.lineNumber });
      }
    });
    async function attachWorker(info) {
      if (info.type !== 'service_worker' || !info.url.startsWith('chrome-extension://') || workerAttached.has(info.targetId)) return;
      workerAttached.add(info.targetId);
      try {
        const { sessionId } = await collect(browserSession.send('Target.attachToTarget', { targetId: info.targetId, flatten: false }), 'worker attachment');
        workerSessions.add(sessionId);
        workerTargets.set(sessionId, info.targetId);
        const id = ++commandId;
        const ready = new Promise((resolveCommand, reject) => workerCommands.set(id, { resolve: resolveCommand, reject }));
        await collect(browserSession.send('Target.sendMessageToTarget', { sessionId, message: JSON.stringify({ id, method: 'Runtime.enable' }) }), 'worker Runtime.enable');
        await bounded(ready, timeoutMs, 'worker collector');
        report.coverage.serviceWorker = true;
      } catch (error) { report.gaps.push(`worker collector: ${sanitize(error.message)}`); }
    }
    browserSession.on('Target.targetCreated', ({ targetInfo }) => {
      const task = attachWorker(targetInfo);
      pendingAttachments.add(task);
      task.finally(() => pendingAttachments.delete(task));
    });
    await collect(browserSession.send('Target.setDiscoverTargets', { discover: true }), 'discover workers');
    for (const info of (await collect(browserSession.send('Target.getTargets'), 'list workers')).targetInfos) await attachWorker(info);
    let worker = context.serviceWorkers().find(w => w.url().startsWith('chrome-extension://'));
    if (!worker) worker = await context.waitForEvent('serviceworker', { timeout: timeoutMs });
    const extensionId = new URL(worker.url()).hostname;
    report.artifact.extensionId = extensionId;
    await collect(Promise.all([...pendingAttachments]), 'collectors ready');
    const manager = await context.newPage();
    await attachPage(manager);
    await manager.goto('chrome://extensions/');
    // The diagnostic journal can be disabled by default even in developer
    // mode. Configuration changes are confined to this disposable profile.
    await collect(manager.evaluate(() => new Promise((resolveConfig, reject) => {
      chrome.developerPrivate.updateProfileConfiguration({ inDeveloperMode: true }, () => {
        if (chrome.runtime.lastError) reject(new Error(chrome.runtime.lastError.message));
        else resolveConfig();
      });
    })), 'isolated developer mode');
    await collect(manager.evaluate(id => new Promise((resolveConfig, reject) => {
      chrome.developerPrivate.updateExtensionConfiguration({ extensionId: id, errorCollection: true }, () => {
        if (chrome.runtime.lastError) reject(new Error(chrome.runtime.lastError.message));
        else resolveConfig();
      });
    }), extensionId), 'isolated journal collection');
    await readIsolatedJournal(manager, extensionId, report, currentTransition);

    for (const transition of TRANSITIONS) {
      currentTransition = transition;
      const scenario = { transition, status: 'partial', pending: false, destroyedContexts: 0 };
      report.scenarios.push(scenario);
      const page = await context.newPage();
      await attachPage(page);
      // All page traffic is fulfilled locally; no live website is navigated.
      await page.route('**/*', route => route.fulfill({ contentType: 'text/html',
        body: '<!doctype html><html><head><title>ShipGlows lifecycle fixture</title></head><body>Lifecycle fixture</body></html>' }));
      try {
        await page.goto('https://example.com/shipglows-lifecycle');
        if (prepare) {
          const proof = await bounded(Promise.resolve(prepare({ page, context, extensionId, transition })), timeoutMs, 'scenario readiness');
          scenario.pending = proof?.pending === true;
          scenario.evidence = sanitize(proof?.evidence);
        }
        if (!scenario.pending) report.gaps.push(`${transition}: in-flight synchronization not proven`);
        if (transition === 'reload') await page.reload();
        else if (transition === 'navigate') await page.goto('https://example.com/shipglows-next');
        else if (transition === 'close') { expectedPageCloses.add(page); await collect(page.close(), 'close scenario tab'); }
        else {
          // Reload only this extension in the temporary lab, retaining the tab
          // so stale content scripts can attempt another background operation.
          report.journalEpoch = (report.journalEpoch || 0) + 1;
          await bounded(manager.evaluate(id => new Promise((resolveReload, reject) => {
            chrome.developerPrivate.reload(id, { failQuietly: true, populateErrorForUnpacked: true }, result => {
              if (chrome.runtime.lastError) reject(new Error(chrome.runtime.lastError.message));
              else if (result?.error) reject(new Error(result.error));
              else resolveReload();
            });
          }), extensionId), timeoutMs, 'extension reload');
          await manager.waitForFunction(id => new Promise(resolveInfo => {
            chrome.developerPrivate.getExtensionInfo(id, info => resolveInfo(info?.state === 'ENABLED'));
          }), extensionId);
        }
        await delay(settleMs);
        await collect(Promise.all([...pendingAttachments]), 'collectors ready');
        await readIsolatedJournal(manager, extensionId, report, transition);
        scenario.status = report.diagnostics.some(d => d.transition === transition && d.severity !== 'warning')
          ? 'fail' : scenario.pending ? 'pass' : 'partial';
        if (transition === 'extension-reload' && prepare) {
          await page.reload();
          const proof = await bounded(Promise.resolve(prepare({ page, context, extensionId, transition: 'recovery' })), timeoutMs, 'recovery readiness');
          scenario.recovered = proof?.pending === true;
          if (!scenario.recovered) report.gaps.push('extension-reload: synchronization recovery not proven');
        }
      } catch (error) {
        scenario.status = 'fail';
        addDiagnostic(report, 'scenario', error.message, { transition, severity: 'error' });
      } finally {
        expectedPageCloses.add(page);
        if (!page.isClosed()) await collect(page.close(), 'close scenario tab');
      }
    }
    await delay(settleMs);
    await readIsolatedJournal(manager, extensionId, report, 'final');
  } catch (error) {
    report.gaps.push(`lab: ${sanitize(error.message)}`);
  } finally {
    shuttingDown = true;
    try {
      try {
        await bounded(Promise.resolve(context?.close()), 10000, 'browser shutdown');
      } catch (error) {
        if (!browserPid) throw error;
        report.gaps.push(`forced shutdown: ${sanitize(error.message)}`);
        // Exact PID came from this browser's CDP, never a process-name kill.
        if (process.platform === 'win32') await execFileAsync('taskkill.exe', ['/PID', String(browserPid), '/T', '/F'], { timeout: 10000, windowsHide: true });
        else process.kill(browserPid, 'SIGKILL');
      }
      if (browserPid) {
        let alive = true;
        for (let attempt = 0; attempt < 20; attempt++) {
          try { process.kill(browserPid, 0); } catch (error) { if (error.code === 'ESRCH') { alive = false; break; } throw error; }
          await delay(100);
        }
        if (alive) throw new Error('Owned browser process remains alive');
      }
      report.cleanup = 'stopped';
      // mkdtemp owns this exact directory; never accept a user-supplied profile.
      if (dirname(profile) !== tmpdir() || !profile.startsWith(join(tmpdir(), 'sg-extension-lab-'))) throw new Error('Unexpected cleanup path');
      await rm(profile, { recursive: true, force: true });
    } catch (error) {
      report.cleanup = 'failed';
      report.gaps.push(`cleanup: ${sanitize(error.message)}`);
    }
  }
  return finishReport(report);
}

export async function main(args) {
  const options = {};
  for (let index = 0; index < args.length; index++) {
    const key = args[index];
    if (key === '--help') {
      console.log('node tools/extension_lab.mjs --extension <unpacked-dir> [--scenario <module.mjs>] [--playwright <package-dir>] [--headed] [--output <new-json-file>]');
      return 0;
    }
    if (key === '--headed') { options.headless = false; continue; }
    if (!['--extension', '--scenario', '--playwright', '--output'].includes(key) || !args[index + 1] || args[index + 1].startsWith('--')) throw new Error(`Invalid argument: ${key}`);
    if (options[key]) throw new Error(`Duplicate argument: ${key}`);
    options[key] = args[++index];
  }
  const scenario = options['--scenario'] ? await import(pathToFileURL(resolve(options['--scenario'])).href) : null;
  if (scenario && typeof scenario.prepare !== 'function') throw new Error('Scenario module must export prepare');
  const report = await runLab({ extensionPath: options['--extension'],
    playwright: loadPlaywright(options['--playwright']), prepare: scenario?.prepare, headless: options.headless });
  const output = JSON.stringify(report, null, 2);
  if (options['--output']) await writeFile(resolve(options['--output']), output + '\n', { flag: 'wx' });
  console.log(output);
  return report.verdict === 'pass' ? 0 : report.verdict === 'fail' ? 1 : 2;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main(process.argv.slice(2)).then(code => { process.exitCode = code; }).catch(error => {
    console.error(JSON.stringify({ verdict: 'blocked', error: sanitize(error.message) }));
    process.exitCode = 2;
  });
}
