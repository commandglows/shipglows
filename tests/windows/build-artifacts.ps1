$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Read-SgShortcut([string]$Path) {
    $shell = New-Object -ComObject WScript.Shell
    return $shell.CreateShortcut($Path)
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $repoRoot 'cli\windows\ShipGlows.BuildArtifacts.psm1'
$entrypointPath = Join-Path $repoRoot 'cli\windows\shipglows-build-artifacts.ps1'
$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-build-artifacts-' + [guid]::NewGuid().ToString('N'))
$desktop = Join-Path $fixtureRoot 'Desktop with spaces'
$stateRoot = Join-Path $fixtureRoot 'Local App Data\ShipGlows\BuildArtifacts'
$project = Join-Path $fixtureRoot 'Content Glows Project'

try {
    New-Item -ItemType Directory -Path $desktop,$project -Force | Out-Null
    Assert-Sg (Test-Path -LiteralPath $modulePath -PathType Leaf) 'The build-artifact module is missing.'
    Assert-Sg (Test-Path -LiteralPath $entrypointPath -PathType Leaf) 'The build-artifact command entrypoint is missing.'
    Import-Module $modulePath -Force -DisableNameChecking

    $windowsSource = Join-Path $fixtureRoot 'source windows\Release'
    New-Item -ItemType Directory -Path (Join-Path $windowsSource 'data') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $windowsSource 'app.exe'), 'windows-v1', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $windowsSource 'data\app.so'), 'sibling', [Text.UTF8Encoding]::new($false))
    $localWindows = Publish-SgBuildArtifact `
        -ProjectPath $project -ProjectName 'ContentGlows' -Platform windows -SourceKind local `
        -ArtifactPath (Join-Path $windowsSource 'app.exe') -PackageRoot $windowsSource `
        -SourceId 'local-v1' -Commit 'abc1234' -StateRoot $stateRoot -DesktopPath $desktop

    $windowsLocalShortcut = Join-Path $desktop 'ShipGlows - ContentGlows - Windows - Local.lnk'
    Assert-Sg (Test-Path -LiteralPath $windowsLocalShortcut -PathType Leaf) 'The Windows Local shortcut was not created.'
    $windowsLink = Read-SgShortcut $windowsLocalShortcut
    Assert-Sg ($windowsLink.TargetPath -eq $localWindows.entryPath) 'The Windows shortcut does not target the cached executable.'
    Assert-Sg ($windowsLink.Description -match '^ShipGlows managed build shortcut v1\|') 'The shortcut ownership marker is missing.'
    Assert-Sg (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $localWindows.entryPath) 'data\app.so')) 'The complete Windows package was not cached.'
    Remove-Item -LiteralPath (Split-Path -Parent $windowsSource) -Recurse -Force
    Assert-Sg (Test-Path -LiteralPath $localWindows.entryPath -PathType Leaf) 'The cached build did not survive source worktree removal.'

    $failedPreviousTarget = $windowsLink.TargetPath
    $missingRejected = $false
    try {
        Publish-SgBuildArtifact `
            -ProjectPath $project -ProjectName 'ContentGlows' -Platform windows -SourceKind local `
            -ArtifactPath (Join-Path $fixtureRoot 'missing\app.exe') -PackageRoot (Join-Path $fixtureRoot 'missing') `
            -StateRoot $stateRoot -DesktopPath $desktop | Out-Null
    } catch { $missingRejected = $_.Exception.Message -match 'does not exist' }
    Assert-Sg $missingRejected 'A missing local build must fail closed.'
    Assert-Sg ((Read-SgShortcut $windowsLocalShortcut).TargetPath -eq $failedPreviousTarget) 'A failed publish replaced the last-known-good shortcut.'

    $apkSource = Join-Path $fixtureRoot 'source android\content glows release.apk'
    New-Item -ItemType Directory -Path (Split-Path -Parent $apkSource) -Force | Out-Null
    [IO.File]::WriteAllText($apkSource, 'android-v1', [Text.UTF8Encoding]::new($false))
    $localAndroid = Publish-SgBuildArtifact `
        -ProjectPath $project -ProjectName 'ContentGlows' -Platform android -SourceKind local `
        -ArtifactPath $apkSource -PackageRoot (Split-Path -Parent $apkSource) `
        -SourceId 'local-apk-v1' -StateRoot $stateRoot -DesktopPath $desktop
    $androidLocalShortcut = Join-Path $desktop 'ShipGlows - ContentGlows - Android APK - Local.lnk'
    $androidLink = Read-SgShortcut $androidLocalShortcut
    Assert-Sg ($androidLink.TargetPath -match '(?i)explorer\.exe$') 'The Android shortcut must use Explorer instead of installing the APK.'
    Assert-Sg ($androidLink.Arguments.Contains($localAndroid.entryPath)) 'The Android shortcut does not reveal the cached APK.'

    $oversizeSource = Join-Path $fixtureRoot 'oversize\app.exe'
    New-Item -ItemType Directory -Path (Split-Path -Parent $oversizeSource) -Force | Out-Null
    [IO.File]::WriteAllText($oversizeSource, 'too-large', [Text.UTF8Encoding]::new($false))
    $oversizeRejected = $false
    try {
        Publish-SgBuildArtifact `
            -ProjectPath $project -ProjectName 'Oversize' -Platform windows -SourceKind local `
            -ArtifactPath $oversizeSource -PackageRoot (Split-Path -Parent $oversizeSource) `
            -StateRoot $stateRoot -DesktopPath $desktop -MaxBytes 2 | Out-Null
    } catch { $oversizeRejected = $_.Exception.Message -match 'size limit' }
    Assert-Sg $oversizeRejected 'An oversized package must be rejected before shortcut publication.'

    $collisionSource = Join-Path $fixtureRoot 'collision\app.exe'
    New-Item -ItemType Directory -Path (Split-Path -Parent $collisionSource) -Force | Out-Null
    [IO.File]::WriteAllText($collisionSource, 'collision', [Text.UTF8Encoding]::new($false))
    $collisionShortcut = Join-Path $desktop 'ShipGlows - Collision - Windows - Local.lnk'
    [IO.File]::WriteAllText($collisionShortcut, 'not-a-shipglows-shortcut', [Text.UTF8Encoding]::new($false))
    $collisionRejected = $false
    try {
        Publish-SgBuildArtifact `
            -ProjectPath $project -ProjectName 'Collision' -Platform windows -SourceKind local `
            -ArtifactPath $collisionSource -PackageRoot (Split-Path -Parent $collisionSource) `
            -StateRoot $stateRoot -DesktopPath $desktop | Out-Null
    } catch { $collisionRejected = $_.Exception.Message -match 'not owned by ShipGlows' }
    Assert-Sg $collisionRejected 'An unowned same-name shortcut must never be overwritten.'
    Assert-Sg ([IO.File]::ReadAllText($collisionShortcut) -eq 'not-a-shipglows-shortcut') 'The unowned collision was modified.'

    $fakeGitHub = {
        param([string[]]$Arguments)
        if ($Arguments[0] -eq 'run' -and $Arguments[1] -eq 'list') {
            return [pscustomobject]@{
                ExitCode = 0
                Output = '[{"databaseId":4242,"headSha":"def4567","headBranch":"auth0-migration","conclusion":"success","createdAt":"2026-08-26T12:00:00Z","event":"push","name":"Windows Release"}]'
            }
        }
        if ($Arguments[0] -eq 'run' -and $Arguments[1] -eq 'download') {
            $downloadDirectory = $Arguments[[array]::IndexOf($Arguments, '--dir') + 1]
            New-Item -ItemType Directory -Path (Join-Path $downloadDirectory 'bundle\data') -Force | Out-Null
            [IO.File]::WriteAllText((Join-Path $downloadDirectory 'bundle\app.exe'), 'windows-ci', [Text.UTF8Encoding]::new($false))
            [IO.File]::WriteAllText((Join-Path $downloadDirectory 'bundle\data\app.so'), 'ci-sibling', [Text.UTF8Encoding]::new($false))
            return [pscustomobject]@{ ExitCode = 0; Output = '' }
        }
        return [pscustomobject]@{ ExitCode = 2; Output = 'unexpected gh arguments' }
    }
    $ciWindows = Sync-SgGitHubBuildArtifact `
        -ProjectPath $project -ProjectName 'ContentGlows' -Platform windows `
        -Repository 'commandglows/contentglows' -Workflow 'windows-release.yml' -Branch 'auth0-migration' `
        -ArtifactName 'windows-release' -EntryRelativePath 'bundle\app.exe' `
        -StateRoot $stateRoot -DesktopPath $desktop -GitHubRunner $fakeGitHub
    $windowsCiShortcut = Join-Path $desktop 'ShipGlows - ContentGlows - Windows - CI.lnk'
    Assert-Sg (Test-Path -LiteralPath $windowsCiShortcut -PathType Leaf) 'The Windows CI shortcut was not created.'
    Assert-Sg ((Read-SgShortcut $windowsCiShortcut).TargetPath -eq $ciWindows.entryPath) 'The CI shortcut does not target its cached CI executable.'
    Assert-Sg ((Read-SgShortcut $windowsLocalShortcut).TargetPath -eq $failedPreviousTarget) 'Publishing CI replaced the Local lane.'
    Assert-Sg ($ciWindows.provenance.runId -eq '4242' -and $ciWindows.provenance.event -eq 'push') 'CI provenance is incomplete.'
    Assert-Sg (($ciWindows | ConvertTo-Json -Depth 8) -notmatch '(?i)(token|secret|password|credential)') 'CI state contains a forbidden secret-bearing field.'

    $escapeRejected = $false
    try {
        Sync-SgGitHubBuildArtifact `
            -ProjectPath $project -ProjectName 'Escape' -Platform windows `
            -Repository 'commandglows/contentglows' -Workflow 'windows-release.yml' -Branch 'auth0-migration' `
            -ArtifactName 'windows-release' -EntryRelativePath '..\escape.exe' `
            -StateRoot $stateRoot -DesktopPath $desktop -GitHubRunner $fakeGitHub | Out-Null
    } catch { $escapeRejected = $_.Exception.Message -match 'escapes its allowed root' }
    Assert-Sg $escapeRejected 'A CI entrypoint path escape must fail closed.'

    $ambiguousGitHub = {
        param([string[]]$Arguments)
        if ($Arguments[0] -eq 'run' -and $Arguments[1] -eq 'list') {
            return [pscustomobject]@{ ExitCode=0; Output='[{"databaseId":4343,"headSha":"abcdef1","headBranch":"auth0-migration","conclusion":"success","createdAt":"2026-08-26T12:00:00Z","event":"push","name":"Windows Release"}]' }
        }
        $downloadDirectory = $Arguments[[array]::IndexOf($Arguments, '--dir') + 1]
        New-Item -ItemType Directory -Path $downloadDirectory -Force | Out-Null
        [IO.File]::WriteAllText((Join-Path $downloadDirectory 'first.exe'), 'first', [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText((Join-Path $downloadDirectory 'second.exe'), 'second', [Text.UTF8Encoding]::new($false))
        return [pscustomobject]@{ ExitCode=0; Output='' }
    }
    $ambiguousRejected = $false
    try {
        Sync-SgGitHubBuildArtifact `
            -ProjectPath $project -ProjectName 'Ambiguous' -Platform windows `
            -Repository 'commandglows/contentglows' -Workflow 'windows-release.yml' -Branch 'auth0-migration' `
            -ArtifactName 'windows-release' -StateRoot $stateRoot -DesktopPath $desktop `
            -GitHubRunner $ambiguousGitHub | Out-Null
    } catch { $ambiguousRejected = $_.Exception.Message -match 'exactly one' }
    Assert-Sg $ambiguousRejected 'Ambiguous CI entrypoints must fail closed.'

    $untrustedGitHub = {
        param([string[]]$Arguments)
        return [pscustomobject]@{
            ExitCode = 0
            Output = '[{"databaseId":9999,"headSha":"bad999","headBranch":"auth0-migration","conclusion":"success","createdAt":"2026-08-26T12:01:00Z","event":"pull_request","name":"Windows Release"}]'
        }
    }
    $untrustedRejected = $false
    try {
        Sync-SgGitHubBuildArtifact `
            -ProjectPath $project -ProjectName 'ContentGlows' -Platform windows `
            -Repository 'commandglows/contentglows' -Workflow 'windows-release.yml' -Branch 'auth0-migration' `
            -ArtifactName 'windows-release' -EntryRelativePath 'bundle\app.exe' `
            -StateRoot $stateRoot -DesktopPath $desktop -GitHubRunner $untrustedGitHub | Out-Null
    } catch { $untrustedRejected = $_.Exception.Message -match 'allowed successful CI run' }
    Assert-Sg $untrustedRejected 'A disallowed CI event must fail closed.'
    Assert-Sg ((Read-SgShortcut $windowsCiShortcut).TargetPath -eq $ciWindows.entryPath) 'An untrusted CI run replaced the last-known-good CI shortcut.'

    $unsupportedRejected = $false
    try {
        Publish-SgBuildArtifact `
            -ProjectPath $project -ProjectName 'ContentGlows' -Platform ios -SourceKind local `
            -ArtifactPath $apkSource -PackageRoot (Split-Path -Parent $apkSource) `
            -StateRoot $stateRoot -DesktopPath $desktop | Out-Null
    } catch { $unsupportedRejected = $_.Exception.Message -match 'not runnable from Windows' }
    Assert-Sg $unsupportedRejected 'Windows must not present iOS artifacts as runnable builds.'

    $retentionSource = Join-Path $fixtureRoot 'retention\app.exe'
    New-Item -ItemType Directory -Path (Split-Path -Parent $retentionSource) -Force | Out-Null
    foreach ($version in 1..3) {
        [IO.File]::WriteAllText($retentionSource, "retention-$version", [Text.UTF8Encoding]::new($false))
        Publish-SgBuildArtifact `
            -ProjectPath $project -ProjectName 'Retention' -Platform windows -SourceKind local `
            -ArtifactPath $retentionSource -PackageRoot (Split-Path -Parent $retentionSource) `
            -SourceId "retention-$version" -StateRoot $stateRoot -DesktopPath $desktop | Out-Null
        Start-Sleep -Milliseconds 2
    }
    $retentionState = Get-SgBuildArtifactStatus -ProjectPath $project -ProjectName 'Retention' -StateRoot $stateRoot |
        Where-Object { $_.platform -eq 'windows' -and $_.sourceKind -eq 'local' }
    $retentionGenerations = Get-ChildItem -LiteralPath (Split-Path -Parent $retentionState.generationPath) -Directory
    Assert-Sg ($retentionGenerations.Count -le 2) 'A lane retained more than two validated generations.'

    $reparseSource = Join-Path $fixtureRoot 'reparse-package'
    $reparseTarget = Join-Path $fixtureRoot 'reparse-target'
    New-Item -ItemType Directory -Path $reparseSource,$reparseTarget -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $reparseSource 'app.exe'), 'reparse', [Text.UTF8Encoding]::new($false))
    $junction = Join-Path $reparseSource 'linked-data'
    New-Item -ItemType Junction -Path $junction -Target $reparseTarget | Out-Null
    $reparseRejected = $false
    try {
        Publish-SgBuildArtifact `
            -ProjectPath $project -ProjectName 'Reparse' -Platform windows -SourceKind local `
            -ArtifactPath (Join-Path $reparseSource 'app.exe') -PackageRoot $reparseSource `
            -StateRoot $stateRoot -DesktopPath $desktop | Out-Null
    } catch { $reparseRejected = $_.Exception.Message -match 'reparse point' }
    Assert-Sg $reparseRejected 'A package containing a reparse point must fail closed.'

    $doctrinePath = Join-Path $repoRoot 'skills\references\latest-build-artifact-access.md'
    $runtimeAwarenessPath = Join-Path $repoRoot 'skills\references\agent-runtime-awareness.md'
    $doctrine = [IO.File]::ReadAllText($doctrinePath)
    $runtimeAwareness = [IO.File]::ReadAllText($runtimeAwarenessPath)
    foreach ($required in @('Windows - Local','Windows - CI','Android APK - Local','Android APK - CI','shipglows-build-artifacts.ps1')) {
        Assert-Sg ($doctrine.Contains($required) -or $runtimeAwareness.Contains($required)) "Build-access doctrine is missing: $required"
    }
    $rootInstaller = [IO.File]::ReadAllText((Join-Path $repoRoot 'install-shipglows.ps1'))
    $nativeInstaller = [IO.File]::ReadAllText((Join-Path $repoRoot 'cli\windows\install-devserver.ps1'))
    foreach ($requiredPayload in @('ShipGlows.BuildArtifacts.psm1','shipglows-build-artifacts.ps1')) {
        Assert-Sg ($rootInstaller.Contains($requiredPayload) -and $nativeInstaller.Contains($requiredPayload)) "Installer payload is missing $requiredPayload"
    }

    Write-Output 'Windows ShipGlows build-artifact tests passed.'
} finally {
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
}
