param(
    [int]$MaximumHelpOverheadMedianMs = 300,
    [int]$MaximumHelpMedianMs = 2000,
    [int]$MaximumLauncherHelpMedianMs = 1000,
    [int]$MaximumReconcileMs = 800,
    [int]$MaximumDashboardMedianMs = 2500
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$entrypoint = Join-Path $root 'cli\windows\shipglows-devserver.ps1'
$bootstrap = Join-Path $root 'cli\windows\ShipGlows.PowerShellBootstrap.ps1'
$refresher = Join-Path $root 'cli\windows\ShipGlows.ProjectCatalogRefresh.ps1'
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$source = [IO.File]::ReadAllText($entrypoint)
$moduleSource = [IO.File]::ReadAllText($modulePath)
$bootstrapSource = [IO.File]::ReadAllText($bootstrap)

if (-not (Test-Path -LiteralPath $refresher -PathType Leaf)) { throw 'The detached project-catalog refresher is missing.' }
$refresherSource = [IO.File]::ReadAllText($refresher)

if ($source -notmatch [regex]::Escape('if (Test-SgImmediateAction $Action $ShortcutPath)')) { throw 'The CLI immediate-action fast path is missing.' }
if ($bootstrapSource -notmatch [regex]::Escape('Resolve-SgManagedPowerShellForLaunch')) { throw 'The CLI launcher does not use the integrity-bound fast runtime resolution.' }
$menuSource = [regex]::Match($source,'(?s)function Invoke-Menu\s*\{(.*?)\r?\n\}\r?\n\r?\ntry \{')
if (-not $menuSource.Success) { throw 'The interactive menu contract could not be isolated.' }
if ($menuSource.Value -match [regex]::Escape('Show-SgWindowsDashboard')) { throw 'The interactive menu still prints the project dashboard without an explicit request.' }
if ($menuSource.Value.IndexOf('Start-SgBackgroundCatalogRefresh') -gt $menuSource.Value.IndexOf("Read-SgChoice 'What do you want to do?'")) { throw 'The menu does not start catalogue refresh before user think time.' }
if ([regex]::Matches($menuSource.Value, [regex]::Escape('Complete-SgBackgroundCatalogRefresh')).Count -lt 2) { throw 'The menu does not adopt a completed background snapshot before dispatch.' }
if ($source -notmatch [regex]::Escape('Import-SgAuthenticationModule')) { throw 'The authentication module is not lazy-loaded.' }
if ($source -match '(?m)^Import-Module \$mobileModule -Force -DisableNameChecking\s*$') { throw 'The unused mobile module is still eagerly loaded.' }
if ($moduleSource -notmatch [regex]::Escape('function Get-SgProcessSnapshotMap')) { throw 'The registry process snapshot batch is missing.' }
foreach ($required in @('function Start-SgBackgroundCatalogRefresh','Test-SgProjectCatalogRefreshRequired $config','[Diagnostics.Process]::Start($startInfo)','Clear-SgProjectCatalogMemoryCache $config','function Complete-SgBackgroundCatalogRefresh')) {
    if ($source -notmatch [regex]::Escape($required)) { throw "The non-blocking catalogue refresh contract is missing: $required" }
}
if ([regex]::Matches($source, [regex]::Escape('Get-SgProjectCatalogForDisplay $config')).Count -lt 2) { throw 'Dashboard and picker do not share the consistent display catalogue.' }
if ($source -match [regex]::Escape('Get-SgProjectCatalog $config -SkipProcessReconciliation')) { throw 'A displayed project list still bypasses process reconciliation.' }
$displayCatalogSource = [regex]::Match($moduleSource,'(?s)function Get-SgProjectCatalogForDisplay\([^)]*\)\s*\{(.*?)\r?\n\}')
if (-not $displayCatalogSource.Success -or $displayCatalogSource.Value -notmatch 'Get-SgProjectCatalog \$Config\)') { throw 'Displayed project lists do not consume the prepared catalogue snapshot.' }
if ($displayCatalogSource.Value -match 'ForceRefresh') { throw 'Displayed project lists still force a synchronous workspace rescan.' }

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-catalog-refresh-' + [guid]::NewGuid().ToString('N'))
try {
    $workspace = Join-Path $fixture 'workspace'
    $runtime = Join-Path $fixture 'runtime'
    $project = Join-Path $workspace 'site'
    New-Item -ItemType Directory -Path $project,$runtime -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $project 'package.json'),'{"scripts":{"dev":"astro dev"},"dependencies":{"astro":"latest"}}',[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $runtime 'project-index.json.refreshing'),'refreshing',[Text.UTF8Encoding]::new($false))
    $env:SHIPGLOWS_CATALOG_WORKSPACE = $workspace
    $env:SHIPGLOWS_CATALOG_RUNTIME = $runtime
    try { & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $refresher *> $null }
    finally { Remove-Item Env:SHIPGLOWS_CATALOG_WORKSPACE,Env:SHIPGLOWS_CATALOG_RUNTIME -ErrorAction SilentlyContinue }
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath (Join-Path $runtime 'project-index.json') -PathType Leaf)) { throw 'The detached catalogue refresher did not build its index.' }
    if (Test-Path -LiteralPath (Join-Path $runtime 'project-index.json.refreshing')) { throw 'The detached catalogue refresher did not release its claim.' }

    $secondProject = Join-Path $workspace 'second-site'
    New-Item -ItemType Directory -Path $secondProject -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $secondProject 'package.json'),'{"scripts":{"dev":"vite"},"devDependencies":{"vite":"latest"}}',[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $runtime 'project-index.json.refreshing'),'refreshing',[Text.UTF8Encoding]::new($false))
    $env:SHIPGLOWS_CATALOG_WORKSPACE = $workspace
    $env:SHIPGLOWS_CATALOG_RUNTIME = $runtime
    try { & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $refresher *> $null }
    finally { Remove-Item Env:SHIPGLOWS_CATALOG_WORKSPACE,Env:SHIPGLOWS_CATALOG_RUNTIME -ErrorAction SilentlyContinue }
    $proactiveIndex = Get-Content -LiteralPath (Join-Path $runtime 'project-index.json') -Raw | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or @($proactiveIndex.projects).Count -ne 2) { throw 'The menu refresher did not replace a fresh-but-incomplete snapshot.' }

    Import-Module $modulePath -Force -DisableNameChecking
    $process = Get-Process -Id $PID
    $entries = @()
    1..9 | ForEach-Object {
        $entryPath = Join-Path $workspace "registered-$_"
        New-Item -ItemType Directory -Path $entryPath -Force | Out-Null
        $entries += [pscustomobject]@{name="registered-$_";path=$entryPath;rootPath=$entryPath;launchPath=$entryPath;kind='astro';port=(33000+$_);status='running';pid=$PID;startTimeUtc=$process.StartTime.ToUniversalTime().ToString('o');executablePath=$process.Path;commandSignature=$null;logPath=$null;errorLogPath=$null;lastError=$null}
    }
    [pscustomobject]@{schemaVersion=1;projects=$entries} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $runtime 'registry.json') -Encoding UTF8
    $config = [pscustomobject]@{Workspace=$workspace;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock');ProjectIndexPath=(Join-Path $runtime 'project-index.json');LogDirectory=(Join-Path $runtime 'logs');PortStart=33000;PortEnd=33100}
    $reconcileWatch = [Diagnostics.Stopwatch]::StartNew()
    Reconcile-SgRegistry $config | Out-Null
    $reconcileWatch.Stop()
    if ($reconcileWatch.Elapsed.TotalMilliseconds -ge $MaximumReconcileMs) { throw "Batched registry reconciliation took $([math]::Round($reconcileWatch.Elapsed.TotalMilliseconds,1)) ms and exceeded $MaximumReconcileMs ms." }

} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}

