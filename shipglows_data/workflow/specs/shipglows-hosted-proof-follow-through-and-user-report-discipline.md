---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-10"
created_at: "2026-06-10 07:55:46 UTC"
updated: "2026-06-10"
updated_at: "2026-06-10 08:14:35 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "hosted-proof-follow-through-routing"
owner: "Diane"
user_story: "En tant qu'operatrice ShipGlows, je veux qu'un verdict partial pour preuve hebergee manquante soit toujours converti en route proprietaire concrete, afin de savoir quel skill lancer, sur quel environnement, et pour quel scenario sans devoir inferer le prochain geste."
confidence: high
risk_level: medium
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/references/reporting-contract.md"
  - "skills/references/spec-driven-development-discipline.md"
  - "skills/sg-build/SKILL.md"
  - "skills/sg-verify/SKILL.md"
  - "skills/sg-prod/SKILL.md"
  - "skills/sg-test/SKILL.md"
  - "skills/sg-browser/SKILL.md"
  - "skills/sg-auth-debug/SKILL.md"
  - "shipglows_data/workflow/conversation-audits/"
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.3.0"
    required_status: "active"
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.3.0"
    required_status: "active"
  - artifact: "shipglows_data/workflow/specs/skill-reporting-modes-and-compact-reports.md"
    artifact_version: "1.1.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/specs/spec-driven-tdd-evidence-gates.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/conversation-audits/conversation-shipglows-doctrine-de-langue-20260530-203004-audit.md"
    artifact_version: "1.0.0"
    required_status: "draft"
supersedes: []
evidence:
  - "sg-conversation-audit 2026-06-10: sg-verify partial named missing hosted proof but did not route it to a concrete owner such as sg-prod, sg-test, sg-browser, or sg-auth-debug."
  - "sg-conversation-audit 2026-06-10: sg-start used closure-sounding wording despite explicit hosted proof gaps."
  - "User correction 2026-06-10: recent reporting-concision work should be treated as mostly resolved; this chantier should not focus on report brevity."
  - "Existing spec-driven-development-discipline.md requires proof paths, but the audited partial hosted proof did not become an executable next route."
next_step: "none"
---

## Title

ShipGlows Hosted Proof Follow-Through Routing

## Status

Ready from `sg-ready` on 2026-06-10 after user correction: do not re-open the general reporting-concision chantier. This spec focuses on routing missing hosted proof after `partial` or blocked verification.

## User Story

En tant qu'opératrice ShipGlows, je veux qu'un verdict partial pour preuve hébergée manquante soit toujours converti en route propriétaire concrète, afin de savoir quel skill lancer, sur quel environnement, et pour quel scénario sans devoir inférer le prochain geste.

Acteur principal: opératrice ShipGlows qui lit un verdict de skill.

Déclencheur: un skill lifecycle ou proof skill termine avec succès, partial, blocked, or not verified, especially when hosted/deployed proof remains missing.

Résultat observable: when hosted/deployed/provider proof is missing, the final report names the next owner skill, target environment or URL requirement, and scenario to prove.

## Minimal Behavior Contract

When a required hosted, preview, production, auth, browser, manual, webhook, provider, or deployment proof is missing, the responsible ShipGlows skill must translate that proof gap into a specific owner route such as `sg-ship -> sg-prod`, `sg-prod -> sg-browser`, `sg-prod -> sg-auth-debug`, or `sg-test --preview`, including the scenario to run and the target/environment prerequisite. The easy edge case is a technically accurate partial report that lists missing evidence nouns but leaves the operator to infer which skill owns the next proof.

## Success Behavior

- Given a partial `sg-verify` caused by missing hosted proof, when the report names the gap, then it also names the owner route and scenario, for example `sg-ship web-ui -> sg-prod winflowz-preview -> sg-test --preview login-smoke`.
- Given a hosted proof requires a push/deploy first, when the report names the next proof, then it routes through `sg-ship -> sg-prod` before browser/auth/manual proof.
- Given the deployment URL is unknown, when proof is missing, then the next route starts with `sg-prod` or says the target URL must be supplied.
- Given local implementation is complete but production proof is pending, when `sg-start`, `sg-build`, or `sg-verify` reports the result, then it avoids closure/ship-ready language and routes to the next proof owner.
- Given a proof route would need provider secrets or sensitive logs, when reporting the route, then it describes the redacted setup/proof action without requesting secret values in chat.
- Given a skill contract or shared reference is changed, when validation runs, then scenario-first pressure cases prove the new wording converts hosted-proof gaps into executable routes.

