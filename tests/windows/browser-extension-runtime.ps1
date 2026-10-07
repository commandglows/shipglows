$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$runner = Join-Path $root 'cli\windows\ShipGlows.ExtensionLab.js'
$visualFixture = Join-Path $root 'tests\fixtures\extension-visual'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-extension-runtime-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    Import-Module $modulePath -Force
    $playwright = Get-SgManagedPlaywrightModulePath
    if (-not $playwright) { throw 'Managed Playwright is required for the browser extension runtime test.' }
    $screenshot = Join-Path $fixture 'visual.png'
    [IO.Directory]::CreateDirectory($fixture) | Out-Null
    $visualOutput = & node $runner --extension $visualFixture --playwright $playwright --browser chromium --browser-product Chromium --browser-version managed --headless --json --click-selector '#proof' --visual-selector '#proof' --screenshot $screenshot
    if ($LASTEXITCODE -ne 0) { throw "The interactive visual probe failed: $visualOutput" }
    $visual = $visualOutput | ConvertFrom-Json
    if ($visual.verdict -ne 'loaded' -or $visual.click.state -ne 'passed' -or $visual.visual.dom.state -ne 'captured' -or $visual.visual.dom.text -ne 'After click') { throw "The interactive visual contract did not pass: $visualOutput" }
    if ($visual.visual.dom.computedStyle.backgroundColor -ne 'rgb(1, 2, 3)' -or $visual.visual.screenshotStatus -ne 'captured' -or -not (Test-Path -LiteralPath $screenshot -PathType Leaf)) { throw "The visual CSS or screenshot evidence is incomplete: $visualOutput" }
    if ($visual.browser.requested -ne 'chromium' -or $visual.browser.engine -ne 'chromium' -or -not $visual.browser.executablePath -or -not $visual.browser.runtimeVersion -or -not $visual.browser.isolatedProfile) { throw "The browser identity evidence is incomplete: $visualOutput" }
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
    Write-Host 'Windows browser extension interactive visual and unavailable-CDP recovery: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
