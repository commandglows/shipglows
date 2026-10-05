param([int]$MaximumQuitMedianMs = 500)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$source = Join-Path $root 'cli\windows'
$managed = Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell\7.6.5\win-x64\pwsh.exe'
$fzf = (Get-Command fzf.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$installer = [IO.File]::ReadAllText((Join-Path $source 'install-devserver.ps1'))
$wrapper = [regex]::Match($installer, "(?s)function Install-SgCommandWrappers\s*\{\s*\u0024wrapper = @'\r?\n(.*?)\r?\n'@")
if (-not $wrapper.Success) { throw 'Cannot isolate the installed DevServer wrapper.' }
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg menu & dispatch ' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($fixture)
$savedFzf = $env:FZF_DEFAULT_OPTS
$savedFzfFile = $env:FZF_DEFAULT_OPTS_FILE
$savedMarker = $env:SHIPGLOWS_MANAGED_PWSH
$savedPath = $env:PATH
$savedDispatch = $env:SG_MENU_TEST_DISPATCH
function Invoke-TestLauncher([string]$Arguments = '') {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = Join-Path $env:SystemRoot 'System32\cmd.exe'
    $info.Arguments = '/d /s /c ""' + $launcher + '" ' + $Arguments + '"'
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $launchWatch = [Diagnostics.Stopwatch]::StartNew()
    $process = [Diagnostics.Process]::Start($info)
    try {
        if (-not $process.WaitForExit(5000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw ('Fixture launcher timed out. Output: ' + $process.StandardOutput.ReadToEnd() + $process.StandardError.ReadToEnd())
        }
        $launchWatch.Stop()
        $script:launcherExitMs = $launchWatch.Elapsed.TotalMilliseconds
        $global:LASTEXITCODE = $process.ExitCode
        return $process.StandardOutput.ReadToEnd() + $process.StandardError.ReadToEnd()
    } finally { $process.Dispose() }
}
try {
    $env:FZF_DEFAULT_OPTS_FILE = ''
    $env:PATH = (Split-Path -Parent $fzf) + ';' + $env:PATH
    $launcher = Join-Path $fixture 's.cmd'
    $menuPath = Join-Path $fixture 'shipglows-menu.txt'
    $dispatch = Join-Path $fixture 'dispatch.json'
    $env:SG_MENU_TEST_DISPATCH = $dispatch
    [IO.File]::WriteAllText($launcher, ($wrapper.Groups[1].Value -replace '\r?\n', "`r`n"), [Text.Encoding]::ASCII)
    Copy-Item -LiteralPath (Join-Path $source 'shipglows-menu.cmd') -Destination $fixture
    Copy-Item -LiteralPath (Join-Path $source 'ShipGlows.MenuSession.ps1') -Destination $fixture
    $backend = @'
param([string]$Action='menu',[string]$InitialMenuSelection='',[string]$MenuSessionRequestPath='',[int]$MenuSessionParentId=0,[long]$MenuSessionParentStartTicks=0)
if ($MenuSessionRequestPath) {
    $parent = Get-Process -Id $MenuSessionParentId
    while (-not [IO.File]::Exists($MenuSessionRequestPath)) {
        if ($parent.HasExited) { return }
        Start-Sleep -Milliseconds 20
    }
    $InitialMenuSelection = [IO.File]::ReadAllText($MenuSessionRequestPath).Trim()
    if ($InitialMenuSelection -eq '0') { return }
    [IO.File]::WriteAllText($MenuSessionRequestPath.Replace('.request','.accepted'),'1')
}
[IO.File]::WriteAllText($env:SG_MENU_TEST_DISPATCH,(@{action=$Action;selection=$InitialMenuSelection;managed=$env:SHIPGLOWS_MANAGED_PWSH}|ConvertTo-Json))
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'shipglows-menu.txt'),"0  Quit ShipGlows`r`n")
'@
    [IO.File]::WriteAllText((Join-Path $fixture 'shipglows-devserver.ps1'), $backend)
    $items = @(Get-Content -LiteralPath (Join-Path $source 'shipglows-menu.txt'))
    if ($items.Count -ne 15) { throw 'The root menu lost an existing option.' }
    $times = @()
    foreach ($attempt in 1..5) {
        [IO.File]::WriteAllText($menuPath, ($items -join "`r`n"))
        $env:FZF_DEFAULT_OPTS = '--filter="Quit ShipGlows"'
        $watch = [Diagnostics.Stopwatch]::StartNew()
        $output = Invoke-TestLauncher
        $watch.Stop()
        if ($LASTEXITCODE -ne 0) { throw "Native Quit failed ($LASTEXITCODE): $output" }
        if (Test-Path -LiteralPath $dispatch) { throw ('Native Quit dispatched an action: ' + [IO.File]::ReadAllText($dispatch) + ' output=' + $output) }
        $times += $script:launcherExitMs
    }
    foreach ($key in @('1','2','3','4','5','6','7','8','9','n','a','r','t','u')) {
        [IO.File]::WriteAllText($menuPath, (($items | Where-Object { $_ -notmatch '^0 ' }) -join "`r`n"))
        $env:FZF_DEFAULT_OPTS = "--filter='^$key | ^0'"
        Invoke-TestLauncher | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Native selection $key failed." }
        $result = [IO.File]::ReadAllText($dispatch) | ConvertFrom-Json
        if ($result.selection -cne $key -or $result.managed -ine $managed) { throw "Selection $key lost its identity or managed-host boundary." }
    }
    $env:FZF_DEFAULT_OPTS = ''
    Invoke-TestLauncher h | Out-Null
    $result = [IO.File]::ReadAllText($dispatch) | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or $result.action -ne 'h' -or $result.selection -ne '') { throw 'Commands with arguments no longer bypass the native menu.' }
    $env:PATH = ''
    Invoke-TestLauncher | Out-Null
    $result = [IO.File]::ReadAllText($dispatch) | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0 -or $result.action -ne 'menu' -or $result.selection -ne '') { throw 'Missing fzf no longer falls back to PowerShell.' }
    $median = @($times | Sort-Object)[2]
    if ($median -ge $MaximumQuitMedianMs) { throw "Native Quit median $median ms exceeds $MaximumQuitMedianMs ms." }
    Write-Host ('Native root menu: 14 selections, Quit without dispatch, argument bypass, missing-fzf fallback; quit_median_ms={0:F1}' -f $median)
} finally {
    $env:FZF_DEFAULT_OPTS = $savedFzf
    $env:FZF_DEFAULT_OPTS_FILE = $savedFzfFile
    $env:SHIPGLOWS_MANAGED_PWSH = $savedMarker
    $env:PATH = $savedPath
    $env:SG_MENU_TEST_DISPATCH = $savedDispatch
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
