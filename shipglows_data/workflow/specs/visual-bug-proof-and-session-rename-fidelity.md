---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-17"
created_at: "2026-07-17 14:15:19 UTC"
updated: "2026-07-18"
updated_at: "2026-07-18 12:25:51 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "visual bug proof and current-session rename execution fidelity"
owner: "Diane"
user_story: "As the ShipGlows operator, I want minor visual fixes to retain rendered proof and current-session renames to require an explicit status, so agents cannot overclaim a fix or silently infer workflow state."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/references/spec-driven-development-discipline.md"
  - "skills/003-sg-bug/SKILL.md"
  - "skills/106-sg-fix/SKILL.md"
  - "skills/106-sg-fix/references/bug-fix-workflow.md"
  - "skills/309-sg-tasks/SKILL.md"
  - "shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md"
  - "tools/rename_codex_session.py"
  - "tools/test_rename_codex_session.py"
depends_on:
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/106-sg-fix/references/bug-fix-workflow.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md"
    artifact_version: "1.4.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/specs/professional-bug-management.md"
    artifact_version: "1.0.0"
    required_status: ready
  - artifact: "shipglows_data/workflow/specs/codex-current-session-rename.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Observed conversation failure on 2026-07-17: a testimonial-profile visual repair was reported fixed after build, PNG signature, and CDN HTTP checks without rendered browser proof."
  - "Observed conversation failure on 2026-07-17: the invocation `309-sg-tasks sessions rename` omitted `<status>`, but the agent inferred `done` and renamed the current conversation."
  - "skills/106-sg-fix/SKILL.md currently permits a narrow minor exception for purely cosmetic visual defects but does not state at that exception point that only durable bug-file creation is waived."
  - "skills/003-sg-bug/SKILL.md already defines evidence, fix, retest, verify ownership and hosted proof routing, so the repair must reinforce rather than replace that lifecycle."
  - "tools/rename_codex_session.py already requires positional status and work-title arguments and restricts status values, but its focused tests do not cover a missing-status invocation."
  - "shipglows_data/workflow/specs/codex-current-session-rename.md defines only `sessions rename <status>` and does not authorize status inference."
next_step: "/102-sg-start Visual Bug Proof and Session Rename Fidelity"
---

# Spec: Visual Bug Proof and Session Rename Fidelity

## Title

Visual Bug Proof and Session Rename Fidelity

## Status

ready — reviewed for implementation; no implementation has started.

## User Story

As the ShipGlows operator, I want minor visual fixes to retain rendered proof and current-session renames to require an explicit status, so agents cannot overclaim a fix or silently infer workflow state.

## Minimal Behavior Contract

When a purely cosmetic visual bug qualifies for the minor exception, ShipGlows may omit the durable per-bug Markdown file, but it must still name evidence before the fix and apply the repair. It may then report the repair as `implemented`, but it must not call the bug resolved, fixed, verified, or closed until a person has validated the relevant rendered result; if that visual validation is unavailable, it reports the exact proof gap and routes it to the concrete proof owner. When the operator invokes `sessions rename` without a supported status, ShipGlows must not infer one, derive a title, inspect other sessions, call the rename helper, or mutate Codex or project state; it asks one targeted status question, while the helper independently rejects a missing positional status without database mutation. The easiest edge case is mistaking valid image bytes, HTTP 200 responses, a build, or a locally corrected file for proof that the user-visible page rendered the intended portraits.

## Success Behavior

