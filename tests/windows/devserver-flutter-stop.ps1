$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    $module = Get-Module ShipGlows.DevServer
    & $module {
        $project = 'C:\workspace\gocharbon\app'
        $entry = [pscustomobject]@{kind='flutter-web';port=3001;path=$project;launchPath=$project;commandSignature='ShipGlows:flutter-web:3001:C:\workspace\gocharbon\app';pid=18120}
        function Get-NetTCPConnection { @([pscustomobject]@{OwningProcess=16484}) }
        function Get-CimInstance { @(
            [pscustomobject]@{ProcessId=16484;ParentProcessId=15000;ExecutablePath='C:\flutter\bin\cache\dart-sdk\bin\dartvm.exe';CommandLine="dartvm --packages=$project\.dart_tool\package_config.json"},
            [pscustomobject]@{ProcessId=15000;ParentProcessId=0;ExecutablePath='C:\flutter\bin\flutter.exe';CommandLine="flutter run -d web-server $project"}
        ) }
        $owned = @(Get-SgOwnedFlutterListenerPids $entry)
        if ($owned.Count -ne 1 -or $owned[0] -ne 16484) { throw 'Owned orphan Flutter listener was not resolved.' }
        $unrelated = [pscustomobject]@{kind='flutter-web';port=3001;path='C:\workspace\gocharbon\application';launchPath='C:\workspace\gocharbon\application';commandSignature='other';pid=1}
        if (@(Get-SgOwnedFlutterListenerPids $unrelated).Count -ne 0) { throw 'A similarly prefixed project path claimed an unrelated listener.' }
        $script:stopped = @(); function Stop-SgProcessTree([int]$RootPid) { $script:stopped += $RootPid }
        if (-not (Stop-SgOwnedFlutterListener $entry) -or $script:stopped.Count -ne 1 -or $script:stopped[0] -ne 16484) { throw 'Verified Flutter listener was not stopped.' }
    }
    Write-Host 'Windows DevServer Flutter ownership stop: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