## Error Behavior

- If no concrete proof owner can be selected because the missing evidence type is ambiguous, the skill must report `blocked` or ask one targeted question instead of giving a vague next step.
- If a report claims ship-ready or closed while required hosted proof remains missing, `sg-verify` must reject it or mark it partial.
- If proof collection would expose secrets, private logs, tokens, cookies, provider payloads, or customer data, the report must route to redacted proof or blocked safety handling.

## Problem

The conversation audit found that ShipGlows's lifecycle discipline is mostly working: the agent kept the chantier spec-first, used official provider docs, used the requested subagent, and correctly refused to call the work ship-ready without hosted proof. The remaining problem is the final mile of hosted-proof follow-through: partial verdicts can describe what is missing without turning it into an executable owner route.

This produces avoidable operator friction. The user still has to infer whether the next proof is `sg-prod`, `sg-browser`, `sg-auth-debug`, `sg-test`, `sg-ship`, or another route, and whether a deployment URL or redacted provider setup is required first.

## Solution

Tighten the shared proof-routing contracts with explicit hosted-proof follow-through rules. Add scenario-first pressure cases that force skills to handle:

- partial `sg-verify` with a concrete hosted-proof route;
- unknown deployment URL or missing preview target;
- local implementation complete but deployed proof pending;
- provider/webhook proof blocked by missing redacted setup.

Implementation should be bounded: update shared references and only the skill activation contracts that need a direct rule or validation hook.

## Scope In

- `skills/references/reporting-contract.md`: touch only if needed to reference proof-owner routing in partial/blocked reports; do not reopen the general concision work.
- `skills/references/spec-driven-development-discipline.md`: clarify that proof gaps must include the owner route and scenario, not just missing evidence type.
- `skills/sg-build/SKILL.md`: ensure post-implementation hosted-proof gaps route to the next owner instead of stopping at a descriptive next step.
- `skills/sg-verify/SKILL.md`: require partial proof gaps to name concrete owner routes and scenario targets.
- `skills/sg-start/SKILL.md` only if implementation-complete wording needs a local rule to avoid closure language while proof remains pending.
- `skills/sg-prod/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-browser/SKILL.md`, and `skills/sg-auth-debug/SKILL.md` only if references need a clearer routing vocabulary.
- Add pressure scenarios or fixture-style examples for the audited cases.
- Update technical docs or changelog only if the user-facing skill behavior contract changes materially.

## Scope Out

- No implementation of provider-specific hosted proof for SocialGlowz, Lemon Squeezy, Convex, Vercel, or any product project.
- No broad follow-up on report concision; that is covered by recent reporting-contract work unless a small wording hook is necessary for proof routing.
- No broad rewrite of every ShipGlows skill report template.
- No change to chantier tracing semantics.
- No removal of `report=agent`, verbose, handoff, or detailed evidence modes.
- No public docs update unless the skill behavior promise changes enough to affect public documentation.
- No commit or push in the spec creation step.

## Constraints

- Preserve the existing concise-reporting doctrine without making it the implementation focus.
- Do not hide material proof gaps to make reports shorter.
- Keep detailed matrices available in durable artifacts or `report=agent`.
- Maintain existing proof-owner boundaries:
  - `sg-prod`: deployment/runtime truth, logs, health, preview/prod readiness.
  - `sg-browser`: non-auth page/browser evidence after a URL exists.
  - `sg-auth-debug`: auth/session/callback/protected-route proof.
  - `sg-test`: durable manual QA, retests, checklist rows, and user-confirmed scenarios.
  - `sg-ship`: commit/push/staging scope before preview-push proof.
- Preserve security redaction rules for hosted logs, tokens, secrets, cookies, private provider payloads, and customer data.

## Test Contract

- `surface`: ShipGlows skill contracts and shared references.
- `proof_profile`: scenario-first plus mechanical checks.
- `proof_order`:
  1. Define pressure scenarios from the conversation audit.
  2. Update shared references/skill contracts.
  3. Run targeted `rg` checks for required phrases and owner-route vocabulary.
  4. Run skill budget audit.
  5. Run skill sync check.
  6. Run metadata lint on changed Markdown artifacts.
