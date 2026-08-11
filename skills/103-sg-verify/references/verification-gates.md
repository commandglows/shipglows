---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.3.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-07-17"
status: draft
source_skill: 102-sg-start
scope: 103-sg-verify-gates
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/103-sg-verify/SKILL.md
  - skills/references/documentation-freshness-gate.md
  - skills/references/project-development-mode.md
  - skills/references/sentry-observability.md
  - tools/test_103_sg_verify_excellence_contract.py
depends_on:
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Extracted from 103-sg-verify SKILL.md during compact-skill pilot."
  - "User decision 2026-05-24: Flutter mobile UI proof should use widget tests and Flutter Web smoke before APK/device testing."
  - "Operator decision 2026-07-17: excellence is a distinct critical focus after métier verification, not merely a deeper standard run."
next_review: "2026-06-16"
next_step: "/103-sg-verify mode=excellence sg-verify excellence focus mode"
---

# 103-sg-verify Detailed Gates

## Step Skeleton

1. Identify scope/work item and select `standard` or explicit `excellence` mode.
2. Resolve development mode and required validation surface.
3. Verify user story outcome.
4. Verify success behavior and error behavior.
5. Verify metadata/versioned contracts and `depends_on` coherence.
6. Verify fresh external docs gate when dependency behavior matters.
7. Verify completeness (tasks, acceptance criteria, expected files).
8. Verify bug gate from `shipglows_data/workflow/bugs/*.md` (+ optional `shipglows_data/workflow/BUGS.md` index).
9. Verify correctness against code/tests/invariants/linked consequences.
10. Verify Flutter mobile proof ladder when Flutter UI or APK/device evidence is in scope.
11. Verify coherence (project patterns, language doctrine, docs coherence).
12. Verify dependency, risk, and quick technical checks.
13. In excellence mode only, run the fresh excellence focus pass after standard readiness succeeds.
14. Report the selected focus, verdict, and any concrete repair or owner route.

## Development Mode Gate

Use `project-development-mode.md` to classify:

- `local`
- `vercel-preview-push`
- `hybrid`
- `unknown-vercel`
- `unknown`

Rules:

- In preview/hybrid modes, do not mark ready-to-ship when required hosted/browser/manual proof is missing.
- For preview-required proof, route through `005-sg-ship -> 405-sg-prod -> 107-sg-test --preview` or `109-sg-auth-debug` / `108-sg-browser`.

## Success / Error Behavior Gate

Always report both:

- expected observable success + system effect + evidence
- expected error handling + forbidden bad states + evidence

If success/error behavior is unproven:

- `partial` when risk is moderate and contract remains mostly stable
- `not verified` or `blocked` for high-risk contract gaps (security, data, money, destructive behavior, external critical integrations)

## Metadata / Version Gate

When spec exists:

- verify spec metadata presence (`metadata_schema_version`, `artifact_version`, `status`, `updated`)
- verify `depends_on` coherence with current referenced docs versions/statuses
- flag outdated/missing dependency contracts

Escalation:

- `warning` for non-critical version drift
- `critical` when drift can alter permissions, pricing, security, data behavior, public claims, or architecture contract

## Fresh Docs Gate

Use `documentation-freshness-gate.md`.

Verdicts:

- `fresh-docs checked`
- `fresh-docs not needed`
- `fresh-docs gap`
- `fresh-docs conflict`

Critical domains require current official/contextual references before confident verification: auth, permissions, security, migrations, payment, tenant boundaries, webhooks, critical integrations.

## Bug Gate

Source of truth is `shipglows_data/workflow/bugs/*.md`. `shipglows_data/workflow/BUGS.md` is optional index only.

Verdicts:

- `bug gate clear`
- `partial-risk`
- `blocks ship`
- `not assessed`

Any open high/critical bug in scope blocks ready-to-ship verdict.

## Manual Checklist Gate

If the scope references `manual_test_checklist` artifacts, parse checklist files before the final verdict.

Required rows are blocking unless:
- status is `PASS`
- an explicit and recorded exception was accepted in scope contract
- scope transition moved to a more concrete proof artifact (`107-sg-test` produced a confirmed `Bug Link` or documented manual exception)

