---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-03"
status: active
source_skill: 406-sg-seo
scope: seo-audit-index
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems: [skills/406-sg-seo/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Former SEO audit monolith split by target and AI-visibility decision."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# SEO Audit Index

Load `seo-audit-protocol.md` for every audit/fix. Then load exactly one target branch: `seo-page-audit.md`, `seo-project-audit.md`, or `seo-global-audit.md`. Load `seo-ai-visibility-review.md` only for AEO/GEO, AI crawler, or OpenAI/ChatGPT claims. Audit is read-only; only explicit `fix` authority or an active implementation chantier permits mutation.
