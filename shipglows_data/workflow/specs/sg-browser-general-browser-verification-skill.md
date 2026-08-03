---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-02"
created_at: "2026-05-02 05:53:05 UTC"
updated: "2026-05-02"
updated_at: "2026-05-02 11:36:16 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "As a ShipGlows user working with agents on local sites, previews, and production deployments, I want a general browser verification skill that opens a URL and checks an observable objective, so I can get reliable browser evidence without misusing sg-auth-debug outside its auth-specialized role."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-browser/SKILL.md
  - skills/sg-browser/references/browser-evidence.md
  - skills/references/playwright-mcp-runtime.md
  - skills/sg-auth-debug/SKILL.md
  - skills/sg-test/SKILL.md
  - skills/sg-prod/SKILL.md
  - skills/sg-verify/SKILL.md
  - skills/sg-start/SKILL.md
  - skills/sg-fix/SKILL.md
  - skills/sg-help/SKILL.md
  - README.md
  - site/src/content/skills/sg-browser.md
  - GUIDELINES.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - docs/technical/skill-runtime-and-lifecycle.md
depends_on:
  - artifact: "GUIDELINES.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "docs/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "skills/references/playwright-mcp-runtime.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.8.0"
    required_status: "draft"
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User request 2026-05-02: create future skill sg-browser after Playwright MCP Linux ARM64 Chrome-stable config issue."
  - "User decision context 2026-05-02: sg-auth-debug should stay auth-specialized; a general browsing skill should cover non-auth browser checks."
  - "User decision 2026-05-02: the full spec contract, including the User Story, must be in English and must follow the strict ShipGlows language doctrine."
  - "skills/sg-auth-debug/SKILL.md owns Clerk, Supabase Auth, OAuth, callbacks, sessions, protected routes, and browser auth flows."
  - "skills/sg-test/SKILL.md owns guided manual QA, test logs, bug dossiers, and human flow confirmation."
  - "skills/sg-prod/SKILL.md owns deployment status, Vercel/runtime logs, and live deployment health checks."
  - "docs/technical/skill-runtime-and-lifecycle.md requires Playwright MCP runtime preflight before browser evidence."
  - "skills/references/playwright-mcp-runtime.md forbids Linux ARM64 fallback to Google Chrome stable and points stale MCP config to BUG-2026-05-02-001."
  - "Context7 /microsoft/playwright-mcp checked 2026-05-02: Playwright MCP exposes browser navigation, snapshots, screenshots, console messages, network requests, headless/browser/executable configuration, and isolated/user-data-dir controls."
next_step: "None"
---

# Spec: sg-browser General Browser Verification Skill

## Title

sg-browser General Browser Verification Skill

## Status

ready

## User Story

As a ShipGlows user working with agents on local sites, previews, and production deployments, I want a general browser verification skill that opens a URL and checks an observable objective, so I can get reliable browser evidence without misusing `sg-auth-debug` outside its auth-specialized role.

## Minimal Behavior Contract

When the user invokes `sg-browser` with a URL, route, environment, or visible objective, the skill must verify the requested surface in a real browser or explain why it cannot. It produces a concise report containing the target URL, browser runtime, observed state, requested assertion, relevant console/network evidence, screenshot or snapshot evidence when useful, limits, and next action. On failure, it distinguishes runtime failure, deployment failure, application failure, auth requirement, manual-test requirement, and unsafe action. The easy-to-miss edge case is a false diagnosis: a Playwright MCP failure caused by the wrong ARM64 Chrome fallback, an undeployed preview, or an auth flow must be routed before the skill concludes that the app is broken.

## Success Behavior

- Preconditions: an explicit or derivable URL exists, the validation surface is clear, and the Playwright MCP runtime passes `skills/references/playwright-mcp-runtime.md` preflight.
- Trigger: the user runs `/sg-browser <URL or scope> <objective>`, or another skill routes to `sg-browser` for non-auth browser evidence.
- User/operator result: the report states what was opened, what was expected, what was observed, whether the objective passed or failed, which evidence was collected, which limits apply, and which ShipGlows command should follow.
- System effect: no project file is modified by default, and no tracker is written unless a downstream skill such as `sg-test` or `sg-fix` takes over.
- Success proof: a visible assertion, accessibility snapshot, screenshot, targeted console/network summary, or observable HTTP status confirms the requested objective.
- Silent success: not allowed; every browser verification must produce a short report with runtime, target, verdict, evidence, and limits.