Unresolved required rows (`NOT_RUN`, `FAIL`, `BLOCKED`) produce `partial` or `not verified` unless a safe, documented exception exists.

Use `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/shipglows_checklist_status.py <checklist>` during verification.

## CI Surface Gate (Path-Filtered Workflows)

When workflow files exist under `.github/workflows/**`, verify CI is proportional:

- doc-only or governance-only changes should route to docs/skills/workflow jobs only
- app/site/backend changes should run only matching expensive jobs
- unrelated expensive jobs must be skipped, not forced

Before marking the CI gate clear:

- ensure path filters use positive ownership scopes (`paths`), not only broad `paths-ignore`
- ensure `workflow_dispatch` exists for forced full-surface checks
- ensure branch-protection rules do not require a routinely skipped path-filtered workflow (or an accepted umbrella status exists)

If no `.github/workflows` exists in this repo, document this as `not assessed` with reason "no local workflows to validate", and route the next step to the repository where workflow assets exist.

## Coherence Gates

### Project / Code Coherence

- respect CLAUDE/project constraints
- respect local architecture/style conventions
- verify linked systems and downstream consequences

### Language Doctrine

For touched ShipGlows artifacts:

- internal contracts in English
- user-facing output in active language
- French accents for French user-facing text (except technical identifiers/commands)
- stable machine anchors in English

### Documentation Coherence

When behavior/contracts changed:

- docs aligned or explicit no-impact justification
- stale docs are warnings or critical depending on user risk

## Dependency And Risk Gate

Check diff for:

- new dependencies relevance and vulnerability risk
- obvious security/performance/data risks
- destructive/migration hazards

## Excellence Focus Pass

Run this section only when `excellence` was selected through explicit `mode=excellence` or an unambiguous natural-language request, and only after the standard métier, proof, correctness, security, and risk gates pass. This is a fresh second focus beyond the acceptance criteria, not a rerun of the standard checklist and not a request for more test volume by default.

Challenge the verified work with concrete evidence:

1. **User value and comprehension:** Is a meaningful user outcome, explanation, recovery path, or trust signal still weaker than it reasonably could be?
2. **Cross-surface coherence:** Do behavior, structure, terminology, public docs, runtime surfaces, and owner contracts disagree in a way that creates confusion or drift?
3. **Duplication and structure:** Is repeated logic, content, process, or policy creating avoidable inconsistency or maintenance cost?
4. **User or operator friction:** Does the implementation preserve a manual step, unclear route, hidden state, or repeated workload that the current structure could remove safely?
5. **Durability and robustness:** Is the choice correct today but fragile under ordinary extension, failure, upgrade, scale, or future maintenance?
6. **Merely adequate choices:** Is there a bounded professional alternative that materially improves the outcome without changing the accepted product contract?

Do not claim `excellent` from inherited confidence, the standard checklist alone, or a generic statement that nothing obvious was found. Name the surfaces challenged and the evidence used.

### Materiality Boundary

A gap is material only when resolving it would meaningfully improve at least one of: user outcome or comprehension, cross-surface coherence, correctness or reliability margin, security/privacy, performance or operational robustness, maintainability/durability, avoidable duplication, or operator workload. It must be evidence-backed, concrete enough to change a reasonable ship, follow-up, or architecture decision, and have a repair or owner route.

Pure taste, unsupported polish, speculative preferences, and generic “could be better” observations are non-material suggestions. They may be reported as optional context, but they do not reopen the chantier and cannot produce `verified_with_excellence_gaps`.

### Verdict And Trace Routing

- Return `verified_with_excellence_gaps` when standard readiness is valid and at least one material gap remains. Preserve any earlier standard `verified` history row; append the excellence result instead of rewriting history.
- Return `excellent` only when standard readiness passes, the fresh excellence pass is evidenced, and no material gap remains.
- Keep `partial`, `not verified`, or `blocked` when proof, correctness, security, or blocking risk fails. These verdicts take precedence; never relabel the failure as an excellence gap.
- Record non-material suggestions without reopening follow-up work.

### Repair And Owner Boundary

