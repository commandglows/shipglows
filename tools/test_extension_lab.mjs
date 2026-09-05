import assert from 'node:assert/strict';
import { test } from 'node:test';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { tmpdir } from 'node:os';
import { EventEmitter } from 'node:events';
import { runLab, loadPlaywright, createReport, addDiagnostic, finishReport, readIsolatedJournal, watchCollector, TRANSITIONS, sanitize } from './extension_lab.mjs';

test('unknown errors fail; missing observations never certify personal Chrome', () => {
  const report = createReport();
  report.cleanup = 'stopped';
  assert.equal(finishReport(report).verdict, 'partial');
  addDiagnostic(report, 'worker-exception', 'Previously unknown regression');
  assert.equal(finishReport(report).verdict, 'fail');
  assert.equal(report.coverage.personalJournal, 'not-read');
});

test('event bounds and redaction preserve failure', () => {
  const report = createReport();
  for (let i = 0; i < 520; i++) addDiagnostic(report, 'console', 'token=private https://example.com/private?q=secret C:\\Users\\private\\file');
  assert.equal(report.diagnostics.length, 500);
  assert.equal(report.droppedEvents, 20);
  assert.equal(sanitize('password=abc'), 'password=[redacted]');
  assert.equal(sanitize('"token":"abc"'), '"token":"[redacted]"');
  assert.equal(sanitize('Authorization: Basic abc'), 'Authorization=[redacted]');
  assert.ok(!report.diagnostics[0].message.includes('private'));
  assert.equal(finishReport(report).verdict, 'fail');
});

test('journal absence and inactive collection are gaps, not a clean journal', async () => {
  for (const info of [null, { runtimeErrors: [], manifestErrors: [], errorCollection: { isEnabled: true, isActive: false } }]) {
    const report = createReport();
    await readIsolatedJournal({ evaluate: async () => info }, 'test-extension', report, 'reload');
    assert.equal(report.coverage.isolatedJournal, 'unavailable');
    assert.equal(report.gaps.length, 1);
    assert.equal(finishReport(report).verdict, 'partial');
  }
});

test('scoped pass requires every transition, working collectors and recovery', () => {
  const report = createReport();
  Object.assign(report.coverage, { page: true, isolatedWorld: true, serviceWorker: true, isolatedJournal: 'read' });
  report.cleanup = 'stopped';
  report.scenarios = TRANSITIONS.map(transition => ({ transition, status: 'pass', pending: true, recovered: true }));
  assert.equal(finishReport(report).verdict, 'pass');
  assert.equal(report.coverage.personalJournal, 'not-read');
  report.scenarios[0].pending = false;
  assert.equal(finishReport(report).verdict, 'partial');
  report.scenarios[0].pending = true;
  report.gaps.push('worker collector disconnected');
  assert.equal(finishReport(report).verdict, 'partial');
});

test('unexpected collector detach records a gap, intentional shutdown does not', () => {
  for (const expected of [true, false]) {
    const report = createReport();
    const session = new EventEmitter();
    watchCollector(session, report, 'page', () => expected);
    session.emit('close');
    assert.equal(report.gaps.length, expected ? 0 : 1);
  }
});

