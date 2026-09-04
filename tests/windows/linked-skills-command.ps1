$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$source = Join-Path $repoRoot 'cli\windows\shipglows.ps1'
$tokens = $null; $errors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($source,[ref]$tokens,[ref]$errors)
Assert-Sg (-not $errors.Count) 'Launcher must parse.'
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixture = Join-Path $tempRoot ('sg-linked-command-' + [guid]::NewGuid().ToString('N'))
$originalHome = $env:USERPROFILE
try {
    [void][IO.Directory]::CreateDirectory((Join-Path $fixture '.shipglows'))
    Copy-Item -LiteralPath $source -Destination (Join-Path $fixture 'shipglows.ps1')
    [IO.File]::WriteAllText((Join-Path $fixture 'shipglows-devserver.ps1'), 'throw "Runtime updater must never run for skills"')
    $env:USERPROFILE = $fixture
    $statePath = Join-Path $fixture '.shipglows\development-channel.json'
    @{schemaVersion=1;channel='linked';root=$repoRoot} | ConvertTo-Json | Set-Content -LiteralPath $statePath
    $shellPath = (Get-Process -Id $PID).Path
    $launcher = Join-Path $fixture 'shipglows.ps1'
    $before = @(& $shellPath -NoProfile -File $launcher skills status 2>&1)
    Assert-Sg ($LASTEXITCODE -ne 0) 'Missing links must be reported, not installed by status.'
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $fixture '.agents\skills\shipglows'))) 'Status must not repair links.'
    $repair = @(& $shellPath -NoProfile -File $launcher update skills 2>&1)
    Assert-Sg ($LASTEXITCODE -eq 0) "Targeted repair must succeed without runtime updater: $repair"
    $after = @(& $shellPath -NoProfile -File $launcher skills status 2>&1)
    Assert-Sg ($LASTEXITCODE -eq 0) "Repaired catalogs must pass status: $after"
    Assert-Sg (($after -join ' ') -match 'blocked=0') 'No blocked link may be hidden.'
    Assert-Sg (($after -join ' ') -match 'Existing agent context is not reloaded') 'Do not promise agent reload.'
    $router = Join-Path $fixture '.agents\skills\shipglows'
    [IO.Directory]::Delete($router)
    [void][IO.Directory]::CreateDirectory($router)
    [IO.File]::WriteAllText((Join-Path $router 'keep.txt'),'user-owned')
    $collision = @(& $shellPath -NoProfile -File $launcher update skills 2>&1)
    Assert-Sg ($LASTEXITCODE -ne 0) 'A foreign local directory must block repair.'
    Assert-Sg ([IO.File]::ReadAllText((Join-Path $router 'keep.txt')) -eq 'user-owned') 'Collision data must survive.'
    @{schemaVersion=1;channel='linked';root='C:relative'} | ConvertTo-Json | Set-Content -LiteralPath $statePath
    $invalid = @(& $shellPath -NoProfile -File $launcher update skills 2>&1)
    Assert-Sg ($LASTEXITCODE -ne 0) 'Drive-relative root must fail closed.'
    Write-Output 'PASS: linked status, targeted repair, collision, invalid root, no runtime update.'
} finally {
    $env:USERPROFILE = $originalHome
    $resolved = [IO.Path]::GetFullPath($fixture)
    if (-not $resolved.StartsWith($tempRoot,[StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path -Leaf $resolved) -notlike 'sg-linked-command-*') { throw 'Unsafe fixture cleanup path.' }
    # Remove junction entries without traversing their repository targets.
    foreach ($hostName in @('.agents','.claude')) {
        $links = Join-Path $resolved "$hostName\skills"
        if (Test-Path -LiteralPath $links) {
            foreach ($entry in @(Get-ChildItem -LiteralPath $links -Force)) {
                if ($entry.LinkType) { [IO.Directory]::Delete($entry.FullName) }
            }
        }
    }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
