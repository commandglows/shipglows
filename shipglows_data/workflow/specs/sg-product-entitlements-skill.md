---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-06-10"
created_at: "2026-06-10 11:09:38 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 00:00:00 UTC"
status: ready
source_skill: sg-spec
source_model: GPT-5 Codex
scope: skill-maintenance
owner: Diane
confidence: high
user_story: "As a ShipGlows operator building suite products, I want a dedicated product entitlements skill, so that identity, provider events, product access, product-local mirrors, support actions, and protected backend gates are designed and verified without duplicating auth-debug or local-cloud sync workflows."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - /home/claude/replayglowz/explorations/2026-06-10-suite-entitlements-sync-skill-placement.md
  - skills/601-sg-product-entitlements/SKILL.md
  - skills/600-sg-local-cloud-sync/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/references/product-entitlements-playbook.md
  - skills/sg-help/references/help-catalog.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/technical/code-docs-map.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - site/src/content/skills/
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/product-entitlements-playbook.md"
    artifact_version: "1.0.1"
    required_status: active
  - artifact: "skills/600-sg-local-cloud-sync/references/local-cloud-sync-doctrine.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 20 reclassifies the ReplayGlowz exploration as external provenance and replaces the retired sync-skill dependency with the active 600 local-cloud-sync doctrine."
  - "Exploration report /home/claude/replayglowz/explorations/2026-06-10-suite-entitlements-sync-skill-placement.md recommends one new product-entitlements skill and no standalone data-sync skill."
  - "skills/references/product-entitlements-playbook.md defines the core doctrine: identity, provider events, and product entitlements are separate layers; authentication must not grant product access."
  - "skills/sg-local-cloud-sync/SKILL.md already owns local-to-cloud data promotion, merge, conflict, tombstone, offline queue, UX state, and data-trust proof."
  - "skills/sg-auth-debug/SKILL.md owns auth/OAuth/session debugging, not entitlement lifecycle design."
  - "ReplayGlowz suite-auth migration and backend guard work exposed the recurring need for a skill that prevents duplicate ledgers, stale mirrors, and product-data authorization gaps."
next_step: "/sg-ship \"Add sg-product-entitlements skill\""
---

# Title

sg-product-entitlements skill

## Status

Ready. The placement decision is made: create `sg-product-entitlements` as a new domain skill, and update `sg-local-cloud-sync` only with a clear entitlement handoff. The spec has enough user-story fit, behavior contract, security scope, implementation tasks, and proof definition for `/sg-skill-build`.

## User Story

As a ShipGlows operator building suite products, I want a dedicated product entitlements skill, so that identity, provider events, product access, product-local mirrors, support actions, and protected backend gates are designed and verified without duplicating auth-debug or local-cloud sync workflows.

Primary actor: ShipGlows operator or implementation agent introducing, changing, auditing, or repairing product access.

Secondary actors:

- product builders adding paid plans, Lifetime Deals, manual grants, provider webhooks, app-store purchase validation, premium gates, or support flows;
- suite/account-system owners who maintain canonical identity and entitlement ledgers;
- support operators diagnosing missing, duplicated, refunded, revoked, expired, or migrated access;
- product backend owners who enforce protected read/write gates;
- `sg-local-cloud-sync`, which owns data promotion and merge policy once access preconditions are explicit;
- `sg-auth-debug`, which owns auth/session/OAuth diagnosis.

Trigger: the operator invokes `sg-product-entitlements` for a project, product, provider, grant/revoke/refund flow, product-access mirror, backend guard, paywall, support runbook, or entitlement compliance question.

Observable result: the skill produces a bounded entitlement contract, audit, blocked decision, or spec/build route that keeps identity, provider events, product entitlements, product-local mirrors, and data sync responsibilities separate.

## Minimal Behavior Contract

When invoked, `sg-product-entitlements` must load the product entitlements playbook, identify whether the project is suite-owned or standalone, and produce the smallest safe entitlement contract or audit route. The skill must cover identity versus access, provider event ingestion, canonical ledger ownership, product ids and plan ids, status semantics, code/redemption safety, manual grants, revokes/refunds/expiry, product-local snapshots or mirrors, backend authorization gates, support diagnostics, redaction, smoke proof, docs impact, and handoff to adjacent skills. It must stop instead of endorsing client-owned access, custom-claim-only access, email-only grants, duplicate durable ledgers, stale product-local mirrors without expiry/refresh policy, unverified provider events, or product-data sync that bypasses entitlement re-checks.

