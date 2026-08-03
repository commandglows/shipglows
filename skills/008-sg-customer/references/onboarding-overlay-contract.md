---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 008-sg-customer
scope: onboarding-overlay-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/008-sg-customer/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Transferred from onboarding progress overlay pattern."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Onboarding Overlay Contract

Use for a resumable first-success overlay, never an intro carousel. Its hierarchy is header, selectable progress sections, active-step body, why/action panel, then defer/next footer. Each step has a stable id, group, title, description, why, icon, action label, and testable `completed`, `skipped`, `supported`, and `blockerReason` truth.

Required: independent narrow sections; value and action; optional versus required distinction; safe defer; settings/support resume; recheck after external settings, permission, auth, provider, or lifecycle return; persisted user choice without fake capability state.

Status priority is invariant: `skipped`/refused → distinct danger; `completed` → success; blocked/unsupported → explained warning; current unresolved → active; unknown → neutral. Completed always wins over current; skipped is never completion.

Open on the first unresolved non-skipped step; do not auto-open after all steps resolve. An external handoff persists resume context and rechecks on return. Finish requires required steps satisfied and optional steps explicitly skipped/deferred. Dismiss persists deferred, not completed. Capability truth comes from the product; persist only dismissed, completed, skipped ids, and last selected id.

Do not coerce permissions, hide privacy/billing/data consequences, copy one-off styling, or imply an unsupported platform capability.
