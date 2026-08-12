---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-13"
status: reviewed
source_skill: 100-sg-spec
scope: full-resource-graph-closure-wave-20
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want every remaining full-graph relationship classified by its real ownership so the complete resource graph is valid without fake metadata or cross-project governance leakage."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - tools/resource_dependency_graph.py
  - shipglows_data/
  - skills/
depends_on:
  - artifact: shipglows_data/workflow/specs/full-resource-graph-debt-wave-19.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 20 baseline inherited 689 artifacts, 912 dependencies, zero cycles, and 29 missing-target findings from Wave 19."
  - "Wave 20 result after integration with the Playwright MCP closeout on main: the full graph is valid with 691 artifacts, 895 dependencies, zero cycles, and zero findings; the profiled execution graph remains valid at 133 artifacts, 89 dependencies, and zero cycles."
next_step: "/005-sg-ship full resource graph closure wave 20"
---

# Full Resource Graph Closure — Wave 20

## Status

Reviewed. The complete and profiled graphs are both valid. No generic runtime file was given fabricated artifact metadata, and no unrelated project authority was imported into ShipGlows governance.

## Contract

Classify each remaining graph relationship by consequence:

- canonical ShipGlows documentation stays in `depends_on` with verified version and status;
- executable skills, shims, APIs, and runtime surfaces belong in `linked_systems`;
- external or historical evidence remains evidence only when it explains a past decision;
- unrelated project architecture, branding, product doctrine, or instruction files do not govern ShipGlows;
- inverse relationships are oriented toward one authority rather than hidden behind a cycle;
- a missing planning artifact is removed when its contract is already fully owned by an implemented canonical artifact.

## Acceptance Criteria

- [x] Every Wave 19 residual finding is reviewed individually or as one semantically inseparable owner group.
- [x] Canonical migrations preserve actual version/status contracts.
- [x] Runtime `SKILL.md`, `.agents`, and `.opencode` surfaces are not misrepresented as versioned documentation.
- [x] External APIs and other-repository files do not remain executable ShipGlows dependencies.
- [x] The historical `sf-build` filename is renamed to the canonical `sg-build` spelling and all active references follow it.
- [x] Hidden-directory path normalization preserves `.agents` and `.opencode` exactly.
- [x] The profiled graph remains valid at 133 artifacts, 89 dependencies, and zero cycles.
- [x] The complete `--all` graph is valid at 691 artifacts, 895 dependencies, and zero cycles.

## Result

Wave 20 closes the 29 remaining missing-target findings. It migrates canonical branding, model-routing, lifecycle, design, exploration, parity, entitlement, and governance paths; reclassifies executable/runtime surfaces; removes inverse spec edges; removes other-project governance; and replaces three never-created TUI planning dependencies with the implemented TUI contract already present in this repository.

The graph path normalizer now removes only the explicit `./` prefix. It no longer corrupts hidden runtime directories by turning `.agents` into `agents` or `.opencode` into `opencode`.

This green graph is a semantic result, not a cosmetic one: twenty invalid executable, external, inverse, obsolete, and fictional edges were removed or reclassified, then this trace artifact added one governed dependency, yielding 893 final dependencies from the 912 baseline.

## Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-13 | 900-shipglows-core | audit | Reviewed the 29 residual findings one by one with the operator, preserving canonical owners and rejecting cross-project governance. |
| 2026-08-13 | 102-sg-start | execute | Applied canonical path migrations, runtime/external reclassifications, inverse-edge corrections, TUI contract consolidation, and the `sf-build` to `sg-build` spec rename. |
| 2026-08-13 | 103-sg-verify | verify | Full graph passed at 691/895/0 with zero findings after integrating current main; profiled graph passed at 133/89/0; graph, invocation, activation, metadata, skill audit, and diff checks passed. |
| 2026-08-13 | 104-sg-end | close | Closed the bounded graph-debt programme without inventing metadata or importing unrelated project doctrine. |

## Current Chantier Flow

`900-shipglows-core audit -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
