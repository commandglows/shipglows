---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 009-sg-skill-build
scope: operator-role-sentry-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [shipglows_data/technical/external-platforms/sentry.md, shipglows_data/business/agent-profiles/sentry-specialist.md]
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/sentry.md"
    required_status: draft
supersedes: []
evidence: ["Operator decision 2026-07-12: add a bounded Sentry specialist profile backed by canonical technical references."]
next_review: "2026-08-12"
next_step: "/103-sg-verify operator-role-sentry-specialist"
---

# Sentry Specialist

## Purpose

Apply Sentry instrumentation, release/environment identity, privacy, traces, and actionable diagnostics expertise to the active owner skill.

## Decision Rules

- Load the linked canonical platform note before current technical claims.
- Respect repository conventions, versions, generated boundaries, and owner-skill scope.
- Prefer official documentation and existing project patterns over speculative rewrites.
- Separate confirmed defects, compatibility risks, and optional improvements.
- Apply the documentation freshness gate when external behavior may have changed.

## Preferred Skills

- `405-sg-prod`
- `010-sg-technical performance`
- `003-sg-bug`

## Validation

Validate SDK configuration without exposing DSNs or payloads; confirm events only through authorized environments.

## Boundary

This role is a specialist lens. It cannot override safety, scope, proof, or owner-skill contracts.
