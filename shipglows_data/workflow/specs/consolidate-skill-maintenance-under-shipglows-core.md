---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.4"
project: ShipGlows
created: "2026-07-15"
created_at: "2026-07-15 22:14:05 UTC"
updated: "2026-07-16"
updated_at: "2026-07-16 11:03:07 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: skill-maintenance-surface-consolidation
owner: Diane
user_story: "As the ShipGlows operator, I use one internal skill to audit, build, refresh, validate, and package ShipGlows skills without choosing among overlapping maintenance entrypoints."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - skills/009-sg-skill-build/SKILL.md
  - skills/307-sg-skills-refresh/SKILL.md
  - skills/references/skill-instruction-layering.md
  - skills/references/skill-execution-fidelity.md
  - skills/references/skill-code-index.md
  - plugins/shipglows/assets/pack-catalog.json
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-15: consolidate the two skill-maintenance skills with 900-shipglows-core because they serve the same improvement intent."
  - "009-sg-skill-build owns skill-maintenance lifecycle orchestration; 307-sg-skills-refresh performs one refresh phase; 900-shipglows-core already owns internal skill audit, system repair, and packaging review."
  - "Active routing, docs, catalogs, agent profiles, and shared references expose 009 or 307 as separate invocation choices."
next_step: "none"
---

# Spec: Consolidate Skill Maintenance Under ShipGlows Core

🟢 [ShipGlows] spec: Consolidate Skill Maintenance Under ShipGlows Core | status: ready | path: shipglows_data/workflow/specs/consolidate-skill-maintenance-under-shipglows-core.md | next: none

## Title

Consolidate Skill Maintenance Under ShipGlows Core

## Status

Closed locally after verification; ready for a bounded ship scope.

## User Story

As the ShipGlows operator, I use one internal skill to audit, build, refresh, validate, and package ShipGlows skills without choosing among overlapping maintenance entrypoints.

## Minimal Behavior Contract

`900-shipglows-core` accepts an explicit `audit`, `build`, `refresh`, `packaging`, or `help` mode, loads only the matching playbook, and preserves the lifecycle, placement, evidence, runtime, documentation, and stop rules previously held by `009` and `307`. Invalid or incomplete mode input lists supported modes or asks one routing question; it must not silently run a skill refresh or modify a contract. Retired `009` and `307` commands have no permanent aliases, while active help and runtime surfaces direct operators to `900` modes.

## Success Behavior

- One internal entrypoint, `900-shipglows-core`, covers skill audit, maintenance lifecycle, refresh, packaging, and help.
- `900 build <target>` loads a skill-maintenance lifecycle playbook; non-trivial contract changes still require `100 -> 101 -> 102 -> 103 -> 104 -> 005` gates.
- `900 refresh <target>` loads the conservative refresh playbook and preserves novelty, freshness, evidence, refresh-log, and cross-surface coherence rules.
- `900 audit` and `900 packaging` preserve existing internal-only boundaries and execution-fidelity/system-improvement rules.
- Detailed procedures live in bounded playbooks, not a mega `900` body.
- Active routing, indexes, pack catalogs, runtime links, public-facing help, and technical docs advertise only `900` for internal skill maintenance.
- `009` and `307` directories and current-user runtime links are retired only after contract-completeness and active-reference checks pass.

## Error Behavior

- Bare `900` or an invalid mode explains valid modes; it does not infer `build` or `refresh`.
- `build` stops or routes to `700-sg-explore`, `100-sg-spec`, or `101-sg-ready` when placement or readiness is unresolved.
- `refresh` stops when a proposed change is decorative, lacks proportionate evidence, or is a prohibited ordinary self-refresh of the router itself.
- Missing playbook, target, runtime sync, metadata, public-doc, or proof path blocks retirement of the corresponding source skill.
- Historical specs, refresh logs, archives, and changelog evidence retain factual `009`/`307` names; only active references must migrate.

## Problem

The operator intent is one: improve ShipGlows skills. It is split across `900` for audit/core repair, `009` for skill-maintenance lifecycle, and `307` for refresh. This creates duplicate discovery, ambiguous handoffs, and unnecessary invocation choice even though `307` is operationally a step inside the `009` lifecycle and both overlap the internal `900` system-improvement role.

## Solution

Make `900-shipglows-core` the sole internal skill-maintenance entrypoint. Add explicit modes and two focused playbooks for lifecycle build and conservative refresh; preserve audit and packaging as existing modes. Migrate active routing/docs/catalog/runtime surfaces, then retire `009` and `307` without aliases after proof.

## Scope In

