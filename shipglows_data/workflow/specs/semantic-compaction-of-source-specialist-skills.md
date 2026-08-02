---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-12"
created_at: "2026-06-12 20:35:00 UTC"
updated: "2026-06-12"
updated_at: "2026-06-12 18:23:29 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "source-specialist-semantic-compaction"
owner: "unknown"
user_story: "As the ShipGlows operator, I want the source-oriented specialist skills semantically compacted through the canonical artifact taxonomy, so agents stop confusing diagnostic intake, direct bug repair, manual QA, browser proof, and auth debugging."
confidence: "high"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/105-sg-check/SKILL.md"
  - "skills/106-sg-fix/SKILL.md"
  - "skills/107-sg-test/SKILL.md"
  - "skills/108-sg-browser/SKILL.md"
  - "skills/109-sg-auth-debug/SKILL.md"
  - "skills/references/chantier-tracking.md"
  - "skills/references/reporting-contract.md"
  - "skills/references/decision-quality-contract.md"
  - "shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md"
  - "shipglows_data/workflow/specs/semantic-compaction-of-core-shipglows-skills.md"
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/specs/semantic-compaction-of-core-shipglows-skills.md"
    artifact_version: "1.0.0"
    required_status: "ready"
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
  - "Batch A clarified the lifecycle spine, but the next semantic confusion cluster is the source-oriented specialist family."
  - "The artifact taxonomy requires one primary type and one owner boundary per touched artifact."
  - "Current 105/106/107/108 still rely on older activation styles that expose role overlap, while 109 already partially reflects the newer compaction style."
  - "The user requested the next batch immediately after shipping Batch A."
next_step: "none"
---

# Title

Semantic Compaction Of Source Specialist Skills

# Status

ready

# User Story

As the ShipGlows operator, I want the source-oriented specialist skills semantically compacted through the canonical artifact taxonomy, so agents stop confusing diagnostic intake, direct bug repair, manual QA, browser proof, and auth debugging.

# Minimal Behavior Contract

When this chantier runs, ShipGlows must clarify the specialist skills that discover, diagnose, test, and sometimes fix work before a durable chantier exists: each touched `SKILL.md` must declare one primary `specialist-workflow` role, one dominant question, one clear stop boundary, and one proof/reporting contract. The result must make it obvious when a skill only gathers evidence, when it may repair directly, when it needs user-reported test results, and when auth/debug work is a separate lane. If a compacted skill starts sounding like a lifecycle owner, a generic router, or a reusable global contract, verification must fail. The easiest edge case to miss is making `108-sg-browser`, `107-sg-test`, and `109-sg-auth-debug` all sound like interchangeable proof tools.

# Success Behavior

- Preconditions: the taxonomy spec and the core-lifecycle semantic compaction chantier are already shipped.
- Trigger: the operator launches `/101-sg-ready` and then `/102-sg-start` on this spec.
- User/operator result: an agent can quickly distinguish check execution, bug-fix intake, manual QA logging, one-off browser proof, and auth/session debugging without rereading long workflow bodies.
- System effect: the touched skill activation contracts state crisp specialist boundaries while preserving chantier-potential intake, reporting, security, and proof routing semantics.
- Proof of success: metadata lint, skill budget audit, runtime skill sync, targeted `rg` checks, and a manual boundary review all pass on the touched specialist family.

# Error Behavior

- If any touched skill needs a shared rule rewrite in `skills/references/*`, stop the skill-local batch and reopen the scope as a sequential shared-contract integration step.
- If compacting `106-sg-fix` weakens direct-fix versus spec-first safety, verification must fail.
- If compacting `107-sg-test` makes it possible to imply results without user or tool evidence, verification must fail.
- If compacting `108-sg-browser` blurs the routing edge with `109-sg-auth-debug`, verification must fail.
- Must never happen: deleting chantier-potential intake, proof-path semantics, security/redaction rules, or required reference loaders in order to shorten text.

# Problem