- Given a cosmetic visual defect with no state, permission, data, or interaction consequence, `106-sg-fix` may record `minor exception` instead of creating `shipglows_data/workflow/bugs/BUG-ID.md`.
- Before editing, the fixing phase records `evidence-first` or a justified alternate proof path, the observed defect, and the expected rendered state.
- After the fix, a distinct retest phase obtains a person's validation of the rendered behavior against the correct environment. `107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, or another explicitly justified proof owner may collect or route that validation.
- `003-sg-bug` preserves the ordered state semantics `evidence -> fix-attempted -> retest -> fixed-pending-verify -> verify`; a fix-producing phase cannot promote its own result directly to verified or closed.
- Build, typecheck, asset signature, filesystem presence, URL reachability, and HTTP status remain useful supporting checks but do not substitute for rendered/browser proof of a visual claim.
- If the required target or browser surface is unavailable, the report remains partial or blocked and includes `proof_type`, `owner_skill`, `scenario`, and `target_or_environment` per the existing hosted-proof follow-through contract.
- Given `sessions rename done`, `309-sg-tasks` derives a semantic title and calls the guarded helper exactly as the current contract specifies.
- Given `sessions rename` with no status, `309-sg-tasks` asks for exactly one of `todo`, `doing`, `in_progress`, `blocked`, or `done`, and performs no rename-related read or write.
- The helper rejects a missing positional status before opening a write transaction; focused tests prove the Codex SQLite fixture remains unchanged.

## Error Behavior

- If a visual retest cannot run because the target is unknown, the route starts with `405-sg-prod` target discovery; it does not ask the operator to infer the next proof owner.
- If preview-push mode governs the target, local rendered evidence cannot close the proof gap; the flow follows `005-sg-ship -> 405-sg-prod -> 108-sg-browser/109-sg-auth-debug/107-sg-test` as applicable.
- If browser automation is unavailable, the flow routes the exact manual visual-validation scenario to a person and records `exception-with-proof`, the reason automation is unavailable, the scenario, and the owner; it does not relabel static checks as rendered proof.
- If one actor both applies the code fix and collects the evidence, independence must still be structural: a separate post-fix retest phase against the resulting surface and a later `103-sg-verify` decision are required. A separate subagent is preferred when available but is not itself the proof contract.
- If `sessions rename` omits or supplies an unsupported status, the operator receives a targeted correction request and the current title remains unchanged.
- The missing-status path must never fall through to general `sessions` archive inspection, task synchronization, title derivation, another-thread inspection, or `TASKS.md` mutation.
- The helper must never reinterpret a work-title token as a status, choose a default status, or write after argument validation fails.

## Problem

The existing contracts contain most of the right pieces but leave two activation gaps that surfaced in one real workflow.

First, `106-sg-fix` permits a narrow `minor exception` for a purely cosmetic visual defect. The intended exception concerns durable bug-memory overhead, yet its placement can be read as relaxing the broader bug lifecycle. In the observed testimonial portrait repair, static and transport evidence proved that files and URLs were valid, but no rendered page proof established that the landing page displayed the intended portraits. The result was reported as fixed anyway.

Second, the current-session rename contract accepts only `sessions rename <status>`. In the observed invocation, `<status>` was absent, but the agent inferred `done` from conversational context and mutated the title. That violates the deterministic status gate even though the resulting title happened to sound plausible.

These are execution-fidelity failures, not style issues: one overstates user-visible proof, and one performs a state mutation after inventing a required argument.

## Solution

Strengthen the narrowest reusable owner layers with scenario-first proof. Add one shared rule to the existing proof discipline stating that trace/artifact exceptions never waive behavior proof; adapt it explicitly in `106-sg-fix` and the `003-sg-bug` lifecycle so minor visual defects still follow evidence, fix, independent retest, and verify semantics. Add deterministic missing-status behavior to `309-sg-tasks` and its session playbook, retain the helper's required positional status gate, and add focused mechanical tests that fail on either regression.

## Scope In

