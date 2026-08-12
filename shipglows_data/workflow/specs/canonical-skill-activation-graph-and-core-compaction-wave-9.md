---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 16:45:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 16:52:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: canonical-skill-activation-graph-and-core-compaction-wave-9
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want the existing invocation registry to prove every public-to-engine route before activation while keeping core maintenance compact."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core
  - skills/references/skill-invocation-registry.json
  - skills/references/skill-invocation-preflight.md
  - tools/skill_invocation_check.py
depends_on:
  - artifact: shipglows_data/workflow/specs/progressive-domain-activation-compaction-wave-8.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "The registry already represented 47 of 51 expert owners but did not enforce complete coverage."
  - "The invocation preflight validated names and modes but not owner/engine existence or coherence."
  - "900 body measured ~3.5k tokens before progressive mode compaction."
next_step: "/005-sg-ship canonical skill activation graph and core compaction wave 9"
---

# Title

Canonical skill activation graph and core compaction — wave 9

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want the existing invocation registry to prove every public-to-engine route before activation while keeping core maintenance compact.

# Minimal Behavior Contract

The invocation registry is the sole public-owner-to-engine graph. Explicit invocation blocks when a wrapper/engine is missing, an alias escapes its owner, or an expert has no public owner. Reference loading remains separate and is never inferred from prose. `900` keeps core context, authorization, improvement gates, and packaging boundary local while mode procedures load conditionally.

# Success Behavior

- Registry version 2.4 owns all 14 public wrappers and 51 expert engines.
- Invocation preflight validates graph coherence before accepting a command.
- `--audit-graph` reports deterministic graph metrics and errors.
- `900` body <=1,800 tokens and loads one mode pack before substantive work.

# Error Behavior

Missing engines, unowned experts, invalid owner modes, or cross-owner aliases produce a blocking graph error. Missing mode packs block rather than falling back to memory.

# Scope In

- registry, invocation checker/preflight, graph tests
- `skills/900-shipglows-core/**`
- directly affected technical doctrine, this spec, refresh log

# Scope Out

- reference-level activation manifest
- discovery overage/catalog removal
- public taxonomy or implicit-invocation policy changes

# Constraints

- No second registry or prose-derived graph.
- Preserve public wrapper and expert invocation compatibility.
- Keep reference `depends_on` governance separate.

# Test Contract

Current graph coverage; missing engine; unowned expert; alias outside owner; valid/invalid invocation; core context; audit/build/refresh/packaging modes; metadata, budget, fidelity, and runtime sync.

# Dependencies

Wave 8 reviewed. Fresh external docs not needed for local registry and instruction architecture.

# Invariants

- One canonical owner graph.
- Broken graph cannot activate an explicit command.
- `core` never targets the current project.
- Internal core is never packaged publicly.

# Links & Consequences

All public wrappers, expert aliases, internal engines, help/catalog, sync, and packaging consumers depend on the registry remaining coherent.

# Documentation Coherence

Runtime lifecycle, code-docs map, instruction layering, and context-budget doctrine distinguish owner graph from reference activation.

# Edge Cases

- Existing directory is omitted from every owner.
- Alias engine exists but belongs to another public owner.
- Hidden mode selects a missing engine.
- Custom test registry lacks graph enforcement and retains legacy checker behavior.
- Core critique quotes a project request without changing hard context.

# Implementation Tasks

- [x] Normalize four previously unowned experts into existing public owners.
- [x] Add graph validation and `--audit-graph` to the existing invocation checker.
- [x] Compact `900` into direct audit/build/refresh/packaging packs.
- [x] Update technical doctrine and scenario contracts.

# Acceptance Criteria

- [x] Graph reports 14 public, 51 expert, 51 owned, and no errors.
- [x] Broken engine, ownership, and alias scenarios block.
- [x] `900` is <=1,800 tokens with activation-critical boundaries local.
- [x] Metadata, fidelity, budget, runtime sync, and diff checks pass.

# Test Strategy

Graph unit scenarios, existing invocation/core consumers, then metadata/fidelity/budget/runtime sync.

# Risks

Overloading the owner graph with reference dependencies would recreate eager loading and false coupling; this is explicitly prohibited.

# Execution Notes

Extend the current preflight and registry. Do not create a standalone graph file.

# Open Questions

Reference-level activation profiles remain deferred until measured pilots justify their schema.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 16:45:00 | 100-sg-spec | create | Wave 9 graph/core contract created. |
| 2026-08-12 16:46:00 | 101-sg-ready | review | Ready: graph ownership and reference-graph exclusions are explicit. |
| 2026-08-12 16:49:00 | 102-sg-start | execute | Registry graph, blocking preflight, graph scenarios, and compact core packs implemented. |
| 2026-08-12 16:50:00 | 900-shipglows-core | refresh | Verified exact core context, alias ownership, docs coherence, and progressive mode loading. |
| 2026-08-12 16:52:00 | 103-sg-verify | verify | Graph/core consumers, metadata, fidelity, budget, and Codex runtime sync passed. |
| 2026-08-12 16:52:00 | 104-sg-end | close | Wave 9 closed as reviewed; reference activation profiles remain deferred. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
