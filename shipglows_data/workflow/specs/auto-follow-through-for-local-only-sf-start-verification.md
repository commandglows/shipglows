---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-10"
created_at: "2026-06-10 19:34:59 UTC"
updated: "2026-06-10"
updated_at: "2026-06-10 20:04:03 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "workflow-lifecycle"
owner: "Diane"
user_story: "As a ShipGlows operator, I want sg-start to continue into verification when verification is local, safe, and non-destructive, so I do not have to manually relaunch an obvious command after an implementation that already passed local checks."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sg-start/SKILL.md"
  - "skills/sg-start/references/execution-workflow.md"
  - "skills/sg-build/SKILL.md"
  - "skills/sg-build/references/build-lifecycle-workflow.md"
  - "skills/references/master-workflow-lifecycle.md"
  - "skills/references/reporting-contract.md"
  - "skills/references/spec-driven-development-discipline.md"
  - "shipglows_data/workflow/conversation-audits/2026-06-10-sg-start-stopped-before-verify.md"
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: draft
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Conversation audit 2026-06-10: sg-start stopped after local implementation and routed to /sg-verify, creating operator friction."
  - "The same run completed local validation: plugin audit, skill budget audit, metadata lint, focused rg checks, git diff check, and skill sync check."
  - "sg-start currently defines implemented as complete within sg-start scope while verification can remain pending."
  - "sg-build currently owns full start -> verify -> end -> ship orchestration."
  - "ShipGlows Core plugin audit after the conversation audit reported 66 skills and 0 findings, so this is a lifecycle contract gap, not a mechanical skill-quality finding."
next_step: "/sg-ship Auto-follow-through for local-only sg-start verification"
---

# Spec: Auto-follow-through for local-only sg-start verification

## Title

Auto-follow-through for local-only sg-start verification

## Status

ready

## User Story

As a ShipGlows operator, I want `sg-start` to continue into verification when verification is local, safe, and non-destructive, so I do not have to manually relaunch an obvious command after an implementation that already passed local checks.

## Minimal Behavior Contract

When `sg-start` finishes implementation for a unique spec and the only remaining lifecycle work is local, tool-backed, non-destructive verification that does not require preview, production, auth/browser proof, Sentry, device testing, manual QA, secret access, a user decision, commit, push, or any external side effect, the agent must run the relevant local verification itself or explicitly explain why verification is outside the current scope. If local verification fails, the run must stay inside the lifecycle with `partial`, `blocked`, or a concrete correction route. The easiest edge case to miss is turning `sg-start` into a full orchestrator: auto-follow-through must stay limited to safe local verification and must never include `sg-end`, `sg-ship`, production, preview, manual tests, or external actions.

## Success Behavior

- Preconditions: one unique spec is in scope, `sg-start` completed the planned edits and local checks, and every auto-follow-through criterion is true.
- Trigger: `sg-start` reaches its final phase and the next command would only be `/sg-verify <scope>`.
- Operator result: the final report says whether local verification was run or why auto-follow-through was skipped.
- System effect: the chantier trace does not leave `sg-verify` pending when the agent could safely run it in the same turn; out-of-scope proof gaps still route to the correct owner.
- Proof of success: ShipGlows checks prove that `sg-start`, `sg-build`, and lifecycle references expose the auto-follow-through criteria, stop conditions, scope boundaries, and reporting labels.

## Error Behavior

- If verification requires preview, production, auth/browser proof, Sentry, device testing, manual QA, secret access, a user decision, commit, push, or an external environment, `sg-start` must not auto-continue; it must route to the exact owner with scenario and target/environment when applicable.
- If `sg-start` local checks fail, auto-verify must not hide the failure; the run must continue to a correction when possible or report `partial`/`blocked`.
- If the spec or chantier is ambiguous, verification must not be guessed; route to `/sg-ready`, `/sg-spec`, or a targeted user question based on the gap.
- Must never happen: auto-ship, auto-commit, auto-push, destructive tests, secret exposure, or making `sg-start` equivalent to `sg-build`.

## Problem

A conversation audit found operator friction: after a successful local implementation of `Residual ShipGlows Skill Body Risk Cleanup`, the agent ran local validation and then stopped with `Next step: /sg-verify...`. That behavior matched the current `sg-start` boundary, but it frustrated the operator because the remaining verification was local and non-destructive.