## Success Behavior

- Given a suite product already has a canonical entitlement ledger, when the skill is invoked for a target product, then it directs the work to adapt the target `product_id`, bridge/snapshot, product UI, feature gates, and backend authorization to that ledger instead of creating a second durable product-local ledger.
- Given a standalone product has no suite ledger, when the skill is invoked for new product access, then it defines the minimum durable entitlement, redemption-code, and access-event model needed for server-owned authorization and support diagnostics.
- Given provider, marketplace, app-store, webhook, manual grant, refund, revocation, chargeback, cancellation, or LTD activation work is in scope, when current external behavior matters, then the skill applies the documentation freshness gate and requires verified, idempotent provider-event ingestion before access changes.
- Given protected product data or premium capability is in scope, when the skill produces an implementation route, then it requires backend guards that validate identity, product namespace, active entitlement, feature/quota limits where relevant, and deny-by-default behavior.
- Given product-local access snapshots or mirrors are needed for availability, when the contract allows them, then it labels them as cache/mirror/adapter/compatibility state with TTL, refresh, revocation, and source-of-truth limits.
- Given data promotion, hydration, merge, offline queue, conflict policy, tombstones, or reinstall recovery is in scope, when entitlement preconditions are defined, then the skill hands off the data-trust contract to `sg-local-cloud-sync`.
- Given auth callback, OAuth, cookies, session restore, provider identity, or token acceptance is failing, when the problem is session-level rather than entitlement-lifecycle design, then the skill routes diagnosis to `sg-auth-debug`.
- Given skill implementation completes, when the operator uses `$sg-product-entitlements`, then the skill is discoverable in current-user Claude/Codex runtime links, help catalog, public skill content, and technical docs.

## Error Behavior

- If identity, provider events, and product access are conflated, the skill must block or produce corrective routing before implementation.
- If a target product would create a second durable entitlement ledger while a suite ledger already exists, the skill must treat this as a stop condition unless the spec documents a standalone exception or temporary migration adapter with retirement path.
- If provider signatures, app-store purchase validation, webhook semantics, or marketplace rules matter and fresh official docs are missing, the skill must block entitlement-state decisions until freshness is resolved.
- If raw activation codes, tokens, cookies, provider secrets, OAuth codes, private webhook payloads, or customer data would be logged or persisted unsafely, the skill must block and require redaction/secret-handling design.
- If a product-local snapshot can stay active after a suite revoke/refund/expiry, the skill must block until TTL, refresh, fail-closed, and revocation behavior are explicit.
- If implementation scope includes local/cloud data sync without merge, tombstone, account-boundary, or offline semantics, the skill must hand off to `sg-local-cloud-sync` instead of inventing sync logic.
- If the request is only an auth/session/OAuth debugging problem, the skill must route to `sg-auth-debug` rather than broadening the chantier.

## Problem

ShipGlows already has a strong product entitlements playbook, but no dedicated skill entrypoint. That creates a repeated routing gap: agents discover the doctrine only if they already know to load the reference. In suite products, that gap can become a security problem because product teams may accidentally grant access from identity alone, create duplicate product-local ledgers, trust provider events directly at runtime, or sync product data before entitlement and tenant boundaries are verified.

The exploration on 2026-06-10 found that `sg-local-cloud-sync` already owns synchronization well. Creating a generic `sg-data-sync` would duplicate it. The missing entrypoint is specifically product access lifecycle ownership.

## Solution

Create `skills/sg-product-entitlements/SKILL.md` as a domain skill backed by `skills/references/product-entitlements-playbook.md`. Update `sg-local-cloud-sync` with a concise entitlement handoff so sync contracts name access preconditions and route entitlement-ledger work back to `sg-product-entitlements`. Add discoverability and public/docs coherence through help catalog, technical maps, README/workflow surfaces, runtime skill sync, and public skill content if the current site content model supports it.

## Scope In

