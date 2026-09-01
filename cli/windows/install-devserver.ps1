[CmdletBinding()]
param(
    [string]$ShipglowsDir = (Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'runtime'),
    [string]$Workspace = (Join-Path $env:USERPROFILE 'ShipGlows'),
    [switch]$SkipProfile,
    [switch]$ReplaceAgentConfigs,
    [switch]$UpdateDeveloperTools
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ($PSVersionTable.PSEdition -ne 'Core') {
    $runtimeModule = Join-Path $PSScriptRoot 'ShipGlows.PowerShellRuntime.psm1'
    if (-not (Test-Path -LiteralPath $runtimeModule -PathType Leaf)) { throw 'Managed PowerShell bootstrap module is missing from the Windows installer payload.' }
    Import-Module $runtimeModule -Force -DisableNameChecking
    $managedPowerShell = Resolve-SgManagedPowerShell
    $env:SHIPGLOWS_MANAGED_PWSH = [IO.Path]::GetFullPath($managedPowerShell)
    $reentryArguments = @('-NoLogo','-NoProfile','-File',$PSCommandPath,'-ShipglowsDir',$ShipglowsDir,'-Workspace',$Workspace)
    if ($SkipProfile) { $reentryArguments += '-SkipProfile' }
    if ($ReplaceAgentConfigs) { $reentryArguments += '-ReplaceAgentConfigs' }
    if ($UpdateDeveloperTools) { $reentryArguments += '-UpdateDeveloperTools' }
    & $managedPowerShell @reentryArguments
    exit $LASTEXITCODE
}
if (-not $env:SHIPGLOWS_MANAGED_PWSH -or [IO.Path]::GetFullPath($env:SHIPGLOWS_MANAGED_PWSH) -ine [IO.Path]::GetFullPath((Get-Process -Id $PID).Path)) {
    throw 'The Windows installer refused an unmanaged PowerShell Core host.'
}

$sourceDir = Join-Path $ShipglowsDir 'cli\windows'
$runtimeDir = Join-Path $ShipglowsDir 'bin'
$environmentCli = Join-Path $ShipglowsDir 'cli\environment\shipglows_environment.py'
$environmentSchema = Join-Path $ShipglowsDir 'cli\environment\schemas\shipglows-environment-v1.schema.json'
$environmentProvider = Join-Path $sourceDir 'shipglows-environment-provider.ps1'
if (-not (Test-Path -LiteralPath $environmentCli -PathType Leaf)) { throw "Missing environment control-plane command: $environmentCli" }
if (-not (Test-Path -LiteralPath $environmentSchema -PathType Leaf)) { throw "Missing environment control-plane schema: $environmentSchema" }
if (-not (Test-Path -LiteralPath $environmentProvider -PathType Leaf)) { throw "Missing Windows environment provider: $environmentProvider" }
try { [void]([IO.File]::ReadAllText($environmentSchema) | ConvertFrom-Json) }
catch { throw "Invalid environment control-plane schema: $environmentSchema" }
$codexMcpModule = Join-Path $sourceDir 'ShipGlows.CodexMcp.psm1'
if (-not (Test-Path -LiteralPath $codexMcpModule -PathType Leaf)) { throw "Missing Windows Codex MCP helper: $codexMcpModule" }
Import-Module $codexMcpModule -Force -DisableNameChecking
$mobileModule = Join-Path $sourceDir 'ShipGlows.MobileToolchain.psm1'
if (-not (Test-Path -LiteralPath $mobileModule -PathType Leaf)) { throw "Missing Windows mobile toolchain helper: $mobileModule" }
Import-Module $mobileModule -Force -DisableNameChecking
$installerEngineModule = Join-Path $sourceDir 'ShipGlows.InstallerEngine.psm1'
if (-not (Test-Path -LiteralPath $installerEngineModule -PathType Leaf)) { throw "Missing Windows installer engine: $installerEngineModule" }
Import-Module $installerEngineModule -Force -DisableNameChecking
$installerConsoleModule = Join-Path $sourceDir 'ShipGlows.InstallerConsole.psm1'
if (-not (Test-Path -LiteralPath $installerConsoleModule -PathType Leaf)) { throw "Missing Windows installer console adapter: $installerConsoleModule" }
Import-Module $installerConsoleModule -Force -DisableNameChecking
$wslTursoModule = Join-Path $sourceDir 'ShipGlows.WslTurso.psm1'
if (-not (Test-Path -LiteralPath $wslTursoModule -PathType Leaf)) { throw "Missing Windows WSL and Turso helper: $wslTursoModule" }
Import-Module $wslTursoModule -Force -DisableNameChecking
$tursoCloudInstaller = Join-Path $ShipglowsDir 'cli\install-turso-cloud.sh'
if (-not (Test-Path -LiteralPath $tursoCloudInstaller -PathType Leaf)) { throw "Missing bundled Turso Cloud installer: $tursoCloudInstaller" }
$installerEventSink = New-SgInstallerConsoleEventSink
$script:activeInstallerPhase = $null

function Invoke-SgVisibleBoundedProcess {
    param(
        [Parameter(Mandatory=$true)][string]$OperationId,
        [Parameter(Mandatory=$true)][string]$Label,
        [Parameter(Mandatory=$true)][string]$File,
        [string[]]$Arguments = @(),
        [int]$TimeoutSeconds = 60,
        [string]$InputText = ''
    )
    $operation = New-SgInstallerOperation -Id $OperationId -Label $Label -TimeoutSeconds $TimeoutSeconds
    return Invoke-SgInstallerOperation -Operation $operation -EventSink $installerEventSink -Runner {
        param($progress)
        Invoke-SgBoundedProcess -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds -InputText $InputText -ProgressCallback $progress
    }
}

function Read-SgVisibleInstallerChoice {
    param([bool]$Interactive,[string]$Prompt,[string]$OperationId='installer.input',[string]$Label='Waiting for your answer')
    if (-not $Interactive) { return '' }
    $operation = New-SgInstallerOperation -Id $OperationId -Label $Label -TimeoutSeconds 7200
    return Invoke-SgInstallerInput -Operation $operation -EventSink $installerEventSink -Phase $script:activeInstallerPhase -Reader {
        Read-SgInstallerChoice -Interactive $true -Prompt $Prompt
    }
}

function Read-SgVisibleInstallerConsent {
    param([bool]$Interactive,[string[]]$Missing,[string[]]$Outdated,[string]$Subject,[string]$Guidance,[string]$Prompt,[string]$OperationId,[string]$Label)
    if (-not $Interactive -or (-not $Missing.Count -and -not $Outdated.Count)) { return '' }
    $operation = New-SgInstallerOperation -Id $OperationId -Label $Label -TimeoutSeconds 7200
    return Invoke-SgInstallerInput -Operation $operation -EventSink $installerEventSink -Phase $script:activeInstallerPhase -Reader {
        Read-SgInstallerConsent -Interactive $true -Missing $Missing -Outdated $Outdated -Subject $Subject -Guidance $Guidance -Prompt $Prompt
    }
}
$authModule = Join-Path $sourceDir 'ShipGlows.Auth.psm1'
if (-not (Test-Path -LiteralPath $authModule -PathType Leaf)) { throw "Missing Windows authentication helper: $authModule" }
Import-Module $authModule -Force -DisableNameChecking
$agentInstructionsModule = Join-Path $sourceDir 'ShipGlows.AgentInstructions.psm1'
if (-not (Test-Path -LiteralPath $agentInstructionsModule -PathType Leaf)) { throw "Missing Windows agent instructions helper: $agentInstructionsModule" }
Import-Module $agentInstructionsModule -Force -DisableNameChecking
$gumVersion = '0.17.0'
$gumSha256 = 'B2BE80531C6BABC8D4E0E6CA95773D58118A2E1582AE006AACE08DBC55503072'
New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
New-Item -ItemType Directory -Path $Workspace -Force | Out-Null
$defaultHiddenParent = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.shipglows')).TrimEnd('\')
$defaultRuntimeRoot = [IO.Path]::GetFullPath((Join-Path $defaultHiddenParent 'runtime')).TrimEnd('\')
if ([IO.Path]::GetFullPath($ShipglowsDir).TrimEnd('\') -eq $defaultRuntimeRoot) {
    $hiddenParentItem = Get-Item -LiteralPath $defaultHiddenParent -Force
    $hiddenParentItem.Attributes = $hiddenParentItem.Attributes -bor [IO.FileAttributes]::Hidden
}

function Write-SgInstallerWarning([string]$Message) {
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

function Get-SgInstallerDiagnosticExcerpt {
    param([string[]]$Output,[int]$MaxLines=3,[int]$MaxCharacters=480)
    $lines = @($Output | ForEach-Object { $_ -split '\r?\n' } | ForEach-Object {
        $plain = [regex]::Replace([string]$_, "`e\[[0-9;?]*[ -/]*[@-~]", '')
        ([regex]::Replace($plain.Trim(), '\s+', ' '))
    } | Where-Object { $_ })
    if (-not $lines.Count) { return '' }
    $signals = @($lines | Where-Object { $_ -match '(?i)^\s*\[(?:!|X)\]|\berror\b|\bfailed\b|\bnot found\b|\bno devices detected\b|\blicenses? not accepted\b' })
    $selected = if ($signals.Count) { $signals } else { $lines }
    $excerpt = (@($selected | Select-Object -First ([Math]::Max(1,$MaxLines))) -join ' | ')
    if ($excerpt.Length -gt $MaxCharacters) { return $excerpt.Substring(0,[Math]::Max(1,$MaxCharacters - 1)) + '…' }
    return $excerpt
}

$launcher = Join-Path $runtimeDir 'shipglows-devserver.ps1'
foreach ($launcherModule in @('ShipGlows.DevServer.psm1','ShipGlows.RuntimeStatus.psm1','ShipGlows.FlutterSupervisor.ps1','ShipGlows.ProjectCatalogRefresh.ps1','ShipGlows.Auth.psm1','ShipGlows.MobileToolchain.psm1','ShipGlows.BuildArtifacts.psm1','shipglows-build-artifacts.ps1','ShipGlows.McpCatalog.json','ShipGlows.PowerShellRuntime.psm1','ShipGlows.PowerShellRuntime.json','ShipGlows.PowerShellBootstrap.ps1','shipglows.ps1')) {
    Copy-Item -LiteralPath (Join-Path $sourceDir $launcherModule) -Destination $runtimeDir -Force
}
Copy-Item -LiteralPath (Join-Path $sourceDir 'shipglows-devserver.ps1') -Destination $launcher -Force
$privateDataSource = Join-Path (Split-Path -Parent $sourceDir) 'private_data.py'
$privateDataDestination = Join-Path $ShipglowsDir 'private_data.py'
if (-not (Test-Path -LiteralPath $privateDataSource -PathType Leaf)) { throw "Missing private-data control-plane helper: $privateDataSource" }
Copy-Item -LiteralPath $privateDataSource -Destination $privateDataDestination -Force
$versionSource = Join-Path (Split-Path -Parent (Split-Path -Parent $sourceDir)) 'shipglows-version.json'
$versionDestination = Join-Path $ShipglowsDir 'shipglows-version.json'
if ((Test-Path -LiteralPath $versionSource -PathType Leaf) -and -not ([IO.Path]::GetFullPath($versionSource).Equals([IO.Path]::GetFullPath($versionDestination),[StringComparison]::OrdinalIgnoreCase))) {
    Copy-Item -LiteralPath $versionSource -Destination $versionDestination -Force
}
function Update-SgProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = @($runtimeDir, $userPath, $machinePath) -join ';'
}

function Add-SgUserPathEntry([string]$Directory) {
    if ([string]::IsNullOrWhiteSpace($Directory)) { return }
    $currentUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @($currentUserPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $remainingEntries = @()
    foreach ($entry in $entries) {
        if ($entry.TrimEnd('\') -ine $Directory.TrimEnd('\')) { $remainingEntries += $entry }
    }
    $nextPath = @($Directory) + $remainingEntries
    [Environment]::SetEnvironmentVariable('Path', ($nextPath -join ';'), 'User')
    Update-SgProcessPath
}

function Remove-SgLegacyRuntime {
    if ([IO.Path]::GetFullPath($ShipglowsDir).TrimEnd('\') -ne $defaultRuntimeRoot) { return }
    $legacyVisibleRoot = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE 'ShipGlows')).TrimEnd('\')
    $legacyRoots = @($defaultHiddenParent, $legacyVisibleRoot)
    $currentUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $keptPathEntries = @($currentUserPath -split ';' | Where-Object {
        if ([string]::IsNullOrWhiteSpace($_)) { return $false }
        $entryPath = [IO.Path]::GetFullPath($_).TrimEnd('\')
        foreach ($legacyRoot in $legacyRoots) {
            $legacyBin = [IO.Path]::GetFullPath((Join-Path $legacyRoot 'bin')).TrimEnd('\')
            if ($entryPath -eq $legacyBin) { return $false }
        }
        return $true
    })
    [Environment]::SetEnvironmentVariable('Path', ($keptPathEntries -join ';'), 'User')
    foreach ($legacyRoot in $legacyRoots) {
        foreach ($technicalDirectory in @('bin', 'cli', 'local')) {
            $legacyPath = Join-Path $legacyRoot $technicalDirectory
            if (Test-Path -LiteralPath $legacyPath) {
                Remove-Item -LiteralPath $legacyPath -Recurse -Force
                Write-Host "Removed legacy ShipGlows runtime: $legacyPath" -ForegroundColor DarkGray
            }
        }
    }
    $legacyWorkspace = Join-Path $legacyVisibleRoot 'workspace'
    if ((Test-Path -LiteralPath $legacyWorkspace) -and -not (Get-ChildItem -LiteralPath $legacyWorkspace -Force | Select-Object -First 1)) {
        Remove-Item -LiteralPath $legacyWorkspace -Force
    }
}

function Add-SgRuntimeToUserPath { Add-SgUserPathEntry $runtimeDir }

function Remove-SgObsoleteProfileCommand {
    if ($SkipProfile) { return }
    $profilePath = $PROFILE
    if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) { return }

    $existing = Get-Content -LiteralPath $profilePath -Raw
    $managedBlock = '(?m)^# ShipGlows DevServer \(managed\)\r?\nfunction shipglows-dev \{[^\r\n]*\}\r?\n?'
    $next = [regex]::Replace($existing, $managedBlock, '')
    if ($next -ne $existing) {
        Set-Content -LiteralPath $profilePath -Value $next -Encoding UTF8
        Write-Host 'Removed the obsolete ShipGlows profile command. Use s or shipglows-dev instead.' -ForegroundColor Green
    }
}

function Get-SgPersistentProfileExecutionPolicy {
    foreach ($scope in @('MachinePolicy', 'UserPolicy', 'CurrentUser', 'LocalMachine')) {
        $policy = Get-ExecutionPolicy -Scope $scope
        if ($policy -ne 'Undefined') { return $policy }
    }
    return 'Restricted'
}

function Install-SgGitPushProfileShortcut {
    if ($SkipProfile) {
        Write-Host "Git shortcut 'gp' skipped with -SkipProfile. Use gpush instead." -ForegroundColor Yellow
        return $false
    }

    $persistentPolicy = Get-SgPersistentProfileExecutionPolicy
    if ($persistentPolicy -notin @('Bypass', 'RemoteSigned', 'Unrestricted')) {
        Write-SgInstallerWarning "PowerShell profile scripts are governed by '$persistentPolicy'; ShipGlows kept gp unchanged. Use gpush instead."
        return $false
    }

    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDirectory = Split-Path -Parent $profilePath
    New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    $existing = if (Test-Path -LiteralPath $profilePath -PathType Leaf) {
        Get-Content -LiteralPath $profilePath -Raw
    } else {
        ''
    }
    $managedPattern = '(?ms)^# >>> ShipGlows Git shortcuts >>>\r?\n.*?^# <<< ShipGlows Git shortcuts <<<\r?\n?'
    $hasManagedBlock = [regex]::IsMatch($existing, $managedPattern)
    if ((Test-Path Function:gp) -and -not $hasManagedBlock) {
        Write-SgInstallerWarning "The PowerShell function 'gp' already exists outside ShipGlows's managed profile block. ShipGlows preserved it; gpush remains available."
        return $false
    }
    $withoutManagedBlock = [regex]::Replace($existing, $managedPattern, '').TrimEnd()
    $managedBlock = @'
# >>> ShipGlows Git shortcuts >>>
if (Test-Path Alias:gp) { Remove-Item Alias:gp -Force -ErrorAction SilentlyContinue }
function global:gp {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Message)

    & git rev-parse --is-inside-work-tree 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'gp must be run inside a Git repository.'
        return
    }

    & git add -A
    if ($LASTEXITCODE -ne 0) { Write-Error 'gp stopped because git add -A failed.'; return }

    & git diff --cached --quiet
    $diffStatus = $LASTEXITCODE
    if ($diffStatus -eq 1) {
        $commitMessage = if ($Message.Count -gt 0) {
            $Message -join ' '
        } else {
            'chore: sync changes ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')
        }
        & git commit -m $commitMessage
        if ($LASTEXITCODE -ne 0) { Write-Error 'gp stopped because git commit failed.'; return }
    } elseif ($diffStatus -ne 0) {
        Write-Error 'gp stopped because staged changes could not be inspected.'
        return
    } else {
        Write-Host 'No changes to commit; pushing existing local commits.' -ForegroundColor DarkGray
    }

    & git push
    if ($LASTEXITCODE -ne 0) { Write-Error 'gp stopped because git push failed.' }
}
# <<< ShipGlows Git shortcuts <<<
'@
    $next = if ($withoutManagedBlock) {
        $withoutManagedBlock + [Environment]::NewLine + [Environment]::NewLine + $managedBlock + [Environment]::NewLine
    } else {
        $managedBlock + [Environment]::NewLine
    }
    Set-Content -LiteralPath $profilePath -Value $next -Encoding UTF8
    Write-Host "PowerShell shortcut installed: gp -> git add -A, commit, push (active in new shells)." -ForegroundColor Green
    return $true
}

function Install-SgCommandWrappers {
    $wrapper = @'
@echo off
set "_SHIPGLOWS_PWSH=%USERPROFILE%\.shipglows\toolchains\powershell\7.6.5\win-x64\pwsh.exe"
if not exist "%_SHIPGLOWS_PWSH%" goto shipglows_bootstrap
set "SHIPGLOWS_MANAGED_PWSH=%_SHIPGLOWS_PWSH%"
"%_SHIPGLOWS_PWSH%" -NoLogo -NoProfile -File "%~dp0shipglows-devserver.ps1" %*
@exit /b %ERRORLEVEL%
:shipglows_bootstrap
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0ShipGlows.PowerShellBootstrap.ps1" %*
@exit /b %ERRORLEVEL%
'@
    $longCommand = Join-Path $runtimeDir 'shipglows-dev.cmd'
    Set-Content -LiteralPath $longCommand -Value $wrapper -Encoding ASCII
    Add-SgRuntimeToUserPath

    $shortCommand = Join-Path $runtimeDir 's.cmd'
    $existing = Get-Command s -ErrorAction SilentlyContinue | Select-Object -First 1
    $canUseShortCommand = -not $existing
    if ($existing -and $existing.Source) {
        try { $canUseShortCommand = [IO.Path]::GetFullPath($existing.Source) -eq [IO.Path]::GetFullPath($shortCommand) } catch { }
    }
    if ($canUseShortCommand) {
        Set-Content -LiteralPath $shortCommand -Value $wrapper -Encoding ASCII
        Write-Host 'Short command installed: s' -ForegroundColor Green
    } else {
        Write-SgInstallerWarning "The command 's' is already used by $($existing.Source). ShipGlows kept the non-conflicting command: shipglows-dev."
    }

    $shipglowsCommand = Join-Path $runtimeDir 'shipglows.cmd'
    $shipglowsScript = Join-Path $runtimeDir 'shipglows.ps1'
    $existingShipglows = Get-Command shipglows -ErrorAction SilentlyContinue | Select-Object -First 1
    $canInstallShipglows = -not $existingShipglows
    if ($existingShipglows -and $existingShipglows.Source) {
        try {
            $resolvedExistingShipglows = [IO.Path]::GetFullPath($existingShipglows.Source)
            $canInstallShipglows = $resolvedExistingShipglows -in @(
                [IO.Path]::GetFullPath($shipglowsCommand),
                [IO.Path]::GetFullPath($shipglowsScript)
            )
        } catch { }
    }
    if ($canInstallShipglows) {
        $shipglowsWrapper = @'
@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0shipglows.ps1" %*
@exit /b %ERRORLEVEL%
'@
        Set-Content -LiteralPath $shipglowsCommand -Value $shipglowsWrapper -Encoding ASCII
        Write-Host 'ShipGlows command installed: shipglows' -ForegroundColor Green
    } else {
        Write-SgInstallerWarning "The command 'shipglows' is already used by $($existingShipglows.Source). ShipGlows preserved it."
    }

}

function Test-SgTool([string]$Name, [string[]]$KnownPaths = @()) {
    if (Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue) { return $true }
    foreach ($path in $KnownPaths) {
        if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) { return $true }
    }
    return $false
}

function Get-SgToolPath([string]$Name, [string[]]$KnownPaths = @()) {
    $command = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command -and $command.Source) { return $command.Source }
    foreach ($path in $KnownPaths) {
        if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) { return $path }
    }
    return $null
}

function Test-SgToolRuns([string]$Name, [string[]]$KnownPaths = @(), [string[]]$Arguments = @('--version')) {
    $executable = Get-SgToolPath $Name $KnownPaths
    if (-not $executable) { return $false }
    try {
        $result = Invoke-SgBoundedProcess -File $executable -Arguments $Arguments -TimeoutSeconds 30
        return -not $result.TimedOut -and $result.ExitCode -eq 0
    } catch {
        return $false
    }
}

function Install-SgApplicationCommandWrapper([string]$Name, [string]$CommandName, [string[]]$KnownPaths = @()) {
    $wrapperPath = Join-Path $runtimeDir "$Name.cmd"
    $target = $null
    foreach ($knownPath in $KnownPaths) {
        if (-not $knownPath -or -not (Test-Path -LiteralPath $knownPath -PathType Leaf)) { continue }
        try {
            if ([IO.Path]::GetFullPath($knownPath) -eq [IO.Path]::GetFullPath($wrapperPath)) { continue }
        } catch { continue }
        $target = $knownPath
        break
    }
    if (-not $target) {
        $command = Get-Command $CommandName -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command -and $command.Source) {
            try {
                if ([IO.Path]::GetFullPath($command.Source) -ne [IO.Path]::GetFullPath($wrapperPath)) { $target = $command.Source }
            } catch { }
        }
    }
    if (-not $target) { return $false }

    $wrapper = @"
@echo off
@call "$target" %*
@exit /b %ERRORLEVEL%
# cmd-shim-target=$target
"@
    Set-Content -LiteralPath $wrapperPath -Value $wrapper -Encoding ASCII
    Write-Host "Application command installed: $Name" -ForegroundColor Green
    return $true
}

function Install-SgAgentShortcut([string]$Name, [string]$TargetName, [string[]]$PrefixArguments = @()) {
    $shortcutPath = Join-Path $runtimeDir "$Name.cmd"
    $targetPath = Join-Path $runtimeDir "$TargetName.cmd"
    if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) { return $false }

    $existing = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    $canInstall = -not $existing
    if ($existing -and $existing.Source) {
        try { $canInstall = [IO.Path]::GetFullPath($existing.Source) -eq [IO.Path]::GetFullPath($shortcutPath) } catch { }
    }
    if (-not $canInstall) {
        Write-SgInstallerWarning "The short command '$Name' is already used by $($existing.Source). ShipGlows did not replace it."
        return $false
    }

    $prefix = if (@($PrefixArguments).Count -gt 0) { ($PrefixArguments -join ' ') + ' ' } else { '' }
    $wrapper = @"
@echo off
@call "%~dp0$TargetName.cmd" $prefix%*
"@
    Set-Content -LiteralPath $shortcutPath -Value $wrapper -Encoding ASCII
    $message = "Agent shortcut installed: $Name -> $TargetName $($PrefixArguments -join ' ')"
    Write-Host $message.TrimEnd() -ForegroundColor Green
    return $true
}

