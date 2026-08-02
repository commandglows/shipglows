# 106-sg-fix

> Triage a bug quickly, decide whether it is safe to fix now, and either resolve it or route it into a stricter spec-first path.

## What It Does

`106-sg-fix` is the bug-first entrypoint for ShipGlows. It starts from the broken behavior, reconstructs the user story behind the bug, and decides whether the issue is small and local enough for a direct fix or too ambiguous to patch safely.

That matters because a “quick fix” can easily create a worse product problem if the bug touches permissions, workflow rules, data visibility, or cross-system behavior.

## Who It's For

- Solo founders dealing with production or QA bugs
- Developers who want fast triage without skipping product judgment
- Teams that need a safe fork between hotfixing and spec work

## When To Use It

- when you have a concrete bug report or failing behavior
- when you want rapid triage before opening a bigger workstream
- when it is unclear whether the fix is truly local
- when a small bug may hide a contract or security decision
- when an auth or protected-route bug may need browser-level diagnosis before patching
- when a non-auth browser bug needs visible, console, or network evidence before patching

## What You Give It

- a bug description, error message, or failing behavior
- ideally the observed behavior, expected behavior, and where it happens

## What You Get Back

- a classification: direct fix, spec-first, or diagnostic only
- a short rationale tied to the user story
- either a local fix or an exact next-step command
- explicit product, documentation, and security considerations
- a reroute to `109-sg-auth-debug` when the bug needs real browser-auth evidence
- a reroute to `108-sg-browser` when the bug needs non-auth browser evidence
- development-mode-aware retest routing, including `005-sg-ship` -> `405-sg-prod` before preview retests on Vercel-preview projects
- bug-file-driven handoff compatibility with `003-sg-bug` when the operator wants lifecycle execution from a `BUG-ID`

## Typical Examples

```bash
/106-sg-fix checkout button spins forever after payment
/106-sg-fix users can still access archived projects by URL
/106-sg-fix TypeError in dashboard load on first login
```

## Limits

`106-sg-fix` is not the right tool for broad feature redesign, migrations, or behavior that is still fundamentally undefined. In those cases it should route to spec work instead of guessing.

## Related Skills

- `100-sg-spec` when the bug needs a clear contract first
- `003-sg-bug` when a `BUG-ID` needs fix, retest, verify, close, or ship-risk execution
- `109-sg-auth-debug` when the broken behavior lives in Clerk, OAuth, redirects, or browser session state
- `108-sg-browser` when the broken behavior needs non-auth page, visual, console, or network evidence
- `102-sg-start` to execute the approved fix path
- `103-sg-verify` after a direct fix on important flows
- `005-sg-ship` then `405-sg-prod` before `107-sg-test --preview --retest BUG-ID` when the project requires Vercel preview-push validation
