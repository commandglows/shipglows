---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-27"
created_at: "2026-08-27 23:08:06 UTC"
updated: "2026-08-27"
updated_at: "2026-08-27 23:08:06 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: managed-project-required-ci-gate
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
user_story: "As the ShipGlows operator, I want every managed GitHub project to expose one stable always-on required CI status so branch protection cannot be bypassed or deadlocked by stack-specific path filters."
linked_systems:
  - skills/references/project-delivery-policy.md
  - skills/references/managed-project-ci-policy.md
  - skills/305-sg-init/SKILL.md
  - skills/305-sg-init/references/bootstrap-entrypoint-and-dev-mode.md
  - skills/010-sg-technical/SKILL.md
  - skills/010-sg-technical/references/github-hygiene-playbook.md
  - skills/103-sg-verify/references/verification-ci.md
  - tools/shipglows_required_gate.py
  - tools/test_shipglows_required_gate.py
  - shipglows_data/technical/github-actions.md
depends_on:
  - artifact: skills/references/project-delivery-policy.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.16.0"
    required_status: active
supersedes: []
evidence:
  - "ContentGlows audit 2026-08-27: Android checks is required by the main ruleset while its workflow is filtered to app paths, so an unrelated site or lab pull request can receive no terminal required status."
  - "ShipGlows runtime already proves the safe pattern: one always-triggered ShipGlows required gate reports an explicit successful no-impact result when expensive Windows proof is irrelevant."
  - "Operator decision 2026-08-28: make protective CI mandatory across ShipGlows-managed projects, beginning with a Core contract and a ContentGlows pilot."
next_step: "Implement the canonical policy, generator/auditor, owner integrations, and focused contract proof."
---

# Managed project required CI gate

## Status

ready

## User Story

As the ShipGlows operator, I want every managed GitHub project to expose one stable always-on required CI status so branch protection cannot be bypassed or deadlocked by stack-specific path filters.

## Minimal Behavior Contract

Every managed GitHub repository uses the exact protected status name `ShipGlows required gate`. The owning workflow triggers for every pull request into the production branch, every push to that branch, and manual dispatch. It deterministically classifies changed paths, runs only relevant stack checks, treats an irrelevant lane as an explicit successful no-impact result, and fails closed when classification or an applicable check fails. A ruleset may require the status only after the workflow exists on the production branch and the exact status has completed successfully.

## Success Behavior

- A new or existing managed project can be audited locally without provider mutation.
- Stack detection covers Node, Flutter, Python, and repository-declared custom commands without inventing a package manager or command.
- The generated workflow has one stable terminal job named `ShipGlows required gate` and no top-level path filter.
- Unrelated changes skip expensive stack work but still terminate the protected status successfully.
- Applicable stack failures propagate to the terminal status.
- Ruleset inspection distinguishes absent, drifted, and compliant protection without silently rewriting provider state.
- Explicit reconciliation refuses to protect a missing or unproven status and preserves deletion, non-fast-forward, and unrelated existing rules.
- Bootstrap and GitHub hygiene owners expose the same policy and remediation route.

## Error Behavior

- Unknown production branch, ambiguous package manager, unsupported project declaration, malformed workflow, missing GitHub CLI truth, or unavailable required-check evidence returns a non-zero actionable result.
- A directly required path-filtered job is reported as non-compliant even when its latest observed run is green.
- Provider reconciliation stops before any write if the canonical workflow is absent from the production branch or the exact check has no successful run.
- Existing rules are never replaced from a stale snapshot, and no force, merge, deployment, credential, secret, or reviewer requirement is inferred.

## Pressure Scenarios

- `GATE-ALWAYS-ON`: every protected pull request receives the exact terminal status.
- `GATE-PATH-NO-DEADLOCK`: a site-only change in a Flutter monorepo skips Flutter work but completes the gate.
- `GATE-FAIL-CLOSED`: changed-path classification or an applicable command failure fails the gate.
- `GATE-INSTALL-BEFORE-PROTECT`: ruleset reconciliation refuses a status absent from the production branch or unproven by a successful run.
- `GATE-RULESET-PRESERVE`: reconciliation preserves unrelated rules and never weakens deletion or non-fast-forward protection.
- `GATE-DRIFT`: workflow, command, stack, branch, or ruleset drift receives an actionable audit result.
- `GATE-FOLLOWABLE`: a fresh agent can determine audit, generation, proof, and reconciliation steps from the project plus canonical contract only.

## Scope In

