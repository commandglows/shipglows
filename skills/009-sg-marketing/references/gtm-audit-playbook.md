---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-16"
updated: "2026-07-16"
status: active
source_skill: 009-sg-marketing
scope: gtm-audit
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/009-sg-marketing/SKILL.md
  - skills/references/source-intake-classification.md
  - shipglows_data/technical/product-behavior-intelligence.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes:
  - skills/408-sg-audit-gtm/SKILL.md
  - skills/408-sg-audit-gtm/references/gtm-audit-workflow.md
evidence:
  - "Migrated from 408-sg-audit-gtm during marketing-surface consolidation."
next_step: "/103-sg-verify consolidate marketing skills under sg-marketing"
---

# GTM Audit Playbook

Use only for `009-sg-marketing gtm <page|funnel|project|global>`.

## Context, Proof, And Confidence

Read business, branding, technical-guidelines, and optional competitors/affiliate contracts when present. Report each contract's version, status, updated date, confidence, and next-review value. Missing, stale, low-confidence, or unversioned context is a proof gap and caps the affected grade; absence alone does not prohibit a bounded audit.

Load `source-intake-classification.md` for material competitor, marketplace, or review evidence and cross-check at least one customer-feedback surface when available. Load the draft product-behavior reference when positioning depends on activation, retention, or feature-value proof; do not convert visits, signups, or clicks into behavioral proof.

Treat public promises as product contracts. Security, compliance, AI, payment, pricing, availability, automation, savings, and results claims need visible product/documentation evidence. Flag a mismatch rather than giving an unqualified high grade.

## Audit Flow

- For a page, read the target, navigation, homepage, pricing where relevant, and the page's funnel role. Grade positioning/differentiation, conversion architecture, trust/proof, objections, funnel alignment, analytics, market readiness, and documentation coherence.
- For a project, map the positioning statement and every conversion path from traffic source through post-conversion. Audit awareness, consideration, conversion, and retention surfaces; then test trust architecture, analytics/events/UTMs, mobile/forms/payment where applicable, legal/support readiness, and launch-critical documentation coherence.
- For `global`, select applicable commercial projects explicitly, run bounded project audits, then synthesize cross-project patterns. Do not infer every repository is in scope.

Return A/B/C/D grades with exact evidence, affected surface, business consequence, proof gaps, and bounded owner route. The overall assessment must not average away a launch-critical claim or trust failure.

## Remediation, Tracking, And Reporting

Fix only when explicitly requested or owned by the active chantier. Prioritize broken conversion paths, missing trust signals, missing measurement, legal/compliance gaps, then funnel leaks. Do not recommend building unshipped features as if they existed; separate product decisions from optimization.

Before an audit/task write, load `operational-record-format.md`, re-read the target immediately before editing, and update only the intended traffic-first record. Record audit findings in applicable project-local audit logs and follow-ups in the correct tracker; stop if the anchor remains ambiguous after one re-read.

Report scope, a `Business metadata versions` section, positioning, funnel, page/funnel grades, trust, analytics, launch readiness, documentation coherence, proof gaps, confidence, findings, and the next real action. Evaluate `Chantier potentiel` for non-trivial product, pricing, funnel, analytics, or trust decisions.

## Stops And Quality Bar

- Do not invent market evidence, conversion data, revenue, testimonials, or customer proof.
- For France/EU contexts, assess RGPD, legal notices, CGV, and consent where applicable without giving legal advice.
- Public recommendation strength must match evidence; missing material context is named, not hidden.
- Preserve focused contract, metadata, and budget checks after playbook changes.
