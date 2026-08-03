---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 008-sg-customer
scope: onboarding-overlay-proof-and-copy
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/008-sg-customer/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Proof and communication extraction from the overlay pattern."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Onboarding Overlay — Copy And Proof

Each step says category, enabled outcome, action, and why/fallback. Explain permission value before prompting; never use shame, countdowns, fake urgency, or call an optional feature required. Public/support wording must match whether a step is automatic, optional, manual, or recoverable.

Prove: an active completed step turns success; skipped remains visible and recoverable; defer can resume from settings/support; an external setting refreshes state; all resolved steps can finish without claiming skipped capability. Use component/store tests plus web smoke for web UI; reserve device proof for native permission, IME, picker, notification, or provider behavior. Review README/setup, support, settings, FAQ, screenshots, changelog and manual QA when the promise changes.
