---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-28"
created_at: "2026-08-28 12:45:00 UTC"
updated: "2026-08-28"
updated_at: "2026-08-28 12:45:00 UTC"
status: ready
source_skill: 900-shipglows-core
source_model: GPT-5 Codex
scope: unified-shipglows-update-experience
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
user_story: "As the ShipGlows operator, I want one update command that understands whether I use a linked developer checkout or a normal installation, so CLI, DevServer, TUI, skills, and agent guidance converge without reinstall guesswork."
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
  - "Operator decision 2026-08-28: keep Unix s u for system packages; ShipGlows itself uses shipglows update, while the native Windows DevServer exposes its update entry."
next_step: "Implement the canonical update contract and prove the linked and stable routing paths."
---

# Unified ShipGlows update experience

## Status

ready

## User Story

As the ShipGlows operator, I want one update command that understands whether I use a linked developer checkout or a normal installation, so CLI, DevServer, TUI, skills, and agent guidance converge without reinstall guesswork.

## Minimal Behavior Contract

`shipglows update status` is read-only and reports the active source, channel, and required reload. `shipglows update` selects the stable official bootstrap for a normal installation, or the current clean remote-tracking branch for a linked developer checkout. Linked skills are reported as live rather than copied or reinstalled. Native Windows exposes the same operation through `shipglows update` and the existing DevServer update menu. Unix preserves `s u` as the package-update action.

## Success Behavior

- The operator has one stable command for ShipGlows updates and one read-only status variant.
- A linked checkout refuses to update when its source is dirty, unresolved, or not backed by an upstream branch.
- A linked update fetches the selected remote branch rather than silently switching to `main`.
- A normal Windows install continues to use the official HTTPS bootstrap with syntax validation and transactional runtime replacement.
- The Windows launcher accepts `shipglows update` and delegates to the DevServer implementation.
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
- `UPDATE-WINDOWS-LAUNCHER`: `shipglows update` and the DevServer menu reach the same update implementation.
- `UPDATE-UNIX-COMPATIBILITY`: `shipglows update` is reserved for ShipGlows while `s u` remains the system-package action.
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

- [ ] Add a focused Unix update adapter with `status` and guarded update behavior.
- [ ] Add Windows channel detection, linked-branch validation, and a shared launcher route.
- [ ] Preserve the existing Windows DevServer update menu while making its source selection channel-aware.
- [ ] Document the TUI as a read-only route to `shipglows update` and update the public router guidance.
- [ ] Add scenario-focused contract tests, syntax checks, and runtime documentation alignment.
- [ ] Commit and push only the owned change set.

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

## Current Chantier Flow

- `100-sg-spec` ✅ ready
- `101-sg-ready` ✅ ready by approved contract
- `102-sg-start` ⏳ in progress
- `103-sg-verify` ➖ pending
- `104-sg-end` ➖ pending
- `005-sg-ship` ➖ pending