function Install-SgShellShortcut([string]$Name, [string]$Command) {
    $shortcutPath = Join-Path $runtimeDir "$Name.cmd"
    $existing = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    $canInstall = -not $existing
    if ($existing -and $existing.Source) {
        try { $canInstall = [IO.Path]::GetFullPath($existing.Source) -eq [IO.Path]::GetFullPath($shortcutPath) } catch { }
    }
    if (-not $canInstall) {
        Write-SgInstallerWarning "The short command '$Name' is already used by $($existing.Source). ShipGlows did not replace it."
        return $false
    }

    $wrapper = "@echo off`r`n$Command`r`n"
    Set-Content -LiteralPath $shortcutPath -Value $wrapper -Encoding ASCII
    Write-Host "Shell shortcut installed: $Name" -ForegroundColor Green
    return $true
}

function Disable-SgBlockedPowerShellShim([string]$Name, [string[]]$KnownPaths = @()) {
    $changed = $false
    $userRoot = [IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\') + '\'
    foreach ($cmdPath in $KnownPaths) {
        if (-not $cmdPath -or -not (Test-Path -LiteralPath $cmdPath -PathType Leaf)) { continue }
        $ps1Path = [IO.Path]::ChangeExtension($cmdPath, '.ps1')
        if (-not (Test-Path -LiteralPath $ps1Path -PathType Leaf)) { continue }
        $resolvedPs1Path = [IO.Path]::GetFullPath($ps1Path)
        if (-not $resolvedPs1Path.StartsWith($userRoot, [StringComparison]::OrdinalIgnoreCase)) {
            Write-Host "Protected system PowerShell shim left unchanged for ${Name}: $resolvedPs1Path" -ForegroundColor DarkGray
            continue
        }
        try {
            $backupPath = "$ps1Path.shipglows-disabled"
            if (Test-Path -LiteralPath $backupPath) {
                $backupPath = "$backupPath-$([guid]::NewGuid().ToString('N'))"
            }
            Move-Item -LiteralPath $ps1Path -Destination $backupPath
            Write-Host "Disabled blocked PowerShell shim for $Name; preserved it as $backupPath." -ForegroundColor Green
            $changed = $true
        } catch {
            Write-SgInstallerWarning "The blocked $Name PowerShell shim could not be preserved and disabled: $($_.Exception.Message)"
        }
    }
    return $changed
}

function Install-SgWingetPackage([string]$Name, [string]$PackageId, [string[]]$KnownPaths = @()) {
    if (Test-SgTool $Name $KnownPaths) {
        Write-Host "$Name is already installed." -ForegroundColor Green
        return $true
    }
    $winget = Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $winget) {
        Write-SgInstallerWarning "WinGet is unavailable; $Name could not be installed automatically."
        return $false
    }
    try {
        Write-Host "Installing $Name..." -ForegroundColor Cyan
        Write-Host 'Please wait and keep this window open. WinGet can take several minutes and may appear idle while Windows completes the installation.' -ForegroundColor Yellow
        & $winget.Source install --id $PackageId --exact --source winget --accept-package-agreements --accept-source-agreements --silent --disable-interactivity | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "$Name installation returned exit code $LASTEXITCODE." }
        Update-SgProcessPath
        if (-not (Test-SgTool $Name $KnownPaths)) { throw "$Name was installed but is not discoverable yet." }
        Write-Host "$Name installed." -ForegroundColor Green
        return $true
    } catch {
        Write-SgInstallerWarning "$Name could not be installed automatically: $($_.Exception.Message)"
        return $false
    }
}

function Install-SgGum {
    $destination = Join-Path $runtimeDir 'gum.exe'
    if (Test-Path -LiteralPath $destination -PathType Leaf) {
        try {
            $installedVersion = (& $destination --version 2>$null | Out-String).Trim()
            if ($LASTEXITCODE -eq 0 -and $installedVersion -match [regex]::Escape($gumVersion)) {
                Write-Host "Gum $gumVersion is already installed." -ForegroundColor Green
                return $true
            }
        } catch { }
    }

    if (-not [Environment]::Is64BitOperatingSystem) {
        Write-SgInstallerWarning 'Gum automatic installation currently requires 64-bit Windows; the PowerShell menu will remain available.'
        return $false
    }

    $tempDirectory = Join-Path ([IO.Path]::GetTempPath()) ("shipglows-gum-" + [guid]::NewGuid().ToString('N'))
    $archive = Join-Path $tempDirectory 'gum.zip'
    try {
        New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null
        $url = "https://github.com/charmbracelet/gum/releases/download/v$gumVersion/gum_${gumVersion}_Windows_x86_64.zip"
        Write-Host "Installing Gum $gumVersion for the interactive menu..." -ForegroundColor Cyan
        & curl.exe -fsSL $url -o $archive
        if ($LASTEXITCODE -ne 0) { throw 'Gum download failed.' }
        $actualHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
        if ($actualHash -ne $gumSha256) { throw 'Gum archive checksum validation failed.' }

        $tar = Join-Path $env:WINDIR 'System32\tar.exe'
        if (-not (Test-Path -LiteralPath $tar -PathType Leaf)) { throw 'Windows tar.exe is unavailable.' }
        $archiveEntry = "gum_${gumVersion}_Windows_x86_64/gum.exe"
        & $tar -xf $archive -C $tempDirectory $archiveEntry
        if ($LASTEXITCODE -ne 0) { throw 'Gum archive extraction failed.' }
        $extractedGum = Join-Path $tempDirectory ($archiveEntry -replace '/', '\')
        Copy-Item -LiteralPath $extractedGum -Destination $destination -Force
        Write-Host "Gum $gumVersion installed." -ForegroundColor Green
        return $true
    } catch {
        Write-SgInstallerWarning "Gum could not be installed automatically: $($_.Exception.Message) The PowerShell menu will remain available."
        return $false
    } finally {
        if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Initialize-SgPnpmGlobalBin([string[]]$PnpmPaths) {
    $pnpm = Get-SgToolPath 'pnpm.cmd' $PnpmPaths
    if (-not $pnpm) { return $false }
    if (-not (Test-SgToolRuns 'pnpm.cmd' $PnpmPaths)) {
        Write-SgInstallerWarning 'pnpm --version check failed; pnpm is not ready yet.'
        return $false
    }

    try {
        $defaultGlobalBin = Join-Path $env:LOCALAPPDATA 'pnpm\bin'
        New-Item -ItemType Directory -Path $defaultGlobalBin -Force | Out-Null
        Add-SgUserPathEntry $defaultGlobalBin

        $configured = Invoke-SgBoundedProcess -File $pnpm -Arguments @('config','get','global-bin-dir') -TimeoutSeconds 30
        $globalBin = $configured.Output.Trim()
        if ($configured.TimedOut -or $configured.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($globalBin) -or $globalBin -in @('null', 'undefined')) {
            $globalBin = $defaultGlobalBin
            $configured = Invoke-SgBoundedProcess -File $pnpm -Arguments @('config','set','global-bin-dir',$globalBin,'--global') -TimeoutSeconds 30
            if ($configured.TimedOut -or $configured.ExitCode -ne 0) { throw 'pnpm global-bin-dir configuration failed or timed out.' }
        }
        New-Item -ItemType Directory -Path $globalBin -Force | Out-Null
        Add-SgUserPathEntry $globalBin
        Write-Host "pnpm global commands are available from $globalBin." -ForegroundColor Green
        return $true
    } catch {
        Write-SgInstallerWarning "pnpm is installed, but its global command directory could not be prepared: $($_.Exception.Message)"
        return $false
    }
}

function Install-SgPnpm([string[]]$NpmPaths, [string[]]$CorepackPaths, [string[]]$PnpmPaths) {
    if (Test-SgToolRuns 'pnpm.cmd' $PnpmPaths) {
        Write-Host 'pnpm is already installed.' -ForegroundColor Green
        return (Initialize-SgPnpmGlobalBin $PnpmPaths)
    }

    $npm = Get-SgToolPath 'npm.cmd' $NpmPaths
    if (-not $npm) {
        Write-SgInstallerWarning 'pnpm could not be installed because npm is unavailable.'
        return $false
    }

    try {
        Write-Host 'Preparing pnpm with Corepack...' -ForegroundColor Cyan
        $corepackInstall = Invoke-SgVisibleBoundedProcess -OperationId 'tool.corepack' -Label 'Installing Corepack' -File $npm -Arguments @('install','--global','corepack@latest') -TimeoutSeconds 300
        if ($corepackInstall.TimedOut -or $corepackInstall.ExitCode -ne 0) { throw "Corepack installation failed or timed out: $($corepackInstall.Output)" }
        Update-SgProcessPath

        $corepack = Get-SgToolPath 'corepack.cmd' $CorepackPaths
        if ($corepack) {
            $corepackEnable = Invoke-SgVisibleBoundedProcess -OperationId 'tool.corepack-pnpm' -Label 'Enabling pnpm with Corepack' -File $corepack -Arguments @('enable','pnpm') -TimeoutSeconds 120
            if (-not $corepackEnable.TimedOut -and $corepackEnable.ExitCode -eq 0) {
                Update-SgProcessPath
                if (Test-SgToolRuns 'pnpm.cmd' $PnpmPaths) {
                    Write-Host 'pnpm installed with Corepack.' -ForegroundColor Green
                    return (Initialize-SgPnpmGlobalBin $PnpmPaths)
                }
            } else {
                Write-SgInstallerWarning 'Corepack could not enable pnpm here; using the npm fallback.'
            }
        }

        Write-Host 'Installing pnpm with npm fallback...' -ForegroundColor Cyan
        $pnpmInstall = Invoke-SgVisibleBoundedProcess -OperationId 'tool.pnpm' -Label 'Installing pnpm' -File $npm -Arguments @('install','--global','pnpm@latest') -TimeoutSeconds 300
        if ($pnpmInstall.TimedOut -or $pnpmInstall.ExitCode -ne 0) { throw "pnpm installation failed or timed out: $($pnpmInstall.Output)" }
        Update-SgProcessPath
        if (-not (Test-SgToolRuns 'pnpm.cmd' $PnpmPaths)) { throw 'pnpm was installed but its version check failed.' }
        Write-Host 'pnpm installed.' -ForegroundColor Green
        return (Initialize-SgPnpmGlobalBin $PnpmPaths)
    } catch {
        Write-SgInstallerWarning "pnpm could not be installed automatically: $($_.Exception.Message)"
        return $false
    }
}

function Get-SgCodexPermissionModeFromConfig([string]$ConfigPath) {
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { return '' }
    foreach ($line in (Get-Content -LiteralPath $ConfigPath)) {
        if ($line -match '^\s*\[[^]]+\]\s*$') { break }
        if ($line -match '^\s*default_permissions\s*=\s*"([^"]+)"') {
            if ($Matches[1] -eq ':danger-full-access') { return 'full' }
            if ($Matches[1] -eq ':workspace') { return 'workspace' }
        }
        if ($line -match '^\s*sandbox_mode\s*=\s*"([^"]+)"') {
            if ($Matches[1] -eq 'danger-full-access') { return 'full' }
            if ($Matches[1] -eq 'workspace-write') { return 'workspace' }
        }
    }
    return ''
}

function Resolve-SgCodexPermissionMode([string]$ConfigPath) {
    $requested = if ($env:SHIPGLOWS_CODEX_PERMISSION_MODE) {
        $env:SHIPGLOWS_CODEX_PERMISSION_MODE
    } elseif ($env:SHIPGLOWS_AUTONOMY_MODE) {
        $env:SHIPGLOWS_AUTONOMY_MODE
    } else {
        'ask'
    }
    switch ($requested.Trim().ToLowerInvariant()) {
        { $_ -in @('full', 'permissive', 'danger', 'dangerous') } { return 'full' }
        { $_ -in @('workspace', 'standard', 'safe', 'restricted') } { return 'workspace' }
        { $_ -in @('keep', 'unchanged', 'skip') } { return 'keep' }
        { $_ -in @('', 'ask') } { Write-SgInstallerWarning 'Codex permission mode ask is not used by the one-question full installer; existing permissions were kept.'; return 'keep' }
        default {
            Write-SgInstallerWarning "Unknown SHIPGLOWS_CODEX_PERMISSION_MODE value '$requested'; the existing Codex configuration was kept."
            return 'keep'
        }
    }

    return 'keep'
}

function Set-SgCodexPermissionMode([string]$Mode, [string]$ConfigPath) {
    if ($Mode -notin @('workspace', 'full')) { return $false }
    $approvalPolicy = if ($Mode -eq 'full') { 'never' } else { 'on-request' }
    $permissionProfile = if ($Mode -eq 'full') { ':danger-full-access' } else { ':workspace' }
    $configDirectory = Split-Path -Parent $ConfigPath
    New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null
    $existing = if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) { [IO.File]::ReadAllText($ConfigPath) } else { '' }
    $managedPattern = '(?ms)^# >>> shipglows codex autonomous >>>\r?\n.*?^# <<< shipglows codex autonomous <<<\r?\n?'
    $withoutManagedBlock = [regex]::Replace($existing, $managedPattern, '')
    $keptLines = @()
    $beforeTable = $true
    foreach ($line in ($withoutManagedBlock -split '\r?\n')) {
        if ($line -match '^\s*\[[^]]+\]\s*$') { $beforeTable = $false }
        if ($beforeTable -and $line -match '^\s*(approval_policy|default_permissions|sandbox_mode)\s*=') { continue }
        $keptLines += $line
    }
    $managedBlock = @(
        '# >>> shipglows codex autonomous >>>',
        "approval_policy = `"$approvalPolicy`"",
        "default_permissions = `"$permissionProfile`"",
        '# <<< shipglows codex autonomous <<<'
    ) -join "`n"
    $remainder = ($keptLines -join "`n").Trim([char[]]"`r`n")
    $next = if ($remainder) { "$managedBlock`n`n$remainder`n" } else { "$managedBlock`n" }
    if ($next.Replace("`r`n", "`n") -ceq $existing.Replace("`r`n", "`n")) {
        Write-Host "Codex permissions already configured: $Mode." -ForegroundColor Green
        return $false
    }
    $temp = "$ConfigPath.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temp, $next, [Text.UTF8Encoding]::new($false))
        if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) { Move-SgAtomicReplace $temp $ConfigPath }
        else { Move-Item -LiteralPath $temp -Destination $ConfigPath }
    } finally { if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force } }
    Write-Host "Codex permissions configured: $Mode." -ForegroundColor Green
    return $true
}

function Get-SgNativeNpxPath([string[]]$KnownPaths = @()) {
    foreach ($path in $KnownPaths) {
        if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) { return [IO.Path]::GetFullPath($path) }
    }
    $managedWrapper = [IO.Path]::GetFullPath((Join-Path $runtimeDir 'npx.cmd'))
    foreach ($command in @(Get-Command 'npx.cmd' -CommandType Application -All -ErrorAction SilentlyContinue)) {
        if (-not $command.Source -or [IO.Path]::GetExtension($command.Source) -ine '.cmd') { continue }
        $candidate = [IO.Path]::GetFullPath($command.Source)
        if ($candidate -ine $managedWrapper) { return $candidate }
    }
    return $null
}

function Install-SgDefaultPython([string[]]$UvPaths, [string[]]$PythonPaths) {
    $uv = Get-SgToolPath 'uv.exe' $UvPaths
    if (-not $uv) { throw 'uv is required to install the ShipGlows Python runtime, but it is unavailable.' }

    Write-Host 'Ensuring a default Python runtime with uv...' -ForegroundColor Cyan
    & $uv python install --default | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "uv could not install a default Python runtime (exit code $LASTEXITCODE)." }

    $pythonBinDirectory = Join-Path $env:USERPROFILE '.local\bin'
    Add-SgUserPathEntry $pythonBinDirectory
    foreach ($commandName in @('python.exe', 'python3.exe')) {
        $commandPath = Join-Path $pythonBinDirectory $commandName
        if (-not (Test-Path -LiteralPath $commandPath -PathType Leaf)) {
            throw "$commandName was not published by uv."
        }
        & $commandPath -c 'import ssl, sqlite3' 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "$commandName is not functional after uv installed the default Python runtime."
        }
    }

    $python = $PythonPaths | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
    if (-not $python) { throw 'The uv-managed default Python command could not be resolved.' }
    $version = (& $python --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $version -notmatch '^Python\s+\d+\.\d+\.\d+') {
        throw 'The uv-managed default Python command did not report a valid version.'
    }
    Write-Host "$version installed as python and python3 via uv." -ForegroundColor Green
    return [pscustomobject]@{
        Version = $version
        Manager = 'uv'
        Commands = 'python, python3'
        Path = $python
    }
}

function Assert-SgEnvironmentPythonPackage([string]$PythonPath, [string]$EnvironmentDirectory) {
    $pythonFiles = @('__init__.py','adapters.py','core.py','mise_backend.py','preparation.py','shipglows_environment.py','versions.py','windows_tauri_backend.py') | ForEach-Object { Join-Path $EnvironmentDirectory $_ }
    # Windows PowerShell 5.1 removes embedded double quotes while rebuilding a
    # native argv. Python accepts single-quoted literals, which survive that
    # boundary and keep the -c program intact.
    $script = "import ast,pathlib,sys; [ast.parse(pathlib.Path(p).read_text(encoding='utf-8'), filename=p) for p in sys.argv[1:]]"
    & $PythonPath -c $script @pythonFiles
    if ($LASTEXITCODE -ne 0) { throw 'The installed ShipGlows environment Python package failed syntax validation.' }
}

