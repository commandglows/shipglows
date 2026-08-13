---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-13"
created_at: "2026-08-13 18:44:46 UTC"
updated: "2026-08-13"
updated_at: "2026-08-13 19:47:23 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: reference-driven-frontend-design-contract
owner: Diane
confidence: high
user_story: "As a ShipGlows operator, I want design work driven by screenshots or visual references to preserve the project's system and converge through responsive rendered comparison rather than stop at code correctness."
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-lifecycle-routing.md
  - skills/006-sg-design/references/design-proof-and-reporting.md
  - skills/006-sg-design/references/reference-driven-frontend-playbook.md
  - skills/108-sg-browser/SKILL.md
  - skills/108-sg-browser/references/browser-proof-playbook.md
  - tools/test_sg_design_contract.py
  - tools/test_108_sg_browser_compaction_contract.py
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "OpenAI Learn, Build responsive front-end designs, reviewed 2026-08-13: visual references should be translated into the repository's design system and compared in a real browser across relevant sizes and states."
  - "OpenAI curated playwright-interactive skill, reviewed 2026-08-13: implementation signoff uses one QA inventory, separate functional and visual passes, persistent iteration when available, viewport-fit proof, and visible-defect precedence over numeric metrics."
next_step: "/005-sg-ship reference-driven frontend design contract"
---

# Title

Reference-driven frontend design contract

# Status

Reviewed and locally closed.

# Minimal Behavior Contract

When screenshots, mockups, or visual references define the target, `sg-design` inventories the observable states, translates the direction through the repository's canonical components and design tokens, proves representative responsive renders and behavior in a real browser, and iterates on material mismatches before claiming completion.

# Success Behavior

- References establish hierarchy, composition, spacing, and interaction intent without becoming permission to copy a foreign implementation or create a parallel design system.
- The contract records representative desktop and mobile targets plus applicable hover, selected, loading, empty, error, reduced-motion, and content-variation states.
- Ambiguous details use the simplest project-native interpretation that preserves the overall direction; material product or brand ambiguity remains operator-owned.
- Browser comparison evaluates the implementation against the references, not merely whether the page builds.
- Material mismatches are corrected and rechecked until the accepted target is met or the remaining proof gap is reported honestly.

# Error Behavior

Completion is rejected when reference-driven work invents local visual literals, ignores canonical components, proves only source/build correctness, omits a materially represented viewport or state, or reports visual fidelity without rendered comparison.

# Scope In

- conditional design routing for screenshots, mockups, and visual references
- project-native design-system translation
- responsive and state inventory
- iterative browser comparison and proof
- focused scenario-first regression checks

# Scope Out

- a new public mode or skill
- brand invention or copying proprietary source implementations
- pixel identity that weakens accessibility, performance, or project architecture
- Figma-specific extraction mechanics
- changes to product UI

# Acceptance Criteria

- [x] The design activation contract names the conditional playbook and trigger.
- [x] The playbook requires source inventory, project-native translation, state coverage, responsive targets, and iterative rendered comparison.
- [x] Lifecycle routing and proof guidance reject build-only visual completion.
- [x] A focused mechanical test covers the pressure scenario.
- [x] Refresh, metadata, budget, activation graph, audit, and runtime-sync checks pass.
- [x] Browser implementation signoff connects requirements, controls, states, and final claims to explicit functional and visual proof.
- [x] Persistent iteration, exploratory coverage, viewport fit, dense/transition states, and visible-defect precedence are encoded without burdening narrow browser checks.

# Implementation Tasks

- [x] Add the conditional reference-driven frontend playbook.
- [x] Wire its activation and proof boundaries into the design owner.
- [x] Add focused scenario-first regression assertions.
- [x] Run conservative refresh and proportional verification.
- [x] Extend the bounded browser proof playbook and focused regression tests from the official Playwright Interactive source.

# Pressure Scenario

`DESIGN-REFERENCE-001`: Given a fresh agent receives screenshots or visual references for a frontend surface, when it implements the target in an existing repository, then it inventories relevant widths and states, reuses canonical components and design tokens, translates rather than copies the reference, compares rendered browser evidence back to the target, and iterates on material mismatches before reporting completion.

`BROWSER-SIGNOFF-001`: Given a fresh agent must sign off a reference-driven or user-visible implementation, when it verifies the non-auth surface, then one QA inventory connects requirements, controls, state changes, and final claims to separate functional and visual checks; representative and minimum viewports, dense and transitional states, and safe exploratory paths are covered; and visible clipping cannot be overruled by numeric metrics.

# Documentation Update Plan

No public command or promise changes. Keep the behavior in the design activation map and local references; no README or public catalog update is required.

# Editorial Update Plan

No public editorial surface changes.

# Risks

The main risk is turning visual comparison into pixel-copy pressure or adding a second design-system authority. The playbook keeps project architecture, accessibility, performance, and canonical tokens authoritative while using references as observable targets.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-13 18:44:46 | 100-sg-spec | create | Defined the reference-driven frontend workflow, pressure scenario, placement, and proof boundary. |
| 2026-08-13 18:44:46 | 101-sg-ready | review | Ready: scope, success/error behavior, owner layer, exclusions, and focused proof are explicit. |
| 2026-08-13 18:52:00 | 102-sg-start | implement | Added the conditional playbook, activation/routing/proof wiring, and focused regression test. |
| 2026-08-13 18:52:00 | 900-shipglows-core | refresh | Approved the narrow local placement, source completeness, current official source, and unchanged public surface; found the missing Codex expert runtime link. |
| 2026-08-13 18:52:00 | 103-sg-verify | partial | 66 tests, metadata, budget, activation graph, skill audit, and diff checks passed; runtime sync failed because `006-sg-design` is absent from the Codex runtime directory. |
| 2026-08-13 19:33:46 | 103-sg-verify | verify | Repaired and rechecked the targeted Codex runtime link; focused design tests and metadata lint passed again. |
| 2026-08-13 19:33:46 | 104-sg-end | close | Closed the local skill improvement after source, contract, audit, budget, graph, metadata, and runtime proof. Commit and push remain outside this run. |
| 2026-08-13 19:47:23 | 102-sg-start | implement | Extended browser signoff with shared QA inventory, separate functional/visual passes, runtime-truthful persistence, viewport/state coverage, and visible-defect precedence. |
| 2026-08-13 19:47:23 | 900-shipglows-core | refresh | Approved the conditional browser-playbook placement and confirmed narrow checks remain proportional; current official Playwright Interactive source was recorded. |
| 2026-08-13 19:47:23 | 103-sg-verify | verify | 23 focused tests, metadata, budget, graph, audit, diff, and targeted design/browser Codex runtime checks passed; the missing browser runtime link was repaired. |
| 2026-08-13 19:47:23 | 104-sg-end | close | Reclosed the expanded local contract; commit and push remain outside this run. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
