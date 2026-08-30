$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ('sg-env-' + [Guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'project'
$state = Join-Path $fixture 'state'
New-Item -ItemType Directory -Path $project, $state -Force | Out-Null

try {
    $env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT = $state
    $environmentScript = Join-Path $root 'cli\environment\shipglows_environment.py'
    $python = (Get-Command python.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $json = & $python $environmentScript inspect --project $project
    if ($LASTEXITCODE -ne 0) { throw "environment inspect exited $LASTEXITCODE" }
    $value = ($json -join [Environment]::NewLine) | ConvertFrom-Json
    if ($value.command -ne 'inspect' -or $value.desired.management -ne 'unmanaged') {
        throw 'Windows environment inspect returned an unexpected contract.'
    }
    if (@(Get-ChildItem -LiteralPath $state -Force).Count -ne 0) {
        throw 'Windows environment inspect mutated the private state directory.'
    }

    & $python $environmentScript verify --project $project *> $null
    if ($LASTEXITCODE -ne 0) { throw "environment verify exited $LASTEXITCODE" }
    $statusJson = & $python $environmentScript status --project $project
    if ($LASTEXITCODE -ne 0) { throw "environment status exited $LASTEXITCODE" }
    $statusValue = ($statusJson -join [Environment]::NewLine) | ConvertFrom-Json
    if ($statusValue.state.schema -ne 'shipglows.environment-state/v1') {
        throw 'Windows environment status did not read the verified state.'
    }

    $planJson = & $python $environmentScript plan --project $project
    if ($LASTEXITCODE -ne 0) { throw "environment plan exited $LASTEXITCODE" }
    $approvedDigest = (($planJson -join [Environment]::NewLine) | ConvertFrom-Json).plan.digest
    [IO.File]::WriteAllText(
        (Join-Path $project 'shipglows.environment.json'),
        '{"schema":"shipglows.environment/v1","capabilities":{"tools":[{"id":"node","constraint":"24"}]}}',
        [Text.UTF8Encoding]::new($false)
    )
    $staleJson = & $python $environmentScript apply --project $project --plan-digest $approvedDigest
    if ($LASTEXITCODE -ne 3) { throw "stale environment apply should refuse with exit 3, got $LASTEXITCODE" }
    $staleValue = ($staleJson -join [Environment]::NewLine) | ConvertFrom-Json
    if ($staleValue.code -ne 'stale_plan') { throw 'Windows environment apply did not preserve the stale-plan refusal.' }

    & $python $environmentScript apply --project $project *> $null
    if ($LASTEXITCODE -ne 3) { throw "environment apply should refuse with exit 3, got $LASTEXITCODE" }
} finally {
    Remove-Item Env:SHIPGLOWS_ENVIRONMENT_STATE_ROOT -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'ShipGlows Windows environment control-plane source observation: OK (installed s env adapter requires post-install live proof)'
