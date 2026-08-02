# Flutter + Clerk + Convex Auth Debug Reference

Use this reference when a ShipGlows application is a Flutter app using Clerk, Convex, or both.

Sources checked:
- https://clerk.com/changelog/2025-03-26-flutter-sdk-beta
- https://clerk.com/docs/android/reference/native-mobile/auth
- https://clerk.com/docs/android/guides/configure/auth-strategies/social-connections/overview
- https://clerk.com/docs/android/guides/configure/auth-strategies/sign-in-with-google
- https://pub.dev/packages/clerk_flutter
- https://pub.dev/packages/clerk_auth
- https://pub.dev/packages/convex_dart
- https://docs.convex.dev/client/python
- https://docs.convex.dev/home

Last reviewed: 2026-08-02

## SDK Status

- `clerk_flutter` is Clerk-published but community-maintained and still beta. Current pub.dev version reviewed: `0.0.18-beta`.
- `clerk_auth` is the companion Clerk Dart package and remains beta. Do not treat either package as a stable, officially supported native Flutter contract.
- The package page warns that breaking changes should be expected before `1.0.0`; pin any use and record the accepted risk.
- `convex_dart` exists on pub.dev and provides Dart codegen/realtime APIs. Treat it as third-party unless Convex official docs explicitly list it as an official client.
- Convex official docs list Python, iOS Swift, Android Kotlin, JavaScript, React, Vue, Svelte, Node/Bun and other clients, but no first-party Flutter/Dart client in the reviewed docs.

## Recommended Default

- For Flutter web apps, prefer the ContentFlow pattern documented in `flutter-web-clerkjs-bridge.md`: official ClerkJS on app-domain auth routes plus Dart JS interop.
- For native Flutter apps that need Clerk today, avoid production reliance on `clerk_flutter` / `clerk_auth` unless the project explicitly accepts beta SDK risk; if used, pin versions carefully and test login on real target platforms.
- For Convex from Flutter, prefer a documented project decision:
  - use `convex_dart` with explicit acceptance of third-party dependency risk, or
  - expose a small official HTTP/API layer if auth-critical reliability matters more than realtime client convenience.
- For Google sign-in, prefer Clerk-managed social auth when using Clerk, and avoid hand-rolling direct Google OAuth unless the app has a strong reason.

## Native Android Flutter Bridge

When Flutter is the UI shell but Android needs a production native auth flow,
use Clerk's official Android API SDK from Kotlin behind a typed Flutter
MethodChannel. Do not reintroduce the beta Flutter/Dart SDK solely to cover
Android.

### Default contract — ContentGlowz browser OAuth (validated)

Use this contract for every new Flutter Android app unless the operator has
explicitly approved a documented departure: Google opens in the system browser
and Clerk returns to the APK with an active session. It is the only ShipGlows
Android Google path that has completed a real release-APK login on a physical
device.

- Pin `com.clerk:clerk-android-api:1.0.36` and keep the UI in Flutter.
- Launch Google with `Clerk.auth.signInWithOAuth(OAuthProvider.GOOGLE)`.
- Let the SDK's manifest-registered `SSOReceiverActivity` own the callback.
  Do not add a competing `MainActivity` callback handler or forward OAuth
  parameters through Flutter.
- With SDK `1.0.36`, the callback contract is exactly
  `clerk://<Clerk application id>.callback`. For package/application id
  `com.contentglowz.app`, allowlist exactly
  `clerk://com.contentglowz.app.callback` in the Clerk instance. The generic
  `{package}://callback` examples in some mobile documentation must not
  override the pinned SDK's actual manifest and source contract.
- Enable Clerk Native API, register the Android application, configure the
  **SHA-256** fingerprint of the release CI signer in Clerk Native applications,
  and enable the Google social connection for both sign-in and sign-up. Keep
  keys, fingerprints, and provider secrets out of the repository.
- Expose only typed operations such as `initialize`, `signInWithGoogle`,
  `restoreSession`, `getFreshToken`, and `signOut`; the bridge must never
  return raw callback URLs, OAuth codes, cookies, or tokens to logs.

The asynchronous boundary is part of the auth UX: while Clerk initializes,
restores a session, opens the browser, or completes the callback, show a
visible progress indicator and disable duplicate sign-in attempts. On timeout
or incomplete session, clear the pending state and expose a recoverable,
diagnostic error rather than leaving the entry screen apparently frozen.

### Non-default alternative — Credential Manager + Google ID token

Clerk also documents a different, browserless Android flow: Android Credential
Manager obtains a Google ID token and the app calls
`Clerk.auth.signInWithIdToken`. It is **not** a drop-in change to the default
contract. Do not select it for a new app merely because it exists: it requires
an explicit product reason, an approved departure record, a dedicated Flutter
bridge, and a signed-device validation before it can replace the default.

It needs separate Google Cloud configuration: an Android OAuth client using the
release **SHA-1** signing fingerprint, plus a Web OAuth client whose ID and
secret are configured in Clerk. This SHA-1 belongs to Google's Android client;
it does not replace the SHA-256 fingerprint required by Clerk Native
applications. Never mix Profile A callback setup and Profile B Credential
Manager setup in one first implementation.

### Reusable implementation contract

When scaffolding a new Flutter Android app with Clerk, use the default contract
and write this configuration record before coding:

```text
auth_profile: browser-oauth (ShipGlows default)
android_application_id: <exact Gradle applicationId>
clerk_android_sdk: <exact pinned coordinate and version>
callback_owner: <SDK activity | app activity, only if required>
mobile_redirect: <exact SDK-derived URI, Profile A only>
clerk_release_sha256: <CI signer fingerprint, Clerk Native applications>
release_apk_commit: <commit tested on device>
```

Then apply this sequence before writing the bridge:

1. Record the exact `com.clerk:clerk-android-api` version in Gradle. Inspect that
   version's AAR manifest/source for its callback owner and redirect constant;
   never infer a native callback from a generic web or Flutter example.
2. Keep Flutter responsible for the screen/state and expose a small typed
   MethodChannel (`initialize`, `signInWithGoogle`, `restoreSession`,
   `getFreshToken`, `signOut`). Keep OAuth callbacks in the Clerk Android SDK
   component registered by that version. A custom `MainActivity` callback is a
   defect unless the pinned SDK explicitly requires it.
3. In Clerk Dashboard, enable Native API, add the exact Android application id,
   and add the SHA-256 certificate fingerprint produced by the release CI
   signing job. Debug and release fingerprints are different; test artifacts
   must identify which one they use.
4. Add exactly the redirect URI derived in step 1 to **Allowlist for mobile SSO
   redirect**. For SDK `1.0.36`, the contract is
   `clerk://<Clerk application id>.callback`; for ContentGlowz this is
   `clerk://com.contentglowz.app.callback`. Do not add a competing
   `{package}://callback` URI just because it appears in current generic docs.
5. Prove the default native path in this order: cold start/session restore,
   one sign-in tap, provider completion, session activation, token retrieval,
   protected API call, app restart, and sign-out. Prove browser launch and
   return to the app. Record the tested APK commit and signing identity.

If a departure to Credential Manager is explicitly approved, add its separate
Google Android SHA-1 and Web OAuth client record at that time. It must not
change, delay, or complicate the default contract above.

This contract is version-scoped: if the Clerk Android dependency changes, repeat
step 1 and revalidate the redirect/manifest before shipping or updating the
blueprint.

## Files And Config To Inspect

- `pubspec.yaml`
- `lib/main.dart`
- root app auth/provider setup
- `AndroidManifest.xml` for `android.permission.INTERNET`
- iOS/macOS URL scheme or associated domain config if OAuth redirect depends on it
- any storage/persistor setup for Clerk auth state
- code passing session tokens to Convex or custom backend calls
- environment injection for publishable keys, Convex URL, and Google client ID

## Clerk Flutter Checks

- `ClerkAuth` wraps the app area that needs auth state.
- `ClerkAuthConfig` uses the correct publishable key for the environment.
- `ClerkErrorListener` exists where useful during debugging.
- `ClerkAuthBuilder` or equivalent signed-in/signed-out state is not bypassed by custom state.
- Android has `android.permission.INTERNET`.
- For Google token OAuth, `google_client_id` is present when required by the chosen implementation.
- `clerk_auth` session token polling behavior matches the package version. In `0.0.13-beta+`, token polling defaults changed compared with earlier beta versions.

## Convex From Flutter Checks

- Identify whether the app uses `convex_dart`, a custom HTTP layer, or generated API calls.
- If using `convex_dart`, confirm generated client files are up to date after Convex function changes.
- Confirm Flutter points to the correct Convex deployment URL for local/staging/prod.
- Confirm authenticated Convex calls receive a Clerk token or app-specific bearer token.
- Confirm type conversions and generated IDs match the Convex schema.
- For realtime issues, separate WebSocket connectivity from auth failures.

## Browser / Device Evidence To Capture

- Platform: Android, iOS, web, macOS, Windows, Linux.
- Package versions from `pubspec.lock`.
- Signed-in/signed-out state from Clerk UI or auth builder.
- Token/session polling logs in debug builds.
- Network calls to Clerk and Convex, redacted.
- Redirect URI or deep link observed during Google/OAuth flow.
- Whether the bug occurs on emulator, simulator, real device, Flutter web, or all targets.

## Common Failure Modes

- Beta SDK breaking change after loose version upgrade.
- Reintroducing the old Clerk Flutter beta path into a web app that should use ClerkJS bridge auth.
- Missing Android internet permission.
- Wrong publishable key for the environment.
- Auth state persisted in a platform path that does not work on the current target.
- Google OAuth flow works on web but fails on native due to redirect/deep link configuration.
- Session token exists in Clerk but is never forwarded to Convex/custom backend.
- Convex deployment URL points to dev while Clerk keys point to prod, or the reverse.
- `convex_dart` generated client is stale after backend function changes.
- Flutter web uses browser cookie/session assumptions that do not match native platforms.

## Debug Checklist

- Pin and record SDK versions before debugging.
- Confirm whether the dependency is official stable, official beta, or third-party.
- If the target is Flutter web, check whether the app should follow the ClerkJS bridge path instead of a Dart SDK path.
- Reproduce on the target platform where the bug was reported.
- Verify publishable key and Convex URL are from the same environment.
- Confirm Clerk signs in before debugging Convex.
- Confirm a session token reaches the backend before debugging app data.
- For Google login, capture redirect/deep link behavior and do not assume Playwright browser behavior equals native behavior.
- For Android native OAuth, record the exact stop point: before browser launch,
  provider page, callback return, Clerk session activation, or backend bootstrap.
- Confirm the installed APK commit is the one under test; a stale APK can make
  a corrected callback or SDK contract appear ineffective.
- After a fix, test cold start, sign-in, app restart, token refresh, sign-out, and one protected backend call.
