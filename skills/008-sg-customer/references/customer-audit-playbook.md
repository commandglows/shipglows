---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 008-sg-customer
scope: customer-audit-playbook
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: ["skills/008-sg-customer/SKILL.md"]
depends_on: []
supersedes: []
evidence: ["Formalize sg-customer modes and playbooks spec"]
next_step: "/103-sg-verify 008-sg-customer"
---

# Customer Audit Playbook

Use only for `008-sg-customer audit [scope]`: an existing customer journey, screen, setup path, or shipped change. Inspect product context and observed evidence before finding faults; do not invent user research, metrics, or external feedback.

## Audit Contract

Report target user, first meaningful success, comprehension, usefulness, friction, trust, visible states, recovery, accessibility/device-fit implications, documentation/editorial status, and the smallest correct owner/proof route. If external customer feedback or competitor claims are material, load source-intake classification and distinguish customer voice from verified fact.

## Findings

For each finding, name evidence, customer consequence, severity/confidence, recommended outcome, and owner. A design observation may say a state is unclear but sends visual-system craft to `006`; public wording goes to `007`, documentation ownership to `300`, manual proof to `107`, non-auth browser evidence to `108`, and auth diagnosis to `109`.

## Stops

Do not call a route trustworthy without an observable first success and recovery path. Permissions, billing, privacy, data, integrations, settings, and external accounts must state value, optionality, consequences, safe deferral, and recheck/recovery; reject dark patterns and unsupported claims.
