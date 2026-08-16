$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ('sg-env-' + [Guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'project'
$state = Join-Path $fixture 'state'
New-Item -ItemType Directory -Path $project, $state -Force | Out-Null

try {
    $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT = $state
    $entrypoint = Join-Path $root 'cli\windows\shipglows-devserver.ps1'
    $json = & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entrypoint env inspect -ProjectPath $project
    if ($LASTEXITCODE -ne 0) { throw "environment inspect exited $LASTEXITCODE" }
    $value = ($json -join [Environment]::NewLine) | ConvertFrom-Json
    if ($value.command -ne 'inspect' -or $value.desired.management -ne 'unmanaged') {
        throw 'Windows environment inspect returned an unexpected contract.'
    }
    if (@(Get-ChildItem -LiteralPath $state -Force).Count -ne 0) {
        throw 'Windows environment inspect mutated the private state directory.'
    }

    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entrypoint env verify -ProjectPath $project *> $null
    if ($LASTEXITCODE -ne 0) { throw "environment verify exited $LASTEXITCODE" }
    $statusJson = & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entrypoint env status -ProjectPath $project
    if ($LASTEXITCODE -ne 0) { throw "environment status exited $LASTEXITCODE" }
    $statusValue = ($statusJson -join [Environment]::NewLine) | ConvertFrom-Json
    if ($statusValue.state.schema -ne 'shipglows.environment-state/v1') {
        throw 'Windows environment status did not read the verified state.'
    }

    $planJson = & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entrypoint env plan -ProjectPath $project
    if ($LASTEXITCODE -ne 0) { throw "environment plan exited $LASTEXITCODE" }
    $approvedDigest = (($planJson -join [Environment]::NewLine) | ConvertFrom-Json).plan.digest
    [IO.File]::WriteAllText(
        (Join-Path $project 'shipglows.environment.json'),
        '{"schema":"shipglows.environment/v1","capabilities":{"tools":[{"id":"node","constraint":"24"}]}}',
        [Text.UTF8Encoding]::new($false)
    )
    $staleJson = & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entrypoint env apply -ProjectPath $project -PlanDigest $approvedDigest
    if ($LASTEXITCODE -ne 3) { throw "stale environment apply should refuse with exit 3, got $LASTEXITCODE" }
    $staleValue = ($staleJson -join [Environment]::NewLine) | ConvertFrom-Json
    if ($staleValue.code -ne 'stale_plan') { throw 'Windows environment apply did not preserve the stale-plan refusal.' }

    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $entrypoint env apply -ProjectPath $project *> $null
    if ($LASTEXITCODE -ne 3) { throw "environment apply should refuse with exit 3, got $LASTEXITCODE" }
} finally {
    Remove-Item Env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'ShipGlows Windows environment observation: OK'
