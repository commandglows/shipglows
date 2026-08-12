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

    [string]$TargetHome = $env:USERPROFILE,

    [string]$ShipGlowsRoot = (Split-Path -Parent $PSScriptRoot),

    [switch]$BackupExisting
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Checked = 0
$script:Ok = 0
$script:Repaired = 0
$script:Blocked = 0

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

        Remove-Item -LiteralPath $targetPath -Force
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
foreach ($pair in $pairs) {
    foreach ($runtimeName in $runtimes) {
        Sync-SgSkill $runtimeName $pair.Name $pair.Source
    }
}

Write-Output "summary mode=$Mode runtime=$Runtime catalog=$Catalog checked=$script:Checked ok=$script:Ok repaired=$script:Repaired blocked=$script:Blocked"
if ($Mode -eq 'repair') {
    Write-Output 'note: already-running Claude or Codex sessions may need a reload or new session before repaired skills appear.'
}
if ($script:Blocked -gt 0) { exit 1 }
