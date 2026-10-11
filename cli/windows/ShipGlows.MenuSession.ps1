[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RequestPath,
    [switch]$Wait
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# This channel carries one menu key and process identities, never credentials
# or commands. Every artifact is a fixed sibling under the user's temp root.
$request = [IO.Path]::GetFullPath($RequestPath)
$temporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
if ([IO.Path]::GetDirectoryName($request) -ine $temporaryRoot -or
    [IO.Path]::GetFileName($request) -cnotmatch '^shipglows-menu-[0-9]{1,5}-[0-9]{1,5}\.request$') { exit 70 }
$stem = $request.Substring(0, $request.Length - '.request'.Length)
$artifacts = @($request, "$request.new", "$stem.worker", "$stem.worker.new", "$stem.done", "$stem.done.new", "$stem.accepted", "$stem.selection", "$stem.validated")
foreach ($path in $artifacts) {
    if ([IO.File]::Exists($path) -and ([IO.File]::GetAttributes($path) -band [IO.FileAttributes]::ReparsePoint)) { exit 70 }
}
$managedRoot = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell\7.6.5\win-x64')).TrimEnd('\')
$hostPath = [IO.Path]::GetFullPath((Get-Process -Id $PID).Path)
if ($PSVersionTable.PSEdition -ne 'Core' -or $hostPath -ine (Join-Path $managedRoot 'pwsh.exe') -or
    $env:SHIPGLOWS_MANAGED_PWSH -ine $hostPath) { exit 70 }

function Remove-SgMenuSessionArtifacts {
    foreach ($path in $artifacts) {
        if ([IO.File]::Exists($path) -and -not ([IO.File]::GetAttributes($path) -band [IO.FileAttributes]::ReparsePoint)) {
            [IO.File]::Delete($path)
        }
    }
}

function Read-SgMenuSessionExitCode {
    if (-not [IO.File]::Exists("$stem.done")) { return 70 }
    $text = [IO.File]::ReadAllText("$stem.done").Trim()
    if ($text -notmatch '^[0-9]{1,3}$' -or [int]$text -gt 255) { return 70 }
    return [int]$text
}

if ($Wait) {
    $worker = $null
    $code = 70
    try {
        $deadline = [DateTime]::UtcNow.AddSeconds(10)
        while (-not [IO.File]::Exists("$stem.worker") -and -not [IO.File]::Exists("$stem.done")) {
            if ([DateTime]::UtcNow -ge $deadline) {
                # A late initializer must observe cancellation, not replay the
                # user's selection while the ordinary fallback starts.
                [IO.File]::WriteAllText($request, '0', [Text.Encoding]::ASCII)
                exit 70
            }
            Start-Sleep -Milliseconds 20
        }
        if ([IO.File]::Exists("$stem.worker")) {
            $identity = [IO.File]::ReadAllText("$stem.worker")
            if ($identity -notmatch '^([0-9]+) ([0-9]+)$') { throw 'Invalid menu session process identity.' }
            $workerId = [int]$Matches[1]
            $workerTicks = [long]$Matches[2]
            try { $worker = Get-Process -Id $workerId -ErrorAction Stop } catch { $worker = $null }
            if ($worker) {
                if ($worker.StartTime.ToUniversalTime().Ticks -ne $workerTicks) { throw 'Menu session process identity changed.' }
                $worker.WaitForExit()
            }
        }
        $code = Read-SgMenuSessionExitCode
        if ($code -eq 70 -and [IO.File]::Exists("$stem.accepted")) { $code = 1 }
    } catch {
        $code = if ([IO.File]::Exists("$stem.accepted")) { 1 } else { 70 }
        if ($code -eq 70) { [IO.File]::WriteAllText($request, '0', [Text.Encoding]::ASCII) }
    }
    finally {
        if ($worker) { $worker.Dispose() }
        # A timeout must not erase a request that a late worker still needs.
        if ([IO.File]::Exists("$stem.done")) { Remove-SgMenuSessionArtifacts }
    }
    exit $code
}

$parent = $null
$pipe = $null
$connection = $null
$code = 70
try {
    $parentId = [int](Get-CimInstance Win32_Process -Filter "ProcessId = $PID" -Property ParentProcessId).ParentProcessId
    $parent = Get-Process -Id $parentId -ErrorAction Stop
    $parentTicks = $parent.StartTime.ToUniversalTime().Ticks
    if ([IO.Path]::GetFileName($parent.Path) -ine 'cmd.exe') { throw 'A menu session requires its dedicated command frontend.' }
    # This pipe transfers no payload. The frontend reads until close to wait
    # for the session without starting another PowerShell host.
    $pipeOptions = [IO.Pipes.PipeOptions]::Asynchronous -bor [IO.Pipes.PipeOptions]::CurrentUserOnly
    $pipe = [IO.Pipes.NamedPipeServerStream]::new([IO.Path]::GetFileName($stem), [IO.Pipes.PipeDirection]::Out, 1, [IO.Pipes.PipeTransmissionMode]::Byte, $pipeOptions)
    $connection = $pipe.WaitForConnectionAsync()
    $identity = "$PID $((Get-Process -Id $PID).StartTime.ToUniversalTime().Ticks)"
    $marker = [IO.File]::Open("$stem.worker.new", [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try {
        $bytes = [Text.Encoding]::ASCII.GetBytes($identity)
        $marker.Write($bytes, 0, $bytes.Length)
    } finally { $marker.Dispose() }
    [IO.File]::Move("$stem.worker.new", "$stem.worker")
    $global:LASTEXITCODE = 0
    & (Join-Path $PSScriptRoot 'shipglows-devserver.ps1') -MenuSessionRequestPath $request -MenuSessionParentId $parentId -MenuSessionParentStartTicks $parentTicks
    # A normal script return succeeds even when its last external tool failed;
    # an explicit `exit N` sets invocation success false and supplies N.
    $backendSucceeded = $?
    $code = if ($backendSucceeded) { 0 } else { [int]$LASTEXITCODE }
    if ($code -lt 0 -or $code -gt 255 -or ($code -eq 70 -and [IO.File]::Exists("$stem.accepted"))) { $code = 1 }
} catch {
    # Keep initialization errors silent while the native selector owns the
    # console. Its foreground fallback supplies the ordinary error surface.
    $code = if ([IO.File]::Exists("$stem.accepted")) { 1 } else { 70 }
} finally {
    [IO.File]::WriteAllText("$stem.done.new", ([string]$code + "`r`n"), [Text.Encoding]::ASCII)
    [IO.File]::Move("$stem.done.new", "$stem.done")
    $nativeQuit = [IO.File]::Exists($request) -and [IO.File]::ReadAllText($request).Trim() -ceq '0'
    $parentGone = -not $parent -or $parent.HasExited
    if ($pipe) {
        if ($connection -and -not $connection.IsCompleted -and -not $nativeQuit -and -not $parentGone) {
            # The exceptional foreground waiter may use the process handle
            # rather than connect. Never leave completion waiting indefinitely.
            try { [void]$connection.Wait(500) } catch { }
        }
        $pipe.Dispose()
    }
    if ($nativeQuit -or $parentGone) { Remove-SgMenuSessionArtifacts }
    if ($parent) { $parent.Dispose() }
}
exit $code
