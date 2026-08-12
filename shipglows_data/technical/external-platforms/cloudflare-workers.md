---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-cloudflare-workers
owner: Diane
confidence: high
risk_level: high
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
  - "Official Cloudflare Workers documentation entrypoints checked on 2026-07-12."
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# Cloudflare Workers Platform Note

## Purpose

Canonical ShipGlows reference for Cloudflare edge runtime, bindings, secrets, queues, storage, deployment, and runtime limits.

This note is a source map and decision contract, not a copy of vendor documentation.

## Source Map

- [Official source 1](https://developers.cloudflare.com/workers/)
- [Official source 2](https://developers.cloudflare.com/workers/runtime-apis/)
- [Official source 3](https://developers.cloudflare.com/workers/configuration/bindings/)
- [Official source 4](https://developers.cloudflare.com/workers/configuration/secrets/)

## Freshness Gate Use

Check current official docs plus the project's installed version, lockfile, configuration, and local usage note before making version-sensitive, security-sensitive, or deployment-sensitive claims.

## ShipGlows Decision Rules

- Keep this reference-only until a project adopts Workers.
- Treat bindings and secrets as deployment contracts, never ordinary public environment variables.
- Check runtime compatibility before using Node.js APIs or packages.
- Separate edge request handling from durable data and background processing.
- Verify preview and production environments independently.

## Security Notes

- Never persist tokens, credentials, private payloads, cookies, customer data, or raw provider logs in governance artifacts.
- Treat external tools, webhooks, database access, and deployment bindings as scoped capabilities.

## Validation

Run the declared local/runtime tests and deployment checks; verify bindings, routes, secrets by name only, and production behavior through the production owner.

## Reader Checklist

- identify the actual project version and runtime
- load the governance-root usage note when local behavior matters
- separate official behavior, local evidence, and inference
- record `fresh-docs checked`, `gap`, or `conflict`

## Maintenance Rule

Update this note when Cloudflare Workers changes APIs, compatibility, deployment, security, migration, or runtime behavior that affects ShipGlows decisions.
