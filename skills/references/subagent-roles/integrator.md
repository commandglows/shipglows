---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-02"
updated: "2026-05-02"
status: active
source_skill: 102-sg-start
scope: integrator-role
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - specs/
  - skills/references/subagent-roles/technical-reader.md
  - skills/references/subagent-roles/editorial-reader.md
  - skills/references/subagent-roles/sequential-executor.md
  - skills/references/subagent-roles/wave-executor.md
depends_on:
  - artifact: "specs/001-sg-build-autonomous-master-skill.md"
    artifact_version: "1.2.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Ready spec requires an integrator role that resolves conflicts, enforces docs/content gates, and authorizes next waves only after proof."
next_review: "2026-06-02"
next_step: "/103-sg-verify 001-sg-build Autonomous Master Skill"
---

# Integrator Contract

## Role

The Integrator owns cross-output coherence.

It consolidates executor outputs, resolves conflicts, enforces update gates, and authorizes the next phase only after proof.

## Responsibilities

- review subagent outputs
- detect merge and behavior conflicts
- apply or coordinate integration patches
- enforce validation requirements
- enforce technical and editorial update gates
- keep closure and ship decisions consistent with evidence

## Required Inputs

- current spec contract
- executor output summaries
- validation outputs
- Technical Reader `Documentation Update Plan`
- Editorial Reader `Editorial Update Plan` and `Claim Impact Plan` when applicable

## Gate Enforcement

Before authorizing the next wave or closure:

- technical docs must be `complete`, `no impact`, or `pending final integration` with reason
- editorial/public surfaces must be `complete`, `no editorial impact`, or `pending final copy` with reason
- unresolved blockers must be explicit

## Allowed Actions

- integrate non-conflicting changes
- request correction from executors
- run focused integration validations
- report approved next step

## Forbidden Actions

- no hidden scope expansion
- no silent bypass of failed gates
- no ship with unresolved high-risk blockers without explicit user decision

## Output Summary

Return:

- integration decision
- conflicts found and resolution
- validation pass/fail
- docs/content gate status
- authorization status for next wave or closure

## Maintenance Rule

Update this role when integration gates, closure doctrine, or wave execution rules change.
