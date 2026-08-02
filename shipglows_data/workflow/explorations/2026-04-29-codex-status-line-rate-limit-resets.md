---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-04-29"
updated: "2026-04-29"
status: draft
source_skill: sg-explore
scope: codex-status-line-rate-limit-resets
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - install.sh
  - README.md
  - .claude/statusline-starship.sh
  - ~/.claude/settings.json
  - specs/codex-tui-thread-context-status.md
  - ~/.codex/config.toml
  - ~/.codex/sessions/**/*.jsonl
evidence:
  - "Local Codex CLI version observed: codex-cli 0.125.0."
  - "Local binary strings exposed native status line items including context-remaining, five-hour-limit, weekly-limit, but no reset-date item."
  - "Local Codex session events contain rate_limits.primary.resets_at and rate_limits.secondary.resets_at."
  - "Current ShipGlows Codex status line default was changed to include context-remaining, five-hour-limit, and weekly-limit."
  - "ShipGlows already configures Claude Code statusLine as a shell command pointing at .claude/statusline-starship.sh."
depends_on: []
supersedes: []
next_step: "/sg-spec AI agent rate-limit reset visibility"
---

# Exploration Report: Codex And Claude Code Rate-Limit Reset Visibility

## Starting Question

Can ShipGlows show the end date/time of the current 5-hour and weekly usage windows directly in the agent status line, especially Codex's status line, so the operator does not need to leave a mobile tmux workflow to check OpenAI usage?

## Context Read

- `~/.codex/config.toml` - confirmed the active status line uses native Codex items only:
  `model-with-reasoning`, `current-dir`, `context-remaining`, `five-hour-limit`, and `weekly-limit`.
- Local Codex binary strings - confirmed the installed Codex exposes native status line items such as `context-remaining`, `five-hour-limit`, and `weekly-limit`.
- Local Codex session JSONL events - confirmed Codex records reset timestamps under `rate_limits.primary.resets_at` for the 5-hour window and `rate_limits.secondary.resets_at` for the weekly window.
- `install.sh`, `README.md`, and `specs/codex-tui-thread-context-status.md` - confirmed ShipGlows owns the default Codex TUI configuration and can keep native status line defaults aligned.
- `install.sh` and `.claude/statusline-starship.sh` - confirmed ShipGlows already owns a Claude Code custom status line path through `statusLine.command`, and the shell renderer can calculate arbitrary local signals.
- `skills/sg-explore/SKILL.md` and `templates/exploration_report.md` - used to persist this exploration as a durable report without implementing the feature.

## Internet Research

- None for this capture. The main evidence came from the installed local Codex binary and local Codex session artifacts.

## Problem Framing

The operator works primarily inside Codex conversations on mobile through tmux. A terminal title or side command is much less useful than persistent footer/status-line visibility.

Codex already shows rate-limit usage percentages through native status line items:

```toml
tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]
```

The missing information is not usage percentage, but reset time:

- when the current 5-hour window ends
- when the current weekly window ends

The reset timestamps exist locally in Codex event history, but Codex 0.125.0 does not expose a native status line item for them and does not support a shell-script status line renderer.