- Clarify that the `106-sg-fix` minor exception waives only creation of a new durable bug file.
- Preserve the exception boundary for typo/copy-only fixes, purely cosmetic visual defects without state/permission/data/interaction consequence, and already-tracked duplicates.
- Define a person's rendered visual validation as required for user-visible visual resolution claims; technical checks alone may support an `implemented` report.
- Preserve supporting static checks without treating them as sufficient rendered proof.
- Enforce the lifecycle order across `106-sg-fix` and `003-sg-bug`: evidence before fix, fix-attempted after code change, independent post-fix retest, then `103-sg-verify`.
- Define independence as phase/owner separation and fresh post-fix evidence, not necessarily a different process or subagent.
- Reuse existing development-mode and hosted-proof routing, including explicit proof-gap fields.
- Reject `309-sg-tasks sessions rename` when `<status>` is absent or invalid; request one supported status without inference.
- Preserve valid `sessions rename <status>` current-thread-only, exact-cwd, no-tracker behavior.
- Add pressure-scenario and helper-level regression tests using temporary state only.
- Align internal workflow documentation where it repeats either contract.

## Scope Out

- Changing which defects qualify as truly minor beyond clarifying the proof effect of the exception.
- Requiring a durable bug file for every typo or purely cosmetic defect.
- Requiring a browser retest for copy-only changes whose correctness is fully observable through deterministic text assertions and has no visual-layout claim.
- Requiring a different human or subagent for every retest; the invariant is independent post-fix proof and separate verification authority.
- Replacing `107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, `405-sg-prod`, or `103-sg-verify` with new proof tooling.
- Changing Codex database schema, thread IDs, cwd isolation, title format, five-word title limit, tracker status vocabulary, or prune behavior.
- Inferring a rename status from the latest message, task state, a prior final answer, or existing title.
- Editing project trackers, changelogs, public editorial roadmaps, unrelated skills, or existing completed specs as part of this implementation.
- Committing, pushing, packaging, publishing, or shipping.

## Constraints

- Apply the Reference-First Skill Rule: reusable proof-exception doctrine belongs in `skills/references/spec-driven-development-discipline.md`; keep only activation-critical adaptations in `003-sg-bug` and `106-sg-fix`.
- Do not duplicate the full hosted-proof routing matrix in local skills; link to the shared doctrine and keep compact owner-specific directives.
- Preserve the `professional-bug-management` lifecycle and the already shipped `codex-current-session-rename` contract.
- Do not weaken current exact-cwd, `CODEX_THREAD_ID`, allowed-status, semantic-title, no-tracker, idempotence, or no-other-thread safeguards.
- Scenario tests must use temporary files and temporary SQLite databases; they must never read or write `~/.codex/state_5.sqlite`.
- Contract tests should assert durable semantic markers and pressure-scenario outcomes, not full prose or fragile line counts.
- All modified metadata-bearing references must pass ShipGlows metadata lint.
- Preserve unrelated dirty-worktree changes and avoid whole-file rewrites.
- No new external package is justified.

## Test Contract

- Surface/stack profile: mixed Markdown activation contracts, Python standard-library contract tests, and a guarded SQLite helper.
- Proof path: `scenario-first` because the implementation changes skill, routing, and governance behavior.
- Automated proof:
  - `python3 -m unittest tools.test_bug_proof_fidelity_contract tools.test_rename_codex_session`
  - focused scans for the named pressure scenarios, lifecycle ordering, allowed statuses, and no-inference/no-mutation language
  - `python3 tools/shipglows_metadata_lint.py` on each changed metadata-bearing artifact
  - `python3 tools/audit_shipglows_skills.py`
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `tools/shipglows_sync_skills.sh --check --skill 003-sg-bug --skill 106-sg-fix --skill 309-sg-tasks` if the sync helper accepts repeated `--skill`; otherwise run one supported focused check per changed skill.
- Non-automated proof: adversarial manual walk-through of each pressure scenario against the final activation path, confirming a fresh agent can identify the next required owner and cannot infer `done`.
- Browser/manual application proof: not required for implementing these local contract changes; the contract tests must prove that future visual bug runs require or explicitly route rendered proof.
- Ordered proof ladder: focused unit/contract tests -> metadata lint -> generic audit -> skill budget -> runtime sync -> manual pressure-scenario review.
- Checklist path: none; this chantier changes local skill/tool contracts and uses scenario tests rather than executing a product UI scenario.
- `exception-with-proof`: no live Codex state mutation and no live browser bug repair are performed because the spec hardens orchestration behavior, not an application surface; temporary SQLite and contract fixtures are the safer authoritative proof.

## Dependencies

- `skills/references/spec-driven-development-discipline.md` 1.5.0 supplies proof paths and hosted-proof follow-through.
- `skills/references/skill-instruction-layering.md` 1.1.0 supplies the reference-first and Followability gates.
- `skills/106-sg-fix/references/bug-fix-workflow.md` 1.0.0 supplies detailed fix reporting and execution semantics.
- `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md` 1.4.0 supplies the current session archive contract.
- `shipglows_data/workflow/specs/professional-bug-management.md` 1.0.0 remains the bug-memory and lifecycle source of truth.
- `shipglows_data/workflow/specs/codex-current-session-rename.md` 1.0.0 remains the valid rename source of truth.
- Python standard library: `argparse`, `sqlite3`, `tempfile`, and `unittest`; no dependency addition.
- Fresh external docs: `fresh-docs not needed`, because no framework, SDK, external API, auth provider, deployment provider behavior, or database schema change governs this contract.

## Invariants

- A minor exception changes artifact overhead only; it does not lower the evidence required for a behavior claim.
- A user-visible visual fix is not `resolved`, `fixed`, `verified`, or `closed` solely because code changed, a build passed, image bytes are valid, an asset exists, or a URL returns HTTP 200.
- The fixing phase may report `implemented` after technical validation, but not resolved/fixed until a person validates the post-fix rendered state.
- Retest evidence must be collected after the fix against the relevant rendered surface and environment.
- Verification remains owned by `103-sg-verify`, separate from the fix attempt and retest result.
- Proof gaps name a concrete owner, scenario, proof type, and target/environment rather than leaving the operator to choose a route.
- `sessions rename` has no default status.
- Missing or invalid rename status causes no title derivation, helper call, session inspection, task mutation, or database write.
- Valid rename behavior remains current-thread-only, exact-cwd, semantic, canonical, idempotent, and tracker-independent.
- No test touches live Codex state.

## Links & Consequences

- Upstream: operator bug reports routed through `003-sg-bug` or `106-sg-fix`; current-conversation naming requests routed through `309-sg-tasks`.
- Downstream visual proof owners: `107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, `405-sg-prod`, and `103-sg-verify`.
- Downstream rename mutation: `tools/rename_codex_session.py`, but only after an explicit valid status and semantic work title exist.
- Existing spec consequence: this spec supplements but does not supersede `professional-bug-management.md` or `codex-current-session-rename.md`.
- Runtime/package consequence: none; no public plugin boundary, database schema, service, or package dependency changes.
- Security consequence: none to authorization or sensitive-data handling; existing redaction, exact-cwd, and current-thread safeguards remain mandatory.
- Performance consequence: negligible; the only added runtime work is instruction gating, while tests remain development-only.
- Maintenance consequence: one shared proof rule plus compact local adaptations prevents divergent interpretations across bug owners.

