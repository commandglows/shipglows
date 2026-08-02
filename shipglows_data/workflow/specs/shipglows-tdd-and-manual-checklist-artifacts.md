---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-05-24"
created_at: "2026-05-24 17:23:00 UTC"
updated: "2026-05-29"
updated_at: "2026-05-30 20:21:23 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5.5 Codex"
scope: workflow
owner: Diane
user_story: "En tant qu'opératrice ShipGlows, je veux que les specs et le TDD génèrent des contrats de preuve stack-agnostic et des checklists de test durables que je peux remplir en PASS/FAIL/BLOCKED dans un fichier, afin d'éviter les copier-coller de chat et de donner aux agents une vraie source de suivi."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-spec/SKILL.md
  - skills/sg-spec/references/spec-creation-workflow.md
  - skills/sg-ready/SKILL.md
  - skills/sg-start/SKILL.md
  - skills/sg-start/references/execution-workflow.md
  - skills/sg-test/SKILL.md
  - skills/sg-verify/SKILL.md
  - skills/sg-verify/references/verification-gates.md
  - skills/references/spec-driven-development-discipline.md
  - templates/
  - tools/shipglows_metadata_lint.py
  - tools/shipglows_checklist_status.py
depends_on:
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "templates/spec.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
evidence:
  - "User decision 2026-05-24: TDD should be integrated into ShipGlows skills, not handled as ad hoc chat instructions."
  - "User decision 2026-05-24: manual checklists should be generated during spec or TDD as files that the operator can fill with PASS/FAIL/BLOCKED."
  - "User decision 2026-05-24: ShipGlows proof rules should be technology-agnostic by default, with stack profiles for Flutter, Astro, Python, APIs, auth, and provider/device surfaces."
  - "User decision 2026-05-24: validation must be proportional; small low-risk edits should not trigger heavy stack checks such as full Flutter analysis/tests by default."
  - "User decision 2026-05-27: generated manual checklists use the fixed canonical path shipglows_data/workflow/test-checklists/<scope>.md."
  - "User decision 2026-05-27: implement a small checklist parser/helper so sg-test and sg-verify consume statuses mechanically instead of relying only on agent interpretation."
  - "Fresh docs 2026-05-27: GitHub Actions official workflow syntax docs at https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions confirm paths/paths-ignore filtering, workflow_dispatch, and the caveat that workflows skipped by path/branch/message filtering leave associated checks pending when required."
next_step: "None"
---

# Spec: ShipGlows TDD And Manual Checklist Artifacts

## Title

ShipGlows TDD And Manual Checklist Artifacts

## Status

ready

## User Story

En tant qu'opératrice ShipGlows, je veux que les specs et le TDD génèrent des contrats de preuve stack-agnostic et des checklists de test durables que je peux remplir en PASS/FAIL/BLOCKED dans un fichier, afin d'éviter les copier-coller de chat et de donner aux agents une vraie source de suivi.

## Minimal Behavior Contract

ShipGlows must extend its spec-driven lifecycle with a stack-agnostic test-driven contract layer: specs and execution skills define the strongest practical proof ladder for the detected surface, choose a validation level proportional to the change risk, prioritize automated and agent-run proof, then generate a durable manual checklist file only for proof that remains human, provider-specific, environment-specific, or device-only. The operator can edit that file directly by marking scenarios `PASS`, `FAIL`, `BLOCKED`, `N/A`, or leaving `NOT_RUN`, with optional observed notes and evidence pointers. `sg-test` must consume that file as source of truth, write compact `shipglows_data/workflow/TEST_LOG.md` entries, and create or update `shipglows_data/workflow/bugs/BUG-ID.md` for failing scenarios. The easy edge case is hard-coding the lifecycle to one technology, running heavy checks for trivial edits, or generating a large checklist that becomes another dead document; required scenarios must be scoped, statused, stack-aware, and consumed mechanically by the skills.

## Success Behavior

- Preconditions: A spec, bug, or implementation scope has at least one behavior that cannot be fully proven by automated tests, `sg-browser`, or `sg-auth-debug`.
- Trigger: `sg-spec`, `sg-start`, or `sg-test` determines that manual/operator confirmation is still necessary.
- User/operator result: A Markdown checklist file is created or updated at a predictable project path, and the operator can fill status cells directly without copying results into chat.
- System effect: `sg-test` reads the checklist through a small parser/helper, records compact test history, opens or updates bug files for failures, and leaves unresolved scenarios visible for `sg-verify`.
- Success proof: Metadata lint for the checklist template, skill `rg` checks proving references are wired, and a dry-run fixture or sample checklist showing `PASS`, `FAIL`, `BLOCKED`, and `NOT_RUN` interpretation.
- Silent success: Not allowed. Checklist creation, consumed statuses, generated bug IDs, and remaining gaps must be reported.

