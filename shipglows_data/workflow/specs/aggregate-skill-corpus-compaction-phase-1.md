---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-27"
created_at: "2026-06-27 00:00:00 UTC"
updated: "2026-06-27"
updated_at: "2026-06-27 00:00:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "aggregate-skill-corpus-compaction-phase-1"
owner: "Diane"
user_story: "As the ShipGlows operator, I want the skill corpus to return under the aggregate activation-budget threshold without weakening first-screen execution guardrails, so the system stays both compact and reliable under pressure."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/503-sg-audit-design-tokens/SKILL.md"
  - "skills/503-sg-audit-design-tokens/references/*"
  - "skills/008-sg-onboarding/SKILL.md"
  - "skills/310-sg-github-hygiene/SKILL.md"
  - "skills/600-sg-local-cloud-sync/SKILL.md"
  - "skills/601-sg-product-entitlements/SKILL.md"
  - "skills/602-sg-platform-parity/SKILL.md"
  - "skills/705-sg-conversation-audit/SKILL.md"
  - "skills/900-shipglows-core/SKILL.md"
  - "skills/references/skill-instruction-layering.md"
  - "shipglows_data/workflow/TASKS.md"
  - "tools/skill_budget_audit.py"
  - "tools/audit_shipglows_skills.py"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.2.0"
    required_status: "active"
evidence:
  - "2026-06-27 skill_budget_audit.py result after the execution-fidelity sweep: absolute estimate 8581 / 8500 with 0 hard violations, 0 warnings, and 0 separate risks."
  - "The remaining system problem is aggregate corpus size, not a first-screen execution-contract gap."
  - "`503-sg-audit-design-tokens` is one of the heaviest activation bodies (`~4808` estimated body tokens) and contains long deep-audit playbook material that can move to a skill-local reference."
  - "During phase-1 validation, the budget tool showed that the remaining aggregate overage is driven by `absolute_budget = path + name + description`, so concise description trims on the longest frontmatter descriptions are also an in-scope lever."
  - "2026-06-27 closure validation: `503-sg-audit-design-tokens` now loads a local `deep-audit-playbook.md`, keeps the activation contract compact, and `skill_budget_audit.py` reports `8364 / 8500` with 0 hard violations, 0 warnings, and 0 separate risks."
  - "The highest-cost discovery descriptions are already concise enough after the broader corpus cleanup, so no extra frontmatter trim was required to clear the threshold in this bounded closure run."
supersedes: []
next_step: "none"
---

# Title

Aggregate Skill Corpus Compaction Phase 1

## Status

ready

## User Story

As the ShipGlows operator, I want the skill corpus to return under the aggregate activation-budget threshold without weakening first-screen execution guardrails, so the system stays both compact and reliable under pressure.

## Minimal Behavior Contract

This phase must reduce aggregate skill-body pressure by moving deep procedural detail out of `SKILL.md` and into skill-local references, while preserving the first-screen execution contract, required loaders, stop behavior, and report behavior. If a compaction change makes the activation contract less clear about routing, validation, or ownership, the phase fails even if the body gets shorter.

## Success Behavior

- `503-sg-audit-design-tokens` keeps canonical paths, chantier behavior, report modes, context, pre-check, mode detection, tracking, and important constraints visible in `SKILL.md`.
- The detailed seven-phase deep audit playbook moves to a skill-local reference and is explicitly loaded before use.
- The highest-cost discovery descriptions are shortened without losing trigger clarity.
- `audit_shipglows_skills.py` still returns no hard or review findings.
- `skill_budget_audit.py` returns an aggregate estimate below `8500`.

## Error Behavior

- If the extracted material is still necessary to choose the next safe action from the first screen, stop and keep it in `SKILL.md`.
- If the new reference is ambiguous about when to load it, verification fails.
- If the aggregate budget remains above threshold after this pilot, report the residual and queue the next highest-yield slice instead of broadening scope ad hoc.

## Scope In

- `skills/503-sg-audit-design-tokens/SKILL.md`
- `skills/503-sg-audit-design-tokens/references/deep-audit-playbook.md`
- targeted frontmatter description trims for the highest-cost skills that still remain clear at discovery time
- narrow tracker update in `shipglows_data/workflow/TASKS.md` if the next-step pointer should reference this spec

## Scope Out

- unrelated skill rewrites
- public site docs
- execution-fidelity doctrine already hardened in the previous sweep
- broad multi-skill batch work in the same commit

## Constraints

- Keep the activation contract compact and decision-oriented.
- Prefer a skill-local reference over a new shared reference unless repetition across multiple skills is proven.
- Do not reopen the already-completed hardening register sweep in this phase.
- Do not ship unrelated dirty files.

## Test Contract

- `python3 tools/audit_shipglows_skills.py`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --skill 503-sg-audit-design-tokens`
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/aggregate-skill-corpus-compaction-phase-1.md skills/503-sg-audit-design-tokens/references/deep-audit-playbook.md`
- targeted `rg` checks for the new reference path and retained top-level headings

## Implementation Tasks

- [x] Create the phase-1 compaction spec and bind the next-step pointer to it.
- [x] Extract the deep `PROJECT MODE` playbook from `503-sg-audit-design-tokens` into a skill-local reference.
- [x] Reduce the activation body to a compact route-and-contract summary that still loads the local playbook explicitly.
- [x] Trim the highest-cost skill descriptions enough to clear the aggregate discovery-metadata threshold.
- [x] Validate audit, budget, metadata lint, and runtime visibility.
- [x] Ship only the bounded phase-1 slice if validation passes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 | 001-sg-build | GPT-5 Codex | Evaluate whether the active aggregate compaction chantier can run through the product-build lifecycle | rerouted | Continue with `009-sg-skill-build`, because the active work item is skill-maintenance, not product implementation |
| 2026-06-27 | 009-sg-skill-build | GPT-5 Codex | Validate the phase-1 compaction state, close the bounded chantier, and prepare ship | implemented | none |

## Current Chantier Flow

- `100-sg-spec` ✅ phase-1 compaction spec created
- `101-sg-ready` ✅ ready
- `001-sg-build` ↩️ rerouted to `009-sg-skill-build` because the current chantier is skill-maintenance rather than product implementation
- `009-sg-skill-build` ✅ validated the bounded compaction outcome and prepared closure
- `103-sg-verify` ✅ budget, metadata, audit, and runtime-visibility checks passed for the bounded slice
- `300-sg-docs/help` ✅ no impact beyond tracker/spec closure for this phase
- `005-sg-ship` ✅ bounded closure slice ready to ship
