---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-16"
updated: "2026-07-16"
status: active
source_skill: 009-sg-marketing
scope: marketing-contract-migration-maintenance-evidence
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/009-sg-marketing/SKILL.md
  - tools/test_009_sg_marketing_contract.py
  - shipglows_data/workflow/specs/consolidate-marketing-skills-under-sg-marketing.md
depends_on: []
supersedes: []
evidence:
  - "2026-07-16 fresh comparison of the four retired source contracts using git show HEAD:skills/<retired-skill>/SKILL.md."
  - "Current dispatcher, four selected playbooks, and contract test reviewed after retirement."
next_step: "/103-sg-verify consolidate marketing skills under sg-marketing"
---

# Marketing Contract Migration Evidence

This is a maintenance and verification reference, not an operator playbook. The normal `009-sg-marketing` dispatcher must not load it for `market`, `gtm`, `copy`, or `copywriting`; load it only when maintaining or verifying the migration.

## Completeness Matrix

| Retired source contract | Canonical mode | Exact selected playbook | Required source gates, evidence, stops, and boundaries | Destination representation |
| --- | --- | --- | --- | --- |
| `204-sg-market-study` | `market` | `references/market-study-playbook.md` | Conditional `source-intake-classification.md` for competitor, marketplace, or customer-feedback evidence; use a material customer-feedback surface when available. Conditional draft `product-behavior-intelligence.md` for activation, retention, feature-value, or durable-value proof, with its confidence limit stated. Preserve demand, competition, sizing, monetization, brand/domain, AI visibility, risk, conservative projections, source/date evidence, `MARKET-STUDY.md`, and the `GO / GO CONDITIONNEL / PRUDENT / NO-GO` conclusion. Stop with an evidence limit; never invent market data, competitor facts, pricing, affiliate terms, demand, domain availability, or forecasts. Keep conditional `source-de-chantier`, report language, and `/100-sg-spec` follow-up posture. | Dispatcher **Conditional Shared Gates**, **Boundaries And Reroutes**, and **Core Safety Rules**; market playbook **Scope And Evidence**, **Study Flow**, **Deliverable And Follow-Up**, and **Stops And Quality Bar**. |
| `408-sg-audit-gtm` | `gtm` | `references/gtm-audit-playbook.md` | Conditional `source-intake-classification.md` for competitor, marketplace, review, objection, trust, or positioning evidence, including a material customer-feedback cross-check. Conditional draft `product-behavior-intelligence.md` for activation, retention, feature-value, and behavioral proof; visits, signups, and clicks are not proof. Preserve positioning, offer, funnel, trust, analytics, pricing, legal/support, documentation coherence, launch readiness, A/B/C/D evidence grades, product/claim coherence, and traffic-first durable follow-up. Stop rather than inventing conversion, revenue, testimonial, customer, or market evidence; do not recommend unshipped features as existing product. Keep conditional `source-de-chantier` for product, pricing, funnel, analytics, or trust decisions. | Dispatcher **Conditional Shared Gates** and **Core Safety Rules**; GTM playbook **Context, Proof, And Confidence**, **Audit Flow**, **Remediation, Tracking, And Reporting**, and **Stops And Quality Bar**. |
| `206-sg-audit-copy` | `copy` | `references/copy-audit-playbook.md` | Always apply `content-quality-rubric.md` for rubric statuses and `task-registry-routing.md` before durable follow-ups. Apply the bounded Inspiration Gate for sales/offer, CTA/proof/objection comparison, copy-pattern analysis, or explicit inspiration: at most five private IDs, operator selection before bundle loading, transferable principles rather than phrasing. Preserve business/brand/product/documentation/claim coherence; page, journey, CTA, microcopy, real-system-state, French typography, and `surface missing: blog` checks. Stop for missing selected references or weakened safeguards; do not invent proof, guarantees, pricing, testimonials, legal claims, or system states. Remain the clarity/credibility/usability mode, not an implicit copywriting pass. | Dispatcher **Conditional Shared Gates**, **Boundaries And Reroutes**, and **Core Safety Rules**; copy playbook **Scope And Governance**, **Audit Flow**, **Remediation, Tracking, And Report**, and **Stops And Quality Bar**. |
| `207-sg-audit-copywriting` | `copywriting` | `references/copywriting-audit-playbook.md` | Always apply `content-quality-rubric.md` and `task-registry-routing.md`; use the same bounded Inspiration Gate for offer, CTA/proof/objection, or explicit inspiration. Preserve intended buyer, persona, awareness, offer, differentiation, proof, persuasion structure, objections, emotional path, CTA strategy, journey coherence, strategic artifact governance, and French-language fidelity. Stop for unsupported claims and reject fake urgency, fake social proof, dark patterns, fear, guilt, and unrealistic promises. Route sentence-level repair or full rewrites to `copy`; do not duplicate the full copy audit. Keep conditional `source-de-chantier` for persona, positioning, legal, trust, pricing, or funnel decisions. | Dispatcher **Conditional Shared Gates**, **Boundaries And Reroutes**, and **Core Safety Rules**; copywriting playbook **Distinct Contract And Governance**, **Audit Flow**, **Durable Artifacts, Tracking, And Report**, and **Stops And Ethical Bar**. |

All four predecessor contracts also retain the shared compact-skill safeguards represented in the dispatcher: canonical ShipGlows paths, compact activation plus selected local playbook, conditional `source-de-chantier` tracing and threshold, user/agent reporting modes, decision-quality selection, visible blocked/limited outcomes for missing required evidence or references, no unrelated durable mutation, and focused contract/metadata/budget validation.

## Retired-Name Policy And Allowlist

`009-sg-marketing` is the only active public marketing identity. Its only substantive runtime grammar is `market <target>`, `gtm <target>`, `copy <target>`, and `copywriting <target>`; `help` is informational. The retired `204-sg-market-study`, `206-sg-audit-copy`, `207-sg-audit-copywriting`, and `408-sg-audit-gtm` names are never aliases, examples, runtime entries, source directories, redirects, or routing fallbacks.

The historical `source_skill: 009-sg-skill-build` value is provenance from the former internal maintenance identity, not a `009-sg-marketing` alias. It may remain only as factual frontmatter/history in pre-existing governed artifacts, historical refresh records, and the explicit no-alias maintenance statements in `900-sg-core`/this evidence reference. No `skills/009-sg-skill-build/` directory, runtime symlink, public catalog entry, dispatcher fallback, or marketing example is permitted.

The narrow retired-name allowlist is limited to:

- this maintenance-only reference, where the names identify source evidence;
- `shipglows_data/workflow/specs/consolidate-marketing-skills-under-sg-marketing.md`, where they define the completed migration contract and verification boundary;
- immutable Git source history reachable through `git show HEAD:skills/<retired-skill>/...`;
- historical frontmatter, archival evidence, audit/changelog/refresh history that factually records a former source skill.

Every other current operator-facing, runtime, public, routing, catalog, template, or active maintenance instruction must use `009-sg-marketing` with an exact mode. A new active occurrence of a retired name is migration drift, not history.
