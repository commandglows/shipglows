---
name: 600-sg-local-cloud-sync
description: "Frame local-cloud promotion, merge, sync UX, and security work."
argument-hint: <project, feature, data domains, or sync question>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active chantier spec is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

Because this skill can expose data-loss, tenant-boundary, privacy, and security work, evaluate whether non-trivial follow-up needs `/100-sg-spec` before implementation.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` when another skill needs the full Sync Contract, data-domain matrix, validation commands, unresolved policy decisions, or proof gaps.

## Required References

Load only the references required by the active run:

- `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` before choosing defaults, route, proof, or implementation scope.
- `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md` before changing behavior, defining proof, or recommending implementation.
- `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` before routing non-trivial sync implementation through lifecycle gates.
- `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before asking user-facing decisions.
- `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md` when provider, SDK, auth, storage, offline, encryption, or platform behavior affects the sync design.
- `$SHIPGLOWS_ROOT/skills/references/winflowz-suite-product-registry.md` when WinFlowz suite free products, account-backed sync eligibility, or product access preconditions are mentioned.
- `references/local-cloud-sync-doctrine.md` for account promotion, merge, conflict, tombstone, and queue doctrine.
- `references/ux-security-checklist.md` for user-visible state, sensitive-data policy, tenant/account boundaries, logging, and abuse controls.
- `references/sync-guidance-overlay-and-merge-pattern.md` when designing, auditing, or implementing a SocialGlowz-style real-time sync guidance overlay with post-auth hydration, local/cloud merge decisions, durable queue, and ready feedback.
- `references/flutter-implementation-checklist.md` when the target project uses Flutter, Riverpod, Firebase, secure storage, local stores, or mobile/web proof surfaces.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "not a git repo"`
- Project docs: !`ls shipglows_data/technical/architecture.md shipglows_data/technical/guidelines.md shipglows_data/business/product.md shipglows_data/business/business.md README.md CLAUDE.md AGENTS.md 2>/dev/null || echo "no project docs found"`
- Available specs: !`find shipglows_data/workflow/specs specs docs -maxdepth 3 -type f -name "*.md" 2>/dev/null | sort | head -80`

## Mission

`600-sg-local-cloud-sync` is the ShipGlows entrypoint for local-first data becoming account-backed cloud data.

It turns a project, feature, data domain, or sync question into a practical Sync Contract:

```text
local data inventory
  -> auth/account association
  -> cloud snapshot and ownership boundary
  -> promotion, hydration, merge, conflict, and tombstone policy
  -> sync/save UX states and retry behavior
  -> sensitive-data and secrets policy
  -> offline queue and durability requirements
  -> proof ladder and docs impact
  -> spec/build/verify routing when implementation is needed
```

This skill complements `001-sg-build`, `008-sg-customer`, and `601-sg-product-entitlements`. `001-sg-build` owns implementation lifecycle. `008-sg-customer` owns broad activation and setup comprehension. `601-sg-product-entitlements` owns product access/entitlement preconditions. `600-sg-local-cloud-sync` owns the data-trust contract: no local wipe on account creation, no cross-account replay, no vague merge policy, no hidden secret sync, and no reinstall-recovery promise without durable proof.

## Mode Detection

Parse `$ARGUMENTS` as a sync target.

| Intent | Route |
| --- | --- |
| Read-only sync architecture advice for a clear project | Produce a Sync Contract in the final report |
| Audit an existing local/cloud sync plan or implementation | Review against the doctrine and report findings plus chantier potential |
| Real-time sync guidance widget, post-auth sync overlay, or SocialGlowz-style local/cloud merge UX | Load the Sync Guidance Overlay And Merge Pattern reference, then produce or route the implementation contract |
| Non-trivial implementation across data stores, auth, cloud, UI, docs, or tests | Route to `100-sg-spec -> 101-sg-ready -> 001-sg-build/102-sg-start` |
| Access control, entitlement gating, or entitlement precondition ambiguity | Route access decisions to `601-sg-product-entitlements` before final sync contract |
| Existing ready spec already owns the sync work | Attach to that spec and support the active lifecycle |
| User activation, tutorials, or setup copy dominates | Route or hand off to `008-sg-customer` after the sync contract is clear |
| Provider behavior, SDK semantics, encryption, or offline storage rules are current/external | Run the Documentation Freshness Gate before design decisions |
| Data domains, account boundaries, or secret policy are unclear | Ask one targeted decision question or block |

When two routes are materially plausible, load `question-contract.md` and ask one concise numbered decision question. Otherwise choose the context-safe default that best preserves data integrity, privacy, security, and proof quality.

## Sync Contract

For read-only, audit, or spec-intake output, produce this compact structure:

```text
Sync Contract: [project/feature]

