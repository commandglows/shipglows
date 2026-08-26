---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-08-26"
created_at: "2026-08-26 15:41:37 UTC"
updated: "2026-08-26"
updated_at: "2026-08-26 15:50:41 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: auth0-native-cli-toolbox
owner: Diane
user_story: "As the ShipGlows operator, I want the official Auth0 CLI installed and manageable like the other project services so Auth0 projects work on native Windows without WSL, duplicated tooling, or credential leakage."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.MobileToolchain.psm1
  - cli/windows/ShipGlows.Auth.psm1
  - cli/windows/install-devserver.ps1
  - tests/windows/mobile-toolchain.ps1
  - tests/windows/auth-playwright.ps1
  - shipglows_data/technical/installer-and-user-scope.md
  - shipglows_data/technical/external-platforms/auth0.md
depends_on: []
supersedes: []
evidence:
  - "Operator approval 2026-08-26: add Auth0 after the WSL and Turso installer work."
  - "Official Auth0 CLI release evidence checked 2026-08-26: v1.33.0 is a stable release with Windows x64 and arm64 archives and published checksums."
  - "The Aqua registry exposes auth0/auth0-cli with GitHub-release SHA-256 verification."
next_step: "Implement the ready contract with deterministic Windows fixtures and no real Auth0 authentication."
---

# Auth0 Native CLI Toolbox

## Status

ready — approved architecture and executable implementation contract.

## Minimal Behavior Contract

The Windows installer resolves one exact stable version of the official `auth0/auth0-cli` release through the existing mise/Aqua machine toolbox, writes a private ShipGlows wrapper, and reports its state. Installation never authenticates. The `s a` menu can inspect tenant login state and explicitly launch Auth0 login or logout. Auth0 failure remains isolated and cannot erase a previous valid toolbox or block unrelated provider CLI wrappers.

## Success Behavior

- Native Windows receives the official Auth0 CLI without WSL.
- The toolbox config pins an exact stable version under `aqua:auth0/auth0-cli`; `latest`, ranges, and prereleases are rejected from persisted configuration.
- `auth0.cmd` disables Auth0 CLI analytics for that invocation without changing user or machine environment variables.
- `s a` uses `auth0 tenants list --json-compact --no-input` for status, `auth0 login` for explicit login, and `auth0 logout` for explicit logout.
- Project inspection recognizes Auth0 dependencies in JavaScript and Flutter manifests and reports only the boolean capability need.
- Reruns reuse a valid exact toolbox and remain idempotent.

## Error Behavior

- Resolution, download, checksum, installation, version, or status failures mark Auth0 pending or unauthenticated with an actionable message.
- A failed Auth0 resolution does not rewrite a prior valid toolbox configuration and does not invalidate already available provider wrappers.
- No fallback downloads an unverified binary, invokes npm deploy tooling, opens a shell command surface, or infers login consent.
- Status output, logs, reports, fixtures, and documentation never persist tokens, client secrets, credentials, tenant configuration, or private callback data.

## Scope In

- Official Auth0 CLI in the native Windows machine toolbox through mise/Aqua.
- Exact stable-version resolution, wrapper generation, version verification, project detection, environment report, and `s a` integration.
- Deterministic PowerShell tests and mapped internal technical documentation.

## Scope Out

- Auth0 Deploy CLI, tenant import/export, resource mutation, application creation, user management, or deployment.
- Auth0 MCP/agent skills, browser automation, tenant configuration, real login/logout, credential creation, secret persistence, WSL installation, or application SDK migration.
- Installing or authenticating the CLI on this machine as part of the proof run.

## Constraints and Invariants

- The official binary and checksum path are owned by the Aqua registry; ShipGlows owns only exact-version policy, wrapper isolation, reporting, and lifecycle integration.
- Auth0 is independent of WSL even when a project also uses Turso.
- Authentication is always an explicit operator action after installation.
- The authentication menu uses a closed executable and argument registry; no arbitrary command, argument, tenant, domain, client ID, or path is accepted.
- The wrapper scopes `AUTH0_CLI_ANALYTICS=false` to its child process and never persists it globally.
- `operatorOnly` capabilities and generic shell execution remain outside SaaS projections.

## ZOMBIES Coverage

- Z: missing Auth0, missing network resolution, and unauthenticated state remain honest and non-destructive.
- O: one exact stable release installs, verifies, reports, and exposes the three closed authentication operations.
- M: repeated runs and multi-provider projects preserve deterministic order and isolated provider states.
- B: mutable versions, prereleases, unknown coordinates, extra authentication arguments, and unbounded project scanning fail closed.
- I: installer → mise/Aqua → wrapper → official CLI and `s a` → wrapper boundaries are explicit.
- E: resolver, checksum, install, version, and auth-status failures retain prior valid state and redact output.
- S: extend the existing toolbox and authentication registry; add no daemon, parallel installer, MCP, or deployment layer.