## Error Behavior

- Expected failures: checklist missing, malformed status, duplicate scenario IDs, missing expected result, failing scenario without observed behavior, evidence path escaping repo root, or manual checklist not linked from the spec.
- User/operator response: The responsible skill reports the exact checklist issue and asks for only the missing field or routes to regenerate the checklist.
- System effect: Do not mark tests passed, do not close bugs, and do not claim verification while required checklist scenarios are `FAIL`, `BLOCKED`, or `NOT_RUN`.
- Must never happen: invented PASS results, overwritten operator notes, raw secrets in observed/evidence fields, full logs pasted into checklist tables, stack-specific proof forced onto unrelated projects, or manual/device/provider testing requested before cheaper proofs are attempted.
- Heavy-check overuse must also be avoided: do not run full analysis, full test suites, device builds, or broad browser campaigns for a tiny low-risk copy/style/config edit unless the changed surface or project contract makes that check relevant.
- Silent failure: Not allowed. Invalid or incomplete checklists must produce an explicit `partial`, `blocked`, or `not verified` verdict.

## Problem

ShipGlows currently handles manual proof mostly through chat prompts and compact `shipglows_data/workflow/TEST_LOG.md` entries. That creates friction for the operator, encourages copy-paste, and gives agents weak durable state. It also makes TDD feel separate from spec-driven development, even though manual proof should be part of the same test contract.

## Solution

Introduce a durable `manual_test_checklist` artifact and teach `sg-spec`, `sg-start`, `sg-test`, and `sg-verify` to generate, consume, and verify it. The spec remains the source of behavior; the checklist becomes the operator-editable execution surface for manual scenarios.

## Scope In

- Add `templates/manual_test_checklist.md`.
- Define a canonical project path for generated checklists: `shipglows_data/workflow/test-checklists/<scope>.md`.
- Update spec creation rules so non-trivial specs include a stack-agnostic `Test Contract` and link to a checklist when manual proof is expected.
- Update `sg-start` execution rules so TDD/test-first work creates or updates checklist artifacts when human/device-only proof remains.
- Update `sg-test` to read checklist files, normalize statuses, write compact `shipglows_data/workflow/TEST_LOG.md`, and create/update bug records for failed rows.
- Update `sg-verify` to treat required checklist scenarios as verification evidence and block/partial when required rows are unresolved.
- Define a generic proof ladder plus stack profiles for common ShipGlows surfaces such as Flutter apps, Astro sites, Python services/scripts, API contracts, auth/browser flows, provider integrations, and device/native behavior.
- Add validation proportionality rules so small low-risk edits can use targeted checks or explicit no-impact reasoning instead of automatic full-stack checks.
- Add CI path-filter rules so pushes trigger only the GitHub Actions workflows owned by the changed surface, with manual dispatch for forced runs.

## Scope Out

- No full test runner implementation for Flutter, Astro, Python, Playwright, Patrol, Maestro, Firebase Test Lab, Pact, CodeRabbit, Semgrep, or CodeQL in this spec.
- No migration of historical `shipglows_data/workflow/TEST_LOG.md` entries.
- No replacement of `shipglows_data/workflow/bugs/BUG-ID.md`; checklists point to bug files, they do not become bug dossiers.
- No automatic mutation of production data during checklist execution.

## Constraints

- The checklist must be easy for the operator to edit by hand.
- The checklist must be machine-readable enough for agents to parse with simple Markdown/table logic.
- Generated checklists must use the fixed canonical path `shipglows_data/workflow/test-checklists/<scope>.md`; v1 does not support project-specific folder overrides.
- Agents must preserve operator-entered notes and statuses.
- `sg-test` and `sg-verify` must rely on a small parser/helper for status normalization, required/optional row interpretation, duplicate scenario detection, and safe evidence-path checks.
- Validation must be proportional to risk, changed surface, and project contract; heavier checks need a reason, not habit.
- CI must be proportional too: app, site, backend, docs, skills, and workflow checks should be split by path filters instead of one push triggering every expensive job.
- `shipglows_data/workflow/TEST_LOG.md` remains compact; full failed context belongs in `shipglows_data/workflow/bugs/BUG-ID.md`.
- Sensitive evidence must be redacted and stored by pointer, not pasted raw.
- Existing dirty worktree changes must not be reverted or overwritten during implementation.

