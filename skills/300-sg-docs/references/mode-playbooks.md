---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.8.1"
project: ShipGlows
created: "2026-05-16"
updated: "2026-07-12"
status: draft
source_skill: 102-sg-start
scope: 300-sg-docs-mode-playbooks
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - shipglows_data/technical/
  - shipglows_data/editorial/
  - shipglows_data/workflow/specs/
depends_on:
  - artifact: "skills/300-sg-docs/references/core-governance.md"
    artifact_version: "0.4.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from 300-sg-docs SKILL.md during compact-skill pilot."
  - "Technical docs mode extended with global external platform corpus and governance-root platform usage docs."
  - "Operator decision on 2026-05-24: provider usage notes are risk-driven, not mandatory per technology."
  - "Operator decision on 2026-05-24: monorepo documentation uses the root shipglows_data corpus with scoped app/package entries."
  - "Operator decision on 2026-06-28: docs init for empty repositories must produce an explicit bootstrap contract instead of a generic README-only result."
  - "Operator decision on 2026-06-28: when bootstrap facts are missing, docs init should ask precise numbered questions instead of stopping as blocked."
  - "Operator decision on 2026-06-28: docs skill should support an explicit duplicate-governance audit mode to decide whether duplicated docs are justified, mergeable, or migration debt."
  - "Operator decision on 2026-07-12: topology migration must be tool-triggered before narrow update work and include every legacy shipglows_data corpus."
next_review: "2026-06-16"
next_step: "/103-sg-verify Compact ShipGlows Skill Instructions"
---

# 300-sg-docs Mode Playbooks

## INIT MODE

Use this mode when the repository is empty, near-empty, or the operator explicitly asks for documentation/governance bootstrap.

Load `skills/300-sg-docs/references/bootstrap-starter-templates.md` before writing bootstrap output.

Bootstrap output should prefer a coherent starter contract over placeholder prose. Minimum expected surfaces:

- root `AGENT.md` with repository operating contract
- root `README.md` with explicit project intent status, target surface status, and next framing step
- `shipglows_data/workflow/TASKS.md` with real bootstrap tasks, not filler
- technical governance starter files when no code exists yet:
  - `shipglows_data/technical/README.md`
  - `shipglows_data/technical/code-docs-map.md`

For empty or near-empty repositories:

- do not pretend the project is already defined
- label unknown product/runtime facts as unknown
- mark the repository as `bootstrap` / `not yet scoped`
- make the next framing step explicit
- avoid fake features, stack assumptions, env vars, scripts, or API sections

Question rule for bootstrap:

- load `skills/references/question-contract.md` when a missing fact would materially change the bootstrap documents
- ask one numbered question at a time
- prefer questions for:
  - project intent
  - target surface
  - primary runtime/platform
- after each answer, continue the bootstrap instead of reclassifying the run as blocked
- report `blocked` only when the user refuses to provide a materially required decision and no safe `unknown` default can preserve document truth

Recommended bootstrap question order:

1. project intent
2. target surface
3. primary runtime/platform

Bootstrap questions are part of the work, not a failure condition. The skill should guide the operator through the missing framing until the starter set can be written truthfully.

If source code already exists, `init` may still bootstrap missing governance, but it must derive the README and map from observed code and config rather than the empty-repo template.

## FILE MODE

1. Read target file and one import level.
2. Document non-obvious behavior (why, edge cases, public contract).
3. Follow local style (JSDoc/TSDoc/docstrings/component header comments).
4. Avoid documenting obvious code.

## TECHNICAL DOCS MODE

Load `skills/references/technical-docs-corpus.md`, then read the governance-root `shipglows_data/technical/code-docs-map.md` (fallback legacy `docs/technical/code-docs-map.md`).

Use mode variants:

- bootstrap: missing technical layer
- audit: verify layer coherency
- update-plan: changed code paths require documentation update plan
- monorepo audit: verify that one root `shipglows_data/` covers app/package scopes and nested copies are treated as migration debt

Minimum checks:

- mapped code areas have primary docs or explicit non-coverage
- technical docs contain `Purpose`, `Owned Files`, `Entrypoints`, `Invariants`, `Validation`, `Reader Checklist`, `Maintenance Rule`
- `code-docs-map.md` includes path patterns, validations, triggers
- complex term families have a behavior index or an explicit no-coverage reason
- behavior indexes distinguish ambiguous operator terms instead of flattening them
- mapped behavior indexes link to key symbols, tests, specs/bugs, and decisions or an explicit `no durable decision record needed`
- high-cognitive-load symbols reached from behavior indexes have source comment coverage for contract/invariant recovery
- UI projects declare design-system authority in `shipglows_data/technical/design-system-authority.md` or a mapped scoped app doc
- monorepos have one root `shipglows_data/` with app/package path scopes instead of repeated nested corpora
- monorepos using the Astro plus Flutter plus backend split prefer flat source roots at the monorepo root; nested `apps/*` layout is treated as migration debt unless a durable exception is documented
- external provider behavior has a global source note under `shipglows_data/technical/external-platforms/` when it is common or repeated across projects
- projects or monorepo surfaces that use an external provider have a governance-root usage note under `shipglows_data/technical/platforms/` only when provider behavior affects validation, auth, deploy, runtime, SDK, storage, security, migrations, observability, compliance, production proof, or local exceptions