## Error Behavior

- Expected failures: missing URL, unreachable URL, local server not running, unconfirmed Vercel preview, stale or misconfigured Playwright MCP, timeout, route 404/500, console error, network failure, auth wall, OAuth/provider block, consent/cookie modal, destructive action, visible secret, or sensitive data in logs.
- User/operator response: the report must name the blocker, state whether browser evidence is invalid or partial, and route to `/sg-fix`, `/sg-auth-debug`, `/sg-prod`, `/sg-test`, `/sg-ship`, or `/sg-spec` as appropriate.
- System effect: no destructive action, no sensitive form submission, and no persistence or reporting of secrets, cookies, tokens, complete headers, raw HAR data, localStorage, sessionStorage, or PII.
- Must never happen: launch Playwright MCP without runtime preflight when browser proof is required, use `npx playwright install chrome` as the Linux ARM64 fix, click an irreversible action without explicit approval, treat an auth wall as proof of an app bug, or paste secrets into a report.
- Silent failure: not allowed; if navigation, snapshot, screenshot, console, or network evidence cannot be read, the report must say which proof is missing and why.

## Problem

ShipGlows has several skills that touch browser evidence, but none is the correct general entrypoint for "open this site and verify this observable thing."

`sg-auth-debug` is intentionally specialized for Clerk, Supabase Auth, OAuth, cookies, callbacks, sessions, tenants, protected routes, and auth propagation. Using it for a landing page, layout, public route, console error, or non-auth preview dilutes its contract.

`sg-test` owns guided manual QA and durable test logging, often with human confirmation. `sg-prod` owns deployment status, logs, and production state. `sg-verify` judges readiness against a scope. ShipGlows needs a short, robust skill that collects one-off browser proof without assuming auth, without writing bug dossiers by default, and without forgetting the Playwright MCP Linux ARM64 runtime fix.

## Solution

Create `sg-browser` as the generic ShipGlows skill for browser navigation, quick visual inspection, console/network review, accessibility snapshots, screenshots, and visible assertions on local, preview, or production surfaces. Keep `sg-auth-debug` as the auth specialist and define explicit handoffs to `sg-auth-debug`, `sg-test`, `sg-prod`, `sg-fix`, `sg-ship`, and `sg-verify`.

## Scope In

- Create `skills/sg-browser/SKILL.md` with a compact general browser verification contract.
- Classify `sg-browser` as `conditionnel` for chantier tracing and `source-de-chantier` for incidents or regressions it detects.
- Load `skills/references/playwright-mcp-runtime.md` before any Playwright MCP call.
- Define accepted inputs: URL, route, local project, preview/production URL, visible assertion, console/network objective, viewport, optional screenshot, or request such as "verify that X appears."
- Define the standard report: target, environment, runtime, objective, observations, verdict, evidence collected, limits, and next action.
- Define a read-only default policy: navigation, snapshot, screenshot, console, and network review are allowed; clicks and form fills are limited to reversible actions or explicitly approved actions.
- Define handoffs: auth to `sg-auth-debug`, deployment URL/log uncertainty to `sg-prod`, durable QA to `sg-test`, actionable bug to `sg-fix`, preview-push validation to `sg-ship` then `sg-prod`, and non-trivial chantier follow-up to `sg-spec`.
- Add `skills/sg-browser/references/browser-evidence.md` for evidence families, redaction, wording, limits, and verdict labels.
- Update skills that mention browser evidence so they route to `sg-browser` when the issue is not auth.
- Update technical docs, README guidance, and help/catalog surfaces that list skills or browser/auth paths.
- Enforce the ShipGlows language doctrine: internal contracts in English, user-facing interaction in the user's active language, natural accented French when the active language is French, and stable machine anchors in English.

## Scope Out

