---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.1"
project: ShipGlows
created: "2026-07-15"
created_at: "2026-07-15 16:49:38 UTC"
updated: "2026-07-15"
updated_at: "2026-07-15 20:57:02 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: design-skill-surface-consolidation
owner: Diane
user_story: "As the ShipGlows operator, I invoke one design skill with explicit modes and retain rigorous playbooks without navigating several overlapping design skills."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/
  - skills/500-sg-design-from-scratch/
  - skills/501-sg-design-playground/
  - skills/502-sg-audit-design/
  - skills/503-sg-audit-design-tokens/
  - skills/504-sg-audit-components/
  - skills/409-sg-audit-a11y/SKILL.md
  - skills/000-shipglows/SKILL.md
  - skills/009-sg-skill-build/SKILL.md
  - skills/302-sg-help/SKILL.md
  - skills/302-sg-help/references/help-catalog.md
  - skills/references/skill-instruction-layering.md
  - skills/references/skill-code-index.md
  - skills/references/design-system-token-contract.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows-site/src/content/skills/
  - tools/audit_shipglows_skills.py
  - tools/skill_budget_audit.py
depends_on:
  - artifact: shipglows_data/workflow/explorations/2026-07-15-design-skill-surface-consolidation.md
    artifact_version: "1.0.0"
    required_status: draft
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: shipglows_data/technical/codex-plugin-packaging.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-15: retain one design skill with modes, playbooks, references, and tools."
  - "Current design family exposes 006-sg-design plus 500-sg-design-from-scratch, 501-sg-design-playground, 502-sg-audit-design, 503-sg-audit-design-tokens, 504-sg-audit-components, and 409-sg-audit-a11y."
  - "2026-07-15 skill budget audit: 69 skills and 8536/8500 absolute discovery estimate."
  - "2026-07-15 exploration identified at least 51 non-spec references to the five 500-series retiring invocation keys; 409 references require the same active-versus-historical classification."
next_step: "none"
---

# Spec: Consolidate Design Skill Surface Into Modes And Playbooks

🟢 [ShipGlows] spec: Consolidate Design Skill Surface Into Modes And Playbooks | status: ready | path: shipglows_data/workflow/specs/consolidate-design-skill-surface-into-modes-and-playbooks.md | next: none

## Title

Consolidate Design Skill Surface Into Modes And Playbooks

## Status

Closed locally after verification — ready for `005-sg-ship`.

## User Story

As the ShipGlows operator, I invoke one design skill with explicit modes and retain rigorous playbooks without navigating several overlapping design skills.

## Minimal Behavior Contract

When an operator asks for any supported design action, `006-sg-design` accepts one clear mode and loads only the relevant playbook, then applies the same design-system, proof, safety, and lifecycle constraints previously owned by the specialized skill. If the mode is invalid or ambiguous, it reports the supported modes or asks one targeted routing question; it must never silently choose a different design action. The easy edge case is a stale internal or public reference that still advertises a retired `500–504` or `409` command after the directory has been removed.

## Success Behavior

- An operator can discover and invoke all six migrated specialist capabilities through `006-sg-design` alone:
  - `system`
  - `playground [route-path]`
  - `audit ui [scope]`
  - `audit tokens [scope]`
  - `audit components [scope]`
  - `audit a11y [scope]`
- Each valid mode loads a separately named local playbook and preserves its existing safety, scope, validation, reporting, and chantier behavior.
- `006-sg-design/SKILL.md` remains a compact mode dispatcher; it does not absorb detailed audit matrices, generation procedures, templates, or troubleshooting branches.
- The six standalone `500–504` and `409` invocation directories and their current-user runtime links no longer exist after migration.
- Active routing/help/public documentation uses the `006-sg-design` modes and no active surface advertises a retired command.
- Historical specs, exploration reports, changelog history, and archived artifacts retain factual legacy names; stale-key checks use a narrow historical allowlist rather than rewriting history.
- The skill audit, budget audit, metadata lint, runtime sync, focused routing scenarios, and affected public-site build pass.

