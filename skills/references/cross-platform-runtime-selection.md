---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-11"
updated: "2026-08-11"
status: active
source_skill: 900-shipglows-core
scope: cross-platform-runtime-selection
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/references/identity-provider-selection.md
  - skills/references/backend-data-provider-selection.md
depends_on: []
supersedes: []
evidence:
  - "Official Flutter documentation reviewed 2026-08-11: Android, iOS, Web, Windows, macOS, and Linux."
  - "Official firebase_auth listing reviewed 2026-08-11: Android, iOS, macOS, Web, and Windows; Linux is not listed."
  - "Official Tauri documentation reviewed 2026-08-11: desktop and mobile."
  - "Official Expo documentation reviewed 2026-08-11: Android, iOS, and Web."
  - "Official .NET MAUI documentation reviewed 2026-08-11: Android, iOS, macOS, and Windows; not Web or Linux."
  - "Operator decision 2026-08-11: Flutter is universal; Rust is only a justified native engine."
next_review: "2026-09-11"
next_step: "Refresh platform support before the next runtime commitment."
---

# Cross-Platform Runtime Selection

## Current matrix - reviewed 2026-08-11

| Runtime | Official footprint | Decision |
| --- | --- | --- |
| Flutter | Android, iOS, Web, Windows, macOS, Linux | Canonical universal application shell |
| Tauri | Desktop and mobile with web frontend and Rust host | Native exception, not the universal default |
| Expo | Android, iOS, Web | Does not cover the native desktop footprint |
| .NET MAUI | Android, iOS, macOS, Windows | Does not cover Web or Linux |

## Canonical decision

1. Astro owns public SEO surfaces.
2. Flutter owns Web, Android, iOS, Windows, macOS, and Linux application surfaces.
3. Firebase Auth owns identity; Linux uses REST/OIDC because `firebase_auth` does not list Linux.
4. Convex HTTP owns data and authoritative functions.
5. Rust is added only for a measured native-engine requirement behind a typed Flutter boundary.

## Official sources to refresh

- [Flutter supported platforms](https://docs.flutter.dev/reference/supported-platforms)
- [`firebase_auth`](https://pub.dev/packages/firebase_auth)
- [Tauri](https://tauri.app/)
- [Expo](https://docs.expo.dev/)
- [.NET MAUI](https://learn.microsoft.com/dotnet/maui/supported-platforms)
