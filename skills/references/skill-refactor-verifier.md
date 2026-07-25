---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlowz
created: "2026-07-25"
updated: "2026-07-25"
status: active
source_skill: manual
scope: skill-refactor-verifier
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/skill-instruction-layering.md
  - skills/references/decision-quality-contract.md
  - skills/references/reporting-contract.md
  - skills/references/chantier-tracking.md
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/reporting-contract.md
    artifact_version: "1.10.0"
    required_status: active
supersedes: []
evidence:
  - "Created to verify that skill compaction moves doctrine to references without dropping activation-critical guardrails."
next_review: "2026-08-25"
next_step: "/103-sg-verify skill-refactor-verifier"
---

# Skill Refactor Verifier

## Purpose

Use this reference when compacting or migrating skill instructions so the activation body stays thin without losing operational doctrine.

## Preserve These Nuggets

Before accepting a skill refactor, verify that the target skill still exposes:

- skill name, description, and argument contract
- canonical path loading
- trace category and process role when chantier tracking applies
- report-mode contract and pointer to the reporting reference
- the smallest safe route or mode-detection rule
- required references and when to load them
- local stop conditions that are specific to the owner skill
- validation commands or proof links that the skill still owns

## Compaction Checks

For every moved paragraph, ask:

1. Is the information reusable across multiple skills?
2. Does a dedicated reference already own this doctrine?
3. Does the activation body still tell a fresh agent what to do next?
4. Did any owner-specific routing rule, safety rule, or proof gate disappear?
5. Did the refactor preserve the original intent, not just the surface wording?

If a rule is valuable but not activation-critical, move it to a reference and leave one short local pointer.

## Fail Conditions

Treat the refactor as incomplete if any of these are true:

- a required loader vanished
- trace or reporting visibility was removed
- route ownership became ambiguous
- stop conditions moved out of the skill without a local pointer
- a moved rule no longer has a canonical home
- the new structure is shorter but less followable

## Useful Output

When the verifier passes, report:

- `pass` when the activation body still routes cleanly and all moved details have a home
- `pass-with-notes` when the skill is correct but one or two references could be narrower later
- `blocked` when a gold nugget was lost or a required guardrail no longer has a home
