---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 008-sg-customer
scope: customer-recovery-playbook
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

# Customer Recovery Playbook

Use only for `008-sg-customer recovery [feature-or-state]`: skipped, blocked, failed, revoked, unsupported, expired, or lost-context states. The result is a customer-safe path, not auth debugging, visual implementation, or QA execution.

## Recovery Contract

```text
Recovery Contract: [feature/state]
Target user and interrupted value:
Observable state and plain-language consequence:
Safe immediate action:
Defer/exit path:
Resume or re-entry trigger:
Recheck/retry rule:
Data, permission, billing, privacy, or security consequence:
Owner/proof route:
Documentation/editorial impact:
```

Preserve context where safe, say what remains usable without the prerequisite, and make the next action available after leaving for external settings or another app. Never loop the user through a dead end, erase context to force setup, fake urgency, or imply that an OS/provider-owned setting was changed.

## Owner Boundaries

Route auth/session/callback/provider diagnosis to `109`; browser observation to `108`; manual test evidence to `107`; customer-impacting source changes to a ready spec/build lifecycle. Route visual craft, content, and documentation ownership to `006`, `007`, and `300` respectively.
