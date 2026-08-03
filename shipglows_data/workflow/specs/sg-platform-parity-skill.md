---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-10"
created_at: "2026-06-10 11:15:00 UTC"
updated: "2026-06-10"
updated_at: "2026-06-10 11:15:00 UTC"
status: ready
source_skill: sg-skill-build
source_model: "GPT-5 Codex"
scope: workflow
owner: Diane
user_story: "As a ShipGlows operator building Flutter and multi-platform products, I want a dedicated parity skill that keeps product concepts, implementation evidence, QA proof, and public platform claims aligned across OS targets, so users receive excellent and predictable experiences."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/sg-platform-parity/SKILL.md
  - skills/sg-platform-parity/references/platform-parity-matrix.md
  - skills/sg-platform-parity/agents/openai.yaml
  - site/src/content/skills/sg-platform-parity.md
depends_on:
  - artifact: "skills/sg-skill-build/SKILL.md"
    artifact_version: "current"
    required_status: active
supersedes: []
evidence:
  - "User request 2026-06-10: create sg-platform-parity in ShipGlows."
  - "User decision 2026-06-10: parity should be quasi-complete across platforms, with adapted experiences accepted only when the result is better or required."
next_step: "/sg-verify shipglows_data/workflow/specs/sg-platform-parity-skill.md"
---

# Spec: sg-platform-parity Skill

## Status

ready

## User Story

As a ShipGlows operator building Flutter and multi-platform products, I want a dedicated parity skill that keeps product concepts, implementation evidence, QA proof, and public platform claims aligned across OS targets, so users receive excellent and predictable experiences.

## Minimal Behavior Contract

Create `sg-platform-parity` as a ShipGlows skill. It audits and steers platform parity across web, Android, iOS, Windows, macOS, Linux, and any project-declared platform. It must distinguish same behavior, better/native adaptations, required platform adaptations, accepted degradations, unsupported capabilities, and unknown/proof gaps. It must route implementation, QA, verification, documentation, and ship follow-up to owner skills instead of duplicating their internals.

## Success Behavior

- The skill has a distinct trigger and does not duplicate `sg-build`, `sg-verify`, or `sg-audit`.
- The skill exposes a compact activation contract with canonical paths, chantier tracking, report modes, stop conditions, and validation.
- The skill includes a matrix reference for capability/platform/evidence/gap/route tracking.
- The runtime skill metadata uses `sg-platform-parity` as the exact display name.
- A public skill page explains when to use it and what output to expect.
- Runtime sync makes the skill available to current Claude/Codex skill directories.

## Error Behavior

- If platform evidence is missing, the skill reports `unknown` or `proof-gap` instead of claiming support.
- If adaptation is not better, required, or explicitly accepted as degraded, the skill routes follow-up instead of blessing divergence.
- If dirty unrelated files would be overwritten, the skill stops or limits edits to new owned files.

## Scope In

- `skills/sg-platform-parity/SKILL.md`
- `skills/sg-platform-parity/references/platform-parity-matrix.md`
- `skills/sg-platform-parity/agents/openai.yaml`
- `site/src/content/skills/sg-platform-parity.md`
- Runtime skill sync for current-user Claude/Codex links.

## Scope Out

- Implementing WinFlowz platform ports.
- Rewriting `sg-build`, `sg-verify`, or `sg-audit`.
- Editing unrelated dirty ShipGlows files.
- Shipping or committing without an explicit ship instruction.

## Placement Decision

Create a new domain skill. The behavior has a distinct trigger and durable artifact: a platform parity matrix with capability-level verdicts and platform QA routing. It overlaps audit and verification, but neither `sg-audit` nor `sg-verify` owns the product decision model for cross-platform sameness versus better/required adaptation.

## Proof Path

`scenario-first`: use the WinFlowz desktop/iOS parity pressure scenario. The old workflow made it easy to ask `sg-build` for each platform, but did not maintain a single concordance surface across product promise, implementation, QA, and docs. The new skill is valid if it can route that scenario without claiming implementation support from scaffolds or permission strings alone.

## Current Chantier Flow

| Skill | Status |
|-------|--------|
| sg-spec | ready |
| sg-ready | ready |
| sg-skill-build | implemented |
| sg-verify | pending |
| sg-ship | pending |

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-10 11:15:00 UTC | sg-skill-build | GPT-5 Codex | Created the sg-platform-parity skill contract, matrix reference, runtime metadata, public skill page, and spec. | implemented | /sg-verify shipglows_data/workflow/specs/sg-platform-parity-skill.md |
