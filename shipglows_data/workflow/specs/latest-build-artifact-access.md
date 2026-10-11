---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.7"
project: ShipGlows
created: "2026-08-26"
created_at: "2026-08-26 12:18:53 UTC"
updated: "2026-10-04"
updated_at: "2026-10-04 00:00:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: latest-build-artifact-access
owner: Diane
user_story: "As the ShipGlows operator, I want validated local and CI builds cached and discoverable through ShipGlows commands, while keeping my Desktop shortcuts for live Dev projects only."
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
    artifact_version: "3.11.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-26: successful test builds need stable desktop access instead of deep build paths."
  - "Operator decision 2026-08-26: Local and CI artifact lanes distinguish source and platform."
  - "Operator decision 2026-10-04: Desktop shortcuts are only for live Dev projects; built artifacts stay in the cache and are accessed through ShipGlows commands."
  - "GitHub documents workflow artifacts as archived outputs that authenticated readers can download before retention expiry."
  - "Apple Xcode and iOS execution remain macOS/device surfaces; Windows must not present an IPA as locally runnable."
next_step: "Complete no-build-shortcut implementation and mapped documentation; run focused proof only when requested."
---

# Latest Build Artifact Access

## Title

Latest Build Artifact Access

## Status

in progress — implementation is being aligned to the 2026-10-04 operator decision that Desktop shortcuts are for Dev projects only.

## User Story

As the ShipGlows operator, when an agent completes a local release build or observes a successful trusted CI build, I want the validated artifact cached and its exact path available from ShipGlows commands, while keeping the Desktop limited to live Dev project shortcuts.

## Minimal Behavior Contract

After a successful build, ShipGlows publishes the validated artifact into a private machine-local cache, records its source and integrity metadata atomically, and exposes the cached path through its command output. Local and CI lanes remain separate. Artifact publication never creates or modifies a Desktop shortcut. A failed, missing, expired, ambiguous, oversized, untrusted, or malformed candidate leaves the previous valid lane untouched. The easiest missed edge case is a newer failed CI run or deleted worktree replacing a still-usable last-known-good artifact.

## Success Behavior

- A successful local Windows release is cached and `status` reports its `entryPath` in the Windows Local lane.
- A successful trusted CI Windows artifact is cached and `status` reports its `entryPath` in the Windows CI lane.
- Successful local and CI Android artifacts are cached separately and their APK paths appear in the Android APK Local and CI status lanes; publication never installs either APK.
- Spaces in project names and paths are preserved safely through literal-path handling.
- Each cached artifact remains available if the originating worktree is later removed.
- State records source kind, platform, project identity, creation time, source commit/run when available, artifact SHA-256, and cached path without secrets.
- Artifact publication creates or modifies no Desktop shortcut; Desktop shortcuts use `<Project> - Dev` and launch live Dev sessions.

## Error Behavior

- Failed builds never invoke artifact publication and never alter the Desktop.
- Missing GitHub authentication, missing artifacts, expired artifacts, unsuccessful runs, disallowed workflow events, multiple entrypoint candidates, path escape, reparse points, or size overflow fail closed with an actionable error.
- Windows does not claim Linux binaries or iOS IPA files are runnable. Unsupported host/platform pairs receive an explicit error and are not cached.
- Partial cache/state writes are rolled back or remain unreferenced; the previous valid state stays active.

## Problem

ShipGlows reports deep build paths but owns no durable cache for testable native artifacts. Git worktrees and GitHub artifact retention make those paths temporary.

## Solution

Keep the shared latest-build access doctrine and Windows artifact manager. The manager copies successful local or downloaded CI outputs into a private per-project, per-platform, per-source cache; validates provenance and bounds; writes state atomically; and lets build agents register local outputs, synchronize a named GitHub Actions artifact, or inspect status. It never creates build shortcuts on the Desktop.

## Scope In

- Separate Windows Local, Windows CI, Android APK Local, and Android APK CI lanes.
- Stable private cache under the current user's local ShipGlows application-data root.
- GitHub CLI read-only selection and download of one named artifact from one successful trusted run.
- Atomic state replacement, integrity hashes, bounded extracted content, reparse/path checks, and last-known-good preservation.
- Installer/runtime packaging, shared agent doctrine, focused Windows tests, and mapped technical documentation.
- Compatibility doctrine for Linux, macOS, and iOS without pretending cross-host execution.

## Scope Out

- Adding or changing application-specific GitHub Actions workflows.
- Uploading CI artifacts, dispatching workflows, writing to GitHub, or changing repository permissions.
- Automatic APK installation, ADB use, emulator/device startup, application launch, code signing, notarization, TestFlight, or App Store operations.
- Background polling, resident services, notification daemons, or automatic network access at ShipGlows startup.
- Live Dev shortcut behavior; it remains owned by the Windows DevServer.
- Automatic cleanup beyond two validated generations per lane.

