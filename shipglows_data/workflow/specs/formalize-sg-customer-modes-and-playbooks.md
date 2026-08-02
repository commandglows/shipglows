---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
created_at: "2026-07-17 19:11:33 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 21:48:36 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable)"
scope: customer-skill-mode-architecture
owner: Diane
user_story: "As the ShipGlows operator, I invoke one customer-experience skill with explicit modes and bounded playbooks, so I can choose the correct customer journey work without navigating fragmented functional skills or losing trust, recovery, and proof safeguards."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/008-sg-customer/SKILL.md
  - skills/008-sg-customer/references/
  - skills/006-sg-design/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/107-sg-test/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/300-sg-docs/SKILL.md
  - skills/000-shipglows/SKILL.md
  - skills/001-sg-build/references/build-lifecycle-workflow.md
  - skills/302-sg-help/references/help-catalog.md
  - skills/references/entrypoint-routing.md
  - skills/references/skill-code-index.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows-site/src/content/skills/sg-customer.md
  - plugins/shipglows/assets/pack-catalog.json
  - plugins/shipglows/skills/shipglows/references/pack-catalog.md
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.5.0"
    required_status: active
  - artifact: skills/references/master-workflow-lifecycle.md
    artifact_version: "1.6.0"
    required_status: active
  - artifact: shipglows_data/technical/skill-runtime-and-lifecycle.md
    artifact_version: "1.25.0"
    required_status: reviewed
  - artifact: shipglows_data/technical/codex-plugin-packaging.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: shipglows_data/technical/product-behavior-intelligence.md
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
evidence:
  - "2026-07-17 active-directory scan found exactly one customer/onboarding/end-user owner: skills/008-sg-customer; no second active customer skill exists to consolidate or retire."
  - "008-sg-customer already holds a 228-line activation contract plus onboarding and overlay references, but its intent table mixes audit, flow, onboarding, recovery, UI review, and proof routes without canonical mode grammar or one-playbook selection."
  - "The public sg-customer page exposes five overlapping free-text argument modes (feature or flow, audit, permissions/setup, visual states/progressive disclosure, onboarding popup/progress overlay), while help, routing, README, lifecycle, and runtime documents advertise only a generic 008 entrypoint."
  - "Historical spec sf-onboarding-user-activation-skill.md records the source lineage: sg-onboarding was first created, then transformed into sg-end-user/customer with onboarding retained as a playbook; it is historical evidence, not an active invocation source."
  - "The completed design, marketing, and technical consolidations establish the relevant architecture precedent: one public owner, exact modes, lazy bounded playbooks, public/runtime/help coherence, active-versus-historical scans, and no hidden aliases when identities are retired."
  - "Current-user runtime links /home/claude/.codex/skills/008-sg-customer and /home/claude/.claude/skills/008-sg-customer both resolve to the canonical source; the canonical identity must remain unchanged."
next_step: "/102-sg-start formalize sg-customer modes and playbooks"
---

# Spec: Formalize sg-customer Modes and Playbooks

## Title

Formalize sg-customer Modes and Playbooks

## Status

Draft — placement decision: create this bounded architectural-compaction chantier. `008-sg-customer` is already the single, coherent customer owner, so this is not a consolidation of imaginary source skills and must not create a second skill. The justified improvement is to turn its overlapping free-text lanes into exact, discoverable modes with lazy, bounded playbooks while retaining the canonical `008-sg-customer` identity.

## User Story

As the ShipGlows operator, I invoke one customer-experience skill with explicit modes and bounded playbooks, so I can choose the correct customer journey work without navigating fragmented functional skills or losing trust, recovery, and proof safeguards.

## Minimal Behavior Contract

`008-sg-customer` accepts one selected customer mode and a feature, flow, screen, or state; it loads only the corresponding playbook, returns a customer contract or routes implementation/proof to the owner skill, and makes the first meaningful user result, trust consequence, and recovery path observable. Invalid or materially ambiguous input must show the supported modes or ask one targeted question rather than silently loading several playbooks. The easy-to-miss case is a permission, auth, billing, integration, or revoked/blocked state: the skill must explain value and safe deferral, never coerce access, and retain a recoverable next action even when a user leaves the app or external settings.

