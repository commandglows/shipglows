Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SgEnabledShipGlowsPluginIds {
    param([Parameter(Mandatory=$true)][string]$TargetHome)

    $configPath = Join-Path $TargetHome '.codex\config.toml'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return @() }
    $currentPlugin = $null
    $enabled = New-Object System.Collections.Generic.List[string]
    foreach ($line in Get-Content -LiteralPath $configPath) {
        if ($line -match '^\s*\[(?<section>.+)\]\s*$') {
            $section = $Matches.section.Trim()
            $currentPlugin = if ($section -match '^plugins\.(["'']?)(?<id>shipglows@[^"'']+)\1$') { $Matches.id } else { $null }
            continue
        }
        if ($currentPlugin -and $line -match '^\s*enabled\s*=\s*true\s*(?:#.*)?$') {
            $enabled.Add([string]$currentPlugin)
            $currentPlugin = $null
        }
    }
    return @($enabled | Sort-Object -Unique)
}

function Resolve-SgGitCommand {
    $command = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }
    $fallback = Join-Path $env:ProgramFiles 'Git\cmd\git.exe'
    if (Test-Path -LiteralPath $fallback -PathType Leaf) { return $fallback }
    throw 'Git is required for the ShipGlows developer corpus but was not found.'
}

function ConvertTo-SgComparableRepositoryUrl([string]$RepositoryUrl) {
    return ($RepositoryUrl.Trim().TrimEnd('/') -replace '\.git$', '').ToLowerInvariant()
}

function Assert-SgDeveloperCheckout {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$RepositoryUrl,
        [Parameter(Mandatory=$true)][string]$GitPath
    )

    $expected = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    $actual = (& $GitPath -C $expected rev-parse --show-toplevel 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $actual) { throw "Developer target is not a Git checkout: $expected" }
    $actual = [IO.Path]::GetFullPath($actual).TrimEnd('\')
    if (-not $actual.Equals($expected, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Developer target belongs to a broader Git checkout: $actual"
    }
    $origin = (& $GitPath -C $actual remote get-url origin 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or
        (ConvertTo-SgComparableRepositoryUrl $origin) -cne (ConvertTo-SgComparableRepositoryUrl $RepositoryUrl)) {
        throw "Developer checkout origin does not match $RepositoryUrl`: $origin"
    }
    foreach ($relative in @(
        'skills\shipglows\SKILL.md',
        'skills\references\skill-invocation-registry.json',
        'skills\references\canonical-paths.md',
        'tools\shipglows_sync_skills.ps1',
        'plugins\shipglows\.codex-plugin\plugin.json'
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $actual $relative) -PathType Leaf)) {
            throw "Developer checkout is incomplete; missing $relative in $actual"
        }
    }
    return $actual
}

function Save-SgDeveloperChannelState {
    param(
        [Parameter(Mandatory=$true)][string]$Root,
        [Parameter(Mandatory=$true)][string]$TargetHome,
        [scriptblock]$EnvironmentWriter
    )

    $stateDirectory = Join-Path $TargetHome '.shipglows'
    $statePath = Join-Path $stateDirectory 'development-channel.json'
    $stateExisted = Test-Path -LiteralPath $statePath -PathType Leaf
    $previousState = if ($stateExisted) { [IO.File]::ReadAllText($statePath) } else { $null }
    $previousUserRoot = [Environment]::GetEnvironmentVariable('SHIPGLOWS_ROOT', 'User')
    $previousProcessRoot = [Environment]::GetEnvironmentVariable('SHIPGLOWS_ROOT', 'Process')
    $writeEnvironment = if ($EnvironmentWriter) {
        $EnvironmentWriter
    } else {
        { param($Name,$Value,$Target) [Environment]::SetEnvironmentVariable($Name,$Value,$Target) }
    }

    try {
        New-Item -ItemType Directory -Path $stateDirectory -Force | Out-Null
        $state = [ordered]@{
            schemaVersion = 1
            channel = 'linked'
            root = $Root
            linkedAt = [DateTimeOffset]::UtcNow.ToString('o')
        }
        [IO.File]::WriteAllText($statePath, ($state | ConvertTo-Json -Compress), [Text.UTF8Encoding]::new($false))
        & $writeEnvironment 'SHIPGLOWS_ROOT' $Root 'User'
        & $writeEnvironment 'SHIPGLOWS_ROOT' $Root 'Process'
    } catch {
        try {
            if ($stateExisted) {
                [IO.File]::WriteAllText($statePath, $previousState, [Text.UTF8Encoding]::new($false))
            } elseif (Test-Path -LiteralPath $statePath) {
                Remove-Item -LiteralPath $statePath -Force
            }
            & $writeEnvironment 'SHIPGLOWS_ROOT' $previousUserRoot 'User'
            & $writeEnvironment 'SHIPGLOWS_ROOT' $previousProcessRoot 'Process'
        } catch {
            throw 'ShipGlows developer channel state could not be persisted or rolled back safely.'
        }
        throw
    }
    return $statePath
}

