---
name: 109-sg-auth-debug
description: "Debug auth, OAuth, cookies, callbacks, and sessions."
argument-hint: <bug auth, URL, provider, ou flow à diagnostiquer>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

Primary artifact type: `specialist-workflow`.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. If attached to one unique chantier spec, write the run trace there. If no unique chantier exists, do not write to a spec.

## Chantier Potential Intake

Apply the chantier-potential threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report.
For `109-sg-auth-debug`, use it when auth/session/callback findings reveal non-trivial future work and no unique chantier already owns that work.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for audits and failures, outcome-first for successful support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Mission

`109-sg-auth-debug` answers one question: `Quel composant auth/session/callback explique ce comportement ?`

This skill is the auth/session specialist, not the generic browser fallback. Use it for auth, OAuth, cookies, callbacks, sessions, redirects, tenants, and protected-route behavior when browser proof or runtime evidence must stay inside an auth-safe debugging lane.

It does not own generic browser proof, full manual QA logging, deployment discovery, or direct code-fix implementation:

- one-off non-auth browser proof -> `/108-sg-browser`
- guided manual QA or durable test logging -> `/107-sg-test`
- deploy target discovery or runtime readiness -> `/405-sg-prod`
- implementation repair -> `/106-sg-fix` or `/102-sg-start`

## Required References

- `$SHIPGLOWS_ROOT/skills/references/async-feedback-visibility-contract.md` for auth/session checks, OAuth/browser callbacks, token refresh, sign-in, sign-out, or any delayed provider operation.

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/auth-debug-workflow.md`: Auth debug workflow, provider-reference routing, reproduction strategy, Playwright proof, Sentry/PM2 evidence, and report details.
- `$SHIPGLOWS_ROOT/skills/references/runtime-diagnostics-surface.md`: required when the auth target exposes settings, support, diagnostics, callback error pages, error boundaries, or copy-log UI.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before reading ShipGlows-owned references, running ShipGlows-owned tools/scripts, or checking ShipGlows-owned auth-debug/runtime surfaces.
For `109-sg-auth-debug`, this preflight also applies before auth-safe runtime diagnostics and callback-proof surfaces.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode under `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: bounded professional scope, never shortcut quality.

- INTAKE: load `references/auth-debug-workflow.md` to consume existing evidence and choose repro strategy.
- PROVIDER ROUTING: load the workflow reference, then load only the provider-specific references it selects.
- BROWSER PROOF: load `$SHIPGLOWS_ROOT/skills/references/playwright-mcp-runtime.md` and relevant auth testing references before Playwright MCP calls.

## Core Execution Rules

- Preserve auth/session/callback/provider, tenant, cookie, redirect, token, secret, and redaction safety rules.
- Before asking the operator for logs, screenshots, callback traces, or browser repro steps, apply `$SHIPGLOWS_ROOT/skills/references/operator-last-resort-evidence.md`.
- When the agent can safely navigate the app with Playwright or any other browser/tooling path, proactively look for diagnostics/log-copy UI, use it as redacted evidence, and confirm the commit/build + Paris/UTC build-time header before asking the operator for logs.
- Evaluate `Chantier potentiel` for auth/session/callback/provider/tenant risk beyond a direct local fix.
- Never log secrets, cookies, tokens, OTPs, private env values, or unredacted user auth data.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|ShipGlows-Owned Preflight|canonical ShipGlows path|auth|session|provider|Playwright|Sentry|redaction|references/|operator for logs|runtime surface" skills/109-sg-auth-debug/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --skill 109-sg-auth-debug`
