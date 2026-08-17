$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-start-state-{0}" -f [guid]::NewGuid().ToString('N'))
$surface = Join-Path $fixture 'site'; $runtime = Join-Path $fixture 'runtime'; $logs = Join-Path $runtime 'logs'
try {
    New-Item -ItemType Directory -Path $surface,$runtime,$logs -Force | Out-Null
    Set-Content (Join-Path $surface 'package.json') '{"devDependencies":{"vite":"latest"},"scripts":{"dev":"vite"}}' -Encoding UTF8
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer
    $config = [pscustomobject]@{Workspace=$fixture;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock');LogDirectory=$logs;PortStart=32200;PortEnd=32209}
    $result = & $module {
        param($Config,$Surface)
        function Test-SgPortAvailable { $true }
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { [pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='mock-signature';Interactive=$false} }
        function Start-Process { [pscustomobject]@{Id=77} }
        function Get-SgProcessSnapshot { [pscustomobject]@{Pid=77;StartTimeUtc='2026-08-15T00:00:00Z';ExecutablePath='mock.exe';CommandLine='mock-signature'} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 77 }
        function Wait-SgProjectReady { [pscustomobject]@{ Ready=$true; AppId=$null; Error=$null } }
        Start-SgProject $Config $Surface
    } $config $surface
    if ($result.status -ne 'running' -or $result.port -lt 32200) { throw 'Successful launch state was not returned.' }
    $stored = (Read-SgRegistry $config).projects | Select-Object -First 1
    if ($stored.status -ne 'running' -or $stored.pid -ne 77 -or $stored.reservationToken) { throw 'Successful launch state was not committed atomically.' }
    $environment = Get-SgProjectEnvironment $surface
    if (-not $environment -or $environment.Port -ne $result.port) { throw 'Successful launch did not persist its canonical surface URL.' }

    $flutterSurface = Join-Path $fixture 'flutter-app'
    New-Item -ItemType Directory -Path $flutterSurface,(Join-Path $flutterSurface 'web') -Force | Out-Null
    Set-Content (Join-Path $flutterSurface 'pubspec.yaml') "name: test_app`ndependencies:`n  flutter:`n    sdk: flutter`nflutter:`n  uses-material-design: true" -Encoding UTF8
    $failed = & $module {
        param($Config,$Surface)
        $script:stopped = @()
        function Test-SgPortAvailable { $true }
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { [pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='mock-signature';Interactive=$false} }
        function Start-Process { [pscustomobject]@{Id=88} }
        function Get-SgProcessSnapshot { [pscustomobject]@{Pid=88;StartTimeUtc='2026-08-15T00:00:01Z';ExecutablePath='mock.exe';CommandLine='mock-signature'} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 88 }
        function Wait-SgFlutterSupervisorReady { [pscustomobject]@{ Ready=$false; AppId=$null; Error='Flutter application startup timed out before app.started.'; DaemonPid=0 } }
        function Stop-SgProcessTree { param($RootPid) $script:stopped += $RootPid }
        function Stop-SgOwnedFlutterBrowser { $false }
        $result = Start-SgProject $Config $Surface
        [pscustomobject]@{Result=$result;Stopped=@($script:stopped)}
    } $config $flutterSurface
    if ($failed.Result.status -ne 'error' -or $failed.Result.lastError -notmatch 'app\.started' -or $failed.Stopped.Count -ne 1 -or $failed.Stopped[0] -ne 88) { throw 'Flutter readiness timeout did not fail and clean up the managed process.' }
    $failedStored = (Read-SgRegistry $config).projects | Where-Object { $_.path -eq $flutterSurface } | Select-Object -First 1
    if ($failedStored.status -ne 'error' -or -not $failedStored.lastError) { throw 'Flutter readiness failure was not persisted as error.' }

    $astroSurface=Join-Path $fixture 'astro-site';New-Item -ItemType Directory -Path $astroSurface -Force|Out-Null
    Set-Content (Join-Path $astroSurface 'package.json') '{"dependencies":{"astro":"latest"},"scripts":{"dev":"astro dev"}}' -Encoding UTF8
    $astroRunning=& $module { param($Config,$Surface) function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='astro-signature';Interactive=$false}};function Start-Process{[pscustomobject]@{Id=99}};function Get-SgProcessSnapshot{[pscustomobject]@{Pid=99;StartTimeUtc='2026-08-17T00:00:00Z';ExecutablePath='mock.exe';CommandLine='astro-signature'}};function Test-SgProcessIdentity{param($Entry) [int]$Entry.pid-eq99};function Wait-SgProjectReady{[pscustomobject]@{Ready=$true;AppId=$null;Error=$null}};Start-SgProject $Config $Surface } $config $astroSurface
    & $module { param($Config,$Surface) Invoke-SgRegistryMutation $Config {param($data);$item=@($data.projects|Where-Object{$_.path-eq$Surface})[0];$item.status='stopped';$item.pid=0;$item.startTimeUtc=$null} | Out-Null } $config $astroSurface
    $astroFailed=& $module { param($Config,$Surface) function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='astro-signature';Interactive=$false}};function Start-Process{[pscustomobject]@{Id=100}};function Get-SgProcessSnapshot{[pscustomobject]@{Pid=100;StartTimeUtc='2026-08-17T00:00:01Z';ExecutablePath='mock.exe';CommandLine='astro-signature'}};function Test-SgProcessIdentity{param($Entry) [int]$Entry.pid-eq100};function Wait-SgProjectReady{[pscustomobject]@{Ready=$false;AppId=$null;Error='Astro readiness failed.'}};function Stop-SgProcessTree{};function Copy-SgFlutterDiagnostics{throw 'Astro touched Flutter diagnostics.'};function Stop-SgOwnedFlutterBrowser{throw 'Astro touched Flutter browser cleanup.'};function Wait-SgFlutterOwnedExtinction{throw 'Astro touched Flutter extinction.'};function Remove-SgFlutterLaunchArtifacts{throw 'Astro touched Flutter launch cleanup.'};Start-SgProject $Config $Surface } $config $astroSurface
    if($astroFailed.status-ne'error'-or$astroFailed.port-ne$astroRunning.port){throw 'Astro readiness failure did not persist error on its assigned port.'}
    $astroStored=(Read-SgRegistry $config).projects|Where-Object{$_.path-eq$astroSurface}|Select-Object -First 1
    if($astroStored.status-ne'error'-or$astroStored.pid-ne0){throw 'Astro readiness failure left the registry starting or with a stale PID.'}
    & $module { param($Config,$Surface) Invoke-SgRegistryMutation $Config {param($data);$item=@($data.projects|Where-Object{$_.path-eq$Surface})[0];$item.status='stopped';$item.pid=0;$item.startTimeUtc=$null} | Out-Null } $config $astroSurface
    $astroEarly=& $module { param($Config,$Surface) function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='astro-signature';Interactive=$false}};function Start-Process{[pscustomobject]@{Id=101}};function Get-SgProcessSnapshot{[pscustomobject]@{Pid=101;StartTimeUtc='2026-08-17T00:00:02Z';ExecutablePath='mock.exe';CommandLine='astro-signature'}};function Test-SgProcessIdentity{$false};function Copy-SgFlutterDiagnostics{throw 'Astro early exit touched Flutter diagnostics.'};Start-SgProject $Config $Surface } $config $astroSurface
    if($astroEarly.status-ne'error'-or$astroEarly.port-ne$astroRunning.port){throw 'Astro early exit did not persist error on its assigned port.'}
    Write-Host 'Windows DevServer start-state transition: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}

