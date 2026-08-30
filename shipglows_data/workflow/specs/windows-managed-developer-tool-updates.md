---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-30"
created_at: "2026-08-30 08:24:00 UTC"
updated: "2026-08-30"
updated_at: "2026-08-30 11:53:09 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: windows-managed-developer-tool-updates
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
user_story: "As the ShipGlows operator on Windows, I want ShipGlows to preview and update the global developer tools it owns without changing any project's dependencies."
linked_systems:
  - cli/windows/shipglows.ps1
  - cli/windows/shipglows-devserver.ps1
  - cli/windows/install-devserver.ps1
  - install-shipglows.ps1
  - tests/windows/update-command.ps1
  - tests/windows/devserver-contract.sh
  - README.md
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/installer-and-user-scope.md
depends_on:
  - artifact: skills/references/windows-bootstrap-development-workflow.md
    artifact_version: "2.1.0"
    required_status: active
  - artifact: shipglows_data/workflow/specs/unified-shipglows-update-experience.md
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator approval 2026-08-30: ShipGlows should own controlled Windows updates for its global developer toolchain, separately from ShipGlows self-update and project dependency updates."
  - "Current runtime inspection: s update reruns the full installer, but existing WinGet tools and pnpm are treated as already installed and skipped rather than checked for upgrades."
  - "Public-content follow-up commit a0b49ec prepares paired EN/FR article drafts and permanent docs copy without publishing an availability claim before installed-host proof."
  - "Installed-host proof 2026-08-30: interactive ShipGlows convergence updated npm 12.0.2, pnpm 11.24.0, mise 2026.8.5, and uv 0.12.7; repaired and verified Claude 2.1.251 and OpenCode 1.18.25; the idempotent rerun preserved mobile/IDE state and completed successfully."
next_step: "Close the lifecycle record and decide the release/publication path for the validated Windows update surface."
---

# Windows-managed developer tool updates

## Status

ready

## User Story

As the ShipGlows operator on Windows, I want ShipGlows to preview and update the global developer tools it owns without changing any project's dependencies.

## Minimal Behavior Contract

Given an installed native Windows runtime, `shipglows tools status` and `s tools status` perform read-only package-authority checks and identify the ShipGlows-owned global tool surfaces. `shipglows tools update` and the dedicated interactive menu entry show the update scope, require explicit confirmation, update only the allowlisted global tools through their owning package authorities, then rerun the normal full convergence and report verified final versions. Missing authorities, refusal, partial failure, or an unavailable final version stops or reports the affected tool truthfully; no command runs a project-local package update.

## Success Behavior

- ShipGlows self-update remains `shipglows update`; developer-tool updates use the distinct `shipglows tools ...` namespace.
- Status is read-only and shows WinGet's available-upgrade preview plus exact npm and pnpm current/latest evidence when their commands are available.
- Update displays the allowlisted scope before one explicit confirmation.
- WinGet upgrades target only exact ShipGlows-owned package IDs; ShipGlows never invokes `winget upgrade --all`.
- npm and pnpm targets are resolved from the official npm registry and installed at the displayed exact versions.
- The current full installer convergence runs after the core package-manager layer so managed wrappers, agents, service CLIs, MCP runtimes, and environment reporting are reconciled normally.
- Final command-version probes distinguish success, skipped/unavailable tools, and failures.

## Error Behavior

- Refusal exits without package mutation and without reporting an error.
- Status tolerates a missing optional package authority and labels that surface unavailable.
- Update fails before the normal convergence when a requested core-tool upgrade command fails or times out.
- A registry query that returns an invalid version is rejected before invoking npm or Corepack.
- The command never changes a project manifest, lockfile, `node_modules`, authentication, credentials, WinGet source configuration, execution policy, or restart policy.
- Existing dirty project and unrelated repository files remain untouched.

## Problem

The Windows CLI currently presents `Update ShipGlows`, while its full installer installs missing developer tools. Existing Node/npm/pnpm and WinGet tools are generally accepted as present and are not converged to current approved channels, so the operator can see an npm update notice with no ShipGlows-owned route to assess or apply it.

## Solution

Add one Windows developer-tool update route that reuses the official bootstrap and full installer. The route separates read-only status from mutation, passes an explicit tool-update intent through the bootstrap, upgrades only the declared global tool allowlist, then lets the existing installer repair wrappers and exact managed CLI/toolbox state. Project dependency maintenance remains a separate project-scoped workflow.

## Scope In

- Windows CLI launcher, DevServer shortcut/help/menu, bootstrap argument forwarding, and full-installer update preparation.
- Allowlisted WinGet tools installed by ShipGlows: Git, GitHub CLI, Node LTS, mise, Google Cloud CLI, Doppler, and uv.
- npm and pnpm global package-manager versions plus the already-owned agent, service CLI, Playwright, wrapper, and environment convergence reached by the full installer.
- Focused static tests, PowerShell parsing, mapped runtime/installer documentation, and operator guidance.

## Scope Out

