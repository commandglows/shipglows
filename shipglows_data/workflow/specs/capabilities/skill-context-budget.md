---
artifact: capability_spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-22"
updated: "2026-11-22"
status: active
source_skill: 100-sg-spec
scope: capability-skill-context-budget
owner: Diane
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/skill-context-budget.md
  - tools/skill_budget_audit.py
  - tools/skill_activation_budget.py
  - skills/references/skill-invocation-registry.json
depends_on: []
supersedes: []
evidence:
  - "Seeded 2026-11-22 from skill-description-budget-compliance.md, progressive-skill-discovery-and-activation-budgets.md and progressive-loading-core-pilot.md, checked against tools/skill_budget_audit.py, tools/skill_activation_budget.py and skills/references/skill-context-budget.md 1.16.0."
  - "The discovery ceiling in force is 8500 characters; skill-description-budget-compliance.md still states the earlier 8000."
next_step: none
---

# Capability: skill-context-budget

## Purpose

The limits that keep ShipGlows skills cheap to discover and to activate, and the audits that enforce them. Authorities in force: `skills/references/skill-context-budget.md`, `tools/skill_budget_audit.py`, and `tools/skill_activation_budget.py`.

## Requirements

### Requirement: One-sentence description within the hard limit

Every `SKILL.md` description SHALL be at most one sentence and at most 200 characters, and MUST NOT contain `Args:`; argument syntax belongs in `argument-hint`.

#### Scenario: Description exceeds the hard maximum

- **WHEN** `tools/skill_budget_audit.py` audits a skill whose description is longer than 200 characters
- **THEN** it reports a hard violation and exits non-zero

#### Scenario: Description is long but under the hard maximum

- **WHEN** a description is longer than 140 and at most 200 characters
- **THEN** the audit reports a warning
- **AND** it fails only when run with `--strict`

### Requirement: Skill name matches its directory

A skill `name` SHALL equal its directory name under `skills/<name>/SKILL.md`, use only lowercase letters, digits, and single hyphens, and be at most 64 characters.

#### Scenario: Name and directory differ

- **WHEN** the audit reads a `SKILL.md` whose `name` differs from its parent directory
- **THEN** it reports a hard violation and exits non-zero

### Requirement: Portable discovery index stays within its ceiling

The portable discovery index (repository-relative path, name, and description of the selected catalogue) SHALL stay within 8500 characters; the ceiling MUST NOT be raised without a distinct approved migration.

#### Scenario: Discovery index exceeds the ceiling

- **WHEN** the audited catalogue's repository-relative estimate exceeds 8500 characters
- **THEN** `tools/skill_budget_audit.py` exits non-zero

### Requirement: Long skill bodies are reported as separate risks

The audit SHALL report a `SKILL.md` longer than 500 lines or above about 5000 estimated body tokens as a separate risk that does not by itself fail discovery compliance.

#### Scenario: Body exceeds 500 lines

- **WHEN** the audit reads a `SKILL.md` with more than 500 lines
- **THEN** it lists the skill under separate risks
- **AND** the exit code is unchanged by that risk alone

### Requirement: Always-loaded root context is measured

`tools/skill_budget_audit.py` SHALL measure the always-loaded instruction files (user-global `CLAUDE.md`, repo `CLAUDE.md`, repo `AGENT.md`) and warn above 12000 characters per file or 30000 characters in aggregate.

#### Scenario: One root file is too large

- **WHEN** a root context file exceeds 12000 characters
- **THEN** the audit prints a warning naming that file
- **AND** the run fails only with `--strict`

#### Scenario: A root file is absent

- **WHEN** one of the root context files does not exist
- **THEN** it is skipped without error

### Requirement: Declared activation scenarios enforce their budget

Each scenario declared under `activation_profiles.scenarios` SHALL declare `max_tokens` and `max_depth_after_selection`, and `tools/skill_activation_budget.py` SHALL exit non-zero for an invalid declaration or an over-budget scenario.

#### Scenario: A scenario exceeds its token ceiling

- **WHEN** the unique declared reads of a scenario total more tokens than its `max_tokens`
- **THEN** the scenario is reported `over_budget`
- **AND** the command exits non-zero

### Requirement: Budget never removes a protection

A budget failure MUST be resolved by a smaller sufficient load or an explicit reviewed exception; size MUST NOT justify removing a stop condition, security gate, proof requirement, trace role, or reporting contract.

#### Scenario: A skill body is over its ceiling

- **WHEN** a skill must shrink to meet a budget
- **THEN** detail moves behind an on-demand reference with an imperative pointer
- **AND** every stop condition, security gate, and proof requirement of the skill remains reachable

## Change History

| Date | Change spec | Operation | Requirement | Reason |
|------|-------------|-----------|-------------|--------|
| 2026-11-22 | skill-description-budget-compliance | SEEDED | One-sentence description within the hard limit; Skill name matches its directory; Long skill bodies are reported as separate risks | Seed from the spec, checked against skill_budget_audit.py. |
| 2026-11-22 | progressive-skill-discovery-and-activation-budgets | SEEDED | Portable discovery index stays within its ceiling; Budget never removes a protection | Seed; ceiling in force is 8500, superseding the earlier 8000. |
| 2026-11-22 | progressive-loading-core-pilot | SEEDED | Declared activation scenarios enforce their budget | Seed from the spec, checked against skill_activation_budget.py. |
| 2026-11-22 | (none: skill-context-budget.md 1.16.0) | SEEDED | Always-loaded root context is measured | Seed from the reference in force; no change spec found. |
