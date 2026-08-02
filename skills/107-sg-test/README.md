# 107-sg-test

> Turn finished work into guided manual test evidence, then capture bugs in a form the next agent can actually fix.

## What It Does

`107-sg-test` is the missing layer between "the agent thinks the work is ready" and "a human has tried the real user flow."

It guides the user through concrete manual test scenarios, asks for structured outcomes, and records what happened. When a test fails, the result becomes a reusable bug record instead of disappearing into chat history.

```text
100-sg-spec
  -> 101-sg-ready
  -> 102-sg-start
  -> 105-sg-check
  -> 103-sg-verify
  -> 107-sg-test
  -> 003-sg-bug or 106-sg-fix when a bug is found
  -> 107-sg-test --retest
  -> 005-sg-ship
```

The skill is not meant to replace automated tests. It covers the human-facing and browser-facing proof that is often missing from a green build: login, onboarding, redirects, protected pages, uploads, billing flows, generation flows, and other behavior where the real path matters.

## Who It's For

- Solo founders who need to test shipped work without writing a QA plan from scratch
- Developers who want a repeatable manual test protocol after implementation
- Teams that need bugs and retests captured as project memory, not scattered conversation

## When To Use It

- after `103-sg-verify`, before `005-sg-ship`
- when the feature has a visible user workflow
- when auth, payments, onboarding, uploads, data persistence, or redirects are involved
- after a bug fix, to retest the exact failed scenario
- when the user should be guided through what to click, observe, and report

## What You Give It

- the current task, spec, or recently implemented feature
- the environment to test, such as local, preview, or production
- optionally a specific flow, bug id, or retest target

## What You Get Back

- a focused manual test campaign
- step-by-step instructions for the user
- structured result choices such as pass, error page, infinite loading, wrong redirect, missing data, or custom observation
- a compact `shipglows_data/workflow/TEST_LOG.md` entry that records the campaign outcome
- a compact `shipglows_data/workflow/BUGS.md` entry when the reported result fails
- a detailed `shipglows_data/workflow/bugs/BUG-ID.md` bug file for the failing case
- a redacted `test-evidence/BUG-ID/` location when evidence is too large or sensitive for inline storage
- a clean route into `106-sg-fix` when the bug is actionable

## Checklist-first mode

When a ready spec declares a manual checklist under `shipglows_data/workflow/test-checklists/<scope>.md`, `107-sg-test` uses that checklist as the scenario source:

- parse the checklist artifact with `tools/shipglows_checklist_status.py` and prioritize required rows
- keep the existing `Observed`, `Evidence pointer`, and `Bug Link` fields in order
- escalate unresolved required rows as blockers before marking the run clean
- only add optional rows when they improve confidence and are clearly actionable

The objective is to make manual testing deterministic and auditable: no scenario drift between run and run, and no need to copy manual PASS/FAIL/BLOCKED status back into chat.

## Example: Google Auth

Instead of asking "does login work?", `107-sg-test` should guide the actual flow:

```text
1. Open the app in a private browser window.
2. Go to /login.
3. Click "Continue with Google".
4. Select the intended Google account.
5. Wait for the app callback to complete.
6. Confirm that the app lands on the expected page.
7. Reload the page.
8. Confirm that the session persists.
9. Open a protected route directly.
10. Confirm that access still works without logging in again.
```

Then it should ask for a structured result:

```text
Result?
- Login worked and session persisted
- OAuth or callback error page
- Infinite loading
- Returned to login after Google
- Logged in but protected route failed
- Wrong account, workspace, or destination
- Other observation
```

## Why It Matters

Without this step, a bug report often looks like this:

```text
User: "It does not work, I have a blank page."
Agent: keeps the detail in temporary context.
New session: the bug is effectively gone.
```

With `107-sg-test`, the same signal becomes project memory:

```text
Observation -> scenario -> result -> bug id -> fix -> retest history
```

