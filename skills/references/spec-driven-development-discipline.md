---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlows
created: "2026-05-18"
updated: "2026-08-07"
status: active
source_skill: 102-sg-start
scope: spec-driven-development-discipline
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/102-sg-start/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/003-sg-bug/SKILL.md
  - skills/900-shipglows-core/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/master-delegation-semantics.md
  - skills/references/decision-quality-contract.md
  - skills/references/design-system-token-contract.md
  - skills/references/zombies-edge-case-heuristic.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
evidence:
  - "Spec spec-driven-tdd-evidence-gates.md keeps ShipGlows spec-driven development as the outer lifecycle and adds proof-first implementation discipline."
  - "User decision 2026-05-24: proof paths must support high-quality code and durable decisions, not just the quickest passing change."
  - "User decision 2026-05-24: for Flutter mobile work, prove common UI first with widget tests and Flutter Web smoke before asking for APK/device testing."
  - "Conversation audit 2026-06-09: UI and product behavior claims need an explicit proof path or proof gap before being reported as fixed."
  - "User decision 2026-06-10: proof-first instructions should preserve strong evidence requirements without verbose examples in the decision path."
  - "User decision 2026-06-11: UI/design implementation must not create local visual decisions outside the centralized design-system authority."
  - "User decision 2026-07-18: technical checks may establish an implemented visual repair, but rendered validation is required before resolution claims."
  - "User decision 2026-08-07: non-trivial behavior uses the shared ZOMBIES heuristic proportionally to expose edge cases."
next_review: "2026-06-18"
next_step: "/103-sg-verify shipglows-skill-reporting-and-proof-hardening"
---

# Spec-Driven Development Discipline

## Purpose

ShipGlows stays spec-driven at the lifecycle level. Specs, bug files, release scopes, and mini-contracts define what must be true. Tests and evidence prove that an implementation satisfied that contract.

Use this reference when a ShipGlows skill modifies behavior, fixes a bug, changes a skill contract, or verifies a completion claim.

Before implementation, also load `skills/references/decision-quality-contract.md`. Proof-first discipline must prove a professional solution against the quality and excellence bar; it must not be used to justify the smallest change that merely makes a local check pass.

## Core Rule

Before implementation, name the proof path that fits the changed surface:

- `test-first`: for behavior with a reasonable automated test surface. Start with a failing or focused test, then implement the smallest complete excellent professional change that makes it pass without weakening security, performance, maintainability, product coherence, or future evolution.
- `regression-first`: for bugs. Capture reproduction and cause-root hypothesis first; add a failing regression test when practical.
- `scenario-first`: for skill, prompt, routing, or governance contract changes. Define pressure scenarios or mechanical checks before editing the contract.
- `evidence-first`: for UI, docs, auth, deployment, operational, visual, content, and integration work where automated TDD is not the right proof. Name concrete evidence before claiming completion. For UI/design work, this includes design-system authority and drift-check evidence.
- `exception-with-proof`: when the strongest path is not practical, record why and name the alternate evidence.

The proof path is part of the execution contract. It does not replace the source-of-truth work item.

A user-visible behavior claim is not complete until the report names the proof run or the remaining proof gap. This matters most for UI, input, playback, auth/session, and other flows where static checks can miss the user story.

For a user-visible visual claim, a build, typecheck, asset signature, filesystem
presence, URL reachability, or HTTP 200 is supporting evidence only. A repair
may be reported as `implemented` after those technical checks, but it is not
resolved, fixed, verified, or closed until a person validates the relevant
post-fix rendered result. An artifact or trace exception waives only that
artifact; it never waives behavior proof.

## Stack-Agnostic Test and Proof Contract

For every spec or execution task that includes behavior, add a proof ladder with stack-aware order and explicit exceptions:

- **Automated checks first** when the behavior is testable without external state risk.
- **Agent-run browser/auth proof** when observable behavior includes UI, redirects, routes, session/state, or public runtime surfaces.
- **Contract/integration proof** when service boundaries or external behavior is changed.
- **Provider/device/manual proof** only for provider-native behavior, native-only app behavior, or irreversible user-impacting paths.

For non-trivial changes, proof may be mixed: automated + agent-run proof + manual checklist only for remaining gaps.

For non-trivial behavior, load `skills/references/zombies-edge-case-heuristic.md` and retain compact `ZOMBIES coverage` in the contract or proof plan. Use `Z → O → M` to progress from empty to complex cases, challenge boundaries, interfaces, and exceptional behavior throughout, and keep scenarios simple. Branch-free micro-edits may record a justified `not applicable`.

When automation and required manual evidence are both impossible, use `exception-with-proof` with:
- what was impossible,
- why it is justified,
- and what alternate proof was run.

For skill-contract and governance changes, `scenario-first` means the implementation must define pressure scenarios or mechanical checks before claiming the contract is hardened. The final report should point to those scenarios or scans instead of saying the wording was merely updated.

## Hosted-Proof Follow-Through Rule

For tasks that can end in `partial`, `not verified`, or `blocked` because proof is missing outside the local scope, the contract must include an explicit owner route, not only a missing-evidence noun.

Any hosted/prod/deployed/provider/browser/manual proof gap must declare all of:

