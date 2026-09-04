---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: question-contract-maintenance-evidence
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/question-contract.md
depends_on: []
supersedes: []
evidence:
  - "Approved common-path loading pilot; existing requirements relocated without changing authority."
next_review: "2026-10-05"
next_step: "Verify question gates."
---

# Question Contract Maintenance Evidence

Cold reference: use only to audit or maintain question behavior, never for an
ordinary question. Scenario descriptions are proof criteria, not extra runtime loaders.

## Historical Decisions

  - "Operator correction 2026-09-01: product and experience questions are proactive partnership; technical validation is exceptional, and ordinary Git/GitHub stewardship never asks for validation."
  - "Operator decision 2026-08-15: do not ask a duplicate question before an exact-scope local technical commit already covered by chantier approval."
  - "User request 2026-05-04: skill questions should be numbered, explain why, include helpful icons, and identify the recommended answer."
  - "User clarification 2026-05-04: a default is acceptable only when it is compatible with the current technical/product/editorial context and current best practices."
  - "Operator correction 2026-08-17: recommended defaults should ship useful product value quickly while preserving coherent architecture and non-negotiable safety."
  - "User decision 2026-06-09: skills should be almost fully autonomous and professionally effective, asking fewer questions and only in plain decision language when the operator truly owns the decision."
  - "User decision 2026-06-10: autonomy and question rules should be compact enough to preserve the signal."
  - "User decision 2026-06-28: the operator is not here to code, but is happy to answer precise business-critical questions that the repository cannot answer."
  - "User decision 2026-07-15: a greenfield product stack must be chosen with the operator at the product-consequence level instead of being silently fixed by the agent."
  - "Operator correction 2026-07-17: greenfield platform scope must be established before stack options; ShipGlows must not silently exclude mobile applications and thereby omit Flutter from the decision."
  - "Operator correction 2026-07-17: ShipGlows must apply the established Astro-site and Flutter-app preference before proposing a broad greenfield stack comparison."
  - "Operator clarification 2026-07-17: Astro/Vercel and cross-platform Flutter are first recommendations; ShipGlows must not default a new app to one mobile platform when one codebase can cover Web, iOS, and Android."
  - "Operator correction 2026-07-18: unfinished-chantier choices stay at the outcome and priority layer; internal skills and commands remain agent-owned."
  - "Operator clarification 2026-08-13: short Questionner and Réorienter labels remain valid when the next agent turn actively guides the decision."
  - "Operator decision 2026-08-13: material gaps in governing context may trigger a guided authority question and authorized canonical update."

## Pressure Scenarios

- `SSRP-005 safe default`: when the safe professional default is clear, reversible, in scope, and verifiable, the skill proceeds and reports the assumption only if useful.
- `SSRP-006 required decision`: when the answer changes security, data, product behavior, validation confidence, closure, or ship risk, the skill asks one numbered plain-language question with a recommended option.
- `SSRP-007 operator-owned business truth`: when the missing fact is business, audience, product, or framing context that the operator uniquely knows and the repository cannot prove, the skill asks one precise numbered question and continues after the answer instead of calling the task blocked.
- `SSRP-008 greenfield stack partnership`: given the operator asks to create a new product with no accepted stack, when the framework, hosting, data, or provider direction affects ongoing cost, control, maintenance, portability, or lock-in, then the agent presents one recommended product-level stack direction with practical alternatives and obtains a numbered decision before the spec freezes it.
- `SSRP-009 greenfield platform footprint`: given the operator asks for a new Internet product and does not explicitly accept or reject native apps, when platform scope would change the credible framework options, then the agent establishes web/iOS/Android/desktop intent before blueprint matching or stack recommendation and does not silently place mobile apps in `Scope Out`.
- `SSRP-010 preferred stack preset`: given the established footprint includes a public SEO site plus web/iOS/Android application surfaces, when no project constraint contradicts the defaults, then the agent applies Astro plus Flutter with Vercel web hosting before blueprint matching and asks only about uncovered material providers or justified exceptions.
- `SSRP-011 cross-platform first`: given the operator asks for a new mobile or browser application without a durable single-platform restriction, then the agent first recommends one Flutter codebase for Web, iOS, and Android and keeps Astro on Vercel for any separate public SEO surface.
- `SSRP-012 guided short controls`: selecting `Questionner`, `Approfondir`, or `Réorienter` triggers the shared strategic contract's guided follow-up; no selection authorizes mutation or returns a blank question to the operator.
- `SSRP-014 governing-context recovery`: a material governing gap produces evidence, a proposed interpretation, one authority-owned question, an authorized canonical update, and automatic return to the original chantier; agent-researchable facts are never offloaded.
- `SSRP-015 proactive product experience question`: a non-blocking but useful audience, journey, promise, priority, or product nuance is asked precisely instead of suppressed by a generic ask-less rule.
- `SSRP-016 technical question restraint`: a purely technical question is asked only after evidence, architecture, tests, and standards fail to resolve materially different safe directions.
- `SSRP-017 question-is-not-validation`: asking or answering a product/experience question never authorizes a new mutation or expands an approved scope.
- `SSRP-018 no-git-validation-question`: ordinary commit, push, synchronization, safe reconciliation, and proven temporary-artifact cleanup are autonomous Git stewardship, never operator validation questions.
