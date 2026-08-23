$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$bootstrapPath = Join-Path $root 'install-shipglows.ps1'
$tokens = $null
$errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($bootstrapPath, [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) { throw ($errors | ForEach-Object Message | Out-String) }

$resolver = @($ast.FindAll({
    param($node)
    $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Resolve-SgInstallSurface'
}, $true))
if ($resolver.Count -ne 1) { throw 'Windows install-surface resolver could not be resolved uniquely.' }

Invoke-Expression $resolver[0].Extent.Text

Assert-Sg ((Resolve-SgInstallSurface -RequestedSurface '' -InteractiveSurface '' -InstallMode full) -eq 'runtime') 'Windows full must default to runtime.'
Assert-Sg ((Resolve-SgInstallSurface -RequestedSurface 'developer' -InteractiveSurface '' -InstallMode full) -eq 'maintainer') 'Developer must be a compatibility alias for maintainer.'
Assert-Sg ((Resolve-SgInstallSurface -RequestedSurface '' -InteractiveSurface 'maintainer' -InstallMode full) -eq 'maintainer') 'Interactive maintainer selection must be deterministic.'

foreach ($legacyPublicSurface in @('skills', 'corpus')) {
    $blocked = $false
    try { [void](Resolve-SgInstallSurface -RequestedSurface $legacyPublicSurface -InteractiveSurface '' -InstallMode full) }
    catch { $blocked = $_.Exception.Message -match 'public Codex plugin' }
    Assert-Sg $blocked "Windows must not reinterpret $legacyPublicSurface as a maintainer checkout."
}

$localMaintainerBlocked = $false
try { [void](Resolve-SgInstallSurface -RequestedSurface 'maintainer' -InteractiveSurface '' -InstallMode local) }
catch { $localMaintainerBlocked = $_.Exception.Message -match 'requires InstallMode full' }
Assert-Sg $localMaintainerBlocked 'Maintainer setup must require the full Windows runtime.'

$source = [IO.File]::ReadAllText($bootstrapPath)
Assert-Sg ($source -notmatch 'if\s*\(-not\s+\$InstallSurface\s+-and\s+\$requestedComponents') 'Component selection must never choose an install surface implicitly.'
Assert-Sg ($source -notmatch '\$InstallSurface\s*=\s*''corpus''') 'The legacy corpus name must never become the Windows maintainer surface.'

Write-Output 'Windows install-surface contract tests passed.'
