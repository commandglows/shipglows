---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.6"
project: ShipGlows
created: "2026-08-26"
created_at: "2026-08-26 12:18:53 UTC"
updated: "2026-08-26"
updated_at: "2026-08-26 12:40:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: latest-build-artifact-access
owner: Diane
user_story: "As the ShipGlows operator, I want clearly named desktop shortcuts to the latest successful local and CI builds for each managed project so I can test Windows and Android outputs without navigating build trees or GitHub Actions archives."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/latest-build-artifact-access.md
  - skills/references/agent-runtime-awareness.md
  - cli/windows/ShipGlows.BuildArtifacts.psm1
  - cli/windows/shipglows-build-artifacts.ps1
  - cli/windows/install-devserver.ps1
  - install-shipglows.ps1
  - tests/windows/build-artifacts.ps1
  - shipglows_data/technical/latest-build-artifact-access.md
depends_on:
  - artifact: "skills/references/agent-runtime-awareness.md"
    artifact_version: "3.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-26: successful test builds need stable desktop access instead of deep build paths."
  - "Operator decision 2026-08-26: shortcut titles must distinguish Local from CI and Windows from Android APK."
  - "GitHub documents workflow artifacts as archived outputs that authenticated readers can download before retention expiry."
  - "Apple Xcode and iOS execution remain macOS/device surfaces; Windows must not present an IPA as locally runnable."
next_step: "Integrate the command into a managed project's successful local build and artifact-upload workflows."
---

# Latest Build Artifact Access

## Title

Latest Build Artifact Access

## Status

shipped — the verified Windows implementation, doctrine, technical documentation, and focused proof are remotely persisted on the task branch.

## User Story

As the ShipGlows operator, when an agent completes a local release build or observes a successful trusted CI build, I want a stable, source-labelled shortcut on my desktop so I can reach the exact Windows executable or Android APK immediately without browsing build directories or GitHub Actions.

## Minimal Behavior Contract

After a successful build, ShipGlows publishes the validated artifact into a private machine-local cache, records its source and integrity metadata atomically, and refreshes only the matching ShipGlows-managed desktop shortcut. Local and CI lanes remain separate. Windows shortcuts launch the cached executable with its complete release package; Android APK shortcuts reveal the cached APK in Explorer without installing it. A failed, missing, expired, ambiguous, oversized, untrusted, or malformed candidate leaves the previous valid lane untouched. The easiest missed edge case is a newer failed CI run or deleted worktree replacing a still-usable last-known-good artifact.

## Success Behavior

- A successful local Windows release creates or refreshes `ShipGlows - <Project> - Windows - Local.lnk`.
- A successful CI Windows artifact creates or refreshes `ShipGlows - <Project> - Windows - CI.lnk` after a successful trusted workflow run is selected and downloaded.
- Successful local and CI Android artifacts create separate `Android APK - Local` and `Android APK - CI` shortcuts that reveal, but never install, the APK.
- Spaces in project names and paths are preserved safely through literal-path handling and shortcut arguments.
- Each shortcut resolves to a cached artifact that remains usable if the originating worktree is later removed.
- State records source kind, platform, project identity, creation time, source commit/run when available, artifact SHA-256, cached path, and shortcut path without secrets.

## Error Behavior

- Failed builds never invoke artifact publication and never change a shortcut.
- Missing GitHub authentication, missing artifacts, expired artifacts, unsuccessful runs, disallowed workflow events, multiple entrypoint candidates, path escape, reparse points, or size overflow fail closed with an actionable error.
- An existing shortcut with the desired name but without the exact ShipGlows ownership marker is never overwritten.
- Windows does not claim Linux binaries or iOS IPA files are runnable. Unsupported host/platform pairs receive an explicit status and no launch shortcut.
- Partial cache or shortcut writes are rolled back or remain unreferenced; the previous valid state stays active.

## Problem

ShipGlows reports deep build paths but owns no durable presentation layer for testable native artifacts. Git worktrees and GitHub artifact retention make those paths temporary, while generic desktop links can silently become stale or overwrite unrelated files.

## Solution

