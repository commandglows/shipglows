---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "3.3.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-14"
status: active
source_skill: 900-shipglows-core
scope: agent-runtime-awareness-and-mutation-approval
owner: Diane
confidence: high
user_story: "As an operator, I can invoke $shipglows context to establish exact global and project runtime facts, and every intentional mutation waits for my approval of a visible plan."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/install-devserver.ps1
  - cli/install.sh
  - skills/references/agent-runtime-awareness.md
  - skills/references/playwright-mcp-runtime.md
  - skills/references/mutation-plan-approval.md
depends_on: []
supersedes: []
evidence:
  - "Operator approved one global environment document, one visible project ENVIRONMENT.md, registry-owned live state, and a retained read-only $shipglows context mode."
  - "Operator approved a universal explicit post-plan mutation gate."
next_step: "/103-sg-verify runtime awareness and mutation approval"
---

# Agent Runtime Awareness And Mutation Approval

## Runtime contract

- The full Windows installer writes `%USERPROFILE%\.shipglows\environment.md` idempotently with Windows, PowerShell, Codex CLI, Playwright, DevServer, and tool-surface facts.
- The full Windows installer uses `uv` to ensure one functional default Python runtime, publishes both `python` and `python3` in the user path, and stops before declaring readiness if either command or the `ssl`/`sqlite3` standard-library imports fail.
- The global environment document records the detected Python version, manager, and commands from installation results rather than a hardcoded version.
- The Playwright result records Chromium installation and executable path, MCP configuration and Codex config path, and successful `codex mcp get playwright --json` verification.
- Windows and Linux installers keep Playwright MCP enabled as the default web-QA lane; `playwright-interactive` remains an optional advanced Electron/persistent-program lane.
- Every registered project has a visible, versioned `<project-root>\ENVIRONMENT.md` with a bounded ShipGlows block. Existing user content is preserved.
- The project document stores the durable server manager, assigned port, and canonical loopback URL. It is updated only when registration or a real port assignment changes those facts.
- The Windows DevServer registry remains the sole live-status authority. Start and stop do not rewrite project documentation merely to change status.
- The native Windows backend ignores Flox completely and resolves direct or nested launch targets only from supported application manifests.
- `$shipglows context` resolves the project from the current directory, reads both documents and the registry, reports Python and Playwright evidence, and distinguishes installed/configured/discovered/callable/failed/not-exposed states.
- Current-turn capability discovery checks direct tools, then the host's deferred/searchable catalog (`ALL_TOOLS`, `tool_search`, or equivalent), then a safe read-only probe when available. Absence from the first visible list cannot prove non-availability.
- `open` uses the active registry entry and its persisted port.
- The installer migrates all registered projects and removes only the legacy `.shipglows/server.env` artifacts and exact Git exclude entries that ShipGlows managed.

## Mutation-approval contract

- Before every intentional state mutation, the agent displays `🧭 PLAN À VALIDER` with Objective, Scope, Actions, and Proofs.
- Only explicit approval given after that plan authorizes implementation. The initial imperative request is not approval.
- No spec or other persistent planning artifact is written before approval.
- Read-only discovery may precede approval.
- A material scope, behavior, risk, permission, data, destructive-effect, external-state, or proof change invalidates approval and requires a replacement plan.
- Micro-edits and server/process actions remain subject to the gate; their plan may be compact.

## Out of scope

- Persisted dynamic capability snapshots, session hashes, TTLs, JSON schemas, Codex wrappers, unbounded process inference, and a new Linux environment-document projection. Host-provided direct/deferred tool discovery and existing Linux MCP installation remain in scope.

## Verification

- PowerShell parser checks for module, launcher, installer, and focused migration test.
- Focused Windows regression checks for `uv python install --default`, fail-closed runtime validation, structured Playwright evidence, and generated capability fields.
- Focused Windows/Linux installer checks that Playwright MCP remains globally enabled and future runtime instructions require deferred discovery before an unavailable verdict.
- Scenario checks for direct absence plus deferred presence, safe-probe success, configured-but-undiscovered state, and discovered-call failure.
- Project document preservation, idempotence, durable `3002` URL, live-status separation, and legacy cleanup scenarios.
- Scenario checks for initial imperative, explicit post-plan approval, material-plan change, micro-edit, and server-process mutation.
- Skill budget, metadata, runtime sync, focused contract tests, and `git diff --check`.

## 2026-08-14 Runtime capability visibility slice

- Proof path: regression-first static contract plus native execution on the repaired Windows host.
- Pressure scenarios: `uv` exists but a fresh agent calls Python absent; Chromium is cached and the MCP is verified but its tool is not injected; configuration is mistaken for current-turn callability.
- Browser routing: Playwright MCP is the default web-QA lane; optional `playwright-interactive` capability cannot shadow or block it.
- ZOMBIES coverage: zero runtime fails closed; one managed default publishes both commands; multiple installed versions report only the selected default; interface proof imports `ssl` and `sqlite3`; exceptional install or MCP verification failure cannot be reported as ready.

## Skill Run History

| Date | Skill | Action | Result |
| --- | --- | --- | --- |
| 2026-08-14 | 900-shipglows-core | Extended runtime context with Python and Playwright/Chromium installation, configuration, verification, and callability evidence. | Implemented on an isolated branch with focused proofs. |
| 2026-08-14 | 900-shipglows-core | Added direct-plus-deferred tool discovery and MCP-first browser routing. | Implemented; 607 unit tests, focused Windows/Linux contracts, graph/audit/budget checks, and a live deferred Playwright probe passed. |
| 2026-08-14 | 300-sg-docs | Audited and aligned installer, Windows operator, runtime, lifecycle, plugin, and README documentation. | Complete; topology and metadata checks passed with no unresolved documentation drift. |

## Current Chantier Flow

- `100-sg-spec`: existing runtime-awareness spec extended with the approved capability-visibility slice.
- `101-sg-ready`: ready; scope and regression proof are explicit.
- `102-sg-start`: implementation complete.
- `300-sg-docs`: documentation reflection complete across internal, operator, installer, and bootstrap surfaces.
- `900 refresh`: conservative scenario review included in the focused contracts.
- `103-sg-verify`: focused Windows, skill, metadata, budget, audit, diff, and sync proofs required before publication.
- `104-sg-end`: complete when proof and remote ancestry are recorded.
- `005-sg-ship`: branch push authorized; no PR or deployment.