## Success Behavior

- `008-sg-customer audit [scope]` loads only the customer-audit playbook and yields evidence-backed findings on comprehension, friction, trust, state clarity, and the correct owner/proof route for an existing journey.
- `008-sg-customer flow [feature-or-flow]` loads only the customer-flow playbook and yields an End-User Contract for a new, changed, or shipped path: target user, first success, primary path, states, recovery, documentation/editorial impact, and proof route.
- `008-sg-customer onboarding [feature-or-flow]` loads the existing onboarding playbook and preserves first-success, progressive disclosure, dependency order, required-versus-optional setup, permissions, defer/revisit, and setup recovery; the overlay reference loads only when a stepped overlay is actually requested.
- `008-sg-customer recovery [feature-or-state]` loads only the recovery playbook and produces a recoverable path for skipped, blocked, failed, revoked, unsupported, expired, or lost-context states without reclassifying visual design, auth debugging, docs, or manual QA as customer work.
- One public `008-sg-customer` entrypoint remains visible in current-user runtime, catalogs, help, router, docs, and the public skill page; each surface presents the exact mode grammar and honest limits.
- A clear natural-language goal may be mapped to exactly one mode only when its intent is unambiguous; otherwise the dispatcher asks among the four modes. Bare `audit` must not guess a customer subtype, and a request that only needs generic visual craft, copy, docs, browser proof, manual QA, or auth debugging routes directly to its owner.

## Error Behavior

- If a selected mode cannot identify a target user, first success, trust boundary, observable state, or proof path, stop or ask the smallest material question; do not invent product behavior or false assurance.
- If the request changes source behavior across UI, routing, data, permissions, public claims, or several surfaces without a ready spec, route to `100-sg-spec -> 101-sg-ready -> 001-sg-build/102-sg-start`; do not implement through `008`.
- If a request is design-system/visual craft, public copy/content, documentation ownership, manual evidence logging, non-auth browser evidence, or auth/session diagnosis, route respectively to `006`, `007`, `300`, `107`, `108`, or `109` without duplicating their procedure.
- If permissions, billing, privacy, data sync, API keys, external accounts, device access, or system settings are involved, disclose value, whether the product works without the action, scope, cost/data consequence, defer path, and recovery/recheck path; block coercive, misleading, or unsupported claims.
- If a public/help/catalog/runtime surface presents an obsolete mode, hidden compatibility alias, or a nonexistent second customer skill, verification fails until the active surface is corrected or the occurrence is classified as historical evidence.

## Problem

The customer domain has already been correctly compacted to one active owner, but its operating surface has not received the same final architectural treatment as design/content/marketing/technical. `008` currently recognizes several materially different jobs through prose and free-text intent: audit, journey/flow contract, onboarding/setup, recovery, overlay, visual-state review, and proof routing. This keeps the underlying content rich, but makes invocation and playbook selection inconsistent for a fresh agent, while public documentation advertises overlapping arguments rather than a canonical command grammar. Creating more customer skills would violate the operator's métier-first preference; leaving implicit modes preserves avoidable ambiguity.

## Solution

Keep `008-sg-customer` as the sole public customer-experience owner and make it a compact dispatcher with exactly four canonical modes: `audit`, `flow`, `onboarding`, and `recovery`. Move execution-specific guidance into one bounded local playbook per mode, retain the existing onboarding and optional overlay playbooks as the onboarding lane, migrate only active discoverability/documentation to the exact syntax, and prove that boundaries, trust rules, current-user runtime visibility, and historical lineage remain coherent.

## Scope In

- Refactor `skills/008-sg-customer/SKILL.md` into a compact, explicit mode dispatcher; retain its role, chantier/report contracts, permission/trust non-negotiables, owner boundaries, stop conditions, and validation anchors.
- Canonical mode grammar, exactly:
  - `008-sg-customer audit [scope]`
  - `008-sg-customer flow [feature-or-flow]`
  - `008-sg-customer onboarding [feature-or-flow]`
  - `008-sg-customer recovery [feature-or-state]`
