---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 305-sg-init
scope: bootstrap-entrypoint-and-development-mode
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/305-sg-init/SKILL.md]
depends_on: []
supersedes: []
evidence: ["CLAUDE and development-mode extraction."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Bootstrap Entry Point And Development Mode

Detect framework/runtime/package manager/UI/CSS/content/i18n/auth/backend/storage/hosting/payment from actual project files. Create or update `CLAUDE.md` only after confirmation; it records project overview, commands, architecture, conventions and development mode. If absent, `SHIPGLOWS.md` may carry the development-mode section.

Choose `local`, `vercel-preview-push`, or `hybrid` from the real validation surface. Record hosting, preview source, production URL, observability, diagnostics/log-copy ownership, review date and explicit unknowns. A runtime project needs Sentry and safe diagnostics unless it documents the strict static-site exception. Do not leave pipe-delimited placeholders.
