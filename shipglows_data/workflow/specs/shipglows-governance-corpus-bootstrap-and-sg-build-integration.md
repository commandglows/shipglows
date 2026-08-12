---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipGlows
created: "2026-05-02"
created_at: "2026-05-02 04:51:15 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 20:11:48 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice ShipGlows qui initialise et pilote des projets avec des agents, je veux que les couches de gouvernance documentaire technique et éditoriale soient créées par le workflow normal et consommées par sg-build, afin de ne pas relancer manuellement des chantiers de gouvernance dans chaque nouveau projet."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-init/SKILL.md
  - skills/sg-docs/SKILL.md
  - specs/sg-build-autonomous-master-skill.md
  - skills/references/technical-docs-corpus.md
  - skills/references/editorial-content-corpus.md
  - docs/technical/
  - docs/editorial/
  - docs/technical/code-docs-map.md
  - CONTENT_MAP.md
  - AGENT.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - GUIDELINES.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - docs/technical/public-site-and-content-runtime.md
  - templates/technical_module_context.md
  - templates/editorial_content_context.md
  - templates/content_map.md
  - tools/shipglows_metadata_lint.py
depends_on:
  - artifact: "README.md"
    artifact_version: "0.4.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.7.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/specs/sg-build-autonomous-master-skill.md"
    artifact_version: "1.1.0"
    required_status: ready
  - artifact: "shipglows_data/workflow/specs/shipglows-technical-documentation-layer-for-ai-agents.md"
    artifact_version: "1.0.2"
    required_status: ready
  - artifact: "shipglows_data/workflow/specs/shipglows-editorial-content-governance-layer-for-ai-agents.md"
    artifact_version: "1.0.0"
    required_status: ready
  - artifact: "shipglows_data/technical/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "shipglows_data/editorial/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 20 renames the physical spec from the historical sf-build typo to the canonical sg-build integration filename."
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "Historical migration-source provenance (legacy root documents): BRANDING.md, BUSINESS.md, CONTENT_MAP.md, GTM.md, GUIDELINES.md, PRODUCT.md."
  - "User decision 2026-05-02: the technical and editorial governance layers are not chantiers to rerun manually in every future project."
  - "User decision 2026-05-02: sg-docs should own creation and maintenance of the new documentation corpora."
  - "User decision 2026-05-02: sg-build should integrate the new paths and content map so its agents use the corpora effectively."
  - "Repo evidence 2026-05-02: technical governance chantier is shipped in specs/shipglows-technical-documentation-layer-for-ai-agents.md."
  - "Repo evidence 2026-05-02: editorial governance chantier is shipped in specs/shipglows-editorial-content-governance-layer-for-ai-agents.md."
  - "Repo evidence 2026-05-02: skills/sg-docs/SKILL.md already exposes technical and editorial modes, but skills/sg-init/SKILL.md only bootstraps CONTENT_MAP.md and does not create docs/technical or docs/editorial."
  - "Repo evidence 2026-05-02: skills/sg-build/SKILL.md does not exist yet, so the existing sg-build spec is the correct integration target before implementation."
next_step: "None"
---

# Spec: ShipGlows Governance Corpus Bootstrap and sg-build Integration

## Title

ShipGlows Governance Corpus Bootstrap and sg-build Integration

## Status

ready

## User Story

En tant qu'utilisatrice ShipGlows qui initialise et pilote des projets avec des agents, je veux que les couches de gouvernance documentaire technique et éditoriale soient créées par le workflow normal et consommées par `sg-build`, afin de ne pas relancer manuellement des chantiers de gouvernance dans chaque nouveau projet.

## Minimal Behavior Contract

When a project is initialized, adopted, documented, or later piloted through `sg-build`, ShipGlows must ensure that the technical documentation corpus and editorial governance corpus either exist with project-specific minimal content or are explicitly marked as not applicable with a recoverable next command. Success is observable because `sg-init` reports the governance corpus state, `sg-docs` can create or audit both layers without a separate governance chantier, and the `sg-build` spec requires its Readers to consume those project-local paths before execution, closure, and ship. If the layers are missing, stale, schema-incompatible, or unsafe to create automatically, the workflow stops with a concrete docs-bootstrap plan instead of silently coding or publishing with no governance context. The easy edge case to miss is treating the shipped ShipGlows governance specs as reusable project tasks; they are source doctrine for ShipGlows, while future projects need lightweight corpus bootstrap through `sg-init` and `sg-docs`.

