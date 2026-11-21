---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-11-21"
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
  - "Operator decision 2026-08-16: completed chantiers may offer Approfondir beside Réorienter when the delivered result supports useful follow-up."
next_review: "2026-09-13"
next_step: "/103-sg-verify strategic operator choices"
---

# Strategic Choice Contract

## Purpose

Operator-facing choices steer business, product, customer promise, risk posture, investment, or durable priority; they never outsource technical workflow supervision to the operator.

Apply it to material choices in mutation plans, user questions, unfinished or blocked chantier reports, and final reports returning a decision. Keep routine reversible micro-decisions proportional; invent no strategy exercise when no business consequence differs.

## Material Choice Shape

When credible options lead to materially different futures, each primary option is a distinct business direction, not a task or internal step. Explain proportionally:

- the business or product outcome sought;
- the customer, market, revenue, trust, cost, risk, or organizational effect that materially differs;
- the time horizon affected;
- the material trade-off, constraint, or opportunity cost;
- the condition that would make this direction preferable.

Name the recommended direction and why it best serves the governed product and current evidence. Never recommend the easiest implementation merely because it is faster.

Do not expose commands, files, packages, skills, lifecycle phases, agent topology, or implementation variants as choices unless they change a material business consequence; translate that consequence into plain language first.

## Interaction Controls

Short labels (`Questionner`, `Approfondir`, `Réorienter`) are allowed; their value lies in the guided follow-up after selection, so the label need not carry the full brief.

- After `Questionner`, ask one focused decision brief or a compact sequence of inseparable questions that reveals missing business truth, tests assumptions, or separates credible directions; explain why the answer matters and recommend a default when evidence supports one.
- After `Approfondir`, examine evidence-backed opportunities, risks, assumptions, and lessons in the delivered result, then recommend the most valuable deeper question or extension. Do not silently reopen the completed chantier.
- After `Réorienter`, proactively offer two or three concrete business or product directions with their outcome, horizon, and material trade-off; the agent must not ask the operator to invent the next direction from a blank page.
- After any control, continue guiding until a concrete direction is selected or the operator pauses or cancels. Selecting a control never grants approval for mutation.

`Mettre en pause` and `Annuler` may stay short when obvious; they are state controls, not strategic alternatives, and must not displace useful directions when a material decision exists.

## Plan And Chantier Application

For a mutation plan whose objective embodies one settled direction, the approval choice may stay concise while naming the business or product outcome authorized. If the direction is unresolved, ask the strategic choice before presenting an implementation plan; never hide competing visions behind one approval button.

For an unfinished or blocked chantier, propose specific business directions when evidence supports them; generic continue, redirect, or pause controls alone are insufficient when the run revealed a real product, market, investment, scope, trust, or release decision.

For a completed chantier, offer `Approfondir` and `Réorienter` only when the delivered result has a useful continuation surface; they leave the truthful completed state unchanged, so omit them when ceremonial.

## Pressure Scenarios

- `SC-BUSINESS-VISIONS`: competing directions differ in outcome, stakeholders, horizon, and trade-off; package or workflow variants alone fail.
- `SC-QUESTIONNER`: `Questionner` yields focused, decision-relevant questions and framing before any mutation.
- `SC-APPROFONDIR`: `Approfondir` deepens evidence-backed opportunities, risks, assumptions, and lessons without silently reopening completed delivery.
- `SC-REORIENTER`: `Réorienter` yields concrete alternative directions and a recommendation, not “what do you want?”.
- `SC-NO-BLANK-PAGE`: the operator is never asked to invent strategy, alternatives, or mechanics without agent framing.
- `SC-PROPORTIONALITY`: clear bounded requests execute with no approval choices; bounded agent-proposed actions keep compact confirmation; unknown, unbounded, or materially directional work gets contextual choices, never fabricated alternatives.