- Replace `sg-auth-debug` for Clerk, Supabase Auth, OAuth, callback, cookie, session, tenant, or protected-route debugging.
- Replace `sg-test` for manual QA scenarios, `shipglows_data/workflow/TEST_LOG.md`, `shipglows_data/workflow/BUGS.md`, `shipglows_data/workflow/bugs/`, durable retests, or user-flow test records.
- Replace `sg-prod` for discovering a deployment URL, waiting for Vercel, reading runtime logs, or diagnosing a production outage.
- Fix application code directly; `sg-browser` detects and routes to `sg-fix` or `sg-start`.
- Automate real Google/SSO/MFA login or bypass provider protection.
- Store raw HAR files, sensitive screenshots, cookies, localStorage, sessionStorage, tokens, complete headers, or private payloads.
- Install Chrome stable or repair the Playwright environment; that path remains `sg-fix BUG-2026-05-02-001` or installer/runtime work.

## Constraints

- `sg-browser` must stay short; repeatable evidence detail belongs in `skills/sg-browser/references/browser-evidence.md`.
- All internal `SKILL.md` instructions, workflow rules, stop conditions, acceptance criteria, validation notes, and technical documentation created or edited for this chantier must be in English.
- User-facing report text produced by `sg-browser` must use the user's active language or the project's active language; French user-facing output must be natural and accented.
- Stable machine-readable anchors remain English even when a report is localized, including `Status`, `Scope In`, `Acceptance Criteria`, `Skill Run History`, and command names.
- Browser evidence is invalid if Playwright MCP runtime preflight has not passed.
- On Linux ARM64, never run or recommend `npx playwright install chrome`; use Playwright Chromium, Chromium Headless Shell, or the `--browser chromium` fallback.
- If MCP still reports `/opt/google/chrome/chrome` after the config is correct, classify the current MCP process as stale, stop browser proof, and request reload.
- Respect project development mode: in `vercel-preview-push`, local browser evidence cannot validate deployed preview behavior.
- Production actions are read-only by default; any interaction that can mutate data, buy, delete, publish, send email, or change an account requires explicit approval.
- Reports must redact secrets, cookies, tokens, PII, sensitive headers, and private payloads.
- A loaded page is not enough proof for auth, permissions, billing, data isolation, webhooks, or multi-step flows.

## Dependencies

- Runtime: Playwright MCP through the current Codex/Claude MCP config, configured with an existing Chromium executable or explicit Chromium fallback.
- Runtime tools: `mcp__playwright__browser_navigate`, `browser_snapshot`, `browser_take_screenshot`, `browser_console_messages`, `browser_network_requests`, `browser_resize`, `browser_click`, `browser_fill_form`, and related Playwright MCP tools when available.
- Document contracts: `GUIDELINES.md` 1.3.0, `docs/technical/skill-runtime-and-lifecycle.md` 1.3.0, `skills/references/playwright-mcp-runtime.md` 1.1.0, `shipglows_data/workflow/playbooks/spec-driven-workflow.md` 0.8.0, `docs/technical/code-docs-map.md` 1.0.0.
- Skill dependencies: `sg-auth-debug`, `sg-test`, `sg-prod`, `sg-verify`, `sg-start`, `sg-fix`, `sg-help`.
- Fresh external docs: checked 2026-05-02 through Context7 `/microsoft/playwright-mcp`. Current docs support navigation, snapshots, screenshots, console/network tools, click/fill interactions, headless/browser options, executable-path style launch configuration, isolated mode, and user-data-dir controls.
- Metadata gaps: none blocking for this spec. `shipglows_data/workflow/playbooks/spec-driven-workflow.md` is draft, so implementation must update or explicitly no-impact the workflow doc according to the docs map.

## Invariants