## Success Behavior

- Preconditions: the ShipGlows repo contains the shipped technical and editorial governance layers; a target project can be new or existing; `sg-init`, `sg-docs`, and the `sg-build` spec are available.
- Trigger: the operator runs `/sg-init`, `/sg-docs update`, `/sg-docs technical`, `/sg-docs editorial`, or prepares `/sg-build <story>` on a project.
- User/operator result: the operator does not have to run a separate `ShipGlows Technical Documentation Layer for AI Agents` or `ShipGlows Editorial Content Governance Layer for AI Agents` chantier for each project.
- System effect: `sg-init` creates or reports the technical and editorial corpus state; `sg-docs` becomes the official scaffold/audit path for both layers; the `sg-build` spec requires a governance corpus gate before implementation and docs/content gates during execution.
- Success proof: initialized/adopted projects show `docs/technical/` and, when public content surfaces exist or content work is enabled, `docs/editorial/`; `sg-docs` validation commands pass; `specs/sg-build-autonomous-master-skill.md` names the concrete corpus paths and no longer relies on conversation memory for the integration.
- Silent success: not allowed. The final report for init/docs/build preparation must say whether technical governance is present, editorial governance is present, absent by design, or blocked.

## Error Behavior

- Expected failures: no project root, no writable docs directory, missing templates, metadata-lint failure, stale `CONTENT_MAP.md`, public content surfaces detected but editorial docs missing, no code areas detected for a technical map, runtime content schema conflict, `docs/technical/` accidentally routed to a public site, missing `AGENT.md` or invalid `AGENTS.md` compatibility, or an `sg-build` implementation attempt before the governance corpus gate is defined.
- User/operator response: the workflow reports the missing or blocked layer, the affected files, and the exact next safe command such as `/sg-docs technical`, `/sg-docs editorial`, `/sg-docs update`, or `/sg-spec` when policy is unclear.
- System effect: no public content claim is strengthened without editorial governance, no mapped code change ships without a technical documentation plan, and no future project receives copied ShipGlows-specific governance content as if it were project truth.
- Must never happen: create project docs with ShipGlows's own repository-specific claims, publish internal-only technical docs, add ShipGlows governance frontmatter to Astro runtime content that rejects it, create `skills/references/subagent-roles/reader.md`, or let `sg-build` bypass missing corpus state as a convenience.
- Silent failure: not allowed. Missing governance must be visible as `not applicable`, `needs bootstrap`, `stale`, or `blocked`.

## Problem

ShipGlows now has two durable governance layers:

- `docs/technical/` plus `skills/references/technical-docs-corpus.md` for code-proximate documentation and `Documentation Update Plan` routing.
- `docs/editorial/` plus `skills/references/editorial-content-corpus.md` for public-content surfaces, claims, page intent, Astro runtime schema boundaries, and `Editorial Update Plan` routing.

Those layers were correctly built as ShipGlows repo chantiers. The remaining gap is adoption. A future project should not require the operator to manually run the two governance specs or launch new `sg-start` governance chantiers. The normal creation and maintenance workflow should create the project-local corpus, and the future `sg-build` skill should consume it as part of its orchestration gates.

Today `sg-docs` already contains technical and editorial modes, but `sg-init` only bootstraps `CONTENT_MAP.md` for content architecture and does not create or report `docs/technical/` or `docs/editorial/`. Also, `skills/sg-build/SKILL.md` does not exist yet, so the current integration point is the ready `sg-build` spec. Without this integration, `sg-build` could be implemented against stale assumptions, or future projects could miss the governance layers entirely.

## Solution

