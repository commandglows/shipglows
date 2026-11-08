---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.3.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-11-08"
status: draft
source_skill: sg-docs
scope: external-platform-sentry
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/references/sentry-observability.md
  - skills/405-sg-prod/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Sentry JavaScript environment, source map/debug ID, releases, data collection, and Monitors & Alerts docs/changelog."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Sentry Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Sentry-related freshness checks. Use it before relying on assumptions about SDK setup, environments, releases, source maps, Debug IDs, issue/event evidence, alerts, monitors, Session Replay, PII scrubbing, or production incident proof.

It does not replace Sentry documentation. It records the source map and ShipGlows rules agents should use before changing observability code, deploy proof, release correlation, or project-local Sentry usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| JavaScript SDK environment option | https://docs.sentry.io/platforms/javascript/configuration/environments/ |
| Debug IDs and source map association | https://docs.sentry.io/platforms/javascript/guides/ember/sourcemaps/troubleshooting_js/debug-ids |
| Release API | https://docs.sentry.io/api/releases/create-a-new-release-for-an-organization/ |
| JavaScript data collected / PII considerations | https://docs.sentry.io/platforms/javascript/guides/remix/data-management/data-collected |
| Monitors & Alerts API | https://docs.sentry.io/api/monitors/ |
| Monitors & Alerts changelog | https://sentry.io/changelog/monitors--alerts--now-generally-available/ |
| JavaScript docs index for agents | https://sentrydocs.dev/llms.txt |

Freshness evidence on 2026-05-24:

- Sentry JavaScript environment docs state environments identify where an error occurred and are case-sensitive with naming constraints.
- Sentry Debug ID docs describe Debug IDs as the recommended reliable way to associate minified JavaScript with source maps, using Sentry CLI or bundler plugins.
- Sentry release API docs describe releases as useful for correlating first-seen events with the release that introduced them and for source maps/debug features requiring manual upload.
- JavaScript data-collection docs describe default privacy behavior and note that query strings, breadcrumbs, request data, Session Replay, and console messages may contain PII depending on configuration.
- Sentry changelog announced Monitors & Alerts as generally available, with alert routing separated from monitor configuration.

## Freshness Gate Use

Use `fresh-docs checked` for Sentry decisions only after checking relevant Sentry docs and local project instrumentation/deploy evidence.

Use `fresh-docs gap` when:

- Runtime proof depends on Sentry but no issue/event/release/environment pointer is available.
- Source maps, Debug IDs, releases, or build upload config are changed without checking current Sentry docs and local CI secrets.
- Monitoring/alerting changes rely on deprecated Issue Alert/Metric Alert assumptions instead of current Monitors & Alerts behavior.
- A project uses Sentry but lacks `shipglows_data/technical/platforms/sentry.md`.

Use `fresh-docs conflict` when current Sentry docs contradict local docs, alert assumptions, release assumptions, or planned instrumentation.

## ShipGlows Decision Rules

- Sentry evidence is a pointer, not raw payload material. Reports should reference redacted issue/event/release/environment facts, not paste sensitive telemetry.
- Configure environment and release/dist/build identity consistently so preview/prod incidents can be correlated.
- For JavaScript, prefer modern source map/Debug ID upload through official Sentry tooling or bundler integration when available.
- Keep Sentry auth tokens in CI/secret managers only. Do not commit `.env.sentry-build-plugin` or equivalent.
- Treat Session Replay, breadcrumbs, console logs, query strings, request bodies, headers, and tags as PII leak surfaces.
- Monitors own detection; Alerts own routing. Do not conflate monitor configuration with notification routing.
- Missing Sentry evidence is a proof gap, not proof of no runtime error.

## Suite Standard (2026-11-07, production only since 2026-11-08)

Organization `diane-defores`, region `https://de.sentry.io`, team `diane-defores`, one project per surface named `<project>-<surface>`. Errors only: no tracing, replay, screenshots or user data.

**Production only.** No agent reacts to Sentry in real time, so dev errors serve no one and only consume the event budget. Every surface sends nothing outside production (decision of Diane, 2026-11-08).

