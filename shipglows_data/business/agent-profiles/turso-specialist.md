---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 009-sg-skill-build
scope: agent-profile-turso-specialist
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
evidence: ["Operator decision 2026-07-12: make the Turso specialist lens explicitly invokable."]
linked_systems: [skills/references/operator-roles/turso-specialist.md, skills/references/profile-activation.md]
depends_on:
  - artifact: "skills/references/operator-roles/turso-specialist.md"
    required_status: draft
supersedes: []
next_review: "2026-08-12"
next_step: "/103-sg-verify agent-profile-turso-specialist"
---

# Agent Profile: Turso Specialist

## Role Binding

- `display_name`: `Turso Specialist`
- `role_id`: `turso-specialist`
- `role_contract`: `$SHIPGLOWS_ROOT/skills/references/operator-roles/turso-specialist.md`

## Activation Rule

- `%Turso`
- `%TursoSpecialist`
- `%turso-specialist`
- `profile=turso-specialist`

## Boundary

This profile changes the technical lens, not workflow ownership, authorization, or proof requirements.
