---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-23"
created_at: "2026-08-23 11:00:14 UTC"
updated: "2026-08-23"
updated_at: "2026-08-23 11:12:00 UTC"
status: active
source_skill: 900-shipglows-core
source_model: GPT-5 Codex
scope: restore-global-contract-suite
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
user_story: "As the ShipGlows operator, I want every contract check to reflect current governed behavior so the suite reliably detects regressions."
linked_systems:
  - skills/005-sg-ship/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/references/mutation-plan-approval.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/master-delegation-semantics.md
  - skills/references/decision-quality-contract.md
  - tools/test_*contract.py
depends_on: []
supersedes: []
evidence:
  - "The complete contract suite reports eight failures and one portability error across five confirmed causes."
  - "Operator approval 2026-08-23 authorizes the complete repair, proportional proof, exact commit, and push to main."
next_step: "Persist the verified repair, then close and ship the chantier."
---

# Restore the global contract suite

## Title

Restore the global contract suite without weakening current ShipGlows doctrine.

## Status

Implemented and verified; persistence and closure remain.

## User Story

As the ShipGlows operator, I want every contract check to reflect current governed behavior so the suite reliably detects regressions instead of failing on stale wording, missing references, non-portable paths, or small activation-budget drift.

## Minimal Behavior Contract

Running the complete contract suite from the repository must return zero failures and zero errors. It must still fail if lifecycle references disappear, activation bodies exceed their existing budgets, Git milestone push authority regresses, or alias resolution depends on a machine-specific repository path.

## Success Behavior

All contract tests pass; current commit/push doctrine remains intact; the two missing lifecycle references are restored; compacted skills stay within their existing thresholds; and alias proof resolves a canonical public wrapper portably.

## Error Behavior

Any remaining failure, weakened assertion, raised budget threshold, lost stop condition, contradictory Git authority, or machine-specific path keeps the chantier unverified and unshipped.

## Problem

The suite has nine red results from five causes: two narrow budget overruns, two missing activation references in the start owner, three assertions written for superseded local-only commit rules, one brittle exact-wording assertion, and one repository-local compatibility path that does not exist.

## Solution

Repair each cause at its owning layer: compact activation prose, restore direct references, update tests to assert current remote-persistence boundaries, assert the existing semantic excellence rule, and resolve the public wrapper from the canonical skills surface.

## Scope In

- The nine current red contract results and their direct owners.
- Focused pressure assertions for budget, reference consumption, Git authority, semantic quality, and portable alias resolution.
- Spec trace, complete contract proof, global skill audits, exact commit, and push to `origin/main`.

## Scope Out

- Product behavior, public marketing content, dependencies, deployment, unrelated cleanup, and threshold increases.

## Constraints

- Preserve existing budget ceilings rather than raising them.
- Preserve approved milestone commits and pushes; tests must not restore local-only rules.
- Add references at the activation owner layer without duplicating their procedures.
- Keep all changed Python tests behavior-focused, deterministic, and repository-portable.
- Preserve unrelated work and stage only this chantier.

## Test Contract

Surface: ShipGlows skill contracts and Python contract tests. First run the nine affected modules, then the full `test_*contract.py` discovery suite, metadata and budget audits, activation graph, skill audit, sync check, JSON validation, and diff check. No browser, auth, provider, or manual proof applies.

## Dependencies

- Current canonical mutation, lifecycle, delegation, delivery-policy, decision-quality, and alias contracts.
- Python standard-library unittest runner and existing ShipGlows audit tools.

## Invariants

- Git push remains separately disclosed in a full plan and then executable without duplicate approval inside that approved scope.
- Commit/push proves persistence, not deployment.
- A fresh execution owner can discover product-decision and delivery-policy authorities directly.
- Contract tests resolve repository-owned sources without assuming a local runtime directory inside the repository.

## Links & Consequences

The start owner, mutation approval tests, lifecycle/delegation tests, public alias test, ship/verify budget tests, and global contract suite must be revalidated together. No public invocation grammar changes.

## Documentation Coherence

Update this spec and the directly affected activation references. No public editorial surface changes because the repair restores internal contract truth only.

## Edge Cases

- Z: missing wrapper or reference fails visibly rather than falling back silently.
- O: one current authority has exactly one corresponding assertion.
- M: current remote persistence combines commit, push, upstream, and prohibited-history boundaries without contradictory local-only wording.
- B/I/E/S: exact budget boundaries, portable filesystem resolution, full-suite discovery, and unrelated baseline changes remain covered.

## Implementation Tasks

1. Compact the ship and verify activation bodies below their unchanged thresholds; validate their focused budget contracts.
2. Add direct product-decision and delivery-policy references to the start owner; validate both consumer contracts.
3. Rewrite stale mutation-approval assertions around current milestone push authority and strict prohibited operations; validate mutation and lifecycle contracts.
4. Make core-alias proof resolve the canonical public wrapper and replace the excellence wording assertion with the existing semantic invariant.
5. Run affected and complete contract suites, then global audits, metadata, budgets, graph, sync, JSON, and diff checks.
6. Update lifecycle trace, commit only owned paths, and push `main` to its resolved upstream.

## Acceptance Criteria

1. The complete contract suite reports zero failures and zero errors.
2. Both activation budgets pass without increasing thresholds.
3. The start owner directly names both required shared authorities.
4. Mutation tests assert approved milestone pushes and still forbid amend, rebase, squash, reset, tags, force, hook bypass, ambiguous upstream, deployment, and unrelated remote effects.
5. Alias proof works from the repository without a repository-local `.agents` directory.
6. Skill audit, graph, metadata, budget, sync, JSON, and diff checks pass.
7. Exact owned changes are committed and pushed to `origin/main`.

## Test Strategy

Scenario-first: retain each current failure as a focused mechanical scenario, make the smallest complete owner-level repair, rerun affected modules, then run the explicit global suite required by the audit goal.

## Risks

- Updating assertions to implementation text could hide a true regression; mitigate by asserting behavioral invariants and prohibited boundaries.
- Compacting activation prose could remove a stop or reference; mitigate with existing focused contract tests and diff review.
- Adding direct references could exceed another budget; mitigate with budget audit before closure.

## Execution Notes

Implementation classification: `shared/domain · documentation-only`. Python test changes must remain deterministic and behavior-focused; Markdown activation edits must preserve owner layering and direct-reference rules. Security, UI, backend, data, auth, and deployment gates are not applicable.

First reads: the two over-budget activation bodies, the start owner, mutation approval plus lifecycle/delegation consumers, decision quality, the alias registry/public wrapper, and their nine failing tests. Stop if a proposed fix raises a threshold, restores local-only Git semantics, removes an activation stop, or expands beyond the five diagnosed causes.

## Open Questions

None. The operator selected the complete repair and approved its remote persistence effects.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-23 | 100-sg-spec | GPT-5 Codex | Formalize the five-cause repair contract | draft | Run readiness review |
| 2026-08-23 | 101-sg-ready | GPT-5 Codex | Review structure, behavior, proof, boundaries, and execution autonomy | ready | Implement the bounded repairs |
| 2026-08-23 | 102-sg-start | GPT-5 Codex | Repair the five diagnosed contract causes | implemented | Run complete contract proof |
| 2026-08-23 | 103-sg-verify | GPT-5 Codex | Run focused and global contract, audit, graph, metadata, budget, sync, JSON, and diff proof | verified | Persist the verified repair |

## Current Chantier Flow

- 100-sg-spec: completed
- 101-sg-ready: ready
- 102-sg-start: implemented
- 103-sg-verify: verified
- 104-sg-end: pending
- 005-sg-ship: pending
