---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-16"
created_at: "2026-08-16 09:11:28 UTC"
updated: "2026-08-16"
updated_at: "2026-08-16 09:16:08 UTC"
status: reviewed
source_skill: 900-shipglows-core
source_model: "GPT-5 Codex"
scope: current-project-hygiene-alias
owner: Diane
user_story: "As a ShipGlows operator, I want one safe hygiene command for the current project, with Git cleanup available as an explicit specialized alias."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/002-sg-maintain/references/maintenance-playbooks.md
  - skills/010-sg-technical/references/github-hygiene-playbook.md
  - skills/references/skill-invocation-registry.json
  - tools/skill_invocation_check.py
  - tools/test_skill_invocation_check.py
  - tools/test_002_sg_maintain_contract.py
depends_on:
  - artifact: skills/references/expert-mode-aliases.md
    artifact_version: "1.4.0"
    required_status: active
  - artifact: skills/references/git-temporary-artifact-lifecycle.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-16: hygiene defaults to a read-only audit of the current project and proposes grouped corrections."
  - "Operator decision 2026-08-16: hygiene git is exactly the safe shipglows git clean workflow, never native git clean."
  - "Operator decision 2026-08-16: multi-project hygiene is deferred."
next_step: "/102-sg-start current-project hygiene alias"
---

# Spec: Current-project hygiene alias

## Minimal Behavior Contract

`shipglows hygiene` performs a comprehensive, non-mutating audit of the current project across Git residue, dependencies, security, documentation, checks, audits, and quality debt. It returns one grouped correction proposal; the invocation authorizes no mutation. `shipglows hygiene git` resolves exactly to the safe `shipglows git clean` workflow, which audits first and obtains fresh approval before every cleanup mutation. Multi-project scope is rejected.

## Pressure Scenarios

- `HYGIENE-CURRENT-READONLY`: no argument audits the current project without fetch, install, edit, commit, push, merge, or deletion.
- `HYGIENE-GIT-CLEAN`: `hygiene git` selects engineering Git hygiene with engine mode `clean`, never the native `git clean` command.
- `HYGIENE-NO-GLOBAL`: `hygiene global` and workspace equivalents fail with an actionable current-project-only message.
- `HYGIENE-ZERO`: no findings returns a clean verdict and no proposed mutation.
- `HYGIENE-MANY`: findings from several lanes are deduplicated, risk-ranked, owner-routed, and grouped before any approval request.
- `HYGIENE-DIRTY-GIT`: dirty or ambiguous Git artifacts remain blocked and are never folded into an automatic correction.

## ZOMBIES Coverage

- Zero, one, and many findings retain distinct compact reports.
- Boundaries separate observation, recommendation, approval, and execution.
- Interfaces keep maintenance ownership and Git cleanup ownership distinct.
- Exceptions fail closed on unknown scope, stale remote truth, dirty state, unavailable tools, or partial evidence.

## Implementation Tasks

- [x] Add failing invocation and maintenance scenarios.
- [x] Add the contextual alias, current-project scope rejection, and engine-mode propagation.
- [x] Add the comprehensive read-only maintenance lane and grouped proposal contract.
- [x] Align router, help, operator, lifecycle, and refresh surfaces.
- [x] Run focused and cross-contract validation, runtime visibility, diff, and secret checks.
- [ ] Commit and push only the dedicated feature branch.

## Acceptance Criteria

- [x] AC1: `shipglows hygiene` resolves to `sg-maintenance hygiene` and `002-sg-maintain`.
- [x] AC2: the default audit performs no mutation, including no implicit `git fetch`.
- [x] AC3: `shipglows hygiene git` resolves to `sg-engineering github` with engine mode `clean`.
- [x] AC4: no contract invokes or recommends native `git clean` as the hygiene implementation.
- [x] AC5: multi-project hygiene scope is rejected rather than silently widened.
- [x] AC6: every proposed correction retains its normal owner and fresh approval boundary.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-16 09:11:28 UTC | 900-shipglows-core | GPT-5 Codex | Captured the approved current-project-only hygiene contract and its scenario-first proof. | ready; five focused regression scenarios fail on the expected missing behavior | Implement alias routing and the read-only aggregate lane. |
| 2026-08-16 09:16:08 UTC | 900-shipglows-core | GPT-5 Codex | Implemented and conservatively refreshed the contextual hygiene route, aggregate audit, and safe Git cleanup specialization. | 137 focused/cross-contract tests pass; metadata, 707/934/0 resource graph, budget, audit, runtime visibility, diff, syntax, and secret checks pass | Commit and push only the dedicated branch; retain it until integration. |

## Current Chantier Flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| 100-sg-spec | complete | Behavior, exclusions, ZOMBIES coverage, and proof path are explicit. |
| 101-sg-ready | complete | Existing maintenance and Git owners are reused; no new skill is needed. |
| 102-sg-start | complete | Alias, rejection boundary, engine-mode propagation, and aggregate audit are implemented. |
| 900 refresh | complete | `shipglows` and `002-sg-maintain` preserve owner layering, context budget, help, runtime, and approval boundaries. |
| 103-sg-verify | complete | 137 tests, metadata, full graph, budget, audit, isolated runtime, diff, syntax, and secret proofs pass. |
| 104-sg-end | complete | Router, owners, help, operator guide, lifecycle docs, refresh log, and spec are aligned; no separate site surface exists in this checkout. |
| 005-sg-ship | in_progress | Commit and push the dedicated feature branch only; retain it until integration. |
