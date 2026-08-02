---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: draft
source_skill: 700-sg-explore
scope: design-skill-surface-consolidation
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/500-sg-design-from-scratch/SKILL.md
  - skills/501-sg-design-playground/SKILL.md
  - skills/502-sg-audit-design/SKILL.md
  - skills/503-sg-audit-design-tokens/SKILL.md
  - skills/504-sg-audit-components/SKILL.md
  - skills/409-sg-audit-a11y/SKILL.md
  - skills/references/skill-instruction-layering.md
  - skills/references/design-system-token-contract.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows-site/src/content/skills/
evidence:
  - "Operator decision 2026-07-15: rework the whole design family to retain one skill, modes, playbooks, references, and tools."
  - "The current corpus exposes 69 skills, including 006-sg-design, five 500-series design skills, and 409-sg-audit-a11y."
  - "2026-07-15 skill budget audit reports 8536/8500 absolute discovery estimate."
  - "The current 006-sg-design routing already models the five specialist capabilities as one design lifecycle."
  - "At least 51 non-spec repository files reference the five specialist design invocation keys, including public skill pages."
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
next_step: "/100-sg-spec consolidate design skill surface into modes and playbooks"
---

# Exploration Report: Design Skill Surface Consolidation

## Starting Question

Should ShipGlows retain one public design skill with modes and playbooks instead of exposing `006-sg-design` plus six specialist design capabilities?

## Context Read

- `skills/006-sg-design/SKILL.md` and `references/design-lifecycle-routing.md` - establish one lifecycle owner already routing system creation, playground, and audit work.
- `skills/500-sg-design-from-scratch` through `504-sg-audit-components` - identify the five distinct procedures currently exposed as separate invocation keys.
- `skills/references/skill-instruction-layering.md` - requires a short activation contract and moves detailed mode procedure into references.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` - documents the design master/specialist split now in force.
- `shipglows_data/workflow/specs/semantic-compaction-of-design-content-and-skill-build-master-skills.md` - confirms prior work compacted master semantics, not public invocation count.
- `shipglows-site/src/content/skills/` - confirms public pages exist for several retiring design invocations and must migrate deliberately.

## Internet Research

None. This decision is governed by local ShipGlows contracts and current runtime surfaces.

## Problem Framing

The current design family has one real public owner (`006-sg-design`) and six procedures with the same design lifecycle, proof posture, and public intent. Exposing all seven as independent skills duplicates the choice an operator must make and increases discovery noise. The detailed work is valuable; its current placement as separately discoverable skills is not.

The design family should distinguish these artifact types:

```text
006-sg-design                 public owner and mode dispatcher
  ├── mode system              design-system creation/migration playbook
  ├── mode playground          token playground playbook/tooling
  ├── mode audit ui            UI/UX audit playbook
  ├── mode audit tokens        token audit playbook
  └── mode audit components    component-system audit playbook
  └── mode audit a11y          accessibility audit playbook
```

## Option Space

### Option A: Keep the current master plus six specialist skills

- Summary: retain the existing router/specialist topology and continue compacting bodies only.
- Pros: no invocation migration; existing references remain valid.
- Cons: preserves seven discovery entries for one operator intent, duplicate public pages, and a taxonomy that conflates public skills with detailed procedures.

### Option B: Rename or renumber the five specialist skills

- Summary: retain separate skills but change numbering or names to appear more coherent.
- Pros: limited structural work.
- Cons: does not reduce the number of choices, causes broad documentation/runtime migration, and leaves the underlying placement problem unresolved.

### Option C: One public `006-sg-design` skill with explicit modes and local playbooks

- Summary: migrate the six specialist contracts into bounded design-mode playbooks, leave a compact dispatcher in `006`, and retire the six standalone invocation directories and public pages.
- Pros: one clear public entrypoint, preserves detailed execution doctrine, lowers discovery pressure, aligns with reference-first compaction, and makes future design micro-tasks modes by default.
- Cons: requires a controlled migration of at least 51 non-spec references, runtime links, public documentation, tests, and historical compatibility policy.

## Comparison

Option C is the only option that reduces user-facing complexity without reducing design rigor. It separates public ownership from internal procedure. Option B is high-churn cosmetic work; Option A keeps the exact friction the operator identified.

## Emerging Recommendation

Adopt Option C and treat it as a high-risk, spec-first skill-surface migration.

The target invocation contract is:

```text
006-sg-design [library ... | system | playground [route] | audit ui [scope] |
                  audit tokens [scope] | audit components [scope] | audit a11y [scope] | redesign | migration]
