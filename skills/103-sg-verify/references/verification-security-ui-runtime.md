---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-30"
status: active
source_skill: 103-sg-verify
scope: 103-sg-verify-security-ui-runtime
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/103-sg-verify/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-30: Flutter verification starts on the registry-backed live development target; standalone builds remain package-sensitive checkpoints."
  - "Security, UI, and runtime proof gates extracted from the former monolithic verification contract."
next_step: "/103-sg-verify progressive lifecycle activation compaction wave 4"
---

# Security, UI, And Runtime Verification

Use only for an applicable surface. The activation contract supplies selected shared contracts directly.

## Security And Data

Map the actual internet-facing or privileged surface to relevant OWASP Top 10:2025 risks and ASVS v5.0.0 requirements. Verify authorization/resource/tenant boundaries, input and exceptional-condition handling, integrity, secrets/logging, and residual gaps. One scan never proves complete coverage. Unproven critical security/data/workflow behavior blocks.

## UI And Design System

Confirm UI, IME, keyboard, overlay, responsive, spacing, typography, color, motion, target size, layout, and components use the canonical token/theme/component/measurement authority. Any literal must be named, scoped, platform-bound, and proven. Run the changed-file drift check or accept equivalent specialist evidence; unresolved drift prevents clean verification.

Visual success requires rendered human evidence when the contract demands it. Static checks, HTTP success, or source inspection cannot prove visual resolution.

## Flutter Proof Ladder

Use widget/unit tests first, then the managed live `flutter run` session on the registry-backed active development target. Use Flutter Web smoke (`108-sg-browser` for non-auth, `109-sg-auth-debug` for auth) when browser behavior is relevant, not as a substitute for the selected native target. APK/AAB or standalone Windows builds are release/package checkpoints for risks that depend on installation, packaging, native plugins/DLLs, production mode, performance, or startup without Flutter attached. IME, permissions, overlays, notifications, services, native plugins/channels, pickers, camera/mic, storage, installation, and device performance remain target-scoped. Skipping practical live-target evidence without a concrete exception yields `partial` or `not verified`.

## Runtime And External Proof

Verify safe Sentry/observability, diagnostics or log-copy, and commit/build plus Paris/UTC build header when applicable; static sites may document a valid exception. Reuse the project diagnostic helper/surface or justify a bounded addition. Gather safe local/browser/app/log evidence before asking the operator. Requests to the operator are limited to decisions, secrets, inaccessible environments, manual/device-only proof, or unsafe external side effects.

Hosted, production, provider, browser, auth, and manual evidence must identify scenario and target/environment. Missing target starts discovery rather than a readiness claim.
