---
name: 108-sg-browser
description: "Check non-auth pages with browser, console, and network proof."
argument-hint: <URL, route, environment, or visible objective>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

Primary artifact type: `specialist-workflow`.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, evidence-first, and using the opening chantier header. Use `report=agent`, `handoff`, `verbose`, or `full-report` when another agent needs URLs, runtime details, evidence inventories, internal routes, or lifecycle state.

## Chantier Potential Intake

Apply the chantier-potential threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report.
For `108-sg-browser`, use it when browser evidence reveals non-trivial future work outside a narrow direct fix and no unique chantier already owns that work.

## Mission

`108-sg-browser` answers one question:

```text
What did a real browser actually see on this target for this objective?
```

Use it for one-off browser navigation, visual checks, accessibility snapshots, screenshots, console summaries, network summaries, and visible assertions on local, preview, or production surfaces.

`108-sg-browser` answers one browser-visible objective and routes broader work away.

If the browser objective can be satisfied only by auth/session analysis, durable QA logging, or deployment discovery, reroute immediately instead of stretching this skill into a broader proof owner.

Do not use it as the specialist for auth, manual QA, deployment discovery, production logs, or code fixes:
- Auth, OAuth, cookies, sessions, callbacks, tenants, and protected-route breaks route to `/109-sg-auth-debug`.
- Full manual QA campaigns, retests, `shipglows_data/workflow/TEST_LOG.md`, bug files, and optional `shipglows_data/workflow/BUGS.md` triage views route to `/107-sg-test`.
- Deployment URL discovery, Vercel status, build logs, runtime logs, and live deploy readiness route to `/405-sg-prod`.
- Actionable code bugs route to `/106-sg-fix` or `/102-sg-start`.

## Required References

Always load these before browser work:
- `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md`
- `$SHIPGLOWS_ROOT/skills/references/playwright-mcp-runtime.md`

Load `$SHIPGLOWS_ROOT/skills/108-sg-browser/references/browser-evidence.md` when the request involves console/network evidence, screenshots, production data, redaction, sensitive output, uncertain verdicts, or localized report wording. This is a skill-local reference, not a global `$SHIPGLOWS_ROOT/skills/references/*` file.

Load `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md` when the browser check sees a crash, error boundary, 5xx, unhandled console exception, visible diagnostics/log-copy UI, or visible Sentry/support event ID. Skills do not have direct Sentry dashboard access; use only visible/supplied issue or event pointers and redacted copied diagnostics.

Load `$SHIPGLOWS_ROOT/skills/references/runtime-diagnostics-surface.md` when a runtime app may expose settings, support, debug, diagnostics, error boundary, or copy-log UI. When the agent can navigate/click safely with Playwright or any other browser/tooling path, actively look for that surface and use its copy action before asking the operator for logs.

Read `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` and inspect `CLAUDE.md` or `SHIPGLOWS.md` before treating local browser proof as authoritative for changed behavior.

## Input Triage

Accept:
- full URL
- route plus derivable local or deployed base URL
- local project page
- Vercel preview or production URL
- visible assertion such as `verify that the pricing card appears`
- console or network objective
- viewport preference
- optional screenshot request

If no URL or target can be derived, ask one focused question for the target URL or route.

Route instead of continuing when:
- the objective mentions Clerk, Supabase Auth, OAuth, login, callback, cookies, session, tenant, protected route, or auth provider behavior -> `/109-sg-auth-debug`
- the user asks for a full manual user-flow test, durable QA log, or bug file -> `/107-sg-test`
- the deployment URL is unknown or unconfirmed -> `/405-sg-prod`
- preview-push validation is required but the change has not been shipped -> apply `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`
- the request is broad, such as "check everything" -> ask for one observable objective or route to `/107-sg-test`
- the requested action can buy, delete, publish, send email, change account data, write production data, or trigger external side effects -> ask for explicit approval or route to a safe test environment

## Browser Runtime Preflight

Before the first `mcp__playwright__*` tool call, apply `$SHIPGLOWS_ROOT/skills/references/playwright-mcp-runtime.md`.

Stop browser proof when:
- Playwright MCP config is stale or unsafe.
- Linux ARM64 config falls back to Google Chrome stable or `/opt/google/chrome/chrome`.
- Config is correct but the current MCP process still reports `/opt/google/chrome/chrome`.
- A reference required for the requested objective is missing from its canonical ShipGlows path.

In those cases, do not diagnose the app. Report the runtime or ShipGlows installation blocker. For Playwright runtime blockers, route to `/106-sg-fix BUG-2026-05-02-001` or request a Codex/MCP reload as the runtime reference requires. For missing ShipGlows references, report the missing canonical path and route to `/900-shipglows-core build` or `/106-sg-fix` instead of continuing with partial local memory.

## Verification Flow

