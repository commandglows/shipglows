param([string]$BenchmarkWorkspace = '')

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Write-Package([string]$Path, [string]$Kind = 'vite', [bool]$Runnable = $true) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    $dependency = if ($Kind -eq 'astro') { 'astro' } else { 'vite' }
    $package = [ordered]@{ devDependencies = [ordered]@{ $dependency = 'latest' } }
    if ($Runnable) { $package['scripts'] = [ordered]@{ dev = $dependency } }
    $package | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $Path 'package.json') -Encoding UTF8
}

function New-TestConfig([string]$Workspace, [string]$Runtime) {
    New-Item -ItemType Directory -Path $Workspace,$Runtime -Force | Out-Null
    [pscustomobject]@{
        Workspace = [IO.Path]::GetFullPath($Workspace)
        RuntimeDirectory = [IO.Path]::GetFullPath($Runtime)
        RegistryPath = Join-Path $Runtime 'registry.json'
        LockPath = Join-Path $Runtime 'registry.lock'
        ProjectIndexPath = Join-Path $Runtime 'project-index.json'
        LogDirectory = Join-Path $Runtime 'logs'
        PortStart = 32000
        PortEnd = 32020
    }
}

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-project-catalog-{0}" -f [guid]::NewGuid().ToString('N'))
$workspace = Join-Path $fixture 'workspace'
$runtime = Join-Path $fixture 'runtime'

