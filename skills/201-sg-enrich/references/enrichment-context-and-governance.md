---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 201-sg-enrich
scope: enrichment-context-and-governance
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/201-sg-enrich/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from the enrichment workflow during Wave 16."]
next_review: "2026-09-12"
next_step: "/103-sg-verify enrichment workflow compaction"
---

# Enrichment Context And Governance

Read each selected target completely and identify its topic, audience, intent, language, content type, current strengths, weak points, author voice, frontmatter schema, and public role. For a folder, enumerate supported content files and obtain a bounded selection; prioritize declared high-value surfaces only when project truth supports that ordering.

Before changing public content, claims, or surface intent, load `skills/references/editorial-content-corpus.md`. Before changing runtime content, schemas, public docs, skill contracts, or mapped technical surfaces, load `skills/references/technical-docs-corpus.md`. Select these shared references independently by their gates.

Preserve the existing collection, route, language, author, taxonomy, frontmatter, and supported product promise. Record business, brand, persona, and strategy versions in compatible fields or in the report. Never force ShipGlows metadata into an incompatible application schema.

For existing ShipGlows artifacts, use major for thesis/audience/promise changes, minor for substantive new sections, sources, segments, or strategic CTA, and patch for corrections. For runtime content, update only established modified-date/version fields.

Report relevant `Editorial Update Plan`, `Claim Impact Plan`, and `Documentation Update Plan` outcomes. An undeclared surface, incompatible schema, or claim-register conflict is a blocker, not an invitation to improvise.
