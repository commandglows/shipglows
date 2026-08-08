[CmdletBinding()]
param(
    [string]$ShipglowsDir = (Join-Path $env:USERPROFILE 'shipglows'),
    [string]$Workspace = (Join-Path $env:USERPROFILE 'ShipGlows\workspace'),
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$sourceDir = Join-Path $ShipglowsDir 'cli\windows'
$runtimeDir = Join-Path $env:USERPROFILE 'ShipGlows\bin'
New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
New-Item -ItemType Directory -Path $Workspace -Force | Out-Null

$launcher = Join-Path $runtimeDir 'shipglows-devserver.ps1'
Copy-Item -LiteralPath (Join-Path $sourceDir 'ShipGlows.DevServer.psm1') -Destination $runtimeDir -Force
Copy-Item -LiteralPath (Join-Path $sourceDir 'shipglows-devserver.ps1') -Destination $launcher -Force

if (-not $SkipProfile) {
    $profilePath = $PROFILE
    $profileDir = Split-Path -Parent $profilePath
    if (-not (Test-Path -LiteralPath $profileDir -PathType Container)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    $marker = '# ShipGlows DevServer (managed)'
    $existing = if (Test-Path -LiteralPath $profilePath -PathType Leaf) { Get-Content -LiteralPath $profilePath -Raw } else { '' }
    if ($existing -notlike "*$marker*") {
        $block = @"

$marker
function shipglows-dev { & '$launcher' @args }
"@
        Add-Content -LiteralPath $profilePath -Value $block -Encoding UTF8
    }
}

Write-Host "ShipGlows Windows DevServer installed." -ForegroundColor Green
Write-Host "Workspace: $Workspace"
Write-Host "Command: shipglows-dev"
Write-Host ''
Write-Host 'Dependency check:' -ForegroundColor Yellow
foreach ($tool in @('git','node','npm','uv','flutter')) {
    $found = Get-Command $tool -ErrorAction SilentlyContinue
    if ($found) { Write-Host "  [ok]   $tool" -ForegroundColor Green }
    else { Write-Host "  [miss] $tool (install it or use the project-specific setup instructions)" -ForegroundColor Yellow }
}
Write-Host 'Open a new PowerShell session, then run: shipglows-dev'
