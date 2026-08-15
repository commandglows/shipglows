---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-14"
created_at: "2026-08-14 00:00:00 UTC"
updated: "2026-08-15"
updated_at: "2026-08-15 12:05:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "Codex"
scope: two-tier-mutation-approval-fast-path
owner: Diane
user_story: "En tant qu'opératrice ShipGlows, je veux approuver un chantier technique une seule fois, y compris ses commits locaux ordinaires, sans affaiblir les garde-fous des actions risquées ou distantes."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/mutation-plan-approval.md
  - tools/test_mutation_plan_approval_contract.py
  - tests/windows/static-development-environment.ps1
  - cli/windows/install-devserver.ps1
  - skills/000-shipglows/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/entrypoint-routing.md
depends_on:
  - artifact: "skills/references/mutation-plan-approval.md"
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-14: routine branch and worktree operations need a much lighter approval surface."
  - "Operator decision 2026-08-14: retain a robust full contract for remote, destructive, ambiguous, or materially risky mutations."
  - "The existing universal contract requires four sections and strategic choices even for exact local reversible Git operations."
  - "Operator decision 2026-08-15: a second validation for a micro technical commit already covered by an approved chantier is unacceptable friction."
next_step: "/102-sg-start two-tier mutation approval fast path"
---

# Two-Tier Mutation Approval Fast Path

## Status

ready — focused contract implementation and its exact-scope local technical commit are approved; push, publish, deployment, and external runtime mutation are not authorized.

## Minimal Behavior Contract

Every intentional mutation still requires explicit approval given after the approval message. A request may use `🧭 VALIDATION RAPIDE` only when every eligibility criterion is established: the action is explicitly requested and unambiguous, its target is exact and resolved, it is local-only, routine, readily reversible, and it cannot overwrite, discard, delete, force, publish, deploy, message, change credentials or permissions, or touch unrelated changes. The fast message is one or two sentences naming the exact action, exact target, and main safety guarantee; it has no four-section plan or strategic-choice menu. If any criterion is absent, use the existing full `🧭 PLAN À VALIDER`. `git push` always uses the full plan, and force push retains every stricter gate.

## Success Behavior

- A safe switch to an exact existing branch may receive a one-line fast validation.
- Creating an exact branch/worktree from a resolved base may receive fast validation when collision and dirty-worktree safety are established.
- The initial imperative never approves either path; mutation waits for a later unambiguous response.
- A material change invalidates prior approval and requires a newly appropriate fast validation or full plan.
- Full-plan mutations retain the chantier opening, four sections, Paris time, and contextual strategic choices.
- Approval of a bounded technical implementation includes silent exact-scope local commits; their identifiers are reported at the next natural checkpoint.

## Error Behavior

- Missing or uncertain eligibility falls back to the full plan; the agent does not infer safety.
- Push, force, publish, deploy, deletion, overwrite, messaging, credentials, permissions, or unrelated-change effects never use the fast path.
- A fast validation must not hide multiple actions or an unresolved target behind a generic phrase.
- Approval for one target or action does not authorize another.

## Scope In

- Canonical two-tier approval contract and pressure scenarios.
- Router, lifecycle, partnership, packaged skill, agent-entrypoint, installer, workflow, and technical-documentation references that repeat the gate.
- Focused Python and Windows static regression checks.
- Cumulative local commit authority for bounded technical chantiers.

## Scope Out

- Approval-free intentional mutation.
- Changes to destructive, production, credential, billing, publication, or irreversible gates.
- Push, amend, rebase, squash, reset, tag, hook bypass, deployment, server mutation, packaging, or publishing in this chantier.

## Constraints And Invariants

- Fast-path eligibility is cumulative; every criterion must be proven before presenting it.
- Fast approval changes ceremony only, never authority, scope, or safety.
- `git push` always uses the full plan; force push also retains stricter gates.
- Read-only exploration remains allowed before approval.
- Existing unrelated worktree changes must be preserved.
- Exact-scope technical commits preserve unrelated changes and require secret checks; editorial, mixed-scope, closure, and release commits need explicit inclusion.

## Test Contract

- Proof path: `scenario-first`.
- Automated proof: focused Python contract tests, Windows static contract test, metadata lint on changed metadata-bearing documents, and focused text scans.
- Pressure scenarios: `MAP-FAST-SWITCH`, `MAP-FAST-WORKTREE`, `MAP-FAST-INELIGIBLE`, `MAP-FAST-REPLACEMENT`, `MAP-REMOTE-PUSH`, `MAP-TECHNICAL-COMMIT`, and `MAP-COMMIT-BOUNDARY`.
- No browser, server, package, or external-service proof is needed because this is a local instruction-contract change.

## Acceptance Criteria

- [x] The canonical contract defines the two paths and cumulative fast eligibility.
- [x] The fast message is limited to one or two sentences with exact action, exact target, and main safety guarantee.
- [x] Full-plan form and strategic choices remain required for ineligible mutations.
- [x] `git push` is mechanically asserted as full-plan-only.
- [x] All seven named pressure scenarios are present and tested.
- [x] Distributed surfaces and Windows-installed instructions reflect the same boundary.
- [x] Focused tests and metadata lint pass.
- [x] Approved bounded technical work may be committed locally without duplicate approval while unrelated, editorial, history-rewriting, and remote actions remain gated.

## Current Chantier Flow

`900-shipglows-core build` implemented the cumulative local technical commit authority with scenario-first contract coverage. Focused verification is complete; runtime-link repair remains independent installation maintenance, and no push is authorized.

## Skill Run History

- 2026-08-15 — `900-shipglows-core build`: translated the operator friction into `MAP-TECHNICAL-COMMIT` and `MAP-COMMIT-BOUNDARY`, propagated the rule through lifecycle/question/continuation doctrine, refreshed `706-continue`, and validated the focused contract, metadata, audit, and skill budget.
