---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-25"
created_at: "2026-08-25 17:01:25 UTC"
updated: "2026-08-25"
updated_at: "2026-08-25 17:48:00 UTC"
status: ready
source_skill: sg-planning
source_model: GPT-5 Codex
scope: git-github-runtime-hygiene-and-ci
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
user_story: "As the sole ShipGlows maintainer, I want one current developer root, enforced repository checks, preserved unfinished work, and a minimal Git topology so agents can work safely without stale doctrine or silent untested merges."
linked_systems:
  - .github/workflows/windows-installer-validation.yml
  - skills/references/canonical-paths.md
  - tools/shipglows_sync_skills.ps1
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/installer-and-user-scope.md
  - shipglows_data/technical/operator-guides/windows-devserver.md
  - shipglows_data/workflow/TEST_LOG.md
  - GitHub repository rulesets
  - Windows user environment
depends_on: []
supersedes: []
evidence:
  - "Audit 2026-08-25: origin/main and shipglows-development-runtime match bcdf83d, while the Windows user SHIPGLOWS_ROOT still selects the clean but 31-commit-stale windows-global-toolbox worktree."
  - "Audit 2026-08-25: the latest main commit and PR 33 have zero GitHub check runs because the only workflow excludes cli/windows/** and tests/windows/**."
  - "Audit 2026-08-25: main blocks deletion and non-fast-forward updates but requires neither pull requests nor successful checks."
  - "Audit 2026-08-25: four remote branches are fully merged; d18e779 and PR 29 retain unique work; the local UTF-8 branch is not proven disposable by ancestry."
next_step: "Start staged implementation with fresh evidence revalidation and explicit mutation authority."
---

# Git, GitHub, runtime hygiene, and CI trust

## Title

Make ShipGlows development use one current source of truth, require relevant automated proof, preserve unfinished work, and retire only proven-obsolete Git artifacts.

## Status

Ready. The implementation contract passed substantive readiness review; implementation authority remains required.

## User Story

As the sole ShipGlows maintainer, I want agents and local tools to load the current repository doctrine, GitHub to test every protected change that can affect Windows installation or shared contracts, unfinished commits to remain recoverable, and merged branches/worktrees to stop accumulating without risking data loss.

## Minimal Behavior Contract

When ShipGlows development starts on this machine, a fresh process resolves the linked development runtime at the current `origin/main`, GitHub exposes one terminal required repository gate for every pull request into `main`, Windows-affecting changes run the complete Windows contract, and Git cleanup removes only artifacts mechanically proven merged and clean. A stale root, absent required check, failing relevant suite, unique commit, dirty worktree, ambiguous branch purpose, or unavailable remote proof stops the affected phase without blocking independent safe phases. The easiest missed edge case is a commit that is functionally superseded but still unique by SHA: it must be compared and recorded before deletion, never inferred disposable from similar messages.

## Success Behavior

- A new PowerShell/Codex process resolves `SHIPGLOWS_ROOT` and the linked channel to `shipglows-development-runtime`, whose HEAD matches refreshed `origin/main`.
- Runtime skill links pass the canonical all-catalogue check against that same root; installed runtime and linked development source remain distinct and truthful.
- Every PR into `main` receives one stable repository gate. Changes under Windows installer, DevServer, runtime, or test surfaces run `bash tests/windows/devserver-contract.sh`; unrelated changes receive a truthful no-Windows-impact result rather than no check.
- The `main` ruleset blocks deletion and force-push, requires the stable gate and pull-request integration, requires no second human review for the sole maintainer, and retains an explicit auditable emergency recovery path.
- `d18e779` and the three commits in PR 29 are either integrated through reviewed branches with passing proof or explicitly retained with owner, reason, and review date.
- Fully merged branches/worktrees are removed only after refreshed remote containment, clean-state, process-use, and unique-commit checks pass under a separate destructive approval.
- Final Git/GitHub/runtime audit reports one current canonical root, no lost commits, no unintended dirty scope, and an explained disposition for every retained artifact.

## Error Behavior

