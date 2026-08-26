---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipGlows
created: "2026-08-26"
created_at: "2026-08-26 16:28:49 UTC"
updated: "2026-08-26"
updated_at: "2026-08-26 16:45:18 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: doppler-native-cli-and-agent-secrets
owner: Diane
user_story: "As the ShipGlows operator, I want coding agents to use Doppler safely for declared development and staging environments so project secrets stay out of repository files, logs, conversations, and SaaS command surfaces."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.MobileToolchain.psm1
  - cli/windows/ShipGlows.Auth.psm1
  - cli/windows/ShipGlows.AgentInstructions.psm1
  - cli/lib.sh
  - tests/windows/mobile-toolchain.ps1
  - tests/windows/auth-playwright.ps1
  - tests/windows/agent-instructions.ps1
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/installer-and-user-scope.md
  - shipglows_data/technical/external-platforms/doppler.md
depends_on: []
supersedes: []
evidence:
  - "Operator approval 2026-08-26: add Doppler for agents and development/staging environments."
  - "Official Doppler documentation checked 2026-08-26: native Windows and WinGet are supported, local login stores the CLI token in the Windows keychain, and Doppler run injects secrets into a child process."
  - "Official Doppler CLI release metadata checked 2026-08-26: 3.76.5 is stable and publishes Windows archives, SHA-256 checksums, and signatures."
  - "Credential-free Windows proof passed 2026-08-26: focused Doppler contracts, PowerShell parsing, metadata lint, diff hygiene, and the complete DevServer contract all exited successfully."
  - "Exact-scope commits b34fbc7, 7d505b7, and 8049dff were pushed to origin/codex/development-runtime; the unrelated business-document edit remained unstaged."
next_step: "Separately approve a real Windows installer smoke, operator login, and project-specific development/staging configuration before any live secret injection."
---

# Doppler Native CLI And Agent Secrets

## Status

reviewed — implemented, verified, documented, and pushed without provider mutation.

## Minimal Behavior Contract

The native Windows full installer provisions the official Doppler CLI through its vendor-recommended WinGet package, verifies the executable, exposes a stable runtime wrapper, reports availability and project declaration, and never authenticates. `s a` uses a closed redacted status/login/logout registry. Managed agent instructions permit Doppler only for an explicitly declared project environment and forbid printing, downloading, copying, or persisting secret values. Automatic Windows DevServer wrapping remains off until a project-specific dev/staging mapping is separately specified and proven.

## Success Behavior

- A valid existing Doppler executable is reused; otherwise WinGet installs `Doppler.Doppler` and `doppler --version` must succeed.
- `doppler.cmd` resolves the verified native executable for PowerShell-policy-safe agent access.
- `s a` checks `doppler me --json --no-check-version --no-read-env`, launches explicit `doppler login --no-check-version --no-read-env`, and confirms before `doppler logout --no-check-version --no-read-env`.
- Status output is discarded; ShipGlows receives only connected, disconnected, unknown, or unavailable state.
- Bounded project inspection detects only the presence of `doppler.yaml`, `.doppler.yaml`, or a package-script `doppler run` marker.
- Agent instructions allow `doppler run -- <project-declared command>` for a declared dev/staging scope and prohibit secret-value inspection or persistence.
- Environment reporting states CLI readiness and project declaration without workplace, project, config, scope path, token, or secret names/values.

## Error Behavior

- Missing WinGet, install failure, undiscoverable executable, or failed version probe leaves Doppler pending without blocking the existing machine toolbox or other CLIs.
- A project without a Doppler declaration never gains automatic secret injection.
- Ambiguous environment, project, config, or production intent stops before `doppler setup`, `doppler run`, or any secret operation.
- No fallback uses a curl installer, npm package, MCP server, raw token argument, secret download, secret listing, or value-bearing output.

## Scope In

- Native Windows CLI installation/reuse/verification through `Doppler.Doppler`.
- Stable wrapper, authentication registry, project presence detection, environment report, and managed agent doctrine.
- Read-only audit of the existing Linux Doppler outer-wrapper behavior and an explicit Windows parity boundary.
- Deterministic fixtures, mapped technical/provider documentation, changelog, closure, and ordinary branch push.