try {
    $alpha = Join-Path $workspace 'alpha\site'
    $beta = Join-Path $workspace 'beta\site'
    $ignored = Join-Path $workspace 'ignored'
    $emptyDependencies = Join-Path $workspace 'empty-dependencies'
    Write-Package $alpha 'astro'
    Write-Package $beta 'vite'
    Write-Package $ignored 'astro' $false
    New-Item -ItemType Directory -Path $emptyDependencies -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $emptyDependencies 'package.json') -Value '{"dependencies":{}}' -Encoding UTF8
    New-Item -ItemType Directory -Path (Join-Path $workspace 'alpha\.git') -Force | Out-Null

    Import-Module $modulePath -Force -DisableNameChecking
    $config = New-TestConfig $workspace $runtime

    $edgeConfig = New-TestConfig (Join-Path $fixture 'edge-workspace') (Join-Path $fixture 'edge-runtime')
    Assert-Sg (@(Get-SgProjectCatalog $edgeConfig).Count -eq 0) 'Zero-project catalogue was not empty.'
    Write-Package (Join-Path $edgeConfig.Workspace 'only\site') 'vite'
    $one = @(Get-SgProjectCatalog $edgeConfig -ForceRefresh)
    Assert-Sg ($one.Count -eq 1 -and $one[0].Name -eq 'only/site') 'One-project catalogue was not stable.'

    $deep = Join-Path $edgeConfig.Workspace 'nested\one\two\three\four\five\site'
    Write-Package $deep 'vite'
    $deepRefresh = @(Get-SgProjectCatalog $edgeConfig -ForceRefresh)
    Assert-Sg (@($deepRefresh.path) -contains $deep) 'A supported project below the former scan-depth limit was not discovered.'

    $cold = @(Get-SgProjectCatalog $config)
    Assert-Sg ($cold.Count -eq 2) 'Cold discovery did not return the two runnable surfaces.'
    Assert-Sg ((@($cold.Name) -contains 'alpha/site') -and (@($cold.Name) -contains 'beta/site')) 'Display names are not explicit workspace-relative paths.'
    Assert-Sg (-not (@($cold.Name) -contains 'ignored')) 'A package.json without scripts.dev was treated as runnable.'
    Assert-Sg (Test-Path -LiteralPath $config.ProjectIndexPath -PathType Leaf) 'Persistent project index was not written.'

    $gamma = Join-Path $workspace 'gamma\site'
    Write-Package $gamma 'vite'
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 2) 'The intra-process cache was not reused.'
    Assert-Sg (@(Get-SgProjectCatalogForDisplay $config).Count -eq 2) 'A displayed catalogue bypassed the prepared cache snapshot.'
    Assert-Sg (@(Get-SgProjectCatalog $config -ForceRefresh).Count -eq 3) 'An explicit catalogue refresh did not converge after a project was added.'

    Remove-Module ShipGlows.DevServer -Force
    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 3) 'The converged persistent cache was not reused after a fresh module import.'
    $forced = @(Get-SgProjectCatalog $config -ForceRefresh)
    Assert-Sg ($forced.Count -eq 3) 'Force refresh did not rebuild discovery.'

    $identities = @($forced | ForEach-Object { $_.Id })
    Assert-Sg (($identities | Sort-Object -Unique).Count -eq 3) 'Runnable identities are not unique.'
    $choiceMap = New-SgProjectChoiceMap $forced
    foreach ($item in $forced) {
        Assert-Sg ($choiceMap[$item.Name] -eq $item.Id) "Choice '$($item.Name)' did not resolve to its exact identity."
    }
    $caseVariant = [pscustomobject]@{ path = ($alpha.ToUpperInvariant() + '\') }
    Assert-Sg ((Get-SgRunnableIdentity $caseVariant) -eq (Get-SgRunnableIdentity ($forced | Where-Object Name -eq 'alpha/site'))) 'Case or trailing slash changed runnable identity.'

    $registered = $forced | Where-Object Name -eq 'alpha/site'
    [pscustomobject]@{schemaVersion=1;projects=@([pscustomobject]@{
        name='legacy-root';path=(Join-Path $workspace 'alpha');rootPath=(Join-Path $workspace 'alpha');launchPath=$registered.path;kind='astro';
        port=3010;status='running';pid=0;startTimeUtc=$null;executablePath=$null;commandSignature=$null;logPath='out';errorLogPath='err';lastError=$null
    })} | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $config.RegistryPath -Encoding UTF8
    $merged = @(Get-SgProjectCatalog $config)
    $alphaItems = @($merged | Where-Object Id -eq $registered.Id)
    Assert-Sg ($alphaItems.Count -eq 1 -and $alphaItems[0].IsRegistered -and $alphaItems[0].status -eq 'stopped' -and $alphaItems[0].port -eq 3010) 'Registry/discovery root-launch dedupe or registry authority failed.'

    $staleRegistry = Get-Content -LiteralPath $config.RegistryPath -Raw | ConvertFrom-Json
    $staleRegistry.projects[0].status = 'running'
    $staleRegistry.projects[0].pid = 2147483000
    $staleRegistry.projects[0].startTimeUtc = '2026-01-01T00:00:00Z'
    $staleRegistry.projects[0].executablePath = 'C:\missing.exe'
    $staleRegistry | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $config.RegistryPath -Encoding UTF8
    $unreconciled = @(Get-SgProjectCatalog $config -SkipProcessReconciliation | Where-Object Id -eq $registered.Id)[0]
    Assert-Sg ($unreconciled.status -eq 'running') 'Status-reconciliation fixture did not preserve its stale registry state.'
    $reconciledDisplay = @(Get-SgProjectCatalogForDisplay $config | Where-Object Id -eq $registered.Id)[0]
    Assert-Sg ($reconciledDisplay.status -eq 'stopped') 'A displayed catalogue published a stale process status.'

    Set-Content -LiteralPath $config.ProjectIndexPath -Value '{broken' -Encoding UTF8
    Remove-Module ShipGlows.DevServer -Force
    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 3) 'Corrupt persistent cache was not ignored and rebuilt.'

    $index = Get-Content -LiteralPath $config.ProjectIndexPath -Raw | ConvertFrom-Json
    $index.generatedAt = '24/08/2026 12:00:00'
    $index | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $config.ProjectIndexPath -Encoding UTF8
    Remove-Module ShipGlows.DevServer -Force
    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 3) 'A locale-shaped timestamp was not rejected and self-repaired.'
    $originalCulture = [Threading.Thread]::CurrentThread.CurrentCulture
    $originalUiCulture = [Threading.Thread]::CurrentThread.CurrentUICulture
    try {
        $french = [Globalization.CultureInfo]::GetCultureInfo('fr-FR')
        [Threading.Thread]::CurrentThread.CurrentCulture = $french
        [Threading.Thread]::CurrentThread.CurrentUICulture = $french
        Assert-Sg (@(Get-SgProjectCatalog $config -ForceRefresh).Count -eq 3) 'fr-FR project index round-trip failed.'
        $frenchIndex = Get-Content -LiteralPath $config.ProjectIndexPath -Raw | ConvertFrom-Json
        $frenchValid = & (Get-Module ShipGlows.DevServer) { param($Config,$Index) Test-SgProjectIndex $Config $Index } $config $frenchIndex
        Assert-Sg $frenchValid 'fr-FR index could not validate its invariant timestamp.'
    } finally {
        [Threading.Thread]::CurrentThread.CurrentCulture = $originalCulture
        [Threading.Thread]::CurrentThread.CurrentUICulture = $originalUiCulture
    }

    $index = Get-Content -LiteralPath $config.ProjectIndexPath -Raw | ConvertFrom-Json
    $index.workspace = Join-Path $fixture 'different-workspace'
    $index | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $config.ProjectIndexPath -Encoding UTF8
    Remove-Item -LiteralPath $gamma -Recurse -Force
    Remove-Module ShipGlows.DevServer -Force
    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 2) 'A cache for a different workspace was accepted.'

    $index = Get-Content -LiteralPath $config.ProjectIndexPath -Raw | ConvertFrom-Json
    $index.scannerVersion = 'old'
    $index | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $config.ProjectIndexPath -Encoding UTF8
    Write-Package $gamma 'vite'
    Remove-Module ShipGlows.DevServer -Force
    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 3) 'A cache from another scanner version was accepted.'

    $index = Get-Content -LiteralPath $config.ProjectIndexPath -Raw | ConvertFrom-Json
    $index.schemaVersion = 999
    $index | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $config.ProjectIndexPath -Encoding UTF8
    Remove-Item -LiteralPath $gamma -Recurse -Force
    Remove-Module ShipGlows.DevServer -Force
    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 2) 'Wrong cache schema was accepted.'

    $index = Get-Content -LiteralPath $config.ProjectIndexPath -Raw | ConvertFrom-Json
    $index.generatedAt = (Get-Date).ToUniversalTime().AddMinutes(-5).ToString('o')
    $index | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $config.ProjectIndexPath -Encoding UTF8
    Write-Package $gamma 'vite'
    Remove-Module ShipGlows.DevServer -Force
    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg (@(Get-SgProjectCatalog $config).Count -eq 2) 'A structurally valid stale cache did not return immediately.'
    Assert-Sg (Test-SgProjectCatalogRefreshRequired $config) 'A stale cache did not request background refresh.'
    Assert-Sg (@(Get-SgProjectCatalog $config -ForceRefresh).Count -eq 3) 'Explicit refresh did not discover the new project.'
    Assert-Sg (-not (Test-SgProjectCatalogRefreshRequired $config)) 'A freshly rebuilt cache still requested refresh.'

    $betaItem = @(Get-SgProjectCatalog $config) | Where-Object Name -eq 'beta/site'
    Remove-Item -LiteralPath $beta -Recurse -Force
    $movedRejected = $false
    try { Resolve-SgProjectCatalogEntry $config $betaItem.Id | Out-Null } catch { $movedRejected = $true }
    Assert-Sg $movedRejected 'A deleted cached surface was accepted for an action.'

    Get-SgProjectCatalog $config -ForceRefresh | Out-Null
    Assert-Sg (Test-Path -LiteralPath $config.ProjectIndexPath) 'Force refresh did not recreate the index.'
    $registerTarget = Join-Path $workspace 'register-me'
    Write-Package $registerTarget 'vite'
    Register-SgProject $config $registerTarget | Out-Null
    Assert-Sg ((Test-Path -LiteralPath $config.ProjectIndexPath) -and (Test-SgProjectCatalogRefreshRequired $config)) 'Register did not retain and mark the persistent catalogue stale.'
    Get-SgProjectCatalog $config | Out-Null
    Unregister-SgProject $config $registerTarget
    Assert-Sg ((Test-Path -LiteralPath $config.ProjectIndexPath) -and (Test-SgProjectCatalogRefreshRequired $config)) 'Unregister did not retain and mark the persistent catalogue stale.'

    $jobs = @(1..2 | ForEach-Object {
        Start-Job -ScriptBlock {
            param($ModulePath,$Config)
            Import-Module $ModulePath -Force -DisableNameChecking
            Get-SgProjectCatalog $Config -ForceRefresh | Out-Null
        } -ArgumentList $modulePath,$config
    })
    $jobs | Wait-Job | Out-Null
    $failedJobs = @($jobs | Where-Object State -ne 'Completed')
    $jobs | Receive-Job | Out-Null
    $jobs | Remove-Job -Force
    Assert-Sg ($failedJobs.Count -eq 0) 'Concurrent project-index writers failed.'
    $concurrentIndex = Get-Content -LiteralPath $config.ProjectIndexPath -Raw | ConvertFrom-Json
    Assert-Sg ($concurrentIndex.schemaVersion -eq 1 -and $null -ne $concurrentIndex.projects) 'Concurrent cache writes left an invalid index.'

    Write-Host 'Windows DevServer project catalog: OK'

    if ($BenchmarkWorkspace) {
        $benchmarkRuntime = Join-Path $fixture 'benchmark-runtime'
        $benchmarkConfig = New-TestConfig $BenchmarkWorkspace $benchmarkRuntime
        $coldTimes = @()
        1..5 | ForEach-Object {
            $stopwatch = [Diagnostics.Stopwatch]::StartNew()
            Get-SgProjectCatalog $benchmarkConfig -ForceRefresh | Out-Null
            $stopwatch.Stop(); $coldTimes += $stopwatch.Elapsed.TotalMilliseconds
        }
        $warmTimes = @()
        1..5 | ForEach-Object {
            $stopwatch = [Diagnostics.Stopwatch]::StartNew()
            Get-SgProjectCatalog $benchmarkConfig | Out-Null
            $stopwatch.Stop(); $warmTimes += $stopwatch.Elapsed.TotalMilliseconds
        }
        $coldMedian = @($coldTimes | Sort-Object)[2]
        $warmMedian = @($warmTimes | Sort-Object)[2]
        $benchmarkIndex = Get-Content -LiteralPath $benchmarkConfig.ProjectIndexPath -Raw | ConvertFrom-Json
        $benchmarkIndex.generatedAt = (Get-Date).ToUniversalTime().AddHours(-1).ToString('o')
        $benchmarkIndex | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $benchmarkConfig.ProjectIndexPath -Encoding UTF8
        Remove-Module ShipGlows.DevServer -Force
        Import-Module $modulePath -Force -DisableNameChecking
        $staleTimes = @()
        1..5 | ForEach-Object {
            $stopwatch = [Diagnostics.Stopwatch]::StartNew()
            Get-SgProjectCatalog $benchmarkConfig | Out-Null
            $stopwatch.Stop(); $staleTimes += $stopwatch.Elapsed.TotalMilliseconds
        }
        $staleMedian = @($staleTimes | Sort-Object)[2]
        Write-Host ('BENCHMARK cold_ms={0} warm_ms={1} stale_ms={2} cold_runs={3} warm_runs={4} stale_runs={5}' -f [math]::Round($coldMedian,2),[math]::Round($warmMedian,2),[math]::Round($staleMedian,2),(@($coldTimes | ForEach-Object {[math]::Round($_,2)}) -join ','),(@($warmTimes | ForEach-Object {[math]::Round($_,2)}) -join ','),(@($staleTimes | ForEach-Object {[math]::Round($_,2)}) -join ','))
        Assert-Sg ($coldMedian -lt 2000) 'Background cold catalogue median is at or above 2 seconds.'
        Assert-Sg ($warmMedian -lt 200) 'Warm catalogue median is at or above 200 ms.'
        Assert-Sg ($staleMedian -lt 200) 'Stale catalogue median is at or above 200 ms.'
    }
} finally {
    Get-Job -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Job*' } | Remove-Job -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
