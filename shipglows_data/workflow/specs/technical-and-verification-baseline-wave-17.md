---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: reviewed
source_skill: 100-sg-spec
scope: technical-and-verification-baseline-wave-17
owner: Diane
confidence: high
user_story: "As a ShipGlows operator, I want technical routing and verification to retain their critical decisions while loading less than 5,000 tokens before their first substantive decision."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/
  - skills/103-sg-verify/
  - skills/references/skill-invocation-registry.json
depends_on:
  - artifact: shipglows_data/workflow/specs/progressive-monolithic-workflows-wave-16.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "After Wave 16, measured baselines remain 6177 tokens for 010 and 5657 for 103."
next_step: "/005-sg-ship technical and verification baseline wave 17"
---

# Technical And Verification Baseline — Wave 17

## Status

Reviewed.

## Contract

Reduce the selected activation baselines of `010-sg-technical` and `103-sg-verify` below 5,000 tokens without hiding ownership, mode selection, verdict precedence, authority, security, product, proof, stop, or reporting decisions behind optional detail.

## Acceptance Criteria

- [x] `010-sg-technical` selected baseline is `6,177 -> 4,562` tokens.
- [x] `103-sg-verify` selected baseline is `5,657 -> 4,907` tokens.
- [x] Existing public and explicit invocations preserve their owners and modes.
- [x] Conditional procedure uses direct leaves without sibling chaining.
- [x] Compatibility literals and consumer contracts remain green.
- [x] Graph, metadata, fidelity, budget, runtime sync, and focused scenarios pass.

## Tasks

- [x] Compact the 010 activation core and baseline route.
- [x] Compact the 103 activation core and verification baseline.
- [x] Refresh activation profiles, measurements, docs, and trace.
- [x] Verify and close; commit and push remain with `005-sg-ship`.

## Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 | 100-sg-spec | create | Wave 17 contract created for the two remaining baselines above 5,000 tokens. |
| 2026-08-12 | 101-sg-ready | review | Ready: targets, critical decisions, compatibility, and proof are explicit. |
| 2026-08-12 | 102-sg-start | execute | Compacted 010 behind conditional semantic-mode routing and split 103 procedure into direct `verification-release-proof` and `verification-ci` leaves. |
| 2026-08-12 | 900-shipglows-core | refresh | Refreshed activation metadata while preserving compatibility paths, owner boundaries, and non-chaining leaves. |
| 2026-08-12 | 103-sg-verify | verify | Passed focused contracts, metadata, graph, budget, fidelity, and runtime-sync checks; baselines are 4,562 and 4,907. |
| 2026-08-12 | 104-sg-end | close | Closed Wave 17 with both selected baselines below 5,000 tokens and no unresolved acceptance item. |

## Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