## Dependencies

- Runtime: Markdown parsing through a small ShipGlows-owned parser/helper; no third-party runtime dependency required unless implementation proves it necessary.
- Document contracts: `spec-driven-development-discipline.md`, `decision-quality-contract.md`, existing spec template, bug record template, and `sg-test` bug lifecycle.
- Metadata gaps: `manual_test_checklist` is a new artifact type and may require `tools/shipglows_metadata_lint.py` support.
- Fresh external docs: GitHub Actions official workflow syntax docs checked on 2026-05-27 at `https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions` for `paths`/`paths-ignore`, `workflow_dispatch`, and skipped-workflow pending check behavior.

## Invariants

- Specs define expected behavior; checklists only execute or record proof.
- A checklist row cannot be considered passing unless an operator or agent observed the result.
- Failed checklist rows must link to a bug file or a concrete next action.
- Required checklist rows with `FAIL`, `BLOCKED`, or `NOT_RUN` prevent a clean `sg-verify` verdict.
- Manual/device/provider rows are only required after cheaper proof surfaces are attempted or ruled out for the detected stack.
- Trivial or low-risk edits may use targeted proof, such as a focused file read, snapshot expectation, type-local check, targeted test, or explicit `no functional impact` note, instead of broad analysis/test runs.
- GitHub Actions workflows should use positive `paths` filters for their owned surfaces and `workflow_dispatch` for manual override. Branch protection must not require a path-filtered job in contexts where it will be skipped, unless a separate always-on meta/status workflow handles required checks.

## Links & Consequences

- Upstream systems: `sg-spec`, `sg-ready`, `sg-start`, `sg-test`, `sg-verify`, bug lifecycle, spec-driven development discipline.
- Downstream systems: `shipglows_data/workflow/TEST_LOG.md`, `shipglows_data/workflow/bugs/BUG-ID.md`, `test-evidence/BUG-ID/`, final ship readiness, operator workflow.
- Cross-cutting checks: redaction, path safety, metadata lint, skill runtime sync, public skill docs if behavior promises change.
- CI consequences: `.github/workflows/**` may need surface-specific path filters, required-check review, and workflow dispatch support so docs/spec/skill pushes do not trigger app builds or APK jobs.

## Documentation Coherence

- Update `sg-test` README and public skill page if they describe manual QA prompts but not checklist files.
- Update `sg-help` catalog if it describes `sg-test` as chat-only guided manual QA.
- Update `spec-driven-development-discipline.md` to include stack-agnostic proof ladders and checklist artifacts as part of proof-first/TDD.
- Update `templates/spec.md` or `sg-spec` workflow so future specs know where `Test Contract` and checklist links belong.

## Edge Cases

- Operator marks `FAIL` but leaves observed behavior blank.
- Operator writes lowercase `pass` or French `réussi`; parser should normalize only documented aliases or ask for clarification.
- Multiple rows fail the same underlying bug; `sg-test` should avoid duplicate bug files when reproduction and observed behavior clearly match.
- Checklist contains optional exploratory rows; unresolved optional rows should not block verification.
- Checklist references an evidence path outside the repo; `sg-test` must reject or ask for a safe pointer.
- Auth flow row belongs to `sg-auth-debug`, not generic `sg-browser`.
- Astro/public-site row skips build/content-schema/browser proof and jumps to human review; verification must flag the proof order gap.
- Python/API row skips unit/contract tests and jumps to manual verification; verification must flag the proof order gap.
- Flutter UI row is Web-testable but checklist jumps straight to APK; verification must flag the stack-profile proof order gap.
- Tiny text/style-only row triggers full Flutter analysis/test suite without changed behavior or risk; verification should flag the validation as overbroad and recommend a proportional check policy.
- Docs/spec/skills-only push triggers app/APK CI because workflows lack path filters; verification should flag CI as overbroad and route to workflow filtering.

## Implementation Tasks

