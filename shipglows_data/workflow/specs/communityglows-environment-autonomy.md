---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.5"
project: ShipGlows
created: "2026-09-01"
created_at: "2026-09-01 10:17:36 UTC"
updated: "2026-09-01"
updated_at: "2026-09-01 11:50:44 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5.6 Codex
scope: CommunityGlows Windows environment installation and activation autonomy
owner: Diane
user_story: "As a CommunityGlows developer on Windows, I want the ShipGlows CLI and DevServer to detect, plan, install with explicit consent, activate, and verify every required local dependency so that extension, site, and Tauri work can proceed from a fresh process without manual toolchain repair or false readiness."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/environment/core.py
  - cli/environment/preparation.py
  - cli/environment/mise_backend.py
  - cli/environment/shipglows_environment.py
  - cli/environment/schemas/shipglows-environment-v1.schema.json
  - cli/windows/shipglows-devserver.ps1
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/ShipGlows.MobileToolchain.psm1
  - cli/windows/install-devserver.ps1
  - tests/environment/
  - tests/windows/
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/architecture.md
  - shipglows_data/technical/installer-and-user-scope.md
  - shipglows_data/technical/operator-guides/windows-devserver.md
  - shipglows_data/technical/code-docs-map.md
  - C:/Users/Diane/ShipGlows/communityglows
depends_on:
  - artifact: shipglows_data/workflow/specs/shipglows-reproducible-environment-control-plane.md
    artifact_version: "1.8.1"
    required_status: active
  - artifact: shipglows_data/technical/runtime-cli.md
    artifact_version: "1.36.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator approval 2026-09-01: validate the complete CommunityGlows dependency installation and activation flow, then push, synchronize the Windows runtime, and perform the real smoke tests."
  - "Read-only source audit 2026-09-01: `s env apply` is executable only for the bounded Node 24 plus pnpm 10 mise pilot and has no Rust, Cargo, rustup, Tauri, MSVC, or WebView2 backend."
  - "Read-only CommunityGlows plan 2026-09-01: Cargo and Tauri are blocked, Node and pnpm are non-executable pending operations, and the plan reports no consent, download, or network effect."
  - "Read-only preparation audit 2026-09-01: CommunityGlows preparation proposes Cargo, Node, pnpm, and web but omits the Tauri target, which would be lost after inferred-to-explicit management transition."
  - "Synthetic redaction proof 2026-09-01: the Python environment redactor preserves a contextual Authorization Bearer canary even though the PowerShell DevServer redactor removes it."
  - "CommunityGlows manifests pin Node 24.0.0 through .node-version/.nvmrc/.tool-versions, require Node >=24 <25, pin root pnpm 8.11.0 with lockfile v6, and use npm 11.14.1 plus npm ci for the site."
  - "CommunityGlows manifests pin Tauri CLI 2.11.4, API 2.11.1, Rust crate 2.11.5, tauri-build 2.6.3, and Rust MSRV 1.88.0; Windows bundling requires Rust/Cargo/rustup, stable MSVC, Windows SDK, and WebView2."
  - "The installed-runtime Rust path already provisions Rust 1.97.1 through isolated mise and writes cargo/rustc/rustup wrappers, but it is Android-centric, not connected to `s env`, and lacks fresh-process parity proof."
  - "The DevServer registry assigns CommunityGlows root port 3006 and site port 3000; both are stopped and have no lastError."
  - "Application Control previously blocked native Node binding oxc-parser for extension builds; this is an external policy outcome and must not be misclassified as a CLI defect or bypassed."
next_step: Deliver the exact verified source diff in Milestone 5 without staging concurrent or unrelated paths.
---

# CommunityGlows Environment Autonomy

## Title

CommunityGlows Environment Autonomy

## Status

Ready for sequential implementation. The adversarial review found no unresolved product, platform, security, ownership, or proof decision; implementation, installation, push, runtime synchronization, and live builds have not started.

## User Story

As a CommunityGlows developer on Windows, I want the ShipGlows CLI and DevServer to detect, plan, install with explicit consent, activate, and verify every dependency required by the root extension, Astro site, and local Tauri application, so that a new PowerShell or agent process can work without manual PATH repair, false success, or confusion between external Windows policy blocks and ShipGlows defects.

