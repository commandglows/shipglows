$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    $module = Get-Module ShipGlows.DevServer
    & $module {
        function Get-SgCommandPath { 'C:\flutter\bin\flutter.bat' }
        $profile = 'C:\runtime\flutter\app\launch-123'
        $launch = 'C:\runtime\flutter\launch-123'
        $spec = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $false $profile 'chrome' '' $launch 'ShipGlowsFlutter-launch-123'
        if ($spec.Interactive) { throw 'Flutter Web launch must be managed in the background.' }
        $arguments = $spec.Arguments -join ' '
        foreach ($expected in @('ShipGlows.FlutterSupervisor.ps1','-LaunchDirectory','-ProjectPath','-FlutterPath','-Port 3010','-Device chrome','-LaunchIdentity ShipGlowsFlutter-launch-123')) {
            if (-not $arguments.Contains($expected)) { throw "Flutter Web managed launch is missing: $expected" }
        }
        $visible = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $true $profile 'chrome' '' $launch 'ShipGlowsFlutter-launch-123'
        if (($visible.Arguments -join ' ') -notmatch '(?:^|\s)-Visible(?:\s|$)') { throw 'Explicit Flutter open must promote to a visible browser session.' }
        $webServer = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010 $false '' 'web-server' '' $launch 'ShipGlowsFlutter-launch-123'
        if (($webServer.Arguments -join ' ') -notmatch '-Device web-server' -or ($webServer.Arguments -join ' ') -match '-ProfilePath') { throw 'Flutter web-server must remain an explicit advanced mode.' }

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
            [IO.File]::WriteAllText((Join-Path $fixture '.shipglows.env'), 'SHIPGLOWS_DART_DEFINE_FILE=../outside.json')
            try { [void](Get-SgRuntimeSettings $fixture); throw 'Traversal in Dart define path was accepted.' } catch { if ($_.Exception.Message -eq 'Traversal in Dart define path was accepted.') { throw } }
        } finally { Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue }

        $script:openCalls = @()
        $script:realSupervisorCommand=${function:Invoke-SgFlutterSupervisorCommand}
        function Invoke-SgFlutterSupervisorCommand { param($Entry,$Method,$Timeout) if($Entry.PSObject.Properties['flutterTokenPath']){return & $script:realSupervisorCommand $Entry $Method $Timeout};$script:openCalls += "ipc:$Method"; [pscustomobject]@{ok=$true} }
        function Test-SgProcessIdentity { $false }
        function Stop-SgProject { param($Config,$Path) $script:openCalls += "stop:$Path"; $true }
        function Start-SgProject { param($Config,$Path,$Port,[switch]$FlutterVisible) $script:openCalls += "start:${Path}:${Port}:$([bool]$FlutterVisible)"; [pscustomobject]@{status='running'} }
        $entry = [pscustomobject]@{kind='flutter-web';status='running';port=3010;path='C:\workspace\app';flutterHeadless=$true;flutterDevice='chrome'}
        [void](Open-SgProject ([pscustomobject]@{}) $entry)
        if (($script:openCalls -join '|') -ne 'ipc:open|start:C:\workspace\app:3010:True') { throw 'Explicit open did not promote the headless Flutter session safely.' }
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
    if ($source -notmatch [regex]::Escape('-RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Hidden')) { throw 'Managed launches must redirect logs and hide the process window.' }
    $supervisorSource = Get-Content -LiteralPath (Join-Path (Split-Path $modulePath) 'ShipGlows.FlutterSupervisor.ps1') -Raw
    foreach ($expected in @("'run','--machine','-d'",'--web-run-headless','--web-hostname','--web-port','--dart-define-from-file=','app.restart')) { if (-not $supervisorSource.Contains($expected)) { throw "Flutter supervisor launch contract is missing: $expected" } }
    Write-Host 'Windows DevServer Flutter background launch: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
