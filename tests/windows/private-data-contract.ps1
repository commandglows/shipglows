$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$sandbox = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-private-data-test-' + [guid]::NewGuid().ToString('N'))
$prior = @{}
foreach ($name in @('SHIPGLOWS_PRIVATE_DIR','SHIPGLOWS_PRIVATE_DATA_DIR','SHIPGLOWS_PRIVATE_DATA_REPO','SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE')) { $prior[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }

try {
    New-Item -ItemType Directory -Path $sandbox -Force | Out-Null
    $env:SHIPGLOWS_PRIVATE_DIR = Join-Path $sandbox '.shipglows'
    $env:SHIPGLOWS_PRIVATE_DATA_CONFIG_FILE = Join-Path $sandbox 'config\private-data.env'
    Remove-Item Env:SHIPGLOWS_PRIVATE_DATA_DIR -ErrorAction SilentlyContinue
    Remove-Item Env:SHIPGLOWS_PRIVATE_DATA_REPO -ErrorAction SilentlyContinue
    Import-Module $modulePath -Force -DisableNameChecking

    $default = Get-SgPrivateDataConfiguration
    Assert-Sg ($default.DataDirectory -eq [IO.Path]::GetFullPath((Join-Path $env:SHIPGLOWS_PRIVATE_DIR 'data'))) 'Default private data path must be %USERPROFILE%\\.shipglows\\data equivalent.'
    Assert-Sg (-not $default.Repository) 'No repository must be assumed before explicit setup.'

    Write-SgPrivateDataConfiguration 'https://github.com/example/private-data.git' $default.DataDirectory
    $saved = Get-SgPrivateDataConfiguration
    Assert-Sg ($saved.Repository -eq 'https://github.com/example/private-data.git') 'Saved repository must be read declaratively.'
    Assert-Sg (Test-SgOwnerOnlyPath $saved.ConfigPath) 'Private data config must be owner-only.'

    [IO.File]::WriteAllText($saved.ConfigPath, "UNSAFE=`$(Get-Date)`r`n", (New-Object Text.UTF8Encoding($false)))
    Protect-SgOwnerOnlyPath $saved.ConfigPath
    $rejected = $false
    try { [void](Get-SgPrivateDataConfiguration) } catch { $rejected = $_.Exception.Message -match 'declarative' }
    Assert-Sg $rejected 'Configuration must reject executable or unknown declarations without evaluating them.'

    Assert-Sg (Test-SgWindowsCompatibleRepositoryPaths @('projects/alpha/file.txt','mail-intake/queue.json')) 'Ordinary repository paths must be accepted.'
    Assert-Sg (-not (Test-SgWindowsCompatibleRepositoryPaths @('mail-source/a:b.eml'))) 'Colon paths must be rejected before clone.'
    Assert-Sg (-not (Test-SgWindowsCompatibleRepositoryPaths @('CON/file.txt'))) 'Reserved Windows names must be rejected before clone.'
    Assert-Sg (-not (Test-SgWindowsCompatibleRepositoryPaths @('folder/trailing.'))) 'Trailing dot paths must be rejected before clone.'

    $workspace = Join-Path $sandbox 'workspace'
    $privateProject = Join-Path $default.DataDirectory 'private-app'
    New-Item -ItemType Directory -Path (Join-Path $workspace 'public-app') -Force | Out-Null
    New-Item -ItemType Directory -Path $privateProject -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $privateProject 'package.json'), '{"scripts":{"dev":"vite"}}')
    $config = Get-SgDevConfig
    $config.Workspace = $workspace
    $config.RuntimeDirectory = Join-Path $sandbox 'runtime'
    $config.RegistryPath = Join-Path $config.RuntimeDirectory 'registry.json'
    $config.LockPath = Join-Path $config.RuntimeDirectory 'registry.lock'
    $config.ProjectIndexPath = Join-Path $config.RuntimeDirectory 'project-index.json'
    $catalog = @(Get-SgProjectCatalog $config -ForceRefresh -SkipProcessReconciliation)
    Assert-Sg (-not (@($catalog | ForEach-Object { $_.path }) -contains $privateProject)) 'Private data must never be scanned as a DevServer project.'

    Write-Output 'Windows private-data contract tests passed.'
} finally {
    foreach ($name in $prior.Keys) {
        if ($null -eq $prior[$name]) { Remove-Item "Env:$name" -ErrorAction SilentlyContinue }
        else { [Environment]::SetEnvironmentVariable($name, $prior[$name], 'Process') }
    }
    if (Test-Path -LiteralPath $sandbox) { Remove-Item -LiteralPath $sandbox -Recurse -Force }
}
