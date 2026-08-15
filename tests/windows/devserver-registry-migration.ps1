$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-registry-migration-{0}" -f [guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'gocharbon'; $site = Join-Path $project 'site'; $runtime = Join-Path $fixture 'runtime'
try {
    New-Item -ItemType Directory -Path $site,$runtime -Force | Out-Null
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer
    $config = [pscustomobject]@{RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock')}
    [pscustomobject]@{schemaVersion=1;projects=@(
        [pscustomobject]@{name='gocharbon';path=$project;launchPath=$site;kind='astro';port=3002;status='running';pid=77;startTimeUtc='stamp';executablePath='mock.exe';commandSignature='sig';logPath='out';errorLogPath='err';lastError=$null},
        [pscustomobject]@{name='site';path=$site;launchPath=$site;kind='astro';port=0;status='stopped';pid=0;startTimeUtc=$null;executablePath=$null;commandSignature=$null;logPath=$null;errorLogPath=$null;lastError=$null}
    )} | ConvertTo-Json -Depth 10 | Set-Content $config.RegistryPath -Encoding UTF8
    & $module { param($Config) function Test-SgProcessIdentity([object]$Entry) { [int]$Entry.pid -eq 77 }; Reconcile-SgRegistry $Config } $config | Out-Null
    $state = Read-SgRegistry $config
    if ($state.projects.Count -ne 1) { throw 'Duplicate historical root/surface entries were not merged.' }
    $entry = $state.projects[0]
    if ($entry.path -ne $site -or $entry.rootPath -ne $project -or $entry.port -ne 3002 -or $entry.pid -ne 77 -or $entry.logPath -ne 'out') { throw 'Live registry data was not preserved during migration.' }
    Write-Host 'Windows DevServer registry migration: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
