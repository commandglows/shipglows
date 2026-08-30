Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:SgBuildArtifactSchema = 'shipglows-build-artifact/v1'
$script:SgShortcutPrefix = 'ShipGlows managed build shortcut v1'

function Get-SgDefaultBuildArtifactRoot {
    $localData = [Environment]::GetFolderPath('LocalApplicationData')
    if ([string]::IsNullOrWhiteSpace($localData)) { throw 'Windows LocalApplicationData is unavailable.' }
    return Join-Path $localData 'ShipGlows\BuildArtifacts'
}

function Get-SgDefaultDesktopPath {
    $desktop = [Environment]::GetFolderPath('DesktopDirectory')
    if ([string]::IsNullOrWhiteSpace($desktop)) { throw 'The Windows desktop directory is unavailable.' }
    return $desktop
}

function Get-SgTextSha256([string]$Value) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($Value)
    $hash = [Security.Cryptography.SHA256]::HashData($bytes)
    return ([Convert]::ToHexString($hash)).ToLowerInvariant()
}

function Get-SgSafeBuildDisplayName([string]$ProjectName) {
    $name = ($ProjectName -replace '[<>:"/\\|?*\x00-\x1F]', '_').Trim().TrimEnd('.')
    $name = ($name -replace '\s+', ' ')
    if ([string]::IsNullOrWhiteSpace($name)) { throw 'ProjectName must contain at least one valid filename character.' }
    if ($name.Length -gt 80) { $name = $name.Substring(0, 80).TrimEnd() }
    return $name
}

