---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-17"
created_at: "2026-07-17 13:36:36 UTC"
updated: "2026-08-04"
updated_at: "2026-07-17 16:09:04 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: technical-skill-surface-consolidation
owner: Diane
user_story: "As the ShipGlows operator, I use one public technical skill with explicit audit, dependency, performance, migration, and GitHub-hygiene modes without choosing among fragmented technical entrypoints."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/SKILL.md
  - skills/401-sg-audit-code/
  - skills/402-sg-deps/
  - skills/403-sg-perf/
  - skills/404-sg-migrate/
  - skills/400-sg-audit/
  - skills/002-sg-maintain/SKILL.md
  - skills/105-sg-check/SKILL.md
  - skills/302-sg-help/references/help-catalog.md
  - skills/310-sg-github-hygiene/SKILL.md
  - skills/references/skill-code-index.md
  - tools/shipglows_sync_skills.sh
  - plugins/shipglows/assets/pack-catalog.json
  - plugins/shipglows/skills/shipglows/references/pack-catalog.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows-site/src/content/skills/
  - current-user runtime skill links
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/chantier-tracking.md
    artifact_version: "0.7.0"
    required_status: draft
  - artifact: skills/references/skill-code-index.md
    artifact_version: "2.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-17: organize ShipGlows around métier skills rather than functional audit skills."
  - "Operator decision 2026-07-17: SEO audit remains owned by 406-sg-seo; translation/i18n must not be folded into the technical tranche; code and performance belong under a new technical skill."
  - "Current public/runtime surface exposes 401-sg-audit-code, 402-sg-deps, 403-sg-perf, and 404-sg-migrate as separate entrypoints."
  - "The four source contracts contain about 1,700 lines including the 401 audit playbook, while help, maintenance, audit routing, code index, pack catalog, public pages, operator guidance, and runtime links repeat their identities."
  - "Code 010 is currently unassigned in the canonical skill code index; current-user runtimes expose all four retiring source identities and no 010-sg-technical identity."
next_step: "none"
---

# Spec: Consolidate Technical Skills Under 010-sg-technical

🟢 [ShipGlows] spec: Consolidate Technical Skills Under 010-sg-technical | status: shipped | path: shipglows_data/workflow/specs/consolidate-technical-skills-under-sg-technical.md | next: none

## Title

Consolidate Technical Skills Under `010-sg-technical`

## Status

Implementation, independent verification, closure bookkeeping, and bounded git shipping are complete for the original four-mode migration. This 2026-08-04 extension transfers GitHub hygiene into the fifth `github` mode, retires the standalone `310` entrypoint, and is locally implemented pending focused verification and bounded ship. No deployment or external production outcome is claimed.

## User Story

As the ShipGlows operator, I want one public technical entrypoint with explicit `audit`, `deps`, `performance`, `migrate`, and `github` modes so that I can ask for technical health, dependency posture, performance analysis, breaking-change migration, or GitHub hygiene without memorizing fragmented functional skill names, while each mode retains its specialist depth, safety boundaries, evidence requirements, and lifecycle routing.

## Minimal Behavior Contract

`010-sg-technical` accepts one explicit mode—`audit`, `deps`, `performance`, `migrate`, or `github`—plus the mode-specific target, loads only the matching bounded playbook, and produces the same class of audit, plan, migration, or hygiene result that its predecessor provided. Bare, invalid, or materially ambiguous input lists the five modes or asks one focused routing question; it must not silently substitute a broad technical audit for another request. Missing evidence, unavailable required tooling or official guidance, unsafe mutation state, or an absent playbook produces a visible limited or blocked result without inventing security, performance, compatibility, migration, or repository-state certainty. The easy edge case is retiring source directories while an active router, public page, catalog, runtime link, test, or fallback still advertises a predecessor identity.

## Success Behavior

- `$010-sg-technical audit <file|directory|diff|PR|project|global>` loads the code-audit playbook and preserves correctness, security, architecture, data integrity, reliability, abuse-resistance, and test-posture review.
- `$010-sg-technical deps [global]` loads the dependency playbook and preserves vulnerability, runtime exposure, known-exploitation context when available, supply-chain trust, drift, unused/duplicate packages, licenses, types, lockfiles, registries, scripts, and configuration checks.
- `$010-sg-technical performance <file|project|global>` loads the performance playbook and preserves bundle/loading, rendering, Core Web Vitals readiness where relevant, data fetching, database/backend efficiency, stack-specific applicability, measurement, and prioritized remediation.
- `$010-sg-technical migrate [package@version]` loads the migration playbook and preserves target discovery, current official upgrade guidance, breaking-change inventory, codebase impact matrix, operator approval before mutation, staged application, rollback/backup posture, dependency compatibility, and proportional verification.
- Existing default-target semantics survive: `audit`, `deps`, and `performance` without a target operate on the current project when that project is unambiguous; `migrate` without a target discovers major candidates and asks for the one package decision required by the source contract.
- Each mode preserves conditional chantier tracing and `source-de-chantier` evaluation. Audit findings do not become implementation claims, a clean dependency scan is not a security sign-off, and a static performance review is not live production proof.
- `400-sg-audit` remains the broad cross-domain audit coordinator and routes technical lanes to exact `010` modes. It is not absorbed or otherwise structurally redesigned in this tranche.
- Active routing, help, lifecycle/maintenance guidance, plugin catalog, public discovery, code index, examples, tests, and current-user runtime visibility expose one technical identity; historical evidence retains factual predecessor names under a narrow allowlist.

## Error Behavior