The lifecycle spine is now semantically cleaner, but the next confusion cluster sits in the source-oriented specialist family. These skills do not own the full chantier lifecycle, yet they still influence whether work becomes a spec, a direct fix, a QA log, a browser evidence pass, or an auth investigation. Their older activation contracts still mix mission, workflow, support doctrine, and neighboring-skill boundaries unevenly.

That makes them harder for agents to retain in memory. The risk is not mostly line count. It is boundary blur: a browser proof skill can start sounding like manual QA; a bug-fix skill can start sounding like generic implementation; an auth-debug skill can quietly become the catch-all for every browser failure. This batch should compress semantics while preserving the gates that protect proof quality, security, and correct owner routing.

# Solution

Run one bounded specialist-family batch on `105-sg-check`, `106-sg-fix`, `107-sg-test`, `108-sg-browser`, and `109-sg-auth-debug`.

The batch should:

1. Normalize activation shape where missing: primary artifact type, instruction-layering note where useful, mission, and compact owner-boundary language.
2. Preserve the `source-de-chantier` posture and chantier-potential intake where applicable.
3. Make the dominant question of each specialist explicit so the family stops overlapping semantically.
4. Keep all reusable doctrine in references unless the activation contract truly needs it to route safely.

## Ideal Specialist Matrix

| Skill | Primary artifact type | Dominant question | Dominant responsibility | Forbidden drift | Must-preserve sentence |
| --- | --- | --- | --- | --- | --- |
| `skills/105-sg-check/SKILL.md` | `specialist-workflow` | `Quels checks techniques apportent une confiance proportionnée sur cette surface ?` | Run and interpret technical checks without overstating product proof | Owning lifecycle closure, browser QA, or general bug fixing | `105-sg-check` is a technical confidence pass, not product proof. |
| `skills/106-sg-fix/SKILL.md` | `specialist-workflow` | `Ce bug est-il assez clair et borné pour un correctif direct sûr ?` | Decide direct-fix vs spec-first and repair small clear bugs durably | Quick-fix logic, generic implementation routing, or closure claims | `106-sg-fix` may repair directly only when the bug is small, clear, and low-risk. |
| `skills/107-sg-test/SKILL.md` | `specialist-workflow` | `Quel résultat manuel observé faut-il enregistrer pour ce flow ?` | Drive manual QA and durable test logging without inventing outcomes | One-off browser proof, direct code fixing, or silent pass claims | `107-sg-test` never invents results and needs user or tool evidence before logging success. |
| `skills/108-sg-browser/SKILL.md` | `specialist-workflow` | `Qu’a vraiment vu le navigateur sur cette cible pour cet objectif précis ?` | Gather narrow browser evidence on non-auth surfaces | Auth-debug, full QA campaign, deployment discovery, or code-fix ownership | `108-sg-browser` answers one browser-visible objective and routes broader work away. |
| `skills/109-sg-auth-debug/SKILL.md` | `specialist-workflow` | `Quel composant auth/session/callback explique ce comportement ?` | Diagnose auth-specific failures with redaction and proof discipline | Generic browser QA, non-auth debugging, or unsafe secret handling | `109-sg-auth-debug` is the auth/session specialist, not the generic browser fallback. |

# Scope In

- Semantically compact the activation contracts of `105-sg-check`, `106-sg-fix`, `107-sg-test`, `108-sg-browser`, and `109-sg-auth-debug`.
- Align this family with the artifact taxonomy and the compaction style already used on the lifecycle spine.
- Add missing primary artifact labels or mission sections where needed.
- Clarify direct-fix, browser-proof, manual-QA, and auth-debug boundaries without changing runtime invocation or core behavior.
- Extract or flag any newly discovered shared-doctrine drift rather than broadening the batch silently.

# Scope Out

- Changing public command names, skill numbers, or runtime invocation forms.
- Rewriting skill-local reference bodies unless a readiness-approved follow-up explicitly owns them.
- Editing lifecycle owner skills already covered by the previous chantier.
- Changing proof-owner routing doctrine across the whole repo.
- Updating plugin packaging or public docs unless a touched technical doc becomes materially stale.

# Constraints

