---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 102-sg-start
scope: 102-sg-start-topology
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: no
linked_systems:
  - skills/102-sg-start/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Topology detail loads only after an execution contract exists."
next_step: none
---

# Execution Topology

Use the canonical model-routing and master-delegation contracts; do not duplicate their catalogues.

Choose one runtime/model profile proportional to complexity, ambiguity, failure cost, duration, and tool needs. Per-group overrides require a material reliability or efficiency gain without reducing quality.

Independent read-only scopes run in parallel by default. Mutations use delegated sequential execution unless a ready spec already defines non-overlapping `Execution Batches`, dependency order, validation per batch, and one integration owner. Tightly coupled files remain sequential.

For each delegated group record goal, owned files or read-only scope, model/effort, validations, dependency order, and integration owner. Never assign one writable file to multiple agents. Integrate centrally, run combined validation, and retain the structured receipt with `Agents: <count> · <mode>`. If tooling cannot honor the selected topology, report degraded execution explicitly.

