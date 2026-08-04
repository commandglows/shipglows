---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-16"
created_at: "2026-07-16 10:33:44 UTC"
updated: "2026-07-16"
updated_at: "2026-07-16 10:50:05 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5"
scope: "dependabot-queue-continuation"
owner: "Diane"
user_story: "As a ShipGlows operator, I want GitHub hygiene to continue through unrelated safe Dependabot pull requests when one risky pull request needs quarantine or specialist handling, so the backlog reaches an explicit, revalidated disposition without repeated operator intervention."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/010-sg-technical github/SKILL.md"
  - "tools/test_010_sg_technical_contract.py"
  - "skills/402-sg-deps/SKILL.md"
  - "skills/404-sg-migrate/SKILL.md"
  - "github:gh-fix-ci"
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.6.0"
    required_status: active
supersedes: []
evidence:
  - "A real mixed backlog contained 13 Dependabot pull requests spanning safe patch/minor updates, major upgrades, workflow-sensitive GitHub Actions updates, failing or stale checks, and one incompatible obsolete dependency."
  - "The backlog was completed only after risky pull requests were isolated and handled separately while unrelated safe pull requests continued."
  - "The current 310 contract routes major and failing-CI pull requests but its stop conditions can be read as stopping the whole queue when only one pull request is risky."
  - "The 2026-07-16 ShipGlows Core audit recommended a per-PR terminal disposition and queue revalidation after every mutation."
next_step: "none"
---

# Dependabot Queue Continuation for GitHub Hygiene

## Title

Dependabot queue continuation for GitHub hygiene

## Status

closed locally / ready for bounded ship

## User Story

As a ShipGlows operator, I want `010-sg-technical github` to continue through unrelated safe Dependabot pull requests when one risky pull request needs quarantine or specialist handling, so the backlog reaches an explicit, revalidated disposition without repeated operator intervention.

## Minimal Behavior Contract

When `dependabot` or an approved mutating hygiene run receives a mixed pull-request backlog, it classifies and processes each pull request independently, preserves all existing merge-safety and approval gates, and records one terminal run disposition for every pull request: `merged`, `closed`, `deferred`, `routed`, or `blocked`. A risky, stale, incompatible, or failing pull request is quarantined and handed to the appropriate owner without preventing unrelated eligible work from continuing. After every merge, close, branch update, or other queue mutation, the skill refreshes GitHub truth before choosing the next action and resumes until no actionable pull request remains. The easy edge case is confusing an item-scoped blocker with a queue-wide blocker: only a global loss of safe operating conditions may stop the full queue.

## Success Behavior

- Preconditions: the target repository is known, GitHub truth is refreshed, the operator has authorized the requested mutation lane, and a mixed Dependabot backlog exists.
- Trigger: `010-sg-technical github` starts the Dependabot backlog loop.
- Operator result: every pull request appears once in the final disposition ledger with a terminal status and a concise reason; no actionable pull request is silently left behind.
- System effect: eligible patch/minor pull requests continue while major, sensitive, stale, failing, or incompatible items are quarantined, routed, deferred, closed, or blocked according to existing safety rules.
- Revalidation effect: every queue mutation is followed by a fresh open-PR and check/base-state read before another mutation is selected.
- Proof of success: the focused contract test and scenario scan prove continuation, terminal disposition coverage, item-scoped blocking, and mutation-triggered revalidation.

## Error Behavior

- If one pull request requires `402-sg-deps`, `404-sg-migrate`, or `github:gh-fix-ci`, record `routed` with owner and reason, then continue unrelated eligible pull requests.
- If a pull request cannot safely proceed during this run but has a clear future condition or decision owner, record `deferred` with that condition; do not misreport it as merged or resolved.
- If a pull request is unsafe and no agent-runnable recovery remains, record `blocked` for that pull request and continue the queue when global operating conditions remain valid.
- If GitHub authentication, repository access, operator authorization, or reliable refreshed queue truth is unavailable, stop the queue as globally blocked and report which pull requests remain undisposed or unverified.
- If revalidation shows that a previously eligible pull request has changed, reclassify it before acting; never rely on stale eligibility.
- Must never happen: silently skipping a pull request, treating a handoff as a successful merge, bypassing existing major/sensitive/workflow approval gates, or continuing mutations after global GitHub truth becomes unreliable.

## Problem

