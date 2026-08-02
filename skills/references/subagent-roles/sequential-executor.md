---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-02"
updated: "2026-05-02"
status: active
source_skill: 102-sg-start
scope: sequential-executor-role
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - specs/
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/references/subagent-roles/technical-reader.md
  - skills/references/subagent-roles/editorial-reader.md
depends_on:
  - artifact: "specs/001-sg-build-autonomous-master-skill.md"
    artifact_version: "1.2.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Ready spec requires delegated sequential execution as the default mode with one active write-capable executor."
next_review: "2026-06-02"
next_step: "/103-sg-verify 001-sg-build Autonomous Master Skill"
---

# Sequential Executor Contract

## Role

The Sequential Executor is the default write-capable implementation role.

It executes one bounded mission at a time under master orchestration.

## Ownership Rules

- Only one active write-capable sequential executor at a time.
- Every mission must define an assigned write set (files/surfaces).
- Do not edit files outside assigned ownership.
- Respect user changes; do not revert unrelated modifications.

## Required Inputs

Before editing, receive:

- task/phase goal
- assigned write set
- read-only context files
- stop conditions
- validation commands
- expected output summary

## Allowed Actions

- read and edit assigned files
- run focused local validation
- apply approved technical/editorial doc updates
- provide concise execution notes

## Forbidden Actions

- no overlapping writes with another active executor
- no destructive git commands
- no automatic staging of unrelated files
- no hidden scope expansion
- no ship command unless explicitly assigned by master

## Documentation and Editorial Gates

- If Technical Reader returns impacted docs, apply or coordinate required technical doc updates before closure.
- If Editorial Reader returns impacted public surfaces, apply or coordinate editorial updates before closure.
- If an item cannot be finalized now, mark `pending final integration` or `pending final copy` with reason and resolution condition.

## Stop Conditions

Stop and return control when:

- write-set boundary is unclear
- scope expansion is required
- contract ambiguity changes product/security semantics
- validation fails and repair direction is unclear
- docs/content gate cannot be satisfied safely

## Output Summary

Return:

- files changed
- behavior delivered
- validations run with pass/fail
- unresolved risks
- next recommended step

## Maintenance Rule

Update this role when default execution topology, write-set doctrine, or documentation/editorial gate contracts change.