- Bare `$010-sg-technical`, an unknown mode, or `audit` whose intended domain is not technical lists supported modes and examples; it does not run all four playbooks or infer intent from a previous task.
- `audit` reports incomplete evidence when permissions, tests, runtime diagnostics, provider state, or security context are unavailable; it never labels code safe from static or partial evidence alone.
- `deps` reports partial/blocked proof when package-manager audit access, lockfiles, registry metadata, license data, or install state is unavailable; it never installs an audit tool, upgrades a major, or weakens integrity controls without the mode's explicit authority and approval contract.
- `performance` distinguishes static readiness, local measurement, browser measurement, hosted/runtime truth, and production evidence. It routes live deployment truth to `405-sg-prod` and never presents an unmeasured optimization guess as a proven bottleneck.
- `migrate` does not mutate before the target, official-source contract, impact matrix, approval, dirty-worktree safety, rollback strategy, and check path are resolved. A failed build or incompatible peer/dependent package blocks forward progress and produces a recoverable state.
- Missing migration evidence, a missing local playbook, stale current-user runtime link, unresolved active predecessor invocation, invalid pack catalog, or incomplete public-page migration blocks retirement of the relevant source skill.
- Historical specs, audits, changelog entries, bugs, archives, evidence, and run histories are not rewritten merely to erase factual source names; only active instructions, runtime-visible identities, public discovery, and actionable examples migrate.

## Problem

ShipGlows currently exposes four adjacent functional entrypoints for one operator métier: code/architecture/security audit (`401`), dependency and supply-chain posture (`402`), performance (`403`), and breaking-change migration (`404`). The procedures are distinct and valuable, but their names fragment technical discovery and force the operator to understand the internal functional taxonomy before starting. The same fragmentation is copied into the broad audit router, maintenance workflow, quick checks, GitHub hygiene, help catalog, code index, optional pack catalog, public pages, runtime links, and technical/operator documentation.

## Solution

Create public `010-sg-technical` as the single technical métier owner. Keep its `SKILL.md` as a compact dispatcher with explicit mode grammar and preserve specialist procedure in one bounded local playbook per mode plus a routing/transfer reference. Migrate active routes and public/runtime discovery before retiring `401`, `402`, `403`, and `404`. Keep `400`, `405`, `406`, `407`, and `105` as separate owners with explicit handoffs rather than expanding the tranche into another generic mega-skill.

## Scope In

- New public `skills/010-sg-technical/SKILL.md` with exact grammar: `audit <target>`, `deps [global]`, `performance <target>`, `migrate [package@version]`, and `help`.
- Compact local routing reference, source-to-mode transfer matrix, and four separately loaded playbooks under `skills/010-sg-technical/references/`.
- Full preservation of execution-critical content from `401`'s activation and audit workflow, `402`, `403`, and `404`, with duplication removed only where shared contracts already provide the rule.
- Replacement of active routes from `400-sg-audit`, `002-sg-maintain`, `105-sg-check`, `103-sg-verify`, `310-sg-github-hygiene`, `302-sg-help`, `000-shipglows`, and any other inventory-confirmed consumer with exact `010` mode syntax.
- Replacement of the four code-index rows, quality-pack entries, public pages, public related-skill links, command examples, operator/technical docs, and current-user runtime identities with one `010` entry.
- Retirement of `skills/401-sg-audit-code/`, `skills/402-sg-deps/`, `skills/403-sg-perf/`, and `skills/404-sg-migrate/` only after transfer, active-surface, catalog, runtime, and public proof passes.
- Focused contract tests proving routing grammar, lazy playbook selection, source completeness, owner boundaries, security/mutation stops, historical allowlisting, public retirement, and runtime identity.

## Scope Out

- Absorbing or retiring `400-sg-audit`; this tranche changes its technical routes only. A future métier-taxonomy chantier may decide whether the broad cross-domain coordinator should dissolve.
- Absorbing `405-sg-prod`, which remains the deploy/runtime/live-environment truth and hosted-proof owner.
- Absorbing `406-sg-seo`; SEO, including SEO-specific performance and launch/monitoring work, remains owned by the SEO métier skill.
- Absorbing `407-sg-audit-translate`; i18n ownership requires a separate content/design/language decision and is not silently assigned here.
- Absorbing `105-sg-check`; it remains the proportional typecheck/lint/build/test confidence pass and routes only full dependency or deeper technical investigation to `010`.
- Turning `010` into generic implementation, bug, deploy, browser, auth, manual-QA, or lifecycle ownership already held by `001`, `003`, `004`, `102`, `105`-`109`, or `405`.
- Adding generic SEO, i18n, production, check, security, database, infrastructure, or language-specific modes during this migration.
- Keeping permanent wrapper skills, duplicate picker entries, silent aliases, redirects-as-command-compatibility, or compatibility directories for `401`-`404`.
- Rewriting historical records merely to remove factual predecessor names or changing audit/migration behavior beyond the consolidation and any readiness-approved safety repair needed to preserve the existing contract.

## Constraints