Claude Code is different and should not be treated as blocked by the same constraint. ShipGlows already configures Claude Code with:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash $SHIPGLOWS_DIR/.claude/statusline-starship.sh"
  }
}
```

That means Claude Code can display locally computed reset information in its status line by extending the ShipGlows status line script. The hard blocker is Codex, not Claude Code.

## Local Evidence Snapshot

Latest local values observed during the exploration:

```text
5h reset:     2026-04-29 12:29:14 UTC
weekly reset: 2026-05-05 05:59:15 UTC
```

These values are examples from local session history, not durable truths. A future implementation must read the latest available `rate_limits` event at runtime.

Useful local fields:

```text
rate_limits.primary.used_percent
rate_limits.primary.window_minutes
rate_limits.primary.resets_at
rate_limits.secondary.used_percent
rate_limits.secondary.window_minutes
rate_limits.secondary.resets_at
```

## Option Space

### Option A: Native Codex Status Line Only

Summary:
Use only official/native status line items in `tui.status_line`.

Current best line:

```toml
tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]
```

Pros:
- Works today.
- Stable and supported by Codex.
- No scraping, no background process, no fragile terminal integration.

Cons:
- Cannot show reset dates or times.
- Only shows percentages or native labels that Codex decides to render.

Verdict:
This is the current production-safe default, but it does not satisfy the reset-time requirement.

### Option B: Terminal Title Wrapper

Summary:
Create a wrapper around `codex` that reads latest local `resets_at` values and writes them into the terminal title before or during the session.

Pros:
- Technically feasible.
- Uses local Codex data, not scraping.
- Can show exact reset times.

Cons:
- The user explicitly said this is not useful enough on mobile because tmux/conversation view does not make the title visible.
- Does not solve the requested "inside Codex footer" placement.

Verdict:
Useful for desktop, rejected for this user's primary workflow.

### Option C: Manual Reset-Time Script

Summary:
Provide a command that asks the user for 5h and weekly reset times, saves them locally, and prints them on demand.

Pros:
- Simple and independent from Codex internals.
- Works even when Codex logs do not yet contain rate-limit data.

Cons:
- Still cannot inject arbitrary text into Codex's native status line.
- Requires manual maintenance.
- Only useful as an external command unless Codex adds custom status line support.

Verdict:
Possible as a fallback, but it does not meet the status-line-first requirement.

### Option D: Read Local Codex Rate-Limit Events

Summary:
Build a small ShipGlows helper that reads `~/.codex/sessions/**/*.jsonl`, extracts the latest `rate_limits` block, converts reset epoch seconds to human-readable times, and prints a concise status.

Pros:
- Uses real Codex-provided data already present locally.
- Avoids web scraping.
- Can support both 5h and weekly windows.
- Can back a future status line item if Codex ever supports custom renderers.

Cons:
- Cannot render inside Codex status line today.
- Needs careful redaction and parsing because session files may contain conversation content, commands, and logs.
- Latest local reset time depends on Codex having written a recent `rate_limits` event.

Verdict:
Best implementation substrate for a future feature, but currently limited to commands, title wrappers, tmux status, or external displays.

### Option E: Scrape OpenAI Usage Page

Summary:
Use browser automation or Playwright MCP to log into the OpenAI usage page and scrape reset times.

Pros:
- Could reflect server-side truth even before local Codex writes a fresh event.
- Might reveal UI-only data if Codex local logs are stale.

Cons:
- Fragile against UI changes, auth state, Cloudflare, 2FA, mobile sessions, and rate-limit page changes.
- Higher security sensitivity: cookies, auth sessions, and account usage page.
- More operational friction than reading local Codex artifacts.

Verdict:
Plan C only. Prefer local Codex artifacts first.

### Option F: Upstream Codex Feature Request

Summary:
Ask OpenAI/Codex to add native status line items such as `five-hour-reset`, `weekly-reset`, or support for custom shell-rendered status line segments.

Pros:
- Only path that truly satisfies "inside native Codex status line" cleanly.
- Could become stable and portable.

Cons:
- Depends on upstream.
- Not available for immediate ShipGlows implementation.

Verdict:
Recommended upstream request if this remains important.

### Option G: Claude Code Custom Status Line

Summary:
Extend ShipGlows's Claude Code status line script to read the same rate-limit source, or a shared ShipGlows cache, and render 5-hour plus weekly reset times directly in Claude Code.

Pros:
- Feasible today because Claude Code supports `statusLine.command`.
- Fits the user's "inside the conversation UI" preference when using Claude Code.
- Can reuse a shared safe parser if ShipGlows later builds one for Codex helper commands.
- Gives ShipGlows a working reference implementation while Codex waits for upstream support.

Cons:
- Does not solve the Codex status line limitation.
- Claude Code and Codex may expose usage/rate-limit data differently; a shared parser must be careful about source semantics.
- Any parser reading agent session artifacts must avoid leaking prompts, commands, logs, secrets, tokens, cookies, or customer data.

Verdict:
Recommended as the first actually implementable UI path if the user also wants this in Claude Code. It should be scoped separately from the Codex-native request.

## Comparison

| Option | Shows in Codex status line today | Shows in Claude Code status line today | Shows exact reset time | Fragility | Fit for mobile tmux |
|--------|----------------------------------|----------------------------------------|------------------------|-----------|---------------------|
| Native Codex items | yes | n/a | no | low | high |
| Terminal title wrapper | no | no | yes | low-medium | low |
| Manual script | no | no | yes | low | medium |
| Local Codex log reader | no | possible via Claude script if source applies | yes | medium | medium |
| Usage page scraping | no | possible via Claude script | yes | high | medium |
| Upstream Codex feature | future only | n/a | yes | low if accepted | high |
| Claude Code custom status line | n/a | yes | yes | medium | high |

## Emerging Recommendation

Do not implement a Codex workaround right now.

When this chantier is reopened, split the work into two tracks:

1. Claude Code track, implementable now:
   - extend `.claude/statusline-starship.sh`
   - read a safe, minimal rate-limit source
   - render `5h reset` and `week reset` directly in Claude Code
   - avoid copying raw session logs or sensitive content

2. Codex track, blocked for native footer rendering:
   - keep native `five-hour-limit` and `weekly-limit` in `tui.status_line`
   - file or track an upstream Codex request for reset-time status line items
   - optionally provide an external command while waiting

The shared substrate for both tracks should be a safe local parser:
   - reads latest session JSONL files
   - extracts only `rate_limits`
   - prints reset times and percentages
   - never persists or prints raw conversation content

If Codex adds custom status line rendering later, the same parser can become the Codex renderer. Until then, it can only power a command, tmux status, terminal title, or Claude Code status line.

## Non-Decisions

- No scraping strategy chosen.
- No manual reset-time storage format chosen.
- No tmux status integration chosen.
- No upstream issue filed from this exploration.
- No Claude Code status line extension implemented.
- No code implementation started, per `sg-explore` mode.

## Rejected Paths

- Terminal-title-only solution - rejected for the user's primary mobile/tmux workflow.
- Scraping first - rejected as too fragile and security-sensitive compared with local `rate_limits` data.
- Claiming reset dates can be added to `tui.status_line` today - rejected because Codex 0.125.0 only accepts native predefined status line items and no reset-date item was observed.
- Treating Claude Code as equally blocked - rejected because Claude Code already supports a shell-command status line renderer in ShipGlows.

## Risks And Unknowns

- Codex's local session JSONL structure may change in future versions.
- Local session files may contain sensitive prompts or logs; any parser must extract only specific `rate_limits` fields and avoid copying raw content.
- `resets_at` semantics could differ from "full reset" if OpenAI changes rate-limit behavior.
- The usage page might expose more precise or differently scoped windows than local Codex events.
- A native upstream item could make custom ShipGlows work unnecessary.
- Claude Code can display computed data today, but it still needs a safe data source and redaction-aware parser.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: local Codex config path and session artifact paths; no secrets were copied.
- Redactions applied: none needed in the final report.
- Notes: Local session JSONL can contain sensitive conversation and command content. This report records only field names, high-level structure, and sanitized reset-time examples.

## Decision Inputs For Spec

- User story seed:
  En tant qu'utilisatrice Codex et Claude Code sur mobile dans tmux, je veux voir les dates de reset 5h et weekly sans quitter la conversation agent, afin d'anticiper mes limites sans surveiller la page Usage OpenAI.

- Scope in seed:
  Local rate-limit parser, safe JSONL extraction, human-readable reset formatting, Claude Code status line integration, optional manual fallback, documentation of the native Codex status line limitation.

- Scope out seed:
  Browser scraping by default, raw session log persistence, modifying Codex binary, pretending arbitrary Codex status line segments are supported.

- Invariants/constraints seed:
  Do not leak prompts, secrets, cookies, tokens, or raw logs from `~/.codex/sessions`.
  Keep native status line defaults limited to supported items.
  Keep Claude Code custom status line logic in the existing ShipGlows renderer path.
  Treat reset timestamps as volatile runtime state.

- Validation seed:
  Use a fixture containing only `rate_limits` JSON, verify extracted 5h and weekly reset times, verify no unrelated JSONL content is printed, and verify behavior when no rate-limit event exists.

## Handoff

- Recommended next command: `/sg-spec AI agent rate-limit reset visibility`
- Why this next step:
  The desired user outcome is clear, but the implementation needs a security-conscious spec because it may read local agent session artifacts that can contain sensitive data. Claude Code is implementable now; Codex-native footer rendering depends on upstream support.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-04-29 | Show remaining context instead of used context | Inspected local Codex supported status line items and ShipGlows Codex TUI defaults | Replaced `context-used` with `context-remaining` in active/default config | Done |
| 2026-04-29 | Add 5h and weekly usage indicators | Confirmed native items `five-hour-limit` and `weekly-limit` exist | Added both to active/default status line | Done |
| 2026-04-29 | Show reset date/time in status line | Inspected native items and local rate-limit events | Found reset timestamps exist locally but no native status line reset item exists | Park feature until `/sg-spec` |
| 2026-04-29 | Include Claude Code in the exploration | Inspected ShipGlows's Claude Code `statusLine.command` path and `.claude/statusline-starship.sh` | Added Claude Code as an implementable status line track and Codex as the blocked native-footer track | Done |
