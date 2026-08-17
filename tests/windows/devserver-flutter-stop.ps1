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

        $entry | Add-Member -NotePropertyName browserProfilePath -NotePropertyValue 'C:\runtime with space\flutter\launch-123' -Force
        function Get-CimInstance { @(
            [pscustomobject]@{ProcessId=200;ParentProcessId=1;ExecutablePath='C:\Program Files\Google\Chrome\Application\chrome.exe';CommandLine='chrome.exe --user-data-dir="C:\runtime with space\flutter\launch-123" --remote-debugging-port=41000'},
            [pscustomobject]@{ProcessId=201;ParentProcessId=1;ExecutablePath='C:\Program Files\Google\Chrome\Application\chrome.exe';CommandLine='chrome.exe --user-data-dir=C:\Users\Shadow\Chrome'},
            [pscustomobject]@{ProcessId=202;ParentProcessId=1;ExecutablePath='C:\Program Files\Google\Chrome\Application\chrome.exe';CommandLine='chrome.exe --user-data-dir="C:\runtime with space\flutter\launch-123-other"'}
        ) }
        $browserPids = @(Get-SgOwnedFlutterBrowserPids $entry)
        if ($browserPids.Count -ne 1 -or $browserPids[0] -ne 200) { throw 'Flutter browser ownership must require the exact ShipGlows profile path.' }

        $runtime=Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-clean-{0}" -f [guid]::NewGuid().ToString('N'));$launch=Join-Path $runtime 'flutter-launch\0123456789abcdef0123456789abcdef';New-Item -ItemType Directory -Path (Join-Path $launch 'chrome-profile'),(Join-Path $launch 'responses') -Force|Out-Null;[IO.File]::WriteAllText((Join-Path $launch 'token'),'token')
        try{function Test-SgProcessIdentity{$false};function Get-SgOwnedFlutterBrowserPids{return @()};function Get-SgOwnedFlutterListenerPids{return @()};$cleanupEntry=[pscustomobject]@{flutterLaunchDirectory=$launch;kind='flutter-web';pid=0};$cleanupConfig=[pscustomobject]@{RuntimeDirectory=$runtime};if(-not(Remove-SgFlutterLaunchArtifacts $cleanupConfig $cleanupEntry)-or(Test-Path $launch)){throw 'Owned Flutter launch artifacts were not cleaned.'};if(-not(Remove-SgFlutterLaunchArtifacts $cleanupConfig $cleanupEntry)){throw 'Flutter launch cleanup is not idempotent.'}}finally{Remove-Item -LiteralPath $runtime -Recurse -Force -ErrorAction SilentlyContinue}

        $runtime=Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-retry-{0}" -f [guid]::NewGuid().ToString('N'));$launch=Join-Path $runtime 'flutter-launch\fedcba9876543210fedcba9876543210';New-Item -ItemType Directory -Path $launch -Force|Out-Null
        try {
            $retryEntry=[pscustomobject]@{name='retry';path=$project;kind='flutter-web';status='stopped';pid=0;startTimeUtc=$null;lastError=$null;flutterLaunchDirectory=$launch}
            function ConvertTo-SgCanonicalPath { param($Path) [string]$Path }
            function Read-SgRegistry { [pscustomobject]@{projects=@($retryEntry)} }
            function Stop-SgOwnedFlutterListener { $false }; function Stop-SgOwnedFlutterBrowser { $false }
            function Invoke-SgRegistryMutation { param($Config,$Mutation); & $Mutation ([pscustomobject]@{projects=@($retryEntry)}) }
            function Test-SgProjectCatalogEntry { $true }
            $cleanupConfig=[pscustomobject]@{RuntimeDirectory=$runtime}
            if (-not (Stop-SgProject $cleanupConfig $project)) { throw 'Retried Flutter stop did not report residual cleanup.' }
            if (Test-Path -LiteralPath $launch) { throw 'Retried Flutter stop left residual launch artifacts.' }
            if ($script:stopped -contains 99999) { throw 'Retried Flutter cleanup stopped an unrelated process.' }
        } finally { Remove-Item -LiteralPath $runtime -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Write-Host 'Windows DevServer Flutter ownership stop: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
