---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-18"
created_at: "2026-07-18 08:25:32 UTC"
updated: "2026-07-18"
updated_at: "2026-07-18 08:46:11 UTC"
status: ready
source_skill: 900-shipglows-core
source_model: "GPT-5 Codex"
scope: unfinished-chantier-user-choice-contract
owner: Diane
user_story: "As a ShipGlows operator, I receive clear numbered choices whenever a chantier remains open, so I can steer its outcome without being asked to launch or understand internal skills."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/final-report-timestamp.md
  - skills/references/chantier-tracking.md
  - skills/references/question-contract.md
  - skills/references/master-delegation-semantics.md
  - skills/001-sg-build/references/build-lifecycle-workflow.md
  - skills/100-sg-spec/references/spec-creation-workflow.md
  - skills/101-sg-ready/references/readiness-review-playbook.md
  - skills/003-sg-bug/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/005-sg-ship/SKILL.md
  - skills/006-sg-design/references/design-proof-and-reporting.md
  - skills/104-sg-end/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - skills/600-sg-local-cloud-sync/SKILL.md
  - tools/test_reporting_contract.py
depends_on:
  - artifact: skills/references/reporting-contract.md
    artifact_version: "1.10.0"
    required_status: active
  - artifact: skills/references/question-contract.md
    artifact_version: "1.9.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-07-18: every unfinished chantier message must offer operator-visible options; agents launch internal skills in background."
  - "The existing reporting contract forbids manual internal next steps but does not require an operator-visible choice block for an open chantier."
  - "The excellence pass found legacy user-report templates that still exposed commands, paths, internal owners, or lifecycle flow despite the new shared rule; those contradictions were migrated and covered by focused regression checks."
next_step: "/005-sg-ship unfinished chantier user choice contract"
---

# Spec: Unfinished Chantier User Choice Contract

## Title

Unfinished Chantier User Choice Contract

## Status

Ready — bounded shared reporting repair; no product, external-provider, data, security, or shipping decision is introduced.

## User Story

As a ShipGlows operator, I receive clear numbered choices whenever a chantier remains open, so I can steer its outcome without being asked to launch or understand internal skills.

## Minimal Behavior Contract

A final user-facing report for an unfinished chantier ends with two or three numbered plain-language choices. The default is continue, reprioritize, or pause; a real business or safety decision replaces those generic choices. Internal skills, commands, lifecycle labels, owners, and agent topology never appear in that choice surface.

## Success Behavior

- An open or partial chantier offers a visible continue/reorient/pause choice block.
- A required material decision is stated as the specific numbered choice, with a recommended option.
- A completed chantier has no unnecessary choice block.
- A blocked chantier offers safe recovery choices, not a generic internal next step.

## Error Behavior

- A report must not end with a skill name, slash command, lifecycle flow, or instruction for the operator to launch internal work.
- Routine progress commentary must not interrupt autonomous work merely to request a choice.

## Problem

The current contract correctly keeps internal lifecycle steps agent-runnable, but it can leave an operator without a visible way to steer an unfinished objective and can still expose internal routing in legacy templates.

## Solution

Add one shared continuity-choice rule, align question and delegation doctrine, migrate legacy user-report templates that contradicted the shared rule, and lock the behavior with focused regression tests.

## Scope In

- Shared reporting, question, and delegation contracts.
- User-report templates that exposed internal routes, commands, paths, or lifecycle flow.
- Focused reporting-contract regression coverage.

## Scope Out

- Requiring choices on completed chantiers or routine in-flight commentary.
- Changing product workflows, public skills, runtime packaging, commits, pushes, or deployment.

## Invariants

- Internal owner selection and execution remain agent-owned.
- User choices are outcome and priority decisions, never internal workflow controls.
- One material decision at a time remains the maximum.

## Implementation Tasks

- [x] Task 1: Define shared unfinished-chantier choice behavior and anti-leakage rule.
- [x] Task 2: Align question and master-delegation contracts with internal execution ownership.
- [x] Task 3: Replace the build user-report template that exposed lifecycle flow.
- [x] Task 4: Add deterministic regression checks for the shared rule and build template.
- [x] Task 5: Run an excellence pass across legacy user-report templates and remove remaining internal route, command, path, and lifecycle leakage.

## Acceptance Criteria

- [x] AC 1: An unfinished user-facing final report ends with numbered plain-language choices.
- [x] AC 2: The choices contain no skill names, commands, lifecycle stages, owners, or agent topology.
- [x] AC 3: A material decision replaces generic choices; a completed chantier omits them.
- [x] AC 4: Active user-report templates cannot reintroduce an internal lifecycle flow, command, owner, or path in user mode.

## Test Strategy

- Run the focused reporting contract suite.
- Run the core contract suite, audit, budget check, and runtime sync check.
- Inspect active user-report templates and the scoped diff for internal-routing leakage and unrelated changes.

## Risks

- Over-asking could interrupt autonomous work. Mitigation: apply choices only to final user-facing reports that leave a chantier open; routine commentary remains informational.
- Generic choices could hide a real decision. Mitigation: specific material decisions replace the generic block.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-18 08:25:32 UTC | 100-sg-spec + 101-sg-ready | GPT-5 Codex | Derived a bounded shared-contract repair from the operator correction and checked the placement, scope, proof, and no-external-dependency conditions. | ready | `/102-sg-start unfinished chantier user choice contract` |
| 2026-07-18 08:25:32 UTC | 900-shipglows-core build | GPT-5 Codex | Applied the shared rule, aligned adjacent doctrine, removed the exposed build-flow template, and added focused regression coverage. | implemented; validation pending | `/103-sg-verify unfinished chantier user choice contract` |
| 2026-07-18 08:29:40 UTC | 103-sg-verify + 104-sg-end | GPT-5 Codex | Replayed the focused reporting and core-contract tests, metadata lint, execution-fidelity audit, budget audit, runtime sync, and scoped diff hygiene; recorded the durable task and changelog outcome. | verified and closed locally | `/005-sg-ship unfinished chantier user choice contract` |
| 2026-07-18 08:46:11 UTC | 103-sg-verify | GPT-5 Codex | mode=excellence: challenged shared doctrine, timestamps, chantier-potential output, lifecycle user templates, metadata versions, regression coverage, runtime visibility, and closure coherence; repaired the bounded legacy-template contradictions, replayed the full scoped evidence, and confirmed the separate skill-code index failure is identical on `HEAD` rather than introduced here. | excellent | ready to publish when authorized |

## Current Chantier Flow

- `100-sg-spec`: drafted and ready — the shared contract is bounded and testable.
- `101-sg-ready`: ready — no unresolved operator-owned, security, data, or external dependency decision.
- `102-sg-start`: implemented — shared reporting and adjacent templates are aligned.
- `103-sg-verify`: excellent (`mode=excellence`) — the fresh cross-surface pass found and repaired legacy user-template contradictions; 26 focused contract tests, metadata lint, execution-fidelity audit, budget audit, runtime sync, and diff hygiene pass.
- `104-sg-end`: closed locally — the task tracker and changelog record the shared reporting change.
- `005-sg-ship`: not launched.

Next step: `/005-sg-ship unfinished chantier user choice contract`
