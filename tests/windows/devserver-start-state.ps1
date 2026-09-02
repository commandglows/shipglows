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
    & $module {
        $started=[DateTimeOffset]::Parse('2026-09-02T00:00:00Z').UtcDateTime
        $silent=[pscustomobject]@{status='starting';appId='app-1';daemonPid=10;lastError=$null;progressActive=$false;lastProgressAtUtc=$null}
        $silentDecision=Get-SgFlutterStartupDecision $silent $started $started.AddSeconds(91) 90 300 600
        if(-not$silentDecision.Terminal-or$silentDecision.StartupState-ne'timed-out'){throw 'Silent Flutter startup did not reach its deterministic base timeout.'}
        $one=[pscustomobject]@{status='building';appId='app-1';daemonPid=10;lastError=$null;progressActive=$true;lastProgressAtUtc=$started.AddSeconds(80).ToString('o')}
        $oneDecision=Get-SgFlutterStartupDecision $one $started $started.AddSeconds(250) 90 300 600
        if($oneDecision.Terminal-or$oneDecision.StartupState-ne'building'){throw 'One valid Flutter progress event did not extend readiness for a slow Windows build.'}
        $jsonOne=('{"status":"building","appId":"app-1","daemonPid":10,"lastError":null,"progressActive":true,"lastProgressAtUtc":"'+$started.AddSeconds(80).ToString('o')+'"}')|ConvertFrom-Json
        $jsonDecision=Get-SgFlutterStartupDecision $jsonOne $started $started.AddSeconds(250) 90 300 600
        if($jsonDecision.Terminal-or$jsonDecision.StartupState-ne'building'){throw 'PowerShell JSON date conversion collapsed the Flutter progress lease.'}
        $many=[pscustomobject]@{status='building';appId='app-1';daemonPid=10;lastError=$null;progressActive=$true;lastProgressAtUtc=$started.AddSeconds(350).ToString('o')}
        $manyDecision=Get-SgFlutterStartupDecision $many $started $started.AddSeconds(500) 90 300 600
        if($manyDecision.Terminal-or$manyDecision.StartupState-ne'building'){throw 'Repeated Flutter progress did not rearm the bounded readiness lease.'}
        $hardDecision=Get-SgFlutterStartupDecision $many $started $started.AddSeconds(601) 90 300 600
        if(-not$hardDecision.Terminal-or$hardDecision.StartupState-ne'timed-out-with-live-progress'){throw 'Flutter progress bypassed the absolute startup ceiling.'}
        $finished=[pscustomobject]@{status='starting';appId='app-1';daemonPid=10;lastError=$null;progressActive=$false;lastProgressAtUtc=$started.AddSeconds(80).ToString('o')}
        $finishedDecision=Get-SgFlutterStartupDecision $finished $started $started.AddSeconds(391) 90 300 600
        if(-not$finishedDecision.Terminal-or$finishedDecision.StartupState-ne'timed-out'){throw 'Finished Flutter progress incorrectly remained live.'}
        $ready=[pscustomobject]@{status='running';appId='app-1';daemonPid=10;lastError=$null;progressActive=$false;lastProgressAtUtc=$null}
        $readyDecision=Get-SgFlutterStartupDecision $ready $started $started.AddSeconds(500) 90 300 600
        if(-not$readyDecision.Terminal-or-not$readyDecision.Ready-or$readyDecision.AppId-ne'app-1'){throw 'Matching app.started state was not accepted as running.'}
        $error=[pscustomobject]@{status='error';appId='app-1';daemonPid=10;lastError='Flutter failed.';progressActive=$false;lastProgressAtUtc=$null}
        $errorDecision=Get-SgFlutterStartupDecision $error $started $started.AddSeconds(1) 90 300 600
        if(-not$errorDecision.Terminal-or$errorDecision.StartupState-ne'failed'-or$errorDecision.Error-ne'Flutter failed.'){throw 'Supervisor error did not fail readiness immediately.'}
        $disconnected=[pscustomobject]@{Ready=$false;Error='Flutter application stopped before app.started.'}
        if(-not(Test-SgFlutterWindowsStartupRetry 'flutter-web' 'windows' $disconnected 0)){throw 'First transient Windows debug-attach failure did not permit one recovery attempt.'}
        if(Test-SgFlutterWindowsStartupRetry 'flutter-web' 'windows' $disconnected 1){throw 'Windows debug-attach recovery was not bounded to one retry.'}
        if(Test-SgFlutterWindowsStartupRetry 'flutter-web' 'chrome' $disconnected 0){throw 'Windows debug-attach recovery leaked into Chrome.'}
        if(Test-SgFlutterWindowsStartupRetry 'flutter-web' 'windows' ([pscustomobject]@{Ready=$false;Error='Flutter reported an application error.'}) 0){throw 'Compilation/application errors were incorrectly made retryable.'}
    }
    $config = [pscustomobject]@{Workspace=$fixture;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock');LogDirectory=$logs;PortStart=32200;PortEnd=32209}
    [void](Write-SgProjectEnvironment $surface 32205)
    $result = & $module {
        param($Config,$Surface)
        function Test-SgPortAvailable { $true }
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { [pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='mock-signature';Interactive=$false} }
        function Start-SgDetachedProcess { [pscustomobject]@{Id=77;CommandSignature='mock-signature'} }
        function Get-SgProcessSnapshot { [pscustomobject]@{Pid=77;StartTimeUtc='2026-08-15T00:00:00Z';ExecutablePath='mock.exe';CommandLine='mock-signature'} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 77 }
        function Wait-SgProjectReady { [pscustomobject]@{ Ready=$true; AppId=$null; Error=$null } }
        Start-SgProject $Config $Surface
    } $config $surface
    if ($result.status -ne 'running' -or $result.port -ne 32205) { throw 'Successful launch did not recover the durable project port when the registry port was zero.' }
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
        function Start-SgDetachedProcess { [pscustomobject]@{Id=88;CommandSignature='mock-signature'} }
        function Get-SgProcessSnapshot { [pscustomobject]@{Pid=88;StartTimeUtc='2026-08-15T00:00:01Z';ExecutablePath='mock.exe';CommandLine='mock-signature'} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 88 }
        function Wait-SgFlutterSupervisorReady { [pscustomobject]@{ Ready=$false; AppId=$null; Error='Flutter application startup timed out before app.started.'; DaemonPid=0 } }
        function Stop-SgProcessTree { param($RootPid) $script:stopped += $RootPid }
        function Stop-SgOwnedFlutterBrowser { $false }
        function Wait-SgManagedExtinction { $true }
        $result = Start-SgProject $Config $Surface
        [pscustomobject]@{Result=$result;Stopped=@($script:stopped)}
    } $config $flutterSurface
    if ($failed.Result.status -ne 'error' -or $failed.Result.lastError -notmatch 'app\.started' -or $failed.Stopped.Count -ne 1 -or $failed.Stopped[0] -ne 88) { throw 'Flutter readiness timeout did not fail and clean up the managed process.' }
    $failedStored = (Read-SgRegistry $config).projects | Where-Object { $_.path -eq $flutterSurface } | Select-Object -First 1
    if ($failedStored.status -ne 'error' -or -not $failedStored.lastError) { throw 'Flutter readiness failure was not persisted as error.' }

    $retrySurface=Join-Path $fixture 'flutter-retry'
    New-Item -ItemType Directory -Path $retrySurface -Force|Out-Null
    Copy-Item -LiteralPath (Join-Path $flutterSurface 'pubspec.yaml') -Destination (Join-Path $retrySurface 'pubspec.yaml')
    [IO.File]::WriteAllText((Join-Path $retrySurface '.shipglows.env'),"SHIPGLOWS_FLUTTER_DEVICE=windows`n")
    $retryFlow=& $module {
        param($Config,$Surface)
        $script:launchCount=0;$script:readinessCount=0;$script:stopped=@{};$script:cleanupComplete=$false;$script:secondLaunchAfterCleanup=$false
        function Test-SgPortAvailable{$true}
        function Invoke-SgDependencySetup{}
        function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='retry-signature';Interactive=$false;FlutterSdkRoot='C:\flutter'}}
        function Start-SgDetachedProcess{$script:launchCount++;if($script:launchCount-eq2){$script:secondLaunchAfterCleanup=$script:cleanupComplete};[pscustomobject]@{Id=(200+$script:launchCount);CommandSignature='retry-signature'}}
        function Get-SgProcessSnapshot{param($Pid)[pscustomobject]@{Pid=$Pid;StartTimeUtc="2026-09-02T00:00:0$script:launchCount`Z";ExecutablePath='mock.exe';CommandLine='retry-signature'}}
        function Test-SgProcessIdentity{param($Entry) [int]$Entry.pid-gt0-and-not$script:stopped.ContainsKey([int]$Entry.pid)}
        function Wait-SgFlutterSupervisorReady{$script:readinessCount++;if($script:readinessCount-eq1){[pscustomobject]@{Ready=$false;AppId=$null;Error='Flutter application stopped before app.started.';DaemonPid=201;StartupState='failed'}}else{[pscustomobject]@{Ready=$true;AppId='retry-app';Error=$null;DaemonPid=202;StartupState='running'}}}
        function Stop-SgProcessTree{param($RootPid)$script:stopped[$RootPid]=$true}
        function Stop-SgOwnedFlutterBrowser{$false}
        function Wait-SgFlutterOwnedExtinction{$true}
        function Remove-SgFlutterLaunchArtifacts{$script:cleanupComplete=$true;$true}
        function Wait-SgManagedExtinction{$true}
        function Copy-SgFlutterDiagnostics{}
        function Install-SgFlutterDevShortcut{}
        $result=Start-SgProject $Config $Surface
        [pscustomobject]@{Result=$result;LaunchCount=$script:launchCount;ReadinessCount=$script:readinessCount;SecondLaunchAfterCleanup=$script:secondLaunchAfterCleanup;StoppedCount=$script:stopped.Count}
    } $config $retrySurface
    if($retryFlow.Result.status-ne'running'-or$retryFlow.LaunchCount-ne2-or$retryFlow.ReadinessCount-ne2-or-not$retryFlow.SecondLaunchAfterCleanup-or$retryFlow.StoppedCount-ne1){throw 'Windows startup recovery did not cleanly retry once and reach app.started on the second launch.'}

    & $module { param($Config,$Surface) Invoke-SgRegistryMutation $Config {param($data);$item=@($data.projects|Where-Object{$_.path-eq$Surface})[0];$item.status='stopped';$item.pid=0;$item.startTimeUtc=$null} | Out-Null } $config $retrySurface
    $doubleFailure=& $module {
        param($Config,$Surface)
        $script:launchCount=0;$script:stopped=@{}
        function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='retry-signature';Interactive=$false;FlutterSdkRoot='C:\flutter'}}
        function Start-SgDetachedProcess{$script:launchCount++;[pscustomobject]@{Id=(210+$script:launchCount);CommandSignature='retry-signature'}}
        function Get-SgProcessSnapshot{param($Pid)[pscustomobject]@{Pid=$Pid;StartTimeUtc="2026-09-02T00:01:0$script:launchCount`Z";ExecutablePath='mock.exe';CommandLine='retry-signature'}}
        function Test-SgProcessIdentity{param($Entry) [int]$Entry.pid-gt0-and-not$script:stopped.ContainsKey([int]$Entry.pid)}
        function Wait-SgFlutterSupervisorReady{[pscustomobject]@{Ready=$false;AppId=$null;Error='Flutter application stopped before app.started.';DaemonPid=0;StartupState='failed'}}
        function Stop-SgProcessTree{param($RootPid)$script:stopped[$RootPid]=$true};function Stop-SgOwnedFlutterBrowser{$false};function Wait-SgFlutterOwnedExtinction{$true};function Remove-SgFlutterLaunchArtifacts{$true};function Wait-SgManagedExtinction{$true};function Copy-SgFlutterDiagnostics{}
        $result=Start-SgProject $Config $Surface
        [pscustomobject]@{Result=$result;LaunchCount=$script:launchCount;StoppedCount=$script:stopped.Count}
    } $config $retrySurface
    if($doubleFailure.Result.status-ne'error'-or$doubleFailure.LaunchCount-ne2-or$doubleFailure.StoppedCount-ne2){throw 'A second Windows debug-attach failure triggered an unbounded third launch or skipped cleanup.'}
    $moduleSource=Get-Content -LiteralPath $modulePath -Raw
    if($moduleSource.IndexOf('Release-SgProjectPort $Config $entry.path $reservationToken $entryData.lastError')-gt$moduleSource.IndexOf('if($retryFlutterStartup)')){throw 'Flutter retry is attempted before releasing the failed reservation.'}

    $nonRetrySurfaces=@()
    foreach($case in @(@('android-case','android'),@('chrome-case','chrome'),@('web-server-case','web-server'),@('explicit-error-case','windows'))){
        $caseSurface=Join-Path $fixture $case[0];New-Item -ItemType Directory -Path $caseSurface -Force|Out-Null
        Copy-Item -LiteralPath (Join-Path $flutterSurface 'pubspec.yaml') -Destination (Join-Path $caseSurface 'pubspec.yaml')
        [IO.File]::WriteAllText((Join-Path $caseSurface '.shipglows.env'),("SHIPGLOWS_FLUTTER_DEVICE={0}`n" -f $case[1]))
        $nonRetrySurfaces+=$caseSurface
    }
    $nonRetryFlow=& $module {
        param($Config,$Surfaces)
        $script:launches=@{};$script:stopped=@{}
        function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgFlutterCommandPath{'C:\flutter\bin\flutter.bat'};function Resolve-SgFlutterAndroidDevice{'android-device'}
        function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='non-retry-signature';Interactive=$false;FlutterSdkRoot='C:\flutter'}}
        function Start-SgDetachedProcess{param($FilePath,$ArgumentList,$WorkingDirectory)$script:launches[$WorkingDirectory]=1+[int]$script:launches[$WorkingDirectory];[pscustomobject]@{Id=(300+$script:launches.Count);CommandSignature='non-retry-signature'}}
        function Get-SgProcessSnapshot{param($Pid)[pscustomobject]@{Pid=$Pid;StartTimeUtc='2026-09-02T00:02:00Z';ExecutablePath='mock.exe';CommandLine='non-retry-signature'}}
        function Test-SgProcessIdentity{param($Entry) [int]$Entry.pid-gt0-and-not$script:stopped.ContainsKey([int]$Entry.pid)}
        function Wait-SgFlutterSupervisorReady{param($StatePath,$ProcessEntry)$surface=[string]$ProcessEntry.path;$error=if((Split-Path $surface -Leaf)-eq'explicit-error-case'){'Flutter reported an application error.'}else{'Flutter application stopped before app.started.'};[pscustomobject]@{Ready=$false;AppId=$null;Error=$error;DaemonPid=0;StartupState='failed'}}
        function Stop-SgProcessTree{param($RootPid)$script:stopped[$RootPid]=$true};function Stop-SgOwnedFlutterBrowser{$false};function Wait-SgFlutterOwnedExtinction{$true};function Remove-SgFlutterLaunchArtifacts{$true};function Wait-SgManagedExtinction{$true};function Copy-SgFlutterDiagnostics{}
        foreach($surface in $Surfaces){[void](Start-SgProject $Config $surface)}
        return $script:launches
    } $config $nonRetrySurfaces
    foreach($surface in $nonRetrySurfaces){if([int]$nonRetryFlow[$surface]-ne1){throw "Non-retry startup case launched more than once: $(Split-Path $surface -Leaf)"}}

    & $module { param($Config,$Surface) Invoke-SgRegistryMutation $Config {param($data);$item=@($data.projects|Where-Object{$_.path-eq$Surface})[0];$item.status='stopped';$item.pid=0;$item.startTimeUtc=$null} | Out-Null } $config $flutterSurface
    $visibleStarted=& $module {
        param($Config,$Surface)
        $script:launchWasVisible=$false
        function Test-SgPortAvailable { $true }
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { param($ProjectPath,$Kind,$Port,$FlutterVisible) $script:launchWasVisible=[bool]$FlutterVisible;[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='visible-signature';Interactive=$false;FlutterSdkRoot='C:\flutter'} }
        function Start-SgDetachedProcess { [pscustomobject]@{Id=89;CommandSignature='visible-signature'} }
        function Get-SgProcessSnapshot { [pscustomobject]@{Pid=89;StartTimeUtc='2026-08-15T00:00:02Z';ExecutablePath='mock.exe';CommandLine='visible-signature'} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 89 }
        function Wait-SgFlutterSupervisorReady { [pscustomobject]@{Ready=$true;AppId='visible-app';Error=$null;DaemonPid=890} }
        $result=Start-SgProject $Config $Surface 0 -FlutterVisible
        [pscustomobject]@{Result=$result;LaunchWasVisible=$script:launchWasVisible}
    } $config $flutterSurface
    $visibleStored=(Read-SgRegistry $config).projects|Where-Object{$_.path-eq$flutterSurface}|Select-Object -First 1
    if(-not$visibleStarted.LaunchWasVisible-or$visibleStarted.Result.flutterHeadless-or$visibleStored.flutterHeadless-or$visibleStored.status-ne'running'){throw 'Visible Flutter promotion was not recorded as a non-headless managed session.'}

    $astroSurface=Join-Path $fixture 'astro-site';New-Item -ItemType Directory -Path $astroSurface -Force|Out-Null
    Set-Content (Join-Path $astroSurface 'package.json') '{"dependencies":{"astro":"latest"},"scripts":{"dev":"astro dev"}}' -Encoding UTF8
    New-Item -ItemType Directory -Path (Join-Path $astroSurface '.astro') -Force | Out-Null
    $astroLock=Join-Path $astroSurface '.astro\dev.json'
    [IO.File]::WriteAllText($astroLock,('{"pid":'+$PID+',"port":3000,"url":"http://127.0.0.1:3000","background":true,"startedAt":"2026-08-25T10:45:24.889Z"}'))
    $repaired=& $module { param($Surface) Repair-SgStaleAstroDevLock $Surface { param($LockPid) [pscustomobject]@{Pid=$LockPid;ExecutablePath='C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe';CommandLine='powershell'} } } $astroSurface
    if(-not$repaired-or(Test-Path -LiteralPath $astroLock)){throw 'Astro PID reuse lock was not removed before managed startup.'}
    [IO.File]::WriteAllText($astroLock,'{"pid":4242,"port":3000,"url":"http://127.0.0.1:3000","background":true,"startedAt":"2026-08-25T10:45:24.889Z"}')
    $preserved=& $module { param($Surface) Repair-SgStaleAstroDevLock $Surface { param($LockPid) [pscustomobject]@{Pid=$LockPid;ExecutablePath='C:\Program Files\nodejs\node.exe';CommandLine='node C:\project\node_modules\astro\astro.mjs dev'} } } $astroSurface
    if($preserved-or-not(Test-Path -LiteralPath $astroLock)){throw 'Live Astro lock was removed during PID reuse reconciliation.'}
    [IO.File]::Delete($astroLock)
    $astroRunning=& $module { param($Config,$Surface) function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='astro-signature';Interactive=$false}};function Start-SgDetachedProcess{[pscustomobject]@{Id=99;CommandSignature='astro-signature'}};function Get-SgProcessSnapshot{[pscustomobject]@{Pid=99;StartTimeUtc='2026-08-17T00:00:00Z';ExecutablePath='mock.exe';CommandLine='astro-signature'}};function Test-SgProcessIdentity{param($Entry) [int]$Entry.pid-eq99};function Wait-SgProjectReady{[pscustomobject]@{Ready=$true;AppId=$null;Error=$null}};Start-SgProject $Config $Surface } $config $astroSurface
    & $module { param($Config,$Surface) Invoke-SgRegistryMutation $Config {param($data);$item=@($data.projects|Where-Object{$_.path-eq$Surface})[0];$item.status='stopped';$item.pid=0;$item.startTimeUtc=$null} | Out-Null } $config $astroSurface
    $astroFailed=& $module { param($Config,$Surface) function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='astro-signature';Interactive=$false}};function Start-SgDetachedProcess{[pscustomobject]@{Id=100;CommandSignature='astro-signature'}};function Get-SgProcessSnapshot{[pscustomobject]@{Pid=100;StartTimeUtc='2026-08-17T00:00:01Z';ExecutablePath='mock.exe';CommandLine='astro-signature'}};function Test-SgProcessIdentity{param($Entry) [int]$Entry.pid-eq100};function Wait-SgProjectReady{[pscustomobject]@{Ready=$false;AppId=$null;Error='Astro readiness failed.'}};function Stop-SgProcessTree{};function Wait-SgManagedExtinction{$true};function Copy-SgFlutterDiagnostics{throw 'Astro touched Flutter diagnostics.'};function Stop-SgOwnedFlutterBrowser{throw 'Astro touched Flutter browser cleanup.'};function Wait-SgFlutterOwnedExtinction{throw 'Astro touched Flutter extinction.'};function Remove-SgFlutterLaunchArtifacts{throw 'Astro touched Flutter launch cleanup.'};Start-SgProject $Config $Surface } $config $astroSurface
    if($astroFailed.status-ne'error'-or$astroFailed.port-ne$astroRunning.port){throw 'Astro readiness failure did not persist error on its assigned port.'}
    $astroStored=(Read-SgRegistry $config).projects|Where-Object{$_.path-eq$astroSurface}|Select-Object -First 1
    if($astroStored.status-ne'error'-or$astroStored.pid-ne0){throw 'Astro readiness failure left the registry starting or with a stale PID.'}
    & $module { param($Config,$Surface) Invoke-SgRegistryMutation $Config {param($data);$item=@($data.projects|Where-Object{$_.path-eq$Surface})[0];$item.status='stopped';$item.pid=0;$item.startTimeUtc=$null} | Out-Null } $config $astroSurface
    $astroEarly=& $module { param($Config,$Surface) function Test-SgPortAvailable{$true};function Invoke-SgDependencySetup{};function Get-SgLaunchSpec{[pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='astro-signature';Interactive=$false}};function Start-SgDetachedProcess{[pscustomobject]@{Id=101;CommandSignature='astro-signature'}};function Get-SgProcessSnapshot{[pscustomobject]@{Pid=101;StartTimeUtc='2026-08-17T00:00:02Z';ExecutablePath='mock.exe';CommandLine='astro-signature'}};function Test-SgProcessIdentity{$false};function Copy-SgFlutterDiagnostics{throw 'Astro early exit touched Flutter diagnostics.'};Start-SgProject $Config $Surface } $config $astroSurface
    if($astroEarly.status-ne'error'-or$astroEarly.port-ne$astroRunning.port){throw 'Astro early exit did not persist error on its assigned port.'}

    $stderr = Join-Path $fixture 'blocked.stderr.log'
    Set-Content -LiteralPath $stderr -Value 'Application Control blocked oxc-parser native binding.' -Encoding UTF8
    $startedAt = Get-Date
    $earlyReadiness = & $module {
        param($Stderr)
        function Test-SgHttpReady { $false }
        function Test-SgProcessIdentity { $false }
        Wait-SgProjectReady 'vite' 32206 '' 10 ([pscustomobject]@{pid=404}) $Stderr
    } $stderr
    if ($earlyReadiness.Ready -or $earlyReadiness.Error -notmatch 'Application Control.*oxc-parser') { throw 'Dead startup did not preserve its actionable stderr cause.' }
    if (((Get-Date) - $startedAt).TotalSeconds -gt 2) { throw 'Dead startup waited for the generic readiness timeout.' }

    $terminalStateRoot=Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-terminal-{0}" -f [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $terminalStateRoot -Force|Out-Null
    try {
        $terminalStatePath=Join-Path $terminalStateRoot 'state.json'
        [IO.File]::WriteAllText($terminalStatePath,'{"status":"error","appId":"app-stopped","daemonPid":42,"lastError":"Flutter application stopped before app.started.","progressActive":false}')
        $terminal=& $module { param($StatePath) function Test-SgProcessIdentity { $false }; Wait-SgFlutterSupervisorReady $StatePath ([pscustomobject]@{pid=42}) 1 1 1 } $terminalStatePath
        if($terminal.Ready-or$terminal.Error-notmatch'app\.started'-or$terminal.StartupState-ne'failed'){throw 'Published Flutter startup failure was hidden by the exited supervisor process.'}
    } finally { Remove-Item -LiteralPath $terminalStateRoot -Recurse -Force -ErrorAction SilentlyContinue }

    $secretValues = @('authBearerSecret','authBasicSecret','loneBearerSecret','tokenSecret','secretSecret','quoted password secret','apiKeySecret','dart secret')
    @(
        'Authorization: Bearer authBearerSecret',
        'Authorization = Basic authBasicSecret',
        'Bearer loneBearerSecret',
        'token: tokenSecret',
        'secret=secretSecret',
        'password "quoted password secret"',
        'api-key apiKeySecret',
        "dart-define='dart secret'",
        'token validation failed while loading the native binding'
    ) | Set-Content -LiteralPath $stderr -Encoding UTF8
    $redactedFailure = & $module { param($Stderr) Get-SgStartupFailure $Stderr } $stderr
    foreach ($secretValue in $secretValues) {
        if ($redactedFailure.Contains($secretValue)) { throw "Startup diagnostics leaked secret fixture: $secretValue" }
    }
    if ($redactedFailure -notmatch '\[REDACTED\]' -or $redactedFailure -notmatch 'token validation failed') { throw 'Startup diagnostic redaction removed useful context or omitted its marker.' }
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
