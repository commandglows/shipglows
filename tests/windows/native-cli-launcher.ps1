param(
    [int]$MaximumMenuReadyMs = 1000
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$source = Join-Path $root 'cli\windows\ShipGlows.CliLauncher.cs'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw 'The native Windows CLI launcher source is missing.'
}

$compiler = @(
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'),
    (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe')
) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $compiler) { throw 'The Windows .NET Framework C# compiler is unavailable.' }

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-native-launcher-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    $launcher = Join-Path $fixture 's.exe'
    & $compiler /nologo /target:exe /optimize+ "/out:$launcher" $source
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
        throw 'The native Windows CLI launcher did not compile.'
    }

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $launcher
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    $watch = [Diagnostics.Stopwatch]::StartNew()
    if (-not $process.Start()) { throw 'The native Windows CLI launcher did not start.' }
    $firstLineTask = $process.StandardOutput.ReadLineAsync()
    if (-not $firstLineTask.Wait($MaximumMenuReadyMs)) {
        try { $process.Kill() } catch { }
        throw "The native menu did not render within $MaximumMenuReadyMs ms."
    }
    $watch.Stop()
    if ($firstLineTask.Result -ne 'ShipGlows Windows') {
        throw "Unexpected native menu header: $($firstLineTask.Result)"
    }

    $children = @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($process.Id)" -ErrorAction Stop)
    $forbiddenChildren = @($children | Where-Object { $_.Name -in @('cmd.exe','pwsh.exe','powershell.exe') })
    if ($forbiddenChildren.Count) {
        $childNames = ($forbiddenChildren.Name -join ', ')
        try { $process.Kill() } catch { }
        throw "The idle native menu spawned a shell before selection: $childNames"
    }

    $process.StandardInput.WriteLine('0')
    $process.StandardInput.Flush()
    if (-not $process.WaitForExit(3000)) {
        try { $process.Kill() } catch { }
        throw 'The native menu did not exit after the quit selection.'
    }
    if ($process.ExitCode -ne 0) { throw "The native menu exited with code $($process.ExitCode)." }

    $capturePath = Join-Path $fixture 'forwarded.json'
    $entrypoint = Join-Path $fixture 'shipglows-devserver.ps1'
    [IO.File]::WriteAllText($entrypoint, @'
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Remaining=@())
[pscustomobject]@{
    arguments=@($Remaining)
    managedMarker=[string]$env:SHIPGLOWS_MANAGED_PWSH
} | ConvertTo-Json -Compress | Set-Content -LiteralPath $env:SHIPGLOWS_NATIVE_CAPTURE -Encoding UTF8
exit 23
'@, [Text.UTF8Encoding]::new($false))
    $env:SHIPGLOWS_NATIVE_CAPTURE = $capturePath
    try {
        & $launcher 'status' '--literal=space value' 'quote"value' *> $null
        $forwardedExitCode = $LASTEXITCODE
    } finally {
        Remove-Item Env:SHIPGLOWS_NATIVE_CAPTURE -ErrorAction SilentlyContinue
    }
    if ($forwardedExitCode -ne 23) { throw "The native launcher did not preserve the child exit code: $forwardedExitCode" }
    $capture = Get-Content -LiteralPath $capturePath -Raw | ConvertFrom-Json
    if (@($capture.arguments).Count -ne 3 -or $capture.arguments[0] -ne 'status' -or $capture.arguments[1] -ne '--literal=space value' -or $capture.arguments[2] -ne 'quote"value') {
        throw 'The native launcher did not preserve command arguments.'
    }
    if ([string]::IsNullOrWhiteSpace([string]$capture.managedMarker) -or -not ([string]$capture.managedMarker).EndsWith('\pwsh.exe',[StringComparison]::OrdinalIgnoreCase)) {
        throw 'The native launcher did not bind the child to the managed PowerShell coordinate.'
    }

    Write-Host "Native Windows CLI launcher regression: OK menu_ready_ms=$([math]::Round($watch.Elapsed.TotalMilliseconds,1)) shells_before_selection=0 arguments=preserved exit_code=preserved"
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
