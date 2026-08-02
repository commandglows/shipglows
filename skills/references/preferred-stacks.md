---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-23"
status: active
source_skill: 900-shipglows-core
scope: preferred-stack-presets
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - skills/references/question-contract.md
  - skills/references/app-blueprints.md
  - skills/001-sg-build/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/101-sg-ready/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Existing ShipGlows Auth SDK Policy: apps use Flutter, sites use Astro, backend/data uses Convex, scripts/jobs/tools use Python, and auth is mostly Clerk."
  - "Operator correction 2026-07-17: public/SEO sites habitually use Astro and application surfaces use Flutter."
  - "Operator decision 2026-07-16: Vercel is the default web host; the dedicated-server deployment matrix applies only when a separate server runtime is genuinely required."
  - "Operator clarification 2026-07-17: Astro, Vercel, and Flutter are first-recommendation defaults, and an app request should prefer one Flutter codebase for web, iOS, and Android instead of stopping at a mobile-only build."
next_review: "2026-10-17"
next_step: "none"
---

# Preferred Stack Presets

## Purpose

This reference records operator-approved ShipGlows technology defaults. Apply
these presets after the product platform footprint is known and before
blueprint matching or a broad greenfield technology comparison.

A preferred stack preset is not an app blueprint:

- a preset records the default technology direction approved by the operator;
- a blueprint is a validated app-archetype skeleton extracted from a shipped
  product and may additionally provide models, routes, folders, and conventions.

Do not make the operator repeatedly approve a preset already covering the
requested surfaces. Ask only about material product consequences that remain
uncovered, or about a justified exception.

These are first-recommendation defaults, not merely options that must appear in
a comparison. When they fit the product, lead with them, explain the resulting
surface split in plain language, and continue without asking the operator to
rediscover ShipGlows's habitual stack.

## Canonical Defaults

### Public and SEO-sensitive websites

- Framework: Astro.
- Hosting: Vercel.
- Recommend this pair first whenever a product needs a public website; use a
  different framework or host only for a documented product constraint.
- Use Astro for public, indexable, content-led surfaces such as landing pages,
  editorial pages, public menus, product/category pages, legal pages, and help.

### Cross-platform application surfaces

- Framework: Flutter.
- Targets: Flutter Web, iOS, and Android from the same application codebase.
- Hosting for the Flutter Web build: Vercel.
- Recommend the shared Web + iOS + Android footprint first for a new consumer
  or business application, even when the initial request names only a mobile
  app or only a browser app. Narrow the targets only when the operator states a
  durable product reason or a verified platform constraint makes one target
  unsuitable.
- Use Flutter for authenticated or transactional application flows, dashboards,
  configuration, ordering, and other app-centric interaction.

### Combined public site and application

- Public/SEO surface: Astro on Vercel.
- Application surface: Flutter Web on Vercel plus iOS and Android builds.
- Keep one backend and data authority for catalog, identity, permissions,
  availability, prices, orders, and other shared business state.
- Define an explicit navigation boundary between the Astro site and Flutter app
  while preserving brand, accessibility, analytics, and deep-link continuity.

#### Expected source layout

When the operator accepts the Astro plus Flutter preset with a shared backend, the expected source layout is:

- `site/` for the Astro public/SEO surface
- `app/` for the Flutter ordering application
- `backend/` for the shared backend authority
- `packages/contracts/` when typed cross-surface contracts are versioned separately

Deployment entrypoints such as Vercel build commands should be expressible from the monorepo root without relying on nested package discovery unless the project documents a durable exception.

### Supporting defaults

- Backend/data baseline: Convex.
- Scripts, jobs, and internal tools: Python.
- Authentication baseline: Clerk, often with Google sign-in.

These supporting defaults are starting assumptions, not universal mandates.
Provider suitability, official SDK support, transactional guarantees, legal or
payment requirements, cost, and portability may justify a different provider.
When an exception materially changes product operations or lock-in, research it
and ask one product-level decision rather than silently switching.

## Resolution Order

For greenfield work:

1. Establish launch and roadmap platform footprint.
2. Lead with and apply every compatible operator-approved preferred preset;
   presets are the first recommendation, not one neutral option among others.
3. Resolve an exact app blueprint if one exists; it may refine the preset but
   must not silently contradict it.
4. Research and ask only for material technology choices not already covered,
   including justified exceptions to a default.
5. Record the accepted direction and remaining provider decisions in the spec.

## Pressure Scenarios

- `PSP-001 site only`: a public content or SEO site defaults to Astro on Vercel.
- `PSP-002 app only`: an application targeting web, iOS, and Android defaults to
  Flutter, with its web build on Vercel.
- `PSP-003 site plus app`: a product needing public SEO pages and transactional
  web/mobile experiences defaults to Astro plus Flutter, not Next.js plus
  Flutter and not Flutter for the SEO surface.
- `PSP-004 backend exception`: when the baseline backend lacks suitable official
  platform support or creates material transactional risk, compare a justified
  alternative and obtain the operator's product-level decision.
- `PSP-005 apparently mobile-only app`: a new app initially described only for
  iOS or Android is first framed as one Flutter codebase for Web, iOS, and
  Android; it is narrowed only from explicit product intent or verified
  platform constraints.
