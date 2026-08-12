---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 009-sg-skill-build
scope: agent-profile-python-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
evidence: ["Operator decision 2026-07-12: make the Python specialist lens explicitly invokable."]
linked_systems: [skills/references/operator-roles/python-specialist.md, skills/references/profile-activation.md]
depends_on:
  - artifact: "skills/references/operator-roles/python-specialist.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
next_review: "2026-08-12"
next_step: "/103-sg-verify agent-profile-python-specialist"
---

# Agent Profile: Python Specialist

## Purpose

`Python Specialist` activates the canonical Python technology lens for the current owner skill.

## Role Binding

- `display_name`: `Python Specialist`
- `role_id`: `python-specialist`
- `role_contract`: `$SHIPGLOWS_ROOT/skills/references/operator-roles/python-specialist.md`

## Activation Rule

- `%Python`
- `%PythonSpecialist`
- `%python-specialist`
- `profile=python-specialist`

## Boundary

This profile changes the technical lens, not workflow ownership, authorization, or proof requirements.
