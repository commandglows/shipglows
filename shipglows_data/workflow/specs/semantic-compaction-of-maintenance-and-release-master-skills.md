---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-12"
created_at: "2026-06-12 23:40:00 UTC"
updated: "2026-06-12"
updated_at: "2026-06-13 00:07:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "maintenance-and-release-master-semantic-compaction"
owner: "unknown"
user_story: "As the ShipGlows operator, I want the maintenance and release master skills semantically compacted through the canonical artifact taxonomy, so agents stop confusing maintenance orchestration, bug-loop execution, and release-confidence orchestration."
confidence: "high"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/002-sg-maintain/SKILL.md"
  - "skills/003-sg-bug/SKILL.md"
  - "skills/004-sg-deploy/SKILL.md"
  - "skills/references/master-delegation-semantics.md"
  - "skills/references/master-workflow-lifecycle.md"
  - "skills/references/chantier-tracking.md"
  - "skills/references/reporting-contract.md"
  - "skills/references/decision-quality-contract.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md"
  - "shipglows_data/workflow/specs/semantic-compaction-of-core-shipglows-skills.md"
  - "shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md"
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/specs/semantic-compaction-of-core-shipglows-skills.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.4.1"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Batch A clarified the lifecycle spine and Batch C clarified the source/proof specialists, but the next remaining confusion cluster is the master family around maintenance, bug-loop execution, and release confidence."
  - "The artifact taxonomy requires each touched skill to keep one primary artifact type, one dominant question, and one owner boundary."
  - "Current `002-sg-maintain`, `003-sg-bug`, and `004-sg-deploy` are functionally strong but still semantically heavy and easy to blur because they each orchestrate neighboring specialist lanes."
  - "The user explicitly requested the next batch and selected D1."
next_step: "none"
---

# Title

Semantic Compaction Of Maintenance And Release Master Skills

# Status

ready

# User Story

As the ShipGlows operator, I want the maintenance and release master skills semantically compacted through the canonical artifact taxonomy, so agents stop confusing maintenance orchestration, bug-loop execution, and release-confidence orchestration.

# Minimal Behavior Contract

When this chantier runs, ShipGlows must keep `002-sg-maintain`, `003-sg-bug`, and `004-sg-deploy` explicitly classifiable as `master-workflow` skills with distinct dominant questions, owned lifecycle spans, and owner-routing boundaries. The compacted result must make it obvious that maintenance decides what existing-project upkeep to carry through, bug-loop execution decides how one bug work item moves through evidence/fix/retest/ship risk, and deploy decides how one bounded release scope moves through checks, ship, hosted truth, post-deploy proof, and verification. If any compacted skill starts sounding like a generic orchestrator for all three jobs, verification must fail. The easiest edge case to miss is making `002`, `003`, and `004` all sound like interchangeable "run the next lifecycle step" masters.

# Success Behavior

- Preconditions: the taxonomy spec, Batch A lifecycle compaction, and Batch C source specialist compaction are already shipped.
- Trigger: the operator launches `/101-sg-ready` and then `/102-sg-start` on this spec.
- User/operator result: an agent can quickly distinguish project upkeep, single-bug lifecycle execution, and bounded release confidence without rereading long surrounding doctrine.
- System effect: the touched activation contracts state crisp `master-workflow` boundaries while preserving chantier tracing, delegated sequential semantics, proof-owner routing, and stop conditions.
- Proof of success: metadata lint, skill budget audit, runtime skill sync, targeted `rg` checks, and a manual family-boundary review all pass on the touched master family.

# Error Behavior

- If any touched skill needs a shared contract rewrite in `skills/references/*`, stop the skill-local batch and record a separate sequential integration follow-up instead of widening scope.
- If compacting `002-sg-maintain` weakens the distinction between maintenance orchestration and direct owner-lane execution, verification must fail.
- If compacting `003-sg-bug` weakens the distinction between one bug work item and generic maintenance or release orchestration, verification must fail.
- If compacting `004-sg-deploy` weakens the distinction between push success and release proof, verification must fail.
- Must never happen: deleting master delegation loaders, lifecycle routing boundaries, bug-risk framing, deployment-truth gates, or required proof-owner handoffs in order to shorten text.