- Root mismatch, missing skills, invalid linked-channel JSON, a runtime-link collision, or a development worktree behind `origin/main` blocks runtime activation and reports the exact conflicting source.
- The required GitHub gate fails when workflow selection cannot classify changed paths, when a relevant test is skipped, when the complete Windows contract fails, or when the workflow cannot fetch the tested SHA.
- Ruleset mutation stops before enforcement if the expected check name has not completed successfully on a real pull request or if the sole maintainer recovery path is unproven.
- Salvage stops on conflicts, failing tests, unclear product intent, secrets, or overlap with newer behavior; it never rewrites or discards the original branch while evidence is incomplete.
- Cleanup stops on any dirty/untracked file, unique commit, open PR, active process, protection, unresolved ownership, remote ambiguity, or failed containment proof.

## Problem

The machine currently has two competing developer-root declarations. The linked-channel file names the current development runtime, but the higher-priority Windows user variable still names an older merged worktree. This makes agent behavior depend on launch context and has already caused stale skill contracts to be loaded. GitHub protects history from force and deletion but does not require a pull request or successful checks. Its only workflow watches two bootstrap files, so PR 33 changed the actual Windows DevServer installer and regression test without receiving CI. Six worktrees, six remote branches, a stale local `main`, one unique unpublished CLI commit, one three-commit draft PR, and one ancestry-unique local UTF-8 branch create avoidable ambiguity.

## Solution

Execute five ordered, independently stoppable phases: establish the current linked runtime as the sole developer source; introduce an always-reported repository gate with path-aware Windows proof; enable a solo-maintainer ruleset only after the gate succeeds on a real PR; salvage unique work without rewriting its source; then clean only fully proven temporary artifacts. Keep remote publication, provider configuration, integration, and each destructive cleanup batch separately visible and approval-gated.

## Scope In

- Windows user `SHIPGLOWS_ROOT`, linked development-channel truth, current development worktree, and Codex/agent skill-link verification.
- GitHub Actions triggers and jobs needed for a stable required repository gate and complete Windows contract coverage.
- Repository ruleset behavior for `main`: pull-request integration, successful check, force/deletion protection, sole-maintainer review posture, and emergency recovery.
- Read-only and test-backed disposition of PR 29, `d18e779`, the local UTF-8 branch, merged remote branches, related worktrees, and stale local refs.
- Directly mapped technical/operator documentation, durable test evidence, and final Git/GitHub/runtime audit.

## Scope Out

- Product features, public marketing copy, dependency upgrades, provider authentication, application deployment, release tags, and unrelated repository cleanup.
- Automatic deletion of any branch/worktree during runtime, CI, ruleset, or salvage phases.
- Force push, history rewriting, squash/rebase of existing remote work, secret or credential changes, and deletion of the installed runtime fallback.
- Requiring an additional human reviewer or opening the repository to contributors.

## Constraints

- Preserve all unrelated and pre-existing work. Never stash, reset, force, or rewrite an existing branch.
- Use fresh worktrees from refreshed `origin/main` for salvage and implementation; originals remain immutable backups until their replacement is merged and proven.
- Keep one stable required GitHub check name that always terminates; path selection may skip expensive Windows execution only with an explicit successful no-impact result.
- Windows-relevant paths include at least `install-shipglows.ps1`, `local/install_local.ps1`, `cli/windows/**`, `tests/windows/**`, and the owning workflow. Changes to path ownership update the code-docs map and gate together.
- Do not enforce a required check or pull-request rule until a real PR proves the exact check identity and the recovery procedure.
- No cleanup authority is implied by this spec, a successful merge, or a clean audit. Every destructive target requires a fresh exact plan and approval.
- Remote branch deletion is last; preserve local or remote recovery until target containment and final proof are terminal.

## Test Contract

The authoritative proof surfaces are Windows user/process environment observation, canonical runtime-link checks, local Git topology, GitHub API state, a real pull-request workflow run, the complete Windows contract, focused salvage tests, and a final remote-containment audit. Runtime repair uses a fresh child PowerShell process and `tools/shipglows_sync_skills.ps1 -Mode check -All -Runtime codex -Catalog all`. CI changes run workflow syntax/metadata checks, PowerShell 5.1 parsing where applicable, and `bash tests/windows/devserver-contract.sh` locally before publication; the published PR must show the stable required gate at the exact head SHA. Ruleset proof reads back the active rules and verifies a normal PR path without attempting force-push or deletion. Salvage uses target-specific focused tests plus the repository suite required by the touched surfaces. Cleanup proof is read-only until its separate approved phase. No browser, auth, production, or deployment proof applies.

