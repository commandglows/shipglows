---
artifact: capability_spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-22"
updated: "2026-11-22"
status: active
source_skill: 100-sg-spec
scope: capability-chantier-registry
owner: Diane
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/chantier-tracking.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows_data/workflow/specs/
depends_on: []
supersedes: []
evidence:
  - "Seeded 2026-11-22 from specs-as-chantier-registry.md and skill-taxonomy-and-chantier-sources.md, checked against skills/references/chantier-tracking.md 0.10.0."
  - "Seed limit: requirements were checked against the doctrine text in force, not replayed against every skill."
next_step: none
---

# Capability: chantier-registry

## Purpose

How ShipGlows records which chantier a skill run belongs to: one registry of change specs, a durable run history inside each spec, and strict rules on who may write a trace. Authority in force: `skills/references/chantier-tracking.md`.

## Requirements

### Requirement: Single chantier registry

`shipglows_data/workflow/specs/` SHALL be the only registry of spec-first chantiers; no skill SHALL keep a separate chantier registry in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, or a root `specs/` directory.

#### Scenario: A skill needs to record chantier state

- **WHEN** a skill must persist the progress of a chantier
- **THEN** it writes into the chantier's spec under `shipglows_data/workflow/specs/`
- **AND** it creates no parallel registry in a tracker file

#### Scenario: A root specs directory exists

- **WHEN** specs are found in a root `specs/` directory
- **THEN** they are treated as migration sources only, routed through `300-sg-docs migrate-layout`

### Requirement: Lifecycle run trace on a unique spec

A skill whose trace category is `obligatoire` SHALL, when exactly one chantier spec is identified, append its current run to `Skill Run History` and update `Current Chantier Flow`.

#### Scenario: Lifecycle skill runs on one identified spec

- **WHEN** `101-sg-ready`, `102-sg-start`, `103-sg-verify`, `104-sg-end`, or `005-sg-ship` runs with exactly one chantier spec in scope
- **THEN** the spec gains a `Skill Run History` row with date, skill, model, action, result, and next step
- **AND** `Current Chantier Flow` shows the updated status of that skill

#### Scenario: The spec has no run history yet

- **WHEN** an identified spec lacks a `Skill Run History` section
- **THEN** the skill adds the section with the canonical table header
- **AND** existing metadata and contract sections are preserved

### Requirement: No guessed spec

A skill MUST NOT write a trace into a guessed spec; when no unique spec can be identified, it SHALL stop for an explicit choice or run untraced.

#### Scenario: Several specs plausibly match

- **WHEN** more than one spec could own the current run
- **THEN** the skill asks for an explicit spec or reports the run as not traced
- **AND** no spec file is modified

### Requirement: Conditional and helper skills stay out of specs without a unique chantier

A `conditionnel` skill SHALL trace only when its run is attached to one unique chantier spec, and a `non-applicable` skill MUST NOT write run history into any spec.

#### Scenario: Audit runs outside any chantier

- **WHEN** a `conditionnel` skill such as `400-sg-audit` runs with no unique chantier spec
- **THEN** it writes to no spec
- **AND** its user report opens with a `(local)` chantier header

#### Scenario: Helper skill runs inside a chantier flow

- **WHEN** a `non-applicable` skill such as `302-sg-help` or `700-sg-explore` runs while a chantier is active
- **THEN** it writes no `Skill Run History` row

### Requirement: Run history records only real runs

A skill MUST record only its current run or facts already present in the spec or report; it MUST NOT invent past runs.

#### Scenario: Earlier stages left no trace

- **WHEN** a skill traces its run on a spec whose earlier stages have no history rows
- **THEN** it appends only its own row
- **AND** it adds no reconstructed rows for earlier stages

### Requirement: Source skills route new work through the spec owner

A source skill that finds future work beyond a clear bounded fix SHALL report a `Chantier potentiel` decision (`oui`, `non`, or `incertain`) with its reason, and MUST NOT create a new spec itself.

#### Scenario: Audit finds work that crosses the threshold

- **WHEN** a source skill finds P0/P1 risk, broad scope, or a required product or architecture decision
- **THEN** its report carries `Chantier potentiel: oui` with title, reason, severity, scope, and evidence
- **AND** the durable spec is created only by `100-sg-spec`

#### Scenario: Finding is a clear bounded fix

- **WHEN** the finding has a few enumerable actions and no directional choice
- **THEN** the report states `Chantier potentiel: non` with its reason

## Change History

| Date | Change spec | Operation | Requirement | Reason |
|------|-------------|-----------|-------------|--------|
| 2026-11-22 | specs-as-chantier-registry | SEEDED | Single chantier registry; Lifecycle run trace on a unique spec; No guessed spec; Conditional and helper skills stay out of specs without a unique chantier; Run history records only real runs | Seed from the spec, checked against chantier-tracking.md. |
| 2026-11-22 | skill-taxonomy-and-chantier-sources | SEEDED | Source skills route new work through the spec owner | Seed from the spec, checked against chantier-tracking.md. |
