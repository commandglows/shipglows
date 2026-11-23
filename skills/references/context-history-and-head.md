---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlows
created: "2026-08-25"
updated: "2026-11-23"
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
  - tools/product_updates.py
  - tools/feedback_triage.py
  - tools/code_context_graph.py
  - skills/references/context-quality-contract.md
  - skills/301-sg-context/SKILL.md
  - skills/304-sg-changelog/SKILL.md
  - skills/104-sg-end/SKILL.md
  - skills/005-sg-ship/SKILL.md
  - shipglows_data/workflow/history/
  - shipglows-app-engine/shared/updates
  - shipglows-app-engine/shared/roadmap
  - skills/references/content-tree-model.md
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "2026-11-23: feedback triage (tools/feedback_triage.py) creates hidden roadmap items through this projection; pointer to product-feedback-triage.md."
  - "2026-11-23: append auto-projects public events (updates and roadmap) into sites declared by .shipglows.product-updates.json; operator gate pending/publish."
  - "2026-11-23: public events project into draft update entries of @shipglows/astro-updates sites; agent roadmap writes stay hidden and append-only."
  - "Operator correction 2026-09-01: closure refreshes bounded context after Git-state changes and uses exact changed paths plus the canonical code-docs map before documentation classification."
  - "Operator approval on 2026-08-25 selected date-segmented immutable history, branch/worktree-aware Context Head, automatic normal-path capture, and a public bilingual allowlisted projection."
  - "Operator approval on 2026-08-30 made changelog classification and significant-event capture a shared closure behavior for every managed repository."
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

Before documentation classification in verification, closure, or full-close
shipping, reconstruct the exact task-owned changed paths from current Git state
and refresh the bounded head/capsule if branch, HEAD, staged, unstaged, or
untracked state changed. Compare code paths with the canonical
`code-docs-map.md`; a stale or incomplete generated view triggers targeted
canonical fallback and never authorizes `not impacted` by itself.

Context Head generation combines the recent semantic event window with the native derived code graph through the shared capsule ranking API. Up to eight recent event file references seed a projection capped at 40 evidence items and 20 related source pointers. The generated section reports truncation and selection-reason counts explicitly. The graph and capsule are disposable discovery views, never canonical truth; an unavailable graph degrades to targeted canonical retrieval without making history unreadable.

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

At closure, record at most one significant event per closure. Select the event that best preserves the delivered outcome, proof, invalidation, or durable next action; do not create separate events merely to mirror report blocks. A repository with no significant event remains a valid empty state.

## Public Projection Gate

Events are internal by default. Add a `public` object only when all of these are proven:

- the change is useful to ShipGlows users and the public surface is declared;
- English and French title/summary fields are complete and claim-equivalent;
- the category and delivery state use canonical codes;
- a compact delivery proof is present;
- wording does not expose internal summaries, branches, worktrees, paths, logs, vulnerabilities, customer data, secrets, or unshipped roadmap promises.

A roadmap-only `public` object (`public.roadmap` without changelog copy) skips the bilingual copy rules, never the proof rule for `shipped`.

`DELIVERY_SITE_BUILD` is valid only when the announced site behavior ships in the same build. `DELIVERY_SHIPPED` and `DELIVERY_AVAILABLE` require corresponding evidence. Ambiguous entries stay internal without blocking other eligible daily updates.

The public site reads only the public allowlist. Raw history objects never become page props, HTML, JSON endpoints, or client payloads.

The closure report classifies the changelog projection separately: `public-ready` when eligible bilingual public copy is prepared for a declared delivery path, `internal-only` when the significant event must remain private, `not applicable` when no significant changelog event exists, or `needs review` when eligibility, copy, safety, or evidence remains unresolved. `public-ready` is readiness, not proof that an entry is published, deployed, or available. A public object still obeys every allowlist and delivery-proof rule above.

## Product Updates And Roadmap

When a closure, ship or release records a public-ready event, include its `public` object in the same `append`; add `public.roadmap` (`--roadmap <item id>:<status>`, repeatable, or `--public-file <json>` for new-item copy) when the work moves a roadmap item. A roadmap-only `public` (no changelog copy) may omit `delivery`, but `shipped` always requires `public.delivery` proof: `append` refuses it otherwise.

Projection is automatic: when the repository has `.shipglows.product-updates.json`, `append` projects the event into each declared site and returns the report in `projection` (event kept even when a site fails). Report `created`, `unchanged`, `skipped-edited`, `already-projected`, `missing`, `skipped-stale`; never force them. Re-run with `project --event-id <evt_...> [--dry-run]`; a site without the config uses `project-updates --site-root <site> --product <key>`.

The tool writes `src/content/updates/<locale>/<id>.md` with `status: draft`, `source: { producer: agent, ref: <event id> }` (`shared/updates` contract) and never overwrites. Roadmap: it appends to `statusHistory` (never rewrites it), sets `status`, and on `shipped` links `relatedRoadmap[]` and `shippedIn[]` in every locale; a new item needs `title`/`summary` copy and is created `visibility: hidden`. Agents never set `status: published` nor `visibility: public`, nor write vote counts or requester identities: the operator reviews `pending` and runs `publish --id <id>` or `--all`, or `sg-release` after explicit review. `shipglows_app/site` still exports `shipglows.public-changelog/v1` and accepts changelog-only `public` objects.

Triage of one product's stored feedback, requests and votes (`tools/feedback_triage.py`, items created hidden through this projection): `product-feedback-triage.md`.

## Recovery And Growth

Missing history is a valid empty state. Invalid JSON, unsupported schema, symlinks, path escape, oversize input, secret-like public copy, partial locale data, or conflicting duplicates fail closed with bounded diagnostics.

Keep events compact and significant. The year/month/day layout supports future year-level archival without changing IDs or the public schema. Do not introduce a database, compaction rewrite, or destructive retention policy until measured repository growth justifies a separately approved migration.

## Proof

- `python -m unittest tools.test_context_history tools.test_context_history_contract tools.test_product_updates`
- Run project-local public-projection tests and build when a public changelog consumer changes.
- Recheck cache freshness after any relevant Git state change.