## Dependencies

- Current `origin/main` and a clean `shipglows-development-runtime` worktree.
- Git, GitHub CLI authentication with repository admin permission, PowerShell 5.1/Core, Git Bash, Python/uv, and existing ShipGlows test tooling.
- Existing canonical-path, mutation-approval, temporary-artifact lifecycle, code-docs mapping, Windows DevServer, and test contracts.
- GitHub Actions and repository rulesets availability. Provider mutations require explicit authority at their phase.

## Invariants

- The Windows user variable and linked-channel JSON identify the same valid absolute developer root; no nearby checkout or filename coincidence can win.
- The linked development runtime is updateable by fast-forward and never replaces or mutates the installed runtime fallback implicitly.
- Installation, configuration, discovery, activation, callability, CI success, merge, remote persistence, and deployment remain distinct states.
- A passing lightweight selector cannot substitute for a required Windows suite when a Windows-owned path changed.
- `main` never permits deletion or non-fast-forward updates. Required checks never create a permanent lockout for the sole maintainer.
- Unique work is preserved by content and history evidence, not commit-message similarity. Clean merge ancestry alone never proves a worktree unused.
- Cleanup is sequential, recoverable as long as practical, and excludes shared dependency stores, current runtime roots, open-PR branches, and unrelated directories.

## Links & Consequences

Changing the developer root affects every ShipGlows skill, CLI helper, Codex session, and runtime diagnostic on this machine. Changing CI path ownership affects Windows installer, DevServer, mobile/toolbox, archive, and workflow contributors. Enforcing the ruleset changes every future integration into `main`; its gate name and recovery policy become repository governance. Salvaging `d18e779` affects CLI SaaS capability reporting and its cloud-preview tests. PR 29 affects conversation handoff contracts and context-quality proof. Cleanup changes local interruption recovery and remote branch discoverability, so documentation and final receipts must distinguish merged, retained, and removed artifacts.

## Documentation Coherence

Update the technical code-docs map for the CI-owned Windows surface, runtime CLI and installer/operator guidance for linked-root precedence, the relevant bug/test log when a reproduced defect is closed, and this spec's run history/flow. Public installer copy changes only if verified user-visible setup behavior changes; branch hygiene and CI governance alone have no public editorial impact.

## Edge Cases

- **Z — Zero:** no Windows-owned path changed; the stable gate succeeds with an explicit no-impact receipt and runs no expensive Windows suite.
- **O — One:** one relevant path changes; the complete Windows contract runs once at the PR head and its result owns the gate.
- **M — Many:** mixed docs/core/Windows changes still produce one stable gate and all applicable proof, without duplicate runs hiding failures.
- **B — Boundary:** `cli/windows/**` and `tests/windows/**` are included even when neither bootstrap file changes.
- **I — Interface:** user environment, linked-channel JSON, junction targets, GitHub check name, and ruleset required-check identifier agree exactly.
- **E — Error:** missing Git Bash, invalid YAML, failed path selection, stale SHA, failed Windows test, or unavailable GitHub API produces a failing gate or blocked phase, never success-by-absence.
- **S — Security:** workflow permissions remain least-privileged, untrusted PR code receives no write token or secrets, ruleset changes cannot weaken force/deletion protection, and logs redact credentials and private payloads.
- A merged branch with an active process remains retained.
- A local branch with a patch already represented differently on `main` receives a recorded content-equivalence decision before deletion.
- An old draft PR that is mergeable but untested remains open or is replaced only after its three commits are preserved on a reviewed branch.

## Implementation Tasks

