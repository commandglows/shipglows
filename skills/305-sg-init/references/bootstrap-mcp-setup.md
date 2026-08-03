---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 305-sg-init
scope: bootstrap-mcp-setup
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: no
linked_systems: [skills/305-sg-init/SKILL.md]
depends_on: []
supersedes: []
evidence: ["MCP setup extraction."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Bootstrap MCP Setup

Use only for an explicit MCP/server setup request. Inspect `.claude/settings.json`; merge minimally without overwriting existing servers. Resolve absolute ShipGlows and project paths, never shell variables in JSON. Offer detected Clerk, Convex, Vercel or Supabase integration for approval before adding it. Keep any local codebase MCP disabled by default; do not claim installed tooling proves access or production safety.
