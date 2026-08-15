---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.8.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-15"
status: active
source_skill: 102-sg-start
scope: technical-docs-corpus
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/technical/
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/technical/design-system-authority.md
  - shipglows_data/technical/external-platforms/
  - templates/project_platform_usage.md
  - templates/technical_module_context.md
  - skills/300-sg-docs/SKILL.md
depends_on:
  - artifact: "shipglows_data/technical/code-docs-map.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "skills/references/code-navigation-and-function-docs.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Ready spec requires a skill-facing reference for technical docs loading."
  - "300-sg-docs first-run bootstrap and update adoption now treat missing code-docs maps as recoverable bootstrap state."
  - "External platform corpus added for global Freshness Gate source notes and governance-root provider usage docs."
  - "Operator decision on 2026-05-24: provider usage notes are risk-driven, not mandatory per technology."
  - "Operator decision on 2026-05-24: monorepos use one root shipglows_data corpus with scoped app/package coverage."
  - "Operator decision on 2026-06-11: UI projects need an explicit design-system authority so agents cannot bypass centralized tokens."
  - "Operator clarification 2026-08-15: closure must visibly classify documentation and align directly mapped docs before claiming completion."
next_review: "2026-06-01"
next_step: "/300-sg-docs technical audit"
---

# Technical Docs Corpus

## Purpose

This reference tells ShipGlows skills how to use the internal `shipglows_data/technical/` layer without loading the whole repository or turning agent entry files into mega-docs.

## Loading Rule

1. Resolve the governance root first. In a monorepo, use the monorepo-root `shipglows_data/`, not a nested app/package `shipglows_data/`.
2. Read `shipglows_data/technical/code-docs-map.md` first for any code-changing task when it exists; if it is missing, report a technical governance bootstrap trigger and route to `/300-sg-docs technical`. Legacy `docs/technical/code-docs-map.md` is a migration source only.
3. Match changed or target paths to the map when present.
4. Load only the primary technical doc and necessary secondary docs.
5. Produce a `Documentation Update Plan` after every code-changing execution wave and again during end verification. Before closure, apply `documentation-reflection-gate.md`, align directly mapped impacted docs in the same approved workstream, and expose its exact classification in the closure report.
6. Keep shared docs sequential unless the ready spec assigns disjoint ownership.
7. When a task depends on an external provider, SDK, framework, hosting platform, API, or toolchain behavior, read the matching global note under `shipglows_data/technical/external-platforms/` when it exists. Then read the governance-root usage note under `shipglows_data/technical/platforms/` only when it exists or when the task is materially affected by project-specific provider configuration.
8. For UI projects, read the surface-scoped design-system authority such as `shipglows_data/technical/<surface>/design-system-authority.md`, or the documented equivalent, before UI/design implementation, audits, scaffolding, verification, or platform parity work. If it is missing, report a technical governance bootstrap trigger and route to `/300-sg-docs technical` or `/006-sg-design` before visual changes.
9. When the operator starts from a behavior term rather than a path, load `skills/references/code-navigation-and-function-docs.md` and treat the context layer in this order: `context.md` for system orientation, `context-function-tree.md` for structural orientation, `code-docs-map.md` for path routing, then a mapped behavior index or domain model for term disambiguation.
10. If the behavior term is mapped, use the behavior index before broad repo search.
11. If the behavior term is ambiguous, report the named meanings instead of assuming one.
12. If the behavior term is unmapped and the recovery cost is clearly non-trivial, classify it as a `technical navigation bootstrap gap` or `technical navigation drift` and route to `/300-sg-docs technical`.

## `300-sg-docs` Technical Mode Contract

`300-sg-docs technical` or `300-sg-docs technical audit` should:

