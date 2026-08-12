---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 17:18:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 17:22:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: installed-skill-discovery-budget-remediation-wave-11
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want the complete installed catalogue below its discovery ceiling without weakening public routing triggers."
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - tools/skill_budget_audit.py
  - skills/references/skill-context-budget.md
depends_on:
  - artifact: shipglows_data/workflow/specs/release-entitlement-compaction-and-activation-profile-wave-10.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Installed runtime measured 8670/8500 before remediation."
  - "Public implicit catalogue already passed and was left unchanged."
next_step: "/005-sg-ship installed skill discovery budget remediation wave 11"
---

# Title

Installed skill discovery budget remediation — wave 11

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want the complete installed catalogue below its discovery ceiling without weakening public routing triggers.

# Minimal Behavior Contract

Compact descriptions only for expert/legacy engines whose invocation is explicit. Preserve high-signal domain and action nouns, exact skill names, public wrapper descriptions, ownership graph, and runtime inventory.

# Success Behavior

- Installed lexical estimate <=8,500 with useful margin.
- Public implicit estimate remains unchanged.
- No description warning or trigger-vocabulary regression.

# Error Behavior

A generic, ambiguous, overlong, or trigger-poor description blocks completion even if the aggregate number passes.

# Scope In

- selected expert `description` fields
- focused description contract, budget evidence, this spec, refresh log

# Scope Out

- skill removal, catalog policy, public wrapper descriptions, names/paths
- body/reference compaction

# Constraints

- Preserve explicit expert discoverability.
- Canonical and compatibility email descriptions remain identical.

# Test Contract

Trigger vocabulary, per-description length, implicit public stability, complete runtime lexical budget, generic-verb warnings, graph and invocation compatibility.

# Dependencies

Wave 10 reviewed and pushed.

# Invariants

- No public trigger is weakened.
- No skill is uninstalled.
- Ownership graph remains complete.

# Links & Consequences

Codex installed discovery, expert help, invocation registry, and skill budget reporting consume these descriptions.

# Documentation Coherence

Refresh the measured inventory in `skill-context-budget.md`.

# Edge Cases

- Compatibility alias drifts from canonical description.
- Short description begins with a generic verb and loses trigger nouns.
- Portable source passes while runtime lexical estimate fails.

# Implementation Tasks

- [x] Compact selected explicit-only expert descriptions.
- [x] Add trigger-vocabulary and alias-parity tests.
- [x] Refresh portable, implicit, and runtime measurements.

# Acceptance Criteria

- [x] Runtime estimate is 8345/8500 with 155 characters of margin.
- [x] Public implicit portable estimate remains 1376/8500.
- [x] Budget reports zero hard violations, warnings, or risks.
- [x] Graph, invocation, and focused contracts pass.

# Test Strategy

Description contract, budget audit with explicit runtime root, graph/invocation consumers, fidelity and sync.

# Risks

Over-shortening could reduce expert comprehension; trigger nouns are mechanically preserved.

# Execution Notes

No catalog removal was needed. The compatibility alias remains installed.

# Open Questions

None.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 17:18:00 | 100-sg-spec | create | Wave 11 budget remediation contract created from runtime measurement. |
| 2026-08-12 17:19:00 | 101-sg-ready | review | Ready: explicit-only scope and trigger preservation are testable. |
| 2026-08-12 17:20:00 | 102-sg-start | execute | Compacted selected expert descriptions without catalog removal. |
| 2026-08-12 17:21:00 | 900-shipglows-core | refresh | Verified trigger nouns, alias parity, public stability, and truthful runtime measurement. |
| 2026-08-12 17:22:00 | 103-sg-verify | verify | Focused contracts, graph/invocation, fidelity, budget, and runtime sync passed. |
| 2026-08-12 17:22:00 | 104-sg-end | close | Wave 11 closed as reviewed with installed budget below ceiling. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
