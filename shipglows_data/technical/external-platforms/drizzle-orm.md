---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-drizzle-orm
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
    required_status: draft
supersedes: []
evidence:
  - "Official Drizzle ORM documentation entrypoints checked on 2026-07-12."
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# Drizzle ORM Platform Note

## Purpose

Canonical ShipGlows reference for TypeScript SQL schemas, queries, migrations, generated artifacts, and database-driver boundaries.

This note is a source map and decision contract, not a copy of vendor documentation.

## Source Map

- [Official source 1](https://orm.drizzle.team/docs/overview)
- [Official source 2](https://orm.drizzle.team/docs/sql-schema-declaration)
- [Official source 3](https://orm.drizzle.team/docs/migrations)
- [Official source 4](https://orm.drizzle.team/docs/drizzle-kit-overview)

## Freshness Gate Use

Check current official docs plus the project's installed version, lockfile, configuration, and local usage note before making version-sensitive, security-sensitive, or deployment-sensitive claims.

## ShipGlows Decision Rules

- Keep this reference-only until adopted by a project.
- Treat schema definitions and migrations as distinct but synchronized contracts.
- Review generated SQL before applying it to shared or production databases.
- Preserve transaction, index, constraint, and dialect-specific behavior.
- Do not infer authorization from ORM typing; enforce it at the application/database boundary.

## Security Notes

- Never persist tokens, credentials, private payloads, cookies, customer data, or raw provider logs in governance artifacts.
- Treat external tools, webhooks, database access, and deployment bindings as scoped capabilities.

## Validation

Run typecheck, migration generation/checks, SQL diff review, focused database tests, and rollback/backup proof proportional to risk.

## Reader Checklist

- identify the actual project version and runtime
- load the governance-root usage note when local behavior matters
- separate official behavior, local evidence, and inference
- record `fresh-docs checked`, `gap`, or `conflict`

## Maintenance Rule

Update this note when Drizzle ORM changes APIs, compatibility, deployment, security, migration, or runtime behavior that affects ShipGlows decisions.