- [ ] Task 1: Add manual checklist artifact template
  - File: `templates/manual_test_checklist.md`
  - Action: Define frontmatter, status vocabulary, scenario table, operator-fill rules, redaction rules, evidence pointer rules, and maintenance rule.
  - User story link: Gives the operator a file to fill instead of replying in chat.
  - Depends on: None
  - Validate with: `python3 tools/shipglows_metadata_lint.py templates/manual_test_checklist.md`
  - Notes: Use statuses `NOT_RUN`, `PASS`, `FAIL`, `BLOCKED`, `N/A`.

- [ ] Task 2: Teach metadata lint the new artifact type
  - File: `tools/shipglows_metadata_lint.py`
  - Action: Accept `artifact: manual_test_checklist` with required metadata fields.
  - User story link: Keeps generated checklists durable and auditable.
  - Depends on: Task 1
  - Validate with: `python3 tools/shipglows_metadata_lint.py templates/manual_test_checklist.md`
  - Notes: Do not lint `shipglows_data/workflow/TEST_LOG.md`.

- [ ] Task 3: Add stack-agnostic Test Contract and checklist generation rules to spec creation
  - File: `skills/sg-spec/references/spec-creation-workflow.md`
  - Action: Require a `Test Contract` section for non-trivial specs: detected stack/surface, automated tests, agent-run browser/auth proof, contract/integration proof, provider/device proof, manual checklist path, and explicit exceptions.
  - User story link: Makes TDD part of the spec, not an afterthought.
  - Depends on: Task 1
  - Validate with: `rg -n "Test Contract|manual_test_checklist|test-checklists|PASS|FAIL|BLOCKED" skills/sg-spec/references/spec-creation-workflow.md`
  - Notes: Specs should link the checklist path when one is generated.

- [ ] Task 4: Update spec template with Test Contract placeholder
  - File: `templates/spec.md`
  - Action: Add `Test Contract` after `Acceptance Criteria` or before `Test Strategy`, with manual checklist link and stack-agnostic proof ladder fields.
  - User story link: Makes future specs mechanically consistent.
  - Depends on: Task 3
  - Validate with: `rg -n "Test Contract|Manual checklist|Proof ladder" templates/spec.md`
  - Notes: Keep the template concise.

- [ ] Task 5: Update TDD/proof discipline reference
  - File: `skills/references/spec-driven-development-discipline.md`
  - Action: Define stack-agnostic proof ladders, validation proportionality, and checklist artifacts as part of proof-first TDD when manual proof remains after automated/browser/auth/provider evidence.
  - User story link: Aligns checklist files with the core lifecycle doctrine.
  - Depends on: Task 1
  - Validate with: `rg -n "manual checklist|test-checklists|manual_test_checklist|proof-first" skills/references/spec-driven-development-discipline.md`
  - Notes: Flutter, Astro, Python, API, auth, provider, and device profiles must be examples beneath the generic doctrine, not the core doctrine.

- [ ] Task 6: Update execution workflow
  - File: `skills/sg-start/references/execution-workflow.md`
  - Action: Choose a proportional validation level before editing; when implementation leaves manual/device/provider-specific proof, generate or update the linked checklist before reporting completion.
  - User story link: Ensures the checklist exists during TDD/development, not only after verification fails.
  - Depends on: Tasks 3 and 5
  - Validate with: `rg -n "manual checklist|test-checklists|sg-test|proof ladder|stack|proportional|sg-browser|sg-auth-debug" skills/sg-start/references/execution-workflow.md`
  - Notes: Do not create filler checklists for fully automated scopes.

- [ ] Task 6.5: Update check selection policy
  - File: `skills/sg-check/SKILL.md`
  - Action: Add a proportional check-selection rule: quick tiny edits use targeted checks or no-impact reasoning; broad analysis/test/build commands are reserved for behavior, imports, generated code, dependencies, shared components, risky config, or pre-ship verification.
  - User story link: Prevents agents from running expensive or annoying checks at every tiny edit.
  - Depends on: Task 5
  - Validate with: `rg -n "proportional|targeted checks|no functional impact|full suite|tiny edit|broad checks" skills/sg-check/SKILL.md`
  - Notes: Flutter `flutter analyze`/full test runs are examples, not the only target.

