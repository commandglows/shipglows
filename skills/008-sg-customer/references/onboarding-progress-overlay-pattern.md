---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-06-12"
updated: "2026-08-03"
status: active
source_skill: 008-sg-customer
scope: onboarding-progress-overlay-index
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/008-sg-customer/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Compacted by loading decision; the former monolith remains this bounded compatibility index."
next_step: "/103-sg-verify compact monolithic skill references"
---

# Onboarding Progress Overlay Index

Load this index only after `008-sg-customer onboarding` has established that a stepped overlay is explicitly required. It does not itself contain the contract.

| Need | Load exactly this direct reference |
| --- | --- |
| Product shape, state priority, navigation, persistence | `onboarding-overlay-contract.md` |
| Vue/Tauri implementation | `onboarding-overlay-vue.md` |
| Flutter implementation | `onboarding-overlay-flutter.md` |
| Copy, proof, documentation impact | `onboarding-overlay-proof-and-copy.md` |

Inspect the closest available source implementation before porting: WinFlowz Flutter shell/permission contract/tests or Temu Vue overlay/store/style. Preserve interaction structure, but map visual values through the target design-system authority.
