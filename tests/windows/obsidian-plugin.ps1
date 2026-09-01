$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-obsidian-plugin-{0}" -f [guid]::NewGuid().ToString('N'))

function Write-SgObsidianFixture([string]$Path, [string]$Id = 'dreamglows') {
    New-Item -ItemType Directory -Path (Join-Path $Path 'src') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $Path 'package.json'), @"
{"name":"obsidian-$Id","scripts":{"dev":"vite build --mode development --watch","build":"vite build"},"devDependencies":{"obsidian":"^1.7.2","vite":"^8.2.0"}}
"@, [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $Path 'manifest.json'), @"
{"id":"$Id","name":"DreamGlows","version":"1.0.0","minAppVersion":"0.15.0","description":"Fixture"}
"@, [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $Path 'src\main.ts'), 'export default class FixturePlugin {}', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $Path 'styles.css'), '.fixture {}', [Text.UTF8Encoding]::new($false))
}

try {
    $chrome = Join-Path $fixture 'chrome_extension'
    $obsidian = Join-Path $fixture 'obsidian_plugin'
    $vite = Join-Path $fixture 'site'
    foreach ($path in @($chrome,$obsidian,$vite)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    [IO.File]::WriteAllText((Join-Path $chrome 'package.json'), '{"scripts":{"dev":"vite","dev:chrome":"vite -c vite.chrome.config.ts"},"devDependencies":{"@crxjs/vite-plugin":"^2.7.1","vite":"^8.2.2"}}', [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText((Join-Path $vite 'package.json'), '{"scripts":{"dev":"vite"},"devDependencies":{"vite":"^8.2.2"}}', [Text.UTF8Encoding]::new($false))
    Write-SgObsidianFixture $obsidian

    Import-Module $modulePath -Force -DisableNameChecking
    Assert-Sg ((Get-SgProjectKind $obsidian) -eq 'obsidian-plugin') 'Obsidian was not classified before generic Vite.'
    Assert-Sg ((Get-SgProjectKind $chrome) -eq 'browser-extension') 'Chrome extension classification regressed.'
    Assert-Sg ((Get-SgProjectKind $vite) -eq 'vite') 'Ordinary Vite classification regressed.'

    $descriptor = Get-SgObsidianPluginDescriptor $obsidian
    Assert-Sg ($descriptor.PluginId -eq 'dreamglows') 'Obsidian plugin id was not exposed.'
    Assert-Sg ($descriptor.DevelopmentScriptName -eq 'dev' -and $descriptor.BuildScriptName -eq 'build') 'Declared Obsidian scripts were not exposed.'
    Assert-Sg (($descriptor.ArtifactPaths -join ',') -eq 'main.js,manifest.json,styles.css') 'Obsidian artifact inventory is incomplete.'
    Assert-Sg (($descriptor.Evidence -join ' ') -match 'manifest.json.*package.json.*src/main.ts.*scripts.dev') 'Obsidian classification evidence is incomplete.'
    Assert-Sg ($descriptor.SurfaceState -eq 'detected') 'An unconfigured Obsidian plugin was not reported as detected.'
    Assert-Sg ((Get-SgProjectExperience 'obsidian-plugin').Label -eq 'Obsidian plugin') 'Obsidian user-facing label is missing.'

    $descriptors = @(Get-SgProjectDescriptors $fixture)
    Assert-Sg ($descriptors.Count -eq 3) 'Chrome + Obsidian + Vite monorepo surfaces were not detected independently.'
    Assert-Sg ((@($descriptors.Kind | Sort-Object) -join ',') -eq 'browser-extension,obsidian-plugin,vite') 'Mixed monorepo kinds are incorrect.'

    $module = Get-Module ShipGlows.DevServer
    $launch = & $module {
        param($Project)
        function Get-SgCommandPath([string[]]$Names) { return 'C:\tools\npm.cmd' }
        Get-SgLaunchSpec $Project 'obsidian-plugin' 0
    } $obsidian
    $launchText = $launch.Arguments -join ' '
    Assert-Sg ($launchText -match 'run dev') 'Obsidian start did not use the declared development script.'
    Assert-Sg ($launchText -notmatch '(?i)--host|--port|vite\s+--') 'Obsidian launch inherited generic HTTP/Vite flags.'

    $runtime = Join-Path $fixture 'runtime'
    $logs = Join-Path $runtime 'logs'
    New-Item -ItemType Directory -Path $runtime,$logs -Force | Out-Null
    $config = [pscustomobject]@{Workspace=$fixture;RuntimeDirectory=$runtime;RegistryPath=(Join-Path $runtime 'registry.json');LockPath=(Join-Path $runtime 'registry.lock');LogDirectory=$logs;PortStart=32300;PortEnd=32309}
    $registered = @(Register-SgProject $config $obsidian) | Select-Object -First 1
    Assert-Sg ($registered.surfaceState -eq 'detected' -and $registered.pluginId -eq 'dreamglows') 'Registration did not retain detected Obsidian metadata.'
    $missingVault = $false
    try { Start-SgProject $config $obsidian | Out-Null }
    catch { $missingVault = $_.Exception.Message -match 'SHIPGLOWS_OBSIDIAN_VAULT.*\.shipglows\.env' }
    Assert-Sg $missingVault 'Start did not fail actionably when no Obsidian vault was declared.'
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $fixture '.obsidian'))) 'ShipGlows invented an Obsidian vault.'

    $vault = Join-Path $fixture 'isolated-vault'
    New-Item -ItemType Directory -Path (Join-Path $vault '.obsidian\plugins') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $obsidian '.shipglows.env'), "SHIPGLOWS_OBSIDIAN_VAULT=$vault`nSHIPGLOWS_OBSIDIAN_SYNC_MODE=copy`n", [Text.UTF8Encoding]::new($false))
    $settings = Get-SgRuntimeSettings $obsidian
    Assert-Sg ($settings.ObsidianVault -eq [IO.Path]::GetFullPath($vault) -and $settings.ObsidianSyncMode -eq 'copy') 'Explicit Obsidian vault configuration was not resolved.'

    $descriptor = Get-SgObsidianPluginDescriptor $obsidian
    Assert-Sg ($descriptor.SurfaceState -eq 'build-required') 'Missing main.js did not produce build-required.'
    [IO.File]::WriteAllText((Join-Path $obsidian 'main.js'), 'module.exports = class FixturePlugin {};', [Text.UTF8Encoding]::new($false))
    (Get-Item -LiteralPath (Join-Path $obsidian 'main.js')).LastWriteTimeUtc = [DateTime]::UtcNow.AddMinutes(-10)
    (Get-Item -LiteralPath (Join-Path $obsidian 'src\main.ts')).LastWriteTimeUtc = [DateTime]::UtcNow
    Assert-Sg ((Get-SgObsidianPluginDescriptor $obsidian).SurfaceState -eq 'build-required') 'Stale main.js did not produce build-required.'
    (Get-Item -LiteralPath (Join-Path $obsidian 'main.js')).LastWriteTimeUtc = [DateTime]::UtcNow.AddSeconds(1)
    $descriptor = Get-SgObsidianPluginDescriptor $obsidian
    Assert-Sg ($descriptor.SurfaceState -eq 'configured') 'Fresh artifacts plus an explicit vault did not produce configured.'

    $sync = Sync-SgObsidianPluginArtifacts $descriptor $vault
    $target = Join-Path $vault '.obsidian\plugins\dreamglows'
    Assert-Sg ($sync.TargetPath -eq $target -and $sync.Copied.Count -eq 3) 'Obsidian copy sync did not report the exact isolated target and artifacts.'
    foreach ($artifact in @('main.js','manifest.json','styles.css')) {
        $sourceHash = (Get-FileHash -LiteralPath (Join-Path $obsidian $artifact) -Algorithm SHA256).Hash
        $targetHash = (Get-FileHash -LiteralPath (Join-Path $target $artifact) -Algorithm SHA256).Hash
        Assert-Sg ($sourceHash -eq $targetHash) "Obsidian sync did not preserve $artifact."
    }

    $ready = & $module {
        param($Project)
        function Test-SgProcessIdentity([object]$Entry) { return $true }
        Wait-SgObsidianPluginReady $Project 0 ([pscustomobject]@{startTimeUtc=[DateTimeOffset]::UtcNow.AddSeconds(-2).ToString('o')}) ''
    } $obsidian
    Assert-Sg ($ready.Ready -and $ready.PluginId -eq 'dreamglows') 'Fresh Obsidian artifacts were not accepted as build readiness evidence.'

    & $module { param($Config,$Surface) Invoke-SgRegistryMutation $Config { param($data); $entry=@($data.projects|Where-Object{$_.path-eq$Surface})[0]; $entry.status='stopped';$entry.pid=0;$entry.startTimeUtc=$null } | Out-Null } $config $obsidian
    $started = & $module {
        param($Config,$Surface,$Vault)
        $script:launchPort = -1
        function Invoke-SgDependencySetup { }
        function Get-SgLaunchSpec { param($ProjectPath,$Kind,$Port) $script:launchPort=$Port; [pscustomobject]@{FilePath='mock.exe';Arguments=@();Signature='obsidian-watch';Interactive=$false} }
        function Start-SgDetachedProcess { [pscustomobject]@{Id=91;CommandSignature='obsidian-watch';JobName='Local\ShipGlows-11111111111111111111111111111111'} }
        function Get-SgProcessSnapshot { [pscustomobject]@{Pid=91;StartTimeUtc='2026-09-01T00:00:00Z';ExecutablePath='mock.exe';CommandLine='obsidian-watch'} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 91 }
        function Wait-SgObsidianPluginReady { [pscustomobject]@{Ready=$true;AppId=$null;PluginId='dreamglows';ArtifactPaths=@('main.js','manifest.json','styles.css');Error=$null} }
        function Sync-SgObsidianPluginArtifacts { [pscustomobject]@{TargetPath=(Join-Path $Vault '.obsidian\plugins\dreamglows');Copied=@('main.js','manifest.json','styles.css')} }
        $result = Start-SgProject $Config $Surface
        [pscustomobject]@{Result=$result;LaunchPort=$script:launchPort}
    } $config $obsidian $vault
    Assert-Sg ($started.LaunchPort -eq 0 -and $started.Result.port -eq 0) 'Obsidian start allocated or forwarded an HTTP port.'
    Assert-Sg ($started.Result.status -eq 'running' -and $started.Result.surfaceState -eq 'ready') 'Obsidian watch/build/sync state did not become running + ready.'
    Assert-Sg ($started.Result.validationState -eq 'validation-unavailable') 'Actual Obsidian load was not distinguished from build/sync readiness.'
    Assert-Sg ($started.Result.obsidianPluginPath -eq $target) 'Registry state omitted the explicit Obsidian installation target.'
    Assert-Sg ((Format-SgProjectStatus $started.Result) -match 'Obsidian plugin.*ready.*validation-unavailable') 'User-facing Obsidian state is not explicit.'
    Assert-Sg ((Get-SgProjectEnvironment $obsidian).Url -eq '') 'Obsidian ENVIRONMENT.md still claims a localhost URL.'
    Assert-Sg ((Open-SgProject $config $started.Result).path -eq $obsidian) 'Obsidian Open guidance incorrectly required a web port.'

    Write-Host 'Windows Obsidian plugin support: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