function Write-SgGlobalDevelopmentEnvironment([hashtable]$AgentInfo, [pscustomobject]$PlaywrightInfo, [pscustomobject]$PlaywrightRuntimeInfo, [pscustomobject]$PythonInfo, [bool]$FlutterReady, [pscustomobject]$AndroidInfo, [pscustomobject]$IdeInfo, [pscustomobject]$ServiceInfo, [bool]$DeveloperModeReady, [pscustomobject]$TauriInfo) {
    $environmentPath = Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'environment.md'
    New-Item -ItemType Directory -Path (Split-Path -Parent $environmentPath) -Force | Out-Null
    $codexStatus = if ($AgentInfo.Codex.Installed) { 'installed' } else { 'not installed' }
    $playwrightInstalled = if ($PlaywrightInfo.Installed) { 'yes' } else { 'no' }
    $playwrightConfigured = if ($PlaywrightInfo.McpConfigured) { 'yes, see per-project readiness below' } else { 'no' }
    $playwrightVerified = if ($PlaywrightInfo.McpVerified) { 'yes, per-project configuration converged' } else { 'no' }
    $playwrightConfigPath = if ($PlaywrightInfo.ConfigPath) { $PlaywrightInfo.ConfigPath } else { 'not available' }
    $chromiumPath = if ($PlaywrightInfo.ChromiumPath) { $PlaywrightInfo.ChromiumPath } else { 'not available' }
    $flutterInstalled = if ($FlutterReady) { 'yes' } else { 'no' }
    $androidToolchainReady = if ($AndroidInfo.ToolchainReady) { 'yes' } else { 'no' }
    $androidLicensesReady = if ($AndroidInfo.LicensesReady) { 'yes' } else { 'no' }
    $androidDeviceReady = if ($AndroidInfo.DeviceReady) { 'yes' } else { 'no' }
    $androidEmulatorInstalled = if ($AndroidInfo.PSObject.Properties['EmulatorInstalled'] -and $AndroidInfo.EmulatorInstalled) { 'yes' } else { 'no' }
    $androidAvdReady = if ($AndroidInfo.PSObject.Properties['AvdReady'] -and $AndroidInfo.AvdReady) { 'yes' } else { 'no' }
    $androidEmulatorAccelerationReady = if ($AndroidInfo.PSObject.Properties['EmulatorAccelerationReady'] -and $AndroidInfo.EmulatorAccelerationReady) { 'yes' } else { 'no' }
    $androidStudioReady = if ($IdeInfo.AndroidStudioReady) { 'yes' } else { 'no' }
    $visualStudioCppReady = if ($IdeInfo.VisualStudioCppReady) { 'yes' } else { 'no' }
    $windowsDesktopReady = if ($FlutterReady -and $IdeInfo.VisualStudioCppReady -and $DeveloperModeReady) { 'yes' } else { 'no' }
    $firebaseDeviceStreamingReady = if ($IdeInfo.FirebaseDeviceStreamingReady) { 'yes' } else { 'no' }
    $developerModeStatus = if ($DeveloperModeReady) { 'yes' } else { 'no' }
    $tauriDetected = if ($TauriInfo -and $TauriInfo.Detected) { 'yes' } else { 'no' }
    $tauriHostReady = if ($TauriInfo -and $TauriInfo.HostReady) { 'yes' } else { 'no' }
    $tauriRustReady = if ($TauriInfo -and $TauriInfo.RustReady) { 'yes' } else { 'no' }
    $tauriNdkReady = if ($TauriInfo -and $TauriInfo.NdkReady) { 'yes' } else { 'no' }
    $tauriProjectStatus = if ($TauriInfo -and $TauriInfo.ProjectStatus) { [string]$TauriInfo.ProjectStatus } else { 'not_applicable' }
    $tauriBaseline = if ($TauriInfo -and $TauriInfo.Baseline) { "Rust $($TauriInfo.Baseline.RustToolchainVersion); Tauri CLI $($TauriInfo.Baseline.TauriCliVersion); Android API $($TauriInfo.Baseline.AndroidApiLevel); NDK $($TauriInfo.Baseline.NdkVersion)" } else { 'not applicable' }
    $tauriNextAction = if ($tauriDetected -eq 'no') { 'none' } elseif ($tauriHostReady -eq 'no') { 'rerun the interactive ShipGlows full installer and accept the reusable Tauri Android toolchain.' } elseif ($tauriProjectStatus -eq 'migration_required') { 'use the generated handoff to migrate the project with Codex; ShipGlows never mutates it automatically.' } elseif ($tauriProjectStatus -eq 'unknown') { 'inspect the reported Tauri manifests before claiming compatibility.' } else { 'none' }
    $agentLines = @()
    foreach ($agentName in @('Codex','Claude','OpenCode','Kilo','Gemini')) {
        $agent = $AgentInfo[$agentName]
        $installed = if ($agent -and $agent.Installed) { 'yes' } else { 'no' }
        $mcp = if ($agent -and $agent.McpSummary) { [string]$agent.McpSummary } else { 'not configured' }
        $agentLines += "- $agentName CLI installed: $installed"
        $agentLines += "- $agentName MCP readiness: $mcp"
    }
    $serviceLines = @()
    foreach ($serviceName in @('Firebase','FlutterFire','Convex','Vercel','Supabase','Clerk','Auth0','Doppler','GoogleCloud','AndroidNative')) {
        $state = if ($ServiceInfo -and $ServiceInfo.PSObject.Properties[$serviceName]) { [string]$ServiceInfo.$serviceName } else { 'not detected' }
        $serviceLines += "- $serviceName development tooling: $state"
    }
    $dopplerDeclared = if ($ServiceInfo -and $ServiceInfo.PSObject.Properties['Needs'] -and $ServiceInfo.Needs.PSObject.Properties['Doppler'] -and $ServiceInfo.Needs.Doppler) { 'detected' } else { 'not detected' }
    $serviceLines += "- Doppler project declaration: $dopplerDeclared"
    $firebaseDeviceStreamingNextAction = if (-not $IdeInfo.AndroidStudioReady) {
        'rerun the interactive ShipGlows full installer and accept the Windows IDE bundle.'
    } elseif (-not $IdeInfo.FirebaseDeviceStreamingReady) {
        'open Android Studio, sign in yourself, select a Firebase project, then open Device Manager > Firebase.'
    } else { 'none' }
    $androidNextAction = if (-not $FlutterReady) {
        'rerun the ShipGlows full installer to repair Flutter/Dart.'
    } elseif (-not $AndroidInfo.LicensesReady) {
        'rerun the ShipGlows full installer in an interactive PowerShell and review the official Android SDK licenses.'
    } elseif (-not $AndroidInfo.ToolchainReady) {
        'rerun the ShipGlows full installer to complete Android SDK provisioning.'
    } elseif (-not $AndroidInfo.DeviceReady) {
        if ($androidAvdReady -eq 'yes' -and $androidEmulatorAccelerationReady -eq 'yes') { 'start ShipGlows_API_36 with `flutter emulators --launch ShipGlows_API_36`, or connect a real phone with USB debugging.' }
        elseif ($androidAvdReady -eq 'yes') { 'ShipGlows_API_36 is installed but hardware acceleration is unavailable; use a real phone or a hosted Android device.' }
        elseif ($androidEmulatorInstalled -eq 'yes') { 'rerun the interactive full installer to create ShipGlows_API_36, or connect a real phone with USB debugging.' }
        else { 'connect a real phone with USB debugging, or install and start the optional ShipGlows Android emulator.' }
    } else { 'none' }
    $content = @"
# ShipGlows development environment

- Host operating system: Windows
- Shell: PowerShell
- Agent instruction hosts: per-agent native global files
- Codex CLI: $codexStatus
- Local server manager: ShipGlows native Windows DevServer (shipglows-devserver)
- Python: $($PythonInfo.Version)
- Python manager: $($PythonInfo.Manager)
- Python commands: $($PythonInfo.Commands)
- Flutter and Dart installed: $flutterInstalled
- Android toolchain ready: $androidToolchainReady
- Android licenses ready: $androidLicensesReady
- Android device ready: $androidDeviceReady
- Android emulator installed: $androidEmulatorInstalled
- Android virtual device ready: $androidAvdReady
- Android emulator acceleration ready: $androidEmulatorAccelerationReady
- Android next action: $androidNextAction
- Android Studio installed: $androidStudioReady
- Visual Studio Desktop C++ workload ready: $visualStudioCppReady
- Flutter Windows desktop toolchain ready: $windowsDesktopReady
- Windows Developer Mode enabled: $developerModeStatus
- Windows Developer Mode next action: $(if ($DeveloperModeReady) { 'none' } else { 'open Windows Settings > System > For developers; ShipGlows never changes this policy automatically.' })
- Firebase Android Device Streaming configured: $firebaseDeviceStreamingReady
- Firebase Android Device Streaming next action: $firebaseDeviceStreamingNextAction
- Tauri Android project detected: $tauriDetected
- Tauri Android host toolchain ready: $tauriHostReady
- Tauri Rust toolchain ready: $tauriRustReady
- Tauri Android NDK ready: $tauriNdkReady
- Tauri project compatibility: $tauriProjectStatus
- Tauri validated baseline: $tauriBaseline
- Tauri next action: $tauriNextAction
- Playwright Chromium installed: $playwrightInstalled
- Playwright MCP configured: $playwrightConfigured
- Playwright MCP verified: $playwrightVerified
- Playwright MCP config: $playwrightConfigPath
- Playwright Chromium path: $chromiumPath
- Playwright CLI installed: $($PlaywrightRuntimeInfo.StableReady)
- Playwright CLI version: $($PlaywrightRuntimeInfo.StableVersion)
- Playwright Chromium revision: $($PlaywrightRuntimeInfo.StableRevision)
- Playwright Agent CLI installed: $($PlaywrightRuntimeInfo.AgentCliReady)
- Playwright Agent CLI version: $($PlaywrightRuntimeInfo.AgentCliVersion)
- Motion runtime ready: $($PlaywrightRuntimeInfo.MotionReady)
- mise machine toolbox: $(if($ServiceInfo -and $ServiceInfo.PSObject.Properties['Mise']){[string]$ServiceInfo.Mise}else{'pending'})
- mise machine toolbox root: $(if($ServiceInfo -and $ServiceInfo.PSObject.Properties['ToolboxRoot']){[string]$ServiceInfo.ToolboxRoot}else{'not available'})
$($agentLines -join [Environment]::NewLine)
$($serviceLines -join [Environment]::NewLine)

- Windows-supported Flutter targets: web, Android, Windows desktop
- Flutter targets requiring another host: iOS and macOS require macOS; Linux desktop requires Linux

For a managed project, read `<project-root>\ENVIRONMENT.md` for the durable URL assigned by the ShipGlows CLI, and read the Windows ShipGlows DevServer registry for live status. Do not derive the URL from `package.json`, framework defaults, or another project's port.

ChatGPT apps/connectors and Codex CLI tools are separate surfaces. Installation or configuration does not make a tool callable in the current turn. Inspect both directly exposed tools and any deferred/searchable catalog provided by the current Codex host before declaring a configured tool unavailable; use only tools discovered and callable in that turn.
"@
    if ((Test-Path -LiteralPath $environmentPath -PathType Leaf) -and [IO.File]::ReadAllText($environmentPath).Replace("`r`n","`n") -ceq $content.Replace("`r`n","`n")) { return $environmentPath }
    [IO.File]::WriteAllText($environmentPath, $content, [Text.UTF8Encoding]::new($false))
    return $environmentPath
}

function Get-SgInstalledCommandVersion([string]$CommandName, [string[]]$KnownPaths = @()) {
    $command = Get-SgToolPath $CommandName $KnownPaths
    if (-not $command) { return '' }
    $result = Invoke-SgBoundedProcess $command @('--version') 30
    if ($result.TimedOut -or $result.ExitCode -ne 0) { return '' }
    $match = [regex]::Match($result.Output,'(?<!\d)(\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)(?!\d)')
    return $(if ($match.Success) { $match.Groups[1].Value } else { '' })
}

