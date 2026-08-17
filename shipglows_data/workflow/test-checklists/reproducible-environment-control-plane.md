---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.7.0"
project: ShipGlows
created: "2026-08-16"
updated: "2026-08-17"
status: active
source_skill: sg-engineering
scope: reproducible-environment-control-plane-foundation-and-mise-pilot
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/environment/
  - cli/shipglows.sh
  - cli/windows/shipglows-devserver.ps1
  - tests/environment/
  - tests/runtime/environment-observation.sh
  - tests/windows/environment-observation.ps1
  - tests/windows/environment-mise-adapter.ps1
depends_on:
  - artifact: shipglows_data/workflow/specs/shipglows-reproducible-environment-control-plane.md
    artifact_version: "1.8.1"
    required_status: active
supersedes: []
evidence:
  - "Regression-first schema contract failed on the absent cli.environment module before implementation."
  - "Independent security regressions failed before hardening because inspect invoked an unknown PATH executable, a trusted probe ran during inspect and a forged executable plan reached its runner."
  - "Independent verification also reproduced false-ready observations for an unevaluated version constraint and an empty successful version probe before both paths were hardened."
  - "Foundation tests use only temporary project and state directories and invoke no package manager or network operation."
  - "Task 5 first failed because cli.environment.mise_backend did not exist, then passed after the structured adapter and semantic apply boundary were implemented."
  - "Task 5 tests inject all mise, WinGet and Node observations; no live package manager, download or host mutation is used."
  - "Independent Task 5 verification first reproduced arbitrary external PATH executable trust, executable digest drift, inherited secret leakage and incomplete mise config isolation, then proved the bounded corrections green."
  - "The approved Best Fried Chicken provider smoke acquired mise through the official jdx.mise WinGet package and verified locked Node 24.19.0 plus pnpm 10.34.5 for PowerShell and agent-child consumers without running project dependencies."
  - "The real smoke reproduced and closed Windows App Execution Alias identity, fresh-install PATH discovery, false global-tool readiness and project-root ceiling errors before convergence."
  - "The approved Task 8 installed-runtime update from commit 1801ae0 exited 0 and the final probes verified Rust 1.97.1, Cargo 1.97.1, NDK 29.0.14206865 and the four required Rust Android targets without mutating CommunityGlows."
next_step: "Keep later backend adapters separately approval-gated."
---

# Reproducible environment control-plane foundation and mise pilot checklist

## Automated contract proof

- [x] Strict JSON rejects duplicate keys, non-finite numbers, unknown fields and unsupported schema majors.
- [x] JSON, runtime-policy, referenced-source and persisted-state reads have explicit 1 MiB, 64 KiB, 8 MiB and 4 MiB bounds.
- [x] Capability entries, project metadata, policies, namespaced extensions and backend references use closed schemas.
- [x] Direct, parent-segment and available symlink escapes are rejected after canonical path resolution.
- [x] `.shipglows.env` accepts only `SHIPGLOWS_ENV_PORT` and `SHIPGLOWS_AUTO_REPAIR`; capability ownership remains in the JSON manifest.
- [x] Zero native sources reports `unmanaged`; exact recognized native paths report inferred intent without recursive scanning.
- [x] Secret-shaped keys and credential-bearing URLs are redacted from state and Markdown rendering.
- [x] Verify persists the rendered redacted Markdown attestation inside the atomic private record; project-file merging remains a separately gated ownership decision.
- [x] A persisted Markdown attestation inconsistent with its structured evidence is rejected instead of being relayed by status.
- [x] Inspect launches no tool process; only verify may execute bounded version probes from the fixed trusted registry, and unknown manifest capability names remain `unknown` without PATH resolution.
- [x] A trusted probe with empty version evidence is `degraded`; a declared version constraint stays `unknown` until an owning adapter evaluates it.
- [x] Concurrent state writers leave one parseable atomic record with no temporary or lock files.
- [x] Unix state permissions are forced to `0700`/`0600`, temporary files use exclusive creation and a lock older than the bounded stale interval is recoverable.
- [x] Truncated state is rejected and a later verify reconstructs it from source intent and fresh observation.
- [x] Evidence freshness changes a stale ready state to `drifted` and other stale states to `unknown`.
- [x] Identical source and platform inputs produce byte-equivalent operation order and digest; changed intent changes the digest.
- [x] Referenced backend manifests and recognized companion lockfiles contribute their content hashes, so a post-approval change produces a stale plan.
- [x] Multiple platform backend references block ownership selection rather than merging mutations.
- [x] Stale approval digests and the absence of an active backend both refuse before the injected runner is called.
- [x] A digest-valid forged plan with `executable=true` is still refused because this foundation contains no execution backend.
- [x] Bash and PowerShell source entrypoints inspect an unmanaged temporary project without legacy DevServer setup mutation.
- [x] Source CLI inspection disables local Python bytecode writes as well as ShipGlows state writes.
- [x] Bash and PowerShell `apply` adapters propagate the safe refusal exit code `3`.

