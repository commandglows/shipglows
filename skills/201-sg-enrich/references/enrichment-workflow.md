---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 201-sg-enrich
scope: 201-sg-enrich-enrichment-workflow
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/201-sg-enrich/SKILL.md
  - skills/201-sg-enrich/references/enrichment-context-and-governance.md
  - skills/201-sg-enrich/references/enrichment-research.md
  - skills/201-sg-enrich/references/enrichment-rewrite-and-visibility.md
  - skills/201-sg-enrich/references/enrichment-quality-and-reporting.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.8.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 16 split the monolithic enrichment workflow into direct conditional leaves."
next_review: "2026-09-12"
next_step: "/103-sg-verify enrichment workflow compaction"
---

# Enrichment Workflow

Use this index only for substantive enrichment of existing content. Literal placeholders, typos, heading-tag changes, and deterministic one-line replacements stay on the direct focused-edit path defined by `201-sg-enrich`.

## First Decision

Resolve one target file or a bounded folder selection. Preserve its language, author voice, frontmatter schema, purpose, and existing supported claims before deciding what to change.

Choose required leaves directly from this index:

- Before changing a public surface, metadata, content role, or product-facing claim, load `references/enrichment-context-and-governance.md`.
- When claims, versions, comparisons, statistics, examples, or content decay need verification, load `references/enrichment-research.md`.
- For substantive rewriting, scannability, AI visibility, structured data, internal links, or conversion changes, load `references/enrichment-rewrite-and-visibility.md`.
- Before a readiness verdict, batch summary, or detailed report, load `references/enrichment-quality-and-reporting.md`.

These leaves are independent siblings. Load only the branches selected by the current work; no leaf loads another leaf.

## Non-Negotiable Gates

- Never invent facts, metrics, quotes, customer proof, comparisons, author experience, or recommendations. Cite unstable and material claims with fresh authoritative sources.
- Preserve the original author's personality and the project's content schema. Add metadata or structured data only when compatible with the runtime.
- Preserve declared product names, canonical surfaces, delivery explanations, claim boundaries, and editorial intent.
- Match the target language exactly. Enrichment must improve usefulness without silently changing the product promise or turning neutral content into unsupported sales copy.
- Use the shared content quality rubric for the final gate; missing evidence or failed criteria remain `needs revision` or `blocked`.

## Stop Conditions

Stop or report partial when no target can be resolved safely, the public surface or schema is ambiguous, required evidence is unavailable, proposed claims exceed project truth, or the change needs unapproved external publication or durable state mutation.