## Minimal Behavior Contract

Given the CommunityGlows repository, `inspect` must identify the required Node, root pnpm, site npm, Rust, Cargo, rustup, local Tauri CLI, MSVC/Windows SDK, and WebView2 capabilities without mutation; `plan` must produce a deterministic, reviewable set of independent operations with exact effects and explicit consent; `apply` must execute only the approved digest through trusted fixed-argument adapters; and a fresh process followed by `verify` and `status` must report `ready` with exit code `0` only when every applicable capability is actually usable. Missing, declined, incompatible, blocked, stale, or partially installed capabilities remain non-ready with exit code `4`, while invalid input and refused application retain codes `2` and `3`. The easy-to-miss case is a tool that works in the installer process but is absent or resolves to a different version in the new user or agent process.

## Success Behavior

- `inspect` and `plan` exit `0`, do not create environment state, do not initialize DevServer state, and accurately separate root pnpm from site npm ownership.
- The approved apply flow can acquire or reuse the trusted ShipGlows-managed Rust toolchain, expose cargo/rustc/rustup through the official runtime command path, and preserve project manifests and lockfiles.
- Version evaluation proves Node `>=24.0.0 <25`, root pnpm `8.11.0`, local Tauri CLI `2.11.4`, Rust `>=1.88.0` at the ShipGlows validated coordinate, and the host prerequisites required by the selected Tauri Windows target.
- A newly spawned managed PowerShell and an agent-like child resolve the same intended commands and versions; `verify` records this evidence and `status` returns it without probing.
- The root and site remain registered on durable ports `3006` and `3000`; starting one surface neither reallocates nor conflates the other.
- After source proof, exact-scope Git delivery, installed-runtime synchronization, and source/runtime parity proof, the real CommunityGlows extension, site, and Tauri build lanes are attempted and reported independently.

## Error Behavior

- Refused consent, absent trusted installer, unavailable network, timeout, non-zero provider exit, unexpected version, restart requirement, stale plan, changed executable identity, partial install, missing fresh-process command, or unavailable MSVC/WebView2 keeps the relevant capability non-ready and blocks dependent Tauri work.
- A failure never triggers another backend, elevation, policy change, Windows restart, project migration, package upgrade, or fallback version silently.
- Application Control blocking `oxc-parser` is reported as an external Windows policy block with the affected Chrome/Firefox lane; ShipGlows must not change policy or claim the CLI installer failed unless its own operation failed.
- Missing `VITE_CONVEX_URL` blocks only the release lane that requires it, is reported without printing its value, and never causes secret discovery or production-scope inference.
- No error, plan, state, registry entry, attestation, log excerpt, or CLI exception may retain the value from `Authorization: Bearer <token>`, Basic credentials, secret-shaped keys, credentialed URLs, or the defined canary corpus.
- A successful installation command without final observation is `pending`, never `ready`.

## Problem

CommunityGlows is correctly inferred as a managed Windows project, but the current control plane is diagnostic rather than autonomous. Generic constrained tools are always observed as `unknown`; the Tauri target has no active observer; and generic apply refuses every plan outside the exact Node 24 plus pnpm 10 pilot. The separate full Windows installer can create a Rust toolchain and wrappers, but that path is Android-oriented, selects one Tauri candidate from a whole workspace, is not connected to the project environment plan, and is not proven in a new process. Preparation can also convert the inferred project into an explicit manifest that omits Tauri. These gaps make `ready` unreachable and conceal version mismatches such as a global pnpm 11.x versus CommunityGlows pnpm 8.11.0.

## Solution

Extend the thin environment control plane with composable Windows capability adapters rather than another package manager. Preserve native ownership: package manifests and lockfiles define project versions; ShipGlows isolated mise owns its validated Rust toolchain; Windows owns MSVC, the SDK, and WebView2; the local package owns the Tauri JavaScript CLI. Planning composes all required operations without allowing one adapter to erase another capability. Application remains digest-bound and consent-gated. Observation evaluates supported version constraints and proves the effective command from fresh user and agent processes. The DevServer consumes readiness and durable port truth but does not masquerade an extension start as a Tauri build.

