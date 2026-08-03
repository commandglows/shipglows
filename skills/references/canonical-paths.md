---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.8.0"
project: ShipGlows
created: "2026-04-27"
updated: "2026-08-03"
status: active
source_skill: 102-sg-start
scope: canonical-path-resolution
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - tools/
  - templates/
  - shipglows_data/
depends_on: []
supersedes: []
evidence:
  - "Repeated skill path-resolution failures when running from project repositories"
  - "Project governance layout decision moved ShipGlows artifacts out of project roots and into shipglows_data/."
  - "Operator decision on 2026-05-24: monorepos must keep one governance corpus at the monorepo root instead of repeating shipglows_data in each app/package."
  - "Operator decision on 2026-06-28: generated build and preview folders such as .vercel/output remain disposable local outputs, not canonical project artifacts."
  - "Operator clarification on 2026-07-13: root compliance is determined by documentary and architecture ownership contracts, with explicit QA, bug, public-reference, and historical exceptions."
  - "Operator decision on 2026-07-13: archived governance history must resolve under shipglows_data/workflow/archives instead of a root archive directory."
  - "Operator decision on 2026-07-13: root docs and bug workflow paths must migrate into canonical technical and workflow families."
  - "Operator decision on 2026-07-23: flat source roots at the monorepo root (site/, app/, backend/, packages/) are the preferred canonical shape for projects using the Astro plus Flutter plus backend split; nested apps/* packaging is allowed only with a documented durable exception."
  - "Operator decision on 2026-08-03: canonical ShipGlows resources use governed progressive discovery rather than ad hoc path search when the activation contract needs supporting references."
next_review: "2026-09-03"
next_step: "/103-sg-verify canonical path policy"
---

# ShipGlows Canonical Paths

ShipGlows skills often run from a project repository, but ShipGlows-owned tools and references live in the ShipGlows installation. Resolve paths by ownership, not by the current working directory.

## Roots

- ShipGlows root: `${SHIPGLOWS_ROOT:-$HOME/shipglows}`
- Legacy tracking compatibility path: `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}` (read-only historical, not active source of truth)
- Project root: current working directory, unless the user explicitly gives another project path
- Governance root: the nearest canonical root for project-owned ShipGlows artifacts. In a single-project repo, this is the repository root. In a monorepo, this is the monorepo root, not an app/package subdirectory.

## Resolution Rules

- ShipGlows-owned tools, shared references, skill references, templates, workflow docs, and internal scripts must be loaded from `$SHIPGLOWS_ROOT`.
- Skill-local references such as `references/foo.md` mean `$SHIPGLOWS_ROOT/skills/<skill-name>/references/foo.md`, not `./references/foo.md` in the project repo.
- Project-owned artifacts are resolved from the governance-root `shipglows_data` umbrella.

  - `shipglows_data/technical/*`
  - `shipglows_data/business/*`
  - `shipglows_data/editorial/*`
  - `shipglows_data/workflow/*`

- In monorepos, prefer theme-first paths inside `shipglows_data/`, then scope by surface only when needed, for example:

  - `shipglows_data/branding/branding.md`
  - `shipglows_data/branding/voice-and-tone.md`
  - `shipglows_data/branding/visual-identity.md`
  - `shipglows_data/business/site/business.md`
  - `shipglows_data/product/app/product.md`
  - `shipglows_data/technical/site/*`

- Root compatibility exceptions remain at repository root:

  - `AGENT.md`
  - `CLAUDE.md`
  - `README.md`
  - `AGENTS.md` (must be a compatibility symlink to `AGENT.md`)
  - `CHANGELOG.md` (optional public/project changelog)

