---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-tanstack-start
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/technical/external-platforms/README.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "1.0.0"
    required_status: draft
supersedes: []
evidence:
  - "Official TanStack Start documentation entrypoints checked on 2026-07-12."
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# TanStack Start Platform Note

## Purpose

Canonical ShipGlows reference for TanStack Start full-stack React routing, server functions, rendering, data loading, and deployment adapters.

This note is a source map and decision contract, not a copy of vendor documentation.

## Source Map

- [Official source 1](https://tanstack.com/start/latest/docs/framework/react/overview)
- [Official source 2](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
- [Official source 3](https://tanstack.com/start/latest/docs/framework/react/guide/routing)

## Freshness Gate Use

Check current official docs plus the project's installed version, lockfile, configuration, and local usage note before making version-sensitive, security-sensitive, or deployment-sensitive claims.

## ShipGlows Decision Rules

- Keep this reference-only and recheck maturity before each adoption decision.
- Do not standardize it without a project-specific advantage over the current Astro/React stack.
- Keep server-only code, secrets, and client bundles strictly separated.
- Check adapter, deployment, caching, and server-function behavior against current docs.
- Require a migration and maintenance-cost comparison before replacing an established framework.

## Security Notes

- Never persist tokens, credentials, private payloads, cookies, customer data, or raw provider logs in governance artifacts.
- Treat external tools, webhooks, database access, and deployment bindings as scoped capabilities.

## Validation

Run typecheck, tests, build, target-adapter proof, and browser checks for routing, data loading, server functions, and hydration.

## Reader Checklist

- identify the actual project version and runtime
- load the governance-root usage note when local behavior matters
- separate official behavior, local evidence, and inference
- record `fresh-docs checked`, `gap`, or `conflict`

## Maintenance Rule

Update this note when TanStack Start changes APIs, compatibility, deployment, security, migration, or runtime behavior that affects ShipGlows decisions.
