---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-typescript
owner: Diane
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems: [skills/references/operator-roles/typescript-specialist.md]
depends_on: []
supersedes: []
evidence: ["Canonical sources: TypeScript Handbook, TSConfig Reference, and release notes."]
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# TypeScript Platform Note

## Sources

- https://www.typescriptlang.org/docs/handbook/intro.html
- https://www.typescriptlang.org/tsconfig/
- https://www.typescriptlang.org/docs/handbook/release-notes/overview.html

## Decision Rules

- Respect the project `tsconfig` and framework build contract.
- Prefer explicit domain types and narrowing over unsafe assertions.
- Treat generated types and provider SDK types as owned boundaries.
- Run the project typecheck; transpilation alone is not type proof.
- Check current release notes before relying on recently introduced syntax or compiler behavior.

## Validation

Use the project package manager and declared typecheck/build scripts. Add focused tests when runtime behavior is not proven by types.
