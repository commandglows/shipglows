'use strict';

const fs = require('fs');
const path = require('path');
const { spawn, spawnSync } = require('child_process');

function parseArgs(argv) {
  const options = { headless: false, json: false, timeoutMs: 30000 };
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (token === '--headless') options.headless = true;
    else if (token === '--json') options.json = true;
    else if (token === '--obsidian') options.obsidian = argv[++index];
    else if (token === '--playwright') options.playwright = argv[++index];
    else if (token === '--profile') options.profile = argv[++index];
    else if (token === '--vault') options.vault = argv[++index];
    else if (token === '--plugin-id') options.pluginId = argv[++index];
    else if (token === '--port') options.port = Number(argv[++index]);
    else if (token === '--interaction-command') options.interactionCommand = argv[++index];
    else if (token === '--screenshot') options.screenshot = argv[++index];
    else if (token === '--timeout-ms') options.timeoutMs = Number(argv[++index]);
    else throw new Error('Unknown argument: ' + token);
  }
  for (const name of ['obsidian', 'playwright', 'profile', 'vault', 'pluginId', 'port']) {
    if (!options[name]) throw new Error('--' + name.replace(/[A-Z]/g, (value) => '-' + value.toLowerCase()) + ' is required.');
  }
  if (!Number.isInteger(options.port) || options.port < 1024 || options.port > 65535) throw new Error('The CDP port is invalid.');
  if (!Number.isInteger(options.timeoutMs) || options.timeoutMs < 5000 || options.timeoutMs > 120000) throw new Error('The timeout is invalid.');
  return options;
}

function safeDiagnostic(value) {
  return String(value || '')
    .replace(/\b(token|secret|password|api[-_]?key|openai[-_]?key)\s*[:=]\s*\S+/gi, '$1=[redacted]')
    .slice(0, 500);
}

async function waitForEndpoint(playwright, endpoint, deadline) {
  let lastError;
  while (Date.now() < deadline) {
    try { return await playwright.chromium.connectOverCDP(endpoint); }
    catch (error) { lastError = error; await new Promise((resolve) => setTimeout(resolve, 150)); }
  }
  throw new Error('Obsidian CDP endpoint did not become available: ' + safeDiagnostic(lastError && lastError.message));
}

async function clickTrustModal(page) {
  const modal = page.locator('.modal-container:visible').last();
  if (!(await modal.count())) return false;
  const text = safeDiagnostic(await modal.innerText().catch(() => ''));
  if (!/(trust|author|plugin|confiance|auteur|restricted|restreint|community|communaut)/i.test(text)) return false;
  const buttons = modal.locator('button');
  const count = await buttons.count();
  if (!count) throw new Error('The Obsidian trust modal has no actionable button.');
  await buttons.nth(count - 1).click();
  return true;
}

