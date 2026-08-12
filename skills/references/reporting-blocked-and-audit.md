---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
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
depends_on: []
supersedes: []
evidence:
  - "Extracted from reporting-contract.md in wave 13."
next_review: "2026-11-12"
next_step: none
---

# Reporting Blocked And Audit

## Failure And Partial Rule

Concise does not mean vague. State the blocking gate, redacted concrete evidence, safest next action, and whether current work can continue or ship. Translate internal gates into user consequences. Never claim completion when required proof is missing.

## Unfinished Chantier Choice

When a user-facing final report returns control while the chantier remains unfinished, end the message
with a numbered, plain-language choice block. Use two or three outcome choices and recommend the safest current direction. The choices must never expose skill names, slash commands, lifecycle labels, internal owners, or agent topology.

When no material decision is missing, use:

```text
1. ✅ Continuer comme prévu — le travail continue avec la priorité actuelle.
2. 🧭 Réorienter — indique ce que tu veux changer ou privilégier.
3. ⏸ Mettre en pause — le chantier reste conservé pour plus tard.

Réponds avec le numéro ou indique une autre direction.
```

Replace generic choices with a specific business/product/safety/scope/release/risk decision when one is actually required. Completed work receives no choice block. A blocked chantier receives specific safe recovery choices.

## Audit Reports

Audit skills report findings first. In user mode include scope, clear/issues/blocked result, the few highest-severity findings, proof gaps, and `Chantier potentiel` when applicable. Keep large domain matrices only when comparison changes the decision. Detailed scoring, commands, assumptions, and handoff notes belong to agent mode.

## Recurrence-Claim Boundary

Report a local repair only for the cause and context actually tested and name known conditions that could reintroduce it. Do not extend it to other
projects, configurations, or future changes.

Do not say or imply “pour toujours”, “garanti”, “ne se reproduira pas”, or a semantic equivalent unless all three conditions are present: an explicit preventive invariant,
an invariant scope that covers exactly the claimed scope, and focused
mechanical proof that was run for that invariant. A generic lint, build, or
audit never proves that operational invariant on its own.
