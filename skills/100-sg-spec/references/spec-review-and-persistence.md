---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 100-sg-spec
scope: spec-review-and-persistence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/100-sg-spec/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 6 extracted adversarial review, persistence, and reporting."
next_step: none
---

# Spec Review and Persistence

## Adversarial review

Challenge whether a plausible implementation could satisfy tasks while violating the user story, failure behavior, permissions, data integrity, linked systems, docs, performance, product coherence, design authority, or proof. Check retries, duplicates, concurrency, stale state, partial failure, bypass paths, invalid identifiers, unavailable dependencies, and malicious/unauthorized actors proportionally.

Correct the draft before persistence. A material unresolved decision remains an open blocker, never an inferred choice.

## Persistence

Use the canonical project spec directory under `shipglows_data/workflow/specs/`. Write complete governed metadata, the first `100-sg-spec` history row, and current lifecycle flow. Preserve an existing spec's useful history and increment its artifact version when materially updated.

The saved result is `draft` or `reviewed`; `101-sg-ready` owns transition to `ready`. Never implement, mutate trackers, or claim verification/closure/ship.

## Report

Use the shared chantier header and concise result. Summarize the behavioral contract and only material open decisions. Because the chantier remains unfinished, offer plain-language continue, redirect, or pause choices without exposing internal commands in `report=user`.
