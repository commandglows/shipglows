---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 008-sg-customer
scope: onboarding-overlay-vue
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: no
linked_systems: [skills/008-sg-customer/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Vue extraction from the overlay pattern."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Onboarding Overlay — Vue

Use only for Vue/Tauri/web. Render a modal dialog with labelled header, keyboard-accessible progress buttons, active body, status badge, primary real action, optional refresh, and defer/next footer. `aria-current="step"` identifies the active step; icons are decorative and each button has a status label.

Implement one pure `stepStatus(step, isCurrent)` helper with the contract priority: skipped, completed, blocked, current, pending. Map its semantic classes (`is-pending`, `is-current`, `is-completed`, `is-skipped`, `is-blocked`) through project tokens; never hard-code the source palette. Keep action, refresh, skip, dismiss, selection and next/finish callbacks in the parent/store rather than duplicating product truth in the component.
