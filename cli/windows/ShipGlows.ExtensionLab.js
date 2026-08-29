'use strict';

const path = require('path');

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
    process.stdout.write(payload.headless ? 'Headless proof complete.\n' : 'Close the Chromium window to stop the lab.\n');
  }
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
    emit({ ok: true, name: manifest.name, version: manifest.version, manifestVersion: manifest.manifest_version, extensionId, extensionPath, profile: 'temporary', headless: options.headless }, options.json);
    if (options.headless) return;
    await new Promise((resolve) => context.once('close', resolve));
  } finally { await context.close().catch(() => {}); }
}

main().catch((error) => {
  process.stderr.write(JSON.stringify({ ok: false, error: error.message }) + '\n');
  process.exitCode = 1;
});
