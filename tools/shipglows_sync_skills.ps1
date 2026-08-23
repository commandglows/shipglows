[CmdletBinding(DefaultParameterSetName = 'All')]
param(
    [ValidateSet('check', 'repair')]
    [string]$Mode = 'check',

    [Parameter(ParameterSetName = 'All')]
    [switch]$All,

    [Parameter(Mandatory, ParameterSetName = 'Skill')]
    [ValidatePattern('^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$')]
    [string]$Skill,

    [ValidateSet('claude', 'codex', 'all')]
    [string]$Runtime = 'all',

    [ValidateSet('public', 'expert', 'all')]
    [string]$Catalog = 'public',

    [ValidateSet('linked', 'plugin')]
    [string]$CodexEntrypoint = 'linked',

    [string]$TargetHome = $env:USERPROFILE,

    [string]$ShipGlowsRoot = (Split-Path -Parent $PSScriptRoot),

    [switch]$BackupExisting,

    [switch]$CleanStale
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Checked = 0
$script:Ok = 0
$script:Repaired = 0
$script:Blocked = 0
$script:Skipped = 0

function Resolve-SgPath([string]$Path) {
    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
}

function Get-SgRuntimeDirectory([string]$Name) {
    switch ($Name) {
        'claude' { return Join-Path $TargetHome '.claude\skills' }
        'codex' { return Join-Path $TargetHome '.agents\skills' }
        default { throw "Unsupported runtime: $Name" }
    }
}

function Get-SgSourceDirectory([string]$Name) {
    $source = Join-Path (Join-Path $ShipGlowsRoot 'skills') $Name
    if (-not (Test-Path -LiteralPath (Join-Path $source 'SKILL.md') -PathType Leaf)) {
        throw "Missing source SKILL.md: $source\SKILL.md"
    }
    $resolvedSource = Resolve-SgPath $source
    $resolvedSkills = Resolve-SgPath (Join-Path $ShipGlowsRoot 'skills')
    if (-not $resolvedSource.StartsWith("$resolvedSkills\", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Source resolves outside skills root: $source"
    }
    return $source
}

function Get-SgPublicPairs {
    $registryPath = Join-Path $ShipGlowsRoot 'skills\references\skill-invocation-registry.json'
    if (-not (Test-Path -LiteralPath $registryPath -PathType Leaf)) {
        throw "Missing public skill registry: $registryPath"
    }
    $registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
    $pairs = foreach ($domain in $registry.public_catalog.domains) {
        foreach ($entry in $domain.skills) {
            $publicSkill = $entry.PSObject.Properties['public_skill']
            $source = if ($publicSkill -and $publicSkill.Value) { [string]$publicSkill.Value } else { [string]$entry.id }
            [pscustomobject]@{ Name = [string]$entry.id; Source = $source }
        }
    }
    $router = $registry.public_catalog.router
    $publicRouter = $router.PSObject.Properties['public_skill']
    $routerSource = if ($publicRouter -and $publicRouter.Value) { [string]$publicRouter.Value } else { [string]$router.id }
    @($pairs) + [pscustomobject]@{ Name = [string]$router.id; Source = $routerSource }
}

function Get-SgExpertPairs {
    $publicSources = @{}
    foreach ($pair in Get-SgPublicPairs) { $publicSources[$pair.Source] = $true }
    Get-ChildItem -LiteralPath (Join-Path $ShipGlowsRoot 'skills') -Directory | ForEach-Object {
        if ((Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf) -and
            -not $publicSources.ContainsKey($_.Name) -and
            $_.Name -match '^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$' -and
            $_.Name -notmatch '--') {
            [pscustomobject]@{ Name = $_.Name; Source = $_.Name }
        }
    }
}

function Get-SgLinkTarget([System.IO.FileSystemInfo]$Item) {
    if (-not $Item.LinkType) { return $null }
    $rawTarget = @($Item.Target)[0]
    if (-not $rawTarget) { return $null }
    if (-not [System.IO.Path]::IsPathRooted($rawTarget)) {
        $rawTarget = Join-Path $Item.Parent.FullName $rawTarget
    }
    if (-not (Test-Path -LiteralPath $rawTarget)) { return $null }
    return Resolve-SgPath $rawTarget
}

function New-SgDirectoryLink([string]$TargetPath, [string]$SourcePath) {
    $parent = Split-Path -Parent $TargetPath
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    New-Item -ItemType Junction -Path $TargetPath -Target $SourcePath | Out-Null
}

function Test-SgCodexPluginEnabled {
    $configPath = Join-Path $TargetHome '.codex\config.toml'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return $false }

    $inShipGlowsPlugin = $false
    foreach ($line in Get-Content -LiteralPath $configPath) {
        if ($line -match '^\s*\[(?<section>.+)\]\s*$') {
            $section = $Matches.section.Trim()
            $inShipGlowsPlugin = $section -match '^plugins\.(["'']?)shipglows@[^"'']+\1$'
            continue
        }
        if ($inShipGlowsPlugin -and $line -match '^\s*enabled\s*=\s*true\s*(?:#.*)?$') {
            return $true
        }
    }
    return $false
}

function Reconcile-SgCodexRouterChannel {
    $targetPath = Join-Path (Get-SgRuntimeDirectory 'codex') 'shipglows'
    if ($CodexEntrypoint -eq 'linked') {
        if (Test-SgCodexPluginEnabled) {
            throw 'Codex ShipGlows entrypoint conflict: the plugin is enabled while -CodexEntrypoint linked was selected. Remove the plugin or select the plugin entrypoint.'
        }
        return
    }

    if (-not (Test-SgCodexPluginEnabled)) {
        throw "Codex ShipGlows plugin entrypoint was selected, but no enabled ShipGlows plugin is recorded in $TargetHome\.codex\config.toml."
    }

    $item = Get-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
    if (-not $item) {
        $script:Skipped++
        Write-Output 'skipped runtime=codex skill=shipglows reason=plugin-entrypoint-selected'
        return
    }
    $resolvedTarget = Get-SgLinkTarget $item
    $resolvedSkills = Resolve-SgPath (Join-Path $ShipGlowsRoot 'skills')
    if (-not $resolvedTarget -or -not $resolvedTarget.StartsWith("$resolvedSkills\", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Codex router path is not a ShipGlows-managed junction: $targetPath"
    }
    if ($Mode -eq 'check') {
        $script:Blocked++
        Write-Output "conflict runtime=codex skill=shipglows target=$targetPath reason=plugin-entrypoint-selected"
        return
    }
    [System.IO.Directory]::Delete($item.FullName, $false)
    $script:Repaired++
    $script:Skipped++
    Write-Output "repaired runtime=codex skill=shipglows target=$targetPath reason=plugin-entrypoint-selected"
}

function Sync-SgSkill([string]$RuntimeName, [string]$Name, [string]$SourceName) {
    $sourcePath = Get-SgSourceDirectory $SourceName
    $resolvedSource = Resolve-SgPath $sourcePath
    $targetPath = Join-Path (Get-SgRuntimeDirectory $RuntimeName) $Name
    $script:Checked++

    $item = Get-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
    if ($item) {
        $resolvedTarget = Get-SgLinkTarget $item
        if ($resolvedTarget -and $resolvedTarget.Equals($resolvedSource, [System.StringComparison]::OrdinalIgnoreCase) -and
            (Test-Path -LiteralPath (Join-Path $targetPath 'SKILL.md') -PathType Leaf)) {
            $script:Ok++
            Write-Output "ok runtime=$RuntimeName skill=$Name target=$targetPath"
            return
        }

        if ($Mode -eq 'check') {
            $script:Blocked++
            $reason = if ($item.LinkType) { 'stale-or-broken-link' } else { 'non-link-existing' }
            Write-Output "drift runtime=$RuntimeName skill=$Name target=$targetPath reason=$reason"
            return
        }

        if (-not $item.LinkType) {
            if (-not $BackupExisting) {
                $script:Blocked++
                Write-Output "blocked runtime=$RuntimeName skill=$Name target=$targetPath reason=non-link-existing next=remove-or-rerun-with--BackupExisting"
                return
            }
            $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            $backupPath = Join-Path $item.Parent.FullName ".$($item.Name).backup-$stamp-$PID"
            Move-Item -LiteralPath $targetPath -Destination $backupPath
            New-SgDirectoryLink $targetPath $sourcePath
            $script:Repaired++
            Write-Output "repaired runtime=$RuntimeName skill=$Name target=$targetPath reason=backed-up-existing backup=$backupPath"
            return
        }

        if (-not $item.PSIsContainer) {
            throw "Refusing to replace a non-directory runtime link: $targetPath"
        }
        # Windows PowerShell 5.1 can throw a NullReferenceException when
        # Remove-Item targets a directory junction. Directory.Delete removes
        # the junction itself without traversing or deleting its source.
        [System.IO.Directory]::Delete($item.FullName, $false)
        New-SgDirectoryLink $targetPath $sourcePath
        $script:Repaired++
        Write-Output "repaired runtime=$RuntimeName skill=$Name target=$targetPath reason=stale-or-broken-link"
        return
    }

    if ($Mode -eq 'check') {
        $script:Blocked++
        Write-Output "missing runtime=$RuntimeName skill=$Name target=$targetPath"
        return
    }

    New-SgDirectoryLink $targetPath $sourcePath
    $script:Repaired++
    Write-Output "repaired runtime=$RuntimeName skill=$Name target=$targetPath reason=missing"
}

function Remove-SgStaleLinks([string]$RuntimeName, [System.Collections.Generic.HashSet[string]]$DesiredNames) {
    if ($Mode -ne 'repair' -or -not $CleanStale) { return }
    $runtimeDirectory = Get-SgRuntimeDirectory $RuntimeName
    if (-not (Test-Path -LiteralPath $runtimeDirectory -PathType Container)) { return }
    $resolvedSkills = Resolve-SgPath (Join-Path $ShipGlowsRoot 'skills')

    foreach ($item in @(Get-ChildItem -LiteralPath $runtimeDirectory -Force)) {
        if (-not $item.LinkType -or $DesiredNames.Contains($item.Name)) { continue }
        $resolvedTarget = Get-SgLinkTarget $item
        if (-not $resolvedTarget) { continue }
        if (-not $resolvedTarget.StartsWith("$resolvedSkills\", [System.StringComparison]::OrdinalIgnoreCase)) { continue }

        if (-not $item.PSIsContainer) {
            throw "Refusing to remove a non-directory runtime link: $($item.FullName)"
        }
        [System.IO.Directory]::Delete($item.FullName, $false)
        $script:Repaired++
        Write-Output "repaired runtime=$RuntimeName skill=$($item.Name) target=$($item.FullName) reason=removed-invalid-shipglows-link"
    }
}

if (-not $TargetHome) { throw 'USERPROFILE is unavailable; use -TargetHome.' }
if (-not (Test-Path -LiteralPath (Join-Path $ShipGlowsRoot 'skills') -PathType Container)) {
    throw "Missing skills directory: $ShipGlowsRoot\skills"
}

$pairs = if ($PSCmdlet.ParameterSetName -eq 'Skill') {
    @([pscustomobject]@{ Name = $Skill; Source = $Skill })
} elseif ($Catalog -eq 'public') {
    @(Get-SgPublicPairs)
} elseif ($Catalog -eq 'expert') {
    @(Get-SgExpertPairs)
} else {
    @(Get-SgPublicPairs) + @(Get-SgExpertPairs)
}

$runtimes = if ($Runtime -eq 'all') { @('claude', 'codex') } else { @($Runtime) }
$codexSelected = $runtimes -contains 'codex'
if ($codexSelected) { Reconcile-SgCodexRouterChannel }
$desiredNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($pair in $pairs) { [void]$desiredNames.Add([string]$pair.Name) }
foreach ($pair in $pairs) {
    foreach ($runtimeName in $runtimes) {
        if ($runtimeName -eq 'codex' -and $pair.Name -eq 'shipglows' -and $CodexEntrypoint -eq 'plugin') { continue }
        Sync-SgSkill $runtimeName $pair.Name $pair.Source
    }
}
foreach ($runtimeName in $runtimes) {
    Remove-SgStaleLinks $runtimeName $desiredNames
}

Write-Output "summary mode=$Mode runtime=$Runtime catalog=$Catalog codex_entrypoint=$CodexEntrypoint checked=$script:Checked ok=$script:Ok repaired=$script:Repaired skipped=$script:Skipped blocked=$script:Blocked"
if ($Mode -eq 'repair') {
    Write-Output 'note: already-running Claude or Codex sessions may need a reload or new session before repaired skills appear.'
}
if ($script:Blocked -gt 0) { exit 1 }