- This batch stays sequential by default.
- Skill-local edits are allowed in one bounded execution wave; shared-reference edits require a separate sequential follow-up.
- Each touched skill keeps its existing trace category and process role unless the taxonomy proves a mismatch.
- Each touched skill must remain classifiable as one `specialist-workflow`.
- Security, redaction, auth, and proof-discipline sentences cannot be weakened for brevity.
- The batch must preserve the distinction between source-of-chantier intake and lifecycle ownership.
- Runtime/observability exception: this chantier changes activation-contract text only, so no Sentry, copy-log, or build-header mutation is expected; verification relies on metadata lint, skill sync, targeted grep, and manual semantic review instead of runtime telemetry.
- Language doctrine: internal contract labels, section names, and machine anchors stay in English; operator-facing explanatory prose may stay French, and any visible French text added during implementation must remain natural and accented.

# Test Contract

- Surface: ShipGlows governance, specialist activation contracts, and source-of-chantier routing semantics.
- proof_profile: mixed
- proof_order:
  1. approve the batch contract
  2. apply skill-local edits
  3. run validations
  4. review family boundaries for overlap or missing doctrine
  5. decide whether any shared-contract follow-up is needed
- checklist_path: `shipglows_data/workflow/test-checklists/semantic-compaction-of-source-specialist-skills.md` if implementation requires more than straightforward skill-local edits; otherwise `not required`
- required_scenario_ids:
  - `SC-105-boundary-check-confidence-not-product-proof`
  - `SC-106-direct-fix-vs-spec-first`
  - `SC-107-no-invented-manual-results`
  - `SC-108-browser-non-auth-boundary`
  - `SC-109-auth-specialist-redaction-boundary`
- required_results:
  - Every touched skill declares one explicit `specialist-workflow` role and one dominant boundary.
  - `106-sg-fix` keeps the direct-fix versus spec-first safety gate explicit.
  - `107-sg-test` still requires user or tool evidence before any success claim.
  - `108-sg-browser` still routes auth/session/callback objectives away from the non-auth browser lane.
  - `109-sg-auth-debug` still keeps auth/session scope and redaction rules explicit.
  - Metadata lint, skill budget audit, runtime skill sync, and targeted `rg` checks pass after implementation.
- exception_with_proof: if a shared-reference drift is discovered, stop this batch, capture the evidence in verification/reporting, and route to a follow-up spec instead of mutating shared references here.
- exception_without_proof: none; no success, safety, or boundary claim may be accepted without command output or manual evidence.
- Automated proof available:
  - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md`
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `tools/shipglows_sync_skills.sh --check --all`
  - targeted `rg` checks for primary artifact labels, trace/process metadata, mission sections, and family-specific must-preserve rules
- Non-automated proof required:
  - manual role-boundary review across `105/106/107/108/109`
- Fresh external docs verdict: `fresh-docs not needed`, because this chantier changes local ShipGlows skill semantics rather than provider/framework behavior.

# Dependencies

- `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`: canonical artifact taxonomy and boundary matrix.
- `shipglows_data/workflow/specs/semantic-compaction-of-core-shipglows-skills.md`: prior compaction style and lifecycle-family precedent.
- `skills/references/chantier-tracking.md`: source-de-chantier trace and intake rules.
- `skills/references/reporting-contract.md`: compact user-facing reporting rules.
- `skills/references/decision-quality-contract.md`: quality bar and shortcut ban.

# Invariants

- `105-sg-check` remains a confidence/check skill, not product proof or lifecycle closure.
- `106-sg-fix` remains the bounded bug-fix entrypoint, not the generic implementation master.
- `107-sg-test` remains the manual QA and durable log owner and must not invent outcomes.
- `108-sg-browser` remains the non-auth browser-evidence specialist and must not absorb auth/session debugging.
- `109-sg-auth-debug` remains the auth/session specialist with strong redaction and safety posture.

# Links & Consequences

- This family sits directly under many diagnosis and proof routes, so wording drift can change how agents escalate or under-escalate work.
- If a shared doctrine conflict appears here, it likely affects other specialist families later.
- Runtime skill sync must pass after any activation-body edit.
- Documentation updates are probably unnecessary unless a technical lifecycle doc currently blurs these family boundaries.

# Documentation Coherence

- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` only if this batch changes the documented distinction between proof/diagnostic specialists.
- Keep `README.md` and `AGENT.md` unchanged unless a user-facing route promise becomes stale.
- Tracker and changelog updates belong to `104-sg-end` and `005-sg-ship`, not this spec.
- No README, FAQ, onboarding, pricing, or support copy change is expected from this batch because it only compacts internal ShipGlows specialist activation contracts.

