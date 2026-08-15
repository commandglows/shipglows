$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-port-reservation-{0}" -f [guid]::NewGuid().ToString('N'))
$runtime = Join-Path $fixture 'runtime'; $one = Join-Path $fixture 'one'; $two = Join-Path $fixture 'two'
try {
    New-Item -ItemType Directory -Path $runtime,$one,$two -Force | Out-Null
    $config = [pscustomobject]@{ RuntimeDirectory=$runtime; RegistryPath=(Join-Path $runtime 'registry.json'); LockPath=(Join-Path $runtime 'registry.lock'); PortStart=32160; PortEnd=32169 }
    [pscustomobject]@{schemaVersion=1;projects=@(
        [pscustomobject]@{name='one';path=$one;launchPath=$one;kind='vite';port=0;status='stopped';pid=0},
        [pscustomobject]@{name='two';path=$two;launchPath=$two;kind='vite';port=0;status='stopped';pid=0}
    )} | ConvertTo-Json -Depth 10 | Set-Content $config.RegistryPath -Encoding UTF8
    $configJson = $config | ConvertTo-Json -Compress
    $jobScript = { param($Module,$ConfigJson,$Path) Import-Module $Module -Force -DisableNameChecking; $c=$ConfigJson|ConvertFrom-Json; (Reserve-SgProjectPort $c $Path).Port }
    $jobs = @(Start-Job $jobScript -ArgumentList $modulePath,$configJson,$one; Start-Job $jobScript -ArgumentList $modulePath,$configJson,$two)
    $ports = @($jobs | Wait-Job | Receive-Job); $jobs | Remove-Job -Force
    if ($ports.Count -ne 2 -or $ports[0] -eq $ports[1]) { throw "Concurrent reservations collided: $($ports -join ',')." }

    Import-Module $modulePath -Force -DisableNameChecking
    $collision = $false
    try { Reserve-SgProjectPort $config $one $ports[1] $true | Out-Null } catch { $collision = $_.Exception.Message -like '*occupied or reserved*' }
    if (-not $collision) { throw 'An explicit reserved-port collision did not fail.' }
    $oneEntry = (Read-SgRegistry $config).projects | Where-Object path -eq $one | Select-Object -First 1
    Release-SgProjectPort $config $one $oneEntry.reservationToken 'setup failed'
    $released = (Read-SgRegistry $config).projects | Where-Object path -eq $one | Select-Object -First 1
    if ($released.status -ne 'error' -or $released.reservationToken -or $released.port -ne $ports[0]) { throw 'Failed launch did not release its reservation while preserving the surface port.' }
    $invalidPort = $false
    try { Reserve-SgProjectPort $config $one 70000 $true | Out-Null } catch { $invalidPort = $_.Exception.Message -like 'Requested port must be*' }
    if (-not $invalidPort) { throw 'An out-of-range requested port was accepted.' }
    Write-Host 'Windows DevServer transactional port reservation: OK'
} finally {
    Get-Job -ErrorAction SilentlyContinue | Remove-Job -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
