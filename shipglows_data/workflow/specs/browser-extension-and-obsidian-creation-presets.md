---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-09-03"
created_at: "2026-09-03 10:19:49 UTC"
updated: "2026-09-03"
updated_at: "2026-09-03 10:35:47 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5.6 Codex
scope: creation-presets
owner: Diane
user_story: "As an operator asking ShipGlows to create a browser extension or Obsidian plugin without technical details, I want a consistent native-first Vue stack and host-level proof so that the proposal follows our standards without making me choose implementation mechanics."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/references/browser-extension-lab.md
  - skills/references/obsidian-plugin-workflow.md
  - skills/sg-development/SKILL.md
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/shipglows-devserver.ps1
  - shipglows_data/technical/
depends_on: []
supersedes: []
evidence:
  - "The operator approved WXT, TypeScript, pnpm, multi-browser delivery, and desktop-plus-mobile Obsidian support on 2026-09-03."
  - "The operator selected Vue 3 instead of React for rich interfaces while retaining platform-native UI for simple surfaces."
  - "Existing ShipGlows Labs already provide isolated browser-extension and Obsidian host proof."
next_step: "Complete exact-scope Git delivery to canonical dev."
---

# Spec: Browser Extension And Obsidian Creation Presets

## Status

ready

## Minimal Behavior Contract

For a greenfield browser extension, ShipGlows recommends WXT, strict TypeScript, Manifest V3, pnpm, and multi-browser output. For a greenfield Obsidian plugin, it starts from the official TypeScript API and esbuild-compatible artifact contract. Both surfaces use native platform primitives for simple UI and Vue 3 for rich UI. React is not part of either default. Agents ask only about product consequences not covered by the preset.

## Scope In

- Canonical preferred-stack presets for browser extensions and Obsidian plugins.
- Native-versus-Vue selection criteria and lifecycle boundaries.
- Development-owner routing to both specialized workflows.
- WXT-aware Windows classification, dependency readiness, managed development launch, generated environment guidance, and browser-specific Lab artifact resolution.
- Scenario-first regression coverage for sparse creation requests.

## Scope Out

- Installer, template generator, installed-runtime activation, or product-repository changes.
- Dependency installation, build execution, store submission, BRAT publication, release, commit, or push without its normal lifecycle authority.
- A mandatory Vue dependency for simple interfaces.

## Constraints And Invariants

- Browser extensions default to WXT, Vue 3 only for rich UI, Manifest V3, minimal permissions, and Chromium-family plus Firefox output.
- Obsidian plugins retain the official `Plugin` lifecycle, APIs, theme variables, and distributable artifact shape whether or not Vue is used.
- Every Vue application has an explicit mount owner and deterministic unmount path.
- Obsidian desktop and mobile remain supported unless a verified Node/Electron requirement justifies `isDesktopOnly: true`.
- Build success never substitutes for isolated host proof; publication is never implicit.

## Proof Contract

- Scenario-first: sparse extension and plugin creation prompts resolve to the approved presets without asking the operator to choose a framework.
- Static integration: the development owner links both specialized workflows.
- Focused unit contract: exact native-first, Vue, WXT, portability, lifecycle, and no-React markers are present.
- Governance: metadata lint and diff integrity pass for the changed references and spec.

## Implementation Tasks

1. Extend the preferred stack authority with the two approved presets.
2. Add creation-specific architecture rules to both specialized workflows.
3. Connect browser-extension development explicitly from the public development owner.
4. Extend the Windows adapter and Lab descriptor for WXT while retaining CRXJS behavior.
5. Add focused regression contracts and run proportional validation.
6. Reconcile technical and editorial documentation, record proof, and complete the normal delivery path.

## Acceptance Criteria

- [x] A vague browser-extension request defaults to WXT, TypeScript, pnpm, Manifest V3, multi-browser delivery, and native-first/Vue-rich UI.
- [x] A vague Obsidian-plugin request defaults to the official TypeScript/esbuild-compatible structure, desktop-plus-mobile support, and native-first/Vue-rich UI.
- [x] React is explicitly absent from both defaults.
- [x] Vue lifecycle cleanup and host-native ownership are explicit.
- [x] Development routes discover both Lab workflows and preserve their safety boundaries.
- [x] WXT classification, dependency ownership, Chrome MV3 launch, production/development output selection, and CRXJS compatibility are covered.
- [x] Focused tests and metadata checks pass.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-09-03 10:19:49 UTC | 100-sg-spec | GPT-5.6 Codex | Formalized the operator-approved native-first Vue creation presets and bounded integration work. | drafted | Run readiness review. |
| 2026-09-03 10:19:49 UTC | 101-sg-ready | GPT-5.6 Codex | Confirmed scope, security boundaries, product defaults, implementation order, and scenario-first proof. | ready | Implement the presets. |
| 2026-09-03 10:35:47 UTC | 102-sg-start | GPT-5.6 Codex | Added both creation presets, Vue lifecycle rules, WXT runtime classification and launch support, browser-specific artifact resolution, focused tests, and aligned technical/editorial documentation. | implemented | Run final verification. |
| 2026-09-03 10:35:47 UTC | 103-sg-verify | GPT-5.6 Codex | Passed 35 Python contracts, four focused Windows suites, three adjacent Windows regressions, PowerShell parsing, metadata lint, and diff integrity; the umbrella Bash harness was unavailable because WSL has no Bash, while its affected Windows lanes ran directly. | verified | Close and deliver to canonical dev. |
| 2026-09-03 10:35:47 UTC | 104-sg-end | GPT-5.6 Codex | Reconciled stack, runtime, operator, README, changelog, and chantier documentation; retained installed-runtime activation as an explicit later update boundary. | closed | Commit and push exact scope to canonical dev. |

## Current Chantier Flow

- `sg-spec`: done.
- `sg-ready`: passed.
- `sg-start`: complete.
- `sg-verify`: verified.
- `sg-end`: closed.
- `sg-ship`: pending.

Next step: commit and push exact scope to canonical dev.
