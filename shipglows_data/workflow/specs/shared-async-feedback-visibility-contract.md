---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-07-18"
created_at: "2026-07-18 00:00:00 UTC"
updated: "2026-07-18"
updated_at: "2026-07-18 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "shared-async-feedback-visibility-contract"
owner: "Diane"
user_story: "As a product user, I want every operation that may take noticeable time to show progress, current stage, and recovery guidance, so I can distinguish active work from a broken or abandoned screen."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/references/decision-quality-contract.md"
  - "skills/references/spec-driven-development-discipline.md"
  - "skills/references/reporting-contract.md"
  - "skills/006-sg-design/SKILL.md"
  - "skills/008-sg-customer/SKILL.md"
  - "shipglows_data/technical/app/guidelines.md"
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.1"
    required_status: "active"
supersedes: []
evidence:
  - "User direction 2026-07-18: delayed behavior must visibly communicate that work is in progress; users must not be left wondering whether the product is stuck."
  - "Android auth feedback: a Clerk session check displayed a static message, making a real wait indistinguishable from a hang."
  - "The same ambiguity can recur in design, customer, auth, data, and integration flows across projects unless the rule is shared."
next_step: "/005-sg-ship ship bounded shared feedback contract slice; runtime pilot remains pending"
---

# Title

Shared Async Feedback Visibility Contract

## Status

ready

## User Story

As a product user, I want every operation that may take noticeable time to show progress, current stage, and recovery guidance, so I can distinguish active work from a broken or abandoned screen.

## Minimal Behavior Contract

Every user-triggered or startup operation that can exceed the platform's immediate response window must expose an observable busy state. The state must include an appropriate animation or progress indicator, a plain-language status (what is being checked/loaded/saved), input protection against duplicate submission, and a deterministic completion, error, timeout, retry, or cancellation outcome. Shared guidance must apply across projects and surfaces, including design and customer journeys; local design systems own the visual carrier, while this contract owns the feedback behavior.

## Success Behavior

- On start, the relevant control or region immediately shows an animation or measurable progress state.
- Status text names the current stage without exposing secrets, tokens, cookies, or private payloads.
- Duplicate taps/actions are prevented or safely coalesced while work is active.
- Completion restores usable controls and announces the resulting state.
- Error or timeout explains what happened and offers a safe retry or next step.
- The pattern is usable with reduced-motion settings and accessible to assistive technology.

## Error Behavior

- Never leave a static “checking/loading/processing” message without motion, progress, timeout, or recovery guidance.
- Never show an indefinite spinner with no bounded fallback for a network/provider operation.
- Never claim completion from a local state change when the external operation has not returned success.
- Diagnostics must be redacted and safe to copy; no credentials or auth artifacts are logged.

## Pressure Scenarios

- `ASYNC-AUTH-CHECK`: app startup checks a Clerk/session/backend state for several seconds; the user can see active progress, then success or retryable failure.
- `ASYNC-DESIGN-ACTION`: a design preview/render/export or asset operation takes time; the surface shows stage/progress and prevents duplicate actions.
- `ASYNC-CUSTOMER-ACTION`: onboarding, save, upload, or customer-support action waits on a service; the user gets progress plus timeout/retry guidance.
- `ASYNC-FAILURE-RECOVERY`: provider/network failure occurs after progress begins; the surface exits busy state and offers a safe retry without losing confirmed input.
- `ASYNC-REDUCED-MOTION`: reduced-motion preference is active; the user still receives non-motion progress/status semantics.

## Scope In

- Add a shared, stack-agnostic feedback contract/reference and adoption checklist for product-facing skills and projects.
- Define minimum semantics for busy, progress, success, error, timeout, retry, cancellation, duplicate-action protection, accessibility, and safe diagnostics.
- Require design and customer skills to reference the same contract while preserving project-specific design-system tokens and journey language.
- Add scenario-first mechanical/documentation checks and a small reusable test matrix.

## Scope Out

- Replacing any project's design system or animation library.
- Mandating one spinner, color, copy style, timeout duration, or state-management framework.
- Retrofitting every existing screen in this spec; adoption is routed to bounded project/spec work.
- Changing backend retry policy, auth providers, or analytics taxonomy beyond observable feedback requirements.

## Test Contract

- `rg`/audit check confirms the shared contract is referenced by `006-sg-design`, `008-sg-customer`, and relevant lifecycle/auth skills.
- Scenario checks cover each pressure scenario above with explicit busy-to-terminal-state transitions.
- Accessibility review confirms semantics remain available with reduced motion and screen readers.
- Targeted Flutter/widget, browser, or native tests are selected by each adopting project; provider/device proof remains manual only where native behavior requires it.
- Safe-diagnostics check confirms no token, cookie, credential, or private payload is included in progress text or logs.

## Implementation Tasks

- [x] Create the canonical shared reference and adoption checklist.
- [x] Add first-screen cross-references and ownership boundaries to design and customer/auth skills.
- [x] Add and run scenario/mechanical checks through the existing audit, budget, metadata, unit, and sync tooling.
- [ ] Pilot the contract on the Android auth flow and one design or customer async flow.
- [x] Run readiness, implementation, refresh review, and verification lifecycle gates for this contract.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-18 | 100-sg-spec | GPT-5 Codex | Create shared async feedback visibility contract from operator feedback | ready | 101-sg-ready validate scope and proof contract |
| 2026-07-18 | 101-sg-ready | GPT-5 Codex | Validate shared behavior, scope, and scenario-first proof contract | ready | 102-sg-start implement canonical reference and bounded adoption links |
| 2026-07-18 | 102-sg-start | GPT-5 Codex | Add canonical reference, adoption checklist, and design/customer/auth cross-references | implemented | 103-sg-verify run scenario and mechanical checks |
| 2026-07-18 | 900-shipglows-core | GPT-5 Codex | Refresh review of shared contract and cross-skill adoption | reviewed | 103-sg-verify run standard contract and sync checks |
| 2026-07-18 | 103-sg-verify | GPT-5 Codex | Run scenario-first, audit, budget, metadata, unit, and runtime sync checks | verified | 104-sg-end close and prepare ship handoff |
| 2026-07-18 | 104-sg-end | GPT-5 Codex | Close completed contract/reference work; keep runtime pilot explicitly pending | complete | 005-sg-ship ship bounded documentation/skill slice |

## Current Chantier Flow

- `100-sg-spec` ✅ spec created
- `101-sg-ready` ✅ ready
- `102-sg-start` ✅ implemented
- `103-sg-verify` ✅ verified
- `104-sg-end` ✅ complete
- `005-sg-ship` ⏳ pending
