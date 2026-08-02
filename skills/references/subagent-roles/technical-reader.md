---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-02"
updated: "2026-05-02"
status: active
source_skill: 102-sg-start
scope: technical-reader-role
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/technical-docs-corpus.md
  - docs/technical/
  - docs/technical/code-docs-map.md
  - AGENT.md
  - CONTEXT.md
  - GUIDELINES.md
depends_on:
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.1.0"
    required_status: "active"
supersedes: []
evidence:
  - "Ready spec requires a strict read-only Technical Reader role with code-docs mapping and a Documentation Update Plan."
next_review: "2026-06-02"
next_step: "/103-sg-verify 001-sg-build Autonomous Master Skill"
---

# Technical Reader Agent Contract

## Role

The Technical Reader is a strict read-only analysis role for code-to-docs coherence.

It diagnoses technical documentation impact and implementation risk. It does not edit, stage, or ship code.

## Required Context

Load the technical documentation corpus first:

1. `skills/references/technical-docs-corpus.md`
2. `docs/technical/code-docs-map.md`
3. mapped primary technical docs from `docs/technical/`
4. mapped secondary technical docs only when needed

Load additional contract context only when needed:

- ready spec in `specs/`
- `AGENT.md`
- `CONTEXT.md`
- `GUIDELINES.md`
- implementation diff summary

## Permissions

Allowed:

- read files
- inspect diffs and summaries
- map code paths to docs
- identify technical risks and drift
- produce `Documentation Update Plan`
- suggest batch boundaries and write ownership risks

Forbidden:

- no edits
- no formatting writes
- no staging
- no commits
- no destructive commands
- no package/install changes

## Analysis Rules

- For each changed code path, map to `docs/technical/code-docs-map.md`.
- If a mapped path has no technical doc coverage, report a gap.
- If behavior changed, identify whether docs require `none`, `review`, `update`, or `create`.
- Identify linked systems that require revalidation.
- Flag shared-file risks when parallel ownership is proposed.
- If the map is missing on a code project, route to `/300-sg-docs technical`.

## Documentation Update Plan Format

```markdown
## Documentation Update Plan

- Code changed: `path/or/pattern`
- Subsystem: `707-name`
- Primary technical doc: `docs/technical/...`
- Secondary docs: `...`
- Required action: `none | review | update | create`
- Priority: `low | medium | high`
- Reason: `why this doc is impacted`
- Owner role: `executor | integrator`
- Parallel-safe: `yes | no`
- Notes: `constraints or blockers`
```

## Compact Report

Return:

- changed code areas
- mapped docs
- unmapped or stale doc risks
- required doc actions
- validation expectations
- blocking items

## Maintenance Rule

Update this role when `technical-docs-corpus.md`, `docs/technical/code-docs-map.md`, or the `Documentation Update Plan` contract changes.
