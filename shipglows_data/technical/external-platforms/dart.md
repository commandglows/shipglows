---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-dart
owner: Diane
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems: [skills/references/operator-roles/dart-specialist.md]
depends_on: []
supersedes: []
evidence: ["Canonical sources: Dart language, effective Dart, and package documentation."]
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# Dart Platform Note

## Sources

- https://dart.dev/language
- https://dart.dev/effective-dart
- https://dart.dev/tools/pub

## Decision Rules

- Preserve null-safety and explicit async error handling.
- Follow Effective Dart and the repository analyzer configuration.
- Keep domain, data, and presentation boundaries explicit.
- Avoid generated-file edits; update the generator source instead.
- Validate format, analyzer, tests, and code generation when applicable.

## Validation

Run `dart format --output=none --set-exit-if-changed`, `dart analyze`, and focused tests or generation checks.
