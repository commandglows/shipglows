---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-08-24"
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
evidence:
  - "Canonical sources: Flutter documentation, breaking changes, and testing guides."
  - "Flutter 3.47.1 dependency checks set the supported Android floors to Gradle 8.14.0, AGP 8.11.1, and KGP 2.2.20 while warning below the AGP 9 transition target."
  - "Flutter issue 189383 and pull request 188716 document the AGP 9 transition and explicitly validate AGP 8.11.1 with Gradle 8.14."
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# Flutter Platform Note

## Sources

- https://docs.flutter.dev/
- https://docs.flutter.dev/release/breaking-changes
- https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin
- https://docs.flutter.dev/testing/overview
- https://github.com/flutter/flutter/blob/3.47.1/packages/flutter_tools/gradle/src/main/kotlin/DependencyVersionChecker.kt
- https://github.com/flutter/flutter/issues/189383
- https://github.com/flutter/flutter/pull/188716
- https://github.com/flutter/flutter/issues/181557

## Flutter 3.47 Android Compatibility Decision

- Flutter 3.47.1 accepts Gradle 8.14.0, AGP 8.11.1, and KGP 2.2.20 as inclusive minimum versions. A project on exactly AGP 8.11.1 and Gradle 8.14 is supported, but it sits on the lower boundary and receives upgrade warnings toward Gradle 9.1 and AGP 9.0.1.
- Flutter 3.47 prepares the AGP 9 transition. AGP 9 introduces built-in Kotlin and can conflict with projects or plugins that still apply `kotlin-android`; full AGP 9 support remains tracked upstream.
- Do not describe AGP 8.11.1 plus Gradle 8.14 as incompatible with Flutter 3.47 without a failing Android build. Describe it as the minimum supported compatibility boundary and preserve the project pin until the AGP 9 migration is explicitly implemented and proved.
- Keep Android toolchain compatibility separate from Windows execution trust. A Windows Application Control refusal to load unsigned Dart binaries is not evidence of an AGP or Gradle failure.
- Recheck the exact Flutter source and current migration guidance before changing the managed baseline because these thresholds are version-specific.

## Decision Rules

- Preserve platform parity, responsive layout, safe areas, and keyboard/IME behavior.
- Follow the project state-management and navigation conventions.
- Keep widgets focused and avoid business logic in presentation code.
- Check current breaking changes before SDK-sensitive migrations.
- Require analyzer, tests, and device/browser proof proportional to the UI change.

## Validation

Run `flutter analyze`, focused tests, and the relevant platform build or manual flow.
