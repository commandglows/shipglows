---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-25"
updated: "2026-08-25"
status: active
source_skill: 900-shipglows-core
scope: context-history-and-head
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/context_history.py
  - skills/references/context-quality-contract.md
  - skills/301-sg-context/SKILL.md
  - skills/304-sg-changelog/SKILL.md
  - skills/104-sg-end/SKILL.md
  - skills/005-sg-ship/SKILL.md
  - shipglows_data/workflow/history/
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator approval on 2026-08-25 selected date-segmented immutable history, branch/worktree-aware Context Head, automatic normal-path capture, and a public bilingual allowlisted projection."
next_review: "2026-09-25"
next_step: none
---

# Context History And Context Head

## Purpose

Keep significant ShipGlows work resumable without turning every command into durable meta-work. Git, specs, governed files, activity evidence, and proofs remain canonical. History events are compact semantic pointers; `CONTEXT_HEAD` is a bounded generated cache.

## Availability And Authority

Use this contract when the selected Git project contains `shipglows_data/` or explicitly adopts the context-event format. Resolve the project root first and apply its mutation approval rules.

- Read-only context may run `tools/context_history.py --project-root <root> head --print --no-write` without creating a cache.
- Writing `.shipglows/CONTEXT_HEAD.md`, `.shipglows/CONTEXT_HEAD.json`, or a history event requires the current task's applicable mutation authority.
- The cache directory is worktree-local and ignored by Git. Event shards are repository truth only after normal review and delivery.
- If the tool is absent, the project does not adopt the format, or writing is unauthorized, use the native targeted Git/source fallback and state that no Context Head cache was persisted.

## Read And Refresh

Before broad repository reconstruction, run `check` when a cache exists. A branch, HEAD, worktree, staged, unstaged, or untracked fingerprint change makes it stale. Regenerate from current Git state and the event corpus before use; never report a stale cache as current.

Read the generated head as a discovery and resume view, then revalidate decision-changing claims against their canonical sources. Do not reload the whole repository when only one dependent claim was invalidated.

Default bounds are 30 significant events and 16,000 characters. Increasing them requires evidence that the smaller projection omitted a decision-changing item; file or token volume is never a quality target.

## Significant Event Capture

Append exactly one immutable event at a meaningful transition:

- accepted product or architecture decision;
- implemented user-visible change or fix;
- verification, delivery, or production proof;
- explicit context invalidation;
- durable next action that prevents work from being lost.

Do not record shell commands, intermediate attempts, formatting, routine reads, repeated status messages, hidden reasoning, raw logs, prompts, transcripts, secrets, credentials, customer data, private URLs, or low-value implementation chatter.

Each event uses one unique file under `shipglows_data/workflow/history/YYYY/MM/DD/`. Parallel work never appends to a shared daily file. Event identity is immutable: an identical replay deduplicates, while divergent reuse fails closed.

## Public Projection Gate

Events are internal by default. Add a `public` object only when all of these are proven:

- the change is useful to ShipGlows users and the public surface is declared;
- English and French title/summary fields are complete and claim-equivalent;
- the category and delivery state use canonical codes;
- a compact delivery proof is present;
- wording does not expose internal summaries, branches, worktrees, paths, logs, vulnerabilities, customer data, secrets, or unshipped roadmap promises.

`DELIVERY_SITE_BUILD` is valid only when the announced site behavior ships in the same build. `DELIVERY_SHIPPED` and `DELIVERY_AVAILABLE` require corresponding evidence. Ambiguous entries stay internal without blocking other eligible daily updates.

The public site reads only the public allowlist. Raw history objects never become page props, HTML, JSON endpoints, or client payloads.

## Recovery And Growth

Missing history is a valid empty state. Invalid JSON, unsupported schema, symlinks, path escape, oversize input, secret-like public copy, partial locale data, or conflicting duplicates fail closed with bounded diagnostics.

Keep events compact and significant. The year/month/day layout supports future year-level archival without changing IDs or the public schema. Do not introduce a database, compaction rewrite, or destructive retention policy until measured repository growth justifies a separately approved migration.

## Proof

- `python -m unittest tools.test_context_history tools.test_context_history_contract`
- Run project-local public-projection tests and build when a public changelog consumer changes.
- Recheck cache freshness after any relevant Git state change.