## Error Behavior

- If a mode cannot identify its required playbook, token authority, project route, or safe proof path, `006-sg-design` stops or routes according to the preserved mode-specific contract.
- If a migration would weaken token authority, production gating, redaction, accessibility, proof, or chantier behavior, implementation stops and restores the relevant local directive before continuing.
- If active docs, runtime links, or source contracts still name a retired invocation key, verification fails until it is migrated or explicitly classified as historical evidence.
- If a previously used `500–504` or `409` command is entered after removal, it is not silently emulated by a hidden alias; help/routing must guide the operator to the canonical `006-sg-design` mode when the runtime supports that route.
- Must never happen: a mega-`SKILL.md`, a mega-reference, a second public design owner, a permanent alias skill, or deletion of unrelated skills/files.

## Problem

The design family currently exposes seven skills for one operator intent: a master `006-sg-design` plus six specialists. Previous compaction correctly moved long procedure details into references, but retained specialist invocation directories, public pages, and runtime visibility. This keeps the discovery list noisy, duplicates routing choices, and blurs the distinction between a public owner skill and an internal procedure.

## Solution

Make `006-sg-design` the sole public design skill. Add explicit mode detection and lazy playbook loading, move the six specialist procedures into purpose-specific references beneath `skills/006-sg-design/references/`, migrate all active references and public guidance, then retire the `500–504` and `409` directories and runtime links once checks prove no active surface still depends on them.

## Scope In

- `skills/006-sg-design/SKILL.md` mode contract, routing matrix, arguments, stop behavior, and validation references.
- Six bounded local playbooks migrated from the existing specialist skill contracts and references:
  - `design-system-creation-playbook.md`
  - `design-playground-playbook.md`
  - `design-audit-playbook.md`
  - `design-token-audit-playbook.md`
  - `component-system-audit-playbook.md`
  - `accessibility-audit-playbook.md`
- Transfer of the existing specialist README/reference material only where it remains execution-critical.
- Retirement of `skills/500-sg-design-from-scratch/` through `skills/504-sg-audit-components/` and `skills/409-sg-audit-a11y/` after their content and active references are migrated.
- Current-user runtime visibility cleanup through the ShipGlows sync helper.
- Active routing/help/lifecycle docs, public skill pages, and tests/tooling that name the retiring keys.
- A narrow migration/compatibility policy documenting the canonical commands and historical-reference allowlist.

## Scope Out

- Consolidating non-design skills or redesigning the entire 69-skill taxonomy.
- Changing visual product code, design tokens, presets, components, branding, or public site UI.
- Rewriting historical specs, exploration reports, archives, or changelog records merely to remove factual legacy names.
- Keeping permanent compatibility wrapper skills or inventing new aliases outside `006-sg-design`.

## Constraints

- The sole public design invocation owner is `006-sg-design`.
- Canonical modes are exactly `system`, `playground`, `audit ui`, `audit tokens`, `audit components`, and `audit a11y`; existing `library`, `redesign`, and `migration` modes remain subject to their current `006` contracts.
- The activation contract must select modes and load references; detailed procedure stays in purpose-specific local playbooks.
- Preserve the design-system token contract, including centralized authority, drift checks, accessibility, reduced motion, focus, target-size, safe-area, responsive, and IME/keyboard safeguards.
- Preserve the playground's production access gate and dev-only mutation controls; migration must not expose token-writing endpoints or weaken auth assumptions.
- Preserve report modes, chantier tracing semantics, redaction, public-claim discipline, and proof obligations from every retired specialist.
- Security impact is none because this is a local skill-contract and documentation migration; the existing playground production gate and dev-only mutation controls are preserved rather than expanded.
- Retired skills are removed rather than renamed or retained as wrappers. Only documentation/routing guidance can explain the new commands.
- Any stale-name scan must distinguish active contracts from immutable historical evidence through a reviewable allowlist.
- No unrelated dirty files may be modified. `cli/install.sh` is already dirty and is outside this scope.

## Test Contract

