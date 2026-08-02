---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-09"
updated: "2026-07-09"
status: active
source_skill: 009-sg-skill-build
scope: content-owner-handoffs
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/007-sg-content/references/content-router.md
  - skills/007-sg-content/references/repurpose-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Content owner routing uses one 007 repurpose mode and one canonical owner matrix."
next_review: "2026-08-09"
next_step: "/103-sg-verify content-owner-handoffs"
---

# Content Owner Handoffs

## Purpose

Define the canonical owner matrix for content work after source intake or content intent is understood.

This reference centralizes who owns the next step. Local skills may keep activation-critical routing sentences, but the owner list and handoff payload should stay shared.

## Owner Matrix

| Need | Owner |
| --- | --- |
| External URL/source triage | `205-sg-veille` |
| Deep research report | `203-sg-research` |
| Market, keyword, competitor, or demand study | `009-sg-marketing market` |
| Source-faithful pack, reusable source analysis, or applied repurposing handoff | `007-sg-content repurpose <source>` |
| Original long-form article, guide, editorial, or public draft | `200-sg-redact` |
| Upgrade existing content with research, structure, or clarity | `201-sg-enrich` |
| Positioning, funnel, trust, offer, or launch-readiness audit | `009-sg-marketing gtm` |
| Clarity, tone, CTA, and page-level copy audit | `009-sg-marketing copy` |
| Persona, offer, persuasion, and conversion audit | `009-sg-marketing copywriting` |
| Technical or on-page SEO / search-intent audit | `406-sg-seo` |
| README, docs, or content-governance update | `300-sg-docs` |
| Audience email sequences | `sg-emailing` |
| Public browser proof | `108-sg-browser` |
| Verification | `103-sg-verify` |
| Ship | `005-sg-ship` |

## Handoff Payload

When one skill routes content work to another, include at minimum:

- target surface or file
- source truth
- source proof
- intended content move
- claim constraints or proof limits
- recommended command or owner invocation
- priority and next step

## Routing Rules

- Prefer the smallest owner that can safely complete the next step.
- Route to `007-sg-content repurpose <source>` first when the work starts from source material and the downstream surface is not yet fully resolved.
- Route to `300-sg-docs` when the main job is governance, README/docs maintenance, metadata, or declared documentation surfaces.
- Route to `200-sg-redact` only once source truth, surface, and claim posture are clear enough to draft.
- Route to `201-sg-enrich` when the target already exists and needs strengthening more than net-new writing.
- Use audit owners when the job is critique or optimization rather than authorship.
- Use `103-sg-verify` before `005-sg-ship` when a content task changed governed repo artifacts or public surfaces.

## Non-Goals

- This reference does not decide whether a spec is needed.
- This reference does not override local stop conditions, public-surface gates, or storage contracts.
- This reference does not authorize one owner skill to edit through another owner's boundary.