async function inspectPlugin(page, options, diagnostics) {
  try {
    await page.waitForFunction((vault) => {
      const current = window.app && window.app.vault && window.app.vault.adapter && window.app.vault.adapter.basePath;
      return typeof current === 'string' && current.toLowerCase() === vault.toLowerCase();
    }, path.resolve(options.vault), { timeout: options.timeoutMs });
  } catch { throw new Error('The CDP page did not prove the exact disposable vault.'); }
  const trustDeadline = Date.now() + options.timeoutMs;
  while (Date.now() < trustDeadline) {
    if (await page.evaluate((pluginId) => Boolean(window.app.plugins && window.app.plugins.plugins[pluginId]), options.pluginId)) break;
    await clickTrustModal(page);
    const enabled = await page.evaluate(async (pluginId) => {
      if (!window.app.plugins || !window.app.plugins.manifests[pluginId]) return false;
      try { await window.app.plugins.enablePluginAndSave(pluginId); return true; } catch { return false; }
    }, options.pluginId);
    if (enabled) break;
    await page.waitForTimeout(100);
  }
  try { await page.waitForFunction((pluginId) => window.app.plugins && window.app.plugins.manifests[pluginId], options.pluginId, { timeout: options.timeoutMs }); }
  catch { throw new Error('Obsidian did not discover the copied plugin manifest after the trust step.'); }
  try { await page.waitForFunction((pluginId) => window.app.plugins && window.app.plugins.plugins[pluginId], options.pluginId, { timeout: options.timeoutMs }); }
  catch { throw new Error('Obsidian discovered the plugin but did not load its instance.'); }
  const observed = await page.evaluate((pluginId) => {
    const app = window.app;
    const manifest = app.plugins.manifests[pluginId];
    const commands = Object.keys(app.commands.commands).filter((id) => id.startsWith(pluginId + ':')).sort();
    return { vaultName: app.vault.getName(), vaultPath: app.vault.adapter.basePath, pluginLoaded: Boolean(app.plugins.plugins[pluginId]), pluginId, name: manifest.name, version: manifest.version, commands };
  }, options.pluginId);
  let interaction = { state: 'not-requested', command: '' };
  if (options.interactionCommand) {
    interaction = await page.evaluate(async (command) => {
      const found = window.app.commands.findCommand(command);
      if (!found) return { state: 'failed', command, error: 'Command is not registered.' };
      try { await window.app.commands.executeCommandById(command); return { state: 'passed', command }; }
      catch (error) { return { state: 'failed', command, error: String(error && error.message || error).slice(0, 500) }; }
    }, options.interactionCommand);
    await page.waitForTimeout(500);
  }
  let screenshot = '';
  if (options.screenshot) { await page.screenshot({ path: options.screenshot, fullPage: false }); screenshot = options.screenshot; }
  return { observed, interaction, screenshot, diagnostics: diagnostics.slice(0, 20) };
}

function stopOwnedProcess(pid) {
  if (!pid) return;
  spawnSync('taskkill.exe', ['/PID', String(pid), '/T', '/F'], { windowsHide: true, stdio: 'ignore' });
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const playwright = require(path.resolve(options.playwright));
  const endpoint = 'http://127.0.0.1:' + options.port;
  const child = spawn(path.resolve(options.obsidian), [
    '--user-data-dir=' + path.resolve(options.profile),
    '--remote-debugging-address=127.0.0.1',
    '--remote-debugging-port=' + options.port,
  ], { windowsHide: options.headless, stdio: 'ignore' });
  let browser;
  try {
    browser = await waitForEndpoint(playwright, endpoint, Date.now() + options.timeoutMs);
    const contexts = browser.contexts();
    if (contexts.length !== 1) throw new Error('The isolated Obsidian instance exposed an unexpected number of browser contexts.');
    const context = contexts[0];
    const diagnostics = [];
    context.on('page', (page) => {
      page.on('pageerror', (error) => diagnostics.push({ type: 'pageerror', message: safeDiagnostic(error.message) }));
      page.on('console', (message) => { if (['error', 'warning'].includes(message.type())) diagnostics.push({ type: message.type(), message: safeDiagnostic(message.text()) }); });
    });
    let page;
    const deadline = Date.now() + options.timeoutMs;
    while (Date.now() < deadline && !page) {
      page = context.pages().find((candidate) => candidate.url().startsWith('app://obsidian.md'));
      if (!page) await new Promise((resolve) => setTimeout(resolve, 100));
    }
    if (!page) throw new Error('The isolated Obsidian page was not observed.');
    page.on('pageerror', (error) => diagnostics.push({ type: 'pageerror', message: safeDiagnostic(error.message) }));
    page.on('console', (message) => { if (['error', 'warning'].includes(message.type())) diagnostics.push({ type: message.type(), message: safeDiagnostic(message.text()) }); });
    const result = await inspectPlugin(page, options, diagnostics);
    const diagnosticsState = result.diagnostics.length ? 'failed' : 'passed';
    const payload = { ok: true, artifact: 'passed', hostLoad: 'passed', interaction: result.interaction, diagnostics: { state: diagnosticsState, entries: result.diagnostics }, ...result.observed, screenshot: result.screenshot };
    process.stdout.write(JSON.stringify(payload) + '\n');
    if (!options.headless) await new Promise((resolve) => child.once('exit', resolve));
  } finally {
    if (browser) await browser.close().catch(() => {});
    stopOwnedProcess(child.pid);
  }
}

main().catch((error) => {
  process.stderr.write(JSON.stringify({ ok: false, error: safeDiagnostic(error.message) }) + '\n');
  process.exitCode = 1;
});