Integrate the shipped governance corpus into ShipGlows's creation and orchestration workflow. `sg-init` should create or explicitly report lightweight project-local technical and editorial governance state. `sg-docs` should own bootstrap, update, and audit behavior for both corpora, including existing-project adoption. The ready `sg-build` spec should be amended before implementation so its Technical Reader and Editorial Reader load the concrete corpus paths, run a governance corpus gate, and block closure or ship when the relevant corpus is missing or stale.

## Scope In

- Add a governance corpus bootstrap stage to `skills/sg-init/SKILL.md`.
- Ensure `sg-init` reports `docs/technical`, `docs/editorial`, and `CONTENT_MAP.md` status in the final init report.
- Make `sg-init` create a minimal `docs/technical/` layer for initialized projects when docs can be written.
- Make `sg-init` create or explicitly skip `docs/editorial/` based on detected public/content surfaces, with a visible reason when skipped.
- Make `sg-init` preserve `AGENT.md` as the agent routing entrypoint and `AGENTS.md` as symlink compatibility only when created or checked.
- Extend `skills/sg-docs/SKILL.md` so `update` and audit/adoption modes can bootstrap missing governance layers without a separate governance chantier.
- Clarify first-run behavior for `sg-docs technical` when `docs/technical/code-docs-map.md` does not exist yet.
- Clarify first-run behavior for `sg-docs editorial` when `docs/editorial/README.md` does not exist yet.
- Update `specs/sg-build-autonomous-master-skill.md` to include a `Governance Corpus Gate` before implementation and concrete corpus paths in Technical Reader and Editorial Reader instructions.
- Update `README.md` and `shipglows_data/workflow/playbooks/spec-driven-workflow.md` to explain the division of responsibilities: `sg-init` bootstraps, `sg-docs` maintains, `sg-build` consumes.
- Update technical docs that map skill/workflow changes.
- Validate metadata, skill budget, path coverage, and no-public-leak constraints.

## Scope Out

- Do not reimplement the already shipped technical governance layer.
- Do not reimplement the already shipped editorial governance layer.
- Do not create a public blog route, CMS, newsletter workflow, search, analytics, or RSS feed.
- Do not create `skills/sg-build/SKILL.md`; that remains owned by `specs/sg-build-autonomous-master-skill.md`.
- Do not create a generic `skills/references/subagent-roles/reader.md`.
- Do not make every tiny project carry a full, verbose documentation set; bootstrap should be minimal and project-specific.
- Do not publish `docs/technical/` to the public site.
- Do not add ShipGlows governance metadata to framework runtime content when the local schema rejects it.
- Do not move project decision docs into `shipglows_data`; project repositories remain the canonical home.

## Constraints

- Internal workflow instructions and stable section headings must be English; user-facing reports and questions stay in the active user language.
- Bootstrap must be conservative: create minimal project-local artifacts, not copied ShipGlows-specific conclusions.
- Technical governance is applicable to code projects by default; if no code area can be mapped, the technical map must record an explicit non-coverage reason.
- Editorial governance is applicable when public pages, README public promises, docs, FAQ, skill pages, pricing, support copy, blog/article intent, or runtime content surfaces exist.
- A missing editorial layer may be valid for an internal-only project, but the workflow must state `no editorial surfaces detected` or equivalent.
- Shared files are sequential: `skills/sg-init/SKILL.md`, `skills/sg-docs/SKILL.md`, `specs/sg-build-autonomous-master-skill.md`, `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `CONTENT_MAP.md`, `AGENT.md`, and `docs/technical/code-docs-map.md`.
- Generated docs must pass `tools/shipglows_metadata_lint.py` unless the target is framework runtime content with its own schema.
- The bootstrap must not depend on a network service or external package.

## Dependencies

- Local runtime: Markdown specs, ShipGlows skills, `rg`, shell checks, git, and `tools/shipglows_metadata_lint.py`.
- Existing shipped doctrine: `docs/technical/`, `docs/editorial/`, `technical-docs-corpus.md`, `editorial-content-corpus.md`, and their shipped specs.
- Workflow docs: `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `README.md`, `GUIDELINES.md`, and `CONTENT_MAP.md`.
- Future consumer: `specs/sg-build-autonomous-master-skill.md`, because the actual `skills/sg-build/SKILL.md` does not exist yet.
- Fresh external docs: not needed for this spec because the work is local Markdown workflow, local scaffolding, and existing ShipGlows skill doctrine. If implementation changes Astro runtime content schema or introduces a new framework integration, rerun the Documentation Freshness Gate for that specific change.

