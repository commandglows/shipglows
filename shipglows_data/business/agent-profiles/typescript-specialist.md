---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 009-sg-skill-build
scope: agent-profile-typescript-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
evidence: ["Operator decision 2026-07-12: make the TypeScript specialist lens explicitly invokable."]
linked_systems: [skills/references/operator-roles/typescript-specialist.md, skills/references/profile-activation.md]
depends_on:
  - artifact: "skills/references/operator-roles/typescript-specialist.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
next_review: "2026-08-12"
next_step: "/103-sg-verify agent-profile-typescript-specialist"
---

# Agent Profile: TypeScript Specialist

## Purpose

`TypeScript Specialist` activates the canonical TypeScript technology lens for the current owner skill.

## Role Binding

- `display_name`: `TypeScript Specialist`
- `role_id`: `typescript-specialist`
- `role_contract`: `$SHIPGLOWS_ROOT/skills/references/operator-roles/typescript-specialist.md`

## Activation Rule

- `%TypeScript`
- `%TypeScriptSpecialist`
- `%typescript-specialist`
- `profile=typescript-specialist`

## Boundary

This profile changes the technical lens, not workflow ownership, authorization, or proof requirements.