## Scope In

- Contextual secret redaction shared by Python environment outputs and PowerShell DevServer diagnostics.
- CommunityGlows inference and preparation for Node, pnpm, npm, Cargo, rustup/Rust, Tauri Windows, MSVC/Windows SDK, WebView2, and Linux-only Flox evidence.
- Deterministic composable plan/apply operations, approval digest, executable identity, effects, refusal, partial failure, retry, and post-apply observation.
- Supported constraint evaluation for the exact CommunityGlows Node, pnpm, Tauri, and Rust coordinates.
- Reuse of the validated ShipGlows Rust 1.97.1 isolated mise toolchain and runtime wrappers where compatible.
- Fresh-process activation proof for managed PowerShell and an agent-like child.
- Exact semantic exit codes: ready/unmanaged `0`, invalid `2`, apply refusal `3`, managed non-ready `4`.
- DevServer integration and parity for root `3006` and site `3000` without introducing a fake Tauri web surface.
- Focused and full contract tests, documentation alignment, exact-scope commit/push, runtime synchronization, live CommunityGlows smoke, Tauri Windows bundle, and official local artifact registration after a successful release build.

## Scope Out

- Installing or changing Rust, Cargo, rustup, MSVC, WebView2, Node, pnpm, npm, or Windows policy before source code and fixture proof pass.
- Bypassing Application Control, changing antivirus/security policy, disabling UAC, or automatically restarting Windows.
- Changing CommunityGlows source, dependencies, package pins, lockfiles, README, Tauri configuration, or environment secrets as part of the CLI implementation.
- Tauri Android/iOS initialization or migration; the selected live acceptance target is native Windows desktop.
- Production Doppler configuration, secret retrieval, authentication, or inference of a production environment.
- Force push, broad dirty-worktree staging, unrelated cleanup, or modification of the pre-existing untracked optional-dotfiles specification.

## Constraints

- Preserve all unrelated dirty work and stage only task-owned paths.
- Internal contracts and documentation use English; user-facing CLI diagnostics remain concise, actionable, and redacted.
- Repository files are untrusted data. Never execute repository-provided command names or scripts during `inspect` or `plan`.
- Executable apply operations use fixed argv, trusted roots, executable identity binding, bounded output/timeouts, minimal inherited environment, and exact plan/source digests.
- Consent is explicit and non-transferable across a replan; acquisition requiring elevation remains a separate approved operation when appropriate.
- Flox remains evidence but is incompatible as a native Windows owner.
- Local package installation uses the declared manager: root pnpm 8.11.0 and site npm 11.14.1/npm ci. Do not rewrite `npm ci` into tokenized `npm c i`.
- Documentation Freshness Gate: implementation must recheck current official Tauri Windows prerequisites, Rust/rustup, mise, WebView2 Runtime, and Visual Studio workload guidance before provider code or claims; any conflict pauses the affected milestone.

## Test Contract

- Surface/profile: Windows x64, source checkout first, disposable project/state/runtime roots, then installed runtime, then real CommunityGlows.
- Proof order: pure parser/redaction tests -> fake structured-runner plan/apply tests -> isolated PowerShell fresh-process tests -> complete source contract suites -> exact commit/push -> installed-runtime sync/parity -> real CommunityGlows verify/status -> extension/site/Tauri builds -> artifact registration.
- No live provider, installation, elevation, network package acquisition, policy mutation, or build occurs in fixture milestones.
- Manual proof is limited to visible provider/UAC consent if requested by the approved apply operation and any unavoidable Windows installer UI; command and final observation evidence remain machine-readable.
- Required live evidence: exact command path/version from a new managed PowerShell, exact path/version from an agent-like child, environment state/attestation, DevServer registry entries, build exit codes, output artifact existence, and official artifact registry entry.
- Security proof uses synthetic canaries only and asserts both the redaction marker and preservation of useful non-sensitive context.

## Dependencies