The issue is not that the agent skipped all testing. It did test locally. The issue is that current contracts do not say when `sg-start` may continue into `sg-verify`, or how to distinguish that bounded continuation from the full lifecycle orchestration owned by `sg-build`.

## Solution

Add a bounded local auto-follow-through contract:

- `sg-start` remains an implementation skill.
- `sg-build` remains the full lifecycle orchestrator.
- `sg-start` may run local verification only when every safety and scope criterion is true.
- Reports must make either `auto-verify: run` or `auto-verify: skipped` visible with an actionable reason.
- Lifecycle references must name stop conditions and out-of-scope proof owners.

## Scope In

- Clarify `skills/sg-start/SKILL.md` around local auto-follow-through.
- Update `skills/sg-start/references/execution-workflow.md` with criteria, stop conditions, and reporting behavior.
- Adjust `skills/sg-build/SKILL.md` or `skills/sg-build/references/build-lifecycle-workflow.md` to keep the boundary clear between bounded `sg-start` auto-verify and full orchestration.
- Update `skills/references/master-workflow-lifecycle.md` only if shared lifecycle doctrine would otherwise contradict the new rule.
- Add focused `rg` checks and pressure scenarios for allowed and forbidden continuation.
- Update technical docs only if the ShipGlows runtime/lifecycle map documents these transitions at this level.

## Scope Out

- Automatically running `sg-end`, `sg-ship`, commits, pushes, previews, production checks, browser/auth proof, Sentry reads, APK/device tests, or manual QA.
- Changing skill names, invocation keys, or the central role of `sg-build`.
- Editing the ShipGlows Core plugin audit script.
- Resolving existing unrelated chantiers or relaunching all pending specs.
- Making `sg-start` responsible for proof surfaces it cannot validate locally.

## Constraints

- Keep `sg-start` as implementation, not as master orchestration.
- Keep `sg-build` as the `start -> verify -> end -> ship` orchestrator.
- Follow `spec-driven-development-discipline.md`: every missing proof route must name owner, scenario, and target/environment.
- Auto-follow-through applies only to local, non-destructive, tool-backed validation.
- Stop conditions must remain visible in top-level `SKILL.md`; detailed matrices may live in references.
- No new behavior may weaken preview, production, auth, Sentry, manual, device, secret, commit, push, or external-side-effect gates.

## Test Contract

- Surface profile: Markdown skill contracts and ShipGlows lifecycle references.
- Automated proof available: metadata lint, skill budget audit, ShipGlows Core plugin audit, focused `rg` checks, sync check, and diff check.
- Non-automated proof required: scenario-first review of allowed and forbidden follow-through cases.
- Proof path: `scenario-first` with mechanical checks.
- Manual checklist path: not required.
- Fresh external docs: not needed; this is local ShipGlows instruction architecture.

## Dependencies

- `skills/references/decision-quality-contract.md` for bounded professional behavior.
- `skills/references/spec-driven-development-discipline.md` for proof owner routing.
- `skills/references/reporting-contract.md` for concise visible reporting.
- `skills/references/chantier-tracking.md` for lifecycle trace semantics.
- `skills/references/skill-instruction-layering.md` for what stays local versus reference.
- Conversation audit: `shipglows_data/workflow/conversation-audits/2026-06-10-sg-start-stopped-before-verify.md`.

## Invariants

- `sg-start` still uses `implemented` for completed local implementation scope.
- `sg-start` still reports `partial` or `blocked` when local implementation or local verification fails in a way that prevents continuation.
- `sg-build` remains the only skill expected to continue through verification, closure, and ship as a master lifecycle.
- Hosted, production, provider, browser, auth, manual, and device proof gaps must name a concrete owner route instead of being hidden by auto-follow-through.
- No secrets, private payloads, external side effects, commits, pushes, or deployment actions are introduced by verification.

## Links & Consequences

- Better default follow-through can reduce operator friction after local-only work.
- Too broad an implementation could blur skill ownership and make `sg-start` unsafe.
- Reporting changes affect operator trust: concise reports must say whether verification actually ran or why it was skipped.
- Verification semantics affect `sg-verify`, `sg-build`, `sg-end`, and `sg-ship` flow expectations.

## Documentation Coherence

