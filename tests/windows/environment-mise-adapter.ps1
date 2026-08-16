$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$python = @(
    Get-Command python.exe -CommandType Application -ErrorAction SilentlyContinue
    Get-Command python3.exe -CommandType Application -ErrorAction SilentlyContinue
) | Where-Object { $_ } | Select-Object -First 1
if (-not $python) { throw 'Python 3 is required for the mise adapter fixture.' }

$processPathBefore = $env:PATH
$userPathBefore = [Environment]::GetEnvironmentVariable('Path', 'User')
$machinePathBefore = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$profileBefore = if (Test-Path -LiteralPath $PROFILE -PathType Leaf) {
    (Get-FileHash -LiteralPath $PROFILE -Algorithm SHA256).Hash
} else {
    $null
}

$contract = Join-Path $root 'tests\environment\mise-backend-contract.py'
$output = & $python.Source $contract 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "mise adapter child fixture failed with exit $LASTEXITCODE`n$($output -join [Environment]::NewLine)"
}
if (($output -join [Environment]::NewLine) -notmatch 'ShipGlows mise backend contract: OK') {
    throw 'mise adapter child fixture returned no success evidence.'
}

if ($env:PATH -cne $processPathBefore) { throw 'The mise pilot changed the PowerShell process PATH.' }
if ([Environment]::GetEnvironmentVariable('Path', 'User') -cne $userPathBefore) {
    throw 'The mise pilot changed the persistent user PATH.'
}
if ([Environment]::GetEnvironmentVariable('Path', 'Machine') -cne $machinePathBefore) {
    throw 'The mise pilot changed the persistent machine PATH.'
}
$profileAfter = if (Test-Path -LiteralPath $PROFILE -PathType Leaf) {
    (Get-FileHash -LiteralPath $PROFILE -Algorithm SHA256).Hash
} else {
    $null
}
if ($profileAfter -cne $profileBefore) { throw 'The mise pilot changed the PowerShell profile.' }

Write-Host 'ShipGlows Windows mise adapter: OK'
