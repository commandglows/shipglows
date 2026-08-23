---
artifact: workflow_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-02"
updated: "2026-08-22"
status: active
source_skill: 900-shipglows-core
scope: product-decision-traceability-and-change
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/guided-business-product-discovery.md
  - skills/references/atlas-cartography-lifecycle.md
  - skills/006-sg-design/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/101-sg-ready/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/104-sg-end/SKILL.md
  - skills/300-sg-docs/SKILL.md
  - skills/011-sg-pilotage/references/review-playbook.md
  - skills/references/progressive-clarity-and-agency-contract.md
depends_on:
  - artifact: skills/references/guided-business-product-discovery.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/atlas-cartography-lifecycle.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator approval 2026-08-02: reuse BMAD's change-impact, cross-artifact alignment, critical moments, traceability, focused elicitation and retrospective learning without its process weight."
  - "Local BMAD review 2026-08-02: useful patterns came from UX alignment, correct-course, journey/capability, emotional-response and retrospective workflows."
  - "Pilotage consolidation on 2026-08-03 transferred retrospective synthesis to 011-sg-pilotage review."
  - "Operator decision 2026-08-22: critical moments should increase clarity and recovery guidance with stakes without manufacturing emotional pressure."
next_step: "Apply this contract to material product decisions and Atlas-changing work."
---

# Product Decision Chain

## Purpose

Keep product intent, implementation and proof coherent while an application evolves. This contract adds relationships between existing canonical artifacts; it does not create a second product database, duplicate roadmap or new mandatory document family.

## Canonical Chain

For every material product decision, preserve the smallest useful path through:

```text
business goal
  → customer need
  → journey and critical moment
  → observable capability
  → Atlas function and/or surface
  → governing spec or accepted contract
  → implementation evidence and proof
```

Reuse stable IDs already owned by the business/product docs, Atlas, specs and proof artifacts. A node may be intentionally absent only with `not_applicable` plus a reason. Do not invent IDs for every sentence, DOM node, implementation function or test assertion.

Minimum trace fields wherever the decision is recorded:

- `decision_id` or existing stable artifact/spec ID;
- current statement and state (`confirmed`, `evidence_backed`, `hypothesis`, `unknown`, `superseded`);
- upstream reason IDs;
- downstream affected IDs;
- evidence references;
- preserved invariants;
- first unresolved decision, when any.

## Cross-Contract Coherence Gate

Before readiness or a material implementation, compare only the contracts touched by the work:

- business promise ↔ priority customer need;
- journey ↔ observable capabilities;
- capabilities ↔ Atlas functions/surfaces and delivery state;
- GTM claims ↔ product behavior and available proof;
- desired emotion/trust posture ↔ UX behavior and recovery paths;
- UX requirement ↔ architecture/runtime support;
- spec acceptance criteria ↔ implementation tasks and proof;
- protection state ↔ requested change and preserved dimensions.

Classify findings:

- `conflict`: two confirmed contracts disagree; blocks readiness/implementation;
- `orphan`: a material node has no justified upstream reason or downstream owner; blocks completion until linked, retired or marked not applicable;
- `gap`: a necessary contract is unknown; asks one operator-owned question or creates a scoped task;
- `warning`: coherence is plausible but evidence is weak; preserve explicitly for verification.

Absence of an irrelevant document is not a failure. UI-implied work without any UX/brand/experience authority is a gap; backend-only work does not fabricate one.

## Critical Experience Moments

For the priority journey, identify only the moments whose failure materially changes adoption, trust, conversion or retention:

- core action;
- first useful result or aha moment;
- trust decision;
- failure/error moment;
- recovery moment;
- repeat-value moment when retention matters.

For each selected moment record:

- user trigger and expected visible result;
- desired emotion and emotion to avoid;
- observable capability;
- linked Atlas function/surface IDs when available;
- acceptable failure/recovery behavior;
- success signal and proof;
- protection or focus consequence.

When a critical moment can affect trust, consent, access, money, data, safety, or recovery, apply `progressive-clarity-and-agency-contract.md`. Increase consequence visibility and recovery guidance with the real stakes; do not manufacture urgency merely to increase conversion or compliance.

