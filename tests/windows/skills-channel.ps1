$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$helper = Join-Path $repoRoot 'tools\shipglows_sync_skills.ps1'
$fixtureHome = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-skills-channel-' + [guid]::NewGuid().ToString('N'))
$configDirectory = Join-Path $fixtureHome '.codex'
$configPath = Join-Path $configDirectory 'config.toml'

try {
    New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
    [IO.File]::WriteAllText(
        $configPath,
        "[plugins.`"shipglows@shipglows`"]`nenabled = true`n",
        [Text.UTF8Encoding]::new($false)
    )

    $ErrorActionPreference = 'Continue'
    $conflictOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $helper `
        -Mode check -All -Runtime codex -Catalog public -CodexEntrypoint linked `
        -TargetHome $fixtureHome -ShipGlowsRoot $repoRoot 2>&1 | Out-String
    $conflictExitCode = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    Assert-Sg ($conflictExitCode -ne 0) 'Linked mode must reject an enabled ShipGlows plugin.'
    Assert-Sg ($conflictOutput -match 'entrypoint conflict') 'Linked-mode conflict must be explicit.'

    [IO.File]::WriteAllText(
        $configPath,
        "[plugins.`"shipglows@shipglows`"]`nenabled = false`n",
        [Text.UTF8Encoding]::new($false)
    )
    $linkedOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $helper `
        -Mode repair -All -Runtime codex -Catalog public -CodexEntrypoint linked `
        -TargetHome $fixtureHome -ShipGlowsRoot $repoRoot 2>&1 | Out-String
    Assert-Sg ($LASTEXITCODE -eq 0) "Linked repair failed: $linkedOutput"
    $router = Get-Item -LiteralPath (Join-Path $fixtureHome '.agents\skills\shipglows') -Force
    Assert-Sg ($router.LinkType -eq 'Junction') 'Developer router must be a directory junction.'
    Assert-Sg ($linkedOutput -match 'codex_entrypoint=linked') 'Linked summary must expose channel ownership.'

    $routerPath = Join-Path $fixtureHome '.agents\skills\shipglows'
    [System.IO.Directory]::Delete($routerPath, $false)
    New-Item -ItemType Junction -Path $routerPath -Target (Join-Path $repoRoot 'skills\sg-bug') | Out-Null
    $staleRepairOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $helper `
        -Mode repair -All -Runtime codex -Catalog public -CodexEntrypoint linked `
        -TargetHome $fixtureHome -ShipGlowsRoot $repoRoot 2>&1 | Out-String
    Assert-Sg ($LASTEXITCODE -eq 0) "Stale junction repair failed: $staleRepairOutput"
    $repairedRouter = Get-Item -LiteralPath $routerPath -Force
    Assert-Sg ((Resolve-Path -LiteralPath $repairedRouter.Target[0]).Path -eq (Resolve-Path -LiteralPath (Join-Path $repoRoot 'skills\shipglows')).Path) 'Stale developer router junction must be replaced without traversing its source.'
    Assert-Sg ($staleRepairOutput -match 'reason=stale-or-broken-link') 'Stale junction repair must remain observable.'

    [IO.File]::WriteAllText(
        $configPath,
        "[plugins.`"shipglows@shipglows`"]`nenabled = true`n",
        [Text.UTF8Encoding]::new($false)
    )
    $pluginOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $helper `
        -Mode repair -All -Runtime codex -Catalog public -CodexEntrypoint plugin `
        -TargetHome $fixtureHome -ShipGlowsRoot $repoRoot 2>&1 | Out-String
    Assert-Sg ($LASTEXITCODE -eq 0) "Plugin reconciliation failed: $pluginOutput"
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\shipglows'))) 'Plugin mode must remove the managed linked router.'
    Assert-Sg (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\sg-development\SKILL.md')) 'Plugin mode must preserve non-router public skills.'
    Assert-Sg ($pluginOutput -match 'plugin-entrypoint-selected') 'Plugin reconciliation must report the router decision.'

    Write-Output 'Windows ShipGlows skill-channel tests passed.'
} finally {
    if (Test-Path -LiteralPath $fixtureHome) {
        Remove-Item -LiteralPath $fixtureHome -Recurse -Force
    }
}