- Compact mode dispatcher and lifecycle identity in `skills/900-shipglows-core/SKILL.md`.
- Local playbooks under `skills/900-shipglows-core/references/` for skill maintenance and refresh.
- Migration of execution-critical rules from `009` and `307`, including readiness, placement, scenario-first proof, refresh evidence, runtime sync, documentation coherence, and stop conditions.
- Retirement of `skills/009-sg-skill-build/` and `skills/307-sg-skills-refresh/` and their current-user links.
- Active routing, help, catalog, agent-profile, technical, workflow, public-site, and tooling references.
- Narrow historical allowlist for specs, refresh log, changelog, archives, and factual run history.

## Scope Out

- Consolidating unrelated product, design, content, docs, audit, or lifecycle skills.
- Publishing `900` as a public ShipGlows plugin skill or adding a public `sg-core` page.
- Preserving permanent wrappers, aliases, or hidden compatibility skill directories for `009` or `307`.
- Rewriting historical artifacts merely to erase factual invocation history.
- Changing the semantics of existing `900 audit`, `packaging`, or internal-only safeguards beyond what mode routing requires.

## Constraints

- The sole internal skill-maintenance invocation owner is `900-shipglows-core`.
- Canonical modes are `audit`, `build <target>`, `refresh <target>`, `packaging`, and `help`.
- `build` retains spec-first requirements for non-trivial changes; `refresh` remains conservative and does not authorize generic self-refresh.
- `900` remains internal-only and absent from the public plugin and public skill site.
- `SKILL.md` remains an activation dispatcher; detailed lifecycle and refresh procedures move into bounded references.
- Active `009`/`307` references must migrate; history remains intact and reviewable.
- No unrelated dirty files enter this migration or a later ship scope.

## Test Contract

Proof path: `scenario-first`, supplemented by mechanical runtime, catalog, metadata, and active-reference evidence.

1. Mode scenarios: valid `audit`, `build`, `refresh`, `packaging`, and `help`; bare/invalid modes; build with an ambiguous target; refresh self-target; missing playbook.
2. Contract-completeness comparison: each retired source requirement maps to `900` dispatcher, a local playbook, or an existing shared reference.
3. Active-surface proof: focused stale-name scans distinguish active files from historical evidence.
4. Tooling proof: metadata lint, skill audit, budget audit, code-index lint where baseline allows, runtime sync, plugin catalog JSON, pack refresh, and site build where public help changes.
5. Filesystem proof: retired source directories and runtime links absent; `900` links present after sync.

## Dependencies

- `skill-instruction-layering.md` — activation/playbook placement.
- `spec-driven-development-discipline.md` — scenario-first contract proof.
- `skill-execution-fidelity.md` — audit/system-improvement rules.
- `master-workflow-lifecycle.md` and `master-delegation-semantics.md` — lifecycle and delegated execution rules.
- `codex-plugin-packaging.md` — internal/public packaging boundary.
- Fresh external docs: `fresh-docs not needed`; this is a local skill-contract and documentation migration.

## Invariants

- One internal owner for skill improvement: `900-shipglows-core`.
- One explicit mode maps to one bounded playbook or existing `900` procedure.
- No source skill directory survives as a permanent alias.
- Internal-only `900` policy remains intact.
- A fresh agent can find the required lifecycle or refresh gate from `900` without reading retired folders.

## Links & Consequences

- `000-shipglows`, `001-sg-build`, `300-sg-docs`, `302-sg-help`, and technical workflow docs must route skill-maintenance requests to `900 build` or `900 refresh`.
- `skills/references/*`, operator profiles, and workflow playbooks may contain active execution handoffs and need migration.
- Plugin pack catalogs must no longer list `009` or `307`; `900` remains excluded from public packaging.
- The audit helper's directory-specific semantics and code index must not leave a stale retired identity.

## Documentation Coherence

- Update internal help, README, launch/focus guides, technical lifecycle docs, workflow playbooks, agent profiles, and relevant public explanations of ShipGlows workflow.
- Do not add a public `900` page; document the internal-only boundary where public content currently mentions `009` or `307`.
- Update changelog and closure tracking only after verification/closure, without claiming shipment before `005`.

## Edge Cases

- `900 build` with no target lists required target shape; it does not select the last edited skill.
- `900 refresh 900-shipglows-core` requires explicit manual maintenance/scenario-first path, never ordinary self-refresh.
- A stale runtime cache after filesystem sync is a reload-only proof gap, not a reason to recreate retired skills.
- A retired invocation found in `REFRESH_LOG.md`, specs, archives, or prior changelog entries is historical evidence, not active drift.
- A public pack still referencing `009` or `307` blocks retirement even if local skills pass.

## Implementation Tasks

- [x] Task 1: Freeze the migration inventory and stale-name policy.
  - Files: this spec and targeted active-reference inventory.
  - Action: classify every `009`/`307` occurrence as active, generated/runtime, public, test/tooling, or historical.
  - Validate with: reviewed `rg` inventory and explicit historical allowlist.

