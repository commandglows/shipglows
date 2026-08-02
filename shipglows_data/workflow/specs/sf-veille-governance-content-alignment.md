---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-05-22"
created_at: "2026-05-22 12:22:56 UTC"
updated: "2026-05-22"
updated_at: "2026-05-22 12:27:46 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "skill-maintenance"
owner: "Diane"
user_story: "En tant qu'utilisatrice ShipGlows, je veux que sg-veille respecte la gouvernance actuelle des projets, de la recherche et du contenu, afin que les URLs triées deviennent des décisions fiables sans écrire dans les mauvais dossiers ni inventer des surfaces éditoriales."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/sg-veille/SKILL.md"
  - "skills/sg-veille/README.md"
  - "site/src/content/skills/sg-veille.md"
  - "shipglows_data/workflow/research/"
  - "shipglows_data/editorial/content-map.md"
  - "shipglows_data/workflow/TASKS.md"
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "User listed five concrete sg-veille governance gaps on 2026-05-22."
  - "sg-veille currently treats ~/shipglows_data as global business source of truth instead of separating control-plane registry from project-local governance corpora."
  - "Existing ShipGlows veille reports live under shipglows_data/workflow/research/."
  - "shipglows_data/workflow/TASKS.md contains a deferred item to align sg-veille with content governance."
next_step: "/sg-skill-build sg-veille-governance-content-alignment"
---

# Title

sg-veille Governance Content Alignment

# Status

Ready.

# User Story

En tant qu'utilisatrice ShipGlows, je veux que sg-veille respecte la gouvernance actuelle des projets, de la recherche et du contenu, afin que les URLs triées deviennent des décisions fiables sans écrire dans les mauvais dossiers ni inventer des surfaces éditoriales.

# Minimal Behavior Contract

`sg-veille` accepts URLs or pasted content, fetches/analyzes them, scores relevance across registered projects, and asks one triage decision per source. It must use `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}` only as the cross-project control plane for registry/master tracking, use each target project's local `shipglows_data/` governance corpus for business/editorial/technical context, save veille reports and tools under canonical `shipglows_data/workflow/research/`, and route blog/newsletter/public-content ideas through `sg-content` or report `surface missing: blog` when no declared surface exists.

# Success Behavior

- URLs are triaged against project-local business/editorial/technical context.
- Reports and tools are saved under canonical workflow research paths.
- Content ideas do not invent blog/newsletter surfaces.
- User-facing questions follow `question-contract`.
- Final reports follow `reporting-contract`.

# Error Behavior

If a target project lacks local governance context, `sg-veille` reports a context gap and lowers confidence. If a content action needs an undeclared blog/article surface, it reports `surface missing: blog` and routes through `sg-content` or `sg-docs editorial` instead of writing a task that assumes the surface exists.

# Problem

`sg-veille` still encodes older ShipGlows assumptions: global `~/shipglows_data` as business truth, `~/shipglows/research` outputs, local AskUserQuestion rules, no report mode contract, and direct content backlog actions without editorial surface gates.

# Solution

Update the `sg-veille` activation contract, README, public skill page, and existing tracker item so the skill follows current path, content, report, and question governance.

# Scope In

- `skills/sg-veille/SKILL.md`
- `skills/sg-veille/README.md`
- `site/src/content/skills/sg-veille.md`
- `shipglows_data/workflow/TASKS.md` status for the explicit deferred item
- validation and refresh log if needed

# Scope Out

- No implementation of an actual veille run.
- No new blog/newsletter surface.
- No broad rewrite of `sg-content`, `sg-repurpose`, `sg-research`, or `sg-market-study`.
- No commit or push.

# Constraints

- Internal skill contract text stays English where it defines durable behavior.
- User-facing French prompts/reports keep natural accented French.
- Runtime Astro content keeps its existing frontmatter schema.
- Do not touch unrelated dirty files.

# Dependencies

- `skills/references/canonical-paths.md`
- `skills/references/reporting-contract.md`
- `skills/references/question-contract.md`
- `skills/references/editorial-content-corpus.md`
- `shipglows_data/editorial/content-map.md`
- `shipglows_data/editorial/blog-and-article-surface-policy.md`

Fresh external docs: `fresh-docs not needed` — this is local ShipGlows governance alignment, not an external framework behavior change.

# Invariants

- `sg-veille` remains `source-de-chantier`.
- `sg-content` owns content lifecycle orchestration.
- Operational trackers remain lightweight and do not receive governance frontmatter.
- Research reports are workflow artifacts, not runtime content.

# Links & Consequences

- Cross-project registry remains `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}/PROJECTS.md`.
- Cross-project master tasks can still use `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}/TASKS.md` when explicitly adding portfolio tasks.
- Project-local decision context comes from `[project]/shipglows_data/{business,editorial,technical,workflow}/`.
- Public skill docs must reflect the corrected paths and content gates.

# Documentation Coherence

Update `skills/sg-veille/README.md` and `site/src/content/skills/sg-veille.md`. Mark the existing deferred task complete if validation passes.

# Edge Cases

- A link can be useful for a project but only as research, not as content, when no content surface exists.
- A project can be listed in the master registry but lack local governance docs; score with lower confidence and report the gap.
- A content idea can route to `sg-content` without creating a blog article.

# Implementation Tasks

- [x] Task 1: Update `sg-veille` activation contract.
  - File: `skills/sg-veille/SKILL.md`
  - Action: Add report modes, question contract, editorial corpus, canonical context/output paths, and content-surface routing.
  - User story link: Prevents stale governance behavior during URL triage.
  - Depends on: None.
  - Validate with: `rg -n "Report Modes|question-contract|editorial-content-corpus|surface missing: blog|shipglows_data/workflow/research|sg-content" skills/sg-veille/SKILL.md`

