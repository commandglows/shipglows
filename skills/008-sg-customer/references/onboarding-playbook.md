---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-07-17"
status: active
source_skill: 008-sg-customer
scope: onboarding-playbook
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/008-sg-customer/SKILL.md
  - skills/008-sg-customer/references/onboarding-progress-overlay-pattern.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-06-29: retain onboarding as a customer-mode playbook rather than a separate active skill."
next_review: "2026-07-29"
next_step: "/103-sg-verify 008-sg-customer"
---

# Onboarding Playbook

## Purpose

Use this playbook only for `008-sg-customer onboarding [feature-or-flow]`: onboarding, activation, setup guidance, first-run flows, first-success recovery, or feature adoption.

Onboarding is a mode of end-user experience. It should help the user reach value, understand state, recover from blockers, and trust the product. It is not only a welcome modal, tooltip tour, or checklist.

## Activation Principles

Every onboarding recommendation or implementation contract should cover:

- **First success**: the earliest meaningful value moment the user should reach.
- **Context**: what feature this is, who it helps, and why it matters now.
- **Why and how**: plain-language benefit plus concrete action, not only labels.
- **Progressive disclosure**: reveal only what the user needs now; keep advanced detail, secondary setup, and expert shortcuts behind later steps or optional expansion.
- **Small steps**: each step should be narrow enough to understand and complete without cognitive overload.
- **Dependency order**: required prerequisites before advanced or fragile setup.
- **Required vs optional**: separate core value from enhancers and nice-to-have modules.
- **User control**: defer, skip, revisit, or disable optional setup without punishment.
- **Next best action**: when a recurring friction or setup fork appears, present the continue path, the recommended path, and the owner skill or guided ShipGlows route when it materially improves first success.
- **Visual cues**: use identifiable icons, colors, badges, and affordances for current, completed, skipped, blocked, and warning states; completed state wins over current state when both are true.
- **Visible state**: current, completed, skipped, blocked, unsupported, revoked, and recoverable states when relevant.
- **Recovery**: refresh/recheck actions, settings deep links, resume paths, and clear next actions after leaving the app.
- **Progressive depth**: beginner path first; shortcuts or expert details only when useful.
- **Trust**: no permission coercion, dark patterns, fake urgency, or hidden data consequences.
- **Coherence**: docs, support copy, screenshots, public claims, changelog, and in-app states say the same thing.

When onboarding is already attached to a concrete feature, route, or shipped change, anchor the guidance to the current product state first. Start from the earliest observable success path, then explain the recovery path if the user gets stuck, and only then expand into optional setup or expert shortcuts.

If the user already has a broken first-run or setup flow, treat recovery to first success as the main goal.

## Onboarding Contract

Use this compact structure for read-only or planning output:

```text
Onboarding Contract: [feature/flow]

Target user:
First success:
Entry trigger:
Step size / disclosure:
Required setup:
Optional enhancers:
Recommended sequence:
Visual cues:
States:
Recovery paths:
Why/how copy notes:
Next best action:
Docs/editorial impact:
Proof path:
Implementation route:
```

If implementation is needed, convert the contract into a spec-ready behavior contract before editing source files.

## UX/UI Mode

For onboarding UI, review:

- whether the first visible state tells the user what value they can reach
- whether the primary action is obvious without explanatory text elsewhere
- whether skipped, blocked, completed, and current states are distinct
- whether the flow works when the user leaves for OS settings, provider auth, payment, billing, file access, or another external surface
- whether the user can resume without restarting the whole journey
- whether the UI uses the project design-system authority for layout, spacing, colors, icons, and motion

Route broad visual-system, component, layout, or token work to `006-sg-design`. Keep `008-sg-customer` focused on the customer's path, comprehension, state, recovery, and proof.

## Permission And Sensitive Setup

For permissions, system settings, billing, integrations, API keys, auth, data sync, device access, or external accounts:

- explain the user value before the action
- state whether the feature works without it
- place fragile or unavailable setup after prerequisites
- offer a safe defer path
- provide recheck/recovery after settings changes
- do not imply the app can grant permission itself when the OS/provider owns it
- do not hide privacy, billing, quota, data, or security consequences
- use fresh official docs when current external behavior affects the guidance

## Specialized Overlay Pattern

Load `skills/008-sg-customer/references/onboarding-progress-overlay-pattern.md` only when the request explicitly needs a popup-style or stepped onboarding overlay. Ordinary onboarding loads no overlay pattern.