- Create `skills/sg-product-entitlements/SKILL.md`.
- Use `skills/references/product-entitlements-playbook.md` as the main doctrine source rather than duplicating the full playbook in the skill body.
- Define mode detection for read-only contract, audit, compliance review, support-runbook framing, provider/manual/LTD/access-code work, backend guard work, and spec/build routing.
- Define clear handoffs to `sg-auth-debug`, `sg-local-cloud-sync`, `sg-spec`, `sg-ready`, `sg-start`/`sg-build`, `sg-verify`, `sg-docs`, `sg-prod`, and `sg-test`.
- Update `skills/sg-local-cloud-sync/SKILL.md` with entitlement-gated sync handoff language only; do not move sync doctrine into the new skill.
- Add or update skill discoverability surfaces: `skills/sg-help/references/help-catalog.md`, `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, and `shipglows_data/technical/code-docs-map.md`.
- Add public skill content under `site/src/content/skills/` if existing public skill pages are current and the content model accepts the entry.
- Repair/check current-user runtime links for `$HOME/.claude/skills/sg-product-entitlements` and `$HOME/.codex/skills/sg-product-entitlements`.
- Validate with scenario-first pressure checks, skill budget audit, runtime link check, metadata lint, docs/site checks, targeted stale-route checks, and diff hygiene.

## Scope Out

- Implementing entitlement code in ReplayGlowz, WinFlowz, SocialGlowz, or any product project.
- Changing prices, plans, provider configuration, manual grants, or support actions in a live product.
- Creating a standalone `sg-data-sync` skill.
- Replacing `sg-local-cloud-sync` or moving its merge/offline/tombstone doctrine into `sg-product-entitlements`.
- Replacing `sg-auth-debug` for session/OAuth/cookie/callback diagnosis.
- Writing provider-specific Stripe, Paddle, Polar, AppSumo, Google Play, App Store, Lemon Squeezy, or webhook implementation code.
- Creating new suite ledger tables or migrations.
- Shipping product-facing public claims about paid access, pricing, refunds, or support promises.

## Constraints

- The skill name is fixed by operator decision: `sg-product-entitlements`.
- Skill contracts and internal references must be in English.
- User-facing reports must follow the user's active language and the shared reporting contract.
- The skill must preserve the doctrine that authentication proves identity only and must never itself grant product access.
- Provider systems are event sources, not runtime authorization sources.
- Suite products use the suite ledger by default; duplicate durable product-local ledgers are stop conditions unless explicitly justified.
- Product-local access state is a cache, mirror, migration adapter, or compatibility fallback unless the product is intentionally standalone.
- Entitlement work is high security impact because it can expose protected product data or paid capabilities.
- External provider/API behavior must use the documentation freshness gate and official/current docs when it changes entitlement decisions.
- The implementation must not overwrite unrelated dirty files already present in the ShipGlows repo.
- Runtime skill sync must use ShipGlows helper tools and block on non-symlink conflicts.

## Test Contract

- surface: ShipGlows skill contract, adjacent skill handoff, help/docs/public skill surfaces, runtime skill links.
- stack profile: Markdown skill contracts, ShipGlows governance docs, static site content, shell validation tools.
- proof profile: scenario-first with mechanical validation.
- automated proof available: `rg` checks, skill budget audit, metadata lint, runtime skill sync check, site build if public content changes, `git diff --check`.
- non-automated proof required: review of pressure scenarios in the spec and `sg-verify` lifecycle gate.
- proof order: spec readiness -> skill creation/update -> runtime link repair/check -> scenario `rg` checks -> skill budget audit -> metadata lint -> public/docs build checks -> `sg-verify` -> ship.
- checklist path: no product manual QA checklist is required; this is a ShipGlows skill-maintenance chantier.
- required scenario ids:
  - SPE-001 suite ledger exists: skill blocks duplicate product-local durable ledger and routes to suite ledger adaptation.
  - SPE-002 standalone product: skill allows a local entitlement model only with explicit source-of-truth, tables/events, statuses, and support proof.
  - SPE-003 identity-only access: skill blocks access granted by login, email, custom claims, cookie, localStorage, or client path alone.
  - SPE-004 provider event ingestion: skill requires signature/token validation, idempotency key, environment/product allowlists, replay rejection, and refund/revoke handling.
  - SPE-005 activation code: skill requires secret handling, no raw-code logs, reuse policy, same-user idempotency, and support-safe diagnostics.
  - SPE-006 product-local snapshot: skill requires cache/mirror/adapter label, TTL/refresh/revocation semantics, and fail-closed behavior.
  - SPE-007 backend gate: skill requires server-side identity, product namespace, entitlement, feature/quota checks, and denial of client-supplied access fields.
  - SPE-008 entitlement-gated sync: `sg-product-entitlements` defines access preconditions and hands merge/hydration/tombstone/offline contract to `sg-local-cloud-sync`.
  - SPE-009 auth/session failure: skill routes OAuth/session/cookie/callback debugging to `sg-auth-debug`.
  - SPE-010 support runbook: skill requires redacted lookup, grant, revoke, refund, expire, reissue, duplicate-account, wrong-account-code, and retention guidance.
- exception with proof: external provider docs are not needed to create the skill itself because no provider integration is implemented; the skill must require fresh official docs when provider behavior governs a project contract.
- exception without proof: none.

## Dependencies

- `skills/references/product-entitlements-playbook.md`: primary doctrine.
- `skills/sg-local-cloud-sync/SKILL.md` and skill-local sync references: existing sync owner to preserve and link.
- `skills/sg-auth-debug/SKILL.md`: auth/session/OAuth diagnosis owner to preserve and link.
- `skills/sg-skill-build/SKILL.md`: implementation owner for skill creation and validation.
- `skills/references/decision-quality-contract.md`: quality bar for security and routing decisions.
- `skills/references/documentation-freshness-gate.md`: required for provider/API behavior in later project-specific entitlement specs.
- `skills/references/reporting-contract.md`: final report requirements.
- `tools/shipglows_sync_skills.sh`: runtime skill link repair/check.
- `tools/skill_budget_audit.py`: skill size/context validation.
- Public content and technical docs only if existing repository surfaces remain valid during implementation.

Fresh external docs verdict: `fresh-docs not needed` for this spec because it defines a ShipGlows skill contract and does not implement provider/API behavior. Future product entitlement specs that touch providers, marketplace APIs, app-store validation, OAuth, webhook signatures, or current SDK behavior must pass the documentation freshness gate with official/current sources.

## Invariants

- Identity is not product access.
- Provider event is not runtime authorization.
- Product entitlement is server-owned.
- Suite ledger is canonical for suite products unless an explicit standalone or temporary-migration exception is documented.
- Fail closed when identity, provider verification, ledger lookup, bridge/snapshot refresh, product namespace, or entitlement status is unavailable or malformed.
- `product_id`, `plan_id`, status, source, and environment must normalize before writes that authorize access.
- Revoked, refunded, expired, inactive, and pending-review states do not grant access.
- Access status in custom claims, cookies, localStorage, app settings, client-owned paths, or UI state is never durable truth.
- Product-local mirrors must be redacted, expiry-bound, refreshable, and subordinate to the canonical source.
- Raw secrets, activation codes, cookies, OAuth codes, provider secrets, webhook secrets, and raw customer-sensitive payloads must not be logged or persisted unsafely.
- Data sync must re-check auth, entitlement, account association, and domain policy before remote writes.

## Links & Consequences

- `sg-build` and `sg-start` can route entitlement implementation through this skill for contracts before coding.
- `sg-local-cloud-sync` remains the data-trust owner and gains an entitlement handoff, reducing ambiguous sync/data-access routing.
- `sg-auth-debug` remains the owner for session/OAuth/callback/provider-auth failures.
- `sg-prod` and `sg-test` remain responsible for hosted/live behavior proof after entitlement implementation ships.
- `sg-docs` remains responsible for docs corpus edits, but this skill must identify docs/support/public-copy impact.
- Public skill inventory and help catalog should expose the new entrypoint so operators do not have to remember the playbook filename.
- Adding a new skill increases runtime sync and skill budget obligations.

## Documentation Coherence

- Add the new skill to `skills/sg-help/references/help-catalog.md`.
- Update `README.md` and `shipglows_data/workflow/playbooks/spec-driven-workflow.md` where skill routing lists or domain capability summaries mention auth, billing, access, product gates, or sync.
- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` and `shipglows_data/technical/code-docs-map.md`.
- Add `site/src/content/skills/sg-product-entitlements.md` if current public skill-page patterns support it.
- Avoid copying the full product entitlements playbook into every doc; link to the canonical reference.
- Mention the `sg-local-cloud-sync` handoff in both skills only enough to prevent duplicate sync ownership.

