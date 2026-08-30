---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-08-26"
updated: "2026-08-26"
status: reviewed
source_skill: 900-shipglows-core
scope: latest-build-artifact-access
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.BuildArtifacts.psm1
  - cli/windows/shipglows-build-artifacts.ps1
  - tests/windows/build-artifacts.ps1
  - skills/references/latest-build-artifact-access.md
  - shipglows_data/workflow/specs/latest-build-artifact-access.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/latest-build-artifact-access.md"
    artifact_version: "1.0.6"
    required_status: reviewed
supersedes: []
evidence:
  - "Focused Windows fixtures prove four source-labelled lanes, cached-package survival, CI selection, collision protection, bounded retention, and fail-closed path handling."
  - "Windows installer payload assertions prove the module and command entrypoint are packaged without activating artifact access during installation."
next_review: "2026-11-26"
next_step: "/104-sg-end latest-build-artifact-access"
---

# Latest Build Artifact Access

## Purpose

This subsystem gives an operator stable access to the latest successful test build without depending on a disposable worktree or a deep CI artifact path. It owns four independent lanes per project: Windows Local, Windows CI, Android APK Local, and Android APK CI.

## Owned Files

| Path | Responsibility |
| --- | --- |
| `cli/windows/ShipGlows.BuildArtifacts.psm1` | Cache, validation, state, shortcut, retention, and GitHub artifact synchronization engine |
| `cli/windows/shipglows-build-artifacts.ps1` | Closed command surface for local publication, CI synchronization, and status |
| `skills/references/latest-build-artifact-access.md` | Agent trigger, commands, platform limits, and reporting doctrine |
| `skills/references/agent-runtime-awareness.md` | Shared discoverability for post-build publication |
| `tests/windows/build-artifacts.ps1` | Deterministic Windows contract and adversarial fixtures |
| `cli/windows/install-devserver.ps1`, `install-shipglows.ps1` | Installed-runtime packaging only; neither activates publication during installation |

## Entrypoints

The profile-independent entrypoint is:

```powershell
pwsh -NoProfile -File "$env:SHIPGLOWS_ROOT\cli\windows\shipglows-build-artifacts.ps1" <register-local|sync-ci|status> ...
```

`register-local` accepts a proven successful local Windows package or Android APK. `sync-ci` reads one explicit successful GitHub Actions run and downloads one named artifact through the existing authenticated `gh` session. `status` reports all four lanes and performs no repair.

The command never starts a build, dispatches a workflow, launches an application, installs an APK, changes authentication, or deploys.

## Cache And State

The default private root is `%LOCALAPPDATA%\ShipGlows\BuildArtifacts`. A stable project identifier derives from the Git origin plus project-relative path when available, with a canonical absolute-path fallback. Each `windows|android` and `local|ci` lane owns a state file and at most two validated generations.

State schema `shipglows-build-artifact/v1` records the project identity and display name, platform, source kind, source identifier, optional commit, creation time, SHA-256, cached generation/entrypoint, shortcut path, and closed bounded CI provenance. It persists no token, credential, command, argument list, URL containing credentials, PID, or private build log.

Writes are staged and atomic. The shortcut changes only after the package validates; state and shortcut rollback preserve the prior last-known-good lane when publication fails.

## Naming And Platform Matrix

| Host artifact | Local shortcut | CI shortcut | Windows behavior |
| --- | --- | --- | --- |
| Windows package | `ShipGlows - <Project> - Windows - Local.lnk` | `ShipGlows - <Project> - Windows - CI.lnk` | Launch cached `.exe` with its cached package as working directory |
| Android APK | `ShipGlows - <Project> - Android APK - Local.lnk` | `ShipGlows - <Project> - Android APK - CI.lnk` | Open Explorer with cached APK selected; never install |
| Linux/AppImage | none | none | Unsupported by this Windows implementation |
| macOS `.app` / iOS `.ipa` | none | none | Requires a future macOS-native presentation or Apple build/device path |

Spaces are valid in visible shortcut names and filesystem paths. Unsafe Windows filename characters in the project display name are rejected.

## Invariants And Security

- A build-success proof precedes local publication; CI must match the explicit repository, workflow, branch, successful conclusion, allowed event, and artifact name.
- The default allowed CI events are `push`, `workflow_dispatch`, and `release`.
- Package paths remain inside their declared roots. Reparse points, path escape, missing or ambiguous entrypoints, unsupported extensions, malformed state, excess bytes, and excess file counts fail closed.
- An existing `.lnk` is replaceable only when its exact ShipGlows ownership marker matches the project and lane. Same-name user shortcuts remain untouched.
- Local and CI state never replace one another. A newer invalid candidate never replaces a usable generation.
- SHA-256 records integrity after acquisition; it is not code signing, artifact attestation, release approval, or malware analysis.
- GitHub artifact retention can expire remote downloads, so the local cache is the durable test-access boundary after successful synchronization.

## Validation

Run the focused contract on Windows:

```powershell
pwsh -NoLogo -NoProfile -File tests/windows/build-artifacts.ps1
```

Also parse the module, entrypoint, installers, and test with the PowerShell parser; run metadata lint for this document and its mapped artifacts; run the skill dependency graph audit after doctrine dependencies change; and finish with `git diff --check`.

The fixtures use a temporary Desktop/cache/project and an injected GitHub runner. They do not access a real repository, download an external artifact, install an APK, or launch the cached application.

## Reader Checklist

- Does the changed behavior preserve all four visibly source-labelled lanes?
- Does the shortcut target a private cached artifact rather than a worktree or extraction staging directory?
- Does failure preserve the previous state and shortcut?
- Does a Windows package retain every required sibling file?
- Is Android still reveal-only, and are Linux/macOS/iOS limitations honest?
- Are GitHub selection and the allowlisted persisted provenance fields closed, bounded, option-safe, and credential-free?
- Do installer changes package the surfaces without performing publication?
- Do focused tests cover the new success and failure branch?

## Maintenance Rule

Update this document, the shared doctrine, the spec, and the focused fixtures whenever cache/state schema, project identity, shortcut naming, provenance fields, CI trust selection, platform behavior, package bounds, retention, collision ownership, command parameters, or installer payload changes. Project-specific workflow artifact uploads remain owned by that project and require their own reviewed change.

Official reference boundaries: [GitHub Actions artifacts](https://docs.github.com/actions/using-workflows/storing-workflow-data-as-artifacts) and [Apple Xcode requirements](https://developer.apple.com/support/xcode/).