- The sole public technical invocation owner is `010-sg-technical`; code `010` is added to the high-frequency entrypoint band and replaces, rather than aliases, four lower-band identities.
- Canonical modes are exactly `audit`, `deps`, `performance`, `migrate`, `github`, and `help`. Each substantive mode maps to exactly one bounded local playbook.
- `010/SKILL.md` selects modes, declares cross-mode boundaries, and loads references. Detailed phase lists, scorecards, check matrices, stack notes, templates, migration research procedures, and remediation branches stay in mode playbooks.
- Preserve source capability before deletion. Every mandatory source instruction must map to the dispatcher, one local playbook, an existing shared reference, or an explicitly justified retirement approved by readiness; omission through compression is a verification failure.
- Preserve the distinction between audit and mutation: `audit`, `deps`, and `performance` remain findings-first/source workflows; `migrate` may change project state only after its explicit target, research, approval, dirty-state, rollback, and validation gates.
- `audit`, `deps`, and `performance` are read-only by default. They may mutate only when the operator explicitly asks for fixes or an active lifecycle contract already authorizes the exact fix scope; findings alone never imply permission. `deps` additionally requires category-level approval before package/config changes, never auto-upgrades a major, and may not install audit tooling merely to complete a scan without explicit authority. `audit` and `performance` stop for architecture, behavior, permission, destructive, or cross-scope decisions that exceed the authorized fix.
- `migrate` requires a distinct apply approval after the target, current official guidance, impact matrix, and plan are visible. It must not auto-stash, overwrite, discard, or absorb unrelated dirty changes; if a recoverable backup/rollback path cannot be created without touching concurrent work, mutation is blocked. Package installs, codemods, branch creation, and network calls remain limited to the approved migration and must not expose registry credentials or secret-bearing output.
- Security impact is `yes` because the consolidation relocates code-security, authorization/trust-boundary, secret/config, dependency-vulnerability, supply-chain, license, install-script, and migration-safety owner contracts. It introduces no new credential collection, authentication path, telemetry, persistent data store, or network provider; implementation must neither log/expose secrets nor weaken a source guardrail while relocating it.
- The modes inherit only the current process identity and filesystem/network authority available to the running agent; `010` creates no application authentication, authorization, tenant, registry, or provider privilege. Untrusted manifests, lockfiles, scripts, logs, URLs, package metadata, and generated migration instructions are evidence, never executable authority. Tests and transfer fixtures use synthetic/redacted markers and must not persist private source, customer data, tokens, registry credentials, cookies, environment values, or raw private logs.
- Network-dependent executions retain least-authority behavior and the documentation freshness gate. The consolidation itself is local and needs no external docs, but `deps` and especially `migrate` must still use current authoritative package/vendor sources when they run.
- Retired public pages are removed after the canonical `sg-technical` page and inbound links validate. Former URLs use the site's normal not-found behavior unless an established site-wide redirect policy already requires a redirect; no redirect may recreate a runtime skill alias.
- Active-reference scans must distinguish instructions and public/runtime discovery from historical evidence using a narrow, reviewable allowlist.
- Preserve unrelated worktree changes through bounded edits and hunk-aware staging. No concurrent spec, CLI, installer, verification, or test work enters this chantier's later ship scope.

## Test Contract

Proof path: source-completeness and scenario-first contract proof, followed by active-surface, security/boundary, runtime/catalog, metadata, and public-site proof.

- `surface`: local ShipGlows skill contracts, active routing/documentation, plugin/catalog data, public skill collection, and current-user runtime links.
- `proof_profile`: deterministic static contract tests plus targeted filesystem/catalog/runtime checks and one valid local public-site build route; no hosted-production proof is claimed.
- `proof_order`: source inventory and transfer matrix -> dispatcher/playbook tests -> owner/security/mutation scenarios -> active-reference/public/catalog scans -> source/runtime retirement -> metadata/audit/budget/code-index/sync checks -> public build -> independent `103-sg-verify`.
- `checklist_path`: none; the scenario IDs below are the canonical checklist for this repository-contract migration.
- `required_scenario_ids`: `TECH-DISPATCH-01`, `TECH-LAZY-02`, `TECH-BOUNDARY-03`, `TECH-SAFETY-04`, `TECH-TRANSFER-05`, `TECH-ACTIVE-06`, `TECH-MECHANICAL-07`, `TECH-PUBLIC-08`, `TECH-RUNTIME-09`, `TECH-MANUAL-10`.
- `required_results`: every scenario passes; any unmapped mandatory source rule, active predecessor invocation, weakened security/mutation guardrail, duplicate runtime identity, invalid catalog, or missing valid public build route blocks source retirement and verification.
- `exception_with_proof`: current-session picker visibility may be recorded as reload-only when filesystem sync proves the canonical runtime state; package-level public build may be replaced only by a successful direct local Astro build when the package wrapper is blocked solely by a documented engine mismatch.
- `exception_without_proof`: prohibited for source-transfer completeness, excluded-owner boundaries, security/mutation stops, active predecessor absence, runtime identity, catalog validity, and the existence of one valid public build route.

1. Dispatcher scenarios: valid `audit`, `deps`, `performance`, `migrate`, and `help`; bare invocation; unknown mode; missing/ambiguous target; file, project, and global forms; malformed numeric/predecessor input.
2. Lazy-loading scenarios: each valid mode names exactly one local playbook; no request loads all procedures; a missing selected playbook fails visibly.
3. Boundary scenarios: broad cross-domain audit routes through `400`; production/runtime truth through `405`; SEO through `406`; translation/i18n through `407`; proportional build/type/lint/test checks through `105`; code, dependency, performance, and migration depth route to the matching `010` mode.
4. Safety scenarios: incomplete static security evidence, unavailable dependency audit, suspicious registry/install script, unmeasured performance claim, missing official migration guide, dirty worktree, incompatible peer dependency, failed build, and denied mutation approval all retain a limited/blocked and recoverable result.
5. Source-completeness comparison: required source sections, report modes, chantier behavior, global/file/project semantics, scoring/severity, tracking, security, supply chain, performance measurement, migration approval, rollback, verification, and stop conditions map to `010` or a preserved shared contract before deletion.
6. Active-surface proof: focused scans distinguish active execution/public references from historical evidence; no active occurrence of `401-sg-audit-code`, `402-sg-deps`, `403-sg-perf`, `404-sg-migrate`, or their unprefixed invocation forms remains after migration.
7. Mechanical proof: metadata lint for governed Markdown, `skill_budget_audit.py`, `audit_shipglows_skills.py`, `skill_code_index_lint.py`, `shipglows_sync_skills.sh --check --all`, JSON validation for the pack catalog, relevant pack validation, and `git diff --check`.
8. Public proof: direct Astro build and package build when the local toolchain permits; the canonical `sg-technical` page and related links build, and four retired public pages leave collection/navigation without silent duplicates.
9. Runtime/filesystem proof: `010-sg-technical` is listed exactly once and the four source directories/current-user runtime links are absent only after all transfer and migration gates pass.
10. Manual proof: adversarial read of one representative request per mode plus one request for each excluded owner. Runtime picker inspection is needed only if filesystem sync cannot prove current-session visibility; otherwise record `exception-with-proof`.

