# registry.lock contention: a waiter names the holder, start survives a busy registry after
# readiness, and reconciliation probes run outside the lock.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-registry-lock-{0}" -f [guid]::NewGuid().ToString('N'))
$surface = Join-Path $fixture 'site'; $runtime = Join-Path $fixture 'runtime'; $logs = Join-Path $runtime 'logs'
$holderScript = Join-Path $fixture 'holder.ps1'
$holders = @()
function Start-LockHolder([int]$Seconds) {
    $process = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList @('-NoProfile','-NonInteractive','-File',"`"$holderScript`"","`"$modulePath`"","`"$runtime`"",$Seconds) -WindowStyle Hidden -PassThru
    $ownerPath = Join-Path $runtime 'registry.lock.owner.json'
    $deadline = (Get-Date).AddSeconds(30)
    while (-not (Test-Path -LiteralPath $ownerPath)) {
        if ($process.HasExited -or (Get-Date) -ge $deadline) { throw 'The lock holder never recorded itself.' }
        Start-Sleep -Milliseconds 50
    }
    return $process
}
try {
    New-Item -ItemType Directory -Path $surface,$runtime,$logs -Force | Out-Null
    Set-Content (Join-Path $surface 'package.json') '{"devDependencies":{"vite":"latest"},"scripts":{"dev":"vite"}}' -Encoding UTF8
    Set-Content $holderScript @'
param($ModulePath,$Runtime,$Seconds)
Import-Module $ModulePath -Force -DisableNameChecking
$config = [pscustomobject]@{RuntimeDirectory=$Runtime;RegistryPath=(Join-Path $Runtime 'registry.json');LockPath=(Join-Path $Runtime 'registry.lock')}
& (Get-Module ShipGlows.DevServer) { param($Config,$Seconds) Invoke-SgRegistryMutation $Config { Start-Sleep -Seconds ([int]$Seconds) } | Out-Null } $config $Seconds
'@ -Encoding UTF8
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer
    $config = [pscustomobject]@{Workspace=$fixture;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock');LogDirectory=$logs;PortStart=32400;PortEnd=32409;LockTimeoutSeconds=1}

    # A waiter that times out names the live holder instead of the raw .NET sharing violation.
    $holder = Start-LockHolder 4; $holders += $holder
    $message = $null
    try { & $module { param($Config) Invoke-SgRegistryMutation $Config { } | Out-Null } $config } catch { $message = $_.Exception.Message }
    if (-not $message -or $message -notmatch "held by pid $($holder.Id)\b" -or $message -notmatch 'holder\.ps1') { throw "Lock timeout did not name its holder: $message" }
    if (-not $holder.WaitForExit(20000)) { throw 'The lock holder did not exit.' }
    if (Test-Path -LiteralPath (Join-Path $runtime 'registry.lock.owner.json')) { throw 'The lock holder left its owner record behind.' }

    # A registry still busy after readiness warns and keeps the started application running.
    [void](Write-SgProjectEnvironment $surface 32405)
    $started = & $module {
        param($Config,$Surface,$StartHolder)
        $script:warnings = @()
        function Test-SgPortAvailable { $true }
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { [pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='mock-signature';Interactive=$false} }
        function Start-SgDetachedProcess { [pscustomobject]@{Id=77;CommandSignature='mock-signature'} }
        function Get-SgProcessSnapshot { [pscustomobject]@{Pid=77;StartTimeUtc='2026-10-27T00:00:00Z';ExecutablePath='mock.exe';CommandLine='mock-signature'} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 77 }
        function Wait-SgProjectReady { $script:lateHolder = & $StartHolder 6; [pscustomobject]@{ Ready=$true; AppId=$null; Error=$null } }
        function Start-SgManagedProcessExitMonitor { }
        function Install-SgDevShortcut { }
        function Write-SgWarn([string]$Message) { $script:warnings += $Message }
        $result = Start-SgProjectCore $Config $Surface
        [pscustomobject]@{ Result=$result; Warnings=@($script:warnings); Holder=$script:lateHolder }
    } $config $surface ${function:Start-LockHolder}
    $holders += $started.Holder
    if ($started.Result.status -ne 'running') { throw "A busy registry after readiness changed the start result: $($started.Result.status)" }
    if (-not ($started.Warnings -match 'Retrying once') -or -not ($started.Warnings -match 'still pending')) { throw "A busy registry after readiness was not reported as a retried warning: $($started.Warnings -join ' | ')" }
    if (-not $started.Holder.WaitForExit(20000)) { throw 'The late lock holder did not exit.' }

    # The next reconciliation records the running session; its HTTP probe runs once and outside the lock.
    $reconciled = & $module {
        param($Config)
        $script:httpCalls = 0; $script:httpUnlocked = 0
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 77 }
        function Get-SgListeningTcpPortSet { $null }
        function Test-SgHttpReady {
            $script:httpCalls++
            try { $handle = [IO.File]::Open($Config.LockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None); $handle.Dispose(); $script:httpUnlocked++ } catch { }
            $true
        }
        $registry = Reconcile-SgRegistry $Config
        [pscustomobject]@{ Registry=$registry; Calls=$script:httpCalls; Unlocked=$script:httpUnlocked }
    } $config
    $stored = @($reconciled.Registry.projects | Where-Object { $_.path -eq (ConvertTo-SgCanonicalPath $surface) }) | Select-Object -First 1
    if (-not $stored -or $stored.status -ne 'running' -or $stored.reservationToken) { throw 'Reconciliation did not record the session started during a busy registry.' }
    if ($reconciled.Calls -ne 1 -or $reconciled.Unlocked -ne 1) { throw "Reconciliation probed under the lock or twice (calls=$($reconciled.Calls), unlocked=$($reconciled.Unlocked))." }
    Write-Host 'devserver-registry-lock: ok'
} finally {
    foreach ($process in @($holders | Where-Object { $_ })) { if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue } }
    Remove-Module ShipGlows.DevServer -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