## Invariants

- `sg-docs` owns documentation corpus creation, update, and audit behavior.
- `sg-init` may bootstrap docs but must not become the long-term docs executor.
- `sg-build` consumes governance layers and gates work; it must not duplicate full `sg-docs` scaffold logic.
- Technical Reader and Editorial Reader stay read-only roles; executors or integrators apply updates.
- The shipped governance specs remain historical source doctrine, not per-project tasks.
- `CONTENT_MAP.md` remains the canonical editorial routing map.
- `docs/technical/code-docs-map.md` remains the canonical technical code-to-doc map.
- `AGENT.md` remains the canonical agent entrypoint; `AGENTS.md` is a symlink compatibility alias only.

## Links & Consequences

- `sg-init`: gains a docs governance bootstrap/reporting responsibility.
- `sg-docs`: becomes the explicit owner of both corpus bootstrap and ongoing audits for initialized and existing projects.
- `sg-build` spec: must be amended before `sg-build` implementation so the future skill does not ship without corpus gates.
- `README.md` and workflow docs: must explain the normal path so operators do not run internal governance specs manually.
- `docs/technical/skill-runtime-and-lifecycle.md`: must reflect the new skill workflow responsibilities.
- `docs/technical/public-site-and-content-runtime.md`: must reflect editorial governance only if public content routing guidance changes.
- `CONTENT_MAP.md`: only changes if implementation changes content routing rules or surface detection wording.
- Security: public claim safety improves, but incorrect automatic copying could expose internal details or misleading claims; bootstrap must use project evidence.
- Performance: no runtime application impact; validation cost is local metadata/build checks only.
- SEO/content: no new public pages in this chantier; public docs may need concise explanation updates.

## Documentation Coherence

- Update `skills/sg-init/SKILL.md` so new projects receive or explicitly skip the two governance corpora as part of initialization.
- Update `skills/sg-docs/SKILL.md` so the official docs workflow can bootstrap, update, and audit both corpora for new and existing projects.
- Update `specs/sg-build-autonomous-master-skill.md` so `sg-build` references the shipped corpus paths and has a pre-implementation governance gate.
- Update `README.md` and `shipglows_data/workflow/playbooks/spec-driven-workflow.md` so users understand: `sg-init` bootstraps, `sg-docs` owns docs, `sg-build` consumes.
- Update `docs/technical/skill-runtime-and-lifecycle.md` because skill lifecycle behavior changes.
- Update `docs/technical/public-site-and-content-runtime.md` only if public content routing or editorial surface behavior changes.
- Do not update `CHANGELOG.md` during `sg-spec`; `sg-end` owns changelog preparation.

## Edge Cases

- A project has code but no public site: create technical governance; mark editorial governance as not applicable unless README/public claims or docs surfaces exist.
- A project has a public site but no blog: create editorial governance and record `surface missing: blog` only when blog/article output is requested.
- A project has Astro runtime content with a strict schema: do not add ShipGlows metadata to content collection files unless the schema accepts it.
- A project already has `docs/technical/` or `docs/editorial/`: audit and merge missing governance structure instead of overwriting.
- A project has `AGENTS.md` as a real file: report a compatibility conflict and ask before converting to a symlink or preserving it as external-tool-specific guidance.
- `sg-build` starts in a project with no governance corpus: it must run or route to `sg-docs` bootstrap, or explicitly record no-impact/no-surface status before implementation.
- `sg-docs update` runs on an old project: it should create missing corpus layers only when the project evidence supports them, and report skipped layers.
- Public claims exist in README but no site exists: editorial governance still applies because README is a public surface.
- Technical docs become stale after code changes: `sg-build` closure and ship remain blocked unless the stale item is resolved or explicitly marked with the allowed pending condition.

## Implementation Tasks

