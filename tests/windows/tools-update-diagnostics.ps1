param([string]$WindowsRoot = (Join-Path $PSScriptRoot '..\..\cli\windows'))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
function Assert-Test($Condition,$Message) { if (-not $Condition) { throw $Message } }
Import-Module (Join-Path $WindowsRoot 'ShipGlows.InstallerEngine.psm1') -Force
Import-Module (Join-Path $WindowsRoot 'ShipGlows.InstallerConsole.psm1') -Force
$temp = Join-Path $env:TEMP ('sg-update-proof-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($temp)
try {
    $log = Join-Path $temp 'events.jsonl'
    $messages = [Collections.Generic.List[string]]::new()
    $writer = { param($Text,$NoNewline,$Color) $messages.Add($Text) }.GetNewClosure()
    $sink = New-SgInstallerConsoleEventSink -Interactive $false -Writer $writer -LogPath $log
    $operation = New-SgInstallerOperation -Id 'tool.update.git' -Label 'Updating Git'
    $null = Invoke-SgInstallerOperation -Operation $operation -EventSink $sink -SuccessExitCodes @(0,-1978335189) -Runner {
        param($progress)
        & $progress 1
        [pscustomobject]@{ExitCode=-1978335189;TimedOut=$false;Output='No applicable update'}
    }
    Assert-Test (-not (($messages -join '') -match '\[failed\]')) 'No applicable update must not display failure'
    $null = Invoke-SgInstallerOperation -Operation $operation -EventSink $sink -Runner {
        [pscustomobject]@{ExitCode=1;TimedOut=$false;Output='EBUSY resource busy or locked token=TEST_SECRET_DO_NOT_LOG'}
    }
    $text = [IO.File]::ReadAllText($log)
    Assert-Test ($text -match 'EBUSY' -and $text -notmatch 'TEST_SECRET_DO_NOT_LOG') 'Log must classify lock errors without persisting raw output'
    Assert-Test ($text -notmatch 'INSTALL_STEP_PROGRESS') 'Do not fill log with spinner ticks'
    Assert-Test (($messages -join '') -match 'Diagnostic log:') 'Failure must point to persistent log'
    $tokens=$null; $errors=$null
    $ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $WindowsRoot 'install-devserver.ps1'),[ref]$tokens,[ref]$errors)
    Assert-Test ($errors.Count -eq 0) 'Installer must parse'
    foreach($name in @('Set-SgLauncherContent','Install-SgCommandWrappers','Invoke-SgManagedWingetToolUpdate')) {
        $node=$ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name},$true)
        . ([scriptblock]::Create($node.Extent.Text))
    }
    function Get-SgToolPath { 'mock-winget' }
    function Test-SgTool { $true }
    function Test-SgToolRuns { $true }
    function Update-SgProcessPath {}
    function Invoke-SgVisibleBoundedProcess { [pscustomobject]@{ExitCode=$script:testExit;TimedOut=$false;Output=''} }
    $definition=[pscustomobject]@{Key='git';Name='Git';PackageId='Git.Git';Command='git.exe';Paths=@()}
    $script:testExit=-1978335189
    Assert-Test (Invoke-SgManagedWingetToolUpdate $definition) 'No-update result must succeed'
    $script:testExit=5; $failed=$false
    try { $null=Invoke-SgManagedWingetToolUpdate $definition } catch { $failed=$true }
    Assert-Test $failed 'Real WinGet failure must propagate'
    function Get-Command { $null }
    function Add-SgRuntimeToUserPath {}
    $runtimeDir=$temp
    Install-SgCommandWrappers
    $launcher=Join-Path $temp 's.cmd'
    $stamp=(Get-Item $launcher).LastWriteTimeUtc
    Install-SgCommandWrappers
    Assert-Test ((Get-Item $launcher).LastWriteTimeUtc -eq $stamp) 'Unchanged launcher must not be rewritten'
    # Simulate a child changing the running batch file, then returning an error.
    $child=@'
param([Parameter(ValueFromRemainingArguments=$true)]$Arguments)
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 's.cmd'),"@echo off`r`nSHOULD_NOT_EXECUTE`r`n")
Write-Output ($Arguments -join '|')
exit 17
'@
    [IO.File]::WriteAllText((Join-Path $temp 'shipglows-devserver.ps1'),$child)
    $output=& $launcher tools update 2>&1
    Assert-Test ($LASTEXITCODE -eq 17) "Launcher must preserve child failure after self rewrite; exit=$LASTEXITCODE output=$($output -join '|')"
    Assert-Test (($output -join '') -match 'tools\|update' -and ($output -join '') -notmatch 'SHOULD_NOT_EXECUTE') 'Launcher must forward arguments and not resume rewritten lines'
    Install-SgCommandWrappers
    Assert-Test ([IO.File]::ReadAllText($launcher) -notmatch 'SHOULD_NOT_EXECUTE') 'Changed existing launcher must be replaced successfully'
    Write-Host 'PASS persistent diagnostics, WinGet outcomes, launcher idempotence and self rewrite'
} finally {
    # Only this generated proof directory is removed.
    if ([IO.Path]::GetFullPath($temp).StartsWith([IO.Path]::GetFullPath($env:TEMP),[StringComparison]::OrdinalIgnoreCase)) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
