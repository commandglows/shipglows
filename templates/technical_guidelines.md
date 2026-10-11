---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: sg-docs
scope: guidelines
owner: "[owner]"
confidence: medium
risk_level: medium
task_branch_policy: forbidden
worktree_policy: forbidden
linked_systems: []
security_impact: yes
docs_impact: yes
evidence: []
depends_on: []
supersedes: []
next_review: "YYYY-MM-DD"
next_step: "/sg-docs audit"
---

# Technical Guidelines

## Stack

## Critical Rules

`task_branch_policy` and `worktree_policy` independently govern silent creation
of temporary branches and worktrees. Missing or invalid values default to
`forbidden`. `allowed` is durable permission, never a requirement or
preference. This setting does not authorize unrelated Git writes or override
applicable `AGENTS.md` and execution-posture rules.

## Preferred Patterns

## Anti-Patterns

## Validation Expectations

## Documentation Expectations
