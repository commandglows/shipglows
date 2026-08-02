---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "ShipGlows"
created: "2026-06-29"
created_at: "2026-06-29 00:00:00 UTC"
updated: "2026-06-29"
updated_at: "2026-06-29 00:00:00 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "Codex GPT-5"
scope: "skill-maintenance"
owner: "Diane"
user_story: "En tant qu'utilisatrice ShipGlows, je veux que les skills de cadrage, pilotage et exploration chargent explicitement la doctrine opérateur/questions et qu'un garde-fou détecte les oublis, afin que ShipGlows pose les bonnes questions métier au lieu de se déclarer bloqué trop tôt."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/002-sg-maintain/SKILL.md"
  - "skills/003-sg-bug/SKILL.md"
  - "skills/007-sg-content/SKILL.md"
  - "skills/702-sg-priorities/SKILL.md"
  - "skills/705-sg-conversation-audit/SKILL.md"
  - "skills/references/question-contract.md"
  - "skills/references/operator-partnership-contract.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "shipglows_data/technical/code-docs-map.md"
depends_on:
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/operator-partnership-contract.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.23.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-06-28: the operator is not here to code but is happy to answer important business, product, and framing questions when asked precisely."
  - "Implemented 2026-06-28: shared doctrine added to question-contract and operator-partnership-contract, plus first propagation wave across 000, 001, 009, 100, 302, 305, 700."
  - "User follow-up 2026-06-28: many places still deserve a link toward this reference."
next_step: "/101-sg-ready operator-partnership-doctrine-propagation-and-coverage-guard"
---

# Spec: Operator Partnership Doctrine Propagation And Coverage Guard

🟠 [ShipGlows] spec: Operator Partnership Doctrine Propagation And Coverage Guard | status: draft | path: shipglows_data/workflow/specs/operator-partnership-doctrine-propagation-and-coverage-guard.md | next: /101-sg-ready operator-partnership-doctrine-propagation-and-coverage-guard

## Title

Operator Partnership Doctrine Propagation And Coverage Guard

## Status

Draft.

The direction is clear enough to specify. The expected implementation path is bounded skill-maintenance work inside ShipGlows, with no external-doc dependency. Readiness should focus on target-skill list, acceptance criteria, and the automation boundary.

## User Story

En tant qu'utilisatrice ShipGlows, je veux que les skills de cadrage, pilotage et exploration chargent explicitement la doctrine opérateur/questions et qu'un garde-fou détecte les oublis, afin que ShipGlows pose les bonnes questions métier au lieu de se déclarer bloqué trop tôt.

## Minimal Behavior Contract

The selected ShipGlows skills that frequently frame work, ask questions, or decide blocked states must explicitly load `skills/references/question-contract.md` and/or `skills/references/operator-partnership-contract.md` when their behavior depends on user-facing questions or operator-owned business truth. A lightweight coverage guard must make missing links visible during ShipGlows maintenance, without forcing every skill in the repo to load both references indiscriminately.

## Success Behavior

- Preconditions: shared doctrine references already exist and are active.
- Trigger: ShipGlows skill-maintenance work targets the next propagation wave after the initial doctrine rollout.
- User/operator result: skills that commonly frame, prioritize, maintain, or classify work no longer default to premature `blocked` outcomes when one precise business/product/framing question would unlock progress.
- System effect: doctrine links become explicit in the remaining high-risk skills, and a small validation surface catches future omissions in targeted categories.
- Success proof: targeted `rg` checks, skill budget audit, metadata lint for touched docs/references, and any lightweight automation introduced for doctrine coverage.

## Error Behavior

- If a target skill does not ask user-facing questions or does not depend on operator-owned business truth, it must not be forced to load both references just to satisfy a blanket rule.
- If a proposed guard would create noisy false positives across low-risk or purely atomic skills, scope it down to the high-risk skill families instead of weakening the doctrine.
- If a target skill already has equivalent explicit loading, preserve the existing correct pattern and avoid churn-only edits.

## Problem

The shared operator/question doctrine now exists, and a first propagation wave already updated the main router, build/spec/init/help/explore surfaces. The remaining risk is uneven adoption: some skills that still frame work, ask material questions, or classify blocked states may continue to behave as if business framing gaps are generic blockers instead of operator-owned truth that should be requested precisely. Without a visible coverage guard, future skill edits can regress this behavior silently.

## Solution

Run a second bounded propagation wave across the highest-value remaining skills, then add a minimal doctrine-coverage check or documented validation pattern that makes missing explicit links visible in future ShipGlows maintenance. Keep the guard narrow, pragmatic, and category-aware rather than universal.

## Scope In

- Update the next propagation-wave skills with explicit doctrine links where behavior justifies them.
- Define the target skill set for this wave, starting from high-risk framing/pilotage/content/bug-maintenance owners such as `002-sg-maintain`, `003-sg-bug`, `007-sg-content`, `702-sg-priorities`, and `705-sg-conversation-audit`.
- Update shared technical docs or maps when propagation or validation coverage changes.
- Add a lightweight doctrine-coverage guard, audit command, or check recipe for future maintenance.

## Scope Out

- Rewriting every skill in the repository.
- Forcing doctrine links into low-risk atomic skills that never ask user-facing questions.
- Changing invocation keys, public promises unrelated to operator collaboration, or broad lifecycle doctrine outside this operator/question topic.
- Building a heavy lint framework that costs more maintenance than the regression it prevents.

## Constraints

- Internal skill contracts stay in English.
- The propagation should remain additive and compact.
- The coverage guard must be easy to run during ShipGlows maintenance and should not depend on fragile heuristics that classify all skills identically.
- Respect existing unrelated dirty files in the ShipGlows worktree.

## Test Contract