function Install-SgMissingAgentClis([string]$NpmPath, [hashtable]$CurrentReady, [bool]$UpdateApproved = $false) {
    $interactive = [Environment]::UserInteractive -and -not [Console]::IsInputRedirected
    $choice = ''
    $definitions = @{
        Codex    = @{ Package='@openai/codex'; Command='codex.cmd'; Paths=$codexPaths }
        Claude   = @{ Package='@anthropic-ai/claude-code'; Command='claude.cmd'; Paths=$claudePaths; PostInstall='install.cjs' }
        OpenCode = @{ Package='opencode-ai'; Command='opencode.cmd'; Paths=$opencodePaths; PostInstall='postinstall.mjs' }
        Kilo     = @{ Package='@kilocode/cli'; Command='kilo.cmd'; Paths=@($kiloPaths + $kilocodePaths) }
        Gemini   = @{ Package='@google/gemini-cli'; Command='gemini.cmd'; Paths=$geminiPaths }
    }
    $outdated = @{}; $resolvedVersions = @{}
    foreach ($name in $definitions.Keys) {
        $outdated[$name] = $false
        if (-not [bool]$CurrentReady[$name]) { continue }
        try {
            $resolvedVersions[$name] = Resolve-SgNpmVersion $NpmPath $definitions[$name].Package
            $installedVersion = Get-SgInstalledCommandVersion $definitions[$name].Command $definitions[$name].Paths
            if ($installedVersion -and $installedVersion -ne $resolvedVersions[$name]) { $outdated[$name] = $true }
            elseif (-not $installedVersion) { Write-SgInstallerWarning "$name CLI runs, but its installed version could not be proven; it was preserved." }
        } catch { Write-SgInstallerWarning "$name CLI version comparison remains pending: $($_.Exception.Message)" }
    }
    $initial = Get-SgAgentInstallPlan -Interactive $interactive -AgentReady $CurrentReady -AgentOutdated $outdated -Choice ''
    if ($initial.Ask -and -not $UpdateApproved) {
        $choice = Read-SgVisibleInstallerConsent -Interactive $interactive -Missing @($initial.Missing) -Outdated @($initial.Outdated) -Subject 'coding-agent CLIs' -Guidance 'ShipGlows installs only the CLI binaries; authentication and provider credentials remain yours.' -Prompt 'Install the missing or update the outdated coding-agent CLIs now? [y/N]' -OperationId 'input.agent-cli' -Label 'coding-agent CLI consent'
    }
    $plan = if ($UpdateApproved) {
        [pscustomobject]@{ Install=@($initial.Outdated); Status=if(@($initial.Outdated).Count){'install'}else{'ready'} }
    } else { Get-SgAgentInstallPlan -Interactive $interactive -AgentReady $CurrentReady -AgentOutdated $outdated -Choice $choice }
    foreach ($name in @($plan.Install)) {
        $definition = $definitions[$name]
        try {
            $version = if ($resolvedVersions[$name]) { $resolvedVersions[$name] } else { Resolve-SgNpmVersion $NpmPath $definition.Package }
            $install = Invoke-SgVisibleBoundedProcess -OperationId ("agent." + $name.ToLowerInvariant()) -Label ("Installing $name CLI $version") -File $NpmPath -Arguments @('install','--global',"$($definition.Package)@$version",'--registry=https://registry.npmjs.org/') -TimeoutSeconds 900
            $ready = -not $install.TimedOut -and $install.ExitCode -eq 0 -and (Test-SgToolRuns $definition.Command $definition.Paths)
            if (-not $ready -and $definition.PostInstall) {
                $prefix = Invoke-SgBoundedProcess $NpmPath @('prefix','--global') 30
                $node = Get-SgToolPath 'node.exe' $nodePaths
                $postInstallPath = if (-not $prefix.TimedOut -and $prefix.ExitCode -eq 0) { Join-Path (Join-Path $prefix.Output.Trim() 'node_modules') (($definition.Package + '/' + $definition.PostInstall).Replace('/','\')) } else { '' }
                if ($node -and $postInstallPath -and (Test-Path -LiteralPath $postInstallPath -PathType Leaf)) {
                    $postInstall = Invoke-SgVisibleBoundedProcess -OperationId ("agent." + $name.ToLowerInvariant() + '.postinstall') -Label ("Completing $name CLI $version native installation") -File $node -Arguments @($postInstallPath) -TimeoutSeconds 900
                    $ready = -not $postInstall.TimedOut -and $postInstall.ExitCode -eq 0 -and (Test-SgToolRuns $definition.Command $definition.Paths)
                }
            }
            if (-not $ready) { Write-SgInstallerWarning "$name CLI exact-version installation or executable verification failed." }
            if ($UpdateApproved -and -not $ready) { throw "$name CLI update failed final executable verification." }
        } catch { Write-SgInstallerWarning "$name CLI remains pending: $($_.Exception.Message)" }
    }
    return @{
        Codex = Test-SgToolRuns 'codex.cmd' $codexPaths
        Claude = Test-SgToolRuns 'claude.cmd' $claudePaths
        OpenCode = Test-SgToolRuns 'opencode.cmd' $opencodePaths
        Kilo = (Test-SgToolRuns 'kilo.cmd' $kiloPaths) -or (Test-SgToolRuns 'kilocode.cmd' $kilocodePaths)
        Gemini = Test-SgToolRuns 'gemini.cmd' $geminiPaths
    }
}

function Invoke-SgProjectEnvironmentMigration([string]$ModulePath) {
    Import-Module $ModulePath -Force -DisableNameChecking
    $config = Get-SgDevConfig
    $projectPaths = @(Sync-SgRegisteredProjectEnvironments $config)
    Write-Host "ShipGlows registered projects synchronized: $($projectPaths.Count)" -ForegroundColor Green
    return $projectPaths
}

function Get-SgRecordedMobileEnvironmentState {
    $environmentPath = Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'environment.md'
    $values = @{}
    if (Test-Path -LiteralPath $environmentPath -PathType Leaf) {
        foreach ($line in Get-Content -LiteralPath $environmentPath) {
            if ($line -match '^- ([^:]+):\s*(.+)$') { $values[$matches[1]] = $matches[2].Trim() }
        }
    }
    $isYes = { param([string]$Name) $values.ContainsKey($Name) -and $values[$Name] -eq 'yes' }
    return [pscustomobject]@{
        FlutterReady = & $isYes 'Flutter and Dart installed'
        AndroidInfo = [pscustomobject]@{
            ToolchainReady = & $isYes 'Android toolchain ready'
            LicensesReady = & $isYes 'Android licenses ready'
            DeviceReady = & $isYes 'Android device ready'
            EmulatorInstalled = & $isYes 'Android emulator installed'
            AvdReady = & $isYes 'Android virtual device ready'
            EmulatorAccelerationReady = & $isYes 'Android emulator acceleration ready'
            NdkReady = & $isYes 'Tauri Android NDK ready'
        }
        IdeInfo = [pscustomobject]@{
            AndroidStudioReady = & $isYes 'Android Studio installed'
            VisualStudioCppReady = & $isYes 'Visual Studio Desktop C++ workload ready'
            FirebaseDeviceStreamingReady = & $isYes 'Firebase Android Device Streaming configured'
        }
        TauriInfo = [pscustomobject]@{
            Detected = & $isYes 'Tauri Android project detected'
            HostReady = & $isYes 'Tauri Android host toolchain ready'
            RustReady = & $isYes 'Tauri Rust toolchain ready'
            NdkReady = & $isYes 'Tauri Android NDK ready'
            ProjectStatus = $(if ($values.ContainsKey('Tauri project compatibility')) { $values['Tauri project compatibility'] } else { 'unknown' })
            Baseline = Get-SgTauriAndroidBaseline
        }
    }
}

function Invoke-SgManagedWingetToolUpdate([object]$Definition) {
    $winget = Get-SgToolPath 'winget.exe'
    if (-not $winget) { Write-SgInstallerWarning "WinGet is unavailable; $($Definition.Name) could not be checked for an update."; return $false }
    if (-not (Test-SgTool $Definition.Command $Definition.Paths)) { return $true }

    $result = Invoke-SgVisibleBoundedProcess -OperationId ("tool.update." + $Definition.Key) -Label ("Updating " + $Definition.Name) -File $winget -Arguments @('upgrade','--id',$Definition.PackageId,'--exact','--source','winget','--accept-package-agreements','--accept-source-agreements','--silent','--disable-interactivity') -TimeoutSeconds 1800
    Update-SgProcessPath
    if (-not (Test-SgToolRuns $Definition.Command $Definition.Paths)) {
        throw "$($Definition.Name) is unavailable after its WinGet update attempt."
    }
    if ($result.TimedOut) { throw "$($Definition.Name) WinGet update timed out." }
    if ($result.ExitCode -ne 0) {
        Write-SgInstallerWarning "$($Definition.Name) remains usable, but WinGet returned exit code $($result.ExitCode); this can mean no applicable update or a provider-side refusal."
    }
    return $true
}

function Invoke-SgManagedPackageManagerUpdates([string[]]$NpmPaths, [string[]]$CorepackPaths, [string[]]$PnpmPaths) {
    $npm = Get-SgToolPath 'npm.cmd' $NpmPaths
    if (-not $npm) { Write-SgInstallerWarning 'npm is unavailable; exact npm and pnpm updates were skipped before normal convergence.'; return }
    $NpmPath = $npm
    $prefixResult = Invoke-SgBoundedProcess $npm @('prefix','--global') 30
    $npmPrefixPath = if (-not $prefixResult.TimedOut -and $prefixResult.ExitCode -eq 0) { $prefixResult.Output.Trim() } else { '' }
    $updatedNpmPath = if ($npmPrefixPath -and [IO.Path]::IsPathFullyQualified($npmPrefixPath)) { Join-Path $npmPrefixPath 'npm.cmd' } else { '' }

    $npmVersion = Resolve-SgNpmVersion $NpmPath 'npm@latest'
    $installedNpm = Get-SgInstalledCommandVersion 'npm.cmd' $NpmPaths
    Write-Host "npm: installed=$(if($installedNpm){$installedNpm}else{'unknown'}) target=$npmVersion" -ForegroundColor Cyan
    if ($installedNpm -ne $npmVersion) {
        $npmUpdate = Invoke-SgVisibleBoundedProcess -OperationId 'tool.update.npm' -Label ("Updating npm to $npmVersion") -File $npm -Arguments @('install','--global',"npm@$npmVersion",'--registry=https://registry.npmjs.org/') -TimeoutSeconds 900
        if ($npmUpdate.TimedOut -or $npmUpdate.ExitCode -ne 0) { throw "npm $npmVersion update failed or timed out." }
        Update-SgProcessPath
        $npm = Get-SgToolPath 'npm.cmd' $NpmPaths
        if (-not $npm) { throw 'npm became unavailable after its update.' }
    }
    $verifiedNpm = if ($updatedNpmPath -and (Test-Path -LiteralPath $updatedNpmPath -PathType Leaf)) {
        $result = Invoke-SgBoundedProcess $updatedNpmPath @('--version') 30
        $match = if (-not $result.TimedOut -and $result.ExitCode -eq 0) { [regex]::Match($result.Output,'(?<!\d)(\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)(?!\d)') } else { $null }
        if ($match -and $match.Success) { $match.Groups[1].Value } else { '' }
    } else { Get-SgInstalledCommandVersion 'npm.cmd' $NpmPaths }
    if ($verifiedNpm -ne $npmVersion) { throw "npm update mismatch: installed=$verifiedNpm target=$npmVersion" }

    $pnpmVersion = Resolve-SgNpmVersion $NpmPath 'pnpm@latest'
    $installedPnpm = Get-SgInstalledCommandVersion 'pnpm.cmd' $PnpmPaths
    Write-Host "pnpm: installed=$(if($installedPnpm){$installedPnpm}else{'unknown'}) target=$pnpmVersion" -ForegroundColor Cyan
    if ($installedPnpm -ne $pnpmVersion) {
        $corepack = Get-SgToolPath 'corepack.cmd' $CorepackPaths
        $pnpmUpdated = $false
        if ($corepack) {
            $corepackUpdate = Invoke-SgVisibleBoundedProcess -OperationId 'tool.update.pnpm' -Label ("Updating pnpm to $pnpmVersion with Corepack") -File $corepack -Arguments @('prepare',"pnpm@$pnpmVersion",'--activate') -TimeoutSeconds 300
            $pnpmUpdated = -not $corepackUpdate.TimedOut -and $corepackUpdate.ExitCode -eq 0
            if ($pnpmUpdated) {
                Update-SgProcessPath
                $pnpmUpdated = (Get-SgInstalledCommandVersion 'pnpm.cmd' $PnpmPaths) -eq $pnpmVersion
            }
        }
        if (-not $pnpmUpdated) {
            $pnpmUpdate = Invoke-SgVisibleBoundedProcess -OperationId 'tool.update.pnpm-fallback' -Label ("Updating pnpm to $pnpmVersion with npm") -File $npm -Arguments @('install','--global',"pnpm@$pnpmVersion",'--registry=https://registry.npmjs.org/') -TimeoutSeconds 900
            if ($pnpmUpdate.TimedOut -or $pnpmUpdate.ExitCode -ne 0) { throw "pnpm $pnpmVersion update failed or timed out." }
        }
        Update-SgProcessPath
    }
    $verifiedPnpm = Get-SgInstalledCommandVersion 'pnpm.cmd' $PnpmPaths
    if ($verifiedPnpm -ne $pnpmVersion) { throw "pnpm update mismatch: installed=$verifiedPnpm target=$pnpmVersion" }
}

function Invoke-SgManagedDeveloperToolUpdates([object[]]$Definitions, [string[]]$NpmPaths, [string[]]$CorepackPaths, [string[]]$PnpmPaths) {
    Write-Host 'Updating only ShipGlows-owned global developer tools. Project dependencies are excluded.' -ForegroundColor Yellow
    foreach ($definition in $Definitions) { [void](Invoke-SgManagedWingetToolUpdate $definition) }
    Invoke-SgManagedPackageManagerUpdates $NpmPaths $CorepackPaths $PnpmPaths
    Write-Host 'Developer tool updates completed; normal ShipGlows convergence will now verify managed wrappers and CLIs.' -ForegroundColor Green
}

function Move-SgManagedPartialDirectory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return '' }
    $quarantine = "$Path.partial-$(Get-Date -Format 'yyyyMMdd-HHmmss')-$([guid]::NewGuid().ToString('N').Substring(0,8))"
    Move-Item -LiteralPath $Path -Destination $quarantine
    Write-SgInstallerWarning "Incomplete managed tool was preserved for inspection: $quarantine"
    return $quarantine
}

function Save-SgVerifiedDownload([string]$Url, [string]$Sha256, [string]$Destination) {
    if ($Url -notmatch '^https://' -or $Url -notmatch '[.]zip(?:\?|$)' -or [IO.Path]::GetExtension($Destination) -ine '.zip') { throw 'Only HTTPS ZIP tool downloads are allowed.' }
    if ($Sha256 -notmatch '^[0-9A-Fa-f]{64}$') { throw 'Tool download requires a complete SHA-256 digest.' }
    $curl = Get-SgToolPath 'curl.exe' @((Join-Path $env:SystemRoot 'System32\curl.exe'))
    if (-not $curl) { throw 'Verified tool downloads require the Windows curl.exe client.' }
    & $curl --fail --location --progress-bar --retry 3 --retry-all-errors --retry-delay 2 --connect-timeout 30 --max-time 1200 --continue-at - --output $Destination $Url
    if ($LASTEXITCODE -ne 0) { throw "Verified tool download failed after bounded retries: $Url" }
    $actual = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
    if ($actual -ine $Sha256) { throw "Downloaded archive checksum mismatch for $Url" }
}

function Get-SgFlutterBaseline {
    return [pscustomobject]@{
        Schema = 'shipglows.flutter-baseline/v1'
        ValidatedAt = '2026-08-23'
        FlutterVersion = '3.47.1'
        DartVersion = '3.13.1'
        Commit = '6655482ec06e547f90abf8ae7590466f4415978d'
    }
}

function Resolve-SgFlutterStableCommit([string]$GitPath) {
    if ([string]::IsNullOrWhiteSpace($GitPath)) { return '' }
    $baseline = Get-SgFlutterBaseline
    $resolved = Invoke-SgBoundedProcess -File $GitPath -Arguments @('ls-remote','https://github.com/flutter/flutter.git','refs/heads/stable') -TimeoutSeconds 60
    if (-not $resolved.TimedOut -and $resolved.ExitCode -eq 0 -and $resolved.Output -match '(?m)^[0-9a-f]{40}\s+refs/heads/stable$') { return $baseline.Commit }
    return ''
}

function Set-SgManagedFlutterStableRevision([string]$GitPath, [string]$FlutterRoot, [string]$Commit) {
    if ($Commit -notmatch '^[0-9a-f]{40}$') { throw 'Flutter stable convergence requires a proven commit.' }
    $managedRoot = [IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter')).TrimEnd('\')
    $resolvedRoot = [IO.Path]::GetFullPath($FlutterRoot).TrimEnd('\')
    if (-not $resolvedRoot.Equals($managedRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Flutter stable convergence is restricted to the ShipGlows-managed SDK.' }

    $origin = Invoke-SgBoundedProcess -File $GitPath -Arguments @('-C',$resolvedRoot,'remote','get-url','origin') -TimeoutSeconds 30
    $originUrl = if (-not $origin.TimedOut -and $origin.ExitCode -eq 0) { $origin.Output.Trim().TrimEnd('/') } else { '' }
    if ($originUrl -notmatch '(?i)^https://github[.]com/flutter/flutter(?:[.]git)?$') { throw 'Managed Flutter origin is not the official Flutter repository.' }
    $status = Invoke-SgBoundedProcess -File $GitPath -Arguments @('-C',$resolvedRoot,'status','--porcelain','--untracked-files=no') -TimeoutSeconds 30
    if ($status.TimedOut -or $status.ExitCode -ne 0 -or -not [string]::IsNullOrWhiteSpace($status.Output)) { throw 'Managed Flutter has tracked local changes; stable convergence was safely skipped.' }
    $head = Invoke-SgBoundedProcess -File $GitPath -Arguments @('-C',$resolvedRoot,'rev-parse','HEAD') -TimeoutSeconds 30
    $previousCommit = if (-not $head.TimedOut -and $head.ExitCode -eq 0 -and $head.Output.Trim() -match '^[0-9a-f]{40}$') { $head.Output.Trim() } else { '' }
    if (-not $previousCommit) { throw 'Managed Flutter current revision could not be proven.' }

    $fetch = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.update' -Label 'Converging the validated Flutter SDK baseline' -File $GitPath -Arguments @('-C',$resolvedRoot,'fetch','--depth','1','origin',("+{0}:refs/remotes/origin/shipglows-stable" -f $Commit)) -TimeoutSeconds 600
    if ($fetch.TimedOut -or $fetch.ExitCode -ne 0) { Write-SgInstallerWarning 'Flutter baseline fetch failed or timed out; the existing managed SDK was preserved.'; return $false }
    $remote = Invoke-SgBoundedProcess -File $GitPath -Arguments @('-C',$resolvedRoot,'rev-parse','refs/remotes/origin/shipglows-stable') -TimeoutSeconds 30
    if ($remote.TimedOut -or $remote.ExitCode -ne 0 -or $remote.Output.Trim() -cne $Commit) { Write-SgInstallerWarning 'Fetched Flutter baseline did not match the validated commit; the existing managed SDK was preserved.'; return $false }
    if ($previousCommit -ceq $Commit) {
        $checkoutCurrent = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.checkout' -Label 'Naming the Flutter stable SDK branch' -File $GitPath -Arguments @('-C',$resolvedRoot,'checkout','-B','stable',$Commit) -TimeoutSeconds 120
        if ($checkoutCurrent.TimedOut -or $checkoutCurrent.ExitCode -ne 0) { return $false }
        [void](Invoke-SgBoundedProcess -File $GitPath -Arguments @('-C',$resolvedRoot,'branch','--set-upstream-to=origin/shipglows-stable','stable') -TimeoutSeconds 30)
        return $true
    }

    $checkout = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.checkout' -Label 'Activating Flutter stable SDK' -File $GitPath -Arguments @('-C',$resolvedRoot,'checkout','-B','stable',$Commit) -TimeoutSeconds 120
    if (-not $checkout.TimedOut -and $checkout.ExitCode -eq 0) {
        [void](Invoke-SgBoundedProcess -File $GitPath -Arguments @('-C',$resolvedRoot,'branch','--set-upstream-to=origin/shipglows-stable','stable') -TimeoutSeconds 30)
        $updatedState = Get-SgFlutterInstallState -FlutterRoot $resolvedRoot
        if ($updatedState.Status -eq 'ready') { return $true }
    }

    $rollback = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.rollback' -Label 'Restoring the previous Flutter SDK revision' -File $GitPath -Arguments @('-C',$resolvedRoot,'checkout','-B','stable',$previousCommit) -TimeoutSeconds 120
    $rollbackState = if (-not $rollback.TimedOut -and $rollback.ExitCode -eq 0) { Get-SgFlutterInstallState -FlutterRoot $resolvedRoot } else { $null }
    if (-not $rollbackState -or $rollbackState.Status -ne 'ready') { throw 'Flutter stable convergence and automatic rollback both failed; the managed SDK needs inspection.' }
    Write-SgInstallerWarning 'Flutter stable convergence failed; restored the previous managed revision.'
    return $false
}

function Install-SgFlutter([string[]]$FlutterPaths, [string[]]$GitPaths) {
    $flutterDirectory = Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter'
    $existingFlutter = Get-SgToolPath 'flutter.bat' $FlutterPaths
    if ($existingFlutter) {
        $existingRoot = Split-Path (Split-Path $existingFlutter -Parent) -Parent
        $existingState = Get-SgFlutterInstallState -FlutterRoot $existingRoot
        if ($existingState.Status -eq 'ready') {
            if ([IO.Path]::GetFullPath($existingRoot).TrimEnd('\') -eq [IO.Path]::GetFullPath($flutterDirectory).TrimEnd('\')) {
                Add-SgUserPathEntry (Join-Path $existingRoot 'bin')
                $managedGit = Get-SgToolPath 'git.exe' $GitPaths
                if ($managedGit) {
                    $stableCommit = Resolve-SgFlutterStableCommit $managedGit
                    if ($stableCommit) {
                        try { [void](Set-SgManagedFlutterStableRevision $managedGit $existingRoot $stableCommit) }
                        catch { Write-SgInstallerWarning "Flutter stable convergence was safely skipped: $($_.Exception.Message)" }
                    }
                    else { Write-SgInstallerWarning 'Flutter stable commit could not be resolved; the existing managed SDK was preserved.' }
                    $existingState = Get-SgFlutterInstallState -FlutterRoot $existingRoot
                } else { Write-SgInstallerWarning 'Git is unavailable; the existing managed Flutter SDK could not be checked for a stable update.' }
            }
            if ($existingState.Status -ne 'ready') { Write-SgInstallerWarning 'Flutter/Dart validation failed after stable convergence.'; return $false }
            $configured = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.configure' -Label 'Configuring Flutter web, Android, and Windows targets' -File $existingState.FlutterPath -Arguments @('config','--enable-web','--enable-android','--enable-windows-desktop') -TimeoutSeconds 90
            if ($configured.TimedOut -or $configured.ExitCode -ne 0) { Write-SgInstallerWarning 'Flutter platform configuration failed or timed out.'; return $false }
            Write-Host "Using validated existing Flutter/Dart SDK without changing its location: $existingRoot" -ForegroundColor Green
            return $true
        }
    }
    $git = Get-SgToolPath 'git.exe' $GitPaths
    if (-not $git) { Write-SgInstallerWarning 'Flutter could not be installed because Git is unavailable.'; return $false }
    $state = Get-SgFlutterInstallState -FlutterRoot $flutterDirectory
    if ($state.Status -eq 'partial') { [void](Move-SgManagedPartialDirectory $flutterDirectory); $state = Get-SgFlutterInstallState -FlutterRoot $flutterDirectory }
    if ($state.Status -eq 'absent') {
        $commit = Resolve-SgFlutterStableCommit $git
        if (-not $commit) { Write-SgInstallerWarning 'Flutter stable commit could not be resolved and proven; installation is pending.'; return $false }
        New-Item -ItemType Directory -Path $flutterDirectory | Out-Null
        foreach ($step in @(
            @('init'),
            @('remote','add','origin','https://github.com/flutter/flutter.git'),
            @('fetch','--depth','1','origin',("+{0}:refs/remotes/origin/shipglows-stable" -f $commit)),
            @('checkout','-B','stable',$commit),
            @('branch','--set-upstream-to=origin/shipglows-stable','stable')
        )) {
            $arguments = @('-C',$flutterDirectory) + $step
            $result = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.clone' -Label 'Installing Flutter stable SDK' -File $git -Arguments $arguments -TimeoutSeconds 600
            if ($result.TimedOut -or $result.ExitCode -ne 0) { [void](Move-SgManagedPartialDirectory $flutterDirectory); Write-SgInstallerWarning 'Flutter resolved-commit installation failed or timed out.'; return $false }
        }
    }
    $state = Get-SgFlutterInstallState -FlutterRoot $flutterDirectory
    if ($state.Status -ne 'ready') { Write-SgInstallerWarning 'Flutter/Dart executable validation failed after installation.'; return $false }
    Add-SgUserPathEntry (Join-Path $flutterDirectory 'bin')
    $configured = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.configure' -Label 'Configuring Flutter web, Android, and Windows targets' -File $state.FlutterPath -Arguments @('config','--enable-web','--enable-android','--enable-windows-desktop') -TimeoutSeconds 90
    if ($configured.TimedOut -or $configured.ExitCode -ne 0) { Write-SgInstallerWarning 'Flutter platform configuration failed or timed out.'; return $false }
    Write-Host 'Flutter SDK resolved to a concrete stable commit; Flutter and Dart versions are valid.' -ForegroundColor Green
    return $true
}

function Install-SgJdk17 {
    $jdkRoot = Join-Path $env:LOCALAPPDATA 'ShipGlows\jdk17'
    $javaCommand = Get-SgToolPath 'java.exe' @()
    $existing = Resolve-SgExistingJdk17 -JavaHome $env:JAVA_HOME -JavaCommand $javaCommand
    if ($existing.Ready) {
        if ($existing.Home.Equals($jdkRoot,[StringComparison]::OrdinalIgnoreCase)) { [Environment]::SetEnvironmentVariable('JAVA_HOME',$jdkRoot,'User'); $env:JAVA_HOME=$jdkRoot; Add-SgUserPathEntry (Join-Path $jdkRoot 'bin') }
        else {
            try { Set-SgResolvedToolProcessEnvironment -JdkHome $existing.Home }
            catch { Write-SgInstallerWarning "Existing JDK 17 is valid but the child-process environment could not be normalized: $($_.Exception.Message)"; return '' }
            Write-Host "Using validated existing JDK 17; JAVA_HOME was normalized for this installer and its children only: $($existing.Home)" -ForegroundColor Green
        }
        return $existing.JavaPath
    }
    $java = Join-Path $jdkRoot 'bin\java.exe'
    $check = if (Test-Path -LiteralPath $java -PathType Leaf) { Invoke-SgBoundedProcess $java @('-version') 30 } else { $null }
    if (-not $check -or $check.TimedOut -or $check.ExitCode -ne 0 -or $check.Output -notmatch '(?i)(openjdk|java).*\b17\b') {
        if (Test-Path -LiteralPath $jdkRoot) { [void](Move-SgManagedPartialDirectory $jdkRoot) }
        $apiUrl = 'https://api.adoptium.net/v3/assets/latest/17/hotspot?architecture=x64&heap_size=normal&image_type=jdk&jvm_impl=hotspot&os=windows&vendor=eclipse'
        $assets = Invoke-RestMethod -UseBasicParsing -Uri $apiUrl -TimeoutSec 60
        $package = Resolve-SgAdoptiumJdkPackage (@($assets)[0])
        $archive = Join-Path ([IO.Path]::GetTempPath()) ("sg-jdk-$([guid]::NewGuid().ToString('N')).zip")
        $staging = "$jdkRoot.staging-$([guid]::NewGuid().ToString('N'))"
        try {
            Save-SgVerifiedDownload $package.Url $package.Sha256 $archive
            $extractedRoot = Expand-SgVerifiedZip -ArchivePath $archive -DestinationPath $staging -ExpectedRelativePath 'bin\java.exe'
            Move-Item -LiteralPath $extractedRoot -Destination $jdkRoot
        } finally {
            if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }
            if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
        }
    }
    $check = Invoke-SgBoundedProcess $java @('-version') 30
    if ($check.TimedOut -or $check.ExitCode -ne 0 -or $check.Output -notmatch '(?i)(openjdk|java).*\b17\b') { throw 'JDK 17 executable validation failed.' }
    [Environment]::SetEnvironmentVariable('JAVA_HOME',$jdkRoot,'User'); $env:JAVA_HOME=$jdkRoot; Add-SgUserPathEntry (Join-Path $jdkRoot 'bin')
    return $java
}

function Install-SgAndroidCommandLineTools([string]$SdkRoot) {
    $sdkManager = Join-Path $SdkRoot 'cmdline-tools\latest\bin\sdkmanager.bat'
    if (Test-Path -LiteralPath $sdkManager -PathType Leaf) {
        $check = Invoke-SgBoundedProcess $sdkManager @('--version') 30
        if (-not $check.TimedOut -and $check.ExitCode -eq 0 -and $check.Output -match '\d+') { return $sdkManager }
        [void](Move-SgManagedPartialDirectory (Join-Path $SdkRoot 'cmdline-tools\latest'))
    }
    if ([Console]::IsInputRedirected) { Write-SgInstallerWarning 'Android command-line tools pending: license confirmation requires an interactive terminal.'; return '' }
    Write-Host 'Review the official Android SDK terms: https://developer.android.com/studio/terms' -ForegroundColor Yellow
    $license = (Read-SgVisibleInstallerChoice -Interactive $interactive -Prompt 'Accept the Android SDK terms to download the official command-line tools? [y/N]' -OperationId 'input.android-terms' -Label 'Android SDK terms consent').ToLowerInvariant()
    if ($license -notin @('y','yes')) { Write-SgInstallerWarning 'Android command-line tools and licenses remain pending by user choice.'; return '' }
    Write-Host 'Resolving the official Android command-line tools package and SHA-256...' -ForegroundColor Yellow
    $repositoryUrl = 'https://dl.google.com/android/repository/repository2-3.xml'
    $repository = [xml](Invoke-WebRequest -UseBasicParsing -Uri $repositoryUrl -TimeoutSec 60).Content
    $downloadPage = (Invoke-WebRequest -UseBasicParsing -Uri 'https://developer.android.com/studio?hl=en' -TimeoutSec 60).Content
    $package = Resolve-SgAndroidCommandLineToolsPackage -RepositoryXml $repository -OfficialDownloadHtml $downloadPage
    $sizeMb = [math]::Ceiling([double]$package.SizeBytes / 1MB)
    Write-Host "Downloading Android command-line tools $($package.Version) ($sizeMb MB)..." -ForegroundColor Yellow
    $archive = Join-Path ([IO.Path]::GetTempPath()) ("sg-android-tools-$([guid]::NewGuid().ToString('N')).zip")
    $staging = Join-Path ([IO.Path]::GetTempPath()) ("sg-android-tools-$([guid]::NewGuid().ToString('N'))")
    try {
        Save-SgVerifiedDownload $package.Url $package.Sha256 $archive
        Write-Host 'Android command-line tools SHA-256 verified. Extracting the archive...' -ForegroundColor Yellow
        $toolRoot = Expand-SgVerifiedZip -ArchivePath $archive -DestinationPath $staging -ExpectedRelativePath 'bin\sdkmanager.bat'
        New-Item -ItemType Directory -Path (Split-Path (Join-Path $SdkRoot 'cmdline-tools\latest') -Parent) -Force | Out-Null
        Move-Item -LiteralPath $toolRoot -Destination (Join-Path $SdkRoot 'cmdline-tools\latest')
    } finally {
        if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }
        if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
    }
    $check = Invoke-SgBoundedProcess $sdkManager @('--version') 30
    if ($check.TimedOut -or $check.ExitCode -ne 0 -or $check.Output -notmatch '\d+') { throw 'Android sdkmanager validation failed.' }
    Write-Host 'Android command-line tools installed and executable validation passed.' -ForegroundColor Green
    return $sdkManager
}

function Get-SgHypervisorEvidence {
    try {
        $computer = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1
        return Test-SgWindowsHypervisorEvidence ([bool]$computer.HypervisorPresent) ([bool]$cpu.VirtualizationFirmwareEnabled) ([bool]$cpu.VMMonitorModeExtensions) ([bool]$cpu.SecondLevelAddressTranslationExtensions)
    } catch { return $false }
}

function Install-SgAndroidToolchain([bool]$FlutterReady, [string[]]$FlutterPaths, [bool]$TauriRequired = $false) {
    if (-not $FlutterReady -and -not $TauriRequired) { Write-SgInstallerWarning 'Android setup is pending because no Flutter or Tauri Android consumer was detected.'; return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false; SdkRoot=''; NdkReady=$false } }
    if (-not (Test-SgSupportedAndroidArchitecture)) { Write-SgInstallerWarning 'Android setup is pending: automatic Windows provisioning currently requires an x64 operating system. No Android package was downloaded.'; return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false } }
    $interactive = -not [Console]::IsInputRedirected
    $java = Install-SgJdk17
    if (-not $java) { return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false } }
    $managedSdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
    $existingSdk = Resolve-SgExistingAndroidSdk -CandidateRoots @($env:ANDROID_HOME,$env:ANDROID_SDK_ROOT,$managedSdkRoot) -SdkManagerCommand (Get-SgToolPath 'sdkmanager.bat' @())
    $managedSdk = -not $existingSdk.Ready -or ($existingSdk.Root -and $existingSdk.Root.Equals($managedSdkRoot,[StringComparison]::OrdinalIgnoreCase))
    $sdkRoot = if ($existingSdk.Ready) { $existingSdk.Root } else { $managedSdkRoot }
    $sdkManager = if ($existingSdk.Ready) { if (-not $managedSdk) { Write-Host "Using validated existing Android SDK; Android homes are normalized for this installer and its children only, without persistent environment or PATH changes: $sdkRoot" -ForegroundColor Green }; $existingSdk.SdkManagerPath } else { Install-SgAndroidCommandLineTools $sdkRoot }
    if ($existingSdk.Ready -and -not $managedSdk) {
        try { Set-SgResolvedToolProcessEnvironment -SdkRoot $sdkRoot }
        catch { Write-SgInstallerWarning "Existing Android SDK is valid but the child-process environment could not be normalized: $($_.Exception.Message)"; return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false } }
    }
    if ($managedSdk -and $sdkManager) {
        [Environment]::SetEnvironmentVariable('ANDROID_HOME',$sdkRoot,'User'); [Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT',$sdkRoot,'User'); $env:ANDROID_HOME=$sdkRoot; $env:ANDROID_SDK_ROOT=$sdkRoot
        foreach ($path in @((Join-Path $sdkRoot 'platform-tools'),(Join-Path $sdkRoot 'cmdline-tools\latest\bin'),(Join-Path $sdkRoot 'emulator'))) { Add-SgUserPathEntry $path }
    }
    if (-not $sdkManager) { return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false } }
    $licenseCheck = Invoke-SgBoundedProcess -File $sdkManager -Arguments @('--licenses') -TimeoutSeconds 30 -InputText 'n'
    $licensesReady = Test-SgAndroidLicenseResult $licenseCheck
    if (-not $licensesReady -and -not $interactive) { Write-SgInstallerWarning 'Android pending: run sdkmanager --licenses interactively; no license was accepted automatically.'; return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false } }
    if (-not $licensesReady) {
        Write-Host 'sdkmanager now presents every official Android SDK license. Accept or refuse each license yourself.' -ForegroundColor Yellow
        [void](Invoke-SgInteractiveBoundedProcess $sdkManager @('--licenses') 600)
        $licenseCheck = Invoke-SgBoundedProcess -File $sdkManager -Arguments @('--licenses') -TimeoutSeconds 30 -InputText 'n'
        $licensesReady = Test-SgAndroidLicenseResult $licenseCheck
    }
    if (-not $licensesReady) { Write-SgInstallerWarning 'Android SDK licenses are refused or incomplete; essential packages remain pending.'; return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false } }
    $coordinates = Get-SgAndroidCoordinates
    $essentialPackages = @('platform-tools',$coordinates.PlatformPackage,$coordinates.BuildToolsPackage)
    $tauriBaseline = Get-SgTauriAndroidBaseline
    if ($TauriRequired) { $essentialPackages += "ndk;$($tauriBaseline.NdkVersion)" }
    $essential = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.android.essential' -Label 'Installing Android platform, build tools, and required native components' -File $sdkManager -Arguments $essentialPackages -TimeoutSeconds 1800
    if ($essential.TimedOut -or $essential.ExitCode -ne 0) { Write-SgInstallerWarning 'Essential Android SDK package installation failed or timed out.' }
    $ndkRoot = Join-Path $sdkRoot "ndk\$($tauriBaseline.NdkVersion)"
    $ndkReady = Test-Path -LiteralPath (Join-Path $ndkRoot 'source.properties') -PathType Leaf
    if ($TauriRequired -and $ndkReady) {
        [Environment]::SetEnvironmentVariable('NDK_HOME',$ndkRoot,'User')
        [Environment]::SetEnvironmentVariable('ANDROID_NDK_HOME',$ndkRoot,'User')
        $env:NDK_HOME=$ndkRoot; $env:ANDROID_NDK_HOME=$ndkRoot
    } elseif ($TauriRequired) { Write-SgInstallerWarning "Tauri Android NDK $($tauriBaseline.NdkVersion) remains pending." }
    $adb = Join-Path $sdkRoot 'platform-tools\adb.exe'
    $emulatorPlan = Get-SgEmulatorProvisionPlan
    $emulatorCandidate = Join-Path $sdkRoot 'emulator\emulator.exe'
    $emulatorState = Get-SgAndroidEmulatorProvisionState -SdkRoot $sdkRoot -EmulatorPath $emulatorCandidate -ImagePackage $emulatorPlan.Packages[1] -AvdName $emulatorPlan.AvdName
    $emulatorSupported = Get-SgHypervisorEvidence
    if ($emulatorState.Complete) {
        Write-Host "Android emulator and $($emulatorPlan.AvdName) are already installed; skipping the emulator question." -ForegroundColor Green
    } elseif ($interactive -and -not $emulatorSupported) {
        Write-SgInstallerWarning 'Android emulator hardware acceleration is not proven on this machine. You can still install it, but startup may fail or software emulation may be very slow.'
    }
    $emulatorPrompt = if ($emulatorState.EmulatorInstalled -or $emulatorState.ImageInstalled -or $emulatorState.AvdReady) { 'Repair the Android emulator and ShipGlows_API_36 now? [y/N]' } else { 'Install the Android emulator and create ShipGlows_API_36 now? [y/N]' }
    $choice = Read-SgVisibleInstallerChoice -Interactive ($interactive -and -not $emulatorState.Complete) -Prompt $emulatorPrompt -OperationId 'input.android-emulator' -Label 'Android emulator choice'
    $plan = Get-SgAndroidInstallPlan -Interactive $interactive -EmulatorSupported $emulatorSupported -EmulatorChoice $choice -EmulatorReady $emulatorState.Complete
    $emulator = if (Test-Path -LiteralPath $emulatorCandidate -PathType Leaf) { $emulatorCandidate } else { '' }
    $emulatorAccelerationReady = $false
    $avdReady = $emulatorState.Complete
    if ($plan.InstallEmulator) {
        Write-Host 'Downloading the Android emulator and Android 36 system image. sdkmanager may remain silent during this several-gigabyte bounded download.' -ForegroundColor Yellow
        $emulatorInstallSucceeded = Invoke-SgInteractiveBoundedProcess $sdkManager $emulatorPlan.Packages 1800
        $emulator = $emulatorCandidate
        if ($emulatorInstallSucceeded -and (Test-Path -LiteralPath $emulator -PathType Leaf)) {
            $avdManager = Join-Path (Split-Path $sdkManager -Parent) 'avdmanager.bat'
            $image = $emulatorPlan.Packages[1]
            $list = Invoke-SgBoundedProcess $emulator @('-list-avds') 30
            $avdPattern = "(?m)^$([regex]::Escape($emulatorPlan.AvdName))\r?$"
            if ($list.Output -notmatch $avdPattern) {
                $create = Invoke-SgVisibleBoundedProcess -OperationId 'sdk.android.avd' -Label "Creating Android virtual device $($emulatorPlan.AvdName)" -File $avdManager -Arguments @('create','avd','--name',$emulatorPlan.AvdName,'--package',$image,'--device',$emulatorPlan.Device) -TimeoutSeconds 120 -InputText 'no'
                if ($create.TimedOut -or $create.ExitCode -ne 0) { Write-SgInstallerWarning 'Emulator packages installed but AVD creation failed or timed out.' }
                $list = Invoke-SgBoundedProcess $emulator @('-list-avds') 30
            }
            if ($list.Output -match $avdPattern) {
                $avdReady = $true
                Write-Host "Android virtual device ready: $($emulatorPlan.AvdName)" -ForegroundColor Green
                $emulatorAccelerationReady = Test-SgAndroidAcceleration $emulator
                if (-not $emulatorAccelerationReady) {
                    Write-SgInstallerWarning "The AVD is installed, but hardware acceleration remains unavailable. A diagnostic-only software attempt can use: emulator -avd $($emulatorPlan.AvdName) -accel off -gpu software. It may be unusably slow or fail to boot."
                }
            } else { Write-SgInstallerWarning 'Emulator packages installed but AVD verification is pending.' }
        } else {
            Write-SgInstallerWarning 'Android emulator package installation failed or timed out.'
            $emulator = if (Test-Path -LiteralPath $emulatorCandidate -PathType Leaf) { $emulatorCandidate } else { '' }
        }
    }
    $emulatorState = Get-SgAndroidEmulatorProvisionState -SdkRoot $sdkRoot -EmulatorPath $emulatorCandidate -ImagePackage $emulatorPlan.Packages[1] -AvdName $emulatorPlan.AvdName
    $emulator = if ($emulatorState.EmulatorInstalled) { $emulatorCandidate } else { '' }
    $avdReady = $emulatorState.Complete
    if ($avdReady -and -not $emulatorAccelerationReady) { $emulatorAccelerationReady = Test-SgAndroidAcceleration $emulator }
    if ($plan.PhysicalDeviceAlternative -or ($plan.InstallEmulator -and -not $emulatorAccelerationReady)) { Write-Host 'Android alternative: connect a real phone with USB debugging enabled, then run flutter devices.' -ForegroundColor Yellow }
    $developerModeReady = Test-SgWindowsDeveloperMode
    if (-not $developerModeReady) {
        Write-Host 'Windows Developer Mode is off. It can be required for Flutter plugins that use symbolic links; it does not provide Android emulator acceleration.' -ForegroundColor Yellow
        $developerChoice = Read-SgVisibleInstallerChoice -Interactive ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) -Prompt 'Open the official Windows Developer Mode settings now? [y/N]' -OperationId 'input.developer-mode' -Label 'Windows Developer Mode choice'
        $developerPlan = Get-SgDeveloperModeGuidancePlan -Interactive ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) -DeveloperModeReady $false -Choice $developerChoice
        if ($developerPlan.OpenSettings) { Start-Process $developerPlan.SettingsUri }
    }
    $flutterPath = Get-SgToolPath 'flutter.bat' $FlutterPaths
    $dartPath = if ($flutterPath) { Join-Path (Split-Path $flutterPath -Parent) 'dart.bat' } else { '' }
    $diagnostic = if ($flutterPath) {
        $diagnosticRunner = {
            param($File,$Arguments,$TimeoutSeconds)
            $joined = $Arguments -join ' '
            if ($joined -eq 'doctor -v') { return Invoke-SgVisibleBoundedProcess -OperationId 'diagnostic.flutter-doctor' -Label 'Checking Flutter and Android readiness' -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds }
            if ($joined -eq 'devices') { return Invoke-SgVisibleBoundedProcess -OperationId 'diagnostic.flutter-devices' -Label 'Checking available Flutter devices' -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds }
            return Invoke-SgBoundedProcess -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds
        }
        Get-SgFlutterAndroidDiagnostic -FlutterPath $flutterPath -DartPath $dartPath -JavaPath $java -SdkManagerPath $sdkManager -AdbPath $adb -EmulatorPath $emulator -Runner $diagnosticRunner
    } else {
        $sdkReady = -not $essential.TimedOut -and $essential.ExitCode -eq 0 -and (Test-Path -LiteralPath $adb -PathType Leaf)
        [pscustomobject]@{ ToolchainReady=$sdkReady; LicensesReady=$licensesReady; DeviceReady=$false; TimedOut=$false; Reason=if($sdkReady){'Android host toolchain is ready; device proof remains separate.'}else{'Android SDK provisioning is incomplete.'}; DoctorOutput=''; DevicesOutput='' }
    }
    $diagnostic | Add-Member -NotePropertyName AvdReady -NotePropertyValue $avdReady -Force
    $diagnostic | Add-Member -NotePropertyName EmulatorAccelerationReady -NotePropertyValue $emulatorAccelerationReady -Force
    $diagnostic | Add-Member -NotePropertyName SdkRoot -NotePropertyValue $sdkRoot -Force
    $diagnostic | Add-Member -NotePropertyName NdkReady -NotePropertyValue $ndkReady -Force
    Write-Host "Android readiness: toolchain=$($diagnostic.ToolchainReady); licenses=$($diagnostic.LicensesReady); device=$($diagnostic.DeviceReady)" -ForegroundColor Cyan
    if (-not $diagnostic.ToolchainReady -or -not $diagnostic.LicensesReady -or -not $diagnostic.DeviceReady) {
        $detail = Get-SgInstallerDiagnosticExcerpt @($diagnostic.DoctorOutput,$diagnostic.DevicesOutput)
        $detailSuffix = if ($detail) { " Detail: $detail" } else { '' }
        Write-SgInstallerWarning "Flutter Android diagnostic: $($diagnostic.Reason)$detailSuffix"
    }
    return $diagnostic
}

