---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: shipglows
created: "2026-09-05"
updated: "2026-10-16"
status: active
source_skill: sg-development
scope: flutter-configured-launch
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.FlutterConfiguration.ps1
  - cli/windows/ShipGlows.DevServer.psm1
  - tests/windows/flutter-configuration.ps1
depends_on: []
supersedes: []
evidence:
  - "Approved 2026-09-05: short app requests include declared authentication by default."
next_step: "Validate interactive login separately from configured runtime startup."
next_review: "2026-10-05"
---

# Flutter launch configuration

A request to launch an app includes its declared authentication and service
configuration. An agent must resolve that configuration, not require the user
to repeat Doppler, Dart defines or provider setup in each prompt.

The independent `.shipglows.backend.json` contract is also mandatory for every
managed launch, including Flutter. Backend readiness is checked before entering
this configuration resolver and before any session replacement. An explicit,
justified `none` backend exception does not waive this authentication recipe.
See the [Windows backend contract](operator-guides/windows-devserver.md#backend-obligatoire-au-lancement).
Backend availability, user login and protected API access remain separate proofs.

## Project recipe

An authenticated project declares `.shipglows.flutter.json` with exactly:

- `schemaVersion`: `shipglows.flutter-recipe.v1`.
- `configurationScript`: a project-relative Python resolver, no reparse paths.
- `doppler`: either the exact string `"NONE"` for an explicitly local configuration source, or exact `project` and development/staging `config`; no production.
- `publicDefines` / `publicEnvironment`: explicit public parameter allowlists.
- `requiredDefines`: nonempty required members of `publicDefines`.
- `forbiddenTrueDefines`: policy flags that must resolve to literal `false`.

The manager runs the declared resolver with `--configuration-json --target
windows|web|android`, adding `--web-origin` from the assigned port for Web. With
`doppler: "NONE"`, the resolver runs directly under Python and the recipe owner
is responsible for its local public configuration inputs. With a Doppler scope,
it uses Doppler `--no-fallback` and explicitly preserves disabled bypass policy
flags. No service secret is persisted. An unavailable provider/configuration
fails before a running session is stopped.

The resolver returns exactly `schemaVersion` (`shipglows.flutter-configuration.v1`),
`dartDefines` and `environment`. Both dictionaries contain only strings and
explicitly allowlisted public client parameters. Secret/password/token/private-key
fields are forbidden. The manager separates stdout from stderr and never echoes
resolver diagnostics or configuration values on failure. Provider/client/origin
coherence belongs to the project resolver; the runtime enforces the declaration.

The public Dart projection is written only in the owner-only ephemeral managed
launch directory and passed with `--dart-define-from-file`. Existing stop/cleanup
owns its lifetime. Public native parameters are passed to the child environment
(Android Gradle needs its Auth0 domain and scheme independently from Dart).
Doppler service credentials are neither serialized nor forwarded by this projection.

## Reuse and builds

Each managed start resolves the configuration again. The fingerprint includes
the recipe, resolver source, public configuration, target/device selection and
Web origin. It excludes only the volatile build-time fields `BUILD_TIMESTAMP`,
`BUILD_AT_UTC`, and `BUILD_AT_PARIS`, so refreshing a timestamp does not restart
an otherwise identical session. Matching sessions are reused; changed or pre-contract sessions are
stopped through managed process ownership and restarted after successful preflight.
The fingerprint is configuration evidence, not a credential or login claim.

A recipe supersedes a legacy `SHIPGLOWS_DART_DEFINE_FILE` reference, so ignored
checkout files cannot prevent a fresh authenticated launch. Known authentication
dependencies without a recipe fail with a declaration error. Projects without
those dependencies retain the existing no-auth path; legacy defines are validated
as JSON and cannot enable an authentication bypass or contain service secrets.

`s start -ProjectPath <app> -FlutterDevice windows|android|chrome|web-server`
selects an explicit target for this launch without rewriting `.shipglows.env`.
`-FlutterDeviceId` selects a particular Android device. Omission retains the
project's durable selection. Android fingerprints include the resolved device;
Web preflight pins the origin to the port that will actually be reserved.

`-FlutterMode debug|profile` selects the run mode of the same managed session
(`.shipglows.env` may declare `SHIPGLOWS_FLUTTER_MODE=debug|profile` durably;
`debug` is the default). `profile` runs `flutter run --machine --profile -d <device>`
through the same supervisor, Doppler wrapper and public-define projection as
debug, for performance measurement with Flutter attached. `--release` is never
a managed session; release artifacts stay with the build publisher. The mode is
part of the session fingerprint, so switching debug/profile restarts the session,
and the registry entry records `flutterMode` for `s status`. Flutter supports
neither hot reload nor hot restart in profile mode ("Restart is not supported in
profile mode"): the source watcher stays off and `s reload` refuses with the
`s restart` alternative, which rebuilds the profile session. `s stop` is unchanged.

The project's standalone build entrypoints use the same resolver. A debug app,
profile/release artifact and an authenticated interactive session are distinct
outcomes. Build artifacts still use the official artifact publisher after actual
successful builds. Short wording never authorizes a production Doppler scope or
provider-account changes.

## Verification

Run `tests/windows/flutter-configuration.ps1` with Windows PowerShell, plus the
background launch, supervisor, start-state and agent-instruction suites. Project
resolver tests must exercise missing configuration, wrong client/origin, bypass,
target/mode selection, native environment, and secret exclusion.

Report four separate facts: configuration checked, app running, interactive
login verified, protected API access verified. Neither compilation nor
`app.started` proves the last two. Config changes require managed revalidation;
hot reload alone is not a configuration refresh.

Existing authentication is mandatory. An auth-free local development exception
requires evidence that auth is not yet implemented and no protected data is
exposed; disclose the exception. Broken or missing configured auth requires
diagnosis and never authorizes bypass. A rendered login screen does not prove
login. Requested end-to-end validation requires login and protected-access proof
or the exact remaining limitation and user-only step.

`tests/windows/devserver-flutter-mode.ps1` covers the mode parameter end to end:
`.shipglows.env` parsing, supervisor arguments (`--profile`, never `--release`),
fingerprint invalidation, registry/status display and the profile reload refusal.

The focused configuration test covers missing recipes for known auth dependencies,
public projects without auth, disabled bypass flags, missing required values,
secret exclusion, unchanged/changed session fingerprints, failed preflight
preserving a live session, and archive/update/rollback inclusion of the helper.
The agent-instruction test verifies these guards reach every supported agent.