# Edge Cases

- `105-sg-check` starts sounding authoritative enough to imply the product is verified.
- `106-sg-fix` starts sounding like a shortcut alias for `102-sg-start`.
- `107-sg-test` loses the user/tool-evidence requirement and reads like a generic checklist generator.
- `108-sg-browser` becomes a catch-all proof tool instead of a narrow browser evidence specialist.
- `109-sg-auth-debug` becomes too broad and absorbs any page failure that merely happens during login-adjacent navigation.

# Implementation Tasks

- [ ] Task 1: Establish the family matrix in the spec.
  - File: `shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md`
  - Action: Freeze the dominant question, forbidden drift, and must-preserve sentence for `105/106/107/108/109`.
  - User story link: Creates a durable semantic contract before edits.
  - Depends on: None.
  - Validate with: `rg -n "Ideal Specialist Matrix|105-sg-check|106-sg-fix|107-sg-test|108-sg-browser|109-sg-auth-debug" shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md`
  - Notes: This task completes with the spec itself.

- [ ] Task 2: Compact the specialist activation contracts.
  - Files: `skills/105-sg-check/SKILL.md`, `skills/106-sg-fix/SKILL.md`, `skills/107-sg-test/SKILL.md`, `skills/108-sg-browser/SKILL.md`, `skills/109-sg-auth-debug/SKILL.md`
  - Action: Add or align primary artifact type, mission, instruction-layering cues, and compact owner-boundary wording while preserving behavior.
  - User story link: Reduces confusion between diagnostic intake, fix, QA, browser proof, and auth-debug work.
  - Depends on: Task 1.
  - Validate with: `rg -n "Primary artifact type|Instruction Layering|Mission|Trace category|Process role" skills/105-sg-check/SKILL.md skills/106-sg-fix/SKILL.md skills/107-sg-test/SKILL.md skills/108-sg-browser/SKILL.md skills/109-sg-auth-debug/SKILL.md`
  - Notes: Keep the write set skill-local unless readiness explicitly expands scope.

- [x] Task 3: Verify family boundaries and proof rules.
  - Files: touched skill files and any touched docs if needed.
  - Action: Run lint/audit/sync checks and a manual overlap review focused on proof, auth, direct-fix, and test-result boundaries.
  - User story link: Prevents semantic compaction from collapsing distinct specialist lanes.
  - Depends on: Task 2.
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `tools/shipglows_sync_skills.sh --check --all`
  - Notes: Verification must explicitly check that `107` cannot imply unobserved success and `108` does not absorb auth scope.

- [x] Task 4: Decide whether shared-contract follow-up is needed.
  - File: `shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md`
  - Action: Record whether a later shared-reference/doc integration batch is unnecessary or required.
  - User story link: Keeps this batch bounded and prevents hidden scope growth.
  - Depends on: Task 3.
  - Validate with: `rg -n "shared-contract follow-up|shared-reference|no shared-reference drift" shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md`
  - Notes: If no drift appears, this task closes with a no-follow-up decision.

# Acceptance Criteria

