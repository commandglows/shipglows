---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-10-21"
updated: "2026-10-21"
status: draft
source_skill: sg-docs
scope: agent-profile-vue-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
evidence: ["Operator decision 2026-10-21: make the Vue specialist lens explicitly invokable."]
linked_systems: [skills/references/operator-roles/vue-specialist.md, skills/references/profile-activation.md]
depends_on:
  - artifact: "skills/references/operator-roles/vue-specialist.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
next_review: "2026-11-21"
next_step: "/sg-docs technical audit"
---

# Agent Profile: Vue Specialist

## Purpose

`Vue Specialist` activates the canonical Vue technology lens for the current owner skill.

## Role Binding

- `display_name`: `Vue Specialist`
- `role_id`: `vue-specialist`
- `role_contract`: `$SHIPGLOWS_ROOT/skills/references/operator-roles/vue-specialist.md`

## Activation Rule

- `%Vue`
- `%VueSpecialist`
- `%vue-specialist`
- `profile=vue-specialist`

## Boundary

This profile changes the technical lens, not workflow ownership, authorization, or proof requirements.