- Internal docs: update `shipglows_data/technical/skill-runtime-and-lifecycle.md` only if it currently documents lifecycle boundaries at this level.
- Public docs/site: no impact expected unless skill pages expose lifecycle promises.
- Changelog: update only during ship/closure.
- Help catalog: no impact unless skill descriptions change.

## Edge Cases

- A local check passes but `sg-verify` would require fresh context or a broader adversarial review: skip auto-follow-through and route explicitly.
- A spec asks for manual QA: do not auto-run `sg-test`; route to `sg-test` with scenario.
- A project is `vercel-preview-push` or `hybrid`: local checks may run, but preview/browser proof must follow `sg-ship -> sg-prod`.
- Dirty unrelated files exist: auto-follow-through may run read-only verification but must not stage, commit, push, ship, or claim dirty-worktree cleanliness.
- The user explicitly asked only for implementation, not verify: auto-follow-through may still run safe local verification unless the user says not to.
- The user invoked `sg-build`: full orchestration remains under `sg-build`, not this limited path.

## Implementation Tasks

- [x] Task 1: Define auto-follow-through criteria in `sg-start`.
  - File: `skills/sg-start/SKILL.md`
  - Action: Add a concise local section stating when `sg-start` may run local `sg-verify` automatically and when it must not.
  - User story link: prevents manual relaunch when verification is safe and obvious.
  - Depends on: none.
  - Validate with: `rg -n "auto-follow-through|auto-verify|sg-verify|preview|production|manual|Sentry|device" skills/sg-start/SKILL.md`
  - Notes: Keep the role boundary clear.

- [x] Task 2: Add detailed workflow and stop conditions.
  - File: `skills/sg-start/references/execution-workflow.md`
  - Action: Add criteria matrix, run/skipped reporting, failure handling, and owner routing for non-local proof.
  - User story link: gives future agents an executable contract.
  - Depends on: Task 1.
  - Validate with: `rg -n "auto-follow-through|auto-verify: run|auto-verify: skipped|owner_skill|target_or_environment" skills/sg-start/references/execution-workflow.md`
  - Notes: Keep examples out of the activation body.

- [x] Task 3: Preserve `sg-build` orchestration boundary.
  - File: `skills/sg-build/SKILL.md`, `skills/sg-build/references/build-lifecycle-workflow.md`
  - Action: Clarify that `sg-build` remains the full lifecycle owner; `sg-start` auto-verify is a bounded local exception, not end/ship orchestration.
  - User story link: prevents future ambiguity about which skill owns full continuation.
  - Depends on: Task 1.
  - Validate with: `rg -n "sg-start|auto-verify|full lifecycle|sg-end|sg-ship" skills/sg-build/SKILL.md skills/sg-build/references/build-lifecycle-workflow.md`
  - Notes: Do not make `sg-build` noisier in user mode.

- [x] Task 4: Update shared lifecycle doctrine only if needed.
  - File: `skills/references/master-workflow-lifecycle.md`
  - Action: Add a short shared note if current lifecycle doctrine would otherwise contradict auto-verify.
  - User story link: keeps downstream lifecycle skills coherent.
  - Depends on: Tasks 1-3.
  - Validate with: `rg -n "auto-verify|sg-start|sg-verify|local verification" skills/references/master-workflow-lifecycle.md`
  - Notes: Skip if local skill docs are sufficient.

- [x] Task 5: Validate skill quality and scenario pressure cases.
  - File: `skills/sg-start/SKILL.md`, `skills/sg-start/references/execution-workflow.md`, `skills/sg-build/SKILL.md`, `skills/sg-build/references/build-lifecycle-workflow.md`
  - Action: Run mechanical checks and review scenarios: local-only allowed, preview denied, manual QA denied, dirty unrelated files read-only, failed verification reroutes.
  - User story link: proves the new behavior is safer and clearer.
  - Depends on: Tasks 1-4.
  - Validate with: `python3 ~/plugins/shipglows-core/scripts/audit_shipglows_skills.py`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `python3 tools/shipglows_metadata_lint.py <changed-frontmatter-files> shipglows_data/workflow/specs/auto-follow-through-for-local-only-sg-start-verification.md`; `tools/shipglows_sync_skills.sh --check --all`; `git diff --check`
  - Notes: No app/browser tests required.

## Acceptance Criteria

