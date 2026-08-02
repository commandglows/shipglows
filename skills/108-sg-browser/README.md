# 108-sg-browser

> Open a URL in a real browser and verify one observable non-auth objective.

## What It Does

`108-sg-browser` is ShipGlows's generic browser evidence skill. It opens a local, preview, or production surface in a real browser and checks one concrete objective: visible state, layout, screenshot need, accessibility snapshot, console signal, or network signal.

The report is intentionally narrow. It names the target, environment, Playwright MCP runtime, requested objective, observed state, verdict, evidence, limits, and next ShipGlows command.

Use it when you need to know what the browser actually saw without opening a full manual QA campaign or stretching auth debugging into generic page checks.

## Who It's For

- Founders who need quick browser evidence before deciding what to fix
- Developers checking local pages, Vercel previews, or production routes
- Teams that want a clear boundary between page evidence, auth diagnosis, deployment checks, and manual QA logs

## When To Use It

- when a public page, preview, or production URL should display an expected state
- when a visual, console, network, screenshot, or accessibility snapshot check is enough
- when a browser finding should route to `106-sg-fix`, `107-sg-test`, `405-sg-prod`, `109-sg-auth-debug`, or `103-sg-verify`
- when `105-sg-check` or `103-sg-verify` says browser-observable non-auth behavior is still unproven

## What You Give It

- a URL, route, local page, preview URL, or production page
- one observable objective such as text appearing, a CTA rendering, a route loading, or a console/network condition
- optionally a viewport, screenshot preference, or interaction limit

## What You Get Back

- a real-browser observation for the requested objective
- a narrow verdict: `pass`, `fail`, `partial`, `blocked`, `needs-auth`, `needs-deploy`, `needs-manual-test`, or `unsafe-action`
- focused screenshot, snapshot, console, or network evidence when useful
- redacted output and explicit limits around what was not proven
- the next ShipGlows command when the finding belongs elsewhere

## Typical Examples

```bash
/108-sg-browser https://example.com verify Example Domain is visible
/108-sg-browser local homepage check that the pricing CTA renders
/108-sg-browser preview URL inspect console errors on /dashboard
/108-sg-browser production page verify the docs link is visible
```

## Limits

- It is read-only by default.
- It does not diagnose login, OAuth, cookies, sessions, callbacks, tenants, providers, or protected routes; use `109-sg-auth-debug`.
- It does not replace guided manual QA, retests, `shipglows_data/workflow/TEST_LOG.md`, bug files, or optional `shipglows_data/workflow/BUGS.md` triage views; use `107-sg-test`.
- It does not discover deployment URLs, inspect Vercel status, or read runtime logs; use `405-sg-prod`.
- It does not click destructive or production-mutating actions without explicit approval.

## Related Skills

- `109-sg-auth-debug` for auth, session, callback, cookie, tenant, provider, and protected-route evidence
- `107-sg-test` for durable manual QA, retests, and bug records
- `405-sg-prod` for deployment URL, runtime log, and live deploy confidence
- `106-sg-fix` when the browser finding is a narrow actionable bug
- `103-sg-verify` when browser evidence is needed before readiness can be claimed