## Scope Out

- Real Doppler installation, login/logout, workplace/project/config selection, `doppler setup`, secret read/write/download, token creation/revocation, MCP, SaaS/browser exposure, CI credential changes, production activation, server launch, or deployment during proof.
- Automatic Windows DevServer `doppler run` activation without a later project-specific environment contract.
- Moving existing `.env` values, deleting files, or changing any managed project's Doppler configuration.

## Constraints And Invariants

- WinGet is the official recommended long-lived Windows installation path and supplies its package integrity manifest; ShipGlows neither downloads release archives nor invokes Doppler self-update.
- Credentials remain owned by Doppler and the Windows keychain. ShipGlows never reads `doppler configure get token`, accepts `--token`, or stores a token.
- `--no-read-env` prevents the ShipGlows auth-status surface from silently using an inherited `DOPPLER_TOKEN`; project execution retains provider-native environment semantics only when separately authorized.
- The SaaS capability contract exposes no generic Doppler command, secret operation, path, argument, or environment mapping.
- Dev, staging, and production scopes are never inferred or interchanged.

## ZOMBIES Coverage

- Z: missing CLI, missing manifest, unauthenticated state, and absent WinGet remain explicit and non-destructive.
- O: one verified CLI, one declared dev/staging project, and one closed auth definition work deterministically.
- M: repeated installs, multiple projects, and multiple agents keep independent project scope and one machine CLI.
- B: secret-shaped arguments, inherited token status, missing version evidence, malformed markers, and scan limits fail closed.
- I: installer → WinGet → native executable → wrapper → agent/project command and `s a` → Doppler keychain/API boundaries are explicit.
- E: installation, version, auth status, instruction replacement, and detection failures preserve prior valid state and unrelated tools.
- S: reuse the existing installer, auth registry, project detector, report, and managed instruction block; add no MCP, daemon, secret proxy, or generic executor.

## OWASP Security Gate

- Categories considered: A01 Broken Access Control, A02 Security Misconfiguration, A03 Software Supply Chain Failures, A04 Cryptographic Failures, A05 Injection, A06 Insecure Design, A07 Authentication Failures, A08 Software or Data Integrity Failures, A09 Security Logging and Alerting Failures, and A10 Mishandling of Exceptional Conditions.
- Trust boundaries: WinGet manifest/package, native executable, Windows keychain, inherited environment, project declaration, child-process environment, agent shell, logs, and Doppler API.
- Authorization: CLI availability grants no secret access; Doppler token permissions and explicit project/config scope remain authoritative.
- Selected ASVS requirements: no compliance claim; fixture proof covers local installer/auth/redaction boundaries, not the external tenant or project authorization model.
- Residual gap: real dev/staging access and Windows process injection require a separately approved project-specific smoke.

## Implementation Tasks

1. Extend the Windows installer with Doppler paths, official WinGet provisioning, executable verification, stable wrapper, isolated readiness, and environment reporting.
2. Extend project detection with presence-only Doppler markers and no configuration-value parsing.
3. Extend the authentication registry with exact status/login/logout arguments and output redaction.
4. Extend managed agent instructions with the declared-environment rule, safe `doppler run` boundary, and forbidden secret-output/persistence operations.
5. Extend focused Windows fixtures for zero/one/many detection, installation source and probe, wrapper packaging, auth arguments, inherited-token isolation, redaction, instruction idempotence, and failure isolation.
6. Add the Doppler provider note; update installer, runtime, code-doc map, technical index, changelog, spec evidence, then run complete Windows proof and exact-scope delivery.

## Acceptance Criteria

