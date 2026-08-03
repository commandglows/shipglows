---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 008-sg-customer
scope: onboarding-overlay-flutter
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: no
linked_systems: [skills/008-sg-customer/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Flutter extraction from the overlay pattern."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Onboarding Overlay — Flutter

Use only for Flutter. Compose a `Dialog` from header, progress dots, active step, action panel, and footer. The parent owns selection/action/skip/dismiss/next/refresh callbacks; progress dots own accessible semantic status. Use project colours and widgets. The colour resolver implements skipped → danger, satisfied → success, blocked → warning, current → active, otherwise pending; a satisfied active step must render success immediately.
