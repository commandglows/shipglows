---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-26"
updated: "2026-08-26"
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
  - "Operator decision 2026-08-26: every successful testable build needs direct access without deep-path navigation."
  - "Operator decision 2026-08-26: Local and CI shortcut titles remain visibly distinct."
  - "Focused pressure scenarios preserve last-known-good artifacts and reject unowned shortcut collisions."
next_review: "2026-11-26"
next_step: "/103-sg-verify latest build artifact access"
---

# Latest Build Artifact Access

## Trigger

Apply this contract after a successful Windows release or Android APK build, or after an agent observes a successful trusted GitHub Actions build whose workflow already uploads a complete named artifact. Never run publication before build success is proven.

## Required Windows outcome

Keep four independent per-project lanes and exact visible suffixes:

- `Windows - Local`
- `Windows - CI`
- `Android APK - Local`
- `Android APK - CI`

Spaces in shortcut names and artifact paths are supported and must be passed as literal arguments. ShipGlows copies the validated package into its per-user local cache before changing the lane shortcut, so deleting a worktree does not invalidate the published build.

Windows shortcuts launch the cached `.exe` from its complete package and working directory. Android shortcuts open Explorer with the cached `.apk` selected; publication never installs the APK, starts a device, or proves device behavior.

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

The CI command is read-only toward GitHub and uses the existing authenticated `gh` session. It never dispatches a workflow or writes credentials. If the project does not upload a usable artifact, report the exact missing workflow/artifact contract and leave shortcut state unchanged; adding that workflow is a separate project chantier.

## Safety and failure contract

- Persist no secret, token, credential, command, or free-form argument.
- Accept CI only from one explicit repository/workflow/branch, a successful run, an allowed event, and one named artifact.
- Bound bytes and file count; reject reparse points, path escape, missing or ambiguous entrypoints, malformed state, and unsupported platforms.
- Overwrite a shortcut only when its exact ShipGlows marker matches the same project/platform/source lane.
- Keep Local and CI last-known-good state independent. Failure never deletes or replaces the previous valid lane.
- Record SHA-256 and provenance as integrity evidence, not as code-signing, attestation, release approval, or safety proof.
- Do not launch or install an artifact automatically.

## Platform honesty

- Windows `.exe`: shortcut creation and launch are supported on Windows.
- Android `.apk`: cached-file discovery is supported on Windows; installation and device proof are separate.
- Linux binary/AppImage: runnable shortcuts belong to a future Linux host implementation; Windows may not claim compatibility.
- macOS `.app`: runnable aliases belong to a future macOS host implementation.
- iOS `.ipa`: build/sign/test requires Apple tooling and an applicable macOS/device/TestFlight path; Windows creates no runnable shortcut.

## Reporting and proof

After publication, report the lane and shortcut name. If publication is skipped or fails, report the exact reason and confirm whether a prior last-known-good shortcut remains. Focused proof is `tests/windows/build-artifacts.ps1`; real CI or device proof remains project-owned.
