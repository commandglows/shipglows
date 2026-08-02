---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-05-24"
status: active
source_skill: 102-sg-start
scope: editorial-content-corpus
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/editorial/content-map.md
  - shipglows_data/editorial/ROADMAP.md
  - shipglows_data/editorial/
  - shipglows_data/business/business.md
  - shipglows_data/business/product.md
  - shipglows_data/branding/branding.md
  - shipglows_data/business/gtm.md
  - site/src/pages/
  - site/src/content/
  - skills/009-sg-marketing/SKILL.md
depends_on:
  - artifact: "shipglows_data/editorial/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.7.0"
    required_status: draft
supersedes: []
evidence:
  - "Ready spec requires a compact loading reference for editorial and content agents."
  - "300-sg-docs first-run bootstrap and update adoption now treat missing editorial governance as recoverable bootstrap state when public surfaces exist."
  - "Operator decision on 2026-05-24: monorepos use one root shipglows_data editorial corpus with scoped public surfaces."
next_review: "2026-06-01"
next_step: "/300-sg-docs audit editorial"
---

# Editorial Content Corpus

## Purpose

This reference tells content, copy, docs, and Editorial Reader agents how to load ShipGlows public-content context without re-reading the whole repo.

## Load Order

1. Resolve the governance root first. In a monorepo, use the monorepo-root `shipglows_data/`, not a nested app/site/package `shipglows_data/`.
2. Read `shipglows_data/editorial/content-map.md` first. It is the canonical public content routing map. Root `CONTENT_MAP.md` is a migration source only.
3. Read `shipglows_data/editorial/README.md` for the editorial governance index when present; if it is missing on a public/content project, report an editorial governance bootstrap trigger and route to `/300-sg-docs editorial`. Legacy `docs/editorial/` is a migration source only.
4. Read `shipglows_data/editorial/public-surface-map.md` for public surfaces and update triggers.
5. Read `shipglows_data/editorial/page-intent-map.md` for page jobs, CTAs, source contracts, and shared-file risk.
6. Read `shipglows_data/editorial/claim-register.md` when public claims touch security, privacy, compliance, AI reliability, automation, speed, savings, availability, pricing, or business outcomes.
7. Read `shipglows_data/editorial/editorial-update-gate.md` to produce an `Editorial Update Plan` or `Claim Impact Plan`.
8. Read `shipglows_data/editorial/astro-content-schema-policy.md` before editing `site/src/content/**`.
9. Read `shipglows_data/editorial/blog-and-article-surface-policy.md` before recommending blog or article output.
10. Read `skills/references/task-registry-routing.md` before writing durable editorial follow-up tasks or backlog items.

## Contract Sources

Use these contracts to bound public copy:

- `shipglows_data/business/business.md`: audience, value proposition, market, business model uncertainty.
- `shipglows_data/business/product.md`: user problem, desired outcomes, workflow scope, non-goals.
- `shipglows_data/branding/branding.md`: voice, trust posture, vocabulary, and claim boundaries.
- `shipglows_data/business/gtm.md`: public promise, channels, objections, proof limits, and conversion path.
- `shipglows_data/business/portfolio-project-pitch-links.md`: index of versioned pitch-file URLs for `#shipglows-owner` and `#portfolio` reasoning.
- `shipglows_data/technical/guidelines.md`: internal language doctrine and documentation rules.
- `shipglows_data/business/project-competitors-and-inspirations.md`: optional competitors, alternatives, inspiration, and anti-pattern registry.
- `shipglows_data/business/affiliate-programs.md`: optional affiliate, referral, partner, sponsorship, and disclosure registry.
- Ready specs and verified implementation behavior when the public claim depends on a recent change.

## Public Surface Sources

Use these files to inspect the actual public site:

- `site/src/pages/`
- `site/src/components/`
- `site/src/content.config.ts`
- `site/src/content/skills/`
- `site/package.json`
- `shipglows-site/pnpm-lock.yaml`

Astro runtime content must preserve the schema declared in `site/src/content.config.ts`. Report ShipGlows context versions in the plan or final report when the runtime content schema does not accept governance metadata.

## Skill Consumers

These skills should use this corpus before changing or judging public content:

- `skills/300-sg-docs/SKILL.md`
- `skills/007-sg-content/references/repurpose-playbook.md`
- `skills/009-sg-marketing/SKILL.md`
- `skills/200-sg-redact/SKILL.md`
- `skills/201-sg-enrich/SKILL.md`

## Output Expectations

- Missing `shipglows_data/editorial/README.md` on a public/content project: treat it as a first-run bootstrap trigger.
- Missing `shipglows_data/editorial/ROADMAP.md` on a public/content project after bootstrap or update: treat it as a recoverable editorial-governance normalization gap and route to `/300-sg-docs editorial` or `/300-sg-docs update`.
- Existing project adoption: `300-sg-docs update` reports editorial governance as `created`, `already existed`, `needs audit`, `skipped - no editorial surfaces detected`, or `blocked`.
- Public-content impact: produce an `Editorial Update Plan`.
- Sensitive public claims: produce a `Claim Impact Plan`.
- Durable editorial follow-up: write the task record to `shipglows_data/editorial/ROADMAP.md`, not to `shipglows_data/workflow/TASKS.md`, unless the follow-up is actually technical execution.
- No public impact: state `no editorial impact` with a reason.
- Missing blog or article path: report `surface missing: blog`.
- Runtime schema conflict: preserve the schema and report the incompatibility.
- Monorepo content surfaces: keep one root `shipglows_data/editorial/` corpus and scope entries by app/site/package; do not create duplicate editorial corpora under each frontend.

## Maintenance Rule

Update this reference when editorial governance docs, public surface maps, claim plan formats, Astro content policy, or content-writing skill consumers change.