Proof path: `scenario-first`.

Pressure scenario: a user asks for bootstrap, prioritization, bug handling, or content/system framing where the repository lacks one business/product/audience fact that the operator can answer. The relevant skill should explicitly load the shared doctrine, ask one precise numbered decision question, and continue after the answer rather than reporting a generic blocked state.

Guard scenario: a future edit adds or changes a question-heavy owner skill but forgets to reference the doctrine. The lightweight coverage guard should flag that omission in a focused, maintainable way.

## Dependencies

- `skills/references/question-contract.md`
- `skills/references/operator-partnership-contract.md`
- `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `shipglows_data/technical/code-docs-map.md`
- `skills/009-sg-skill-build/SKILL.md`

Fresh external docs: `fresh-docs not needed` — this chantier is governed by local ShipGlows skill contracts and technical docs, not unstable external framework behavior.

## Invariants

- The operator is not treated as a fallback technician.
- Skills still ask few questions; propagation must not encourage noisy interrogation.
- Blocking remains valid for true safety, scope, permission, or integrity boundaries.
- Shared references remain the canonical doctrine; skills should link to them, not duplicate them.

## Links & Consequences

- A wider doctrine propagation reduces premature blocked states in business/product framing work.
- `009-sg-skill-build` and future refresh/maintenance work gain a clear validation target for operator-collaboration behavior.
- Technical docs must reflect that operator-collaboration doctrine is now a mapped maintenance surface, not just an implicit expectation.

## Documentation Coherence

Documentation impact is expected for any touched skill docs, shared technical docs, and validation mapping if a new coverage check is introduced. Public-site updates are only needed if the changed skills have visible public promises affected by this doctrine.

## Edge Cases

- Some skills may need only `question-contract.md`, not `operator-partnership-contract.md`, when they ask user-facing questions but do not rely on business-framing truth.
- Some skills may need only `operator-partnership-contract.md` when the main change is delegated-intent interpretation rather than a formal question gate.
- The coverage guard should allow documented exceptions for purely mechanical, non-interactive, or proof-only skills.

## Implementation Tasks

- [ ] Task 1: Finalize the propagation-wave target list.
  - Files: target `skills/*/SKILL.md`
  - Action: confirm which remaining high-risk skills need explicit doctrine links in this wave.
  - Depends on: None.
  - Validate with: focused `rg` inventory over target skills.

- [ ] Task 2: Propagate doctrine links to the selected skills.
  - Files: selected `skills/*/SKILL.md`
  - Action: add required-reference lines and compact execution/stop-condition wording where operator-owned business truth should prevent premature blocked states.
  - Depends on: Task 1.
  - Validate with: focused `rg` checks for doctrine references and wording.

- [ ] Task 3: Add the lightweight coverage guard.
  - Files: `tools/*` or shared docs/check recipes, depending on the smallest maintainable implementation.
  - Action: introduce a focused validation surface that detects missing doctrine links in the targeted skill families.
  - Depends on: Task 1.
  - Validate with: the new guard itself plus a bounded proof case.

- [ ] Task 4: Update mapped technical documentation.
  - Files: `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/technical/code-docs-map.md`, and any directly impacted governance doc.
  - Action: record the expanded doctrine coverage and validation expectations.
  - Depends on: Tasks 2-3.
  - Validate with: metadata lint and focused `rg` checks.

- [ ] Task 5: Run ShipGlows validation for the chantier.
  - Files: changed surfaces.
  - Action: run budget audit, metadata lint, doctrine coverage checks, and focused text validation.
  - Depends on: Tasks 2-4.
  - Validate with: validation commands in `Test Strategy`.

## Acceptance Criteria

- [ ] The selected propagation-wave skills explicitly load the appropriate shared doctrine reference(s).
- [ ] At least one maintenance/bug/content/pilotage skill family is covered beyond the initial first wave.
- [ ] The changed skills no longer frame missing business/product/audience truth as a generic blocker when one precise operator question can resolve it.
- [ ] A lightweight doctrine-coverage guard or equivalent validation recipe exists and is documented.
- [ ] Technical docs and mapping surfaces reflect the new maintenance expectation.
- [ ] Validation passes or any residual exception is explicitly documented.

## Test Strategy

Validation commands:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/operator-partnership-doctrine-propagation-and-coverage-guard.md shipglows_data/technical/skill-runtime-and-lifecycle.md shipglows_data/technical/code-docs-map.md
rg -n "question-contract|operator-partnership-contract|operator-owned|business|framing|blocked" skills/002-sg-maintain/SKILL.md skills/003-sg-bug/SKILL.md skills/007-sg-content/SKILL.md skills/702-sg-priorities/SKILL.md skills/705-sg-conversation-audit/SKILL.md
```

If a new automation guard is introduced, add its canonical validation command here and use it in verify.

## Risks

- Over-propagation can turn the doctrine into cargo-cult boilerplate. Mitigation: keep the target list deliberate and behavior-based.
- A noisy lint/check can create maintenance friction and be ignored. Mitigation: prefer a narrow guard over a global mandatory rule.
- Some skills may already imply the doctrine through shared references. Mitigation: document exceptions rather than duplicating meaning blindly.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-29 00:00:00 UTC | 100-sg-spec | Codex GPT-5 | Created the chantier spec for the second propagation wave of operator/question doctrine links and a lightweight coverage guard. | implemented | /101-sg-ready operator-partnership-doctrine-propagation-and-coverage-guard |

## Current Chantier Flow

- `100-sg-spec`: implemented; durable spec created for the next doctrine propagation wave.
- `101-sg-ready`: pending.
- `102-sg-start`: pending.
- `103-sg-verify`: pending.
- `104-sg-end`: pending.
- `005-sg-ship`: pending.