- [x] Task 2: Build the compact `900` dispatcher and modes.
  - Files: `skills/900-shipglows-core/SKILL.md`.
  - Action: define exact grammar, mode routing, lifecycle trace, invalid-input behavior, and internal-only boundary.
  - Validate with: scenario matrix and focused heading/reference scans.

- [x] Task 3: Migrate lifecycle and refresh procedures into playbooks.
  - Files: `skills/900-shipglows-core/references/skill-maintenance-playbook.md`, `skill-refresh-playbook.md`.
  - Action: preserve source-critical placement, readiness, proof, runtime, freshness, logging, docs, and stop rules without duplicating shared doctrine.
  - Validate with: source-to-target completeness matrix and pressure scenarios.

- [x] Task 4: Migrate active routing, docs, catalogs, profiles, and tooling.
  - Files: active contracts/docs identified in Task 1.
  - Action: replace active retired commands with `900 build` or `900 refresh`, preserve historical evidence, and maintain public/internal packaging separation.
  - Validate with: stale-key scan, JSON/catalog checks, and affected site build.

- [x] Task 5: Retire source skills and runtime visibility.
  - Files: `skills/009-sg-skill-build/`, `skills/307-sg-skills-refresh/`, runtime links, indexes/manifests.
  - Action: remove only after Tasks 2-4 prove complete; refresh `900` runtime links and remove stale old links.
  - Validate with: source absence, sync check, and code-index/pack-catalog validation.

- [x] Task 6: Verify and close the migration.
  - Files: governed contract/docs artifacts and this spec.
  - Action: run full scenario and mechanical proof, record limits accurately, then route through closure and ship.
  - Validate with: `/103-sg-verify consolidate skill maintenance under shipglows core`, then local closure bookkeeping through `104-sg-end`.

## Acceptance Criteria

- [x] CA 1: Given an operator needs to improve a ShipGlows skill, when they invoke `900 build <target>`, then the lifecycle playbook and its readiness/proof gates are selected.
- [x] CA 2: Given an operator needs a conservative skill refresh, when they invoke `900 refresh <target>`, then the refresh playbook preserves evidence, novelty, logging, and self-refresh protections.
- [x] CA 3: Given `audit`, `packaging`, or `help`, when the mode is valid, then existing 900 ownership and internal-only rules are retained.
- [x] CA 4: Given bare or invalid mode input, when action selection would change behavior, then supported modes are listed or one targeted question is asked instead of guessing.
- [x] CA 5: Given the runtime inventory after migration, when internal skill-maintenance entries are listed, then `900-shipglows-core` is the only owner from this family.
- [x] CA 6: Given active docs, help, profiles, catalogs, and tooling, when scanned, then no active `009` or `307` invocation remains outside the historical allowlist.
- [x] CA 7: Given historical records contain retired names, when validation runs, then they remain intact and classified as history.
- [x] CA 8: Given the migrated corpus, when audit, budget, metadata, runtime, catalog, pack, and relevant site checks run, then they pass or a named proof gap blocks verification.

## Test Strategy

- Scenario-first routing matrix and source-to-playbook comparison.
- Narrow active-reference scans plus explicit historical exclusions.
- `python3 tools/audit_shipglows_skills.py`.
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- `python3 tools/shipglows_metadata_lint.py` for governed Markdown artifacts.
- `tools/shipglows_sync_skills.sh --check --all` after source/runtime migration.
- `jq empty plugins/shipglows/assets/pack-catalog.json` and `refresh_shipglows_pack.py` where catalog changes.
- Astro build only if public content changes.

## Risks

- A mega `900` body could replace duplicate entrypoints with unreadable activation instructions; mitigate through bounded playbooks.
- Deleting `009`/`307` before all source-critical rules migrate could weaken readiness or refresh quality; mitigate with completeness comparison before retirement.
- Stale active help or runtime links could leave users invoking removed commands; mitigate with focused scans and sync proof.
- `900` could accidentally become public through catalog migration; preserve its explicit internal-only exclusion.

## Execution Notes

- Read first: all three source contracts, `skill-execution-fidelity.md`, `skill-instruction-layering.md`, `master-workflow-lifecycle.md`, and `codex-plugin-packaging.md`.
- Implement sequentially: inventory -> dispatcher -> playbooks -> active surfaces -> retirement -> verification.
- Treat the existing `009` and `307` previous-spec references as historical unless an active instruction routes an operator there.
- Preserve unrelated dirty worktree changes, especially the already-open design consolidation and customer rename work.

## Open Questions

None. The operator chose a single internal skill-maintenance owner, `900-shipglows-core`, with modes/playbooks rather than micro-skills or compatibility wrappers.

