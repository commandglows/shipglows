---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 18:19:03 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 18:27:09 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: high-traffic-activation-profiles-wave-14
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want high-traffic owners to expose measurable activation profiles so expensive gates are visible and inconsistent resources fail before activation."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/SKILL.md
  - skills/300-sg-docs/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/references/skill-invocation-registry.json
  - tools/skill_activation_budget.py
  - tools/resource_dependency_graph.py
depends_on:
  - artifact: shipglows_data/workflow/specs/executable-resource-graph-and-progressive-reporting-wave-13.md
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 13 proved explicit activation accounting and dependency closure on 004, 601, and 900."
  - "010, 300, and 103 are high-traffic owners with multiple direct conditional playbooks and shared gates."
next_step: "/005-sg-ship high traffic activation profiles wave 14"
---

# Title

High-traffic activation profiles — wave 14

# Status

Reviewed. Six activation profiles are valid. This wave measures the three new
owners without compacting them; the next tranche owns shared-baseline
remediation.

# Minimal Behavior Contract

Add explicit registry profiles for `010-sg-technical`, `300-sg-docs`, and `103-sg-verify`. Each profile declares the existing body, only genuinely mandatory pre-decision references as baseline, and direct conditional gates matching mechanical loaders already present in the owner contract. Profiles account and preflight; they do not replace runtime loaders, create new modes, or make conditional references eager.

# Success Behavior

- Every selected owner reports body, baseline, independent gate, and unique worst-case estimates.
- Selected invocation fails closed when any profiled root or explicit dependency is inconsistent.
- Mode families remain direct and non-chaining.
- Existing owner, safety, proof, report, and runtime behavior remains unchanged.

# Error Behavior

Missing paths, inaccurate eager baselines, collapsed mutually exclusive modes, undeclared direct loaders, or profile/runtime drift block completion. A large worst case is reported as measurement evidence, not hidden by removing required proof.

# Scope In

- activation profiles for `010`, `300`, and `103`
- focused profile, dependency, invocation, owner-consumer, budget, metadata, and sync tests
- Wave 14 documentation and refresh trace

# Scope Out

- compaction of the profiled bodies or references
- activation profiles for every remaining skill
- full-corpus `--all` dependency-debt cleanup
- discovery taxonomy or implicit-invocation changes

# Acceptance Criteria

- [x] Six activation profiles (`004`, `103`, `300`, `601`, `900`, `010`) validate without missing resources.
- [x] Each new profile has a bounded baseline and independently selectable direct gates.
- [x] Focused owner and graph contracts pass without changing owner semantics.
- [x] Measured hotspots and next compaction candidates are recorded honestly.
- [x] Metadata, fidelity, budget, Codex runtime sync, and chantier trace pass.

# Implementation Tasks

- [x] Audit exact loaders and pressure scenarios for all three owners.
- [x] Add registry profiles and scenario-first profile tests.
- [x] Validate executable dependency closure and invocation preflight.
- [x] Refresh budget/lifecycle docs and log.
- [x] Verify and close as reviewed; commit and push remain the ship gate.

# Measurements And Next Debt

Wave 14 records selected-baseline estimates of 11,361 tokens for
`010-sg-technical`, 9,517 for `103-sg-verify`, and 6,791 for `300-sg-docs`.
These figures expose cost; they are not passing budget claims and were not
reduced in this wave.

The next compaction tranche should address repeated shared baseline weight,
starting with `canonical-paths.md`, `intent-to-outcome-autonomy.md`, and
`decision-quality-contract.md`. It must preserve owner, safety, proof, and
freshness semantics rather than hiding those resources from profiles.

# Risks

Treating all named references as baseline would inflate normal activation and defeat progressive disclosure. Omitting security, freshness, proof, or reporting gates would make the profile look cheap but untruthful. The profile must mirror direct loader decisions exactly.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 18:19:03 | 100-sg-spec | create | Wave 14 contract created for three high-traffic activation profiles. |
| 2026-08-12 18:19:03 | 101-sg-ready | review | Ready: owners, boundaries, failure behavior, tests, and non-goals are explicit. |
| 2026-08-12 18:27:09 | 102-sg-start | implement | Added direct profiles for 010, 103, and 300 without changing owner loaders. |
| 2026-08-12 18:27:09 | 900-shipglows-core | refresh | Recorded six-profile accounting, executable closure, and honest baseline hotspots. |
| 2026-08-12 18:27:09 | 103-sg-verify | verify | Focused profile, graph, metadata, budget, and Codex sync contracts passed; the absent local Claude catalogue is outside this wave. |
| 2026-08-12 18:27:09 | 104-sg-end | close | Closed Wave 14 as reviewed; shared-baseline compaction remains a separate tranche. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
