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
    Assert-Sg (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\sg-design\SKILL.md')) 'Public mode must expose the public design owner.'
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\006-sg-design'))) 'Public mode must exclude the internal design engine.'

    $personalSkill = Join-Path $fixtureHome '.agents\skills\personal-skill'
    New-Item -ItemType Directory -Path $personalSkill -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $personalSkill 'SKILL.md'), "personal`n", [Text.UTF8Encoding]::new($false))
    $expertOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $helper `
        -Mode repair -All -Runtime codex -Catalog expert -CodexEntrypoint linked `
        -TargetHome $fixtureHome -ShipGlowsRoot $repoRoot 2>&1 | Out-String
    Assert-Sg ($LASTEXITCODE -eq 0) "Expert switch failed: $expertOutput"
    Assert-Sg (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\006-sg-design\SKILL.md')) 'Expert mode must expose the internal design engine.'
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\sg-design'))) 'Expert mode must exclude the public design owner.'
    Assert-Sg (Test-Path -LiteralPath (Join-Path $personalSkill 'SKILL.md')) 'Catalog switching must preserve personal skills.'

    $publicConflictOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $helper `
        -Mode check -All -Runtime codex -Catalog public -CodexEntrypoint linked `
        -TargetHome $fixtureHome -ShipGlowsRoot $repoRoot 2>&1 | Out-String
    Assert-Sg ($LASTEXITCODE -ne 0) 'Public check must reject an installed expert catalog.'
    Assert-Sg ($publicConflictOutput -match 'excluded-by-public-catalog') 'Catalog conflict must explain the exclusive public boundary.'
    $publicSwitchOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $helper `
        -Mode repair -All -Runtime codex -Catalog public -CodexEntrypoint linked `
        -TargetHome $fixtureHome -ShipGlowsRoot $repoRoot 2>&1 | Out-String
    Assert-Sg ($LASTEXITCODE -eq 0) "Public switch failed: $publicSwitchOutput"
    Assert-Sg (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\sg-design\SKILL.md')) 'Public switch must restore the public design owner.'
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $fixtureHome '.agents\skills\006-sg-design'))) 'Public switch must remove the internal design engine.'
    Assert-Sg (Test-Path -LiteralPath (Join-Path $personalSkill 'SKILL.md')) 'Public switch must preserve personal skills.'

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
