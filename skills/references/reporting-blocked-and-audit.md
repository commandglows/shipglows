---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-09-04"
status: active
source_skill: 900-shipglows-core
scope: reporting-blocked-and-audit
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/strategic-choice-contract.md
depends_on:
  - artifact: "skills/references/strategic-choice-contract.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-09-03: partial, blocked, audit, and decision reports use the shared compact labelled rows with blank-line separation."
  - "Extracted from reporting-contract.md in wave 13."
  - "Operator decision 2026-08-13: unfinished chantier choices must support strategic business steering and guided follow-up."
  - "Operator correction 2026-09-04: unfinished state alone does not manufacture a choice; numbered options require a real operator-owned decision with distinct consequences."
next_review: "2026-11-12"
next_step: none
---

# Reporting Blocked And Audit

## Failure And Partial Rule

Concise does not mean vague. State the blocking gate, redacted concrete evidence, safest next action, and whether current work can continue or ship. Translate internal gates into user consequences. Never claim completion when required proof is missing.

Apply the universal compact user layout from `reporting-contract.md`: render the current state as `✨ RÉSULTAT :` or `🔨 PROGRESSION :`, evidence as `🧪 PREUVES`, the blocker or residual gap as `⚠️ LIMITES`, continuity as `🧠 CONTEXTE`, and recovery or decision framing as `🧭 SUITE`. Keep each label and its content on one line and separate labelled rows with exactly one blank line. Omit inapplicable rows rather than printing empty placeholders.

## Unfinished Chantier Choice

First decide why control must return. Use a numbered, plain-language choice block only when the operator owns a real unresolved decision and two or three credible directions have distinct product, customer, market, investment, scope, trust, release, or risk consequences. Introduce those options with the blank-line-separated `🧭 SUITE` row, load `skills/references/strategic-choice-contract.md`, and recommend the strongest responsible direction. The choices must never expose skill names, slash commands, lifecycle labels, internal owners, or agent topology.

When no material operator decision is missing, do not manufacture a menu. Continue authorized agent-runnable work. If control must return for one required recovery action or fact, state that exact action or fact directly. If one diagnosed blocker has no meaningful alternative, report its recovery condition without padding it into multiple choices. A completed chantier receives no unfinished-choice block; its mandatory SUITE may still identify a separate grounded business improvement without reopening the chantier.

Short `Questionner`, `Approfondir`, or `Réorienter` controls are optional guided exploration affordances, not substitutes for an unresolved decision. Use them only when the current result exposes a useful exploration surface; selecting one triggers active guided follow-up and grants no mutation authority.

## Audit Reports

Audit skills report findings first. In user mode apply the shared compact labelled rows and blank-line separation; include scope, clear/issues/blocked result, the few highest-severity findings, proof gaps, and `Chantier potentiel` when applicable. Keep large domain matrices only when comparison changes the decision. Detailed scoring, commands, assumptions, and handoff notes belong to agent mode.

## Recurrence-Claim Boundary

Report a local repair only for the cause and context actually tested and name known conditions that could reintroduce it. Do not extend it to other
projects, configurations, or future changes.

Do not say or imply “pour toujours”, “garanti”, “ne se reproduira pas”, or a semantic equivalent unless all three conditions are present: an explicit preventive invariant,
an invariant scope that covers exactly the claimed scope, and focused
mechanical proof that was run for that invariant. A generic lint, build, or
audit never proves that operational invariant on its own.
