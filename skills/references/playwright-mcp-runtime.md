---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-05-02"
updated: "2026-08-14"
status: active
source_skill: 106-sg-fix
scope: playwright-mcp-runtime
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - install.sh
  - skills/108-sg-browser/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/109-sg-auth-debug/references/playwright-auth.md
  - skills/references/agent-runtime-awareness.md
  - BUG-2026-05-02-001
depends_on:
  - artifact: "skills/references/agent-runtime-awareness.md"
    artifact_version: "3.2.0"
    required_status: active
supersedes: []
evidence:
  - "BUG-2026-05-02-001: Playwright MCP looked for Google Chrome stable at /opt/google/chrome/chrome on Linux ARM64."
  - "Fixed config points Playwright MCP to local Playwright Chromium with --executable-path."
  - "108-sg-browser added as the generic non-auth consumer of browser evidence."
  - "The 2026-08-14 Codex runtime exposed Playwright only through a deferred tool catalog, proving that visible-list-only discovery creates false negatives."
next_review: "2026-06-02"
next_step: "/107-sg-test --retest BUG-2026-05-02-001"
---

# Playwright MCP Runtime

Use this reference before any ShipGlows skill calls Playwright MCP directly or uses browser-level evidence through `108-sg-browser` or `109-sg-auth-debug`.

## Invariant

Playwright MCP is ShipGlows's default browser automation lane for ordinary web
navigation, snapshots, screenshots, console/network inspection, and bounded UI
proof. The optional upstream `playwright-interactive` skill is an advanced lane
for Electron or complex persistent Playwright programs only when its skill and
REPL runtime are both callable. Its absence or failure never makes a working
Playwright MCP unavailable and never blocks the default web QA lane.

On Linux ARM64, never let Playwright MCP launch with the bare default config that can fall through to Google Chrome stable.

Correct runtime config is one of:

- `--executable-path <existing executable>` pointing to Playwright Chromium or Chromium Headless Shell.
- explicit `--browser chromium --headless --no-sandbox` when no executable path is known yet.

Do not recommend or run `npx playwright install chrome` as the fix for Linux ARM64. Chrome stable is the wrong channel for this environment. Use Playwright Chromium or Chromium Headless Shell.

On native Windows, the ShipGlows full installer owns the user-global Codex
entry `mcp_servers.playwright`. It resolves an absolute `npx.cmd`, downloads
Chromium with the Playwright version carried by `@playwright/mcp@latest`, and
enables the server for every project in that Codex profile. It never relies on
`npx.ps1` and never installs Playwright inside an application repository.

ShipGlows may replace only the Playwright MCP table it owns. Other Codex keys
and MCP servers must survive installation and repair. A successful installer
verdict requires both a readable Codex MCP entry and a Chromium executable in
the user Playwright cache; configuration alone is incomplete.

## Preflight Before MCP Tool Calls

Before the first `mcp__playwright__*` call in a skill run:

0. Apply `agent-runtime-awareness.md`. Inspect both directly exposed tools and
   the current host's deferred/searchable catalog for the `mcp__playwright__*`
   namespace. Record a match as `discovered`, but do not call it until the
   executable and configuration checks below pass. Do not infer absence from
   the initial visible tool list.

1. Check whether the repo or current user has an executable Chromium path:

```bash
find "$HOME/.cache/ms-playwright" -maxdepth 4 -type f \
  \( -path '*/chrome-linux/chrome' -o -path '*/chrome-linux/headless_shell' \) \
  -perm -111 -print 2>/dev/null | sort -Vr | head -n 1
```

2. Check `~/.codex/config.toml` and `~/.claude/settings.json` when they exist:
   - Good: Playwright args include `--executable-path` and the target exists.
   - Good fallback: Playwright args include `--browser` with `chromium`.
   - Bad: Playwright args are only `["-y", "@playwright/mcp@latest"]`.
   - Bad on ARM64: Playwright args select `chrome` or imply Google Chrome stable.
   - Good on native Windows: the command is an existing absolute `npx.cmd`,
     args select headless Chromium, and the server is enabled.

3. If config is bad, do not launch Playwright MCP as proof. Route to:

```text
/106-sg-fix BUG-2026-05-02-001
```

4. If config is good but MCP still errors with `/opt/google/chrome/chrome`, assume the current Codex/MCP process is stale and still using old args. Ask for a Codex/MCP reload before claiming browser evidence.

5. After the executable and configuration checks pass, use the smallest
   read-only probe available. Report `callable` only when that probe or the
   requested browser action succeeds; report `failed` with the exact error when
   discovery succeeded but the call did not.

## Runtime Dependencies

ShipGlows `install.sh` owns the default runtime libraries for Playwright Chromium because Playwright MCP is configured by default.

If direct Chromium launch reaches the correct executable but fails on a missing shared library such as `libatk-1.0.so.0`, the issue is not the Chrome-path bug anymore. Install or repair the Playwright runtime libraries, then retest.

## Evidence Rule

A successful browser-auth diagnosis should name the browser runtime used:

- `Playwright MCP runtime: executable-path <path>`
- `Playwright MCP runtime: chromium fallback`
- `Playwright MCP runtime: blocked, stale MCP config`
- `Playwright MCP capability: callable|failed|not exposed`

Never treat a browser-flow failure as an app or auth failure until the runtime preflight has passed.