```

The `006-sg-design` activation body must only select a mode, state the invariant, and load the matching reference. The detailed procedures from `500` through `504` and `409` move into clearly named files under `skills/006-sg-design/references/`; they must not be copied into a new mega-`SKILL.md` or one mega-reference.

Suggested reference mapping:

| Retired invocation | Target mode | Target playbook |
| --- | --- | --- |
| `500-sg-design-from-scratch` | `system` | `design-system-creation-playbook.md` |
| `501-sg-design-playground` | `playground` | `design-playground-playbook.md` |
| `502-sg-audit-design` | `audit ui` | `design-audit-playbook.md` |
| `503-sg-audit-design-tokens` | `audit tokens` | `design-token-audit-playbook.md` |
| `504-sg-audit-components` | `audit components` | `component-system-audit-playbook.md` |
| `409-sg-audit-a11y` | `audit a11y` | `accessibility-audit-playbook.md` |

## Non-Decisions

- No decision to consolidate the whole 69-skill corpus into `000–009` in this chantier.
- No decision on whether historical invocation aliases remain supported; the spec must decide this explicitly.
- No product-design, token, preset, component, or public-site implementation is included.

## Rejected Paths

- Renumbering specialist skills only - changes labels without reducing discovery or choice.
- Keeping deprecated wrapper skills as permanent aliases - retains the skill-list and runtime-surface cost that the migration is intended to remove.
- Moving all specialist detail into `006-sg-design/SKILL.md` - violates the activation-contract and followability rules.
- Treating the private inspiration library as an implementation playbook - it remains source-derived curation material, not a project design-system authority.

## Risks And Unknowns

- Removing invocation directories breaks explicit old commands unless a time-bounded compatibility policy is chosen and validated.
- Public skill pages and runtime sync entries must be removed or replaced deliberately; stale pages would promise nonexistent commands.
- Existing specs, historical reports, and archives should retain factual old invocation names; broad historical rewrites would damage traceability.
- The current `501` playground contains code-generation and dev-only endpoint guidance. Its migration must preserve its security and production-gating constraints.
- The `409` workflow has WCAG/APG, keyboard, focus, ARIA, screen-reader, and cross-platform checks. Its migration must preserve all of them and its token-authority handoff.
- Scope must stay inside the design family; a whole-corpus consolidation is a separate architectural decision.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: only local ShipGlows skill, governance, and public-documentation contracts were inspected.

## Decision Inputs For Spec

- User story seed: As the ShipGlows operator, I invoke one design skill with clear modes while retaining rigorous, separately loadable playbooks for each design procedure.
- Scope in seed: `006` mode contract; migration of `500–504` and `409` procedures into `006` local references; retiring their invocation directories/runtime links; routing/docs/public-page updates; targeted tooling/tests; validation and migration documentation.
- Scope out seed: broad 69-skill redesign; design-product implementation; rewrites of immutable history.
- Invariants/constraints seed: one public design entrypoint; mode-specific lazy loading; compact activation body; no weakened token, security, accessibility, proof, or chantier rules; no stale public command pages; no unrelated dirty-file changes.
- Validation seed: scenario matrix for every mode; `rg` stale-key scan with an explicit historical allowlist; metadata lint; skill audit; budget audit; runtime sync check; public-site build when documentation changes; design mode routing review.

## Handoff

- Recommended next command: `/100-sg-spec consolidate design skill surface into modes and playbooks`
- Why this next step: the owner decision, target architecture, migration boundaries, and key risks are now concrete enough for a ready implementation spec.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-07-15 16:49:38 UTC | Consolidate the design skill family | Inspected current skill contracts, routing, compaction work, public pages, and reference footprint; compared retain, rename, and mode/playbook migration options | Recommended one public `006-sg-design` skill with five explicit modes and local playbooks | `/100-sg-spec consolidate design skill surface into modes and playbooks` |
| 2026-07-15 16:59:01 UTC | Correct accessibility boundary | Re-read the `409` contract and detailed workflow after operator clarification | Corrected the target: `audit a11y` is a sixth `006` mode, not a separate public owner | `/101-sg-ready consolidate design skill surface into modes and playbooks` |