| Surface | Integration | Sends only when |
| --- | --- | --- |
| Astro site | `@sentry/astro` integration, `sentry.client.config.ts` at the site root; `sentry.server.config.ts` when an adapter serves pages | `enabled: import.meta.env.PROD` in `Sentry.init` |
| Flutter app | `sentry_flutter`, `initSentry()` called after the app's own error handlers, no `appRunner` so no zone is added | `initSentry()` returns early unless `kReleaseMode`; environment from `SENTRY_ENVIRONMENT`, otherwise `production` |
| Flutter app wired through Doppler (CommandGlows, NoCocaïne, ReplayGlows, ContentGlows) | `SENTRY_DSN` dart define | the managed dev recipe (`flutter_config.py` / `shipglows_flutter_config.py`, `.shipglows.flutter.json`) never forwards it, and Doppler `dev` no longer holds it; only `prd` and release lanes pass it. CommandGlows still requires it with `--release`; ContentGlows forwards it only from `--build --mode release` |
| Browser extension | dependency-free `sentry-report` script in the service worker and popup, never the SDK and never in content scripts | the manifest has an `update_url` (store install); an unpacked load sends nothing |
| Node service | `@sentry/node`, imported first | `enabled: NODE_ENV === "production"`; the ShipGlows runner also reads `SENTRY_ENABLED`, `false` in Doppler `shipglows_app/dev`, untouched in `prd_runner` |

- New client surfaces keep the public DSN in code; the production gate above, not the DSN, decides whether a build reports. Apps wired earlier read `SENTRY_DSN` from Doppler `prd` or their release lane.
- A distributed agent-worker must run with `NODE_ENV=production` to report.
- Budget guards: the production-only gate is the only per-surface guard. A rate limit per DSN key is not available on the current `diane-defores` plan (Business/Enterprise only: `update_dsn` and the API return 200 but `rateLimit` stays null, tested 2026-11-08 on `beatglows-app`). Spike Protection is on for every project (confirmed by Diane).
- A site with a Content-Security-Policy must list `https://*.ingest.de.sentry.io` in `connect-src`.
- A site or app that promises no data leaves the device must disclose Sentry in its privacy page before reporting (DreamGlows on 2026-11-07, Claiire on 2026-11-08).
- Convex backends use the native exception reporting integration, Pro plan only, configured per deployment in the dashboard; it sends the Convex `tokenIdentifier` as the Sentry user.

## Common Project-Local Fields

A project using Sentry should maintain `<governance-root>/shipglows_data/technical/platforms/sentry.md` with:

- Sentry project/org slug, if safe
- SDK/framework and package versions
- DSN env var name, never secret values
- environment/release/dist naming policy
- source map/Debug ID upload route and CI secret names
- replay, breadcrumbs, logs, PII scrubbing, and sampling policy
- monitor/alert ownership
- issue/event evidence route for `sg-prod`, `sg-fix`, and `sg-verify`

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store Sentry auth tokens, raw event payloads, breadcrumbs, replay contents, headers, cookies, auth codes, private URLs, or PII in ShipGlows docs.
- Treat Sentry DSNs as public-ish project identifiers, not auth secrets, but avoid publishing them unnecessarily.
- Before enabling richer telemetry, verify scrubbing and sampling.
- Source maps should support debugging without exposing source maps publicly after upload unless the project explicitly accepts that risk.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/sentry.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/sentry.md
```

## Reader Checklist

- `Sentry.init`, `SENTRY_`, source map upload, replay, breadcrumbs, monitor, alert, issue ID, or event ID found -> check for project-local Sentry usage note.
- Runtime failure/debug task -> ask for or locate redacted Sentry issue/event/release/environment evidence.
- Build/deploy pipeline changed -> verify release/source map/Debug ID upload.
- Observability policy changed -> verify PII, replay, breadcrumbs, and alert routing.

## Maintenance Rule

Update this note when Sentry SDK, environment/release, source map/Debug ID, data collection, Replay, Monitors & Alerts, or ShipGlows incident-proof rules change.