Observed problem: a mixed Dependabot backlog can contain safe updates alongside major upgrades, workflow-sensitive changes, stale or failing checks, and an incompatible obsolete dependency. Under the current contract, encountering one risky item can appear to satisfy a broad stop condition and prematurely end the entire run.

System cause: `010-sg-technical github` defines risk classification and specialist routes, but it does not explicitly distinguish pull-request-scoped stops from queue-wide stops, require a terminal disposition ledger, or state that processing resumes after an isolated handoff.

## Solution

Prevention rule: quarantine risk at the narrowest pull-request scope, preserve existing mutation permissions, continue independent eligible work, refresh queue truth after every mutation, and stop only when no actionable pull request remains or a genuine queue-wide safety condition fails.

Contract/tooling improvement proposal: add one compact queue-continuation rule and focused pressure scenario to `skills/010-sg-technical github/SKILL.md`, then add `tools/test_010_sg_technical_contract.py` to mechanically protect terminal dispositions, item-scoped blockers, revalidation, and specialist routes.

## Scope In

- Clarify the local `010-sg-technical github` contract for mixed Dependabot queue orchestration.
- Define terminal run dispositions: `merged`, `closed`, `deferred`, `routed`, and `blocked`.
- Distinguish pull-request-scoped blockers from global queue blockers.
- Require refreshed GitHub truth after every queue mutation and before the next action.
- Require continuation until no actionable pull request remains.
- Add a focused standard-library contract test for this behavior.

## Scope Out

- Changing the public skill name, invocation, argument shape, description, or user-facing promise.
- Weakening or broadening existing approval, merge, branch-protection, sensitive-package, workflow, or destructive-action rules.
- Implementing dependency audits, major migrations, or CI debugging inside `310`.
- Editing shared doctrine, public/help documentation, marketplace packaging, trackers, changelog, or unrelated skill contracts.
- Building a GitHub API client, persistent queue database, or generalized PR orchestration framework.

## Constraints

- Keep the behavior owner-specific and activation-critical in the local `310` contract; shared doctrine is not justified by this pressure scenario.
- Preserve `402-sg-deps`, `404-sg-migrate`, and `github:gh-fix-ci` ownership boundaries.
- A `routed` disposition proves a handoff, not successful downstream completion.
- A `deferred` disposition must name its future condition or decision owner.
- A `blocked` disposition is item-scoped unless a named global condition makes all further safe mutations impossible.
- Revalidation must use current GitHub state rather than an in-memory snapshot after a mutation.
- Keep the activation body compact and followable; detailed examples belong in the focused test rather than new prose-heavy references.
- Preserve unrelated dirty worktree changes.

## Test Contract

- Surface profile: Markdown skill activation contract plus Python standard-library contract test.
- Proof path: `scenario-first`, followed by focused mechanical assertions.
- Automated proof: `python3 -m unittest tools.test_310_github_hygiene_contract`, focused section scan, generic skill audit, skill budget audit, and runtime sync check.
- Non-automated proof: adversarial reading of the mixed 13-PR pressure scenario against the updated contract.
- Manual/browser/provider proof: exception-with-proof; not applicable because this change defines local workflow instructions and does not execute a live GitHub queue.
- Fresh external docs: not needed; no GitHub API, action version, or external integration behavior is being changed.

## Dependencies

- `skills/010-sg-technical github/SKILL.md` is the sole behavior owner.
- `skills/references/skill-instruction-layering.md` governs local activation-body placement and the Followability Gate.
- `skills/references/spec-driven-development-discipline.md` requires pressure-scenario proof for skill-contract changes.
- `skills/references/decision-quality-contract.md` preserves the professional and operator-autonomy bar.
- `skills/references/reporting-contract.md` governs the final operator report.
- `tools/audit_shipglows_skills.py`, `tools/skill_budget_audit.py`, and `tools/shipglows_sync_skills.sh` provide generic regression evidence after the focused proof passes.

## Invariants

- Safe patch/minor merge eligibility remains unchanged.
- Major versions and sensitive package lanes remain outside automatic merge behavior.
- Workflow, deploy, auth, billing, permissions, infrastructure, and security-sensitive pull requests retain their existing gates.
- Dirty-worktree, branch protection, conflict, authentication, authorization, secret, and permission safeguards remain intact.
- `310` coordinates and reports; specialist skills retain analysis, migration, and CI-debug ownership.
- Every pull request known to the processed queue receives a terminal run disposition or is explicitly listed as unverified under a global blocker.

