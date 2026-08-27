---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.5.0"
project: ShipGlows
created: "2026-04-27"
updated: "2026-08-27"
status: active
source_skill: 102-sg-start
scope: canonical-path-resolution
owner: Diane
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
  - "Governance uses one project-root shipglows_data corpus."
  - "The 2026-08-11 runtime layout uses ~/.shipglows/runtime on Linux and Windows."
  - "The 2026-08-14 mutation gate follows target resolution."
next_review: "2026-09-03"
next_step: "/103-sg-verify canonical path policy"
---

# ShipGlows Canonical Paths

Resolve paths by ownership, never by filename coincidence or cwd. Before mutation, load `skills/references/mutation-plan-approval.md` from the resolved root and obtain its defined authority; a qualifying exact micro-request supplies authority only for that micro-mutation and does not authorize a chantier, while every other path retains the required post-message approval. Read-only resolution may precede either path.

## Mandatory Roots

- ShipGlows root: resolve `$SHIPGLOWS_ROOT` from the process. On Windows, if empty, read its current-user environment value, then `%USERPROFILE%\.shipglows\development-channel.json`; a valid absolute `channel: linked` root containing `skills/000-shipglows/SKILL.md` wins. This supports an already running agent that missed environment updates. Otherwise use the user's `.shipglows/runtime`; Linux uses the exported value, then that default.
- Project root: the current working directory unless the operator selects another project.
- Governance root: the repository root for a single project, or the monorepo root rather than an app/package subdirectory.

Treat values as paths, preserve spaces, and reject `..`, symlink, junction, shadow-directory, or nearby-checkout inference outside the owned root.

## Ownership Rules

- ShipGlows skills, references, tools, templates, workflow docs, and scripts resolve from `$SHIPGLOWS_ROOT`; project-local names never shadow them.
- A project-local `skills/`, `tools/`, or `templates/` directory never shadows the installation.
- Skill `references/foo.md` means `$SHIPGLOWS_ROOT/skills/<skill>/references/foo.md`.
- Project source uses the selected project root; governance uses its root `shipglows_data/`.
- If an owned file is absent from `$SHIPGLOWS_ROOT`, report an installation gap. Do not substitute a project copy, continue from memory, or search the project.

## ShipGlows-Owned Tool Preflight

Resolve `$SHIPGLOWS_ROOT`; confirm the exact target tool exists and remains beneath that root; pass arguments safely. Never infer from project cwd or ask the operator to run an agent-runnable check.

## Direct Conditional Routes

- Runtime/private roots or legacy compatibility -> `canonical-runtime-and-private-roots.md`.
- Governance placement, migration, workflow families, or destinations -> `canonical-project-governance-placement.md`.
- Monorepo topology -> `monorepo-governance-topology.md`.
- Ranked discovery -> `resource-discovery.md` before `tools/resource_resolver.py`; recommendations never replace owner, safety, freshness, or project truth.

Load only the required branch. These routes are siblings and never require one another.
