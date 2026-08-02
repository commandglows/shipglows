---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-10"
created_at: "2026-06-10 18:58:09 UTC"
updated: "2026-06-10"
updated_at: "2026-06-10 19:24:03 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "skill-governance-refactor"
owner: "Diane"
user_story: "As a ShipGlows operator maintaining local skills, I want the remaining body-size review findings resolved through the established layering contract, so plugin audits finish cleanly without weakening workflow guardrails."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sg-audit-components/SKILL.md"
  - "skills/sg-build/SKILL.md"
  - "skills/sg-fix/SKILL.md"
  - "skills/sg-test/SKILL.md"
  - "skills/sg-audit-components/references/"
  - "skills/sg-build/references/"
  - "skills/sg-fix/references/"
  - "skills/sg-test/references/"
  - "skills/references/skill-instruction-layering.md"
  - "skills/references/skill-context-budget.md"
  - "skills/references/chantier-tracking.md"
  - "skills/references/reporting-contract.md"
  - "tools/skill_budget_audit.py"
  - "plugins/shipglows-core/scripts/audit_shipglows_skills.py"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "shipglows_data/workflow/specs/compact-shipglows-skill-instructions-phase-4.md"
    artifact_version: "1.0.0"
    required_status: "ready"
supersedes: []
evidence:
  - "ShipGlows Core plugin audit on 2026-06-10 after direct cleanup: 66 skills audited, 4 files with review findings, 0 hard findings, 0 style findings."
  - "Remaining plugin audit review findings: sg-audit-components body-size risk about 5111 tokens, sg-build about 5031 tokens, sg-fix about 5134 tokens, and sg-test about 5360 tokens."
  - "tools/skill_budget_audit.py on 2026-06-10 reports 66 skills, 0 hard violations, 0 warnings, 3 separate body-token risks: sg-audit-components, sg-fix, and sg-test; sg-build is near threshold by that estimator and still flagged by the plugin audit."
  - "Direct cleanup already removed hard-coded skill validation paths, missing report-contract style warnings, missing mission-heading style warnings, and runtime-specific AskUserQuestion/Task tool wording."
  - "Existing compact skill instruction phases 1-4 are complete historical chantiers; this spec handles the new residual findings from the current 66-skill inventory."
next_step: "/sg-skill-build hipflow alias skill quality cleanup, or remove unintended skills/hipflow and rerun /sg-verify"
---

# Spec: Residual ShipGlows Skill Body Risk Cleanup

## Title

Residual ShipGlows Skill Body Risk Cleanup

## Status

ready

## User Story

As a ShipGlows operator maintaining local skills, I want the remaining body-size review findings resolved through the established layering contract, so plugin audits finish cleanly without weakening workflow guardrails.

## Minimal Behavior Contract

When this chantier runs, ShipGlows must reduce or explicitly justify the remaining body-size review findings for `sg-audit-components`, `sg-build`, `sg-fix`, and `sg-test` by moving bulky playbooks, examples, context probes, checklists, and long workflow detail into explicitly loaded skill-local references while keeping each `SKILL.md` as a concise activation contract. A compacted skill must still expose its role, canonical path loader, trace category, process role, report mode, required references, mode detection, stop conditions, validation commands, and result semantics that other skills rely on. If a guardrail cannot be safely extracted without making the activation contract ambiguous, the implementation must keep the stricter local sentence and document a justified exception. The easiest edge case to miss is making the audit pass by hiding mandatory manual QA, bug memory, lifecycle orchestration, or source-de-chantier behavior in a reference that the top-level skill no longer clearly loads.

## Success Behavior

