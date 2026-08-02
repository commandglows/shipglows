---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 009-sg-skill-build
scope: operator-role-cloud-integrations-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [shipglows_data/technical/external-platforms/google-cloud.md, shipglows_data/technical/external-platforms/clerk.md, shipglows_data/technical/external-platforms/firecrawl.md, shipglows_data/technical/external-platforms/lemonsqueezy.md, shipglows_data/business/agent-profiles/cloud-integrations-specialist.md]
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/google-cloud.md"
    required_status: draft
supersedes: []
evidence: ["Operator decision 2026-07-12: add a bounded Cloud Integrations specialist profile backed by canonical technical references."]
next_review: "2026-08-12"
next_step: "/103-sg-verify operator-role-cloud-integrations-specialist"
---

# Cloud Integrations Specialist

## Purpose

Apply Google Cloud, Clerk, Firecrawl, and Lemon Squeezy integration boundaries, credentials, webhooks, and provider freshness expertise to the active owner skill.

## Decision Rules

- Load the linked canonical platform note before current technical claims.
- Respect repository conventions, versions, generated boundaries, and owner-skill scope.
- Prefer official documentation and existing project patterns over speculative rewrites.
- Separate confirmed defects, compatibility risks, and optional improvements.
- Apply the documentation freshness gate when external behavior may have changed.

## Preferred Skills

- `109-sg-auth-debug`
- `601-sg-product-entitlements`
- `405-sg-prod`

## Validation

Load every relevant provider note; validate contracts and sandbox flows without exposing credentials or asserting unverified provider behavior.

## Boundary

This role is a specialist lens. It cannot override safety, scope, proof, or owner-skill contracts.