## Constraints

- The command runs only after an agent has proven local build success or while explicitly synchronizing CI artifacts.
- CI synchronization requires an explicit repository, workflow, branch, artifact name, platform, and project target.
- GitHub access is read-only and uses the existing authenticated `gh` session; credentials and tokens never enter arguments, state, or logs.
- Allowed CI events default to `push`, `workflow_dispatch`, and `release`; other event types require a future explicit policy decision.
- Cache and state are private, bounded, and versioned; build publication has no Desktop write path.
- All filesystem paths are canonicalized, bounded beneath their declared roots, handled literally, and checked for reparse points.
- User-facing project Dev shortcuts use `<Project> - Dev`; artifact lanes use closed platform/source labels.

## Test Contract

- Proof path: `scenario-first` with focused PowerShell fixtures.
- Automated proof: local publish, CI selection/download through an injected fake GitHub runner, state parsing, SHA-256, no Desktop writes, last-known-good preservation, size/path/reparse rejection, and installer packaging assertions.
- External proof: not required for this implementation checkpoint; tests use a temporary desktop, cache, project, and fake GitHub output. A real project CI artifact remains a separate project-owned integration proof.
- Browser/auth/device/manual proof: not applicable because no application is launched, authenticated, installed, or deployed.
- Pressure scenario `BUILD-ACCESS-LAST-GOOD`: a newer failed local or CI candidate cannot replace the prior valid cache lane.
- Pressure scenario `BUILD-ACCESS-SOURCE-LABEL`: Local and CI cache lanes remain distinct for the same project and platform.
- Pressure scenario `BUILD-ACCESS-WORKTREE-REMOVAL`: command status exposes the private cache path rather than the disposable worktree.
- Pressure scenario `BUILD-ACCESS-DESKTOP-BOUNDARY`: publishing Windows and Android artifacts never creates or modifies Desktop shortcuts.
- Pressure scenario `BUILD-ACCESS-CI-TRUST`: only a successful explicitly selected trusted run and named artifact can be published.
- Pressure scenario `BUILD-ACCESS-HOST-PARITY`: Windows never presents Linux or iOS artifacts as runnable.

## Dependencies

- Windows PowerShell Core runtime managed by ShipGlows.
- Existing GitHub CLI authentication for CI synchronization.
- An application workflow that already uploads a usable complete Windows package or Android APK artifact.

## Invariants

- No build is launched by the artifact manager.
- No artifact is cached before upstream build success is established.
- Artifact publication never creates or changes Desktop shortcuts.
- Local and CI last-known-good states are independent.
- Windows packages retain required sibling DLL/data files.
- Android publication never means installed or device-tested.
- CI download never means provenance attestation, release approval, deployment, or production verification.
- No secret, token, private log payload, or arbitrary command is persisted.

## Links & Consequences

- `agent-runtime-awareness.md` becomes the shared trigger contract for Windows/Android build agents.
- Windows installers must package both the module and command entrypoint.
- Project-specific workflows may later need a separate spec to upload named complete artifacts.
- Build reports must name the cached path or an actionable reason it was not produced.
- Linux/macOS consumers can reuse the state schema later but require host-native artifact access implementations.

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
- A legacy build `.lnk` or unrelated Desktop link is never touched by artifact publication.
- GitHub run succeeds but artifact download fails or artifact has expired.
- Linux executable, macOS app, or iOS IPA observed on Windows.

## ZOMBIES Coverage

- Z: no previous state, empty download, missing entrypoint, and no successful run fail without publishing a cache lane; valid publication creates no shortcut.
- O: one valid local Windows package and one valid Android APK publish successfully.
- M: multiple projects, platforms, source lanes, candidates, generations, and repeated publications remain isolated and bounded.
- B: path root, maximum bytes/files, and generation-retention boundaries are checked.
- I: build agent → artifact command → GitHub CLI/filesystem → cache/state boundaries are explicit.
- E: failed build, GitHub denial/expiry, ambiguous artifact, interrupted write, reparse point, and unsupported host recover without losing last-known-good state.
- S: four explicit lanes and one command surface avoid a background service or cross-platform runtime abstraction.

## Implementation Tasks

