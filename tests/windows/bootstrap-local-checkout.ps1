$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# The linked maintainer channel installs from its own checkout, so a private
# GitHub repository cannot block `s update`.
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$bootstrapPath = Join-Path $root 'install-shipglows.ps1'
$tokens = $null
$errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($bootstrapPath, [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) { throw ($errors | ForEach-Object Message | Out-String) }
foreach ($name in @('Resolve-LocalCheckoutSource','Save-ShipglowsSourceArchive')) {
    $definition = @($ast.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name }, $true))
    if ($definition.Count -ne 1) { throw "Bootstrap function could not be resolved uniquely: $name" }
    Invoke-Expression $definition[0].Extent.Text
}
function Fail([string]$Message) { throw $Message }

$updateScript = [IO.File]::ReadAllText((Join-Path $root 'cli\windows\shipglows-devserver.ps1'))
if ($updateScript -notmatch [regex]::Escape("'-SourceCheckout',`$source.Root")) { throw 'The linked update channel does not install from its checkout.' }

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-local-checkout-' + [guid]::NewGuid().ToString('N'))
try {
    $checkout = Join-Path $fixture 'checkout'
    New-Item -ItemType Directory -Path (Join-Path $checkout 'cli\windows') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $checkout 'install-shipglows.ps1') -Value '# installer' -Encoding ASCII
    Set-Content -LiteralPath (Join-Path $checkout 'cli\windows\shipglows-devserver.ps1') -Value '# committed' -Encoding ASCII
    & git -C $checkout init -q -b main
    & git -C $checkout -c user.name=ShipGlows -c user.email=test@shipglows.invalid add -A
    & git -C $checkout -c user.name=ShipGlows -c user.email=test@shipglows.invalid commit -q -m fixture
    if ($LASTEXITCODE -ne 0) { throw 'Fixture checkout could not be committed.' }
    $head = (& git -C $checkout rev-parse HEAD).Trim()
    Set-Content -LiteralPath (Join-Path $checkout 'cli\windows\shipglows-devserver.ps1') -Value '# uncommitted' -Encoding ASCII

    $source = Resolve-LocalCheckoutSource -CheckoutPath $checkout -Ref 'main'
    if ($source.Commit -cne $head -or $source.Checkout -ne [IO.Path]::GetFullPath($checkout)) { throw 'Linked checkout source is not pinned to the branch commit.' }

    $archive = Join-Path $fixture 'shipglows.zip'
    Save-ShipglowsSourceArchive -Source $source -ArchivePath $archive -CurlPath 'curl-must-not-run.exe'
    $extract = Join-Path $fixture 'extract'
    New-Item -ItemType Directory -Path $extract | Out-Null
    & tar.exe -xf $archive -C $extract
    if ($LASTEXITCODE -ne 0) { throw 'Linked checkout archive could not be extracted with tar.exe.' }
    $top = @(Get-ChildItem -LiteralPath $extract -Directory)
    if ($top.Count -ne 1 -or $top[0].Name -cne "shipglows-$head") { throw 'Linked checkout archive does not match the GitHub archive layout.' }
    $installed = (Get-Content -LiteralPath (Join-Path $top[0].FullName 'cli\windows\shipglows-devserver.ps1') -Raw).Trim()
    if ($installed -cne '# committed') { throw 'Linked checkout archive included uncommitted content.' }

    foreach ($case in @(@{Path=$checkout;Ref='no-such-branch';Pattern='Could not resolve'}, @{Path='relative\checkout';Ref='main';Pattern='absolute path'}, @{Path=$fixture;Ref='main';Pattern='not a ShipGlows checkout'})) {
        $rejected = $false
        try { [void](Resolve-LocalCheckoutSource -CheckoutPath $case.Path -Ref $case.Ref) } catch { $rejected = $_.Exception.Message -match $case.Pattern }
        if (-not $rejected) { throw "Linked checkout source accepted an invalid input: $($case.Pattern)" }
    }
    Write-Host 'Windows bootstrap linked checkout source: OK'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
