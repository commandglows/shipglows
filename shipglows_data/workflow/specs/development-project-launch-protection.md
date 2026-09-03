---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-03"
updated: "2026-09-03"
status: ready
source_skill: sg-development
source_model: GPT-5
scope: development-project-launch-protection
owner: Diane
user_story: "En tant qu'opératrice, je veux qu'un projet Dev exposé publiquement rappelle sa protection de lancement et l'état réel de sa collecte email."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/project-delivery-policy.md
  - tools/project_delivery_policy.py
  - templates/launch_protection.md
depends_on: []
supersedes: []
evidence:
  - "Operator approval 2026-09-03: Dev status keeps a launch-protection reference and holding pages may collect launch-notification emails."
next_review: "2026-10-03"
next_step: "Use the projection in the next project-status UI consumer."
---

# Development Project Launch Protection

## Contract

`delivery_posture` remains the sole Dev/Live business status. A Dev project
gets a visible launch-protection review requirement. A separate operational
record identifies the holding page, public URL, email-capture state, provider,
proof and release condition without copying a long handoff into the status.

Email capture distinguishes `inactive`, `configured` and `verified`.
`configured` means implemented but not proven on the hosted surface.

## Acceptance Criteria

- `development` reports `Dev` and requests a protection review.
- Live postures report `Live`.
- Missing or invalid protection data remains visible.
- A holding page exposes a compact reference and email state.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-09-03 | sg-development | GPT-5 | Formalized and implemented the approved projection with focused contract proof. | verified | Use it in the next status UI consumer. |
