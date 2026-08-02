---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-flutter
owner: Diane
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems: [skills/references/operator-roles/flutter-specialist.md]
depends_on: []
supersedes: []
evidence: ["Canonical sources: Flutter documentation, breaking changes, and testing guides."]
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# Flutter Platform Note

## Sources

- https://docs.flutter.dev/
- https://docs.flutter.dev/release/breaking-changes
- https://docs.flutter.dev/testing/overview

## Decision Rules

- Preserve platform parity, responsive layout, safe areas, and keyboard/IME behavior.
- Follow the project state-management and navigation conventions.
- Keep widgets focused and avoid business logic in presentation code.
- Check current breaking changes before SDK-sensitive migrations.
- Require analyzer, tests, and device/browser proof proportional to the UI change.

## Validation

Run `flutter analyze`, focused tests, and the relevant platform build or manual flow.
