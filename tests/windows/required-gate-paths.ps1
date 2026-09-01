$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$resolver = Join-Path $root '.github\scripts\Resolve-WindowsValidationImpact.ps1'
$workflow = Join-Path $root '.github\workflows\windows-installer-validation.yml'

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Resolve-Impact([string[]]$Paths) {
    return & $resolver -Path $Paths
}

$zero = Resolve-Impact @('README.md', 'shipglows_data/technical/runtime-cli.md')
Assert-Sg (-not $zero.WindowsChanged) 'Documentation-only paths must report no Windows impact.'
Assert-Sg ($zero.MatchedCount -eq 0) 'Zero-impact classification must report zero matches.'

$one = Resolve-Impact @('cli/windows/install-devserver.ps1')
Assert-Sg $one.WindowsChanged 'A cli/windows change must require Windows validation.'
Assert-Sg ($one.MatchedCount -eq 1) 'One relevant path must report one unique match.'

$many = Resolve-Impact @(
    'README.md',
    'tests/windows/mobile-toolchain.ps1',
    'cli/environment/shipglows_environment.py',
    '.github/workflows/windows-installer-validation.yml'
)
Assert-Sg $many.WindowsChanged 'Mixed changes must retain Windows impact.'
Assert-Sg ($many.MatchedCount -eq 3) 'Mixed changes must report every relevant path exactly once.'

$boundary = Resolve-Impact @('cli/windows-old/example.ps1', 'tests/windows.md')
Assert-Sg (-not $boundary.WindowsChanged) 'Prefix boundaries must not classify neighboring paths.'

$windowsSeparators = Resolve-Impact @('tests\windows\agent-instructions.ps1')
Assert-Sg $windowsSeparators.WindowsChanged 'Windows separators must normalize before classification.'

$unsafeRejected = $false
try {
    [void](Resolve-Impact @('../outside.ps1'))
} catch {
    $unsafeRejected = $_.Exception.Message -match 'Unsafe changed path'
}
Assert-Sg $unsafeRejected 'Unsafe changed paths must fail closed.'

$workflowText = Get-Content -LiteralPath $workflow -Raw -Encoding UTF8
foreach ($requiredWorkflowContract in @(
    'name: ShipGlows required gate',
    'permissions:',
    'contents: read',
    'persist-credentials: false',
    "`$version = '15.2.0'",
    "`$expectedSha256 = '71B2FEF860ABE467217A538FF31DE02F5258807C0129F771846F87BD029AAFC5'",
    'Provision pinned managed PowerShell runtime',
    'Ensure-SgPowerShellRuntime',
    'bash tests/windows/devserver-contract.sh'
)) {
    Assert-Sg ($workflowText.Contains($requiredWorkflowContract)) "Required workflow contract is missing: $requiredWorkflowContract"
}

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-required-gate-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $pathsFile = Join-Path $fixture 'paths.txt'
    $outputFile = Join-Path $fixture 'github-output.txt'
    Set-Content -LiteralPath $pathsFile -Encoding UTF8 -Value @('README.md', 'install-shipglows.ps1')
    $fileResult = & $resolver -PathsFile $pathsFile -GitHubOutput $outputFile
    $outputs = Get-Content -LiteralPath $outputFile -Encoding UTF8
    Assert-Sg $fileResult.WindowsChanged 'PathsFile input must classify relevant paths.'
    Assert-Sg ($outputs -contains 'windows_changed=true') 'GitHub output must expose the stable boolean.'
    Assert-Sg ($outputs -contains 'matched_count=1') 'GitHub output must expose the unique match count.'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}

Write-Host 'Windows required-gate path contract: OK'
