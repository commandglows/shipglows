---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-02"
updated: "2026-09-02"
status: active
source_skill: 001-sg-build
scope: flutter-app-zoom
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - email-sidebar-app/packages/shipglows_flutter_zoom
depends_on: []
supersedes: []
evidence:
  - "The email-sidebar-app pilot proves zoom, reset, ordinary scrolling, scale events, and a filled viewport."
next_review: "2027-03-02"
next_step: "Adopt the pinned package in the next Flutter application that requests app-wide zoom."
---

# Flutter App Zoom

Use the focused `shipglows_flutter_zoom` package when a Flutter web or desktop
application needs app-wide Ctrl/Command+mouse-wheel zoom. Do not copy the
pointer-signal or viewport-compensation implementation into each application.

Pin the validated baseline commit `2b8b751` from
`commandglows/email-sidebar-app` and the package path
`packages/shipglows_flutter_zoom`. Wrap the application surface in
`FlutterZoomViewport`; configure only the product-owned minimum, maximum,
initial value, step, reset shortcuts, and optional change callback.

Required adoption proof covers modified scroll, browser scale signals,
Ctrl/Command+0 reset, ordinary scrolling, unchanged viewport dimensions,
responsive layout, editable controls, supported themes, and the application's
managed Flutter target. Persisting the zoom level is host-owned and optional.

Create a rollout playbook only when several existing applications are approved
for one coordinated migration. The package remains the behavior source of
truth; a playbook never duplicates its implementation.