External platform docs use two layers:

- global source note: `shipglows_data/technical/external-platforms/<provider>.md`
- provider usage note: `<governance-root>/shipglows_data/technical/platforms/<provider>.md`

Do not mirror vendor docs. Keep links to official sources, freshness anchors, ShipGlows decision rules, validation routes, and project-specific usage. Do not create filler project-local notes for standard, low-risk provider usage that is already clear from code/config and the global note.

Output update plans with fields:

- code changed
- subsystem
- primary doc
- secondary docs
- action (`none|review|update|create`)
- priority
- reason
- owner role
- parallel-safe
- notes

Behavior-index bootstrap is justified when:

- the same operator term repeatedly maps to multiple behaviors
- the recovery path spans code, tests, specs, bugs, and decisions
- the subsystem is product-critical, platform-critical, or cognitively dense

## EDITORIAL GOVERNANCE MODE

Load `skills/references/editorial-content-corpus.md`, then governance-root editorial governance docs (`shipglows_data/editorial/*` fallback legacy `docs/editorial/*`).

If the run touches operational follow-up or asks where a content/public-docs task should live, also load `skills/references/task-registry-routing.md` and keep the split explicit:

- `shipglows_data/workflow/TASKS.md` = execution backlog
- `shipglows_data/editorial/ROADMAP.md` = editorial/public-content backlog

Do not let editorial bootstrap or update work silently repopulate `TASKS.md` with public-content follow-up when the new roadmap artifact exists.

Use mode variants:

- bootstrap: missing editorial governance with public surfaces detected
- audit: verify claims/page intents/content map/gates
- update-plan: changed public content requires editorial update plan

Must check:

- content-map coverage for public surfaces
- claim register for sensitive claims and proof status
- page intent map coherence
- editorial gate expectations
- runtime content schema compatibility
- editorial roadmap presence and role when the project has durable public-content follow-up
- monorepos use the root `shipglows_data/editorial/` corpus for shared public/content surfaces, with entries scoped by app/site/package where needed

Bootstrap/update rule:

- when editorial governance is applicable and the corpus is being bootstrapped or normalized, create `shipglows_data/editorial/ROADMAP.md` if it is missing and the target repo is writable
- keep the roadmap operational only; it is the backlog companion to the editorial corpus, not a substitute for `content-map.md`, `page-intent-map.md`, or the claim register

If no public/editorial surfaces are detected, report `skipped - no editorial surfaces detected`.

## DUPLICATE GOVERNANCE MODE

Use this mode when the operator wants an explicit review of duplicated governance artifacts or when a monorepo migration reveals the same truth repeated across root and surface-scoped docs.

Audit order:

1. inventory candidate duplicate sets across `shipglows_data/`, legacy root docs, and surface-scoped governance folders
2. group artifacts by theme first, then by surface
3. compare overlap, ownership, freshness, and decision impact
4. classify each set using the duplicate-governance rule from `core-governance.md`
5. merge or normalize when the classification is mechanically safe
6. leave bounded divergence only where the surface truth genuinely differs

Candidate families to inspect first:

- branding
- business
- product
- gtm
- technical context / architecture / guidelines
- editorial content-map / page-intent / claim docs
- legacy root files that mirror canonical `shipglows_data/` artifacts

Required output per duplicate set:

- `artifact set`
- `classification` (`merge-to-shared|keep-surface-specific|split-shared-and-surface-delta|collision-needs-review`)
- `canonical target`
- `action`
- `reason`

Merge rules:

- preserve non-redundant content before removing the source duplicate
- prefer theme-first canonical targets at the governance root
- when overlap is mostly shared with a small real delta, create or keep a shared base and move the delta to the smallest scoped file
- when evidence is insufficient to resolve conflicting truths safely, stop at `collision-needs-review` instead of guessing

Default canonical targets in monorepos:

- shared branding -> `shipglows_data/branding/branding.md` with optional sibling brand bundle files under `shipglows_data/branding/`
- shared business -> `shipglows_data/business/business.md`
- shared product -> `shipglows_data/product/product.md` only when the product truth is genuinely shared; otherwise `shipglows_data/product/<surface>/product.md`
- shared gtm -> `shipglows_data/gtm/gtm.md` only when channel/offer truth is genuinely shared; otherwise `shipglows_data/gtm/<surface>/gtm.md`
- technical and editorial docs stay scoped by surface unless a shared root artifact is clearer and truthful

When the operator asks for cleanup, this mode may also execute the merge and deletion pass, but only after preserving unique content in the chosen canonical target.

## README MODE

Generate or update README using project evidence:

- one-line project description
- features
- quick start
- structure
- stack
- env vars
- scripts
- contributing

If README exists and user preference is unclear, ask merge/replace/skip.

If the repository is empty or near-empty:

- load `skills/300-sg-docs/references/bootstrap-starter-templates.md`
- do not emit a normal product README template
- write a bootstrap README instead
- ask a numbered bootstrap question first when project intent or target surface is still materially unknown
- required sections:
  - current project intent status
  - current implementation status
  - known target surface or `unknown`
  - immediate next framing step
- keep the README explicit that governance exists before implementation

## API MODE

Document detected API endpoints:

- method/path
- auth expectations
- request/response schemas
- status codes
- usage examples

Prefer output location aligned with project (`docs/API.md` or local API docs pattern).

## COMPONENTS MODE

Document component contracts:

- purpose
- props/slots with real types
- usage examples
- dependencies

Prefer project-native output (`docs/COMPONENTS.md` or local pattern).

## AUDIT MODE

Run documentation coherency audit:

- inventory docs and doc-like surfaces
- compare code vs docs for drift and missing coverage
- validate metadata on applicable ShipGlows artifacts
- validate professional bug model documentation
- validate language doctrine
- validate freshness of context docs and dependency versions when applicable

Prioritize user-risk docs (install, auth, billing, migration, API, troubleshooting).

## UPDATE MODE

Run a silent documentation audit, then apply selected remediations.

Required gates:

- preserve governance corpus ownership boundaries
- only run skill-budget audit when scope touches skills/discovery metadata
- persist conversation-derived durable decisions to proper docs surfaces
- when the run touches operational follow-up trackers, load `skills/references/task-registry-routing.md` and preserve the split explicitly:
  - execution/implementation work -> `shipglows_data/workflow/TASKS.md`
  - editorial/public-content work -> `shipglows_data/editorial/ROADMAP.md`
  - mixed findings -> split across both trackers instead of collapsing into one record
- when slimming or deleting local docs, run a source-to-canonical preservation pass first and update the canonical target in the same change
- keep bug model documentation consistent
- create/update canonical business/product/branding/architecture/gtm/content-map/guidelines docs when missing and justified
- when branding is non-trivial, prefer a governed bundle under `shipglows_data/branding/` rather than stuffing all brand doctrine into one file
- create/update `shipglows_data/technical/design-system-authority.md` when a project has UI code but no declared canonical token/theme/component authority
- when invoked to repair weak product/surface governance discovered by another owner, start with recovery (minimal question + inferable updates first), then resume the originating run immediately after `300-sg-docs update`

When the target repo already declares `shipglows_data/editorial/ROADMAP.md`, `300-sg-docs update` should treat it as the canonical editorial operational companion and should not describe `shipglows_data/workflow/TASKS.md` as the place for content-roadmap work.

When the target repo has applicable editorial governance but no `shipglows_data/editorial/ROADMAP.md`, `300-sg-docs update` should create it as part of the recoverable normalization pass rather than leaving it as an implied manual follow-up.

Priority buckets:

- P0 dangerous drift
- P1 conventions
- P2 stale docs
- P3 missing coverage

## LAYOUT MIGRATION MODE

Move root legacy artifacts, every `shipglows_data/` corpus, and non-standalone nested `shipglows_data/` copies into the governance-root `shipglows_data/` without destructive overwrite.

Rules:

- classify each source as moveable/collision/external-root-ok/tracker/runtime-content
- classify nested monorepo corpora as migrate/collision/standalone-exception
- build a preservation ledger for every migrated local doc or tracker before converting it into a facade
- migrate non-redundant tracker content into canonical workflow files, not only technical docs
- prefer `git mv` inside git repos
- do not overwrite collisions silently
- run metadata lint and legacy path grep checks

Required migration proof per source:

- source path
- chosen canonical target
- preserved sections or tasks
- intentionally rejected sections with reason
- resulting local state

If the operator asks for a consolidation pass after migration, do not treat that as redundant. Re-open the original sources, compare them against the canonical destinations, and repair any semantic loss found.

## METADATA MODE

Frontmatter migration is additive, not content rewrite.

Rules:

- load migration guide + metadata linter when available
- define scope before edits
- classify candidates (`migrate`, `already compliant`, `runtime content`, `tracker excluded`, `archive excluded`, `ambiguous`)
- preserve body unchanged
- infer only obvious metadata values, otherwise `unknown` and lower confidence
- lint changed scope

## AUTO MODE

Detect likely gaps and choose the narrowest safe default.

When the repository is empty or near-empty:

- prefer `INIT MODE`
- load `skills/300-sg-docs/references/bootstrap-starter-templates.md`
- do not stop at a generic "what do you want to document next" question unless a material decision blocks safe bootstrap
- ask a specific numbered bootstrap question when one fact would materially improve the starter documents
- create the governance starter set first, then report the remaining framing gap

When code or public surfaces already exist, continue to choose between README/API/components/env/changelog/missing docs based on observed evidence.

## Final Reporting Templates

Keep user-facing reports concise by default. Include only sections that affect next action:

- outcome
- evidence
- limits/gaps
- next step
- chantier block when relevant

For blocked or explicit handoff runs, switch to detailed `report=agent` format.