- Preserve the generic natural-language entrypoint only as dispatcher input, never as a hidden fifth mode; select one mode when evidence is sufficient or ask a concise mode question.
- Retain and tighten `references/onboarding-playbook.md`; keep `references/onboarding-progress-overlay-pattern.md` optional under onboarding, never a separate public mode or skill.
- Add bounded local `customer-audit-playbook.md`, `customer-flow-playbook.md`, and `customer-recovery-playbook.md`, transferring all applicable current contract semantics once into the appropriate destination.
- Add a semantic transfer matrix or deterministic focused contract test proving every active `008` rule has a destination or a documented retained dispatcher rule; preservation is semantic, not line-count based.
- Update active routing, help, public `sg-customer` page, README/workflow/lifecycle/operator guidance, code-index-facing descriptions, and catalog/pack references only where they state supported customer modes or invocation examples.
- Re-run current-user runtime synchronization/checks without changing the canonical `008-sg-customer` identity.

## Scope Out

- Creating, renaming, retiring, or aliasing another customer/onboarding/end-user skill: there is no second active source identity to consolidate.
- Retiring `008-sg-customer`, changing its numeric/runtime name, or adding `sg-onboarding`, `sg-end-user`, `sg-activation`, `sg-recovery`, or per-mode wrapper skills.
- Visual-system, token, layout, component, branding, accessibility-craft, or animation implementation owned by `006-sg-design`.
- Public product copy, editorial strategy, public claims, FAQ/support copy writing, or content workflow owned by `007-sg-content`; canonical documentation architecture/metadata owned by `300-sg-docs`.
- Browser, console, and network proof owned by `108-sg-browser`; durable manual QA/tests and TEST_LOG/bug artifacts owned by `107-sg-test`; auth/OAuth/cookie/session/callback diagnosis owned by `109-sg-auth-debug`.
- Product implementation, lifecycle execution, production proof, commits, pushes, or edits to unrelated dirty files.

## Constraints

- `008-sg-customer` remains the one public customer métier skill; modes are invocation grammar and playbook selectors, not separate skills or product domains.
- One selected mode loads one primary playbook. Only `onboarding` may additionally load the overlay pattern when the requested interaction requires it; ordinary onboarding must not load the 557-line overlay reference.
- Preserve all current End-User Principles: first success/value-loop reality, comprehension, usefulness, friction, trust, visible states, recovery, accessibility/device fit, documentation/editorial coherence, and proportional proof.
- Preserve `006` as design-system/visual craft, `007` as content/public copy, `300` as documentation/governance, `107` as manual QA, `108` as non-auth browser evidence, and `109` as auth-safe diagnostics. `008` names these handoffs but must not copy their workflows.
- Do not promise activation through shallow UI completion: when value-loop measurement is in scope, load `product-behavior-intelligence.md` and define first success from durable product value.
- Worktree isolation is mandatory: inspect `git status` before implementation; no unrelated dirty, staged, generated, cache, runtime-link, or concurrent files enter the change or commit. Use path-scoped diffs and hunk-aware staging if a later ship is authorized.
- Fresh external docs: `fresh-docs not needed` for this local skill architecture migration. Individual future runs must invoke the freshness gate when platform policy, permissions, billing, app-store rules, accessibility standards, SDKs, or provider behavior governs advice.

## Test Contract

Surface profile: ShipGlows skill contract, local references, public skill documentation, routing/help/catalog/runtime discovery; no product runtime implementation.

Proof profile: `scenario-first` plus mechanical active-surface, metadata, runtime-sync, and public-build evidence.

Required scenario IDs: `CA 1` through `CA 12`; the focused contract test must name each scenario, including the clear natural-language dispatch, bare/invalid/mixed input, lazy-overlay, six-owner-boundary, trust/permission, no-alias, and active-versus-historical cases.

Required results: every focused scenario passes; each mandatory validator exits `0`; the active-surface scan returns only canonical `008-sg-customer` grammar plus the reviewed historical allowlist; both current-user links resolve to the canonical source; the public build succeeds and the generated `sg-customer` route contains one owner with all four modes. Any unmet result is a verification blocker, except the explicitly recorded static-build or runtime-picker `exception-with-proof` below.

Proof order:

1. Create the source/completeness inventory from the current `008` activation plus both current references; classify every active rule as retained dispatcher wording or exactly one mode playbook destination.
2. Add a deterministic focused contract test before or alongside edits. It must prove exact grammar, one-primary-playbook loading, invalid/bare ambiguity behavior, required security/trust markers, owner routes, no second customer identity, and no accidental default loading of the overlay reference.
3. Run the focused test; `audit_shipglows_skills.py`, `skill_code_index_lint.py`, `skill_budget_audit.py`, metadata lint, and `shipglows_sync_skills.sh --check --all`.
4. Scan active surfaces separately from immutable history. Inspect all `008-sg-customer`, `sg-customer`, `008-sg-onboarding`, `sg-onboarding`, `008-sg-end-user`, and `sg-end-user` occurrences. Historical specs, archives, changelog/refresh history, and dated evidence may retain factual names only under a reviewed allowlist; active invocation/routing/docs may advertise only canonical `008` syntax.
5. Build the affected Astro public skill content. Inspect the generated/static route and public skill page for one truthful `sg-customer` owner and the four mode examples.
6. Runtime proof: use filesystem sync to prove both current-user links resolve to `skills/008-sg-customer`. If a live picker still shows stale state after a correct sync, record `exception-with-proof` and request reload; do not recreate a legacy alias.

Manual/device/browser/auth proof: not applicable to this local contract migration. `exception-with-proof`: public browser proof is unnecessary if the public static build and rendered content checks pass; future product-flow implementations route proof to `107`, `108`, or `109` as appropriate.

## Dependencies