- `sg-browser` answers: what did the browser actually see on this URL for this objective?
- `sg-auth-debug` answers: where does the auth/session/provider/callback/protected flow break?
- `sg-test` answers: what real user scenario was tested, by whom or by what evidence, and how should it be logged?
- `sg-prod` answers: which deployment is live or preview-ready, and what do deployment/runtime logs say?
- `sg-browser` may collect proof, but it must not claim readiness for a whole feature unless the requested objective is that narrow.
- `sg-browser` must never diagnose app behavior from a stale or misconfigured browser runtime.
- `sg-browser` must keep evidence minimal, redacted, and relevant to the stated objective.
- `sg-browser` must prefer accessibility snapshots, visible DOM, and targeted console/network summaries over raw dumps.
- `sg-browser` must preserve ShipGlows language doctrine across skill instructions, reference docs, user-facing reports, and examples.
- If a finding crosses the chantier threshold, `sg-browser` reports `Chantier potentiel` and routes to `/sg-spec` rather than creating a spec itself.

## Links & Consequences

- Upstream systems: user requests, `sg-start` validation routing, `sg-verify` evidence needs, `sg-test` preflight evidence, `sg-prod` live URL confirmation, `sg-fix` reproduction requests.
- Downstream systems: `sg-auth-debug` for auth, `sg-test` for durable manual QA and bug logging, `sg-fix` for direct bugs, `sg-prod` for deployment/log uncertainty, `sg-ship` for preview-push validation, `sg-spec` for non-trivial follow-up.
- Cross-cutting checks: security redaction, production mutation safety, development-mode correctness, browser runtime correctness, language doctrine, docs coherence, and skill budget.
- Regression impact: existing `sg-auth-debug` routes remain valid; only non-auth browser checks move to `sg-browser`.
- Operational consequence: skills that currently say "use Playwright" must say whether they mean generic `sg-browser` or auth-specific `sg-auth-debug`.

## Documentation Coherence