$flutterResult = & {
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer
    & $module {
        $log = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-machine-{0}.log" -f [guid]::NewGuid().ToString('N'))
        try {
            [IO.File]::WriteAllText($log, "[{`"event`":`"app.start`",`"params`":{`"appId`":`"app-1`"}}]`n")
            $httpOnly = Wait-SgFlutterReady $log 0
            if ($httpOnly.Ready) { throw 'app.start or HTTP availability alone must not mark Flutter running.' }
            [IO.File]::AppendAllText($log, "[{`"event`":`"app.started`",`"params`":{`"appId`":`"app-1`"}}]`n")
            $started = Wait-SgFlutterReady $log 1
            if (-not $started.Ready -or $started.AppId -ne 'app-1') { throw 'Matching app.started machine event was not accepted.' }
            [IO.File]::WriteAllText($log, "[{`"event`":`"app.start`",`"params`":{`"appId`":`"app-1`"}}]`n[{`"event`":`"app.started`",`"params`":{`"appId`":`"other`"}}]`n")
            if ((Wait-SgFlutterReady $log 0).Ready) { throw 'A mismatched app.started event must not mark Flutter running.' }
            [IO.File]::AppendAllText($log, "[{`"event`":`"app.stop`",`"params`":{`"appId`":`"app-1`",`"error`":`"boom`"}}]`n")
            $stopped = Wait-SgFlutterReady $log 0
            if ($stopped.Ready -or -not $stopped.Error) { throw 'app.stop before readiness must return a startup error.' }
        } finally { Remove-Item -LiteralPath $log -Force -ErrorAction SilentlyContinue }
    }
}
