$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$previousManagedPowerShell=$env:SHIPGLOWS_MANAGED_PWSH
$env:SHIPGLOWS_MANAGED_PWSH=(Get-Process -Id $PID).Path
$modulePath=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../cli/windows/ShipGlows.DevServer.psm1'))
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('sg-backend-'+[guid]::NewGuid().ToString('N'))
$surface=Join-Path $fixture 'surface'
$runtime=Join-Path $fixture 'runtime'
$external=$null
function Assert-Throws([scriptblock]$Action,[string]$Pattern) {
    try { & $Action; throw 'Expected rejection was not raised.' } catch { if ($_.Exception.Message -notmatch $Pattern) { throw } }
}
function Write-Manifest($Manifest) { $Manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $surface '.shipglows.backend.json') -Encoding utf8 }
function Get-FreeTestPort {
    $listener=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,0)
    $listener.Start(); $port=$listener.LocalEndpoint.Port; $listener.Stop(); return $port
}
try {
    New-Item -ItemType Directory -Path $surface,$runtime,(Join-Path $runtime 'logs') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $surface 'package.json') -Value '{"devDependencies":{"vite":"latest"},"scripts":{"dev":"vite"}}'
    Import-Module $modulePath -Force -DisableNameChecking
    $module=Get-Module ShipGlows.DevServer
    $config=[pscustomobject]@{Workspace=$fixture;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock');LogDirectory=(Join-Path $runtime 'logs');PortStart=34000;PortEnd=34999}
    # Real app processes and readiness; avoid installing a product framework in the fixture.
    & $module {
        function script:Invoke-SgDependencySetup { }
        function script:Get-SgLaunchSpec {
            param($ProjectPath,$Kind,$Port)
            [pscustomobject]@{FilePath=(Get-SgCommandPath @('python.exe'));Arguments=@('-m','http.server',[string]$Port,'--bind','127.0.0.1');Signature='http.server';Interactive=$false}
        }
    }
    Assert-Throws { Start-SgProject $config $surface } 'Backend declaration required'
    if (Test-Path -LiteralPath $config.RegistryPath) { throw 'Absent backend mutated registry before preflight.' }
    Set-Content -LiteralPath (Join-Path $surface '.shipglows.backend.json') -Value '{broken'
    Assert-Throws { Start-SgProject $config $surface } 'not valid JSON'
    $none=[ordered]@{schemaVersion='shipglows.backend.v1';provider='none';mode='none';reason='Static isolated test fixture without API or persistence.';command=$null;dependencies=@();readiness=$null}
    foreach ($badJson in @(
        '{"schemaVersion":"shipglows.backend.v1","mode":"none","mode":"local"}',
        '{"schemaVersion":"shipglows.backend.v1","provider":"none","mode":"none","reason":"Justified test fixture","command":null,"dependencies":[],"readiness":null,"extra":true}'
    )) {
        Set-Content -LiteralPath (Join-Path $surface '.shipglows.backend.json') -Value $badJson
        Assert-Throws { Start-SgProject $config $surface } 'duplicate JSON|fields are invalid'
    }
    Write-Manifest $none
    $appPort=Get-FreeTestPort
    $running=Start-SgProject $config $surface $appPort
    if ($running.status -ne 'running' -or $running.backend.status -ne 'not-required') { throw 'Explicit no-backend launch failed.' }
    $before=[IO.File]::ReadAllText($config.RegistryPath)
    $none.reason=''
    Write-Manifest $none
    Assert-Throws { Start-SgProject $config $surface -Restart } 'meaningful reason'
    if ([IO.File]::ReadAllText($config.RegistryPath) -cne $before) { throw 'Invalid restart changed existing registry.' }
    if (-not (& $module {param($Entry) Test-SgProcessIdentity $Entry} $running)) { throw 'Invalid restart stopped existing app.' }
    $none.reason='Static isolated test fixture without API or persistence.'
    $none.typo=$true; Write-Manifest $none
    Assert-Throws { Start-SgProject $config $surface } 'fields are invalid'
    $none.Remove('typo')

    $backendPort=Get-FreeTestPort
    $remote=[ordered]@{schemaVersion='shipglows.backend.v1';provider='http';mode='remote';reason=$null;command=$null;dependencies=@();readiness=@{url="http://127.0.0.1:$backendPort/";statusCode=200;timeoutSeconds=1}}
    $remote.command=@{executable='python.exe';arguments=@();authorized=$true}; Write-Manifest $remote
    Assert-Throws { Start-SgProject $config $surface -Restart } 'Remote backend commands are forbidden'
    $remote.command=$null
    Write-Manifest $remote
    Assert-Throws { Start-SgProject $config $surface -Restart } 'readiness failed'
    if ([IO.File]::ReadAllText($config.RegistryPath) -cne $before) { throw 'Unavailable backend changed existing registry.' }
    $external=Start-Process -FilePath (Get-Command python.exe).Source -ArgumentList @('-m','http.server',[string]$backendPort,'--bind','127.0.0.1') -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $fixture 'remote.out') -RedirectStandardError (Join-Path $fixture 'remote.err')
    $remote.readiness.timeoutSeconds=15; Write-Manifest $remote
    $running=Start-SgProject $config $surface -Restart
    if ($running.status -ne 'running' -or $running.backend.mode -ne 'remote' -or $running.backend.process) { throw 'Remote check launched or recorded an owned backend process.' }
    $reused=Start-SgProject $config $surface
    if ($reused.pid -ne $running.pid) { throw 'Verified remote session was not reused.' }
    [void](Stop-SgProject $config $surface)
    if ($external.HasExited) { throw 'Stopping app terminated external backend.' }
    $external.Kill($true); $external.WaitForExit(); $external.Dispose(); $external=$null

    $local=[ordered]@{schemaVersion='shipglows.backend.v1';provider='custom';mode='local';reason=$null;command=@{executable='python.exe';arguments=@('-m','http.server',[string]$backendPort,'--bind','127.0.0.1');authorized=$true};dependencies=@('package.json');readiness=@{url="http://127.0.0.1:$backendPort/";statusCode=200;timeoutSeconds=15}}
    Write-Manifest $local
    foreach ($mutation in @(
        { $local.command.authorized=$false },
        { $local.dependencies=@('../outside.json') },
        { $local.readiness.url='https://example.invalid/' },
        { $local.command.executable='missing-backend-fixture.exe' }
    )) {
        & $mutation; Write-Manifest $local
        Assert-Throws { & $module {param($Path) Read-SgBackendManifest $Path} $surface } 'authorized executable|outside the project|loopback URL|unavailable'
        $local.command.authorized=$true; $local.dependencies=@('package.json'); $local.readiness.url="http://127.0.0.1:$backendPort/"; $local.command.executable='python.exe'
    }
    Write-Manifest $local
    $running=Start-SgProject $config $surface
    if ($running.status -ne 'running' -or -not $running.backend.process.jobName) { throw 'Local supervised backend did not become ready.' }
    $reused=Start-SgProject $config $surface
    if ($reused.pid -ne $running.pid -or $reused.backend.process.pid -ne $running.backend.process.pid) { throw 'Local backend reuse created a second process.' }
    $planBefore=& $module {param($Path) Read-SgBackendManifest $Path} $surface
    Add-Content -LiteralPath (Join-Path $surface 'package.json') -Value ' '
    $planAfter=& $module {param($Path) Read-SgBackendManifest $Path} $surface
    if ($planBefore.Fingerprint -eq $planAfter.Fingerprint) { throw 'Dependency mutation did not invalidate backend fingerprint.' }
    Assert-Throws { Start-SgProject $config $surface -Restart } 'port is occupied'
    if (-not (& $module {param($Entry) Test-SgProcessIdentity $Entry} $running)) { throw 'Changed backend destroyed existing session.' }

    # Kill only the child HTTP server, leaving its supervisor to enforce the invariant.
    $children=@(Get-NetTCPConnection -State Listen -LocalPort $backendPort | Select-Object -ExpandProperty OwningProcess -Unique)
    if ($children.Count -ne 1) { throw 'Could not identify unique backend fixture child.' }
    Stop-Process -Id $children[0] -Force
    $deadline=[DateTime]::UtcNow.AddSeconds(20)
    do { Start-Sleep -Milliseconds 250; $stored=@((Read-SgRegistry $config).projects)[0] } while ($stored.status -ne 'error' -and [DateTime]::UtcNow -lt $deadline)
    if ($stored.status -ne 'error' -or $stored.backend.status -ne 'error' -or (& $module {param($Entry) Test-SgProcessIdentity $Entry} $running)) { throw 'Backend loss did not stop the app and persist an error.' }
    Write-Manifest $local
    $running=Start-SgProject $config $surface
    & $module { param($Backend) Stop-SgBackend $Backend } $running.backend
    foreach ($iteration in 1..2) {
        $reconciled=@((Reconcile-SgRegistry $config).projects)[0]
        if ($reconciled.status -ne 'error' -or $reconciled.backend.status -ne 'error') { throw 'Lost backend supervisor was incorrectly reconciled to running.' }
    }
    [void](Stop-SgProject $config $surface)
    if (-not (Test-SgPortAvailable $backendPort)) { throw 'Local backend listener survived explicit stop.' }
    Assert-Throws {
        & $module {
            param($Config,$Surface)
            function Start-SgProjectCore { throw 'fixture application configuration failed' }
            Start-SgProject $Config $Surface
        } $config $surface
    } 'fixture application configuration failed'
    if (-not (Test-SgPortAvailable $backendPort)) { throw 'Backend survived application preflight failure.' }
    Write-Host 'Backend manifest, preservation, remote verification, local lifecycle and supervision: OK'
} finally {
    if ($external) { if (-not $external.HasExited) { $external.Kill($true) }; $external.Dispose() }
    if (Get-Variable config -ErrorAction SilentlyContinue) { try { [void](Stop-SgProject $config $surface) } catch { Write-Warning $_ } }
    $env:SHIPGLOWS_MANAGED_PWSH=$previousManagedPowerShell
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if ([IO.Path]::GetFullPath($fixture).StartsWith([IO.Path]::GetTempPath(),[StringComparison]::OrdinalIgnoreCase) -and (Split-Path $fixture -Leaf) -like 'sg-backend-*') { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
