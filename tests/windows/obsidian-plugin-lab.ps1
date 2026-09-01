$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition,[string]$Message){if(-not$Condition){throw $Message}}

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-obsidian-lab-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path (Join-Path $fixture 'src') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $fixture 'package.json'),'{'+'"name":"obsidian-fixture","scripts":{"dev":"vite build --watch","build":"vite build"},"devDependencies":{"obsidian":"^1.12.0","vite":"^8.0.0"}}',[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $fixture 'manifest.json'),'{'+'"id":"fixture-plugin","name":"Fixture Plugin","version":"1.2.3","minAppVersion":"1.12.7"}',[Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $fixture 'src\main.ts'),'export default class FixturePlugin {}',[Text.UTF8Encoding]::new($false))
    Import-Module $modulePath -Force -DisableNameChecking
    $required = Get-SgObsidianBratArtifactReport $fixture
    Assert-Sg ($required.State -eq 'build-required' -and $required.Missing -contains 'main.js') 'Missing main.js did not produce build-required.'
    [IO.File]::WriteAllText((Join-Path $fixture 'main.js'),'module.exports = class FixturePlugin {};',[Text.UTF8Encoding]::new($false))
    $passed = Get-SgObsidianBratArtifactReport $fixture
    Assert-Sg ($passed.State -eq 'passed' -and $passed.Files.Count -eq 2) 'Valid local BRAT artifacts did not pass.'
    Assert-Sg (@($passed.Files | Where-Object {$_.Sha256 -notmatch '^[A-F0-9]{64}$'}).Count -eq 0) 'Artifact hashes are missing or malformed.'
    (Get-Item -LiteralPath (Join-Path $fixture 'src\main.ts')).LastWriteTimeUtc=[DateTime]::UtcNow.AddSeconds(2)
    Assert-Sg ((Get-SgObsidianBratArtifactReport $fixture).State -eq 'build-required') 'Stale main.js was accepted by the Lab.'
    (Get-Item -LiteralPath (Join-Path $fixture 'main.js')).LastWriteTimeUtc=[DateTime]::UtcNow.AddSeconds(3)
    [IO.File]::WriteAllText((Join-Path $fixture 'style.css'),'body{}',[Text.UTF8Encoding]::new($false))
    Assert-Sg ((Get-SgObsidianBratArtifactReport $fixture).State -eq 'failed') 'Misnamed style.css was accepted.'
    Remove-Item -LiteralPath (Join-Path $fixture 'style.css') -Force
    [IO.File]::WriteAllText((Join-Path $fixture 'versions.json'),'{'+'"1.2.2":"1.12.7"}',[Text.UTF8Encoding]::new($false))
    Assert-Sg ((Get-SgObsidianBratArtifactReport $fixture).State -eq 'failed') 'Inconsistent versions.json was accepted.'
    $runner = Get-Content -LiteralPath (Join-Path $root 'cli\windows\ShipGlows.ObsidianLab.js') -Raw
    Assert-Sg ($runner -match '--user-data-dir=' -and $runner -match '127\.0\.0\.1' -and $runner -match 'taskkill\.exe') 'Runner isolation/process identity contract is incomplete.'
    Write-Host 'Windows Obsidian local lab contracts: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if(Test-Path -LiteralPath $fixture){Remove-Item -LiteralPath $fixture -Recurse -Force}
}
