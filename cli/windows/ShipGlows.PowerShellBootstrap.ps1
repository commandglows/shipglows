[CmdletBinding()]
param(
    [switch]$Offline,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$RemainingArgs = @()
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$module = Join-Path $PSScriptRoot 'ShipGlows.PowerShellRuntime.psm1'
Import-Module $module -Force -DisableNameChecking
try { $managed = Resolve-SgManagedPowerShell -Offline:$Offline }
catch { [Console]::Error.WriteLine("ShipGlows PowerShell bootstrap failed: {0}" -f $_.Exception.Message); exit 70 }
$env:SHIPGLOWS_MANAGED_PWSH = [IO.Path]::GetFullPath($managed)
$frontend = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
& $managed -NoLogo -NoProfile -File $frontend @RemainingArgs
exit $LASTEXITCODE
