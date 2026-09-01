$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$tokens = $null
$errors = $null
[void][Management.Automation.Language.Parser]::ParseFile($modulePath, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | ForEach-Object Message | Out-String) }
Import-Module $modulePath -Force -DisableNameChecking

function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

$sandbox = Join-Path ([IO.Path]::GetTempPath()) ('sg-cli-capabilities-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $sandbox | Out-Null
    $config = [pscustomobject]@{ RuntimeDirectory=$sandbox; CliCapabilitiesPath=(Join-Path $sandbox 'cli-capabilities.v1.json') }
    $path = Write-SgCliCapabilitySnapshot $config
    Assert-Sg ($path -ceq $config.CliCapabilitiesPath) 'The configured snapshot path must be preserved.'
    Assert-Sg ((Get-Item -LiteralPath $path).Length -le 65536) 'The snapshot must stay within 64 KiB.'
    $snapshot = Read-SgCliCapabilitySnapshot $config
    Assert-Sg ($snapshot.schemaVersion -ceq 'shipglows.cli-capabilities.v1') 'The schema version drifted.'
    Assert-Sg (@($snapshot.capabilities).Count -eq 31) 'The closed capability inventory must contain exactly 31 records.'
    Assert-Sg (@($snapshot.capabilities | Where-Object id -eq 'plugin.obsidian.lab')[0].state -ceq 'available') 'The local Obsidian Lab capability is missing.'
    Assert-Sg (@($snapshot.capabilities | Where-Object id -eq 'workspace.close')[0].reasonCode -ceq 'unsupportedWindows') 'Unsupported Windows behavior must be explicit.'
    $raw = [IO.File]::ReadAllText($path)
    Assert-Sg ($raw -notmatch '(?i)"(command|argument|path|port|secret|token|credential)"\s*:|\\Users\\') 'The snapshot leaked an excluded field or private path.'
    Assert-Sg (([DateTime]::ParseExact($snapshot.generatedAt, "yyyy-MM-dd'T'HH:mm:ss.fff'Z'", [Globalization.CultureInfo]::InvariantCulture)).Kind -in @([DateTimeKind]::Unspecified,[DateTimeKind]::Utc)) 'The generatedAt timestamp is not canonical UTC milliseconds.'
    $corrupt = $raw | ConvertFrom-Json
    $corrupt.capabilities[0] | Add-Member -NotePropertyName command -NotePropertyValue 'arbitrary'
    [IO.File]::WriteAllText($path, ($corrupt | ConvertTo-Json -Depth 5 -Compress), [Text.UTF8Encoding]::new($false))
    $failedClosed = $false
    try { [void](Read-SgCliCapabilitySnapshot $config) } catch { $failedClosed = $_.Exception.Message -match 'invalid' }
    Assert-Sg $failedClosed 'An open-shaped capability record must fail closed.'
} finally {
    if (Test-Path -LiteralPath $sandbox) { Remove-Item -LiteralPath $sandbox -Recurse -Force }
}

Write-Host 'Windows CLI capability snapshot regression: OK'