- `skills/references/skill-instruction-layering.md` — compact dispatcher versus purpose-specific playbook placement.
- `skills/references/decision-quality-contract.md`, `spec-driven-development-discipline.md`, and `master-workflow-lifecycle.md` — bounded professional scope and scenario-first proof.
- `shipglows_data/technical/product-behavior-intelligence.md` — value-loop rather than vanity activation semantics when behavior measurement is requested.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` and `codex-plugin-packaging.md` — public/current-user runtime, docs, and packaging consequences.
- `shipglows_data/workflow/specs/sf-onboarding-user-activation-skill.md` — historical lineage only; its obsolete source names must not become active aliases.
- Fresh external docs: `fresh-docs not needed` for this entirely local ShipGlows contract/documentation migration.

## Invariants

- One public customer owner: `008-sg-customer`.
- Exactly four canonical modes: `audit`, `flow`, `onboarding`, `recovery`.
- One mode selects one bounded primary playbook; no broad run loads audit, flow, onboarding, recovery, and overlay material together.
- Onboarding stays a mode of customer experience, never the whole owner or a resurrected separate skill.
- A mode does not alter the authority boundary: design -> `006`, content/public copy -> `007`, documentation/governance -> `300`, manual QA -> `107`, non-auth browser proof -> `108`, auth/session -> `109`.
- Customer trust is not optional: no dark patterns, fake urgency, permission coercion, concealed billing/privacy/data effects, unsupported capability claims, or loss of a safe defer/recovery path.
- Current-user runtime exposes the same canonical `008` source, and catalogs/help/public docs do not create shadow identities.
- Historical facts remain factual; active routes are canonical. Since no predecessor is retired in this chantier, no alias is created or retained.

## Links & Consequences

- `000-sg-shipglows` and `001-sg-build` continue to route customer-experience work to `008`, but their active phrasing/examples must use the four canonical modes when they need a command-level route.
- `006` receives visual-system authority; `008` may assess whether a state is comprehensible but must route component, token, layout, motion, visual accessibility-craft, and branding changes.
- `007` receives public/support copy and claim-writing work; `300` receives documentation structure, governance, metadata, or canonical-placement work. `008` retains only the customer impact/status and hands off the owned change.
- `107`, `108`, and `109` receive proof/detection work with their existing durable-record, read-only browser, and auth/redaction contracts. `008` only selects the needed proof route.
- `shipglows-site/src/content/skills/sg-customer.md` becomes a clearer public decision surface: four modes, examples, outcomes, limits, and related-owner boundaries, without creating four pages.
- Pack/catalog files retain one `008-sg-customer` identity. They may require no content change if they store only the identity, but their scan/check is required to prove no hidden duplicate is introduced.

## Documentation Coherence

Documentation Update Plan: required and complete only after all active public/operator surfaces describe one customer entrypoint and exact modes where they expose command grammar.

Editorial Update Plan: `no editorial impact` for the skill-contract migration itself; `007` owns any public product copy changes discovered in future customer runs.

Expected review/update surface:

- `README.md`
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
- `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`
- `skills/references/entrypoint-routing.md`
- `skills/302-sg-help/references/help-catalog.md`
- `skills/references/skill-code-index.md` only if its purpose text needs canonical-mode precision
- `shipglows-site/src/content/skills/sg-customer.md`
- `shipglows-site/src/content/skills/shipglows.md` and `sg-build.md` only when they expose detailed customer examples
- `plugins/shipglows/assets/pack-catalog.json` and packaged `pack-catalog.md` for identity-only confirmation

Do not update historical specs, archives, changelog entries, or refresh history merely to erase factual `sg-onboarding`/`sg-end-user` lineage.

## Edge Cases

- `audit` without scope: ask for the existing journey/screen/state; do not guess onboarding versus recovery.
- A clear free-text request such as “audit the new invite flow” may resolve to `audit`; “make users understand the invite flow” may resolve to `flow`; mixed intent asks one concise choice rather than loading both.
- “Onboarding popup” is `onboarding`, then conditionally loads the overlay pattern; it is not an `overlay` public mode.
- A skipped permission, revoked integration, failed payment, external-settings return, expired session, or unsupported device is `recovery` only when the customer-path issue is in scope; actual auth/session diagnosis routes to `109`, billing/access contract work may route to `601`, and implementation remains spec-first.
- A flow audit finds token/layout/contrast defects: record the customer consequence, then route visual repair to `006`, including its accessibility mode when needed.
- A flow audit finds vague copy or public claim drift: record the customer consequence, route the wording/claim work to `007`, and documentation placement to `300`.
- A stale `sg-onboarding` name appears in `sf-onboarding-user-activation-skill.md`, changelog, or refresh history: preserve it as historical truth; a stale active command/reference fails verification.
- No old source directory is retired here. The no-alias rule is therefore preventative: do not add compatibility wrappers, symlinks, or hidden parser aliases for historical `sg-onboarding` or `sg-end-user` identities.

## Implementation Tasks

- [x] Task 1: Freeze the active source/completeness inventory and boundary matrix.
  - Files: `skills/008-sg-customer/SKILL.md`, both current `008` references, active route/help/public/catalog/runtime files, and a focused test/helper if needed.
  - Action: map every active customer rule to retained dispatcher text or one destination playbook; classify every historical predecessor occurrence; document that no second active source identity exists and no source retirement/alias migration is authorized.
  - User story link: makes one customer owner genuinely easier to invoke rather than cosmetically renamed.
  - Depends on: ready spec.
  - Validate with: reviewed semantic transfer matrix, active/historical `rg` baseline, and a clean scoped diff plan.

- [x] Task 2: Build the compact `008` dispatcher and four-mode grammar.
  - Files: `skills/008-sg-customer/SKILL.md`.
  - Action: set exact argument hint, sole-public-owner declaration, one-playbook mode selection, natural-language/ambiguity behavior, security/trust/permission gates, owner handoffs, and focused validation anchors; preserve trace/report contracts without duplicating lifecycle doctrine.
  - User story link: gives the operator a clear command-level choice without fragmenting the métier.
  - Depends on: Task 1.
  - Validate with: focused grammar/routing scenarios and `rg` checks for modes, owner boundaries, trust rules, and no-alias guardrails.

- [x] Task 3: Create bounded audit, flow, and recovery playbooks; retain onboarding as the activation lane.
  - Files: `skills/008-sg-customer/references/customer-audit-playbook.md`, `customer-flow-playbook.md`, `customer-recovery-playbook.md`, `onboarding-playbook.md`, and optionally only minimal cross-links in `onboarding-progress-overlay-pattern.md`.
  - Action: transfer execution-specific guidance semantically, including contracts, first-success/value-loop criteria, states, recovery, permissions, proof selection, docs/editorial status, and exact owner reroutes. Keep overlay behavior optional and onboarding-scoped.
  - User story link: preserves depth while the entrypoint stays legible.
  - Depends on: Task 2.
  - Validate with: source-transfer matrix, focused scenarios, metadata lint, and budget audit.

- [x] Task 4: Add deterministic contract proof and active-reference scan.
  - Files: focused test under `tools/` or the established skill-contract test location; only required supporting assets.
  - Action: prove one primary playbook per exact mode, invalid/ambiguous input, trust/permission/recovery requirements, owner boundaries, overlay lazy-load, no second customer source, no historical alias, and exact reviewed historical allowlist behavior.
  - User story link: prevents the compact surface from silently dropping customer safety or reintroducing duplicate discoverability.
  - Depends on: Tasks 1-3.
  - Validate with: focused test passing from clean source state plus unused-allowlist failure behavior.

- [x] Task 5: Align active public, help, runtime, and catalog discovery.
  - Files: active routes/help/docs/public skill content/catalog records named in Documentation Coherence, plus only necessary runtime sync outputs.
  - Action: present `008-sg-customer` once with its exact four-mode grammar and clear limits; keep identity-only catalogs unchanged when no wording is stored, but include them in the proof scan.
  - User story link: the same canonical choice appears wherever an operator discovers it.
  - Depends on: Task 4.
  - Validate with: active-surface scan, public content build, code-index/catalog validation, and runtime sync check.

- [x] Task 6: Run independent verification and close only after scope-isolated proof.
  - Files: changed skill/reference/test/documentation artifacts and canonical closure surfaces owned by `103`, `104`, and `005`.
  - Action: independently replay semantic transfer, mode routing, boundaries, active-versus-historical scan, metadata, budget, runtime sync, public build, and diff hygiene; classify unrelated baseline failures without modifying them.
  - User story link: establishes that the unique customer skill is durable in real discovery/runtime surfaces.
  - Depends on: Tasks 1-5.
  - Validate with: `103-sg-verify`, then `104-sg-end` and `005-sg-ship` under their owner contracts if shipping is later authorized.

## Acceptance Criteria

- [x] CA 1: Given an existing user journey, when the operator invokes `008-sg-customer audit [scope]`, then exactly the audit playbook loads and returns customer findings plus the correct owner/proof route.
- [x] CA 2: Given a new, changed, or shipped feature journey, when the operator invokes `008-sg-customer flow [feature-or-flow]`, then exactly the flow playbook produces a complete End-User Contract with first success, states, recovery, docs/editorial status, and proof route.
- [x] CA 3: Given setup/activation/first-run work, when the operator invokes `008-sg-customer onboarding [feature-or-flow]`, then exactly the onboarding playbook loads; the overlay pattern loads only when a stepped-overlay interaction is actually requested.
- [x] CA 4: Given skipped, blocked, failed, revoked, unsupported, expired, or lost-context user state, when the operator invokes `008-sg-customer recovery [feature-or-state]`, then exactly the recovery playbook produces a safe resume/defer/recheck path and routes diagnostic ownership correctly.
- [x] CA 5: Given bare, invalid, or materially mixed input, when the dispatcher cannot select one safe mode, then it lists or asks among exactly `audit`, `flow`, `onboarding`, and `recovery` rather than silently selecting or loading several modes.
- [x] CA 6: Given a design-system, content/copy, documentation, manual QA, browser, or auth/session concern dominates, when `008` identifies it, then it routes respectively to `006`, `007`, `300`, `107`, `108`, or `109` without duplicating their workflow.
- [x] CA 7: Given permissions, billing, privacy, data, integrations, external accounts, device access, or settings are part of a mode, when customer guidance is produced, then it explains value, optionality, consequence, safe defer, and recovery/recheck and rejects coercion or unsupported claims.
- [x] CA 8: Given all active customer source material, when transfer completeness is reviewed, then each rule has exactly one retained/target destination or a reviewed retirement rationale; no customer safety behavior is lost through compaction.
- [x] CA 9: Given active skills, runtime links, help, docs, public pages, catalogs, and code-index surfaces, when scanned, then `008-sg-customer` is the sole discoverable customer owner and all detailed syntax uses the four canonical modes.
- [x] CA 10: Given historical `sg-onboarding`/`sg-end-user` evidence, when stale-name scanning runs, then only reviewed factual historical occurrences remain; no wrapper, symlink, parser alias, or second public source is added.
- [x] CA 11: Given the public skill collection, when it builds, then one truthful `sg-customer` page describes modes, outcomes, limits, and owner boundaries without four public pages or unsupported claims.
- [x] CA 12: Given the full scoped change, when focused contract tests, metadata lint, skill/code-index/budget checks, catalog validation, runtime sync, active scans, public build, and `git diff --check` run, then they pass or a material proof gap blocks verification.

## Test Strategy

- Add scenario-first deterministic tests for `audit`, `flow`, `onboarding`, `recovery`, clear natural-language mapping, invalid/bare/mixed input, one-playbook selection, lazy overlay, value-loop gate, and all six adjacent-owner routes.
- Add source-transfer proof that examines the current 228-line activation contract and current two references semantically; preserve rules such as completed-over-current visual state priority even when the overlay reference remains optional.
- Run `python3 tools/audit_shipglows_skills.py`, `python3 tools/skill_code_index_lint.py`, and `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- Run `python3 tools/shipglows_metadata_lint.py` on every changed governed Markdown artifact.
- Validate `plugins/shipglows/assets/pack-catalog.json` with `jq` and run the package’s relevant audit/refresh validation if catalog/public packaging changes.
- Run `tools/shipglows_sync_skills.sh --check --all`; verify both current-user `008` symlinks resolve to the canonical source, without changing them to a predecessor path.
- Run active reference scans that include help/router/docs/public/catalog/runtime/test/tool files and use a narrow reviewed historical allowlist; do not suppress the whole spec/archive/history corpus.
- Run `pnpm --dir shipglows-site build` and inspect the `sg-customer` content route. If the local engine blocks a valid build route, record the exact engine-only gap and do not claim public proof.
- Run `git diff --check` and path-scoped `git diff --name-only`; no unrelated pre-existing work may be absorbed.