- [ ] Task 6.6: Add proportional CI path-filter policy
  - File: `skills/references/spec-driven-development-discipline.md`, `skills/sg-ship/SKILL.md`, `skills/sg-ci-build/SKILL.md` if present, and relevant project workflow docs
  - Action: Define that GitHub Actions workflows should use positive `paths` filters by surface, plus `workflow_dispatch`; document required-check caveats when branch protection expects skipped path-filtered workflows.
  - User story link: Prevents docs/spec/skill pushes from triggering expensive app/APK jobs.
  - Depends on: Task 6.5
  - Validate with: `rg -n "paths:|paths-ignore|workflow_dispatch|required checks|path-filter|surface" skills shipglows_data/technical .github/workflows 2>/dev/null || true`
  - Notes: Prefer positive `paths` filters over broad `paths-ignore` because ownership is clearer.

- [ ] Task 7: Update sg-test checklist consumption
  - File: `skills/sg-test/SKILL.md`, `tools/shipglows_checklist_status.py`
  - Action: Add checklist mode: read a checklist file through the parser/helper, normalize statuses, ask only for missing actionable details, append compact `shipglows_data/workflow/TEST_LOG.md`, and create/update bug files for failed required rows.
  - User story link: Lets the operator fill the file and lets agents continue from it.
  - Depends on: Task 1
  - Validate with: `rg -n "manual_test_checklist|test-checklists|PASS|FAIL|BLOCKED|NOT_RUN|checklist mode" skills/sg-test/SKILL.md`
  - Notes: Preserve compact bug model and redaction rules.

- [ ] Task 8: Update verification gates
  - File: `skills/sg-verify/SKILL.md`, `skills/sg-verify/references/verification-gates.md`
  - Action: Add a manual checklist gate: required rows must be passed, linked to accepted bug follow-up, or explicitly waived with reason before clean verification.
  - User story link: Gives agents a real durable source for manual proof status.
  - Depends on: Task 7
  - Validate with: `rg -n "Manual Checklist|manual_test_checklist|test-checklists|PASS|FAIL|BLOCKED|NOT_RUN" skills/sg-verify/SKILL.md skills/sg-verify/references/verification-gates.md`
  - Notes: `FAIL` should normally block or route to bug work.

- [ ] Task 9: Update readiness gate
  - File: `skills/sg-ready/SKILL.md`
  - Action: Ensure ready specs with required manual proof either include a checklist path or explicitly state why no manual checklist is needed.
  - User story link: Prevents specs from becoming ready without a proof plan.
  - Depends on: Task 3
  - Validate with: `rg -n "Test Contract|manual checklist|test-checklists|ready" skills/sg-ready/SKILL.md`
  - Notes: Keep small/local specs lightweight.

- [ ] Task 10: Update docs/help/public pages if public promise changes
  - File: `skills/sg-test/README.md`, `skills/sg-help/references/help-catalog.md`, `site/src/content/skills/sg-test.md` if present
  - Action: Explain checklist files, operator-fill workflow, bug routing, and relation to `shipglows_data/workflow/TEST_LOG.md`.
  - User story link: Makes the workflow discoverable.
  - Depends on: Tasks 7 and 8
  - Validate with: `rg -n "checklist|test-checklists|PASS|FAIL|BLOCKED|TEST_LOG" skills/sg-test/README.md skills/sg-help/references/help-catalog.md site/src/content/skills/sg-test.md`
  - Notes: Build site only if public content changes.

## Acceptance Criteria