- Canonical managed-project CI policy and delivery-policy integration.
- Cross-platform Python audit/generation tooling with deterministic project inspection.
- Explicit GitHub ruleset inspection and guarded reconciliation surfaces.
- Bootstrap, GitHub hygiene, and CI verification owner integration.
- Focused contract tests and mapped technical documentation.
- Exact-scope milestone commits and ordinary pushes on `codex/development-runtime`.

## Scope Out

- Mutating ContentGlows or another managed project from Core context.
- Bulk fleet rollout, pull-request merge, release, deploy, branch deletion, force push, credential changes, or production mutation.
- Inventing stack checks when a project does not expose a safe conventional or declared command.
- Requiring a second human reviewer for solo-maintainer development or published projects.

## Constraints And Invariants

- `ShipGlows required gate` is the sole canonical protected status identity.
- Top-level workflow `paths` and `paths-ignore` are forbidden on the owning required workflow.
- Path selectivity lives inside the workflow; the terminal gate always runs with `if: always()` when it depends on optional jobs.
- The production branch defaults to `main` only when project policy does not declare an alternative.
- Audit is read-only. Workflow generation writes only the explicit output path. Provider apply is separately explicit and preconditioned by fresh provider evidence.
- Generated workflows use least-privileged read permissions, exact revision checkout, pinned maintained actions, bounded timeouts, and no secrets.
- Existing unrelated dirty work remains unstaged and byte-preserved.

## Implementation Tasks

- [x] Create and readiness-review this durable contract.
- [ ] Add the canonical managed-project CI policy and link it from delivery doctrine.
- [ ] Implement deterministic project inspection, workflow rendering, local audit, and guarded ruleset plan/apply tooling.
- [ ] Integrate bootstrap, GitHub hygiene, and CI verification owners.
- [ ] Add focused pressure-scenario tests and technical documentation mapping.
- [ ] Run verification, closure bookkeeping, exact-scope final commit, and ordinary push.
- [ ] Hand off ContentGlows as the first project-context pilot without mutating it here.

## Test Contract

- `python -m unittest tools.test_shipglows_required_gate`
- `python tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/managed-project-required-ci-gate.md skills/references/managed-project-ci-policy.md`
- focused owner-contract tests for `305-sg-init`, `010-sg-technical`, `103-sg-verify`, and `900-shipglows-core`
- `python tools/audit_shipglows_skills.py`
- `python tools/skill_budget_audit.py --skills-root skills --format markdown`
- runtime sync checks only for affected skills
- `git diff --check` and exact staged-scope secret scan before each commit

## Documentation Coherence

The canonical rule belongs in a shared policy reference. Project delivery doctrine states when it applies; bootstrap records and installs it; GitHub hygiene audits and reconciles it; CI verification proves its path and failure behavior; technical GitHub Actions documentation explains the generated runtime contract. ContentGlows remains evidence and a later pilot target, not a Core mutation surface.

## Risks

- **Maintainer lockout:** requiring a status before it exists or succeeds can block every merge. Mitigate with install-before-protect and successful-run preconditions.
- **False green:** selector or command drift can skip relevant checks. Mitigate with deterministic ownership, explicit unknown failure, and boundary tests.
- **Provider overwrite:** replacing an entire ruleset from stale state can weaken controls. Mitigate with fresh read-modify-write, preservation assertions, and dry-run plans.
- **Workflow supply chain:** mutable actions or secrets can expand CI risk. Mitigate with pinned actions, read-only permissions, and no privileged events.
- **Stack overreach:** inferred commands can be destructive or wrong. Mitigate with a small conventional allowlist and explicit project declarations for everything else.

## Execution Notes

Implementation classification: `infrastructure · shared/domain · documentation`. Topology: `main-only`; one integration owner retains the overlapping policy/tool/test surfaces. Proof discipline: scenario-first. No frontend, application backend, auth, tenant, billing, private data, production, or deployment surface applies.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-27 | 100-sg-spec | GPT-5 Codex | Formalized the universal always-on managed-project CI gate contract. | created | Run substantive readiness review. |
| 2026-08-27 | 101-sg-ready | GPT-5 Codex | Reviewed behavior, failure semantics, owner boundaries, provider safety, proof, and followability. | ready | Implement the contract under the approved Core plan. |

## Current Chantier Flow

- `100-sg-spec` ✅ created
- `101-sg-ready` ✅ ready
- `102-sg-start` ⏳ pending
- `103-sg-verify` ⏳ pending
- `104-sg-end` ⏳ pending
- `005-sg-ship` ⏳ pending
