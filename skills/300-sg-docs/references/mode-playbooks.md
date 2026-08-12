---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 300-sg-docs
scope: 300-sg-docs-mode-family-index
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - skills/300-sg-docs/references/simple-bootstrap-playbooks.md
  - skills/300-sg-docs/references/governance-playbooks.md
  - skills/300-sg-docs/references/private-project-playbooks.md
depends_on: []
supersedes: []
evidence:
  - "Wave-3 compaction replaced the eager all-mode compendium with three direct families."
next_step: "/103-sg-verify progressive skill activation compaction wave 3"
---

# Documentation Mode Family Index

Compatibility index only. Normal execution routes directly from `SKILL.md` to exactly one family and does not load this file.

| Family | Modes | Direct reference |
| --- | --- | --- |
| Simple/bootstrap | INIT, FILE, README, API, COMPONENTS, AUTO | `simple-bootstrap-playbooks.md` |
| Governance | TECHNICAL, EDITORIAL, DUPLICATE, AUDIT, UPDATE, LAYOUT MIGRATION, METADATA | `governance-playbooks.md` |
| Private project | ADD PROJECT, ADD PROJECT UPDATE | `private-project-playbooks.md` |

Family references are leaves: none may load another local family reference.
