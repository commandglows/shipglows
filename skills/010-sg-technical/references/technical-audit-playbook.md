---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-08-03"
status: active
source_skill: 010-sg-technical
scope: technical-audit-index
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/010-sg-technical/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Former audit monolith compacted by target decision."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Technical Audit Index

`010-sg-technical audit` first loads `technical-audit-protocol.md`, then exactly one target branch: `technical-file-audit.md` for a file/diff/PR, `technical-project-audit.md` for the current project, or `technical-global-audit.md` for `global`. Missing target branch is a visible blocked result. Findings do not authorize mutation.
