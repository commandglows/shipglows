---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-28"
created_at: "2026-08-28 12:45:00 UTC"
updated: "2026-08-28"
updated_at: "2026-09-03 12:07:38 UTC"
status: reviewed
source_skill: 900-shipglows-core
source_model: GPT-5 Codex
scope: unified-shipglows-update-experience
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
user_story: "As the ShipGlows operator, I want explicit platform-supported update commands, so a bare update request never mutates an ambiguous target."
linked_systems:
  - cli/shipglows.sh
  - cli/shipglows_update.sh
  - cli/windows/shipglows.ps1
  - cli/windows/shipglows-devserver.ps1
  - install-shipglows.sh
  - install-shipglows.ps1
  - tui/
  - skills/shipglows/SKILL.md
  - README.md
  - shipglows_data/technical/runtime-cli.md
depends_on:
  - artifact: skills/references/windows-bootstrap-development-workflow.md
    artifact_version: "2.1.0"
    required_status: active
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.16.0"
    required_status: active
supersedes: []
evidence:
  - "Audit 2026-08-28: linked Codex skills are live and verified, while the Windows runtime is an installed copy, Unix has no ShipGlows self-update command, and the TUI has no update entry."
  - "Operator decision 2026-08-28: keep Unix s u for system packages; ShipGlows runtime updates use the explicit shipglows runtime update command, while the native Windows launcher routes operators to it."
  - "Operator decision 2026-09-03: bare shipglows update is non-mutating guidance; runtime updates require shipglows runtime update."
next_step: "Use shipglows update status before the next runtime refresh."
---

# Unified ShipGlows update experience

## Status

ready

## User Story

As the ShipGlows operator, I want explicit platform-supported update commands, so a bare update request never mutates an ambiguous target.

## Minimal Behavior Contract

`shipglows update status` is read-only and reports the active source, channel, and required reload. `shipglows runtime update` selects the stable official bootstrap for a normal installation, or the current clean remote-tracking branch for a linked developer checkout. Bare `shipglows update` performs no mutation and lists the explicit commands supported by the current platform; Windows includes runtime, skills, tools, and status, while Unix includes runtime, skills, and status. Linked skills are reported as live rather than copied or reinstalled. Native Windows exposes the runtime operation through the explicit command while its native launcher refuses self-update. Unix preserves `s u` as the package-update action.

## Success Behavior

- The operator has distinct stable commands for each update surface supported by the current platform, plus one read-only status variant.
- A linked checkout refuses to update when its source is dirty, unresolved, or not backed by an upstream branch.
- A linked update fetches the selected remote branch rather than silently switching to `main`.
- A normal Windows install continues to use the official HTTPS bootstrap with syntax validation and transactional runtime replacement.
- The Windows launcher accepts `shipglows runtime update` and delegates to the DevServer implementation; bare `shipglows update` lists explicit choices without mutation.
- The TUI remains read-only in V1 and clearly routes update actions to the canonical CLI command rather than running an independent updater.
- Agent-facing documentation tells a user that linked skills need only a new Codex/Claude session after a source update.

## Error Behavior

- Unknown update modes fail with the accepted commands and no mutation.
- A malformed developer-channel state, missing Git checkout, dirty checkout, detached HEAD, missing upstream, or failed Git inspection stops before bootstrap execution.
- A failed download, syntax validation, or bootstrap preserves the active runtime and does not report success.
- Existing Unix `s u` package-update behavior remains unchanged.
- No update operation exposes secrets, changes credentials, force-pushes, stashes user work, or edits user projects.

## Pressure Scenarios

- `UPDATE-LINKED-LIVE-SKILLS`: a linked developer checkout reports skills live and requests only an agent restart.
- `UPDATE-LINKED-DIRTY-REFUSAL`: local source changes stop a runtime update before any fetch, checkout, stash, or install.
- `UPDATE-LINKED-BRANCH`: a clean linked checkout uses its resolved upstream branch, not implicit `main`.
- `UPDATE-STABLE-WINDOWS`: a normal Windows install keeps the HTTPS download, syntax check, and transactional bootstrap path.
- `UPDATE-WINDOWS-LAUNCHER`: `shipglows runtime update` reaches the DevServer update implementation while native self-update routes to that command.
- `UPDATE-UNIX-COMPATIBILITY`: `shipglows runtime update` is reserved for the ShipGlows runtime while `s u` remains the system-package action.
- `UPDATE-TUI-ROUTE`: the read-only TUI explains the canonical CLI route and never gains an independent mutation path.

## Scope In

- Canonical update command and read-only status path on Unix and native Windows.
- Linked-channel branch selection and dirty-worktree safety checks.
- Native Windows DevServer menu/launcher integration.
- TUI and agent help discoverability without turning the TUI into a write surface.
- Focused tests and mapped runtime documentation.

## Scope Out

- Updating third-party packages through ShipGlows update.
- Altering `s u` on Unix.
- Automatic stashing, force pushes, releases, deployments, credentials, plugins, or project code.
- Editing the installed runtime directly instead of using its bootstrap.

## Implementation Tasks

- [x] Add a focused Unix update adapter with `status` and guarded update behavior.
- [x] Add Windows channel detection, linked-branch validation, and a shared launcher route.
- [x] Preserve the existing Windows DevServer update menu while making its source selection channel-aware.
- [x] Document the TUI as a read-only route to `shipglows runtime update` and update the public router guidance.
- [x] Add scenario-focused contract tests, syntax checks, and runtime documentation alignment.
- [x] Commit and push the implementation milestone only; closure bookkeeping is pending.

## Test Contract

- PowerShell syntax parsing for changed Windows scripts.
- Focused Windows update-routing/DevServer contract checks.
- `bash -n` and focused Unix update adapter checks.
- TUI typecheck/tests only if TUI source changes.
- `git diff --check` and exact-scope secret scan before delivery.

## Documentation Coherence

The runtime CLI document and README describe the canonical command and the developer/stable distinction. TUI documentation remains truthful that it is read-only. The public skill router explains the verbal route without duplicating executable procedure.

## Execution Notes

Implementation classification: infrastructure · cross-surface coherence. Proof discipline: scenario-first plus focused runtime syntax/contract checks. The pre-existing competitor research edit is unrelated and remains unstaged.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-28 | 900-shipglows-core | GPT-5 Codex | Formalized the approved unified update contract after confirming Git/GitHub alignment. | ready | Implement the runtime routes and focused proof. |
| 2026-08-28 | 900-shipglows-core | GPT-5 Codex | Implemented Unix and Windows update routes, retained the DevServer menu, and installed the pushed branch through the native bootstrap. | verified | Commit and push closure bookkeeping. |
| 2026-08-28 | 005-sg-ship | GPT-5 Codex | Delivered the implementation and verification commits to the resolved current upstream without force. | shipped | Use the canonical status command before a future refresh. |
| 2026-09-03 | sg-development | GPT-5.6 Codex | Replaced ambiguous bare runtime mutation with explicit runtime, skills, tools, and status routing across Windows and Unix. | verified locally | Deliver through the protected dev pull-request gate. |

## Current Chantier Flow

- `100-sg-spec` ✅ ready
- `101-sg-ready` ✅ ready by approved contract
- `102-sg-start` ✅ implemented
- `103-sg-verify` ✅ verified
- `104-sg-end` ✅ closed
- `005-sg-ship` ✅ shipped
