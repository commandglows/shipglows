---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 305-sg-init
scope: bootstrap-trackers-and-report
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems: [skills/305-sg-init/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Tracker and reporting extraction."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Bootstrap Trackers And Report

Use `shipglows_data/workflow/TASKS.md` as the active project tracker; it has no YAML frontmatter. Preserve a real root `TASKS.md` or `AUDIT_LOG.md` and report layout migration debt rather than overwrite it. Create project-local tracker rows from detected work, never placeholders. Project discovery is local markers and `shipglows_data`, not central `PROJECTS.md`.

Create a root `CHANGELOG.md` only if absent. Final output must explicitly mark every entrypoint, tracker, business/brand/guideline/context, governance layer, MCP state and domain applicability as created, existing, skipped, blocked or needs audit, followed by the next owner route.