## Verification Evidence

- Proof path: `scenario-first` with ten focused contract tests covering valid/invalid modes, packaging identity, lifecycle/refresh source requirements, and the repaired `build -> refresh -> final budget -> 103` transition.
- Source completeness: the retired `009` and `307` contracts were compared from `git show HEAD`; placement, readiness, scenario proof, runtime, docs/public visibility, conservative replacement, cadence, refresh logging, language, and self-refresh protections map to the dispatcher or bounded playbooks. Material builds now require conservative refresh before final budget and verification; self-target `900` uses a spec-backed independent manual review, while a mechanical `refresh not needed` exception requires written justification and focused proof distinct from `fresh-docs not needed`.
- Runtime/source retirement: both source directories and all four current-user `009`/`307` links are absent; Claude and Codex `900` links resolve to the canonical source; focused and all-skill sync checks pass.
- Active surface: no retired invocation remains after excluding factual `source_skill`, `supersedes`, specs, changelog, refresh log, archives, reviews, repurpose packs, and conversation-audit history.
- Internal/public boundary: the public pack catalog contains none of `900`, `009`, or `307`; their public pages are absent and all nine blog articles contain no retired invocation or internal `900` command. The global packaging audit still reports its pre-existing `000-shipglows`/source-portability baseline, with no `900` exposure finding.
- Mechanical proof: ten contract unit tests, governed metadata lint, generic skill audit, budget audit, catalog JSON, filesystem assertions, focused and 236/236 all-runtime sync, and `git diff --check` pass. `skill_code_index_lint.py` still reports the pre-existing `sg-*`/ShipGlows alias-index baseline, with no `009`/`307`-specific error.
- Site build: direct Astro build passes with 90 generated pages; no `900`, `sg-skill-build`, or `sg-skills-refresh` public route is generated.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-15 22:14:05 UTC | 100-sg-spec | GPT-5 Codex | Created the skill-maintenance consolidation contract from the operator decision and source-contract inventory | drafted | `/101-sg-ready consolidate skill maintenance under shipglows core` |
| 2026-07-15 22:14:05 UTC | 101-sg-ready | GPT-5 Codex | Reviewed structure, mode semantics, migration scope, historical policy, proof contract, and internal-only boundary | ready | `/102-sg-start consolidate skill maintenance under shipglows core` |
| 2026-07-15 23:15:34 UTC | 103-sg-verify | GPT-5 Codex | Compared retired source contracts, repaired bounded migration gaps, and ran scenario, metadata, runtime, catalog, pack, stale-name, audit, budget, and filesystem proof | verified | `/104-sg-end consolidate skill maintenance under shipglows core` |
| 2026-07-15 23:19:00 UTC | 104-sg-end | GPT-5 Codex | Closed local tracker and changelog bookkeeping after verified skill-maintenance consolidation; no commit or push performed | closed | `/005-sg-ship consolidate skill maintenance under shipglows core` |
| 2026-07-15 23:20:44 UTC | 005-sg-ship | GPT-5 Codex | Audited whole-file ship provenance and found required shared routing, catalog, index, changelog, and tracker files mixed with unrelated design, customer-rename, and conversation-tracking changes; staged nothing | blocked | Separate or intentionally batch the overlapping chantiers, then rerun `/005-sg-ship consolidate skill maintenance under shipglows core` |
| 2026-07-15 23:22:10 UTC | 001-sg-build | GPT-5 Codex | Completed orchestration through implementation, verification, and local closure; ship remained correctly blocked because the required whole-file scope could not be isolated from overlapping chantiers | partial | Separate or intentionally batch the overlapping chantiers, then rerun `/005-sg-ship consolidate skill maintenance under shipglows core` |
| 2026-07-16 11:03:07 UTC | 103-sg-verify | GPT-5 Codex | Independently reverified compaction excellence after repairing the build-to-refresh lifecycle, self-target review, mechanical exception, and packaging identity contracts; ten scenarios and all focused proof passed | verified | `/005-sg-ship` the operator-authorized design, customer, and skill-maintenance batch |
| 2026-07-16 11:16:50 UTC | 005-sg-ship | GPT-5 Codex | Validated and staged the operator-authorized design, customer, and skill-maintenance batch with isolated index hunks, full cached-scope review, runtime proof, metadata, unit tests, and site build | shipped | none |

## Current Chantier Flow

- `100-sg-spec` ✅ draft created
- `101-sg-ready` ✅ ready
- `102-sg-start` ✅ implemented
- `103-sg-verify` ✅ excellence reverified with ten focused scenarios
- `104-sg-end` ✅ closed locally
- `005-sg-ship` ✅ shipped in the operator-authorized consolidation batch

Next step: none.
