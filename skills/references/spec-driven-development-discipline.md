---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.8.0"
project: ShipGlows
created: "2026-05-18"
updated: "2026-11-21"
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
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.6.0"
    required_status: active
supersedes: []
evidence:
  - "Spec-driven TDD evidence gates keep ShipGlows spec-driven development as the outer lifecycle and add proof-first implementation discipline."
  - "User decisions 2026-05-24 and 2026-06-10: proof must support durable, high-quality code; Flutter UI proves common UI with widget tests and Flutter Web smoke before APK/device; keep strong evidence requirements without verbose examples."
  - "Audit 2026-06-09 and user decisions 2026-06-11, 2026-07-18, 2026-08-07: UI and product claims need a proof path or gap; UI decisions stay in the design-system authority; visual repairs need rendered validation; non-trivial behavior uses ZOMBIES proportionally."
  - "User decision 2026-11-21: lint, analyze, type checks and tests run without asking; builds need approval; critical or counter-intuitive requirements are pinned test-first and never weakened to fit a test."
next_review: "2026-06-18"
next_step: "/103-sg-verify shipglows-skill-reporting-and-proof-hardening"
---

# Spec-Driven Development Discipline

## Purpose

ShipGlows stays spec-driven at the lifecycle level: specs, bug files, release scopes and mini-contracts define what must be true; tests and evidence prove an implementation satisfied them.

Load this reference when a skill changes behavior, fixes a bug, changes a skill contract, or verifies a completion claim. Before implementation, also load `skills/references/decision-quality-contract.md`: proof-first discipline proves a professional solution against the quality bar, never the smallest change that merely passes a local check.

## Core Rule

Before implementation, name the proof path that fits the changed surface:

- `test-first`: behavior with a reasonable automated test surface. Start with a failing or focused test, then implement the smallest complete professional change that passes it without weakening security, performance, maintainability, product coherence or evolution.
- `regression-first`: bugs. Capture reproduction and cause-root hypothesis first; add a failing regression test when practical.
- `scenario-first`: skill, prompt, routing or governance contract changes. Define pressure scenarios or mechanical checks before editing the contract.
- `evidence-first`: UI, docs, auth, deployment, operational, visual, content and integration work where automated TDD is not the right proof. Name concrete evidence before claiming completion; UI/design work includes design-system authority and drift-check evidence.
- `exception-with-proof`: the strongest path is impractical; record why and name the alternate evidence.

The proof path is part of the execution contract; it does not replace the source-of-truth work item.

A user-visible behavior claim is not complete until the report names the proof run or the remaining proof gap, most of all for UI, input, playback, auth/session and other flows that static checks can miss.

For a user-visible visual claim, a build, typecheck, asset signature, filesystem presence, URL reachability, or HTTP 200 is supporting evidence only. A repair may be reported as `implemented` on those checks, but not as resolved, fixed, verified or closed until a person validates the post-fix rendered result. An artifact or trace exception waives only that artifact; it never waives behavior proof.

## Requirements That Must Stick

Agents revert or weaken a requirement when they guess what a test, grader or reviewer expects. Close that path:

- For a critical or counter-intuitive requirement, `test-first` is mandatory: write a test pinning the requirement itself, watch it fail, then implement until it passes. Lint, analyze, type checks and tests run without asking; only builds need approval.
- Never edit the test to make it pass. Before claiming done, check `git diff` on test files; changing an assertion that pins a requirement is a requirement change and needs the operator's decision.
- Never drop, soften or defer a stated requirement because it seems unlikely to be tested or graded. If it conflicts with another constraint, stop and report the conflict.
- Verify claims externally: measure memory, time, size, calls or logs from outside the program (OS tools, profiler, harness, independent script); never trust numbers the program prints about itself.

## Stack-Agnostic Test and Proof Contract

For any spec or execution task that includes behavior, add a proof ladder in stack-aware order, with explicit exceptions:

- **Automated checks first** when behavior is testable without external state risk.
- **Agent-run browser/auth proof** when observable behavior includes UI, redirects, routes, session/state or public runtime surfaces.
- **Contract/integration proof** when service boundaries or external behavior change.
- **Provider/device/manual proof** only for provider-native, native-only or irreversible user-impacting paths.

Non-trivial changes may mix these; manual checks cover only the remaining gaps.

For non-trivial behavior, load `skills/references/zombies-edge-case-heuristic.md` and keep a compact `ZOMBIES coverage` in the contract or proof plan. Branch-free micro-edits may record a justified `not applicable`.

When automation and required manual evidence are both impossible, use `exception-with-proof`: what was impossible, why it is justified, and what alternate proof ran.

For skill-contract and governance changes, `scenario-first` means defining pressure scenarios or mechanical checks before claiming the contract is hardened; the report points to them rather than saying the wording was updated.

## Hosted-Proof Follow-Through Rule

