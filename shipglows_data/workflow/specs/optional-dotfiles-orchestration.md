---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-08-31"
created_at: "2026-08-31 17:20:16 UTC"
updated: "2026-08-31"
updated_at: "2026-08-31 17:20:16 UTC"
status: draft
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice de ShipGlows, je veux pouvoir installer facultativement mes dotfiles depuis l'installation ShipGlows, tout en conservant un installateur dotfiles autonome, afin d'obtenir un poste complet sans maintenir deux implementations concurrentes."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "install-shipglows.ps1"
  - "install-shipglows.sh"
  - "cli/windows/install-devserver.ps1"
  - "cli/install.sh"
  - "tests/windows"
  - "tests/install"
  - "commandglows/dotfiles"
depends_on:
  - artifact: "shipglows_data/technical/context.md"
    artifact_version: "0.14.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/specs/installer-supply-chain-and-codebase-risk-reduction.md"
    artifact_version: "1.1.0"
    required_status: ready
  - artifact: "commandglows/dotfiles:shipglows_data/workflow/specs/cross-platform-dotfiles-installer-hardening.md"
    artifact_version: "1.0.1"
    required_status: ready
supersedes: []
evidence:
  - "Operator decision 2026-08-31: dotfiles remain independently installable on Windows and Linux."
  - "Operator decision 2026-08-31: ShipGlows may offer dotfiles as an optional installation step but must delegate to the official dotfiles installer."
  - "Repository inspection: ShipGlows has native Windows and Unix public bootstraps, while dotfiles owns separate native PowerShell and Bash engines backed by a shared component manifest."
next_step: "/sg-ready Optional dotfiles orchestration"
---

# Spec: Optional dotfiles orchestration

## Title

Optional dotfiles orchestration from the ShipGlows installer

## Status

draft

## User Story

En tant qu'utilisatrice de ShipGlows, je veux pouvoir installer facultativement mes dotfiles depuis l'installation ShipGlows, tout en conservant un installateur dotfiles autonome, afin d'obtenir un poste complet sans maintenir deux implementations concurrentes.

## Minimal Behavior Contract

ShipGlows proposes an explicit optional dotfiles step during an interactive Windows or Unix installation and exposes an equivalent explicit automation option. Accepting delegates to the official dotfiles bootstrap for the current operating system; declining leaves the ShipGlows flow unchanged. Non-interactive installation never opts in implicitly. A download, source-verification, bootstrap, or dotfiles-install failure stops the optional step with an actionable error and never reports dotfiles as installed. The easy-to-miss boundary is that ShipGlows orchestrates the external installer but never copies its component manifest, package selection, configuration placement, backup, update, or uninstall logic.

## Success Behavior

- Preconditions: a supported Windows or native Linux host, network access when the dotfiles source is not already locally available, and a resolvable official dotfiles repository/ref.
- Trigger: the operator selects the dotfiles option interactively or supplies the documented explicit automation option.
- User/operator result: ShipGlows clearly reports that dotfiles installation was delegated and whether it succeeded, failed, or was declined.
- System effect: the official dotfiles installer performs its own OS-specific installation under its existing ownership, safety, backup, and recovery contracts.
- Success proof: controlled fixtures prove exact delegation arguments and exit propagation; the standalone dotfiles contracts remain green.
- Silent success: not allowed; successful delegation must be visible in the installer summary.

## Error Behavior

- Expected failures: unsupported OS, invalid repository/ref, unavailable verified source, missing native prerequisite, dotfiles bootstrap failure, or non-zero delegated installer exit.
- User/operator response: name the failed dotfiles stage, preserve the original exit context, and provide the standalone recovery entrypoint without asking for secrets.
- System effect: do not retry destructively, do not claim dotfiles completion, and do not duplicate or compensate for dotfiles-owned mutations inside ShipGlows.
- Must never happen: `curl | shell`, implicit non-interactive opt-in, copied component/package logic, deletion of an existing dotfiles checkout, reset/stash of user work, or a successful ShipGlows summary that hides a failed requested dotfiles step.
- Silent failure: not allowed.

## Problem

