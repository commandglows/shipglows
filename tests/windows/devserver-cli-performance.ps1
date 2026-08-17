param([int]$MaximumHelpMedianMs = 650)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$entrypoint = Join-Path $root 'cli\windows\shipglows-devserver.ps1'
$refresher = Join-Path $root 'cli\windows\ShipGlows.ProjectCatalogRefresh.ps1'
$source = [IO.File]::ReadAllText($entrypoint)

if (-not (Test-Path -LiteralPath $refresher -PathType Leaf)) { throw 'The detached project-catalog refresher is missing.' }

if ($source -notmatch [regex]::Escape('if (Test-SgImmediateAction $Action $ShortcutPath)')) { throw 'The CLI immediate-action fast path is missing.' }
if ($source -notmatch [regex]::Escape('Import-SgAuthenticationModule')) { throw 'The authentication module is not lazy-loaded.' }
if ($source -match '(?m)^Import-Module \$mobileModule -Force -DisableNameChecking\s*$') { throw 'The unused mobile module is still eagerly loaded.' }
foreach ($required in @('function Start-SgBackgroundCatalogRefresh','Test-SgProjectCatalogRefreshRequired $config','[Diagnostics.Process]::Start($startInfo)','Clear-SgProjectCatalogMemoryCache $config','function Complete-SgBackgroundCatalogRefresh')) {
    if ($source -notmatch [regex]::Escape($required)) { throw "The non-blocking catalogue refresh contract is missing: $required" }
}

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

} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}

$times = @()
1..7 | ForEach-Object {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entrypoint h *> $null
    if ($LASTEXITCODE -ne 0) { throw 'The help fast path failed.' }
    $watch.Stop()
    $times += $watch.Elapsed.TotalMilliseconds
}
$median = @($times | Sort-Object)[3]
if ($median -ge $MaximumHelpMedianMs) { throw "Windows CLI help median $([math]::Round($median,1)) ms exceeds $MaximumHelpMedianMs ms." }
Write-Host ('Windows CLI performance regression: OK help_median_ms={0}' -f [math]::Round($median,1))
