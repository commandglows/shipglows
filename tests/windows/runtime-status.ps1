$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$modulePath = Join-Path $root 'cli\windows\ShipGlows.RuntimeStatus.psm1'
$versionPath = Join-Path $root 'shipglows-version.json'
$tokens = $null
$errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($modulePath,[ref]$tokens,[ref]$errors)
Assert-Sg (-not $errors -or $errors.Count -eq 0) 'Runtime-status module must parse.'
Assert-Sg ((Get-Content -Raw $versionPath | ConvertFrom-Json).version -match '^\d+\.\d+\.\d+$') 'ShipGlows must publish a canonical semantic version.'
Import-Module $modulePath -Force -DisableNameChecking

$current = Get-SgShipGlowsUpdateAssessment '0.1.0' '0.1.0' 'same' 'same'
Assert-Sg ($current.Level -eq 'current' -and -not $current.Available) 'Matching versions must be green/current.'
$patch = Get-SgShipGlowsUpdateAssessment '0.1.0' '0.1.1'
Assert-Sg ($patch.Level -eq 'update' -and $patch.Available) 'A patch release must be orange/update.'
$minor = Get-SgShipGlowsUpdateAssessment '0.1.0' '0.2.0'
Assert-Sg ($minor.Level -eq 'major-update' -and $minor.Available) 'A minor release must be red/major-update.'
$source = Get-SgShipGlowsUpdateAssessment '0.1.0' '0.1.0' 'installed' 'newer'
Assert-Sg ($source.Level -eq 'update' -and $source.Available) 'A newer linked source commit must request an update.'
$unknown = Get-SgShipGlowsUpdateAssessment '' '0.1.0'
Assert-Sg ($unknown.Level -eq 'unknown') 'Missing installed version must stay explicit.'

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-runtime-status-' + [guid]::NewGuid().ToString('N'))
$previousUserProfile = $env:USERPROFILE
try {
    $env:USERPROFILE = Join-Path $fixture 'user'
    $runtime = Join-Path $fixture 'runtime'
    New-Item -ItemType Directory -Path (Join-Path $env:USERPROFILE '.shipglows\runtime'),$runtime -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $env:USERPROFILE '.shipglows\runtime\.shipglows-install.json'),'{"schemaVersion":1,"version":"0.1.0","sourceCommit":"installed"}',[Text.UTF8Encoding]::new($false))
    $config = [pscustomobject]@{ RuntimeDirectory=$runtime }
    $result = Update-SgShipGlowsStatusCache $config { '0.1.1' }
    Assert-Sg ($result.level -eq 'update') 'Cached remote patch result must retain the update level.'
    $cache = Read-SgShipGlowsStatusCache $config
    Assert-Sg ($cache -and $cache.installedVersion -eq '0.1.0' -and (Test-SgShipGlowsStatusCacheFresh $cache)) 'Cache must be readable and fresh after an atomic write.'
    Remove-Item -LiteralPath (Get-SgRuntimeStatusPaths $config).CachePath -Force
    $offline = Update-SgShipGlowsStatusCache $config { '' }
    Assert-Sg ($offline.level -eq 'unknown' -and -not (Test-Path -LiteralPath (Get-SgRuntimeStatusPaths $config).CachePath)) 'A failed first check must not cache a false current result.'
} finally {
    $env:USERPROFILE = $previousUserProfile
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}

Write-Output 'Windows ShipGlows runtime-status tests passed.'
