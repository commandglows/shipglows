---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-14"
created_at: "2026-08-14 00:00:00 UTC"
updated: "2026-08-27"
updated_at: "2026-08-27 09:41:36 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "Codex"
scope: two-tier-mutation-approval-fast-path
owner: Diane
user_story: "En tant qu'opératrice ShipGlows, je veux qu'une demande claire et bornée autorise directement ses quelques actions énumérables, indépendamment de leur caractère local ou distant et du niveau d'effort du modèle, tandis qu'un chantier inconnu ou directionnel reste supervisé."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/mutation-plan-approval.md
  - tools/test_mutation_plan_approval_contract.py
  - tests/windows/static-development-environment.ps1
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.AgentInstructions.psm1
  - skills/000-shipglows/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/entrypoint-routing.md
depends_on:
  - artifact: "skills/references/mutation-plan-approval.md"
    artifact_version: "1.16.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-14: routine branch and worktree operations need a much lighter approval surface."
  - "Operator decision 2026-08-14: retain a robust full contract for remote, destructive, ambiguous, or materially risky mutations."
  - "The existing universal contract requires four sections and strategic choices even for exact local reversible Git operations."
  - "Operator decision 2026-08-15: a second validation for a micro technical commit already covered by an approved chantier is unacceptable friction."
  - "Operator decision 2026-08-15: standalone `v` should be a canonical approval shortcut for the immediately preceding pending chantier plan."
  - "Operator correction 2026-08-27: modifying one exact file is not a chantier; the explicit request authorizes only its qualifying micro-mutation, while a chantier still requires one plan."
  - "Operator correction 2026-08-27: the boundary is request clarity, a few enumerable actions/files, and agent directional discretion—not local versus remote; explicit bounded edits, commits, and ordinary pushes need no duplicate validation, regardless of reasoning effort."
next_step: "/102-sg-start two-tier mutation approval fast path"
---

# Two-Tier Mutation Approval Fast Path

## Status

implemented — standard verification passed for the boundedness-based contract correction, focused proofs, public/operator surfaces, and synchronization of the five active Windows agent-instruction blocks; Git delivery remains pending.

## Minimal Behavior Contract

An explicit clear bounded request directly authorizes its few coherent enumerable actions and targets when the agent need not invent, propose, or select a material direction. This includes a targeted file modification, deterministic micro-fix, exact-scope commit, ordinary resolved push, or small explicit sequence; local versus remote and model reasoning effort do not alter the classification. The authority is limited to the request and does not authorize a chantier. `🧭 VALIDATION RAPIDE` is for bounded agent-proposed actions or almost-clear intent. `🧭 PLAN À VALIDER` is for unknown outcomes, unbounded action/target sets, or substantial analysis and directional choice. Force push and destructive or irreversible actions retain dedicated stricter gates.

## Success Behavior

- A safe switch to an exact existing branch may receive a one-line fast validation.
- Creating an exact branch/worktree from a resolved base may receive fast validation when collision and dirty-worktree safety are established.
- The initial imperative authorizes its clear bounded action set and never authorizes a chantier.
- A targeted file edit, exact-scope commit, ordinary resolved push, or small explicit sequence proceeds without a second validation prompt when every direct-authority condition holds.
- The same request receives the same classification at `low`, `medium`, `high`, and `xhigh` reasoning effort.
- A material change invalidates prior approval and requires a newly appropriate fast validation or full plan.
- Full-plan mutations retain the chantier opening, four sections, Paris time, and contextual strategic choices.
- Approval of a bounded technical implementation includes silent exact-scope local commits; their identifiers are reported at the next natural checkpoint.
- Standalone `v` or `V` approves the immediately preceding pending approval message only when its approval outcome is unambiguous and no intervening control or replacement exists.

## Error Behavior

- Missing or uncertain boundedness falls back to the full plan; the agent does not infer scope or direction.
- A bounded-looking request that reveals multiple material implementations, unbounded file families, or product, architecture, data, security, or permission direction stops before expansion and becomes a planned chantier.
- Force, destructive or irreversible actions, credentials, permissions, and unrelated effects retain dedicated safety gates; remoteness alone is never a chantier classifier.
- A fast validation must not hide multiple actions or an unresolved target behind a generic phrase.
- Approval for one target or action does not authorize another.

## Scope In

- Canonical two-tier approval contract and pressure scenarios.
- Router, lifecycle, partnership, packaged skill, agent-entrypoint, installer, workflow, and technical-documentation references that repeat the gate.
- Focused Python and Windows static regression checks.
- Cumulative commit and ordinary-push authority for bounded technical chantiers.
- Canonical bounded `v` approval shortcut.
- Clear bounded-request authority and its chantier boundary.

## Scope Out

- Mutation inferred beyond one explicit clear bounded request.
- Changes to destructive, production, credential, billing, publication, or irreversible gates.
- Force push, amend, rebase, squash, reset, tag, hook bypass, deployment, server mutation, packaging, or publishing outside the approved implementation delivery.

