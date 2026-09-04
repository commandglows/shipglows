$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$modulePath=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try{
    $module=Get-Module ShipGlows.DevServer
    & $module {
        $project=Join-Path ([IO.Path]::GetTempPath()) ("sg-native-owner-{0}"-f[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path (Join-Path $project 'windows') -Force|Out-Null;[IO.File]::WriteAllText((Join-Path $project 'windows\CMakeLists.txt'),'set(BINARY_NAME "app")')
        $entry=[pscustomobject]@{kind='flutter-web';flutterDeviceId='windows';path=$project;launchPath=$project;pid=10;startTimeUtc='2026-09-04T16:00:00Z'}
        function Get-CimInstance {@(
            [pscustomobject]@{ProcessId=101;ExecutablePath=(Join-Path $project 'build\windows\x64\runner\Debug\app.exe');CreationDate=[datetime]'2026-09-04T16:00:10Z'},
            [pscustomobject]@{ProcessId=102;ExecutablePath=(Join-Path $project 'build\windows\x64\runner\Release\app.exe');CreationDate=[datetime]'2026-09-04T16:00:10Z'},
            [pscustomobject]@{ProcessId=103;ExecutablePath='C:\workspace\contentglows-neighbor\app\build\windows\x64\runner\Debug\app.exe';CreationDate=[datetime]'2026-09-04T16:00:10Z'},
            [pscustomobject]@{ProcessId=104;ExecutablePath=(Join-Path $project 'build\windows\x64\runner\Debug\old.exe');CreationDate=[datetime]'2026-09-04T15:00:00Z'}
        )}
        $owned=@(Get-SgOwnedFlutterNativePids $entry)
        if($owned.Count-ne1-or$owned[0]-ne101){throw 'Flutter Windows ownership was not restricted to the current project Debug runner and launch time.'}
        $script:killed=@();function Stop-SgProcessTree([int]$RootPid){$script:killed+=$RootPid}
        if(-not(Stop-SgOwnedFlutterNative $entry)-or$script:killed.Count-ne1-or$script:killed[0]-ne101){throw 'Owned Flutter Windows runner was not stopped exactly once.'}

        $script:entry=[pscustomobject]@{name='contentglows-app';kind='flutter-web';flutterDeviceId='windows';path=$project;launchPath=$project;status='running';pid=10;lastError=$null;flutterLaunchDirectory='C:\runtime\flutter-launch\0123456789abcdef0123456789abcdef';reservationToken=$null;reservationTimeUtc=$null}
        function Invoke-SgRegistryMutation {param($Config,$Mutation);$registry=[pscustomobject]@{projects=@($script:entry)};& $Mutation $registry;return $registry}
        function Get-SgProcessSnapshotMap {@{10=[pscustomobject]@{Pid=10}}}
        function Test-SgProcessIdentity {$true}
        function Get-SgFlutterSupervisorState {[pscustomobject]@{status='error';lastError='Flutter application stopped before app.started.';appId='';daemonPid=0}}
        $errorRegistry=Reconcile-SgRegistry ([pscustomobject]@{})
        if($errorRegistry.projects[0].status-ne'error'-or$errorRegistry.projects[0].flutterStartupState-ne'error'-or$errorRegistry.projects[0].lastError-notmatch'app\.started'){throw 'A live wrapper incorrectly promoted an errored Flutter supervisor to running.'}
        function Get-SgFlutterSupervisorState {[pscustomobject]@{status='running';lastError=$null;appId='app-1';daemonPid=99}}
        $runningRegistry=Reconcile-SgRegistry ([pscustomobject]@{})
        if($runningRegistry.projects[0].status-ne'running'-or$runningRegistry.projects[0].flutterStartupState-ne'running'-or$runningRegistry.projects[0].flutterAppId-ne'app-1'-or$runningRegistry.projects[0].flutterDaemonPid-ne99){throw 'A ready Flutter supervisor was not reconciled as running.'}
        function Get-SgOwnedFlutterNativePids {return @()}
        $missingRunnerRegistry=Reconcile-SgRegistry ([pscustomobject]@{})
        if($missingRunnerRegistry.projects[0].status-ne'error'-or$missingRunnerRegistry.projects[0].lastError-notmatch'runner'){throw 'A missing Windows runner did not invalidate stale supervisor readiness.'}
        function Get-SgOwnedFlutterListenerPids {return @()};function Get-SgOwnedFlutterBrowserPids {return @()}
        function Test-SgProcessIdentity {$false}
        $script:entry.status='error';$script:entry.lastError='build failed'
        $deadErrorRegistry=Reconcile-SgRegistry ([pscustomobject]@{})
        if($deadErrorRegistry.projects[0].status-ne'error'-or$deadErrorRegistry.projects[0].flutterStartupState-ne'error'-or$deadErrorRegistry.projects[0].lastError-ne'build failed'-or$deadErrorRegistry.projects[0].pid-ne0){throw 'Dead-process reconciliation erased a durable Flutter startup error or retained its stale PID.'}
        if(-not(Test-SgFlutterStartupRetryable 'Error waiting for a debug connection: The log reader stopped unexpectedly.')-or(Test-SgFlutterStartupRetryable 'CMake compilation failed.')){throw 'Flutter startup retry classification is not restricted to the transient debug connection signature.'}

        $stateRoot=Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-ready-{0}"-f[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $stateRoot|Out-Null;$statePath=Join-Path $stateRoot 'state.json'
        try{
            [IO.File]::WriteAllText($statePath,'{"status":"building","appId":"app-build","daemonPid":42,"progressActive":true}')
            function Test-SgProcessIdentity {$true}
            $clock=[Diagnostics.Stopwatch]::StartNew();$buildTimeout=Wait-SgFlutterSupervisorReady $statePath 0 ([pscustomobject]@{pid=10}) 1;$clock.Stop()
            if($clock.ElapsedMilliseconds-lt700-or$buildTimeout.Error-notmatch'build timed out'){throw 'Active Flutter build progress did not receive its dedicated startup window.'}
            $transitionAt=[datetime]'2026-09-04T20:00:00Z';$timing=Update-SgFlutterReadinessWindow $true $false $transitionAt.AddMinutes(-1) 90 $transitionAt
            if($timing.ActiveProgress-or$timing.Deadline-ne$transitionAt.AddSeconds(90)){throw 'Flutter debug attachment did not receive a fresh deadline after a long build completed.'}
            function Test-SgProcessIdentity {$false}
            $clock.Restart();$deadSupervisor=Wait-SgFlutterSupervisorReady $statePath 30 ([pscustomobject]@{pid=10}) 60;$clock.Stop()
            if($clock.ElapsedMilliseconds-gt1500-or$deadSupervisor.Error-notmatch'exited during startup'){throw 'Supervisor death was not detected promptly while Flutter reported build progress.'}
        }finally{Remove-Item -LiteralPath $stateRoot -Recurse -Force -ErrorAction SilentlyContinue}
        Remove-Item -LiteralPath $project -Recurse -Force
    }
    Write-Host 'Windows DevServer Flutter startup ownership and reconciliation: OK'
}finally{Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue}