## Scope and safety proof

- [x] No Flox, mise, WinGet Configuration, Dev Container, Android, Flutter, Playwright or agent installation command is executed by the foundation.
- [x] Backward-compatibility migration policy for existing `.shipglows.env` is documented and validated as an explicit editorial boundary.
- [x] Automated fixtures perform no authentication, license acceptance, elevation, PATH/profile edit, download, deployment, publish, commit or push; the separately approved real smoke downloaded only mise, Node and pnpm and did not run project dependency installation.
- [x] Existing editorial roadmap changes are outside the implementation scope and remain preserved.
- [x] Technical documentation defines the installed-runtime layout and keeps shipped-readiness evidence separate until the isolated installer proof passes.

## Windows mise plus Node 24 and pnpm 10 source-pilot proof

- [x] Missing mise produces a distinct official `jdx.mise` WinGet acquisition operation; Node and pnpm remain blocked until a fresh plan observes mise.
- [x] Wrong approval, source/lock digest drift, executable path/SHA-256 drift and digest-valid semantic forgery refuse before any apply runner call.
- [x] Only root `[tools] node = "24"` plus `pnpm = "10"` is accepted; env, hook, template, option, task and repository-command execution surfaces are outside the pilot.
- [x] `mise.lock` must pin one exact Node 24 `core:node` entry and one exact pnpm 10 `aqua:pnpm/pnpm` entry with matching Windows authority/path/checksum evidence; ShipGlows records presence/ownership without inventing artifact provenance.
- [x] Existing `package.json#packageManager` must equal the exact locked pnpm version; absent `packageManager` is accepted and no project manifest is rewritten.
- [x] Install argv is reconstructed independently as `mise --locked install node` and `mise --locked install pnpm`; verification argv is reconstructed as `mise --locked exec -- <tool> --version` for both PowerShell and agent-child consumers, and `pnpm install` is never run.
- [x] Inherited `MISE_*` controls and unrelated ambient application credentials are removed from the child; process-local safe/no-hooks/no-env, exact-config/tool-version filenames, config-directory/ceiling, system/global-isolation, no-system-deps and no-auto-install settings are applied without changing persistent PATH, profiles, environment variables or global Node ownership.
- [x] Alternate project mise configuration, repository-resolved executables and external PATH executables outside canonical package-manager roots are rejected before any runner call; canonical executable path plus SHA-256 is approval-bound and revalidated before apply.
- [x] Fresh, existing valid, partial/broken, conflicting global PATH/Node/pnpm, offline-ready, offline-missing, exact-lock, package-manager drift, second-run and spaces/Unicode/metacharacter project fixtures pass.
- [x] Timeout, nonzero and empty backend/install evidence fail closed; no ShipGlows temporary install artifact survives fixture cleanup.
- [x] Attestation records `mise_project` ownership for Node and pnpm across both consumers without a full mise executable path, secrets or raw environment output.
- [x] Read-only planning first proves `mise --locked which <tool>` ownership, disables every current mise auto-install setting and cannot mistake a matching global Node/pnpm for a mise-owned tool.
- [x] WinGet App Execution Alias resolution falls back to the registered Desktop App Installer package binary, and a fresh mise install is found in canonical WinGet package roots even before a new shell refreshes PATH.
- [x] The mise discovery ceiling is the project parent, so the validated root `mise.toml` remains visible while parent configuration stays outside the cascade.
- [x] Current official mise Windows install, exec, lock, safe-mode, offline and cache semantics were checked and retained as durable spec/runtime evidence.
- [x] PowerShell wrapper launches the fixture as a separate child process and proves process/user/machine PATH plus `$PROFILE` remain byte-for-byte unchanged.
- [x] All six environment contracts, Unix and PowerShell observation adapters, PowerShell 5.1 parsing, JSON schema parsing and the complete Windows DevServer contract pass locally.