## Constraints And Invariants

- Fast-path eligibility is cumulative; every criterion must be proven before presenting it.
- Clear bounded-request authority is evaluated before validation and never expands into a chantier.
- Fast approval changes ceremony only, never authority, scope, or safety.
- An explicitly requested ordinary push to a resolved upstream may execute directly; force push retains stricter gates.
- Read-only exploration remains allowed before approval.
- Existing unrelated worktree changes must be preserved.
- Exact-scope technical commits preserve unrelated changes and require secret checks; editorial, mixed-scope, closure, and release commits need explicit inclusion.

## Test Contract

- Proof path: `scenario-first`.
- Automated proof: focused Python contract tests, Windows static contract test, metadata lint on changed metadata-bearing documents, and focused text scans.
- Pressure scenarios: `MAP-BOUNDED-REQUEST`, `MAP-BOUNDED-EXPANSION`, `MAP-EFFORT-INVARIANT`, `MAP-SMALL-CHANGE`, `MAP-FAST-SWITCH`, `MAP-FAST-WORKTREE`, `MAP-FAST-INELIGIBLE`, `MAP-FAST-REPLACEMENT`, `MAP-BOUNDED-PUSH`, `MAP-TECHNICAL-COMMIT`, `MAP-COMMIT-BOUNDARY`, and `MAP-V-SHORTCUT`.
- No browser, server, package, or external-service proof is needed because this is a local instruction-contract change.

## Acceptance Criteria

- [x] The canonical contract defines the two paths and cumulative fast eligibility.
- [x] The fast message is limited to one or two sentences with exact action, exact target, and main safety guarantee.
- [x] Full-plan form and strategic choices remain required for ineligible mutations.
- [x] Explicit ordinary push is mechanically asserted as direct when branch/upstream and scope are resolved; force push remains separately gated.
- [x] All named bounded-request, expansion, effort, fast-validation, Git, and approval-shortcut pressure scenarios are present and tested.
- [x] Distributed surfaces and Windows-installed instructions reflect the same boundary.
- [x] Focused tests and metadata lint pass.
- [x] Approved bounded technical work may be committed and ordinarily pushed without duplicate approval while unrelated, destructive, history-rewriting, and materially different effects remain gated.
- [x] Standalone `v` is accepted only as an immediate unambiguous response to the pending approval message and is inert in every other context.
- [x] One clear bounded request executes without another approval prompt and never authorizes a chantier.
- [x] An ordinary exact-scope commit or explicitly requested resolved push never receives its own approval prompt.

## Current Chantier Flow

`900-shipglows-core build` implemented clear bounded-request authority and kept the hard chantier boundary at unknown, unbounded, or materially directional work. `103-sg-verify` passed the focused contracts, metadata, Windows synchronization, skill audit, and budget checks. `104-sg-end` prepared closure with documentation and editorial surfaces updated; Git delivery remains pending.

## Skill Run History

- 2026-08-15 — `900-shipglows-core build`: translated the operator friction into `MAP-TECHNICAL-COMMIT` and `MAP-COMMIT-BOUNDARY`, propagated the rule through lifecycle/question/continuation doctrine, refreshed `706-continue`, and validated the focused contract, metadata, audit, and skill budget.
- 2026-08-15 — `900-shipglows-core build`: added and verified `MAP-V-SHORTCUT` so standalone `v` canonically approves only the immediately preceding unambiguous pending approval message; 76 focused contract/graph tests, metadata, audit, and budget checks passed.
- 2026-08-27 — `900-shipglows-core build`: operator clarified that an exact file micro-modification is not a chantier; started scenario-first repair so the request itself authorizes only that micro-mutation while a real chantier still requires one plan.
- 2026-08-27 — `103-sg-verify`: 28 mutation-contract tests, 4 strategic-choice tests, the Windows static regression, metadata lint across 11 governed artifacts, and direct checks of all five active agent-instruction blocks passed.
- 2026-08-27 — `104-sg-end` / `005-sg-ship`: implementation commit `96d5340` was pushed normally to `origin/codex/development-runtime`; four pre-existing unrelated dirty paths remained outside the commit.
- 2026-08-27 — `900-shipglows-core build`: operator replaced the local/remote micro-mutation boundary with clear bounded-request authority based on enumerable actions/targets and directional discretion; scenario-first implementation started with ordinary commit/push and effort invariance in scope.
- 2026-08-27 — `103-sg-verify`: standard verification passed 79 focused unit/contract scenarios, Windows static regression, 15-file metadata lint, active-agent instruction synchronization, skill audit, budget audit, and conservative contradiction scans; effort invariance is contract-level, not a multi-model runtime evaluation.
- 2026-08-27 — `104-sg-end`: closure bookkeeping is partial only because Git delivery is pending; documentation is updated across canonical runtime/workflow/operator surfaces, editorial is updated across README and public plugin guidance, and no archive or tracker mutation is required.
