---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: extension-lifecycle-lab
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/extension_lab.mjs
  - tools/test_extension_lab.mjs
  - skills/108-sg-browser/references/browser-proof-playbook.md
next_review: "2026-10-05"
depends_on: []
supersedes: []
evidence:
  - "Real Chromium proof covers guarded/broken messaging, worker and isolated-world positive controls, and the isolated Errors journal."
next_step: "Use a product-owned prepare hook for the exact synchronization being diagnosed."
---

# Extension lifecycle diagnostics

`tools/extension_lab.mjs` runs an unpacked MV3 extension with a service worker in
a fresh temporary Playwright Chromium profile. It checks tab reload, navigation,
closure, and extension reload while a host tab survives. The extension reload
waits for loading to complete, then a fresh page must resume synchronization.

This is a source tool, not an installed `s extension-lab` or `s extension-inspect`
command. It does not install dependencies, launch a DevServer, or use Chrome's
personal profile. Node and Playwright with its full bundled Chromium must already
be available. Firefox and MV2 are outside this tool's scope.

## Run an extension

```powershell
node tools/extension_lab.mjs --extension <absolute-unpacked-directory> --scenario <absolute-scenario.mjs> --playwright <absolute-playwright-package-directory>
```

`--playwright` selects the existing package directory containing Playwright's
package.json. Omit it when `playwright` resolves through Node normally. For the
managed Windows runtime, inspect the declared installed version under
`%LOCALAPPDATA%\ShipGlows\node-tools`; do not install a guessed replacement.
`--headed` shows the isolated browser. `--output <new-json-file>` writes a report
without overwriting an existing file; otherwise the report goes to stdout.

The scenario is trusted executable project test code exporting an async `prepare`
function. The hook receives `{ page, context, extensionId, transition }` and runs
before each transition, plus `transition: 'recovery'` after extension reload.
It must drive the product's actual synchronization and wait for evidence that
the background received it while its response is still pending:

```javascript
export async function prepare({ page }) {
  // Product-specific UI action and observable acknowledgment belong here.
  await page.waitForFunction(() =>
    document.documentElement.dataset.syncAcknowledged === 'true' &&
    document.documentElement.dataset.syncPending === 'true');
  return { pending: true, evidence: 'Background acknowledged; response pending' };
}
```

The attributes above are an example, not automatically inserted by ShipGlows.
Adapt the hook to real product evidence; never return `pending: true` just because
a timeout elapsed. The harness fulfills page requests with local HTML at
`https://example.com/shipglows-lifecycle`, so the extension must match that origin.
A trusted prepare hook may replace the fixture route for its product. Extension
background code still executes normally; use test artifacts and no production
credentials. This is not a network sandbox or a universal product test.

Omitting the hook exercises generic transitions but returns `partial`; generic
navigation alone cannot prove the synchronization race. Import `runLab` when
composing with an existing test suite. Hook timeouts close the browser but cannot
cancel arbitrary JavaScript or external operations started by trusted hook code.

## Evidence and verdicts

- `page`: context console and unhandled page errors.
- `isolatedWorld`: CDP Runtime exceptions with execution-world metadata.
- `serviceWorker`: worker console plus a separate worker Runtime attachment.
- `isolatedJournal`: actual Chromium developerPrivate journal, with both
  `errorCollection.isEnabled` and `isActive` verified.
- `personalJournal`: always `not-read` in this tool. UI evidence stays separate.

The temporary profile alone enables developer mode and extension error collection.
Command-line-loaded extensions otherwise can expose an inactive empty journal.
The private journal API and nested Target CDP protocol are version-dependent:
failed attachment/readiness/read shape becomes a gap rather than clean evidence.
Snapshots occur before and after transitions and are retained across reload.
Worker inspection perturbs natural suspension; this run does not prove the
uninspected worker idle/suspension lifecycle or every startup event before attachment.

Exit codes: `0` means all scoped scenarios and recovery passed with the required
collectors; `1` means an error was observed; `2` means partial or blocked evidence.
Warnings are recorded but are not automatically failures. Unknown error families
fail without a message allowlist. Multiple channels can report the same exception;
the diagnostic count is not a count of unique application bugs.

Reports cap diagnostic events at 500 and message excerpts at 1500 characters.
Overflow is recorded. URL, local-path and common credential redaction is best
effort; treat output as private diagnostic data and review before sharing. Never
commit personal journals. The browser PID is recorded and checked after shutdown;
failed shutdown/cleanup remains visible and prevents a scoped pass.

## Personal Chrome journal

An explicit targeted request authorizes opening and reading the specified
extension's Errors page through a currently callable browser UI. Resolve the
profile and extension from observed UI or user-provided identity. Do not read
other extensions, clear logs, change settings, reload/install extensions, enable
remote debugging or copy browser profile files under that read-only authority.
If Chrome/the profile is unavailable, report it as not read; do not substitute the
lab journal. Capture only the relevant error family, source/line and lifecycle
context; keep private page content out of reports and repository artifacts.

## Regression proof

```powershell
node --test tools/test_extension_lab.mjs
$env:SHIPGLOWS_LAB_PLAYWRIGHT = '<absolute-playwright-package-directory>'
node --test tools/test_extension_lab.mjs
```

The first invocation skips real Chromium deliberately. The second must run the
browser test: a guarded fixture passes; an unguarded real messaging fixture emits
context invalidation; worker/content uncaught positive controls must also appear
in the journal; missing in-flight proof remains partial. Every fixture uses its
own temporary profile and closes it before deletion.

Primary references: [Playwright extensions](https://playwright.dev/docs/chrome-extensions),
[Runtime protocol](https://chromedevtools.github.io/devtools-protocol/tot/Runtime/),
[Chromium developerPrivate implementation](https://raw.githubusercontent.com/chromium/chromium/main/chrome/browser/extensions/api/developer_private/developer_private_functions.cc),
[Chromium error console](https://raw.githubusercontent.com/chromium/chromium/main/chrome/browser/extensions/error_console/error_console.cc).