- [ ] AC 1: Given a non-trivial spec has manual/device/provider-only proof, when `sg-spec` completes, then the spec contains a stack-agnostic `Test Contract` with detected surface, automated proof, agent-run browser/auth proof, contract/integration proof when relevant, manual checklist path, and unresolved proof gaps.
- [ ] AC 2: Given a checklist file is generated, when metadata lint runs, then the checklist template and any generated sample pass lint or have a documented tracker exception.
- [ ] AC 3: Given the operator fills a required row as `PASS`, when `sg-test` consumes the checklist, then it records a compact `shipglows_data/workflow/TEST_LOG.md` pass pointer without asking for duplicate chat input.
- [ ] AC 4: Given the operator fills a required row as `FAIL`, when `sg-test` consumes the checklist, then it creates or updates `shipglows_data/workflow/bugs/BUG-ID.md`, writes a compact `shipglows_data/workflow/TEST_LOG.md` pointer, and links the bug ID in the checklist or report.
- [ ] AC 5: Given a required row is `BLOCKED` or `NOT_RUN`, when `sg-verify` runs, then verification is `partial`, `not verified`, or `blocked` with a concrete next action.
- [ ] AC 6: Given a checklist jumps to manual/device/provider proof while cheaper stack-appropriate proof is available, when `sg-verify` runs, then it flags the proof ladder gap.
- [ ] AC 7: Given all required checklist rows are `PASS` and automated/browser proof passed, when `sg-verify` runs, then manual proof does not require chat copy-paste and can be cited from the checklist.
- [ ] AC 8: Given a checklist row includes raw secrets or an unsafe evidence path, when `sg-test` reads it, then it refuses to persist unsafe evidence and asks for a redacted pointer.
- [ ] AC 9: Given a tiny low-risk text/style-only edit, when an execution skill chooses validation, then it must not run broad full-stack checks by default and must record targeted proof or `no functional impact`.
- [ ] AC 10: Given behavior, imports, generated code, shared component, dependency, risky config, auth, data, provider, or pre-ship scope changes, when validation is selected, then the skill must choose the relevant heavier check and explain why.
- [ ] AC 11: Given a push changes only docs/specs/skills outside the app path, when GitHub Actions evaluates workflows, then app/APK workflows are skipped by path filters and only relevant docs/skills checks run.
- [ ] AC 12: Given a push changes an app/site/backend path, when GitHub Actions evaluates workflows, then the matching surface workflow runs and unrelated expensive workflows stay skipped unless explicitly forced.
- [ ] AC 13: Given a workflow is path-filtered, when branch protection requires checks, then required-check behavior is reviewed so skipped workflows do not block unrelated PRs.
- [ ] AC 14: Given public `sg-test` docs are changed, when `pnpm --dir shipglows-site build` runs, then the site build passes.
- [ ] AC 15: Given skills are changed, when skill checks run, then `skill_budget_audit` and `shipglows_sync_skills.sh --check --all` pass or report only accepted non-blocking risks.

## Test Contract

- Automated tests first: implementation should include focused tests for any parser/normalizer introduced for checklist statuses and evidence paths.
- Agent-run proof: use `rg`, metadata lint, skill budget audit, and runtime sync checks for skill/template changes.
- Manual checklist artifact: this spec should produce no operator checklist yet; it defines the system for future generated checklists.
- Manual checklist path: generated checklists always live under `shipglows_data/workflow/test-checklists/<scope>.md`.
- Checklist parser/helper: v1 must include a small parser/helper so `PASS`, `FAIL`, `BLOCKED`, `NOT_RUN`, and `N/A` are consumed mechanically.
- Stack-agnostic proof ladder: preserve the generic rule that cheaper automated/agent-run proof comes before manual, provider, production, or device proof.
- Stack profiles: include examples for Flutter, Astro, Python, API contracts, auth/browser flows, provider integrations, and device/native behavior without making any one technology the default.
- Proportional validation: include a risk tier so tiny edits do not trigger full suites by habit, while meaningful behavior/risk changes still get strong evidence.
- Proportional CI: include path-filter expectations so a push only triggers workflows relevant to changed surfaces, with `workflow_dispatch` for deliberate full runs.
- Exception policy: if the helper cannot parse a checklist safely, `sg-test` must report the exact malformed row or unsafe evidence pointer instead of falling back to guessed interpretation.

## Test Strategy

- Unit: checklist status normalization, required/optional row interpretation, evidence path safety, duplicate scenario IDs if implemented as script/helper.
- Integration: dry-run fixture or sample project where `sg-test` consumes a checklist with `PASS`, `FAIL`, `BLOCKED`, and `NOT_RUN`.
- Manual: operator edits one checklist row directly and reruns `sg-test` to confirm no chat copy-paste is needed.

## Risks

- Security impact: yes, because checklists may contain observed behavior and evidence pointers. Mitigation: redaction rules, repo-root path safety, no raw secrets, no raw logs.
- Product/data/performance risk: medium. Poorly scoped checklists can slow delivery; mitigation is required/optional row semantics and small scenario sets.
- Workflow risk: high. This touches core lifecycle skills; implementation must be spec-first and verified with skill sync checks.

## Execution Notes

- Read first: `skills/sg-test/SKILL.md`, `skills/sg-spec/references/spec-creation-workflow.md`, `skills/sg-start/references/execution-workflow.md`, `skills/sg-verify/SKILL.md`, `skills/sg-verify/references/verification-gates.md`, `templates/spec.md`, `templates/bug_record.md`, `tools/shipglows_metadata_lint.py`.
- Validate with: metadata lint for changed artifacts, `rg` checks in tasks, `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`, `tools/shipglows_sync_skills.sh --check --all`, and site build if public content changes.
- Stop conditions: unclear checklist path, inability to preserve operator edits, unsafe evidence handling, manual checklist replacing automated tests, validation or CI becoming either too weak for risk or too heavy by habit, branch protection conflicting with skipped path-filtered workflows, or stack-agnostic proof ladder weakened.

