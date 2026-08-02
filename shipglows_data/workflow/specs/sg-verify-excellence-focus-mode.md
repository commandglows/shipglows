---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-17"
created_at: "2026-07-17 09:39:49 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 09:59:32 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "103-sg-verify excellence focus mode"
owner: "Diane"
user_story: "As the ShipGlows operator, I want an explicit excellence verification focus after métier verification, so that work which is correct and shippable can still be challenged for material quality, coherence, durability, and user-value improvements."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/103-sg-verify/SKILL.md"
  - "skills/103-sg-verify/references/verification-gates.md"
  - "skills/103-sg-verify/README.md"
  - "skills/references/decision-quality-contract.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
  - "shipglows-site/src/content/skills/sg-verify.md"
  - "tools/test_103_sg_verify_excellence_contract.py"
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator observation on 2026-07-17: ordinary métier verification can pass while a later excellence-focused pass repeatedly finds meaningful improvements."
  - "Operator decision on 2026-07-17: excellence is a distinct verification focus, not merely a deeper standard verification run."
  - "Current 103-sg-verify contract already checks ship-readiness and decision quality but exposes no explicit excellence mode or excellence-specific verdict semantics."
  - "Integration review on 2026-07-17: preserve the shared excellence quality bar in every mode while limiting excellence result claims to the excellence focus, and accept unambiguous natural-language excellence requests."
next_step: "/104-sg-end sg-verify excellence focus mode"
---

# Spec: sg-verify Excellence Focus Mode

## Title

sg-verify Excellence Focus Mode

## Status

ready

## User Story

As the ShipGlows operator, I want an explicit excellence verification focus after métier verification, so that work which is correct and shippable can still be challenged for material quality, coherence, durability, and user-value improvements.

## Minimal Behavior Contract

`103-sg-verify` accepts a standard verification request, an explicit `mode=excellence`, or an unambiguous natural-language request for an excellence pass. Standard mode judges métier correctness, contract fulfillment, proof, and ship-readiness while retaining the shared decision-quality bar without making an excellence result claim. Excellence mode keeps those gates, then performs a fresh critical pass beyond the acceptance criteria to find material missed opportunities, incoherence, duplication, avoidable operator or user friction, weak durability, and merely adequate choices. Missing proof or blocking risk must never produce an excellence verdict, and non-material stylistic preferences must not reopen otherwise verified work.

## Success Behavior

- Preconditions: A bounded work item, task contract, or already verified result can be identified.
- Trigger: The operator runs `/103-sg-verify [scope]` for standard mode, or uses `mode=excellence` or an unambiguous natural-language excellence request for the excellence focus.
- User/operator result: The report clearly distinguishes métier readiness from excellence findings and does not imply that `verified` means `excellent`.
- System effect: When a unique spec exists, the trace records the selected mode, the matching verdict, and a concrete repair or owner route for material gaps.
- Success proof: Focused scenario tests prove mode detection, verdict precedence, materiality, reopening behavior, and proportional validation.
- Silent success: Not allowed; the selected focus and verdict must be visible in the report.

## Error Behavior

- Expected failures: No reliable scope, missing required proof, a blocking bug or risk, ambiguous mode, or an excellence claim unsupported by a fresh critical pass.
- User/operator response: Keep `partial`, `not verified`, or `blocked` semantics and name the concrete missing proof or owner route.
- System effect: Do not record `excellent`; do not erase an earlier standard `verified` trace when excellence finds a new material improvement gap.
- Must never happen: Treat a stylistic preference as a reopened chantier, downgrade a proof failure to an excellence gap, or claim excellence from the standard checklist alone.
- Silent failure: Not allowed; the reason excellence could not be established must be explicit.

## Problem

The current verification contract is strong at checking the métier promise and ship-readiness, but it has no explicit second focus for asking what remains average after those gates pass. Re-running verification with an informal demand for excellence can uncover further improvements, yet the behavior, materiality threshold, trace semantics, and verdict vocabulary are not deterministic.

## Solution

Add a local `standard`/`excellence` mode contract to `103-sg-verify`. Keep standard verification as the default and make excellence an explicit second-pass focus with separate verdict semantics, materiality rules, scenario proof, and discoverable operator documentation.

