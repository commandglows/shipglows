$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    $module = Get-Module ShipGlows.DevServer
    & $module {
        function Resolve-SgPowerShellExecutable { 'C:\fixture\pwsh.exe' }
        $fallbackRoot = Join-Path ([IO.Path]::GetTempPath()) ("sg-managed-flutter-{0}" -f [guid]::NewGuid().ToString('N'))
        $previousLocalAppData = $env:LOCALAPPDATA
        try {
            New-Item -ItemType Directory -Path (Join-Path $fallbackRoot 'ShipGlows\flutter\bin') -Force | Out-Null
            [IO.File]::WriteAllText((Join-Path $fallbackRoot 'ShipGlows\flutter\bin\flutter.bat'),'@exit /b 0')
            [IO.File]::WriteAllText((Join-Path $fallbackRoot 'ShipGlows\flutter\bin\dart.bat'),'@exit /b 0')
            $env:LOCALAPPDATA = $fallbackRoot
            function Get-SgCommandPath { $null }
            $managedFlutter = Get-SgFlutterCommandPath
            if ($managedFlutter -ne (Join-Path $fallbackRoot 'ShipGlows\flutter\bin\flutter.bat')) { throw 'DevServer did not recover the validated managed Flutter path for a stale parent PATH.' }
        } finally {
            $env:LOCALAPPDATA = $previousLocalAppData
            Remove-Item -LiteralPath $fallbackRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
        $diagRoot=Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-diag-{0}" -f [guid]::NewGuid().ToString('N'));$durable=Join-Path $diagRoot 'durable';$launch=Join-Path $diagRoot 'launch';New-Item -ItemType Directory -Path $durable,$launch -Force|Out-Null
        try{$secret='token=0123456789abcdef0123456789abcdef';[IO.File]::WriteAllText((Join-Path $launch 'flutter.stdout.log'),(('x'*300000)+"`nmachine-line`n$secret"));[IO.File]::WriteAllText((Join-Path $launch 'flutter.stderr.log'),'host-error');[IO.File]::WriteAllText((Join-Path $launch 'state.json'),'{"Status":"error","LastError":"startup failed"}');$entry=[pscustomobject]@{flutterLaunchDirectory=$launch};$out=Join-Path $durable 'stdout.log';$err=Join-Path $durable 'stderr.log';Copy-SgFlutterDiagnostics $entry $out $err;$durableText=Get-Content $out -Raw;if($durableText-notmatch'machine-line|startup failed'-or(Get-Content $err -Raw)-notmatch'host-error'){throw 'Flutter diagnostics were not copied to durable logs before cleanup.'};if($durableText.Length-gt270000-or$durableText-match'0123456789abcdef'){throw 'Flutter diagnostics were not tail-bounded and redacted.'};$large=Join-Path $diagRoot 'multi-mib.log';$stream=[IO.File]::OpenWrite($large);try{$stream.SetLength(8MB);$stream.Seek(-4,[IO.SeekOrigin]::End)|Out-Null;$bytes=[Text.Encoding]::UTF8.GetBytes('TAIL');$stream.Write($bytes,0,$bytes.Length)}finally{$stream.Dispose()};$tail=Get-SgBoundedFileTail $large 262144;if($tail.Length-gt262144-or-not$tail.EndsWith('TAIL')){throw 'Bounded tail helper did not seek within a multi-MiB file.'}}finally{Remove-Item $diagRoot -Recurse -Force -ErrorAction SilentlyContinue}
        function Get-SgCommandPath { 'C:\flutter\bin\flutter.bat' }
        $profile = 'C:\runtime\flutter\app\launch-123'
        $launch = 'C:\runtime\flutter\launch-123'
        $spec = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $false $profile 'chrome' '' $launch 'ShipGlowsFlutter-launch-123'
        if ($spec.Interactive) { throw 'Flutter Web launch must be managed in the background.' }
        $arguments = $spec.Arguments -join ' '
        if ($arguments -match '(?:^|\s)-Visible(?:\s|$)') { throw 'Normal Flutter start must remain headless until the explicit Open action.' }
        foreach ($expected in @('ShipGlows.FlutterSupervisor.ps1','-LaunchDirectory','-ProjectPath','-FlutterPath','-Port 3010','-Device chrome','-LaunchIdentity ShipGlowsFlutter-launch-123')) {
            if (-not $arguments.Contains($expected)) { throw "Flutter Web managed launch is missing: $expected" }
        }
        $visible = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $true $profile 'chrome' '' $launch 'ShipGlowsFlutter-launch-123'
        if (($visible.Arguments -join ' ') -notmatch '(?:^|\s)-Visible(?:\s|$)') { throw 'Explicit Flutter open must promote to a visible browser session.' }
        $webServer = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $false '' 'web-server' '' $launch 'ShipGlowsFlutter-launch-123'
        if (($webServer.Arguments -join ' ') -notmatch '-Device web-server' -or ($webServer.Arguments -join ' ') -match '-ProfilePath') { throw 'Flutter web-server must remain an explicit advanced mode.' }

        $windows = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $false '' 'windows' '' $launch 'ShipGlowsFlutter-launch-123'
        $windowsArguments = $windows.Arguments -join ' '
        if ($windowsArguments -notmatch '-Device windows' -or $windowsArguments -match '-Port|ProfilePath|web-hostname|web-port') { throw 'Flutter Windows must launch without web port or browser profile arguments.' }
        $android = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $false '' 'emulator-5554' '' $launch 'ShipGlowsFlutter-launch-123'
        $androidArguments = $android.Arguments -join ' '
        if ($androidArguments -notmatch '-Device emulator-5554' -or $androidArguments -match '-Port|ProfilePath|web-hostname|web-port') { throw 'Flutter Android must launch by exact device id without web arguments.' }

        $deviceJson='[{"name":"Pixel","id":"phone-1","isSupported":true,"targetPlatform":"android-arm64","emulator":false}]'
        $selected=Resolve-SgFlutterAndroidDevice 'flutter.bat' 'phone-1' 'ShipGlows_API_36' { param($f,$a) [pscustomobject]@{ExitCode=0;Output=$deviceJson} } { param($ms) } 2
        if ($selected -ne 'phone-1') { throw 'Explicit connected Android device selection drifted.' }
        $script:androidProbe=0
        $autoRunner={param($f,$a)$joined=$a-join' ';if($joined-eq'emulators --launch ShipGlows_API_36'){[pscustomobject]@{ExitCode=0;Output='started'}}else{$script:androidProbe++;$output=if($script:androidProbe-lt2){'[]'}else{'[{"name":"ShipGlows API 36","id":"emulator-5554","isSupported":true,"targetPlatform":"android-x64","emulator":true}]'};[pscustomobject]@{ExitCode=0;Output=$output}}}
        $automatic=Resolve-SgFlutterAndroidDevice 'flutter.bat' '' 'ShipGlows_API_36' $autoRunner {param($ms)} 2
        if($automatic-ne'emulator-5554'){throw 'ShipGlows Android emulator was not launched and selected when no device was connected.'}

        $fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-settings-{0}" -f [guid]::NewGuid().ToString('N'))
        try {
            New-Item -ItemType Directory -Path (Join-Path $fixture 'config') -Force | Out-Null
            [IO.File]::WriteAllText((Join-Path $fixture 'config\defines.json'), '{"API_URL":"private-value"}')
            [IO.File]::WriteAllText((Join-Path $fixture '.shipglows.env'), "SHIPGLOWS_FLUTTER_DEVICE=web-server`nSHIPGLOWS_DART_DEFINE_FILE=config/defines.json`n")
            $settings = Get-SgRuntimeSettings $fixture
            if ($settings.FlutterDevice -ne 'web-server' -or $settings.DartDefineFile -ne (Join-Path $fixture 'config\defines.json')) { throw 'Durable Flutter settings were not resolved safely.' }
            $defined = Get-SgLaunchSpec $fixture 'flutter-web' 3010 $false '' $settings.FlutterDevice $settings.DartDefineFile $launch 'ShipGlowsFlutter-launch-123'
            $definedArguments = $defined.Arguments -join ' '
            if (-not $definedArguments.Contains('-DartDefineFile') -or $definedArguments.Contains('private-value')) { throw 'Dart defines must be passed by file path without leaking values.' }
            [IO.File]::WriteAllText((Join-Path $fixture '.shipglows.env'), "SHIPGLOWS_FLUTTER_DEVICE=android`nSHIPGLOWS_FLUTTER_DEVICE_ID=phone-1`n")
            $androidSettings=Get-SgRuntimeSettings $fixture
            if($androidSettings.FlutterDevice-ne'android'-or$androidSettings.FlutterDeviceId-ne'phone-1'){throw 'Explicit Android development target settings drifted.'}
            [IO.File]::WriteAllText((Join-Path $fixture '.shipglows.env'), 'SHIPGLOWS_DART_DEFINE_FILE=../outside.json')
            try { [void](Get-SgRuntimeSettings $fixture); throw 'Traversal in Dart define path was accepted.' } catch { if ($_.Exception.Message -eq 'Traversal in Dart define path was accepted.') { throw } }
        } finally { Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue }

        $windowsFixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-windows-{0}" -f [guid]::NewGuid().ToString('N'))
        try {
            New-Item -ItemType Directory -Path (Join-Path $windowsFixture 'windows'),(Join-Path $windowsFixture 'desktop') -Force | Out-Null
            [IO.File]::WriteAllText((Join-Path $windowsFixture 'shipglows-dev.cmd'),'@exit /b 0')
            if ((Get-SgRuntimeSettings $windowsFixture).FlutterDevice -ne 'windows') { throw 'A Flutter Windows surface did not default to live Windows development.' }
            $devEntry=[pscustomobject]@{kind='flutter-web';flutterDevice='windows';name='Fixture';path=$windowsFixture}
            $shortcutPath=Install-SgFlutterDevShortcut $devEntry (Join-Path $windowsFixture 'desktop') (Join-Path $windowsFixture 'shipglows-dev.cmd')
            $shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($shortcutPath)
            if ($shortcut.Arguments -notmatch '^start -ProjectPath ' -or $shortcut.TargetPath -ne (Join-Path $windowsFixture 'shipglows-dev.cmd')) { throw 'Flutter Dev shortcut does not route to the managed live start command.' }
        } finally { Remove-Item -LiteralPath $windowsFixture -Recurse -Force -ErrorAction SilentlyContinue }

        $script:openCalls = @()
        $script:realSupervisorCommand=${function:Invoke-SgFlutterSupervisorCommand}
        function Invoke-SgFlutterSupervisorCommand { param($Entry,$Method,$Timeout) if($Entry.PSObject.Properties['flutterTokenPath']){return & $script:realSupervisorCommand $Entry $Method $Timeout};$script:openCalls += "ipc:$Method"; [pscustomobject]@{ok=$true} }
        function Test-SgProcessIdentity { $false }
        function Wait-SgFlutterOwnedExtinction { param($Entry,$Timeout) $script:openCalls += "wait:$Timeout"; $true }
        function Stop-SgOwnedFlutterListener { $script:openCalls += 'stop-listener'; $false }
        function Stop-SgOwnedFlutterBrowser { $script:openCalls += 'stop-browser'; $false }
        function Remove-SgFlutterLaunchArtifacts { $script:openCalls += 'remove-artifacts'; $true }
        function Stop-SgProject { param($Config,$Path) $script:openCalls += "stop:$Path"; $true }
        function Start-SgProject { param($Config,$Path,$Port,[switch]$FlutterVisible) $script:openCalls += "start:${Path}:${Port}:$([bool]$FlutterVisible)"; [pscustomobject]@{status='running'} }
        $entry = [pscustomobject]@{kind='flutter-web';status='running';port=3010;path='C:\workspace\app';flutterHeadless=$true;flutterDevice='chrome'}
        [void](Open-SgProject ([pscustomobject]@{}) $entry)
        if (($script:openCalls -join '|') -ne 'ipc:open|stop-listener|stop-browser|wait:8|remove-artifacts|start:C:\workspace\app:3010:True') { throw 'Explicit open did not promote the headless Flutter session through proven owned-process extinction.' }

        $script:openCalls=@()
        $visibleEntry=[pscustomobject]@{kind='flutter-web';status='running';port=3010;path='C:\workspace\app';flutterHeadless=$false;flutterDevice='chrome'}
        $sameVisibleEntry=Open-SgProject ([pscustomobject]@{}) $visibleEntry
        if(-not[object]::ReferenceEquals($sameVisibleEntry,$visibleEntry)-or$script:openCalls.Count-ne0){throw 'Open restarted or duplicated an already-visible managed Flutter session.'}
        $script:openCalls=@();$script:clock=[datetime]'2026-08-17T10:00:00Z'
        function Test-SgProcessIdentity { $true }
        function Get-Date { $script:clock=$script:clock.AddSeconds(9);$script:clock }
        try{[void](Open-SgProject ([pscustomobject]@{}) $entry);throw 'Slow supervisor open was accepted.'}catch{if($_.Exception.Message -eq 'Slow supervisor open was accepted.'){throw}}
        if(@($script:openCalls|Where-Object{$_ -like 'start:*'}).Count -ne 0){throw 'Open relaunched visible Flutter before proving supervisor extinction.'}
        function Get-Date { Microsoft.PowerShell.Utility\Get-Date }

        $ipcRoot=Join-Path ([IO.Path]::GetTempPath()) ("sg-ipc-timeout-{0}" -f [guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $ipcRoot,(Join-Path $ipcRoot 'commands'),(Join-Path $ipcRoot 'responses') -Force|Out-Null
        try{Protect-SgOwnerOnlyPath $ipcRoot;Protect-SgOwnerOnlyPath (Join-Path $ipcRoot 'commands');Protect-SgOwnerOnlyPath (Join-Path $ipcRoot 'responses');$tokenPath=Join-Path $ipcRoot 'token';[IO.File]::WriteAllText($tokenPath,('a'*64));Protect-SgOwnerOnlyPath $tokenPath;$ipcEntry=[pscustomobject]@{flutterLaunchDirectory=$ipcRoot;flutterTokenPath=$tokenPath};try{[void](Invoke-SgFlutterSupervisorCommand $ipcEntry reload 0);throw 'IPC timeout was accepted.'}catch{if($_.Exception.Message -eq 'IPC timeout was accepted.'){throw}};if(@(Get-ChildItem (Join-Path $ipcRoot 'commands') -File).Count-ne0){throw 'Timed-out IPC command file was left published.'}}finally{Remove-Item -LiteralPath $ipcRoot -Recurse -Force -ErrorAction SilentlyContinue}
    }
    $source = Get-Content -LiteralPath $modulePath -Raw
    foreach($expected in @('Invoke-CimMethod -ClassName Win32_Process -MethodName Create','-RedirectStandardOutput','-RedirectStandardError','-PassThru -Wait -WindowStyle Hidden','ShowWindow=[uint16]0')){if(-not$source.Contains($expected)){throw 'Managed detached launches must redirect logs and hide the process window.'}}
    $supervisorSource = Get-Content -LiteralPath (Join-Path (Split-Path $modulePath) 'ShipGlows.FlutterSupervisor.ps1') -Raw
    foreach ($expected in @("'run','--machine','-d'",'--web-run-headless','--web-hostname','--web-port','--dart-define-from-file=','app.restart')) { if (-not $supervisorSource.Contains($expected)) { throw "Flutter supervisor launch contract is missing: $expected" } }
    Write-Host 'Windows DevServer Flutter background launch: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