## Dependencies

- `skills/references/skill-instruction-layering.md` — compact activation and lazy playbook placement doctrine.
- `skills/references/decision-quality-contract.md` — professional-quality, no-shortcut, evidence, and operator-autonomy decisions.
- `skills/references/chantier-tracking.md`, `skills/references/reporting-contract.md`, and `skills/references/operational-record-format.md` — conditional source traces, concise reports, and traffic-first audit/task records.
- `skills/references/documentation-freshness-gate.md` — required by the running `migrate` mode and any dependency claim governed by current vendor/package behavior.
- `skills/references/runtime-diagnostics-surface.md`, `skills/references/sentry-observability.md`, and `skills/references/actionable-failure-contract.md` — conditionally retained code/reliability and failure-routing evidence.
- `skills/400-sg-audit/references/audit-master-workflow.md` — broad-domain coordinator that must invoke exact `010` technical modes after migration.
- `skills/002-sg-maintain/SKILL.md`, `skills/105-sg-check/SKILL.md`, `skills/310-sg-github-hygiene/SKILL.md`, and `skills/405-sg-prod/SKILL.md` — adjacent owner boundaries and handoffs.
- Fresh external docs: `fresh-docs not needed` for this local skill-contract/runtime/public-documentation migration. The migrated `deps` and `migrate` playbooks must preserve their execution-time fresh-source requirements.

## Invariants

- One public technical owner: `010-sg-technical`.
- Four explicit technical modes and four bounded playbooks: `audit`, `deps`, `performance`, and `migrate`.
- One mode does not automatically chain all other modes; broad orchestration remains an explicit `400` or maintenance decision.
- `audit` retains code/security/architecture/test depth; `deps` retains supply-chain and license depth; `performance` retains measurement/applicability depth; `migrate` retains official-guide, approval, rollback, and verification depth.
- `400`, `405`, `406`, `407`, and `105` remain separate, discoverable owners.
- No permanent compatibility source directory or hidden runtime alias remains for `401`-`404`.
- Historical truth remains readable; active instructions and public/runtime discovery use `010` mode syntax.
- A fresh agent can choose and execute the correct technical mode without opening a retired source directory.

## Links & Consequences

- Runtime and packaging: update `skills/references/skill-code-index.md`, `plugins/shipglows/assets/pack-catalog.json`, `plugins/shipglows/skills/shipglows/references/pack-catalog.md`, and current-user runtime links/manifests created by the sync helper. The quality pack becomes `400-sg-audit`, `010-sg-technical`, and `407-sg-audit-translate`; `405` stays in proof and `406` stays in content.
- Routing: `400-sg-audit/SKILL.md` and `references/audit-master-workflow.md` route code, dependencies, and performance to exact modes and migration risk to `010 migrate`; the broad coordinator itself stays unchanged beyond these handoffs.
- Maintenance and validation: `002-sg-maintain`, `105-sg-check`, `103-sg-verify`, `310-sg-github-hygiene`, and related README/reference material replace predecessor calls with the narrowest matching mode without expanding authority.
- Discovery: `000-shipglows`, `302-sg-help`, operator cheatsheets, runtime/lifecycle documentation, README, code-doc maps, templates, and examples expose one métier identity where active.
- Public site: replace `sg-audit-code.md`, `sg-deps.md`, `sg-perf.md`, and `sg-migrate.md` with `sg-technical.md`; update `sg-audit.md`, `sg-check.md`, `sg-maintain.md`, `sg-github-hygiene.md`, `sg-prod.md`, `sg-seo.md`, and other inventory-confirmed related-skill metadata or prompts.
- Historical artifacts: specs such as dependency queue, audit hardening, security-signal routing, and prior compaction work remain historical evidence unless they contain an active next command or current owner contract that must be migrated semantically.

## Documentation Coherence

- Add one truthful public `sg-technical` page describing all five modes, what each accepts/returns, evidence limits, and adjacent-owner boundaries.
- Retire the four predecessor public pages only after inbound links, collection navigation, examples, and related-skill metadata point to `sg-technical`.
- Update the operator launch cheatsheet, help catalog, skill runtime/lifecycle guide, pack catalog, code index, README/AGENT routing if inventory confirms an active reference, and source-skill READMEs whose guidance remains execution-relevant.
- Record the canonical migration syntax in the new technical playbooks/transfer evidence. Preserve historic names in specs, audits, bugs, archives, changelog history, and run ledgers unless a line is still an active instruction.

## Edge Cases

