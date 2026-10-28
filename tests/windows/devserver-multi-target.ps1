# Several targets of one surface run side by side; a conflicting target never replaces another implicitly.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-multi-target-{0}" -f [guid]::NewGuid().ToString('N'))
$tauri = Join-Path $fixture 'tauri-app'; $flutter = Join-Path $fixture 'flutter-app'; $runtime = Join-Path $fixture 'runtime'; $logs = Join-Path $runtime 'logs'
try {
    New-Item -ItemType Directory -Path (Join-Path $tauri 'src-tauri'),(Join-Path $flutter 'windows'),(Join-Path $flutter 'web'),$runtime,$logs -Force | Out-Null
    Set-Content (Join-Path $tauri '.shipglows.runtime.json') '{"surface":"tauri"}'
    Set-Content (Join-Path $tauri 'src-tauri\tauri.conf.json') '{"identifier":"com.fixture.app","build":{"devUrl":"http://127.0.0.1:32306","beforeDevCommand":"pnpm tauri:dev"}}'
    Set-Content (Join-Path $tauri 'src-tauri\tauri.dev.conf.json') '{"identifier":"com.fixture.dev"}'
    Set-Content (Join-Path $flutter 'pubspec.yaml') "name: test_app`ndependencies:`n  flutter:`n    sdk: flutter`nflutter:`n  uses-material-design: true" -Encoding UTF8
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer
    $config = [pscustomobject]@{Workspace=$fixture;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock');LogDirectory=$logs;PortStart=32300;PortEnd=32320}

    & $module {
        param($Config,$Tauri,$Flutter)
        # A fake process table: launched processes stay alive until a stop removes them.
        $script:live = @{}; $script:nextPid = 500; $script:launches = @()
        function Test-SgPortAvailable { param($Port) -not (@($script:live.Values | Where-Object { $_.Port -eq [int]$Port }).Count) }
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { param($ProjectPath,$Kind,$Port,$FlutterVisible,$FlutterProfilePath,$FlutterDevice,$DartDefineFile,$FlutterLaunchDirectory,$FlutterLaunchIdentity,$FlutterMode,$TauriDevice,$TauriDeviceName,$TauriFrontend,$TauriSessionDirectory)
            $script:launches += [pscustomobject]@{Kind=$Kind;Port=[int]$Port;TauriDevice=[string]$TauriDevice;TauriFrontend=[string]$TauriFrontend;FlutterDevice=[string]$FlutterDevice;Directory=[string]$TauriSessionDirectory}
            $script:pendingPort = if ([string]$TauriFrontend -eq 'shared' -or ($Kind -eq 'flutter-web' -and $FlutterDevice -in @('windows','android'))) { 0 } else { [int]$Port }
            [pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='mock';Interactive=$false;FlutterSdkRoot='C:\flutter'} }
        function Start-SgDetachedProcess { $script:nextPid++; $script:live[$script:nextPid] = [pscustomobject]@{Port=$script:pendingPort}; [pscustomobject]@{Id=$script:nextPid;CommandSignature='mock';JobName="job-$($script:nextPid)"} }
        function Get-SgProcessSnapshot { param($Pid) if ($script:live.ContainsKey([int]$Pid)) { [pscustomobject]@{Pid=[int]$Pid;StartTimeUtc="2026-10-23T10:00:$('{0:d2}' -f ([int]$Pid % 60))Z";ExecutablePath='mock.exe';CommandLine='mock'} } }
        function Get-SgProcessSnapshotMap { param($Pids) $map=@{}; foreach ($id in @($Pids)) { $snapshot = Get-SgProcessSnapshot $id; if ($snapshot) { $map[[int]$id] = $snapshot } }; $map }
        function Test-SgProcessIdentity { param($Entry,$SnapshotByPid) [int]$Entry.pid -gt 0 -and $script:live.ContainsKey([int]$Entry.pid) }
        function Stop-SgManagedJob { param($Entry) [void]$script:live.Remove([int]$Entry.pid); $true }
        function Stop-SgProcessTree { param($RootPid) [void]$script:live.Remove([int]$RootPid) }
        function Get-SgListeningTcpPortSet { $null }
        function Test-SgHttpReady { $true }
        function Wait-SgProjectReady { [pscustomobject]@{Ready=$true;AppId=$null;Error=$null} }
        function Wait-SgFlutterSupervisorReady { [pscustomobject]@{Ready=$true;AppId='app';Error=$null;DaemonPid=0} }
        function Get-SgFlutterSupervisorState { [pscustomobject]@{status='running';appId='app';daemonPid=0;ready=$true} }
        function Get-SgOwnedFlutterNativePids { param($Entry) if ([string]$Entry.flutterDeviceId -eq 'windows' -and [int]$Entry.pid -gt 0 -and $script:live.ContainsKey([int]$Entry.pid)) { @(9999) } else { @() } }
        function Get-SgOwnedFlutterListenerPids { @() }
        function Get-SgOwnedFlutterBrowserPids { @() }
        function Invoke-SgFlutterSupervisorCommand { param($Entry) [void]$script:live.Remove([int]$Entry.pid) }
        function Start-SgManagedProcessExitMonitor { }
        function Install-SgDevShortcut { }
        function Resolve-SgTauriAndroidDevice { [pscustomobject]@{Adb='adb.exe';Serial='R5CR10';Name='SM-G996B'} }
        function Invoke-SgFlutterAndroidTool { [pscustomobject]@{ExitCode=0;Output=''} }
        function Write-SgInfo { } ; function Write-SgWarn { }
        $session = { param($target) $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $Tauri })[0]; Get-SgEntrySession $entry $target }

        # 1. A second Tauri target never replaces the first one silently.
        $desktop = Start-SgProjectCore $Config $Tauri -TauriDevice windows
        if ($desktop.status -ne 'running' -or $desktop.port -ne 32306 -or $desktop.target -ne 'windows') { throw "Tauri desktop did not start on its devUrl port: $($desktop.status) $($desktop.port)" }
        $refused = $null
        try { Start-SgProjectCore $Config $Tauri -TauriDevice android | Out-Null } catch { $refused = $_.Exception.Message }
        if ($refused -notmatch '-Frontend shared' -or $refused -notmatch '-Frontend own' -or $refused -notmatch '-Replace') { throw "A conflicting Tauri target did not offer the explicit choices: $refused" }
        if ((& $session 'windows').status -ne 'running' -or (& $session 'android')) { throw 'A refused Tauri target changed the running desktop session.' }

        # 2. Shared frontend: both targets run, each with its own logs and start time.
        $phone = Start-SgProjectCore $Config $Tauri -TauriDevice android -Frontend shared
        if ($phone.status -ne 'running' -or $phone.port -ne 32306 -or $phone.portRole -ne 'shared' -or $phone.frontendOwner -ne 'windows') { throw 'The Android target did not attach to the shared desktop frontend.' }
        if ($script:launches[-1].TauriFrontend -ne 'shared') { throw 'The shared Tauri launch did not drop its own frontend command.' }
        $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $Tauri })[0]
        if (@(Get-SgEntrySessions $entry | Where-Object { $_.status -eq 'running' }).Count -ne 2) { throw 'Two Tauri targets are not both running.' }
        if ((Split-Path -Parent $phone.logPath) -eq (Split-Path -Parent $desktop.logPath) -or $phone.logPath -notmatch '\\android\\' -or $desktop.logPath -notmatch '\\windows\\') { throw 'Targets share or misplace their log directory.' }
        $lines = @(Format-SgSessionStatusLines $entry)
        if ($lines.Count -ne 2 -or @($lines | Where-Object { $_ -match 'since \d' }).Count -ne 2 -or -not ($lines -match 'shared frontend of windows')) { throw "Status does not list both targets with start times: $($lines -join ' / ')" }
        if ((Format-SgProjectStatus $entry) -notmatch '\+') { throw 'The dashboard line does not show both active targets.' }
        $again = Start-SgProjectCore $Config $Tauri
        if ($again.target -ne 'windows' -and $again.target -ne 'android') { throw 'A start without target did not reuse a live target.' }
        if ($script:launches.Count -ne 2) { throw 'A start without target launched a new process instead of reusing a live target.' }

        # 3. Stopping the frontend owner stops its attached target too, and says why.
        if (-not (Stop-SgProjectCore $Config $Tauri -Target windows)) { throw 'The desktop target stop was not reported.' }
        $stoppedPhone = & $session 'android'
        if ($stoppedPhone.status -ne 'stopped' -or $stoppedPhone.lastEvent -notmatch 'frontend of the windows target') { throw "The attached Android target was not stopped with its frontend owner: $($stoppedPhone | ConvertTo-Json -Compress)" }

        # 4. -Replace is explicit and recorded on the replaced target.
        [void](Start-SgProjectCore $Config $Tauri -TauriDevice windows)
        $replaced = Start-SgProjectCore $Config $Tauri -TauriDevice android -Replace
        if ($replaced.status -ne 'running' -or $replaced.port -ne 32306 -or (& $session 'windows').lastEvent -notmatch 'replaced by the android target') { throw 'An explicit replacement was not performed and recorded.' }

        # 5. -Frontend own runs a second frontend on a free port.
        $ownDesktop = Start-SgProjectCore $Config $Tauri -TauriDevice windows -Frontend own
        if ($ownDesktop.status -ne 'running' -or $ownDesktop.port -eq 32306 -or $ownDesktop.portRole -ne 'secondary' -or $script:launches[-1].TauriFrontend -ne 'own') { throw 'An own-frontend target did not get a separate port.' }
        $durable = Get-SgProjectEnvironment $Tauri
        if ($durable.Port -ne 32306) { throw 'A secondary frontend port replaced the durable surface port.' }
        [void](Stop-SgProjectCore $Config $Tauri)
        $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $Tauri })[0]
        if (@(Get-SgEntrySessions $entry | Where-Object { $_.status -ne 'stopped' }).Count -ne 0 -or $script:live.Count -ne 0) { throw 'A project stop left a target running.' }

        # 6. Flutter targets run in parallel; the Web target keeps a real port.
        $native = Start-SgProjectCore $Config $Flutter -FlutterDevice windows
        $web = Start-SgProjectCore $Config $Flutter -FlutterDevice chrome
        $flutterEntry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $Flutter })[0]
        if ($native.status -ne 'running' -or $web.status -ne 'running' -or @(Get-SgEntrySessions $flutterEntry | Where-Object { $_.status -eq 'running' }).Count -ne 2) { throw 'Flutter Windows and Chrome targets did not run side by side.' }
        if ($web.port -le 0 -or $native.portRole -ne 'none') { throw 'Flutter targets did not keep their port roles.' }
        [void](Stop-SgProjectCore $Config $Flutter -Target chrome)
        $flutterEntry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $Flutter })[0]
        if ((Get-SgEntrySession $flutterEntry 'windows').status -ne 'running' -or (Get-SgEntrySession $flutterEntry 'chrome').status -ne 'stopped') { throw 'Stopping one Flutter target touched another.' }

        # 7. A registry written before targets migrates its runtime state into the matching session.
        $legacy = [pscustomobject]@{name='legacy';path='C:\legacy';kind='tauri';port=3006;status='running';pid=4242;startTimeUtc='2026-10-23T10:52:46Z';tauriDevice='android';tauriDeviceId='R5CR10';logPath='C:\logs\stdout.log'}
        ConvertTo-SgSessionEntry $legacy
        $migrated = Get-SgEntrySession $legacy 'android'
        if (-not $migrated -or $migrated.pid -ne 4242 -or $migrated.port -ne 3006) { throw 'A legacy surface-level session was not migrated to its target.' }
    } $config $tauri $flutter
    Write-Output 'Windows DevServer multi-target sessions: PASS'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if ([IO.Path]::GetFullPath($fixture).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
    }
}