# Problem

The lifecycle spine and source specialists are now clearer, but the next semantic confusion cluster sits in the master family that wraps upkeep, bugs, and release confidence. These skills are adjacent and all orchestrate downstream specialists, which makes them easy to blur in agent memory even when their actual workflow contracts differ materially.

The risk is not merely length. It is role collapse. `002-sg-maintain` can start sounding like a global project supervisor for any technical work. `003-sg-bug` can start sounding like a generic defect router instead of a one-bug lifecycle executor. `004-sg-deploy` can start sounding like a simple ship alias or a production-health skill. This batch should compact semantics while preserving the boundaries that protect correct routing, proof quality, and release truth.

# Solution

Run one bounded master-family batch on `002-sg-maintain`, `003-sg-bug`, and `004-sg-deploy`.

The batch should:

1. Normalize activation shape where useful: primary artifact type, mission, and compact dominant-question language.
2. Preserve the `master-workflow` posture and delegated sequential lifecycle semantics.
3. Make the dominant question of each master explicit so the family stops overlapping semantically.
4. Keep reusable doctrine in shared references unless the activation contract truly needs it to route safely.

## Ideal Master Matrix

| Skill | Primary artifact type | Dominant question | Dominant responsibility | Forbidden drift | Must-preserve sentence |
| --- | --- | --- | --- | --- | --- |
| `skills/002-sg-maintain/SKILL.md` | `master-workflow` | `Quel travail de maintenance doit etre traite pour ce projet, et jusqu'ou peut-on le mener proprement dans cette run ?` | Orchestrate maintenance lanes across bugs, deps, docs, audits, checks, repair, verification, and ship/deploy routing | Becoming a generic build/deploy executor or silently bypassing owner skills | `002-sg-maintain` decides maintenance scope and carries it through the right owner lanes to verified, shippable completion. |
| `skills/003-sg-bug/SKILL.md` | `master-workflow` | `Quel est l'etat reel de ce bug work item, et quelle est la prochaine etape de lifecycle la plus sure ?` | Execute one bug lifecycle through evidence, fix, retest, verify, and ship-risk gates | Becoming generic maintenance triage, direct code-fix ownership, or release orchestration | `003-sg-bug` owns bug-loop state interpretation and continuation, not generic project maintenance or release proof. |
| `skills/004-sg-deploy/SKILL.md` | `master-workflow` | `Quel niveau de confiance release faut-il obtenir pour ce scope, de checks locaux jusqu'a la preuve post-deploy ?` | Orchestrate release checks, ship, deployment truth, post-deploy proof, verification, and changelog routing | Becoming a push-only shortcut, hosted-debug catch-all, or generic prod-health reader | `004-sg-deploy` treats push and deployment as gates toward proof, not as proof themselves. |

# Scope In

- Semantically compact the activation contracts of `002-sg-maintain`, `003-sg-bug`, and `004-sg-deploy`.
- Align this family with the artifact taxonomy and the compaction style already applied to lifecycle and specialist batches.
- Add or tighten primary artifact labels, mission sections, and compact owner-boundary wording where useful.
- Clarify maintenance, bug-loop, and release-confidence boundaries without changing runtime invocation or core behavior.
- Record any newly discovered shared-doctrine drift rather than broadening the batch silently.

# Scope Out

- Changing public command names, skill numbers, or runtime invocation forms.
- Rewriting shared reference bodies unless a separate follow-up explicitly owns them.
- Editing lifecycle or specialist skills already covered by previous batches.
- Changing deployment provider behavior, preview/prod doctrine, or bug-file schema.
- Updating plugin packaging or public docs unless a touched technical doc becomes materially stale.

# Constraints