- Existing reproducible environment control-plane schemas, state storage, structured mise runner, and digest-bound approval semantics.
- Existing Windows isolated Tauri Rust baseline and wrapper implementation.
- Managed PowerShell/runtime bin activation and official Windows runtime synchronization path.
- CommunityGlows native manifests and lockfiles as read-only version truth.
- Windows Visual Studio Installer/vswhere, Windows SDK state, and WebView2 Runtime state as host-owned evidence.
- `VITE_CONVEX_URL` supplied through the project-declared development path when the release build requires it; value disclosure is forbidden.

## Invariants

- `ready` is derived only from current observation of every applicable capability and consumer process.
- `inspect`, `plan`, and `status` are non-mutating; `verify` mutates only private environment evidence; `apply` mutates only approved backend/runtime targets.
- Project manifests and lockfiles remain unchanged during environment installation and activation.
- Source and installed runtime implement the same schemas, adapters, redaction, exit codes, and command behavior before live proof.
- External Windows blocks and unavailable toolchains are classified separately from CLI defects.
- Root and site durable ports remain `3006` and `3000`; port values come from the DevServer registry.
- Local and CI artifact lanes remain distinct; a successful local Windows release is registered through the official build-artifact command and reported through the refreshed official Desktop shortcut.

## Links & Consequences

- Upstream: `shipglows-reproducible-environment-control-plane.md`, environment schema/state, Windows installer baseline, CommunityGlows manifests, and the DevServer registry.
- Downstream: clone preparation guidance, `s env` commands, DevServer start behavior, coding-agent PATH visibility, CommunityGlows builds, runtime packaging, operator documentation, and security claims.
- Revalidation: changes to capability schema, plan grammar, redaction, executable trust, exit semantics, installer wrappers, Tauri baseline, or DevServer readiness require focused contracts plus the mapped complete Windows suite.
- Consequence: documentation currently stating that Cargo/Tauri remain blocked and no install occurs must change only after the executable behavior is source- and runtime-proven.

## Documentation Coherence

- Update `shipglows_data/technical/runtime-cli.md` for the implemented CommunityGlows inference, executable Rust/Tauri Windows adapter, activation, semantic exits, and source/runtime proof.
- Update `shipglows_data/technical/architecture.md` for composable capability adapters and ownership boundaries.
- Update `shipglows_data/technical/installer-and-user-scope.md` and the Windows DevServer operator guide for consent, host prerequisites, fresh-process activation, Application Control classification, and live workflow.
- Review `shipglows_data/technical/code-docs-map.md`; update it only if owned paths, validation commands, or update triggers change.
- CommunityGlows README drift (Vite 6 wording and `tauri:dev` semantics) is recorded as a separate project documentation follow-up and is not edited by this chantier unless implementation behavior makes that correction necessary and the operator expands scope.

## Edge Cases

### ZOMBIES coverage

- Z — no tools, no state, no WebView2, no MSVC workload, no Cargo, no token value, and an unmanaged empty project.
- O — one missing capability, one executable operation, one approved digest, one Tauri project, and one fresh child consumer.
- M — independent missing capabilities, repeated apply/verify, root plus site package managers, multiple Tauri candidates, concurrent verify writers, and source/runtime parity.
- B — Node 23/24/25, pnpm 8.11.0 versus adjacent/mismatched majors, Rust below/at/above MSRV and baseline, evidence just before/after freshness expiry, output at timeout/size boundaries, and port zero versus durable ports.
- I — repository manifest to parser, plan to consent, plan to backend, runtime wrapper to mise, process PATH to child, environment state to status, DevServer registry to launch, and build output to artifact registry.
- E — denial, timeout, provider non-zero/ambiguous exit, partial install, stale digest, executable drift, corrupt state, restart required, Application Control denial, missing release variable, failed sync, failed build, and artifact registration failure.
- S — begin with the contextual Bearer regression and one missing Rust capability, then compose the complete CommunityGlows flow without introducing a universal package manager.

## Implementation Tasks