- `checklist_path`: none; deterministic scenario and static checks are sufficient.
- `required_scenario_ids`:
  - `VERIFY-PARTIAL-HOSTED`: `sg-verify partial` from missing hosted proof includes owner route and scenario.
  - `UNKNOWN-DEPLOYMENT-TARGET`: hosted proof cannot proceed until `sg-prod` discovers or confirms the target URL.
  - `LOCAL-COMPLETE-PROD-PENDING`: `sg-start`/`sg-build` avoids closure-sounding wording when production proof is pending.
  - `PREVIEW-PUSH-LADDER`: preview-push validation routes `sg-ship -> sg-prod` before browser/auth/manual proof.
  - `SAFETY-REDACTION`: hosted proof route does not request or expose secrets/private logs in user mode.
- `required_results`:
  - Shared proof discipline states that partial proof gaps need an executable owner route when the route is knowable.
  - `sg-verify` contract explicitly distinguishes missing evidence type, proof owner, scenario, and target.
  - `sg-build` contract routes post-implementation hosted-proof gaps through the right proof owner.
  - Validation commands pass without increasing skill instruction budget beyond accepted limits.
- `exception_with_proof`:
  - If a skill already inherits the required behavior entirely through a shared reference, implementation may leave that skill body unchanged, but validation must show the inherited reference covers the scenario.
  - If no public docs are changed, record `docs public: not needed` in the implementation report.
- `exception_without_proof`: not allowed for skill-contract changes.
- Fresh external docs: not needed; this is local ShipGlows workflow/reporting behavior, not external API behavior.

## Dependencies

- `skills/references/reporting-contract.md@1.3.0`: current user-mode and agent-mode reporting contract.
- `skills/references/spec-driven-development-discipline.md@1.3.0`: current proof-path and evidence-first doctrine.
- `skills/sg-build/SKILL.md`: master orchestration and downstream reporting behavior.
- `skills/sg-verify/SKILL.md`: partial verification and proof-gap semantics.
- `skills/sg-prod/SKILL.md`: deployment/runtime proof owner.
- `skills/sg-test/SKILL.md`: durable manual QA and checklist proof owner.
- `skills/sg-browser/SKILL.md`: browser proof owner.
- `skills/sg-auth-debug/SKILL.md`: auth/session proof owner.
- `shipglows_data/workflow/conversation-audits/conversation-shipglows-doctrine-de-langue-20260530-203004-audit.md`: source finding set.

## Invariants

- Existing user-mode concision rules remain in force but are not the primary scope of this chantier.
- Partial verification remains honest and cannot be reframed as ship-ready.
- The operator should not need to infer the next skill from a list of missing evidence nouns.
- Detailed evidence remains available for agents and durable artifacts.
- Safety/redaction rules override convenience and report compactness.
- Existing dirty worktree changes must not be reverted or pulled into an unrelated ship scope.

## Links & Consequences

- Improves `sg-build` and `sg-verify` handoff quality after local implementation but before hosted proof.
- Reduces user friction from ambiguous partial-proof next steps.
- Makes `sg-prod`, `sg-browser`, `sg-auth-debug`, and `sg-test` routing more predictable.
- May require minor updates to shared reporting examples and pressure scenarios.
- Could affect public skill docs if they currently promise report shapes or proof routing.

## Documentation Coherence