- This batch stays sequential by default.
- Skill-local edits are allowed in one bounded execution wave; shared-reference edits require a separate sequential follow-up.
- Each touched skill must remain classifiable as one `master-workflow`.
- Delegated sequential semantics, proof-owner routing, and stop conditions cannot be weakened for brevity.
- The batch must preserve the distinction between project-wide upkeep, one bug work item, and one bounded release scope.
- Runtime/observability exception: this chantier changes activation-contract text only, so no Sentry, diagnostics, or build-header mutation is expected; verification relies on metadata lint, skill sync, targeted grep, and manual semantic review instead of runtime telemetry.
- Language doctrine: internal contract labels, section names, and machine anchors stay in English; operator-facing explanatory prose may stay French, and any visible French text added during implementation must remain natural and accented.
- Existing unrelated dirty files must remain out of ship scope.

# Test Contract

- Surface: ShipGlows governance, master activation contracts, and lifecycle routing semantics.
- proof_profile: mixed
- proof_order:
  1. approve the batch contract
  2. apply skill-local edits
  3. run validations
  4. review master-family boundaries for overlap or missing doctrine
  5. decide whether any shared-contract or doc follow-up is needed
- checklist_path: `shipglows_data/workflow/test-checklists/semantic-compaction-of-maintenance-and-release-master-skills.md` if implementation requires more than straightforward skill-local edits; otherwise `not required`
- required_scenario_ids:
  - `MC-002-maintenance-not-generic-build`
  - `MC-003-bug-work-item-not-generic-maintenance`
  - `MC-004-push-is-not-release-proof`
- required_results:
  - Every touched skill declares one explicit `master-workflow` role and one dominant boundary.
  - `002-sg-maintain` keeps owner-lane orchestration explicit and does not collapse into a generic executor.
  - `003-sg-bug` keeps one-bug lifecycle interpretation explicit and does not absorb generic maintenance or deploy proof.
  - `004-sg-deploy` still keeps check -> ship -> hosted truth -> proof -> verify order explicit.
  - Metadata lint, skill budget audit, runtime skill sync, and targeted `rg` checks pass after implementation.
- exception_with_proof: if a shared-reference drift is discovered, stop this batch, capture the evidence in verification/reporting, and route to a follow-up spec instead of mutating shared references here.
- exception_without_proof: none; no success, safety, or boundary claim may be accepted without command output or manual evidence.
- Automated proof available:
  - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md`
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `tools/shipglows_sync_skills.sh --check --all`
  - targeted `rg` checks for primary artifact labels, trace/process metadata, mission sections, and family-specific must-preserve rules
- Non-automated proof required:
  - manual role-boundary review across `002/003/004`
- Fresh external docs verdict: `fresh-docs not needed`, because this chantier changes local ShipGlows skill semantics rather than provider/framework behavior.

# Dependencies

- `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`: canonical artifact taxonomy and boundary matrix.
- `shipglows_data/workflow/specs/semantic-compaction-of-core-shipglows-skills.md`: prior lifecycle-family compaction style.
- `shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md`: specialist-family precedent for post-spine batches.
- `skills/references/master-delegation-semantics.md`: master delegation doctrine.
- `skills/references/master-workflow-lifecycle.md`: shared lifecycle skeleton and work item model.
- `skills/references/chantier-tracking.md`: chantier tracing and source threshold rules.
- `skills/references/reporting-contract.md`: compact user-facing reporting rules.
- `skills/references/decision-quality-contract.md`: quality bar and shortcut ban.

# Invariants

- `002-sg-maintain` remains the project maintenance master, not a direct replacement for `001-sg-build`, `003-sg-bug`, or `004-sg-deploy`.
- `003-sg-bug` remains the bug-loop lifecycle executor for one bug work item and must keep bug-file truth, retest, and ship-risk semantics explicit.
- `004-sg-deploy` remains the release-confidence orchestrator and must keep hosted truth and post-deploy proof distinct from a push.
- Shared mandatory rules stay in references; activation contracts stay focused on routing, boundaries, and local non-negotiables.
- The work improves semantic clarity before reducing line count.

# Links & Consequences

- These three masters sit above multiple specialist owners; wording drift can change routing across maintenance, bug, and release work.
- Any touched shared reference would affect more than this family and must be treated as a contract change, not a wording-only edit.
- Runtime skill sync must pass after any skill-body edit.
- Documentation updates are only needed if the documented family boundaries or runtime taxonomy materially change.

# Documentation Coherence

- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` only if this batch changes the documented distinction between maintenance, bug-loop, and release-confidence masters.
- Keep `README.md` and `AGENT.md` unchanged unless a user-facing route promise becomes stale.
- Tracker and changelog updates belong to `104-sg-end` and `005-sg-ship`, not this spec.
- No public docs change is expected from this batch because it only compacts internal ShipGlows master activation contracts.