1. **Milestone 0 — close the redaction boundary.** Target `cli/environment/core.py`, CLI exception emission, PowerShell diagnostic parity, and security contracts. Implement contextual credential masking without removing useful error context. Validation: focused Python redaction corpus, DevServer redaction fixture, CLI end-to-end output canaries, `git diff --check`. Dependency: none. Stop if a proposed regex can expose suffix tokens or corrupt non-secret version/path evidence.
2. **Milestone 1 — make desired state complete and evaluable.** Target discovery, preparation, schema, version evaluators, and inference contracts. Preserve Tauri across inferred-to-explicit preparation; represent root pnpm and site npm ownership; add Rust/Cargo/rustup, Tauri Windows, MSVC/SDK, WebView2, and Flox compatibility facts; evaluate supported constraints. Validation: CommunityGlows-shaped fixtures for missing/present/mismatched/boundary versions and preparation round trip. Dependency: Milestone 0.
3. **Milestone 2 — compose secure plan/apply adapters.** Target plan grammar, adapter composition, isolated mise Rust reuse/acquisition, consent/effects, trust roots, fixed argv, retries, partial failure, and fresh observation. Ensure Node/pnpm handling cannot erase Rust/Tauri operations. Validation: fake-runner acquisition/install/replan/converged/refused/stale/drift/offline/timeout tests with zero real provider calls. Dependency: Milestone 1 and fresh official documentation review.
4. **Milestone 3 — prove activation and DevServer consumption.** Target runtime wrappers/PATH, installed launcher, Tauri host observer, DevServer readiness/ports, and multi-Tauri selection. Require an explicit project target instead of silently selecting the first workspace candidate. Validation: isolated runtime and new `pwsh -NoProfile` plus agent-child command/version proof; root `3006` and site `3000` registry assertions; no Tauri build impersonation by browser-extension start. Dependency: Milestone 2.
5. **Milestone 4 — integrate contracts and documentation.** Run all environment contracts, mapped PowerShell adapters, complete Windows DevServer contract, metadata lint, secret scan, and documentation updates. Validation commands include every `tests/environment/*-contract.py`, `tests/windows/environment-observation.ps1`, `tests/windows/environment-mise-adapter.ps1`, `tests/windows/environment-installed-runtime.ps1`, the focused DevServer dependency/start tests, `git diff --check`, and the repository metadata linter on this spec and changed docs. Dependency: Milestone 3.
6. **Milestone 5 — deliver verified source.** Review exact task-owned diff, create exact-scope commits, push the current branch to its resolved upstream, and prove remote persistence. No unrelated dirty or untracked path is staged. Dependency: Milestone 4 green.
7. **Milestone 6 — synchronize and prove the installed runtime.** Use the official runtime update/synchronization route, compare source/runtime hashes or behavior contracts, and execute the installed `s env` smoke from a disposable project before CommunityGlows. Dependency: pushed source from Milestone 5. Stop on source/runtime divergence.
8. **Milestone 7 — execute the real CommunityGlows install and activation flow.** Run inspect and plan first; review effects; apply the exact approved digest including Rust/rustup/Cargo only when proposed; honor visible consent; spawn new managed PowerShell and agent-like processes; require `verify` and `status` exit `0`. No Windows policy change or production secret action. Dependency: installed-runtime parity.
9. **Milestone 8 — exercise product build lanes independently.** Verify DevServer root `3006` and site `3000`; run root Chrome and Firefox builds, site npm ci/build, and the appropriate Tauri Windows bundle using the local CLI. Classify missing Rust/MSVC/WebView2 as environment defects, `oxc-parser` denial as external Application Control, and missing `VITE_CONVEX_URL` as a release configuration block. Dependency: Milestone 7 ready.
10. **Milestone 9 — register and report successful release artifacts.** After a successful local Windows Tauri release, register the MSI/NSIS output with the official local artifact registry command, preserve Local versus CI lanes, and report the refreshed official Desktop shortcut. Extension ZIP/directories and site dist are recorded as build proof but are not substituted for the Windows release artifact contract. Dependency: successful Milestone 8 artifact.

### Execution Batches

No parallel write batches are authorized. Redaction, schema, plan grammar, installer wrappers, shared tests, runtime packaging, and documentation have overlapping ownership and must be integrated sequentially. Read-only rechecks may run concurrently only when an integration owner has already frozen the target diff.