## Links & Consequences

- The local contract becomes resilient to mixed-risk backlogs without increasing mutation authority.
- Final reports become auditable because disposition count can be compared with the refreshed queue inventory.
- Revalidation reduces stale-check and stale-base decisions after merges or branch updates.
- Specialist handoffs become non-blocking for unrelated queue items, but their downstream outcome must not be overstated.
- The focused test guards semantics that the generic skill audit cannot prove.

## Documentation Coherence

- Internal skill contract: update `skills/010-sg-technical github/SKILL.md`.
- Focused regression documentation: encode pressure scenarios in `tools/test_010_sg_technical_contract.py`.
- Shared references: no change; the failure class is local to Dependabot queue orchestration.
- Public/help docs and invocation catalog: no change unless implementation unexpectedly alters the promise or invocation, which is outside scope and must stop the chantier for rescoping.
- Changelog and trackers: excluded from this implementation scope; lifecycle closure/ship may decide bookkeeping separately.

## Edge Cases

- A merge changes the base and makes another pull request conflicted or stale: refresh, reclassify, and give the changed pull request a new terminal disposition.
- A routed owner finishes within the same broader run: refresh the PR and replace the provisional route outcome with the final observed disposition in the ledger; do not duplicate the PR row.
- A routed owner cannot run because its own prerequisites are missing: keep `routed` only if the handoff is durable and explicit; otherwise use `blocked` or `deferred` with the missing prerequisite.
- A dependency is incompatible and obsolete: `closed` is valid only after the PR is actually closed; code removal or replacement remains outside `310` and must use the proper owner.
- New Dependabot PRs appear during revalidation: include them if they are part of the refreshed target backlog and can be classified safely; otherwise record why they are deferred.
- Two pull requests update the same dependency or lockfile lane: process one, revalidate, then close, supersede, reclassify, or defer the other from current state.
- The queue contains only routed, deferred, or blocked items: finish the run because no actionable PR remains, with no false clean/merged claim.

## Implementation Tasks

- [x] Task 1: Add the queue-continuation contract and pressure scenario.
  - File: `skills/010-sg-technical github/SKILL.md`
  - Action: Add a compact rule that classifies blockers per pull request, requires the five terminal dispositions, refreshes GitHub truth after each mutation, and continues until no actionable pull request remains; clarify that only global blockers stop the full queue.
  - User story link: prevents one risky pull request from stranding unrelated safe updates.
  - Depends on: none.
  - Validate with: `rg -n "merged|closed|deferred|routed|blocked|after every mutation|no actionable|queue" skills/010-sg-technical github/SKILL.md`
  - Notes: Do not alter existing merge authority or specialist ownership.

- [x] Task 2: Add the focused contract test.
  - File: `tools/test_010_sg_technical_contract.py`
  - Action: Add standard-library assertions that the activation contract exposes all dispositions, item-scoped versus global stop semantics, mutation revalidation, continuation, and the `402`/`404`/`gh-fix-ci` routes.
  - User story link: prevents future compaction or wording changes from reintroducing premature queue stops.
  - Depends on: Task 1.
  - Validate with: `python3 -m unittest tools.test_310_github_hygiene_contract`
  - Notes: Test behavior-bearing phrases and scenario invariants, not incidental formatting.

- [x] Task 3: Run focused and corpus-level validation.
  - File: `skills/010-sg-technical github/SKILL.md`, `tools/test_010_sg_technical_contract.py`
  - Action: Run the focused test first, then the section scan, generic skill audit, budget audit, sync check, and diff check.
  - User story link: proves the narrow improvement without weakening the broader skill system.
  - Depends on: Tasks 1-2.
  - Validate with: commands listed in `Test Strategy` and `Execution Notes`.
  - Notes: A passing generic audit alone is insufficient.

## Acceptance Criteria