## Scope In

- Mode detection for default/`mode=standard`, explicit `mode=excellence`, and unambiguous natural-language excellence requests; conflicting or unknown explicit mode values still block.
- A fresh excellence-pass checklist focused beyond acceptance criteria.
- Verdict precedence and the new `verified_with_excellence_gaps` and `excellent` results.
- Material-gap and non-material-suggestion boundaries.
- Reopening and repair/owner-routing behavior after a prior `verified` result.
- Focused tests, runtime sync verification, and operator/public documentation updates.

## Scope Out

- A new standalone excellence skill.
- Changing the acceptance criteria of existing project specs automatically.
- Turning every suggestion into blocking work.
- Replacing specialist design, copy, security, performance, or product audits.
- Commit, push, release, or production deployment.

## Constraints

- Excellence is a distinct focus, not a synonym for more test volume.
- Existing `partial`, `not verified`, and `blocked` meanings remain authoritative for proof and risk failures.
- The `SKILL.md` activation contract stays compact; detailed prompts and matrices belong in its local reference.
- Validation remains proportional to the changed surface.
- Unrelated dirty CLI files remain untouched.

## Dependencies

- Runtime: None; this is a local skill-contract change.
- Document contracts: `decision-quality-contract` 1.2.0, `skill-instruction-layering` 1.1.0, and `spec-driven-development-discipline` 1.5.0.
- Metadata gaps: None.
- Fresh external docs: `fresh-docs not needed`; no external behavior governs the change.

## Invariants

- Standard mode remains the default métier and ship-readiness gate.
- Excellence mode cannot return `excellent` unless standard readiness also passes.
- Proof/risk failures take precedence over excellence findings.
- An earlier standard `verified` result remains historically true when a later excellence pass opens improvement work.
- Only material gaps reopen or route follow-up work.

## Links & Consequences

- Upstream systems: Lifecycle skills and operators invoking `103-sg-verify`.
- Downstream systems: `104-sg-end`, `005-sg-ship`, repair owners, chantier trace, runtime-discoverable skill copies, and public skill documentation.
- Cross-cutting checks: Skill budget, metadata, runtime sync, public discovery coherence, and scenario-first contract tests.

## Documentation Coherence

- Document the mode and verdict distinction in the skill README, operator launch cheatsheet, and public `sg-verify` page.
- Update broader README/workflow doctrine only if the concise operator surfaces cannot express the new invocation and semantics without drift.

## Edge Cases

- Standard verification passes, but excellence finds one material duplication or coherence gap.
- Excellence finds only taste-level wording or formatting preferences.
- Excellence is requested while required hosted, browser, auth, or manual proof is still missing.
- A prior `verified` trace exists and must not be rewritten or misrepresented.
- A deterministic micro-change needs focused validation rather than an exhaustive audit.
- Excellence exposes a scope-changing product decision that the verification skill cannot repair safely.

## Materiality Contract

A gap is material when resolving it would meaningfully improve at least one of: user outcome or comprehension, cross-surface coherence, correctness or reliability margin, security/privacy, performance/operational robustness, maintainability/durability, avoidable duplication, or operator workload. It must be concrete enough to change a reasonable ship, follow-up, or architecture decision and have evidence plus an owner route. Pure taste, speculative polish without user/system consequence, and generic “could be better” observations are suggestions and do not reopen the chantier.

## Verdict Contract

- `verified`: Standard métier/ship-readiness checks pass; no excellence claim is made.
- `verified_with_excellence_gaps`: Standard readiness passes, but the explicit excellence pass finds one or more material improvements. The prior verified state remains valid while bounded follow-up work is reopened or routed.
- `excellent`: Standard readiness passes, the explicit fresh excellence pass is complete, and no material excellence gap remains.
- `partial`, `not verified`, `blocked`: Existing proof, correctness, or risk semantics take precedence; these results cannot be replaced by an excellence verdict.

## Implementation Tasks

