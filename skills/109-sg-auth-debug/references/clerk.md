# Clerk Auth Debug Reference

Use this reference when a ShipGlows project uses Clerk: an Astro site with `@clerk/astro`, or a Flutter app (native or Flutter web) with Clerk. See `astro-clerk.md` and `flutter-clerk-convex.md` for platform-specific detail.

Sources checked:
- https://clerk.com/docs/astro/getting-started/quickstart
- https://clerk.com/docs/reference/astro/integration
- https://clerk.com/docs/guides/development/clerk-environment-variables
- https://clerk.com/docs/guides/custom-redirects
- https://clerk.com/docs/guides/configure/auth-strategies/social-connections/google
- https://clerk.com/docs/android/guides/configure/auth-strategies/sign-in-with-google
- https://clerk.com/changelog/2025-03-26-flutter-sdk-beta
- https://clerk.com/docs/guides/development/errors/frontend-api

Last reviewed: 2026-04-26

## Ideal Flow

1. The app initializes Clerk at its root: the `clerk()` integration plus `@clerk/astro/components` in the Astro layout, or `ClerkAuth` around the auth area in Flutter.
2. Public sign-in or sign-up route is reachable without route protection blocking it.
3. User starts sign-in from Clerk UI, Account Portal, or a custom flow.
4. For OAuth, Clerk redirects through the provider and receives the callback. On native Android, the callback is owned by the Clerk Android SDK component (see `flutter-clerk-convex.md`).
5. Clerk completes the auth process, creates or resumes the session, and sets the expected browser or app state.
6. App redirects to the intended post-login URL from `redirect_url`, force redirect, fallback redirect, or provider defaults.
7. Protected routes see an authenticated Clerk state through Astro middleware or server helpers, or through Flutter auth state, and the session token reaches Convex when backend calls need it.

## Files And Config To Inspect

- Astro:
  - `astro.config.mjs` (`clerk()` integration and its options)
  - `src/middleware.ts` or root `middleware.ts` (when not using `/src`)
  - layouts importing `@clerk/astro/components`
  - pages that render signed-in or signed-out content
  - sign-in and sign-up pages, and any custom OAuth callback route
- Flutter:
  - `pubspec.yaml` (pinned Clerk package versions)
  - `lib/main.dart` and the root auth/provider setup
  - `ClerkAuth` / `ClerkAuthConfig` usage and signed-in/signed-out builders
  - `AndroidManifest.xml` (INTERNET permission, callback components)
  - iOS/macOS URL scheme or associated domain config when OAuth depends on it
  - storage/persistor setup for Clerk auth state
  - code passing session tokens to Convex or custom backend calls
- `.env*`, deployment env, and dashboard config:
  - Astro: `PUBLIC_CLERK_PUBLISHABLE_KEY`, `CLERK_SECRET_KEY`, and the integration redirect options
  - Flutter: the publishable key and Convex URL injected for the target environment

## Middleware And Route Protection Checks

- Astro: confirm `clerkMiddleware()` is exported as `onRequest` from the middleware file, at the location the project layout expects.
- Astro: confirm protected routes are explicitly matched and protected in code. `clerkMiddleware()` does not protect all routes by default; apps must opt in.
- Astro: confirm sign-in, sign-up, OAuth callback, static assets, and integration routes are not accidentally protected.
- Astro: if the app protects everything by default, explicitly keep the sign-in and sign-up routes public.
- Astro: confirm the protection covers the pages and API endpoints that rely on auth state.
- Astro: in dev only, consider temporary debug logging on the middleware, if the installed `@clerk/astro` version supports it.
- Flutter: confirm signed-out screens are gated by `ClerkAuthBuilder` or an equivalent signed-in state, and that Convex calls only run after a session exists.

## Redirect Checks

- Identify the first requested URL, sign-in URL, OAuth callback URL, and final URL.
- Check whether `redirect_url` is present in the URL and whether it is preserved.
- Check force redirect settings before fallback settings. Force redirect wins over user-intended return flows.
- Check that server-side redirects in Astro middleware or pages only use configured URLs.
- If the app returns to `/` instead of the dashboard, suspect missing fallback redirect config.
- If the app loops back to sign-in, suspect session not established, callback not handled, or middleware protecting the callback/return path.
- Prefer the current fallback and force redirect settings (Astro: `signInFallbackRedirectUrl` integration option and its counterparts). Treat older after-sign-in patterns as legacy unless the app version requires them.

