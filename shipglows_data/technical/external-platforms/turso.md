---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-turso
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
  - "Official Turso documentation entrypoints checked on 2026-07-12."
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# Turso Platform Note

## Purpose

Canonical ShipGlows reference for Turso Cloud, embedded Turso/libSQL, CLI authentication, schema proof, replicas, and MCP boundaries.

This note is a source map and decision contract, not a copy of vendor documentation.

## Source Map

- [Official source 1](https://docs.turso.tech/introduction)
- [Official source 2](https://docs.turso.tech/cli/introduction)
- [Official source 3](https://docs.turso.tech/cli/authentication)
- [Official source 4](https://docs.turso.tech/cli/db/shell)
- [Official source 5](https://docs.turso.tech/tursodb/quickstart)

## Freshness Gate Use

Check current official docs plus the project's installed version, lockfile, configuration, and local usage note before making version-sensitive, security-sensitive, or deployment-sensitive claims.

## ShipGlows Decision Rules

- Distinguish hosted Turso Cloud CLI operations from embedded/local database behavior.
- Use the official Cloud CLI for authoritative hosted schema proof; do not substitute local MCP inspection.
- Keep auth tokens and database credentials out of docs, logs, prompts, and broad MCP configuration.
- Prefer project-local dependency and migration contracts; verify libSQL/SQLite compatibility explicitly.
- Require backups and an explicit mutation scope before destructive hosted database operations.

## Security Notes

- Never persist tokens, credentials, private payloads, cookies, customer data, or raw provider logs in governance artifacts.
- Treat external tools, webhooks, database access, and deployment bindings as scoped capabilities.

## Validation

Check the local package/CLI version, authentication status without printing tokens, project migrations, and focused hosted or local database proof.

## Reader Checklist

- identify the actual project version and runtime
- load the governance-root usage note when local behavior matters
- separate official behavior, local evidence, and inference
- record `fresh-docs checked`, `gap`, or `conflict`

## Maintenance Rule

Update this note when Turso changes APIs, compatibility, deployment, security, migration, or runtime behavior that affects ShipGlows decisions.
