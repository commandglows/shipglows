---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 101-sg-ready
scope: readiness-risk-review
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/101-sg-ready/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 6 extracted conditional adversarial and security review."
next_step: none
---

# Readiness Risk Review

## Adversarial review

Try to produce a plausible implementation that violates the user story, failure semantics, permissions, data integrity, adjacent systems, docs, product coherence, design authority, or proof. Check invalid/missing identifiers, duplicates, retries, concurrency, stale state, partial failures, dependency outages, step skipping, replay, bypasses, and silent success/failure proportionally.

## Product and platform

For material product work, reconcile touched business/product/GTM/brand/UX/architecture/Atlas/proof contracts. Conflicts and material orphans block; gaps require one scoped decision or owned task. Greenfield work declares launch/roadmap surfaces and applies compatible preferred stacks before blueprint or uncovered provider choices.

## Security and data

Identify assets, actors, trust boundaries, auth/authz/tenant/data flows, inputs/outputs, secrets, logs, third parties, and abuse cases. Require least privilege, server-side enforcement, validation, safe failure, idempotency/rollback where relevant, redaction, dependency/provenance controls, and concrete proof.

The `OWASP Security Gate` maps applicable Top 10:2025 categories and selected versioned ASVS requirements, or records justified `not applicable`; it names proof, residual gaps, and owner routes. A material blind spot is `not ready`.

## Freshness and authority

External behavior needs current official/primary evidence. UI needs canonical design authority. Atlas Gold/Diamond or unknown mapped impact needs exact authorization/mapping work. Do not accept local UI controls as security boundaries.
