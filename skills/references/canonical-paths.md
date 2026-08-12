---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.1.0"
project: ShipGlows
created: "2026-04-27"
updated: "2026-08-12"
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
  - "Repeated failures showed that project cwd and ShipGlows installation ownership must remain distinct."
  - "Governance decisions require one project-root shipglows_data corpus, with documented standalone exceptions."
  - "The 2026-08-11 runtime layout standardizes Linux and Windows installs under ~/.shipglows/runtime."
next_review: "2026-09-03"
next_step: "/103-sg-verify canonical path policy"
---

# ShipGlows Canonical Paths

Resolve paths by ownership, never by filename coincidence or the current working directory.

## Mandatory Roots

- ShipGlows runtime root: `$SHIPGLOWS_ROOT`, defaulting to the current user's `.shipglows/runtime` directory on Linux and Windows.
- Project root: the current working directory unless the operator selects another project.
- Governance root: the repository root for a single project, or the monorepo root rather than an app/package subdirectory.

Treat environment values as paths, preserve spaces, and use the active shell's safe path handling. Resolve an owned target beneath its declared root; do not accept `..`, symlink, junction, or shadow-directory traversal outside that root.

## Ownership Rules

- ShipGlows-owned skills, references, tools, templates, workflow docs, and internal scripts resolve from `$SHIPGLOWS_ROOT`.
- `references/foo.md` inside a skill means `$SHIPGLOWS_ROOT/skills/<skill-name>/references/foo.md`, never project `./references/foo.md`.
- Project source resolves from the selected project root. Project governance resolves from the governance-root `shipglows_data/` corpus.
- A project-local `skills/`, `tools/`, or `templates/` directory never shadows the ShipGlows installation.
- If an owned file is absent from `$SHIPGLOWS_ROOT`, report an installation gap. Do not substitute a project copy, continue from memory, or report it missing merely because it is absent from the project.

## ShipGlows-Owned Tool Preflight

Before running a ShipGlows-owned tool:

1. resolve `$SHIPGLOWS_ROOT`
2. confirm the owned parent path exists beneath that root
3. confirm the exact target tool exists and remains beneath that root
4. run it with arguments passed safely for the active platform

Do not infer the tool path from the project cwd. If the check remains agent-runnable, do not ask the operator to run it.

## Direct Conditional Routes

- Local service state, private data, inspiration storage, or legacy compatibility: load `skills/references/canonical-runtime-and-private-roots.md` directly.
- Project governance placement, legacy migration, workflow families, or artifact destinations: load `skills/references/canonical-project-governance-placement.md` directly.
- Monorepo source topology (`site/`, `app/`, `backend/`, `ext/`, packages): load `skills/references/monorepo-governance-topology.md` directly.
- Ranked or expanded resource discovery: load `skills/references/resource-discovery.md` before using `tools/resource_resolver.py` results. Recommendations supplement mandatory owner, safety, freshness, and project-truth gates; they never replace them.

Load only the branch required by the current decision. These routes are siblings and never require one another.