- treat a missing `shipglows_data/technical/code-docs-map.md` as a first-run bootstrap trigger, not as an immediate read failure
- create baseline `shipglows_data/technical/README.md` and `shipglows_data/technical/code-docs-map.md` governance scaffolding for code projects when safe
- in monorepos, create or update the technical layer only at the monorepo root, prefer theme-first folders, and scope surfaces inside `shipglows_data/technical/<surface>/` or `code-docs-map.md`
- report nested app/package `shipglows_data/` directories as migration debt unless a standalone-project exception is documented
- record an explicit `non-coverage` reason when no major code area can be mapped
- verify that every major code area in `code-docs-map.md` has a primary technical doc or explicit non-coverage reason
- scaffold missing subsystem docs from `templates/technical_module_context.md`
- scaffold missing behavior indexes from `templates/technical_behavior_index.md` when a complex term family has repeated recovery cost
- check stale path references, missing validations, missing `Maintenance Rule` sections, and missing Reader triggers
- check whether complex term families have a behavior index or an explicit no-coverage reason
- check whether mapped behavior indexes link to key symbols, tests, specs/bugs, and decisions or an explicit no-decision reason
- classify missing or stale term-based recovery as `technical navigation bootstrap gap` or `technical navigation drift`
- check whether UI projects declare `shipglows_data/technical/<surface>/design-system-authority.md` or an equivalent authority covering brand contract, token source, theme carrier, component bridge, layout/motion authority, forbidden bypasses, and validation
- check global external platform notes when provider behavior is part of the documented technical contract
- report a governance-root platform usage gap only when provider use is project-specific enough to affect validation, auth, deploy, runtime, SDK behavior, storage, security, migrations, secrets handling, observability, compliance, or production proof
- verify that `technical_module_context` files pass `tools/shipglows_metadata_lint.py`
- fail or report a blocking gap when a mapped code area changed but no impacted doc appears in the `Documentation Update Plan`
- fail closure when its report omits the visible `updated`, `not impacted — <concrete reason>`, or `needs review — <surface>` documentation classification

`300-sg-docs update` should also detect missing technical governance in existing projects and report one of `created`, `already existed`, `needs audit`, `skipped - no code areas detected`, or `blocked` with `/300-sg-docs technical` as the recovery command.

## Documentation Update Plan

Use the format defined in `shipglows_data/technical/code-docs-map.md`. The owner role is usually `executor` for the subsystem doc and `integrator` for shared files such as `code-docs-map.md`, `AGENT.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/guidelines.md`, and `shipglows_data/workflow/playbooks/spec-driven-workflow.md`.

## External Platform Corpus

Global provider notes live under `shipglows_data/technical/external-platforms/`. They preserve source maps and ShipGlows decision rules for the Freshness Gate, but they must not duplicate vendor documentation.

Provider usage lives under the governance root at `shipglows_data/technical/platforms/<provider>.md`. In a monorepo, the same note can cover one app/package or multiple surfaces; use explicit scope and path references instead of duplicating notes under each subdirectory. These files document actual adoption: environments, validation surface, domains/callback expectations, env var keys, MCP/CLI evidence route, and local exceptions.

Do not require one usage note per technology. Create one from `templates/project_platform_usage.md` only when local usage changes the agent's decisions or proof route. For standard, low-risk usage where the code/config plus the global platform note are enough, record `not needed - standard usage covered by code/config and global note` instead of creating filler documentation.

Use the global note to decide what current external sources to check. Use the governance-root usage note to decide whether local, preview, production, MCP, CLI, browser, or manual proof is authoritative for that project or monorepo surface.

## Safety Rules

- The Reader diagnoses impact; it does not silently edit docs unless explicitly assigned.
- `shipglows_data/technical/` is internal-only in v1.
- Do not copy secrets, tokens, private URLs, raw logs, cookies, or credentials into technical docs.
- Do not copy vendor documentation into the corpus; keep source links, operational rules, freshness evidence, and project-specific adoption details.
- Do not add per-file `last_verified_against` fields in v1.
- If `AGENTS.md` exists, it must be a symlink to `AGENT.md`.

## Maintenance Rule

Update this reference when the technical docs map, template, Reader plan format, or `300-sg-docs` technical mode contract changes.