- `skills/sg-help/SKILL.md` must list `/sg-browser` with concise usage and distinguish it from `/sg-auth-debug`, `/sg-test`, and `/sg-prod`.
- `README.md` should add a generic browser verification path near the existing auth/browser diagnostic path.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md` should mention `sg-browser` only where support/source skills or validation evidence paths are listed.
- `docs/technical/skill-runtime-and-lifecycle.md` should mention `sg-browser` as the generic Playwright MCP consumer and preserve the shared runtime preflight invariant.
- `skills/sg-auth-debug/SKILL.md` should point non-auth browser checks to `sg-browser`, while retaining auth ownership.
- `skills/sg-test/SKILL.md` should route direct tool-collected browser evidence to `sg-browser` when no durable manual test log is needed.
- `skills/sg-prod/SKILL.md` should route post-deploy page checks to `sg-browser` after the deployment URL is confirmed.
- `skills/sg-verify/SKILL.md` and `skills/sg-start/SKILL.md` should mention `sg-browser` for non-auth browser proof.
- Public site skill pages may need update if they expose the skill catalog; confirm via `docs/technical/code-docs-map.md` during implementation.
- Documentation and skill-contract edits must follow `GUIDELINES.md` language doctrine: internal contracts in English, localized user-facing interaction where relevant.

## Edge Cases

- The URL is local but no dev server is running: report blocked and suggest the project-specific start path, not a browser bug.
- The project is `vercel-preview-push`: route to `/sg-ship` then `/sg-prod` before treating preview browser evidence as authoritative.
- The requested page requires login: route to `sg-auth-debug` if the objective is auth/session behavior; otherwise report auth wall as a precondition.
- The visible page is correct but console has severe errors: report partial pass with console risk, not clean pass.
- The network request fails with 401/403/500: include sanitized endpoint/status and route by likely owner.
- A cookie banner, interstitial, or provider page blocks the requested assertion: report the blocker and avoid unsafe bypass.
- The requested action would mutate production data: ask for explicit approval or route to a safe test environment.
- MCP runtime path is correct in config but the tool still tries `/opt/google/chrome/chrome`: classify stale MCP process and do not diagnose the app.
- Snapshot is empty but screenshot shows content, or screenshot is blank but snapshot has DOM: report evidence mismatch and avoid overclaiming.
- The user asks for "check everything": narrow to a short explicit objective or route to `sg-test` for scenario planning.
- The user invokes the skill in French: the user-facing report is in natural accented French, while internal headings, commands, and stable anchors stay English.

## Implementation Tasks

- [x] Task 1: Create the generic browser skill contract
  - File: `skills/sg-browser/SKILL.md`
  - Action: Add a new English-language skill with frontmatter, canonical path loading, chantier classification `conditionnel/source-de-chantier`, Playwright MCP runtime preflight, input triage, read-only defaults, report format, handoff rules, language-doctrine rules, and security redaction constraints.
  - User story link: Provides the general `/sg-browser` entrypoint for browser evidence.
  - Depends on: None
  - Validate with: `rg -n "name: sg-browser|playwright-mcp-runtime|Chantier Tracking|sg-auth-debug|sg-test|sg-prod|read-only|Language Doctrine" skills/sg-browser/SKILL.md`
  - Notes: Keep the SKILL body concise; move detailed evidence policy to Task 2 if it grows.

- [x] Task 2: Add the browser evidence reference
  - File: `skills/sg-browser/references/browser-evidence.md`
  - Action: Document evidence types, redaction rules, console/network summary limits, screenshot/snapshot use, production interaction safety, localized report wording, and standard verdict labels.
  - User story link: Makes browser proof reliable and safe without bloating the skill body.
  - Depends on: Task 1
  - Validate with: `python3 tools/shipglows_metadata_lint.py skills/sg-browser/references/browser-evidence.md`
  - Notes: Reference should include frontmatter because it is a durable ShipGlows technical guideline.

- [x] Task 3: Route non-auth browser work away from sg-auth-debug
  - File: `skills/sg-auth-debug/SKILL.md`
  - Action: Add a short boundary rule: use `sg-browser` for public UI, visual, console, network, and non-auth navigation checks; keep `sg-auth-debug` for auth/session/provider/callback/protected flows.
  - User story link: Preserves `sg-auth-debug` as a specialist.
  - Depends on: Task 1
  - Validate with: `rg -n "sg-browser|non-auth|Clerk|OAuth|session|protected" skills/sg-auth-debug/SKILL.md`
  - Notes: Do not remove existing Playwright auth reference or provider references.

- [x] Task 4: Update testing and production routing
  - File: `skills/sg-test/SKILL.md`
  - Action: Route one-off browser proof to `sg-browser` when no guided manual QA log or bug dossier is needed; keep `sg-test` ownership over scenario planning, test logs, retests, and bug records.
  - User story link: Prevents `sg-test` from being used as a lightweight browser checker.
  - Depends on: Task 1
  - Validate with: `rg -n "sg-browser|browser evidence|shipglows_data/workflow/TEST_LOG.md|shipglows_data/workflow/BUGS.md|sg-auth-debug" skills/sg-test/SKILL.md`
  - Notes: Keep the existing rule that results are not logged before evidence exists.

- [x] Task 5: Update production and verification handoffs
  - File: `skills/sg-prod/SKILL.md`
  - Action: After `sg-prod` confirms a deployment URL, route page-level browser assertions to `sg-browser`; keep deploy status, Vercel logs, and runtime logs in `sg-prod`.
  - User story link: Separates live URL discovery from browser observation.
  - Depends on: Task 1
  - Validate with: `rg -n "sg-browser|deployment URL|browser|runtime logs|Vercel" skills/sg-prod/SKILL.md`
  - Notes: This is a routing addition only.

- [x] Task 6: Update lifecycle skill references
  - File: `skills/sg-verify/SKILL.md`
  - Action: Mention `sg-browser` as the support skill for non-auth browser evidence during verification, with `sg-auth-debug` reserved for auth/session/protected flow risk.
  - User story link: Lets verification request the right browser proof.
  - Depends on: Task 1
  - Validate with: `rg -n "sg-browser|sg-auth-debug|browser evidence|protected|session" skills/sg-verify/SKILL.md`
  - Notes: Do not make `sg-verify` delegate automatically if the current environment forbids it.

- [x] Task 7: Update implementation routing for browser-dependent tasks
  - File: `skills/sg-start/SKILL.md`
  - Action: Add `sg-browser` to validation routing for non-auth browser flows and preserve preview-push rules before browser/manual proof.
  - User story link: Ensures implementation work asks for the right browser proof at the right time.
  - Depends on: Task 1
  - Validate with: `rg -n "sg-browser|preview-push|sg-auth-debug|browser/manual" skills/sg-start/SKILL.md`
  - Notes: Keep `sg-start` from treating local browser checks as preview proof.

- [x] Task 8: Update bug-first routing
  - File: `skills/sg-fix/SKILL.md`
  - Action: Route browser reproduction that is not auth-specific through `sg-browser`; keep auth/browser-session bugs routed to `sg-auth-debug`.
  - User story link: Makes bug reproduction use the right diagnostic skill.
  - Depends on: Task 1
  - Validate with: `rg -n "sg-browser|sg-auth-debug|browser|auth|reproduce" skills/sg-fix/SKILL.md`
  - Notes: If `sg-fix` finds a direct bug while using browser evidence, it still owns the fix attempt.

- [x] Task 9: Update help and workflow docs
  - File: `skills/sg-help/SKILL.md`
  - Action: Add `/sg-browser` to the skill catalog, examples, and mode notes; distinguish it from `/sg-auth-debug`, `/sg-test`, and `/sg-prod`.
  - User story link: Makes the new skill discoverable.
  - Depends on: Tasks 1-8
  - Validate with: `rg -n "/sg-browser|sg-auth-debug|sg-test|sg-prod" skills/sg-help/SKILL.md`
  - Notes: Keep examples short.

- [x] Task 10: Update README browser workflow
  - File: `README.md`
  - Action: Add a concise generic browser verification path and keep the existing auth/browser diagnostic path for `sg-auth-debug`.
  - User story link: Documents when to use the new skill.
  - Depends on: Tasks 1-9
  - Validate with: `rg -n "sg-browser|Auth/browser diagnostic|browser verification" README.md`
  - Notes: Avoid overexplaining implementation details in public-facing README prose.

- [x] Task 11: Update technical lifecycle docs
  - File: `docs/technical/skill-runtime-and-lifecycle.md`
  - Action: Record `sg-browser` as the generic Playwright MCP browser evidence skill and preserve the mandatory `playwright-mcp-runtime.md` preflight.
  - User story link: Keeps code-proximate docs aligned with skill runtime behavior.
  - Depends on: Tasks 1-10
  - Validate with: `python3 tools/shipglows_metadata_lint.py docs/technical/skill-runtime-and-lifecycle.md`
  - Notes: Update `updated` and evidence metadata if implementation changes the doc.

- [x] Task 12: Update workflow doctrine if the skill catalog is described there
  - File: `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Action: Add `sg-browser` only where support/source skills or validation evidence paths are listed.
  - User story link: Keeps lifecycle routing coherent for future agents.
  - Depends on: Tasks 1-11
  - Validate with: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Notes: If the file does not mention comparable skill routing, record a no-impact justification instead of forcing a broad rewrite.