function Resolve-SgBuildProjectIdentity {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath,
        [string]$ProjectName = ''
    )

    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) { throw "Project path does not exist: $ProjectPath" }
    $resolvedProject = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $ProjectPath).Path).TrimEnd('\')
    $displayName = Get-SgSafeBuildDisplayName $(if ($ProjectName) { $ProjectName } else { Split-Path -Leaf $resolvedProject })
    $identitySource = "path|$($resolvedProject.ToLowerInvariant())"
    $git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($git) {
        $gitRoot = (& $git.Source -C $resolvedProject rev-parse --show-toplevel 2>$null | Out-String).Trim()
        $rootExit = $LASTEXITCODE
        if ($rootExit -eq 0 -and $gitRoot) {
            $gitRoot = [IO.Path]::GetFullPath($gitRoot).TrimEnd('\')
            $relativeProject = [IO.Path]::GetRelativePath($gitRoot, $resolvedProject).Replace('\','/')
            $origin = (& $git.Source -C $gitRoot remote get-url origin 2>$null | Out-String).Trim()
            if ($LASTEXITCODE -eq 0 -and $origin) {
                $normalizedOrigin = ($origin.Trim().TrimEnd('/') -replace '\.git$', '').ToLowerInvariant()
                $identitySource = "git|$normalizedOrigin|$($relativeProject.ToLowerInvariant())"
            }
        }
    }
    return [pscustomobject]@{
        id = (Get-SgTextSha256 $identitySource).Substring(0, 16)
        displayName = $displayName
        path = $resolvedProject
    }
}

function Assert-SgBuildPathInside([string]$Candidate, [string]$Root, [string]$Label) {
    $fullRoot = [IO.Path]::GetFullPath($Root).TrimEnd('\')
    $fullCandidate = [IO.Path]::GetFullPath($Candidate)
    if (-not ($fullCandidate.Equals($fullRoot, [StringComparison]::OrdinalIgnoreCase) -or
        $fullCandidate.StartsWith($fullRoot + '\', [StringComparison]::OrdinalIgnoreCase))) {
        throw "$Label escapes its allowed root: $fullCandidate"
    }
    return $fullCandidate
}

function Get-SgBuildPackageStats {
    param(
        [Parameter(Mandatory=$true)][string]$PackageRoot,
        [long]$MaxBytes,
        [int]$MaxFiles
    )

    $rootItem = Get-Item -LiteralPath $PackageRoot -Force
    if (($rootItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Build package contains a reparse point: $($rootItem.FullName)" }
    $files = New-Object System.Collections.Generic.List[object]
    foreach ($item in Get-ChildItem -LiteralPath $PackageRoot -Force -Recurse) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Build package contains a reparse point: $($item.FullName)" }
        if (-not $item.PSIsContainer) { [void]$files.Add($item) }
    }
    if ($files.Count -gt $MaxFiles) { throw "Build package exceeds the file-count limit of $MaxFiles." }
    [long]$bytes = 0
    foreach ($file in $files) {
        $bytes += [long]$file.Length
        if ($bytes -gt $MaxBytes) { throw "Build package exceeds the size limit of $MaxBytes bytes." }
    }
    return [pscustomobject]@{ files = $files.Count; bytes = $bytes }
}

function Write-SgBuildAtomicText([string]$Path, [string]$Text) {
    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $temporary = Join-Path $directory ('.' + [IO.Path]::GetFileName($Path) + '.' + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [IO.File]::WriteAllText($temporary, $Text, [Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $temporary -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
    }
}

function Get-SgBuildLane([string]$Platform, [string]$SourceKind) {
    $platformKey = $Platform.Trim().ToLowerInvariant()
    $sourceKey = $SourceKind.Trim().ToLowerInvariant()
    if ($platformKey -notin @('windows','android')) {
        throw "Platform '$Platform' is not runnable from Windows; supported shortcut platforms are windows and android."
    }
    if ($sourceKey -notin @('local','ci')) { throw "SourceKind must be local or ci: $SourceKind" }
    $platformLabel = if ($platformKey -eq 'windows') { 'Windows' } else { 'Android APK' }
    $sourceLabel = if ($sourceKey -eq 'local') { 'Local' } else { 'CI' }
    return [pscustomobject]@{
        platform = $platformKey
        sourceKind = $sourceKey
        key = "$platformKey-$sourceKey"
        platformLabel = $platformLabel
        sourceLabel = $sourceLabel
    }
}

function Get-SgBuildShortcutMarker([string]$ProjectId, [string]$LaneKey) {
    return "$script:SgShortcutPrefix|$ProjectId|$LaneKey"
}

function ConvertTo-SgBuildProvenance([hashtable]$Provenance) {
    $allowed = @('repository','workflow','branch','artifactName','runId','event','createdAt')
    if ($Provenance.Count -gt $allowed.Count) { throw 'Provenance contains too many fields.' }
    $result = [ordered]@{}
    foreach ($key in @($Provenance.Keys | Sort-Object)) {
        if ($key -notin $allowed) { throw "Provenance field is not allowed: $key" }
        $value = [string]$Provenance[$key]
        if ($value.Length -gt 512 -or $value -match '[\x00-\x1F]') { throw "Provenance value is invalid or exceeds 512 characters: $key" }
        $result[$key] = $value
    }
    return $result
}

function Assert-SgManagedShortcutCollision([string]$ShortcutPath, [string]$ExpectedMarker) {
    if (-not (Test-Path -LiteralPath $ShortcutPath)) { return }
    try {
        $shell = New-Object -ComObject WScript.Shell
        $existing = $shell.CreateShortcut($ShortcutPath)
        if ($existing.Description -ne $ExpectedMarker) { throw 'marker mismatch' }
    } catch {
        throw "Existing shortcut is not owned by ShipGlows and will not be overwritten: $ShortcutPath"
    }
}

function New-SgBuildShortcutFile {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Marker,
        [Parameter(Mandatory=$true)][string]$Platform,
        [Parameter(Mandatory=$true)][string]$EntryPath
    )

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($Path)
    if ($Platform -eq 'windows') {
        $shortcut.TargetPath = $EntryPath
        $shortcut.WorkingDirectory = Split-Path -Parent $EntryPath
        $shortcut.IconLocation = "$EntryPath,0"
    } else {
        $explorer = Join-Path $env:WINDIR 'explorer.exe'
        if (-not (Test-Path -LiteralPath $explorer -PathType Leaf)) { throw 'Windows Explorer is unavailable.' }
        $shortcut.TargetPath = $explorer
        $shortcut.Arguments = "/select,`"$EntryPath`""
        $shortcut.WorkingDirectory = Split-Path -Parent $EntryPath
    }
    $shortcut.Description = $Marker
    $shortcut.Save()
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Windows did not create the shortcut: $Path" }
}

function Remove-SgOldBuildGenerations([string]$GenerationsRoot, [string[]]$KeepPaths, [int]$KeepCount = 2) {
    if (-not (Test-Path -LiteralPath $GenerationsRoot -PathType Container)) { return }
    $kept = 0
    foreach ($directory in Get-ChildItem -LiteralPath $GenerationsRoot -Directory -Force | Sort-Object Name -Descending) {
        $full = Assert-SgBuildPathInside -Candidate $directory.FullName -Root $GenerationsRoot -Label 'Generation cleanup target'
        if ($KeepPaths -contains $full -or $kept -lt $KeepCount) {
            $kept++
            continue
        }
        Remove-Item -LiteralPath $full -Recurse -Force
    }
}

function Publish-SgBuildArtifact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath,
        [string]$ProjectName = '',
        [Parameter(Mandatory=$true)][string]$Platform,
        [Parameter(Mandatory=$true)][string]$SourceKind,
        [Parameter(Mandatory=$true)][string]$ArtifactPath,
        [Parameter(Mandatory=$true)][string]$PackageRoot,
        [string]$SourceId = '',
        [string]$Commit = '',
        [hashtable]$Provenance = @{},
        [string]$StateRoot = '',
        [string]$DesktopPath = '',
        [long]$MaxBytes = 2147483648,
        [int]$MaxFiles = 50000
    )

    $lane = Get-SgBuildLane -Platform $Platform -SourceKind $SourceKind
    $identity = Resolve-SgBuildProjectIdentity -ProjectPath $ProjectPath -ProjectName $ProjectName
    if ($SourceId -and $SourceId -notmatch '^[A-Za-z0-9._:-]{1,160}$') { throw 'SourceId contains unsupported characters or exceeds 160 characters.' }
    if ($Commit -and $Commit -notmatch '^[0-9A-Fa-f]{7,64}$') { throw 'Commit must be a hexadecimal Git object identifier.' }
    $stateProvenance = ConvertTo-SgBuildProvenance -Provenance $Provenance
    if (-not $StateRoot) { $StateRoot = Get-SgDefaultBuildArtifactRoot }
    if (-not $DesktopPath) { $DesktopPath = Get-SgDefaultDesktopPath }
    $StateRoot = [IO.Path]::GetFullPath($StateRoot).TrimEnd('\')
    $DesktopPath = [IO.Path]::GetFullPath($DesktopPath).TrimEnd('\')
    New-Item -ItemType Directory -Path $StateRoot,$DesktopPath -Force | Out-Null

    if (-not (Test-Path -LiteralPath $PackageRoot -PathType Container)) { throw "Build package root does not exist: $PackageRoot" }
    if (-not (Test-Path -LiteralPath $ArtifactPath -PathType Leaf)) { throw "Build artifact does not exist: $ArtifactPath" }
    $package = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $PackageRoot).Path).TrimEnd('\')
    $artifact = Assert-SgBuildPathInside -Candidate (Resolve-Path -LiteralPath $ArtifactPath).Path -Root $package -Label 'Build artifact'
    $expectedExtension = if ($lane.platform -eq 'windows') { '.exe' } else { '.apk' }
    if ([IO.Path]::GetExtension($artifact) -ine $expectedExtension) { throw "The $($lane.platform) artifact must use $expectedExtension`: $artifact" }
    [void](Get-SgBuildPackageStats -PackageRoot $package -MaxBytes $MaxBytes -MaxFiles $MaxFiles)

    $projectRoot = Join-Path (Join-Path $StateRoot 'projects') $identity.id
    $laneRoot = Join-Path $projectRoot $lane.key
    $generationsRoot = Join-Path $laneRoot 'generations'
    $statePath = Join-Path $laneRoot 'state.json'
    New-Item -ItemType Directory -Path $generationsRoot -Force | Out-Null
    $shortcutPath = Join-Path $DesktopPath "ShipGlows - $($identity.displayName) - $($lane.platformLabel) - $($lane.sourceLabel).lnk"
    $marker = Get-SgBuildShortcutMarker -ProjectId $identity.id -LaneKey $lane.key
    Assert-SgManagedShortcutCollision -ShortcutPath $shortcutPath -ExpectedMarker $marker

    $staging = Join-Path $laneRoot ('.staging-' + [guid]::NewGuid().ToString('N'))
    $shortcutTemporary = Join-Path $DesktopPath ('.shipglows-shortcut-' + [guid]::NewGuid().ToString('N') + '.lnk')
    $shortcutBackup = Join-Path $DesktopPath ('.shipglows-shortcut-backup-' + [guid]::NewGuid().ToString('N') + '.lnk')
    $previousState = if (Test-Path -LiteralPath $statePath -PathType Leaf) { [IO.File]::ReadAllText($statePath) } else { $null }
    $previousGeneration = $null
    if ($previousState) {
        try { $previousGeneration = ([IO.File]::ReadAllText($statePath) | ConvertFrom-Json).generationPath } catch { throw "Existing ShipGlows build state is invalid: $statePath" }
    }

    try {
        New-Item -ItemType Directory -Path $staging -Force | Out-Null
        if ($lane.platform -eq 'windows') {
            foreach ($item in Get-ChildItem -LiteralPath $package -Force) {
                Copy-Item -LiteralPath $item.FullName -Destination $staging -Recurse -Force
            }
            $entryRelative = [IO.Path]::GetRelativePath($package, $artifact)
        } else {
            Copy-Item -LiteralPath $artifact -Destination (Join-Path $staging ([IO.Path]::GetFileName($artifact)))
            $entryRelative = [IO.Path]::GetFileName($artifact)
        }
        [void](Get-SgBuildPackageStats -PackageRoot $staging -MaxBytes $MaxBytes -MaxFiles $MaxFiles)
        $stagedEntry = Assert-SgBuildPathInside -Candidate (Join-Path $staging $entryRelative) -Root $staging -Label 'Cached entrypoint'
        if (-not (Test-Path -LiteralPath $stagedEntry -PathType Leaf)) { throw "Cached entrypoint is missing: $entryRelative" }
        $entryHash = (Get-FileHash -LiteralPath $stagedEntry -Algorithm SHA256).Hash.ToLowerInvariant()
        $generationName = [DateTimeOffset]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '-' + $entryHash.Substring(0, 12)
        $generationPath = Join-Path $generationsRoot $generationName
        if (Test-Path -LiteralPath $generationPath) { $generationPath += '-' + [guid]::NewGuid().ToString('N').Substring(0, 8) }
        Move-Item -LiteralPath $staging -Destination $generationPath
        $entryPath = Assert-SgBuildPathInside -Candidate (Join-Path $generationPath $entryRelative) -Root $generationPath -Label 'Published entrypoint'

        $state = [ordered]@{
            schema = $script:SgBuildArtifactSchema
            projectId = $identity.id
            projectName = $identity.displayName
            platform = $lane.platform
            sourceKind = $lane.sourceKind
            sourceId = $SourceId
            commit = $Commit
            publishedAt = [DateTimeOffset]::UtcNow.ToString('o')
            generationPath = $generationPath
            entryPath = $entryPath
            entryRelativePath = $entryRelative
            entrySha256 = $entryHash
            shortcutPath = $shortcutPath
            provenance = $stateProvenance
        }

        New-SgBuildShortcutFile -Path $shortcutTemporary -Marker $marker -Platform $lane.platform -EntryPath $entryPath
        if (Test-Path -LiteralPath $shortcutPath -PathType Leaf) { Copy-Item -LiteralPath $shortcutPath -Destination $shortcutBackup }
        Move-Item -LiteralPath $shortcutTemporary -Destination $shortcutPath -Force
        Write-SgBuildAtomicText -Path $statePath -Text ($state | ConvertTo-Json -Depth 8)
        if (Test-Path -LiteralPath $shortcutBackup) { Remove-Item -LiteralPath $shortcutBackup -Force }
        Remove-SgOldBuildGenerations -GenerationsRoot $generationsRoot -KeepPaths @($generationPath,$previousGeneration) -KeepCount 2
        return [pscustomobject]$state
    } catch {
        if (Test-Path -LiteralPath $shortcutBackup -PathType Leaf) {
            Move-Item -LiteralPath $shortcutBackup -Destination $shortcutPath -Force
        } elseif ((Test-Path -LiteralPath $shortcutPath -PathType Leaf) -and -not $previousState) {
            Remove-Item -LiteralPath $shortcutPath -Force
        }
        if ($previousState) {
            Write-SgBuildAtomicText -Path $statePath -Text $previousState
        } elseif (Test-Path -LiteralPath $statePath) {
            Remove-Item -LiteralPath $statePath -Force
        }
        throw
    } finally {
        foreach ($temporaryPath in @($staging,$shortcutTemporary,$shortcutBackup)) {
            if (Test-Path -LiteralPath $temporaryPath) { Remove-Item -LiteralPath $temporaryPath -Recurse -Force }
        }
    }
}

function Invoke-SgDefaultGitHubRunner {
    param([Parameter(Mandatory=$true)][string[]]$Arguments)
    $gh = Get-Command gh.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $gh) { throw 'GitHub CLI is required to synchronize CI build artifacts.' }
    $output = (& $gh.Source @Arguments 2>&1 | Out-String).Trim()
    return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
}

function Assert-SgGitHubField([string]$Value, [string]$Label) {
    if ([string]::IsNullOrWhiteSpace($Value) -or $Value.Length -gt 512 -or $Value.StartsWith('-') -or $Value -match '[\x00-\x1F]') {
        throw "$Label is empty, option-shaped, contains control characters, or exceeds 512 characters."
    }
}

function Sync-SgGitHubBuildArtifact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath,
        [string]$ProjectName = '',
        [Parameter(Mandatory=$true)][string]$Platform,
        [Parameter(Mandatory=$true)][string]$Repository,
        [Parameter(Mandatory=$true)][string]$Workflow,
        [Parameter(Mandatory=$true)][string]$Branch,
        [Parameter(Mandatory=$true)][string]$ArtifactName,
        [string]$EntryRelativePath = '',
        [string[]]$AllowedEvents = @('push','workflow_dispatch','release'),
        [string]$StateRoot = '',
        [string]$DesktopPath = '',
        [long]$MaxBytes = 2147483648,
        [int]$MaxFiles = 50000,
        [scriptblock]$GitHubRunner = ${function:Invoke-SgDefaultGitHubRunner}
    )

    $lane = Get-SgBuildLane -Platform $Platform -SourceKind ci
    foreach ($field in @(@($Repository,'Repository'),@($Workflow,'Workflow'),@($Branch,'Branch'),@($ArtifactName,'ArtifactName'))) {
        Assert-SgGitHubField -Value $field[0] -Label $field[1]
    }
    if ($Repository -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw "Repository must use owner/name form: $Repository" }
    if (-not $StateRoot) { $StateRoot = Get-SgDefaultBuildArtifactRoot }
    $downloadRoot = Join-Path ([IO.Path]::GetFullPath($StateRoot)) ('downloads\' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $downloadRoot -Force | Out-Null
    try {
        $listArguments = @('run','list','--repo',$Repository,'--workflow',$Workflow,'--branch',$Branch,'--status','success','--limit','20','--json','databaseId,headSha,headBranch,conclusion,createdAt,event,name')
        $listResult = & $GitHubRunner -Arguments $listArguments
        if (-not $listResult -or [int]$listResult.ExitCode -ne 0) { throw "GitHub run lookup failed: $($listResult.Output)" }
        try { $runs = @(([string]$listResult.Output | ConvertFrom-Json)) }
        catch { throw 'GitHub run lookup returned invalid JSON.' }
        $run = $runs | Where-Object {
            $_.conclusion -eq 'success' -and $_.headBranch -eq $Branch -and $_.event -in $AllowedEvents
        } | Select-Object -First 1
        if (-not $run) { throw 'No allowed successful CI run was found for the requested workflow and branch.' }
        $runId = [string]$run.databaseId
        if ($runId -notmatch '^\d+$') { throw 'GitHub returned an invalid workflow run identifier.' }

        $downloadArguments = @('run','download',$runId,'--repo',$Repository,'--name',$ArtifactName,'--dir',$downloadRoot)
        $downloadResult = & $GitHubRunner -Arguments $downloadArguments
        if (-not $downloadResult -or [int]$downloadResult.ExitCode -ne 0) { throw "GitHub artifact download failed: $($downloadResult.Output)" }
        [void](Get-SgBuildPackageStats -PackageRoot $downloadRoot -MaxBytes $MaxBytes -MaxFiles $MaxFiles)

        if ($EntryRelativePath) {
            $entryPath = Assert-SgBuildPathInside -Candidate (Join-Path $downloadRoot $EntryRelativePath) -Root $downloadRoot -Label 'CI entrypoint'
            if (-not (Test-Path -LiteralPath $entryPath -PathType Leaf)) { throw "CI entrypoint does not exist: $EntryRelativePath" }
        } else {
            $extension = if ($lane.platform -eq 'windows') { '*.exe' } else { '*.apk' }
            $candidates = @(Get-ChildItem -LiteralPath $downloadRoot -File -Recurse -Filter $extension)
            if ($candidates.Count -ne 1) { throw "CI artifact must contain exactly one $extension entrypoint when EntryRelativePath is omitted; found $($candidates.Count)." }
            $entryPath = $candidates[0].FullName
        }

        $provenance = @{
            repository = $Repository
            workflow = $Workflow
            branch = $Branch
            artifactName = $ArtifactName
            runId = $runId
            event = [string]$run.event
            createdAt = [string]$run.createdAt
        }
        return Publish-SgBuildArtifact `
            -ProjectPath $ProjectPath -ProjectName $ProjectName -Platform $lane.platform -SourceKind ci `
            -ArtifactPath $entryPath -PackageRoot $downloadRoot -SourceId "github-run-$runId" `
            -Commit ([string]$run.headSha) -Provenance $provenance -StateRoot $StateRoot `
            -DesktopPath $DesktopPath -MaxBytes $MaxBytes -MaxFiles $MaxFiles
    } finally {
        $downloadsRoot = Split-Path -Parent $downloadRoot
        [void](Assert-SgBuildPathInside -Candidate $downloadRoot -Root $downloadsRoot -Label 'CI download cleanup target')
        if (Test-Path -LiteralPath $downloadRoot) { Remove-Item -LiteralPath $downloadRoot -Recurse -Force }
    }
}

function Get-SgBuildArtifactStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath,
        [string]$ProjectName = '',
        [string]$StateRoot = ''
    )
    $identity = Resolve-SgBuildProjectIdentity -ProjectPath $ProjectPath -ProjectName $ProjectName
    if (-not $StateRoot) { $StateRoot = Get-SgDefaultBuildArtifactRoot }
    $projectRoot = Join-Path (Join-Path ([IO.Path]::GetFullPath($StateRoot)) 'projects') $identity.id
    $results = New-Object System.Collections.Generic.List[object]
    foreach ($platform in @('windows','android')) {
        foreach ($source in @('local','ci')) {
            $lane = Get-SgBuildLane -Platform $platform -SourceKind $source
            $statePath = Join-Path (Join-Path $projectRoot $lane.key) 'state.json'
            if (Test-Path -LiteralPath $statePath -PathType Leaf) {
                try {
                    $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json
                    if ($state.schema -ne $script:SgBuildArtifactSchema -or $state.projectId -ne $identity.id -or
                        $state.platform -ne $platform -or $state.sourceKind -ne $source) {
                        throw 'state contract mismatch'
                    }
                    [void]$results.Add($state)
                }
                catch { throw "Invalid ShipGlows build state: $statePath" }
            } else {
                [void]$results.Add([pscustomobject]@{ schema=$script:SgBuildArtifactSchema; projectId=$identity.id; projectName=$identity.displayName; platform=$platform; sourceKind=$source; status='missing' })
            }
        }
    }
    return $results | ForEach-Object { $_ }
}

Export-ModuleMember -Function Publish-SgBuildArtifact, Sync-SgGitHubBuildArtifact, Get-SgBuildArtifactStatus