1. Identify target, environment, requested objective, development mode, and allowed interaction level.
2. Run Playwright MCP runtime preflight.
3. Navigate to the target.
4. Capture an accessibility snapshot first when useful.
5. Capture a screenshot only when visual evidence adds value or the user asks for it.
6. Review console messages or network requests only when relevant to the objective or when visible evidence is partial.
7. For runtime apps, proactively look for safe diagnostics entry points such as Settings, Support, Diagnostics, Debug, error fallback, overflow menu, or `Copy diagnostics` / `Copy logs`. Use any available browser/navigation tool, but only reversible navigation/clicks.
8. If a diagnostics/log-copy action is reachable, click it, read the copied text from clipboard when tooling/browser permissions allow it, or read the visible diagnostic text. Confirm whether the first lines contain commit/build plus Paris/UTC build time.
9. Apply `$SHIPGLOWS_ROOT/skills/references/operator-last-resort-evidence.md` before asking the operator for logs. In `108-sg-browser`, ask only when the diagnostics surface is missing, blocked by auth/permissions, unsafe to open, or clipboard/text extraction fails.
10. If a Sentry/support event ID is visible or supplied, correlate only that pointer and summarize it without raw payloads.
11. Avoid raw dumps. Prefer targeted, redacted summaries.
12. Decide a narrow verdict for the requested objective only.
13. Route the next step based on the evidence.

## Read-Only Default

The default policy is `read-only`.

Allowed by default:
- navigation
- viewport resize
- accessibility snapshot
- screenshot
- console summary
- network request summary
- reversible clicks such as opening menus, tabs, accordions, or local navigation
- opening diagnostics/support/settings/debug panels and clicking `Copy diagnostics` / `Copy logs` when it does not mutate product data

Not allowed without explicit approval:
- form submission that creates or changes data
- purchase, deletion, publish, invite, email, webhook, billing, account, or production mutation
- bypassing auth walls, provider protections, consent flows, captchas, MFA, passkeys, or anti-bot controls
- reading or reporting cookies, localStorage, sessionStorage, tokens, complete headers, raw HAR data, private payloads, or PII

## Report Contract

Report in the user's active language. Keep stable labels, commands, and machine anchors in English.

## Language Doctrine

Internal instructions, workflow rules, stable headings, stop conditions, acceptance criteria, and validation notes stay in English. User-facing observations and explanations use the user's active language; French output must be natural and accented while command names, paths, stable labels, and verdict labels remain English.

Every final report must open with `🎯 VERDICT (HH:mm) : [pass / fail / partial / blocked / needs-auth / needs-deploy / needs-manual-test / unsafe-action]`, then include:
- `Target`
- `Environment`
- `Playwright MCP runtime`
- `Objective`
- `Observed`
- `Evidence`
- `Limits`
- `Next step`

Verdict labels:
- `pass`
- `fail`
- `partial`
- `blocked`
- `needs-auth`
- `needs-deploy`
- `needs-manual-test`
- `unsafe-action`

Success is never silent. Failure is never silent. If evidence is missing, name the missing proof and why it could not be collected.

## Handoff Rules

- Auth wall or auth objective -> `/109-sg-auth-debug [target or bug]`
- Unconfirmed deploy or missing preview URL -> `/405-sg-prod [project or URL]`
- Preview-push project with unshipped changes -> `/005-sg-ship [scope]`, then `/405-sg-prod [project or URL]`
- Full manual flow or durable QA evidence -> `/107-sg-test [scope]`
- Narrow actionable bug -> `/106-sg-fix [summary]`
- Non-trivial or cross-system follow-up -> `/100-sg-spec [title and compact context]`
- Implementation verification gap -> `/103-sg-verify [scope]`

## Security And Redaction

Redact secrets, cookies, tokens, credentials, private emails, account identifiers, sensitive request headers, private payloads, and production PII.

If a screenshot or snapshot may expose sensitive data, summarize the relevant visible state instead of embedding or persisting the sensitive evidence.

If a finding crosses the chantier threshold, report `Chantier potentiel` and route to `/100-sg-spec`. Do not write `shipglows_data/workflow/BUGS.md`, `shipglows_data/workflow/bugs/`, `shipglows_data/workflow/TEST_LOG.md`, `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md` from this skill.

## Final Report Shape

```text
🧱 CHANTIER (local|spec) : [nom]
🎯 VERDICT (HH:mm) : [réussi | échec | partiel | bloqué]

[Ce que le navigateur a réellement observé]
✅ [Preuve compacte : page, état visible, console ou réseau]
[Limite ou risque seulement s'il change la confiance]

## Chantier potentiel

Chantier potentiel: [oui / non / incertain]
Titre proposé: [title or None]
Raison: [threshold reason]
Sévérité: [P0 / P1 / P2 / P3 / unknown]
Formalisation recommandée: [oui / non] — [raison courte]

[Si le chantier reste ouvert, terminer par deux ou trois choix numérotés en
langage simple. Ne jamais exposer une URL privée, un runtime interne, un skill,
une commande, un propriétaire, un chemin de spec ou un flux.]
```
