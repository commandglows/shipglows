---
name: 108-sg-browser
description: "Check non-auth pages with browser, console, and network proof."
argument-hint: "<URL, route, environment, or visible objective>"
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned files. Project targets resolve from the current project root.

## Chantier And Reporting

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Attach to one unique spec when present; otherwise use `(local)`. Apply `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` for trace and `Chantier potentiel`. Before reporting load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`; default to concise evidence-first `report=user`.

## Mission

`108-sg-browser` answers one objective-bounded question: what did a real browser observe on this non-auth target? It owns navigation, visible assertions, accessibility snapshots, screenshots, targeted console/network proof, and implementation-signoff QA inventories bounded to that objective—not auth, durable QA records, deploy discovery, production logs, or code repair.

## Scope And Owner Gate

Accept a URL, derivable route, environment, visible assertion, console/network objective, viewport, or screenshot request. If no target is derivable, ask once.

When the objective is implementation signoff, reference fidelity, or a user-visible completion claim, treat its requirements, implemented controls and state changes, and intended final-report claims as one bounded QA inventory. Simple screenshot, state, console, network, or single-assertion requests remain focused and do not trigger the full signoff matrix.

Route before browser work:

- auth/OAuth/cookies/session/callback/tenant/protected route → `109-sg-auth-debug`;
- full manual flow, retest, `TEST_LOG.md`, or bug record → `107-sg-test`;
- unknown/unconfirmed deployment target or runtime logs → `405-sg-prod`;
- actionable code repair → `106-sg-fix` or `102-sg-start`;
- broad “check everything” → one observable objective or durable QA.

Read `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` and project `CLAUDE.md`/`SHIPGLOWS.md`. Preview-push changed behavior requires `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`; local evidence there is non-authoritative.

## Browser Preflight

Before deriving or opening a local URL, load and apply
`$SHIPGLOWS_ROOT/skills/references/agent-runtime-awareness.md`; use the active
URL assigned in the project's `ENVIRONMENT.md` only when the matching DevServer registry entry is active. Before the first browser/Playwright
action, load and apply `$SHIPGLOWS_ROOT/skills/references/playwright-mcp-runtime.md`.
`configured` or `installed` Playwright/MCP state is not `available` session
evidence. Inspect direct and deferred/searchable current-turn tool catalogs,
then use the smallest read-only Playwright probe before reporting `callable` or
`not exposed`. Stale/unsafe configuration, a mismatched running browser, missing
canonical authority, or unavailable target blocks app diagnosis; report the
runtime/install/deploy owner instead.

## Progressive Browser Packs

Local packs load directly and never chain. `$SHIPGLOWS_ROOT/skills/108-sg-browser/references/browser-evidence.md` is a compatibility index only.

- After target, owner, environment, and runtime preflight pass, load `$SHIPGLOWS_ROOT/skills/108-sg-browser/references/browser-proof-playbook.md`.
- After evidence is collected or a proof blocker is established, load `$SHIPGLOWS_ROOT/skills/108-sg-browser/references/browser-report-and-routing.md`.

Load at most one local pack before the first substantive action.

## Read-Only And Safety Gate

Default is read-only: navigate, resize, snapshot, screenshot, summarize console/network, open reversible menus/tabs, and open/copy safe diagnostics.

Explicit approval is required before submitting or mutating data, purchase, deletion, publish, invite, email, webhook, billing/account change, or production side effect. Never bypass auth, consent, captcha, MFA, passkeys, anti-bot, or provider protections. Without approval return `unsafe-action` or use a safe environment.

Never read/report cookies, tokens, storage/session contents, complete headers, raw HAR, private payloads, account identifiers, private emails, PII, or sensitive screenshots. Prefer the least sensitive proof; summarize/redact rather than persist exposure.

## Evidence And Verdict Boundary

Use accessibility state before screenshots when sufficient. Console/network evidence is targeted, not a raw dump. When runtime diagnostics are visible, load applicable `$SHIPGLOWS_ROOT/skills/references/runtime-diagnostics-surface.md`, `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md`, and `$SHIPGLOWS_ROOT/skills/references/operator-last-resort-evidence.md`; use safe copy/navigation before asking the operator.

Verdicts are objective-bounded: `pass`, `fail`, `partial`, `blocked`, `needs-auth`, `needs-deploy`, `needs-manual-test`, or `unsafe-action`. Evidence mismatch or missing proof cannot be `pass`; a narrow pass never proves the whole feature. For implementation signoff, functional behavior, viewport fit, and visual quality must each pass independently.

## Stop Conditions

Stop for auth ownership, missing/unconfirmed deployment, unshipped preview-required change, unsafe mutation without approval, stale browser runtime, sensitive evidence that cannot be safely summarized, missing canonical reference, or an objective too broad for one browser check.

## Report Modes

Use `report=user` by default and `report=agent` only for an internal handoff.

## Final Report Shape

```text
🧱 CHANTIER (local|spec) : <name>
🎯 VERDICT (HH:mm) : <verdict>
<What the browser actually observed>
✅ <Compact objective-matched evidence>
⚠️ <Only a material proof limit or risk>
```

Use the operator's language. Internal URLs, commands, paths, owner names, runtime details, and evidence inventories belong only to `report=agent`. If non-trivial future work crosses the threshold, emit a redacted `Chantier potentiel` without writing trackers, bug files, or test logs.

## Validation

Run `tools/test_108_sg_browser_compaction_contract.py`, reporting and proof consumers, metadata, budget, and runtime-sync checks.
