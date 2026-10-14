$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Exercise the real checked-out payload without an anonymous GitHub download.
# This tests packaging/extraction, not public or authenticated download access.
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-bootstrap-archive-' + [guid]::NewGuid().ToString('N'))
$bootstrap = Join-Path $root 'install-shipglows.ps1'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($bootstrap, [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) { throw 'Bootstrap source has PowerShell syntax errors.' }
$extractors = @($ast.FindAll({
    param($node)
    $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Extract-ShipglowsWindowsFiles'
}, $true))
if ($extractors.Count -ne 1) { throw 'Bootstrap extractor must resolve uniquely.' }
Invoke-Expression $extractors[0].Extent.Text
function Fail([string]$Message) { throw $Message }
$zip = $null

try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $archive = Join-Path $fixture 'head.zip'
    & git -C $root archive --format=zip --prefix=shipglows-test/ --output=$archive HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Could not export the exact tested revision.' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($archive)

    foreach ($fullMode in @($false, $true)) {
        $destination = Join-Path $fixture $(if ($fullMode) { 'full' } else { 'local' })
        New-Item -ItemType Directory -Path $destination | Out-Null
        $entries = @(Extract-ShipglowsWindowsFiles -ArchivePath $archive -DestinationPath $destination -FullMode $fullMode)
        $expectedCount = if ($fullMode) { 42 } else { 2 }
        if ($entries.Count -ne $expectedCount) { throw "Unexpected extraction inventory: $($entries.Count), expected $expectedCount." }
        $files = @(Get-ChildItem -LiteralPath $destination -Recurse -File)
        if ($files.Count -ne $entries.Count) { throw 'Extraction wrote files outside its returned inventory.' }
        foreach ($entry in $entries) {
            if ($entry -notmatch '^shipglows-test/(.+)$') { throw "Unexpected archive root: $entry" }
            $relative = $Matches[1]
            $extracted = Join-Path $destination $entry
            if (-not (Test-Path -LiteralPath $extracted -PathType Leaf)) { throw "Missing extracted file: $relative" }
            # Hash raw committed bytes, not a checkout that may have CRLF filters.
            $zipEntry = $zip.GetEntry($entry)
            if ($null -eq $zipEntry) { throw "Returned entry is absent from the Git archive: $entry" }
            $stream = $zipEntry.Open()
            $hasher = [Security.Cryptography.SHA256]::Create()
            try {
                $expectedHash = [BitConverter]::ToString($hasher.ComputeHash($stream)).Replace('-', '')
            } finally {
                $stream.Dispose()
                $hasher.Dispose()
            }
            if ($expectedHash -cne (Get-FileHash -LiteralPath $extracted -Algorithm SHA256).Hash) {
                throw "Extracted bytes differ from the committed archive: $relative"
            }
            if ([IO.Path]::GetExtension($relative) -in @('.ps1', '.psm1')) {
                $fileTokens = $null; $fileErrors = $null
                [void][Management.Automation.Language.Parser]::ParseFile($extracted, [ref]$fileTokens, [ref]$fileErrors)
                if ($fileErrors.Count -gt 0) { throw "Extracted PowerShell source is invalid: $relative" }
            }
        }
        $versionPath = Join-Path $destination 'shipglows-test/shipglows-version.json'
        $version = [IO.File]::ReadAllText($versionPath) | ConvertFrom-Json
        if ([string]$version.version -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$') {
            throw 'Extracted runtime version metadata is invalid.'
        }
    }
    Write-Host 'Exact-revision local/full bootstrap archive extraction: OK'
} finally {
    if ($null -ne $zip) { $zip.Dispose() }
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
