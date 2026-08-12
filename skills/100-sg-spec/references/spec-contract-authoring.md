---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 100-sg-spec
scope: spec-contract-authoring
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
  - "Wave 6 extracted the autonomous contract authoring schema."
next_step: none
---

# Spec Contract Authoring

Write the canonical metadata plus these sections: `Title`, `Status`, `User Story`, `Minimal Behavior Contract`, `Success Behavior`, `Error Behavior`, `Problem`, `Solution`, `Scope In`, `Scope Out`, `Constraints`, `Test Contract`, `Dependencies`, `Invariants`, `Links & Consequences`, `Documentation Coherence`, `Edge Cases`, `Implementation Tasks`, `Acceptance Criteria`, `Test Strategy`, `Risks`, `Execution Notes`, `Open Questions`, `Skill Run History`, and `Current Chantier Flow`.

## Behavioral core

The minimal behavior paragraph states trigger/input, observable result, failure behavior, and the easiest missed edge case without implementation detail. Success and failure each name observable user/operator and system states plus proof.

## Tasks and acceptance

Each ordered task names target, explicit action, user-story link, dependency, exact validation, and constraints. Acceptance criteria cover success, failure, boundaries, integrations, misuse/abuse where relevant, and compact proportional `ZOMBIES coverage`.

## Proof and consequences

The `Test Contract` declares surface/profile, automated proof, browser/auth/integration/provider/manual proof order, checklist path/required rows when applicable, and explicit exceptions. `Links & Consequences` names upstream/downstream consumers and revalidation. Documentation coherence names impacted artifacts or `None, because ...`.

## Risk gates

Record trust boundaries, authorized/unauthorized actors, data/tenant/auth rules, misuse cases, rollback/retry/idempotency, sensitive logging/redaction, and residual risk where relevant. Internet-facing/privileged work includes an `OWASP Security Gate` with applicable Top 10/ASVS mapping and proof. UI, Atlas, product, runtime, analytics, public-claim, and external-doc authorities remain explicit.

No `TBD`, vague verbs without proof, hidden conversation dependencies, or optimistic readiness claims.
