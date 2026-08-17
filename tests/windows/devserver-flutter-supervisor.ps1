$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$supervisorPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.FlutterSupervisor.ps1'))
. $supervisorPath -TestMode

Assert-SgFlutterSafeValue 'C:\workspace with space\app' 'project path'
foreach ($unsafe in @("bad`npath",'bad"path',[string]([char]0))) {
    try { Assert-SgFlutterSafeValue $unsafe 'test'; throw 'Unsafe supervisor value was accepted.' } catch { if ($_.Exception.Message -eq 'Unsafe supervisor value was accepted.') { throw } }
}

$token = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
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