- Update `CHANGELOG.md` during `sg-end`/`sg-ship` if skill behavior changes.
- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` only if it describes proof-owner routing or user report modes affected by this change.
- Update public skill pages only if a user-facing invocation or promise changes.
- Keep the conversation audit as private evidence; do not publish raw transcript content.

## Edge Cases

- A partial proof gap has several valid owner routes; ask a targeted question or name the first required route in the proof ladder.
- A hosted proof requires a push first; route `sg-ship -> sg-prod` before browser/manual proof.
- A deployment URL is already known; route directly to `sg-prod` or downstream proof owner as appropriate.
- A missing provider smoke cannot run without operator secrets; report blocked by configuration and name the redacted setup step, not the secret.
- A report has a non-blocking caveat unrelated to hosted proof; leave existing reporting-contract rules to handle it.
- A downstream skill returns too much detail; treat as already covered by reporting-contract unless it obscures the proof route.

## Implementation Tasks

- [x] Task 1: Add hosted-proof follow-through rule to the proof discipline
  - File: `skills/references/spec-driven-development-discipline.md`
  - Action: State that missing hosted/deployed/provider proof must include proof type, owner skill, scenario, and target/environment when knowable.
  - User story link: Gives the operator one actionable proof route instead of missing-evidence nouns.
  - Depends on: none.
  - Validate with: `rg -n "owner skill|scenario|target|environment|proof gap" skills/references/spec-driven-development-discipline.md`

- [x] Task 2: Update `sg-verify` partial-proof contract
  - File: `skills/sg-verify/SKILL.md`
  - Action: Require `partial` findings to route each missing required proof to `sg-prod`, `sg-browser`, `sg-auth-debug`, `sg-test`, `sg-ship`, or another concrete owner.
  - User story link: Makes partial verification operational.
  - Depends on: Task 1.
  - Validate with: `rg -n "partial|sg-prod|sg-browser|sg-auth-debug|sg-test|sg-ship|owner route" skills/sg-verify/SKILL.md`

- [x] Task 3: Update `sg-build` post-implementation proof routing
  - File: `skills/sg-build/SKILL.md`
  - Action: Ensure local-complete but hosted-proof-pending work routes to the next proof owner instead of stopping at generic "rerun verification" language.
  - User story link: Prevents the operator from inferring the next skill.
  - Depends on: Task 1.
  - Validate with: `rg -n "hosted proof|sg-prod|sg-browser|sg-auth-debug|sg-test|sg-ship|proof owner" skills/sg-build/SKILL.md`

- [x] Task 4: Add closure-language guard where needed
  - File: `skills/sg-start/SKILL.md`
  - Action: If not already covered by references, prevent closure-sounding wording when implementation is local-only and hosted/provider/manual proof remains pending.
  - User story link: Avoids giving the operator a false sense of lifecycle completion.
  - Depends on: Task 1.
  - Validate with: `rg -n "local implementation|hosted proof|production proof|pending|partial" skills/sg-start/SKILL.md`

- [x] Task 5: Add pressure scenarios or examples
  - File: `skills/references/spec-driven-development-discipline.md` or a suitable proof-routing reference/fixture.
  - Action: Add `VERIFY-PARTIAL-HOSTED`, `UNKNOWN-DEPLOYMENT-TARGET`, `PREVIEW-PUSH-LADDER`, `LOCAL-COMPLETE-PROD-PENDING`, and `SAFETY-REDACTION` scenarios.
  - User story link: Makes future audits and verification deterministic.
  - Depends on: Tasks 1-4.
  - Validate with: `rg -n "VERIFY-PARTIAL-HOSTED|UNKNOWN-DEPLOYMENT-TARGET|PREVIEW-PUSH-LADDER|LOCAL-COMPLETE-PROD-PENDING|SAFETY-REDACTION" skills/references skills`

- [ ] Task 6: Run skill quality checks
  - File: `tools/` and skill inventory.
  - Action: Run metadata lint, skill budget audit, and skill sync check for changed skills.
  - User story link: Preserves ShipGlows skill quality and discoverability.
  - Depends on: Tasks 1-5.
  - Validate with:
    - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/shipglows-hosted-proof-follow-through-and-user-report-discipline.md`
    - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
    - `tools/shipglows_sync_skills.sh --check --all`

## Acceptance Criteria

- [x] AC 1: Given `sg-verify` returns `partial` for missing hosted proof, when the report is produced, then it names the proof owner, scenario, and target/environment when knowable.
- [x] AC 2: Given hosted proof requires a new deploy, when the report is produced, then it routes through `sg-ship -> sg-prod` before browser/auth/manual proof.
- [x] AC 3: Given the deployment URL or preview target is unknown, when proof is missing, then the report routes to `sg-prod` or asks for the target URL instead of naming a downstream browser/manual test prematurely.
- [x] AC 4: Given local implementation is complete but production/provider proof is pending, when `sg-start` or `sg-build` reports, then it avoids closed/ship-ready wording and routes to the next proof owner.
- [x] AC 5: Given the proof route would expose secrets or private logs, when reporting, then the skill blocks or redacts and routes to a safe proof path.
- [x] AC 6: Given changed skill contracts, when validation runs, then metadata lint, skill budget audit, and skill sync checks pass.

## Test Strategy

- Scenario-first validation:
  - Review the five hosted-proof pressure scenarios against the updated references.
  - Re-run or manually map the audited SocialGlowz transcript outcome to the new contract: `sg-verify partial` would route to specific proof owner(s), target environment, and scenario.