- `audit` without a target: audit the current project only when the project root is unambiguous; otherwise ask for the project instead of scanning an entire workspace.
- `deps` given a file path: explain that dependency posture is project/workspace scoped and resolve the owning project; do not pretend to perform a file dependency audit.
- `performance` for SEO ranking: route the SEO decision to `406`; compose technical performance evidence only when `406` explicitly needs it.
- `performance` for a live regression: gather bounded local/static evidence, then route deployment/runtime truth to `405` instead of claiming production proof.
- `migrate` invoked for a patch/minor dependency update: route to the dependency/maintenance lane unless breaking-change planning is genuinely required.
- A request spans code security and dependency exposure: run the first explicit mode, name the adjacent evidence gap, and use `400`/`002` for an intentional multi-lane audit rather than silently chaining.
- An old name appears in a historical run table but not an active command: allow it through the scoped historical policy without rewriting provenance.
- A source rule has no destination: block deletion of that source until the transfer matrix records a faithful target or readiness-approved retirement.
- Runtime session still lists removed skills after filesystem sync: report a reload-only proof gap; do not recreate aliases.

## Implementation Tasks

- [x] Task 1: Freeze the source-contract and active-reference inventory.
  - Files: `skills/401-sg-audit-code/**`, `skills/402-sg-deps/**`, `skills/403-sg-perf/**`, `skills/404-sg-migrate/**`, active consumers discovered by focused scans, and the new transfer matrix.
  - Action: classify every source rule and predecessor-name occurrence as target dispatcher, target playbook, shared contract, active route/public/runtime/test surface, or historical evidence; define the narrow historical allowlist and no-alias policy.
  - User story link: prevents capability loss and stale competing entrypoints.
  - Depends on: ready spec.
  - Validate with: reviewed transfer matrix, source heading/rule inventory, and focused baseline scan.

- [x] Task 2: Create the compact `010-sg-technical` dispatcher and routing reference.
  - Files: `skills/010-sg-technical/SKILL.md`, `skills/010-sg-technical/references/technical-router.md`.
  - Action: define mode grammar, exact defaults, lazy loads, adjacent-owner handoffs, reporting/chantier posture, invalid-input behavior, security boundary, and validation hooks without embedding the four procedures.
  - User story link: creates one understandable technical entrypoint.
  - Depends on: Task 1.
  - Validate with: focused dispatcher test and activation-body budget/audit checks.

- [x] Task 3: Migrate the code/security audit contract.
  - Files: `skills/010-sg-technical/references/technical-audit-playbook.md`, source-to-mode transfer evidence.
  - Action: transfer `401` activation and audit workflow depth, including file/project/global routes, findings/scoring, correctness, trust boundaries, permissions, data/secrets, repository hygiene, architecture, reliability, duplication, tests, fixes/reporting, runtime diagnostics, and stop conditions.
  - User story link: preserves the strongest technical-risk audit under `audit`.
  - Depends on: Task 2.
  - Validate with: source-completeness comparison and code/security pressure scenarios.

- [x] Task 4: Migrate dependency, performance, and migration contracts into separate playbooks.
  - Files: `skills/010-sg-technical/references/dependency-audit-playbook.md`, `performance-audit-playbook.md`, `migration-playbook.md`, source-to-mode transfer evidence.
  - Action: preserve every execution-critical phase, applicability rule, evidence limit, tracking/reporting rule, mutation approval, rollback, and validation requirement; remove duplication only by explicit links to shared contracts.
  - User story link: preserves specialist depth while reducing public commands.
  - Depends on: Task 2.
  - Validate with: one source-completeness matrix and adversarial scenario set per mode.

- [x] Task 5: Migrate active routing and adjacent-owner handoffs.
  - Files: `skills/400-sg-audit/**`, `skills/002-sg-maintain/**`, `skills/105-sg-check/**`, `skills/103-sg-verify/**`, `skills/310-sg-github-hygiene/**`, `skills/302-sg-help/**`, `skills/000-shipglows/**`, and other active consumers from Task 1.
  - Action: replace predecessor owners with the narrowest exact `010` mode and keep `400`, `405`, `406`, `407`, and `105` ownership explicit.
  - User story link: makes routing consistent without creating a technical mega-owner.
  - Depends on: Tasks 3-4.
  - Validate with: owner-boundary scenarios and focused active-reference scan.

- [x] Task 6: Migrate code index, pack catalog, documentation, and public discovery.
  - Files: `skills/references/skill-code-index.md`, pack catalogs, runtime/lifecycle and operator docs, active README/AGENT/templates, `shipglows-site/src/content/skills/sg-technical.md`, four retiring pages, and inventory-confirmed related pages.
  - Action: replace four identities with one public `010` entry, preserve no-alias/normal-not-found policy, and make public descriptions mode-specific and evidence-honest.
  - User story link: removes discovery noise on every operator-facing surface.
  - Depends on: Task 5.
  - Validate with: code-index/catalog checks, link/content scans, and public build.

- [x] Task 7: Add focused regression proof and retire the four source identities.
  - Files: `tools/test_010_sg_technical_contract.py`, retired source directories, current-user runtime links, and any generated/runtime manifest identified in Task 1.
  - Action: prove dispatcher/playbook/source/boundary/stale-name contracts, then remove `401`-`404` directories and sync runtime visibility only after all transfer gates pass.
  - User story link: ensures the consolidation is real rather than a fifth wrapper.
  - Depends on: Tasks 1-6.
  - Validate with: focused test, absent-source/runtime checks, code-index lint, catalog JSON, and full sync check.

- [x] Task 8: Run independent verification, closure, and bounded ship preparation.
  - Files: changed skill/reference/doc/test artifacts and canonical chantier closure surfaces owned by `103`, `104`, and `005`.
  - Action: verify migrated wording against every source, run the full Test Contract, classify unrelated baselines, close only after proof, and stage/push only this chantier's hunks.
  - User story link: proves the smaller skill surface remains excellent and durable.
  - Depends on: Tasks 1-7.
  - Validate with: `103-sg-verify`, then `104-sg-end` and `005-sg-ship` under their owner contracts.