- [ ] Task 1: Add governance corpus bootstrap detection to `sg-init`
  - File: `skills/sg-init/SKILL.md`
  - Action: Add a step after `CONTENT_MAP.md` generation that detects code areas, public/content surfaces, existing `docs/technical/`, existing `docs/editorial/`, and `AGENT.md` / `AGENTS.md` state.
  - User story link: Makes governance creation part of normal project initialization.
  - Depends on: None
  - Validate with: `rg -n "Governance Corpus Bootstrap|docs/technical|docs/editorial|technical governance|editorial governance|AGENTS.md" skills/sg-init/SKILL.md`
  - Notes: The step should detect first, then create minimal artifacts or report a skipped/not-applicable state.

- [ ] Task 2: Define `sg-init` technical governance bootstrap behavior
  - File: `skills/sg-init/SKILL.md`
  - Action: Specify that code projects get minimal `docs/technical/README.md` and `docs/technical/code-docs-map.md` scaffolding, with explicit non-coverage reasons when no major code area is detected.
  - User story link: Gives future agents a technical map without running a separate governance chantier.
  - Depends on: Task 1
  - Validate with: `rg -n "docs/technical/README.md|docs/technical/code-docs-map.md|non-coverage|technical docs" skills/sg-init/SKILL.md`
  - Notes: Delegate detailed subsystem docs to `sg-docs technical`; do not produce a mega-doc during init.

- [ ] Task 3: Define `sg-init` editorial governance bootstrap behavior
  - File: `skills/sg-init/SKILL.md`
  - Action: Specify when to create `docs/editorial/` from detected public/content surfaces and when to report `no editorial surfaces detected` or an equivalent skipped state.
  - User story link: Makes public-content governance available for sites, README promises, docs, FAQ, skill pages, pricing, and future content work.
  - Depends on: Task 1
  - Validate with: `rg -n "docs/editorial|public surfaces|no editorial surfaces|README|FAQ|pricing|blog|runtime content" skills/sg-init/SKILL.md`
  - Notes: Do not invent blog paths; use the existing `surface missing: blog` doctrine.

- [ ] Task 4: Update the `sg-init` final report
  - File: `skills/sg-init/SKILL.md`
  - Action: Add report lines for `AGENT.md`, `docs/technical`, `docs/editorial`, and governance next steps.
  - User story link: Makes success or skipped governance state observable.
  - Depends on: Tasks 2 and 3
  - Validate with: `rg -n "AGENT.md:|docs/technical:|docs/editorial:|Governance|sg-docs technical|sg-docs editorial" skills/sg-init/SKILL.md`
  - Notes: The final report should distinguish created, already existed, skipped, blocked, and needs audit.

- [ ] Task 5: Extend `sg-docs update` for governance adoption
  - File: `skills/sg-docs/SKILL.md`
  - Action: Add update-mode rules that detect missing technical/editorial corpora and create or audit them using the existing technical/editorial modes.
  - User story link: Lets existing projects adopt the corpus without manual governance specs.
  - Depends on: None
  - Validate with: `rg -n "governance adoption|missing docs/technical|missing docs/editorial|sg-docs technical|sg-docs editorial|existing project" skills/sg-docs/SKILL.md`
  - Notes: Preserve the rule that `sg-docs` is support-de-chantier unless attached to one unique spec.

- [ ] Task 6: Clarify first-run technical docs mode
  - File: `skills/sg-docs/SKILL.md`
  - Action: Update technical mode so a missing `docs/technical/code-docs-map.md` is a bootstrap trigger, not an immediate read failure.
  - User story link: Makes `/sg-docs technical` usable on a fresh project.
  - Depends on: Task 5
  - Validate with: `rg -n "first-run|bootstrap trigger|code-docs-map.md.*missing|docs/technical.*missing" skills/sg-docs/SKILL.md`
  - Notes: The mode should create a minimal map from detected code paths, then audit.

- [ ] Task 7: Clarify first-run editorial governance mode
  - File: `skills/sg-docs/SKILL.md`
  - Action: Update editorial mode so missing `docs/editorial/README.md` is a bootstrap trigger and missing blog route stays `surface missing: blog`.
  - User story link: Makes `/sg-docs editorial` usable on a fresh public/content project.
  - Depends on: Task 5
  - Validate with: `rg -n "first-run|bootstrap trigger|docs/editorial/README.md.*missing|surface missing: blog|public surfaces" skills/sg-docs/SKILL.md`
  - Notes: Preserve runtime content schema boundaries.