function Install-SgDeveloperCheckout {
    param(
        [Parameter(Mandatory=$true)][string]$TargetPath,
        [Parameter(Mandatory=$true)][string]$RepositoryUrl,
        [Parameter(Mandatory=$true)][string]$Ref
    )

    $gitPath = Resolve-SgGitCommand
    $target = [IO.Path]::GetFullPath($TargetPath).TrimEnd('\')
    if (Test-Path -LiteralPath $target) {
        return Assert-SgDeveloperCheckout -Path $target -RepositoryUrl $RepositoryUrl -GitPath $gitPath
    }

    $parent = Split-Path -Parent $target
    if (-not $parent -or $target.Equals([IO.Path]::GetPathRoot($target), [StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe developer checkout target: $target"
    }
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $staging = Join-Path $parent ('.shipglows-clone-' + [guid]::NewGuid().ToString('N'))
    try {
        & $gitPath clone --branch $Ref -- $RepositoryUrl $staging
        if ($LASTEXITCODE -ne 0) { throw "Could not clone ShipGlows ref $Ref." }
        [void](Assert-SgDeveloperCheckout -Path $staging -RepositoryUrl $RepositoryUrl -GitPath $gitPath)
        if (Test-Path -LiteralPath $target) { throw "Developer target appeared during clone: $target" }
        Move-Item -LiteralPath $staging -Destination $target
    } finally {
        if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
    }
    return Assert-SgDeveloperCheckout -Path $target -RepositoryUrl $RepositoryUrl -GitPath $gitPath
}

function Enable-SgWindowsDeveloperChannel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ShipGlowsRoot,
        [string]$TargetHome = $env:USERPROFILE,
        [string]$RepositoryUrl = 'https://github.com/commandglows/shipglows.git',
        [switch]$ConfirmChannelSwitch
    )

    if (-not $ConfirmChannelSwitch) {
        throw 'The developer channel switch requires explicit confirmation.'
    }
    $root = Assert-SgDeveloperCheckout -Path $ShipGlowsRoot -RepositoryUrl $RepositoryUrl -GitPath (Resolve-SgGitCommand)
    $syncHelper = Join-Path $root 'tools\shipglows_sync_skills.ps1'
    $codex = Get-Command codex.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $codex) { throw 'Codex CLI is required to switch the ShipGlows developer channel.' }

    $plugins = @(Get-SgEnabledShipGlowsPluginIds -TargetHome $TargetHome)
    $removed = New-Object System.Collections.Generic.List[string]
    try {
        foreach ($pluginId in $plugins) {
            & $codex.Source plugin remove $pluginId
            if ($LASTEXITCODE -ne 0) { throw "Could not remove conflicting Codex plugin $pluginId." }
            $removed.Add($pluginId)
        }
        if (@(Get-SgEnabledShipGlowsPluginIds -TargetHome $TargetHome).Count) {
            throw 'A ShipGlows plugin remains enabled after the requested channel switch.'
        }

        $managedPowerShell = $env:SHIPGLOWS_MANAGED_PWSH
        if (-not $managedPowerShell -or -not (Test-Path -LiteralPath $managedPowerShell -PathType Leaf)) { throw 'The ShipGlows-managed PowerShell runtime is required for developer corpus synchronization.' }
        & $managedPowerShell -NoLogo -NoProfile -File $syncHelper `
            -Mode repair -All -Runtime codex -Catalog public -CodexEntrypoint linked `
            -TargetHome $TargetHome -ShipGlowsRoot $root -CleanStale
        if ($LASTEXITCODE -ne 0) { throw 'Could not link the ShipGlows developer skills into Codex.' }
        & $managedPowerShell -NoLogo -NoProfile -File $syncHelper `
            -Mode check -All -Runtime codex -Catalog public -CodexEntrypoint linked `
            -TargetHome $TargetHome -ShipGlowsRoot $root
        if ($LASTEXITCODE -ne 0) { throw 'ShipGlows developer skill verification failed.' }
    } catch {
        foreach ($pluginId in $removed) {
            & $codex.Source plugin add $pluginId 2>$null
        }
        throw
    }

    [void](Save-SgDeveloperChannelState -Root $root -TargetHome $TargetHome)
    Write-Output "ShipGlows developer channel linked to $root"
    return $root
}

Export-ModuleMember -Function Get-SgEnabledShipGlowsPluginIds, Assert-SgDeveloperCheckout, Install-SgDeveloperCheckout, Enable-SgWindowsDeveloperChannel