`103-sg-verify` may repair a stable, bounded local issue when the contract and correct result are already clear, then rerun the affected evidence. Otherwise route the gap rather than expanding verification into an implicit audit or product redesign:

- product meaning, acceptance criteria, architecture, or scope change -> `100-sg-spec` (use `700-sg-explore` first only when the decision itself is unclear)
- design, copy, code/security, or performance specialist investigation -> `006-sg-design`, `009-sg-marketing`, `010-sg-technical audit`, or `010-sg-technical performance`
- hosted, preview, production, browser, auth, or manual proof -> the existing `005-sg-ship`, `405-sg-prod`, `108-sg-browser`, `109-sg-auth-debug`, or `107-sg-test` proof route with scenario and target/environment
- multi-owner or security-sensitive repair -> the appropriate ready-spec lifecycle or specialist owner; do not mutate it opportunistically from verification

### Pressure Scenarios

- `EXCELLENCE-001 STANDARD-DEFAULT`: A normal invocation selects standard métier and ship-readiness verification, may return `verified`, and makes no excellence claim.
- `EXCELLENCE-002 MATERIAL-GAP`: A prior standard `verified` result exists; the fresh excellence pass finds evidence-backed duplication or incoherence. Return `verified_with_excellence_gaps`, preserve the prior row, and route bounded follow-up.
- `EXCELLENCE-003 NO-MATERIAL-GAP`: Standard readiness passes and the evidenced fresh pass finds no material gap. `excellent` is allowed.
- `EXCELLENCE-004 PROOF-OR-RISK-FAILURE`: Hosted proof is missing or a correctness/security risk blocks. Keep `partial`, `not verified`, or `blocked`; an excellence verdict is forbidden.
- `EXCELLENCE-005 NON-MATERIAL-SUGGESTION`: The pass finds only taste-level wording or formatting preferences. Record them at most as optional suggestions and do not reopen the chantier.
- `EXCELLENCE-006 ATOMIC-PROPORTIONALITY`: A deterministic atomic change has focused evidence for its exact contract. Excellence accepts that focused evidence and does not force an unrelated exhaustive audit.

## Technical Checks Gate

Run quick checks only (no local build by default):

- lint/typecheck/tests where available and relevant
- if required checks fail -> `critical`

## Flutter Mobile Proof Ladder Gate

When scope touches Flutter mobile UI or asks the operator to test an APK, verify the evidence order:

1. Widget/unit tests for ordinary Flutter UI behavior when practical.
2. Agent-run Flutter Web smoke for shared UI surfaces that can run without native-only behavior. Use `108-sg-browser` for non-auth UI objectives and `109-sg-auth-debug` for auth/session/callback/protected-route objectives.
3. APK/device proof only for native-only behavior or remaining device-specific risk.

Common Web-smoke candidates: manual clipboard add, edit, cancel, save without change, save with change, search, pin/unpin, onboarding visuals, and settings visuals.

APK/device proof remains required for IME/keyboard behavior, permissions, overlays, notifications, background/foreground services, native plugins, platform channels, file pickers, camera/mic, storage, install/update behavior, or real-device performance.

If a Flutter UI change skipped widget tests and agent-run Flutter Web smoke without a concrete exception, mark verification `partial` or `not verified` before asking for manual APK proof.

## Reporting Contract (Required Blocks)

Include compact but explicit sections:

- summary table
- critical / warning / suggestion
- user story verdict
- success/error verdict
- metadata/contract version verdict
- language doctrine verdict
- fresh docs verdict
- development mode verdict
- Sentry observability status when applicable
- runtime diagnostics/log-copy/build-header status when applicable
- runtime diagnostic surface reuse/adoption status when applicable: existing helper/component reused, or a scoped new helper added from `runtime-diagnostics-surface.md`
- operator autonomy status: safe evidence gathered by the agent vs genuinely unavailable inputs requiring the operator
- bug gate verdict
- workflow next step
- chantier block

Never output `⚠` or `✗` without a concrete next command.

## Graceful Degradation

When context artifacts are missing, continue with explicit confidence limits and list skipped checks/reasons.