- [ ] Task 8: Amend the `sg-build` spec with a Governance Corpus Gate
  - File: `specs/sg-build-autonomous-master-skill.md`
  - Action: Add a pre-implementation gate requiring `sg-build` to check project-local `docs/technical/`, `docs/editorial/` when applicable, `CONTENT_MAP.md`, and corpus references before launching execution.
  - User story link: Ensures the future autonomous master skill consumes the shipped corpora instead of relying on chat history.
  - Depends on: Tasks 5-7
  - Validate with: `rg -n "Governance Corpus Gate|docs/technical|docs/editorial|technical-docs-corpus|editorial-content-corpus|CONTENT_MAP|sg-docs technical|sg-docs editorial" specs/sg-build-autonomous-master-skill.md`
  - Notes: Bump the spec artifact version because this changes the implementation contract.

- [ ] Task 9: Align `sg-build` role references with shipped corpus paths
  - File: `specs/sg-build-autonomous-master-skill.md`
  - Action: Clarify that the Technical Reader loads `skills/references/technical-docs-corpus.md` and the project-local `docs/technical/code-docs-map.md`; the Editorial Reader loads `skills/references/editorial-content-corpus.md`, `CONTENT_MAP.md`, and project-local `docs/editorial/`.
  - User story link: Makes subagent behavior deterministic and path-based.
  - Depends on: Task 8
  - Validate with: `rg -n "Technical Reader.*technical-docs-corpus|docs/technical/code-docs-map|Editorial Reader.*editorial-content-corpus|docs/editorial" specs/sg-build-autonomous-master-skill.md`
  - Notes: Do not create the role files in this chantier unless readiness explicitly requires moving that work out of the sg-build chantier.

- [ ] Task 10: Update workflow doctrine for responsibility split
  - File: `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Action: Add a concise section or paragraph stating `sg-init` bootstraps governance corpora, `sg-docs` maintains/audits them, and `sg-build` consumes them during gates.
  - User story link: Prevents operators and agents from rerunning the governance specs manually per project.
  - Depends on: Tasks 1-9
  - Validate with: `rg -n "sg-init.*bootstrap|sg-docs.*maintain|sg-build.*consume|governance corpus|docs/technical|docs/editorial" shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Notes: Keep the doc concise; do not duplicate full `sg-docs` instructions.

- [ ] Task 11: Update README discoverability
  - File: `README.md`
  - Action: Add a short explanation of the normal project path for governance corpus creation and use.
  - User story link: Makes the workflow understandable without reading specs.
  - Depends on: Task 10
  - Validate with: `rg -n "sg-init|sg-docs|sg-build|docs/technical|docs/editorial|governance corpus" README.md`
  - Notes: Public wording must not overpromise autonomous execution.

- [ ] Task 12: Update technical docs for skill runtime changes
  - File: `docs/technical/skill-runtime-and-lifecycle.md`
  - Action: Document the new `sg-init` / `sg-docs` / `sg-build` responsibility split and validation expectations.
  - User story link: Keeps the code-proximate technical docs aligned with skill changes.
  - Depends on: Tasks 1-11
  - Validate with: `rg -n "sg-init|sg-docs|sg-build|governance corpus|Documentation Update Plan|Editorial Update Plan" docs/technical/skill-runtime-and-lifecycle.md`
  - Notes: Update `docs/technical/public-site-and-content-runtime.md` only if public content routing rules change.

