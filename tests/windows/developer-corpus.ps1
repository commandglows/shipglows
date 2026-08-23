$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$module = Join-Path $repoRoot 'cli\windows\ShipGlows.DeveloperCorpus.psm1'
$fixtureHome = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-developer-corpus-' + [guid]::NewGuid().ToString('N'))

try {
    $moduleText = [IO.File]::ReadAllText($module)
    Assert-Sg ($moduleText -notmatch '--single-branch') 'Contributor clones must fetch the complete branch namespace.'
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
    $failedProcessWrite = $false
    $rollbackWriter = {
        param($Name,$Value,$Target)
        if ($Target -eq 'Process' -and $Value -eq $repoRoot -and -not $failedProcessWrite) {
            $failedProcessWrite = $true
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
    if (Test-Path -LiteralPath $fixtureHome) { Remove-Item -LiteralPath $fixtureHome -Recurse -Force }
}
