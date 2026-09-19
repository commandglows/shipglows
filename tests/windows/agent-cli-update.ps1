param([string]$InstallerPath = (Join-Path $PSScriptRoot '..\..\cli\windows\install-devserver.ps1'))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Extract only the functions under test: never execute the installer or npm.
function Get-TestFunction([string]$Path, [string]$Name) {
    $tokens = $null; $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw "Invalid PowerShell: $Path" }
    $function = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $Name }, $true)
    if (-not $function) { throw "Missing function: $Name" }
    return [scriptblock]::Create($function.Extent.Text)
}
. (Get-TestFunction $InstallerPath 'Install-SgMissingAgentClis')
. (Get-TestFunction (Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.MobileToolchain.psm1') 'Get-SgAgentInstallPlan')

$codexPaths = $claudePaths = $opencodePaths = $kiloPaths = $kilocodePaths = $geminiPaths = $nodePaths = @()
function Resolve-SgNpmVersion {
    if ($script:scenario -eq 'registry-error') { throw 'registry unavailable' }
    if ($script:scenario -eq 'empty-target') { return '' }
    return '0.155.1'
}
function Get-SgInstalledCommandVersion {
    if ($script:scenario -eq 'unknown-before') { return '' }
    if ($script:scenario -eq 'already-current') { return '0.155.1' }
    if ($script:installs -eq 0 -or $script:scenario -eq 'stale') { return '0.154.0' }
    if ($script:scenario -eq 'unknown-after') { return '' }
    return '0.155.1'
}
function Invoke-SgVisibleBoundedProcess {
    param($OperationId, $Label, $File, $Arguments, $TimeoutSeconds)
    $script:installs++
    if ($Arguments[2] -ne '@openai/codex@0.155.1') { throw 'Incorrect exact package target' }
    return [pscustomobject]@{ TimedOut=($script:scenario -eq 'timeout'); ExitCode=$(if($script:scenario -eq 'npm-error'){1}else{0}) }
}
function Test-SgToolRuns { return $script:scenario -ne 'broken-executable' }
function Write-SgInstallerWarning { param($Message) $script:warnings++ }
function Read-SgVisibleInstallerConsent { return 'y' }

$cases = @(
    @{ Name='stale'; Error='version mismatch'; Installs=1 },
    @{ Name='unknown-after'; Error='version mismatch'; Installs=1 },
    @{ Name='npm-error'; Error='failed final executable verification'; Installs=1 },
    @{ Name='timeout'; Error='failed final executable verification'; Installs=1 },
    @{ Name='broken-executable'; Error='failed final executable verification'; Installs=1 },
    @{ Name='registry-error'; Error='registry unavailable'; Installs=0 },
    @{ Name='empty-target'; Error='target version could not be resolved'; Installs=0 },
    @{ Name='unknown-before'; Error='installed version could not be proven'; Installs=0 },
    @{ Name='success'; Error=''; Installs=1 },
    @{ Name='already-current'; Error=''; Installs=0 }
)
$failures = @()
foreach ($case in $cases) {
    $script:scenario = $case.Name; $script:installs = 0; $script:warnings = 0
    $caught = ''; $completed = $false
    try {
        $null = Install-SgMissingAgentClis 'mock-npm' @{ Codex=$true } $true
        $completed = $true
    } catch { $caught = $_.Exception.Message }
    if (($case.Error -and ($completed -or $caught -notlike "*$($case.Error)*")) -or
        (-not $case.Error -and -not $completed) -or $script:installs -ne $case.Installs) {
        $failures += "$($case.Name): completed=$completed installs=$script:installs error=$caught"
    } else { Write-Host "PASS $($case.Name)" }
}
# Ordinary convergence retains its warning-only behavior when comparison fails.
$script:scenario = 'registry-error'; $script:installs = 0; $script:warnings = 0
try {
    $null = Install-SgMissingAgentClis 'mock-npm' @{ Codex=$true; Claude=$true; OpenCode=$true; Kilo=$true; Gemini=$true } $false
    if ($script:warnings -ne 5 -or $script:installs -ne 0) { throw 'Expected five warnings and no install' }
    Write-Host 'PASS ordinary convergence preserves warnings'
} catch { $failures += "ordinary convergence: $_" }
if ($failures.Count) { throw ($failures -join "`n") }
Write-Host 'PASS agent CLI update behavior (11 scenarios)'