## Risks

- Artificial fragmentation could reappear as four de facto skills. Mitigation: retain one `008` identity, one public page, one runtime link pair, no wrapper directories, and explicit mode/playbook separation.
- Over-compaction could lose trust, permission, recovery, state, accessibility, or proof requirements. Mitigation: semantic transfer matrix, scenario-first tests, and source-completeness gate before any old wording is removed.
- A generic `flow` mode could become a design, content, or implementation mega-owner. Mitigation: exact adjacent-owner routes and mode-specific stop conditions.
- Legacy `sg-onboarding` or `sg-end-user` facts could be mistaken for active aliases. Mitigation: active/historical scan, reviewed allowlist, and explicit no-alias policy.
- Public/help/runtime drift could leave the dispatcher correct but discoverability ambiguous. Mitigation: active public/catalog/runtime inventory, build, sync, and code-index checks.
- Sensitive setup guidance could normalize dark patterns or conceal privacy/billing/access consequences. Mitigation: explicit value/optionality/consequence/defer/recovery rules and fresh-docs gates on future external-policy runs.
- Concurrent dirty work could contaminate validation or ship scope. Mitigation: baseline `git status`, scoped diff review, no broad rewrite, and owner-controlled later staging.

## Execution Notes

- Read first: the full current `008` activation and both local references; the historical onboarding spec; current `006`, `007`, `107`, `108`, `109`, and `300` activation boundaries; `000`/`001` routing; public `sg-customer` content; help/catalog/runtime docs; and the design/content/marketing/technical consolidation specs as architecture precedents.
- Implement in order: inventory and semantic transfer matrix -> dispatcher grammar -> bounded playbooks -> deterministic contract test -> active docs/help/public/catalog alignment -> runtime sync -> independent verification. Do not retire any directory because none is a valid predecessor source.
- Recommended implementation model/profile: GPT-5.5 high or the strongest available equivalent. This is a recommendation only; downstream runs must report the actual model/profile used and must not claim a runtime override that was unavailable.
- Keep shared doctrine canonical. The dispatcher retains selection and non-negotiable safety/boundary rules; long audit/flow/onboarding/recovery procedure belongs in local references. Do not make one mega-reference.
- Before edits, record clean/dirty worktree baseline. Re-run active scans after changes from the repository root; treat `.git`, generated output, archived history, and unrelated concurrent files as separately classified evidence rather than blanket exclusions.
- Stop and amend this spec if evidence reveals a genuinely distinct active customer owner, a required change to `600`/`601` ownership, a material public promise change, or a conflict with runtime packaging rules. Do not solve those findings by silently expanding `008`.

