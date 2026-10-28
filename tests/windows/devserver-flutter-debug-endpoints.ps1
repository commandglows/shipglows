$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# The supervisor turns the app.debugPort / app.devTools / app.dtd events of flutter run --machine into state.json
# endpoints, and s status shows them with the live flutter.*.log files of the launch directory.
$supervisorPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.FlutterSupervisor.ps1'))
$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$fixturePath = Join-Path $PSScriptRoot 'fixtures\flutter-machine-debug-endpoints.stdout.txt'
. $supervisorPath -TestMode

$vmService = 'ws://127.0.0.1:3196/FAKEvmToken0=/ws'
$devTools = 'http://127.0.0.1:9100/?uri=ws://127.0.0.1:3196/FAKEvmToken0=/ws'
$dtd = 'ws://127.0.0.1:52011/FAKEdtdToken='

$state = New-SgFlutterProtocolState
foreach ($line in [IO.File]::ReadAllLines($fixturePath)) { Update-SgFlutterProtocolState $state $line }
if ($state.Status -ne 'running' -or $state.AppId -ne 'fixture-app-1') { throw "Fixture did not reach the running state: $($state.Status)." }
if ($state.VmServiceUri -cne $vmService) { throw "VM service URI was not captured from app.debugPort (another app's or a remote URI won): $($state.VmServiceUri)" }
if ($state.DevToolsUri -cne $devTools) { throw "DevTools URI must keep the last loopback app.devTools URI: $($state.DevToolsUri)" }
if ($state.DtdUri -cne $dtd) { throw "DTD URI was not captured from app.dtd: $($state.DtdUri)" }
$persisted = $state | ConvertTo-Json -Depth 8 -Compress | ConvertFrom-Json
if ($persisted.VmServiceUri -cne $vmService -or $persisted.DevToolsUri -cne $devTools -or $persisted.DtdUri -cne $dtd) { throw 'Debug endpoints do not survive the state.json round trip.' }

$stopped = New-SgFlutterProtocolState
foreach ($line in [IO.File]::ReadAllLines($fixturePath)) { Update-SgFlutterProtocolState $stopped $line }
Update-SgFlutterProtocolState $stopped '[{"event":"app.stop","params":{"appId":"fixture-app-1"}}]'
if ($stopped.VmServiceUri -or $stopped.DevToolsUri -or $stopped.DtdUri) { throw 'app.stop must clear the debug endpoints.' }

Import-Module $modulePath -Force -DisableNameChecking
try {
    $module = Get-Module ShipGlows.DevServer
    $root = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-endpoints-{0}" -f [guid]::NewGuid().ToString('N'))
    $launch = Join-Path $root 'flutter-launch\0123456789abcdef0123456789abcdef'; $durable = Join-Path $root 'logs\app\windows\run'
    New-Item -ItemType Directory -Path $launch, $durable -Force | Out-Null
    try {
        [IO.File]::WriteAllText((Join-Path $launch 'flutter.stdout.log'), [IO.File]::ReadAllText($fixturePath))
        [IO.File]::WriteAllText((Join-Path $launch 'flutter.stderr.log'), '')
        $durableOut = Join-Path $durable 'stdout.log'; $durableErr = Join-Path $durable 'stderr.log'
        [IO.File]::WriteAllText($durableOut, ''); [IO.File]::WriteAllText($durableErr, '')
        $session = [pscustomobject]@{ target='windows'; status='running'; port=0; portRole='none'; pid=0; startTimeUtc=$null; startedAtUtc=$null; stoppedAtUtc=$null; lastEvent=$null; lastError=$null; flutterDeviceId='windows'; flutterMode='profile'; flutterLaunchDirectory=$launch; logPath=$durableOut; errorLogPath=$durableErr }

        & $module {
            param($Session, $State, $Remote)
            Set-SgFlutterDebugEndpoints $Session $State
            $rejected = [pscustomobject]@{}; Set-SgFlutterDebugEndpoints $rejected $Remote
            if ($rejected.vmServiceUri -or $rejected.devToolsUri -or $rejected.dtdUri) { throw 'Registry endpoints must refuse non-loopback URIs.' }
        } $session $persisted ([pscustomobject]@{ VmServiceUri='ws://10.0.0.5:3196/x=/ws'; DevToolsUri='https://devtools.example.com/'; DtdUri='ws://evil.example/' })
        if ($session.vmServiceUri -cne $vmService -or $session.devToolsUri -cne $devTools -or $session.dtdUri -cne $dtd) { throw 'Supervisor endpoints were not mirrored into the registry session.' }

        $logs = Get-SgSessionLogFiles $session
        if (-not $logs.Live -or $logs.Directory -ne $launch -or $logs.Out -ne (Join-Path $launch 'flutter.stdout.log') -or $logs.Err -ne (Join-Path $launch 'flutter.stderr.log')) { throw 'Live Flutter logs must resolve to the supervisor flutter.*.log files.' }

        $lines = @(Format-SgSessionStatusLines ([pscustomobject]@{ name='app'; kind='flutter-web'; sessions=@($session) }))
        Write-Host 'Fixture s status target lines:'; foreach ($line in $lines) { Write-Host "  $line" }
        if ($lines[0] -notlike "*| logs $launch") { throw "Status must announce the live launch logs: $($lines[0])" }
        if (@($lines | Where-Object { $_ -ceq "  VM service  $vmService" }).Count -ne 1) { throw 'Status is missing the VM service line.' }
        if (@($lines | Where-Object { $_ -ceq "  DevTools    $devTools" }).Count -ne 1) { throw 'Status is missing the DevTools line.' }

        & $module {
            param($Session, $DurableOut)
            Copy-SgFlutterDiagnostics $Session $Session.logPath $Session.errorLogPath
            Copy-SgFlutterDiagnostics $Session $Session.logPath $Session.errorLogPath
            $copies = @([IO.File]::ReadAllLines($DurableOut) | Where-Object { $_ -like '*"event":"app.started"*' }).Count
            if ($copies -ne 1) { throw "The post-mortem copy must happen once per launch, found $copies." }
        } $session $durableOut

        Remove-Item -LiteralPath $launch -Recurse -Force
        & $module { param($Session) $Session.status = 'stopped'; Set-SgFlutterDebugEndpoints $Session $null } $session
        $after = Get-SgSessionLogFiles $session
        if ($after.Live -or $after.Directory -ne $durable -or $after.Out -ne $durableOut) { throw 'Once the launch directory is gone, logs fall back to the durable post-mortem copy.' }
        $stoppedLines = @(Format-SgSessionStatusLines ([pscustomobject]@{ name='app'; kind='flutter-web'; sessions=@($session) }))
        if (@($stoppedLines | Where-Object { $_ -like '*VM service*' -or $_ -like '*DevTools*' }).Count -ne 0) { throw 'A stopped target must not show debug endpoints.' }
    } finally {
        Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
    }
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
}
Write-Host 'Flutter debug endpoint tests passed.'