- [ ] Task 13: Run validation checks
  - File: `skills/sg-init/SKILL.md`, `skills/sg-docs/SKILL.md`, `specs/sg-build-autonomous-master-skill.md`, `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `docs/technical/`
  - Action: Run metadata lint, targeted rg checks, skill budget audit, and public-site build if public docs or site content changed.
  - User story link: Proves the workflow integration is coherent and does not break existing shipped layers.
  - Depends on: Tasks 1-12
  - Validate with: `python3 tools/shipglows_metadata_lint.py specs docs AGENT.md CONTENT_MAP.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md GUIDELINES.md && python3 tools/skill_budget_audit.py --skills-root skills --format markdown && pnpm --dir shipglows-site build`
  - Notes: Site build is required only if implementation touches `site/` or public docs pages, but safe to run as final proof.

## Acceptance Criteria

- [ ] AC 1: Given a fresh code project is initialized with `sg-init`, when initialization finishes, then technical governance is reported as created, already existed, skipped with reason, or blocked with next command.
- [ ] AC 2: Given a fresh project has public pages, docs, README promises, FAQ, pricing, public skill pages, or runtime content, when `sg-init` runs, then editorial governance is created or explicitly reported as blocked with a concrete reason.
- [ ] AC 3: Given a project has no public/content surfaces, when `sg-init` runs, then editorial governance may be skipped but the report states why and names `/sg-docs editorial` as the adoption command if public surfaces appear later.
- [ ] AC 4: Given `docs/technical/code-docs-map.md` is absent, when `/sg-docs technical` runs, then the missing map is treated as a bootstrap trigger and not as a silent failure.
- [ ] AC 5: Given `docs/editorial/README.md` is absent, when `/sg-docs editorial` runs on a public/content project, then the missing layer is treated as a bootstrap trigger and not as a silent failure.
- [ ] AC 6: Given an existing project runs `/sg-docs update`, when technical or editorial corpus layers are missing, then `sg-docs` produces creation, audit, skip, or blocked status for each layer.
- [ ] AC 7: Given the future `sg-build` skill prepares implementation, when governance corpus state is missing or stale, then the `sg-build` spec requires routing to `sg-docs` bootstrap/audit or recording a no-impact/no-surface reason before execution.
- [ ] AC 8: Given a code-changing `sg-build` chantier proceeds, when Technical Reader analysis runs, then it loads `technical-docs-corpus.md` and project-local `docs/technical/code-docs-map.md`.
- [ ] AC 9: Given a public-content or visible-behavior `sg-build` chantier proceeds, when Editorial Reader analysis runs, then it loads `editorial-content-corpus.md`, `CONTENT_MAP.md`, and project-local `docs/editorial/`.
- [ ] AC 10: Given a future project has Astro runtime content, when editorial governance is bootstrapped or audited, then the workflow preserves the runtime content schema and does not add incompatible ShipGlows metadata.
- [ ] AC 11: Given `AGENTS.md` exists, when init/docs governance runs, then it is absent, a symlink to `AGENT.md`, or reported as a compatibility conflict; it is not silently maintained as a second canonical source.
- [ ] AC 12: Given implementation finishes, when validation runs, then metadata lint passes for active artifacts and skill budget audit reports no hard discovery violations.
- [ ] AC 13: Given the spec is read by a fresh agent, when it implements the integration, then it does not recreate the shipped governance specs and does not create `skills/sg-build/SKILL.md`.

## Test Strategy

- Static metadata: run `python3 tools/shipglows_metadata_lint.py specs docs AGENT.md CONTENT_MAP.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md GUIDELINES.md`.
- Skill compliance: run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- Targeted rg checks: verify `sg-init`, `sg-docs`, and the `sg-build` spec contain the new governance corpus language and concrete paths.
- Site build: run `pnpm --dir shipglows-site build` if README, public docs pages, `shipglows-site/`, or public content changed.
- Manual scenario 1: simulate a code-only project init and verify technical created plus editorial skipped with reason.
- Manual scenario 2: simulate an Astro/public-docs project init and verify technical plus editorial created or clearly blocked.
- Manual scenario 3: simulate `/sg-docs update` on an existing project with no governance layers and verify adoption statuses.
- Manual scenario 4: simulate `sg-build` on a project missing `docs/technical/`; verify the spec routes to `sg-docs technical` or blocks before implementation.
- Manual scenario 5: simulate `sg-build` on a visible behavior change with no editorial layer; verify the spec routes to `sg-docs editorial` or records no public impact before closure.

## Risks

- Security impact: yes, because public claims, internal technical docs, and generated project docs can leak private details or misrepresent behavior if copied incorrectly.
- Mitigation: generated content must be project-specific, internal technical docs stay internal, runtime content schemas are preserved, and metadata/public-claim checks remain required.
- Workflow risk: high if `sg-build` is implemented before this integration and bypasses the corpus gate.
- Mitigation: update `specs/sg-build-autonomous-master-skill.md` before `/sg-start sg-build Autonomous Master Skill`.
- Overprocess risk: medium if every tiny repo receives too much documentation.
- Mitigation: bootstrap minimal corpora and allow explicit skipped/not-applicable states.
- Drift risk: medium if `sg-init` and `sg-docs` diverge.
- Mitigation: `sg-init` bootstraps only; `sg-docs` owns maintenance and audit.
- Public-content risk: medium if README is treated as internal-only.
- Mitigation: README public promises count as editorial surfaces.

## Execution Notes

- Read first: `skills/sg-init/SKILL.md`, `skills/sg-docs/SKILL.md`, `specs/sg-build-autonomous-master-skill.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `README.md`, `docs/technical/skill-runtime-and-lifecycle.md`.
- Start with `sg-init` because future project creation is the adoption entrypoint.
- Then update `sg-docs` because it owns the reusable corpus creation and audit behavior.
- Then amend the `sg-build` spec so the future implementation starts from current corpus doctrine.
- Keep changes sequential because the touched files are shared workflow contracts.
- Use existing templates and shipped docs as doctrine, but do not copy ShipGlows-specific repository facts into future project templates.
- No new package is expected.
- Avoid creating `skills/sg-build/SKILL.md`; this chantier only prepares its spec integration.
- Avoid creating `reader.md`; the accepted role split is Technical Reader and Editorial Reader.
- Stop and return to `/sg-spec` if readiness determines that `sg-build` must be implemented in the same chantier, because that would expand scope beyond corpus integration.
- Stop if the implementation requires adding new artifact types to the metadata linter; that would need an explicit metadata-scope decision.
- Fresh external docs: not needed for current scope because all changes are local ShipGlows Markdown workflow and validation rules.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-02 04:51:15 UTC | sg-spec | GPT-5 Codex | Created the integration spec for bootstrapping shipped technical/editorial governance corpora through sg-init/sg-docs and wiring them into the sg-build spec before implementation. | Draft spec saved. | `/sg-ready ShipGlows Governance Corpus Bootstrap and sg-build Integration` |
| 2026-05-02 06:02:09 UTC | sg-ready | GPT-5 Codex | Evaluated structure, metadata, user-story alignment, task ordering, documentation coherence, language doctrine, adversarial risk, security scope, and fresh-docs need. | ready | `/sg-start ShipGlows Governance Corpus Bootstrap and sg-build Integration` |
| 2026-05-02 09:56:47 UTC | sg-start | GPT-5 Codex | Implemented governance corpus bootstrap/adoption instructions in sg-init and sg-docs, amended the sg-build spec with a Governance Corpus Gate and concrete corpus paths, aligned workflow/README/technical docs, and ran focused validation. | implemented | `/sg-verify ShipGlows Governance Corpus Bootstrap and sg-build Integration` |
| 2026-05-02 10:15:32 UTC | sg-ship | GPT-5 Codex | Full close and ship for the governance corpus bootstrap and sg-build integration, with task/changelog bookkeeping, scoped validation, and explicit note that separate sg-verify was not launched. | shipped | None |

## Current Chantier Flow

```text
sg-spec: done, draft spec created
sg-ready: done, ready
sg-start: implemented
sg-verify: not launched; scoped ship checks passed
sg-end: closed via sg-ship full
sg-ship: shipped
```

Current state:

- Chantier identified: yes.
- Implementation started: yes.
- Spec path: `shipglows_data/workflow/specs/shipglows-governance-corpus-bootstrap-and-sg-build-integration.md`.
- Required next step: None.
- Execution rule: sequential by default because the target files are shared workflow contracts; shipped with scoped static/build evidence and without a separate `sg-verify` lifecycle run.