- [x] Task 13: Run skill validation and routing checks
  - File: `skills/`
  - Action: Run skill budget audit, metadata lint for new reference/docs/spec, and targeted `rg` checks proving the new routing exists.
  - User story link: Proves the new skill is discoverable and not over budget.
  - Depends on: Tasks 1-12
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Also run `python3 tools/shipglows_metadata_lint.py specs/sg-browser-general-browser-verification-skill.md skills/sg-browser/references/browser-evidence.md docs/technical/skill-runtime-and-lifecycle.md shipglows_data/workflow/playbooks/spec-driven-workflow.md` after relevant files exist.

## Acceptance Criteria

- [ ] AC 1: Given `/sg-browser https://example.com "verify Example Domain is visible"`, when runtime preflight passes, then the report includes the target URL, runtime status, observed text/snapshot evidence, verdict, and limits.
- [ ] AC 2: Given Playwright MCP config still falls back to `/opt/google/chrome/chrome` on Linux ARM64, when `sg-browser` starts, then it refuses browser evidence and routes to `/sg-fix BUG-2026-05-02-001`.
- [ ] AC 3: Given config is good but MCP still errors with `/opt/google/chrome/chrome`, when `sg-browser` runs, then it reports stale MCP process and asks for Codex/MCP reload before diagnosing the app.
- [ ] AC 4: Given the objective mentions Clerk, Supabase Auth, OAuth, callback, session, cookie, tenant, or protected route behavior, when `sg-browser` triages the request, then it routes to `/sg-auth-debug` instead of continuing as generic browser verification.
- [ ] AC 5: Given the target is a Vercel preview-push project without a confirmed deployment URL, when the user asks for browser validation, then `sg-browser` routes to `/sg-ship` then `/sg-prod` before treating preview evidence as authoritative.
- [ ] AC 6: Given a production URL and an objective that only requires reading page state, when `sg-browser` runs, then it avoids mutating actions and reports only redacted relevant evidence.
- [ ] AC 7: Given the requested check requires submitting a form, deleting, buying, publishing, sending an email, or changing account data, when no explicit approval exists, then `sg-browser` refuses or asks for approval and does not click through.
- [ ] AC 8: Given a visible pass but severe console or network failures, when `sg-browser` reports, then the verdict is partial or risky rather than clean pass.
- [ ] AC 9: Given a browser finding is actionable but narrow, when `sg-browser` finishes, then it routes to `/sg-fix <summary>` without writing `shipglows_data/workflow/BUGS.md` or `shipglows_data/workflow/bugs/` itself.
- [ ] AC 10: Given the user asks for a full manual user-flow QA log, when `sg-browser` triages, then it routes to `/sg-test` because durable test logging is out of scope.
- [ ] AC 11: Given a page-level browser check after `sg-prod` confirms a deployment URL, when `sg-browser` runs, then `sg-prod` remains the source of deployment truth and `sg-browser` remains the source of page observation.
- [ ] AC 12: Given a future agent opens `sg-help`, when it searches for browser verification, then `/sg-browser` is listed and its boundary with `/sg-auth-debug`, `/sg-test`, and `/sg-prod` is clear.
- [ ] AC 13: Given a future agent opens `skills/sg-browser/SKILL.md`, `skills/sg-browser/references/browser-evidence.md`, or touched technical docs, then the internal contract text is English and stable anchors remain English.
- [ ] AC 14: Given the active user/project language is French, when `sg-browser` produces a user-facing report, then the report is natural accented French while commands, anchors, and stable labels remain English.