## Task 5 quality and security boundary

- [x] ZOMBIES: zero-trust parsing, observable dual-consumer evidence, minimal fixed operations, bounded outputs/timeouts/config, idempotent second run, explicit ownership and small pilot scope are covered.
- [x] Clean Code Gate: backend policy, process request/result boundary and injectable runner are cohesive; orchestration remains in core and process mechanics remain out of manifest parsing.
- [x] OWASP A03: acquisition uses the documented `jdx.mise` package identity; Node and pnpm require exact backend ownership, release URL authority/path and supported checksum formats; the approved real provider cycle converged against official Node and pnpm release coordinates.
- [x] OWASP A05: repository strings, task/hook/template content, persisted argv and repository-resolved executables cannot become process commands.
- [x] OWASP A08: approval digest, current source digest, exact lock evidence, backend version and complete operation semantics are revalidated before apply runner use.
- [x] OWASP A10: missing, broken, timeout, nonzero, empty, offline, drift and second-run states fail closed or converge without false success.
- [x] Auto-verification eligibility/result: repository-local contracts passed, then separately approved provider evidence verified the source pilot on Windows; installed-runtime packaging has its own proof block below.

## Native Windows installed-runtime packaging proof

- [x] Root bootstrap extraction runs against a synthetic complete archive, returns the exact twelve-file allowlist and rejects a second archive missing one environment module.
- [x] Native installer validates the environment schema before setup and validates every packaged Python module with the uv-managed Python runtime before continuing.
- [x] Installed `s env` resolves `%USERPROFILE%\.shipglows\runtime\cli\environment` while the source entrypoint still resolves its sibling source package.
- [x] An isolated installed-runtime invocation of `s env inspect` succeeds from an unmanaged temporary project without creating DevServer workspace, registry or menu-cache state.
- [x] Packaging proof performs no Android/Flutter install, authentication, license acceptance, project dependency installation, live-runtime overwrite, commit or push.

## Deferred platform evidence

- [x] Close the approved installed-runtime packaging proof above.
- [x] Prove one project-local Node 24 plus pnpm 10 cycle through mise on fresh, existing, partial, conflicting-PATH and offline installed-cache Windows fixtures using injected runners only.
- [x] Run the explicitly approved real-provider smoke on `dianedef/bestfriedchicken`, without `pnpm install`, application execution, commit or push.
- [x] Run the published native Windows Task 8 update and verify the PATH-backed `rustc`, `cargo` and `rustup` wrappers, exact NDK and all four Rust Android targets on the existing host; preserve CommunityGlows as `migration_required` without project mutation.
- [ ] Prove Flox, WinGet Configuration and Dev Container adapters only in their owning later tasks.
- [ ] Generate or merge a project `ENVIRONMENT.md` managed block only after its ownership and non-overwrite contract is approved.
