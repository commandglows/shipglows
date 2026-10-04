---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipGlows
created: "2026-08-26"
updated: "2026-10-04"
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
    artifact_version: "1.0.7"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator decision 2026-10-04: artifact publication never creates Desktop shortcuts; shortcuts are reserved for live Dev projects."
  - "Focused Windows fixtures cover four source-labelled cache lanes, cached-package survival, CI selection, no Desktop writes, bounded retention, and fail-closed path handling."
  - "Windows installer payload assertions prove the module and command entrypoint are packaged without activating artifact access during installation."
next_review: "2026-11-26"
next_step: "/104-sg-end latest-build-artifact-access"
---

# Latest Build Artifact Access

## Purpose

This subsystem caches the latest successful test builds so their paths remain available after a worktree is removed or a CI artifact expires. It owns four independent lanes per project: Windows Local, Windows CI, Android APK Local, and Android APK CI. It does not create Desktop shortcuts; those are reserved for live Dev projects.

## Owned Files

| Path | Responsibility |
| --- | --- |
| `cli/windows/ShipGlows.BuildArtifacts.psm1` | Cache, validation, state, retention, and GitHub artifact synchronization engine |
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

State schema `shipglows-build-artifact/v1` records the project identity and display name, platform, source kind, source identifier, optional commit, creation time, SHA-256, cached generation/entrypoint, and closed bounded CI provenance. Older state files may contain a retired `shortcutPath`; status ignores it. State persists no token, credential, command, argument list, URL containing credentials, PID, or private build log.

Writes are staged and atomic. State replacement happens only after the package validates; rollback preserves the prior last-known-good lane when publication fails. The `status` command returns the cached `entryPath` for each populated lane.

## Naming And Platform Matrix

| Host artifact | Local cache lane | CI cache lane | Windows behavior |
| --- | --- | --- | --- |
| Windows package | `Windows - Local` | `Windows - CI` | Report the cached `.exe` path and retain the complete package |
| Android APK | `Android APK - Local` | `Android APK - CI` | Report the cached `.apk` path; never install |
| Linux/AppImage | none | none | Unsupported by this Windows cache |
| macOS `.app` / iOS `.ipa` | none | none | Requires a future native artifact access path or applicable Apple build/device path |

Artifact publication has no Desktop write path. Development shortcuts use `<Project> - Dev` and are owned by the DevServer. Spaces in project names and filesystem paths remain supported.

## Invariants And Security

- A build-success proof precedes local publication; CI must match the explicit repository, workflow, branch, successful conclusion, allowed event, and artifact name.
- The default allowed CI events are `push`, `workflow_dispatch`, and `release`.
- Package paths remain inside their declared roots. Reparse points, path escape, missing or ambiguous entrypoints, unsupported extensions, malformed state, excess bytes, and excess file counts fail closed.
- Artifact publication never creates or modifies a Desktop shortcut.
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

- Does the changed behavior preserve all four source-labelled cache lanes?
- Does command status expose a private cached artifact rather than a worktree or extraction staging directory?
- Does failure preserve the previous last-known-good state?
- Does artifact publication leave Desktop shortcuts to the DevServer?
- Does a Windows package retain every required sibling file?
- Is Android still reveal-only, and are Linux/macOS/iOS limitations honest?
- Are GitHub selection and the allowlisted persisted provenance fields closed, bounded, option-safe, and credential-free?
- Do installer changes package the surfaces without performing publication?
- Do focused tests cover the new success and failure branch?

## Maintenance Rule

Update this document, the shared doctrine, the spec, and the focused fixtures whenever cache/state schema, project identity, Desktop shortcut exclusion, provenance fields, CI trust selection, platform behavior, package bounds, retention, command parameters, or installer payload changes. Project-specific workflow artifact uploads remain owned by that project and require their own reviewed change.

Official reference boundaries: [GitHub Actions artifacts](https://docs.github.com/actions/using-workflows/storing-workflow-data-as-artifacts) and [Apple Xcode requirements](https://developer.apple.com/support/xcode/).
