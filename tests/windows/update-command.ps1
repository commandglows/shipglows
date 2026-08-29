$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$entrypoint = Join-Path $repoRoot 'cli\windows\shipglows.ps1'
$devServer = Join-Path $repoRoot 'cli\windows\shipglows-devserver.ps1'
$runtimeStatus = Join-Path $repoRoot 'cli\windows\ShipGlows.RuntimeStatus.psm1'
$entrypointText = [IO.File]::ReadAllText($entrypoint)
$devServerText = [IO.File]::ReadAllText($devServer)

foreach ($path in @($entrypoint, $devServer)) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
    Assert-Sg (-not $errors -or $errors.Count -eq 0) "PowerShell syntax must remain valid: $path"
}

Assert-Sg (Test-Path -LiteralPath $runtimeStatus -PathType Leaf) 'The Windows runtime-status module must be packaged with the DevServer.'

Assert-Sg ($entrypointText.Contains("CommandArguments[0] -ieq 'update'")) 'shipglows update must be accepted by the focused Windows launcher.'
Assert-Sg ($entrypointText.Contains("'shipglows-devserver.ps1'")) 'shipglows update must delegate to the active DevServer implementation.'
Assert-Sg ($devServerText.Contains('function Get-SgUpdateSource')) 'DevServer update must resolve the active channel before mutation.'
Assert-Sg ($devServerText.Contains("Channel='linked'")) 'Linked developer channels must be represented explicitly.'
Assert-Sg ($devServerText.Contains('rev-parse --is-inside-work-tree')) 'Linked updates must accept valid Git worktrees as developer checkouts.'
Assert-Sg ($devServerText.Contains('uncommitted changes, so the update stopped to preserve them')) 'Linked updates must explain that dirty checkout refusal preserves local changes.'
Assert-Sg ($devServerText.Contains('status --short')) 'Dirty linked-update errors must provide a focused inspection command.'
Assert-Sg ($devServerText.Contains("then retry 's update'")) 'Dirty linked-update errors must provide the retry path.'
Assert-Sg ($devServerText.Contains("if (`$choice -eq 'u') { return }")) 'The interactive update action must leave the menu after success or failure instead of redrawing the project catalog.'
Assert-Sg ($devServerText.Contains("'update status' = 'update-status'")) 'DevServer must expose a read-only update-status route.'
Assert-Sg ($devServerText.Contains("'u  Update ShipGlows'")) 'DevServer menu must retain its visible ShipGlows update entry.'
Assert-Sg ($devServerText.Contains('Start-SgBackgroundUpdateStatusRefresh')) 'DevServer must refresh ShipGlows status outside the first paint.'
Assert-Sg ($devServerText.Contains('Show-SgShipGlowsStatus')) 'DevServer dashboard must render ShipGlows version status.'

Write-Output 'Windows ShipGlows update-command tests passed.'
