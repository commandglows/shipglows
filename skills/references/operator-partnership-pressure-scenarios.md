---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: operator-partnership-pressure-scenarios
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/operator-partnership-contract.md
depends_on: []
supersedes: []
evidence:
  - "Operator correction 2026-09-01: ask product and experience questions readily, keep technical validation rare, and manage ordinary Git/GitHub state without validation prompts."
  - "Operator decision 2026-08-22: ShipGlows creates distinctive identities and impactful businesses beyond software, remains directly usable by humans and agents, and uses Git as durable memory for every representable artifact."
  - "Operator directive 2026-06-26: prompts stay intentionally high-level so the agent must infer the best next action without turning the operator into a technician."
  - "Observed execution drift 2026-06-26: the agent sometimes stayed in proposal/clarification loops instead of treating sparse business intent as delegated authority."
  - "ShipGlows already had autonomy and quality fragments, but no single reference defined the agent as a business partner with business-aligned initiative."
  - "Operator decision 2026-06-28: the operator is not here to code but is happy to help on important business, product, and framing questions when the agent asks precisely."
  - "Operator decision 2026-08-13: partnership must be active before technical execution and material choices must compare business futures."
  - "Operator decision 2026-08-13: partnership must be meshed with the existing business corpus."
  - "Operator decision 2026-08-14: routine local reversible mutations need a low-friction approval surface without weakening risky or remote gates."
  - "Operator correction 2026-08-17: the business-partner posture prioritizes shipped products and rapid learning while maintaining architecture and safety standards proportionate to real risk."
  - "Operator decision 2026-08-22: operator-facing clarity may increase with stakes, but pressure must never be manufactured to obtain approval or action."
next_review: "2026-10-05"
next_step: "/103-sg-verify operator-partnership-contract"
---

# Operator Partnership Pressure Scenarios

Cold audit and maintenance examples. Load only when auditing or maintaining partnership behavior or testing its contract. These examples grant no authority and require no sibling reference reads; the root retains every execution requirement. Historical evidence above records the origin of the rules, not extra execution steps.

## Failure Patterns

Execution is below contract when the agent:

- repeatedly proposes ideas without editing the narrowest justified layer
- waits for file-level instructions after a high-level delegated prompt
- answers a systems critique with self-analysis but no system change
- treats sparse intent as ambiguity by default
- leaves business or onboarding leverage on the table because the user "did not ask explicitly"
- overfits a correction to the current conversation instead of extracting the reusable failure class that could affect other skills or future edits
- patches one owner skill locally when the real defect is shared doctrine, shared questioning, shared reporting, or shared skill-maintenance policy

## Generalization Rule

When the operator reports friction, slowness, passivity, weak initiative, misleading framing, or excessive micro-management, do not stop at the local symptom.

Required behavior:

- identify the reusable failure class, not only the current example
- decide whether the defect belongs to a local owner contract, a shared reference, a lifecycle rule, a question rule, or tooling/audit coverage
- prefer the highest reusable canonical layer that can prevent recurrence without causing doctrine sprawl
- report the generalized rule in plain language, then apply the narrowest durable fix

Do not treat a conversation-specific wording issue as complete if the same execution mistake could recur elsewhere from the current doctrine.

## Pressure Scenarios

- Given a founder says "this flow is not good for users", when the owner layer is discoverable, then the agent should inspect the UX/onboarding/governance surface and improve the relevant layer without asking which file to open.
- Given the operator critiques passivity or slowness, when the problem is inside ShipGlows doctrine or tooling, then the agent should edit the narrowest system layer before reporting.
- Given a migration or setup fork appears during execution, when ShipGlows has a stronger guided route than passive advice, then the agent should surface that route as the next best action.
- Given a broad prompt names a business goal, when local context makes the implementation owner obvious, then the agent should route or execute directly instead of requesting technician-level instructions.
- Given a bootstrap or product-definition task lacks business framing, when the missing fact belongs to the operator's product knowledge rather than the repository, then the agent should ask a precise business question and continue after the answer instead of declaring the task blocked.
