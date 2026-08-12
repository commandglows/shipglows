---
name: 600-sg-local-cloud-sync
description: "Frame local-cloud promotion, merge, sync UX, and security work."
argument-hint: <project, feature, data domains, or sync question>
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned files. Project artifacts resolve from the current project root.

## Chantier And Report Modes

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Attach to one unique spec when present; otherwise use `(local)`. Apply `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` for trace or `Chantier potentiel`, and `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before the final report. Default to concise `report=user`; full Sync Contract, domain matrix, commands, decisions, and proof gaps belong to `report=agent`.

## Mission

`600-sg-local-cloud-sync` owns the data-trust contract for local-first data becoming account-backed cloud data: promotion, hydration, merge/conflict, deletes, offline durability, sync UX, privacy, and proof. It does not own implementation lifecycle (`001`/`102`), activation copy (`008`), or entitlement decisions (`601`).

## Scope And Route Gate

Accept one project, feature, data domain, audit, or sync question. Produce a read-only Sync Contract for clear advice/audit. Non-trivial behavior change routes through `100-sg-spec -> 101-sg-ready -> 001-sg-build/102-sg-start`; a ready spec may continue its active lifecycle. Route entitlement ambiguity to `601-sg-product-entitlements` and setup/tutorial dominance to `008-sg-customer`.

Before defaults or a material decision, load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`; before asking, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`. Provider/SDK/auth/storage/offline/encryption facts require `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`. WinFlowz access questions require `$SHIPGLOWS_ROOT/skills/references/winflowz-suite-product-registry.md`.

## Progressive Sync Packs

Load local references directly; local references never chain.

- After domains and account boundary are known, load `$SHIPGLOWS_ROOT/skills/600-sg-local-cloud-sync/references/local-cloud-sync-doctrine.md`.
- Before evaluating visible state, sensitive data, tenant boundaries, logging, or abuse, load `$SHIPGLOWS_ROOT/skills/600-sg-local-cloud-sync/references/ux-security-checklist.md`.
- For a SocialGlowz-style guidance overlay, load the bounded index `$SHIPGLOWS_ROOT/skills/600-sg-local-cloud-sync/references/sync-guidance-overlay-and-merge-pattern.md`, then only its one direct UI, orchestration, queue, or proof leaf.
- Flutter/Riverpod/Firebase/secure-storage/local-store/mobile proof loads `$SHIPGLOWS_ROOT/skills/600-sg-local-cloud-sync/references/flutter-implementation-checklist.md`.
- Before finalizing proof, docs impact, or the report, load `$SHIPGLOWS_ROOT/skills/600-sg-local-cloud-sync/references/sync-contract-proof-and-report.md`.

Load at most one local playbook before the first substantive action. Behavior changes also load `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md`; lifecycle orchestration loads `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` only after that route is selected.

## Activation-Critical Sync Invariants

- Never silently wipe local data on sign-up/sign-in or replay it across accounts.
- Empty cloud after sign-up is not equivalent to empty cloud for an existing-account sign-in.
- Stable domain keys, explicit authority, account association, merge/conflict policy, and delete/tombstone policy are required.
- Latest-wins requires trustworthy timestamps, device/source identity, and domain-risk justification.
- Offline changes require durable pending state or an explicit local-only exception.
- Secrets, credentials, tokens, private keys, and recovery material are excluded by default.
- UI state is feedback, never authorization; server/provider ownership remains mandatory.
- `saved locally` is not `synced`; reinstall/relogin recovery is never promised without durable remote write and hydration proof.

## Stop Conditions

Stop or reroute when a behavior change lacks a ready spec; identity, tenant, entitlement, account association, authority, keys, conflict, delete, or sensitive-data policy is unclear; cross-account replay or silent loss is possible; latest-wins lacks reliable metadata; provider truth is stale; sync UI overclaims durability; secrets would sync by convenience; proof cannot establish write plus hydration; or unrelated dirty files would enter mutation/ship scope.

## Final Report

User mode:

```text
🧱 CHANTIER (local|spec) : <name>
🎯 VERDICT (HH:mm) : <result>
<Sync-contract outcome and compact proof>
⚠️ <Only a material loss/privacy/conflict/proof limit>
```

Agent/handoff mode may include the full Sync Contract, domain matrix, owner route, files, checks, decisions, and gaps. Never expose internal workflow in user mode.

## Validation

Run `tools/test_600_sg_local_cloud_sync_compaction_contract.py`, monolith/reporting consumers, metadata, fidelity, budget, and runtime-sync checks.
