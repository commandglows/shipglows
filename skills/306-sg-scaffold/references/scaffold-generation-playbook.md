---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 306-sg-scaffold
scope: scaffold-generation
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: no
linked_systems:
  - skills/306-sg-scaffold/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-2 compaction extracted type-specific generation rules from the scaffold activation contract."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Scaffold Generation Playbook

Load this reference only after discovery produces a safe generation contract.

## Generate from evidence

Match the observed extension, location, naming, imports, exports, typing, framework pattern, styling, tokens, validation, states, and documentation convention. Preserve product terminology and the surrounding user flow.

For relevant public UI, include established loading, empty, error, success, and permission-denied states. For server code, use the project's server-side authz, tenant scoping, validation, and error patterns. Never substitute UI hiding for enforcement or accept untrusted input more loosely than neighboring code.

## Safe shells

Use a safe shell only when it is useful and honest:

- page: route shell with explicit pending decisions and safe empty/error structure;
- component: typed presentational shell without invented business logic;
- API: read-only stub or `501 Not Implemented` until authz and validation are decided;
- content: schema-valid draft without invented promises.

Do not use a safe shell to bypass a missing design-system authority, conceal a blueprint/project conflict, or imply a privileged/public behavior is complete.

## Report

For success, report `SCAFFOLDED: <type> - <name>`, created paths, examples, patterns, blueprint/version and used aspects, security impact, documentation impact, and focused validation.

For a stop, report `NOT SCAFFOLDED: <type> - <name>`, the exact reason, blueprint if present, targeted decisions, and a safe next path.
