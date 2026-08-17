$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$enginePath = Join-Path $root 'cli\windows\ShipGlows.InstallerEngine.psm1'
$consolePath = Join-Path $root 'cli\windows\ShipGlows.InstallerConsole.psm1'
$mobilePath = Join-Path $root 'cli\windows\ShipGlows.MobileToolchain.psm1'
$installerPath = Join-Path $root 'cli\windows\install-devserver.ps1'

function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

if (-not (Test-Path -LiteralPath $enginePath -PathType Leaf)) { throw 'Windows installer engine module is missing.' }
if (-not (Test-Path -LiteralPath $consolePath -PathType Leaf)) { throw 'Windows installer console module is missing.' }

$engineText = [IO.File]::ReadAllText($enginePath)
foreach ($forbidden in @('Read-Host','Write-Host','gum','ForegroundColor','RawUI')) {
    Assert-Sg ($engineText -notmatch [regex]::Escape($forbidden)) "Installer engine depends on UI token: $forbidden"
}

Import-Module $enginePath -Force -DisableNameChecking
Import-Module $consolePath -Force -DisableNameChecking
Import-Module $mobilePath -Force -DisableNameChecking

$events = New-Object Collections.Generic.List[object]
$operation = New-SgInstallerOperation -Id 'agent.codex' -Label 'Updating Codex CLI' -TimeoutSeconds 30
$result = Invoke-SgInstallerOperation -Operation $operation -EventSink { param($event) $events.Add($event) } -Runner {
    param($progress)
    & $progress 2
    [pscustomobject]@{ ExitCode=0; Output='installed'; TimedOut=$false }
}
Assert-Sg (($events.Code -join '|') -eq 'INSTALL_STEP_STARTED|INSTALL_STEP_PROGRESS|INSTALL_STEP_COMPLETED') 'Successful operation emitted an invalid event sequence.'
Assert-Sg ($result.ExitCode -eq 0) 'Successful operation did not return its runner result.'

$timeoutEvents = New-Object Collections.Generic.List[object]
[void](Invoke-SgInstallerOperation -Operation $operation -EventSink { param($event) $timeoutEvents.Add($event) } -Runner {
    param($progress)
    [pscustomobject]@{ ExitCode=-1; Output='timed out'; TimedOut=$true }
})
Assert-Sg ($timeoutEvents[-1].Code -eq 'INSTALL_STEP_TIMED_OUT') 'Timed-out operation did not emit its terminal event.'

$written = New-Object Collections.Generic.List[object]
$sink = New-SgInstallerConsoleEventSink -Interactive $false -Writer { param($text,$noNewline,$color) $written.Add([pscustomobject]@{ Text=$text; NoNewline=$noNewline; Color=$color }) }
foreach ($event in $events) { & $sink $event }
Assert-Sg ($written.Count -eq 2) 'Non-interactive console must emit only start and terminal lines.'
Assert-Sg ($written[0].Text -match 'Updating Codex CLI') 'Non-interactive start line omitted the operation label.'

$progressText = Format-SgInstallerConsoleEvent -Event $events[1] -Interactive $true
Assert-Sg ($progressText.Text -match 'Updating Codex CLI' -and $progressText.Text -match '2s' -and $progressText.NoNewline) 'Interactive progress format omitted loader context.'

$realEvents = New-Object Collections.Generic.List[object]
$realOperation = New-SgInstallerOperation -Id 'proof.progress' -Label 'Proving live progress' -TimeoutSeconds 5
[void](Invoke-SgInstallerOperation -Operation $realOperation -EventSink { param($event) $realEvents.Add($event) } -Runner {
    param($progress)
    Invoke-SgBoundedProcess -File (Get-Command powershell.exe).Source -Arguments @('-NoProfile','-Command','Start-Sleep -Milliseconds 650') -TimeoutSeconds 5 -ProgressCallback $progress
})
Assert-Sg ($realEvents.Code -contains 'INSTALL_STEP_PROGRESS') 'Real bounded process did not emit progress before completion.'

$installerText = [IO.File]::ReadAllText($installerPath)
Assert-Sg ($installerText -notmatch 'Read-Host') 'Installer composition root bypasses the console adapter for a prompt.'
Assert-Sg ($installerText -match 'Invoke-SgVisibleBoundedProcess.+agent\.') 'Coding-agent installation does not use the visible operation boundary.'
Assert-Sg ($installerText -match 'Invoke-SgVisibleBoundedProcess.+service\.') 'Service CLI installation does not use the visible operation boundary.'
Assert-Sg ($installerText -match 'Invoke-SgVisibleBoundedProcess.+mcp\.') 'Captured MCP configuration does not use the visible operation boundary.'

Write-Host 'Windows installer engine/UI contract: OK' -ForegroundColor Green