- Static validation:
  - `rg` checks listed in Implementation Tasks.
  - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/shipglows-hosted-proof-follow-through-and-user-report-discipline.md`.
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
  - `tools/shipglows_sync_skills.sh --check --all`.
- No external docs required.

## Risks

- Adding route requirements in too many skill bodies could bloat activation contracts; prefer shared references and targeted hooks.
- Proof routing can become wrong if it ignores project development mode; preserve `project-development-mode` and `sg-ship -> sg-prod` preview gates.
- Skills may name a route that cannot run without secrets or operator setup; reports must say `blocked by setup` rather than invent proof.

## Execution Notes

- Source intake from `sg-conversation-audit`:
  - Chantier potentiel: oui
  - Titre propose: ShipGlows hosted-proof follow-through and user-report discipline
  - Raison retenue après correction utilisateur: partial verification lacks a concrete proof-owner handoff; reporting concision itself is already mostly covered by recent work.
  - Severite: P2
  - Scope: `sg-build`, `sg-verify`, reporting contract pressure scenarios, proof-owner routing language.
  - Spec recommandee: `/sg-spec shipglows hosted-proof follow-through and user-report discipline`
- Fresh external docs: not needed; this is local ShipGlows skill/reporting behavior.
- First files to inspect during implementation: `skills/references/reporting-contract.md`, `skills/references/spec-driven-development-discipline.md`, `skills/sg-verify/SKILL.md`, `skills/sg-build/SKILL.md`, `skills/sg-start/SKILL.md`.
- Preserve unrelated dirty changes in the ShipGlows repo.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-10 08:14:35 UTC | sg-ship | GPT-5 Codex | Closed tracker/changelog/spec bookkeeping for the hosted-proof routing chantier and prepared the bounded ship scope. | shipped | none |
| 2026-06-10 08:09:36 UTC | sg-build | GPT-5 Codex + gpt-5.3-codex-spark subagents | Implemented the hosted-proof follow-through routing contract through bounded Spark subagents, then verified acceptance criteria and validation commands. | implemented | `/sg-end shipglows-hosted-proof-follow-through-and-user-report-discipline` |
| 2026-06-10 08:06:14 UTC | sg-ready | GPT-5 Codex | Reviewed the hosted-proof follow-through routing spec for readiness: behavior contract, scope, target files, pressure scenarios, security/redaction, and validation plan are sufficiently explicit. | ready | `/sg-start shipglows-hosted-proof-follow-through-and-user-report-discipline` |
| 2026-06-10 07:59:02 UTC | sg-spec | GPT-5 Codex | Narrowed the draft after user correction: reporting concision is already mostly covered, so the chantier now focuses on hosted-proof follow-through routing after partial verification. | draft | `/sg-ready shipglows-hosted-proof-follow-through-and-user-report-discipline` |
| 2026-06-10 07:55:46 UTC | sg-spec | GPT-5 Codex | Created draft spec from the conversation-audit chantier potential about hosted-proof follow-through, user-report concision, and concrete proof-owner routing. | draft | `/sg-ready shipglows-hosted-proof-follow-through-and-user-report-discipline` |

## Current Chantier Flow

| Step | Status | Evidence | Next |
|------|--------|----------|------|
| sg-spec | complete | Draft spec created from the 2026-06-10 conversation audit, then narrowed to hosted-proof follow-through routing after user correction. | Run `/sg-ready shipglows-hosted-proof-follow-through-and-user-report-discipline`. |
| sg-ready | complete | Ready review passed on 2026-06-10: behavior contract, tasks, scenarios, validation, and security/redaction gates are explicit. | Run implementation. |
| sg-start | complete | Implemented by bounded Spark worker: hosted-proof rule, pressure scenarios, `sg-verify`, `sg-build`, and `sg-start` routing hooks. | Verify. |
| sg-verify | complete | Independent Spark verification passed: rg checks, metadata lint, skill budget audit, and skill sync check all passed. | Close chantier bookkeeping. |
| sg-end | complete | Full-close bookkeeping updated: `shipglows_data/workflow/TASKS.md`, `CHANGELOG.md`, and spec trace. | Ship bounded scope. |
| sg-ship | complete | Bounded ship scope prepared for commit/push: hosted-proof routing skill contracts plus chantier bookkeeping. | None. |
