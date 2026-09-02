$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$cliPath = Join-Path $root 'cli\windows\shipglows-devserver.ps1'
$runnerPath = Join-Path $root 'cli\windows\ShipGlows.ExtensionLab.js'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-extension-lab-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    $static = Join-Path $fixture 'static'; $built = Join-Path $fixture 'built'; $multiBrowser = Join-Path $fixture 'multi-browser'; $ambiguous = Join-Path $fixture 'ambiguous'; $ordinary = Join-Path $fixture 'ordinary'
    foreach ($path in @($static,$built,$multiBrowser,$ambiguous,$ordinary)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    [IO.File]::WriteAllText((Join-Path $static 'manifest.json'),'{' + '"name":"Static","version":"1.0.0","manifest_version":3}',[Text.UTF8Encoding]::new($false))
    New-Item -ItemType Directory -Path (Join-Path $built 'dist\chrome') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $built 'dist\chrome\manifest.json'),'{' + '"name":"Built","version":"2.0.0","manifest_version":3}',[Text.UTF8Encoding]::new($false))
    New-Item -ItemType Directory -Path (Join-Path $multiBrowser 'dist\chrome') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $multiBrowser 'dist\firefox') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $multiBrowser 'dist\chrome\manifest.json'),'{' + '"name":"Chrome","version":"2.0.0","manifest_version":3}',[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $multiBrowser 'dist\firefox\manifest.json'),'{' + '"name":"Firefox","version":"2.0.0","manifest_version":3}',[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $ambiguous 'manifest.json'),'{' + '"name":"Source","version":"1.0.0","manifest_version":3}',[Text.UTF8Encoding]::new($false))
    New-Item -ItemType Directory -Path (Join-Path $ambiguous 'dist') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $ambiguous 'dist\manifest.json'),'{' + '"name":"Dist","version":"1.0.0","manifest_version":3}',[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $ordinary 'manifest.json'),'{' + '"name":"Ordinary metadata","version":"1.0.0"}',[Text.UTF8Encoding]::new($false))
    Import-Module $modulePath -Force
    $staticDescriptor = Get-SgBrowserExtensionDescriptor $static; $builtDescriptor = Get-SgBrowserExtensionDescriptor $built
    Assert-Sg ($staticDescriptor.Mode -eq 'static' -and $staticDescriptor.RelativeManifestPath -eq 'manifest.json') 'Static extension was not detected.'
    Assert-Sg ($builtDescriptor.Mode -eq 'built' -and $builtDescriptor.RelativeManifestPath -eq 'dist/chrome/manifest.json') 'Built extension was not detected.'
    Assert-Sg ((Get-SgBrowserExtensionDescriptor $multiBrowser Chromium).RelativeManifestPath -eq 'dist/chrome/manifest.json') 'Chromium did not select its browser-specific artifact.'
    Assert-Sg ((Get-SgBrowserExtensionDescriptor $multiBrowser Firefox).RelativeManifestPath -eq 'dist/firefox/manifest.json') 'Firefox did not select its browser-specific artifact.'
    Assert-Sg ((Get-SgProjectKind $static) -eq 'browser-extension') 'Static extension was not classified as runnable.'
    Assert-Sg ($null -eq (Get-SgBrowserExtensionDescriptor $ordinary)) 'An ordinary manifest was misclassified as a browser extension.'
    $rejected = $false; try { Get-SgBrowserExtensionDescriptor $ambiguous | Out-Null } catch { $rejected = $_.Exception.Message -match 'Multiple browser extension artifacts' }
    Assert-Sg $rejected 'Ambiguous extension artifacts were silently selected.'
    $moduleText = [IO.File]::ReadAllText($modulePath)
    $cliText = [IO.File]::ReadAllText($cliPath)
    $runnerText = [IO.File]::ReadAllText($runnerPath)
    Assert-Sg ($cliText -match 'extension-lab.*\[-Browser.*\[-Screenshot\]') 'Extension Lab help does not advertise multi-browser visual proof.'
    Assert-Sg ($moduleText -match "extension-lab-evidence" -and $moduleText -match "--screenshot") 'Extension Lab does not retain screenshot evidence outside its temporary profile.'
    foreach ($contract in @('screenshotStatus','screenshotPath','VIEWPORT','--browser','--click-selector','--visual-selector','webExtension.install','isolatedProfile','--disable-vivaldi','observation-unavailable')) {
        Assert-Sg ($runnerText.Contains($contract)) "Extension Lab visual JSON contract is missing: $contract"
    }
    foreach ($contract in @('Get-SgBrowserLabExecutable','--browser-executable','--browser-product','--browser-version')) {
        Assert-Sg ($moduleText.Contains($contract)) "Extension Lab browser identity contract is missing: $contract"
    }
    Write-Host 'Windows browser extension lab detection: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