That gives future agents the reproduction steps, expected behavior, environment, and history they need to act without making the user re-explain everything.

## Bug File Roles

ShipGlows uses a bug-file-first model:

- `shipglows_data/workflow/TEST_LOG.md` is the compact campaign log. It answers what was tested, when, and whether the run passed or failed.
- `shipglows_data/workflow/bugs/BUG-ID.md` is the detailed Markdown source of truth. It holds reproduction steps, expected and observed behavior, diagnosis notes, fix attempts, retest history, and closure criteria.
- `shipglows_data/workflow/BUGS.md`, when present, is an optional compact/generated triage index. It lists actionable bugs, status, severity, owner, and pointers to bug files.
- `test-evidence/BUG-ID/` stores redacted screenshots, logs, HAR, dumps, or other supporting material when the evidence is too large to keep inline.

The split is deliberate: the bug file holds durable detail, while the optional index stays scannable.

`shipglows_data/workflow/TEST_LOG.md` should record campaigns and scenario outcomes:

```markdown
## 2026-04-26 - Google Auth

- Scope: Google login through Clerk
- Environment: preview
- Status: fail
- Result summary: Infinite loading after Google callback
- Bug pointer: BUG-2026-04-26-001 -> shipglows_data/workflow/bugs/BUG-2026-04-26-001.md
- Follow-up: /106-sg-fix BUG-2026-04-26-001
```

`shipglows_data/workflow/BUGS.md` should record actionable defects as a compact index:

```markdown
- BUG-2026-04-26-001 | open | high | Infinite loading after Google callback | last-tested: 2026-04-26 | bug-file: shipglows_data/workflow/bugs/BUG-2026-04-26-001.md
```

The matching bug file lives in `shipglows_data/workflow/bugs/BUG-2026-04-26-001.md`, and any redacted evidence lives under `test-evidence/BUG-2026-04-26-001/`.

## Status Lifecycle

The canonical bug states are:

- `open`
- `needs-info`
- `needs-repro`
- `in-diagnosis`
- `fix-attempted`
- `fixed-pending-verify`
- `closed`
- `closed-without-retest`
- `duplicate`
- `wontfix`

Practical flow:

- `003-sg-bug` can read the bug state and continue the next safe lifecycle action through owner skills.
- `107-sg-test` opens or updates the bug file when a scenario fails.
- `106-sg-fix` reads the bug file and appends diagnosis and fix attempts.
- `107-sg-test --retest BUG-ID` appends retest history and moves the bug toward verification or closure.
- `103-sg-verify` checks whether the bug state still blocks the wider release decision.
- `005-sg-ship` uses the bug state to decide whether shipping is clean or partial-risk.

Evidence rules:

- keep screenshots, HAR, stack traces, logs, and dumps redacted before persistence
- store larger evidence under `test-evidence/BUG-ID/`
- never inline raw secrets, cookies, tokens, private data, or production PII in `shipglows_data/workflow/TEST_LOG.md`, optional `shipglows_data/workflow/BUGS.md`, or the bug file

## Typical Examples

```bash
/107-sg-test
/107-sg-test Google Auth
/107-sg-test --retest BUG-2026-04-26-001
/107-sg-test --prod onboarding flow
```

## Limits

`107-sg-test` depends on human observation for flows that cannot be safely or fully automated. It should not invent generic QA scripts detached from the spec, diff, acceptance criteria, or recent verification findings. It also must not log a pass or fail result before the user answers, unless the agent directly collected browser/tool evidence in the same run.

It records evidence; it does not prove the absence of every bug.

## Related Skills

- `103-sg-verify` before manual test planning
- `108-sg-browser` when a one-off non-auth browser proof is enough and no durable QA log is needed
- `109-sg-auth-debug` when auth failure needs browser-level diagnosis
- `003-sg-bug` when a `BUG-ID` needs lifecycle execution
- `106-sg-fix` when a failed test creates an actionable bug
- `005-sg-ship` once checks, verification, and testing are good enough
