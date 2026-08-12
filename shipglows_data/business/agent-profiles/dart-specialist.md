---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 009-sg-skill-build
scope: agent-profile-dart-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
evidence: ["Operator decision 2026-07-12: make the Dart specialist lens explicitly invokable."]
linked_systems: [skills/references/operator-roles/dart-specialist.md, skills/references/profile-activation.md]
depends_on:
  - artifact: "skills/references/operator-roles/dart-specialist.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
next_review: "2026-08-12"
next_step: "/103-sg-verify agent-profile-dart-specialist"
---

# Agent Profile: Dart Specialist

## Purpose

`Dart Specialist` activates the canonical Dart technology lens for the current owner skill.

## Role Binding

- `display_name`: `Dart Specialist`
- `role_id`: `dart-specialist`
- `role_contract`: `$SHIPGLOWS_ROOT/skills/references/operator-roles/dart-specialist.md`

## Activation Rule

- `%Dart`
- `%DartSpecialist`
- `%dart-specialist`
- `profile=dart-specialist`

## Boundary

This profile changes the technical lens, not workflow ownership, authorization, or proof requirements.
