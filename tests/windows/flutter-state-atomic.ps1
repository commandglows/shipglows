$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$supervisorPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.FlutterSupervisor.ps1'))
. $supervisorPath -TestMode

$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-flutter-state-{0}" -f [guid]::NewGuid().ToString('N'))
$lockerScript = Join-Path $fixture 'locker.ps1'
try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    $statePath = Join-Path $fixture 'state.json'
    [IO.File]::WriteAllText($statePath, '{"sequence":0}')
    [IO.File]::WriteAllText($lockerScript, @'
param([string]$Path,[string]$ReadyPath)
$stream=[IO.File]::Open($Path,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite)
try{[IO.File]::WriteAllText($ReadyPath,'ready');Start-Sleep -Milliseconds 350}finally{$stream.Dispose()}
'@)

    $readyPath = Join-Path $fixture 'locker.ready'
    $currentPowerShell = (Get-Process -Id $PID).Path
    $lockerStart = [Diagnostics.ProcessStartInfo]::new()
    $lockerStart.FileName = $currentPowerShell
    $lockerStart.UseShellExecute = $false
    $lockerStart.CreateNoWindow = $true
    foreach($argument in @('-NoProfile','-File',$lockerScript,$statePath,$readyPath)){[void]$lockerStart.ArgumentList.Add($argument)}
    $locker = [Diagnostics.Process]::Start($lockerStart)
    try {
        $deadline=(Get-Date).AddSeconds(5)
        while(-not(Test-Path -LiteralPath $readyPath)){if((Get-Date)-ge$deadline){throw 'Transient lock fixture did not become ready.'};Start-Sleep -Milliseconds 20}
        Write-SgFlutterJsonAtomic $statePath ([ordered]@{sequence=1;status='running'})
    } finally { if(-not$locker.HasExited){$locker.Kill();$locker.WaitForExit()};$locker.Dispose() }

    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    if($state.sequence-ne1-or$state.status-ne'running'){throw 'Released transient lock did not publish one valid atomic state.'}
    if(@(Get-ChildItem -LiteralPath $fixture -Filter 'state.json.*.tmp' -File).Count-ne0-or@(Get-ChildItem -LiteralPath $fixture -Filter 'state.json.*.bak' -File).Count-ne0){throw 'Successful atomic state write left temporary files.'}

    $deleteSharingReader=[IO.File]::Open($statePath,[IO.FileMode]::Open,[IO.FileAccess]::Read,([IO.FileShare]::ReadWrite-bor[IO.FileShare]::Delete))
    try{Write-SgFlutterJsonAtomic $statePath ([ordered]@{sequence=2;reader='delete-sharing'}) 200 20}finally{$deleteSharingReader.Dispose()}
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    if($state.sequence-ne2-or$state.reader-ne'delete-sharing'){throw 'Delete-sharing reader blocked atomic replacement.'}

    $persistent=[IO.File]::Open($statePath,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite)
    try {
        $clock=[Diagnostics.Stopwatch]::StartNew();$threw=$false
        try{Write-SgFlutterJsonAtomic $statePath ([ordered]@{sequence=3}) 200 20}catch{$threw=$true}
        $clock.Stop()
        if(-not$threw){throw 'Persistent sharing violation was swallowed.'}
        if($clock.ElapsedMilliseconds-lt150-or$clock.ElapsedMilliseconds-gt2000){throw "Persistent sharing violation was not bounded: $($clock.ElapsedMilliseconds) ms."}
    } finally {$persistent.Dispose()}
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    if($state.sequence-ne2){throw 'Failed replacement damaged the last valid atomic state.'}
    if(@(Get-ChildItem -LiteralPath $fixture -Filter 'state.json.*.tmp' -File).Count-ne0-or@(Get-ChildItem -LiteralPath $fixture -Filter 'state.json.*.bak' -File).Count-ne0){throw 'Failed atomic state write left temporary files.'}

    $nonSharingPath=Join-Path (Join-Path $fixture 'missing-parent') 'state.json'
    $clock=[Diagnostics.Stopwatch]::StartNew();$threw=$false
    try{Write-SgFlutterJsonAtomic $nonSharingPath ([ordered]@{sequence=4}) 2000 100}catch{$threw=$true}
    $clock.Stop()
    if(-not$threw-or$clock.ElapsedMilliseconds-ge500){throw "Non-sharing I/O failure was retried: $($clock.ElapsedMilliseconds) ms."}

    Write-Host "Windows Flutter atomic state sharing on $currentPowerShell`: OK"
} finally {Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue}