## Documentation Coherence

- Internal documentation impact: yes. Align `skills/106-sg-fix/references/bug-fix-workflow.md` and `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md` with the new deterministic behavior.
- Skill README/public syntax impact: verify `skills/309-sg-tasks/README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `skills/302-sg-help/references/help-catalog.md`, and `shipglows-site/src/content/skills/sg-tasks.md` still show the required `<status>` argument. Edit only a surface that implies omission or inference; otherwise record no-change evidence.
- Bug public documentation impact: verify `shipglows-site/src/content/skills/sg-bug.md` and `shipglows-site/src/content/skills/sg-fix.md` do not promise that minor visual work can be called fixed without rendered proof. Edit only if the public promise conflicts with the hardened internal contract.
- Editorial roadmap impact: none. This is workflow/tooling fidelity, not a public-content backlog item, and `shipglows_data/editorial/ROADMAP.md` stays untouched.
- Changelog impact: none during implementation under this chantier unless a later authorized closure/ship phase explicitly owns a user-facing changelog entry.
- Existing completed specs stay unchanged; this new spec records the follow-up contract.

## Edge Cases

- A portrait asset is a valid PNG and its remote URL returns HTTP 200, but CSS clips it, the DOM references a different source, hydration replaces it, or the browser blocks it: static checks pass, the repair may be reported implemented, but the bug is not resolved until a person validates its rendered state.
- A visual defect occurs only at a responsive breakpoint: the retest scenario must name the viewport/state rather than using a generic homepage load.
- A visual fix is local but the project uses preview-push authority: the local browser result is supporting evidence only and the hosted proof route remains required.
- Browser proof cannot run because the URL is unknown: route to `405-sg-prod` for target discovery before choosing browser/auth/manual proof.
- The same agent applies and retests a fix: acceptable only when the retest is a distinct post-fix phase against the resulting surface and `103-sg-verify` remains a separate decision gate.
- A copy-only typo has no layout or rendered-state claim: deterministic text proof may be proportionate; this does not broaden the exception to visual-layout claims.
- `sessions rename` is followed by whitespace only: treat status as absent, ask the targeted status question, and do nothing else.
- `sessions rename finished`: reject the unsupported synonym and list the five canonical statuses; do not map it to `done`.
- A prior final answer said the work was complete: it is evidence for a possible operator choice, not authority to infer the missing rename status.
- The current title is already canonical: missing status still cannot trigger idempotent inference; no helper call occurs.
- The helper receives too few positional arguments directly: argument parsing exits non-zero and the temporary database remains byte-for-byte or row-for-row unchanged.

## Implementation Tasks

- [ ] Task 1: Add the reusable proof-exception rule and visual pressure scenario.
  - File: `skills/references/spec-driven-development-discipline.md`
  - Action: state that artifact/trace exceptions never waive behavior proof; add `VISUAL-MINOR-EXCEPTION-PROOF` and the static-check-not-rendered-proof boundary while reusing hosted-proof routing.
  - User story link: prevents a minor visual fix from being reported complete without rendered evidence.
  - Depends on: none.
  - Validate with: `python3 -m unittest tools.test_bug_proof_fidelity_contract` plus metadata lint.
  - Notes: keep the doctrine reusable and compact; do not add a second hosted-proof matrix.

- [ ] Task 2: Bind the minor exception to bug-memory only in the fix owner.
  - Files: `skills/106-sg-fix/SKILL.md`, `skills/106-sg-fix/references/bug-fix-workflow.md`
  - Action: make the exception's sole effect explicit, require evidence before fix, permit `implemented` after technical validation, require a person's rendered visual validation before resolved/fixed wording and later verification, and expose structured proof-gap routing in the detailed report path.
  - User story link: preserves fast handling of truly minor defects without weakening user-visible proof.
  - Depends on: Task 1.
  - Validate with: `python3 -m unittest tools.test_bug_proof_fidelity_contract`, focused `rg`, metadata lint, and skill budget audit.
  - Notes: preserve design-system drift checks and current direct/spec-first routing.

- [ ] Task 3: Enforce ordered, independent retest semantics in the bug-loop owner.
  - File: `skills/003-sg-bug/SKILL.md`
  - Action: add the activation-critical rule that minor trace exceptions do not bypass evidence/retest/verify, that static asset/build/HTTP checks cannot close visual claims, and that post-fix retest uses a distinct proof owner/phase before `103-sg-verify`.
  - User story link: prevents lifecycle orchestration from accepting the fixing phase's own optimistic completion claim.
  - Depends on: Tasks 1-2.
  - Validate with: `python3 -m unittest tools.test_bug_proof_fidelity_contract`, focused `rg`, generic skill audit, and skill budget audit.
  - Notes: do not duplicate `106-sg-fix` internals or require a separate subagent as the only form of independence.

- [ ] Task 4: Add focused visual bug proof regression tests.
  - File: `tools/test_bug_proof_fidelity_contract.py`
  - Action: create scenario-first contract tests covering `VISUAL-MINOR-EXCEPTION-PROOF`, `VISUAL-STATIC-CHECK-NOT-RENDERED-PROOF`, `BUG-FIX-INDEPENDENT-RETEST`, and structured proof-gap routing across the shared reference, `106`, and `003`.
  - User story link: makes the proof rule mechanically durable instead of relying on wording review alone.
  - Depends on: Tasks 1-3.
  - Validate with: `python3 -m unittest tools.test_bug_proof_fidelity_contract`.
  - Notes: assert semantic markers and owner boundaries, not exact paragraphs.

- [ ] Task 5: Define deterministic missing-status behavior for current-session rename.
  - Files: `skills/309-sg-tasks/SKILL.md`, `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`
  - Action: add pressure scenario `CONVERSATION-RENAME-MISSING-STATUS`; reject omission or invalid status, ask one targeted status question, and prohibit title derivation, helper invocation, session/archive inspection, tracker mutation, and status inference on that path.
  - User story link: ensures the operator controls workflow state before any title mutation.
  - Depends on: none.
  - Validate with: `python3 -m unittest tools.test_rename_codex_session` plus metadata lint and focused `rg`.
  - Notes: preserve the explicit command's no-second-confirmation behavior after a valid status is supplied.

- [ ] Task 6: Prove the helper rejects missing status without live-state access.
  - File: `tools/test_rename_codex_session.py`
  - Action: add helper/CLI tests showing too few arguments and unsupported statuses fail non-zero or raise the expected parser/error path before any temporary SQLite row changes; extend the contract test to require the missing-status pressure scenario in `309` and the playbook.
  - User story link: provides a second deterministic guard beneath the conversational contract.
  - Depends on: Task 5.
  - Validate with: `python3 -m unittest tools.test_rename_codex_session`.
  - Notes: `tools/rename_codex_session.py` should remain unchanged if its current required positional argument already passes the new test; do not add a default.

- [ ] Task 7: Verify documentation coherence without widening the chantier.
  - Files: `skills/309-sg-tasks/README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `skills/302-sg-help/references/help-catalog.md`, `shipglows-site/src/content/skills/sg-tasks.md`, `shipglows-site/src/content/skills/sg-bug.md`, `shipglows-site/src/content/skills/sg-fix.md`
  - Action: scan the named surfaces for contradiction; update only those that imply status inference or proof-free visual closure, otherwise retain them and record no-change evidence in verification.
  - User story link: keeps operator-facing promises aligned with the internal workflow contract.
  - Depends on: Tasks 2-5.
  - Validate with: focused `rg`, metadata lint for changed artifacts, and public content schema/build checks only if a public page changes.
  - Notes: do not mutate editorial roadmap or unrelated skill catalog entries.