- [x] AC 1 — Mixed queue continuation: Given 13 Dependabot pull requests spanning safe patch/minor updates, major upgrades, workflow-sensitive updates, stale or failing checks, and one incompatible obsolete dependency, when one risky pull request is quarantined or routed, then unrelated eligible pull requests continue without weakening existing gates.
- [x] AC 2 — Terminal coverage: Given a processed queue inventory, when the run ends, then every known pull request has exactly one final ledger disposition of `merged`, `closed`, `deferred`, `routed`, or `blocked`, or is explicitly named as unverified because a global blocker prevented reliable classification.
- [x] AC 3 — Mutation revalidation: Given any merge, close, branch update, or queue mutation, when the next pull request is selected, then open-PR, check, and base-state truth has been refreshed first.
- [x] AC 4 — Scoped blocking: Given one pull request is major, sensitive, conflicted, stale, failing, or incompatible, when global operating conditions remain valid, then only that pull request is quarantined and the rest of the queue continues.
- [x] AC 5 — Specialist routing: Given dependency risk, a major migration, or failing CI requires specialist work, when the item is routed, then the ledger names `402-sg-deps`, `404-sg-migrate`, or `github:gh-fix-ci` and does not claim downstream success.
- [x] AC 6 — Queue completion: Given repeated revalidation finds no remaining pull request eligible for an in-scope action, when the run reports, then it stops with a complete disposition ledger and no false claim that deferred, routed, or blocked items were resolved.
- [x] AC 7 — Safety preservation: Given a major or sensitive pull request lacks its existing explicit approval and proof, when queue continuation runs, then the pull request is not merged merely to empty the backlog.
- [x] AC 8 — Focused regression proof: Given the implementation is complete, when `python3 -m unittest tools.test_310_github_hygiene_contract` runs, then it passes assertions for continuation, terminal dispositions, scoped/global blockers, revalidation, and owner routes.
- [x] AC 9 — Followability: Given a fresh agent loads the activation contract, when it encounters the pressure scenario, then it can identify the next safe per-PR action and the condition that permits or stops queue continuation without consulting conversation history.

## Test Strategy

- Pressure scenario `DEPENDABOT-MIXED-QUEUE-CONTINUES`: model the 13-PR backlog and prove that a quarantined major/workflow/CI/incompatible item does not terminate unrelated safe work.
- Pressure scenario `DEPENDABOT-MUTATION-REFRESH`: after a merge or close, require refreshed open-PR, checks, and base truth before another action.
- Pressure scenario `DEPENDABOT-ITEM-VS-GLOBAL-BLOCK`: distinguish one conflicted or risky PR from loss of authentication, authorization, or reliable queue truth.
- Pressure scenario `DEPENDABOT-DISPOSITION-COVERAGE`: compare refreshed queue inventory with the final unique disposition ledger.
- Focused automated test: `python3 -m unittest tools.test_310_github_hygiene_contract`.
- Focused scan: `rg -n "Dependabot|queue|merged|closed|deferred|routed|blocked|revalid|actionable|402-sg-deps|404-sg-migrate|github:gh-fix-ci" skills/010-sg-technical/references/github-hygiene-playbook.md tools/test_010_sg_technical_contract.py`.
- Corpus checks: `python3 tools/audit_shipglows_skills.py`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `tools/shipglows_sync_skills.sh --check --skill 010-sg-technical github`; `git diff --check`.

## Risks

- Queue orchestration could accidentally imply broader auto-merge authority; acceptance criteria explicitly preserve all existing approval and sensitivity gates.
- `routed`, `deferred`, and `blocked` can become vague parking states; each must carry a reason and owner or future condition where applicable.
- Revalidation can loop if external state changes continuously; each pass must either mutate one item, assign a terminal disposition, or stop on a named global blocker.
- A phrase-coupled test can impede future compaction; assertions should target semantic labels and pressure-scenario anchors rather than prose layout.
- The activation body could grow unnecessarily; keep one compact local rule and move executable scenario detail into the focused test.

## Execution Notes

- Read first: `skills/010-sg-technical github/SKILL.md`, `skills/references/skill-instruction-layering.md`, `skills/references/spec-driven-development-discipline.md`, and existing focused contract tests under `tools/test_*_contract.py`.
- Implementation order: write the focused failing assertions, add the smallest complete local contract that passes them, then run corpus checks.
- Proof path: `scenario-first`; the generic audit is baseline evidence only.
- Model guidance: current GPT-5 profile with high reasoning recommended; runtime model override status is not supported and must not be claimed.
- Fresh external docs verdict: `fresh-docs not needed`.
- Stop and rescope if implementation would change invocation, public promise, merge permissions, shared doctrine, specialist behavior, or require files beyond the local skill and focused test.
- Do not edit `TASKS.md`, `AUDIT_LOG.md`, `CHANGELOG.md`, public/help docs, shared references, or unrelated dirty files during implementation.

