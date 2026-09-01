param([string]$ManagedPowerShellPath = '')

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$mobileModule = Join-Path $root 'cli\windows\ShipGlows.MobileToolchain.psm1'
$devServerModule = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$managedPowerShell = if ($ManagedPowerShellPath) { [IO.Path]::GetFullPath($ManagedPowerShellPath) } else { [IO.Path]::GetFullPath((Get-Process -Id $PID -ErrorAction Stop).Path) }

function Assert-Sg([bool]$Condition,[string]$Message) { if (-not $Condition) { throw $Message } }
Assert-Sg (-not [string]::IsNullOrWhiteSpace($managedPowerShell)) 'The managed PowerShell runtime identity is unavailable.'
$managedRoot = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell')).TrimEnd('\') + '\'
Assert-Sg ([IO.Path]::IsPathRooted($managedPowerShell) -and [IO.Path]::GetFileName($managedPowerShell) -ieq 'pwsh.exe' -and $managedPowerShell.StartsWith($managedRoot,[StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $managedPowerShell -PathType Leaf)) 'The managed PowerShell identity must be an existing ShipGlows-owned absolute pwsh.exe path.'

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-environment-activation-' + [guid]::NewGuid().ToString('N'))
try {
    $runtime = Join-Path $fixture 'runtime'
    $bin = Join-Path $runtime 'bin'
    $toolchain = Join-Path $runtime 'toolchains\tauri-windows'
    $project = Join-Path $fixture 'communityglows'
    $site = Join-Path $project 'site'
    $desktopA = Join-Path $project 'apps\desktop-a'
    $desktopB = Join-Path $project 'apps\desktop-b'
    New-Item -ItemType Directory -Path $bin,$toolchain,$site,$desktopA,$desktopB -Force | Out-Null

    Import-Module $mobileModule -Force -DisableNameChecking
    $fakeMise = Join-Path $runtime 'mise.cmd'
    @'
@echo off
if "%1"=="-C" shift
if not "%1"=="" shift
if "%1"=="exec" shift
if "%1"=="rust@1.97.1" shift
if "%1"=="--" shift
if "%1"=="cargo" echo cargo 1.97.1 (fixture)& exit /b 0
if "%1"=="rustc" echo rustc 1.97.1 (fixture)& exit /b 0
if "%1"=="rustup" echo rustup 1.28.2 (fixture)& exit /b 0
exit /b 65
'@ | Set-Content -LiteralPath $fakeMise -Encoding ASCII
    foreach ($command in @('cargo','rustc','rustup')) {
        [IO.File]::WriteAllText((Join-Path $bin "$command.cmd"),(Get-SgTauriRustWrapperContent -MisePath $fakeMise -ToolchainRoot $toolchain -Command $command),[Text.Encoding]::ASCII)
    }

    $worker = Join-Path $fixture 'worker.ps1'
    @'
$ErrorActionPreference='Stop'
$env:PATH=$env:SHIPGLOWS_FIXTURE_BIN+';'+[Environment]::GetEnvironmentVariable('SystemRoot')+'\System32'
[pscustomobject]@{Pid=$PID;Cargo=(& cargo --version);Rustc=(& rustc --version);Rustup=(& rustup --version)} | ConvertTo-Json -Compress
'@ | Set-Content -LiteralPath $worker -Encoding UTF8
    $env:SHIPGLOWS_FIXTURE_BIN = $bin
    $direct = (& $managedPowerShell -NoLogo -NoProfile -NonInteractive -File $worker | ConvertFrom-Json)
    Assert-Sg ($direct.Cargo -match '^cargo 1[.]97[.]1 ' -and $direct.Rustc -match '^rustc 1[.]97[.]1 ' -and $direct.Rustup -match '^rustup 1[.]28[.]2 ') 'Disposable wrappers were not activated in a new managed PowerShell process.'

    $agentChild = Join-Path $fixture 'agent-child.ps1'
    @'
$ErrorActionPreference='Stop'
& $env:SHIPGLOWS_MANAGED_PWSH -NoLogo -NoProfile -NonInteractive -File $env:SHIPGLOWS_FIXTURE_WORKER
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
'@ | Set-Content -LiteralPath $agentChild -Encoding UTF8
    $env:SHIPGLOWS_FIXTURE_WORKER = $worker
    $env:SHIPGLOWS_MANAGED_PWSH = $managedPowerShell
    $agent = (& $managedPowerShell -NoLogo -NoProfile -NonInteractive -File $agentChild | ConvertFrom-Json)
    Assert-Sg ($agent.Pid -ne $direct.Pid -and $agent.Cargo -match '^cargo 1[.]97[.]1 ') 'An agent-like child did not inherit the activated wrappers in its own managed process.'

    Remove-Module ShipGlows.MobileToolchain -Force
    Import-Module $devServerModule -Force -DisableNameChecking
    $devServerText = [IO.File]::ReadAllText($devServerModule)
    $startOffset = $devServerText.IndexOf('function Start-SgProject',[StringComparison]::Ordinal)
    $stopOffset = $devServerText.IndexOf('function Stop-SgProject',[StringComparison]::Ordinal)
    $startText = $devServerText.Substring($startOffset,$stopOffset-$startOffset)
    Assert-Sg ($startText.IndexOf('Read-SgEnvironmentState',[StringComparison]::Ordinal) -ge 0 -and $startText.IndexOf('Read-SgEnvironmentState',[StringComparison]::Ordinal) -lt $startText.IndexOf('Reserve-SgProjectPort',[StringComparison]::Ordinal)) 'DevServer does not consume environment readiness before its first port mutation.'
    $capabilities = @(
        [pscustomobject]@{kind='tool';id='node';scope='.';status='ready'},
        [pscustomobject]@{kind='tool';id='pnpm';scope='.';status='ready'},
        [pscustomobject]@{kind='tool';id='node';scope='site';status='ready'},
        [pscustomobject]@{kind='tool';id='pnpm';scope='site';status='ready'},
        [pscustomobject]@{kind='target';id='tauri-windows';scope='.';status='blocked'}
    )
    $state = [pscustomobject]@{schema='shipglows.environment-state/v1';project=[pscustomobject]@{root=$project};observed=[pscustomobject]@{capabilities=$capabilities}}
    $previousStateRoot = $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT
    $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT = Join-Path $fixture 'state'
    New-Item -ItemType Directory -Path $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT -Force | Out-Null
    $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Get-SgEnvironmentStatePath $project) -Encoding UTF8
    $loadedState = Read-SgEnvironmentState $project
    Assert-Sg ($loadedState.project.root -eq $project -and @($loadedState.observed.capabilities).Count -eq 5) 'DevServer did not read the project-scoped persisted readiness state.'
    $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT = $previousStateRoot
    $extension = Get-SgEnvironmentReadinessForSurface -ProjectRoot $project -LaunchPath $project -Kind browser-extension -EnvironmentState $state
    Assert-Sg ($extension.Status -eq 'ready' -and $extension.SurfaceStatus -eq 'ready' -and $extension.TauriStatus -eq 'blocked') 'DevServer conflated extension readiness with the independent Tauri target.'
    $astro = Get-SgEnvironmentReadinessForSurface -ProjectRoot $project -LaunchPath $site -Kind astro -EnvironmentState $state
    Assert-Sg ($astro.Status -eq 'ready' -and $astro.SurfaceScope -eq 'site') 'DevServer did not consume the site-scoped environment readiness.'

    $multiState = [pscustomobject]@{schema='shipglows.environment-state/v1';project=[pscustomobject]@{root=$project};observed=[pscustomobject]@{capabilities=@(
        [pscustomobject]@{kind='target';id='tauri';scope='apps/desktop-a';status='ready'},
        [pscustomobject]@{kind='target';id='tauri-windows';scope='apps/desktop-a';status='blocked'},
        [pscustomobject]@{kind='target';id='tauri-windows';scope='apps/desktop-b';status='ready'}
    )}}
    $ambiguous = Get-SgEnvironmentReadinessForSurface -ProjectRoot $project -LaunchPath $project -Kind browser-extension -EnvironmentState $multiState -RequireTauri
    Assert-Sg ($ambiguous.Status -eq 'blocked' -and $ambiguous.Reason -match 'explicit project scope') 'Multiple Tauri projects were silently reduced to the first candidate.'
    $chosen = Get-SgEnvironmentReadinessForSurface -ProjectRoot $project -LaunchPath $desktopA -Kind vite -EnvironmentState $multiState -RequireTauri -TauriScope 'apps/desktop-a'
    Assert-Sg ($chosen.Status -eq 'ready' -and $chosen.TauriScope -eq 'apps/desktop-a') 'Explicit project-scoped Tauri selection did not deduplicate the legacy alias safely.'

    $registryPath = Join-Path $runtime 'registry.json'
    [pscustomobject]@{schemaVersion=1;projects=@(
        [pscustomobject]@{name='communityglows';path=$project;rootPath=$project;launchPath=$project;kind='browser-extension';port=3006;status='stopped';pid=0},
        [pscustomobject]@{name='communityglows-site';path=$site;rootPath=$project;launchPath=$site;kind='astro';port=3000;status='stopped';pid=0}
    )} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $registryPath -Encoding UTF8
    $registry = Read-SgRegistry ([pscustomobject]@{RuntimeDirectory=$runtime;RegistryPath=$registryPath})
    $ports = @{}; foreach ($entry in $registry.projects) { $ports[[string]$entry.path]=[int]$entry.port }
    Assert-Sg ($ports[$project] -eq 3006 -and $ports[$site] -eq 3000) 'CommunityGlows durable root/site ports were not preserved independently.'

    Write-Host 'Windows environment activation and DevServer readiness: OK' -ForegroundColor Green
} finally {
    Remove-Module ShipGlows.MobileToolchain -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item Env:SHIPGLOWS_FIXTURE_BIN -ErrorAction SilentlyContinue
    Remove-Item Env:SHIPGLOWS_FIXTURE_WORKER -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