- [ ] Task 8: Run the complete scenario-first verification set.
  - Files: all files changed by Tasks 1-7; no new runtime artifact.
  - Action: run focused tests, metadata lint, generic audit, budget audit, focused runtime sync, dirty-diff review, and adversarial scenario walk-through; record any unavailable proof as partial rather than passing.
  - User story link: proves both failure classes are prevented without regressing valid flows.
  - Depends on: Tasks 1-7.
  - Validate with: all commands in `Test Contract` and `git diff --check` limited to scoped files.
  - Notes: stop if unrelated dirty changes overlap any target file rather than overwriting them.

## Acceptance Criteria

- [ ] AC 1: Given a purely cosmetic visual defect qualifies for the minor exception, when `106-sg-fix` executes, then only creation of a new durable bug file is waived and the proof path remains mandatory.
- [ ] AC 2: Given a visual fix has passed build, file-signature, existence, URL, or HTTP checks, when no person has validated the rendered result, then the workflow may report it implemented but neither `106-sg-fix` nor `003-sg-bug` may report the user-visible behavior resolved, fixed, verified, or closed.
- [ ] AC 3: Given a visual fix has been applied, when the lifecycle continues, then a distinct post-fix retest phase records a person's rendered validation before `103-sg-verify` can decide closure.
- [ ] AC 4: Given the same agent performs fix and retest, when independence is evaluated, then a fresh post-fix proof phase and separate verification decision satisfy the contract; mere reuse of pre-fix/static evidence does not.
- [ ] AC 5: Given the rendered proof target is unavailable or unknown, when the run reports a gap, then it includes `proof_type`, `owner_skill`, `scenario`, and `target_or_environment` and avoids completion language.
- [ ] AC 6: Given preview-push authority applies, when only local rendered proof exists, then the bug remains unverified until the existing ship/prod/browser-auth-manual route completes or a valid exception-with-proof is recorded.
- [ ] AC 7: Given `sessions rename done`, when title derivation succeeds, then only the current exact-cwd `CODEX_THREAD_ID` title is updated and no tracker or other thread changes.
- [ ] AC 8: Given `sessions rename` omits `<status>`, when `309-sg-tasks` parses the invocation, then it asks for one canonical status and performs no title derivation, helper call, session inspection, tracker mutation, or database write.
- [ ] AC 9: Given `sessions rename finished` uses an unsupported status, when parsed, then it is rejected without synonym mapping or mutation and the five allowed values are presented.
- [ ] AC 10: Given the helper is invoked with a missing positional status/work-title shape, when argument parsing fails, then focused tests prove the temporary SQLite fixture is unchanged and live Codex state is never opened.
- [ ] AC 11: Given a valid status is supplied, when the operation reaches the helper, then the existing exact-cwd, current-thread-only, semantic-title, five-word, canonical-status, idempotence, and no-tracker gates still pass.
- [ ] AC 12: Given a fresh agent loads the changed activation contracts, when it walks `VISUAL-MINOR-EXCEPTION-PROOF` and `CONVERSATION-RENAME-MISSING-STATUS`, then it can identify the required next action without relying on duplicated doctrine or conversational inference.
- [ ] AC 13: Given implementation is complete, when validation runs, then focused tests, metadata lint, generic audit, budget audit, runtime sync, and diff checks pass or the chantier remains partial/blocked with the failing evidence named.
- [ ] AC 14: Given documentation coherence is reviewed, when existing public/internal surfaces already state `sessions rename <status>` and do not promise proof-free visual closure, then they remain unchanged with recorded scan evidence rather than receiving cosmetic churn.

