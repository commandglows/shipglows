---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-10"
updated: "2026-06-10"
status: active
source_skill: 107-sg-test
scope: "manual-qa-workflow"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/107-sg-test/SKILL.md"
  - "shipglows_data/workflow/TEST_LOG.md"
  - "shipglows_data/workflow/bugs/*.md"
  - "shipglows_data/workflow/BUGS.md"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from 107-sg-test/SKILL.md during residual body-risk cleanup."
next_step: "none"
---

# Manual QA Workflow

Use this reference after the top-level `107-sg-test` activation contract has loaded project development mode and selected a scope.

## Scenario Families

Generate only scenarios that match the feature:

- Happy path: intended flow succeeds.
- Persistence path: reload, revisit, saved state, session, or stored data still works.
- Permission path: protected route, owner/admin/member, logged-out behavior.
- Error path: invalid input, missing dependency, declined auth, expired session, unavailable backend.
- Regression path: nearby flow that might have been broken.
- Retest path: exact reproduction steps from a known bug.

For auth, OAuth, callbacks, protected routes, cookies, or session persistence, include browser-level steps, reload checks, and direct protected-route checks. If the test fails, route to `109-sg-auth-debug` unless the bug is obviously unrelated to auth configuration or browser state.

## Flutter Proof Ladder

For Flutter app UI:

1. Ask for or run relevant widget/unit checks when practical.
2. Prefer agent-run Flutter Web smoke for shared UI flows such as add, edit, cancel, save, search, pin/unpin, onboarding, and settings visuals.
3. Route Web proof to `108-sg-browser` for non-auth UI and `109-sg-auth-debug` for auth/session/callback/protected-route behavior.
4. Use APK/device scenarios only for native-only behavior or after Web smoke passes and remaining risk is device-specific.

Native-only examples: IME/keyboard behavior, permissions, overlays, notifications, background services, native plugins, platform channels, file pickers, camera/mic, storage, install/update, and real-device performance.

## Production Safety

For production tests, keep steps read-only or reversible by default. Explicitly mark any step that creates data, sends email, triggers billing, deletes data, publishes content, or calls external services. Ask for confirmation before destructive or costly steps.

## Prompt Format

When first prompting the user, output only:

```text
## Manual Test: [feature]

Environment: [environment]
Goal: [one-line expected user outcome]

Steps:
1. ...
2. ...
3. ...

Report the result:
- PASS: [success condition]
- FAIL_ERROR: [error page/message]
- FAIL_LOADING: infinite loading or blocked pending state
- FAIL_REDIRECT: wrong route, loop, or sent back to login
- FAIL_DATA: missing, stale, duplicated, or wrong data
- FAIL_PERMISSION: user can/cannot access something incorrectly
- FAIL_UI: visible UI break, inaccessible control, or confusing state
- BLOCKED: could not run the test
- OTHER: describe what happened
```

Ask only for needed evidence: final URL or screen, visible error, data/session persistence after reload, account/role used when relevant, Sentry/support event ID, screenshot path, or copied console/network error.

## Reply Interpretation

Normalize the user's answer to `pass`, `fail`, `blocked`, or `not run`. Capture category, observed behavior, expected behavior, reproduction steps actually executed, environment, evidence supplied, confidence, and whether a bug should be opened.

If the reply is vague, ask one follow-up question before logging failure:

```text
Tu étais sur quelle URL ou quel écran au moment du blocage, et qu'est-ce qui était visible ?
```

## shipglows_data/workflow/TEST_LOG.md Entry

Right before editing `shipglows_data/workflow/TEST_LOG.md`, re-read it if it exists. If absent, create it. Append only this compact format:

```markdown
## YYYY-MM-DD - [Feature or Flow]

- Scope: [feature|spec|BUG-ID]
- Environment: [local|preview|prod|unknown]
- Tester: user
- Source: 107-sg-test
- Status: [pass|fail|blocked|not run]
- Confidence: [high|medium|low]
- Result summary: [one short line]
- Bug pointer: [none | BUG-ID -> shipglows_data/workflow/bugs/BUG-ID.md]
- Evidence pointer: [none | test-evidence/BUG-ID/... | external reference]
- Follow-up: [none | /106-sg-fix BUG-ID | /107-sg-test --retest BUG-ID | next command]
```

