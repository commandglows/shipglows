---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 008-sg-customer
scope: customer-flow-playbook
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

# Customer Flow Playbook

Use only for `008-sg-customer flow [feature-or-flow]`: new, changed, or shipped user paths. Start with the intended user and durable value. When capture, organization, revisit, or assistance creates the value loop, load product-behavior intelligence and define first success from that loop, never from a superficial setup click.

## End-User Contract

```text
End-User Contract: [feature/flow]
Target user:
First success:
Primary path:
Comprehension and usefulness:
Friction:
Trust and optionality:
States:
Recovery:
Onboarding/setup impact:
Documentation Update Plan:
Editorial Update Plan:
Proof path:
Implementation route:
```

Make states current, completed, skipped, blocked, unsupported, failed, empty, loading, and recoverable where relevant. Prefer a beginner path with optional expert shortcuts and a small decision surface for repeat setup forks: continue, recommended guided route, or defer/cancel.

## Routing And Stops

This contract is planning/read-only. Material source changes need a ready spec and build lifecycle. Do not replace `006`, `007`, `300`, `107`, `108`, or `109`; declare their impact and route the owned work. For sensitive setup disclose value, whether the feature works without it, privacy/billing/data/security consequences, defer, and recheck path.