- `shipglows_data/` remains the project governance corpus for this phase; the external `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}` is legacy, read-only, and not used as project-document source of truth.
- Monorepo rule: keep exactly one canonical `shipglows_data/` at the monorepo root. Do not create parallel `shipglows_data/` directories inside `apps/*`, `packages/*`, or sibling app/site/lab folders unless that subdirectory is intentionally a separately cloned and shipped standalone project.
- When running from a monorepo subdirectory, source files resolve from the target subdirectory but governance artifacts resolve from the monorepo root `shipglows_data/`.
- If both a monorepo root `shipglows_data/` and nested subproject `shipglows_data/` directories exist, treat nested copies as migration debt unless the repo documents a standalone exception.
- `shipglows_data/workflow/` holds project-level workflow artifacts such as `specs/`, `shipglows_data/workflow/bugs/`, `audits/`, `reviews/`, `verification/`, and project-local operational trackers.
- Root `archive/`, `bugs/`, `docs/`, `specs/`, `research/`, `BUGS.md`, and `TEST_LOG.md` are migration sources. Preserve useful inactive history under `shipglows_data/workflow/archives/<bounded-scope>/`; keep bug, QA, conversation, and exploration records under `shipglows_data/workflow/`; keep operator guides under `shipglows_data/technical/operator-guides/`.
- `shipglows_data/workflow/playbooks/` holds reusable transversal operating playbooks shared across projects or business domains.
- `shipglows_data/workflow/checklists/` holds reusable non-test checklists paired to shared playbooks.
- `shipglows_data/workflow/test-checklists/` holds executed manual proof artifacts, not the reusable checklist library.
- Project-local `TASKS.md` and `AUDIT_LOG.md` live at `shipglows_data/workflow/TASKS.md` and `shipglows_data/workflow/AUDIT_LOG.md`. Root `TASKS.md` and `AUDIT_LOG.md` are legacy project tracker locations unless an external project tool explicitly requires them.
- `PROJECTS.md` is a legacy compatibility artifact when present in `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}`; treat it as migration/degraded-discovery input only, not primary governance.
- Legacy root ShipGlows governance files such as `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, `TASKS.md`, and `AUDIT_LOG.md` are migration sources only. They are not compliant project artifact locations.
- Generated local-output directories such as `node_modules/`, `dist/`, `.astro/`, `.vercel/`, `.vercel/output/`, and `.playwright-mcp/` are disposable runtime artifacts, not governance artifacts, evidence artifacts, or source-of-truth project documents.
- If a ShipGlows-owned file is missing from `$SHIPGLOWS_ROOT`, report a ShipGlows installation gap. Do not report it missing just because it is absent from the project repository.

## Source Root Conventions

ShipGlows does not mandate one universal source tree shape, but when a project uses the canonical public-site + application + backend split, prefer flat application roots at the monorepo root instead of nested `apps/*` bundles.

Preferred canonical source roots:

- `site/` — public web surface
- `app/` — application surface
- `backend/` — data, migrations, server-side authority
- `packages/` or `packages/contracts/` — shared typed contracts when cross-surface contracts are versioned separately

Anti-patterns:

- `apps/site/`, `apps/app/`, `apps/backend/`
- duplicating the same logical surface under multiple root folders because of historical package boundaries
- burying the governance corpus under a source app folder; governance stays at the monorepo root

Resolution rule:

- source files resolve from their logical root folder
- governance artifacts always resolve from the monorepo root `shipglows_data/`, regardless of where the source root lives
- build, workspace, and deployment configs should be reachable from the monorepo root without assuming nested package management unless the project documents a durable exception

## ShipGlows-Owned Tool Preflight

Before running any ShipGlows-owned tool, follow this preflight order exactly:

1. resolve `$SHIPGLOWS_ROOT`
2. confirm the owned path exists under `$SHIPGLOWS_ROOT`
3. confirm the target tool file exists
4. run the tool

Do not infer ShipGlows-owned tool paths from the current working directory. If this preflight is still agent-runnable, do not ask the operator to run the tool instead.

## Progressive Resource Discovery

After selecting a skill and mode for non-trivial work, use `tools/resource_resolver.py` when supporting references or playbooks are not already sufficient. Load `skills/references/resource-discovery.md` before relying on ranked or expanded results. Existing activation-critical loaders remain mandatory during migration; resolver recommendations supplement them and never replace owner, safety, freshness, or project-truth gates automatically.

## Canonical Project Artifact Map

| Legacy root file | Canonical project path |
| --- | --- |
| `BUSINESS.md` | `shipglows_data/business/<surface>/business.md` or shared `shipglows_data/business/business.md` |
| `PRODUCT.md` | `shipglows_data/product/<surface>/product.md` or shared `shipglows_data/product/product.md` |
| `BRANDING.md` | shared `shipglows_data/branding/branding.md` with optional sibling brand bundle files under `shipglows_data/branding/` |
| `GTM.md` | `shipglows_data/gtm/<surface>/gtm.md` or shared `shipglows_data/gtm/gtm.md` |
| `INSPIRATION.md` | `shipglows_data/business/<surface>/project-competitors-and-inspirations.md` |
| `AFFILIATES.md` | `shipglows_data/business/<surface>/affiliate-programs.md` |
| `CONTEXT.md` | `shipglows_data/technical/<surface>/context.md` |
| `CONTEXT-FUNCTION-TREE.md` | `shipglows_data/technical/<surface>/context-function-tree.md` |
| `ARCHITECTURE.md` | `shipglows_data/technical/<surface>/architecture.md` |
| `GUIDELINES.md` | `shipglows_data/technical/<surface>/guidelines.md` |
| `CONTENT_MAP.md` | `shipglows_data/editorial/<surface>/content-map.md` |
| `TASKS.md` | `shipglows_data/workflow/TASKS.md` |
| `AUDIT_LOG.md` | `shipglows_data/workflow/AUDIT_LOG.md` |
| `specs/*.md` | `shipglows_data/workflow/specs/*.md` |

## Command Pattern

```bash
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/shipglows}"
"$SHIPGLOWS_ROOT/tools/shipglows_metadata_lint.py"
```

Use the same pattern for other ShipGlows-owned tools and scripts.
