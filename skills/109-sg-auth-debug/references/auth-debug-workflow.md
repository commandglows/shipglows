---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 109-sg-auth-debug
scope: 109-sg-auth-debug-auth-debug-workflow
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/109-sg-auth-debug/SKILL.md
  - skills/109-sg-auth-debug/references/
depends_on: []
supersedes: []
evidence:
  - "Wave 16 replaced the historical monolith with a compact first-decision core and direct conditional leaves."
next_review: "2026-09-12"
next_step: "/103-sg-verify 109-sg-auth-debug compaction"
---

# Auth Debug Workflow

## Purpose

Compact first-decision core for auth, OAuth, cookie, session, callback, tenant, provider, and protected-route diagnosis. The activation body remains authoritative for ownership, safety, stops, and shared loaders.

## First Decision

1. Consume the existing spec, bug report, arguments, current diff, and only then the minimum code needed. Record actor, environment, development mode, start URL/flow, provider, observed result, and expected result.
2. Classify the proof surface using `project-development-mode.md`. Local is authoritative only for a local flow. Hosted OAuth, callback, secure-cookie, deployed-env, edge/serverless, or domain behavior requires the confirmed preview/production route.
3. Choose exactly the direct leaf or provider reference needed for the next action. Do not load every leaf and do not load this index again from a leaf.

## Direct Conditional Leaves

- Intake, environment authority, automation limits, and escalation: load `references/auth-intake-and-authority.md`.
- Provider/stack discovery and minimum code inspection: load `references/auth-provider-routing.md`, then only the provider-specific references it selects.
- Browser reproduction, Playwright runtime preflight, evidence, Sentry/PM2, and human-step limits: load `references/auth-browser-proof.md`.
- Cause classification, verdict, handoff, and report fields: load `references/auth-diagnosis-and-report.md`.

Leaves are independent and must not load sibling leaves. Provider references remain independently selectable from the activation body or provider-routing leaf.

## Non-Negotiable Core

- Never expose or request raw secrets, cookies, tokens, OTPs, passwords, private environment values, OAuth codes, raw HAR files, sensitive breadcrumbs, or unredacted auth data.
- Never bypass auth, weaken authorization, reuse a primary account as test infrastructure, or mutate provider/production state without explicit authority and the owning workflow.
- Evidence must distinguish symptom, observation, hypothesis, and recommended correction. A local success never proves hosted callback/session behavior when hosted authority is required.
- Strong MFA, CAPTCHA, device approval, magic links, WebAuthn/passkeys, and external anti-bot gates may require a human step; continue safely to the furthest observable point and report the exact boundary.
- Missing required authority, environment, safe test identity, provider evidence, or browser runtime yields `partial` or `blocked`, never a guessed success.
