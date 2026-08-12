---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: shipglows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 102-sg-start
scope: 102-sg-start-triage
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/102-sg-start/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "START-DIRECT and START-SPEC-FIRST keep classification before mutation-only doctrine."
next_step: none
---

# Execution Workflow Triage

Load this reference only to identify and classify the work item. It does not authorize writing.

## Identify

Use `$ARGUMENTS` when present. Otherwise inspect the current task source and ask one bounded selection question; never invent the work item.

Classify `direct` only when scope, expected behavior, files, authority, and failure handling are clear and local. Force `spec-first` for ambiguity, multiple systems, auth/data/migration/API/security, external integrations, destructive behavior, money, permissions, tenant boundaries, or consequential side effects.

Known failing auth/session/callback/protected-route flows retain `102-sg-start` implementation ownership but require `109-sg-auth-debug` evidence before blind patching. Non-auth browser proof routes to `108-sg-browser`.

If classification remains product- or security-meaningful, ask one decision. A clarification route may use `700-sg-explore`; a missing ready contract routes through `100-sg-spec -> 101-sg-ready -> 102-sg-start` and stops before writes.

## Scenario Outcomes

- `START-DIRECT`: form a silent mini-contract, then load `execution-contract.md` directly from `SKILL.md`.
- `START-SPEC-FIRST`: require one matching `ready` spec, read it fully, then load `execution-contract.md` directly.
- `START-MALFORMED-REF`: a missing, malformed, or contradictory required reference blocks execution; never infer its doctrine.

For `report=agent` only, detailed evidence is selected later from `execution-report.md`. User reports follow the shared reporting contract.
