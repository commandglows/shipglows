---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-14"
created_at: "2026-08-14 00:00:00 UTC"
updated: "2026-08-27"
updated_at: "2026-08-27 00:52:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "Codex"
scope: two-tier-mutation-approval-fast-path
owner: Diane
user_story: "En tant qu'opératrice ShipGlows, je veux que ma demande explicite autorise directement sa micro-modification exacte sans autoriser implicitement un chantier, et qu'un chantier validé ne redemande jamais l'autorisation de ses commits ordinaires."
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
  - "Operator decision 2026-08-15: standalone `v` should be a canonical approval shortcut for the immediately preceding pending chantier plan."
  - "Operator correction 2026-08-27: modifying one exact file is not a chantier; the explicit request authorizes only its qualifying micro-mutation, while a chantier still requires one plan."
next_step: "/102-sg-start two-tier mutation approval fast path"
---

# Two-Tier Mutation Approval Fast Path

## Status

ready — focused contract implementation and its exact-scope local technical commit are approved; push, publish, deployment, and external runtime mutation are not authorized.

## Minimal Behavior Contract

An explicit request directly authorizes one qualifying exact micro-mutation: a single-line addition, typo, formatting or literal correction, narrow metadata/documentation edit, or deterministic micro-bug with one small implementation established by read-only diagnosis. This direct authority is local-only, routine, reversible, no-harm, and limited to the requested mutation; it does not authorize a chantier. Every other mutation still requires approval after `🧭 VALIDATION RAPIDE` when all fast criteria hold or after the full `🧭 PLAN À VALIDER`. An ordinary exact-scope local commit records already authorized work without a separate prompt. `git push` always uses the full plan, and force push retains every stricter gate.

## Success Behavior

- A safe switch to an exact existing branch may receive a one-line fast validation.
- Creating an exact branch/worktree from a resolved base may receive fast validation when collision and dirty-worktree safety are established.
- The initial imperative authorizes only its qualifying exact micro-mutation and never authorizes a chantier.
- Adding one requested line to one resolved file, correcting a typo, or applying a deterministic micro-bug fix proceeds without a second validation prompt when every direct-authority condition holds.
- A material change invalidates prior approval and requires a newly appropriate fast validation or full plan.
- Full-plan mutations retain the chantier opening, four sections, Paris time, and contextual strategic choices.
- Approval of a bounded technical implementation includes silent exact-scope local commits; their identifiers are reported at the next natural checkpoint.
- Standalone `v` or `V` approves the immediately preceding pending approval message only when its approval outcome is unambiguous and no intervening control or replacement exists.

## Error Behavior

- Missing or uncertain eligibility falls back to the full plan; the agent does not infer safety.
- A micro-looking request that reveals multiple plausible implementations, broader file families, or product, architecture, data, security, or permission judgment stops before mutation and becomes a planned chantier.
- Push, force, publish, deploy, deletion, overwrite, messaging, credentials, permissions, or unrelated-change effects never use the fast path.
- A fast validation must not hide multiple actions or an unresolved target behind a generic phrase.
- Approval for one target or action does not authorize another.

## Scope In

- Canonical two-tier approval contract and pressure scenarios.
- Router, lifecycle, partnership, packaged skill, agent-entrypoint, installer, workflow, and technical-documentation references that repeat the gate.
- Focused Python and Windows static regression checks.
- Cumulative local commit authority for bounded technical chantiers.
- Canonical bounded `v` approval shortcut.
- Exact micro-request authority and its chantier boundary.

## Scope Out

- Mutation inferred beyond one explicit qualifying micro-request.
- Changes to destructive, production, credential, billing, publication, or irreversible gates.
- Push, amend, rebase, squash, reset, tag, hook bypass, deployment, server mutation, packaging, or publishing in this chantier.

## Constraints And Invariants

- Fast-path eligibility is cumulative; every criterion must be proven before presenting it.
- Direct micro-authority is evaluated before validation and never expands from a file edit into a chantier.
- Fast approval changes ceremony only, never authority, scope, or safety.
- `git push` always uses the full plan; force push also retains stricter gates.
- Read-only exploration remains allowed before approval.
- Existing unrelated worktree changes must be preserved.
- Exact-scope technical commits preserve unrelated changes and require secret checks; editorial, mixed-scope, closure, and release commits need explicit inclusion.

## Test Contract

- Proof path: `scenario-first`.
- Automated proof: focused Python contract tests, Windows static contract test, metadata lint on changed metadata-bearing documents, and focused text scans.
- Pressure scenarios: `MAP-EXACT-MICRO-REQUEST`, `MAP-MICRO-TO-CHANTIER`, `MAP-SMALL-CHANGE`, `MAP-FAST-SWITCH`, `MAP-FAST-WORKTREE`, `MAP-FAST-INELIGIBLE`, `MAP-FAST-REPLACEMENT`, `MAP-REMOTE-PUSH`, `MAP-TECHNICAL-COMMIT`, `MAP-COMMIT-BOUNDARY`, and `MAP-V-SHORTCUT`.
- No browser, server, package, or external-service proof is needed because this is a local instruction-contract change.

## Acceptance Criteria

- [x] The canonical contract defines the two paths and cumulative fast eligibility.
- [x] The fast message is limited to one or two sentences with exact action, exact target, and main safety guarantee.
- [x] Full-plan form and strategic choices remain required for ineligible mutations.
- [x] `git push` is mechanically asserted as full-plan-only.
- [x] All eight named pressure scenarios are present and tested.
- [x] Distributed surfaces and Windows-installed instructions reflect the same boundary.
- [x] Focused tests and metadata lint pass.
- [x] Approved bounded technical work may be committed locally without duplicate approval while unrelated, editorial, history-rewriting, and remote actions remain gated.
- [x] Standalone `v` is accepted only as an immediate unambiguous response to the pending approval message and is inert in every other context.
- [x] One exact requested micro-mutation executes without another approval prompt and never authorizes a chantier.
- [x] An ordinary exact-scope local commit never receives its own approval prompt.

## Current Chantier Flow

`900-shipglows-core build` implemented exact micro-request authority with a hard chantier boundary and silent exact-scope local commits. Focused Python and Windows contract proofs pass, all five active Windows agent-instruction blocks are synchronized, and ordinary final push is the remaining delivery step under the plan approved on 2026-08-27.

## Skill Run History

- 2026-08-15 — `900-shipglows-core build`: translated the operator friction into `MAP-TECHNICAL-COMMIT` and `MAP-COMMIT-BOUNDARY`, propagated the rule through lifecycle/question/continuation doctrine, refreshed `706-continue`, and validated the focused contract, metadata, audit, and skill budget.
- 2026-08-15 — `900-shipglows-core build`: added and verified `MAP-V-SHORTCUT` so standalone `v` canonically approves only the immediately preceding unambiguous pending approval message; 76 focused contract/graph tests, metadata, audit, and budget checks passed.
- 2026-08-27 — `900-shipglows-core build`: operator clarified that an exact file micro-modification is not a chantier; started scenario-first repair so the request itself authorizes only that micro-mutation while a real chantier still requires one plan.
- 2026-08-27 — `103-sg-verify`: 28 mutation-contract tests, 4 strategic-choice tests, the Windows static regression, metadata lint across 11 governed artifacts, and direct checks of all five active agent-instruction blocks passed.
