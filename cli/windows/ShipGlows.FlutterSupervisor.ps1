param(
    [switch]$TestMode,
    [string]$LaunchDirectory,
    [string]$ProjectPath,
    [string]$FlutterPath,
    [int]$Port,
    [string]$ProfilePath,
    [string]$LaunchIdentity,
    [switch]$Visible,
    [ValidateSet('chrome','web-server')][string]$Device = 'chrome',
    [string]$DartDefineFile = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-SgFlutterSafeValue([string]$Value, [string]$Label) {
    if ([string]::IsNullOrWhiteSpace($Value) -or $Value.Length -gt 32768 -or $Value.IndexOf([char]0) -ge 0 -or $Value -match '[\r\n"]') { throw "Unsafe $Label." }
}

function Assert-SgFlutterNoReparsePath([string]$Path) {
    $currentPath=[IO.Path]::GetFullPath($Path)
    while($currentPath){$current=Get-Item -LiteralPath $currentPath -Force -ErrorAction Stop;if($current.Attributes -band [IO.FileAttributes]::ReparsePoint){throw "Reparse points are forbidden in Flutter supervisor paths: $Path"};$parent=Split-Path $currentPath -Parent;if(-not$parent-or$parent-eq$currentPath){break};$currentPath=$parent}
}

function Protect-SgFlutterOwnerOnlyPath([string]$Path) {
    Assert-SgFlutterNoReparsePath $Path
    $sid=[Security.Principal.WindowsIdentity]::GetCurrent().User
    $acl=Get-Acl -LiteralPath $Path
    $acl.SetAccessRuleProtection($true,$false)
    foreach($rule in @($acl.Access)){$acl.RemoveAccessRuleAll($rule)}
    $inheritance=if((Get-Item -LiteralPath $Path -Force).PSIsContainer){[Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'}else{[Security.AccessControl.InheritanceFlags]::None}
    $rule=New-Object Security.AccessControl.FileSystemAccessRule($sid,[Security.AccessControl.FileSystemRights]::FullControl,$inheritance,[Security.AccessControl.PropagationFlags]::None,[Security.AccessControl.AccessControlType]::Allow)
    $acl.AddAccessRule($rule);Set-Acl -LiteralPath $Path -AclObject $acl
}

function Test-SgFlutterOwnerOnlyPath([string]$Path) {
    try{Assert-SgFlutterNoReparsePath $Path;$acl=Get-Acl -LiteralPath $Path;$sid=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value;$allowed=@($acl.Access|Where-Object{$_.AccessControlType -eq 'Allow'});return [bool]($acl.AreAccessRulesProtected -and $allowed.Count -eq 1 -and $allowed[0].IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value -eq $sid -and (($allowed[0].FileSystemRights -band [Security.AccessControl.FileSystemRights]::FullControl) -eq [Security.AccessControl.FileSystemRights]::FullControl))}catch{return $false}
}

function ConvertTo-SgWindowsArgument([string]$Value) {
    Assert-SgFlutterSafeValue $Value 'process argument'
    if ($Value -notmatch '[\s\\]') { return $Value }
    $escaped = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function ConvertFrom-SgFlutterCommandJson([string]$Json, [string]$ExpectedToken) {
    if ($Json.Length -gt 65536) { throw 'Supervisor command exceeds 64 KiB.' }
    try { $command = $Json | ConvertFrom-Json -ErrorAction Stop } catch { throw 'Malformed supervisor command JSON.' }
    if (-not $command -or $command -is [array]) { throw 'Malformed supervisor command schema.' }
    $names=@($command.PSObject.Properties.Name);$unknown=@($names|Where-Object{$_ -notin @('token','id','method')});$missing=@(@('token','id','method')|Where-Object{$_ -notin $names});if($unknown.Count -gt 0 -or $missing.Count -gt 0){throw 'Malformed supervisor command schema.'}
    if ($command.token -isnot [string] -or [string]$command.token -cne $ExpectedToken) { throw 'Supervisor command authentication failed.' }
    if($command.id -isnot[string] -or $command.method -isnot[string]){throw 'Malformed supervisor command schema.'};$id = [string]$command.id
    if ($id -notmatch '^[A-Za-z0-9-]{1,64}$') { throw 'Invalid supervisor command id.' }
    $method = [string]$command.method
    if ($method -notin @('reload','stop','open')) { throw 'Unsupported supervisor command method.' }
    return [pscustomobject]@{ Id=$id; Method=$method }
}

function Claim-SgFlutterCommandFile([IO.FileInfo]$CommandFile) {
    if (-not $CommandFile -or -not $CommandFile.Exists -or $CommandFile.Extension -ne '.json') { return $null }
    $claimed = "$($CommandFile.FullName).processing"
    try { Move-Item -LiteralPath $CommandFile.FullName -Destination $claimed -ErrorAction Stop; return $claimed } catch { return $null }
}

function New-SgFlutterDebounceState { [pscustomobject]@{ Pending=$false; LastChangeUtc=$null; QuietMilliseconds=500 } }
function Register-SgFlutterChange([object]$State, [datetime]$AtUtc) { $State.Pending=$true; $State.LastChangeUtc=$AtUtc.ToUniversalTime() }
function Test-SgFlutterDebounceReady([object]$State, [datetime]$AtUtc) { return [bool]($State.Pending -and $State.LastChangeUtc -and ($AtUtc.ToUniversalTime() - $State.LastChangeUtc).TotalMilliseconds -ge [int]$State.QuietMilliseconds) }
function Complete-SgFlutterDebounce([object]$State) { $State.Pending=$false; $State.LastChangeUtc=$null }

function New-SgFlutterProtocolState {
    [pscustomobject]@{ Status='starting'; AppId=$null; DaemonPid=0; Ready=$false; LastError=$null; LastResponseId=$null; LastResponseOk=$null; UpdatedAtUtc=[datetime]::UtcNow.ToString('o') }
}

function Update-SgFlutterProtocolState([object]$State, [string]$Line) {
    if ([string]::IsNullOrWhiteSpace($Line) -or $Line.Length -gt 1048576) { return }
    try { $messages = @($Line | ConvertFrom-Json -ErrorAction Stop) } catch { return }
    foreach ($message in $messages) {
        if ($message.PSObject.Properties['id'] -and $null -ne $message.id) { $State.LastResponseId=[int]$message.id;$State.LastResponseOk=-not[bool]$message.PSObject.Properties['error'];if(-not$State.LastResponseOk){$State.LastError='Flutter machine request failed.'};continue }
        if (-not $message.PSObject.Properties['event'] -or -not $message.PSObject.Properties['params']) { continue }
        $params = $message.params
        switch ([string]$message.event) {
            'daemon.connected' { if ($params.pid -as [int]) { $State.DaemonPid=[int]$params.pid } }
            'app.start' { if ([string]$params.appId -match '^[A-Za-z0-9._-]{1,256}$') { $State.AppId=[string]$params.appId; $State.Status='starting' } }
            'app.started' { if ($State.AppId -and [string]$params.appId -ceq [string]$State.AppId) { $State.Ready=$true; $State.Status='running'; $State.LastError=$null } }
            'app.stop' { if ($State.AppId -and [string]$params.appId -ceq [string]$State.AppId) { $State.Ready=$false; $State.Status='stopped'; if ($params.PSObject.Properties['error'] -and $params.error) { $State.Status='error'; $State.LastError='Flutter reported an application error.' } } }
        }
    }
    $State.UpdatedAtUtc=[datetime]::UtcNow.ToString('o')
}

function Write-SgFlutterJsonAtomic([string]$Path, [object]$Value) {
    $json = $Value | ConvertTo-Json -Depth 8 -Compress
    $temp = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
    [IO.File]::WriteAllText($temp,$json,(New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath $temp -Destination $Path -Force
}

function Send-SgFlutterMachineRequest([Diagnostics.Process]$Process, [int]$Id, [string]$Method, [string]$AppId) {
    $params = [ordered]@{appId=$AppId}
    if ($Method -eq 'app.restart') { $params.fullRestart=$false; $params.pause=$false; $params.reason='ShipGlows source change'; $params.debounce=$true }
    $request = @([ordered]@{id=$Id;method=$Method;params=$params}) | ConvertTo-Json -Depth 5 -Compress
    $Process.StandardInput.WriteLine($request)
    $Process.StandardInput.Flush()
}

function Wait-SgFlutterMachineResponse([Diagnostics.Process]$Process,[Collections.Concurrent.ConcurrentQueue[string]]$Queue,[object]$State,[string]$LogPath,[int]$RequestId,[int]$TimeoutSeconds=10) {
    $deadline=(Get-Date).AddSeconds($TimeoutSeconds);$line=$null
    while((Get-Date)-lt $deadline){while($Queue.TryDequeue([ref]$line)){[IO.File]::AppendAllText($LogPath,$line+[Environment]::NewLine);Update-SgFlutterProtocolState $State $line;if($State.LastResponseId -eq $RequestId){if(-not$State.LastResponseOk){throw 'Flutter machine request failed.'};return $true}};if($Process.HasExited){throw 'Flutter exited while waiting for a machine response.'};Start-Sleep -Milliseconds 50}
    throw 'Flutter machine response timed out.'
}

function Invoke-SgFlutterSupervisor {
    foreach ($item in @(@($LaunchDirectory,'launch directory'),@($ProjectPath,'project path'),@($FlutterPath,'Flutter path'),@($LaunchIdentity,'launch identity'))) { Assert-SgFlutterSafeValue ([string]$item[0]) ([string]$item[1]) }
    if ($Port -lt 1024 -or $Port -gt 65535) { throw 'Invalid Flutter web port.' }
    $token = [string]$env:SHIPGLOWS_SUPERVISOR_TOKEN
    if ($token -notmatch '^[a-f0-9]{64}$') { throw 'Missing or invalid supervisor token.' }
    Remove-Item Env:SHIPGLOWS_SUPERVISOR_TOKEN -ErrorAction SilentlyContinue
    $launchRoot=[IO.Path]::GetFullPath($LaunchDirectory); $projectRoot=[IO.Path]::GetFullPath($ProjectPath)
    New-Item -ItemType Directory -Path $launchRoot -Force | Out-Null;Assert-SgFlutterNoReparsePath $launchRoot
    if(-not(Test-SgFlutterOwnerOnlyPath $launchRoot)){throw 'Flutter supervisor launch directory ACL is not owner-only.'}
    $statePath=Join-Path $launchRoot 'state.json'; $commandDir=Join-Path $launchRoot 'commands'; $responseDir=Join-Path $launchRoot 'responses'
    New-Item -ItemType Directory -Path $commandDir,$responseDir -Force | Out-Null;Protect-SgFlutterOwnerOnlyPath $commandDir;Protect-SgFlutterOwnerOnlyPath $responseDir
    $stdoutPath=Join-Path $launchRoot 'flutter.stdout.log'; $stderrPath=Join-Path $launchRoot 'flutter.stderr.log'

    $flutterRoot=Split-Path (Split-Path $FlutterPath -Parent) -Parent
    $dart=Join-Path $flutterRoot 'bin\cache\dart-sdk\bin\dart.exe'; $snapshot=Join-Path $flutterRoot 'bin\cache\flutter_tools.snapshot'
    if (-not (Test-Path -LiteralPath $dart -PathType Leaf) -or -not (Test-Path -LiteralPath $snapshot -PathType Leaf)) { throw 'Validated Flutter Dart host files are missing.' }
    $args=@($snapshot,'run','--machine','-d',$Device,'--web-hostname','127.0.0.1','--web-port',[string]$Port)
    if ($Device -eq 'chrome') { Assert-SgFlutterSafeValue $ProfilePath 'browser profile path'; if (-not $Visible) {$args+='--web-run-headless'}; $args+="--web-browser-flag=--user-data-dir=$ProfilePath" }
    if ($DartDefineFile) { Assert-SgFlutterSafeValue $DartDefineFile 'Dart define file path'; $args+="--dart-define-from-file=$DartDefineFile" }
    $psi=New-Object Diagnostics.ProcessStartInfo
    $psi.FileName=$dart; $psi.Arguments=(@($args | ForEach-Object { ConvertTo-SgWindowsArgument ([string]$_) }) -join ' '); $psi.WorkingDirectory=$projectRoot
    $psi.UseShellExecute=$false; $psi.CreateNoWindow=$true; $psi.RedirectStandardInput=$true; $psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true
    $process=New-Object Diagnostics.Process; $process.StartInfo=$psi; $process.EnableRaisingEvents=$true
    $outQueue=New-Object 'Collections.Concurrent.ConcurrentQueue[string]'; $errQueue=New-Object 'Collections.Concurrent.ConcurrentQueue[string]'
    $outputHandler={param($s,$e) if($null-ne $e.Data){$outQueue.Enqueue([string]$e.Data)}}.GetNewClosure()
    $errorHandler={param($s,$e) if($null-ne $e.Data){$errQueue.Enqueue([string]$e.Data)}}.GetNewClosure()
    $process.add_OutputDataReceived($outputHandler);$process.add_ErrorDataReceived($errorHandler)
    if (-not $process.Start()) { throw 'Flutter host process could not start.' }
    $process.BeginOutputReadLine(); $process.BeginErrorReadLine()
    $state=New-SgFlutterProtocolState; $state | Add-Member SupervisorPid $PID; $state | Add-Member FlutterPid $process.Id; $state | Add-Member BrowserProfilePath $ProfilePath; $state | Add-Member Visible ([bool]$Visible)
    Write-SgFlutterJsonAtomic $statePath $state
    $watcher=$null; $changes=New-SgFlutterDebounceState
    $changeQueue=New-Object 'Collections.Concurrent.ConcurrentQueue[string]'
    $lib=Join-Path $projectRoot 'lib'
    if (Test-Path -LiteralPath $lib -PathType Container) { $watcher=New-Object IO.FileSystemWatcher($lib,'*.dart');$watcher.IncludeSubdirectories=$true;$changeHandler={param($s,$e)$changeQueue.Enqueue([string]$e.FullPath)}.GetNewClosure();$watcher.add_Changed($changeHandler);$watcher.add_Created($changeHandler);$watcher.add_Renamed($changeHandler);$watcher.add_Deleted($changeHandler);$watcher.EnableRaisingEvents=$true }
    $requestId=1000; $stopRequested=$false
    try {
        while (-not $process.HasExited) {
            $line=$null; $changed=$null
            while($outQueue.TryDequeue([ref]$line)){[IO.File]::AppendAllText($stdoutPath,$line+[Environment]::NewLine);Update-SgFlutterProtocolState $state $line;Write-SgFlutterJsonAtomic $statePath $state}
            while($errQueue.TryDequeue([ref]$line)){[IO.File]::AppendAllText($stderrPath,$line+[Environment]::NewLine)}
            while($changeQueue.TryDequeue([ref]$changed)){Register-SgFlutterChange $changes ([datetime]::UtcNow)}
            $nowUtc = [datetime]::UtcNow
            if($state.Ready -and (Test-SgFlutterDebounceReady $changes $nowUtc)){ $requestId++;try{Send-SgFlutterMachineRequest $process $requestId 'app.restart' $state.AppId;[void](Wait-SgFlutterMachineResponse $process $outQueue $state $stdoutPath $requestId 10)}catch{$state.LastError=$_.Exception.Message};Complete-SgFlutterDebounce $changes;Write-SgFlutterJsonAtomic $statePath $state }
            foreach($commandFile in @(Get-ChildItem -LiteralPath $commandDir -Filter '*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name)){
                $claimedPath=Claim-SgFlutterCommandFile $commandFile
                if(-not $claimedPath){continue}
                $response=[ordered]@{ok=$false;error='Invalid command.'}
                try { $claimed=Get-Item -LiteralPath $claimedPath -ErrorAction Stop;if($claimed.Length -gt 65536){throw 'Supervisor command exceeds 64 KiB.'};$command=ConvertFrom-SgFlutterCommandJson ([IO.File]::ReadAllText($claimedPath)) $token;$response=[ordered]@{ok=$true;method=$command.Method}
                    if($command.Method -eq 'reload'){if(-not $state.Ready){throw 'Flutter application is not ready.'};$requestId++;Send-SgFlutterMachineRequest $process $requestId 'app.restart' $state.AppId;[void](Wait-SgFlutterMachineResponse $process $outQueue $state $stdoutPath $requestId 10)}
                    elseif($command.Method -in @('stop','open')){if($state.AppId){$requestId++;Send-SgFlutterMachineRequest $process $requestId 'app.stop' $state.AppId;[void](Wait-SgFlutterMachineResponse $process $outQueue $state $stdoutPath $requestId 10)};$stopRequested=$true}
                } catch {$response=[ordered]@{ok=$false;error=$_.Exception.Message}}
                try{Write-SgFlutterJsonAtomic (Join-Path $responseDir ($commandFile.BaseName+'.json')) $response}finally{Remove-Item -LiteralPath $claimedPath -Force -ErrorAction SilentlyContinue}
            }
            if($stopRequested){if(-not $process.WaitForExit(5000)){$process.Kill()};break}
            Start-Sleep -Milliseconds 100
        }
    } finally { if($watcher){$watcher.Dispose()}; if(-not $process.HasExited){$process.Kill()};$state.Ready=$false;if($state.Status -notin @('stopped','error')){$state.Status=if($stopRequested){'stopped'}else{'error'};$state.LastError=if($stopRequested){$null}else{'Flutter host process exited unexpectedly.'}};Write-SgFlutterJsonAtomic $statePath $state;$process.Dispose() }
}

if (-not $TestMode) { Invoke-SgFlutterSupervisor }