## Test Strategy

- Unit/helper: extend `tools/test_rename_codex_session.py` with missing-argument and no-mutation cases against temporary SQLite.
- Contract: create `tools/test_bug_proof_fidelity_contract.py` to assert the shared doctrine and owner skills expose the required scenarios, lifecycle boundary, and proof-gap route.
- Regression: rerun every existing `SessionRenameTests` and `SessionNamingContractTests` case to preserve valid current-session behavior.
- Integration: run the generic skill audit and focused runtime sync after all contract edits.
- Metadata: lint the shared reference, bug-fix workflow, session playbook, and this spec; lint any public metadata-bearing page only if changed.
- Manual/adversarial: walk the exact observed portrait scenario and the exact missing-status invocation from initial input to report/mutation boundary.
- Negative proof: confirm no test reads the live Codex database, no `TASKS.md` or editorial roadmap changes, and no existing spec rewrite.

## Risks

- Over-broad browser requirement: mitigated by limiting rendered proof to visual/user-visible claims and retaining proportionate deterministic proof for copy-only changes.
- False independence: mitigated by defining independence as fresh post-fix phase plus separate verification authority, not merely a different agent label.
- Duplicated doctrine and skill bloat: mitigated by shared-reference-first placement and focused local activation directives.
- Brittle prose tests: mitigated by named scenario markers, required fields, and semantic assertions instead of full-sentence matching.
- Breaking valid rename UX: mitigated by preserving no-second-confirmation semantics after an explicit valid status.
- Accidental live-state mutation during tests: mitigated by temporary databases, explicit fixture paths, and tests that fail if default Codex state is consulted.
- Dirty-worktree collision: mitigated by authoritative rereads, bounded patches, and stopping on overlap rather than normalizing files.
- Public docs churn: mitigated by scan-first documentation tasks and edits only for demonstrated contradiction.

