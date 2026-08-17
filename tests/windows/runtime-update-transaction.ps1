$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$bootstrap = Join-Path $root 'install-shipglows.ps1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-runtime-update-' + [guid]::NewGuid().ToString('N'))

function Get-BootstrapFunctionSources([string]$Path, [string[]]$Names) {
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw 'Bootstrap parsing failed.' }
    foreach ($name in $Names) {
        $node = $ast.Find({ param($candidate) $candidate -is [Management.Automation.Language.FunctionDefinitionAst] -and $candidate.Name -eq $name }, $true)
        if (-not $node) { throw "Bootstrap function is missing: $name" }
        $node.Extent.Text
    }
}

function Get-TreeDigest([string]$Path) {
    $rows = foreach ($directory in @(Get-ChildItem -LiteralPath $Path -Recurse -Force -Directory | Sort-Object FullName)) {
        $relative = $directory.FullName.Substring($Path.TrimEnd('\').Length + 1).Replace('\','/')
        "directory|$relative"
    }
    $rows += foreach ($file in @(Get-ChildItem -LiteralPath $Path -Recurse -Force -File | Sort-Object FullName)) {
        $relative = $file.FullName.Substring($Path.TrimEnd('\').Length + 1).Replace('\','/')
        "file|$relative|$((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash)"
    }
    return ($rows -join "`n")
}

try {
    foreach ($source in @(Get-BootstrapFunctionSources $bootstrap @('Test-SgManagedRelativePath','Get-SgRuntimeUpdateOperation','Invoke-SgRuntimePayloadTransaction'))) { Invoke-Expression $source }
    $runtime = Join-Path $fixture 'runtime'
    $payload = Join-Path $fixture 'payload'
    New-Item -ItemType Directory -Path (Join-Path $runtime 'cli\windows'),(Join-Path $runtime 'cli\environment'),(Join-Path $payload 'cli\windows'),(Join-Path $payload 'cli\environment') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $runtime 'cli\windows\current.ps1'),'old')
    [IO.File]::WriteAllText((Join-Path $runtime 'cli\windows\stale.ps1'),'stale')
    [IO.File]::WriteAllText((Join-Path $runtime '.shipglows-runtime-files.json'),'["cli/windows/current.ps1","cli/windows/stale.ps1"]')
    [IO.File]::WriteAllText((Join-Path $payload 'cli\windows\current.ps1'),'new')
    [IO.File]::WriteAllText((Join-Path $payload 'cli\environment\new.py'),'new')
    $managed = @('cli/windows/current.ps1','cli/environment/new.py')
    if ((Get-SgRuntimeUpdateOperation -RuntimeRoot (Join-Path $fixture 'absent') -PayloadRoot $payload -ManagedRelativePaths $managed -SourceCommit ('a' * 40)) -ne 'install') { throw 'Absent runtime must classify as install.' }
    if ((Get-SgRuntimeUpdateOperation -RuntimeRoot $runtime -PayloadRoot $payload -ManagedRelativePaths $managed -SourceCommit ('a' * 40)) -ne 'repair') { throw 'Legacy runtime without install state must classify as repair.' }

    Invoke-SgRuntimePayloadTransaction -PayloadRoot $payload -RuntimeRoot $runtime -ManagedRelativePaths $managed -Action { }
    if ([IO.File]::ReadAllText((Join-Path $runtime 'cli\windows\current.ps1')) -cne 'new') { throw 'Upgrade did not activate the new payload.' }
    if (Test-Path -LiteralPath (Join-Path $runtime 'cli\windows\stale.ps1')) { throw 'Upgrade retained a stale managed file.' }
    if (-not (Test-Path -LiteralPath (Join-Path $runtime 'cli\environment\new.py'))) { throw 'Upgrade omitted a new managed file.' }
    [IO.File]::WriteAllText((Join-Path $runtime '.shipglows-install.json'),('{"sourceCommit":"' + ('b' * 40) + '"}'))
    if ((Get-SgRuntimeUpdateOperation -RuntimeRoot $runtime -PayloadRoot $payload -ManagedRelativePaths $managed -SourceCommit ('a' * 40)) -ne 'update') { throw 'Different source commit must classify as update.' }
    [IO.File]::WriteAllText((Join-Path $runtime '.shipglows-install.json'),('{"sourceCommit":"' + ('a' * 40) + '"}'))
    if ((Get-SgRuntimeUpdateOperation -RuntimeRoot $runtime -PayloadRoot $payload -ManagedRelativePaths $managed -SourceCommit ('a' * 40)) -ne 'no-op') { throw 'Matching source and payload must classify as no-op.' }
    $firstDigest = Get-TreeDigest $runtime
    Invoke-SgRuntimePayloadTransaction -PayloadRoot $payload -RuntimeRoot $runtime -ManagedRelativePaths $managed -Action { }
    if ((Get-TreeDigest $runtime) -cne $firstDigest) { throw 'Second upgrade pass is not byte-idempotent.' }

    [IO.File]::WriteAllText((Join-Path $runtime 'unrelated.txt'),'preserve')
    $beforeFailure = Get-TreeDigest $runtime
    [IO.File]::WriteAllText((Join-Path $payload 'cli\windows\current.ps1'),'broken-new')
    New-Item -ItemType Directory -Path (Join-Path $payload 'cli\new\deep') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $payload 'cli\new\deep\failure.txt'),'must-roll-back')
    $failureManaged = @($managed) + @('cli/new/deep/failure.txt')
    $failed = $false
    try { Invoke-SgRuntimePayloadTransaction -PayloadRoot $payload -RuntimeRoot $runtime -ManagedRelativePaths $failureManaged -Action { throw 'injected failure' } }
    catch { $failed = $_.Exception.Message -match 'injected failure' }
    if (-not $failed) { throw 'Injected update failure was not propagated.' }
    if ((Get-TreeDigest $runtime) -cne $beforeFailure) { throw 'Failed update did not restore the runtime byte-for-byte.' }

    $localPayload = Join-Path $fixture 'local-payload'
    New-Item -ItemType Directory -Path (Join-Path $localPayload 'local') -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $localPayload 'local\install_local.ps1'),'local')
    Invoke-SgRuntimePayloadTransaction -PayloadRoot $localPayload -RuntimeRoot $runtime -ManagedRelativePaths @('local/install_local.ps1') -ManagedManifestName '.shipglows-runtime-files.local.json' -Action { }
    if (-not (Test-Path -LiteralPath (Join-Path $runtime 'cli\windows\current.ps1'))) { throw 'Local-mode update removed full-mode managed files.' }
    Invoke-SgRuntimePayloadTransaction -PayloadRoot $payload -RuntimeRoot $runtime -ManagedRelativePaths $managed -ManagedManifestName '.shipglows-runtime-files.full.json' -Action { }
    if (-not (Test-Path -LiteralPath (Join-Path $runtime 'local\install_local.ps1'))) { throw 'Full-mode update removed local-mode managed files.' }

    $lockPath = Join-Path (Split-Path -Parent $runtime) '.shipglows-runtime-update.lock'
    $lock = [IO.File]::Open($lockPath,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    try {
        $locked = $false
        try { Invoke-SgRuntimePayloadTransaction -PayloadRoot $payload -RuntimeRoot $runtime -ManagedRelativePaths $managed -Action { } }
        catch { $locked = $_.Exception.Message -match 'already in progress' }
        if (-not $locked) { throw 'Concurrent runtime update was not rejected.' }
    } finally {
        $lock.Dispose()
        Remove-Item -LiteralPath $lockPath -Force
    }

    foreach ($unsafe in @('..\outside','C:\outside','cli/../outside','')) {
        if (Test-SgManagedRelativePath $unsafe) { throw "Unsafe managed path was accepted: $unsafe" }
    }
    Write-Host 'Windows runtime update transaction: OK' -ForegroundColor Green
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
