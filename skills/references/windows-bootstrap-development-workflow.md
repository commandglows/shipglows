---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-08-11"
updated: "2026-08-11"
status: active
source_skill: manual
scope: windows-bootstrap-development-workflow
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - install-shipglows.ps1
  - cli/windows/install-devserver.ps1
  - tests/windows/devserver-contract.sh
  - shipglows_data/technical/installer-and-user-scope.md
depends_on:
  - artifact: "shipglows_data/technical/installer-and-user-scope.md"
    artifact_version: "1.1.10"
    required_status: reviewed
supersedes: []
evidence:
  - "Windows bootstrap branch installation and migration validated on 2026-08-11."
  - "A download-only refresh left the active DevServer stale during the Windows repository-picker fix on 2026-08-11."
next_review: "2026-09-11"
next_step: "/103-sg-verify Windows bootstrap development workflow"
---

# Windows Bootstrap Development Workflow

Use this reference when an agent changes or tests the native Windows ShipGlows bootstrap, installer, runtime paths, wrappers, migration behavior, or self-update flow.

## Canonical Layout

- Installed runtime: `%USERPROFILE%\.shipglows` (internal and hidden; never edit it as source).
- Development clone: `%USERPROFILE%\ShipGlows\shipglows`.
- User projects: `%USERPROFILE%\ShipGlows\<project>`.
- The clone is the source of truth for edits. The installed runtime is disposable output produced by the bootstrap.

## Why Test From A Branch

`install-shipglows.ps1` downloads a GitHub archive for the requested ref. It intentionally does not deploy uncommitted files from the current clone. A remotely pushed branch therefore tests the exact artifact another user would download without publishing unvalidated installer behavior to `main`.

Do not push an untested installer change directly to `main`. Use a branch whenever behavior affects installation, migration, PATH, wrappers, updates, dependencies, permissions, or user files.

## Deployment Truth

- `-DownloadOnly` refreshes and validates the staged Windows files under `%USERPROFILE%\.shipglows\cli\windows`. It does not run `cli/windows/install-devserver.ps1` and does not redeploy `%USERPROFILE%\.shipglows\bin`.
- The `s` wrapper executes `%USERPROFILE%\.shipglows\bin\shipglows-devserver.ps1`. That active file, not the downloaded staging copy, determines the user's behavior.
- A runtime-facing fix is installed only after the full bootstrap completes:

  ```powershell
  .\install-shipglows.ps1 -Branch <ref> -InstallMode full
  ```

- Use `-DownloadOnly` only to test download, archive extraction, or parsing. Never use it as proof that the active `s` command was updated.

## Agent Handoff

1. Start from an up-to-date `main` and create a focused branch.

   ```powershell
   cd "$env:USERPROFILE\ShipGlows\shipglows"
   git switch main
   git pull --ff-only
   git switch -c agent/<description>
   ```

2. Modify source files in the clone. Never patch `%USERPROFILE%\.shipglows` directly.

3. Run static validation before publishing the branch.

   ```powershell
   & 'C:\Program Files\Git\bin\bash.exe' tests/windows/devserver-contract.sh
   git diff --check
   ```

   Parse every changed PowerShell file with `System.Management.Automation.Language.Parser` as required by the repository contract.

4. Commit only intended files and push the branch.

   ```powershell
   git push -u origin agent/<description>
   ```

5. Test the downloadable branch artifact with the real bootstrap.

   ```powershell
   .\install-shipglows.ps1 -Branch agent/<description> -InstallMode full
   ```

6. Verify behavior proportionally to risk. For path or migration changes, verify at minimum:

   - commands such as `s` resolve to `%USERPROFILE%\.shipglows\bin` in a fresh shell;
   - `%USERPROFILE%\.shipglows\bin\s.cmd` targets the adjacent `shipglows-devserver.ps1`;
   - the active `%USERPROFILE%\.shipglows\bin\shipglows-devserver.ps1` matches the tested source after normalizing line endings;
   - `%USERPROFILE%\.shipglows` retains the Windows `Hidden` attribute;
   - `%USERPROFILE%\ShipGlows` contains projects only;
   - rerunning the installer is idempotent;
   - unrelated user configuration and project files remain unchanged.

7. Open a PR, record the real bootstrap evidence, wait for required checks, and merge only after the branch installation succeeds.

8. Reinstall from `main` after the merge so the local runtime no longer tracks a test ref.

   ```powershell
   git switch main
   git pull --ff-only
   .\install-shipglows.ps1 -Branch main -InstallMode full
   ```

9. Confirm all three deployment layers: the clone is at merged `main`, the staged copy under `%USERPROFILE%\.shipglows\cli\windows` contains the merged change, and the active copy under `%USERPROFILE%\.shipglows\bin` matches it after normalizing line endings. Confirm `s.cmd` launches that active copy, then report the PR, commit, validations, migration effects, and any recoverable backups.

## Pressure Scenario: `DOWNLOAD-ONLY-NOT-ACTIVE`

Given an older active DevServer and a newer branch archive, running the bootstrap with `-DownloadOnly` may succeed while `s` still runs the older file. The workflow must reject completion until a full install succeeds and normalized source, staged, and active contents agree. The core contract test mechanically preserves this distinction.

## Safety Boundaries

- Never delete or move `%USERPROFILE%\ShipGlows` recursively: it is the user-project root.
- Resolve and validate every migration target before deletion.
- A migration may remove only explicitly owned runtime paths.
- Preserve unrelated dirty worktree files and case-collision artifacts.
- Stop before merge if the branch bootstrap cannot be tested from the remote archive.
- A successful static test is not a substitute for a real Windows bootstrap when installer behavior changes.
- Never claim a runtime fix is installed from `-DownloadOnly`, the staged file, or a successful download alone.
