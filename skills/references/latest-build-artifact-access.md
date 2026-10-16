---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-26"
updated: "2026-10-16"
status: active
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
  - skills/references/agent-runtime-awareness.md
  - tests/windows/build-artifacts.ps1
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-30: managed flutter run is the ordinary development loop; build lanes remain release and explicit standalone-validation checkpoints."
  - "Operator decision 2026-08-26: every successful testable build needs direct access without deep-path navigation."
  - "Operator decision 2026-08-26: Local and CI artifact lanes remain visibly distinct."
  - "Focused pressure scenarios preserve last-known-good cached artifacts and reject unsafe paths."
  - "Operator decision 2026-10-04: Desktop shortcuts are reserved for live Dev projects; built artifacts remain in ShipGlows cache and command status."
  - "Operator decision 2026-10-15: only shipglows-dev start creates canonical `<repository>-<surface> - Dev` shortcuts; raw release outputs are deleted once the registered build is tested."
next_review: "2026-11-26"
next_step: "/103-sg-verify latest build artifact access"
---

# Latest Build Artifact Access

This contract is not the ordinary Flutter development loop. Iterative Flutter work uses the managed live `flutter run` session, and performance measurement uses the managed profile session (`s start … -FlutterMode profile`), not a build lane. Refresh a build lane only after a successful release build or an explicit standalone/package-sensitive validation checkpoint.

## Trigger

Apply this contract after a successful Windows release or Android APK build, or after an agent observes a successful trusted GitHub Actions build whose workflow already uploads a complete named artifact. Never run publication before build success is proven.

## Cache lanes

Keep four independent per-project cache lanes, identified in status output as:

- `Windows - Local`
- `Windows - CI`
- `Android APK - Local`
- `Android APK - CI`

ShipGlows copies each validated package into its per-user local cache, so deleting a worktree does not invalidate the published build. Artifact publication does not create or modify Desktop shortcuts.

Desktop shortcuts are created only by `shipglows-dev start` for live development servers and use the name `<repository>-<surface> - Dev`. Build artifacts are accessed through the ShipGlows command output; publication never launches a Windows executable, installs an APK, starts a device, or proves device behavior.

## Cleanup after testing

The cache keeps the last two validated generations per lane, so the raw release output in the checkout is redundant once registered. After the registered build has been tested, delete `build\windows\x64\runner\Release` or `build\app\outputs` in that checkout. Never delete the cache lanes by hand.

## Agent commands

Resolve the installed or linked ShipGlows root first, then call its Windows entrypoint. For a local Windows build, provide the complete release directory as `PackageRoot` and its app executable as `ArtifactPath`:

```powershell
pwsh -NoProfile -File "$env:SHIPGLOWS_ROOT\cli\windows\shipglows-build-artifacts.ps1" register-local -ProjectPath <project> -ProjectName <name> -Platform windows -PackageRoot <release-directory> -ArtifactPath <app.exe> -Commit <sha>
```

For an Android build, use `-Platform android`, the APK parent as `PackageRoot`, and the exact `.apk` as `ArtifactPath`.

For CI, supply an explicit repository, workflow, branch, artifact name, and optional entrypoint relative to the downloaded artifact:

```powershell
pwsh -NoProfile -File "$env:SHIPGLOWS_ROOT\cli\windows\shipglows-build-artifacts.ps1" sync-ci -ProjectPath <project> -ProjectName <name> -Platform windows -Repository <owner/repo> -Workflow <workflow> -Branch <branch> -ArtifactName <artifact> -EntryRelativePath <relative-app.exe>
```

The CI command is read-only toward GitHub and uses the existing authenticated `gh` session. It never dispatches a workflow or writes credentials. If the project does not upload a usable artifact, report the exact missing workflow/artifact contract and leave the prior cached lane unchanged; adding that workflow is a separate project chantier.

## Safety and failure contract

- Persist no secret, token, credential, command, or free-form argument.
- Accept CI only from one explicit repository/workflow/branch, a successful run, an allowed event, and one named artifact.
- Bound bytes and file count; reject reparse points, path escape, missing or ambiguous entrypoints, malformed state, and unsupported platforms.
- Never create or modify a Desktop shortcut for a build artifact.
- Keep Local and CI last-known-good state independent. Failure never deletes or replaces the previous valid lane.
- Record SHA-256 and provenance as integrity evidence, not as code-signing, attestation, release approval, or safety proof.
- Do not launch or install an artifact automatically.

## Platform honesty

- Windows `.exe`: validated package caching and local-path reporting are supported on Windows.
- Android `.apk`: cached-file reporting is supported on Windows; installation and device proof are separate.
- Linux binary/AppImage: unsupported by this Windows artifact cache.
- macOS `.app` and iOS `.ipa`: require a future macOS-native artifact access path and applicable Apple tooling/device proof.

## Reporting and proof

After publication, report the lane and cached artifact path from the command output. If publication is skipped or fails, report the exact reason and confirm whether a prior last-known-good cached artifact remains. Focused proof is `tests/windows/build-artifacts.ps1`; real CI or device proof remains project-owned.
