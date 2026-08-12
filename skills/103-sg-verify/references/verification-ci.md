---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 103-sg-verify
scope: 103-sg-verify-ci
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems: [skills/103-sg-verify/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Wave 17 moved conditional workflow checks from the mandatory baseline."]
next_step: "/103-sg-verify progressive lifecycle activation compaction wave 17"
---

# Verification CI

Load directly when CI or workflows are in scope. This leaf loads no sibling.

Confirm path filters run owned jobs, unrelated expensive jobs skip, manual dispatch remains available, and branch protection does not require routinely skipped jobs without an umbrella status. Run relevant lint, typecheck, and tests; a failure is critical. Without a local workflow report `not assessed` and name the responsible repository when known.
