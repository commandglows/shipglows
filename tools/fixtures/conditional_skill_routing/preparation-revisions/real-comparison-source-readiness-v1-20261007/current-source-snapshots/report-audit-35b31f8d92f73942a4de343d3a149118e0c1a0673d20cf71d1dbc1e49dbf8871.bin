---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-09-05"
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
  - "Extracted from reporting-contract.md in wave 13."
  - "Operator decision 2026-08-13: unfinished chantier choices must support strategic business steering and guided follow-up."
next_review: "2026-11-12"
next_step: none
---

# Reporting Blocked And Audit

## Failure And Partial Rule

Concise does not mean vague. State the blocking gate, redacted concrete evidence, safest next action, and whether current work can continue or ship. Translate internal gates into user consequences. Never claim completion when required proof is missing.

## Unfinished Chantier Choice

Continue a safely executable authorized unit before returning control; do not ask
for permission to continue it. If an operator decision, missing authority or
requested steering is needed, end the message
with a numbered, plain-language choice block. Apply the strategic-choice contract
already selected by the reporting owner; offer two or three genuine choices and recommend
the strongest responsible business direction. Choices must never expose skill names,
slash commands, lifecycle labels, internal owners, or agent topology.

For an external wait or unavailable proof with no operator choice, report the
evidence, remaining limit and recovery action without inventing alternatives.
Incomplete work stays incomplete. Unknown targets and new effects still require
resolution before execution; continuation never expands authority.

Use `Questionner` or `Réorienter` only for requested steering with useful guided
follow-up, not a generic continuation gate. Follow the reporting owner's response
instruction and compact layout. Completed work receives no unfinished-choice block.

## Audit Reports

Audit skills report findings first. In user mode include scope, clear/issues/blocked result, the few highest-severity findings, proof gaps, and `Chantier potentiel` when applicable. Keep large domain matrices only when comparison changes the decision. Detailed scoring, commands, assumptions, and handoff notes belong to agent mode.

## Recurrence-Claim Boundary

Report a local repair only for the cause and context actually tested and name known conditions that could reintroduce it. Do not extend it to other
projects, configurations, or future changes.

Do not say or imply “pour toujours”, “garanti”, “ne se reproduira pas”, or a semantic equivalent unless all three conditions are present: an explicit preventive invariant,
an invariant scope that covers exactly the claimed scope, and focused
mechanical proof that was run for that invariant. A generic lint, build, or
audit never proves that operational invariant on its own.