- [x] AC 1: Given the touched family, when an agent reads each activation contract, then one primary `specialist-workflow` role is explicit in every touched skill.
- [x] AC 2: Given `106-sg-fix`, when an agent chooses a path, then the direct-fix versus spec-first distinction remains explicit and safety-bound.
- [x] AC 3: Given `107-sg-test`, when no user or tool evidence exists, then the skill still cannot imply a passing result.
- [x] AC 4: Given `108-sg-browser`, when the objective is auth/session/callback related, then the boundary still routes to `109-sg-auth-debug`.
- [x] AC 5: Given `109-sg-auth-debug`, when handling evidence, then the auth/session specialization and redaction posture remain explicit.
- [x] AC 6: Given Batch C completes, when validations run, then metadata lint, budget audit, runtime sync, and targeted grep checks all pass.

# Test Strategy

- Run metadata lint on the spec after creation and after any later trace updates.
- Run skill budget audit after activation-contract edits.
- Run runtime skill sync after activation-contract edits.
- Use targeted `rg` to confirm family markers, mandatory metadata, and must-preserve phrases remain visible.
- Perform one manual semantic review across the family before claiming the batch ready to ship.

# Risks

- High: this family influences how agents discover new chantiers or avoid premature ones.
- High: auth/debug and browser boundaries are easy to blur through over-shortening.
- Medium: old activation bodies may still hide shared doctrine that tempts scope growth.
- Medium: `105-sg-check` can be overtrusted if its confidence language is weakened.

## Closure Notes

- No shared-reference drift was discovered during Batch C verification; no shared-contract follow-up is required for this chantier.

# Execution Notes

- Read first: `skills/105-sg-check/SKILL.md`, `skills/106-sg-fix/SKILL.md`, `skills/107-sg-test/SKILL.md`, `skills/108-sg-browser/SKILL.md`, `skills/109-sg-auth-debug/SKILL.md`.
- Preserve the family as `source-de-chantier` specialists; do not promote any of them into lifecycle owners.
- Prefer the Batch A style: short activation contract, clear mission, precise owner boundaries, detailed workflow kept in references.
- Stop immediately if a correct edit would require mutating shared references; convert that into an explicit follow-up instead of widening the write set silently.
- Validation commands after edits: metadata lint, budget audit, runtime sync, targeted `rg`.
- Security review focus before claiming success: confirm `109` redaction posture, confirm `108` cannot become an auth fallback, confirm `107` cannot claim unobserved outcomes, and confirm `106` cannot bypass the spec-first safety boundary on unclear or higher-risk bugs.
- Stop conditions: stop if any required readiness fix would touch a file outside this spec, if a shared doctrine change is needed, or if the family boundaries still rely on conversation history after compaction.

# Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-12 20:35:00 UTC | 100-sg-spec | GPT-5 Codex | Created a new bounded specialist-family semantic compaction spec for the next post-Batch-A chantier | drafted | /101-sg-ready shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md |
| 2026-06-12 18:17:57 UTC | 101-sg-ready | GPT-5 Codex | Ran the readiness gate, repaired the spec-local readiness gaps, and approved the bounded specialist-family batch | ready | /102-sg-start shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md |
| 2026-06-12 21:00:00 UTC | 102-sg-start | GPT-5 Codex | Compacted the Batch C specialist-family activation contracts inside the owned skill set and ran the required local validations | implemented | /103-sg-verify shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md |
| 2026-06-12 18:21:56 UTC | 103-sg-verify | GPT-5 Codex | Verified Batch C specialist-family semantic compaction against the spec contract, taxonomy boundaries, preserved family distinctions, and required local validations | verified | /104-sg-end shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md |
| 2026-06-12 18:23:29 UTC | 104-sg-end | GPT-5 Codex | Closed Batch C bookkeeping, updated the canonical trackers and changelog, and confirmed the next lifecycle handoff to ship | closed | /005-sg-ship shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md |
| 2026-06-12 21:20:00 UTC | 005-sg-ship | GPT-5 Codex | Shipped the bounded Batch C specialist-family semantic compaction, updated the chantier trace to shipped, and pushed the owned scope | shipped | none |

## Current Chantier Flow

- 100-sg-spec: drafted
- 101-sg-ready: ready
- 102-sg-start: implemented
- 103-sg-verify: verified
- 104-sg-end: closed
- 005-sg-ship: shipped
- Next step: `none`