- [x] AC 1: Given `sg-start` completes local implementation and all auto-follow-through criteria are true, when its final phase runs, then it runs local verification or records `auto-verify: run` with validation evidence.
- [x] AC 2: Given verification requires preview, production, auth/browser, Sentry, manual QA, device proof, secret access, commit, or push, when `sg-start` finishes implementation, then it records `auto-verify: skipped` with exact owner route and does not run that proof.
- [x] AC 3: Given local verification fails, when `sg-start` reports, then it does not claim lifecycle success; it reports `partial` or a concrete correction route.
- [x] AC 4: Given the user invokes `sg-build`, when implementation passes verification, then `sg-build` remains responsible for closure and ship orchestration.
- [x] AC 5: Given unrelated dirty files exist, when auto-verify is local/read-only, then no staging, commit, push, ship, or dirty-scope claim occurs.
- [x] AC 6: Given a future agent reads only top-level `sg-start`, then it can identify the auto-follow-through rule and the forbidden proof surfaces without opening long examples.
- [x] AC 7: Given skill audits run after implementation, then ShipGlows Core plugin audit and skill budget audit report no new hard/review/style/body-risk findings.
- [x] AC 8: Given the implementation changes frontmatter docs or references, then metadata lint passes for changed artifacts.

## Test Strategy

- Scenario-first proof:
  - ALLOWED-LOCAL: local skill-governance verification after all checks pass.
  - DENY-PREVIEW: preview-push/browser proof must route to `sg-ship -> sg-prod`.
  - DENY-MANUAL: manual QA must route to `sg-test`, not auto-run.
  - FAIL-VERIFY: local verification failure reports `partial` or correction route.
  - DIRTY-READONLY: unrelated dirty files do not block read-only verification but block ship claims.
- Mechanical checks:
  - focused `rg` for criteria and stop conditions
  - metadata lint
  - skill budget audit
  - ShipGlows Core plugin audit
  - sync check
  - `git diff --check`

## Risks

- Medium workflow risk: too much automation could hide proof gaps.
- Medium trust risk: too little automation keeps frustrating the operator after safe local work.
- Low security risk: no auth/data behavior should change, but proof routing must avoid secrets and external targets.
- Documentation risk: lifecycle docs can become inconsistent if only one skill is updated.

## Execution Notes

- Read first:
  - `skills/sg-start/SKILL.md`
  - `skills/sg-start/references/execution-workflow.md`
  - `skills/sg-build/SKILL.md`
  - `skills/sg-build/references/build-lifecycle-workflow.md`
  - `skills/references/spec-driven-development-discipline.md`
  - `skills/references/reporting-contract.md`
- Proof path: `scenario-first`.
- Fresh external docs verdict: `fresh-docs not needed`.
- Stop and reroute if implementation would require changing `sg-verify` behavior materially; that would expand scope.
- Do not edit public docs unless user-facing skill promise text changes.

## Open Questions

None. The intended policy is bounded: auto-continue only for safe local verification, never for external proof or ship actions.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-10 19:34:59 UTC | sg-spec | GPT-5 Codex | Created spec from conversation audit finding about sg-start stopping before local verification follow-through. | draft saved | /sg-ready Auto-follow-through for local-only sg-start verification |
| 2026-06-10 19:42:23 UTC | sg-ready | GPT-5 Codex | Validated structure, user-story fit, bounded scope, language doctrine, security posture, adversarial cases, and proof path; corrected internal-contract language before readiness. | ready | /sg-start Auto-follow-through for local-only sg-start verification |
| 2026-06-10 19:48:10 UTC | sg-start | GPT-5 Codex + gpt-5.3-codex-spark subagent | Implemented bounded sg-start local auto-verify contract across sg-start, sg-build, shared lifecycle, and technical docs; local validation passed. | implemented; auto-verify: run | /sg-end Auto-follow-through for local-only sg-start verification |
| 2026-06-10 20:04:03 UTC | sg-end | GPT-5 Codex | Closed bookkeeping after local auto-verification, updated task tracking and changelog prep, and left commit/push to sg-ship. | closed | /sg-ship Auto-follow-through for local-only sg-start verification |

## Current Chantier Flow

- sg-spec: draft saved.
- sg-ready: ready.
- sg-start: implemented.
- sg-verify: local auto-verify completed by sg-start.
- sg-end: closed.
- sg-ship: not launched.
- Next step: `/sg-ship Auto-follow-through for local-only sg-start verification`.