## Edge Cases

- Product has suite identity but no product entitlement.
- Product has a legacy product id that should be an alias/migration input, not a new grant id.
- Product has historical local entitlement tables but a suite ledger now exists.
- Product needs free/default access but revocation must still block access.
- Product-local access snapshot says active but suite ledger says revoked/refunded/expired.
- Provider sends duplicate, delayed, partial, wrong-environment, unknown-product, or malformed events.
- Activation code is entered by the wrong account.
- Same user retries a redemption after a transient failure.
- Manual grant is created without audit/support notes.
- Refund, chargeback, cancellation, failed renewal, or license deactivation must remove access without deleting identity.
- Product data exists locally and needs cloud promotion only after entitlement succeeds.
- Support needs to identify access without exposing secrets or excessive customer data.
- App-store or marketplace rules require separate validation constraints.

## Implementation Tasks

1. Create `skills/sg-product-entitlements/SKILL.md` with frontmatter, canonical path instructions, chantier tracking, reporting, required references, mode detection, mission, contract shape, handoffs, stop conditions, validation, and final report format.
2. Keep the skill body compact and point to `skills/references/product-entitlements-playbook.md` for detailed doctrine rather than duplicating the playbook.
3. Encode mode detection for read-only contract, audit/compliance, provider/manual/LTD/access-code work, backend guard work, support-runbook framing, and implementation routing.
4. Add explicit handoffs to `sg-auth-debug`, `sg-local-cloud-sync`, `sg-spec`, `sg-ready`, `sg-start`/`sg-build`, `sg-verify`, `sg-prod`, `sg-test`, and `sg-docs`.
5. Update `skills/sg-local-cloud-sync/SKILL.md` with a short entitlement-gated sync integration note and stop/handoff language.
6. Update help/discoverability surfaces: `skills/sg-help/references/help-catalog.md`, `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, and `shipglows_data/technical/code-docs-map.md`.
7. Add public skill page `site/src/content/skills/sg-product-entitlements.md` if public skill pages are currently part of the repo and buildable.
8. Run runtime repair/check with `tools/shipglows_sync_skills.sh --repair --skill sg-product-entitlements` and `tools/shipglows_sync_skills.sh --check --skill sg-product-entitlements`.
9. Run skill budget audit, metadata lint, targeted `rg` scenario checks, public site build if public content changed, and `git diff --check`.
10. Append implementation, refresh, verify, and ship lifecycle rows to this spec as those skills run.

## Acceptance Criteria

- `skills/sg-product-entitlements/SKILL.md` exists and is discoverable as `sg-product-entitlements`.
- The skill loads and applies `skills/references/product-entitlements-playbook.md`.
- The skill has clear mode detection for product access contract, audit, support, provider/manual/LTD/access-code, backend gate, and implementation-routing work.
- The skill explicitly blocks duplicate durable ledgers for suite products unless a documented standalone or temporary adapter exception exists.
- The skill explicitly blocks identity-only, client-owned, custom-claim-only, cookie/localStorage-only, and provider-direct runtime authorization.
- The skill covers product-local snapshot/mirror/cache TTL, refresh, revocation, fail-closed, and source-of-truth semantics.
- The skill routes data promotion, hydration, merge, conflict, tombstone, offline queue, and reinstall-recovery concerns to `sg-local-cloud-sync`.
- `sg-local-cloud-sync` names entitlement preconditions and hands entitlement-ledger ownership to `sg-product-entitlements`.
- The skill routes session/OAuth/cookie/callback failures to `sg-auth-debug`.
- Help, docs, public skill content where applicable, technical maps, and runtime links are aligned.
- Scenario `rg` checks prove all `SPE-*` pressure scenarios are represented in the skill or adjacent handoff text.
- Validation commands pass or any blocker is recorded before `/sg-verify` can pass.

## Test Strategy

Use `scenario-first` because this is a skill contract and routing change. Validate each required `SPE-*` scenario with targeted `rg` checks across `skills/sg-product-entitlements/SKILL.md`, `skills/sg-local-cloud-sync/SKILL.md`, and docs/help surfaces when relevant.

Mechanical validation commands expected during implementation:

```bash
rg -n "name: sg-product-entitlements|product-entitlements-playbook|suite ledger|duplicate|provider event|activation code|snapshot|mirror|backend authorization|support runbook|sg-local-cloud-sync|sg-auth-debug" skills/sg-product-entitlements/SKILL.md
rg -n "entitlement|product access|sg-product-entitlements|fail closed|access preconditions" skills/sg-local-cloud-sync/SKILL.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill sg-product-entitlements
tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/sg-product-entitlements-skill.md shipglows_data/technical
git diff --check
```

If public content changes, also run the existing site build command documented by the repo.

## Risks

- Security risk: a vague skill could normalize entitlement shortcuts. Mitigation: stop conditions must be explicit and scenario-tested.
- Overlap risk: the skill could duplicate `sg-local-cloud-sync` or `sg-auth-debug`. Mitigation: handoff rules are part of scope and acceptance criteria.
- Discoverability risk: a skill that exists only in `skills/` but not runtime/help/public docs will be missed. Mitigation: runtime sync and docs updates are required.
- Context-budget risk: copying the full playbook into the skill would make the skill too large. Mitigation: keep the skill compact and reference the playbook.
- Provider freshness risk: provider behavior changes frequently. Mitigation: require documentation freshness gate for provider-dependent project work.
- Dirty-worktree risk: ShipGlows has unrelated dirty files. Mitigation: implementation must avoid reverting or co-mingling unrelated edits.

## Execution Notes

- This spec originated from `/sg-explore` report `/home/claude/replayglowz/explorations/2026-06-10-suite-entitlements-sync-skill-placement.md`.
- The user selected the skill name `sg-product-entitlements` on 2026-06-10.
- Preferred implementation owner: `/sg-skill-build shipglows_data/workflow/specs/sg-product-entitlements-skill.md` after `/sg-ready`.
- Preferred proof path: `scenario-first`.
- Do not create `sg-data-sync` in this chantier.
- Do not edit product projects such as ReplayGlowz as part of this skill-maintenance spec.
- Stop if another active spec already owns the exact `sg-product-entitlements` skill creation.

## Open Questions

None blocking. The public skill page should be included if the current ShipGlows site content surface is buildable during implementation; if the site is unavailable, record a docs/public-content blocker rather than weakening the skill contract.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-10 11:09:38 UTC | sg-spec | GPT-5 Codex | Created skill-maintenance spec for `sg-product-entitlements` and its `sg-local-cloud-sync` entitlement handoff from the exploration report and operator naming decision. | draft | `/sg-ready shipglows_data/workflow/specs/sg-product-entitlements-skill.md` |
| 2026-06-10 11:20:13 UTC | sg-ready | GPT-5 Codex | Reviewed structure, user-story alignment, security scope, adjacent-skill handoffs, test contract, documentation coherence, and adversarial bypass cases. | ready | `/sg-skill-build shipglows_data/workflow/specs/sg-product-entitlements-skill.md` |
| 2026-06-10 11:28:23 UTC | sg-skill-build | GPT-5 Codex | Created `skills/sg-product-entitlements/SKILL.md`, added entitlement precondition handoff in `sg-local-cloud-sync`, added public skill content, repaired runtime links, and aligned help/docs/content discovery surfaces. | implemented | `/sg-verify sg-product-entitlements-skill.md` |
| 2026-06-10 11:35:28 UTC | sg-verify | GPT-5 Codex | Verified scenario-first contract coverage, runtime links, skill-code index, skill budget, metadata, public site build, docs/content coherence, language doctrine, and diff hygiene. | verified | `/sg-ship "Add sg-product-entitlements skill"` |

## Current Chantier Flow

- sg-spec: ready
- sg-ready: ready
- sg-start: implemented via sg-skill-build
- sg-verify: verified
- sg-end: pending
- sg-ship: pending
