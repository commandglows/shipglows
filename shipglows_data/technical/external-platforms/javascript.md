---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-javascript
owner: Diane
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems: [skills/references/operator-roles/javascript-specialist.md]
depends_on: []
supersedes: []
evidence: ["Canonical sources: MDN JavaScript Guide and ECMAScript specification."]
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# JavaScript Platform Note

## Sources

- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide
- https://tc39.es/ecma262/

## Decision Rules

- Respect the declared runtime, module format, and browser/server boundary.
- Handle async failures and resource cleanup explicitly.
- Avoid implicit coercion and mutation when they obscure behavior.
- Prefer platform APIs supported by the actual target runtime.
- Validate behavior with lint, tests, and the relevant runtime/build.

## Validation

Use project scripts and test runtime-visible behavior; syntax or bundling alone is insufficient for async, DOM, or network paths.
