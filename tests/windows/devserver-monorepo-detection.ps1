$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-monorepo-{0}" -f [guid]::NewGuid().ToString('N'))

try {
    $site = Join-Path $fixture 'site'
    $frontend = Join-Path $fixture 'apps\frontend'
    $backend = Join-Path $fixture 'apps\backend'
    $flutter = Join-Path $fixture 'apps\mobile'
    $ignored = Join-Path $fixture 'node_modules\fake'
    New-Item -ItemType Directory -Path $site,$frontend,$backend,(Join-Path $flutter 'web'),$ignored -Force | Out-Null
    Set-Content (Join-Path $site 'package.json') '{"dependencies":{"astro":"latest"},"scripts":{"dev":"astro dev"}}' -Encoding UTF8
    Set-Content (Join-Path $frontend 'package.json') '{"devDependencies":{"vite":"latest"},"scripts":{"dev":"vite"}}' -Encoding UTF8
    Set-Content (Join-Path $backend 'requirements.txt') 'fastapi' -Encoding UTF8
    Set-Content (Join-Path $flutter 'pubspec.yaml') "flutter:`n  uses-material-design: true" -Encoding UTF8
    Set-Content (Join-Path $ignored 'package.json') '{"dependencies":{"astro":"latest"}}' -Encoding UTF8

    Import-Module $modulePath -Force -DisableNameChecking
    $descriptors = @(Get-SgProjectDescriptors $fixture)
    if ($descriptors.Count -ne 4) { throw "Expected four runnable surfaces, got $($descriptors.Count)." }
    $kinds = @($descriptors.Kind | Sort-Object)
    if (($kinds -join ',') -ne 'astro,flutter-web,python,vite') { throw "Unexpected surface kinds: $($kinds -join ',')." }
    if (@($descriptors | Where-Object { $_.LaunchPath -like '*node_modules*' }).Count) { throw 'A pruned dependency directory was detected as a surface.' }

    $runtime = Join-Path $fixture 'runtime'
    New-Item -ItemType Directory -Path $runtime -Force | Out-Null
    $config = [pscustomobject]@{Workspace=$fixture;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock')}
    $registered = @(Register-SgProject $config $fixture)
    if ($registered.Count -ne 4 -or @($registered | Select-Object -ExpandProperty name -Unique).Count -ne 4) { throw 'Monorepo surfaces were not registered independently.' }
    foreach ($entry in $registered) {
        $environment = Get-SgProjectEnvironment $entry.path
        if (-not $environment -or $environment.Port -ne 0) { throw "Surface environment was not initialized: $($entry.path)" }
    }

    [void](Write-SgProjectEnvironment $site 32123)
    $registeredAgain = @(Register-SgProject $config $fixture)
    $siteEntry = $registeredAgain | Where-Object { $_.path -eq $site } | Select-Object -First 1
    if ($siteEntry.port -ne 32123) { throw 'Registration did not hydrate the durable surface port.' }
    [void](Write-SgProjectEnvironment $frontend 32123)
    $collisionRegistration = @(Register-SgProject $config $fixture)
    $frontendEntry = $collisionRegistration | Where-Object { $_.path -eq $frontend } | Select-Object -First 1
    if ($frontendEntry.port -ne 0) { throw 'Registration accepted a durable port already owned by another surface.' }
    if ((Get-SgProjectEnvironment $frontend).Port -ne 0) { throw 'Registration did not reconcile the colliding durable port.' }

    $ambiguous = $false
    try { Get-SgProjectDescriptor $fixture | Out-Null } catch { $ambiguous = $_.Exception.Message -like 'Multiple runnable surfaces*' }
    if (-not $ambiguous) { throw 'A multi-surface root was not rejected by the single-surface API.' }

    Set-Content (Join-Path $site 'package.json') '{broken' -Encoding UTF8
    $invalid = $false
    try { Get-SgProjectDescriptors $fixture | Out-Null } catch { $invalid = $_.Exception.Message -like 'Invalid package.json:*' }
    if (-not $invalid) { throw 'Invalid package.json was silently treated as an absent surface.' }
    Write-Host 'Windows DevServer monorepo detection: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