## Open Questions

None. Repository evidence supports the smallest complete professional contract: formalize the existing unique `008-sg-customer` owner into four modes/playbooks; no external product, security, provider, cost, or irreversible operator decision is being inferred.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-17 19:11:33 UTC | 100-sg-spec | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Inspected the complete `008` activation, onboarding/overlay playbooks, historical onboarding spec, design/content/marketing/technical precedents, adjacent owner boundaries, active routing/help/docs/public/catalog/runtime surfaces, and current-user links. | drafted; architectural compaction justified; no implementation performed | `/101-sg-ready formalize sg-customer modes and playbooks` |
| 2026-07-17 19:15:19 UTC | 101-sg-ready | GPT-5 Codex | Adversarially reviewed the four-mode dispatcher contract, ownership boundaries, trust/permission/recovery safeguards, active-versus-historical no-alias proof, runtime/catalog consequences, and isolated worktree; added explicit scenario IDs and required results to make the proof gate deterministic. | ready | `/102-sg-start formalize sg-customer modes and playbooks` |
| 2026-07-17 19:45:00 UTC | 102-sg-start + 900-shipglows-core build | GPT-5 Codex (report=agent) | Implemented the compact four-mode `008` dispatcher, audit/flow/recovery playbooks, retained onboarding with lazy overlay loading, deterministic CA 1–12 proof, discovery/public/runtime alignment, and conservative refresh trace. | implemented | `/103-sg-verify formalize sg-customer modes and playbooks` |
| 2026-07-17 21:47:30 UTC | 103-sg-verify | GPT-5 Codex | `mode=standard`: independently replayed CA 1–12, metadata, budget, runtime sync, stale-name scan, generated public route inspection, scoped diff hygiene, and the public Astro build using the declared pnpm 11.8.0 toolchain; tightened the deterministic one-mode/one-playbook assertion and removed an active historical predecessor mention. | verified | `/104-sg-end formalize sg-customer modes and playbooks` |
| 2026-07-17 21:48:36 UTC | 104-sg-end | GPT-5 Codex | Closed the verified local skill/runtime/public-documentation migration by synchronizing the canonical spec, task registry, and evidence-bounded changelog entry; no commit, push, deployment, or product-flow outcome is claimed. | closed | `/005-sg-ship formalize sg-customer modes and playbooks` |
| 2026-07-17 21:50:51 UTC | 005-sg-ship | GPT-5 Codex (report=agent) | Re-ran focused CA 1–12 proof, canonical `008` runtime visibility, diff hygiene, secret scan, and the linked-bug gate; staged only the customer-consolidation contract, playbooks, proof, and aligned documentation/closure surfaces. | shipped | `none` |

## Current Chantier Flow

- `100-sg-spec`: drafted — single-owner placement and four-mode contract are specified from active evidence; no artificial source-skill consolidation or alias is authorized.
- `101-sg-ready`: ready — adversarial review passed after the Test Contract was made deterministic for required scenarios and results.
- `102-sg-start`: implemented — compact dispatcher, bounded mode playbooks, transfer matrix, deterministic contract proof, and active discovery alignment are complete; local verification evidence is recorded by the implementation run.
- `103-sg-verify`: verified (`mode=standard`) — CA 1–12, metadata, zero budget violations, 204/204 runtime sync, active-name scan, generated public route, and pnpm 11.8.0 Astro build pass. The global code-index lint remains a documented pre-existing legacy-runtime baseline outside this scoped change.
- `104-sg-end`: closed — canonical spec, task registry, and changelog record the verified local skill/runtime/public-documentation migration without a ship, deployment, or product-flow outcome claim.
- `005-sg-ship`: shipped — scoped customer-consolidation commit pushed after focused CA 1–12 proof and current-user runtime visibility passed; this records repository delivery only, not a product-flow or hosted-runtime outcome.

Next command: `none`
