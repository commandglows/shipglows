---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 900-shipglows-core
scope: core-packaging
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 9 extracted public/internal packaging mechanics."
next_step: none
---

# Core Packaging

Keep the public plugin independent from a maintainer's private runtime. Validate public bundle contents, canonical entrypoint, sparse-bootstrap assumptions, registry routes, and runtime links before packaging.

Sparse bootstrap requires explicit approval because it downloads source and changes local state. Never package secrets, private transcripts/customer context, dependency directories, caches, generated artifacts, or machine-specific paths. Never publish the internal core engine or revive the deprecated pilot as canonical.
