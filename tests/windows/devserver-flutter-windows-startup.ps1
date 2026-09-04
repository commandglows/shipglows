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

        $script:entry=[pscustomobject]@{name='contentglows-app';kind='flutter-web';path=$project;launchPath=$project;status='running';pid=10;startTimeUtc='2026-09-04T16:00:00Z';lastError=$null;flutterLaunchDirectory='C:\runtime\flutter-launch\0123456789abcdef0123456789abcdef';reservationToken=$null;reservationTimeUtc=$null}
        function Invoke-SgRegistryMutation {param($Config,$Mutation);$registry=[pscustomobject]@{projects=@($script:entry)};& $Mutation $registry;return $registry}
        function Get-SgProcessSnapshotMap {@{10=[pscustomobject]@{Pid=10}}}
        function Test-SgProcessIdentity {$true}
        function Get-SgFlutterSupervisorState {[pscustomobject]@{status='error';lastError='Flutter application stopped before app.started.';appId='';daemonPid=0}}
        $errorRegistry=Reconcile-SgRegistry ([pscustomobject]@{})
        if($errorRegistry.projects[0].status-ne'error'-or$errorRegistry.projects[0].lastError-notmatch'app\.started'){throw 'A live wrapper incorrectly promoted an errored Flutter supervisor to running.'}
        function Get-SgFlutterSupervisorState {[pscustomobject]@{status='running';lastError=$null;appId='app-1';daemonPid=99}}
        $runningRegistry=Reconcile-SgRegistry ([pscustomobject]@{})
        if($runningRegistry.projects[0].status-ne'running'-or$runningRegistry.projects[0].flutterAppId-ne'app-1'-or$runningRegistry.projects[0].flutterDaemonPid-ne99){throw 'A ready Flutter supervisor was not reconciled as running.'}
        if(-not(Test-SgFlutterStartupRetryable 'Error waiting for a debug connection: The log reader stopped unexpectedly.')-or(Test-SgFlutterStartupRetryable 'CMake compilation failed.')){throw 'Flutter startup retry classification is not restricted to the transient debug connection signature.'}
        Remove-Item -LiteralPath $project -Recurse -Force
    }
    Write-Host 'Windows DevServer Flutter startup ownership and reconciliation: OK'
}finally{Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue}
