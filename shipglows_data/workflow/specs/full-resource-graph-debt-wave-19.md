---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: reviewed
source_skill: 100-sg-spec
scope: full-resource-graph-debt-wave-19
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want the remaining full-graph findings resolved or explicitly classified without fabricating dependencies or weakening profiled invocation checks."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - tools/resource_dependency_graph.py
  - shipglows_data/
  - skills/references/
depends_on:
  - artifact: shipglows_data/workflow/specs/full-resource-graph-debt-wave-18.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 19 baseline: 688 artifacts, 923 dependencies, zero cycles, and 89 full-graph findings."
  - "Wave 19 result: 689 artifacts, 912 dependencies, zero cycles, and 29 full-graph findings; all remaining findings are missing-target diagnostics and the profiled graph remains valid at 133 artifacts, 89 dependencies, and zero cycles."
next_step: "/005-sg-ship full resource graph debt wave 19"
---

# Full Resource Graph Debt — Wave 19

## Status

Reviewed. The bounded remediation is complete; the remaining diagnostic debt is explicitly classified and no dependency metadata was fabricated.

## Contract

Resolve the remaining safe path, status, version, and unversioned-target debt. Keep genuine missing artifacts and external dependencies visible. Do not add artifact metadata to generic README, template, or executable skill files solely to satisfy the graph.

## Acceptance Criteria

- [x] Canonical path migrations use existing semantically exact targets: 44 missing paths now resolve to proven canonical artifacts.
- [x] Status and version constraints match actual governed metadata or become provenance: all 10 original constraint findings are resolved.
- [x] Non-artifact README, template, and SKILL relationships leave `depends_on` safely: 6 unversioned edges were reclassified without fake artifact metadata.
- [x] No cycle is introduced and the profiled graph remains valid at 133 artifacts, 89 dependencies, and zero cycles; two candidate path migrations were reverted because they created inverse cycles.
- [x] Remaining findings are classified precisely.

## Result And Remaining Debt

The full `--all` diagnostic now measures 689 artifacts, 912 dependencies, zero cycles, and 29 findings, down from 688 artifacts, 923 dependencies, zero cycles, and 89 findings. Every remaining finding is a missing target. They are retained because they resolve to external resources, genuinely absent artifacts, old unversioned skill paths without a proven current equivalent, or candidate inverse relationships that would create cycles if migrated mechanically.

This result is intentionally truthful rather than green: generic README, template, and executable skill files did not receive fabricated governance metadata, and the two cycle-producing candidate migrations remain classified debt. The profiled execution graph is unchanged and valid at 133 artifacts, 89 dependencies, and zero cycles.

## Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 | 100-sg-spec | create | Wave 19 contract created from the 89 remaining diagnostic findings. |
| 2026-08-12 | 101-sg-ready | review | Ready for bounded path, constraint, and non-artifact-edge remediation. |
| 2026-08-12 | 102-sg-start | execute | Migrated 44 proven canonical paths, resolved 10 constraint findings, and reclassified 6 non-artifact unversioned edges. |
| 2026-08-12 | 900-shipglows-core | refresh | Reviewed canonical ownership, rejected fake metadata, and reverted two candidate migrations that introduced inverse cycles. |
| 2026-08-12 | 103-sg-verify | verify | Full diagnostic measured 689 artifacts, 912 dependencies, zero cycles, and 29 classified missing targets; profiled graph remained valid at 133/89/0. |
| 2026-08-12 | 104-sg-end | close | Accepted the bounded remediation and retained only truthful external, absent, legacy-path, or inverse-cycle missing-target debt. |

## Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900-shipglows-core refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