## Open Questions

None. Resolved on 2026-05-27:

- Generated checklists live at the fixed canonical path `shipglows_data/workflow/test-checklists/<scope>.md`.
- v1 includes a small parser/helper so checklist statuses are consumed mechanically by `sg-test` and `sg-verify`.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-24 17:23:00 UTC | sg-spec | GPT-5.5 Codex | Created spec for ShipGlows TDD and manual checklist artifacts | draft | /sg-ready ShipGlows TDD and Manual Checklist Artifacts |
| 2026-05-26 16:47:52 UTC | sg-ready | GPT-5 Codex | Reviewed readiness: structure and metadata pass, but open product/implementation questions and GitHub Actions freshness evidence gaps block implementation start | not ready | /sg-spec ShipGlows TDD and Manual Checklist Artifacts |
| 2026-05-27 00:00:00 UTC | sg-spec | GPT-5 Codex | Resolved open decisions: fixed checklist path, parser/helper required, and GitHub Actions official docs freshness evidence recorded | draft updated | /sg-ready ShipGlows TDD and Manual Checklist Artifacts |
| 2026-05-27 09:27:19 UTC | sg-ready | GPT-5 Codex | Re-reviewed readiness after open decisions and freshness evidence were resolved | ready | /sg-start ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-28 20:28:19 UTC | sg-docs | GPT-5.5 Codex | Added proportional CI path-filter policy and branch-protection guidance, plus a scope matrix for aligned path ownership when workflows exist in-repo | implemented | /sg-verify re-open ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-28 20:32:30 UTC | sg-verify | GPT-5.5 Codex | Re-verified spec with runtime checks and focused gates; implementation is substantial but not fully verified as required manual checklist and preview/manual evidence are still missing | partial | /sg-start ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-28 21:54:33 UTC | sg-start | GPT-5.5 Codex | Executed runtime parser proof for manual checklist statuses, fixed table parsing in `tools/shipglows_checklist_status.py`, and completed required validation sweep for this chantier | implemented | /sg-verify ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-28 22:01:10 UTC | sg-content | GPT-5 Codex | Updated public sg-test/help content to reflect the canonical checklist path and parser-backed checklist-first proof flow after sg-start implementation | implemented | /sg-verify ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-28 22:16:51 UTC | sg-verify | GPT-5 Codex | Verified parser, metadata, skill sync, site build, and public docs; verdict remains partial because the durable checklist fixture contains unresolved required FAIL/BLOCKED/NOT_RUN rows without a formal exception | partial | /sg-start resolve checklist fixture gate for ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-29 03:41:57 UTC | sg-start | GPT-5.5 Codex | Separated parser-only status cases into a dedicated fixture and made the scope checklist operator-safe (no required unresolved FAIL/BLOCKED/NOT_RUN rows) so manual-verification gates can be durable | implemented | /sg-verify ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-29 14:35:05 UTC | sg-verify | GPT-5 Codex | Verified the operator checklist gate, parser fixture separation, metadata, skill sync, site build, and focused contract checks | verified | /sg-end ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-29 18:07:14 UTC | sg-end | GPT-5 Codex | Closed the verified TDD/manual checklist artifact chantier, prepared tracker and changelog bookkeeping, and left commit/push to sg-ship | closed | /sg-ship ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-29 21:13:36 UTC | sg-content | GPT-5 Codex | Aligned README, workflow doctrine, FAQ, skill modes, and launch-cheatsheet content with checklist-first manual proof after closure | implemented | /sg-ship ShipGlows TDD And Manual Checklist Artifacts |
| 2026-05-30 20:21:23 UTC | sg-ship | GPT-5 Codex | Shipped the verified TDD/manual checklist artifacts with conversation-audit workflow changes in a scoped ShipGlows workflow commit | shipped | None |

## Current Chantier Flow

- `sg-spec`: done, draft spec created.
- `sg-ready`: ready.
- `sg-start`: implemented.
- `sg-verify`: verified.
- `sg-end`: closed.
- `sg-ship`: shipped.

Next step: None