## Google Social Connection Through Clerk

- Development Clerk instances can use Clerk-provided shared Google OAuth credentials and redirect URIs.
- Production should use custom Google credentials and the corresponding Clerk Authorized Redirect URI.
- In the Clerk dashboard, Google should be enabled for sign-up and sign-in if users must authenticate with it.
- Google sign-in is not allowed in WebViews. Treat in-app browsers as a platform limitation unless a supported setup is explicitly configured.
- Google OAuth apps in Testing mode are limited; production apps should use a Google OAuth app with publishing status set to production when required.
- Native Android Google sign-in follows the callback contract in `flutter-clerk-convex.md`, not web redirect assumptions.

## Browser And Device Evidence To Capture

- Initial URL and final URL (Astro/web), or the screen and route sequence (Flutter).
- Whether the sign-in page renders Clerk UI or Account Portal correctly.
- Whether clicking Google starts an external redirect or fails in-place.
- Whether the callback route renders or immediately redirects.
- Visible Clerk or provider error text.
- Network statuses for sign-in, callback, and protected route requests.
- Console errors around missing Clerk keys, invalid publishable key, hydration/provider failure, or failed prefetch.
- Cookies after login (web): presence, domain, `Secure`, `SameSite`, and expiry for Clerk-related cookies.
- Server logs showing auth helpers running on a route that the Clerk middleware did not cover.
- For Flutter: platform, pinned package versions from `pubspec.lock`, and the evidence list in `flutter-clerk-convex.md`.

## Common Failure Modes

- Missing or wrong publishable key (`PUBLIC_CLERK_PUBLISHABLE_KEY` on Astro, the `ClerkAuthConfig` key in Flutter).
- Secret key configured locally but missing in preview/production.
- Mixed key families, such as `pk_test_` with `sk_live_` or `pk_live_` with `sk_test_`.
- Middleware protects the sign-in, sign-up, callback, or return route.
- Middleware matcher is too broad or misses API endpoints that need auth.
- Astro server auth expected without `output: "server"` or an SSR adapter.
- Astro middleware file placed in the wrong directory for the project layout.
- Assuming `clerkMiddleware()` protects all routes.
- Redirect settings point to an old route or wrong environment domain.
- Sign-in URL or Account Portal configured outside the current primary app unexpectedly.
- Force redirect hides the intended `redirect_url`.
- Custom OAuth flow forgets to render Clerk's OAuth callback component on the configured callback route.
- Production Google social connection uses the wrong Google OAuth credentials or redirect URI.
- Google OAuth app remains in Testing mode and the user is not allowed.
- Env changes were made in the hosting provider but the site was not rebuilt and redeployed (Astro `PUBLIC_*` values are baked in at build time).
- Session cookie is absent because of domain, HTTPS/local mismatch, subdomain, or authorized party configuration.
- Asset or route `404` interacts badly with middleware or the root layout and surfaces as an auth error.
- Sign-in UI renders while already signed in and redirects according to Clerk session settings.
- Flutter: beta `clerk_flutter` / `clerk_auth` upgraded loosely, causing breaking changes.
- Flutter Android: a custom `MainActivity` callback handler competes with the Clerk SDK callback component.

## Debug Checklist

- Identify whether the failure occurs before provider redirect, at provider, at Clerk callback, after session creation, or inside app protection.
- Confirm the platform (Astro site or Flutter app) and the pinned `@clerk/astro` or Clerk Flutter package versions.
- Verify env keys are from the same Clerk instance as the dashboard/provider config.
- Verify sign-in, sign-up, and callback routes are public.
- Verify the protected route matcher only matches intended app areas.
- Verify post-login redirect settings and URL params.
- Test once in a clean browser profile or private context to separate stale cookie state from app behavior.
- For web/Astro, use Playwright to capture URL transitions and visible errors before reading too much code. For Flutter native, capture the stop point on a real target device.
- After a fix, retest the original URL and the protected destination, not only the login page.
