---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 109-sg-auth-debug
scope: auth-browser-proof
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/109-sg-auth-debug/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from the auth-debug workflow during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify auth browser proof"
---

# Auth Browser Proof

Before any Playwright MCP call, load shared `playwright-mcp-runtime.md` and local `playwright-auth.md`. Apply their executable-path/runtime preflight. A stale or invalid runtime is `blocked`; do not substitute theoretical code inspection for browser proof.

Use the authority-approved target. Preview-required work needs the URL confirmed by `405-sg-prod`; if the latest relevant push/deploy is unconfirmed, stop with that next step. Do not use localhost as final evidence for hosted callbacks, OAuth domains, deployed environment, edge/serverless middleware, or secure-cookie behavior.

Capture the smallest redacted proof set: starting URL, triggering action, redirect/final URL with sensitive query values removed, final page/state, visible error, and only relevant console/network status. Never capture or paste raw cookies, authorization headers, tokens, OAuth codes/state, credentials, OTPs, private payloads, raw HAR, or sensitive Sentry breadcrumbs.

Recommended sequence: open target, snapshot, trigger auth, await navigation/state, snapshot arrival, then inspect only relevant console/network evidence. If a human step is necessary, navigate to the safe boundary, state the exact action only the user can perform, and resume observation afterward.

Use visible diagnostics/copy-log UI before requesting operator evidence; verify its commit/build and Paris/UTC build-time header. When an error ID, 5xx, error boundary, or Sentry signal exists, load shared `sentry-observability.md` and correlate only redacted evidence to the same flow/environment. For local PM2 without a usable Sentry pointer, use redacted PM2 and Doppler checks under that doctrine.

Name the exact failure: missing/inactive trigger, rejected popup, wrong external redirect, callback error, return to sign-in, lost session, or protected backend rejection. If automation stops at MFA/CAPTCHA/device approval/magic-link/WebAuthn, retain evidence up to that boundary and return `partial` or `blocked`.
