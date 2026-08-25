$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$bootstrapPath = Join-Path $root 'install-shipglows.ps1'
$tokens = $null
$errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($bootstrapPath, [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) { throw ($errors | ForEach-Object Message | Out-String) }

$resolver = @($ast.FindAll({
    param($node)
    $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Resolve-GitHubSource'
}, $true))
if ($resolver.Count -ne 1) { throw 'Bootstrap source resolver could not be resolved uniquely.' }
$resolverSource = $resolver[0].Extent.Text
if ($resolverSource -match 'commit/.+\.patch|\^From ') { throw 'Bootstrap still derives a ref from commit-patch contents.' }
foreach ($required in @('api.github.com/repos/$repositoryPath/commits/$encodedRef','ConvertFrom-Json',"'^[0-9a-f]{40}$'")) {
    if ($resolverSource -notmatch [regex]::Escape($required)) { throw "Canonical GitHub commit resolution is missing: $required" }
}

Invoke-Expression $resolverSource
function Fail([string]$Message) { throw $Message }

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-bootstrap-ref-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $fakeCurl = Join-Path $fixture 'curl.cmd'
    $mergeSha = 'b364c329ce099360471e0810e524b01ed97fcb09'
    Set-Content -LiteralPath $fakeCurl -Encoding ASCII -Value @('@echo off', "@echo {`"sha`":`"$mergeSha`"}")

    $resolved = Resolve-GitHubSource -RepositoryUrl 'https://github.com/commandglows/shipglows.git' -Ref 'main' -CurlPath $fakeCurl
    if ($resolved.Commit -cne $mergeSha) { throw 'Bootstrap did not preserve the canonical merge commit SHA.' }
    if ($resolved.ArchiveUrl -cne "https://github.com/commandglows/shipglows/archive/$mergeSha.zip") { throw 'Bootstrap archive is not pinned to the canonical merge commit SHA.' }

    Set-Content -LiteralPath $fakeCurl -Encoding ASCII -Value @('@echo off', 'exit /b 97')
    $uppercaseSha = $mergeSha.ToUpperInvariant()
    $resolvedSha = Resolve-GitHubSource -RepositoryUrl 'https://github.com/commandglows/shipglows.git' -Ref $uppercaseSha -CurlPath $fakeCurl
    if ($resolvedSha.Commit -cne $mergeSha) { throw 'Bootstrap did not normalize a complete commit SHA without an API lookup.' }
    if ($resolvedSha.ArchiveUrl -cne "https://github.com/commandglows/shipglows/archive/$mergeSha.zip") { throw 'Direct SHA archive is not pinned to the normalized commit.' }

    Set-Content -LiteralPath $fakeCurl -Encoding ASCII -Value @('@echo off', '@echo {"sha":"not-a-commit"}')
    $rejected = $false
    try {
        [void](Resolve-GitHubSource -RepositoryUrl 'https://github.com/commandglows/shipglows.git' -Ref 'main' -CurlPath $fakeCurl)
    } catch {
        $rejected = $_.Exception.Message -match 'valid commit'
    }
    if (-not $rejected) { throw 'Bootstrap accepted an invalid GitHub commit SHA.' }

    Write-Host 'Windows bootstrap ref resolution regression: OK'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