ShipGlows and dotfiles expose complementary installation experiences, but operators who want both currently run them separately. Reimplementing terminal tooling inside ShipGlows would create duplicate ownership and platform drift; making dotfiles depend on ShipGlows would remove their legitimate standalone use.

## Solution

Add a thin, optional orchestration adapter to each ShipGlows public installer. The adapter resolves and verifies the official dotfiles source, invokes its native bootstrap with explicit arguments, propagates its result, and otherwise treats the dotfiles repository as an independent product.

## Scope In

- Interactive opt-in in the Windows and native Unix ShipGlows public installation experiences.
- Explicit non-interactive option and documented environment-variable equivalent where the existing installer convention supports it.
- Fail-closed retrieval of the official dotfiles bootstrap into a temporary location; never execute a response body through a pipe.
- Windows delegation to the official PowerShell dotfiles entrypoint.
- Native Linux delegation to the official Bash dotfiles entrypoint.
- Exact argument, refusal, failure, idempotence, and no-duplication contract tests.
- Technical and operator documentation for the optional relationship.

## Scope Out

- Moving terminal components, their manifest, configuration files, shortcuts, backup journal, update logic, or uninstall logic into ShipGlows.
- Making ShipGlows mandatory for standalone dotfiles installation.
- Making dotfiles installation an implicit default in automation, CI, update, repair, download-only, or maintainer flows.
- WSL or Termux orchestration unless a later explicit product decision adds them.
- Installing dotfiles on the operator's current machine as part of implementation proof.
- Publishing, release, deployment, or modification of the dotfiles public site.

## Constraints

- Ownership direction is one-way and optional: `ShipGlows -> dotfiles`; dotfiles never depends on ShipGlows.
- Both repositories retain their native Windows/Linux engines and may evolve independently behind documented delegation inputs.
- The source trust path must reuse or extend ShipGlows' existing pinned/ref-resolved download protections.
- Tests use fixtures or stubs and must not perform a real workstation installation.
- Existing dirty files in either repository remain preserved and outside implementation commits unless explicitly owned by the chantier.

## Dependencies

- Runtime: native PowerShell on Windows, Bash on Linux, and the prerequisites already required by the official dotfiles bootstraps.
- Document contracts: ShipGlows runtime context `0.14.0`, installer supply-chain spec `1.1.0`, and dotfiles installer hardening spec `1.0.1`.
- Metadata gaps: the public dotfiles release/ref policy must be confirmed during readiness; no secret or private repository access is assumed.

## Invariants

- Dotfiles remain independently installable without ShipGlows.
- ShipGlows contains no terminal-component inventory or platform-specific dotfiles installation logic.
- Declining or omitting the option preserves current ShipGlows behavior.
- Non-interactive installation requires explicit opt-in.
- Requested delegation failure is visible and fail-closed.
- No installer resets, stashes, overwrites, or deletes user-owned repository work.

## Links & Consequences

- Upstream systems: ShipGlows Windows and Unix public bootstraps, their interactive choice handling, environment options, and source-resolution helpers.
- Downstream systems: official dotfiles Windows/Linux bootstraps, installer summaries, support documentation, and CI contracts in both repositories.
- Cross-cutting checks: supply-chain validation, OS detection, non-interactive safety, temporary-file cleanup, exit-code fidelity, idempotence, and documentation coherence.

## Documentation Coherence

- Update ShipGlows installation guidance to describe dotfiles as optional and independently owned.
- Update the technical context and code-doc map if the orchestration adapter creates a new maintained installer boundary.
- Update dotfiles documentation only if the delegated invocation contract or public entrypoint changes.
- Public-site claims require a separate editorial review and are not implied by implementation completion.

## Edge Cases

- Interactive console is unavailable and no explicit dotfiles option is supplied.
- The operator requests `DownloadOnly`, update, repair, or maintainer setup together with dotfiles orchestration.
- A local dotfiles checkout exists but is dirty, has a mismatched origin, or targets another branch.
- The remote ref resolves but the downloaded archive/bootstrap is missing the expected entrypoint.
- ShipGlows succeeds but the requested dotfiles delegation fails.
- Dotfiles report a converged installation and perform no mutation.
- Windows path quoting, PowerShell host differences, or Unix spaces in home paths alter delegated arguments.
- WSL is installed on Windows but the host must still use the native Windows dotfiles engine.

