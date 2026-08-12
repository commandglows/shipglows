---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: shipglows
created: "2026-06-10"
updated: "2026-08-12"
status: active
source_skill: 001-sg-build
scope: build-early-route
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "BUILD-EARLY-REROUTE selects ownership before greenfield or delivery packs."
next_step: none
---

# Build Lifecycle Early Route

Gather the project root, request, branch/status, task sources, and canonical spec locations. Validate explicit invocation preflight when invoked by name.

Search active specs before creating one. Compare user story, expected result, linked systems, affected surfaces, and current flow. Continue one match; ask when several plausibly own the outcome; create a spec only for a genuinely new promise.

`BUILD-EARLY-REROUTE`: route existing-project upkeep to `002-sg-maintain`, one defect loop to `003-sg-bug`, settled implementation awaiting release proof to `004-sg-deploy`, and direct evidence to its proof owner. Stop this build route before loading greenfield/readiness/delivery detail.

Otherwise classify the product change as existing-product or greenfield and continue from the matching direct pack named in `SKILL.md`. A named operator profile may affect sequencing but never bypass readiness, proof, closure, or ship authority.

User mode must remain outcome-facing. Ne jamais exposer une commande, un skill, un agent, un flux, un chemin de spec ou une étape interne. Agent mode may include route, topology, evidence, risks, and lifecycle trace.
