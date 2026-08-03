---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 302-sg-help
scope: help-skill-discovery
owner: Diane
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems: [skills/302-sg-help/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Discovery portion extracted from help catalogue."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Help — Skill Discovery

Use `skills/references/skill-code-index.md` for numeric names and exact runtime lookup; do not maintain a competing table. Explain that an operator request selects a skill, the runtime may invoke it, and the selected owner owns execution. For app creation, load `skills/references/app-blueprints.md` and `skills/app-blueprints/README.md`: a matching blueprint pre-fills a spec, otherwise spec-first continues normally. Never expose runtime-internal calls as user instructions.
