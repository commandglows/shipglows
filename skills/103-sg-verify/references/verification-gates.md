---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 103-sg-verify
scope: 103-sg-verify-pack-index
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/103-sg-verify/SKILL.md
  - skills/103-sg-verify/references/verification-baseline.md
  - skills/103-sg-verify/references/verification-excellence.md
  - skills/103-sg-verify/references/verification-security-ui-runtime.md
  - skills/103-sg-verify/references/verification-coherence.md
depends_on: []
supersedes: []
evidence:
  - "Wave-4 compaction replaced the eager detailed gate compendium with direct conditional packs."
next_step: "/103-sg-verify mode=excellence progressive lifecycle activation compaction wave 4"
---

# Verification Pack Index

Compatibility index only. Normal execution loads packs directly from `SKILL.md`.

| Pack | Current file | Trigger |
| --- | --- | --- |
| Baseline | `verification-baseline.md` | Every selected standard or excellence run |
| Excellence | `verification-excellence.md` | Standard readiness passed and excellence mode is explicit |
| Security, UI, runtime | `verification-security-ui-runtime.md` | Applicable security/data/UI/runtime/external proof surface |
| Coherence | `verification-coherence.md` | Documentation, closure, skill, Atlas, product, editorial, or cross-contract scope |

Pack references are leaves and never load one another.
