---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 201-sg-enrich
scope: enrichment-research
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems: [skills/201-sg-enrich/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from the enrichment workflow during Wave 16."]
next_review: "2026-09-12"
next_step: "/103-sg-verify enrichment workflow compaction"
---

# Enrichment Research

Audit existing claims before adding material. Check statistics, dates, APIs, versions, tools, legal/market statements, comparisons, external recommendations, and words such as “currently” or “recently.” Flag stale numbers and deprecated behavior; preserve still-valid evidence.

Research in the target language and English where technical depth helps. Prefer official documentation, primary studies, public datasets, original repositories, and named verifiable cases. Compare leading coverage to locate genuine omissions, not to copy its framing. Cite each material addition close to the supported claim.

For OpenAI, ChatGPT, Codex, models, APIs, pricing, prompt guidance, or tool behavior, use the installed `openai-docs` skill and official OpenAI sources before rewriting the claim. Broader adoption, citation, SEO, or third-party benchmark claims still require appropriate independent primary evidence. Report stale or unsupported OpenAI assertions as an `OpenAI freshness risk`.

Never manufacture a statistic, quote, result, expert view, or case study. If current evidence cannot be found, remove, qualify, or explicitly flag the claim. A numerical density target never overrides accuracy or relevance.