- `proof_type`: hosted, preview, production, auth, browser, webhook/provider, manual QA, or similar
- `owner_skill`: `405-sg-prod`, `108-sg-browser`, `109-sg-auth-debug`, `107-sg-test`, `005-sg-ship`, or a justified concrete alternative
- `scenario`: the exact action/flow to prove next (example: `login-smoke`, `checkout-smoke`, `webhook-smoke`)
- `target_or_environment`: preview URL, production URL, tenant, environment, or `target needed`

When `target_or_environment` is unknown, the first route is `405-sg-prod` for target discovery; do not route directly to non-hosted proof before discovery.

## Pressure Scenarios

- `VERIFY-PARTIAL-HOSTED`: `103-sg-verify` partial caused by missing hosted proof must include all hosted follow-through fields and a concrete owner route.
- `UNKNOWN-DEPLOYMENT-TARGET`: if the deployment URL/target is unknown, route as `target needed` and assign a concrete owner for discovery.
- `PREVIEW-PUSH-LADDER`: preview proof needing deployment must route `005-sg-ship` -> `405-sg-prod` before browser/auth/manual owner routing.
- `LOCAL-COMPLETE-PROD-PENDING`: local implementation complete while production/provider proof is pending must avoid closure/ship-ready language and name next owner.
- `SAFETY-REDACTION`: proof routes touching private payloads/logs/tokens/cookies/secrets must stay redacted and avoid requesting sensitive values.
- `VISUAL-IMPLEMENTED-NOT-RESOLVED`: valid image bytes, HTTP 200, a build, or a
  corrected local file may support `implemented`, but a person validates the
  rendered result before any resolved/fixed/verified/closed claim. If that
  validation is unavailable, report the proof gap with its concrete owner,
  scenario, proof type, and target or environment.

## Validation Proportionality

Not every change needs heavy checks.

Small, low-risk edits (docs-only copy, comments, narrow config updates, no behavior change, no auth/data boundary change) should prefer scoped checks and explicit `no functional impact` when that is true.

High-risk or behavior-sensitive changes still use stronger proof, including checks listed in the proof contract.

Do not default to full framework-heavy checks for low-risk edits; do not bypass stronger checks for high-risk behavior changes.

## CI Surface Gate (Path-Proportional CI)

CI strategy follows the same proportionality rule as testing:

- `docs` / `editorial` / `skills` / `workflow-tracker` edits should not force app or APK pipelines.
- app/site/backend edits should trigger only the matching heavy pipelines.
- cheap checks stay local and cheap; heavy checks are run when scope is materially impacted.

When path-filtered workflows are used:

- prefer explicit positive `paths` ownership over only `paths-ignore`
- require `workflow_dispatch` for full-surface manual reruns
- avoid branch protection setups that block unrelated PRs because filtered workflows were skipped

## Flutter Mobile Proof Ladder

For Flutter mobile work, do not ask the operator to install or test an APK until cheaper proof surfaces have been used or explicitly ruled out.

Default order:

1. Widget tests first for ordinary Flutter UI behavior, state transitions, form validation, crashes, regressions, loaders, empty states, and error states.
2. Flutter Web smoke next for UI surfaces that share the same Flutter widget/app code. The agent should run or route this proof itself when a local, preview, or production Web target is available: use `108-sg-browser` for non-auth UI proof and `109-sg-auth-debug` for auth/session/callback/protected-route proof.
3. Android APK/device proof last for behavior Flutter Web cannot prove: IME/keyboard behavior, permissions, overlays, notifications, background/foreground services, native plugins, platform channels, file pickers, camera/mic, storage, install/update behavior, and real-device performance.

For classic Flutter UI flows, the execution contract should list agent-run Web smoke scenarios before APK testing. Examples: manual clipboard add, edit, cancel, save without change, save with change, search, pin/unpin, and visual onboarding/settings.

Use `exception-with-proof` only when widget tests or Flutter Web are not practical, and name the reason before routing to APK/device evidence.

## Stop Conditions

Stop, reroute, or report `partial`/`not verified` when:

- non-trivial work has no ready spec, bug file, release scope, or mini-contract
- testable behavior changes without a test-first path or a recorded exception
- a bug fix lacks reproduction or cause-root evidence
- a skill contract change lacks pressure scenarios or mechanical checks
- evidence-first work names no concrete evidence surface
- UI/design implementation work has no declared design-system authority, token source, component bridge, or drift-check path
- a final report claims a user-visible behavior, skill behavior, or workflow behavior is fixed without naming validation run or the remaining proof gap
- proof collection would expose secrets, cookies, tokens, credentials, private payloads, production PII, or sensitive screenshots
- a Flutter UI change routes straight to APK/manual device testing while widget tests or agent-run Flutter Web smoke via `108-sg-browser`/`109-sg-auth-debug` can reasonably prove the shared UI behavior
- the proposed implementation is merely the fastest/easiest patch and does not satisfy the decision-quality contract
- the proposed implementation is adequate but visibly below the excellence bar for the risk

## Reporting

Final reports for execution and verification skills should state:

- chosen proof path
- validation or evidence actually performed
- explicit exception reason when test-first or regression-first was skipped
- remaining proof gap, if any

For concise user-mode reports, this can be one short evidence line. For agent or handoff reports, include the detailed validation matrix.

Good evidence examples: unit test, typecheck, build, lint, metadata lint, skill budget audit, runtime sync check, browser proof, screenshot, manual QA, redacted log, retest history, production check, or targeted `rg` confirmation.
