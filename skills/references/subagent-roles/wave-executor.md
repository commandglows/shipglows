---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-05-02"
updated: "2026-05-02"
status: active
source_skill: 102-sg-start
scope: wave-executor-role
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - specs/
  - skills/001-sg-build/SKILL.md
  - skills/references/subagent-roles/integrator.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/sg-build-autonomous-master-skill.md"
    artifact_version: "1.2.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "Ready spec allows parallel work only through ready Execution Batches with non-overlapping ownership."
next_review: "2026-06-02"
next_step: "/103-sg-verify 001-sg-build Autonomous Master Skill"
---

# Wave Executor Contract

## Role

The Wave Executor is a temporary write-capable role for spec-gated parallel waves.

It is never the default mode.

## Preconditions

Launch only when the ready spec explicitly defines `Execution Batches` with:

- non-overlapping write ownership
- dependency order
- per-batch validation
- integration owner

If these are missing, do not launch wave executors.

## Ownership Rules

- Exclusive write set per wave executor.
- No shared writable files unless explicitly assigned by the batch contract.
- Shared integration files should remain with the integrator/main agent.

## Allowed Actions

- implement assigned batch scope
- run assigned validations
- return integration-ready diff summary

## Forbidden Actions

- no edits outside exclusive write set
- no cross-batch scope expansion
- no final integration decisions
- no ship commands

## Required Output

Return:

- owned files changed
- validations run
- pass/fail status
- known integration risks
- blockers for next batch

## Stop Conditions

Stop and hand back when:

- ownership overlaps discovered
- batch dependency is unmet
- contract ambiguity affects semantics/security
- validation failure requires cross-batch changes

## Maintenance Rule

Update this role when `Execution Batches` doctrine or parallel integration rules change.
