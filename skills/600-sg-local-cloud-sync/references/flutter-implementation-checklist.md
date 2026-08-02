---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-01"
updated: "2026-06-01"
status: draft
source_skill: 600-sg-local-cloud-sync
scope: flutter-local-cloud-sync
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/600-sg-local-cloud-sync/SKILL.md
depends_on:
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from WinFlowz Flutter/Riverpod sync implementation lessons."
next_step: "/103-sg-verify shipglows_data/workflow/specs/600-sg-local-cloud-sync-skill.md"
---

# Flutter Local-Cloud Sync Checklist

## Architecture Shape

Prefer a layered contract:

- pure Dart sync models
- pure controller for decision matrix
- metadata store for account association and checksums
- queue store for pending/offline operations
- domain adapters for local and remote snapshots
- provider entrypoint for auth/entitlement/config context
- UI component for sync/save state

Avoid putting merge policy directly inside widgets or provider callbacks.

## Riverpod And Provider Entry

Check:

- auth context provider distinguishes signed-out, local fallback, signed-in, and entitlement states
- provider does not instantiate cloud adapters when provider config is unavailable
- controller can be tested without Firebase/Supabase/native plugins
- UI reads sync state through a stable provider
- refresh/retry actions are idempotent or guarded

## Store Requirements

For every local store:

- name whether it is durable across app restart
- name whether it survives uninstall
- expose a structured snapshot API
- include deleted/tombstone records when needed
- cap or page large histories intentionally
- filter sensitive content before remote write
- preserve metadata shape on write/read round trip

If a domain is in-memory only, mark it local-only until durability exists.

## Test Order

1. Pure Dart controller tests for account association, empty-cloud distinction, merge, conflict, latest-wins, tombstones, local-only domains, and metadata round trip.
2. Store tests for snapshot, tombstone, retention, queue, and sensitive filtering.
3. Provider tests for auth/config/entitlement branches.
4. Widget tests for sync/save state component.
5. Flutter Web smoke for shared UI when practical.
6. Physical device QA only for native-only behavior such as uninstall/reinstall, secure storage, OS lifecycle, IME, overlay service, or platform plugins.

## Validation Commands

Use project guardrails first. Common Flutter checks:

```bash
dart analyze <changed Dart files and focused tests>
flutter test <focused test files>
flutter analyze
flutter test
```

Do not run Android builds, Gradle, APK packaging, or device install commands when project guardrails forbid them. Route those checks to CI or physical-device QA.

## Common Failure Patterns

- switching store namespaces on sign-in and making local data disappear
- claiming cloud sync after only local save
- wrapping metadata on write but reading the wrong shape
- missing provider entrypoint for the controller
- using latest-wins without trustworthy metadata
- syncing secrets because it is convenient
- forgetting tombstones for deletes
- treating sign-up empty cloud and existing-account empty cloud as the same state
- not proving reinstall/relogin on a real device when native storage behavior matters