## Open Questions

None. The operator authorized the bounded improvement, and the scope, dispositions, owner routes, safety invariants, and proof path are explicit.

## Verification Evidence

- Verdict: `verified`; the user story and AC 1-9 are satisfied by scenario-first proof plus focused mechanical checks.
- Adversarial scenario 1, mixed risk: a major or sensitive PR receives an item-scoped disposition and route while unrelated eligible PRs continue; the existing explicit-approval and no-auto-merge rules remain unchanged.
- Adversarial scenario 2, mutation drift: after a merge or close makes the next PR stale or conflicted, the contract requires refreshed open-PR, check, and base-state truth, reclassification, and an updated existing ledger row before another action.
- Adversarial scenario 3, global truth loss: loss of GitHub authentication, repository access, mutation-lane authorization, or reliable refreshed queue truth stops the full queue and lists remaining PRs as unverified.
- Adversarial scenario 4, completed handoff: when a routed owner later finishes, revalidation replaces the existing PR disposition instead of adding a duplicate row; `routed` alone never claims downstream success.
- Focused proof: `python3 -m unittest tools.test_310_github_hygiene_contract` passed 8 tests; the required `rg` scenario scan passed.
- Corpus proof: generic skill audit reported 0 hard findings and one unrelated review finding for `205-sg-veille`; the 310 budget is `ok` at 229 lines / about 2889 body tokens; Claude and Codex runtime sync checks passed; metadata lint and `git diff --check` passed.
- Gates: success behavior `pass`; error behavior `pass`; proof-path fit `pass`; task-application-loop fit `pass`; closure-archive-guard fit `pass`; structure replacement fit `pass`; fast-fix shortcut gate `pass`; operator autonomy gate `pass`; bug gate `clear` with no scoped bug record; development mode `local` by minimal inference; CI surface `not assessed` because no local workflows exist; fresh docs `not needed`; documentation coherence `no impact beyond the internal contract and focused test`; language doctrine `pass`; dependencies and runtime diagnostics `not applicable`.
- Scope and safety: no dependency, public invocation, shared-doctrine, specialist-owner, or mutation-authority expansion was introduced; the activation contract remains followable from its local queue rules and named stop conditions.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-16 10:33:44 UTC | 100-sg-spec | GPT-5 | Created a bounded autonomous spec from the GitHub hygiene execution audit and the mixed 13-PR Dependabot pressure scenario. | draft saved | `/101-sg-ready Dependabot queue continuation for GitHub hygiene` |
| 2026-07-16 10:37:17 UTC | 101-sg-ready | GPT-5 | Reviewed structure, user-story alignment, workflow integrity, security boundaries, proof paths, documentation coherence, and task ordering against the mixed-queue pressure scenarios. | ready | `/102-sg-start Dependabot queue continuation for GitHub hygiene` |
| 2026-07-16 10:41:19 UTC | 102-sg-start | GPT-5 Codex | Added the focused failing contract test, implemented per-PR queue continuation and terminal dispositions without weakening safety gates, then passed focused and corpus-level local checks. | implemented | `/103-sg-verify Dependabot queue continuation for GitHub hygiene` |
| 2026-07-16 10:45:03 UTC | 103-sg-verify | GPT-5 Codex | Independently verified AC 1-9 through four adversarial queue simulations, focused contract tests, safety-invariant checks, corpus audit, budget, metadata, diff, and runtime-sync proof. | verified | `/104-sg-end Dependabot queue continuation for GitHub hygiene` |
| 2026-07-16 10:47:28 UTC | 104-sg-end | GPT-5 Codex | Applied the closure-archive guard, confirmed complete implementation and proof, runtime sync, documentation no-impact, and no remaining scoped source-of-truth delta. | closed | `/005-sg-ship Dependabot queue continuation for GitHub hygiene` |
| 2026-07-16 10:50:05 UTC | 005-sg-ship | GPT-5 Codex | Shipped the bounded Dependabot queue-continuation contract and focused regression proof after task-scoped checks, staging, commit, and push. | shipped | none |

## Current Chantier Flow

- `100-sg-spec`: draft saved.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented.
- `103-sg-verify`: verified.
- `104-sg-end`: closed.
- `005-sg-ship`: shipped.
- Next step: `none`.
