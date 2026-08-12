---
name: 300-sg-docs
description: "Maintain docs, bootstrap governance, metadata, and governance-layout compliance."
disable-model-invocation: true
argument-hint: [file-path | "init" | "readme" | "api" | "components" | "audit" | "update" | "metadata" | "migrate-frontmatter" | "migrate-layout" | "technical" | "technical audit" | "editorial" | "editorial audit" | "duplicata" | "duplicates" | "duplicate audit"]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project source files resolve from the current target path, but project governance artifacts resolve from the canonical governance root. For monorepos, that means the monorepo-root `shipglows_data/`, not repeated `shipglows_data/` directories inside each app/package.

## Public Métier Ownership

Public label: `sg-docs`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or documentation mode selection. Resolve `project -> product -> surface -> feature` and own internal architecture, governance, code-adjacent, context, metadata, and agent documentation through update and validation. Public README, FAQ, tutorials, guides, landing pages, blog, and help-center content belong to `sg-content`.

## Instruction Layering

Load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` before execution. This skill keeps only activation and gate logic locally; detailed doctrine and large mode playbooks are loaded from references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `shipglows_data/workflow/specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise and outcome-first.
Use `report=agent` for blocked runs, handoff, or explicit verbose request.

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Existing README: !`head -20 README.md 2>/dev/null || echo "no README.md"`
- Project structure sample: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -40`

## Mode Detection

- `init`, `bootstrap`, `docs init`, or `governance init` -> `INIT MODE`
- file path -> `FILE MODE`
- `readme` -> `README MODE`
- `api` -> `API MODE`
- `components` -> `COMPONENTS MODE`
- `audit` -> `AUDIT MODE`
- `update` -> `UPDATE MODE`
- `metadata` or `migrate-frontmatter` -> `METADATA MODE`
- `migrate-layout` or `layout` -> `LAYOUT MIGRATION MODE`
- `technical`, `technical audit`, `docs/technical` -> `TECHNICAL DOCS MODE`
- `editorial`, `editorial audit`, `docs/editorial` -> `EDITORIAL GOVERNANCE MODE`
- `duplicata`, `duplicates`, `duplicate audit` -> `DUPLICATE GOVERNANCE MODE`
- `add-project`, `project import`, `import project`, `import url` -> `ADD PROJECT MODE`
- `add-project update`, `project refresh`, `refresh project`, `update project` -> `ADD PROJECT UPDATE MODE`
- empty args -> `AUTO MODE`

## Always-On Governance Preflight

Before mode selection, run `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/audit_project_governance_topology.py" .`. Continue normally on `compliant`; enter layout migration on `migration-required`; resolve bootstrap/ownership on `review-required`. Do not report narrow docs work complete while this gate is unresolved.

## Required References

Always load:

1. `$SHIPGLOWS_ROOT/skills/300-sg-docs/references/core-governance.md`
2. `$SHIPGLOWS_ROOT/skills/300-sg-docs/references/mode-playbooks.md`

Load on demand:

- `$SHIPGLOWS_ROOT/skills/references/project-governance-rules.md` when the task is about governed-project compliance, canonical governance shape, monorepo governance expectations, or whether a project respects ShipGlows governance rules.
- `$SHIPGLOWS_ROOT/skills/references/documentation-governance-rules.md` when the task is about documentation architecture, metadata, canonical placement, duplicate docs, update discipline, or when the operator uses `#docs`.
- `$SHIPGLOWS_ROOT/skills/300-sg-docs/references/bootstrap-starter-templates.md` when mode is `init` or when `readme`/`auto` bootstraps an empty or near-empty repository.
- `$SHIPGLOWS_ROOT/skills/references/technical-docs-corpus.md` when mode is technical or update touches technical governance.
- `$SHIPGLOWS_ROOT/skills/references/code-navigation-and-function-docs.md` when mode is technical or when the task starts from operator terminology rather than file paths.
- `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` when mode is editorial or update touches public-content surfaces.
- `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md` when mode is `update` or `editorial` and the work touches operational follow-up trackers, so `shipglows_data/workflow/TASKS.md` stays execution-only while `shipglows_data/editorial/ROADMAP.md` carries editorial/public-content backlog.
- `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before any user-facing merge/replace/scope/surface question, including `init` bootstrap questions for unknown project intent, target surface, or runtime.
- `$SHIPGLOWS_ROOT/skills/references/guided-business-product-discovery.md` when `init` or `update` creates or substantially repairs business, product, GTM or brand context.
- `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md` when documentation creates, changes, repairs or audits material links between business goals, customer needs, journeys, capabilities, Atlas nodes, specs and proof.
- `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md` when documentation depends on current external framework, SDK, provider, runtime, schema, auth, deployment, or API behavior.
- `$SHIPGLOWS_ROOT/skills/references/skill-context-budget.md` only when scope touches `skills/`, skill discovery metadata, or Codex/Claude skill compliance.
- `$SHIPGLOWS_ROOT/skills/references/private-data-repo-contract.md` when scope touches durable private operator data, `~/.shipglows/data/`, private project fiches, or bootstrap/install docs that mention the private data repository.
- `$SHIPGLOWS_ROOT/shipglows_data/technical/metadata-migration-guide.md` when mode is metadata/migrate-frontmatter.
- `$SHIPGLOWS_ROOT/shipglows_data/workflow/playbooks/project-import-playbook.md` and `$SHIPGLOWS_ROOT/shipglows_data/workflow/checklists/project-import-checklist.md` when mode is `add-project` or `add-project update`.

## Execution Contract

- Keep internal contracts in English; user-facing output stays in the active user/project language.
- For empty or near-empty repositories, prefer explicit bootstrap output over generic README generation: create the smallest coherent governance starter set and label unknown project facts as unknown rather than inferred.
- For empty or near-empty repositories, do not treat missing project framing as blocked by default. Ask the smallest numbered decision question needed to define the bootstrap documents, then continue.
- Do not populate business, product, GTM or brand contracts from one project sentence or technical-stack inference. Use the guided discovery loop, preserve existing confirmed content, label hypotheses and persist the first unresolved operator decision.
- Preserve product-decision trace links in canonical documents without creating a parallel registry. When a confirmed decision changes, retain its superseded history and update dependent contracts in canonical-source order.
- Preserve redaction/security rules: never expose secrets, cookies, tokens, private keys, or private logs.
- Preserve documentation-update gates: changed behavior must have docs alignment proof or explicit `not impacted because ...`.
- Preserve canonical ShipGlows paths, documentation architecture, and metadata rules through the shared governance references instead of inventing local placement doctrine.
- For migration or consolidation work, treat local docs as source material until preservation is proven. Before replacing a local doc with a compatibility facade or deleting it, map it to a canonical destination, preserve non-redundant content, and record any intentional rejection.
- When a project declares products, preserve the product-governance contract in docs: product inventory, canonical product/sales surfaces, delivery-path documentation, and claim-evidence references must remain explicit enough for other skills to reuse without discovery drift.
- `shipglows_data/workflow/TEST_LOG.md`, `shipglows_data/workflow/BUGS.md`, `PROJECTS.md`, and canonical workflow trackers are operational trackers, not frontmatter-required decision artifacts.
- Operational trackers may still contain durable planning or decision content. During migration, mine them for canonical task, QA, or decision updates instead of assuming they are disposable.
- When scope touches `skills/`, skill README files, `site/src/content/skills/*.md`, or skill discovery metadata, verify skill contract coherence, public skill-page coherence, and runtime skill visibility together. Route non-trivial skill-contract changes through `900-shipglows-core build`.
- Do not add ShipGlows governance frontmatter to app-rendered runtime content such as `site/src/content/skills/*.md`.

## ADD PROJECT MODE

Use this mode when the operator gives a URL or repository and wants a private project fiche created or refreshed under `~/.shipglows/data/projects/`.

Load:

- `shipglows_data/workflow/playbooks/project-import-playbook.md`
- `shipglows_data/workflow/checklists/project-import-checklist.md`
- `skills/references/source-intake-classification.md`
- `skills/references/private-memory-store.md`
- `skills/references/private-data-repo-contract.md`

Follow the playbook order exactly:

1. identify source type and project candidate
2. detect existing ShipGlows data, pitch, or governed docs
3. extract stable project truth
4. write or update one private project file
5. record uncertainty, provenance, and next action
6. hand off to source classification if downstream routing is still needed

Do not invent a public story when the source does not support one. If the source is ambiguous or the URL is unavailable, report the gap and ask for the smallest missing URL or project truth needed to continue.

When documenting or generating bootstrap guidance for this mode, keep the storage doctrine explicit: `~/.shipglows/data/` is a separate private Git repository, while public governance remains in project repos and ephemeral review state lives elsewhere.

## ADD PROJECT UPDATE MODE

Use this mode when the operator wants to refresh an existing private project fiche after the project evolved.

This mode uses the same playbook and checklist as `ADD PROJECT MODE`, but the intent changes:

- refresh the pitch
- update the business angle
- adjust routing tags and owner-skill candidate
- record what changed since the last import
- keep old claims only if they still hold

Load:

- `shipglows_data/workflow/playbooks/project-import-playbook.md`
- `shipglows_data/workflow/checklists/project-import-checklist.md`
- `skills/references/source-intake-classification.md`
- `skills/references/private-memory-store.md`

Additional update rule:

- compare the current source against the existing private file first
- prefer update notes over rewriting the whole fiche when only the pitch or angle changed
- if the project no longer matches the original file, treat it as a rewrite plus explicit change log

## Stop Conditions

Stop and report `blocked` when:

- required ShipGlows-owned reference is missing and no safe fallback exists
- requested migration would overwrite canonical docs without explicit merge decision
- metadata lint fails on changed artifacts and cannot be corrected safely
- governance conflicts cannot be resolved (for example `AGENTS.md` not a symlink to `AGENT.md`)
- a migration would slim, delete, or facade a local doc before preservation proof exists for its non-redundant content
- a skill documentation update changes the public promise or lifecycle route but has no bounded skill-maintenance contract
- external behavior is documented without a required `fresh-docs checked` or explicit `fresh-docs not needed` verdict

## Validation

Run focused checks for touched surfaces:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/audit_project_governance_topology.py" .
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/shipglows_metadata_lint.py" <changed-artifacts>
rg -n "Maintenance Rule|Validation|Owned Files|Entrypoints" shipglows_data/technical "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/templates/technical_module_context.md"
rg -n "Editorial Update Plan|Claim Impact Plan|pending final copy|surface missing|Astro content schema" shipglows_data/editorial docs/editorial
test ! -e AGENTS.md || { test -L AGENTS.md && test "$(readlink AGENTS.md)" = "AGENT.md"; }
```

When a run migrates or consolidates local docs into canonical `shipglows_data/` targets:

```bash
git diff --name-only -- <migrated-local-docs> <canonical-targets>
rg -n "Canonical|compatibility facade|shipglows_data" <migrated-local-docs>
```

Use these checks to confirm the source docs were intentionally converted into facades and that canonical targets were actually updated in the same change, not merely after the fact.

When the scope touches skill discovery or skill docs policy:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/skill_budget_audit.py" --skills-root "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/skills" --format markdown
"${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/shipglows_sync_skills.sh" --check --all
rg -n "Report Modes|Required References|Validation|Stop Conditions" "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}"/skills/[0-9][0-9][0-9]-*/SKILL.md "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}"/skills/*/SKILL.md
```

When the scope touches public skill pages or docs rendered by the site:

```bash
pnpm --dir "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/shipglows-site" build
```