## Acceptance Criteria

- [ ] AC 1: CommunityGlows `inspect` exits `0`, reports complete capability/source facts including incompatible native Windows Flox, performs no version process probe, and creates no state/registry/workspace mutation.
- [ ] AC 2: `prepare` preserves a detected Tauri Windows target and all required tools; applying its digest cannot downgrade desired state from inferred Tauri to explicit non-Tauri.
- [ ] AC 3: `plan` exits `0`, is deterministic, contains every applicable independent operation, reports truthful network/download/privilege/consent effects, and never marks an installation executable without explicit approval semantics.
- [ ] AC 4: An absent or mismatched Node, root pnpm, site npm, Rust/Cargo/rustup, local Tauri CLI, MSVC/SDK, or WebView2 capability produces an actionable non-ready status and exact supported/observed version evidence.
- [ ] AC 5: Correct Node 24, pnpm 8.11.0, Tauri CLI 2.11.4, Rust/Cargo/rustup, MSVC/SDK, and WebView2 observations can collectively produce `ready`; constraints no longer force permanent `unknown`.
- [ ] AC 6: Apply without digest, with a stale/forged digest, changed sources, changed executable identity, blocked plan, or refused consent performs zero backend operations and exits `3` with a redacted reason.
- [ ] AC 7: Approved acquisition/install uses trusted fixed argv and minimal inherited environment, preserves project files, reports partial failure honestly, and replans from observed state.
- [ ] AC 8: `Authorization: Bearer <canary>` and contextual variants never expose the canary through Python, PowerShell, JSON state, attestation, registry diagnostics, stdout, or stderr; `[REDACTED]` and useful non-sensitive context remain visible.
- [ ] AC 9: A new managed PowerShell and an agent-like child both resolve the intended node, pnpm/npm, cargo, rustc, rustup, and local Tauri invocation; the test does not rely on the installer process environment or a user profile hook.
- [ ] AC 10: Managed missing, declined, failed, incompatible, restart-required, and stale-evidence scenarios make `verify` and `status` exit exactly `4`; invalid contract exits `2`; apply refusal exits `3`; complete fresh evidence exits `0`.
- [ ] AC 11: Multiple Tauri candidates never cause silent first-project selection; the project-scoped CommunityGlows operation is deterministic or blocks for explicit scope.
- [ ] AC 12: DevServer preserves root port `3006` and site port `3000`, clears stale lastError after stop, surfaces startup failure honestly, and does not treat browser-extension readiness as Tauri readiness.
- [ ] AC 13: Source and installed runtime pass the same focused contracts and return equivalent inspect/plan/apply/verify/status behavior before the live CommunityGlows test.
- [ ] AC 14: Root Chrome/Firefox, site, and Tauri build outcomes are reported separately; Application Control, absent toolchain, config/secret block, CLI defect, and source/build defect classifications are evidence-backed.
- [ ] AC 15: A successful local Windows Tauri release produces the expected MSI/NSIS artifact, registers it through the official local artifact registry, and refreshes the official Desktop shortcut without a manual worktree shortcut.
- [ ] AC 16: Exact-scope commits exclude all pre-existing unrelated changes, push succeeds to the resolved upstream, runtime synchronization follows the push, and no force push occurs.
- [ ] AC 17: Mapped technical documentation describes only source- and runtime-proven behavior; CommunityGlows README drift remains a separate explicitly scoped follow-up unless scope is expanded.

## Test Strategy

- Unit: strict discovery/preparation, semver/MSRV boundaries, plan validation, redaction corpus, exit mapping, state integrity, multi-project selection, and artifact classification.
- Integration: fake structured runners with trusted executable identities; disposable source/runtime/state roots; Windows PowerShell and managed PowerShell wrappers; no network in default suites.
- Fresh-process: spawn clean managed PowerShell and agent-like children with controlled environment, then prove exact command paths, versions, and exit propagation.
- DevServer: dependency setup, npm ci argument integrity, detached start failure, port hydration, stop cleanup, registry migration, and CommunityGlows-shaped root/site surfaces.
- Installed runtime: package closed set, isolated inspect, behavior/hash parity, and official sync route.
- Live: operator-approved real apply, CommunityGlows verify/status, extension/site/Tauri builds, Application Control classification, and artifact registration.
- Security: secret canaries, repository command-injection strings, executable drift, path containment, bounded output, timeout, partial failure, and no ambient credential inheritance.

