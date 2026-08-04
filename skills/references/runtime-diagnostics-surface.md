---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-06-11"
updated: "2026-08-03"
status: active
source_skill: 009-sg-skill-build
scope: runtime-diagnostics-surface
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/sentry-observability.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/305-sg-init/SKILL.md
  - skills/010-sg-technical/SKILL.md
depends_on:
  - skills/references/sentry-observability.md
supersedes: []
evidence:
  - "Operator directive 2026-06-11: all runtime apps should expose a diagnostics screen/panel with a Copy action."
  - "Operator directive 2026-06-11: agents should favor reusing an existing project diagnostic component/pattern before inventing a new one."
  - "2026-08-03: dependent skill links now target activation contracts rather than obsolete monolithic audit/bootstrap procedures."
next_review: "2026-06-25"
next_step: "/103-sg-verify runtime diagnostics surface adoption"
---

# Runtime Diagnostics Surface

Use this reference when creating, auditing, fixing, testing, or verifying a runtime application.

## Contract

Every runtime app should expose a safe user/operator diagnostic surface unless a static-site exception is documented in `sentry-observability.md`.

Preferred surfaces:

- settings/support panel
- error boundary fallback
- debug drawer/modal
- auth callback error page
- native overflow/debug menu for mobile shells

The surface must include a visible copy action named like `Copy diagnostics`, `Copy logs`, `Copier le diagnostic`, or equivalent local UI copy.

Copied text must start with:

```text
commit/build: <sha or build id>
build_at_paris: YYYY-MM-DD HH:mm Europe/Paris
build_at_utc: YYYY-MM-DD HH:mm UTC
```

Useful payload after the header: app version, environment, route/screen, timestamp, platform, Sentry status/event id when visible, and redacted recent logs. Do not include secrets, cookies, tokens, auth codes, raw headers, private text, private URLs, or PII.

## Reuse Rule

Before adding a new surface, search the project for existing diagnostics/copy patterns:

```bash
rg -n "Copy diagnostics|Copy logs|Copier.*diagnostic|buildIdentityHeader|buildDiagnosticsReport|diagnosticSummary|navigator.clipboard|Clipboard.setData"
```

Reuse the local component/helper when present. If none exists, add the smallest native pattern for the stack.

## Minimal Patterns

Flutter/Dart:

```dart
List<String> buildIdentityHeader() => <String>[
  'commit/build: $buildId',
  'build_at_paris: $buildAtParis',
  'build_at_utc: $buildAtUtc',
];

Future<void> copyDiagnostics(BuildContext context) async {
  final report = <String>[
    ...buildIdentityHeader(),
    'App diagnostics',
    'route: ${ModalRoute.of(context)?.settings.name ?? 'unknown'}',
  ].join('\n');
  await Clipboard.setData(ClipboardData(text: report));
}
```

Vue/Tauri/Web:

```ts
export function buildIdentityHeader(): string[] {
  return [
    `commit/build: ${__BUILD_ID__ || __GIT_COMMIT__ || "unknown"}`,
    `build_at_paris: ${__BUILD_AT_PARIS__ || "unknown"}`,
    `build_at_utc: ${__BUILD_AT_UTC__ || "unknown"}`,
  ];
}

export function buildDiagnosticsReport(): string {
  return [
    ...buildIdentityHeader(),
    "App diagnostics",
    `url: ${window.location.href}`,
    `user_agent: ${navigator.userAgent}`,
  ].join("\n");
}
```

Use Vite/CI/Dart defines or the platform build system to inject `BUILD_ID`, `BUILD_AT_PARIS`, and `BUILD_AT_UTC`. Do not compute build time only at copy time unless the native platform has no build metadata path yet; in that fallback, label the evidence as runtime-generated.

## Audit And Verification

Audits should report a missing runtime diagnostic surface as a reliability finding, not as cosmetic polish.

Browser-capable skills should use this surface autonomously. If the agent can safely navigate the runtime app with Playwright, another browser tool, or an app-visible debug surface, it should open the diagnostics/settings/support area and use the copy action when useful before asking the operator for logs.

Verification should be `partial` or `not verified` for runtime apps when:

- no diagnostics/log-copy surface exists,
- the copy action exists but omits the build identity header,
- copied diagnostics expose secrets or private user data,
- the implementation hardcodes stale build metadata instead of deriving it from build/CI inputs.
