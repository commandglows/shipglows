---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-08-13"
status: active
source_skill: 900-shipglows-core
scope: decision-quality-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/decision-quality-implementation-discipline.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/spec-driven-development-discipline.md
  - skills/references/master-delegation-semantics.md
  - skills/references/operator-partnership-contract.md
  - skills/references/question-contract.md
  - skills/references/design-system-token-contract.md
  - skills/references/skill-instruction-layering.md
  - tools/test_industrial_excellence_contract.py
depends_on: []
supersedes: []
evidence:
  - "Wave 15 preserves the universal decision gates in the canonical path and moves implementation pressure detail to one direct conditional leaf."
  - "Operator directives prioritize correctness, security, relevant performance, excellence, durability, and agent-gathered proof before speed or convenience."
next_review: "2026-09-12"
next_step: "/103-sg-verify decision-quality-contract"
---

# Decision Quality Contract

## Purpose

Set the mandatory quality decision for ShipGlows work. Speed, cost, and convenience matter only after the quality bar.

## Decision Quality Baseline

Optimize, in order appropriate to the risk, for:

1. correctness and reliability against the accepted outcome;
2. security, privacy, permissions, tenant isolation, data safety, and abuse resistance;
3. performance and operational robustness where latency, throughput, resources, reliability, or trust can be affected;
4. maintainability, clarity, durability, upgradeability, and future evolution;
5. professional excellence, current proven practice, coherent architecture and UX/API ergonomics;
6. proof proportional to the claim and cost of error.

Choose cheaper, faster, simpler, or smaller options only when they are quality-equivalent across the applicable metrics.

`Smallest safe path` is the smallest complete professional implementation preserving product, security, relevant performance, maintainability, evolution, and matching proof. Small blast radius is good; shortcut quality is not.

## Industrial Excellence Gate

`industrial-grade` completion scales with consequence. Work merely functional, unintentionally generic for the accepted product, fragile, cluttered, or with unresolved provisional elements presented as final is `partial`; complexity is not excellence. NASA, government, ANSSI, RGAA, and SecNumCloud claims require a framework-specific scoped audit and direct evidence.

## Structure Replacement Fit

A new rule, tool, layer, dependency, or process must replace a weak point, manual step, ambiguity, drift, or maintenance burden. If it only adds structure without a quality-equivalent reduction elsewhere, do not add it.

## Fast Fix Shortcut Gate

A change fails this gate when it hides root cause, bypasses the owner or durable structure, weakens proof, or leaves an incoherent exception. Use `root cause -> owner boundary -> smallest complete professional fix -> matching proof`. Label unavoidable temporary mitigation honestly and route durable follow-up; never report mitigation as completion.

Load `skills/references/decision-quality-implementation-discipline.md` only when implementation, repair, refactoring, mitigation, library/tool choice, or shortcut pressure requires the detailed discipline.

## Safety Gate

Stop or ask before a choice changes security, privacy, permissions, tenant boundaries, data handling, destructive behavior, secrets, irreversible state, or external side effects without authority. Never trade these boundaries or their required proof for speed, cost, or convenience.

## Product Gate

Ask one targeted operator question when the high-quality routes materially differ in product promise, public behavior, architecture/provider, data model, migration, pricing/claims, material cost, or irreversible business posture. Recommend the strongest professional default. Load `question-contract.md` and, for product meaning or acceptance, `product-decision-chain.md`.

## Operator Autonomy Gate

Gather safe evidence, diagnostics, logs, project context, and runnable proof before asking the operator. Sparse intent normally delegates diagnosis and localization; missing file paths or commands are not ambiguity. Ask only for a real decision, secret, privileged/manual-only evidence, unavailable environment, or operator-owned business truth. Load `operator-partnership-contract.md` only for broader partnership or initiative decisions.

## Followability Gate

Before completion, verify that a fresh agent can identify the owner, next required action, conditional reference, stop boundary, and proof from the activation path. If not, keep one compact directive at the owner layer and move detail to the narrowest direct reference. Skill-contract changes load `skill-instruction-layering.md` for the full gate.

## Conditional Routes

- UI, UX, layout, theme, responsive, motion, component, keyboard/IME, or visual work loads `skills/references/design-system-token-contract.md`; unexplained hardcoded visual values fail or remain partial.
- Model or delegated execution loads its dedicated routing/delegation authority while preserving this baseline.
- Conditional detail references load directly from the owner decision and never chain through sibling leaves.

Never present a lower-quality shortcut as a virtue.