Add a shared latest-build access doctrine plus a Windows artifact manager. The manager copies successful local or downloaded CI outputs into a private per-project, per-platform, per-source cache; validates provenance and bounds; writes versioned state atomically; and updates source-labelled desktop shortcuts with collision protection. A small command surface lets build agents register local outputs, synchronize a named GitHub Actions artifact, or inspect status.

## Scope In

- Separate Windows Local, Windows CI, Android APK Local, and Android APK CI lanes.
- Stable private cache under the current user's local ShipGlows application-data root.
- Windows `.lnk` creation through the Windows shell shortcut API.
- GitHub CLI read-only selection and download of one named artifact from one successful trusted run.
- Atomic state/shortcut replacement, integrity hashes, bounded extracted content, reparse/path checks, and last-known-good preservation.
- Installer/runtime packaging, shared agent doctrine, focused Windows tests, and mapped technical documentation.
- Compatibility doctrine for Linux, macOS, and iOS without pretending cross-host execution.

## Scope Out

- Adding or changing application-specific GitHub Actions workflows.
- Uploading CI artifacts, dispatching workflows, writing to GitHub, or changing repository permissions.
- Automatic APK installation, ADB use, emulator/device startup, application launch, code signing, notarization, TestFlight, or App Store operations.
- Background polling, resident services, notification daemons, or automatic network access at ShipGlows startup.
- Linux desktop shortcut implementation, macOS aliases, and iOS deployment implementation in this Windows tranche.
- Automatic cleanup beyond two validated generations per lane.

## Constraints

- The command runs only after an agent has proven local build success or while explicitly synchronizing CI artifacts.
- CI synchronization requires an explicit repository, workflow, branch, artifact name, platform, and project target.
- GitHub access is read-only and uses the existing authenticated `gh` session; credentials and tokens never enter arguments, state, logs, or shortcuts.
- Allowed CI events default to `push`, `workflow_dispatch`, and `release`; other event types require a future explicit policy decision.
- Cache and shortcut ownership are fail-closed and versioned.
- All filesystem paths are canonicalized, bounded beneath their declared roots, handled literally, and checked for reparse points.
- User-facing shortcut labels use spaces; internal identifiers use closed lowercase values.

## Test Contract

- Proof path: `scenario-first` with focused PowerShell fixtures.
- Automated proof: local publish, CI selection/download through an injected fake GitHub runner, state parsing, SHA-256, shortcut ownership, last-known-good preservation, size/path/reparse rejection, and installer packaging assertions.
- External proof: not required for this implementation checkpoint; tests use a temporary desktop, cache, project, and fake GitHub output. A real project CI artifact remains a separate project-owned integration proof.
- Browser/auth/device/manual proof: not applicable because no application is launched, authenticated, installed, or deployed.
- Pressure scenario `BUILD-ACCESS-LAST-GOOD`: a newer failed local or CI candidate cannot replace the prior valid shortcut.
- Pressure scenario `BUILD-ACCESS-SOURCE-LABEL`: Local and CI shortcuts remain distinct for the same project and platform.
- Pressure scenario `BUILD-ACCESS-WORKTREE-REMOVAL`: the shortcut points into the private cache rather than the disposable worktree.
- Pressure scenario `BUILD-ACCESS-UNOWNED-COLLISION`: an unowned same-name shortcut blocks replacement.
- Pressure scenario `BUILD-ACCESS-CI-TRUST`: only a successful explicitly selected trusted run and named artifact can be published.
- Pressure scenario `BUILD-ACCESS-HOST-PARITY`: Windows never presents Linux or iOS artifacts as runnable.

## Dependencies

- Windows PowerShell Core runtime managed by ShipGlows.
- Windows Script Host shortcut API.
- Existing GitHub CLI authentication for CI synchronization.
- An application workflow that already uploads a usable complete Windows package or Android APK artifact.

## Invariants

- No build is launched by the artifact manager.
- No artifact or shortcut is published before upstream build success is established.
- No shortcut is overwritten unless its ownership marker exactly matches the lane.
- Local and CI last-known-good states are independent.
- Windows packages retain required sibling DLL/data files.
- Android publication never means installed or device-tested.
- CI download never means provenance attestation, release approval, deployment, or production verification.
- No secret, token, private log payload, or arbitrary command is persisted.

