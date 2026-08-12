---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 18:00:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 18:00:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: executable-resource-graph-and-progressive-reporting-wave-13
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want profiled execution to fail before activation when explicit resource dependencies are inconsistent, while reporting loads only the detail required by the selected report mode."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/resource_dependency_graph.py
  - tools/skill_invocation_check.py
  - skills/references/skill-invocation-registry.json
  - skills/references/reporting-contract.md
  - skills/references/reporting-agent-handoff.md
  - skills/references/reporting-blocked-and-audit.md
  - skills/references/reporting-pressure-scenarios.md
depends_on:
  - artifact: shipglows_data/workflow/specs/shared-activation-cores-and-entitlement-doctrine-wave-12.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 13 adds an executable dependency-closure check to the existing ownership preflight instead of inferring dependencies from prose."
  - "The shared reporting contract had independent handoff, blocked/audit, and maintenance detail that did not need to load for every successful user report."
next_step: "/005-sg-ship executable resource graph and progressive reporting wave 13"
---

# Title

Executable resource graph and progressive reporting — wave 13

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want profiled execution to fail before activation when explicit resource dependencies are inconsistent, while reporting loads only the detail required by the selected report mode.

# Minimal Behavior Contract

The invocation preflight combines the registry ownership graph with the explicit dependency closure of activation-profile resources. The closure follows `skills/**` dependencies transitively; a profiled `shipglows_data/**` resource is validated as a terminal project-governance leaf. Every traversed dependency must declare a minimum semantic version and exact required status, every selected artifact must expose a valid semantic version and supported status, and reachable cycles block activation.

The default resource-graph command validates only this executable profiled closure. `--all` remains a diagnostic audit of historical corpus debt and is non-blocking for invocation. Reporting keeps one compact core plus three direct conditional leaves: agent handoff, blocked/audit, and pressure scenarios. Explicit `report=agent` has sole priority over the blocked/audit leaf because the handoff leaf already owns detailed risks and audit state.

# Success Behavior

- Explicit invocation returns `valid` only after ownership and selected resource-closure preflights both pass.
- `skills/**` dependency traversal is transitive and checks existence, version, status, and cycles.
- Profiled `shipglows_data/**` artifacts are validated as terminal governance leaves without recursively importing the project corpus.
- A normal successful `report=user` loads only the reporting core.
- Conditional report detail is selected directly; leaves never chain to sibling leaves.

# Error Behavior

Missing or unversioned roots, missing dependency constraints, absent targets, incompatible versions/statuses, invalid actual metadata, or reachable cycles fail closed with deterministic errors. Historical errors found by `--all` remain visible diagnostic debt and do not invalidate an otherwise coherent profiled invocation.

# Scope In

- executable profiled resource-dependency graph
- combined ownership and dependency invocation preflight
- `900-shipglows-core` activation profile
- compact reporting core and three direct conditional leaves
- focused tests, technical documentation, context-budget evidence, and refresh trace

# Scope Out

- inference of dependencies from prose or `linked_systems`
- automatic repair of every historical dependency in the full corpus
- recursive traversal beyond profiled `shipglows_data/**` governance leaves
- dependency visualization UI
- conversion of every skill to an activation profile

# Constraints

- Runtime loaders remain the execution authority; activation profiles declare the executable accounting/preflight surface.
- The advisory resource resolver remains separate from the blocking explicit dependency graph.
- `--all` must not be represented as a passing prerequisite while historical debt remains.
- `report=agent` is explicit and exclusive; it does not combine with the blocked/audit leaf.

# Test Contract

Profile closure validity, transitive cross-tree reachability up to project leaves, missing version/status constraints, actual metadata validity, version/status mismatch, missing targets, reachable cycles, selected-invocation blocking, reporting branch selection, compatibility consumers, metadata, budget, fidelity, and runtime sync.

# Dependencies

Wave 12 is reviewed. The canonical invocation registry and explicit `depends_on` metadata remain the only machine-readable inputs.

# Invariants

- No dependency edge is inferred from prose.
- A valid ownership route cannot bypass an invalid selected dependency closure.
- Project-governance leaves are checked but do not expand the entire project corpus during profiled preflight.
- Reporting leaves are direct and conditional; agent mode has one detailed-report authority.

# Implementation Tasks

- [x] Add the explicit resource-dependency graph and focused contracts.
- [x] Combine ownership and profiled dependency checks in invocation preflight.
- [x] Add the `900-shipglows-core` activation profile and align reachable metadata.
- [x] Split reporting into a compact core and three direct conditional leaves.
- [x] Refresh technical doctrine, code/docs ownership, budget guidance, and lifecycle trace.

# Acceptance Criteria

- [x] Default dependency audit validates the executable activation-profile closure.
- [x] Selected profiled invocation fails closed on dependency inconsistency.
- [x] Full-corpus `--all` remains an explicit non-blocking diagnostic.
- [x] Reporting branch selection preserves user, agent, blocked/audit, and maintenance behavior without sibling chaining.
- [x] Focused graph, invocation, reporting, chantier, and metadata checks pass.

# Test Strategy

Run graph and invocation unit contracts first, reporting compatibility contracts second, then chantier trace and metadata lint. The integration owner runs the wider fidelity, budget, and runtime-sync suite.

# Risks

Calling the profiled closure a complete corpus graph would hide historical debt; recursively expanding project-governance dependencies would also make invocation cost and authority unpredictable. Both boundaries remain explicit in code and documentation.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 18:00:00 | 100-sg-spec | create | Wave 13 contract records the executable graph and progressive-reporting boundaries. |
| 2026-08-12 18:00:00 | 101-sg-ready | review | Ready: ownership, closure, project-leaf, diagnostic-debt, and reporting-priority semantics are explicit. |
| 2026-08-12 18:00:00 | 102-sg-start | execute | Added graph/preflight integration, profile metadata, reporting leaves, and focused contracts. |
| 2026-08-12 18:00:00 | 706-continue | document | Aligned durable spec, refresh log, technical doctrine, code/docs map, and chantier regression coverage. |
| 2026-08-12 18:00:00 | 103-sg-verify | verify | Focused graph, invocation, reporting, chantier, and metadata checks passed; wider integration proof remains owned by the integrator. |
| 2026-08-12 18:00:00 | 104-sg-end | close | Wave 13 closed as reviewed; full-corpus dependency debt remains a separate diagnostic backlog. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