Data domains:
Local durability:
Remote authority:
Account association:
Promotion trigger:
Hydration trigger:
Merge policy:
Conflict policy:
Delete/tombstone policy:
Offline queue:
Sensitive-data policy:
Secrets policy:
Sync/save UX states:
Retry/recovery:
Tenant/account boundary:
Observability:
Proof path:
Docs/editorial impact:
Implementation route:
```

If implementation is needed, convert the contract into a spec-ready behavior contract instead of editing source files directly.

## Core Doctrine

Every sync recommendation or implementation contract must cover:

- **No silent local wipe**: account creation or sign-in must not discard anonymous/local user data.
- **Account association**: local data needs remembered account metadata before it can be replayed automatically into cloud.
- **Empty-cloud distinction**: an empty cloud snapshot after sign-up is not the same as an empty cloud snapshot after signing into an existing account.
- **Cloud hydration**: a clean local install with existing cloud data should hydrate local state after auth and entitlement checks.
- **Domain keys**: every sync domain needs stable business keys and deterministic identity.
- **Merge matrix**: equal checksums sync cleanly; disjoint keys merge; same key/different payload conflicts unless reliable latest-wins metadata exists.
- **Latest-wins constraints**: latest modification can win only when timestamps, device/source IDs, and clock assumptions are reliable enough for the domain risk.
- **Tombstones**: delete-capable domains need tombstones, retention, or another explicit delete propagation model.
- **Offline queue**: local changes made while offline or unauthenticated need durable pending state or a declared local-only exception.
- **Secrets excluded by default**: secrets, tokens, credentials, private keys, and recovery material are not synced unless a future spec explicitly designs secure secret sync.
- **Visible states**: sync and settings-save state should show loading, saved/synced, pending, retrying, blocked, and error states when relevant.
- **Proof before promise**: reinstall/relogin recovery must not be claimed until durable remote write and hydration are proven.
- **Access gating**: unresolved or inactive entitlement state is not a sync boundary pass; treat as denied until entitlement ownership is explicit.
- **WinFlowz suite free access**: when WinFlowz sync depends on product access, load the suite product registry before interpreting local-only, inactive-access, or free-account states.

## Security And Privacy Rules

For auth, tenant, data, and sensitive-content surfaces:

- identify who can initiate promotion, hydration, merge, delete, retry, export, or import
- enforce ownership server-side or provider-side when remote data is touched
- block cross-account replay unless an explicit import/export flow is designed
- validate untrusted remote and local payloads before merge
- avoid logging secrets, tokens, credentials, PII, full clipboard contents, private payloads, or raw sync snapshots
- treat sync UI as feedback only, never as the security boundary
- document retention for tombstones, deleted records, and queued operations
- consider abuse risks: repeated promotion attempts, huge payloads, expensive fan-out, replay, duplicate writes, and quota exhaustion
- name the provider trust assumptions and use fresh official docs when provider behavior controls correctness

## Proof Paths

Choose proof proportional to the surface:

- `scenario-first`: default for sync contracts and skill-level routing.
- `test-first`: for pure controller, merge, conflict, tombstone, metadata, queue, and adapter logic.
- `regression-first`: for data-loss or cross-account replay bugs.
- `evidence-first`: for UI sync-state proof, hosted/browser smoke, provider console evidence, logs, or docs.
- `exception-with-proof`: only when a proof surface is unavailable; name the alternate evidence.

Default proof ladder:

1. Pure domain/controller tests for merge, conflict, metadata, account association, and tombstones.
2. Store/adapter tests for durable local snapshots and remote write/read contracts.
3. UI/widget tests for sync/save indicators, retry, blocked, and error states.
4. Browser/auth proof for shared web UI when available.
5. Provider/integration proof for real backend boundaries.
6. Device/manual proof only for native-only storage, OS permissions, lifecycle, offline behavior, or reinstall/relogin paths.

## Documentation And Editorial Gates

After sync work, produce both statuses:

- `Documentation Update Plan`: `complete` / `no impact` / `blocked`
- `Editorial Update Plan`: `complete` / `no editorial impact` / `blocked`

Check impact on:

- architecture docs, data model docs, security/privacy docs, support docs, onboarding docs, manual QA checklists, changelog, release notes, public claims, pricing/plan copy, and screenshots
- in-app wording around backup, sync, saved, cloud, account, export, import, and reinstall recovery
- support promises about account creation preserving local data

## Stop Conditions

Stop and report `blocked` or route to the owner skill when:

- implementation would change behavior without a ready spec
- local data durability is insufficient for the promised sync behavior
- auth identity, tenant boundary, entitlement, or account association is unclear
- merge keys or conflict policy are undefined
- latest-wins is proposed without reliable metadata
- deletes exist without tombstones or retention policy
- secrets or sensitive content would be synced by convenience
- cross-account replay could occur
- provider behavior matters and fresh official docs are missing
- sync scope that depends on entitlements is blocked until access preconditions are explicit
- UI claims saved/synced before durable local and remote success criteria are met
- reinstall/relogin recovery is promised without full write/hydrate proof
- unrelated dirty files would enter implementation or ship scope

## Validation

For skill-contract changes, validate with:

```bash
rg -n "name: 600-sg-local-cloud-sync|Sync Contract|Core Doctrine|Security And Privacy Rules|Proof Paths|Stop Conditions" skills/600-sg-local-cloud-sync/SKILL.md
rg -n "account association|cross-account|secrets|tombstones|latest-wins|reinstall|Flutter|Riverpod" skills/600-sg-local-cloud-sync/references
test -f skills/600-sg-local-cloud-sync/references/sync-guidance-overlay-and-merge-pattern.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill 600-sg-local-cloud-sync
```

For product implementations, use the project checks named by the ready spec and route browser/auth/manual/provider proof to the proper owner skill.

## Final Report

User mode:

```text
🧱 CHANTIER (local|spec) : [nom]
🎯 VERDICT (HH:mm) : [résultat]

[Résultat du contrat de synchronisation et preuve compacte]
[Risque de perte, confidentialité, conflit ou limite de preuve seulement s'il compte]
[Impact documentaire seulement s'il change la confiance ou la décision]

[Si le chantier reste ouvert, terminer par deux ou trois choix numérotés en
langage simple. Ne jamais exposer un skill, une commande, un propriétaire
interne, une étape de cycle de vie, un chemin de spec ou un flux.]
```

Agent/handoff mode may include the full Sync Contract, data-domain matrix, owner-skill routing, target files, validation commands, unresolved decisions, and proof gaps.

## Rules

- Do not treat sync as a storage toggle.
- Do not duplicate `001-sg-build`, `100-sg-spec`, `101-sg-ready`, `103-sg-verify`, `300-sg-docs`, `008-sg-customer`, `107-sg-test`, `108-sg-browser`, or `109-sg-auth-debug` internals.
- Keep internal contracts in English and user-facing output in the active user language.
- Ask only when the answer changes data ownership, account boundary, security posture, conflict policy, sensitive-data policy, proof, docs/public claims, or implementation scope.
- Prefer a blocked sync contract over a convenient data-loss path.