These records inform design and Atlas priority. They do not assign Gold or Diamond automatically; only the operator approves those levels.

## Decision Change Protocol

When the operator changes a confirmed product direction, do not patch the nearest file immediately.

1. Name the trigger and evidence.
2. Show `before → after` in plain language.
3. Traverse the canonical chain in both directions and list affected contracts, IDs, tasks and proofs.
4. Separate direct changes, dependent review and preserved invariants.
5. Classify the change as `minor`, `material` or `fundamental` from product impact, not file count.
6. Propose exact contract edits and any scope/roadmap/proof consequences.
7. Ask for operator confirmation only when the new product promise, priority, cost, risk or irreversible behavior is not already explicit.
8. Apply approved changes in canonical-source order, then update dependents and verify the chain.

Never delete the previous decision silently. Mark it `superseded`, link its replacement and preserve historical evidence/baselines needed for recovery.

## Focused Deepening

When a decision is vague, risky or contradictory, choose at most one relevant lens:

- alternative customer or stakeholder perspective;
- failure/recovery and trust;
- current alternative/competitor contrast;
- first principles;
- pre-mortem;
- technical feasibility or proof challenge.

Show the resulting improvement and return to the ordinary `Confirmer`, `Corriger`, `Approfondir` loop. Do not expose a permanent method menu, simulate a committee or run role-play as a substitute for evidence.

## Learning Loop

At a material review or closure, capture only lessons supported by delivery evidence, customer feedback, failed proof, rework or an explicit operator decision.

Each reusable lesson records:

- observed outcome and evidence;
- causal interpretation, clearly labelled if still a hypothesis;
- applicability boundary;
- keep/change/retire decision;
- next-project or next-chantier verification hook;
- candidate owner layer when the lesson may improve shared ShipGlows doctrine.

At the next related chantier, check whether the prior lesson was applied and whether it helped. Do not promote a project-local lesson into a shared skill merely because it sounds generally useful; require a recurring failure class or explicit operator approval plus focused proof.

## Owner Routing

- Guided discovery and canonical project docs: `300-sg-docs` / `305-sg-init`.
- Experience principles and critical moments: `006-sg-design` with product/customer context.
- Trace chain and change contract in a spec: `100-sg-spec`.
- Cross-contract coherence decision: `101-sg-ready`.
- Pre-write impact traversal and canonical-order application: `102-sg-start`.
- Actual-chain and proof coherence: `103-sg-verify`.
- Evidence-backed lesson capture: `104-sg-end` and retrospective synthesis by `011-sg-pilotage review`.

## Pressure Scenarios

- `ATLAS-019 DECISION-CHANGE`: a confirmed customer or product decision changes; before code, ShipGlows shows before/after, traverses affected contracts/IDs/proofs and names preserved invariants.
- `ATLAS-020 COHERENCE-CONFLICT`: a GTM promise contradicts product capability or proof; readiness reports `conflict` and cannot pass silently.
- `ATLAS-021 CRITICAL-MOMENT`: a first-value or recovery moment maps emotion, visible result, capability, Atlas IDs and proof without auto-approving quality.
- `ATLAS-022 ORPHAN-TRACE`: a material function/surface/spec task with no customer reason or downstream proof is linked, retired or justified before completion.
- `ATLAS-023 ONE-LENS`: vague or risky framing triggers one relevant deepening lens, then returns to confirmation; no method dump appears.
- `ATLAS-024 LESSON-REPLAY`: a proved lesson records applicability and a future check; the next related review verifies whether it was applied and useful.
- `ATLAS-025 LIGHTWEIGHT`: ShipGlows reuses existing docs, IDs, specs and Atlas; it does not create role-play agents, party mode, permanent A/P/C menus or a parallel roadmap.

## Non-Goals

- No simulated stakeholder theatre as decision evidence.
- No exhaustive document generation merely to satisfy a process.
- No mandatory enterprise hierarchy, sprint vocabulary or time estimates.
- No automatic propagation that overwrites operator-confirmed product intent.
- No replacement of specs, Atlas, Git history, proof artifacts or project trackers.