1. Target `skills/references/latest-build-artifact-access.md` and `skills/references/agent-runtime-awareness.md`; define the post-success trigger, four lane names, platform behavior, exact command surface, failure semantics, and report obligation. User-story link: a fresh build agent can publish access without conversation memory. Dependency: this ready spec. Validation: focused `rg` assertions in `tests/windows/build-artifacts.ps1`.
2. Target `cli/windows/ShipGlows.BuildArtifacts.psm1` and `cli/windows/shipglows-build-artifacts.ps1`; implement stable project identity, local publication, CI synchronization, status, atomic cache/state, two-generation retention, and host/platform gates without Desktop writes. User-story link: cached artifacts remain discoverable through commands. Dependency: task 1. Validation: `pwsh -NoProfile -File tests/windows/build-artifacts.ps1`.
3. Target `cli/windows/install-devserver.ps1` and `install-shipglows.ps1`; package both new Windows surfaces without activating them during installation. User-story link: the doctrine is available from installed ShipGlows. Dependency: task 2. Validation: focused payload assertions in `tests/windows/build-artifacts.ps1` plus PowerShell syntax parsing.
4. Target `tests/windows/build-artifacts.ps1`; keep deterministic temporary cache/project fixtures for local Windows, local APK, CI selection/download, source separation, worktree-source removal, last-known-good, no Desktop writes, bounds, reparse/path checks, ambiguous candidates, and unsupported platforms. User-story link: recurrence is caught mechanically. Dependency: tasks 1–3. Validation: the test file exits zero and emits its success marker.
5. Target `shipglows_data/technical/latest-build-artifact-access.md`, `shipglows_data/technical/code-docs-map.md`, and `shipglows_data/technical/README.md`; document ownership, entrypoints, schema, invariants, validation, platform matrix, Reader checklist, and maintenance trigger. User-story link: future agents and maintainers can find and preserve the behavior. Dependency: tasks 1–4. Validation: metadata lint for new metadata-bearing artifacts and focused link scans.
6. Target this spec plus the exact owned implementation/doc/test files; run focused proof, verify acceptance, update flow/history, scan staged content for secrets, and deliver exact-scope commits to `origin/codex/development-runtime`. User-story link: the durable ShipGlows system change is remotely protected. Dependency: tasks 1–5. Validation: focused test, metadata lint, `git diff --check`, staged-path inspection, commit reachability, and ordinary push result.

## Acceptance Criteria

- [x] Four source-labelled cache lanes are deterministic and safely preserve spaces.
- [ ] Windows and Android Local/CI artifacts are cached and their paths appear in status; artifact publication creates no Desktop shortcuts.
- [x] A successful local publish survives removal of its source worktree.
- [x] CI synchronization selects one successful allowed-event run and one explicitly named artifact through existing GitHub CLI authentication.
- [x] State contains no credentials and records canonical provenance plus SHA-256.
- [x] Failed or unsafe candidates leave the previous valid cache lane and state unchanged.
- [x] Path escapes, reparse points, oversize packages, and ambiguous entrypoints fail closed.
- [x] Linux/macOS/iOS limitations are represented honestly; Windows creates no misleading Desktop access for them.
- [x] Installer payloads include the module and command entrypoint.
- [ ] Focused Windows tests and metadata checks pass for the revised Desktop boundary.
- [x] Technical documentation and code-doc mappings are coherent.
- [ ] Exact-scope commits are pushed to `origin/codex/development-runtime` without unrelated changes.

## Test Strategy

- Build a temporary fixture project with spaces in its name, a fake Windows release directory, and a fake APK.
- Assert local and CI artifact publication leaves a temporary Desktop empty of `.lnk` files.
- Inject a fake GitHub runner that returns a successful allowed-event run and materializes a named artifact under a bounded staging directory.
- Exercise failure before state commit for missing/failed runs, collisions, size/file-count boundaries, reparse points when supported, and ambiguous entrypoints.
- Assert cached targets remain after deleting fixture source packages.
- Run PowerShell syntax validation and installer payload scans.

## OWASP Security Gate

- Categories considered: A03 Software Supply Chain Failures, A05 Injection, A06 Insecure Design, A08 Software or Data Integrity Failures, and A10 Mishandling of Exceptional Conditions.
- Trust boundaries: authenticated GitHub CLI output, workflow/run metadata, downloaded files, local build paths, private cache, and state JSON.
- Authorization: the operator-approved ShipGlows build workflow may publish only explicit project/platform/source lanes; arbitrary repositories, commands, URLs, or credentials are not persisted or executed.
- Selected ASVS requirements: not claimed; this is a local developer-tool workflow rather than an application security control. The focused scenarios prove path, provenance, integrity-recording, collision, and failure boundaries.
- Residual gap: GitHub artifact attestation verification and platform code-signature verification are outside this tranche and must not be implied by SHA-256 recording.

## Risks