## Links & Consequences

- `agent-runtime-awareness.md` becomes the shared trigger contract for Windows/Android build agents.
- Windows installers must package both the module and command entrypoint.
- Project-specific workflows may later need a separate spec to upload named complete artifacts.
- Build reports must name the refreshed shortcut or an actionable reason it was not produced.
- Linux/macOS consumers can reuse the state schema later but require host-native presentation implementations.

## Documentation Coherence

- Add `skills/references/latest-build-artifact-access.md` as the canonical execution doctrine.
- Add `shipglows_data/technical/latest-build-artifact-access.md` for architecture, command surface, state schema, safety, validation, and maintenance.
- Update `shipglows_data/technical/code-docs-map.md` and `shipglows_data/technical/README.md` if their current mapping/index structure requires the new subsystem.
- Update installer documentation only when the mapped documentation gate identifies a direct claim.

## Edge Cases

- Empty or invalid project display name.
- Project names containing spaces or Windows-invalid filename characters.
- Multiple worktrees for the same origin and project-relative path.
- No previous valid artifact.
- Repeated publication of the same hash/run.
- Multiple matching `.exe` or `.apk` files without an explicit relative entrypoint.
- Cached package missing the requested entrypoint after copy/download.
- CI artifact exceeding the configured byte/file limits.
- Symlink, junction, or other reparse point inside a package.
- Desktop redirected to OneDrive or another valid local folder.
- Existing owned shortcut from another project/lane and existing unowned same-name shortcut.
- GitHub run succeeds but artifact download fails or artifact has expired.
- Linux executable, macOS app, or iOS IPA observed on Windows.

## ZOMBIES Coverage

- Z: no previous state, empty download, missing entrypoint, and no successful run fail without a shortcut.
- O: one valid local Windows package and one valid Android APK publish successfully.
- M: multiple projects, platforms, source lanes, candidates, generations, and repeated publications remain isolated and bounded.
- B: path root, maximum bytes/files, shortcut-name length, and generation-retention boundaries are checked.
- I: build agent → artifact command → GitHub CLI/filesystem → cache/state → Windows shortcut boundaries are explicit.
- E: failed build, GitHub denial/expiry, ambiguous artifact, collision, interrupted write, reparse point, and unsupported host recover without losing last-known-good state.
- S: four explicit lanes and one command surface avoid a background service or cross-platform runtime abstraction.

## Implementation Tasks

1. Target `skills/references/latest-build-artifact-access.md` and `skills/references/agent-runtime-awareness.md`; define the post-success trigger, four lane names, platform behavior, exact command surface, failure semantics, and report obligation. User-story link: a fresh build agent can publish access without conversation memory. Dependency: this ready spec. Validation: focused `rg` assertions in `tests/windows/build-artifacts.ps1`.
2. Target `cli/windows/ShipGlows.BuildArtifacts.psm1` and `cli/windows/shipglows-build-artifacts.ps1`; implement stable project identity, local publication, CI synchronization, status, atomic cache/state, managed shortcut collision protection, two-generation retention, and host/platform gates. User-story link: shortcuts remain usable and source-labelled. Dependency: task 1. Validation: `pwsh -NoProfile -File tests/windows/build-artifacts.ps1`.
3. Target `cli/windows/install-devserver.ps1` and `install-shipglows.ps1`; package both new Windows surfaces without activating them during installation. User-story link: the doctrine is available from installed ShipGlows. Dependency: task 2. Validation: focused payload assertions in `tests/windows/build-artifacts.ps1` plus PowerShell syntax parsing.
4. Target `tests/windows/build-artifacts.ps1`; add deterministic temporary Desktop/cache/project fixtures for local Windows, local APK, CI selection/download, source separation, worktree-source removal, last-known-good, collision, bounds, reparse/path checks, ambiguous candidates, and unsupported platforms. User-story link: recurrence is caught mechanically. Dependency: tasks 1–3. Validation: the test file exits zero and emits its success marker.
5. Target `shipglows_data/technical/latest-build-artifact-access.md`, `shipglows_data/technical/code-docs-map.md`, and `shipglows_data/technical/README.md`; document ownership, entrypoints, schema, invariants, validation, platform matrix, Reader checklist, and maintenance trigger. User-story link: future agents and maintainers can find and preserve the behavior. Dependency: tasks 1–4. Validation: metadata lint for new metadata-bearing artifacts and focused link scans.
6. Target this spec plus the exact owned implementation/doc/test files; run focused proof, verify acceptance, update flow/history, scan staged content for secrets, and deliver exact-scope commits to `origin/codex/development-runtime`. User-story link: the durable ShipGlows system change is remotely protected. Dependency: tasks 1–5. Validation: focused test, metadata lint, `git diff --check`, staged-path inspection, commit reachability, and ordinary push result.

