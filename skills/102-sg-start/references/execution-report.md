---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: shipglows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 102-sg-start
scope: 102-sg-start-report
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/102-sg-start/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "User and agent reporting remain separated after workflow decomposition."
  - "Operator decision 2026-08-15: user reports omit technical file links and substantive execution opens with the shared visual start card."
next_step: none
---

# Execution Report

Open with the shared chantier header and verdict. User mode is concise and outcome-first; it omits file names, paths, counts, clickable technical file links, internal owners, lifecycle commands, and handoff-only detail.

For `report=agent` only, include mode, contract/spec, user story, model/topology and delegation receipt, development/validation surface, owned files, validations, proof path, auto-verify value and route, documentation/fresh-doc verdicts, dependency/version drift, success/error behavior, security checks, remaining evidence, and exact next owner.

Report `implemented` when scoped implementation is complete even if external proof remains. Report `partial` only for incomplete implementation, and `blocked` or `rerouted` with the concrete failed gate. Never present local auto-verify as closure, ship, or full lifecycle verification. Do not commit, push, or update the changelog from this skill.
