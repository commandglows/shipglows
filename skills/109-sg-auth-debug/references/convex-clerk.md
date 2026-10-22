# Convex + Clerk Auth Debug Reference

Use this reference when the app uses Clerk for identity and Convex for backend data or realtime state. In the ShipGlows stack this means a Flutter app (primary) or an Astro site with client-side Convex calls.

Sources checked:
- https://docs.convex.dev/auth/clerk
- https://docs.convex.dev/auth/debug
- https://docs.convex.dev/auth/functions-auth
- https://docs.convex.dev/api/interfaces/server.UserIdentity
- https://clerk.com/docs/integrations/databases/convex
- https://clerk.com/docs/guides/development/customize-redirect-urls

Last reviewed: 2026-04-26

## Ideal Flow

1. User starts login in the app (Flutter) or on the Astro site.
2. Clerk authenticates the user through the configured method.
3. Clerk returns the user to the app, or the Flutter native flow completes the session (see `flutter-clerk-convex.md`).
4. The client sees the user as signed in in Clerk.
5. The client obtains the Clerk JWT expected by Convex, commonly the `convex` template. On Astro this is passed to the Convex JS client's auth setter; in Flutter it is sent as a bearer token on Convex HTTP calls.
6. The Convex client sends that token to the Convex backend.
7. Convex validates the token using `convex/auth.config.ts`, where `domain` must match the token issuer and `applicationID` must match the audience.
8. Convex auth state becomes authenticated, `ctx.auth.getUserIdentity()` returns an identity in protected functions, and the client renders protected content.

## Files And Config To Inspect

- `convex/auth.config.ts`
- Flutter: the root auth/provider setup and the code that attaches the Clerk token to Convex HTTP calls
- Astro: the client-side script where Clerk and the Convex JS client are initialized
- queries/mutations that call `ctx.auth.getUserIdentity()`
- deployment env for Clerk issuer and Convex deployment URL
- Clerk dashboard integration/JWT template for Convex, especially whether a `convex` token template exists
- Convex dashboard Authentication settings and deployed auth config

## Critical Config Checks

- `convex/auth.config.ts` must use the Clerk issuer/frontend API URL that matches the Clerk instance.
- If using `process.env.CLERK_JWT_ISSUER_DOMAIN`, confirm it exists in the Convex dashboard/environment for the deployed Convex backend.
- Confirm the app's frontend Clerk keys, Clerk dashboard instance, and Convex auth issuer all point to the same environment.
- Confirm the token is requested only after the Clerk session exists. On Astro, initialize the Convex client and set its auth in browser script, not during server rendering.
- Confirm `applicationID` matches the JWT audience. The common default is `convex`.
- Confirm `npx convex dev` or `npx convex deploy` synchronized new auth config.

## Browser And Device Evidence To Capture

- Whether Clerk UI shows signed-in state.
- Whether Convex-side UI still shows unauthenticated after Clerk login.
- Whether protected content renders after login.
- Console/network errors from Convex websocket or HTTP calls after login.
- Whether queries/mutations fail because `ctx.auth.getUserIdentity()` is null.
- Whether the app briefly authenticates and then drops back to unauthenticated after token refresh.
- WebSocket `sync` authenticate messages or HTTP requests with `Authorization: Bearer <jwt>`.
- Decoded JWT `iss`, `aud`, and `sub`, redacted before sharing.
- Temporary Convex server log of `await ctx.auth.getUserIdentity()` in one affected query/mutation.

## Common Failure Modes

- Clerk login succeeds but Convex still sees unauthenticated.
- `auth.config.ts` issuer does not match the Clerk instance used by the client.
- Convex deployment env is missing the Clerk issuer variable.
- App has correct local env but stale Convex dashboard env for staging/prod.
- Token requested before the Clerk session exists, or auth never set on the Convex client after sign-in.
- Protected UI gates on Convex auth while Clerk auth is still loading, causing false redirects or flashes.
- Convex queries assume identity is present without handling unauthenticated states.
- Convex client instance recreated on every navigation or render instead of kept stable.
- Wrong Clerk SDK package for the platform (`@clerk/astro` on Astro, the Clerk Flutter packages or the Android bridge in Flutter).
- JWT template is missing, misnamed, or has an audience that does not match Convex config.
- Local uses `pk_test` while Convex issuer points to prod, or prod uses `pk_live` while issuer points to dev.
- App stores users by `subject` alone instead of the globally stable `tokenIdentifier`.

## Debug Checklist

- First separate Clerk auth from Convex auth: is Clerk signed in on the device or in the browser?
- If Clerk is signed in but Convex is not, inspect the client auth wiring and `convex/auth.config.ts`.
- Confirm Convex deployment env, not only local `.env`.
- Check the client's auth state transitions: loading, unauthenticated, authenticated.
- Inspect one failing query or mutation and confirm whether `ctx.auth.getUserIdentity()` is null.
- Decode the JWT sent to Convex and compare `iss` with `domain`, `aud` with `applicationID`.
- Use `identity.tokenIdentifier` for stable app user mapping unless the project has a documented reason not to.
- If `null` occurs only during initial load, gate protected queries behind the client's authenticated state and handle loading explicitly.
- After a fix, test both UI rendering and at least one authenticated Convex operation.