1. **Freeze and revalidate evidence.** Refresh remote refs read-only; record `main`, open PRs, remote branches, worktrees, dirty state, unique commits, ruleset, workflows, check runs, current user/process root, linked-channel file, and runtime-link targets. Validate with exact SHA/topology receipts. Stop on concurrent changes that alter ownership or scope.
2. **Repair canonical developer-root convergence.** Fast-forward the dedicated development runtime if needed, set the Windows user `SHIPGLOWS_ROOT` to its exact path, keep linked-channel JSON identical, open a fresh child process, and verify canonical skill/tool resolution. Run all-catalogue runtime-link check and repair only managed junctions if the check proves drift. Do not alter installed fallback, credentials, system environment, or unrelated links.
3. **Implement the stable repository gate.** Extend or replace the current workflow so every PR and `main` push reports one stable terminal gate, classifies changed paths deterministically, and runs the complete Windows contract for every owned Windows path. Preserve read-only token permissions, SHA fidelity, failure propagation, cleanup, and local parity. Validate locally and on a published test PR before ruleset mutation.
4. **Enable proportionate `main` governance.** After the exact gate name succeeds, update the repository ruleset to retain deletion/non-fast-forward blocks, require pull-request integration and the stable successful gate, require zero additional approvals for the sole maintainer, dismiss no evidence silently, and configure/document a narrow auditable admin recovery path. Read back and test normal integration; rollback the new rules if legitimate PR integration is blocked.
5. **Salvage `d18e779`.** Create a fresh branch/worktree from current `main`, reapply the CLI SaaS capability outcome without rewriting the original branch, reconcile current CLI architecture, run `tests/cli/cloud-preview-catalog.sh` and all affected CLI/contracts, then publish and integrate through a dedicated PR only after proof. Retain the original until remote containment is exact.
6. **Resolve PR 29.** Re-evaluate its product/contract intent against current `main`, preserve all three commits, build a current integration result without force-pushing or deleting the original, run context-quality and full affected contract proof, then either update and merge the draft or close it only after an equivalent replacement PR is merged.
7. **Classify every remaining branch/worktree.** Prove containment and clean/process state for icon-system, Clerk toolbox, global toolbox, quality repairs, UTF-8 tests, stale local `main`, and any newly created artifacts. Assign `remove`, `retain-explicit`, or `blocked` with evidence, owner, reason, and review date.
8. **Execute cleanup under fresh destructive approval.** Remove only exact approved worktrees from a surviving canonical worktree, then safe local branches, then remote branches. Never force branch deletion; stop on residue, locks, unique commits, open PRs, or unexpected files. Preserve a final list of retained artifacts.
9. **Close with end-to-end proof.** Re-run Git/GitHub/runtime audit, complete Windows gate proof, relevant Python contracts, metadata, branch/ruleset/check APIs, and runtime-link checks. Update mapped documentation and this lifecycle trace; report local, remote, CI, runtime, and cleanup truth separately.

## Acceptance Criteria

1. Fresh processes resolve one exact current developer root and no higher-priority stale declaration remains.
2. Development-runtime HEAD equals refreshed `origin/main`; canonical required skills and tools exist beneath it; managed Codex skill links are valid.
3. Every PR into `main` receives the stable repository gate at its exact head SHA.
4. Windows-owned changes under all declared paths run and pass `bash tests/windows/devserver-contract.sh`; a deliberate failing fixture proves failure propagation before removal from the test branch.
5. `main` ruleset requires pull-request integration and the stable gate, preserves force/deletion protection, requires no second reviewer, and has a tested/read-back recovery posture.
6. No secret, write token, privileged event, mutable third-party action, or untrusted external instruction is introduced by CI.
7. `d18e779` has an explicit integrated-or-retained disposition backed by focused and affected-suite proof; its original branch is preserved until containment.
8. PR 29's three unique commits have an explicit merged, replaced, or retained disposition; no unique work is silently dropped.
9. Every initial branch/worktree has a recorded terminal disposition. Removed artifacts satisfy refreshed containment, clean-state, no-process, no-open-PR, and no-unique-work proof.
10. No force push, history rewrite, installed-runtime deletion, deployment, credential mutation, or unrelated-file change occurs.
11. Mapped technical documentation, TEST_LOG evidence, and this spec flow match the final behavior.
12. Final audit reports current `main`, clean canonical worktree, active ruleset/check identity, open PRs, retained branches/worktrees, and zero unexplained unique commits.

## Test Strategy