## Implementation Tasks

- [ ] Task 1: Freeze the cross-repository delegation contract.
  - File: `shipglows_data/workflow/specs/optional-dotfiles-orchestration.md`
  - Action: confirm repository URL/ref policy, supported surfaces, exact opt-in names, and failure semantics during readiness.
  - User story link: prevents the orchestration layer from becoming a second installer.
  - Depends on: none.
  - Validate with: readiness review against both installer contracts.
  - Notes: any WSL, Termux, default-on, or private-repository requirement requires a spec revision.

- [ ] Task 2: Add Windows opt-in and delegation.
  - File: `install-shipglows.ps1`, and `cli/windows/install-devserver.ps1` only if the selected boundary requires forwarding into the full convergence engine.
  - Action: add interactive and explicit non-interactive opt-in, resolve a verified official dotfiles source, invoke the native PowerShell bootstrap, and propagate its result.
  - User story link: gives Windows operators one guided installation while preserving native ownership.
  - Depends on: Task 1.
  - Validate with: PowerShell parser plus focused fixture tests for accept, decline, non-interactive default, arguments, source failure, and delegated exit failure.
  - Notes: do not run a real dotfiles installation in shared-workspace tests.

- [ ] Task 3: Add native Unix opt-in and delegation.
  - File: `install-shipglows.sh`, and `cli/install.sh` only if the public bootstrap cannot own delegation cleanly.
  - Action: add interactive and explicit non-interactive opt-in, download without piping to a shell, invoke the official native Bash bootstrap, and propagate its result.
  - User story link: gives Linux operators the same guided outcome without replacing the dotfiles Bash engine.
  - Depends on: Task 1.
  - Validate with: `bash -n` plus fixture tests for accept, decline, root/non-root behavior, non-interactive default, source failure, and delegated exit failure.
  - Notes: keep Termux and WSL out of scope.

- [ ] Task 4: Protect ownership and standalone operation mechanically.
  - File: `tests/install/*`, `tests/windows/*`, and the dotfiles installer contract tests only when their public invocation contract changes.
  - Action: assert ShipGlows references only the official bootstrap/repository contract and contains no copied component IDs, package inventory, target paths, backup rules, or uninstall logic.
  - User story link: keeps future maintenance single-sourced.
  - Depends on: Tasks 2 and 3.
  - Validate with: focused static scans and standalone dotfiles Windows/Linux contracts.
  - Notes: tests must distinguish legitimate bootstrap metadata from duplicated installation behavior.

- [ ] Task 5: Align documentation and close with cross-repository proof.
  - File: ShipGlows README/install docs, technical context/code-doc map, and dotfiles docs only if impacted.
  - Action: document optional orchestration, independent installation, automation defaults, recovery, and ownership boundaries; run both repositories' proportional installer suites.
  - User story link: makes the two supported entry paths understandable and trustworthy.
  - Depends on: Tasks 2-4.
  - Validate with: mapped documentation checks, metadata lint, syntax checks, fixture suites, and `git diff --check` in both repositories.
  - Notes: public content remains a distinct approval and publication surface.

## Acceptance Criteria

- [ ] AC 1: Given an interactive supported ShipGlows installation, when the operator accepts dotfiles, then ShipGlows invokes the official native dotfiles bootstrap and reports its result.
- [ ] AC 2: Given the operator declines dotfiles, when ShipGlows completes, then no dotfiles source is downloaded or executed.
- [ ] AC 3: Given a non-interactive installation without explicit opt-in, when ShipGlows runs, then dotfiles are not installed.
- [ ] AC 4: Given explicit non-interactive opt-in, when delegation runs, then its repository/ref and native entrypoint are deterministic and testable.
- [ ] AC 5: Given source resolution, verification, or delegated installation fails, when ShipGlows reports completion, then it returns a non-success result for the requested optional step with actionable context.
- [ ] AC 6: Given Windows, when dotfiles are requested, then only the native PowerShell dotfiles path is used even if WSL exists.
- [ ] AC 7: Given native Linux, when dotfiles are requested, then only the official Bash dotfiles bootstrap is used; Termux remains excluded.
- [ ] AC 8: Given dotfiles are installed directly without ShipGlows, when their existing Windows/Linux contracts run, then standalone behavior remains supported.
- [ ] AC 9: Given the ShipGlows implementation diff, when ownership scans run, then no dotfiles component manifest, package inventory, config placement, backup, update, or uninstall logic has been copied.
- [ ] AC 10: Given documentation is reviewed, when an operator chooses an entry path, then optional orchestration and standalone installation are both described accurately.