function Install-SgOfficialMise {
    $mise = Resolve-SgTrustedMisePath
    if ($mise) { return $mise }
    $winget = Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $winget) { Write-SgInstallerWarning 'ShipGlows toolbox pending: WinGet is unavailable, so the official mise package cannot be acquired.'; return '' }
    $installed = Invoke-SgVisibleBoundedProcess -OperationId 'tool.mise' -Label 'Installing the official mise tool manager' -File $winget.Source -Arguments @('install','--id','jdx.mise','--exact','--source','winget','--accept-package-agreements','--accept-source-agreements','--silent','--disable-interactivity') -TimeoutSeconds 900
    Update-SgProcessPath
    $mise = Resolve-SgTrustedMisePath
    if (-not $mise) {
        $detail = if ($installed.TimedOut) { 'timed out' } elseif ($installed.ExitCode -ne 0) { "returned exit code $($installed.ExitCode)" } else { 'completed without a trusted executable' }
        Write-SgInstallerWarning "ShipGlows toolbox pending: WinGet $detail and the final trusted mise executable could not be proven."
    } elseif ($installed.TimedOut -or $installed.ExitCode -ne 0) {
        Write-Host 'WinGet returned an ambiguous result, but the final trusted mise executable is installed and validated.' -ForegroundColor Green
    }
    return $mise
}

function Install-SgOfficialMiseForTauri { return Install-SgOfficialMise }

function Invoke-SgManagedTauriMise {
    param([string]$MisePath, [string]$ToolchainRoot, [string[]]$Arguments, [int]$TimeoutSeconds = 120, [switch]$Visible, [string]$OperationId = 'tool.rust.tauri', [string]$Label = 'Installing the validated Rust toolchain')
    $runner = if($Visible){
        $visibleRunner = { param($file,$arguments,$timeout) Invoke-SgVisibleBoundedProcess -OperationId $OperationId -Label $Label -File $file -Arguments $arguments -TimeoutSeconds $timeout }.GetNewClosure()
        $visibleRunner
    }else{
        { param($file,$arguments,$timeout) Invoke-SgBoundedProcess $file $arguments $timeout }
    }
    return Invoke-SgIsolatedTauriMise -MisePath $MisePath -ToolchainRoot $ToolchainRoot -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds -Runner $runner
}

function Test-SgTauriRustToolchain {
    param([string]$MisePath, [string]$ToolchainRoot, $Baseline = (Get-SgTauriAndroidBaseline))
    if (-not $MisePath -or -not (Test-Path -LiteralPath (Join-Path $ToolchainRoot 'mise.toml') -PathType Leaf)) { return $false }
    $coordinate="rust@$($Baseline.RustToolchainVersion)"
    $rust = Invoke-SgManagedTauriMise $MisePath $ToolchainRoot @('exec',$coordinate,'--','rustc','--version') 60
    $cargo = Invoke-SgManagedTauriMise $MisePath $ToolchainRoot @('exec',$coordinate,'--','cargo','--version') 60
    $targets = Invoke-SgManagedTauriMise $MisePath $ToolchainRoot @('exec',$coordinate,'--','rustup','target','list','--installed') 60
    if ($rust.TimedOut -or $rust.ExitCode -ne 0 -or $rust.Output -notmatch "(?m)^rustc $([regex]::Escape([string]$Baseline.RustToolchainVersion))\b" -or $cargo.TimedOut -or $cargo.ExitCode -ne 0) { return $false }
    return @($Baseline.RustTargets | Where-Object { $targets.Output -notmatch "(?m)^$([regex]::Escape([string]$_))\r?$" }).Count -eq 0
}

function Install-SgTauriRustWrappers {
    param([string]$MisePath, [string]$ToolchainRoot)
    if (-not $MisePath -or -not (Test-Path -LiteralPath $MisePath -PathType Leaf)) { return $false }
    foreach ($command in @('cargo','rustc','rustup')) {
        $wrapper = Join-Path $runtimeDir "$command.cmd"
        $content = Get-SgTauriRustWrapperContent -MisePath $MisePath -ToolchainRoot $ToolchainRoot -Command $command
        if (-not (Test-Path -LiteralPath $wrapper -PathType Leaf) -or [IO.File]::ReadAllText($wrapper) -cne $content) {
            [IO.File]::WriteAllText($wrapper,$content,[Text.Encoding]::ASCII)
        }
    }
    return $true
}

function Install-SgTauriAndroidToolchain {
    param($ProjectState, [bool]$InstallApproved, [pscustomobject]$AndroidInfo)
    $baseline = Get-SgTauriAndroidBaseline
    if (-not $ProjectState.IsTauri) { return [pscustomobject]@{ Detected=$false; HostReady=$false; RustReady=$false; NdkReady=$false; ProjectStatus='not_applicable'; Baseline=$baseline } }
    $root = Join-Path $env:LOCALAPPDATA 'ShipGlows\Toolchains\tauri-android'
    $configPath = Join-Path $root 'mise.toml'
    $mise = Resolve-SgTrustedMisePath
    $rustReady = Test-SgTauriRustToolchain $mise $root $baseline
    if ($InstallApproved -and -not $rustReady) {
        if (-not $mise) { $mise = Install-SgOfficialMise }
        if ($mise) {
            New-Item -ItemType Directory -Path $root -Force | Out-Null
            $expected = Get-SgTauriMiseConfig $baseline
            if (-not (Test-Path -LiteralPath $configPath -PathType Leaf) -or [IO.File]::ReadAllText($configPath).Replace("`r`n","`n") -cne $expected.Replace("`r`n","`n")) {
                $temporary = "$configPath.tmp-$([guid]::NewGuid().ToString('N'))"
                [IO.File]::WriteAllText($temporary,$expected,[Text.UTF8Encoding]::new($false)); Move-SgAtomicReplace $temporary $configPath
            }
            $install = Invoke-SgManagedTauriMise $mise $root @('install',"rust@$($baseline.RustToolchainVersion)") 1800 -Visible
            if ($install.TimedOut -or $install.ExitCode -ne 0) { Write-SgInstallerWarning 'Validated Tauri Rust installation failed or timed out.' }
            $targetAdd = Invoke-SgManagedTauriMise $mise $root (Get-SgTauriRustTargetAddArguments -Baseline $baseline) 1800 -Visible -OperationId 'tool.rust-targets.tauri' -Label 'Installing the validated Rust Android targets'
            if (-not (Test-SgTauriRustTargetAddResult $targetAdd)) { Write-SgInstallerWarning 'Validated Tauri Rust Android target installation failed or timed out.' }
            $rustReady = Test-SgTauriRustToolchain $mise $root $baseline
        }
    }
    if ($rustReady) { [void](Install-SgTauriRustWrappers $mise $root) }
    $ndkReady = $AndroidInfo.PSObject.Properties['NdkReady'] -and [bool]$AndroidInfo.NdkReady
    [pscustomobject]@{ Detected=$true; HostReady=$rustReady -and $ndkReady; RustReady=$rustReady; NdkReady=$ndkReady; ProjectStatus=[string]$ProjectState.Status; Baseline=$baseline; ToolchainRoot=$root }
}

