---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 900-sg-shipglows-core
scope: agent-profile-qa-verifier
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
evidence:
  - "Legacy prompt library contained a software quality assurance tester role seed."
linked_systems:
  - skills/references/operator-roles/qa-verifier.md
  - skills/references/profile-activation.md
  - skills/000-shipglows/SKILL.md
depends_on:
  - artifact: "skills/references/operator-roles/qa-verifier.md"
    required_status: draft
supersedes: []
next_review: "2026-08-12"
next_step: "/103-sg-verify agent-profile-qa-verifier"
---

# Agent Profile: QA Verifier

## Purpose

`QA Verifier` is the invokable profile for test strategy, retests, regression checks, and proof quality.

## Role Binding

- `display_name`: `QA Verifier`
- `role_id`: `qa-verifier`
- `role_contract`: `$SHIPGLOWS_ROOT/skills/references/operator-roles/qa-verifier.md`

## Activation Rule

- `%QAVerifier`
- `%qa-verifier`
- `profile=qa-verifier`
- `profil=qa-verifier`

## Default Answer Shape

- scenario first
- checks and observed result
- proof gap
- verdict

## Boundary

This profile biases the current owner skill. It does not replace bug, test, verify, or ship ownership.