Rules:

- `shipglows_data/workflow/TEST_LOG.md` is a tracker, not a full bug file.
- Do not mark `pass` unless user or tooling confirmed the success condition.
- Use `blocked` when the user could not run the scenario.
- Use `not run` only for planned campaigns not executed.
- Do not paste long logs; keep only pointers.

## Bug File Model

When a scenario fails or `--retest BUG-ID` is used:

- `shipglows_data/workflow/TEST_LOG.md`: compact scenario history and pointers
- `shipglows_data/workflow/bugs/BUG-ID.md`: detailed Markdown source of truth
- `shipglows_data/workflow/BUGS.md`: optional compact/generated triage index when present or generated
- `test-evidence/BUG-ID/`: optional redacted large artifacts

Canonical statuses: `open`, `needs-info`, `needs-repro`, `in-diagnosis`, `fix-attempted`, `fixed-pending-verify`, `closed`, `closed-without-retest`, `duplicate`, `wontfix`.

## BUG-ID Generation

New IDs use `BUG-YYYY-MM-DD-NNN`.

Before assigning:

1. List `shipglows_data/workflow/bugs/BUG-YYYY-MM-DD-*.md`.
2. Re-read optional `shipglows_data/workflow/BUGS.md` and collect same-day suffixes.
3. Pick the next suffix greater than every suffix found.
4. Check whether `shipglows_data/workflow/bugs/BUG-ID.md` exists immediately before writing.
5. If it exists, re-read once, increment, and retry.
6. If collision repeats, stop and report collision.

Before creating a new bug, search for an open bug with clearly matching reproduction and observed behavior. Update the existing bug if clearly identical; otherwise create a new bug and add related links when useful.

## Bug File Updates

For a new bug, create from `templates/bug_record.md`. For existing bugs, append only; never erase history.

Keep current: Summary, Reproduction, Expected, Observed, Evidence, Diagnosis Notes, Fix Attempts, Retest History, and Redaction Status.

For `--retest BUG-ID`:

1. Read `shipglows_data/workflow/bugs/BUG-ID.md` and optional `shipglows_data/workflow/BUGS.md`.
2. Re-run reproduction steps.
3. Append one Retest History line.
4. On pass, set `fixed-pending-verify`.
5. On fail, set `open` or `needs-repro` when reproduction became unreliable.
6. Write only compact pointers in `shipglows_data/workflow/TEST_LOG.md` and optional `shipglows_data/workflow/BUGS.md`.

## Severity Defaults

- critical: data loss, payment, security, destructive action, privacy leak, total production outage
- high: login blocked, core workflow blocked, protected route broken, paid/core feature unusable
- medium: important workflow degraded with workaround
- low: cosmetic, copy, minor UI issue, non-blocking edge case

## Next-Step Routing

- all required scenarios pass: recommend `/103-sg-verify [scope]` if not already done, otherwise `/005-sg-ship`
- preview-push deployment required first: `/005-sg-ship [scope]`, then `/405-sg-prod [project or URL]`, then rerun `/107-sg-test --preview [scope]`
- bug opened: `/106-sg-fix [bug title]`
- auth/browser evidence needed: `/109-sg-auth-debug [bug title]`
- non-auth one-off browser evidence without durable manual log: `/108-sg-browser [URL or scope] [objective]`
- Sentry identifies likely runtime fault but no fix exists: `/106-sg-fix [BUG-ID or Sentry issue summary]`
- expected behavior unclear: `/100-sg-spec [scope]` or `/101-sg-ready [scope]`
- environment/deploy blocked: `/405-sg-prod` or project-specific deployment check

## Test Logged Report

After the user replies and logs are written:

```text
## Test Logged: [feature]

Result: [pass|fail|blocked|not run]
Scenario: [name]
Evidence: [short summary]

Files updated:
- shipglows_data/workflow/TEST_LOG.md (compact)
- shipglows_data/workflow/bugs/BUG-ID.md (bug file) [if applicable]
- shipglows_data/workflow/BUGS.md (optional compact triage index) [if applicable]
- test-evidence/BUG-ID/... [optional, redacted only]

Next step:
- [exact command]
```