function Invoke-SgTauriMigrationHandoff {
    param($ProjectState, [bool]$CodexReady, [string[]]$CodexPaths)
    if (-not $ProjectState.IsTauri -or $ProjectState.Status -ne 'migration_required') { return $false }
    $handoff = New-SgTauriAndroidMigrationHandoff $ProjectState
    Write-Host "Tauri Android migration required for: $($handoff.ProjectRoot)" -ForegroundColor Yellow
    foreach($difference in @($handoff.Differences)){Write-Host "  - $difference" -ForegroundColor DarkGray}
    if (-not $CodexReady -or [Console]::IsInputRedirected) { Write-SgInstallerWarning 'Tauri migration handoff is ready, but Codex was not opened. The project was not modified.'; return $false }
    $choice = Read-SgVisibleInstallerChoice -Interactive $true -Prompt $handoff.Prompt -OperationId 'input.tauri-handoff' -Label 'Tauri migration handoff choice'
    $plan = Get-SgTauriAndroidHostPlan -TauriDetected $true -MiseReady $true -RustReady $true -NdkReady $true -MigrationRequired $true -Interactive $true -CodexReady $CodexReady -CodexChoice $choice
    if (-not $plan.OpenCodex) { Write-SgInstallerWarning 'Tauri migration was left as a handoff; the project was not modified.'; return $false }
    $codex = Get-SgToolPath 'codex.cmd' $CodexPaths
    if (-not $codex) { Write-SgInstallerWarning 'Codex could not be resolved for the Tauri migration handoff.'; return $false }
    $prompt = 'Migrate this Tauri Android project to the ShipGlows-validated baseline described in the handoff shown by the installer. Preserve product behavior, do not run tauri android init until you have inspected the project, and ask for approval before project mutations.'
    Write-Host 'Opening Codex in the Tauri project. The installer will continue when that Codex session exits.' -ForegroundColor Cyan
    return Invoke-SgInteractiveBoundedProcess $codex @('-C',$handoff.ProjectRoot,$prompt) 14400
}

function Get-SgCurrentWindowsIdeState {
    $androidStudioPaths = @(
        (Join-Path ([Environment]::GetFolderPath('ProgramFiles')) 'Android\Android Studio\bin\studio64.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Android Studio\bin\studio64.exe')
    )
    $androidStudio = Get-SgAndroidStudioState -CandidatePaths $androidStudioPaths
    $vsWhere = Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Microsoft Visual Studio\Installer\vswhere.exe'
    $visualStudio = Get-SgVisualStudioCppState -VsWherePath $vsWhere
    [pscustomobject]@{
        AndroidStudioReady = $androidStudio.Ready
        AndroidStudioPath = $androidStudio.Path
        VisualStudioInstalled = $visualStudio.Installed
        VisualStudioCppReady = $visualStudio.Ready
        VisualStudioInstallationPath = $visualStudio.InstallationPath
        FirebaseDeviceStreamingReady = $false
    }
}

function Invoke-SgWingetIdeInstall([string]$DisplayName, [string[]]$Arguments, [int]$TimeoutSeconds) {
    $winget = Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $winget) { Write-SgInstallerWarning "WinGet is unavailable; $DisplayName remains pending."; return $false }
    Write-Host "Installing $DisplayName. Progress is shown below; keep this window open." -ForegroundColor Cyan
    $ok = Invoke-SgInteractiveBoundedProcess -File $winget.Source -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds
    if (-not $ok) { Write-SgInstallerWarning "$DisplayName installation failed, was cancelled, or timed out." }
    Update-SgProcessPath
    return $ok
}

function Install-SgWindowsIdeToolchains([bool]$FlutterReady, [string[]]$FlutterPaths) {
    $state = Get-SgCurrentWindowsIdeState
    $interactive = -not [Console]::IsInputRedirected
    $initialPlan = Get-SgWindowsIdeInstallPlan -Interactive $interactive -AndroidStudioReady $state.AndroidStudioReady -VisualStudioCppReady $state.VisualStudioCppReady
    if ($initialPlan.Status -eq 'ready') {
        Write-Host 'Android Studio and Visual Studio Community C++ are already ready; skipping the IDE question.' -ForegroundColor Green
        return $state
    }
    $missingText = $initialPlan.Missing -join '; '
    Write-Host "Missing optional IDE toolchains: $missingText" -ForegroundColor Yellow
    Write-Host 'Android Studio provides the Android IDE and Firebase Device Streaming entry point. Visual Studio Community C++ compiles Flutter Windows desktop apps.' -ForegroundColor DarkGray
    if (-not $interactive) {
        Write-SgInstallerWarning 'Windows IDE bundle pending: rerun the full installer interactively; no multi-gigabyte IDE install was inferred.'
        return $state
    }
    $choice = Read-SgVisibleInstallerChoice -Interactive $interactive -Prompt 'Install the missing Windows IDE toolchains now? [y/N]' -OperationId 'input.windows-ide' -Label 'Windows IDE toolchain consent'
    $plan = Get-SgWindowsIdeInstallPlan -Interactive $true -AndroidStudioReady $state.AndroidStudioReady -VisualStudioCppReady $state.VisualStudioCppReady -Choice $choice
    if ($plan.Status -ne 'install') {
        Write-SgInstallerWarning 'Windows IDE bundle was declined; Android Studio and/or Flutter Windows compilation remain pending.'
        return $state
    }
    if ($plan.InstallAndroidStudio) {
        [void](Invoke-SgWingetIdeInstall 'Android Studio' @('install','--id','Google.AndroidStudio','--exact','--source','winget','--accept-package-agreements','--accept-source-agreements','--silent','--disable-interactivity') 3600)
    }
    if ($plan.InstallVisualStudioCpp) {
        if ($state.VisualStudioInstalled -and $state.VisualStudioInstallationPath) {
            $setup = Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Microsoft Visual Studio\Installer\setup.exe'
            if (Test-Path -LiteralPath $setup -PathType Leaf) {
                Write-Host 'Adding Desktop development with C++ to the existing Visual Studio Community installation. This can take a long time.' -ForegroundColor Cyan
                $modified = Invoke-SgInteractiveBoundedProcess -File $setup -Arguments @('modify','--installPath',$state.VisualStudioInstallationPath,'--add','Microsoft.VisualStudio.Workload.NativeDesktop','--includeRecommended','--passive','--norestart') -TimeoutSeconds 10800
                if (-not $modified) { Write-SgInstallerWarning 'Visual Studio C++ workload modification failed, was cancelled, or timed out.' }
            } else { Write-SgInstallerWarning 'Visual Studio Installer was not found; the C++ workload remains pending.' }
        } else {
            Write-Host 'Visual Studio Community with C++ is a large download and may request UAC. ShipGlows will not restart Windows automatically.' -ForegroundColor Yellow
            [void](Invoke-SgWingetIdeInstall 'Visual Studio Community with Desktop development with C++' @('install','--id','Microsoft.VisualStudio.2022.Community','--exact','--source','winget','--accept-package-agreements','--accept-source-agreements','--disable-interactivity','--override','--passive --wait --norestart --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended') 10800)
        }
    }
    $state = Get-SgCurrentWindowsIdeState
    if ($FlutterReady -and $state.VisualStudioCppReady) {
        $flutter = Get-SgToolPath 'flutter.bat' $FlutterPaths
        $config = if ($flutter) { Invoke-SgVisibleBoundedProcess -OperationId 'sdk.flutter.windows' -Label 'Configuring Flutter Windows desktop target' -File $flutter -Arguments @('config','--enable-windows-desktop') -TimeoutSeconds 60 } else { $null }
        if (-not $config -or $config.TimedOut -or $config.ExitCode -ne 0) { Write-SgInstallerWarning 'Flutter Windows desktop enablement could not be proven.' }
    }
    if (-not $state.AndroidStudioReady) { Write-SgInstallerWarning 'Android Studio remains pending.' }
    if (-not $state.VisualStudioCppReady) { Write-SgInstallerWarning 'Visual Studio Community with the native desktop C++ workload remains pending.' }
    if ($state.AndroidStudioReady) { Write-Host 'Android Studio is installed. Firebase Device Streaming still requires your own sign-in and Firebase project selection inside Android Studio.' -ForegroundColor Green }
    return $state
}