async function fixture(mode) {
  const directory = await mkdtemp(join(tmpdir(), 'sg-extension-fixture-'));
  await writeFile(join(directory, 'manifest.json'), JSON.stringify({
    manifest_version: 3, name: 'ShipGlows lifecycle regression fixture', version: '1.0.0',
    background: { service_worker: 'background.js' },
    content_scripts: [{ matches: ['https://example.com/*'], js: ['content.js'], run_at: 'document_start' }],
  }));
  await writeFile(join(directory, 'background.js'), `
chrome.runtime.onMessage.addListener((message, sender, respond) => {
  if (message.type === 'sync') {
    chrome.tabs.sendMessage(sender.tab.id, { type: 'ack', requestId: message.requestId }).catch(() => {});
    ${mode === 'worker-error' ? "setTimeout(() => { throw new Error('SG_WORKER_UNCAUGHT'); }, 10);" : ''}
    setTimeout(() => respond({ ok: true }), 2000);
    return true;
  }
});`);
  await writeFile(join(directory, 'content.js'), `
let pending = 0;
let acknowledged = false;
const requestId = String(Math.random());
const guarded = ${mode !== 'broken'};
let timer;
chrome.runtime.onMessage.addListener(message => {
  if (message.type === 'ack' && message.requestId === requestId && pending > 0) {
    acknowledged = true;
    document.documentElement?.setAttribute('data-sg-pending', String(pending));
  }
});
function sync() {
  if (guarded && !chrome.runtime?.id) { clearInterval(timer); return; }
  pending++;
  ${mode === 'content-error' ? "setTimeout(() => { throw new Error('SG_CONTENT_UNCAUGHT'); }, 10);" : ''}
  const operation = chrome.runtime.sendMessage({ type: 'sync', requestId });
  const settle = () => { pending--; if (acknowledged) document.documentElement?.setAttribute('data-sg-pending', String(pending)); };
  if (guarded) operation.catch(() => {}).finally(settle);
  else operation.then(settle);
}
timer = setInterval(sync, 80);
if (guarded) addEventListener('pagehide', () => clearInterval(timer), { once: true });
`);
  return directory;
}

async function prepare({ page }) {
  await page.waitForFunction(() => Number(document.documentElement.dataset.sgPending) > 0);
  return { pending: true, evidence: 'Background acknowledged receipt; sync response remains pending' };
}

// Opt in explicitly: no downloads and no personal browser/profile connection.
test('real Chromium detects invalidation and positive controls; guarded fixture passes',
  { skip: !process.env.SHIPGLOWS_LAB_PLAYWRIGHT, timeout: 180000 }, async () => {
    const playwright = loadPlaywright(process.env.SHIPGLOWS_LAB_PLAYWRIGHT);
    for (const mode of ['guarded', 'broken', 'worker-error', 'content-error', 'no-proof']) {
      const directory = await fixture(mode);
      try {
        const report = await runLab({ extensionPath: directory, playwright, prepare: mode === 'no-proof' ? undefined : prepare });
        console.log(JSON.stringify({ mode, verdict: report.verdict, coverage: report.coverage,
          scenarios: report.scenarios, gaps: report.gaps,
          diagnostics: report.diagnostics.slice(0, 2), journalDiagnostics: report.diagnostics.filter(d => d.source === 'isolated-journal').length, cleanup: report.cleanup }));
        assert.equal(report.cleanup, 'stopped');
        assert.equal(report.coverage.personalJournal, 'not-read');
        assert.deepEqual(report.scenarios.map(s => s.transition), TRANSITIONS);
        if (mode === 'no-proof') {
          assert.equal(report.verdict, 'partial');
          assert.ok(report.gaps.some(gap => gap.includes('in-flight')));
          continue;
        }
        assert.ok(report.scenarios.every(s => s.pending));
        assert.ok(report.scenarios.find(s => s.transition === 'extension-reload').recovered);
        if (mode === 'guarded') assert.equal(report.verdict, 'pass');
        else {
          assert.equal(report.verdict, 'fail');
          const marker = mode === 'broken' ? /context invalidated|message channel closed|message port closed/i
            : mode === 'worker-error' ? /SG_WORKER_UNCAUGHT/ : /SG_CONTENT_UNCAUGHT/;
          assert.ok(report.diagnostics.some(d => marker.test(d.message)), `Missing ${mode} real diagnostic`);
          if (mode === 'worker-error') assert.ok(report.diagnostics.some(d => d.source === 'worker-exception' && marker.test(d.message)));
          if (mode === 'content-error') assert.ok(report.diagnostics.some(d => d.source === 'isolated-world-exception' && marker.test(d.message)));
          if (mode !== 'broken') assert.ok(report.diagnostics.some(d => d.source === 'isolated-journal' && marker.test(d.message)), `Missing journal positive control: ${mode}`);
        }
      } finally {
        assert.equal(dirname(directory), tmpdir());
        assert.ok(directory.startsWith(join(tmpdir(), 'sg-extension-fixture-')));
        await rm(directory, { recursive: true, force: true });
      }
    }
  });