Proof path: `scenario-first` for skill-contract and routing behavior, supplemented by evidence-first documentation/runtime proof.

1. Automated/mechanical proof:
   - focused `rg` scans for each retired key in active surfaces and the historical allowlist;
   - metadata lint for new/changed Markdown artifacts;
   - `audit_shipglows_skills.py` and `skill_budget_audit.py`;
   - `shipglows_sync_skills.sh --check --all` after removing retired directories and refreshing `006` visibility.
2. Contract proof:
   - mode-routing scenarios prove each supported input loads its matching playbook and rejects/asks on invalid or ambiguous input;
   - scenario review proves `audit a11y` loads the accessibility playbook and preserves WCAG/APG, keyboard, focus, ARIA, screen-reader, and cross-platform contracts.
3. Public documentation proof:
   - build the affected `shipglows-site` skill-content surface and verify links/commands describe `006` modes only.
4. Manual evidence only if needed:
   - inspect the runtime picker after reload if filesystem sync cannot prove removal/visibility in the active session; otherwise record `exception-with-proof` with the filesystem-sync evidence.

## Dependencies

- `shipglows_data/workflow/explorations/2026-07-15-design-skill-surface-consolidation.md` — current decision record.
- `skills/references/skill-instruction-layering.md` — activation/reference placement doctrine.
- `skills/references/design-system-token-contract.md` — preserved design safety invariants.
- `shipglows_data/technical/codex-plugin-packaging.md` — public skill/runtime packaging constraints.
- `skills/references/reporting-contract.md`, `skills/references/chantier-tracking.md`, and `skills/references/spec-driven-development-discipline.md` — lifecycle and proof contracts.
- Fresh external docs: `fresh-docs not needed`; this migration is entirely local to ShipGlows contracts, runtime links, and public documentation.

## Invariants

- One public design owner, `006-sg-design`.
- One mode maps to one bounded playbook; a playbook does not create a second public invocation key.
- Mode selection never bypasses the project design-system authority or proof path.
- Historical truth is preserved; active discoverability is corrected.
- A fresh agent can identify the next safe design action from `006-sg-design` without reading retired skill directories.

## Links & Consequences

- `000-shipglows` must continue to route all design requests to `006-sg-design`, now with the canonical mode syntax.
- `009-sg-skill-build` and `302-sg-help` must not recommend retired design skills.
- `306-sg-scaffold`, `106-sg-fix`, `102-sg-start`, `103-sg-verify`, `307-sg-skills-refresh`, and the design-system authority docs may contain active handoffs that need migration, including `409` handoffs.
- Public `shipglows-site/src/content/skills/sg-design*.md` pages must converge into one truthful design entrypoint or redirect/retire under the site’s established content convention.
- Plugin/runtime packaging must not point at deleted skill paths; any generated catalogs or sync tests need updates in the same change.

## Documentation Coherence

- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` to describe one design skill with modes/playbooks.
- Update public `shipglows-site` skill content that currently documents `sg-design`, `sg-design-from-scratch`, `sg-design-playground`, `sg-audit-design`, `sg-audit-design-tokens`, `sg-audit-components`, or `sg-audit-a11y`.
- Update internal help/routing docs and any public skill index/catalog that contains the retiring invocations.
- Preserve historic references in specs/explorations/archives; add a concise migration note only where active users need it.

## Edge Cases

- `audit` without a subtype: provide the supported audit modes; do not infer UI, tokens, components, or a11y.
- `playground` on a project without a canonical token source: preserve the existing stop/reroute to `system`.
- `system` when multiple candidate token authorities exist: preserve the existing targeted-decision/reroute behavior.
- A stale link in a public page or plugin catalog: fail the active-surface scan even if core skills pass.
- A retired key found only in a historical run table: permit it through the scoped allowlist without changing history.
- A mode’s existing checklist/reference is not migrated: block retirement of its source skill until its execution contract is complete.
- Runtime session still lists removed skills after filesystem sync: record session reload as a proof gap, not as a reason to recreate aliases.

## Implementation Tasks

- [x] Task 1: Freeze the migration inventory and stale-name policy.
  - Files: `shipglows_data/workflow/specs/consolidate-design-skill-surface-into-modes-and-playbooks.md`, targeted active-reference inventory/test helper.
  - Action: classify every `500–504` and `409` reference as active, generated/runtime, public, test/tooling, or historical; define the exact historical allowlist and no-alias policy.
  - User story link: prevents retired commands from remaining discoverable.
  - Depends on: ready spec.
  - Validate with: reviewed inventory plus focused `rg` baseline.

- [x] Task 2: Create the compact `006-sg-design` mode dispatcher.
  - Files: `skills/006-sg-design/SKILL.md`, `skills/006-sg-design/references/design-lifecycle-routing.md`.
  - Action: define canonical grammar, mode detection, load triggers, reroutes, and invalid-input behavior while preserving library/redesign/migration modes.
  - User story link: provides one clear design entrypoint.
  - Depends on: Task 1.
  - Validate with: routing scenario matrix and focused heading/reference scans.

- [x] Task 3: Migrate specialist execution contracts into six local playbooks.
  - Files: `skills/006-sg-design/references/design-system-creation-playbook.md`, `design-playground-playbook.md`, `design-audit-playbook.md`, `design-token-audit-playbook.md`, `component-system-audit-playbook.md`, `accessibility-audit-playbook.md`.
  - Action: move each specialist’s required procedure, validations, report behavior, stop conditions, and local references without duplicating shared doctrine or creating a mega-reference; preserve `409` WCAG/APG, keyboard, focus, ARIA, screen-reader, and cross-platform checks.
  - User story link: retains rigor after reducing the public surface.
  - Depends on: Task 2.
  - Validate with: one pressure scenario per mode and content-completeness comparison against its retiring source.

- [x] Task 4: Migrate active routing, documentation, public pages, and tooling.
  - Files: active contracts/docs identified in Task 1, including `000-shipglows`, `302-sg-help`, lifecycle docs, design authority, `shipglows-site/src/content/skills/`, and affected tests/scripts.
  - Action: replace active retired keys with canonical `006` mode syntax; retain factual historical names only in the approved allowlist.
  - User story link: makes discovery and documentation truthful.
  - Depends on: Tasks 2-3.
  - Validate with: active-surface stale-key scan, link/content checks, and affected site build.

- [x] Task 5: Retire the six standalone design skills and runtime visibility.
  - Files: `skills/500-sg-design-from-scratch/` through `skills/504-sg-audit-components/`, `skills/409-sg-audit-a11y/`, current-user skill links, generated/runtime manifests if present.
  - Action: remove each directory only after the migration-completeness checks pass; repair/check runtime visibility using the shared sync helper.
  - User story link: removes competing design entrypoints.
  - Depends on: Task 4.
  - Validate with: `shipglows_sync_skills.sh --check --all`, source-directory absence checks, and no active stale-key results.

- [x] Task 6: Validate the contract and document the migration result.
  - Files: changed skill/reference/doc/test artifacts and `shipglows_data/technical/skill-runtime-and-lifecycle.md`.
  - Action: run scenario-first proof and ShipGlows validations; record any runtime-session reload proof gap honestly.
  - User story link: ensures the smaller surface remains reliable and discoverable.
  - Depends on: Tasks 1-5.
  - Validate with: full Test Contract command set and `103-sg-verify`.

## Acceptance Criteria

- [x] CA 1: Given an operator needs a design-system migration, when they invoke `006-sg-design system`, then the system loads the migrated design-system creation playbook and preserves token-authority safeguards.
- [x] CA 2: Given an operator invokes `006-sg-design playground /design-system`, when a canonical token authority exists, then the playground playbook is selected with its production/dev mutation safeguards intact.
- [x] CA 3: Given an operator invokes `006-sg-design audit ui`, `audit tokens`, `audit components`, or `audit a11y`, when the scope is valid, then exactly the corresponding audit playbook is selected.
- [x] CA 4: Given an operator invokes bare `audit` or an invalid mode, when subtype selection changes the audit scope, then the skill lists/asks for the supported mode instead of guessing.
- [x] CA 5: Given a fresh runtime skill inventory after migration, when design skills are listed, then only `006-sg-design` is exposed from this consolidated family.
- [x] CA 6: Given active ShipGlows docs, public skill pages, help routes, and tooling, when scanned for `500–504` and `409` keys, then no active reference remains outside the approved historical allowlist.
- [x] CA 7: Given historical artifacts name retired keys, when validation runs, then the artifacts are preserved and classified as historical rather than rewritten or reported as active drift.
- [x] CA 8: Given the migrated corpus, when audit, budget, metadata, runtime-sync, and relevant public-site checks run, then they pass or an explicit proof gap blocks verification.
- [x] CA 9: Given the compact dispatcher, when a fresh agent reads it, then it can identify the mode, matching playbook, stop behavior, and proof path without reading retired directories.

## Test Strategy

- Scenario-first matrix for `system`, `playground`, each audit subtype including `audit a11y`, bare `audit`, invalid input, missing token authority, stale active reference, and historical reference.
- Mechanical scans with reviewed path exclusions rather than broad `rg` suppression.
- `python3 tools/audit_shipglows_skills.py`.
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- `python3 tools/shipglows_metadata_lint.py <all changed metadata artifacts>`.
- `tools/shipglows_sync_skills.sh --check --all` after source/runtime migration.
- Targeted tests for any routing/catalog tooling changed by the migration.
- `pnpm --dir shipglows-site build` if public skill content changes.
- `103-sg-verify` after implementation; no ship/closure claim before that result.

## Verification Evidence

| Gate | Result | Evidence |
|------|--------|----------|
| Success and error behavior | Pass | Scenario assertions cover all six core modes, bare or invalid audit input, the deep-audit composition exception, production playground denial, and retired-directory absence. |
| Constitution and migrated wording | Pass after repair | `103-sg-verify` found that the first pass had over-compressed the six source contracts. The six bounded playbooks now restore mode-specific phases, scoring, severity, framework, security, accessibility, reporting, and stop obligations while `006-sg-design/SKILL.md` remains a compact dispatcher. |
| Proof-path fit | Pass | The contract is local and static: scenario-first assertions, source-to-playbook comparison, active-reference scans, metadata lint, skill audit, budget audit, runtime sync, JSON validation, diff hygiene, and the public-site build provide proportionate proof. |
| Runtime and public surface | Pass | Runtime sync is `246/246`; no active source advertises retired `409` or `500–504` invocations; Astro built 92 pages including `/skills/sg-design` and excluding the six retired public pages. |
| Skill quality and budget | Pass | 63 skills, no hard audit finding, no budget warning, and an absolute discovery estimate of `7912/8500`; `006-sg-design` is 196 body lines (about 3616 tokens) and delegates detail lazily to six focused playbooks. The separate `205-sg-veille` review risk predates and is outside this scope. |
| Task application and closure | Pass | All implementation tasks and acceptance criteria are checked; the operational line, run history, current flow, and next step now agree. No shared tracker was edited by verification. |
| Bug and risk gate | Pass in scope | No open high or critical design-consolidation bug was found. Existing unrelated project bugs and the pre-existing dirty worktree do not alter this bounded verdict. |
| Documentation freshness | Not needed | No unstable external API or framework claim governs this local skill-and-documentation migration. |
| Runtime diagnostics and design drift | Not applicable | This change modifies skill contracts, references, and documentation rather than a product runtime or product UI surface. |

Focused checks passed: metadata lint on the governed artifacts, `audit_shipglows_skills.py`, `skill_budget_audit.py`, `shipglows_sync_skills.sh --check --all`, 17 routing and safety assertions, active retired-key scans, `jq empty` on the plugin catalog, `git diff --check`, and the local Astro production build.

## Risks

- Invocation removal can break users who type old commands; clear mode documentation and no-alias policy make the supported surface unambiguous.
- Incomplete procedure migration can weaken safety or proof. Mitigation: content-completeness comparison and per-mode pressure scenarios before source deletion.
- Stale public docs can create a false public contract. Mitigation: active-surface scan and site build.
- Runtime caches can temporarily show removed skills. Mitigation: distinguish filesystem proof from reload-only proof gap.
- A broad migration can accidentally consume unrelated skill taxonomy work. Mitigation: explicit scope out and targeted stale-key inventory.

## Execution Notes

- Read first: `skills/006-sg-design/SKILL.md`, its routing reference, each `500–504` and `409` contract/reference, `skills/references/skill-instruction-layering.md`, and the exploration report.
- Implement sequentially: inventory -> dispatcher -> six playbooks -> active references/docs/tooling -> retirement -> validation. Do not remove source contracts before their target playbook passes completeness review.
- Keep shared doctrine in existing shared references. The new playbooks own only design-mode-specific procedure.
- Use the ShipGlows-owned preflight before every helper/script and preserve the existing unrelated `cli/install.sh` modification.
- Stop and reroute if an affected active contract belongs to another family or if a migration needs a public compatibility decision outside this no-alias contract.

## Open Questions

None. The operator’s 2026-07-15 direction resolves the public-surface decision: one design skill with modes/playbooks, not renamed specialist skills or permanent aliases.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-15 16:49:38 UTC | 100-sg-spec | GPT-5 Codex | Created the spec from the design-surface consolidation exploration and operator decision | drafted | `/101-sg-ready shipglows_data/workflow/specs/consolidate-design-skill-surface-into-modes-and-playbooks.md` |
| 2026-07-15 16:52:53 UTC | 009-sg-skill-build | GPT-5 Codex | Routed the operator decision through exploration and durable spec creation without editing the design contracts | implemented | `/101-sg-ready shipglows_data/workflow/specs/consolidate-design-skill-surface-into-modes-and-playbooks.md` |
| 2026-07-15 16:59:01 UTC | 009-sg-skill-build | GPT-5 Codex | Corrected the accessibility boundary after operator clarification | `409-sg-audit-a11y` is now `006-sg-design audit a11y`; draft pending readiness review | `/101-sg-ready shipglows_data/workflow/specs/consolidate-design-skill-surface-into-modes-and-playbooks.md` |
| 2026-07-15 17:01:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed the revised contract, adversarial migration cases, scope, proof, and security boundary | ready | `/102-sg-start consolidate design skill surface into modes and playbooks` |
| 2026-07-15 17:09:04 UTC | 102-sg-start | GPT-5.6 Luna | Consolidated the six design contracts into `006` modes/playbooks, migrated active docs/pages/catalogs, removed retired directories, and ran local proof | implemented | `/103-sg-verify consolidate design skill surface into modes and playbooks` |
| 2026-07-15 19:08:14 UTC | 103-sg-verify | GPT-5 Codex | Compared every retired source contract with its target mode, repaired over-compressed playbooks, and verified routing, safeguards, docs, runtime sync, budgets, metadata, stale references, and the static site | verified | `/104-sg-end consolidate design skill surface into modes and playbooks` |
| 2026-07-15 20:57:02 UTC | 104-sg-end | GPT-5 Codex | Closed local tracker and changelog bookkeeping after verified design-surface consolidation; no commit or push performed | closed | `/005-sg-ship consolidate design skill surface into modes and playbooks` |
| 2026-07-16 11:16:50 UTC | 005-sg-ship | GPT-5 Codex | Validated and staged the operator-authorized design, customer, and skill-maintenance batch with isolated index hunks, full cached-scope review, runtime proof, metadata, unit tests, and site build | shipped | none |

## Current Chantier Flow

- `100-sg-spec` ✅ draft created
- `101-sg-ready` ✅ ready
- `102-sg-start` ✅ implemented
- `103-sg-verify` ✅ verified after restoring the execution-critical depth of the six playbooks
- `104-sg-end` ✅ closed locally
- `005-sg-ship` ✅ shipped in the operator-authorized consolidation batch

Next step: none.
