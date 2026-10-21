---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-18"
updated: "2026-07-18"
status: active
source_skill: 102-sg-start
scope: shared-async-feedback-visibility
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
  - shipglows_data/workflow/specs/shared-async-feedback-visibility-contract.md
depends_on: []
supersedes: []
evidence:
  - "User direction 2026-07-18: users must see when delayed behavior is active instead of guessing whether it is broken."
  - "Shared spec shared-async-feedback-visibility-contract.md defines cross-project pressure scenarios and proof obligations."
next_review: "2026-10-18"
next_step: "Adopt per bounded flow using shipglows_data/technical/async-feedback-visibility-adoption-checklist.md"
---

# Shared Async Feedback Visibility Contract

Any user-visible operation that may take longer than an immediate response must make its state legible. This is a cross-project behavior contract, not a mandate for one visual component or animation library.

## Minimum contract

- Start with an animation or measurable progress indicator immediately.
- Name the current stage in plain language: what is being checked, loaded, saved, or processed.
- Prevent duplicate actions while work is active, or safely coalesce them.
- End in success, error, timeout, retry, or cancellation; never leave an indefinite busy state.
- Preserve accessible status semantics with reduced motion and assistive technology.
- Keep status text and diagnostics free of tokens, cookies, credentials, and private payloads.

## Ownership

Project design systems choose tokens, motion carrier, and component primitives. Customer flows choose journey copy and recovery language. Feature/auth owners define real stages and terminal outcomes. This contract owns the minimum observable behavior and proof obligation.

## Adoption proof

For each adopted flow, record the trigger, busy indicator, stage copy, terminal states, duplicate-action behavior, timeout/retry path, reduced-motion behavior, and redacted diagnostics. Use the checklist at `shipglows_data/technical/async-feedback-visibility-adoption-checklist.md`.
