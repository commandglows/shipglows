---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-13"
status: active
source_skill: 900-shipglows-core
scope: operator-facing-strategic-choices
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/intent-to-outcome-autonomy.md
  - skills/references/operator-partnership-contract.md
  - skills/references/mutation-plan-approval.md
  - skills/references/question-contract.md
  - skills/references/reporting-blocked-and-audit.md
  - skills/references/reporting-pressure-scenarios.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "2.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-13: plan and chantier choices must support long-horizon business steering rather than expose short-sighted technical controls."
  - "Operator clarification 2026-08-13: Questionner and Réorienter may remain short labels when selection triggers useful guided questions or concrete reorientation proposals."
  - "Operator decision 2026-08-13: the contract must activate through the common public métier autonomy path, not only at reporting boundaries."
next_review: "2026-09-13"
next_step: "/103-sg-verify strategic operator choices"
---

# Strategic Choice Contract

## Purpose

Operator-facing choices steer the business, product, customer promise, risk posture, investment, or durable priority. They do not outsource technical workflow supervision to the operator.

Apply this contract to material choices in mutation plans, user questions, unfinished or blocked chantier reports, and any final report that returns a decision to the operator. Keep routine reversible micro-decisions proportional; do not invent a strategy exercise when no business consequence differs.

## Material Choice Shape

When credible options lead to materially different futures, each primary option represents a distinct business direction rather than a task or internal next step. Explain proportionally:

- the business or product outcome sought;
- the customer, market, revenue, trust, cost, risk, or organizational effect that materially differs;
- the time horizon affected;
- the material trade-off, constraint, or opportunity cost;
- the condition that would make this direction preferable.

Name the recommended direction and explain why it best serves the governed product and current evidence. Do not recommend the easiest implementation merely because it is faster to execute.

Do not expose commands, files, packages, skills, lifecycle phases, agent topology, or technical implementation variants as operator choices unless they directly change a material business consequence; translate that consequence into plain language first.

## Interaction Controls

Short interaction labels such as `Questionner` and `Réorienter` are allowed. Their value comes from the guided follow-up after selection, so the initial label does not need to contain the full brief.

- After `Questionner`, ask one focused decision brief or a compact sequence of inseparable questions that reveals missing business truth, tests assumptions, or distinguishes the credible directions. Explain why the answer matters and recommend a default when evidence supports one.
- After `Réorienter`, proactively offer two or three concrete business or product directions with their outcome, horizon, and material trade-off. The agent must not ask the operator to invent the next direction from a blank page.
- After either control, continue guiding until a concrete direction is selected or the operator pauses or cancels. Selecting either never grants approval for mutation.

`Mettre en pause` and `Annuler` may also remain short when their immediate consequence is obvious. They are state controls, not strategic alternatives, and must not displace useful business directions when a material decision exists.

## Plan And Chantier Application

For a mutation plan whose objective already embodies one settled direction, the approval choice may stay concise while naming the business or product outcome being authorized. If the direction itself is unresolved, ask the strategic choice before presenting an implementation plan; do not hide competing visions behind one approval button.

For an unfinished or blocked chantier, propose specific business directions whenever evidence supports them. Generic continue, redirect, or pause controls are insufficient as the only choices when the run has revealed a real product, market, investment, scope, trust, or release decision.

## Pressure Scenarios

- `SC-BUSINESS-VISIONS`: competing directions state materially different outcomes, affected stakeholders, horizons, and trade-offs; package or workflow variants alone fail.
- `SC-QUESTIONNER`: selecting the short `Questionner` label produces focused, decision-relevant questions and useful framing before any mutation.
- `SC-REORIENTER`: selecting the short `Réorienter` label produces concrete alternative directions and a recommendation rather than “what do you want?”.
- `SC-NO-BLANK-PAGE`: the operator is never asked to invent strategy, alternatives, or implementation mechanics without agent-provided framing.
- `SC-PROPORTIONALITY`: a reversible micro-edit with no differing business consequence keeps a compact approval choice and does not fabricate strategic alternatives.