- Project `package.json`, lockfiles, dependency upgrades, installs, tests, or migrations.
- `winget upgrade --all`, arbitrary npm/pnpm global packages, Windows Update, drivers, IDE/SDK/license upgrades, authentication, credentials, provider project selection, reboot, release, merge, or deployment.
- Unix package-update behavior and the separate ShipGlows self-update channel contract.

## Constraints

- PowerShell 7 managed-runtime boundary and PowerShell 5.1 bootstrap parsing must remain valid.
- Package updates require an interactive console and explicit operator confirmation.
- Exact package IDs and exact registry-resolved npm package versions are passed as discrete arguments; no shell-composed command is executed.
- No live package upgrade is part of automated proof.
- The installed runtime remains a generated output; source files are changed only in the linked maintainer checkout.

## Test Contract

- Surface/profile: native Windows CLI/bootstrap/installer static contract.
- Proof path: scenario-first contract assertions, PowerShell parser checks, `tests/windows/update-command.ps1`, and the complete Windows static contract.
- Integration/provider proof: no live package mutation in automated tests; a later separately authorized interactive branch bootstrap is required before claiming installed-host convergence.
- Security proof: exact allowlist assertions, absence of `winget upgrade --all`, explicit consent, bounded process calls, and no project package-manager update command.

## Dependencies

- WinGet for allowlisted Windows packages.
- npm registry metadata for exact npm/pnpm target versions.
- Existing managed PowerShell bootstrap and full native Windows installer.
- Existing exact-version agent and machine-toolbox convergence.

## Invariants

- `shipglows update` updates ShipGlows; `shipglows tools update` updates ShipGlows-owned global developer tools.
- Status never mutates package, runtime, project, profile, credential, or source state.
- Update never broadens beyond the explicit allowlist.
- Project dependencies are never updated by the global tools command.
- Refusal is safe, idempotent, and leaves the installed state unchanged.

## Links & Consequences

- Extends, but does not redefine, the completed unified ShipGlows update experience.
- Reuses the full installer, so bootstrap payload lists, active runtime copies, wrappers, environment reporting, and Windows documentation require revalidation.
- A future project-dependency updater must use a separate project-owned contract and cannot reuse this global mutation route implicitly.

## Documentation Coherence

- Update `README.md`, `shipglows_data/technical/runtime-cli.md`, and `shipglows_data/technical/installer-and-user-scope.md`.
- Keep the code-docs map unchanged because the existing `cli/windows/**` mapping already covers the changed files and focused validations.

## Edge Cases

- Z: no updates, missing WinGet, missing npm/Corepack, or empty registry output yields a truthful no-op/unavailable status.
- O: one available allowlisted update is previewed, confirmed, applied, and re-observed.
- M: several tool authorities and packages update sequentially; one failure stops before a misleading final success.
- B: current equals latest, major version changes, command timeout, and non-interactive invocation preserve explicit behavior.
- I: DevServer to bootstrap to installer intent, WinGet exact IDs, npm registry version metadata, and full-convergence handoff stay explicit.
- E: refusal, invalid version, missing authority, timeout, provider failure, and post-update version mismatch are reported without project mutation.
- S: one status path, one update path, one confirmation, and the existing convergence engine.

## Implementation Tasks

1. [x] Extend the focused Windows update tests with failing assertions for `tools status`, `tools update`, menu/help separation, allowlist-only WinGet usage, exact registry versions, explicit consent, and project-dependency exclusion; validate with `tests/windows/update-command.ps1`.
2. [x] Add the CLI/DevServer routes and distinct interactive menu entry; validate PowerShell parsing and focused routing assertions.
3. [x] Forward explicit developer-tool update intent through the bootstrap and implement bounded preview/update preparation in the full installer; validate exact argument forwarding, allowlist assertions, invalid-version refusal, and no broad upgrade command.
4. [x] Update mapped runtime/installer/operator documentation; validate focused wording and metadata.
5. [x] Run the complete Windows static contract, parser checks, `git diff --check`, and exact-scope secret scan; commit and push the approved branch milestone without force.

## Acceptance Criteria

- AC1: `shipglows tools status` and `s tools status` reach the same read-only implementation and never launch the bootstrap.
- AC2: `shipglows tools update` and the dedicated menu action show the allowlist and require explicit confirmation before any package mutation.
- AC3: WinGet mutations use only exact declared IDs and never use `upgrade --all`, `--force`, or reboot-enabling flags.
- AC4: npm and pnpm registry results are validated as package versions, displayed, and installed using the exact displayed versions.
- AC5: the bootstrap forwards tool-update intent only in full mode; the child installer preserves it across managed PowerShell reentry.
- AC6: successful core-tool preparation is followed by normal full convergence and final version probes; failures cannot report complete success.
- AC7: no project manifest, lockfile, dependency directory, or project package-manager update command belongs to the implementation.
- AC8: focused and complete Windows static contracts pass without live package installation.
- AC9: documentation explains the three distinct update surfaces: ShipGlows, global developer tools, and project dependencies.