- [x] Doppler is installed only through the official WinGet package and must pass an executable version probe.
- [x] Installation triggers no login and cannot block unrelated provider tooling.
- [x] A stable wrapper makes Doppler callable by installed coding agents.
- [x] `s a` contains only redacted status and explicit login/logout operations with inherited-token isolation.
- [x] Project detection reports Doppler presence without reading configuration values.
- [x] Agent doctrine permits declared dev/staging execution while forbidding value output, download, persistence, token arguments, and ambiguous production use.
- [x] Automatic Windows DevServer injection and Doppler MCP remain absent.
- [x] Deterministic focused and complete Windows tests pass without credentials, provider mutation, installation, or application launch.
- [x] Mapped documentation is coherent and fresh official sources are recorded.
- [x] Exact-scope commits are pushed without staging the unrelated business-document edit.

## Test Strategy

- Parse every changed PowerShell surface.
- Use temporary manifests and managed instruction files; inspect strings and closed argument arrays.
- Use installer AST/static assertions and injected probes rather than calling WinGet or Doppler.
- Assert no forbidden token/config/secret values enter state, status objects, fixtures, reports, or wrapper arguments.
- Run the complete Windows contract with the known Git-Bash `PSModulePath` isolation required by this host.

## Documentation Coherence

- `external-platforms/doppler.md` owns provider installation, keychain, CLI/MCP, secret access, scope, and freshness rules.
- `installer-and-user-scope.md` owns native installation, wrapper, auth, and failure behavior.
- `runtime-cli.md` owns existing Linux outer-wrapper behavior and the explicit Windows non-automatic boundary.
- `code-docs-map.md` maps implementation and proof surfaces.

## Execution Notes

- Topology: main-only; the installer, auth, instructions, tests, and docs share tightly coupled security invariants.
- Proof profile: scenario-first and credential-free.
- Fresh-docs verdict target: `fresh-docs checked` from official Doppler CLI, Windows, secrets-access, configuration, MCP, service-token, and release sources.
- No secret, account, installation, login, MCP, project setup, runtime launch, staging/production change, deployment, merge, or unrelated file mutation is authorized.

## Open Questions

None. The operator selected agent access and dev/staging usage; automatic project execution remains gated by an explicit project declaration and later runtime proof.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-26 16:28:49 UTC | 100-sg-spec | GPT-5 Codex | Authored the native Doppler CLI, agent secret-use, and dev/staging boundary from the approved high-risk plan. | reviewed | Run readiness review. |
| 2026-08-26 16:28:49 UTC | 101-sg-ready | GPT-5 Codex | Confirmed provider authority, keychain ownership, closed auth, inherited-token isolation, agent rules, parity boundary, ZOMBIES, OWASP, proof, docs, and delivery. | ready | Implement through `102-sg-start`. |
| 2026-08-26 16:45:18 UTC | 102-sg-start | GPT-5 Codex | Added official WinGet provisioning, verified wrapper, redacted auth operations, bounded declaration detection, and managed agent rules. | complete | Verify focused and complete Windows contracts. |
| 2026-08-26 16:45:18 UTC | 103-sg-verify | GPT-5 Codex | Passed focused tests, PowerShell parsing, metadata lint, diff hygiene, and the complete Windows DevServer contract without credentials or provider calls. | passed | Close documentation and delivery evidence. |
| 2026-08-26 16:45:18 UTC | 104-sg-end | GPT-5 Codex | Confirmed the no-secret, no-MCP, no-automatic-injection boundary and recorded official provider freshness. | complete | Push exact-scope closure. |
| 2026-08-26 16:45:18 UTC | 005-sg-ship | GPT-5 Codex | Pushed the implementation and mapped documentation to `origin/codex/development-runtime` while preserving the unrelated local edit. | shipped | Request separate approval for live installation and login proof. |

## Current Chantier Flow

- `100-sg-spec`: complete — contract authored and adversarially reviewed.
- `101-sg-ready`: complete — no blocking ambiguity remained.
- `102-sg-start`: complete — safe native integration implemented.
- `103-sg-verify`: complete — credential-free focused and complete Windows proof passed.
- `104-sg-end`: complete — security, documentation, and freshness closure recorded.
- `005-sg-ship`: complete — exact-scope milestones pushed; live provider proof remains a separate chantier.
