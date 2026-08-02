---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-02"
updated: "2026-05-02"
status: active
source_skill: 102-sg-start
scope: browser-evidence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/108-sg-browser/SKILL.md
  - skills/references/playwright-mcp-runtime.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/107-sg-test/SKILL.md
  - skills/405-sg-prod/SKILL.md
depends_on:
  - artifact: "skills/references/playwright-mcp-runtime.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "GUIDELINES.md"
    artifact_version: "1.3.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Spec specs/108-sg-browser-general-browser-verification-skill.md requires a compact evidence reference for 108-sg-browser."
next_review: "2026-06-02"
next_step: "/103-sg-verify 108-sg-browser General Browser Verification Skill"
---

# Browser Evidence

## Purpose

This reference keeps `108-sg-browser` concise while defining how browser evidence should be collected, summarized, redacted, and reported.

## Evidence Families

| Evidence | Use when | Report as |
| --- | --- | --- |
| Accessibility snapshot | The question is visible text, structure, controls, nav, forms, headings, or state | Short visible-state summary and key labels |
| Screenshot | Layout, visual state, blank page, overlap, modal, canvas, or image rendering matters | Screenshot path or brief visual summary |
| Console messages | The visible state passes but runtime errors may explain risk | Count plus targeted severe errors only |
| Network requests | A route, asset, API call, status code, redirect, or blocked request matters | Sanitized method/path/status summary |
| Diagnostics/log-copy UI | The app exposes a support/debug panel, error boundary, or copy-diagnostics action | Redacted commit/build header plus environment/release/event/log summary |
| URL and redirect chain | The objective depends on navigation, final route, or environment | Start URL, final URL, notable redirect |
| Timing/blocker | Page load, timeout, spinner, interstitial, cookie banner, or provider page blocks proof | Blocker and missing proof |

Prefer the least sensitive evidence that proves the objective.

## Diagnostics Copy Rule

When the agent can browse or navigate the target app and the target is runtime, do not wait for the operator to paste logs if the app can expose them safely. This rule is tool-agnostic: Playwright, another browser tool, or an app-visible debug surface all count when they allow safe navigation.

Actively inspect likely entry points:

- Settings / Parametres
- Support / Help
- Diagnostics / Debug
- error boundary fallback
- overflow or native debug menu
- buttons named `Copy diagnostics`, `Copy logs`, `Copier`, or equivalent localized copy

If a copy action is reachable and does not mutate product data:

1. Click it.
2. Read clipboard text when the browser/tooling permits it, or read the visible diagnostic text.
3. Verify the first lines include `commit/build`, `build_at_paris`, and `build_at_utc`.
4. Summarize only redacted, useful lines: build identity, environment, route, visible event/support id, and short log/error family.

Ask the operator for logs only when the diagnostics surface is absent, auth-blocked, unsafe to open, or inaccessible to Playwright/clipboard extraction.

## Verdict Labels

- `pass`: requested objective was observed and no material blocker was found.
- `fail`: requested objective was not observed and the browser evidence points to application behavior.
- `partial`: visible objective passed but console, network, environment, or evidence mismatch creates material risk.
- `blocked`: browser evidence is invalid or incomplete because of runtime, target, timeout, environment, or tooling.
- `needs-auth`: the page or objective requires auth-specific diagnosis.
- `needs-deploy`: deployment or preview readiness must be confirmed first.
- `needs-manual-test`: the request is a full user-flow or requires human confirmation.
- `unsafe-action`: the requested interaction could mutate data or trigger external side effects without explicit approval.

Do not use `pass` for a whole feature unless the objective itself was that narrow.

## Redaction Rules

Never report or store:
- cookies
- tokens
- credentials
- localStorage or sessionStorage contents
- complete request or response headers
- raw HAR data
- private payloads
- full account identifiers
- private emails
- production PII
- screenshots exposing sensitive data unless the user explicitly requested and approved that evidence

Allowed summaries:
- sanitized endpoint path without query secrets
- status code
- high-level error label
- visible text that is not private
- count of console errors
- short non-secret error message

If in doubt, say the evidence was redacted and report only the non-sensitive fact needed for the verdict.

## Console And Network Limits

Console summaries should include:
- number of severe errors
- the first relevant error family
- source file only when it is not sensitive and helps route the fix

Network summaries should include:
- method
- sanitized path or host
- status code
- blocked, failed, timeout, or redirect state

Do not paste full payloads, auth headers, cookies, request bodies, or response bodies.

## Screenshot And Snapshot Rules

Use accessibility snapshots first when they prove the assertion. They are easier to inspect and easier to redact.

Use screenshots when:
- visual layout is the objective
- snapshot and screenshot disagree
- the page is blank, clipped, hidden behind a modal, or visually broken
- the user explicitly requests visual proof

If snapshot is empty but screenshot shows content, or screenshot is blank but snapshot has DOM, report `partial` or `blocked` and name the evidence mismatch.

## Production Interaction Safety

Production browser work is read-only by default.

Reversible interactions are acceptable:
- open menu
- switch tab
- expand accordion
- dismiss local-only overlay when safe
- navigate to a public link

Explicit approval is required before:
- submitting forms
- creating or editing records
- deleting
- publishing
- purchasing
- sending email
- inviting users
- changing account or billing state
- triggering webhooks or external integrations

If approval is missing, use `unsafe-action` and route to a safe environment, manual test, or explicit approval prompt.

## Localized Reports

The final report uses the user's active language. Stable labels, commands, and verdict labels stay English.

Good localized behavior:
- keep `Target`, `Environment`, `Verdict`, and ShipGlows command names stable
- write observations, limits, and next-step explanations in the user's active language
- use natural French with accents when the active language is French

Do not translate command names, stable anchors, file paths, or verdict labels.

## Handoff Interpretation

Route by blocker:

| Blocker or finding | Next step |
| --- | --- |
| Auth wall or auth objective | `/109-sg-auth-debug [target or bug]` |
| Missing preview or deploy status | `/405-sg-prod [project or URL]` |
| Preview-push project with unshipped changes | `/005-sg-ship [scope]`, then `/405-sg-prod [project or URL]` |
| Full manual user flow | `/107-sg-test [scope]` |
| Narrow actionable bug | `/106-sg-fix [summary]` |
| Non-trivial cross-system follow-up | `/100-sg-spec [title and compact context]` |
| Verification evidence gap | `/103-sg-verify [scope]` |
