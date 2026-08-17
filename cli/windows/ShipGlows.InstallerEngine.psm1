Set-StrictMode -Version Latest

function New-SgInstallerOperation {
    param(
        [Parameter(Mandatory=$true)][string]$Id,
        [Parameter(Mandatory=$true)][string]$Label,
        [int]$TimeoutSeconds = 60
    )
    if ($Id -notmatch '^[a-z0-9]+(?:[._-][a-z0-9]+)*$') { throw "Invalid installer operation id: $Id" }
    if ([string]::IsNullOrWhiteSpace($Label) -or $Label -match '[\r\n\0]') { throw 'Installer operation label is invalid.' }
    if ($TimeoutSeconds -lt 1 -or $TimeoutSeconds -gt 7200) { throw 'Installer operation timeout must be between 1 and 7200 seconds.' }
    [pscustomobject]@{ Id=$Id; Label=$Label.Trim(); TimeoutSeconds=$TimeoutSeconds }
}

function New-SgInstallerEvent {
    param([string]$Code,[object]$Operation,[int]$ElapsedSeconds,[string]$Detail='',[int]$Tick=0)
    [pscustomobject]@{
        Code = $Code
        OperationId = [string]$Operation.Id
        Label = [string]$Operation.Label
        ElapsedSeconds = [Math]::Max(0,$ElapsedSeconds)
        Tick = [Math]::Max(0,$Tick)
        Detail = $Detail
    }
}

function Invoke-SgInstallerEventSink([scriptblock]$EventSink,[object]$Event) {
    if ($EventSink) { & $EventSink $Event }
}

function Invoke-SgInstallerOperation {
    param(
        [Parameter(Mandatory=$true)][object]$Operation,
        [Parameter(Mandatory=$true)][scriptblock]$Runner,
        [scriptblock]$EventSink
    )
    $watch = [Diagnostics.Stopwatch]::StartNew()
    Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_STARTED' $Operation 0)
    try {
        $progressState = [pscustomobject]@{ Tick=0 }
        $progress = {
            param([int]$ElapsedSeconds)
            $progressState.Tick += 1
            Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_PROGRESS' $Operation $ElapsedSeconds -Tick $progressState.Tick)
        }
        $result = & $Runner $progress
        $elapsed = [int][Math]::Floor($watch.Elapsed.TotalSeconds)
        if (-not $result) { throw 'Installer operation runner returned no result.' }
        if ([bool]$result.TimedOut) {
            Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_TIMED_OUT' $Operation $elapsed ([string]$result.Output))
        } elseif ([int]$result.ExitCode -ne 0) {
            Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_FAILED' $Operation $elapsed ([string]$result.Output))
        } else {
            Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_COMPLETED' $Operation $elapsed)
        }
        return $result
    } catch {
        $elapsed = [int][Math]::Floor($watch.Elapsed.TotalSeconds)
        Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_FAILED' $Operation $elapsed $_.Exception.Message)
        throw
    } finally { $watch.Stop() }
}

function Start-SgInstallerPhase {
    param(
        [Parameter(Mandatory=$true)][object]$Operation,
        [scriptblock]$EventSink
    )
    $watch = [Diagnostics.Stopwatch]::StartNew()
    Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_STARTED' $Operation 0)
    [pscustomobject]@{ Operation=$Operation; Stopwatch=$watch; EventSink=$EventSink }
}

function Complete-SgInstallerPhase {
    param([Parameter(Mandatory=$true)][object]$Phase,[string]$Failure='')
    $elapsed = [int][Math]::Floor($Phase.Stopwatch.Elapsed.TotalSeconds)
    $code = if ([string]::IsNullOrWhiteSpace($Failure)) { 'INSTALL_STEP_COMPLETED' } else { 'INSTALL_STEP_FAILED' }
    Invoke-SgInstallerEventSink $Phase.EventSink (New-SgInstallerEvent $code $Phase.Operation $elapsed $Failure)
    $Phase.Stopwatch.Stop()
}

function Invoke-SgInstallerInput {
    param(
        [Parameter(Mandatory=$true)][object]$Operation,
        [Parameter(Mandatory=$true)][scriptblock]$Reader,
        [scriptblock]$EventSink
    )
    Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_AWAITING_INPUT' $Operation 0)
    try { return & $Reader }
    finally { Invoke-SgInstallerEventSink $EventSink (New-SgInstallerEvent 'INSTALL_STEP_INPUT_RECEIVED' $Operation 0) }
}

Export-ModuleMember -Function New-SgInstallerOperation,Invoke-SgInstallerOperation,Start-SgInstallerPhase,Complete-SgInstallerPhase,Invoke-SgInstallerInput
