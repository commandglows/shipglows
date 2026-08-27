$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-browser-extension-{0}" -f [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    $extension = Join-Path $fixture 'toolglows'
    $vite = Join-Path $fixture 'site'
    $incomplete = Join-Path $fixture 'incomplete-extension'
    $unsafeManager = Join-Path $fixture 'unsafe-package-manager'
    foreach ($path in @($extension,$vite,$incomplete,$unsafeManager)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }

    [IO.File]::WriteAllText((Join-Path $extension 'package.json'), @'
{"name":"toolglows","packageManager":"pnpm@10.33.2","scripts":{"dev":"vite","dev:chrome":"vite -c vite.chrome.config.ts"},"devDependencies":{"@crxjs/vite-plugin":"^2.7.1","vite":"^8.2.2"}}
'@, [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $extension 'pnpm-lock.yaml'), "lockfileVersion: '9.0'`n", [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $vite 'package.json'), '{"scripts":{"dev":"vite"},"devDependencies":{"vite":"^8.2.2"}}', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $incomplete 'package.json'), '{"scripts":{"dev":"vite"},"devDependencies":{"@crxjs/vite-plugin":"^2.7.1","vite":"^8.2.2"}}', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $unsafeManager 'package.json'), '{"packageManager":"pnpm@10.33.2 & whoami","scripts":{"dev:chrome":"vite"},"devDependencies":{"@crxjs/vite-plugin":"^2.7.1"}}', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $unsafeManager 'pnpm-lock.yaml'), "lockfileVersion: '9.0'`n", [Text.UTF8Encoding]::new($false))

    Import-Module $modulePath -Force
    Assert-Sg ((Get-SgProjectKind $extension) -eq 'browser-extension') 'CRXJS extension was not classified before generic Vite.'
    Assert-Sg ((Get-SgProjectKind $vite) -eq 'vite') 'Generic Vite project changed kind.'
    Assert-Sg ((Get-SgProjectKind $incomplete) -eq 'vite') 'Extension dependency without explicit dev:chrome script became an executable extension contract.'

    $module = Get-Module ShipGlows.DevServer
    $plan = & $module {
        param($Project)
        function Get-SgCommandPath([string[]]$Names) {
            if ($Names -contains 'corepack.cmd') { return 'C:\tools\corepack.cmd' }
            if ($Names -contains 'pnpm.cmd') { return 'C:\tools\pnpm.cmd' }
            return $null
        }
        New-SgDependencyPlan $Project 'browser-extension'
    } $extension
    Assert-Sg ($plan.Manager -eq 'C:\tools\corepack.cmd') 'Pinned pnpm project did not select Corepack.'
    Assert-Sg (($plan.Arguments -join ' ') -eq 'pnpm@10.33.2 install --frozen-lockfile') 'Pinned pnpm install arguments drifted.'

    $unsafeRejected = $false
    try {
        & $module { param($Project) New-SgDependencyPlan $Project 'browser-extension' } $unsafeManager | Out-Null
    } catch { $unsafeRejected = $_.Exception.Message -match 'Unsupported packageManager declaration' }
    Assert-Sg $unsafeRejected 'Unsafe packageManager text reached the command plan.'

    $launch = & $module {
        param($Project)
        function Get-SgCommandPath([string[]]$Names) { return 'C:\tools\corepack.cmd' }
        Get-SgLaunchSpec $Project 'browser-extension' 32145
    } $extension
    $launchText = $launch.Arguments -join ' '
    Assert-Sg ($launchText -match 'pnpm@10[.]33[.]2 run dev:chrome --host 127[.]0[.]0[.]1 --port 32145') 'Extension launch did not use the explicit Chrome script and reserved HMR port.'
    Assert-Sg ($launchText -notmatch 'run dev:chrome -- --host') 'Pinned pnpm launch forwarded a redundant option separator to Vite.'

    $dist = Join-Path $extension 'dist\chrome'
    New-Item -ItemType Directory -Path $dist -Force | Out-Null
    $manifest = Join-Path $dist 'manifest.json'
    [IO.File]::WriteAllText($manifest, '{"name":"ToolGlows","version":"1.0.0","manifest_version":3}', [Text.UTF8Encoding]::new($false))
    (Get-Item -LiteralPath $manifest).LastWriteTimeUtc = [DateTime]::UtcNow
    $ready = & $module {
        param($Project)
        function Test-SgProcessIdentity([object]$Entry) { return $true }
        function Test-SgPortAvailable([int]$Port) { return $false }
        Wait-SgBrowserExtensionReady $Project 32145 1 ([pscustomobject]@{ startTimeUtc=[DateTimeOffset]::UtcNow.AddSeconds(-2).ToString('o') }) ''
    } $extension
    Assert-Sg ($ready.Ready -and $ready.ManifestPath -eq $manifest) 'Fresh Manifest V3 package was not accepted as extension readiness evidence.'

    [IO.File]::WriteAllText($manifest, '{"name":"ToolGlows","version":"1.0.0","manifest_version":2}', [Text.UTF8Encoding]::new($false))
    $invalidManifest = & $module {
        param($Project)
        function Test-SgProcessIdentity([object]$Entry) { return $true }
        function Test-SgPortAvailable([int]$Port) { return $false }
        Wait-SgBrowserExtensionReady $Project 32145 0 ([pscustomobject]@{ startTimeUtc=[DateTimeOffset]::UtcNow.AddSeconds(-2).ToString('o') }) ''
    } $extension
    Assert-Sg (-not $invalidManifest.Ready) 'Manifest V2 was accepted by the Manifest V3 readiness contract.'

    [IO.File]::WriteAllText($manifest, '{"name":"ToolGlows","version":"1.0.0","manifest_version":3}', [Text.UTF8Encoding]::new($false))
    (Get-Item -LiteralPath $manifest).LastWriteTimeUtc = [DateTime]::UtcNow.AddMinutes(-10)
    $staleManifest = & $module {
        param($Project)
        function Test-SgProcessIdentity([object]$Entry) { return $true }
        function Test-SgPortAvailable([int]$Port) { return $false }
        Wait-SgBrowserExtensionReady $Project 32145 0 ([pscustomobject]@{ startTimeUtc=[DateTimeOffset]::UtcNow.ToString('o') }) ''
    } $extension
    Assert-Sg (-not $staleManifest.Ready) 'A stale unpacked manifest was accepted as current startup evidence.'

    [void](Write-SgProjectEnvironment $extension 32145 -Kind 'browser-extension')
    $environment = Get-SgProjectEnvironment $extension
    $environmentText = [IO.File]::ReadAllText((Join-Path $extension 'ENVIRONMENT.md'))
    Assert-Sg ($environment.Kind -eq 'browser-extension' -and -not $environment.Url) 'Extension environment still claims an ordinary local web URL.'
    Assert-Sg ($environmentText -match 'Unpacked Chrome directory: `dist/chrome`') 'Extension environment omitted the unpacked Chrome target.'

    $runtime = Join-Path $fixture 'runtime'
    New-Item -ItemType Directory -Path $runtime -Force | Out-Null
    $config = [pscustomobject]@{
        Workspace = $fixture
        RuntimeDirectory = $runtime
        RegistryPath = Join-Path $runtime 'registry.json'
        LockPath = Join-Path $runtime 'registry.lock'
    }
    $staleRegistry = [pscustomobject]@{
        schemaVersion = 1
        projects = @([pscustomobject]@{
            name='toolglows'; path=$extension; rootPath=$extension; launchPath=$extension; kind='vite'; port=0; status='stopped'; pid=0
        })
    }
    [IO.File]::WriteAllText($config.RegistryPath, ($staleRegistry | ConvertTo-Json -Depth 6), [Text.UTF8Encoding]::new($false))
    $migratedPaths = @(Sync-SgRegisteredProjectEnvironments $config)
    $migratedEntry = @((Read-SgRegistry $config).projects | Where-Object { $_.path -eq $extension }) | Select-Object -First 1
    Assert-Sg ($migratedPaths -contains $extension) 'Installer synchronization omitted the registered extension path.'
    Assert-Sg ($migratedEntry -and $migratedEntry.kind -eq 'browser-extension') 'Installer synchronization left the registry on its stale Vite kind.'

    Write-Host 'Windows browser-extension project support: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
