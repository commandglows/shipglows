---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-08-12"
status: active
source_skill: 101-sg-ready
scope: readiness-review-playbook-compatibility-index
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/101-sg-ready/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 6 replaced the monolithic readiness workflow with direct leaf packs."
next_step: none
---

# Readiness Review Playbook — Compatibility Index

Do not load this index during execution. The activation contract directly selects:

- `readiness-baseline.md`
- `readiness-risk-review.md`
- `readiness-transition-and-report.md`

`OWASP Security Gate` remains mandatory when applicable.

In `report=user`, use this compact shape unless blocked or detail was requested:

```text
🧱 CHANTIER (spec) : [titre]
🎯 VERDICT (HH:mm) : [prêt | non prêt | bloqué]
[Résultat et décision réellement requise]
```

Use the detailed form only in `report=agent`, blocked runs, handoffs, or explicit verbose requests.
