---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-16"
updated: "2026-07-16"
status: active
source_skill: 009-sg-marketing
scope: market-study
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
  - skills/204-sg-market-study/SKILL.md
  - skills/204-sg-market-study/references/market-study-workflow.md
evidence:
  - "Migrated from 204-sg-market-study during marketing-surface consolidation."
next_step: "/103-sg-verify consolidate marketing skills under sg-marketing"
---

# Market Study Playbook

Use only for `009-sg-marketing market <niche|idea|question>`.

## Scope And Evidence

Establish the niche, target geographies, business model, target audience, and decision the study must inform. If the business context is absent, warn that `shipglows_data/business/business.md` would improve relevance and continue only with named limits; it may be the first context-building study.

Use DataForSEO as the primary source where available, then official statistics, research, and cited web sources as appropriate. Warn before paid provider use. Every number, competitor fact, pricing claim, review signal, domain/handle result, and forecast needs a source and date. Never estimate unavailable search volume or market size.

When competitor pages, marketplaces, or external customer feedback materially affect demand, objections, or positioning, load `source-intake-classification.md`. Use at least one customer-feedback surface when available and material. When durable usage value matters, load the draft product-behavior reference and state its confidence limitation; do not treat traffic or signups as retention proof.

## Study Flow

1. Research 15–25 seed terms across high-, medium-, and low-intent clusters; collect volume, CPC, competition, related terms, intent, trends, geography, and difficulty.
2. Map the SERP and 3–5 serious competitors: rankings, organic footprint, content gaps, backlinks, app-store alternatives, reviews, recency, and feature gaps.
3. Size the opportunity with cited TAM/SAM/SOM, growth, regulation, barriers, substitutes, and conservative capture assumptions. Distinguish observed facts from assumptions.
4. Compare monetization models, competitor pricing, willingness-to-pay signals, and conservative revenue projections. Do not present industry benchmarks as project facts.
5. Check domain, brand, social-handle, and trademark signals as preliminary research, never legal clearance. Assess AI/LLM visibility only when useful.
6. Produce a risk matrix and a GO / GO CONDITIONNEL / PRUDENT / NO-GO conclusion from evidence, not a fabricated score.

## Deliverable And Follow-Up

Write a governed `MARKET-STUDY.md` only when the target is a durable business artifact, using ShipGlows frontmatter, source list, confidence, business model, market, value proposition, and versioned dependencies. Use `0.1.0`/draft for unreviewed or migrated studies; semantic bumps follow changed strategy, evidence, or editorial corrections. Treat competitor/inspiration and affiliate registries as optional; recommend or update them only when their facts will become reusable project contracts or paid-link disclosures are involved.

Report the verdict, score basis, evidence coverage, major limits, demand and competition signal, pricing range, risks, and next three actions. If the result creates non-trivial product, GTM, content, architecture, or implementation decisions, evaluate `Chantier potentiel` and route to `100-sg-spec` rather than silently implementing.

## Stops And Quality Bar

- Report an evidence limit rather than inventing market data, customer proof, affiliate terms, domain availability, or forecasts.
- Use conservative projections and state conversion/ARPU assumptions.
- A negative verdict is valuable; do not force a GO result.
- Match the report language to the user; French output must retain correct accents.
- Validate governed output with the metadata linter; preserve the dispatcher contract test and budget audit after playbook edits.