## OWASP Security Gate

- Categories considered: A03 Software Supply Chain Failures, A04 Cryptographic Failures, A05 Injection, A06 Insecure Design, A07 Identification and Authentication Failures, A09 Security Logging and Monitoring Failures, and A10 Mishandling of Exceptional Conditions.
- Trust boundaries: release metadata and checksums, mise/Aqua configuration, generated wrapper, Auth0 CLI process output, and local authentication state.
- Authorization: installation provisions a binary only; login and logout remain explicit operator actions and tenant mutation is absent.
- Secret handling: no token, domain, client ID, client secret, callback value, or command output is written to ShipGlows state or reports.
- Residual gap: a real authenticated tenant smoke test is intentionally deferred and must be separately approved.

## Implementation Tasks

1. Extend `ShipGlows.MobileToolchain.psm1` with Auth0 project detection, an allowlisted Aqua coordinate, stable-only exact pinning, and a wrapper-scoped analytics opt-out.
2. Extend `install-devserver.ps1` with independent Auth0 resolution, installation/version evidence, reuse state, and environment reporting without login.
3. Extend `ShipGlows.Auth.psm1` with closed status/login/logout arguments and no user-supplied command surface.
4. Extend the two focused Windows fixture suites for zero/one/many detection, stable-version boundaries, wrapper isolation, auth arguments, redaction, rerun, and failure isolation.
5. Add mapped Auth0 platform documentation, update installer/code ownership documentation, then run syntax, focused tests, metadata, diff, secret, and Git-scope proofs.

## Acceptance Criteria

- [x] Auth0 is pinned through `aqua:auth0/auth0-cli` to one exact non-prerelease version.
- [x] Native Windows installation has no WSL dependency and triggers no authentication.
- [x] Other provider tools remain usable when Auth0 resolution fails.
- [x] Auth0 analytics are disabled only inside the generated wrapper process.
- [x] `s a` exposes only the approved non-interactive status and explicit login/logout operations.
- [x] Project detection and environment reporting include Auth0 without exposing project configuration.
- [x] Deterministic focused tests pass without network, installation, browser, tenant, or credentials.
- [x] Technical documentation and code-doc ownership are coherent.
- [ ] Exact-scope commits are pushed without staging the unrelated business-document edit.

## Test Strategy

- Use temporary project manifests containing `auth0`, `@auth0/*`, and `auth0_flutter` markers.
- Feed exact version maps directly to toolbox planning; reject `latest`, ranges, unknown coordinates, and Auth0 prereleases.
- Inspect generated wrappers and assert the analytics variable exists only for Auth0.
- Inspect authentication definitions and assert exact commands and arguments contain no secret-bearing values.
- Parse PowerShell syntax and run focused fixture suites only; do not execute the real installer or Auth0 CLI.

## Documentation Coherence

- `installer-and-user-scope.md` owns installation scope, native-Windows behavior, authentication boundary, and failure semantics.
- `external-platforms/auth0.md` owns the Auth0-specific CLI/SDK/MCP/Deploy-CLI distinction and maintenance trigger.
- `code-docs-map.md` maps implementation surfaces to both documents.

## Execution Notes

- Topology: main-only; this is one cohesive Windows installer/authentication extension.
- Proof profile: scenario-first, mocked and local-only.
- Freshness: official Auth0 CLI release metadata and Aqua registry package definition checked 2026-08-26.
- No dependency installation, login, logout, WSL change, server, browser, application build, tenant mutation, deployment, or merge is authorized.

## Open Questions

None. The operator approved native Auth0 CLI installation, no WSL dependency, and continuation of the established ShipGlows toolbox model.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-26 15:41:37 UTC | 100-sg-spec | GPT-5 Codex | Authored the Auth0 native Windows toolbox and authentication contract from the approved system plan. | reviewed | Run readiness review. |
| 2026-08-26 15:41:37 UTC | 101-sg-ready | GPT-5 Codex | Confirmed exact targets, stable supply-chain policy, auth and telemetry boundaries, failure isolation, proof, and documentation ownership. | ready | Implement through `102-sg-start`. |
| 2026-08-26 15:50:41 UTC | 102-sg-start | GPT-5 Codex | Implemented the native Auth0 toolbox coordinate, stable pin, isolated wrapper, project detection, environment state, closed authentication operations, deterministic fixtures, and mapped technical documentation. | implemented | Run integrated local verification. |

## Current Chantier Flow

- `100-sg-spec`: complete — contract authored and adversarially reviewed.
- `101-sg-ready`: ready — no blocking ambiguity remains.
- `102-sg-start`: complete — implementation, fixtures, and mapped documentation are coherent.
- `103-sg-verify`: pending.
- `104-sg-end`: pending.
- `005-sg-ship`: pending.
