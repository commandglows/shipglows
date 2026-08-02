---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-04"
updated: "2026-07-04"
status: active
source_skill: 102-sg-start
scope: code-navigation-and-function-documentation-system
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/shipglows-code-navigation-and-function-documentation-system.md
  - skills/references/code-navigation-and-function-docs.md
  - templates/technical_behavior_index.md
depends_on:
  - artifact: "skills/references/code-navigation-and-function-docs.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Checklist created during the first implementation wave of the code-navigation standard."
next_step: "/103-sg-verify ShipGlows Code Navigation And Function Documentation System"
---

# Code Navigation And Function Documentation System Checklist

## Usage

Use this checklist to verify term-based technical recovery without falling back to broad code search as the first move.

## Scenarios

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CNF-001 | Term recovery | Starting from `swipe`, the agent resolves named meanings from the behavior index. | yes | The agent distinguishes multiple IME swipe meanings instead of assuming one. | PASS | `ime-gesture-model.md` resolves `swipe` into five named IME behaviors before code search. | `shipglows_data/technical/winflowz_app/ime-gesture-model.md` | Verified during `103-sg-verify` document walk. |  |
| CNF-002 | Context roles | The context layer roles are explicit. | yes | `context.md`, `context-function-tree.md`, `code-docs-map.md`, and the behavior index each have a distinct role. | PASS | Shared doctrine and WinFlowz pilot both describe the four navigation layers with distinct ownership. | `skills/references/code-navigation-and-function-docs.md`; `shipglows_data/technical/winflowz_app/ime-gesture-model.md` |  |  |
| CNF-003 | Path bridge | The behavior index bridges to path-based routing. | yes | Mapped behavior entries link to code entrypoints and `code-docs-map.md`-owned routing surfaces. | PASS | WinFlowz `code-docs-map.md` routes IME gesture files to `ime-gesture-model.md`, which links back to code entrypoints and related docs. | `shipglows_data/technical/winflowz_app/code-docs-map.md`; `shipglows_data/technical/winflowz_app/ime-gesture-model.md` |  |  |
| CNF-004 | Symbol recovery | High-cognitive-load symbols reached from the behavior index are self-orienting. | yes | The key source functions expose concise contract/invariant comments. | PASS | KDoc comments now cover gesture launch, preservation, target arbitration, hover tracking, activation, and release dispatch. | `winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardLongPressSwipePolicy.kt`; `winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzKeyboardView.kt` | Confirmed alongside `flutter analyze`. |  |
| CNF-005 | Artifact links | The behavior index links to tests, specs, bugs, and decisions. | yes | Each named behavior points to its owning artifacts or states why no decision record is needed. | PASS | Pilot artifact links the owning spec and records explicit `no durable decision record needed` where ADRs are unnecessary. | `shipglows_data/technical/winflowz_app/ime-gesture-model.md` | Current pilot has no dedicated linked bug artifact. |  |
| CNF-006 | Ambiguity | Ambiguous operator terms are handled explicitly. | yes | The index contains an ambiguity table or equivalent mapping. | PASS | `swipe` ambiguity is explicit through the alias table and ambiguity table. | `shipglows_data/technical/winflowz_app/ime-gesture-model.md` |  |  |
| CNF-007 | Unmapped term | An unmapped term produces a governance classification. | yes | The agent reports `technical navigation bootstrap gap` or `technical navigation drift` instead of silently broad-searching. | PASS | Shared doctrine and corpus rules define both classifications and route them to `/300-sg-docs technical`. | `skills/references/code-navigation-and-function-docs.md`; `skills/references/technical-docs-corpus.md` | Verified by targeted `rg` checks. |  |
| CNF-008 | Security | The navigation artifacts stay redacted. | yes | No secrets, tokens, raw logs, private URLs, or user data appear in comments or behavior docs. | PASS | Reviewed changed artifacts; only local source paths and canonical docs are referenced. | Changed files in ShipGlows and WinFlowz pilot set | No sensitive payloads found. |  |
| CNF-009 | Governance audit | `300-sg-docs technical audit` can reason about behavior-index coverage. | yes | Audit doctrine includes behavior-index, ambiguity, and comment-coverage checks. | PASS | `300-sg-docs` technical mode now requires behavior-index coverage, ambiguity handling, artifact links, and source comment checks. | `skills/300-sg-docs/SKILL.md`; `skills/300-sg-docs/references/mode-playbooks.md` |  |  |
| CNF-010 | Tooling discipline | Generated docs are optional rather than mandatory. | no | The standard keeps generated API docs stack-specific and justified. | PASS | Shared doctrine keeps generated docs optional and stack-specific rather than mandatory. | `skills/references/code-navigation-and-function-docs.md`; spec contract | Optional scenario only. |  |

## Evidence

- Validate changed governance artifacts with metadata lint.
- Run targeted `rg` checks for behavior-index doctrine and pilot links.
- Walk the WinFlowz `swipe` recovery path from term -> behavior doc -> source comments -> linked artifacts.