- [x] Task 1: Add compact mode and verdict routing to the activation contract.
  - File: `skills/103-sg-verify/SKILL.md`
  - Action: Define default standard mode, explicit excellence activation, verdict precedence, trace semantics, and the local reference loader.
  - User story link: Makes the distinct focus deterministic and visible.
  - Depends on: None.
  - Validate with: `python3 -m unittest tools.test_103_sg_verify_excellence_contract`
  - Notes: Keep detailed excellence heuristics out of the activation body.

- [x] Task 2: Define the detailed excellence pass and materiality routing.
  - File: `skills/103-sg-verify/references/verification-gates.md`
  - Action: Add the second-pass questions, materiality boundary, repair/reroute behavior, and six pressure scenarios.
  - User story link: Ensures excellence looks beyond métier acceptance without generating decorative churn.
  - Depends on: Task 1.
  - Validate with: `python3 -m unittest tools.test_103_sg_verify_excellence_contract`
  - Notes: Reuse existing specialist owners rather than duplicating their audits.

- [x] Task 3: Add scenario-first contract tests.
  - File: `tools/test_103_sg_verify_excellence_contract.py`
  - Action: Mechanically assert mode selection, ordering, verdict precedence, materiality, trace behavior, and proportionality.
  - User story link: Prevents future compaction from collapsing excellence back into standard verification.
  - Depends on: Tasks 1-2.
  - Validate with: `python3 -m unittest tools.test_103_sg_verify_excellence_contract`
  - Notes: Contract tests inspect canonical text; they do not simulate product-specific verification.

- [x] Task 4: Align discovery and operator documentation.
  - File: `skills/103-sg-verify/README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows-site/src/content/skills/sg-verify.md`
  - Action: Document `mode=excellence`, the second-focus promise, and the verdict distinction without claiming a full specialist audit.
  - User story link: Makes the focus intentionally invocable and understandable.
  - Depends on: Tasks 1-3.
  - Validate with: metadata lint and focused `rg` checks.
  - Notes: Broader README/workflow edits require a demonstrated discovery gap.

- [x] Task 5: Refresh and validate the runtime-discoverable skill.
  - File: `skills/REFRESH_LOG.md` and runtime skill links.
  - Action: Run conservative refresh, focused tests, metadata lint, skill audit, budget audit, diff check, and current-user runtime sync check.
  - User story link: Proves the new focus is followable and visible without weakening existing gates.
  - Depends on: Tasks 1-4.
  - Validate with: Commands in `Test Strategy`.
  - Notes: Do not commit or push without explicit authorization.

## Acceptance Criteria

- [x] AC 1: Given an invocation with no excellence intent, when `103-sg-verify` selects its mode, then it defaults to standard métier/ship-readiness verification, retains the shared decision-quality bar, and returns no excellence claim.
- [x] AC 2: Given a prior `verified` result, when explicit `mode=excellence` or an unambiguous natural-language excellence request finds a concrete material duplication, incoherence, missed user-value opportunity, or durability gap, then it returns `verified_with_excellence_gaps`, preserves the earlier standard result, and routes bounded follow-up.
- [x] AC 3: Given an explicit excellence pass with standard readiness and sufficient evidence, when no material gap remains, then the result may be `excellent`.
- [x] AC 4: Given missing proof, a blocking bug, or a correctness/security risk, when excellence is requested, then `partial`, `not verified`, or `blocked` takes precedence and `excellent` is forbidden.
- [x] AC 5: Given only stylistic, taste-level, or unsupported suggestions, when excellence assesses materiality, then the chantier is not reopened.
- [x] AC 6: Given a deterministic atomic change, when verification effort is selected, then focused evidence remains sufficient and excellence does not force an unrelated exhaustive audit.

## Test Strategy

