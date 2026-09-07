param([Parameter(Mandatory)][string]$PayloadPath)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'ShipGlows.DevServer.psm1') -Force -DisableNameChecking
$payload = Get-Content -LiteralPath $PayloadPath -Raw | ConvertFrom-Json
# This script and its child belong to the same kill-on-close Windows Job.
$info = New-Object Diagnostics.ProcessStartInfo
$info.FileName=$payload.Executable
$info.WorkingDirectory=$payload.ProjectPath
$info.UseShellExecute=$false
$info.CreateNoWindow=$true
foreach ($argument in $payload.Arguments) { $info.ArgumentList.Add([string]$argument) }
$child = [Diagnostics.Process]::Start($info)
$attached=$false
$module=Get-Module ShipGlows.DevServer
$mutexName=& $module { param($Payload) 'Local\ShipGlowsBackend-' + (Get-SgBackendDigest ($Payload.Config.RegistryPath + $Payload.ProjectPath.ToLowerInvariant())) } $payload
$mutex=New-Object Threading.Mutex($false,$mutexName)
try {
    while ($true) {
        Start-Sleep -Seconds 1
        $locked=$false
        try {
            try { $locked=$mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $locked=$true }
            if (-not $locked) { continue }
            $entry=@((Read-SgRegistry $payload.Config).projects | Where-Object { $_.path -eq $payload.ProjectPath }) | Select-Object -First 1
            $matches=$entry -and $entry.PSObject.Properties['backend'] -and $entry.backend.instanceId -eq $payload.InstanceId
            if ($matches) {
                $attached=$true
                $module=Get-Module ShipGlows.DevServer
                $healthy=& $module { param($Readiness) Test-SgBackendReady $Readiness } $payload.Readiness
                if (-not $healthy -or $child.HasExited) {
                    [void](Stop-SgProject $payload.Config $payload.ProjectPath -PreserveBackend)
                    & $module {
                        param($Payload)
                        Invoke-SgRegistryMutation $Payload.Config { param($data)
                            $entry=@($data.projects | Where-Object { $_.path -eq $Payload.ProjectPath }) | Select-Object -First 1
                            if ($entry -and $entry.PSObject.Properties['backend'] -and $entry.backend.instanceId -eq $Payload.InstanceId) {
                                $entry.status='error'; $entry.lastError='Required local backend lost readiness.'; $entry.backend.status='error'
                            }
                        } | Out-Null
                    } $payload
                    return
                }
                if ($entry.status -notin @('running','starting','reserved')) { return }
                $appAlive=& $module { param($Entry) Test-SgProcessIdentity $Entry } $entry
                if (-not $appAlive) { return }
            } elseif ($attached) { return }
            elseif ($child.HasExited) { return }
            elseif (-not (& $module { param($Owner) Test-SgProcessIdentity $Owner } $payload.Owner)) { return }
        } finally { if ($locked) { $mutex.ReleaseMutex() } }
    }
} finally { if (-not $child.HasExited) { $child.Kill($true) }; $child.Dispose(); $mutex.Dispose() }
