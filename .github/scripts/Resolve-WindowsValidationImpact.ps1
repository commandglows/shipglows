[CmdletBinding()]
param(
    [string[]]$Path = @(),
    [string]$PathsFile,
    [string]$GitHubOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($PathsFile) {
    if (-not (Test-Path -LiteralPath $PathsFile -PathType Leaf)) {
        throw "Changed-path file does not exist: $PathsFile"
    }
    $Path += @(Get-Content -LiteralPath $PathsFile -Encoding UTF8)
}

$exactPaths = @(
    '.github/scripts/Resolve-WindowsValidationImpact.ps1',
    '.github/workflows/windows-installer-validation.yml',
    'install-shipglows.ps1',
    'local/install_local.ps1',
    'tools/shipglows_sync_skills.ps1'
)
$ownedPrefixes = @(
    'cli/environment/',
    'cli/windows/',
    'tests/environment/',
    'tests/windows/'
)

$normalizedPaths = foreach ($candidate in $Path) {
    if ($null -eq $candidate) { continue }
    $normalized = ([string]$candidate).Trim().Replace('\', '/')
    if (-not $normalized) { continue }
    if ($normalized -match '[\x00-\x1f]' -or
        [IO.Path]::IsPathRooted($normalized) -or
        $normalized -match '(^|/)\.\.(/|$)') {
        throw "Unsafe changed path: $candidate"
    }
    $normalized
}

$matchedPaths = @($normalizedPaths | Where-Object {
    $candidate = $_
    $exactPaths -contains $candidate -or
        @($ownedPrefixes | Where-Object { $candidate.StartsWith($_, [StringComparison]::Ordinal) }).Count -gt 0
} | Sort-Object -Unique)

$windowsChanged = $matchedPaths.Count -gt 0
$result = if ($windowsChanged) { 'true' } else { 'false' }

if ($GitHubOutput) {
    Add-Content -LiteralPath $GitHubOutput -Encoding UTF8 -Value "windows_changed=$result"
    Add-Content -LiteralPath $GitHubOutput -Encoding UTF8 -Value "matched_count=$($matchedPaths.Count)"
}

[pscustomobject]@{
    WindowsChanged = $windowsChanged
    MatchedCount = $matchedPaths.Count
    MatchedPaths = $matchedPaths
}