## Test Strategy

- Unit: None, because this is a skill/doc workflow change without executable production code.
- Integration: Run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` after adding the skill.
- Integration: Run metadata lint for this spec, the new reference, and touched technical docs.
- Integration: Run targeted `rg` commands from the implementation tasks to prove routing language exists.
- Integration: Run `rg -n "[àâäçéèêëîïôöùûüÿÀÂÄÇÉÈÊËÎÏÔÖÙÛÜŸ]" skills/sg-browser/SKILL.md skills/sg-browser/references/browser-evidence.md docs/technical/skill-runtime-and-lifecycle.md shipglows_data/workflow/playbooks/spec-driven-workflow.md` after implementation; any match in internal contract prose must be justified as quoted user-facing text or localized example.
- Manual: After MCP reload if needed, invoke a safe browser check against `https://example.com` or a local disposable page and verify the report includes runtime, target, evidence, verdict, and limits.
- Manual: Simulate triage prompts for auth, preview-push, production mutation, stale MCP runtime, and French user-facing output without clicking unsafe actions.

## Risks

- Security impact: yes, because browser evidence can expose cookies, tokens, PII, private payloads, production data, or destructive actions. Mitigation: read-only defaults, redaction rules, no raw HAR/cookie/header dumps, no storage dumps, and explicit approval for mutations.
- Product/data risk: medium, because a general browser skill can overclaim readiness. Mitigation: narrow objective-based verdicts and handoff to `sg-test`, `sg-verify`, `sg-prod`, or `sg-auth-debug`.
- Runtime risk: medium, because stale Playwright MCP config can produce misleading failures. Mitigation: mandatory `playwright-mcp-runtime.md` preflight and explicit stale-process handling.
- Documentation risk: medium, because multiple skills already mention browser evidence. Mitigation: update routing docs and skill catalog together.
- Language-doctrine risk: medium, because the skill touches internal contracts and user-facing report text. Mitigation: internal contract prose in English, localized user-facing interaction, natural accented French when French is active, and explicit acceptance criteria.
- Scope creep risk: medium, because `sg-browser` could become a full QA framework. Mitigation: keep it one-off, read-only, evidence-focused, and route durable QA to `sg-test`.