if ($PSVersionTable.PSEdition -ne 'Core') {
    Write-Host 'Windows CLI Core-host performance timing: skipped under bootstrap-only Windows PowerShell.'
    return
}
if ($refresherSource -notmatch [regex]::Escape('Get-SgWorkspaceProjectCandidates $config -ForceRefresh')) { throw 'The menu refresher does not proactively rebuild discovery.' }

$coreHost = (Get-Process -Id $PID).Path
$env:SHIPGLOWS_MANAGED_PWSH = $coreHost
& $coreHost -NoLogo -NoProfile -Command 'exit 0'
& $coreHost -NoLogo -NoProfile -File $entrypoint h *> $null
if ($LASTEXITCODE -ne 0) { throw 'The help fast-path warm-up failed.' }
$baselineTimes = @()
$helpTimes = @()
$helpOverheads = @()
1..11 | ForEach-Object {
    $baselineWatch = [Diagnostics.Stopwatch]::StartNew()
    & $coreHost -NoLogo -NoProfile -Command 'exit 0'
    if ($LASTEXITCODE -ne 0) { throw 'The PowerShell startup baseline failed.' }
    $baselineWatch.Stop()

    $helpWatch = [Diagnostics.Stopwatch]::StartNew()
    & $coreHost -NoLogo -NoProfile -File $entrypoint h *> $null
    if ($LASTEXITCODE -ne 0) { throw 'The help fast path failed.' }
    $helpWatch.Stop()

    $baselineTimes += $baselineWatch.Elapsed.TotalMilliseconds
    $helpTimes += $helpWatch.Elapsed.TotalMilliseconds
    $helpOverheads += ($helpWatch.Elapsed.TotalMilliseconds - $baselineWatch.Elapsed.TotalMilliseconds)
}
$baselineMedian = @($baselineTimes | Sort-Object)[5]
$helpMedian = @($helpTimes | Sort-Object)[5]
$helpOverheadMedian = @($helpOverheads | Sort-Object)[5]
if ($helpOverheadMedian -ge $MaximumHelpOverheadMedianMs) { throw "Windows CLI help overhead median $([math]::Round($helpOverheadMedian,1)) ms exceeds $MaximumHelpOverheadMedianMs ms above the host startup baseline." }
if ($helpMedian -ge $MaximumHelpMedianMs) { throw "Windows CLI help median $([math]::Round($helpMedian,1)) ms exceeds the $MaximumHelpMedianMs ms runner sanity ceiling." }
$launcherTimes = @()
$managedPowerShell = Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell\7.6.5\win-x64\pwsh.exe'
if (-not (Test-Path -LiteralPath $managedPowerShell -PathType Leaf)) { throw 'The managed PowerShell runtime required for complete launcher timing is missing.' }
$previousManagedMarker = $env:SHIPGLOWS_MANAGED_PWSH
try {
    $env:SHIPGLOWS_MANAGED_PWSH = $managedPowerShell
    $launcherCommand = ('""{0}" -NoLogo -NoProfile -File "{1}" h"' -f $managedPowerShell,$entrypoint)
    1..7 | ForEach-Object {
        $launcherWatch = [Diagnostics.Stopwatch]::StartNew()
        & cmd.exe /d /c $launcherCommand *> $null
        if ($LASTEXITCODE -ne 0) { throw 'The complete CLI launcher help path failed.' }
        $launcherWatch.Stop()
        $launcherTimes += $launcherWatch.Elapsed.TotalMilliseconds
    }
} finally {
    if ($null -eq $previousManagedMarker) { Remove-Item Env:SHIPGLOWS_MANAGED_PWSH -ErrorAction SilentlyContinue } else { $env:SHIPGLOWS_MANAGED_PWSH = $previousManagedMarker }
}
$launcherMedian = @($launcherTimes | Sort-Object)[3]
if ($launcherMedian -ge $MaximumLauncherHelpMedianMs) { throw "Windows CLI launcher help median $([math]::Round($launcherMedian,1)) ms exceeds $MaximumLauncherHelpMedianMs ms." }
$dashboardTimes = @()
$dashboardFixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-dashboard-perf-' + [guid]::NewGuid().ToString('N'))
$previousLocalAppData = $env:LOCALAPPDATA
$previousWorkspace = $env:SHIPGLOWS_WINDOWS_WORKSPACE
try {
    $dashboardWorkspace = Join-Path $dashboardFixture 'workspace'
    $dashboardLocalAppData = Join-Path $dashboardFixture 'localappdata'
    $dashboardRuntime = Join-Path $dashboardLocalAppData 'ShipGlows\DevServer'
    New-Item -ItemType Directory -Path $dashboardWorkspace,$dashboardRuntime -Force | Out-Null
    [pscustomobject]@{schemaVersion=1;workspace=[IO.Path]::GetFullPath($dashboardWorkspace);scannerVersion='1';generatedAt=(Get-Date).ToUniversalTime().AddHours(-1).ToString('o');projects=@()} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $dashboardRuntime 'project-index.json') -Encoding UTF8
    [pscustomobject]@{schemaVersion=1;projects=@()} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $dashboardRuntime 'registry.json') -Encoding UTF8
    [pscustomobject]@{schemaVersion=1;checkedAt=(Get-Date).ToUniversalTime().ToString('o');installedVersion='1.0.0';availableVersion='1.0.0';level='current';message='ShipGlows est a jour.';available=$false} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $dashboardRuntime 'shipglows-update-status.json') -Encoding UTF8
    $env:LOCALAPPDATA = $dashboardLocalAppData
    $env:SHIPGLOWS_WINDOWS_WORKSPACE = $dashboardWorkspace
    1..7 | ForEach-Object {
        $watch = [Diagnostics.Stopwatch]::StartNew()
        & $coreHost -NoLogo -NoProfile -File $entrypoint d *> $null
        if ($LASTEXITCODE -ne 0) { throw 'The dashboard fast path failed.' }
        $watch.Stop()
        $dashboardTimes += $watch.Elapsed.TotalMilliseconds
    }
} finally {
    $env:LOCALAPPDATA = $previousLocalAppData
    if ($null -eq $previousWorkspace) { Remove-Item Env:SHIPGLOWS_WINDOWS_WORKSPACE -ErrorAction SilentlyContinue } else { $env:SHIPGLOWS_WINDOWS_WORKSPACE = $previousWorkspace }
    if (Test-Path -LiteralPath $dashboardFixture) { Remove-Item -LiteralPath $dashboardFixture -Recurse -Force }
}
$dashboardMedian = @($dashboardTimes | Sort-Object)[3]
if ($dashboardMedian -ge $MaximumDashboardMedianMs) { throw "Windows CLI dashboard median $([math]::Round($dashboardMedian,1)) ms exceeds $MaximumDashboardMedianMs ms." }
Write-Host ('Windows CLI performance regression: OK powershell_baseline_median_ms={0} help_median_ms={1} help_overhead_median_ms={2} launcher_help_median_ms={3} dashboard_median_ms={4} reconcile_ms={5}' -f [math]::Round($baselineMedian,1),[math]::Round($helpMedian,1),[math]::Round($helpOverheadMedian,1),[math]::Round($launcherMedian,1),[math]::Round($dashboardMedian,1),[math]::Round($reconcileWatch.Elapsed.TotalMilliseconds,1))