## OWASP Security Gate

- Categories considered: A02 Security Misconfiguration, A03 Software Supply Chain Failures, A05 Injection, A06 Insecure Design, A08 Software or Data Integrity Failures, A09 Security Logging and Alerting Failures, and A10 Mishandling of Exceptional Conditions.
- Trust/data boundaries: repository manifests to parsers; plan digest to consent; WinGet/mise/Visual Studio/WebView2 providers to trusted executables; runtime wrappers to child processes; process output to redacted state; source checkout to installed runtime; build output to artifact registry.
- Selected ASVS v5.0.0 requirements: no aggregate compliance claim. Concrete implementation proof maps command-injection prevention, secret handling, integrity, logging, and exceptional-condition controls before any ASVS wording.
- Proof: strict schemas, fixed argv, path/executable identity binding, source/plan digests, official coordinate/provenance checks, canary redaction, least inherited environment, non-ready failure semantics, and source/runtime parity.
- Residual gap and owner: Windows providers and Application Control remain external trust boundaries; the implementation owner must use current official documentation and report policy blocks without bypass.

## Risks

- Security: privileged or executable installation can expose supply-chain, injection, credential, and integrity risk. Mitigation: trusted authorities, explicit consent, fixed argv, identity/digest binding, minimal environment, and redaction.
- Architecture: merging the full installer and environment plane carelessly could duplicate ownership. Mitigation: composable adapters and one thin control-plane contract over existing provider owners.
- Compatibility: forcing global pnpm to 8.11.0 could break other tools. Mitigation: project-local invocation/ownership and independent site npm handling.
- Platform: Android-centric Rust readiness can over-install NDK or under-prove Windows desktop prerequisites. Mitigation: explicit Tauri target profiles and Windows-only live acceptance.
- Operational: external installers are not transactionally reversible. Mitigation: separate acquisition, replan, observed-state recovery, idempotency, and honest partial status.
- Testing: fixture success can hide fresh-process or provider gaps. Mitigation: mandatory installed-runtime and live proof before readiness/shipping claims.
- Delivery: dirty worktree or runtime divergence can contaminate the push/sync. Mitigation: exact staging, remote persistence before sync, and parity checks.

## Execution Notes

- Context Capsule target: `ShipGlows -> Windows developer environment autonomy -> CommunityGlows -> CLI/DevServer install and activation flow`.
- Accepted outcome: complete, consented, fresh-process-proven dependency readiness followed by exact delivery, runtime sync, real build lanes, and artifact registration; forbidden outcomes include policy bypass, project dependency drift, secret exposure, false ready, or unscoped Git delivery.
- Qualified truth: operator plan and Rust-install permission are `confirmed`; current source/runtime/registry/manifests and audit findings are `evidence_backed`; live provider success, Application Control recurrence, and release-variable availability remain `unknown` until Milestones 7–9.
- First reads: this spec; `cli/environment/core.py`; `cli/environment/preparation.py`; `cli/environment/mise_backend.py`; `cli/windows/install-devserver.ps1`; `cli/windows/ShipGlows.MobileToolchain.psm1`; mapped focused tests.
- Implementation approach: regression first, smallest complete adapter composition, source proof before provider mutation, remote persistence before runtime sync, and installed-runtime parity before CommunityGlows.
- Stop conditions: contextual secret still leaks; external docs conflict with pinned baseline; capability ownership is ambiguous; a plan cannot express all effects; new-process activation is unprovable; tests require policy bypass; unrelated dirty paths overlap; push target is unresolved; runtime parity fails; or a live build would require an undisclosed/unapproved secret action.

## Open Questions

