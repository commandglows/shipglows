---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-05-02"
updated: "2026-05-02"
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
  - BUG-2026-05-02-001
depends_on: []
supersedes: []
evidence:
  - "BUG-2026-05-02-001: Playwright MCP looked for Google Chrome stable at /opt/google/chrome/chrome on Linux ARM64."
  - "Fixed config points Playwright MCP to local Playwright Chromium with --executable-path."
  - "108-sg-browser added as the generic non-auth consumer of browser evidence."
next_review: "2026-06-02"
next_step: "/107-sg-test --retest BUG-2026-05-02-001"
---

# Playwright MCP Runtime

Use this reference before any ShipGlows skill calls Playwright MCP directly or uses browser-level evidence through `108-sg-browser` or `109-sg-auth-debug`.

## Invariant

On Linux ARM64, never let Playwright MCP launch with the bare default config that can fall through to Google Chrome stable.

Correct runtime config is one of:

- `--executable-path <existing executable>` pointing to Playwright Chromium or Chromium Headless Shell.
- explicit `--browser chromium --headless --no-sandbox` when no executable path is known yet.

Do not recommend or run `npx playwright install chrome` as the fix for Linux ARM64. Chrome stable is the wrong channel for this environment. Use Playwright Chromium or Chromium Headless Shell.

## Preflight Before MCP Tool Calls

Before the first `mcp__playwright__*` call in a skill run:

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

3. If config is bad, do not launch Playwright MCP as proof. Route to:

```text
/106-sg-fix BUG-2026-05-02-001
```

4. If config is good but MCP still errors with `/opt/google/chrome/chrome`, assume the current Codex/MCP process is stale and still using old args. Ask for a Codex/MCP reload before claiming browser evidence.

## Runtime Dependencies

ShipGlows `install.sh` owns the default runtime libraries for Playwright Chromium because Playwright MCP is configured by default.

If direct Chromium launch reaches the correct executable but fails on a missing shared library such as `libatk-1.0.so.0`, the issue is not the Chrome-path bug anymore. Install or repair the Playwright runtime libraries, then retest.

## Evidence Rule

A successful browser-auth diagnosis should name the browser runtime used:

- `Playwright MCP runtime: executable-path <path>`
- `Playwright MCP runtime: chromium fallback`
- `Playwright MCP runtime: blocked, stale MCP config`

Never treat a browser-flow failure as an app or auth failure until the runtime preflight has passed.