Use regression-first proof for each cause: reproduce stale-root precedence in a child process, prove the current workflow omits a Windows-owned change, and retain unique-commit/topology receipts before implementation. Validate phases independently, then together. Runtime tests cover valid, stale, missing, malformed, and conflicting roots plus managed-link collision. CI tests cover zero/one/many/mixed path changes, PR and push events, exact SHA checkout, expected failure, least privilege, and cleanup. Ruleset proof is read-back plus one normal PR integration path; destructive behavior is never tested against `main`. Salvage uses focused CLI/context tests and the full affected contract suite. Cleanup uses read-only preflight and post-removal topology checks. The final suite never converts skipped, unavailable, or provider-unknown evidence into success.

## Risks

- **Agent split-brain:** changing only JSON leaves the higher-priority user variable stale. Mitigate with exact dual-source update and child-process proof.
- **CI blind spot:** incomplete paths or selector errors can recreate success-by-absence. Mitigate with an always-terminal gate, boundary fixtures, and required-check enforcement only after real PR proof.
- **Maintainer lockout:** a required check or PR rule can block the sole maintainer. Mitigate with staged activation, exact check-name proof, narrow admin recovery, read-back, and rollback instructions.
- **Action abuse or secret exposure:** PR workflows execute repository code. Keep `pull_request`, read-only permissions, no secrets/write tokens, pinned maintained actions, and redacted logs.
- **Lost unique work:** ancestry and patch equivalence can disagree. Preserve originals, compare content, test replacements, and delete only after refreshed remote containment.
- **Concurrent Git activity:** another agent may advance `main` or touch a worktree. Revalidate immediately before every mutation and stop on drift.
- **Cleanup overreach:** worktree directories may contain ignored residue or active locks. Inspect exact targets and process use; never recurse outside approved paths or shared stores.
- **Workflow cost:** running the full Windows suite on every change is wasteful. The stable gate skips it only from deterministic no-impact classification while remaining visible and required.

## Execution Notes

Implementation classification: `infrastructure · shared/domain · documentation`. Reuse Git/GitHub, the existing Windows contract runner, canonical-path doctrine, runtime-sync helper, and repository rulesets; add no dependency unless it replaces a proven gap. CI owns deterministic selection, least privilege, explicit errors, exact SHA proof, bounded runtime, and cleanup. Runtime mutation is user-scope only and reversible to the recorded previous value. Salvage and cleanup run sequentially. No UI, application backend, auth, tenant, billing, product data, or deployment surface applies.

Implementation Excellence Gate: infrastructure configuration must be reproducible, least-privileged, observable, rollback-safe, and free of embedded secrets; shared logic remains deterministic and behavior-focused; documentation records source-of-truth and operator recovery. Clean Code Gate applies to workflow scripts and tests: intent-revealing names, cohesive selection/gate responsibility, explicit failure, no duplicated path ownership without a canonical map, no debug residue, and focused regression proof.

OWASP Security Gate: applicable areas are A01 Broken Access Control, A02 Security Misconfiguration, A03 Software Supply Chain Failures, A05 Injection, A09 Security Logging and Alerting Failures, and ASVS configuration/build integrity. Proof requires read-only default permissions, no untrusted secret access, safe argument/path handling, maintained pinned actions, exact checkout SHA, failure propagation, redacted logs, and ruleset read-back. This is a scoped CI/repository-control gate, not a general security certification.

## Open Questions

None for spec authoring. The professional default is pull-request integration with one required automated gate and zero mandatory additional reviewers for a sole maintainer. Provider mutations, publication, integration, and destructive cleanup remain separately approval-gated at execution time.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-25 | sg-planning | GPT-5 Codex | Consolidated the Git/GitHub/runtime audit into one staged durable implementation contract. | draft | Run readiness review. |
| 2026-08-25 | 101-sg-ready | GPT-5 Codex | Reviewed user-story fit, execution autonomy, proof, linked consequences, stale-state handling, GitHub governance, and scoped OWASP risks against current local and remote evidence. | ready | Start staged implementation under explicit mutation authority. |
| 2026-08-25 | 102-sg-start | GPT-5 Codex | Converged the Windows user developer root and all 68 Codex skill links, then implemented the stable path-aware repository gate and its focused regression contract. | in progress | Publish the CI milestone and prove the exact check on a real pull request before changing repository rules. |

## Current Chantier Flow

- specification: ready
- readiness: ready
- implementation: in progress
- verification: pending
- closure: pending
- delivery: pending