None. The operator approved the full plan including real Rust/rustup/Cargo installation through the CLI after source proof. External provider and Application Control outcomes are execution evidence, not unresolved product decisions.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-09-01 10:17:36 UTC | 100-sg-spec | GPT-5.6 Codex | Consolidated the approved operator plan and three read-only audits into one autonomous implementation contract. | Reviewed spec created; no code, installation, provider, Git, runtime, or CommunityGlows mutation performed. | Run readiness review and transition only if every contract gate is complete. |
| 2026-09-01 10:20:19 UTC | 101-sg-ready | GPT-5.6 Codex | Reviewed user-story fit, composable ownership, consent and failure semantics, security boundaries, ZOMBIES coverage, sequential milestones, live proof, delivery, synchronization, and artifact registration. | Ready: a fresh implementation agent can execute Milestone 0 without conversation history; live provider success remains execution evidence rather than a readiness assumption. | Implement Milestone 0 regression first. |
| 2026-09-01 10:34:41 UTC | 102-sg-start | GPT-5.6 Codex | Implemented Milestone 1 desired-state completeness and bounded version evaluation after preserving the existing Milestone 0 redaction changes. | Complete for Milestone 1: scoped root/site package managers, Rust/Tauri Windows and host facts, explicit-manifest inference preservation, multi-Tauri discovery, stale-source state drift, and all nine environment contracts pass without provider, installation, network, build, runtime, or CommunityGlows mutation. | Implement Milestone 2 adapters with injected provider evidence only. |
| 2026-09-01 11:04:02 UTC | 102-sg-start | GPT-5.6 Codex | Completed Milestone 2 with a fixed composable adapter registry, closed JSON Windows provider, structured Python bridge, extracted isolated mise/Rust primitives, transitive executable identities, host observation, and closed installer packaging. | Complete for Milestone 2: all ten environment contracts, provider/mobile/install-surface PowerShell contracts, and the synthetic installed-runtime extraction proof pass with provider execution, installation, network, elevation, build, runtime sync, and CommunityGlows mutation disabled. | Implement Milestone 3 activation and fresh-process DevServer consumption proof. |
| 2026-09-01 11:17:44 UTC | 102-sg-start | GPT-5.6 Codex | Completed Milestone 3 with disposable cargo/rustc/rustup wrappers, exact managed-PowerShell and nested agent-like fresh-process proofs, scoped DevServer environment-state consumption, independent extension/Tauri readiness, explicit multi-Tauri selection, and durable CommunityGlows port assertions. | Complete for Milestone 3: all ten environment contracts, the new activation/DevServer contract, targeted functional DevServer contracts, provider/mobile/install-surface contracts, and closed 34-file installed-runtime parity pass without provider execution, installation, network, elevation, build, runtime sync, or CommunityGlows mutation. The complete DevServer suite remains a Milestone 4 gate. | Implement Milestone 4 integrated contracts and documentation. |
| 2026-09-01 11:50:44 UTC | 102-sg-start | GPT-5.6 Codex | Completed Milestone 4 integration, managed-PowerShell portability repairs, complete Git Bash Windows contract, mapped technical documentation, metadata lint and secret/diff gates. | Complete for Milestone 4: all ten environment contracts, every mapped environment adapter, the complete managed-PowerShell DevServer suite, and `tests/windows/devserver-contract.sh` pass. Performance retains bounded median-of-batch thresholds; process cleanup, JSON envelopes, reservation timestamps, UTF-8 capture and runtime cache timestamps are deterministic across PowerShell 7.6. Installed-runtime live convergence remains pending by design. | Deliver only the exact task-owned source in Milestone 5. |

## Current Chantier Flow

- `100-sg-spec`: done; reviewed contract persisted.
- `101-sg-ready`: done; status transitioned to ready after substantive risk and autonomy review.
- `102-sg-start`: in progress; Milestones 0 through 4 are implemented, documented and contract-proven, while live provider execution and installation remain intentionally unstarted.
- `103-sg-verify`: not started.
- `104-sg-end`: not started.
- `005-sg-ship`: not started.

Next step: deliver the exact verified source diff in Milestone 5 without staging concurrent or unrelated paths.
