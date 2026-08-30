---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-05-24"
updated: "2026-08-26"
status: draft
source_skill: sg-docs
scope: external-platforms-corpus
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/references/technical-docs-corpus.md
  - shipglows_data/technical/code-docs-map.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Operator decision on 2026-05-24: maintain a global source corpus for Freshness Gate and project-local usage docs for precise project adoption."
  - "Initial common provider set added: Vercel, Firecrawl, Convex, Clerk, Firebase, Google Cloud, Supabase, Sentry, Astro, Python, Bash, Gum, and Neovim."
  - "Operator decision on 2026-05-24: project-local provider usage notes are conditional on local risk/complexity, not mandatory per technology."
  - "Operator decision on 2026-05-24: provider usage notes resolve from the governance root, which is the monorepo root for monorepos."
  - "CrewAI global platform note added for agent orchestration, tools, memory, structured outputs, and dependency freshness."
  - "Lemon Squeezy global platform note added for payment API/webhook, official SDK, and CLI/MCP availability decisions."
  - "TypeScript, JavaScript, Flutter, and Dart notes added as canonical sources for technology specialist profiles."
  - "Stripe Managed Payments note added after the operator selected it as the only active direct-payment provider for every current and future Glows suite product; Lemon Squeezy remains superseded historical evidence."
  - "Turso added as a specialist-backed note; PydanticAI, LangGraph, Cloudflare Workers, Hono, Drizzle ORM, and TanStack Start added as reference-only watchlist notes."
  - "Auth0 added with explicit SDK, native operator CLI, Deploy CLI, MCP, tenant, authentication, and secret boundaries."
  - "Doppler added with native CLI, keychain, secret injection, environment scope, service-token, MCP, and agent-safety boundaries."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# External Platforms Corpus

## Purpose

This directory is the global ShipGlows technical source layer for external platforms, SDKs, providers, and tools that often affect implementation quality, security, deployment proof, dependency upgrades, and technical freshness.

It is not a mirror of vendor documentation. Each platform note is a short, source-backed operational cheat sheet that tells agents where to verify current behavior and how that provider usually affects ShipGlows decisions.

## Global vs Governance-Root Usage

Use two layers:

- Global platform note: `shipglows_data/technical/external-platforms/<provider>.md`
- Governance-root usage note: `<governance-root>/shipglows_data/technical/platforms/<provider>.md`

The global note records official sources, freshness anchors, recurring risks, command/tool routing, and ShipGlows decision rules. The governance-root usage note records how a project, monorepo, app, or package actually uses the provider: environment, domains, validation surface, integrations, secrets locations by name only, and known exceptions.

Usage notes are not mandatory for every technology. Create one only when the local usage materially affects agent decisions: auth, deployment, runtime behavior, SDK/API assumptions, storage, migrations, security, compliance, secrets handling, observability, production proof, or local exceptions. If usage is standard and fully clear from code/config plus the global note, report `not needed - standard usage covered by code/config and global note`.

For monorepos, keep usage notes at the monorepo-root `shipglows_data/technical/platforms/` and scope them by app/package inside the note. Do not duplicate provider notes under each app/site/lab/package.

Do not put project secrets, private deployment URLs, tokens, raw logs, or account-specific identifiers in either layer. Usage notes may name expected environment variable keys, provider features, and validation commands, but not secret values.

## When Agents Should Read This Corpus

Read the relevant global platform note when a task depends on:

- deployment, build, runtime, environment, caching, logs, or preview/production semantics
- SDK behavior, API shape, release notes, deprecations, migrations, or security advisories
- auth callbacks, cookies, domains, webhooks, storage, AI providers, background jobs, or external APIs
- dependency upgrades where release notes may imply code or configuration changes
- a `010-sg-technical deps|audit|migrate`, `sg-prod`, `sg-auth-debug`, `sg-verify`, or future `sg-tech-watch` decision

Then read the governance-root usage note if one exists or if project-specific provider behavior affects the decision. If the project clearly needs a local note but has none, report a documentation gap and recommend creating one from `templates/project_platform_usage.md`.

## Freshness Policy

Global platform notes must keep links to primary sources:

- official docs overview or canonical guide
- official CLI/API reference when relevant
- changelog or releases feed
- security/advisory/status source when relevant

Changelogs, release notes, GitHub issues, and blogs can explain symptoms or trigger review, but implementation decisions still need official docs or primary source confirmation unless the platform has no better source.

## Platform Note Minimum Sections

Each provider note should include:

- Purpose
- Source Map
- Freshness Gate Use
- ShipGlows Decision Rules
- Common Project-Local Fields
- Security Notes
- Validation
- Reader Checklist
- Maintenance Rule

## Current Global Notes

- `astro.md`
- `auth0.md`
- `bash.md`
- `clerk.md`
- `cloudflare-workers.md`
- `convex.md`
- `crewai.md`
- `dart.md`
- `drizzle-orm.md`
- `doppler.md`
- `firebase.md`
- `firecrawl.md`
- `flutter.md`
- `google-cloud.md`
- `gum.md`
- `hono.md`
- `javascript.md`
- `langgraph.md`
- `lemonsqueezy.md`
- `neovim.md`
- `python.md`
- `pydanticai.md`
- `sentry.md`
- `stripe-managed-payments.md`
- `supabase.md`
- `tanstack-start.md`
- `turso.md`
- `typescript.md`
- `vercel.md`

## Maintenance Rule

Update this index when a global provider note is added, renamed, removed, or when the governance-root usage template changes.
