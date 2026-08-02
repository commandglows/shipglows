# 109-sg-auth-debug

> Diagnose a broken authentication flow in a real browser with Playwright, then pinpoint the exact failure step instead of guessing from code alone.

## What It Does

`109-sg-auth-debug` is ShipGlowz's browser-auth diagnosis skill. It consumes the existing bug report or spec, reproduces the auth flow with Playwright when possible, and isolates where the flow breaks across UI triggers, Clerk/OAuth configuration, redirects, middleware, cookies, sessions, and post-login app behavior.

It is designed for cases where static code reading is not enough because the failure only becomes clear once the real browser flow runs.

It respects the project development mode: local projects can prove local auth flows locally, while Vercel preview-push projects must use `005-sg-ship` -> `405-sg-prod` before a preview auth result is treated as authoritative.

For public UI, visual, console, network, or non-auth navigation checks, use `108-sg-browser` instead. `109-sg-auth-debug` stays focused on auth, sessions, callbacks, cookies, tenants, providers, and protected routes.

## Who It's For

- Founders debugging login issues on their own apps
- Developers working on Clerk, OAuth, Google login, or protected app flows
- Teams that need reproducible browser-level evidence before fixing auth bugs

## When To Use It

- when login, callback, or session behavior is broken in the browser
- when a Clerk or OAuth bug needs real-flow reproduction
- when redirects, cookies, or middleware behavior look wrong
- when a spec or bug report exists but the exact browser failure point is still unclear
- after an auth fix to confirm the original break is actually gone

## What You Give It

- a bug description, spec, or failing auth flow
- ideally the environment, URL, provider, expected behavior, and observed behavior
- optionally existing repro steps or known error messages

## What You Get Back

- the exact failure point in the auth flow
- browser-level evidence: URLs, page state, visible errors, and useful network/console signals
- a primary diagnosis category tied to code or configuration
- the next recommended fix or verification step
- a clear distinction between local-only evidence and preview/prod-authoritative evidence

## Bundled References

- `references/clerk-tooling.md` for deciding when to use Clerk MCP, Clerk CLI, or Playwright for auth debugging
- `references/clerk-testing.md` for Clerk testing strategy with Playwright, Testing Tokens, test emails/phones, and dev-vs-prod caveats
- `references/clerk.md` for Clerk, Next.js middleware, redirects, sessions, and Google social connection through Clerk
- `references/supabase-testing.md` for Supabase testing strategy with the local stack, Mailpit, SSR cookies, and RLS-focused validation
- `references/supabase-tooling.md` for deciding when to use Supabase MCP, Supabase CLI, or Playwright for auth and platform debugging
- `references/vercel-tooling.md` for deciding when Vercel MCP or Vercel CLI is the right tool for deploy/runtime issues
- `references/google-oauth.md` for Google OAuth redirect rules, consent, provider errors, and automation limits
- `references/convex-tooling.md` for deciding when Convex MCP or Convex CLI is the right tool, especially for auth-config sync
- `references/convex-clerk.md` for Clerk identity propagation into Convex auth and protected functions
- `references/playwright-auth.md` for browser evidence collection, session strategies, and secret handling
- `references/astro-clerk.md` for Astro sites using `@clerk/astro`, SSR, middleware, and Account Portal
- `references/flutter-clerk-convex.md` for Flutter Clerk choices, the native Android Kotlin bridge contract, and Convex access
- `references/flutter-web-clerkjs-bridge.md` for the Flutter web ClerkJS bridge implementation pattern in other repos
- `references/python-convex.md` for Python scripts and jobs that call Convex
- `references/sdk-policy.md` for stable, beta, and unofficial SDK choices in the ShipGlowz stack
- `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/flutter-web-clerkjs-auth-pattern.md` as the cross-repo technical guide for implementing this pattern in Flutter web apps
- `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/tubeflow-youtube-oauth-nextjs-convex-pattern.md` as the cross-repo guide for YouTube OAuth through Next.js, Clerk, and Convex

## Typical Examples

```bash
/109-sg-auth-debug login with Google returns to sign-in page
/109-sg-auth-debug Clerk callback fails on staging after Google auth
/109-sg-auth-debug users authenticate but land on a blank dashboard
```

## Limits

- It does not guarantee a fully automated Google login flow.
- MFA, captcha, device approval, WebAuthn, and similar human-gated steps may block full automation.
- It is not the generic browser evidence path; non-auth page, visual, console, or network checks belong in `108-sg-browser`.
- It is a diagnostic skill, not a replacement for `106-sg-fix`, `102-sg-start`, or `103-sg-verify`.

## Related Skills

- `106-sg-fix` for quick bug triage and direct fixes
- `108-sg-browser` for non-auth page, visual, console, or network evidence
- `100-sg-spec` when the auth bug still lacks a clear contract
- `102-sg-start` to implement the chosen fix path
- `103-sg-verify` to confirm the repaired auth flow is ready to ship
- `405-sg-prod` if the issue only appears after deployment
- `005-sg-ship` then `405-sg-prod` before preview auth retests when the project uses Vercel preview-push validation