## Acceptance Criteria

- [x] Four source-labelled shortcut names are deterministic and safely preserve spaces.
- [x] Windows Local and CI shortcuts launch cached complete packages; Android Local and CI shortcuts reveal cached APKs without installation.
- [x] A successful local publish survives removal of its source worktree.
- [x] CI synchronization selects one successful allowed-event run and one explicitly named artifact through existing GitHub CLI authentication.
- [x] State contains no credentials and records canonical provenance plus SHA-256.
- [x] Failed or unsafe candidates leave the previous valid shortcut and state unchanged.
- [x] Unowned shortcut collisions, path escapes, reparse points, oversize packages, and ambiguous entrypoints fail closed.
- [x] Linux/macOS/iOS limitations are represented honestly; Windows creates no misleading launch shortcut for them.
- [x] Installer payloads include the module and command entrypoint.
- [x] Focused Windows tests and metadata checks pass.
- [x] Technical documentation and code-doc mappings are coherent.
- [x] Exact-scope commits are pushed to `origin/codex/development-runtime` without the unrelated dirty business document.

## Test Strategy

- Build a temporary fixture project with spaces in its name, a fake Windows release directory, and a fake APK.
- Inject a shortcut writer/reader for deterministic ownership tests while retaining a small static assertion for the real WScript Shell adapter.
- Inject a fake GitHub runner that returns a successful allowed-event run and materializes a named artifact under a bounded staging directory.
- Exercise failure before state commit for missing/failed runs, collisions, size/file-count boundaries, reparse points when supported, and ambiguous entrypoints.
- Assert cached targets remain after deleting fixture source packages.
- Run PowerShell syntax validation and installer payload scans.

## OWASP Security Gate

- Categories considered: A03 Software Supply Chain Failures, A05 Injection, A06 Insecure Design, A08 Software or Data Integrity Failures, and A10 Mishandling of Exceptional Conditions.
- Trust boundaries: authenticated GitHub CLI output, workflow/run metadata, downloaded files, local build paths, private cache, state JSON, and Windows shortcut shell API.
- Authorization: the operator-approved ShipGlows build workflow may publish only explicit project/platform/source lanes; arbitrary repositories, commands, URLs, or credentials are not persisted or executed.
- Selected ASVS requirements: not claimed; this is a local developer-tool workflow rather than an application security control. The focused scenarios prove path, provenance, integrity-recording, collision, and failure boundaries.
- Residual gap: GitHub artifact attestation verification and platform code-signature verification are outside this tranche and must not be implied by SHA-256 recording.

## Risks

- A compromised trusted workflow could publish a malicious binary; mitigation is explicit repository/workflow/branch/event selection, no automatic launch, provenance recording, and honest residual-risk reporting.
- Large packages could consume disk; mitigation is byte/file bounds and retention of at most two validated generations per lane.
- Worktree identity could fragment shortcuts; mitigation is stable origin plus project-relative identity with a non-Git fallback.
- Windows shortcut COM behavior may differ by host; mitigation is a real adapter with injectable fixture proof and fail-closed collision handling.
- App-specific workflows may not upload usable packages; mitigation is an actionable gap rather than guessed artifact selection.

## Execution Notes

