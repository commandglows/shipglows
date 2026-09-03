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

$sourceText = Get-Content -LiteralPath $source -Raw
if ($sourceText -notmatch 'Console\.ReadKey\(true\)') { throw 'The native root menu no longer reads immediate key presses.' }
if ($sourceText -notmatch 'case ConsoleKey\.UpArrow:' -or $sourceText -notmatch 'case ConsoleKey\.DownArrow:' -or $sourceText -notmatch 'case ConsoleKey\.Enter:') {
    throw 'The native root menu no longer owns arrow and Enter navigation.'
}
if ($sourceText -match 'SHIPGLOWS_NO_GUM_MENU') { throw 'The native launcher must not disable nested Gum pickers.' }
$expectedShortcuts = @{
    c = "{ 'c', new[] { `"clone`" } }"; g = "{ 'g', new[] { `"register`" } }";
    s = "{ 's', new[] { `"e`" } }"; t = "{ 't', new[] { `"m`", `"t`" } }";
    r = "{ 'r', new[] { `"m`", `"r`" } }"; l = "{ 'l', new[] { `"m`", `"l`" } }";
    o = "{ 'o', new[] { `"open`" } }"; k = "{ 'k', new[] { `"m`", `"o`" } }";
    d = "{ 'd', new[] { `"m`", `"w`" } }"; n = "{ 'n', new[] { `"m`", `"n`" } }";
    a = "{ 'a', new[] { `"a`" } }"; f = "{ 'f', new[] { `"refresh`" } }";
    i = "{ 'i', new[] { `"skills`", `"update`" } }";
    p = "{ 'p', new[] { `"tools`", `"update`" } }"; u = "{ 'u', new[] { `"u`" } }"
}
foreach ($shortcut in $expectedShortcuts.GetEnumerator()) {
    if (-not $sourceText.Contains([string]$shortcut.Value)) {
        throw "The native root menu letter '$($shortcut.Key)' no longer has its expected action mapping."
    }
}
if ($sourceText -match '"[0-9]  [^\"]+"') { throw 'The native root menu must display letter shortcuts instead of numbers.' }
if ($sourceText -notmatch "key\.Key == ConsoleKey\.Escape \? 'q'" -or $sourceText -notmatch "case ConsoleKey\.Escape:\s*MoveBelowMenu\(menuTop\);\s*return 'q';") {
    throw 'Escape must quit the native root menu through the Q action.'
}
if ($sourceText -notmatch 'ClearRootMenuForAction\(\);\s*int exitCode = RunPowerShell\(action\);') {
    throw 'The native root menu must clear immediately before a child action so its diagnostics remain visible.'
}

function Invoke-NativeMenuShortcut {
    param([string]$Launcher,[string]$CapturePath,[string]$Shortcut)
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $Launcher
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    $startInfo.EnvironmentVariables['SHIPGLOWS_NATIVE_CAPTURE'] = $CapturePath
    $startInfo.EnvironmentVariables.Remove('SHIPGLOWS_NO_GUM_MENU')
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    if (-not $process.Start()) { throw "The native $Shortcut hotkey regression process did not start." }
    $process.StandardInput.WriteLine($Shortcut)
    $process.StandardInput.WriteLine('q')
    $process.StandardInput.Flush()
    if (-not $process.WaitForExit(5000)) {
        try { $process.Kill() } catch { }
        throw "The native menu did not dispatch the $Shortcut shortcut."
    }
    if ($process.ExitCode -ne 0) { throw "The native $Shortcut hotkey regression exited with code $($process.ExitCode)." }
    return Get-Content -LiteralPath $CapturePath -Raw | ConvertFrom-Json
}

function Invoke-NativeSelfUpdate {
    param([string]$Launcher,[string[]]$Arguments)
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $Launcher
    $startInfo.Arguments = ($Arguments | ForEach-Object { '"' + $_.Replace('"','\"') + '"' }) -join ' '
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    if (-not $process.Start()) { throw 'The native self-update regression process did not start.' }
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    if (-not $process.WaitForExit(3000)) {
        try { $process.Kill() } catch { }
        throw 'The native self-update regression process did not exit promptly.'
    }
    return [pscustomobject]@{ ExitCode=$process.ExitCode; Stdout=$stdout; Stderr=$stderr }
}

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

    $process.StandardInput.WriteLine('q')
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
    pickerDisabled=[string]$env:SHIPGLOWS_NO_GUM_MENU
} | ConvertTo-Json -Compress | Set-Content -LiteralPath $env:SHIPGLOWS_NATIVE_CAPTURE -Encoding UTF8
if (@($Remaining).Count -eq 1 -and $Remaining[0] -in @('e','u')) { exit 0 }
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
        throw "The native launcher did not preserve command arguments: $($capture.arguments | ConvertTo-Json -Compress)"
    }
    if ([string]::IsNullOrWhiteSpace([string]$capture.managedMarker) -or -not ([string]$capture.managedMarker).EndsWith('\pwsh.exe',[StringComparison]::OrdinalIgnoreCase)) {
        throw 'The native launcher did not bind the child to the managed PowerShell coordinate.'
    }

    $startCapture = Invoke-NativeMenuShortcut -Launcher $launcher -CapturePath $capturePath -Shortcut 'S'
    if (@($startCapture.arguments).Count -ne 1 -or $startCapture.arguments[0] -ne 'e') {
        throw 'The native S shortcut did not dispatch the Start action.'
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$startCapture.pickerDisabled)) {
        throw 'The native shortcut disabled the nested Gum project picker.'
    }
    foreach ($updateArguments in @(@('update'), @('u'))) {
        Remove-Item -LiteralPath $capturePath -Force -ErrorAction SilentlyContinue
        $updateResult = Invoke-NativeSelfUpdate -Launcher $launcher -Arguments $updateArguments
        if ($updateResult.ExitCode -ne 2) {
            throw "The native self-update guard returned $($updateResult.ExitCode) instead of 2 for '$($updateArguments -join ' ')'."
        }
        if ($updateResult.Stderr -notmatch "Run 'shipglows runtime update' in PowerShell instead") {
            throw 'The native self-update guard did not provide the safe replacement command.'
        }
        if (Test-Path -LiteralPath $capturePath) {
            throw 'The native self-update guard launched the PowerShell update path instead of stopping immediately.'
        }
    }

    Write-Host "Native Windows CLI launcher regression: OK menu_ready_ms=$([math]::Round($watch.Elapsed.TotalMilliseconds,1)) shells_before_selection=0 letter_map=complete hotkey_S=dispatched native_self_update=blocked pre_action_clear=guarded child_output=preserved nested_gum=enabled arrows_enter=owned arguments=preserved exit_code=preserved"
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