## Execution Notes

- Read first, in order: `skills/references/spec-driven-development-discipline.md`, `skills/106-sg-fix/SKILL.md`, `skills/106-sg-fix/references/bug-fix-workflow.md`, `skills/003-sg-bug/SKILL.md`, then `skills/309-sg-tasks/SKILL.md` and the session playbook.
- Implement proof doctrine at the shared layer first, then add the smallest activation-critical owner adaptations.
- Define tests from the pressure scenarios before changing contract text.
- Preserve `tools/rename_codex_session.py` unless the focused missing-argument test demonstrates that the existing required positional gate can mutate or return ambiguously; a passing existing guard is evidence, not a reason for churn.
- Do not introduce a new proof owner, status vocabulary, database abstraction, parser dependency, or session-state store.
- Do not turn `minor exception` into a generic `no bug process` mode.
- Do not require a different subagent when sequential fresh evidence and independent verification already provide the intended separation.
- Stop and reroute to a new spec if implementation reveals that public command syntax, Codex schema, bug statuses, or proof-owner responsibilities must change materially.
- Fresh external docs: `fresh-docs not needed`.
- Validation commands are those listed in `Test Contract`; use canonical ShipGlows-owned paths and preflight before running owned tools.

## Open Questions

None. The operator approved a full cross-skill/tooling hardening spec, the existing rename contract supports strict rejection, and the existing proof-owner architecture supports independent rendered retest without a new product or security decision.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-17 14:15:19 UTC | 100-sg-spec | GPT-5 Codex | Created the full scenario-first contract for visual minor-exception proof and deterministic missing-status session rename behavior. | draft ready for review | /101-sg-ready shipglows_data/workflow/specs/visual-bug-proof-and-session-rename-fidelity.md |
| 2026-07-18 00:00:00 UTC | 100-sg-spec | GPT-5 Codex | Clarified the proportional visual-bug rule: technical checks may establish implementation; only a person's rendered validation establishes resolution. | draft refined | /101-sg-ready shipglows_data/workflow/specs/visual-bug-proof-and-session-rename-fidelity.md |
| 2026-07-18 12:25:51 UTC | 101-sg-ready | GPT-5 Codex | Reviewed structure, behavior, scenario-first proof, security boundaries, dependencies, and execution order. | ready | /102-sg-start Visual Bug Proof and Session Rename Fidelity |
| 2026-07-18 12:32:03 UTC | 103-sg-verify | GPT-5.5 (requested; unavailable, used GPT-5 Codex) | mode=standard; scoped scenario-first verification found focused tests, metadata lint, skill audit, budget audit, runtime sync, documentation scan, and diff hygiene passing, but implementation progress and dependency-version trace remain stale in this spec. | partial | Reconcile the implemented-task/acceptance state and `depends_on` versions, then rerun standard verification. |

## Current Chantier Flow

- `100-sg-spec`: done; full draft created and locally validated.
- `101-sg-ready`: ready; fresh-context implementation approved.
- `102-sg-start`: implementation evidence exists in the scoped diff, but durable task/acceptance progress is not recorded.
- `900-shipglows-core refresh`: not started; required after material skill edits.
- `103-sg-verify`: partial; behavioral and mechanical evidence pass, but task-progress and dependency-version trace are stale.
- `104-sg-end`: not started.
- `005-sg-ship`: not authorized.
- Next step: reconcile the active spec's implementation progress and `depends_on` versions, then rerun standard verification.
