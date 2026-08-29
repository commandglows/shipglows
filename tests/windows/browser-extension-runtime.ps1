$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$runner = Join-Path $root 'cli\windows\ShipGlows.ExtensionLab.js'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-extension-runtime-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    Import-Module $modulePath -Force
    $playwright = Get-SgManagedPlaywrightModulePath
    if (-not $playwright) { throw 'Managed Playwright is required for the browser extension runtime test.' }
    [IO.Directory]::CreateDirectory($fixture) | Out-Null
    [IO.File]::WriteAllText(
        (Join-Path $fixture 'manifest.json'),
        '{"manifest_version":3,"name":"No Worker Fixture","version":"1.0.0"}',
        [Text.UTF8Encoding]::new($false)
    )
    $ErrorActionPreference = 'Continue'
    $output = & node $runner --extension $fixture --playwright $playwright --headless --json --simulate-cdp-unavailable 2>&1
    $ErrorActionPreference = 'Stop'
    if ($LASTEXITCODE -eq 0) { throw 'The simulated unavailable-CDP probe unexpectedly succeeded.' }
    $message = ($output | Out-String)
    if ($message -notmatch 'CDP fallback is unavailable' -or $message -notmatch 'Ensure the Manifest V3 service worker') {
        throw "The unavailable-CDP recovery was not actionable: $message"
    }
    Write-Host 'Windows browser extension unavailable-CDP recovery: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
