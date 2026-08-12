---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 201-sg-enrich
scope: enrichment-quality-and-reporting
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

# Enrichment Quality And Reporting

Before completion, verify all added claims and links, technical examples, language and accents, author voice, reading flow, useful next actions, metadata preservation, modified dates when applicable, schema validity, declared surface intent, and absence of placeholders or invented proof. Check for stale dates, deprecated tools, unsupported structured data, and broken internal destinations.

Load `skills/references/content-quality-rubric.md` for the final enrichment gate. Keep `needs revision` or `blocked` when required evidence, schema, authorship, public-claim, or editorial criteria fail. Skip already-strong files in a batch and explain why; do not churn them to satisfy a quota.

For `report=user`, name targets changed or skipped, material improvements, sources/proof, quality verdict, and remaining gaps. Include context versions or metadata gaps plus relevant editorial, claim, and documentation plan outcomes. For explicit detailed handoff, add before/after word counts, sources and stale claims fixed, validation performed, structured-data changes, and blocked criteria. Avoid a large decorative template.
