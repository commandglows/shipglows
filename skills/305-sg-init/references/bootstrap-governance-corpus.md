---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 305-sg-init
scope: bootstrap-governance-corpus
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems: [skills/305-sg-init/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Governance corpus bootstrap extraction."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Bootstrap Governance Corpus

Load technical/editorial corpus references before creating governance. For code areas, create only concise technical index/map when missing; preserve existing material and route detail to `300-sg-docs technical`. For real public surfaces, create only evidence-backed editorial index/roadmap and required maps when missing; preserve runtime-content schemas and never invent a route. If no surface exists, report skipped with reason.

`AGENT.md` is canonical. Create a project-specific entrypoint only when absent; `AGENTS.md` may be a compatibility symlink. A real conflicting `AGENTS.md` requires a decision, not conversion. Report every governance layer visibly.
