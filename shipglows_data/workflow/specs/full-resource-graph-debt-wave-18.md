---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: reviewed
source_skill: 100-sg-spec
scope: full-resource-graph-debt-wave-18
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want the full resource graph debt reduced without making historical records executable or weakening the clean profiled preflight graph."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - tools/resource_dependency_graph.py
  - shipglows_data/
  - skills/references/
depends_on:
  - artifact: shipglows_data/workflow/specs/technical-and-verification-baseline-wave-17.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 18 baseline: 687 artifacts, 998 dependencies, 3 cycles, and 272 full-graph findings."
  - "Wave 18 result: 688 artifacts, 923 dependencies, zero cycles, and 89 full-graph findings; the profiled graph remains valid at 133 artifacts, 89 dependencies, and zero cycles."
next_step: "/005-sg-ship full resource graph debt wave 18"
---

# Full Resource Graph Debt — Wave 18

## Status

Reviewed. The first remediation batch and debt classification are complete; the full diagnostic graph is intentionally not yet claimed valid.

## Contract

Repair the full diagnostic graph in evidence-backed batches. Preserve the clean profiled execution graph. Never invent a missing artifact, reactivate historical material, or replace provenance with an unrelated current document merely to make the audit green.

## First Batch

- break the three known dependency cycles at the correct ownership edge;
- repair safe version/status constraints from existing target metadata;
- classify missing targets and implement only canonical, high-confidence migrations;
- leave ambiguous historical debt visible with an explicit follow-up classification.

## Acceptance Criteria

- [x] Full-graph cycle count is zero.
- [x] Constraint findings decrease without fabricated metadata: 79 safe version/status constraints were repaired.
- [x] Missing dependencies have a measured classification and safe next batch: 13 active canonical paths were migrated and 73 historical edges were reclassified as evidence.
- [x] Profiled graph remains valid at 133 artifacts, 89 dependencies, and zero cycles.
- [x] Metadata lint and focused graph tests pass.

## Remaining Debt

The full `--all` diagnostic now measures 688 artifacts, 923 dependencies, zero cycles, and 89 findings. It remains invalid and non-blocking for skill invocation. The remaining findings are 73 missing targets, 6 status mismatches, 6 unversioned targets, 3 invalid required-version constraints, and 1 invalid actual status. Terminal `stale`/`superseded` history is valid only in diagnostic mode; it remains forbidden in profiled execution.

## Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 | 100-sg-spec | create | Wave 18 contract created from the measured full-graph debt. |
| 2026-08-12 | 101-sg-ready | review | Ready for cycle repair, safe constraint normalization, and missing-target classification. |
| 2026-08-12 | 102-sg-start | execute | Broke 3 cycles, repaired 79 constraints, migrated 13 active canonical paths, and reclassified 73 historical dependency edges as evidence. |
| 2026-08-12 | 900-shipglows-core | refresh | Reviewed ownership, historical/evidence boundaries, and truthful remaining-debt reporting. |
| 2026-08-12 | 103-sg-verify | verify | Focused graph and metadata proof passed; profiled graph valid, full graph improved but still diagnostic with 89 findings. |
| 2026-08-12 | 104-sg-end | close | First Wave 18 remediation batch accepted; remaining debt explicitly retained for later evidence-backed batches. |

## Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900-shipglows-core refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