- [x] Task 2: Update skill README.
  - File: `skills/sg-veille/README.md`
  - Action: Replace stale output paths and describe project-local governance/content routing.
  - User story link: Keeps operator docs aligned.
  - Depends on: Task 1.
  - Validate with: `rg -n "shipglows_data/workflow/research|project-local|sg-content|surface missing" skills/sg-veille/README.md`

- [x] Task 3: Update public skill page.
  - File: `site/src/content/skills/sg-veille.md`
  - Action: Align public description with governance-aware triage and content-surface limits.
  - User story link: Keeps public promise aligned with internal truth.
  - Depends on: Task 1.
  - Validate with: `rg -n "governance|content surface|sg-content|surface missing|project-local" site/src/content/skills/sg-veille.md`

- [x] Task 4: Update explicit deferred tracker item.
  - File: `shipglows_data/workflow/TASKS.md`
  - Action: Mark the sg-veille content-governance item done when validation passes.
  - User story link: Closes the known backlog gap.
  - Depends on: Tasks 1-3.
  - Validate with: `rg -n "Aligner .+sg-veille.+gouvernance contenu" shipglows_data/workflow/TASKS.md`

- [x] Task 5: Validate changed surfaces.
  - File: changed surfaces.
  - Action: Run skill budget, runtime sync, metadata lint, focused rg checks, and site build.
  - User story link: Proves the corrected contract is coherent.
  - Depends on: Tasks 1-4.
  - Validate with: commands in Test Strategy.

# Acceptance Criteria

- [x] `sg-veille` no longer names `~/shipglows_data/` as global business source of truth.
- [x] `sg-veille` writes reports/tools under `shipglows_data/workflow/research/`.
- [x] `sg-veille` loads `reporting-contract` and supports `report=user` / `report=agent`.
- [x] `sg-veille` loads `question-contract` before user-facing triage questions.
- [x] `sg-veille` loads editorial governance for public-content opportunities and reports `surface missing: blog`.
- [x] Public and README docs match the internal contract.
- [x] The explicit deferred task is no longer deferred.
- [x] Validation passes.

# Test Strategy

Proof path: `scenario-first`.

Pressure scenario: an operator passes three competitor/content URLs. `sg-veille` must discover projects from the control-plane registry, score each against project-local governance docs, ask triage through the shared question contract, route blog/newsletter ideas through `sg-content`, report `surface missing: blog` when no declared blog exists, and save outputs under `shipglows_data/workflow/research/`.

Validation commands:

```bash
rg -n "Report Modes|question-contract|editorial-content-corpus|surface missing: blog|shipglows_data/workflow/research|sg-content" skills/sg-veille/SKILL.md
rg -n "shipglows_data/workflow/research|project-local|sg-content|surface missing" skills/sg-veille/README.md
rg -n "governance|content surface|sg-content|surface missing|project-local" site/src/content/skills/sg-veille.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill sg-veille
python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/sg-veille-governance-content-alignment.md
pnpm --dir shipglows-site build
```

# Risks

- Cross-project scoring could become slower if too many project-local docs are loaded. Mitigation: load project docs only for plausible matches and report lower confidence otherwise.
- Content routing could become too conservative. Mitigation: still allow non-blog actions, benchmarks, product/architecture tasks, and `sg-content` handoff.
- Tracker update could collide with unrelated task edits. Mitigation: one-line targeted status update only.

# Execution Notes

Read first: `skills/sg-veille/SKILL.md`, `skills/references/editorial-content-corpus.md`, `shipglows_data/editorial/content-map.md`, `skills/sg-content/SKILL.md`, and existing `shipglows_data/workflow/research/tools.md`.

# Open Questions

None.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-05-22 12:22:56 UTC | sg-spec | GPT-5 Codex | Created ready spec from user-provided sg-veille gap list and local governance references. | ready | `/sg-skill-build sg-veille-governance-content-alignment` |
| 2026-05-22 12:22:56 UTC | sg-ready | GPT-5 Codex | Confirmed the spec is ready because scope, target files, content-gate behavior, paths, validation, and open questions are explicit. | ready | `/sg-skill-build sg-veille-governance-content-alignment` |
| 2026-05-22 12:27:46 UTC | sg-skill-build | GPT-5 Codex | Updated `sg-veille`, README, public skill page, refresh log, and the explicit deferred task; ran budget, runtime sync, metadata lint, focused rg checks, diff check, and Astro build. | implemented | `/sg-verify sg-veille-governance-content-alignment` |
| 2026-05-22 12:27:46 UTC | sg-verify | GPT-5 Codex | Verified the scenario-first pressure case, acceptance criteria, skill coherence, docs coherence, tracker update, runtime sync, metadata, and public site build. | verified | `no commit or push requested` |

# Current Chantier Flow

| Skill | Status | Notes |
| --- | --- | --- |
| sg-spec | ready | Ready spec created from concrete gap list. |
| sg-ready | ready | Scope, files, criteria, and validation are explicit. |
| sg-skill-build | implemented | Contract edits and validation complete. |
| sg-skills-refresh | completed | Refresh log records local governance refresh for `sg-veille`. |
| sg-verify | passed | Scenario-first proof path satisfied by focused checks and build. |
| sg-end | pending | Not started. |
| sg-ship | pending | Not started; no commit/push requested. |