- Topology: main-only; the implementation is one cohesive Windows subsystem and delegation would add coordination without independent scope value.
- First-read files: `skills/references/agent-runtime-awareness.md`, `cli/windows/install-devserver.ps1`, `install-shipglows.ps1`, `tests/windows/developer-corpus.ps1`, and `shipglows_data/technical/code-docs-map.md`.
- Proof profile: scenario-first.
- Pressure scenario: an Auth0 migration agent finishes a Flutter Windows Release build in a disposable worktree and reports only the deep `app.exe` path. The corrected system caches the complete package, refreshes `Windows - Local`, preserves a separate `Windows - CI`, and never replaces either after a failed subsequent build.
- Followability Gate: a fresh build agent must find the trigger and exact command from `agent-runtime-awareness.md`, while detailed behavior remains in one shared reference and mechanical tests catch omissions.
- Fresh official evidence checked: GitHub Actions artifact download/retention documentation and Apple Xcode host requirements, 2026-08-26.
- No dependency installation, server, application build, browser, device, deployment, workflow dispatch, or real artifact download is authorized for this implementation proof.

## Open Questions

None. The operator selected separate Local and CI shortcuts, Windows and Android implementation now, honest Linux/macOS/iOS compatibility boundaries, and ordinary remote delivery of the ShipGlows change.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-26 12:18:53 UTC | 100-sg-spec | GPT-5 Codex | Authored the durable local/CI build artifact access contract from the approved ShipGlows system plan. | draft | Run `101-sg-ready` against this spec. |
| 2026-08-26 12:20:00 UTC | 100-sg-spec | GPT-5 Codex | Adversarially reviewed provenance, stale-state, collision, host-parity, retention, and proof boundaries; tightened every implementation task with exact targets and validation. | reviewed | Run `101-sg-ready` against this spec. |
| 2026-08-26 12:22:00 UTC | 101-sg-ready | GPT-5 Codex | Confirmed autonomous user-story fit, ordered targets and validations, ZOMBIES coverage, GitHub/file trust boundaries, OWASP gate, documentation ownership, and explicit host limitations. | ready | Implement through `102-sg-start`. |
| 2026-08-26 12:31:00 UTC | 102-sg-start | GPT-5 Codex | Implemented and scenario-tested the Windows artifact cache, four managed shortcut lanes, local publication, trusted CI synchronization, fail-closed boundaries, and installer packaging. | in progress | Complete mapped technical documentation and integrated verification. |
| 2026-08-26 12:35:00 UTC | 102-sg-start | GPT-5 Codex | Completed the mapped technical documentation, installer boundary, code-doc ownership, and direct CLI status proof. | implemented | Run integrated `103-sg-verify` proof. |
| 2026-08-26 12:39:00 UTC | 103-sg-verify | GPT-5 Codex | Verified the four-lane behavior, last-known-good failures, option/provenance boundaries, CLI entrypoint, PowerShell syntax, metadata, dependency graph, skill budget, Codex runtime visibility, and Git hygiene. | verified | Close documentation/editorial state, then ship the final exact scope. |
| 2026-08-26 12:40:00 UTC | 104-sg-end | GPT-5 Codex | Closed the unique verified chantier, aligned the changelog, confirmed no matching task row, classified technical documentation as updated and public editorial surfaces as not impacted. | closed | Ship the bounded closure trace. |
| 2026-08-26 12:40:00 UTC | 005-sg-ship | GPT-5 Codex | Persisted the specification, implementation, tests, doctrine, installer packaging, and technical documentation to the configured task-branch upstream without the unrelated business document. | shipped | Integrate local and CI publication in the first managed project. |

## Current Chantier Flow

- `100-sg-spec`: complete — autonomous contract authored and adversarially reviewed.
- `101-sg-ready`: ready — no blocking ambiguity remains.
- `102-sg-start`: complete — implementation, focused fixtures, installer packaging, and mapped documentation are coherent.
- `103-sg-verify`: complete — standard proof matches the scenario-first contract; no external project workflow or device claim is made.
- `104-sg-end`: complete — source-of-truth and changelog are aligned; no matching task record existed and no public claim changed.
- `005-sg-ship`: complete — bounded commits are remotely persisted on `origin/codex/development-runtime`; no deployment or project build is claimed.