function Install-SgPlaywrightChromiumForAgents([bool]$AnyAgentReady, [string]$NpmPath, [string]$NpxPath) {
    if (-not $AnyAgentReady -or -not $NpmPath -or -not $NpxPath) { return [pscustomobject]@{ Ready=$false; Version=''; ChromiumPath='' } }
    try { $version = Resolve-SgNpmVersion $NpmPath '@playwright/mcp' }
    catch { Write-SgInstallerWarning 'Playwright MCP exact version resolution failed; no agent config was changed.'; return [pscustomobject]@{ Ready=$false; Version=''; ChromiumPath='' } }
    $managedRoot = Join-Path $env:LOCALAPPDATA "ShipGlows\node-tools\playwright-mcp-$version"
    $packageJson = Join-Path $managedRoot 'node_modules\@playwright\mcp\package.json'
    if (-not (Test-Path $packageJson -PathType Leaf)) {
        New-Item -ItemType Directory -Path $managedRoot -Force | Out-Null
        $packageInstall = Invoke-SgVisibleBoundedProcess -OperationId 'tool.playwright.mcp' -Label "Installing Playwright MCP $version" -File $NpmPath -Arguments @('install','--prefix',$managedRoot,'--no-save','--ignore-scripts','--registry=https://registry.npmjs.org/',"@playwright/mcp@$version") -TimeoutSeconds 600
        if ($packageInstall.TimedOut -or $packageInstall.ExitCode -ne 0) { Write-SgInstallerWarning 'Playwright MCP exact package installation failed.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    }
    $playwrightCommand = Join-Path $managedRoot 'node_modules\.bin\playwright.cmd'
    $browserMetadata = Join-Path $managedRoot 'node_modules\playwright-core\browsers.json'
    if (-not (Test-Path $playwrightCommand -PathType Leaf) -or -not (Test-Path $browserMetadata -PathType Leaf)) { Write-SgInstallerWarning 'Playwright MCP browser metadata is unavailable.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    $metadata = Get-Content -Raw $browserMetadata | ConvertFrom-Json
    $chromiumMetadata = @($metadata.browsers | Where-Object { $_.PSObject.Properties['name'] -and $_.name -eq 'chromium' } | Select-Object -First 1)
    $revision = if ($chromiumMetadata.Count -eq 1 -and $chromiumMetadata[0].PSObject.Properties['revision']) { [string]$chromiumMetadata[0].revision } else { '' }
    if ($revision -notmatch '^\d+$') { Write-SgInstallerWarning 'Playwright MCP Chromium revision is invalid.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    $install = Invoke-SgVisibleBoundedProcess -OperationId 'tool.playwright.mcp-browser' -Label 'Installing Playwright MCP Chromium' -File $playwrightCommand -Arguments @('install','chromium') -TimeoutSeconds 900
    $chromium = Get-SgPlaywrightChromiumExecutable -Revision $revision
    $chromiumPath = if ($chromium -is [IO.FileSystemInfo]) { $chromium.FullName } else { [string]$chromium }
    $chromiumCheck = if ($chromiumPath) { Invoke-SgBoundedProcess $chromiumPath @('--version') 30 } else { $null }
    if ($install.TimedOut -or $install.ExitCode -ne 0 -or -not $chromiumPath -or -not (Test-SgChromiumExecutableResult $chromiumPath $chromiumCheck)) { Write-SgInstallerWarning 'Playwright Chromium executable usability was not proven; Playwright MCP remains unconfigured.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    return [pscustomobject]@{ Ready=$true; Version=$version; Revision=$revision; ChromiumPath=[IO.Path]::GetFullPath($chromiumPath) }
}

function Read-SgProjectMcpState([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return [pscustomobject]@{ schemaVersion=1; entries=@() } }
    try {
        $state = [IO.File]::ReadAllText($Path) | ConvertFrom-Json -ErrorAction Stop
        if ($state.schemaVersion -ne 1 -or $null -eq $state.entries) { throw 'unsupported state' }
        return $state
    } catch { Write-SgInstallerWarning 'Project MCP state is invalid and was ignored; existing project configs remain protected.'; return [pscustomobject]@{ schemaVersion=1; entries=@() } }
}

function Write-SgProjectMcpState([string]$Path, [object[]]$Entries) {
    $directory = Split-Path $Path -Parent
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $content = ([ordered]@{ schemaVersion=1; entries=@($Entries | Sort-Object path) } | ConvertTo-Json -Depth 8) + [Environment]::NewLine
    $temp = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temp,$content,[Text.UTF8Encoding]::new($false))
        if (Test-Path -LiteralPath $Path -PathType Leaf) { Move-SgAtomicReplace $temp $Path } else { Move-Item -LiteralPath $temp -Destination $Path }
    } finally { if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force } }
}

function Add-SgProjectMcpGitExclude([string]$ProjectPath, [string]$ConfigPath) {
    $probe = [IO.Path]::GetFullPath($ProjectPath)
    $repoRoot = ''
    while ($probe) {
        if (Test-Path -LiteralPath (Join-Path $probe '.git')) { $repoRoot=$probe; break }
        $parent=Split-Path $probe -Parent
        if (-not $parent -or $parent -eq $probe) { break }
        $probe=$parent
    }
    if (-not $repoRoot) { return }
    $gitMetadata = Join-Path $repoRoot '.git'
    if (Test-Path -LiteralPath $gitMetadata -PathType Leaf) {
        $pointer=[IO.File]::ReadAllText($gitMetadata)
        if ($pointer -notmatch '^gitdir:\s*(.+)\s*$') { return }
        $gitMetadata=$matches[1].Trim()
        if (-not [IO.Path]::IsPathRooted($gitMetadata)) { $gitMetadata=Join-Path $repoRoot $gitMetadata }
    }
    $excludePath=Join-Path ([IO.Path]::GetFullPath($gitMetadata)) 'info\exclude'
    $repoPrefix=$repoRoot.TrimEnd('\')+'\'
    $fullConfig=[IO.Path]::GetFullPath($ConfigPath)
    if (-not $fullConfig.StartsWith($repoPrefix,[StringComparison]::OrdinalIgnoreCase)) { return }
    $pattern='/' + $fullConfig.Substring($repoPrefix.Length).Replace('\','/')
    $existing=if(Test-Path -LiteralPath $excludePath -PathType Leaf){[IO.File]::ReadAllText($excludePath)}else{''}
    if (@($existing -split '\r?\n') -contains $pattern) { return }
    New-Item -ItemType Directory -Path (Split-Path $excludePath -Parent) -Force | Out-Null
    $prefix=if($existing -and -not $existing.EndsWith("`n")){"`n"}else{''}
    [IO.File]::AppendAllText($excludePath,"$prefix$pattern`n",[Text.UTF8Encoding]::new($false))
}

function Remove-SgGlobalJsonMcpEntries([string]$Path, [string[]]$Names, [ValidateSet('top-level','opencode','kilo')][string]$Shape = 'top-level') {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
    try { $document=[IO.File]::ReadAllText($Path)|ConvertFrom-Json -ErrorAction Stop } catch { Write-SgInstallerWarning "Global MCP cleanup preserved invalid JSON: $Path"; return }
    $servers = if($Shape -eq 'top-level'){
        if($document.PSObject.Properties['mcpServers']){$document.mcpServers}else{$null}
    }elseif($Shape -eq 'opencode'){
        if($document.PSObject.Properties['mcp'] -and $document.mcp -and $document.mcp.PSObject.Properties['servers']){$document.mcp.servers}else{$null}
    }else{
        if($document.PSObject.Properties['mcp']){$document.mcp}else{$null}
    }
    if(-not $servers){return}
    $changed=$false
    foreach($name in $Names){if($servers.PSObject.Properties[$name]){$servers.PSObject.Properties.Remove($name);$changed=$true}}
    if(-not $changed){return}
    $content=($document|ConvertTo-Json -Depth 64)+[Environment]::NewLine
    $temp="$Path.$([guid]::NewGuid().ToString('N')).tmp"
    try{[IO.File]::WriteAllText($temp,$content,[Text.UTF8Encoding]::new($false));Move-SgAtomicReplace $temp $Path}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
}

function Remove-SgMaintainerGlobalMcpConfigs([hashtable]$AgentReady) {
    $names=@('dart','playwright','firebase','convex','clerk','supabase','vercel','github')
    if($AgentReady.Codex){$codex=Get-SgToolPath 'codex.cmd' $codexPaths;foreach($name in $names){$get=Invoke-SgBoundedProcess $codex @('mcp','get',$name,'--json') 30;if($get.ExitCode -eq 0){[void](Invoke-SgBoundedProcess $codex @('mcp','remove',$name) 30)}}}
    if($AgentReady.Claude){Remove-SgGlobalJsonMcpEntries (Join-Path $env:USERPROFILE '.claude.json') $names}
    if($AgentReady.Gemini){Remove-SgGlobalJsonMcpEntries (Join-Path $env:USERPROFILE '.gemini\settings.json') $names}
    if($AgentReady.OpenCode){$resolved=Resolve-SgAgentConfigPath OpenCode $env:USERPROFILE;Remove-SgGlobalJsonMcpEntries $resolved.Path $names opencode}
    if($AgentReady.Kilo){$resolved=Resolve-SgAgentConfigPath Kilo $env:USERPROFILE;Remove-SgGlobalJsonMcpEntries $resolved.Path $names kilo}
}

function Install-SgAgentMcpConfigs([hashtable]$AgentReady, [string]$DartPath, [string]$NpxPath, $Playwright, [string[]]$ProjectPaths, [hashtable]$ServiceVersions, [bool]$ReplaceExistingAgentConfigs = $false) {
    $results=@{}
    foreach($agentName in @('Codex','Claude','OpenCode','Kilo','Gemini')){$results[$agentName]=[pscustomobject]@{Installed=[bool]$AgentReady[$agentName];McpSummary=if($AgentReady[$agentName]){'pending'}else{'not applicable'};ReadyServers=@();PendingServers=@()}}
    if(-not $DartPath -or -not $NpxPath){Write-SgInstallerWarning 'Project MCP setup is pending because validated Dart or npx is unavailable.';return $results}
    if($ReplaceExistingAgentConfigs){Remove-SgMaintainerGlobalMcpConfigs $AgentReady}
    $statePath=Join-Path $env:LOCALAPPDATA 'ShipGlows\agent-mcp-project-state.json'
    $state=Read-SgProjectMcpState $statePath
    $nextEntries=New-Object Collections.Generic.List[object]
    $readyByAgent=@{};$pendingByAgent=@{}
    foreach($agentName in @('Codex','Claude','OpenCode','Kilo','Gemini')){$readyByAgent[$agentName]=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase);$pendingByAgent[$agentName]=[Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)}
    foreach($projectPath in @($ProjectPaths|Where-Object{$_}|Select-Object -Unique)){
        $needs=Get-SgProjectServiceNeeds -Workspace $projectPath
        $servers=@(Get-SgProjectMcpDefinitions -Needs $needs -Versions $ServiceVersions -DartPath $DartPath -NpxPath $NpxPath -Playwright $Playwright)
        foreach($agentName in @('Codex','Claude','OpenCode','Kilo','Gemini')){
            if(-not [bool]$AgentReady[$agentName]){continue}
            $configPlan=Get-SgProjectAgentMcpConfigPlan -Agent $agentName -ProjectPath $projectPath -Servers $servers
            $record=@($state.entries|Where-Object{[string]$_.path -eq [string]$configPlan.ConfigPath}|Select-Object -First 1)
            $recordedHash=if($record){[string]$record[0].sha256}else{''}
            $write=Write-SgManagedProjectConfig -ConfigPath $configPlan.ConfigPath -Content $configPlan.Content -RecordedHash $recordedHash -ReplaceExisting:$ReplaceExistingAgentConfigs
            if($write.Status -eq 'pending'){
                foreach($name in @($configPlan.ServerNames)){[void]$pendingByAgent[$agentName].Add($name)}
                Write-SgInstallerWarning "$agentName project MCP config was preserved pending: $($configPlan.ConfigPath)"
                if($record){$nextEntries.Add($record[0])}
            }else{
                foreach($name in @($configPlan.ServerNames)){[void]$readyByAgent[$agentName].Add($name)}
                Add-SgProjectMcpGitExclude $projectPath $configPlan.ConfigPath
                $nextEntries.Add([pscustomobject]@{path=[string]$configPlan.ConfigPath;sha256=[string]$write.ExpectedHash;agent=$agentName;project=[IO.Path]::GetFullPath($projectPath)})
            }
        }
    }
    Write-SgProjectMcpState $statePath $nextEntries.ToArray()
    foreach($agentName in @('Codex','Claude','OpenCode','Kilo','Gemini')){
        if(-not [bool]$AgentReady[$agentName]){continue}
        $ready=@($readyByAgent[$agentName]|Sort-Object);$pending=@($pendingByAgent[$agentName]|Sort-Object)
        $summary=if($pending.Count){"partial per project: ready $($ready -join ', '); pending $($pending -join ', ')"}else{"ready per project: $($ready -join ', ')"}
        $results[$agentName]=[pscustomobject]@{Installed=$true;McpSummary=$summary;ReadyServers=$ready;PendingServers=$pending}
    }
    return $results
}

function Install-SgManagedPlaywrightRuntimes([string]$NpmPath) {
    $empty=[pscustomobject]@{StableReady='no';StableVersion='not available';StableRevision='not available';StablePath='';BrowserPath='';AgentCliReady='no';AgentCliVersion='not available';AgentCliPath='';MotionReady='no'}
    if(-not $NpmPath){Write-SgInstallerWarning 'Managed Playwright runtimes are pending because npm is unavailable.';return $empty}
    try {
        $stableVersion=Resolve-SgNpmVersion $NpmPath 'playwright'
        $agentVersion=$stableVersion
        $root=Join-Path $env:LOCALAPPDATA 'ShipGlows\node-tools'
        $stableRoot=Join-Path $root "playwright-$stableVersion"
        foreach($install in @(@{Id='playwright';Name='Playwright';Root=$stableRoot;Package='playwright';Version=$stableVersion})){
            $packageJson=Join-Path (Join-Path $install.Root 'node_modules') (Join-Path $install.Package 'package.json')
            if(-not (Test-Path $packageJson -PathType Leaf)){
                New-Item -ItemType Directory -Path $install.Root -Force|Out-Null
                $result=Invoke-SgVisibleBoundedProcess -OperationId ("tool.node." + $install.Id) -Label ("Installing $($install.Name) $($install.Version)") -File $NpmPath -Arguments @('install','--prefix',$install.Root,'--no-save','--ignore-scripts','--registry=https://registry.npmjs.org/',"$($install.Package)@$($install.Version)") -TimeoutSeconds 600
                if($result.TimedOut -or $result.ExitCode -ne 0){throw "Exact $($install.Package) installation failed."}
            }
        }
        $stableCommand=Join-Path $stableRoot 'node_modules\.bin\playwright.cmd'
        $agentCommand=Join-Path $stableRoot 'playwright-cli.cmd'
        $browserMetadata=Join-Path $stableRoot 'node_modules\playwright-core\browsers.json'
        if(-not (Test-Path $stableCommand -PathType Leaf) -or -not (Test-Path $browserMetadata -PathType Leaf)){throw 'Managed Playwright command or browser metadata is missing.'}
        $agentWrapper="@echo off`r`n@call `"$stableCommand`" cli %*`r`n"
        if(-not (Test-Path $agentCommand -PathType Leaf)-or[IO.File]::ReadAllText($agentCommand)-cne $agentWrapper){[IO.File]::WriteAllText($agentCommand,$agentWrapper,[Text.Encoding]::ASCII)}
        $metadata=Get-Content -Raw $browserMetadata|ConvertFrom-Json
        $revision=[string](@($metadata.browsers|Where-Object name -eq 'chromium')[0].revision)
        if($revision -notmatch '^\d+$'){throw 'Managed Playwright Chromium revision is invalid.'}
        $browser=Join-Path $env:LOCALAPPDATA "ms-playwright\chromium-$revision\chrome-win64\chrome.exe"
        $browserProbe=Join-Path $env:LOCALAPPDATA "ms-playwright\chromium_headless_shell-$revision\chrome-headless-shell-win64\chrome-headless-shell.exe"
        if(-not (Test-Path $browser -PathType Leaf)){
            $installBrowser=Invoke-SgVisibleBoundedProcess -OperationId 'tool.playwright.browser' -Label 'Installing Playwright Chromium' -File $stableCommand -Arguments @('install','chromium') -TimeoutSeconds 900
            if($installBrowser.TimedOut -or $installBrowser.ExitCode -ne 0){throw 'Managed Playwright Chromium installation failed.'}
        }
        $agentBrowserInstall=Invoke-SgVisibleBoundedProcess -OperationId 'tool.playwright-agent.browser' -Label 'Verifying the bundled Playwright CLI browser' -File $agentCommand -Arguments @('install-browser','chromium') -TimeoutSeconds 900
        if($agentBrowserInstall.TimedOut -or $agentBrowserInstall.ExitCode -ne 0){throw 'Managed Playwright Agent CLI browser installation failed.'}
        $stableCheck=Invoke-SgBoundedProcess $stableCommand @('--version') 30
        $agentCheck=Invoke-SgBoundedProcess $agentCommand @('--version') 30
        $browserCheck=if((Test-Path $browser -PathType Leaf)-and(Test-Path $browserProbe -PathType Leaf)){Invoke-SgBoundedProcess $browserProbe @('--version') 30}else{$null}
        $stableReady=-not $stableCheck.TimedOut -and $stableCheck.ExitCode -eq 0 -and $stableCheck.Output -match [regex]::Escape($stableVersion)
        $agentReady=-not $agentCheck.TimedOut -and $agentCheck.ExitCode -eq 0 -and $agentCheck.Output -match [regex]::Escape($agentVersion)
        $browserReady=(Test-Path $browser -PathType Leaf)-and(Test-SgChromiumExecutableResult $browserProbe $browserCheck)
        return [pscustomobject]@{StableReady=if($stableReady){'yes'}else{'no'};StableVersion=$stableVersion;StableRevision=$revision;StablePath=$stableCommand;BrowserPath=if($browserReady){$browser}else{''};AgentCliReady=if($agentReady){'yes'}else{'no'};AgentCliVersion=$agentVersion;AgentCliPath=$agentCommand;MotionReady=if($stableReady -and $browserReady){'yes'}else{'no'}}
    } catch {Write-SgInstallerWarning "Managed Playwright runtime pending: $($_.Exception.Message)";return $empty}
}

function Set-SgFlutterChromeExecutable([string]$BrowserPath) {
    if ([string]::IsNullOrWhiteSpace($BrowserPath) -or -not (Test-Path -LiteralPath $BrowserPath -PathType Leaf)) { return $false }
    $resolved = [IO.Path]::GetFullPath($BrowserPath)
    $managedRoot = [IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'ms-playwright')).TrimEnd('\') + '\'
    if (-not $resolved.StartsWith($managedRoot,[StringComparison]::OrdinalIgnoreCase)) { Write-SgInstallerWarning 'Flutter browser wiring rejected a browser outside the managed Playwright runtime.'; return $false }
    [Environment]::SetEnvironmentVariable('CHROME_EXECUTABLE',$resolved,'User')
    $env:CHROME_EXECUTABLE = $resolved
    return $true
}

function Resolve-SgNpmVersion([string]$NpmPath, [string]$PackageName) {
    $result = Invoke-SgBoundedProcess $NpmPath @('view',$PackageName,'version','--json','--registry=https://registry.npmjs.org/') 45
    if ($result.TimedOut -or $result.ExitCode -ne 0) { throw "Exact version resolution failed for $PackageName." }
    try {
        $resolved = @($result.Output | ConvertFrom-Json)
        $version = if ($resolved.Count -eq 1) { [string]$resolved[0] } else { '' }
    } catch { $version = '' }
    if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw "Exact version resolution failed for $PackageName." }
    return $version
}

function Install-SgMachineToolbox([string]$WorkspacePath, [string]$DartPath, [string]$NpmPath, [bool]$GoogleCloudReady) {
    $needs = Get-SgProjectServiceNeeds -Workspace $WorkspacePath
    $versions = @{}
    $resolvedNeeds = [pscustomobject]@{ Firebase=$false; FlutterFire=$false; Supabase=$false; Convex=$false; Vercel=$false; Clerk=$false; Auth0=$false; AndroidNative=$needs.AndroidNative }
    $states = [ordered]@{ Firebase='pending'; FlutterFire='pending'; Convex='pending'; Vercel='pending'; Supabase='pending'; Clerk='pending'; Auth0='pending'; GoogleCloud=if($GoogleCloudReady){'ready'}else{'pending'}; AndroidNative=if($needs.AndroidNative){'detected; project-specific NDK/CMake versions must be reviewed'}else{'not detected'} }
    $mise = Resolve-SgTrustedMisePath
    if (-not $mise) { $mise = Install-SgOfficialMise }
    $root = Join-Path $env:LOCALAPPDATA 'ShipGlows\Toolchains\machine-toolbox'
    New-Item -ItemType Directory -Path $root -Force | Out-Null

    if (-not $mise) {
        Write-SgInstallerWarning 'Machine CLI toolbox pending: the trusted mise executable is unavailable.'
    } else {
        foreach ($definition in @(
            @{ Need='Firebase'; Package='firebase-tools' },
            @{ Need='Convex'; Package='convex' },
            @{ Need='Vercel'; Package='vercel' },
            @{ Need='Clerk'; Package='clerk' }
        )) {
            try { $versions[$definition.Need] = Resolve-SgNpmVersion $NpmPath $definition.Package; $resolvedNeeds.($definition.Need) = $true }
            catch { Write-SgInstallerWarning "$($definition.Need) exact-version resolution failed; its machine CLI remains pending." }
        }
        foreach ($definition in @(
            @{ Need='Supabase'; Tool='aqua:supabase/cli'; StableOnly=$false },
            @{ Need='Auth0'; Tool='aqua:auth0/auth0-cli'; StableOnly=$true }
        )) {
            try {
                $latest = Invoke-SgManagedTauriMise $mise $root @('latest',$definition.Tool) 120
                $version = if (-not $latest.TimedOut -and $latest.ExitCode -eq 0) { $latest.Output.Trim() -replace '^v','' } else { '' }
                $pattern = if ($definition.StableOnly) { '^\d+\.\d+\.\d+$' } else { '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$' }
                if ($version -notmatch $pattern) { throw "mise returned no exact stable $($definition.Need) version." }
                $versions[$definition.Need] = $version; $resolvedNeeds.($definition.Need) = $true
            } catch { Write-SgInstallerWarning "$($definition.Need) exact-version resolution failed; its machine CLI remains pending." }
        }

        if (@('Firebase','Supabase','Convex','Vercel','Clerk' | Where-Object { -not $versions.ContainsKey($_) }).Count -eq 0) {
            $plan = @(Get-SgMachineToolboxPlan -Versions $versions)
            $configPath = Join-Path $root 'mise.toml'
            $expected = Get-SgMachineToolboxMiseConfig -Plan $plan
            $existingConfig = if (Test-Path -LiteralPath $configPath -PathType Leaf) { [IO.File]::ReadAllText($configPath) } else { '' }
            $preservePinnedAuth0 = -not $versions.ContainsKey('Auth0') -and $existingConfig -match '(?m)^"aqua:auth0/auth0-cli"\s*=\s*"\d+\.\d+\.\d+"\s*$'
            if (-not $preservePinnedAuth0 -and $existingConfig.Replace("`r`n","`n") -cne $expected.Replace("`r`n","`n")) {
                $temporary = "$configPath.tmp-$([guid]::NewGuid().ToString('N'))"
                [IO.File]::WriteAllText($temporary,$expected,[Text.UTF8Encoding]::new($false)); Move-SgAtomicReplace $temporary $configPath
            }
            $installed = Invoke-SgManagedTauriMise $mise $root @('install') 1800 -Visible -OperationId 'tool.machine-toolbox' -Label 'Installing the ShipGlows machine CLI toolbox'
            $toolboxInstalled = -not $installed.TimedOut -and $installed.ExitCode -eq 0
            if (-not $toolboxInstalled) { Write-SgInstallerWarning "Machine CLI toolbox installation failed or timed out (exit=$($installed.ExitCode)); each CLI will be converged independently." }
            $locked = Invoke-SgManagedTauriMise $mise $root @('lock','--platform','windows-x64') 300 -OperationId 'tool.machine-toolbox.lock' -Label 'Locking the ShipGlows machine CLI toolbox'
            if ($locked.TimedOut -or $locked.ExitCode -ne 0) { Write-SgInstallerWarning "Machine CLI toolbox lockfile refresh failed or timed out (exit=$($locked.ExitCode)); exact config pins remain active." }
            foreach ($item in $plan) {
                $wrapper = Join-Path $runtimeDir "$($item.Command).cmd"
                $content = Get-SgMachineToolboxWrapperContent -MisePath $mise -ToolboxRoot $root -Command $item.Command
                if (-not (Test-Path -LiteralPath $wrapper -PathType Leaf) -or [IO.File]::ReadAllText($wrapper) -cne $content) { [IO.File]::WriteAllText($wrapper,$content,[Text.Encoding]::ASCII) }
                $verify = Invoke-SgBoundedProcess $wrapper @('--version') 60
                if (-not (Test-SgServiceCliResult $null $verify $wrapper $item.Version)) {
                    $repair = Invoke-SgManagedTauriMise $mise $root @('install',"$($item.Tool)@$($item.Version)") 900 -Visible -OperationId ("tool.machine-toolbox." + $item.Name) -Label ("Installing the exact $($item.Name) machine CLI")
                    $verify = Invoke-SgBoundedProcess $wrapper @('--version') 60
                } else { $repair = $null }
                $property = $item.Name.Substring(0,1).ToUpperInvariant() + $item.Name.Substring(1)
                $ready = Test-SgServiceCliResult $repair $verify $wrapper $item.Version
                $states[$property] = if($ready){"ready ($($item.Version))"}else{"pending ($($item.Version))"}
                if (-not $ready) { Write-SgInstallerWarning "$($item.Name) machine CLI executable verification failed." }
            }
        }
    }

    # FlutterFire is a Dart Pub tool, but it is still machine-scoped and is
    # installed independently of project detection.
    if ($DartPath) {
        try {
            $pub = Invoke-RestMethod -UseBasicParsing -Uri 'https://pub.dev/api/packages/flutterfire_cli' -TimeoutSec 45
            $version = [string]$pub.latest.version
            if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw 'pub.dev returned no exact FlutterFire version.' }
            $versions.FlutterFire = $version; $resolvedNeeds.FlutterFire = $true
            $pubBin = Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin'; Add-SgUserPathEntry $pubBin
            $exe = Join-Path $pubBin 'flutterfire.bat'
            $verify = if(Test-Path -LiteralPath $exe -PathType Leaf){Invoke-SgBoundedProcess $exe @('--version') 60}else{$null}
            if (-not (Test-SgServiceCliResult $null $verify $exe $version)) {
                $activate = Invoke-SgVisibleBoundedProcess -OperationId 'service.flutterfire' -Label "Installing FlutterFire CLI $version" -File $DartPath -Arguments @('pub','global','activate','flutterfire_cli',$version) -TimeoutSeconds 600
                $verify = if(Test-Path -LiteralPath $exe -PathType Leaf){Invoke-SgBoundedProcess $exe @('--version') 60}else{$null}
            } else { $activate = $null }
            $ready = Test-SgServiceCliResult $activate $verify $exe $version
            $states.FlutterFire = if($ready){"ready ($version)"}else{"pending ($version)"}
            if (-not $ready) { Write-SgInstallerWarning 'FlutterFire CLI executable verification failed.' }
        } catch { Write-SgInstallerWarning "FlutterFire machine CLI remains pending: $($_.Exception.Message)" }
    }

    return [pscustomobject]@{ Needs=$needs; DetectedNeeds=$needs; Versions=$versions; Mise=if($mise){'ready'}else{'pending'}; ToolboxRoot=$root; Firebase=$states.Firebase; FlutterFire=$states.FlutterFire; Convex=$states.Convex; Vercel=$states.Vercel; Supabase=$states.Supabase; Clerk=$states.Clerk; Auth0=$states.Auth0; GoogleCloud=$states.GoogleCloud; AndroidNative=$states.AndroidNative }
}

function Install-SgDetectedServiceClis([string]$WorkspacePath, [string]$DartPath, [string]$NpmPath, [string]$NpxPath, [bool]$GoogleCloudReady = $false) {
    # Backward-compatible entrypoint: detection now controls MCP activation,
    # while the machine CLI toolbox is always installed by a full install.
    return Install-SgMachineToolbox $WorkspacePath $DartPath $NpmPath $GoogleCloudReady
}

Remove-SgLegacyRuntime
Remove-SgObsoleteProfileCommand
Import-Module (Join-Path $runtimeDir 'ShipGlows.PowerShellRuntime.psm1') -Force -DisableNameChecking
$env:SHIPGLOWS_MANAGED_PWSH = Resolve-SgManagedPowerShell
Install-SgCommandWrappers
[void](Install-SgGum)
$programFiles = [Environment]::GetFolderPath('ProgramFiles')
$programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
$gitPaths = @((Join-Path $programFiles 'Git\cmd\git.exe'), (Join-Path $programFilesX86 'Git\cmd\git.exe'))
$ghPaths = @((Join-Path $programFiles 'GitHub CLI\gh.exe'), (Join-Path $programFilesX86 'GitHub CLI\gh.exe'))
$fzfPaths = @((Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\fzf.exe'))
$nodePaths = @((Join-Path $programFiles 'nodejs\node.exe'), (Join-Path $programFilesX86 'nodejs\node.exe'))
$npmPaths = @((Join-Path $env:APPDATA 'npm\npm.cmd'), (Join-Path $programFiles 'nodejs\npm.cmd'), (Join-Path $programFilesX86 'nodejs\npm.cmd'))
$npxPaths = @((Join-Path $env:APPDATA 'npm\npx.cmd'), (Join-Path $programFiles 'nodejs\npx.cmd'), (Join-Path $programFilesX86 'nodejs\npx.cmd'))
$corepackPaths = @((Join-Path $env:APPDATA 'npm\corepack.cmd'), (Join-Path $programFiles 'nodejs\corepack.cmd'), (Join-Path $programFilesX86 'nodejs\corepack.cmd'))
$pnpmPaths = @((Join-Path $env:APPDATA 'npm\pnpm.cmd'))
$uvPaths = @((Join-Path $env:USERPROFILE '.local\bin\uv.exe'), (Join-Path $env:USERPROFILE '.cargo\bin\uv.exe'))
$pythonPaths = @((Join-Path $env:USERPROFILE '.local\bin\python.exe'))
$flutterPaths = @((Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.bat'), (Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.exe'))
$gcloudPaths = @(
    (Join-Path $env:LOCALAPPDATA 'Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd'),
    (Join-Path $programFiles 'Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd'),
    (Join-Path $programFilesX86 'Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd')
)
$dopplerPaths = @(
    (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\doppler.exe'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Doppler\doppler.exe'),
    (Join-Path $programFiles 'Doppler\doppler.exe')
)
$agentBinDirectory = Join-Path $env:APPDATA 'npm'
$pnpmAgentBinDirectory = Join-Path $env:LOCALAPPDATA 'pnpm\bin'
$claudePaths = @((Join-Path $agentBinDirectory 'claude.cmd'), (Join-Path $pnpmAgentBinDirectory 'claude.cmd'))
$codexPaths = @((Join-Path $agentBinDirectory 'codex.cmd'), (Join-Path $pnpmAgentBinDirectory 'codex.cmd'))
$opencodePaths = @((Join-Path $agentBinDirectory 'opencode.cmd'), (Join-Path $pnpmAgentBinDirectory 'opencode.cmd'))
$kiloPaths = @((Join-Path $agentBinDirectory 'kilo.cmd'), (Join-Path $pnpmAgentBinDirectory 'kilo.cmd'))
$kilocodePaths = @((Join-Path $agentBinDirectory 'kilocode.cmd'), (Join-Path $pnpmAgentBinDirectory 'kilocode.cmd'))
$geminiPaths = @((Join-Path $agentBinDirectory 'gemini.cmd'), (Join-Path $pnpmAgentBinDirectory 'gemini.cmd'))
$corePhase = Start-SgInstallerPhase -Operation (New-SgInstallerOperation -Id 'phase.core-tools' -Label 'Preparing core Windows developer tools' -TimeoutSeconds 7200) -EventSink $installerEventSink
$script:activeInstallerPhase = $corePhase
Write-Host 'Preparing Windows developer tools. This step can take a few minutes on the first installation.' -ForegroundColor Yellow
[void](Install-SgWingetPackage 'git.exe' 'Git.Git' $gitPaths)
[void](Install-SgWingetPackage 'gh.exe' 'GitHub.cli' $ghPaths)
[void](Install-SgWingetPackage 'fzf.exe' 'junegunn.fzf' $fzfPaths)
[void](Install-SgWingetPackage 'node.exe' 'OpenJS.NodeJS.LTS' $nodePaths)
$misePath = Install-SgOfficialMise
if (-not $misePath) { Write-SgInstallerWarning 'mise remains pending; the machine CLI toolbox cannot converge.' }
$googleCloudReady = Install-SgWingetPackage 'gcloud.cmd' 'Google.CloudSDK' $gcloudPaths
$dopplerReady = (Install-SgWingetPackage 'doppler.exe' 'Doppler.Doppler' $dopplerPaths) -and (Test-SgToolRuns 'doppler.exe' $dopplerPaths @('--version'))
if (-not $dopplerReady) { Write-SgInstallerWarning 'Doppler CLI remains pending; no login or project setup was attempted.' }
$pnpmReady = Install-SgPnpm $npmPaths $corepackPaths $pnpmPaths
$uvReady = Install-SgWingetPackage 'uv.exe' 'astral-sh.uv' $uvPaths
if (-not $uvReady) { throw 'ShipGlows requires uv to provide a functional default Python runtime.' }
$pythonInfo = Install-SgDefaultPython $uvPaths $pythonPaths
Assert-SgEnvironmentPythonPackage $pythonInfo.Path (Join-Path $ShipglowsDir 'cli\environment')
if ($UpdateDeveloperTools) {
    $developerToolDefinitions = @(
        [pscustomobject]@{Key='git';Name='Git';Command='git.exe';PackageId='Git.Git';Paths=$gitPaths},
        [pscustomobject]@{Key='github';Name='GitHub CLI';Command='gh.exe';PackageId='GitHub.cli';Paths=$ghPaths},
        [pscustomobject]@{Key='node';Name='Node.js LTS';Command='node.exe';PackageId='OpenJS.NodeJS.LTS';Paths=$nodePaths},
        [pscustomobject]@{Key='mise';Name='mise';Command='mise.exe';PackageId='jdx.mise';Paths=@($misePath)},
        [pscustomobject]@{Key='gcloud';Name='Google Cloud CLI';Command='gcloud.cmd';PackageId='Google.CloudSDK';Paths=$gcloudPaths},
        [pscustomobject]@{Key='doppler';Name='Doppler CLI';Command='doppler.exe';PackageId='Doppler.Doppler';Paths=$dopplerPaths},
        [pscustomobject]@{Key='uv';Name='uv';Command='uv.exe';PackageId='astral-sh.uv';Paths=$uvPaths}
    )
    Invoke-SgManagedDeveloperToolUpdates $developerToolDefinitions $npmPaths $corepackPaths $pnpmPaths
}
[void](Complete-SgInstallerPhase $corePhase)

$wslPhase = Start-SgInstallerPhase -Operation (New-SgInstallerOperation -Id 'phase.wsl-turso' -Label 'Inspecting optional WSL and Turso capabilities' -TimeoutSeconds 7200) -EventSink $installerEventSink
$script:activeInstallerPhase = $wslPhase
$interactiveInstaller = -not [Console]::IsInputRedirected
$wslState = Get-SgWslState
$wslInstallResult = $null
if ($wslState.Status -in @('absent','platform_only')) {
    Write-Host "Optional WSL capability: $($wslState.Reason)" -ForegroundColor Yellow
    $wslChoice = Read-SgVisibleInstallerChoice -Interactive $interactiveInstaller -Prompt 'Install WSL with Ubuntu independently from ShipGlows? A visible administrator prompt and restart may be required. [y/N]' -OperationId 'input.wsl' -Label 'WSL installation consent'
    $wslPlan = Get-SgWslInstallPlan -State $wslState -Interactive $interactiveInstaller -Choice $wslChoice
    $wslInstallResult = Invoke-SgWslInstall -Plan $wslPlan
    if ($wslInstallResult.Changed) { Write-Host $wslInstallResult.NextAction -ForegroundColor Yellow }
    elseif ($wslInstallResult.Status -eq 'error') { Write-SgInstallerWarning $wslInstallResult.Reason }
    $wslState = if ($wslInstallResult.Status -eq 'pending_restart') {
        [pscustomobject]@{ Status='pending_restart'; Ready=$false; Distribution=''; Reason=$wslInstallResult.Reason; NextAction=$wslInstallResult.NextAction }
    } elseif ($wslInstallResult.Changed) {
        [pscustomobject]@{ Status='ubuntu_uninitialized'; Ready=$false; Distribution='Ubuntu'; Reason=$wslInstallResult.Reason; NextAction=$wslInstallResult.NextAction }
    } else { $wslState }
} elseif ($wslState.Status -eq 'ubuntu_uninitialized') {
    Write-SgInstallerWarning $wslState.NextAction
} elseif ($wslState.Status -eq 'pending_restart') {
    Write-SgInstallerWarning $wslState.NextAction
} elseif ($wslState.Status -eq 'error') {
    Write-SgInstallerWarning $wslState.Reason
}

$tursoState = Get-SgTursoCloudState -WslState $wslState
if ($wslState.Ready -and -not $tursoState.Ready) {
    Write-Host "Optional Turso Cloud CLI: $($tursoState.Reason)" -ForegroundColor Yellow
    $tursoChoice = Read-SgVisibleInstallerChoice -Interactive $interactiveInstaller -Prompt 'Install the pinned Turso Cloud CLI inside Ubuntu? Authentication will not be started. [y/N]' -OperationId 'input.turso-cloud' -Label 'Turso Cloud CLI installation consent'
    $tursoPlan = Get-SgTursoCloudInstallPlan -WslState $wslState -TursoState $tursoState -Interactive $interactiveInstaller -Choice $tursoChoice
    $tursoResult = Invoke-SgTursoCloudInstall -Plan $tursoPlan -WslState $wslState -InstallerPath $tursoCloudInstaller
    if ($tursoResult.Status -eq 'ready') { Write-Host $tursoResult.Reason -ForegroundColor Green }
    elseif ($tursoResult.Status -eq 'error') { Write-SgInstallerWarning $tursoResult.Reason }
} elseif (-not $wslState.Ready) {
    Write-Host "Turso Cloud CLI remains pending: $($tursoState.NextAction)" -ForegroundColor DarkGray
}
[void](Complete-SgInstallerPhase $wslPhase)

$playwrightRuntime = Install-SgManagedPlaywrightRuntimes (Get-SgToolPath 'npm.cmd' $npmPaths)
[void](Set-SgFlutterChromeExecutable $playwrightRuntime.BrowserPath)
if ($UpdateDeveloperTools) {
    Write-Host 'Preserving recorded mobile and IDE state; developer-tool updates do not run SDK, licence, emulator, or IDE convergence.' -ForegroundColor Green
    $recordedMobileState = Get-SgRecordedMobileEnvironmentState
    $flutterReady = [bool]$recordedMobileState.FlutterReady
    $androidInfo = $recordedMobileState.AndroidInfo
    $ideInfo = $recordedMobileState.IdeInfo
    $tauriInfo = $recordedMobileState.TauriInfo
    $tauriState = [pscustomobject]@{ IsTauri=$false; Status='preserved'; ProjectRoot=''; Differences=@() }
} else {
$mobilePhase = Start-SgInstallerPhase -Operation (New-SgInstallerOperation -Id 'phase.mobile-toolchains' -Label 'Inspecting and preparing mobile toolchains' -TimeoutSeconds 7200) -EventSink $installerEventSink
$script:activeInstallerPhase = $mobilePhase
$flutterReady = Install-SgFlutter $flutterPaths $gitPaths
$tauriState = try { Get-SgTauriAndroidProjectState -Workspace $Workspace } catch { Write-SgInstallerWarning "Tauri Android inspection is unknown: $($_.Exception.Message)"; [pscustomobject]@{ IsTauri=$false; Status='unknown'; ProjectRoot=''; Differences=@('inspection failed') } }
$tauriInstallApproved = $false
if ($tauriState.IsTauri) {
    Write-Host "Tauri Android project detected: $($tauriState.ProjectRoot)" -ForegroundColor Cyan
    $tauriBaseline = Get-SgTauriAndroidBaseline
    $tauriManagedRoot = Join-Path $env:LOCALAPPDATA 'ShipGlows\Toolchains\tauri-android'
    $tauriExistingRustReady = Test-SgTauriRustToolchain (Resolve-SgTrustedMisePath) $tauriManagedRoot $tauriBaseline
    $tauriExistingNdkRoots = @($env:ANDROID_HOME,$env:ANDROID_SDK_ROOT,(Join-Path $env:LOCALAPPDATA 'Android\Sdk')) | Where-Object { $_ }
    $tauriExistingNdkReady = @($tauriExistingNdkRoots | Where-Object { Test-Path -LiteralPath (Join-Path $_ "ndk\$($tauriBaseline.NdkVersion)\source.properties") -PathType Leaf }).Count -gt 0
    if ($tauriExistingRustReady -and $tauriExistingNdkReady) {
        Write-Host 'Validated Tauri Android Rust targets and NDK are already ready; skipping the toolchain question.' -ForegroundColor Green
    } else {
        $tauriChoice = Read-SgVisibleInstallerChoice -Interactive (-not [Console]::IsInputRedirected) -Prompt 'Prepare the reusable Tauri Android toolchain (Rust + NDK) now? [y/N]' -OperationId 'input.tauri-toolchain' -Label 'Tauri Android toolchain consent'
        $tauriInstallApproved = $tauriChoice -in @('y','yes')
        if (-not $tauriInstallApproved) { Write-SgInstallerWarning 'Tauri Android host preparation remains pending; no project file was modified.' }
    }
}
$androidInfo = Install-SgAndroidToolchain $flutterReady $flutterPaths ($tauriState.IsTauri -and $tauriInstallApproved)
if ($tauriState.IsTauri -and $tauriExistingNdkReady) { $androidInfo | Add-Member -NotePropertyName NdkReady -NotePropertyValue $true -Force }
$tauriInfo = Install-SgTauriAndroidToolchain -ProjectState $tauriState -InstallApproved $tauriInstallApproved -AndroidInfo $androidInfo
$ideInfo = Install-SgWindowsIdeToolchains $flutterReady $flutterPaths
[void](Complete-SgInstallerPhase $mobilePhase)
}

Write-Host ''
$agentPhase = Start-SgInstallerPhase -Operation (New-SgInstallerOperation -Id 'phase.coding-agents' -Label 'Preparing coding-agent CLIs and MCPs' -TimeoutSeconds 7200) -EventSink $installerEventSink
$script:activeInstallerPhase = $agentPhase
Write-Host 'Preparing coding-agent CLIs and MCPs (no authentication is started)...' -ForegroundColor Yellow
$initialAgentReady = @{
    Codex = Test-SgToolRuns 'codex.cmd' $codexPaths
    Claude = Test-SgToolRuns 'claude.cmd' $claudePaths
    OpenCode = Test-SgToolRuns 'opencode.cmd' $opencodePaths
    Kilo = (Test-SgToolRuns 'kilo.cmd' $kiloPaths) -or (Test-SgToolRuns 'kilocode.cmd' $kilocodePaths)
    Gemini = Test-SgToolRuns 'gemini.cmd' $geminiPaths
}
$agentReady = Install-SgMissingAgentClis (Get-SgToolPath 'npm.cmd' $npmPaths) $initialAgentReady -UpdateApproved:$UpdateDeveloperTools
$codexReady = [bool]$agentReady.Codex
$claudeReady = [bool]$agentReady.Claude
$opencodeReady = [bool]$agentReady.OpenCode
$kiloResolved = Resolve-SgKiloCommand (Get-SgToolPath 'kilo.cmd' $kiloPaths) (Get-SgToolPath 'kilocode.cmd' $kilocodePaths)
$kiloReady = [bool]$agentReady.Kilo
$geminiReady = [bool]$agentReady.Gemini
[void](Invoke-SgTauriMigrationHandoff -ProjectState $tauriState -CodexReady $codexReady -CodexPaths $codexPaths)
if ($codexReady -and ($env:SHIPGLOWS_CODEX_PERMISSION_MODE -or $env:SHIPGLOWS_AUTONOMY_MODE)) {
    $codexConfigPath = Join-Path $env:USERPROFILE '.codex\config.toml'
    $codexPermissionMode = Resolve-SgCodexPermissionMode $codexConfigPath
    if ($codexPermissionMode -ne 'keep') { [void](Set-SgCodexPermissionMode $codexPermissionMode $codexConfigPath) }
}
$dartPath = if ($flutterReady) { Join-Path (Split-Path (Get-SgToolPath 'flutter.bat' $flutterPaths) -Parent) 'dart.bat' } else { '' }
[void]$androidInfo
$nativeNpx = Get-SgNativeNpxPath $npxPaths
$serviceInfo = Install-SgDetectedServiceClis $Workspace $dartPath (Get-SgToolPath 'npm.cmd' $npmPaths) $nativeNpx $googleCloudReady
$serviceInfo | Add-Member -NotePropertyName Doppler -NotePropertyValue $(if($dopplerReady){'ready'}else{'pending'}) -Force
$playwright = Install-SgPlaywrightChromiumForAgents ($codexReady -or $claudeReady -or $opencodeReady -or $kiloReady -or $geminiReady) (Get-SgToolPath 'npm.cmd' $npmPaths) $nativeNpx
[void](Complete-SgInstallerPhase $agentPhase)
$activationPhase = Start-SgInstallerPhase -Operation (New-SgInstallerOperation -Id 'phase.activation' -Label 'Recording environment and activating commands' -TimeoutSeconds 7200) -EventSink $installerEventSink
$script:activeInstallerPhase = $activationPhase
$managedProjectPaths = @(Invoke-SgProjectEnvironmentMigration (Join-Path $runtimeDir 'ShipGlows.DevServer.psm1'))
$agentInfo = Install-SgAgentMcpConfigs @{ Codex=$codexReady; Claude=$claudeReady; OpenCode=$opencodeReady; Kilo=$kiloReady; Gemini=$geminiReady } $dartPath $nativeNpx $playwright $managedProjectPaths $serviceInfo.Versions $ReplaceAgentConfigs.IsPresent
$playwrightConfigured = @($agentInfo.Values | Where-Object { $_.ReadyServers -contains 'playwright' }).Count -gt 0
$playwrightPending = @($agentInfo.Values | Where-Object { $_.PendingServers -contains 'playwright' }).Count -gt 0
$playwrightInfo = [pscustomobject]@{ Installed=$playwright.Ready; McpConfigured=$playwrightConfigured; McpVerified=$playwrightConfigured -and -not $playwrightPending; ConfigPath='per-project agent configs; readiness listed below'; ChromiumPath=$playwright.ChromiumPath }
$environmentPath = Write-SgGlobalDevelopmentEnvironment $agentInfo $playwrightInfo $playwrightRuntime $pythonInfo $flutterReady $androidInfo $ideInfo $serviceInfo (Test-SgWindowsDeveloperMode) $tauriInfo
Write-Host "ShipGlows development environment recorded: $environmentPath" -ForegroundColor Green
$agentInstructionChanges = @(Install-SgAgentEnvironmentInstructions -UserProfile $env:USERPROFILE -AgentReady @{ Codex=$codexReady; Claude=$claudeReady; OpenCode=$opencodeReady; Kilo=$kiloReady; Gemini=$geminiReady })
if ($agentInstructionChanges.Count) { Write-Host "ShipGlows tool context installed for $($agentInstructionChanges.Count) coding agent(s)." -ForegroundColor Green }

Write-Host ''
Write-Host 'Installing PowerShell-safe application commands...' -ForegroundColor Yellow
[void](Disable-SgBlockedPowerShellShim 'npm' $npmPaths)
[void](Disable-SgBlockedPowerShellShim 'npx' $npxPaths)
[void](Disable-SgBlockedPowerShellShim 'corepack' $corepackPaths)
[void](Disable-SgBlockedPowerShellShim 'pnpm' $pnpmPaths)
[void](Disable-SgBlockedPowerShellShim 'codex' $codexPaths)
[void](Disable-SgBlockedPowerShellShim 'claude' $claudePaths)
[void](Disable-SgBlockedPowerShellShim 'opencode' $opencodePaths)
[void](Disable-SgBlockedPowerShellShim 'kilo' $kiloPaths)
[void](Disable-SgBlockedPowerShellShim 'kilocode' $kilocodePaths)
[void](Disable-SgBlockedPowerShellShim 'gemini' $geminiPaths)
[void](Install-SgApplicationCommandWrapper 'npm' 'npm.cmd' $npmPaths)
[void](Install-SgApplicationCommandWrapper 'npx' 'npx.cmd' $npxPaths)
[void](Install-SgApplicationCommandWrapper 'corepack' 'corepack.cmd' $corepackPaths)
[void](Install-SgApplicationCommandWrapper 'pnpm' 'pnpm.cmd' $pnpmPaths)
[void](Install-SgApplicationCommandWrapper 'codex' 'codex.cmd' $codexPaths)
[void](Install-SgApplicationCommandWrapper 'claude' 'claude.cmd' $claudePaths)
[void](Install-SgApplicationCommandWrapper 'opencode' 'opencode.cmd' $opencodePaths)
[void](Install-SgApplicationCommandWrapper 'kilo' 'kilo.cmd' $kiloPaths)
[void](Install-SgApplicationCommandWrapper 'kilocode' 'kilocode.cmd' $kilocodePaths)
[void](Install-SgApplicationCommandWrapper 'gemini' 'gemini.cmd' $geminiPaths)
if($dopplerReady){[void](Install-SgApplicationCommandWrapper 'doppler' 'doppler.exe' $dopplerPaths)}
if($playwrightRuntime.StablePath){[void](Install-SgApplicationCommandWrapper 'playwright' 'playwright.cmd' @($playwrightRuntime.StablePath))}
if($playwrightRuntime.AgentCliPath){[void](Install-SgApplicationCommandWrapper 'playwright-cli' 'playwright-cli.cmd' @($playwrightRuntime.AgentCliPath))}
[void](Install-SgAgentShortcut 'c' 'claude')
[void](Install-SgAgentShortcut 'co' 'codex')
[void](Install-SgAgentShortcut 'cor' 'codex' @('resume'))
[void](Install-SgAgentShortcut 'oc' 'opencode')
$kiloShortcutTarget = if (Test-SgToolRuns 'kilo.cmd' $kiloPaths) { 'kilo' } else { 'kilocode' }
[void](Install-SgAgentShortcut 'kc' $kiloShortcutTarget)
[void](Install-SgShellShortcut 're' ('"{0}" -NoLogo -NoProfile -NoExit' -f $env:SHIPGLOWS_MANAGED_PWSH))
[void](Install-SgShellShortcut 'ch' ('"{0}" -NoLogo -NoProfile -NoExit -Command "Clear-History; try {{ $historyPath = (Get-PSReadLineOption).HistorySavePath; if ($historyPath -and (Test-Path -LiteralPath $historyPath)) {{ Remove-Item -LiteralPath $historyPath -Force }} }} catch {{ }}; Clear-Host"' -f $env:SHIPGLOWS_MANAGED_PWSH))
[void](Install-SgShellShortcut 'n' 'nvim %*')
[void](Install-SgShellShortcut 'gpush' 'git push %*')
[void](Install-SgGitPushProfileShortcut)
Add-SgRuntimeToUserPath
[void](Complete-SgInstallerPhase $activationPhase)
$script:activeInstallerPhase = $null

Write-Host "ShipGlows Windows DevServer installed." -ForegroundColor Green
Write-Host "Workspace: $Workspace"
Write-Host 'Commands: s (short) or shipglows-dev'
Write-Host ''
Write-Host 'Dependency check:' -ForegroundColor Yellow
foreach ($tool in @('gum','fzf','git','gh','node','npm','pnpm','uv','flutter','doppler')) {
    if ($tool -eq 'gum' -and (Test-Path -LiteralPath (Join-Path $runtimeDir 'gum.exe') -PathType Leaf)) {
        Write-Host "  [ok]   gum" -ForegroundColor Green
        continue
    }
    $knownPaths = switch ($tool) {
        'git' { $gitPaths; break }
        'gh' { $ghPaths; break }
        'fzf' { $fzfPaths; break }
        'node' { $nodePaths; break }
        'npm' { $npmPaths; break }
        'pnpm' { $pnpmPaths; break }
        'uv' { $uvPaths; break }
        'flutter' { $flutterPaths; break }
        'doppler' { $dopplerPaths; break }
        default { @() }
    }
    $executable = switch ($tool) {
        'npm' { 'npm.cmd'; break }
        'pnpm' { 'pnpm.cmd'; break }
        'flutter' { 'flutter.bat'; break }
        'doppler' { 'doppler.exe'; break }
        default { "$tool.exe" }
    }
    if ($tool -eq 'pnpm') { $found = $pnpmReady -and (Test-SgToolRuns $executable $knownPaths) }
    else { $found = Test-SgTool $executable $knownPaths }
    if ($found) { Write-Host "  [ok]   $tool" -ForegroundColor Green }
    else { Write-Host "  [miss] $tool (install it or use the project-specific setup instructions)" -ForegroundColor Yellow }
}
Write-Host 'Run now: s'
