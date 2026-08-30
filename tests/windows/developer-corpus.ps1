$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$module = Join-Path $repoRoot 'cli\windows\ShipGlows.DeveloperCorpus.psm1'
$fixtureHome = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-developer-corpus-' + [guid]::NewGuid().ToString('N'))
$previousManagedPowerShell = $env:SHIPGLOWS_MANAGED_PWSH

try {
    $moduleText = [IO.File]::ReadAllText($module)
    Assert-Sg ($moduleText -notmatch '--single-branch') 'Contributor clones must fetch the complete branch namespace.'
    Assert-Sg ($moduleText -notmatch '\s-CleanStale(?:\s|$)') 'Developer channel activation must use the synchronizer current catalog-reconciliation contract.'
    $publicRouterText = [IO.File]::ReadAllText((Join-Path $repoRoot 'skills\shipglows\SKILL.md'))
    $canonicalPathsText = [IO.File]::ReadAllText((Join-Path $repoRoot 'skills\references\canonical-paths.md'))
    foreach ($requiredEvidence in @('current-user environment value','development-channel.json','already running')) {
        Assert-Sg ($publicRouterText.Contains($requiredEvidence) -or $canonicalPathsText.Contains($requiredEvidence)) "Developer root doctrine is missing stale-process recovery evidence: $requiredEvidence"
    }
    Assert-Sg ($publicRouterText.Contains('channel: linked') -and $publicRouterText.Contains('skills/000-shipglows/SKILL.md')) 'The public router must validate durable linked-channel state before falling back to the installed runtime.'
    Import-Module $module -Force
    $configDirectory = Join-Path $fixtureHome '.codex'
    New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
    [IO.File]::WriteAllText(
        (Join-Path $configDirectory 'config.toml'),
        "[plugins.`"shipglows@shipglows`"]`nenabled = true`n[plugins.`"other@example`"]`nenabled = true`n",
        [Text.UTF8Encoding]::new($false)
    )
    $pluginIds = @(Get-SgEnabledShipGlowsPluginIds -TargetHome $fixtureHome)
    Assert-Sg ($pluginIds.Count -eq 1 -and $pluginIds[0] -eq 'shipglows@shipglows') 'Plugin detection must return only enabled ShipGlows plugins.'

    $checkout = Assert-SgDeveloperCheckout -Path $repoRoot -RepositoryUrl 'https://github.com/commandglows/shipglows.git' -GitPath (Get-Command git.exe).Source
    Assert-Sg ($checkout -eq $repoRoot) 'The canonical checkout must validate without mutation.'

    $confirmationBlocked = $false
    try { Enable-SgWindowsDeveloperChannel -ShipGlowsRoot $repoRoot -TargetHome $fixtureHome }
    catch { $confirmationBlocked = $_.Exception.Message -match 'explicit confirmation' }
    Assert-Sg $confirmationBlocked 'Developer channel mutation must require explicit confirmation.'

    $environmentWrites = New-Object System.Collections.Generic.List[object]
    $environmentWriter = {
        param($Name,$Value,$Target)
        $environmentWrites.Add([pscustomobject]@{ Name=$Name; Value=$Value; Target=$Target })
    }.GetNewClosure()
    $loadedModule = Get-Module ShipGlows.DeveloperCorpus
    $statePath = & $loadedModule {
        param($Root,$TargetHome,$Writer)
        Save-SgDeveloperChannelState -Root $Root -TargetHome $TargetHome -EnvironmentWriter $Writer
    } $repoRoot $fixtureHome $environmentWriter
    $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json
    Assert-Sg ($state.channel -eq 'linked' -and $state.root -eq $repoRoot) 'Developer channel state must identify the exact linked root.'
    Assert-Sg (@($environmentWrites | Where-Object { $_.Name -eq 'SHIPGLOWS_ROOT' -and $_.Value -eq $repoRoot -and $_.Target -eq 'User' }).Count -eq 1) 'Developer channel must persist SHIPGLOWS_ROOT for the current user.'
    Assert-Sg (@($environmentWrites | Where-Object { $_.Name -eq 'SHIPGLOWS_ROOT' -and $_.Value -eq $repoRoot -and $_.Target -eq 'Process' }).Count -eq 1) 'Developer channel must activate SHIPGLOWS_ROOT for the current process.'

    $rollbackHome = Join-Path $fixtureHome 'rollback-home'
    $rollbackControl = [pscustomobject]@{ FailedProcessWrite = $false }
    $rollbackWriter = {
        param($Name,$Value,$Target)
        if ($Target -eq 'Process' -and $Value -eq $repoRoot -and -not $rollbackControl.FailedProcessWrite) {
            $rollbackControl.FailedProcessWrite = $true
            throw 'simulated process environment failure'
        }
    }.GetNewClosure()
    $rollbackObserved = $false
    try {
        & $loadedModule {
            param($Root,$TargetHome,$Writer)
            Save-SgDeveloperChannelState -Root $Root -TargetHome $TargetHome -EnvironmentWriter $Writer
        } $repoRoot $rollbackHome $rollbackWriter
    } catch { $rollbackObserved = $_.Exception.Message -match 'simulated process environment failure' }
    Assert-Sg $rollbackObserved 'Developer channel persistence failure must remain observable.'
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $rollbackHome '.shipglows\development-channel.json'))) 'Failed developer channel persistence must roll back its new state file.'

    [IO.File]::WriteAllText(
        (Join-Path $configDirectory 'config.toml'),
        "[plugins.`"shipglows@shipglows`"]`nenabled = false`n",
        [Text.UTF8Encoding]::new($false)
    )
    $staleRoot = Join-Path $fixtureHome 'deleted-worktree'
    $staleRouterSource = Join-Path $staleRoot 'skills\shipglows'
    New-Item -ItemType Directory -Path $staleRouterSource -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $staleRouterSource 'SKILL.md'), "stale`n", [Text.UTF8Encoding]::new($false))
    $runtimeSkills = Join-Path $fixtureHome '.agents\skills'
    New-Item -ItemType Directory -Path $runtimeSkills -Force | Out-Null
    New-Item -ItemType Junction -Path (Join-Path $runtimeSkills 'shipglows') -Target $staleRouterSource | Out-Null
    $personalSkill = Join-Path $runtimeSkills 'personal-skill'
    New-Item -ItemType Directory -Path $personalSkill -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $personalSkill 'SKILL.md'), "personal`n", [Text.UTF8Encoding]::new($false))
    New-Item -ItemType Directory -Path (Join-Path $fixtureHome '.shipglows') -Force | Out-Null
    [IO.File]::WriteAllText(
        (Join-Path $fixtureHome '.shipglows\development-channel.json'),
        ([ordered]@{ schemaVersion=1; channel='linked'; root=$staleRoot; linkedAt=[DateTimeOffset]::UtcNow.ToString('o') } | ConvertTo-Json -Compress),
        [Text.UTF8Encoding]::new($false)
    )
    Remove-Item -LiteralPath $staleRoot -Recurse -Force
    Assert-Sg (-not (Test-Path -LiteralPath $staleRoot)) 'The stale linked checkout fixture must be absent before channel activation.'

    $environmentWrites.Clear()
    $env:SHIPGLOWS_MANAGED_PWSH = (Get-Command powershell.exe -CommandType Application).Source
    $enabledOutput = @(Enable-SgWindowsDeveloperChannel -ShipGlowsRoot $repoRoot -TargetHome $fixtureHome `
        -ConfirmChannelSwitch -EnvironmentWriter $environmentWriter)
    $enabledRoot = $enabledOutput[-1]
    Assert-Sg ($enabledRoot -eq $repoRoot) 'The public developer-channel command must select the existing canonical checkout.'
    $enabledState = [IO.File]::ReadAllText((Join-Path $fixtureHome '.shipglows\development-channel.json')) | ConvertFrom-Json
    Assert-Sg ($enabledState.channel -eq 'linked' -and $enabledState.root -eq $repoRoot) 'The stale linked channel must be replaced by the canonical checkout state.'
    Assert-Sg (@($environmentWrites | Where-Object { $_.Name -eq 'SHIPGLOWS_ROOT' -and $_.Value -eq $repoRoot -and $_.Target -eq 'User' }).Count -eq 1) 'The public switch must persist the canonical root for the current user.'
    $publicRegistry = Get-Content -LiteralPath (Join-Path $repoRoot 'skills\references\skill-invocation-registry.json') -Raw | ConvertFrom-Json
    $publicNames = @($publicRegistry.public_catalog.domains.skills.id) + @($publicRegistry.public_catalog.router.id)
    foreach ($publicName in $publicNames) {
        $runtimeLink = Get-Item -LiteralPath (Join-Path $runtimeSkills $publicName) -Force
        Assert-Sg ($runtimeLink.LinkType -eq 'Junction') "Public skill must be linked after the official switch: $publicName"
        $runtimeTarget = (Resolve-Path -LiteralPath @($runtimeLink.Target)[0]).Path
        Assert-Sg ($runtimeTarget.StartsWith((Join-Path $repoRoot 'skills'), [StringComparison]::OrdinalIgnoreCase)) "Public skill must point into the canonical checkout: $publicName"
    }
    Assert-Sg (Test-Path -LiteralPath (Join-Path $personalSkill 'SKILL.md')) 'The official switch must preserve personal skills.'

    $source = Join-Path $fixtureHome 'source'
    foreach ($relative in @('skills\shipglows', 'skills\references', 'tools', 'plugins\shipglows\.codex-plugin')) {
        New-Item -ItemType Directory -Path (Join-Path $source $relative) -Force | Out-Null
    }
    foreach ($relative in @(
        'skills\shipglows\SKILL.md',
        'skills\references\skill-invocation-registry.json',
        'skills\references\canonical-paths.md',
        'tools\shipglows_sync_skills.ps1',
        'plugins\shipglows\.codex-plugin\plugin.json'
    )) {
        [IO.File]::WriteAllText((Join-Path $source $relative), "fixture`n", [Text.UTF8Encoding]::new($false))
    }
    & git.exe -C $source init -b main | Out-Null
    & git.exe -C $source config user.name 'ShipGlows Test'
    & git.exe -C $source config user.email 'shipglows-test@example.invalid'
    & git.exe -C $source add .
    & git.exe -C $source commit -m fixture | Out-Null
    $cloneTarget = Join-Path $fixtureHome 'clone\shipglows'
    $cloned = Install-SgDeveloperCheckout -TargetPath $cloneTarget -RepositoryUrl $source -Ref main
    Assert-Sg ($cloned -eq [IO.Path]::GetFullPath($cloneTarget)) 'Fresh developer clone must converge on the exact requested root.'
    Assert-Sg (Test-Path -LiteralPath (Join-Path $cloned 'skills\shipglows\SKILL.md')) 'Fresh developer clone is incomplete.'

    $foreign = Join-Path $fixtureHome 'foreign'
    New-Item -ItemType Directory -Path $foreign -Force | Out-Null
    & git.exe -C $foreign init | Out-Null
    & git.exe -C $foreign remote add origin https://github.com/example/not-shipglows.git
    $originBlocked = $false
    try { Assert-SgDeveloperCheckout -Path $foreign -RepositoryUrl 'https://github.com/commandglows/shipglows.git' -GitPath (Get-Command git.exe).Source }
    catch { $originBlocked = $_.Exception.Message -match 'origin does not match' }
    Assert-Sg $originBlocked 'A foreign repository must never be accepted as the developer checkout.'

    Write-Output 'Windows ShipGlows developer-corpus tests passed.'
} finally {
    $env:SHIPGLOWS_MANAGED_PWSH = $previousManagedPowerShell
    if (Test-Path -LiteralPath $fixtureHome) { Remove-Item -LiteralPath $fixtureHome -Recurse -Force }
}