## Test Strategy

Start scenario-first with the focused Windows update contract. Implement the smallest complete route that passes static parser and textual/behavioral contract checks. Run the full Windows contract only after the focused proof passes. Do not execute a real installer or package upgrade in this run.

## Risks

- Package providers can return localized, ambiguous, or changing output; status should present provider evidence rather than infer unsupported structure.
- npm/pnpm upgrades can affect global wrappers; the normal full convergence must repair and revalidate owned wrappers afterward.
- WinGet installers can require elevation or return ambiguous exit codes; bounded execution and final observation remain authoritative.
- A tool update can introduce incompatibility despite using an official stable channel; the command must report the exact final versions and avoid claiming universal compatibility without a real-host proof.

### OWASP Security Gate

A03 Software Supply Chain Failures, A05 Injection, A08 Software or Data Integrity Failures, and A10 Mishandling of Exceptional Conditions are applicable. Trust boundaries are WinGet, the official npm registry, downloaded ShipGlows bootstrap source, and locally installed executables. No ASVS requirement is claimed because this is a local developer-tool installer rather than an application verification surface. Proof is the exact allowlist, immutable ShipGlows bootstrap resolution, discrete process arguments, version validation, explicit consent, bounded failures, and post-update observation. Residual provider/package integrity risk remains owned by the official package authorities and the later real-host branch proof.

## Execution Notes

Classification: infrastructure · native Windows runtime · supply-chain sensitive. Functional form: one distinct global-tool route replaces the current ambiguity without adding project package management. Proof discipline: scenario-first. Pressure scenario: an npm notice appears while `s update` only advertises ShipGlows; the operator must receive a ShipGlows-owned preview and confirmed update route without leaving the CLI or touching a project.

First-read implementation files: `tests/windows/update-command.ps1`, `cli/windows/shipglows.ps1`, `cli/windows/shipglows-devserver.ps1`, `install-shipglows.ps1`, and `cli/windows/install-devserver.ps1`. Preserve the existing channel-aware ShipGlows update route and the child installer's managed PowerShell reentry. Start with focused failing contract assertions, then implement routing and installer intent forwarding, then update mapped docs. Validate with `powershell.exe -NoProfile -File tests/windows/update-command.ps1`, PowerShell parser checks, `bash tests/windows/devserver-contract.sh`, and `git diff --check`. Stop before any live package mutation, runtime activation, unrelated dirty-file edit, broad `winget upgrade --all`, project dependency operation, credential flow, reboot, merge, or release.

## Open Questions

None. The operator approved the separate global-tool route, explicit preview/confirmation, allowlisted ownership boundary, and project-dependency exclusion on 2026-08-30.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-30 | 100-sg-spec | GPT-5 Codex | Formalized the approved Windows global developer-tool update contract from current runtime evidence and official package-authority behavior. | draft | Run readiness review. |
| 2026-08-30 | 101-sg-ready | GPT-5 Codex | Reviewed user-story fit, supply-chain boundaries, failure behavior, ZOMBIES coverage, documentation consequences, and focused proof. | ready | Implement scenario-first without executing live package updates. |
| 2026-08-30 | 900-shipglows-core | GPT-5 Codex | Implemented separate Windows `tools status|update` routes, exact allowlisted WinGet handling, exact npm/pnpm convergence, existing-agent updates, and mapped documentation. | implemented | Run focused and complete Windows verification. |
| 2026-08-30 | 103-sg-verify | GPT-5 Codex | Passed the focused update contract, PowerShell parsing, complete Windows static contract, metadata lint, and diff checks without executing package mutation. | partial | Publish the branch, then run a separately authorized real-host bootstrap and interactive update proof. |
| 2026-08-30 | 900-shipglows-core | GPT-5 Codex | Published validated implementation commit `11363b6` to `origin/codex/development-runtime` without staging the operator's unrelated dirty file. | delivered | Obtain separate authority for installed-host convergence proof; keep 103 partial and closure pending. |
| 2026-08-30 | 900-shipglows-core | GPT-5 Codex | Prepared the public Windows toolchain story in English and French, permanent runtime documentation, claim boundaries, and changelog projection; site commit `a0b49ec` keeps both articles in draft. | delivered | Keep publication gated by installed-host convergence and release proof. |
| 2026-08-30 | 103-sg-verify | GPT-5 Codex | Ran the installed linked runtime interactively, hardened npm 12 JSON parsing, active pnpm shim convergence, native agent postinstall recovery, Playwright resolution, and SDK/IDE exclusion; final idempotent convergence and complete Windows contract passed. | verified | Close the lifecycle record and choose release/publication timing. |

## Current Chantier Flow

- `100-sg-spec` ✅ ready
- `101-sg-ready` ✅ ready
- `102-sg-start` ✅ implemented
- `103-sg-verify` ✅ verified · installed-host convergence and idempotent rerun passed
- `104-sg-end` ⚪ pending
- `005-sg-ship` ⚪ pending
