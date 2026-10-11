$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$source = Join-Path $root 'cli\windows'
$managed = Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell\7.6.5\win-x64\pwsh.exe'
$temporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$fixture = Join-Path $temporaryRoot ('sg menu lifecycle & ' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($fixture)
$tokens = $null; $parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile((Join-Path $source 'shipglows-devserver.ps1'), [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw 'Cannot parse the menu backend.' }
$menu = $ast.Find({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-Menu' }, $true)
if (-not $menu) { throw 'Cannot isolate the real menu handoff.' }
Copy-Item -LiteralPath (Join-Path $source 'ShipGlows.MenuSession.ps1') -Destination $fixture
[IO.File]::WriteAllText((Join-Path $fixture 'shipglows-menu.txt'), "0  Quit ShipGlows`r`n")
$backend = @'
param([string]$MenuSessionRequestPath,[int]$MenuSessionParentId,[long]$MenuSessionParentStartTicks)
$ErrorActionPreference='Stop'
$InitialMenuSelection=''
function Start-SgBackgroundCatalogRefresh {}
function Start-SgBackgroundUpdateStatusRefresh {}
# Keep the published marker observable before exercising the real wait loop.
Start-Sleep -Milliseconds 150
'@ + "`r`n" + $menu.Extent.Text + "`r`nInvoke-Menu`r`n"
[IO.File]::WriteAllText((Join-Path $fixture 'shipglows-devserver.ps1'), $backend)
$frontends = @(); $workers = @(); $stems = @()
try {
    foreach ($scenario in @('native-quit','frontend-death')) {
        do {
            $stem = Join-Path $temporaryRoot ("shipglows-menu-$(Get-Random -Maximum 32768)-$(Get-Random -Maximum 32768)")
        } while ([IO.Directory]::GetFiles($temporaryRoot, ([IO.Path]::GetFileName($stem) + '.*')).Count)
        $stems += $stem
        $batch = @"
@echo off
set "SHIPGLOWS_MANAGED_PWSH=$managed"
start "" /b "$managed" -NoLogo -NoProfile -File "$fixture\ShipGlows.MenuSession.ps1" -RequestPath "$stem.request"
pause >nul
"@
        $launcher = Join-Path $fixture 'frontend.cmd'
        [IO.File]::WriteAllText($launcher, ($batch -replace '\r?\n', "`r`n"), [Text.Encoding]::ASCII)
        $info = [Diagnostics.ProcessStartInfo]::new()
        $info.FileName = Join-Path $env:SystemRoot 'System32\cmd.exe'
        $info.Arguments = '/d /c call "' + $launcher + '"'
        $info.UseShellExecute = $false
        $info.CreateNoWindow = $true
        $info.RedirectStandardInput = $true
        $info.RedirectStandardOutput = $true
        $info.RedirectStandardError = $true
        $frontend = [Diagnostics.Process]::Start($info)
        $frontends += $frontend
        $deadline = [DateTime]::UtcNow.AddSeconds(10)
        while (-not [IO.File]::Exists("$stem.worker")) {
            if ([DateTime]::UtcNow -ge $deadline) { throw "Worker marker missing: $scenario" }
            Start-Sleep -Milliseconds 10
        }
        $identity = [IO.File]::ReadAllText("$stem.worker")
        if ($identity -notmatch '^([0-9]+) ([0-9]+)$') { throw 'Worker marker was published partially.' }
        $workerId = [int]$Matches[1]; $workerTicks = [long]$Matches[2]
        $worker = Get-Process -Id $workerId -ErrorAction Stop
        if ($worker.StartTime.ToUniversalTime().Ticks -ne $workerTicks) { throw 'Worker identity mismatch.' }
        $workers += $worker
        if ($scenario -eq 'native-quit') {
            [IO.File]::WriteAllText("$stem.request", '0', [Text.Encoding]::ASCII)
        } else {
            # Kill only the dedicated frontend; the worker must terminate itself.
            $frontend.Kill()
            $frontend.WaitForExit()
        }
        if (-not $worker.WaitForExit(5000)) { throw "Session survived $scenario." }
        $remaining = @([IO.Directory]::GetFiles($temporaryRoot, ([IO.Path]::GetFileName($stem) + '.*')))
        if ($remaining.Count) { throw "Session left artifacts after ${scenario}: $($remaining -join ', ')" }
        if (-not $frontend.HasExited) { $frontend.StandardInput.WriteLine(''); $frontend.StandardInput.Close(); $frontend.WaitForExit() }
    }
    Write-Host 'Menu session lifecycle: native Quit and dedicated frontend death stop worker and remove channel artifacts.'
} finally {
    foreach ($worker in $workers) { if (-not $worker.HasExited) { $worker.Kill() }; $worker.Dispose() }
    foreach ($frontend in $frontends) { if (-not $frontend.HasExited) { $frontend.Kill() }; $frontend.Dispose() }
    foreach ($stem in $stems) {
        foreach ($suffix in @('request','request.new','worker','worker.new','done','done.new','accepted','selection','validated')) {
            $path = "$stem.$suffix"
            if ([IO.File]::Exists($path)) { [IO.File]::Delete($path) }
        }
    }
    $resolvedFixture = [IO.Path]::GetFullPath($fixture)
    if ([IO.Path]::GetDirectoryName($resolvedFixture) -ine $temporaryRoot -or [IO.Path]::GetFileName($resolvedFixture) -notmatch '^sg menu lifecycle & [a-f0-9]{32}$') { throw 'Unexpected fixture cleanup target.' }
    Remove-Item -LiteralPath $resolvedFixture -Recurse -Force
}