- Unit: `python3 -m unittest tools.test_103_sg_verify_excellence_contract`
- Integration: `python3 tools/audit_shipglows_skills.py` and `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- Metadata: `python3 tools/shipglows_metadata_lint.py <changed metadata artifacts>`.
- Runtime: `tools/shipglows_sync_skills.sh --check --skill 103-sg-verify`.
- Manual: Focused semantic review of the six acceptance scenarios; no browser/device proof is needed.

## Test Contract

### Surface

- Stack/surface: ShipGlows skill and Markdown documentation.
- Primary proof mode: contract_only.
- Proof order: scenario-first tests, metadata, skill audit, budget, runtime sync, semantic review.

### Manual checklist

- Needed: no.
- Checklist path: None.
- Required scenario coverage: AC 1 through AC 6 in focused automated contract tests.
- Exception with proof: No browser or device proof because the behavior is an instruction contract with mechanical and semantic evidence.

### Required evidence stack

- Automated / unit / integration checks: Focused unittest, metadata lint, skill audit, budget audit, runtime sync, and `git diff --check`.
- Agent-run browser proof: None; no runtime page behavior changes.
- Auth/session proof: None.
- Contract/integration proof: Six pressure scenarios and documentation coherence scan.
- Provider evidence: None.
- Device-native proof: None.

## Risks

- Security impact: None; existing security verification gates remain unchanged and keep verdict precedence.
- Product/data/performance risk: Medium workflow risk if `excellent` is overclaimed, if taste-level suggestions create churn, or if excellence hides missing proof. Mitigated by explicit precedence, materiality, and tests.

## Execution Notes

- Read first: `skills/103-sg-verify/SKILL.md`, `skills/103-sg-verify/references/verification-gates.md`, `skills/references/decision-quality-contract.md`, `skills/references/skill-instruction-layering.md`, and `skills/references/skill-context-budget.md`.
- Proof path: `scenario-first`.
- Repair boundary: Excellence may repair stable, bounded local issues under the existing `103-sg-verify` repair authority. Scope-changing, product-decision, security-sensitive, specialist-audit, hosted-proof, or multi-owner gaps must be routed to the proper owner.
- Validate with: Commands in `Test Strategy`, plus `git diff --check` and focused stale-wording scans.
- Stop conditions: Ambiguous verdict precedence, no mechanical coverage for AC 1-6, skill budget regression, unresolved runtime sync collision, or overlap with unrelated dirty files.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-07-17 09:39:49 UTC | 100-sg-spec | GPT-5 Codex | Created the durable contract for a distinct excellence verification focus. | draft | /101-sg-ready sg-verify excellence focus mode |
| 2026-07-17 09:44:02 UTC | 101-sg-ready | GPT-5 Codex | Confirmed autonomous scope, verdict precedence, materiality, repair boundaries, documentation impact, and scenario-first proof. | ready | /102-sg-start sg-verify excellence focus mode |
| 2026-07-17 09:51:16 UTC | 102-sg-start | GPT-5 Codex | Implemented compact mode routing, detailed excellence gates, AC1-AC6 contract tests, and focused discovery docs; local focused proof passed. | implemented | /900-shipglows-core refresh 103-sg-verify |
| 2026-07-17 09:55:05 UTC | 102-sg-start | GPT-5 Codex | Refined natural-language excellence activation and separated the all-mode decision-quality baseline from excellence-only result claims; focused integration tests passed. | implemented | /900-shipglows-core refresh 103-sg-verify |
| 2026-07-17 09:57:18 UTC | 900-shipglows-core | GPT-5 Codex | Conservatively refreshed the new focus, confirmed compact layering and cross-surface coherence, and passed tests, metadata, audit, budget, runtime sync, diff, and public-site build proof. | refreshed | /103-sg-verify mode=excellence sg-verify excellence focus mode |
| 2026-07-17 09:59:32 UTC | 103-sg-verify | GPT-5 Codex | Ran the new excellence focus, found and repaired two material coherence gaps in natural-language activation and the mode-specific mission, then reran all focused, metadata, audit, budget, sync, diff, and site-build proof with no material gap remaining. | excellent | /104-sg-end sg-verify excellence focus mode |

## Current Chantier Flow

- `100-sg-spec`: draft spec created.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented; focused scenario tests and metadata checks passed.
- `900-shipglows-core refresh`: refreshed; local and public discovery proof passed.
- `103-sg-verify`: excellent; the fresh second focus repaired two material gaps and found none remaining after revalidation.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: `/104-sg-end sg-verify excellence focus mode`
