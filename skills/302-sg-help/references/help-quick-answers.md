---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-10-30"
status: active
source_skill: 302-sg-help
scope: help-quick-answers
owner: Diane
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems: [skills/302-sg-help/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Quick answers extracted from help catalogue."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Help — Quick Answers

First-person current arrival on a new device/host, e.g. « je viens d'arriver sur un
nouvel ordi », also routes to `shipglows init` when no more specific task is requested.
Questions, quotes, project/repository onboarding and concrete app/bug work keep their
own routes; a new staging/backend or Python virtual environment is not a new host.

Too many tasks → priorities then backlog defer. Unknown next step → priorities blockers. New idea mid-work → backlog. Before release → deploy. Outdated dependencies → technical deps; framework upgrade → technical migrate. New project governance → `sg-docs init`. New computer/phone/tablet/VM or durable root/agent context → `shipglows init [context|agents|memory|resume]` through `skills/references/workstation-initialization.md`; optional role/lifetime choices adapt the journey, and `resume` re-observes pending work. Context refresh only → `shipglows context`. Research → research. For questions about rules, profiles, private data, questions, or reference discovery, load the corresponding canonical shared reference rather than paraphrasing it.