# Edge Cases

- `002-sg-maintain` starts sounding like the default wrapper for any non-trivial technical request.
- `003-sg-bug` starts sounding like a thin command router instead of a lifecycle executor.
- `004-sg-deploy` starts sounding like push/deploy success alone is enough to claim release confidence.
- The three masters keep their downstream skill lists but lose the sentence that distinguishes why each list exists.
- A shorter activation contract pushes too much family-specific boundary logic into implicit conversation memory.

# Implementation Tasks

- [x] Task 1: Establish the family matrix in the spec.
  - File: `shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md`
  - Action: Freeze the dominant question, forbidden drift, and must-preserve sentence for `002/003/004`.
  - User story link: Creates a durable semantic contract before edits.
  - Depends on: None.
  - Validate with: `rg -n "Ideal Master Matrix|002-sg-maintain|003-sg-bug|004-sg-deploy" shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md`
  - Notes: This task completes with the spec itself.

- [x] Task 2: Compact the master activation contracts.
  - Files: `skills/002-sg-maintain/SKILL.md`, `skills/003-sg-bug/SKILL.md`, `skills/004-sg-deploy/SKILL.md`
  - Action: Add or align primary artifact type, mission emphasis, and compact owner-boundary wording while preserving behavior.
  - User story link: Reduces confusion between upkeep orchestration, one-bug execution, and release confidence work.
  - Depends on: Task 1.
  - Validate with: `rg -n "Primary artifact type|Mission|Trace category|Process role|Master Delegation|Master Workflow Lifecycle" skills/002-sg-maintain/SKILL.md skills/003-sg-bug/SKILL.md skills/004-sg-deploy/SKILL.md`
  - Notes: Keep the write set skill-local unless readiness explicitly expands scope.

- [x] Task 3: Verify family boundaries and proof rules.
  - Files: touched skill files and any touched docs if needed.
  - Action: Run lint/audit/sync checks and a manual overlap review focused on maintenance-vs-bug-vs-release boundaries.
  - User story link: Prevents semantic compaction from collapsing adjacent master lanes.
  - Depends on: Task 2.
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `tools/shipglows_sync_skills.sh --check --all`
  - Notes: Verification must explicitly check that `004` still treats push/deploy as gates rather than proof.

- [x] Task 4: Decide whether shared-contract or doc follow-up is needed.
  - File: `shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md`
  - Action: Record whether a later shared-reference/doc integration batch is unnecessary or required.
  - User story link: Keeps this batch bounded and prevents hidden scope growth.
  - Depends on: Task 3.
  - Validate with: `rg -n "shared-contract follow-up|no shared-reference drift|documentation follow-up" shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md`
  - Notes: If no drift appears, this task closes with a no-follow-up decision.

# Acceptance Criteria

- [x] AC 1: Given the touched family, when an agent reads each activation contract, then one primary `master-workflow` role is explicit in every touched skill.
- [x] AC 2: Given `002-sg-maintain`, when an agent routes work, then maintenance orchestration remains distinct from generic build/deploy or direct implementation ownership.
- [x] AC 3: Given `003-sg-bug`, when an agent handles a defect, then one-bug lifecycle state interpretation remains explicit and distinct from generic maintenance.
- [x] AC 4: Given `004-sg-deploy`, when an agent reads the release path, then checks, ship, hosted truth, post-deploy proof, and verify remain visibly ordered.
- [x] AC 5: Given the batch completes, when validations run, then metadata lint, budget audit, runtime sync, and targeted grep checks all pass.