## Execution Notes

- Read first: `GUIDELINES.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `docs/technical/code-docs-map.md`, `docs/technical/skill-runtime-and-lifecycle.md`, `skills/references/playwright-mcp-runtime.md`, `skills/sg-auth-debug/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-verify/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/sg-fix/SKILL.md`, `skills/sg-help/SKILL.md`.
- Use `skill-creator` guidance for concise skill design and progressive disclosure through references.
- Implementation order: create the new skill and reference first, then update routing in existing skills, then update README/workflow/technical docs, then run validation.
- Use existing ShipGlows skill patterns: frontmatter, canonical path loading, chantier classification, compact skill bodies, references for repeated detail, and explicit final `Chantier` blocks when tracing applies.
- Avoid new packages; this is a Markdown skill and documentation change built around existing MCP tools and ShipGlows references.
- Avoid broad rewrites to shared docs. Add narrow routing and documentation coherence changes only where the spec lists them.
- Preserve existing user edits and unrelated dirty worktree changes.
- Do not edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md` for this spec.
- Validate with: `python3 tools/shipglows_metadata_lint.py specs/sg-browser-general-browser-verification-skill.md`
- Validate after implementation with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- Fresh external docs: Context7 `/microsoft/playwright-mcp` checked on 2026-05-02; use official Playwright MCP docs if behavior changes before implementation.
- Stop conditions: Playwright MCP current docs contradict the assumed tool surface, the Linux ARM64 runtime fix is not accepted as canonical, the user decides to merge `sg-browser` back into `sg-auth-debug`, or the implementation cannot satisfy ShipGlows language doctrine without changing the requested public/user-facing behavior.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-02 05:53:05 UTC | sg-spec | GPT-5 Codex | Created draft spec for `sg-browser` general browser verification skill after context research across browser/auth/test/prod skills and Playwright MCP runtime docs | draft | /sg-ready sg-browser general browser verification skill |
| 2026-05-02 09:39:56 UTC | sg-ready | GPT-5 Codex | Reviewed readiness for the `sg-browser` general browser verification skill | not ready | /sg-spec sg-browser General Browser Verification Skill |
| 2026-05-02 09:46:41 UTC | sg-spec | GPT-5 Codex | Updated the spec to make the whole implementation contract English, add explicit ShipGlows language-doctrine requirements, and add language acceptance criteria | reviewed | /sg-ready sg-browser General Browser Verification Skill |
| 2026-05-02 09:46:41 UTC | sg-ready | GPT-5 Codex | Re-reviewed readiness after the language-doctrine correction and full English contract update | ready | /sg-start sg-browser General Browser Verification Skill |
| 2026-05-02 10:19:41 UTC | sg-start | GPT-5 Codex | Implemented the `sg-browser` skill, evidence reference, routing handoffs, public skill content, and focused validation checks | implemented | /sg-verify sg-browser General Browser Verification Skill |
| 2026-05-02 10:30:46 UTC | sg-verify | GPT-5 Codex | Verified the `sg-browser` skill contract, routing handoffs, metadata, docs coherence, Playwright MCP freshness, runtime preflight, and safe example browser evidence | verified | /sg-end sg-browser General Browser Verification Skill |
| 2026-05-02 11:36:16 UTC | sg-ship | GPT-5 Codex | Closed and shipped the `sg-browser` skill, Playwright MCP runtime guardrails, routing handoffs, public skill content, skills hub browser-evidence guide, and FAQ discoverability updates | shipped | None |

## Current Chantier Flow

- `sg-spec`: done, spec updated to an English internal contract with explicit language-doctrine requirements.
- `sg-ready`: ready.
- `sg-start`: implemented.
- `sg-verify`: verified.
- `sg-end`: not launched; full closeout handled by this `sg-ship end` run.
- `sg-ship`: shipped.

Next step: `None`