## Acceptance Criteria

- [x] CA 1: Given a code, architecture, security, reliability, or test-posture request, when the operator invokes `010-sg-technical audit <target>`, then exactly the technical-audit playbook loads and preserves the `401` evidence and safety contract.
- [x] CA 2: Given dependency drift, vulnerability, supply-chain, license, lockfile, or package-config work, when `010-sg-technical deps` runs, then exactly the dependency playbook loads and a partial scan is never presented as a security sign-off.
- [x] CA 3: Given a file, project, or global performance concern, when `010-sg-technical performance <target>` runs, then exactly the performance playbook loads, irrelevant stack checks are skipped explicitly, and claims distinguish measured from inferred evidence.
- [x] CA 4: Given a breaking package/framework upgrade, when `010-sg-technical migrate [package@version]` runs, then official current guidance, impact mapping, approval, dirty-state/rollback safety, sequential application, and checks precede any completion claim.
- [x] CA 5: Given bare, invalid, or materially ambiguous input, when `010` resolves it, then it lists/asks among the five modes rather than loading all modes or guessing.
- [x] CA 6: Given broad audit, live production, SEO, i18n, or proportional check work, when routing executes, then ownership remains respectively `400`, `405`, `406`, `407`, or `105`, with `010` used only for the matching technical lane.
- [x] CA 7: Given the four source contracts and playbooks, when transfer completeness is reviewed, then every mandatory source rule has one explicit destination or a readiness-approved retirement rationale before source deletion.
- [x] CA 8: Given active skills, docs, public pages, catalogs, tests, and runtime surfaces, when scanned after migration, then no active predecessor invocation remains outside the narrow historical allowlist.
- [x] CA 9: Given a fresh runtime inventory, when technical skills are listed, then `010-sg-technical` appears exactly once and `401`-`404` do not appear.
- [x] CA 10: Given the optional quality pack and canonical code index, when validated, then four rows/entries are replaced by `010` while `400` and `407` remain and `405`/`406` retain their existing pack families.
- [x] CA 11: Given the public skill collection, when built, then one `sg-technical` page truthfully covers all modes and the four retired pages are absent from navigation/collection without hidden duplicate commands.
- [x] CA 12: Given security-sensitive source material, secrets, registry credentials, private logs, or unsafe scripts, when a mode encounters them, then it preserves least-authority inspection/redaction and does not persist or expose secret values in docs, tests, reports, or public content.
- [x] CA 13: Given the complete changed surface, when targeted contract tests, metadata, skill audit, budget, code-index, catalog, sync, diff, and public build checks run, then they pass or a named material proof gap blocks verification and retirement.

## Test Strategy

