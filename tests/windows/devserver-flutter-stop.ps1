$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    $module = Get-Module ShipGlows.DevServer
    & $module {
        $project = 'C:\workspace\gocharbon\app'
        $entry = [pscustomobject]@{kind='flutter-web';port=3001;path=$project;launchPath=$project;commandSignature='ShipGlows:flutter-web:3001:C:\workspace\gocharbon\app';pid=18120;flutterLaunchDirectory='C:\runtime\flutter-launch\bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';flutterSdkRoot='C:\flutter'}
        function Get-NetTCPConnection { @([pscustomobject]@{OwningProcess=16484}) }
        function Get-CimInstance { @(
            [pscustomobject]@{ProcessId=16484;ParentProcessId=15000;ExecutablePath='C:\flutter\bin\cache\dart-sdk\bin\dartvm.exe';CommandLine='dartvm C:\runtime\flutter-launch\bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb --web-port 3001'},
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

        $orphanEntry=[pscustomobject]@{kind='flutter-web';port=3005;path=$project;launchPath=$project;pid=0;commandSignature='';browserProfilePath='C:\runtime\flutter-launch\aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\chrome-profile';flutterLaunchDirectory='C:\runtime\flutter-launch\aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';flutterSdkRoot='C:\flutter'}
        function Get-NetTCPConnection { @([pscustomobject]@{OwningProcess=301},[pscustomobject]@{OwningProcess=302},[pscustomobject]@{OwningProcess=303},[pscustomobject]@{OwningProcess=304},[pscustomobject]@{OwningProcess=305}) }
        function Get-CimInstance { @(
            [pscustomobject]@{ProcessId=301;ParentProcessId=0;ExecutablePath='C:\flutter\bin\cache\dart-sdk\bin\dart.exe';CommandLine='dart.exe --web-port 3005 --user-data-dir="C:\runtime\flutter-launch\aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\chrome-profile"'},
            [pscustomobject]@{ProcessId=302;ParentProcessId=0;ExecutablePath='C:\flutter\bin\cache\dart-sdk\bin\dart.exe';CommandLine='dart.exe --web-port 3005 --user-data-dir="C:\runtime\flutter-launch\aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\chrome-profile-neighbor"'},
            [pscustomobject]@{ProcessId=303;ParentProcessId=0;ExecutablePath='C:\foreign\server.exe';CommandLine='flutter server.exe C:\runtime\flutter-launch\aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'},
            [pscustomobject]@{ProcessId=304;ParentProcessId=0;ExecutablePath='C:\flutter-neighbor\bin\cache\dart-sdk\bin\dart.exe';CommandLine='dart.exe --web-port 3005 C:\runtime\flutter-launch\aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'},
            [pscustomobject]@{ProcessId=305;ParentProcessId=0;ExecutablePath='C:\flutter\bin\cache\dart-sdk\bin\foreign\dart.exe';CommandLine='dart.exe --web-port 3005 C:\runtime\flutter-launch\aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'}
        ) }
        $orphans=@(Get-SgOwnedFlutterListenerPids $orphanEntry)
        if($orphans.Count-ne1-or$orphans[0]-ne301){throw 'Exact managed Flutter orphan ownership was not isolated from prefix-neighbor or foreign processes.'}
        $script:stopped=@();if(-not(Stop-SgOwnedFlutterListener $orphanEntry)-or$script:stopped.Count-ne1-or$script:stopped[0]-ne301){throw 'Exact managed Flutter orphan listener was not stopped in isolation.'}

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

        $supervisedEntry=[pscustomobject]@{name='supervised';path=$project;kind='flutter-web';status='running';pid=4242;startTimeUtc='2026-08-17T10:00:00Z';lastError=$null;flutterLaunchDirectory='C:\runtime\flutter-launch\cccccccccccccccccccccccccccccccc'}
        $script:identityChecks=0;$script:warnings=@()
        function Read-SgRegistry { [pscustomobject]@{projects=@($supervisedEntry)} }
        function Test-SgProcessIdentity { $script:identityChecks++;return $script:identityChecks-eq1 }
        function Invoke-SgFlutterSupervisorCommand { return [pscustomobject]@{ok=$true} }
        function Stop-SgOwnedFlutterListener { $false };function Stop-SgOwnedFlutterBrowser { $false }
        function Remove-SgFlutterLaunchArtifacts { $true }
        function Write-SgWarn([string]$Message){$script:warnings+=$Message}
        function Invoke-SgRegistryMutation { param($Config,$Mutation);& $Mutation ([pscustomobject]@{projects=@($supervisedEntry)}) }
        if(-not(Stop-SgProject ([pscustomobject]@{RuntimeDirectory='C:\runtime'}) $project)){throw 'Supervisor-proven Flutter stop was not reported.'}
        if(@($script:warnings|Where-Object{$_-match'Stale or unverified'}).Count-ne0){throw 'Supervisor-proven Flutter stop emitted a stale-process warning.'}
    }
    Write-Host 'Windows DevServer Flutter ownership stop: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