- Preconditions: the direct cleanup pass is present, plugin audit reports only the four body-size review findings, and `skills/references/skill-instruction-layering.md` defines what stays local versus what moves to references.
- Trigger: a maintainer runs `/sg-start Residual ShipGlows Skill Body Risk Cleanup` after `/sg-ready` marks this spec ready.
- User/operator result: the operator can rerun the local ShipGlows Core audit and see no findings, or only documented body-size exceptions that are intentionally accepted by verification.
- System effect: `sg-audit-components`, `sg-build`, `sg-fix`, and `sg-test` either fall below the plugin audit body-risk threshold or carry explicit, narrow exceptions justified by safety and accepted by `sg-verify`.
- Proof of success: `python3 ~/plugins/shipglows-core/scripts/audit_shipglows_skills.py` reports 0 hard findings, 0 style findings, and 0 unresolved review findings; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` reports 0 hard violations and no unresolved body-token risks; focused `rg` checks prove mandatory labels and reference-loading routes remain visible.
- Silent success is not allowed; the implementation report must include before/after line counts and body-token estimates for every touched skill.

## Error Behavior

- If a skill-local reference is missing, malformed, too broad, or not explicitly loaded by the activation body, implementation must stop for that skill and keep the original local guardrails.
- If `sg-test` loses the rule that no test result may be invented or that failing manual tests create/update durable bug records, verification must fail.
- If `sg-fix` loses bug-file intake, direct-versus-spec-first routing, proof-path selection, or security/data stop conditions, verification must fail.
- If `sg-build` loses lifecycle orchestration, model/topology routing, governance corpus gates, or concrete proof-owner routing, verification must fail.
- If `sg-audit-components` loses source-de-chantier reporting, component-system audit phases, or pre-check behavior, verification must fail.
- Must never happen: rename skills, change invocation keys, delete guardrails to satisfy an audit, weaken chantier traceability, weaken security/privacy rules, rewrite unrelated dirty files, or claim a clean audit while the plugin audit still reports unresolved review findings.

## Problem

The direct local cleanup resolved all hard, style, portability, and runtime-wording findings from the ShipGlows Core plugin audit. The remaining findings are review-level body-size risks on four skills:

- `skills/sg-audit-components/SKILL.md`
- `skills/sg-build/SKILL.md`
- `skills/sg-fix/SKILL.md`
- `skills/sg-test/SKILL.md`

These files remain long enough that Codex can spend attention on procedural bulk instead of the live task. The risk is not that every long skill is wrong; the risk is instruction dilution in high-impact skills that control lifecycle orchestration, bug repair, manual QA, and component-system audits. Previous compaction phases established the safe pattern: keep `SKILL.md` as an activation contract and move large specialist detail into skill-local references.

## Solution

Apply the existing instruction-layering contract to the four residual skills. For each skill, split the top-level file into a shorter activation body plus one or more focused skill-local references. Prefer references named by purpose, not one catch-all file:

- `skills/sg-audit-components/references/component-audit-workflow.md`
- `skills/sg-build/references/build-lifecycle-workflow.md`
- `skills/sg-fix/references/bug-fix-workflow.md`
- `skills/sg-test/references/manual-qa-workflow.md`

The exact filenames may change if implementation finds a clearer local convention, but each reference must have frontmatter and a narrow purpose. Shared doctrine must point to existing shared references instead of being copied.

## Scope In

- Compact `skills/sg-audit-components/SKILL.md`.
- Compact `skills/sg-build/SKILL.md`.
- Compact `skills/sg-fix/SKILL.md`.
- Compact `skills/sg-test/SKILL.md`.
- Create or update focused skill-local references for moved workflow detail.
- Preserve all existing invocation names, argument hints, trace categories, process roles, report modes, stop conditions, and validation expectations.
- Preserve the current direct-cleanup wording that uses runtime-neutral structured-question and parallel-tool phrasing.
- Update technical docs or code-docs map only if the implementation changes documented skill architecture or adds new reference files that need durable mapping.

## Scope Out

- Changing user-facing skill names, `name:` fields, descriptions, or invocation keys.
- Rewriting the broader ShipGlows taxonomy.
- Editing public site skill pages unless the visible public promise changes.
- Changing the ShipGlows Core plugin audit script.
- Renaming or deleting existing skills.
- Solving unrelated dirty worktree changes or the separate untracked `openpostern-security-signal-routing-for-shipglows-skills.md` spec.

## Constraints

- Resolve ShipGlows-owned files from `${SHIPGLOWS_ROOT:-$HOME/shipglows}`.
- Load and follow `skills/references/skill-instruction-layering.md` before editing.
- Keep top-level `SKILL.md` bodies independently understandable after their required references are loaded.
- Keep `Trace category` and `Process role` visible in every touched top-level body.
- Keep `reporting-contract.md`, `chantier-tracking.md`, `canonical-paths.md`, and skill-specific required references visible where applicable.
- Do not move non-negotiable stop conditions entirely out of the top-level body.
- Do not use line count as the only quality metric; behavior preservation and proof quality take priority.

## Test Contract

- Surface profile: Markdown skill contracts and skill-local references under `skills/`.
- Automated proof available: plugin audit, skill budget audit, metadata lint, `rg` label checks, `git diff --check`.
- Non-automated proof required: scenario-first review of each compacted activation body against the original behavior contract.
- Proof path: scenario-first with mechanical checks first.
- Manual checklist path: not required; the affected surface is internal skill instruction architecture, not a user-operated UI flow.
- Exceptions: any residual body-size warning must be explicitly justified in the implementation report and verified against the exception policy in `skill-instruction-layering.md`.

## Dependencies

- `skills/references/skill-instruction-layering.md` for compaction rules and exception policy.
- `skills/references/canonical-paths.md` for path ownership.
- `skills/references/chantier-tracking.md` for trace category and process role preservation.
- `skills/references/reporting-contract.md` for final report behavior.
- `skills/references/decision-quality-contract.md` for smallest safe path and quality bar.
- Existing skill-local README files for `sg-audit-components`, `sg-fix`, and `sg-test` may be read for context but must not become implicit hidden instruction sources unless the top-level skill explicitly routes to them.
- Fresh external docs: not needed; this change is local ShipGlows instruction architecture and does not depend on current framework, SDK, provider, auth, build, migration, cache, routing, or integration behavior.

## Invariants

- All touched skills remain discoverable by the same directory and `name:` value.
- Frontmatter stays valid and compact.
- Chantiers remain traceable through the existing spec registry.
- Source-de-chantier skills still surface `Chantier potentiel` when future work crosses the threshold.
- Lifecycle skills still preserve implementation, verification, closure, and ship handoff semantics.
- Bug/test skills still preserve durable bug memory, no-invented-results rules, and evidence-first behavior.

## Links & Consequences

- `sg-build` compaction affects the highest-level user-facing orchestrator. Any loss of lifecycle routing can make future implementation work close too early.
- `sg-fix` compaction affects bug traceability, security triage, and proof path selection.
- `sg-test` compaction affects manual QA integrity and durable bug record creation.
- `sg-audit-components` compaction affects audit output quality and source-de-chantier escalation.
- New reference files may need metadata lint and, if project docs map references skill architecture at file granularity, a technical docs update plan.

## Documentation Coherence

- Internal technical docs: update `shipglows_data/technical/skill-runtime-and-lifecycle.md` or `shipglows_data/technical/code-docs-map.md` only if new reference-file conventions or skill architecture expectations change.
- Public docs/site: no impact expected because user-facing skill promises and invocation names stay unchanged.
- Changelog: update if this work is shipped.
- Help catalog: no impact expected unless descriptions, command names, or routing promises change.

## Edge Cases

- `sg-build` may be under the local `skill_budget_audit.py` token threshold but over the plugin audit threshold; treat the stricter plugin result as in scope.
- Extracting context command blocks can reduce size but may remove useful orientation. If moved, the top-level body must say what context must be gathered and where the exact probes live.
- Existing `README.md` files under skill directories are documentation, not automatically loaded instruction references; do not rely on them unless the top-level body explicitly names them.
- Reference extraction can create one large reference that is harder to use than the original skill. Split by purpose when a skill has multiple large concerns.
- Dirty worktree files unrelated to this chantier must not be reverted or included in validation claims.

## Implementation Tasks

- [ ] Task 1: Baseline the four residual findings.
  - File: `skills/sg-audit-components/SKILL.md`, `skills/sg-build/SKILL.md`, `skills/sg-fix/SKILL.md`, `skills/sg-test/SKILL.md`
  - Action: Record current line counts, body-token estimates, plugin audit findings, and the high-risk sections to preserve.
  - User story link: proves the work is aimed at the actual residual findings.
  - Depends on: none.
  - Validate with: `python3 ~/plugins/shipglows-core/scripts/audit_shipglows_skills.py`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `wc -l <files>`.
  - Notes: Treat `sg-build` as in scope even if only the plugin audit flags it.

- [ ] Task 2: Extract `sg-audit-components` detailed audit phases.
  - File: `skills/sg-audit-components/SKILL.md`, `skills/sg-audit-components/references/component-audit-workflow.md`
  - Action: Move long phase descriptions, report examples, and global/file/project mode detail into a focused local reference; keep pre-check, mode routing, source-de-chantier rules, stop/report expectations, and validation visible.
  - User story link: removes body-size risk while preserving component audit behavior.
  - Depends on: Task 1.
  - Validate with: `rg -n "Trace category|Process role|Chantier Potential|Report Modes|Mode detection|Pre-check|component-audit-workflow|Validation" skills/sg-audit-components/SKILL.md`.
  - Notes: Preserve the runtime-neutral wording for structured questions and parallel tooling.

- [ ] Task 3: Extract `sg-build` lifecycle detail without weakening orchestration.
  - File: `skills/sg-build/SKILL.md`, `skills/sg-build/references/build-lifecycle-workflow.md`
  - Action: Move detailed question framing, readiness loop detail, governance gates, execution orchestration examples, and post-implementation gates into a local reference while keeping route decisions, topology semantics, stop conditions, and required shared-reference map visible.
  - User story link: reduces high-impact lifecycle instruction load while preserving user-facing orchestration.
  - Depends on: Task 1.
  - Validate with: `rg -n "Trace category|Process role|Master Delegation|Master Workflow Lifecycle|Existing Chantier Check|Question Gate|Stop Conditions|Final Report|build-lifecycle-workflow" skills/sg-build/SKILL.md`.
  - Notes: Do not change subagent consent semantics or spec-gated parallel rules.

- [ ] Task 4: Extract `sg-fix` bug workflow detail.
  - File: `skills/sg-fix/SKILL.md`, `skills/sg-fix/references/bug-fix-workflow.md`
  - Action: Move detailed intake, bug-file mutation procedure, technical triage checklist, and fix execution details into a local reference while keeping direct-vs-spec-first routing, proof path, bug memory requirement, security/data stop conditions, and final report expectations visible.
  - User story link: preserves safe bug repair while reducing instruction dilution.
  - Depends on: Task 1.
  - Validate with: `rg -n "Trace category|Process role|Chantier Potential|spec-driven-development-discipline|decision-quality-contract|Direct fix|Spec-first|BUG-ID|Stop Conditions|bug-fix-workflow" skills/sg-fix/SKILL.md`.
  - Notes: No bug trace exception expansion is allowed.

- [ ] Task 5: Extract `sg-test` manual QA workflow detail.
  - File: `skills/sg-test/SKILL.md`, `skills/sg-test/references/manual-qa-workflow.md`
  - Action: Move detailed scenario generation, prompt shape, logging procedure, retest handling, and platform-specific ladders into a local reference while keeping no-invented-results, durable `shipglows_data/workflow/TEST_LOG.md`, bug-file behavior, project-mode gates, and routing visible.
  - User story link: preserves manual QA integrity while making the activation contract easier to follow.
  - Depends on: Task 1.
  - Validate with: `rg -n "Trace category|Process role|Never invent test results|TEST_LOG|BUG-|project-development-mode|manual-qa-workflow|Final Report" skills/sg-test/SKILL.md`.
  - Notes: Manual QA semantics are safety-critical; keep the top-level no-invented-results rule local.

- [ ] Task 6: Validate references, budgets, and behavior-preserving labels.
  - File: `skills/*/SKILL.md`, `skills/*/references/*.md`
  - Action: Run mechanical checks, metadata lint for new references, plugin audit, and focused `rg` label checks.
  - User story link: proves the residual findings are actually resolved.
  - Depends on: Tasks 2-5.
  - Validate with: `python3 ~/plugins/shipglows-core/scripts/audit_shipglows_skills.py`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `python3 tools/shipglows_metadata_lint.py <new-reference-files> shipglows_data/workflow/specs/residual-shipglows-skill-body-risk-cleanup.md`; `git diff --check`.
  - Notes: If `tools/shipglows_sync_skills.sh --check --all` is available and relevant to the runtime, run it before closure.

- [ ] Task 7: Update docs/changelog only if affected.
  - File: `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/technical/code-docs-map.md`, `CHANGELOG.md`
  - Action: Add or update only if reference architecture, public promises, or shipped change notes require it.
  - User story link: keeps durable documentation coherent without creating noise.
  - Depends on: Task 6.
  - Validate with: `rg -n "sg-audit-components|sg-build|sg-fix|sg-test|skill-local reference|instruction layering" shipglows_data/technical CHANGELOG.md`.
  - Notes: Public docs are out of scope unless behavior claims change.

## Acceptance Criteria

- [ ] AC 1: Given the current ShipGlows skill tree, when `python3 ~/plugins/shipglows-core/scripts/audit_shipglows_skills.py` runs, then it reports 0 unresolved hard, style, and review findings, or any remaining review finding is explicitly documented as an accepted exception in this spec and final report.
- [ ] AC 2: Given the current ShipGlows skill tree, when `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` runs, then it reports 0 hard violations, 0 warnings, and no unresolved body-token risks for the four target skills.
- [ ] AC 3: Given each touched `SKILL.md`, when a fresh agent reads only the activation body plus its required references, then the skill's mission, route decisions, trace category, process role, report mode, stop conditions, and validation path remain clear.
- [ ] AC 4: Given `sg-test` is compacted, when manual QA is requested, then the top-level body still prevents invented test results and routes durable logs/bug files correctly.
- [ ] AC 5: Given `sg-fix` is compacted, when a bug is reported, then the top-level body still distinguishes direct fixes from spec-first work and preserves bug-file/proof-path/security gates.
- [ ] AC 6: Given `sg-build` is compacted, when a lifecycle implementation is requested, then the top-level body still preserves existing chantier checks, readiness routing, topology semantics, and proof-owner routing.
- [ ] AC 7: Given `sg-audit-components` is compacted, when project/file/global audit modes are requested, then the top-level body still routes to the detailed component audit workflow and preserves source-de-chantier output.
- [ ] AC 8: Given new reference files are created, when metadata lint runs, then their frontmatter is valid and they resolve from `$SHIPGLOWS_ROOT`.
- [ ] AC 9: Given unrelated local modifications exist, when the chantier is complete, then the final report separates this chantier's files from pre-existing dirty worktree changes.

## Test Strategy

- Mechanical checks first: plugin audit, skill budget audit, metadata lint, `git diff --check`.
- Focused `rg` checks second: prove required labels, references, result semantics, and stop conditions remain visible.
- Scenario review third: compare each compacted skill against the original high-risk behavior bullets in this spec.
- Runtime sync check when relevant: `tools/shipglows_sync_skills.sh --check --all`.
- No browser/manual UI proof required because this is internal skill instruction architecture.

## Risks

- High instruction-regression risk: these skills control major lifecycle, bug, and QA behavior.
- Medium maintenance risk: adding references can improve activation clarity but make future edits harder if reference names are vague.
- Security impact: yes, because `sg-fix`, `sg-test`, and `sg-build` include security/data/proof gates; mitigation is to keep non-negotiable guards local and verify labels with `rg`.
- Documentation risk: yes, if new reference architecture is not reflected in technical docs when required.
- Dirty-worktree risk: existing unrelated local edits can be accidentally included in this chantier; mitigation is explicit file scoping and final diff reporting.

## Execution Notes

- Read first: `skills/references/skill-instruction-layering.md`, this spec, then the four target `SKILL.md` files.
- Preferred implementation order: baseline all four, extract one skill at a time, run focused `rg` after each extraction, run full audits at the end.
- Keep extracted references focused by purpose; avoid one mega-reference per skill if the moved content has separable concerns.
- Do not edit public docs, site content, or help catalog unless the visible skill promise changes.
- Stop and reroute to the user if preserving a guardrail conflicts with eliminating a body-size warning.
- Fresh external docs verdict: `fresh-docs not needed`.

## Open Questions

None. The behavior goal, target files, and proof path are defined by the current audit output and existing instruction-layering doctrine.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-10 18:58:09 UTC | sg-spec | GPT-5 Codex | Created residual body-risk cleanup spec from ShipGlows Core audit findings. | draft saved | /sg-ready Residual ShipGlows Skill Body Risk Cleanup |
| 2026-06-10 19:04:20 UTC | sg-ready | GPT-5 Codex | Validated user-story fit, scope, security posture, implementation tasks, proof path, and ShipGlows language doctrine. | ready | /sg-start Residual ShipGlows Skill Body Risk Cleanup |
| 2026-06-10 19:20:15 UTC | sg-start | gpt-5.3-codex-spark | Compacted four residual body-risk skills into activation contracts plus focused skill-local references; plugin audit, budget audit, metadata lint, diff check, rg checks, and sync check passed. | implemented | /sg-verify Residual ShipGlows Skill Body Risk Cleanup |
| 2026-06-10 19:24:03 UTC | sg-verify | GPT-5 Codex | Verified the four scoped body-risk skills and new references; target budget, metadata, and diff checks passed, but global plugin audit now sees unrelated untracked `skills/hipflow/SKILL.md` with one review and one style finding. | partial | /sg-skill-build hipflow alias skill quality cleanup, or remove unintended skills/hipflow and rerun /sg-verify |

## Current Chantier Flow

- sg-spec: draft saved.
- sg-ready: ready.
- sg-start: implemented.
- sg-verify: partial.
- sg-end: not launched.
- sg-ship: not launched.
- Next step: `/sg-skill-build hipflow alias skill quality cleanup`, or remove unintended `skills/hipflow` and rerun `/sg-verify`.
