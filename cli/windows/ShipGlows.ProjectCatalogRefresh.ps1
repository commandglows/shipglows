$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$workspaceValue = [Environment]::GetEnvironmentVariable('SHIPGLOWS_CATALOG_WORKSPACE','Process')
$runtimeValue = [Environment]::GetEnvironmentVariable('SHIPGLOWS_CATALOG_RUNTIME','Process')
[Environment]::SetEnvironmentVariable('SHIPGLOWS_CATALOG_WORKSPACE',$null,'Process')
[Environment]::SetEnvironmentVariable('SHIPGLOWS_CATALOG_RUNTIME',$null,'Process')

if (-not $workspaceValue -or -not $runtimeValue) { exit 2 }
try {
    $workspace = [IO.Path]::GetFullPath($workspaceValue).TrimEnd('\','/')
    $runtime = [IO.Path]::GetFullPath($runtimeValue).TrimEnd('\','/')
} catch { exit 2 }
if (-not [IO.Directory]::Exists($workspace) -or -not [IO.Directory]::Exists($runtime)) { exit 2 }

$modulePath = Join-Path $PSScriptRoot 'ShipGlows.DevServer.psm1'
$refreshPath = Join-Path $runtime 'project-index.json.refreshing'
try {
    Import-Module $modulePath -Force -DisableNameChecking
    $config = [pscustomobject]@{
        Workspace = $workspace
        RuntimeDirectory = $runtime
        RegistryPath = Join-Path $runtime 'registry.json'
        LockPath = Join-Path $runtime 'registry.lock'
        ProjectIndexPath = Join-Path $runtime 'project-index.json'
        LogDirectory = Join-Path $runtime 'logs'
        PortStart = 3000
        PortEnd = 3100
    }
    Get-SgWorkspaceProjectCandidates $config -ForceRefresh | Out-Null
} finally {
    Remove-Item -LiteralPath $refreshPath -Force -ErrorAction SilentlyContinue
}
