$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
Import-Module (Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1') -Force -DisableNameChecking
& (Get-Module ShipGlows.DevServer) {
    function Assert-Snapshot($Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
    $script:queries = @()
    $script:processes = @([pscustomobject]@{Id=101;Path='C:\runtime\worker.exe';StartTime=[datetime]'2026-09-05T00:00:00Z'})
    $script:cimRows = @([pscustomobject]@{ProcessId=101;ExecutablePath='C:\runtime\worker.exe';CommandLine='worker --owned-token'})
    function Get-Process { param($Id, $ErrorAction) $script:processes | Where-Object { $_.Id -in $Id } }
    function Get-CimInstance {
        param($ClassName, $Filter, $Property, $ErrorAction)
        $script:queries += $Filter
        $script:cimRows | Where-Object { $Filter -match "ProcessId = $($_.ProcessId)(?:\D|$)" }
    }
    $entry = [pscustomobject]@{pid=101;startTimeUtc='2026-09-05T00:00:00Z';executablePath='C:\runtime\worker.exe';commandSignature=$null}
    $map = Get-SgProcessSnapshotMap @(101,101,0,-1,999) -CommandLinePids @()
    Assert-Snapshot ($script:queries.Count -eq 0) 'Unsigned native identity must not query CIM.'
    Assert-Snapshot ($map.Count -eq 1 -and (Test-SgProcessIdentity $entry $map)) 'Native identity must remain verifiable; missing PIDs must stay absent.'
    $entry.executablePath='C:\foreign.exe'
    Assert-Snapshot (-not (Test-SgProcessIdentity $entry $map)) 'Wrong executable must fail.'
    $entry.executablePath='C:\runtime\worker.exe'; $entry.startTimeUtc='2026-09-05T00:00:01Z'
    Assert-Snapshot (-not (Test-SgProcessIdentity $entry $map)) 'Reused PID with another start time must fail.'
    $entry.startTimeUtc='2026-09-05T00:00:00Z'; $entry.commandSignature='owned-token'
    $map = Get-SgProcessSnapshotMap @(101) -CommandLinePids @(101)
    Assert-Snapshot ($script:queries.Count -eq 1 -and (Test-SgProcessIdentity $entry $map)) 'Required signature must query CIM and match.'
    $script:processes += [pscustomobject]@{Id=102;Path='C:\runtime\other.exe';StartTime=[datetime]'2026-09-05T00:00:00Z'}
    $script:cimRows += [pscustomobject]@{ProcessId=102;ExecutablePath='C:\runtime\other.exe';CommandLine='other'}
    $mixed=Get-SgProcessSnapshotMap @(101,102) -CommandLinePids @(101)
    Assert-Snapshot ($mixed.Count -eq 2 -and $script:queries[-1] -eq 'ProcessId = 101') 'Only required PIDs may enter the CIM batch.'
    $full=Get-SgProcessSnapshotMap @(101,102)
    Assert-Snapshot ($full[101].CommandLine -and $full[102].CommandLine) 'Existing callers without the selector retain full snapshots.'
    $entry.commandSignature='foreign-token'
    Assert-Snapshot (-not (Test-SgProcessIdentity $entry $map)) 'Mismatched command signature must fail.'
    $script:cimRows=@()
    $map=Get-SgProcessSnapshotMap @(101) -CommandLinePids @(101)
    Assert-Snapshot (-not (Test-SgProcessIdentity $entry $map)) 'Unavailable required command line must fail closed.'
    $entry.commandSignature=$null
    $script:processes[0] | Add-Member -MemberType ScriptProperty -Name Path -Value { throw 'Access denied' } -Force
    $script:cimRows=@([pscustomobject]@{ProcessId=101;ExecutablePath='C:\runtime\worker.exe';CommandLine='worker'})
    $before=$script:queries.Count
    $map=Get-SgProcessSnapshotMap @(101) -CommandLinePids @()
    Assert-Snapshot ($script:queries.Count -eq $before+1 -and (Test-SgProcessIdentity $entry $map)) 'Unreadable native path must fall back to CIM.'
    $script:cimRows=@()
    $map=Get-SgProcessSnapshotMap @(101) -CommandLinePids @()
    Assert-Snapshot (-not (Test-SgProcessIdentity $entry $map)) 'Unavailable required executable must fail closed.'
    $script:processes=@()
    $before=$script:queries.Count
    $map=Get-SgProcessSnapshotMap @(101) -CommandLinePids @(101)
    Assert-Snapshot ($map.Count -eq 0 -and $script:queries.Count -eq $before) 'Exited processes must not query CIM or appear live.'
}
Write-Output 'PASS: conditional CIM, PID reuse, executable, signatures, denied access, exited processes.'
