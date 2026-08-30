---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-24"
created_at: "2026-08-24 19:04:00 Europe/Paris"
updated: "2026-08-24"
updated_at: "2026-08-24 19:04:00 Europe/Paris"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5
scope: shared-iconography-canon
owner: Diane
user_story: "As a ShipGlows product owner, I want one default icon family across app and web projects so interfaces stay coherent without recurring library decisions."
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems:
  - skills/references/design-system-token-contract.md
  - skills/006-sg-design/references/design-system-creation-playbook.md
  - tools/test_sg_design_contract.py
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-24: use Phosphor as the functional default, Simple Icons for brand marks, and Unicon only as a constrained web discovery/export tool."
next_step: "/103-sg-verify shared iconography canon"
---

# Shared Iconography Canon

## Status

ready

## Outcome

ShipGlows projects start with one free, open-source, cross-platform iconography language instead of selecting or mixing libraries ad hoc. A project may deliberately replace it when its own design-system authority records the exception.

## Behavior Contract

- Phosphor is the default functional icon family for new app and web work.
- Regular is the default weight; Fill is reserved for selected or active state when that distinction is accessible and semantically useful.
- Simple Icons is the exception for third-party brand marks and remains subject to each brand's trademark rules.
- Unicon may search or export web assets only with the source constrained to Phosphor, or to Simple Icons for brand marks. It is tooling, not a visual authority.
- Another family, custom SVG, or platform-native icon is allowed only through a project-local documented exception with a functional, platform, accessibility, or brand reason.
- Existing projects migrate incrementally when relevant UI is already being changed; this decision does not authorize a fleet-wide icon rewrite.

## Pressure Scenarios

- `ICON-NEW-PROJECT`: a new UI project needs navigation icons; Phosphor Regular is selected without another library search.
- `ICON-ACTIVE-STATE`: a selected navigation item needs emphasis; Phosphor Fill may pair with a non-icon state cue, while unrelated weights are not mixed decoratively.
- `ICON-BRAND-MARK`: a third-party logo is required; Simple Icons may be used with trademark and accessible-name handling.
- `ICON-MISSING-CONCEPT`: Phosphor lacks a required concept; the project records a bounded custom or alternative-family exception instead of silently mixing sets.
- `ICON-UNICON-SEARCH`: Unicon is used for discovery or export; its source is constrained to Phosphor, or Simple Icons for a brand mark.
- `ICON-EXISTING-PROJECT`: an established project uses another coherent family; no migration occurs unless its own design-system work chooses one.

## Scope

In scope: shared doctrine, design-system creation guidance, and focused contract tests.

Out of scope: dependency installation, project migrations, visual redesigns, or a prohibition on justified project-specific systems.

## Proof Contract

- Focused contract tests assert every canonical rule and exception boundary.
- Metadata lint validates the new spec and changed reference metadata.
- Diff review confirms no project source, dependency, or unrelated doctrine changed.

## Skill Run History

| Date | Skill | Action | Result | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-24 | 100-sg-spec | Define the shared iconography canon and bounded adoption policy | ready | Implement shared doctrine and focused proof |
| 2026-08-24 | 102-sg-start | Add the shared canon and design-system creation requirements | implemented | Run focused contract and metadata checks |
| 2026-08-24 | 103-sg-verify | Run iconography pressure assertions, metadata lint, and diff checks | verified | Close the bounded doctrine chantier |
| 2026-08-24 | 104-sg-end | Confirm doctrine, exceptions, and non-retrofit boundary are complete | complete | Ship the exact documentation and test slice |

## Current Chantier Flow

- `100-sg-spec` ✅ ready
- `102-sg-start` ✅ implemented
- `103-sg-verify` ✅ verified
- `104-sg-end` ✅ complete
- `005-sg-ship` ⏳ pending