## Test Strategy

- Unit: PowerShell and Bash helper-level fixtures for option resolution, source/ref validation, argument construction, and exit propagation.
- Integration: temporary fake official bootstraps record their received arguments and controlled exit codes; no real package or configuration installation.
- Manual: one clean disposable Windows profile and one clean disposable native Linux profile after automated contracts pass; never use the operator's active workstation as the first proof surface.

## Test Contract

### Surface

- Stack/surface: PowerShell and Bash installers.
- Primary proof mode: mixed.
- Proof order: parser/syntax -> unit fixtures -> integration fixtures -> standalone dotfiles contracts -> disposable-profile smoke.

### Manual checklist

- Needed: yes, only for final disposable-profile smoke.
- Checklist path: `shipglows_data/workflow/test-checklists/optional-dotfiles-orchestration.md`
- Required scenario coverage: Windows accept/decline; Linux accept/decline; non-interactive default-off; delegated failure; already-converged dotfiles.
- Exception with proof: if disposable hosts are unavailable, closure remains partial with CI as the named proof owner and target.

### Required evidence stack

- Automated / unit / integration checks: PowerShell parse, `bash -n`, focused Windows/Unix bootstrap fixtures, ShipGlows installer contracts, and dotfiles Windows/Linux contracts.
- Agent-run browser proof: none, because no browser behavior changes.
- Auth/session proof: none, because no authenticated provider is required for public repositories.
- Contract/integration proof: exact delegated entrypoint, repository/ref, arguments, default-off behavior, and exit propagation.
- Provider evidence: CI on Windows and native Linux after implementation is pushed.
- Device-native proof: disposable Windows and native Linux host smoke; WSL and Termux are explicitly excluded.

## Risks

- Security impact: yes; ShipGlows would retrieve and execute an external repository's installer, mitigated by deterministic source/ref resolution, verified temporary download, no shell pipe, and fail-closed behavior.
- Product/data/performance risk: medium; a partial combined installation could confuse operators, mitigated by distinct summaries, explicit ownership, and truthful recovery instructions.

## Execution Notes

- Read first: `CLAUDE.md`, `shipglows_data/technical/context.md`, `install-shipglows.ps1`, `install-shipglows.sh`, relevant installer tests, and the dotfiles `AGENT.md`, `CLAUDE.md`, manifest, and native bootstraps.
- Validate with: focused PowerShell/Bash parser and fixture suites, standalone dotfiles contracts, metadata lint, and `git diff --check` in both repositories.
- Stop conditions: unresolved public repository/ref policy; pressure to copy dotfiles behavior into ShipGlows; implicit automation opt-in; WSL/Termux expansion; destructive checkout handling; unverified external execution; or overlapping unrelated dirty files.

## Open Questions

- Readiness must select the canonical public dotfiles repository/ref policy and exact opt-in names while preserving the default-off invariant.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-31 17:20:16 UTC | sg-spec | GPT-5 Codex | Created the optional cross-platform dotfiles orchestration specification from the approved ownership model. | draft | /sg-ready Optional dotfiles orchestration |

## Current Chantier Flow

- `sg-spec`: done, draft spec created.
- `sg-ready`: not launched.
- `sg-start`: not launched.
- `sg-verify`: not launched.
- `sg-end`: not launched.
- `sg-ship`: not launched.

Next step: `/sg-ready Optional dotfiles orchestration`
