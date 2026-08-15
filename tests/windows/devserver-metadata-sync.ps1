$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-metadata-sync-{0}" -f [guid]::NewGuid().ToString('N'))
$runtime = Join-Path $fixture 'runtime'
try {
    $project = Join-Path $fixture 'communityglows'; $site = Join-Path $project 'site'
    New-Item -ItemType Directory -Path $runtime,$site -Force | Out-Null
    Import-Module $modulePath -Force -DisableNameChecking
    $config = [pscustomobject]@{RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock')}
    [pscustomobject]@{schemaVersion=1;projects=@([pscustomobject]@{name='site';path=$site;launchPath=$site;kind='astro';port=3005;status='stopped';pid=0;logPath='out'})} | ConvertTo-Json -Depth 10 | Set-Content $config.RegistryPath -Encoding UTF8
    $candidate = [pscustomobject]@{name='communityglows-site';path=$site;rootPath=$project;launchPath=$site;kind='astro'}
    Sync-SgDiscoveredProjectMetadata $config $candidate | Out-Null
    Sync-SgDiscoveredProjectMetadata $config $candidate | Out-Null
    $state = Read-SgRegistry $config
    if ($state.projects.Count -ne 1 -or $state.projects[0].name -ne 'communityglows-site' -or $state.projects[0].rootPath -ne $project -or $state.projects[0].port -ne 3005 -or $state.projects[0].logPath -ne 'out') { throw 'Metadata synchronization was not idempotent or changed runtime state.' }
    Write-Host 'Windows DevServer metadata synchronization: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
