---
artifact: content_map
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: sg-docs
scope: content-map
owner: "[owner]"
confidence: medium
risk_level: medium
content_surfaces:
  - blog
  - docs
  - landing_pages
  - editorial_governance
  - claim_register
  - page_intent
  - semantic_clusters
security_impact: unknown
docs_impact: yes
evidence: []
linked_artifacts: []
depends_on: []
supersedes: []
next_review: "YYYY-MM-DD"
next_step: "/007-sg-content repurpose <source>"
---

# Content Map

## Purpose

This file maps where content lives, what each surface is for, and how content should be repurposed without rediscovering the project structure every time.

It is a structural context artifact, not an editorial backlog.

When the project has public content, add an editorial governance layer such as `docs/editorial/` for claim boundaries, page intent, update gates, runtime content schema policy, and missing blog/article stop conditions.

## Content Surfaces

| Surface | Canonical path | Purpose | Format | Source of truth | Update when |
|---|---|---|---|---|---|
| Blog | `[path]` | Educational, editorial, or product-led articles | `[md/mdx/cms]` | `[doc/source]` | `[trigger]` |
| Documentation | `[path]` | Product, API, support, or operator docs | `[md/mdx/pages]` | `[doc/source]` | `[trigger]` |
| Landing Pages | `[path]` | Conversion pages, product pages, feature pages | `[route/files]` | `[doc/source]` | `[trigger]` |
| Changelog / Release Notes | `[path]` | User-facing product change narrative | `[format]` | `[doc/source]` | `[trigger]` |
| FAQ / Support | `[path]` | Objection handling, help answers, support reuse | `[format]` | `[doc/source]` | `[trigger]` |
| Newsletter / Social | `[path or external]` | Distribution and audience relationship | `[format]` | `[doc/source]` | `[trigger]` |
| Editorial Governance | `docs/editorial/` | Public-content impact, claim register, page intent, editorial update gate, runtime schema policy | Markdown governance artifacts | `CONTENT_MAP.md`, product/business/brand/GTM contracts, site routes | Public surfaces, claims, content schema policy, or article/blog rules change |

## Semantic Architecture

| Cluster | Pillar page | Supporting pages | Target intent | Internal link rule | Status |
|---|---|---|---|---|---|
| `[semantic cocoon / topic cluster]` | `[pillar path]` | `[spoke paths]` | `[informational/commercial/support]` | `[pillar <-> spokes]` | `[planned/live/stale]` |

## Page Roles

| Page type | Job | Must include | Must not include |
|---|---|---|---|
| Pillar page | Own the broad topic and route readers to deeper pages | Clear definition, use cases, links to spokes | Thin generic overview |
| Supporting article | Answer a specific sub-question or use case | Specific angle, examples, link to pillar | Duplicate the pillar |
| Product doc | Explain current behavior truthfully | Setup, constraints, edge cases | Marketing claims not proven by product |
| Landing page | Convert a qualified visitor | Offer, proof, CTA, objections | Claims unsupported by docs or product |
| FAQ entry | Resolve a precise question | Direct answer, caveat, next step | Long essay answer |

## Repurposing Rules

- A build conversation can become docs only when it changes behavior, workflow, setup, support, or operational knowledge.
- A build conversation can become marketing only when the user benefit is clear and evidenced.
- A source paragraph or article can become content angles, outlines, FAQ prompts, or newsletter/social hooks.
- External source material must be reframed; do not mirror the author's exact structure or wording.
- Public claims must be backed by `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, product behavior, or explicit evidence.
- Public claims that touch security, privacy, compliance, AI reliability, automation, speed, savings, availability, pricing, or business outcomes must be checked against the claim register when one exists.
- Public page edits should respect the page intent map when one exists.
- Application runtime content (`src/content/**`, Astro collections, MDX consumed by the app, CMS entries) must preserve its framework schema. Store ShipGlows governance context in reports or governance docs when the runtime schema does not accept it.
- If blog/article output is requested but no blog path or article surface is declared, report `surface missing: blog` instead of inventing a path.

## Cross-Surface Update Rules

| Trigger | Check these surfaces |
|---|---|
| New feature | Product docs, landing pages, changelog, FAQ, semantic cluster |
| UX/workflow change | Product docs, onboarding/support, FAQ |
| Bug fix | Changelog, support notes, FAQ when user-visible |
| Positioning change | Landing pages, blog intros, GTM docs, social/newsletter |
| New pillar topic | Pillar page, supporting articles, internal links, FAQ |
| Public content or public claim change | Editorial governance docs, claim register, page intent map, target public surface |
| Runtime content schema change | Content schema, rendered routes, editorial schema policy |
| Blog or article request | Declared blog/article route and collection; otherwise stop with `surface missing: blog` |

## Open Gaps

- [ ] `[surface/path/question to confirm]`
