$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$supervisorPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.FlutterSupervisor.ps1'))
. $supervisorPath -TestMode

$flutterRoot='C:\validated flutter';$packageConfig=Join-Path $flutterRoot 'packages\flutter_tools\.dart_tool\package_config.json';$snapshot=Join-Path $flutterRoot 'bin\cache\flutter_tools.snapshot'
$hostArgs=@(New-SgFlutterHostArguments $flutterRoot $snapshot @('run','--machine'))
if($hostArgs[0] -cne "--packages=$packageConfig" -or $hostArgs[1] -cne $snapshot){throw 'Direct Flutter host argv does not match flutter.bat bootstrap requirements.'}
$headlessRunArgs=@(New-SgFlutterRunArguments 'chrome' 3010 'C:\managed chrome profile' $false)
foreach($expected in @('run','--machine','-d','chrome','--web-hostname','127.0.0.1','--web-port','3010','--web-run-headless','--web-browser-flag=--user-data-dir=C:\managed chrome profile')){if($expected-notin$headlessRunArgs){throw "Background Flutter launch is missing: $expected"}}
$visibleRunArgs=@(New-SgFlutterRunArguments 'chrome' 3010 'C:\managed chrome profile' $true)
if('--web-run-headless'-in$visibleRunArgs){throw 'Visible Flutter launch still requests a headless browser.'}
foreach($expected in @('run','--machine','-d','chrome','--web-hostname','127.0.0.1','--web-port','3010','--web-browser-flag=--user-data-dir=C:\managed chrome profile')){if($expected-notin$visibleRunArgs){throw "Visible Flutter launch is missing: $expected"}}
if(@($visibleRunArgs|Where-Object{$_-match'localhost'}).Count-ne0){throw 'Visible Flutter launch advertised localhost instead of 127.0.0.1.'}
$webServerRunArgs=@(New-SgFlutterRunArguments 'web-server' 3010 '' $false)
if('--web-run-headless'-in$webServerRunArgs-or@($webServerRunArgs|Where-Object{$_-like'--web-browser-flag=*'}).Count-ne0){throw 'Explicit web-server mode inherited Chrome-only arguments.'}
$savedLocalAppData=$env:LOCALAPPDATA;$savedChromeExecutable=$env:CHROME_EXECUTABLE;$browserFixture=Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-browser-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    $env:LOCALAPPDATA=$browserFixture;$managedBrowser=Join-Path $browserFixture 'ms-playwright\chromium-1234\chrome-win64\chrome.exe';New-Item -ItemType Directory -Path (Split-Path $managedBrowser -Parent) -Force|Out-Null;New-Item -ItemType File -Path $managedBrowser -Force|Out-Null;$env:CHROME_EXECUTABLE=$managedBrowser
    if((Resolve-SgFlutterChromeExecutable 'chrome')-cne[IO.Path]::GetFullPath($managedBrowser)){throw 'Flutter supervisor did not resolve the managed Playwright Chromium executable.'}
    $externalBrowser=Join-Path $browserFixture 'external\chrome.exe';New-Item -ItemType Directory -Path (Split-Path $externalBrowser -Parent) -Force|Out-Null;New-Item -ItemType File -Path $externalBrowser -Force|Out-Null;$env:CHROME_EXECUTABLE=$externalBrowser
    try{[void](Resolve-SgFlutterChromeExecutable 'chrome');throw 'Flutter supervisor accepted a browser outside the managed Playwright runtime.'}catch{if($_.Exception.Message-eq'Flutter supervisor accepted a browser outside the managed Playwright runtime.'){throw}}
    if((Resolve-SgFlutterChromeExecutable 'web-server')-ne''){throw 'Flutter web-server mode unexpectedly required Chromium.'}
} finally {$env:LOCALAPPDATA=$savedLocalAppData;$env:CHROME_EXECUTABLE=$savedChromeExecutable;Remove-Item -LiteralPath $browserFixture -Recurse -Force -ErrorAction SilentlyContinue}
$fixture=New-Object Diagnostics.Process;$fixture.StartInfo.FileName=(Join-Path $PSHOME 'powershell.exe');$fixture.StartInfo.Arguments='-NoProfile -Command "[Console]::Out.WriteLine(''machine-line''); [Console]::Error.WriteLine(''error-line'')"';$fixture.StartInfo.UseShellExecute=$false;$fixture.StartInfo.RedirectStandardOutput=$true;$fixture.StartInfo.RedirectStandardError=$true
try{[void]$fixture.Start();$pump=New-SgFlutterStreamPump $fixture;$outQueue=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$errQueue=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$deadline=(Get-Date).AddSeconds(5);do{Pump-SgFlutterStreams $pump $outQueue $errQueue;if(-not$outQueue.IsEmpty-and-not$errQueue.IsEmpty){break};Start-Sleep -Milliseconds 20}while((Get-Date)-lt$deadline);$line=$null;if(-not$outQueue.TryDequeue([ref]$line)-or$line-ne'machine-line'){throw 'PS5.1 stream pump did not receive stdout.'};if(-not$errQueue.TryDequeue([ref]$line)-or$line-ne'error-line'){throw 'PS5.1 stream pump did not receive stderr.'}}finally{if(-not$fixture.HasExited){$fixture.Kill()};$fixture.Dispose()}
$eofPayload=Join-Path ([IO.Path]::GetTempPath()) ("sg-eof-{0}.txt" -f [guid]::NewGuid().ToString('N'));[IO.File]::WriteAllText($eofPayload,'{"id":77,"result":{}}')
$eof=New-Object Diagnostics.Process;$eof.StartInfo.FileName=(Join-Path $env:SystemRoot 'System32\cmd.exe');$eof.StartInfo.Arguments="/d /c type `"$eofPayload`"";$eof.StartInfo.UseShellExecute=$false;$eof.StartInfo.RedirectStandardOutput=$true;$eof.StartInfo.RedirectStandardError=$true
try{[void]$eof.Start();$pump=New-SgFlutterStreamPump $eof;$oq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$eq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$eof.WaitForExit();if(-not(Drain-SgFlutterStreams $pump $oq $eq 2)){throw 'EOF stream drain did not complete.'};$line=$null;$state=New-SgFlutterProtocolState;if(-not$oq.TryDequeue([ref]$line)){throw 'Final stdout line was lost at EOF.'};Update-SgFlutterProtocolState $state $line;if($state.LastResponseId-ne77-or-not$state.LastResponseOk){throw 'Correlated Flutter response immediately before EOF was lost.'}}finally{if(-not$eof.HasExited){$eof.Kill()};$eof.Dispose();Remove-Item -LiteralPath $eofPayload -Force -ErrorAction SilentlyContinue}

$bulkScript=Join-Path ([IO.Path]::GetTempPath()) ("sg-bulk-{0}.ps1" -f [guid]::NewGuid().ToString('N'));[IO.File]::WriteAllText($bulkScript,'for($i=0;$i -lt 1200;$i++){[Console]::Out.WriteLine("o$i");[Console]::Error.WriteLine("e$i")}')
$bulk=New-Object Diagnostics.Process;$bulk.StartInfo.FileName=(Join-Path $PSHOME 'powershell.exe');$bulk.StartInfo.Arguments="-NoProfile -File `"$bulkScript`"";$bulk.StartInfo.UseShellExecute=$false;$bulk.StartInfo.RedirectStandardOutput=$true;$bulk.StartInfo.RedirectStandardError=$true
try{[void]$bulk.Start();$pump=New-SgFlutterStreamPump $bulk;$oq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$eq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$deadline=(Get-Date).AddSeconds(10);while(-not$bulk.HasExited-and(Get-Date)-lt$deadline){Pump-SgFlutterStreams $pump $oq $eq;Start-Sleep -Milliseconds 5};if(-not$bulk.HasExited){throw 'Bulk fixture did not exit.'};if(-not(Drain-SgFlutterStreams $pump $oq $eq 5)-or$oq.Count-ne1200-or$eq.Count-ne1200){throw 'EOF drain lost a backlog larger than 1000 lines.'}}finally{if(-not$bulk.HasExited){$bulk.Kill();$bulk.WaitForExit()};$bulk.Dispose();Remove-Item -LiteralPath $bulkScript -Force -ErrorAction SilentlyContinue}
$killScript=Join-Path ([IO.Path]::GetTempPath()) ("sg-kill-{0}.ps1" -f [guid]::NewGuid().ToString('N'));[IO.File]::WriteAllText($killScript,'for($i=0;$i -lt 1200;$i++){[Console]::Out.WriteLine("k$i")};Start-Sleep 30')
$killed=New-Object Diagnostics.Process;$killed.StartInfo.FileName=(Join-Path $PSHOME 'powershell.exe');$killed.StartInfo.Arguments="-NoProfile -File `"$killScript`"";$killed.StartInfo.UseShellExecute=$false;$killed.StartInfo.RedirectStandardOutput=$true;$killed.StartInfo.RedirectStandardError=$true
try{[void]$killed.Start();$pump=New-SgFlutterStreamPump $killed;$oq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$eq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';Start-Sleep -Milliseconds 500;$killed.Kill();$killed.WaitForExit();if(-not(Drain-SgFlutterStreams $pump $oq $eq 5)-or$oq.Count-le0){throw 'Post-kill drain lost buffered stdout.'}}finally{if(-not$killed.HasExited){$killed.Kill();$killed.WaitForExit()};$killed.Dispose();Remove-Item -LiteralPath $killScript -Force -ErrorAction SilentlyContinue}

$continuousScript=Join-Path ([IO.Path]::GetTempPath()) ("sg-continuous-{0}.ps1" -f [guid]::NewGuid().ToString('N'));[IO.File]::WriteAllText($continuousScript,'while($true){[Console]::Out.WriteLine("o");[Console]::Error.WriteLine("e")}')
$continuous=New-Object Diagnostics.Process;$continuous.StartInfo.FileName=(Join-Path $PSHOME 'powershell.exe');$continuous.StartInfo.Arguments="-NoProfile -File `"$continuousScript`"";$continuous.StartInfo.UseShellExecute=$false;$continuous.StartInfo.RedirectStandardOutput=$true;$continuous.StartInfo.RedirectStandardError=$true
try{[void]$continuous.Start();$pump=New-SgFlutterStreamPump $continuous;$oq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$eq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';Start-Sleep -Milliseconds 300;$clock=[Diagnostics.Stopwatch]::StartNew();Pump-SgFlutterStreams $pump $oq $eq 64;$clock.Stop();if($clock.ElapsedMilliseconds-gt1000-or($oq.Count+$eq.Count)-gt64){throw 'Continuous producer made the stream pump unbounded.'}}finally{if(-not$continuous.HasExited){$continuous.Kill();$continuous.WaitForExit()};$continuous.Dispose();Remove-Item -LiteralPath $continuousScript -Force -ErrorAction SilentlyContinue}

Assert-SgFlutterSafeValue 'C:\workspace with space\app' 'project path'
foreach ($unsafe in @("bad`npath",'bad"path',[string]([char]0))) {
    try { Assert-SgFlutterSafeValue $unsafe 'test'; throw 'Unsafe supervisor value was accepted.' } catch { if ($_.Exception.Message -eq 'Unsafe supervisor value was accepted.') { throw } }
}

$token = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
$machineRequest=New-SgFlutterMachineRequestJson 88 'app.restart' 'app-watch'
if(-not$machineRequest.StartsWith('[')-or-not$machineRequest.EndsWith(']')){throw 'Flutter machine request was not serialized as a top-level JSON array.'}
$parsedMachineRequest=$machineRequest|ConvertFrom-Json
if($parsedMachineRequest-isnot[array]-or$parsedMachineRequest.Count-ne1-or$parsedMachineRequest[0].method-ne'app.restart'){throw 'Flutter machine request array schema is invalid.'}
$valid = ConvertFrom-SgFlutterCommandJson '{"token":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","id":"cmd-1","method":"reload"}' $token
if ($valid.Method -ne 'reload' -or $valid.Id -ne 'cmd-1') { throw 'Valid authenticated reload command was rejected.' }
foreach ($json in @(
    '{"token":"wrong","id":"cmd-1","method":"reload"}',
    '{"token":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","id":"../escape","method":"reload"}',
    '{"token":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","id":"cmd-1","method":"restart"}',
    '{"token":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","id":"cmd-1","method":"status"}',
    '{"token":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","id":"cmd-1","method":"reload","extra":true}',
    '{"token":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","id":1,"method":"reload"}',
    '{broken'
)) {
    try { [void](ConvertFrom-SgFlutterCommandJson $json $token); throw 'Malformed supervisor command was accepted.' } catch { if ($_.Exception.Message -eq 'Malformed supervisor command was accepted.') { throw } }
}

$aclFixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-acl-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $aclFixture -Force | Out-Null
    Protect-SgFlutterOwnerOnlyPath $aclFixture
    if (-not (Test-SgFlutterOwnerOnlyPath $aclFixture)) { throw 'Supervisor launch directory ACL is not explicit owner-only.' }
    $tokenFile = Join-Path $aclFixture 'token'; [IO.File]::WriteAllText($tokenFile,$token)
    Protect-SgFlutterOwnerOnlyPath $tokenFile
    if (-not (Test-SgFlutterOwnerOnlyPath $tokenFile)) { throw 'Supervisor token ACL is not explicit owner-only.' }
} finally { Remove-Item -LiteralPath $aclFixture -Recurse -Force -ErrorAction SilentlyContinue }
$reparseRoot = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-reparse-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    $target=Join-Path $reparseRoot 'target';$link=Join-Path $reparseRoot 'link';New-Item -ItemType Directory -Path $target -Force|Out-Null
    & cmd.exe /d /c "mklink /J `"$link`" `"$target`"" | Out-Null
    if($LASTEXITCODE -eq 0){try{Assert-SgFlutterNoReparsePath $link;throw 'Reparse launch path was accepted.'}catch{if($_.Exception.Message -eq 'Reparse launch path was accepted.'){throw}}}
} finally { if(Test-Path -LiteralPath $link){& cmd.exe /d /c "rmdir `"$link`""|Out-Null};Remove-Item -LiteralPath $reparseRoot -Recurse -Force -ErrorAction SilentlyContinue }
try { [void](ConvertFrom-SgFlutterCommandJson ('x' * 65537) $token); throw 'Oversized supervisor command was accepted.' } catch { if ($_.Exception.Message -eq 'Oversized supervisor command was accepted.') { throw } }

$clock = [datetime]'2026-08-17T10:00:00Z'
$debounce = New-SgFlutterDebounceState
Register-SgFlutterChange $debounce $clock
if (Test-SgFlutterDebounceReady $debounce $clock) { throw 'Reload debounce fired immediately.' }
Register-SgFlutterChange $debounce $clock.AddMilliseconds(300)
if (Test-SgFlutterDebounceReady $debounce $clock.AddMilliseconds(700)) { throw 'Reload debounce ignored the most recent change.' }
if (-not (Test-SgFlutterDebounceReady $debounce $clock.AddMilliseconds(850))) { throw 'Reload debounce did not fire after the quiet period.' }
Complete-SgFlutterDebounce $debounce
if (Test-SgFlutterDebounceReady $debounce $clock.AddSeconds(2)) { throw 'Completed debounce fired twice.' }

$watchRoot=Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-watch-{0}" -f [guid]::NewGuid().ToString('N'));$watcher=$null
try {
    $nested=Join-Path $watchRoot 'nested';New-Item -ItemType Directory -Path $nested -Force|Out-Null
    $watcher=New-SgFlutterChangeWatcher $watchRoot
    $watchState=New-SgFlutterDebounceState
    $dartFile=Join-Path $nested 'main.dart';[IO.File]::WriteAllText($dartFile,'void main() {}')
    $deadline=(Get-Date).AddSeconds(3);do{$detected=Pump-SgFlutterChanges $watcher $watchState 32;if($detected-gt0){break};Start-Sleep -Milliseconds 20}while((Get-Date)-lt$deadline)
    if($detected-lt1-or-not$watchState.Pending){throw 'Synchronous Flutter watcher did not detect a nested Dart change.'}
    1..20|ForEach-Object{[IO.File]::WriteAllText((Join-Path $nested ("f$_.dart")),'void f() {}')}
    $floodClock=[Diagnostics.Stopwatch]::StartNew();$count=Pump-SgFlutterChanges $watcher $watchState 8;$floodClock.Stop()
    if($count-ne8-or$floodClock.ElapsedMilliseconds-gt1000){throw 'Flutter watcher pump was not bounded and fair.'}
    if(-not(Test-SgFlutterDebounceReady $watchState ([datetime]::UtcNow.AddSeconds(1)))){throw 'Detected Dart change did not become reload-ready.'}
    $reloadScript=Join-Path $watchRoot 'reload-fixture.ps1';[IO.File]::WriteAllText($reloadScript,'$line=[Console]::In.ReadLine();$request=$line|ConvertFrom-Json;if($request -isnot [array] -or $request.Count -ne 1 -or $request[0].method -ne ''app.restart''){exit 9};[Console]::Out.WriteLine(''[{"id":88,"result":{"code":0}}]'');Start-Sleep -Milliseconds 200')
    $reload=New-Object Diagnostics.Process;$reload.StartInfo.FileName=(Join-Path $PSHOME 'powershell.exe');$reload.StartInfo.Arguments="-NoProfile -File `"$reloadScript`"";$reload.StartInfo.UseShellExecute=$false;$reload.StartInfo.RedirectStandardInput=$true;$reload.StartInfo.RedirectStandardOutput=$true;$reload.StartInfo.RedirectStandardError=$true
    try{[void]$reload.Start();$reloadPump=New-SgFlutterStreamPump $reload;$roq=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$req=New-Object 'Collections.Concurrent.ConcurrentQueue[string]';$reloadState=New-SgFlutterProtocolState;Send-SgFlutterMachineRequest $reload 88 'app.restart' 'app-watch';[void](Wait-SgFlutterMachineResponse $reload $reloadPump $roq $req $reloadState (Join-Path $watchRoot 'reload.log') 88 3);if($reloadState.LastResponseId-ne88-or-not$reloadState.LastResponseOk){throw 'Watcher-triggered app.restart response was not correlated.'}}finally{if(-not$reload.HasExited){$reload.Kill();$reload.WaitForExit()};$reload.Dispose()}
} finally { if($watcher){$watcher.Dispose()};Remove-Item -LiteralPath $watchRoot -Recurse -Force -ErrorAction SilentlyContinue }

$state = New-SgFlutterProtocolState
Update-SgFlutterProtocolState $state '{"event":"app.start","params":{"appId":"app-1"}}'
Update-SgFlutterProtocolState $state '{"event":"app.started","params":{"appId":"other"}}'
if ($state.Ready) { throw 'Mismatched app.started marked the supervisor ready.' }
Update-SgFlutterProtocolState $state '{"event":"app.started","params":{"appId":"app-1"}}'
if (-not $state.Ready -or $state.AppId -ne 'app-1') { throw 'Matching app.started did not mark the supervisor ready.' }
Update-SgFlutterProtocolState $state '{"id":7,"result":{"code":0,"message":"Reloaded"}}'
if ($state.LastResponseId -ne 7 -or -not $state.LastResponseOk) { throw 'Machine response correlation was not recorded.' }
Update-SgFlutterProtocolState $state '{"id":8,"error":{"code":-32000,"message":"sensitive detail"}}'
if ($state.LastResponseId -ne 8 -or $state.LastResponseOk -or $state.LastError -match 'sensitive detail') { throw 'Machine response errors were not redacted and correlated.' }
$arrayState=New-SgFlutterProtocolState
Update-SgFlutterProtocolState $arrayState '[{"event":"daemon.connected","params":{"pid":4321}}]'
Update-SgFlutterProtocolState $arrayState '[{"event":"app.start","params":{"appId":"app-array"}}]'
Update-SgFlutterProtocolState $arrayState '[{"event":"app.started","params":{"appId":"app-array"}}]'
Update-SgFlutterProtocolState $arrayState '[{"id":91,"result":{"code":0}}]'
if(-not$arrayState.Ready-or$arrayState.Status-ne'running'-or$arrayState.AppId-ne'app-array'-or$arrayState.DaemonPid-ne4321-or$arrayState.LastResponseId-ne91-or-not$arrayState.LastResponseOk){throw 'Real Flutter JSON array envelopes were not flattened into protocol state.'}
foreach($ambiguous in @('[[{"event":"app.started","params":{"appId":"x"}}]]','[1]','[]')){try{[void](ConvertFrom-SgFlutterMachineEnvelope $ambiguous);throw 'Ambiguous Flutter machine envelope was accepted.'}catch{if($_.Exception.Message-eq'Ambiguous Flutter machine envelope was accepted.'){throw}}}

$claimRoot = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-claim-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $claimRoot -Force | Out-Null
    $published = Join-Path $claimRoot 'cmd-claim.json'
    $claimJson=[ordered]@{token=$token;id='cmd-claim';method='reload'}|ConvertTo-Json -Compress
    [IO.File]::WriteAllText($published,$claimJson)
    $claimed = Claim-SgFlutterCommandFile (Get-Item -LiteralPath $published)
    if (-not $claimed -or (Test-Path -LiteralPath $published) -or -not (Test-Path -LiteralPath $claimed)) { throw 'Supervisor did not atomically claim the published command.' }
    Remove-Item -LiteralPath $published -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path -LiteralPath $claimed)) { throw 'Client timeout cleanup removed a command already claimed by the supervisor.' }
    try { [void](ConvertFrom-SgFlutterCommandJson '{broken' $token) } catch {}
    Remove-Item -LiteralPath $claimed -Force -ErrorAction SilentlyContinue
    $next = Join-Path $claimRoot 'cmd-next.json'; [IO.File]::WriteAllText($next,$claimJson)
    if (-not (Claim-SgFlutterCommandFile (Get-Item -LiteralPath $next))) { throw 'Supervisor command loop could not claim a command after a prior processing failure.' }
} finally { Remove-Item -LiteralPath $claimRoot -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host 'Windows Flutter supervisor protocol: OK'