A task that can end `partial`, `not verified` or `blocked` because hosted, prod, deployed, provider, browser or manual proof is missing must declare an explicit owner route with all of:

- `proof_type`: hosted, preview, production, auth, browser, webhook/provider, manual QA, or similar
- `owner_skill`: `405-sg-prod`, `108-sg-browser`, `109-sg-auth-debug`, `107-sg-test`, `005-sg-ship`, or a justified alternative
- `scenario`: the exact flow to prove next (example: `login-smoke`, `checkout-smoke`, `webhook-smoke`)
- `target_or_environment`: preview URL, production URL, tenant, environment, or `target needed`

When the target is unknown, route first to `405-sg-prod` for target discovery; never route straight to non-hosted proof.

## Pressure Scenarios

- `VERIFY-PARTIAL-HOSTED`: `103-sg-verify` partial caused by missing hosted proof must include all hosted follow-through fields and a concrete owner route.
- `UNKNOWN-DEPLOYMENT-TARGET`: an unknown deployment target routes as `target needed` with a concrete discovery owner.
- `PREVIEW-PUSH-LADDER`: preview proof that needs a deployment routes `005-sg-ship` -> `405-sg-prod` before browser/auth/manual owner routing.
- `LOCAL-COMPLETE-PROD-PENDING`: local work complete while production/provider proof is pending avoids closure or ship-ready language and names the next owner.
- `SAFETY-REDACTION`: proof routes touching private payloads, logs, tokens, cookies or secrets stay redacted and never request sensitive values.
- `VISUAL-IMPLEMENTED-NOT-RESOLVED`: valid image bytes, HTTP 200, a build, or a corrected local file may support `implemented`, but a person validates the rendered result before any resolved/fixed/verified/closed claim. If that validation is unavailable, report the proof gap with its owner, scenario, proof type and target or environment.

## Validation Proportionality

Small, low-risk edits (docs copy, comments, narrow config, no behavior, auth or data change) use scoped checks and may state `no functional impact`. High-risk or behavior-sensitive changes use the stronger proof in the contract.

## CI Surface Gate (Path-Proportional CI)

- `docs` / `editorial` / `skills` / `workflow-tracker` edits never force app or APK pipelines; app, site or backend edits trigger only their matching heavy pipelines.
- For path-filtered workflows, prefer explicit positive `paths` over `paths-ignore`, require `workflow_dispatch` for full manual reruns, and avoid branch protection that blocks unrelated PRs when filtered workflows skip.

## Flutter Mobile Proof Ladder

For Flutter mobile work, do not ask the operator to install or test an APK until cheaper proof surfaces have been used or ruled out. Default order:

1. Widget tests for ordinary UI behavior, state transitions, form validation, crashes, regressions, loaders, empty states and error states.
2. Flutter Web smoke for UI that shares the same widget/app code: `108-sg-browser` for non-auth UI, `109-sg-auth-debug` for auth, session, callback or protected-route proof. The agent runs or routes it when a local, preview or production Web target exists.
3. Android APK/device proof last, only for what Flutter Web cannot prove: IME/keyboard, permissions, overlays, notifications, background services, native plugins, platform channels, file pickers, camera/mic, storage, install/update, real-device performance.

Classic Flutter UI flows list agent-run Web smoke scenarios (add, edit, save, search, pin, onboarding, settings) before APK testing. Use `exception-with-proof` only when widget tests or Flutter Web are impractical, and name the reason before routing to APK/device evidence.

## Stop Conditions

Stop, reroute, or report `partial`/`not verified` when:

- non-trivial work has no ready spec, bug file, release scope or mini-contract
- testable behavior changes without a test-first path or a recorded exception
- a test pinning a requirement was edited to pass, or a requirement was weakened without operator decision
- a bug fix lacks reproduction or cause-root evidence
- a skill contract change lacks pressure scenarios or mechanical checks
- evidence-first work names no concrete evidence surface
- UI/design implementation has no declared design-system authority, token source, component bridge or drift-check path
- a final report claims user-visible, skill or workflow behavior is fixed without naming the validation run or remaining proof gap
- proof collection would expose secrets, cookies, tokens, credentials, private payloads, production PII or sensitive screenshots
- a Flutter UI change routes straight to APK/manual device testing while widget tests or agent-run Flutter Web smoke can reasonably prove the shared UI
- the proposed implementation is the fastest or easiest patch and does not satisfy the decision-quality contract, or is visibly below the excellence bar for the risk

## Reporting

Execution and verification reports state the chosen proof path, the validation or evidence actually performed, the exception reason when test-first or regression-first was skipped, and any remaining proof gap. Concise user reports use one evidence line; agent handoffs include the validation matrix.

Good evidence: automated check, lint, type check, build, budget audit, runtime sync check, browser proof, screenshot, manual QA, redacted log, retest history, production check or targeted `rg` confirmation.