# Test Strategy

- Run metadata lint on the spec after creation and after later trace updates.
- Run skill budget audit after activation-contract edits.
- Run runtime skill sync after activation-contract edits.
- Use targeted `rg` to confirm family markers, mandatory metadata, and must-preserve phrases remain visible.
- Perform one manual semantic review across the family before claiming the batch ready to ship.

# Risks

- High: this family sits on routing boundaries where wording drift can redirect whole workflows.
- High: `003` and `004` are both lifecycle-oriented and easy to blur if release proof ordering is over-shortened.
- Medium: `002` has broad lane coverage and can read like a generic orchestrator if the maintenance question is not kept explicit.
- Medium: hidden shared-doctrine drift may tempt scope growth into references or runtime docs.

## Closure Notes

- No shared-reference drift was discovered during D1 verification; no shared-contract follow-up is required for this chantier.
- No runtime taxonomy or public routing promise changed materially; no documentation follow-up is required for this chantier.

# Execution Notes

- Read first: `skills/002-sg-maintain/SKILL.md`, `skills/003-sg-bug/SKILL.md`, `skills/004-sg-deploy/SKILL.md`.
- Preserve the family as `master-workflow` skills; do not demote them into routers or promote them into shared contracts.
- Prefer the Batch A and Batch C style: short activation contract, clear mission, precise owner boundaries, detailed workflow kept in references or local sections only when necessary.
- Stop immediately if a correct edit would require mutating shared references or runtime docs; convert that into an explicit follow-up instead of widening the write set silently.
- Validation commands after edits: metadata lint, budget audit, runtime sync, targeted `rg`.
- Security/proof review focus before claiming success: confirm `002` still preserves owner-lane gates, confirm `003` still preserves bug-file truth and retest/ship-risk semantics, and confirm `004` still preserves deployment-truth and post-deploy proof order.
- Stop conditions: stop if any required readiness fix would touch a file outside this spec, if a shared doctrine change is needed, or if the family boundaries still rely on conversation history after compaction.

# Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-12 23:40:00 UTC | 100-sg-spec | GPT-5 Codex | Created a new bounded master-family semantic compaction spec for the D1 batch covering maintenance, bug-loop, and release-confidence skills | drafted | /101-sg-ready shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md |
| 2026-06-12 23:45:00 UTC | 101-sg-ready | GPT-5 Codex | Validated readiness for the D1 master-family batch and approved the bounded skill-local execution scope | ready | /102-sg-start shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md |
| 2026-06-12 23:52:00 UTC | 102-sg-start | GPT-5 Codex | Compacted the D1 master-family activation contracts inside the owned skill set and ran the required local validations | implemented | /103-sg-verify shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md |
| 2026-06-12 23:55:00 UTC | 103-sg-verify | GPT-5 Codex | Verified D1 maintenance, bug-loop, and release-confidence boundary preservation against the spec contract and required local validations | verified | /104-sg-end shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md |
| 2026-06-13 00:02:00 UTC | 104-sg-end | GPT-5 Codex | Closed D1 bookkeeping, updated the canonical trackers and changelog, and confirmed ship as the remaining lifecycle step | closed | /005-sg-ship shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md |
| 2026-06-13 00:07:00 UTC | 005-sg-ship | GPT-5 Codex | Shipped the bounded D1 master-family semantic compaction with a task-scoped commit and push after final local checks | shipped | none |

## Current Chantier Flow

- 100-sg-spec: drafted
- 101-sg-ready: ready
- 102-sg-start: implemented
- 103-sg-verify: verified
- 104-sg-end: closed
- 005-sg-ship: shipped
- Next step: `none`