- A compromised trusted workflow could publish a malicious binary; mitigation is explicit repository/workflow/branch/event selection, no automatic launch, provenance recording, and honest residual-risk reporting.
- Large packages could consume disk; mitigation is byte/file bounds and retention of at most two validated generations per lane.
- Worktree identity could fragment cached lanes; mitigation is stable origin plus project-relative identity with a non-Git fallback.
- App-specific workflows may not upload usable packages; mitigation is an actionable gap rather than guessed artifact selection.

## Execution Notes

- Topology: main-only; the implementation is one cohesive Windows subsystem and delegation would add coordination without independent scope value.
- First-read files: `skills/references/agent-runtime-awareness.md`, `cli/windows/install-devserver.ps1`, `install-shipglows.ps1`, `tests/windows/developer-corpus.ps1`, and `shipglows_data/technical/code-docs-map.md`.
- Proof profile: scenario-first.
- Pressure scenario: an agent finishes a Flutter Windows Release build in a disposable worktree and reports only the deep `app.exe` path. The system caches the complete package, exposes it through `status`, preserves separate Local and CI lanes, creates no Desktop shortcut, and never replaces the prior lane after a failed subsequent build.
- Followability Gate: a fresh build agent must find the trigger and exact command from `agent-runtime-awareness.md`, while detailed behavior remains in one shared reference and mechanical tests catch omissions.
- Fresh official evidence checked: GitHub Actions artifact download/retention documentation and Apple Xcode host requirements, 2026-08-26.
- No dependency installation, server, application build, browser, device, deployment, workflow dispatch, or real artifact download is authorized for this implementation proof.

## Open Questions

The operator selected Desktop shortcuts for live Dev projects only; Local and CI artifact cache lanes remain available through ShipGlows commands. Windows and Android cache support and honest Linux/macOS/iOS compatibility boundaries remain in scope.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-26 12:18:53 UTC | 100-sg-spec | GPT-5 Codex | Authored the durable local/CI build artifact access contract from the approved ShipGlows system plan. | draft | Run `101-sg-ready` against this spec. |
| 2026-08-26 12:20:00 UTC | 100-sg-spec | GPT-5 Codex | Adversarially reviewed provenance, stale-state, collision, host-parity, retention, and proof boundaries; tightened every implementation task with exact targets and validation. | reviewed | Run `101-sg-ready` against this spec. |
| 2026-08-26 12:22:00 UTC | 101-sg-ready | GPT-5 Codex | Confirmed autonomous user-story fit, ordered targets and validations, ZOMBIES coverage, GitHub/file trust boundaries, OWASP gate, documentation ownership, and explicit host limitations. | ready | Implement through `102-sg-start`. |
- `102-sg-start`: implemented — code, documentation, and fixtures reflect the Dev-only Desktop decision; focused proof remains open.
| 2026-08-26 12:35:00 UTC | 102-sg-start | GPT-5 Codex | Completed the mapped technical documentation, installer boundary, code-doc ownership, and direct CLI status proof. | implemented | Run integrated `103-sg-verify` proof. |
| 2026-08-26 12:39:00 UTC | 103-sg-verify | GPT-5 Codex | Verified the four-lane behavior, last-known-good failures, option/provenance boundaries, CLI entrypoint, PowerShell syntax, metadata, dependency graph, skill budget, Codex runtime visibility, and Git hygiene. | verified | Close documentation/editorial state, then ship the final exact scope. |
| 2026-08-26 12:40:00 UTC | 104-sg-end | GPT-5 Codex | Closed the unique verified chantier, aligned the changelog, confirmed no matching task row, classified technical documentation as updated and public editorial surfaces as not impacted. | closed | Ship the bounded closure trace. |
| 2026-08-26 12:40:00 UTC | 005-sg-ship | GPT-5 Codex | Persisted the specification, implementation, tests, doctrine, installer packaging, and technical documentation to the configured task-branch upstream without the unrelated business document. | shipped | Integrate local and CI publication in the first managed project. |
| 2026-10-04 17:54:16 UTC | 102-sg-start | GPT-6 Codex | Renamed Flutter Dev shortcuts to `<Project> - Dev` with safe legacy cleanup; removed build-artifact Desktop writes and aligned cache, status, fixtures, and documentation. | implemented; focused proof not run | Run the updated Windows artifact fixture and mapped metadata checks. |

## Current Chantier Flow

- `100-sg-spec`: complete — autonomous contract authored and adversarially reviewed.
- `101-sg-ready`: ready — no blocking ambiguity remains.
- `102-sg-start`: implemented — code, documentation, and fixtures reflect the Dev-only Desktop decision; focused proof remains open.
- `103-sg-verify`: pending — revised fixture, metadata, and integration proof remain open.
- `104-sg-end`: pending — close after proof and documentation review.
- `005-sg-ship`: pending — no commit or push was requested.