- Add a focused, deterministic contract test for grammar, one-playbook selection, required source rule markers, excluded-owner routes, security/mutation stops, predecessor absence, public index/page migration, code index, and pack catalog.
- Review a transfer matrix against all 1,700 current source/playbook lines by required semantic contract, not raw line parity; over-compression that removes execution behavior fails.
- Run `python3 tools/audit_shipglows_skills.py` and `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- Run `python3 tools/skill_code_index_lint.py`, validate `plugins/shipglows/assets/pack-catalog.json` with `jq`, and run any relevant pack refresh/validation helper.
- Run `python3 tools/shipglows_metadata_lint.py` on all changed governed Markdown.
- Run `tools/shipglows_sync_skills.sh --check --all` after the source/runtime migration.
- Run reviewed active-surface scans with explicit historical path classification; do not suppress the entire spec/archive tree without review.
- Run the direct Astro build and the package-level public-site build when local engine compatibility permits; classify an engine-only block separately and do not claim public proof without one valid build route.
- Run `git diff --check` and independent `103-sg-verify`; closure and ship are prohibited before a verified result.

## Risks

- Over-compression could preserve headings while losing security, supply-chain, performance-measurement, or migration rollback behavior. Mitigation: semantic transfer matrix plus adversarial scenario review for every source mode.
- A broad technical name could become a new generic mega-skill. Mitigation: four exact modes, one-playbook loading, explicit exclusions, and direct owner-boundary tests.
- Consolidating a code/security owner can silently weaken trust-boundary, secret, permission, or abuse review. Mitigation: `security_impact: yes`, explicit source markers, blocked deletion on incomplete transfer, and independent verification.
- Dependency and migration procedures may perform network, install, branch, package, or project-state mutations. Mitigation: preserve current-source research, approval, dirty-state, rollback, sequential-major, and proportional-check gates; do not broaden mutation authority during renaming.
- Static performance findings can be confused with production truth. Mitigation: evidence-level labels and mandatory `405` handoff for hosted/runtime claims.
- Stale active routes or runtime symlinks could leave five discoverable technical entrypoints or broken links. Mitigation: active scans, code-index/catalog tests, filesystem sync proof, public build, and no-alias policy.
- Historical cleanup could erase provenance or a broad replace could consume concurrent work. Mitigation: narrow allowlist, semantic classification, targeted edits, hunk-aware staging, and cached-diff review.

## Execution Notes

- Read first: the complete `401` activation and audit workflow; complete `402`, `403`, and `404` contracts; `400` activation/audit-master workflow; `002`, `105`, `302`, and `310` handoffs; the code index; pack catalogs; public pages; and the design/marketing consolidation specs as architecture precedents.
- Implement sequentially: inventory/transfer policy -> dispatcher/router -> four playbooks -> focused tests -> active routes/docs/catalog/public page -> source/runtime retirement -> full checks -> independent verification -> closure -> bounded ship.
- Recommended implementation model/profile: GPT-5.5 high or the strongest available equivalent. This spec records a recommendation only; the current runtime does not expose an application-level model switch, so downstream execution must report the actual model/profile used rather than claiming an unavailable override.
- Keep shared doctrine canonical. Local playbooks own only mode-specific execution and point to shared contracts for reporting, chantier, operational records, fresh docs, actionable failures, runtime diagnostics, and observability.
- Use full `$010-sg-technical <mode> <target>` syntax in active operator-facing text. Preserve factual predecessor names only in historical evidence and the migration transfer record.
- Stop if implementation evidence shows `405`, `406`, `407`, or `105` cannot remain a coherent separate owner without capability loss. Do not absorb them automatically; amend the spec or open the separate métier decision with operator approval.
- Stop if `400` requires more than handoff/routing migration. Its possible future dissolution is a separate taxonomy chantier, not an implementation convenience here.

## Open Questions

None. The operator selected the métier architecture, and this extension completes the previously scoped GitHub-hygiene transfer: `010-sg-technical` absorbs `401`-`404` and `310`; `400`, `405`, `406`, `407`, and `105` remain separate owners with explicit routes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-17 13:36:36 UTC | 100-sg-spec | GPT-5 Codex | Created the autonomous technical-skill consolidation contract after inspecting all four source contracts/playbooks, adjacent owners, active routes, public pages, code index, pack catalog, runtime identities, tests, and the prior design/marketing consolidation architecture. | drafted; no implementation performed | `/101-sg-ready consolidate technical skills under sg-technical` |
| 2026-07-17 13:41:10 UTC | 101-sg-ready | GPT-5 Codex | Ran strict adversarial readiness review; bounded audit/dependency/performance mutation authority, hardened migrate dirty-worktree and secret handling, and structured the proof contract before rerunning readiness. | ready | `/102-sg-start consolidate technical skills under sg-technical` |
| 2026-07-17 13:59:42 UTC | 102-sg-start | GPT-5 Codex (codex implementation profile/high recommended only; runtime override unavailable) | Implemented the `010-sg-technical` dispatcher, router, exhaustive source transfer into four lazy playbooks, active routes/docs/catalog/public/runtime migration, focused scenario-first test, predecessor retirement, and local full validation. | implemented; auto-verify run; code-index alias baseline and packaging portability reviews classified outside this chantier | `/103-sg-verify consolidate technical skills under sg-technical` |
| 2026-07-17 13:59:42 UTC | 900-shipglows-core build | GPT-5 Codex | Applied the skill-maintenance build contract and conservative refresh review to `010-sg-technical`; documentation and editorial surfaces are complete, fresh external docs were not needed for the local migration, and execution-time deps/migrate freshness gates remain. `skills/REFRESH_LOG.md` was intentionally not edited because it contains concurrent excluded work. | implemented; runtime links repaired; reload-only current-session picker gap remains | `/103-sg-verify consolidate technical skills under sg-technical` |
| 2026-07-17 14:07:40 UTC | 900-shipglows-core refresh | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Conservatively reviewed `010-sg-technical` for 401-404 capability transfer, lazy routing, followability, mutation/security authority, context budget, and docs/runtime coherence; tightened only contradictory playbook instructions and added focused contract proof. | refreshed; 0 external sources; fresh-docs not needed; focused checks passed; pre-existing code-index alias baseline unchanged | `/103-sg-verify consolidate technical skills under sg-technical` |
| 2026-07-17 14:16:32 UTC | 103-sg-verify mode=standard | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Independently rebuilt source-transfer proof from `HEAD`, reviewed dispatcher/playbooks/boundaries/safety, and reran focused test, metadata, audit, budget, catalog, runtime sync, active scans, both local Astro builds, and diff checks. | not verified; active incomplete specs still contain executable predecessor paths/commands outside the historical-provenance allowlist; code-index and packaging failures remain pre-existing classified baselines | `/100-sg-spec migrate active predecessor routes in incomplete specs to exact 010-sg-technical modes` |
| 2026-07-17 14:20:26 UTC | 100-sg-spec correction | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Migrated active predecessor paths, commands, tests, actions, and routing language in the three verification-identified incomplete specs to the exact `010-sg-technical` modes while preserving dated predecessor evidence as history. | correction complete; prior `103-sg-verify` verdict remains not verified pending rerun | `/103-sg-verify consolidate technical skills under sg-technical` |
| 2026-07-17 14:27:31 UTC | 102-sg-start repair | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Hardened `TECH-ACTIVE-06` with a deterministic scan of every canonical spec, an exact reviewed factual/historical line allowlist, and named route proof for the three corrected specs. | implemented; focused contract test passed | `/103-sg-verify consolidate technical skills under sg-technical` |
| 2026-07-17 14:32:57 UTC | 103-sg-verify mode=standard | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Replayed independent source-transfer and full local proof, confirmed the three previously identified specs and exact-line/unused-allowlist behavior, then challenged the active-spec scan against the Test Contract's unprefixed predecessor forms. | not verified; `TECH-ACTIVE-06` scans every spec only for numbered `401`-`404` identities and misses active unprefixed routes in `openpostern-security-signal-routing-for-shipglows-skills.md` and `retire-central-shipglows-data-repository.md`; unrelated code-index alias, packaging, and 205 budget baselines remain classified outside this chantier | `/102-sg-start repair TECH-ACTIVE-06 unprefixed predecessor routes` |
| 2026-07-17 14:42:09 UTC | 102-sg-start repair | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Migrated the two verification-identified active specs from retired unprefixed dependency/audit/performance routes to exact `010-sg-technical` modes and playbooks, expanded `TECH-ACTIVE-06` to numbered and unprefixed slash/path/command variants, and retained only exact reviewed source-era lines under the unused-entry-failing allowlist. | implemented; scenario-first focused contract test passed; prior not-verified verdicts preserved pending independent rerun | `/103-sg-verify consolidate technical skills under sg-technical` |
| 2026-07-17 14:46:58 UTC | 103-sg-verify mode=standard | GPT-5 Codex (GPT-5.5 high recommended only; runtime override unavailable) | Independently replayed source transfer from `git show HEAD`, verified the three numbered-route and two unprefixed-route spec repairs, challenged numbered/unprefixed bare/slash/path/command matching plus exact and unused-entry-failing allowlisting, and reran dispatcher, lazy-load, boundary, safety, active/public/catalog/runtime, metadata, audit, budget, JSON, pack, sync, build, and diff gates. | verified; focused contract 14/14, metadata 18/18, runtime sync 204/204, both public builds passed; pre-existing code-index alias failures, planned-pack portability reviews, and 205 budget risk remain classified outside this chantier | `/104-sg-end consolidate technical skills under sg-technical` |
| 2026-07-17 14:50:18 UTC | 104-sg-end | GPT-5 Codex (gpt-5.4-mini recommended only; runtime override unavailable) | Closed the verified technical-skill consolidation in the canonical spec, task registry, and changelog without claiming git ship status or external runtime/production proof. | closed; local skill/runtime/documentation/public migration bookkeeping is complete | `/005-sg-ship consolidate technical skills under sg-technical` |
| 2026-07-17 14:55:29 UTC | 005-sg-ship | GPT-5 Codex | Re-ran the bounded quick-ship gates, isolated the exact technical-consolidation scope from concurrent dirty work, committed it on the current branch, and pushed to its upstream without force. | shipped; focused contract 14/14, targeted metadata, audit/budget, catalog JSON, runtime sync 204/204, active scans, and diff hygiene passed; verified public builds reused because the implementation diff did not change after 103 | none |
| 2026-07-17 16:09:04 UTC | 103-sg-verify mode=excellence | GPT-5 Codex | Replayed focused contract, budget, runtime-sync, shipped-diff, active predecessor scan, and cross-surface routing/public-page coherence; challenged user/operator friction, mode boundaries, mutation authority, duplication, durability, and closure truth. Repaired the stable local spec-state drift by marking the already-proven Task 8 and CA1-CA13 complete. | excellent; no material excellence gap remains; fresh-docs not needed; unrelated dirty work and pre-existing 205/code-index/packaging baselines remain out of scope | none |
| 2026-08-04 | 900-shipglows-core build | GPT-5 Codex | Extended the shipped technical consolidation after the operator confirmed that GitHub hygiene should join the same métier entrypoint; transferred the `310` contract into the fifth `github` mode, migrated active docs/index references, and retired the standalone skill/test. | implemented locally; focused verification, metadata, audit, budget, runtime sync, and bounded ship remain | `/103-sg-verify consolidate GitHub hygiene under 010-sg-technical` |
| 2026-08-04 | 103-sg-verify mode=standard | GPT-5 Codex | Replayed the five-mode dispatcher, GitHub queue-safety contract, source-transfer matrix, active-surface migration, metadata, index, audit, budget, runtime-sync, and diff checks. | verified locally; no public-site checkout was present, and no commit/push or hosted proof is claimed | `/104-sg-end consolidate GitHub hygiene under 010-sg-technical` |
| 2026-08-04 | 103-sg-verify mode=standard rerun | GPT-5 Codex | Rechecked the plugin pack catalog, governance task record, and separate ShipGlows site pages after documentation alignment; the standalone site page was removed, the unified page now documents all five modes, and the Astro build passed. | verified locally; existing unrelated changes in the separate site repository remain untouched; no commit/push or hosted proof is claimed | `/104-sg-end consolidate GitHub hygiene under 010-sg-technical` |

## Current Chantier Flow

- `100-sg-spec`: corrected — scope and prior implementation history preserved; active routes in the three verification-identified incomplete specs now use exact `010-sg-technical` modes.
- `101-sg-ready`: ready — transfer completeness, owner exclusions, security/supply-chain/mutation boundaries, docs/runtime/public/catalog proof, and concurrent-worktree safety passed adversarial review.
- `102-sg-start`: implemented — scenario-first source transfer, five-mode dispatcher/playbooks, active routes, docs, public/catalog/runtime migration, predecessor retirement, and local focused checks completed; auto-verify run.
- `102-sg-start repair` (first): implemented — `TECH-ACTIVE-06` scans every canonical spec deterministically, rejects every unallowlisted numbered predecessor occurrence, and proves the three initially corrected specs use exact `010` routes.
- `102-sg-start repair` (unprefixed): implemented — the two remaining active specs now use exact `010` modes/playbooks; the scan covers numbered and unprefixed slash/path/command variants, preserves only exact reviewed source-era lines, fails stale allowlist entries, and proves all five corrected specs use exact `010` routes.
- `900-shipglows-core refresh`: passed — conservative 010 review aligned playbook mutation authority and official-source precedence with focused regression proof; no public/runtime route changed.
- `103-sg-verify`: verified locally for the 2026-08-04 GitHub-hygiene extension; the original four-mode proof remains valid, and the fifth mode passes independent queue-safety and active-surface checks. No public-site checkout or hosted proof was available or required for this local contract migration.
- `104-sg-end`: pending — closure bookkeeping remains to be recorded after the operator confirms whether this local slice should be committed and pushed.
- `005-sg-ship`: pending — no commit or push has been made for this new slice.

Next command: `/103-sg-verify consolidate GitHub hygiene under 010-sg-technical`
