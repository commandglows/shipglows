[CmdletBinding()]
param(
    [string]$ShipglowsDir = (Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'runtime'),
    [string]$Workspace = (Join-Path $env:USERPROFILE 'ShipGlows'),
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$sourceDir = Join-Path $ShipglowsDir 'cli\windows'
$runtimeDir = Join-Path $ShipglowsDir 'bin'
$environmentCli = Join-Path $ShipglowsDir 'cli\environment\shipglows_environment.py'
$environmentSchema = Join-Path $ShipglowsDir 'cli\environment\schemas\shipglows-environment-v1.schema.json'
if (-not (Test-Path -LiteralPath $environmentCli -PathType Leaf)) { throw "Missing environment control-plane command: $environmentCli" }
if (-not (Test-Path -LiteralPath $environmentSchema -PathType Leaf)) { throw "Missing environment control-plane schema: $environmentSchema" }
try { [void]([IO.File]::ReadAllText($environmentSchema) | ConvertFrom-Json) }
catch { throw "Invalid environment control-plane schema: $environmentSchema" }
$codexMcpModule = Join-Path $sourceDir 'ShipGlows.CodexMcp.psm1'
if (-not (Test-Path -LiteralPath $codexMcpModule -PathType Leaf)) { throw "Missing Windows Codex MCP helper: $codexMcpModule" }
Import-Module $codexMcpModule -Force -DisableNameChecking
$mobileModule = Join-Path $sourceDir 'ShipGlows.MobileToolchain.psm1'
if (-not (Test-Path -LiteralPath $mobileModule -PathType Leaf)) { throw "Missing Windows mobile toolchain helper: $mobileModule" }
Import-Module $mobileModule -Force -DisableNameChecking
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

$launcher = Join-Path $runtimeDir 'shipglows-devserver.ps1'
foreach ($launcherModule in @('ShipGlows.DevServer.psm1','ShipGlows.Auth.psm1','ShipGlows.MobileToolchain.psm1')) {
    Copy-Item -LiteralPath (Join-Path $sourceDir $launcherModule) -Destination $runtimeDir -Force
}
Copy-Item -LiteralPath (Join-Path $sourceDir 'shipglows-devserver.ps1') -Destination $launcher -Force
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
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0shipglows-devserver.ps1" %*
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
        & $executable @Arguments 2>$null | Out-Null
        return $LASTEXITCODE -eq 0
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

        $configuredOutput = @(& $pnpm config get global-bin-dir 2>$null)
        $globalBin = ($configuredOutput | Out-String).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($globalBin) -or $globalBin -in @('null', 'undefined')) {
            $globalBin = $defaultGlobalBin
            & $pnpm config set global-bin-dir $globalBin --global | Out-Host
            if ($LASTEXITCODE -ne 0) { throw 'pnpm global-bin-dir configuration failed.' }
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
        & $npm install --global corepack@latest | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "Corepack installation returned exit code $LASTEXITCODE." }
        Update-SgProcessPath

        $corepack = Get-SgToolPath 'corepack.cmd' $CorepackPaths
        if ($corepack) {
            & $corepack enable pnpm | Out-Host
            if ($LASTEXITCODE -eq 0) {
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
        & $npm install --global pnpm@latest | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "pnpm installation returned exit code $LASTEXITCODE." }
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
    $pythonFiles = @('__init__.py','core.py','mise_backend.py','shipglows_environment.py') | ForEach-Object { Join-Path $EnvironmentDirectory $_ }
    $script = 'import ast,pathlib,sys; [ast.parse(pathlib.Path(p).read_text(encoding="utf-8"), filename=p) for p in sys.argv[1:]]'
    & $PythonPath -c $script @pythonFiles
    if ($LASTEXITCODE -ne 0) { throw 'The installed ShipGlows environment Python package failed syntax validation.' }
}

function Write-SgGlobalDevelopmentEnvironment([hashtable]$AgentInfo, [pscustomobject]$PlaywrightInfo, [pscustomobject]$PlaywrightRuntimeInfo, [pscustomobject]$PythonInfo, [bool]$FlutterReady, [pscustomobject]$AndroidInfo, [pscustomobject]$IdeInfo, [pscustomobject]$ServiceInfo, [bool]$DeveloperModeReady) {
    $environmentPath = Join-Path (Join-Path $env:USERPROFILE '.shipglows') 'environment.md'
    New-Item -ItemType Directory -Path (Split-Path -Parent $environmentPath) -Force | Out-Null
    $codexStatus = if ($AgentInfo.Codex.Installed) { 'installed' } else { 'not installed' }
    $playwrightInstalled = if ($PlaywrightInfo.Installed) { 'yes' } else { 'no' }
    $playwrightConfigured = if ($PlaywrightInfo.McpConfigured) { 'yes, see per-agent readiness below' } else { 'no' }
    $playwrightVerified = if ($PlaywrightInfo.McpVerified) { 'yes, per-agent configuration converged' } else { 'no' }
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
    $firebaseDeviceStreamingReady = if ($IdeInfo.FirebaseDeviceStreamingReady) { 'yes' } else { 'no' }
    $developerModeStatus = if ($DeveloperModeReady) { 'yes' } else { 'no' }
    $agentLines = @()
    foreach ($agentName in @('Codex','Claude','OpenCode','Kilo','Gemini')) {
        $agent = $AgentInfo[$agentName]
        $installed = if ($agent -and $agent.Installed) { 'yes' } else { 'no' }
        $mcp = if ($agent -and $agent.McpSummary) { [string]$agent.McpSummary } else { 'not configured' }
        $agentLines += "- $agentName CLI installed: $installed"
        $agentLines += "- $agentName MCP readiness: $mcp"
    }
    $serviceLines = @()
    foreach ($serviceName in @('Firebase','FlutterFire','Convex','Vercel','Supabase','Clerk','AndroidNative')) {
        $state = if ($ServiceInfo -and $ServiceInfo.PSObject.Properties[$serviceName]) { [string]$ServiceInfo.$serviceName } else { 'not detected' }
        $serviceLines += "- $serviceName development tooling: $state"
    }
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
- Flutter Windows desktop toolchain ready: $visualStudioCppReady
- Windows Developer Mode enabled: $developerModeStatus
- Windows Developer Mode next action: $(if ($DeveloperModeReady) { 'none' } else { 'open Windows Settings > System > For developers; ShipGlows never changes this policy automatically.' })
- Firebase Android Device Streaming configured: $firebaseDeviceStreamingReady
- Firebase Android Device Streaming next action: $firebaseDeviceStreamingNextAction
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

function Install-SgMissingAgentClis([string]$NpmPath, [hashtable]$CurrentReady) {
    $interactive = [Environment]::UserInteractive -and -not [Console]::IsInputRedirected
    $choice = ''
    $definitions = @{
        Codex    = @{ Package='@openai/codex'; Command='codex.cmd'; Paths=$codexPaths }
        Claude   = @{ Package='@anthropic-ai/claude-code'; Command='claude.cmd'; Paths=$claudePaths }
        OpenCode = @{ Package='opencode-ai'; Command='opencode.cmd'; Paths=$opencodePaths }
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
    if ($initial.Ask) {
        if (@($initial.Missing).Count) { Write-Host "Missing coding-agent CLIs: $($initial.Missing -join ', ')." -ForegroundColor Yellow }
        if (@($initial.Outdated).Count) { Write-Host "Coding-agent CLI updates available: $($initial.Outdated -join ', ')." -ForegroundColor Yellow }
        Write-Host 'ShipGlows installs only the CLI binaries; authentication and provider credentials remain yours.' -ForegroundColor DarkGray
        $choice = (Read-Host 'Install the missing or update the outdated coding-agent CLIs now? [y/N]').Trim()
    }
    $plan = Get-SgAgentInstallPlan -Interactive $interactive -AgentReady $CurrentReady -AgentOutdated $outdated -Choice $choice
    foreach ($name in @($plan.Install)) {
        $definition = $definitions[$name]
        try {
            $version = if ($resolvedVersions[$name]) { $resolvedVersions[$name] } else { Resolve-SgNpmVersion $NpmPath $definition.Package }
            $install = Invoke-SgBoundedProcess $NpmPath @('install','--global',"$($definition.Package)@$version",'--registry=https://registry.npmjs.org/') 900
            $ready = -not $install.TimedOut -and $install.ExitCode -eq 0 -and (Test-SgToolRuns $definition.Command $definition.Paths)
            if (-not $ready) { Write-SgInstallerWarning "$name CLI exact-version installation or executable verification failed." }
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
    $migrated = 0
    foreach ($entry in @((Read-SgRegistry $config).projects)) {
        $projectPath = [string]$entry.path
        if ([string]::IsNullOrWhiteSpace($projectPath) -or -not (Test-Path -LiteralPath $projectPath -PathType Container)) { continue }
        $port = if ($entry.PSObject.Properties['port']) { [int]$entry.port } else { 0 }
        [void](Write-SgProjectEnvironment $projectPath $port)
        $migrated++
    }
    Write-Host "ShipGlows project environments migrated: $migrated" -ForegroundColor Green
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

function Install-SgFlutter([string[]]$FlutterPaths, [string[]]$GitPaths) {
    $existingFlutter = Get-SgToolPath 'flutter.bat' $FlutterPaths
    if ($existingFlutter) {
        $existingRoot = Split-Path (Split-Path $existingFlutter -Parent) -Parent
        $existingState = Get-SgFlutterInstallState -FlutterRoot $existingRoot
        if ($existingState.Status -eq 'ready') {
            Write-Host "Using validated existing Flutter/Dart SDK without changing its location: $existingRoot" -ForegroundColor Green
            return $true
        }
    }
    $git = Get-SgToolPath 'git.exe' $GitPaths
    if (-not $git) { Write-SgInstallerWarning 'Flutter could not be installed because Git is unavailable.'; return $false }
    $flutterDirectory = Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter'
    $state = Get-SgFlutterInstallState -FlutterRoot $flutterDirectory
    if ($state.Status -eq 'partial') { [void](Move-SgManagedPartialDirectory $flutterDirectory); $state = Get-SgFlutterInstallState -FlutterRoot $flutterDirectory }
    if ($state.Status -eq 'absent') {
        $resolved = Invoke-SgBoundedProcess -File $git -Arguments @('ls-remote','https://github.com/flutter/flutter.git','refs/heads/stable') -TimeoutSeconds 60
        $commit = if (-not $resolved.TimedOut -and $resolved.ExitCode -eq 0 -and $resolved.Output -match '(?m)^([0-9a-f]{40})\s+refs/heads/stable$') { $Matches[1] } else { '' }
        if (-not $commit) { Write-SgInstallerWarning 'Flutter stable commit could not be resolved and proven; installation is pending.'; return $false }
        New-Item -ItemType Directory -Path $flutterDirectory | Out-Null
        foreach ($step in @(
            @('init'),
            @('remote','add','origin','https://github.com/flutter/flutter.git'),
            @('fetch','--depth','1','origin',$commit),
            @('checkout','--detach','FETCH_HEAD')
        )) {
            $arguments = @('-C',$flutterDirectory) + $step
            $result = Invoke-SgBoundedProcess -File $git -Arguments $arguments -TimeoutSeconds 600
            if ($result.TimedOut -or $result.ExitCode -ne 0) { [void](Move-SgManagedPartialDirectory $flutterDirectory); Write-SgInstallerWarning 'Flutter resolved-commit installation failed or timed out.'; return $false }
        }
    }
    $state = Get-SgFlutterInstallState -FlutterRoot $flutterDirectory
    if ($state.Status -ne 'ready') { Write-SgInstallerWarning 'Flutter/Dart executable validation failed after installation.'; return $false }
    Add-SgUserPathEntry (Join-Path $flutterDirectory 'bin')
    $configured = Invoke-SgBoundedProcess -File $state.FlutterPath -Arguments @('config','--enable-web','--enable-android') -TimeoutSeconds 90
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
    $license = (Read-Host 'Accept the Android SDK terms to download the official command-line tools? [y/N]').Trim().ToLowerInvariant()
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

function Install-SgAndroidToolchain([bool]$FlutterReady, [string[]]$FlutterPaths) {
    if (-not $FlutterReady) { Write-SgInstallerWarning 'Android setup is pending because Flutter is unavailable.'; return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false } }
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
    $essential = Invoke-SgBoundedProcess $sdkManager @('platform-tools',$coordinates.PlatformPackage,$coordinates.BuildToolsPackage) 600
    if ($essential.TimedOut -or $essential.ExitCode -ne 0) { Write-SgInstallerWarning 'Essential Android SDK package installation failed or timed out.' }
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
    $choice = if ($interactive -and -not $emulatorState.Complete) { (Read-Host $emulatorPrompt).Trim() } else { '' }
    $plan = Get-SgAndroidInstallPlan -Interactive $interactive -EmulatorSupported $emulatorSupported -EmulatorChoice $choice -EmulatorReady $emulatorState.Complete
    $emulator = if (Test-Path -LiteralPath $emulatorCandidate -PathType Leaf) { $emulatorCandidate } else { '' }
    $emulatorAccelerationReady = $false
    $avdReady = $emulatorState.Complete
    if ($plan.InstallEmulator) {
        Write-Host 'Downloading the Android emulator and Android 36 system image. Progress remains visible; this can use several gigabytes.' -ForegroundColor Yellow
        $emulatorInstallSucceeded = Invoke-SgInteractiveBoundedProcess $sdkManager $emulatorPlan.Packages 1800
        $emulator = $emulatorCandidate
        if ($emulatorInstallSucceeded -and (Test-Path -LiteralPath $emulator -PathType Leaf)) {
            $avdManager = Join-Path (Split-Path $sdkManager -Parent) 'avdmanager.bat'
            $image = $emulatorPlan.Packages[1]
            $list = Invoke-SgBoundedProcess $emulator @('-list-avds') 30
            $avdPattern = "(?m)^$([regex]::Escape($emulatorPlan.AvdName))\r?$"
            if ($list.Output -notmatch $avdPattern) {
                $create = Invoke-SgBoundedProcess -File $avdManager -Arguments @('create','avd','--name',$emulatorPlan.AvdName,'--package',$image,'--device',$emulatorPlan.Device) -TimeoutSeconds 120 -InputText 'no'
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
        $developerChoice = if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) { (Read-Host 'Open the official Windows Developer Mode settings now? [y/N]').Trim() } else { '' }
        $developerPlan = Get-SgDeveloperModeGuidancePlan -Interactive ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) -DeveloperModeReady $false -Choice $developerChoice
        if ($developerPlan.OpenSettings) { Start-Process $developerPlan.SettingsUri }
    }
    $flutterPath = Get-SgToolPath 'flutter.bat' $FlutterPaths
    $dartPath = if ($flutterPath) { Join-Path (Split-Path $flutterPath -Parent) 'dart.bat' } else { '' }
    $diagnostic = Get-SgFlutterAndroidDiagnostic -FlutterPath $flutterPath -DartPath $dartPath -JavaPath $java -SdkManagerPath $sdkManager -AdbPath $adb -EmulatorPath $emulator
    $diagnostic | Add-Member -NotePropertyName AvdReady -NotePropertyValue $avdReady -Force
    $diagnostic | Add-Member -NotePropertyName EmulatorAccelerationReady -NotePropertyValue $emulatorAccelerationReady -Force
    if ($diagnostic.DoctorOutput) { Write-Host $diagnostic.DoctorOutput }; if ($diagnostic.DevicesOutput) { Write-Host $diagnostic.DevicesOutput }
    Write-Host "Android readiness: toolchain=$($diagnostic.ToolchainReady); licenses=$($diagnostic.LicensesReady); device=$($diagnostic.DeviceReady)" -ForegroundColor Cyan
    if (-not $diagnostic.ToolchainReady -or -not $diagnostic.LicensesReady -or -not $diagnostic.DeviceReady) { Write-SgInstallerWarning "Flutter Android diagnostic: $($diagnostic.Reason)" }
    return $diagnostic
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
    $choice = (Read-Host 'Install the missing Windows IDE toolchains now? [y/N]').Trim()
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
        $config = if ($flutter) { Invoke-SgBoundedProcess -File $flutter -Arguments @('config','--enable-windows-desktop') -TimeoutSeconds 60 } else { $null }
        if (-not $config -or $config.TimedOut -or $config.ExitCode -ne 0) { Write-SgInstallerWarning 'Flutter Windows desktop enablement could not be proven.' }
    }
    if (-not $state.AndroidStudioReady) { Write-SgInstallerWarning 'Android Studio remains pending.' }
    if (-not $state.VisualStudioCppReady) { Write-SgInstallerWarning 'Visual Studio Community with the native desktop C++ workload remains pending.' }
    if ($state.AndroidStudioReady) { Write-Host 'Android Studio is installed. Firebase Device Streaming still requires your own sign-in and Firebase project selection inside Android Studio.' -ForegroundColor Green }
    return $state
}

function Install-SgPlaywrightChromiumForAgents([bool]$AnyAgentReady, [string]$NpmPath, [string]$NpxPath) {
    if (-not $AnyAgentReady -or -not $NpmPath -or -not $NpxPath) { return [pscustomobject]@{ Ready=$false; Version=''; ChromiumPath='' } }
    $resolved = Invoke-SgBoundedProcess $NpmPath @('view','@playwright/mcp','version','--json','--registry=https://registry.npmjs.org/') 45
    $version = if (-not $resolved.TimedOut -and $resolved.ExitCode -eq 0) { $resolved.Output.Trim().Trim('"') } else { '' }
    if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { Write-SgInstallerWarning 'Playwright MCP exact version resolution failed; no agent config was changed.'; return [pscustomobject]@{ Ready=$false; Version=''; ChromiumPath='' } }
    $managedRoot = Join-Path $env:LOCALAPPDATA "ShipGlows\node-tools\playwright-mcp-$version"
    $packageJson = Join-Path $managedRoot 'node_modules\@playwright\mcp\package.json'
    if (-not (Test-Path $packageJson -PathType Leaf)) {
        New-Item -ItemType Directory -Path $managedRoot -Force | Out-Null
        $packageInstall = Invoke-SgBoundedProcess $NpmPath @('install','--prefix',$managedRoot,'--no-save','--ignore-scripts','--registry=https://registry.npmjs.org/',"@playwright/mcp@$version") 600
        if ($packageInstall.TimedOut -or $packageInstall.ExitCode -ne 0) { Write-SgInstallerWarning 'Playwright MCP exact package installation failed.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    }
    $playwrightCommand = Join-Path $managedRoot 'node_modules\.bin\playwright.cmd'
    $browserMetadata = Join-Path $managedRoot 'node_modules\playwright-core\browsers.json'
    if (-not (Test-Path $playwrightCommand -PathType Leaf) -or -not (Test-Path $browserMetadata -PathType Leaf)) { Write-SgInstallerWarning 'Playwright MCP browser metadata is unavailable.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    $metadata = Get-Content -Raw $browserMetadata | ConvertFrom-Json
    $revision = [string](@($metadata.browsers | Where-Object name -eq 'chromium')[0].revision)
    if ($revision -notmatch '^\d+$') { Write-SgInstallerWarning 'Playwright MCP Chromium revision is invalid.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    $install = Invoke-SgBoundedProcess $playwrightCommand @('install','chromium') 900
    $chromium = Get-SgPlaywrightChromiumExecutable -Revision $revision
    $chromiumCheck = if ($chromium) { Invoke-SgBoundedProcess $chromium.FullName @('--version') 30 } else { $null }
    if ($install.TimedOut -or $install.ExitCode -ne 0 -or -not $chromium -or -not (Test-SgChromiumExecutableResult $chromium.FullName $chromiumCheck)) { Write-SgInstallerWarning 'Playwright Chromium executable usability was not proven; Playwright MCP remains unconfigured.'; return [pscustomobject]@{ Ready=$false; Version=$version; ChromiumPath='' } }
    return [pscustomobject]@{ Ready=$true; Version=$version; Revision=$revision; ChromiumPath=[IO.Path]::GetFullPath($chromium.FullName) }
}

function Install-SgAgentMcpConfigs([hashtable]$AgentReady, [string]$DartPath, [string]$NpxPath, $Playwright, [object[]]$StackMcpDefinitions = @()) {
    $results = @{}
    foreach ($agentName in @('Codex','Claude','OpenCode','Kilo','Gemini')) {
        $results[$agentName] = [pscustomobject]@{ Installed=[bool]$AgentReady[$agentName]; McpSummary=if($AgentReady[$agentName]){'pending'}else{'not applicable'}; ReadyServers=@(); PendingServers=@() }
    }
    if (-not $DartPath -or -not $NpxPath) { Write-SgInstallerWarning 'Agent MCP setup is pending because validated Dart or npx is unavailable.'; return $results }
    $serverDefinitions = New-Object Collections.Generic.List[object]
    $serverDefinitions.Add([pscustomobject]@{ Name='dart'; Type='local'; Url=''; Command=$DartPath; Arguments=@('mcp-server','--force-roots-fallback') })
    if ($Playwright.Ready) { $serverDefinitions.Add([pscustomobject]@{ Name='playwright'; Type='local'; Url=''; Command=$NpxPath; Arguments=@('-y','--registry=https://registry.npmjs.org/',"@playwright/mcp@$($Playwright.Version)",'--headless','--browser','chromium') }) }
    foreach ($definition in @($StackMcpDefinitions)) { $serverDefinitions.Add($definition) }
    if ($AgentReady.OpenCode) {
        $plan = Get-SgAgentMcpPlan OpenCode (Get-SgToolPath 'opencode.cmd' $opencodePaths) $DartPath $NpxPath $Playwright.Version $Playwright.Ready $StackMcpDefinitions
        $resolvedConfig = Resolve-SgAgentConfigPath OpenCode $env:USERPROFILE
        $write = Get-SgAgentConfigWritePlan $resolvedConfig.Path $plan.Config
        if ($write.Status -eq 'create') { [void](Write-SgNewAgentConfig $resolvedConfig.Path $plan.Config); $ready = (Get-SgAgentConfigWritePlan $resolvedConfig.Path $plan.Config).Status -eq 'unchanged' } else { $ready = $write.Status -eq 'unchanged' }
        if ($ready) { $results.OpenCode = [pscustomobject]@{ Installed=$true; McpSummary="ready: $(@($serverDefinitions.Name) -join ', ')"; ReadyServers=@($serverDefinitions.Name); PendingServers=@() } }
        else { $results.OpenCode = [pscustomobject]@{ Installed=$true; McpSummary='pending: existing JSON/JSONC preserved'; ReadyServers=@(); PendingServers=@($serverDefinitions.Name) }; Write-SgInstallerWarning "OpenCode v2 MCP pending: $($write.Reason)" }
    }
    if ($AgentReady.Kilo) {
        $kiloCommand = Resolve-SgKiloCommand (Get-SgToolPath 'kilo.cmd' $kiloPaths) (Get-SgToolPath 'kilocode.cmd' $kilocodePaths)
        $plan = Get-SgAgentMcpPlan Kilo $kiloCommand.Path $DartPath $NpxPath $Playwright.Version $Playwright.Ready $StackMcpDefinitions
        $resolvedConfig = Resolve-SgAgentConfigPath Kilo $env:USERPROFILE
        $write = Get-SgAgentConfigWritePlan $resolvedConfig.Path $plan.Config
        if ($write.Status -eq 'create') { [void](Write-SgNewAgentConfig $resolvedConfig.Path $plan.Config); $ready = (Get-SgAgentConfigWritePlan $resolvedConfig.Path $plan.Config).Status -eq 'unchanged' } else { $ready = $write.Status -eq 'unchanged' }
        if ($ready) { $results.Kilo = [pscustomobject]@{ Installed=$true; McpSummary="ready: $(@($serverDefinitions.Name) -join ', ')"; ReadyServers=@($serverDefinitions.Name); PendingServers=@() } }
        else { $results.Kilo = [pscustomobject]@{ Installed=$true; McpSummary='pending: existing JSON/JSONC preserved'; ReadyServers=@(); PendingServers=@($serverDefinitions.Name) }; Write-SgInstallerWarning "Kilo MCP pending: $($write.Reason)" }
    }
    if ($AgentReady.Gemini) {
        $gemini = Get-SgToolPath 'gemini.cmd' $geminiPaths
        $settingsPath = Join-Path $env:USERPROFILE '.gemini\settings.json'
        $readyNames = New-Object Collections.Generic.List[string]; $pendingNames = New-Object Collections.Generic.List[string]
        foreach ($server in $serverDefinitions) {
            $state = Get-SgGeminiMcpConfigState -SettingsPath $settingsPath -Server $server
            if ($state.Status -eq 'missing') {
                $add = Invoke-SgBoundedProcess $gemini (Get-SgGeminiMcpAddArguments $server) 60
                $state = if (-not $add.TimedOut -and $add.ExitCode -eq 0) { Get-SgGeminiMcpConfigState -SettingsPath $settingsPath -Server $server } else { [pscustomobject]@{ Status='pending'; Reason='native Gemini MCP add failed or timed out' } }
            }
            if ($state.Status -eq 'ready') { $readyNames.Add($server.Name) }
            else { $pendingNames.Add($server.Name); Write-SgInstallerWarning "Gemini MCP '$($server.Name)' remains pending: $($state.Reason)." }
        }
        $results.Gemini = [pscustomobject]@{ Installed=$true; McpSummary=if($pendingNames.Count){"partial: ready $($readyNames -join ', '); pending $($pendingNames -join ', ')"}else{"ready: $($readyNames -join ', ')"}; ReadyServers=$readyNames.ToArray(); PendingServers=$pendingNames.ToArray() }
    }
    if ($AgentReady.Claude) {
        $claude = Get-SgToolPath 'claude.cmd' $claudePaths
        $readyNames = New-Object Collections.Generic.List[string]; $pendingNames = New-Object Collections.Generic.List[string]
        foreach ($server in $serverDefinitions) {
            $get = Invoke-SgBoundedProcess $claude @('mcp','get',$server.Name) 30
            if ($get.ExitCode -ne 0) {
                $arguments = if ($server.Type -eq 'remote') { @('mcp','add','--transport','http','--scope','user',$server.Name,$server.Url) } else { @('mcp','add','--transport','stdio','--scope','user',$server.Name,'--',$server.Command) + @($server.Arguments) }
                $add = Invoke-SgBoundedProcess $claude $arguments 60
                $verified = if (-not $add.TimedOut -and $add.ExitCode -eq 0) { Invoke-SgBoundedProcess $claude @('mcp','get',$server.Name) 30 } else { $null }
                $expected = if ($server.Type -eq 'remote') { @($server.Url) } else { @($server.Command) + @($server.Arguments) }
                if (-not $verified -or $verified.ExitCode -ne 0 -or @($expected | Where-Object { -not $verified.Output.Contains([string]$_) }).Count) { $pendingNames.Add($server.Name); Write-SgInstallerWarning "Claude MCP '$($server.Name)' remains pending." } else { $readyNames.Add($server.Name) }
            } else {
                $expected = if ($server.Type -eq 'remote') { @($server.Url) } else { @($server.Command) + @($server.Arguments) }
                $missingArgument = @($expected | Where-Object { -not $get.Output.Contains([string]$_) }).Count -gt 0
                if ($missingArgument) { $pendingNames.Add($server.Name); Write-SgInstallerWarning "Claude MCP '$($server.Name)' exists but exact convergence was not proven; it was preserved pending." } else { $readyNames.Add($server.Name) }
            }
        }
        $results.Claude = [pscustomobject]@{ Installed=$true; McpSummary=if($pendingNames.Count){"partial: ready $($readyNames -join ', '); pending $($pendingNames -join ', ')"}else{"ready: $($readyNames -join ', ')"}; ReadyServers=$readyNames.ToArray(); PendingServers=$pendingNames.ToArray() }
    }
    if ($AgentReady.Codex) {
        $codex = Get-SgToolPath 'codex.cmd' $codexPaths
        $readyNames = New-Object Collections.Generic.List[string]; $pendingNames = New-Object Collections.Generic.List[string]
        foreach ($server in ($serverDefinitions | Where-Object Name -ne 'playwright')) {
            $get = Invoke-SgBoundedProcess $codex @('mcp','get',$server.Name,'--json') 30
            if ($get.ExitCode -ne 0) {
                $addArguments = if ($server.Type -eq 'remote') { @('mcp','add',$server.Name,'--url',$server.Url) } else { @('mcp','add',$server.Name,'--',$server.Command) + @($server.Arguments) }
                $add = Invoke-SgBoundedProcess $codex $addArguments 60
                $verified = if (-not $add.TimedOut -and $add.ExitCode -eq 0) { Invoke-SgBoundedProcess $codex @('mcp','get',$server.Name,'--json') 30 } else { $null }
                $expected = if ($server.Type -eq 'remote') { @($server.Url) } else { @($server.Command) + @($server.Arguments) }
                if (-not $verified -or $verified.ExitCode -ne 0 -or @($expected | Where-Object { -not $verified.Output.Contains([string]$_) }).Count) { $pendingNames.Add($server.Name); Write-SgInstallerWarning "Codex MCP '$($server.Name)' remains pending." } else { $readyNames.Add($server.Name) }
            } else {
                $expected = if ($server.Type -eq 'remote') { @($server.Url) } else { @($server.Command) + @($server.Arguments) }
                if (@($expected | Where-Object { -not $get.Output.Contains([string]$_) }).Count) { $pendingNames.Add($server.Name); Write-SgInstallerWarning "Codex MCP '$($server.Name)' exists but exact convergence was not proven; it was preserved pending." } else { $readyNames.Add($server.Name) }
            }
        }
        if ($Playwright.Ready) {
            $configPath = Join-Path $env:USERPROFILE '.codex\config.toml'
            [void](Set-SgCodexPlaywrightMcpConfig $configPath $NpxPath $Playwright.Version $Playwright.ChromiumPath)
            $config = Get-SgCodexPlaywrightMcpConfig $configPath
            if ($config -and $config.Enabled -and $config.Command -eq $NpxPath -and ($config.Arguments -contains "@playwright/mcp@$($Playwright.Version)")) { $readyNames.Add('playwright') } else { $pendingNames.Add('playwright') }
        }
        $results.Codex = [pscustomobject]@{ Installed=$true; McpSummary=if($pendingNames.Count){"partial: ready $($readyNames -join ', '); pending $($pendingNames -join ', ')"}else{"ready: $($readyNames -join ', ')"}; ReadyServers=$readyNames.ToArray(); PendingServers=$pendingNames.ToArray() }
    }
    return $results
}

function Install-SgManagedPlaywrightRuntimes([string]$NpmPath) {
    $empty=[pscustomobject]@{StableReady='no';StableVersion='not available';StableRevision='not available';StablePath='';AgentCliReady='no';AgentCliVersion='not available';AgentCliPath='';MotionReady='no'}
    if(-not $NpmPath){Write-SgInstallerWarning 'Managed Playwright runtimes are pending because npm is unavailable.';return $empty}
    try {
        $stableVersion=Resolve-SgNpmVersion $NpmPath 'playwright'
        $agentVersion=Resolve-SgNpmVersion $NpmPath '@playwright/cli'
        $root=Join-Path $env:LOCALAPPDATA 'ShipGlows\node-tools'
        $stableRoot=Join-Path $root "playwright-$stableVersion"
        $agentRoot=Join-Path $root "playwright-cli-$agentVersion"
        foreach($install in @(@{Root=$stableRoot;Package='playwright';Version=$stableVersion},@{Root=$agentRoot;Package='@playwright/cli';Version=$agentVersion})){
            $packageJson=Join-Path (Join-Path $install.Root 'node_modules') (Join-Path $install.Package 'package.json')
            if(-not (Test-Path $packageJson -PathType Leaf)){
                New-Item -ItemType Directory -Path $install.Root -Force|Out-Null
                $result=Invoke-SgBoundedProcess $NpmPath @('install','--prefix',$install.Root,'--no-save','--ignore-scripts','--registry=https://registry.npmjs.org/',"$($install.Package)@$($install.Version)") 600
                if($result.TimedOut -or $result.ExitCode -ne 0){throw "Exact $($install.Package) installation failed."}
            }
        }
        $stableCommand=Join-Path $stableRoot 'node_modules\.bin\playwright.cmd'
        $agentCommand=Join-Path $agentRoot 'node_modules\.bin\playwright-cli.cmd'
        $browserMetadata=Join-Path $stableRoot 'node_modules\playwright-core\browsers.json'
        if(-not (Test-Path $stableCommand -PathType Leaf) -or -not (Test-Path $agentCommand -PathType Leaf) -or -not (Test-Path $browserMetadata -PathType Leaf)){throw 'Managed Playwright commands or browser metadata are missing.'}
        $metadata=Get-Content -Raw $browserMetadata|ConvertFrom-Json
        $revision=[string](@($metadata.browsers|Where-Object name -eq 'chromium')[0].revision)
        if($revision -notmatch '^\d+$'){throw 'Managed Playwright Chromium revision is invalid.'}
        $browser=Join-Path $env:LOCALAPPDATA "ms-playwright\chromium-$revision\chrome-win64\chrome.exe"
        if(-not (Test-Path $browser -PathType Leaf)){
            $installBrowser=Invoke-SgBoundedProcess $stableCommand @('install','chromium') 900
            if($installBrowser.TimedOut -or $installBrowser.ExitCode -ne 0){throw 'Managed Playwright Chromium installation failed.'}
        }
        $agentBrowserInstall=Invoke-SgBoundedProcess $agentCommand @('install-browser') 900
        if($agentBrowserInstall.TimedOut -or $agentBrowserInstall.ExitCode -ne 0){throw 'Managed Playwright Agent CLI browser installation failed.'}
        $stableCheck=Invoke-SgBoundedProcess $stableCommand @('--version') 30
        $browserCheck=if(Test-Path $browser -PathType Leaf){Invoke-SgBoundedProcess $browser @('--version') 30}else{$null}
        $stableReady=-not $stableCheck.TimedOut -and $stableCheck.ExitCode -eq 0 -and $stableCheck.Output -match [regex]::Escape($stableVersion)
        $agentPackageVersion=[string]((Get-Content -Raw (Join-Path $agentRoot 'node_modules\@playwright\cli\package.json')|ConvertFrom-Json).version)
        $agentReady=-not $agentBrowserInstall.TimedOut -and $agentBrowserInstall.ExitCode -eq 0 -and $agentPackageVersion -eq $agentVersion
        $browserReady=$browserCheck -and -not $browserCheck.TimedOut -and $browserCheck.ExitCode -eq 0
        return [pscustomobject]@{StableReady=if($stableReady){'yes'}else{'no'};StableVersion=$stableVersion;StableRevision=$revision;StablePath=$stableCommand;AgentCliReady=if($agentReady){'yes'}else{'no'};AgentCliVersion=$agentVersion;AgentCliPath=$agentCommand;MotionReady=if($stableReady -and $browserReady){'yes'}else{'no'}}
    } catch {Write-SgInstallerWarning "Managed Playwright runtime pending: $($_.Exception.Message)";return $empty}
}

function Resolve-SgNpmVersion([string]$NpmPath, [string]$PackageName) {
    $result = Invoke-SgBoundedProcess $NpmPath @('view',$PackageName,'version','--json','--registry=https://registry.npmjs.org/') 45
    $version = if (-not $result.TimedOut -and $result.ExitCode -eq 0) { $result.Output.Trim().Trim('"') } else { '' }
    if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw "Exact version resolution failed for $PackageName." }
    return $version
}

function Install-SgDetectedServiceClis([string]$WorkspacePath, [string]$DartPath, [string]$NpmPath, [string]$NpxPath) {
    $needs = Get-SgProjectServiceNeeds -Workspace $WorkspacePath
    $versions = @{}
    $resolvedNeeds = [pscustomobject]@{ Firebase=$false; FlutterFire=$false; Supabase=$false; Convex=$false; Vercel=$false; Clerk=$false; AndroidNative=$needs.AndroidNative }
    foreach ($definition in @(
        @{ Need='Firebase'; Package='firebase-tools' },
        @{ Need='Supabase'; Package='supabase' },
        @{ Need='Convex'; Package='convex' },
        @{ Need='Vercel'; Package='vercel' },
        @{ Need='Clerk'; Package='clerk' }
    )) {
        if (-not [bool]$needs.($definition.Need)) { continue }
        try { $versions[$definition.Need] = Resolve-SgNpmVersion $NpmPath $definition.Package; $resolvedNeeds.($definition.Need) = $true }
        catch { Write-SgInstallerWarning "$($definition.Need) exact-version resolution failed; its CLI and MCP remain pending." }
    }
    if ($needs.FlutterFire) {
        try {
            $pub = Invoke-RestMethod -UseBasicParsing -Uri 'https://pub.dev/api/packages/flutterfire_cli' -TimeoutSec 45
            $version = [string]$pub.latest.version
            if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw 'pub.dev returned no exact FlutterFire version.' }
            $versions.FlutterFire = $version; $resolvedNeeds.FlutterFire = $true
        } catch { Write-SgInstallerWarning 'FlutterFire exact-version resolution failed; its CLI remains pending.' }
    }
    $states = [ordered]@{
        Firebase=if($needs.Firebase){'detected; pending'}else{'not detected'}
        FlutterFire=if($needs.FlutterFire){'detected; pending'}else{'not detected'}
        Convex=if($needs.Convex){'detected; pending'}else{'not detected'}
        Vercel=if($needs.Vercel){'detected; pending'}else{'not detected'}
        Supabase=if($needs.Supabase){'detected; pending'}else{'not detected'}
        Clerk=if($needs.Clerk){'detected; pending'}else{'not detected'}
        AndroidNative=if($needs.AndroidNative){'detected; project-specific NDK/CMake versions must be reviewed'}else{'not detected'}
    }
    foreach ($item in @(Get-SgServiceCliPlan $resolvedNeeds $versions)) {
        $install = $null; $verify = $null; $exe = ''
        if ($item.Name -eq 'firebase') {
            $install = Invoke-SgBoundedProcess $NpmPath @('install','--global',"firebase-tools@$($item.Version)",'--registry=https://registry.npmjs.org/') 600
            $exe = Get-SgToolPath 'firebase.cmd' @((Join-Path $env:APPDATA 'npm\firebase.cmd'))
            $verify = if ($exe) { Invoke-SgBoundedProcess $exe @('--version') 30 } else { $null }
        } elseif ($item.Name -eq 'flutterfire') {
            $install = Invoke-SgBoundedProcess $DartPath @('pub','global','activate','flutterfire_cli',$item.Version) 600
            $pubBin = Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin'; Add-SgUserPathEntry $pubBin
            $exe = Get-SgToolPath 'flutterfire.bat' @((Join-Path $pubBin 'flutterfire.bat'))
            $verify = if ($exe) { Invoke-SgBoundedProcess $exe @('--version') 30 } else { $null }
        } elseif ($item.Name -in @('supabase','convex')) {
            $install = Invoke-SgBoundedProcess $NpxPath @('-y','--registry=https://registry.npmjs.org/',"supabase@$($item.Version)",'--version') 300
            $package = $item.Package
            if ($item.Name -eq 'convex') { $install = Invoke-SgBoundedProcess $NpxPath @('-y','--registry=https://registry.npmjs.org/',"convex@$($item.Version)",'--version') 300 }
            $wrapper = Join-Path $runtimeDir "$($item.Name).cmd"
            $wrapperContent = "@echo off`r`n@call `"$NpxPath`" -y --registry=https://registry.npmjs.org/ $package@$($item.Version) %*`r`n"
            if (-not (Test-Path -LiteralPath $wrapper) -or [IO.File]::ReadAllText($wrapper) -cne $wrapperContent) { [IO.File]::WriteAllText($wrapper,$wrapperContent,[Text.Encoding]::ASCII) }
            $exe = $wrapper; $verify = Invoke-SgBoundedProcess $exe @('--version') 300
        } else {
            $install = Invoke-SgBoundedProcess $NpmPath @('install','--global',"$($item.Package)@$($item.Version)",'--registry=https://registry.npmjs.org/') 600
            $exe = Get-SgToolPath "$($item.Name).cmd" @((Join-Path $env:APPDATA "npm\$($item.Name).cmd"))
            $verify = if ($exe) { Invoke-SgBoundedProcess $exe @('--version') 30 } else { $null }
        }
        $ready = Test-SgServiceCliResult $install $verify $exe $item.Version
        $property = if ($item.Name -eq 'flutterfire') { 'FlutterFire' } else { $item.Name.Substring(0,1).ToUpperInvariant() + $item.Name.Substring(1) }
        $states[$property] = if ($ready) { "ready ($($item.Version))" } else { "pending ($($item.Version))" }
        if (-not $ready) { Write-SgInstallerWarning "$($item.Name) CLI exact-version installation or executable verification failed." }
    }
    return [pscustomobject]@{ Needs=$resolvedNeeds; DetectedNeeds=$needs; Versions=$versions; Firebase=$states.Firebase; FlutterFire=$states.FlutterFire; Convex=$states.Convex; Vercel=$states.Vercel; Supabase=$states.Supabase; Clerk=$states.Clerk; AndroidNative=$states.AndroidNative }
}

Remove-SgLegacyRuntime
Remove-SgObsoleteProfileCommand
Install-SgCommandWrappers
[void](Install-SgGum)
$programFiles = [Environment]::GetFolderPath('ProgramFiles')
$programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
$gitPaths = @((Join-Path $programFiles 'Git\cmd\git.exe'), (Join-Path $programFilesX86 'Git\cmd\git.exe'))
$ghPaths = @((Join-Path $programFiles 'GitHub CLI\gh.exe'), (Join-Path $programFilesX86 'GitHub CLI\gh.exe'))
$fzfPaths = @((Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\fzf.exe'))
$nodePaths = @((Join-Path $programFiles 'nodejs\node.exe'), (Join-Path $programFilesX86 'nodejs\node.exe'))
$npmPaths = @((Join-Path $programFiles 'nodejs\npm.cmd'), (Join-Path $programFilesX86 'nodejs\npm.cmd'))
$npxPaths = @((Join-Path $programFiles 'nodejs\npx.cmd'), (Join-Path $programFilesX86 'nodejs\npx.cmd'))
$corepackPaths = @((Join-Path $programFiles 'nodejs\corepack.cmd'), (Join-Path $programFilesX86 'nodejs\corepack.cmd'), (Join-Path $env:APPDATA 'npm\corepack.cmd'))
$pnpmPaths = @((Join-Path $env:APPDATA 'npm\pnpm.cmd'))
$uvPaths = @((Join-Path $env:USERPROFILE '.local\bin\uv.exe'), (Join-Path $env:USERPROFILE '.cargo\bin\uv.exe'))
$pythonPaths = @((Join-Path $env:USERPROFILE '.local\bin\python.exe'))
$flutterPaths = @((Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.bat'), (Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.exe'))
$agentBinDirectory = Join-Path $env:APPDATA 'npm'
$pnpmAgentBinDirectory = Join-Path $env:LOCALAPPDATA 'pnpm\bin'
$claudePaths = @((Join-Path $agentBinDirectory 'claude.cmd'), (Join-Path $pnpmAgentBinDirectory 'claude.cmd'))
$codexPaths = @((Join-Path $agentBinDirectory 'codex.cmd'), (Join-Path $pnpmAgentBinDirectory 'codex.cmd'))
$opencodePaths = @((Join-Path $agentBinDirectory 'opencode.cmd'), (Join-Path $pnpmAgentBinDirectory 'opencode.cmd'))
$kiloPaths = @((Join-Path $agentBinDirectory 'kilo.cmd'), (Join-Path $pnpmAgentBinDirectory 'kilo.cmd'))
$kilocodePaths = @((Join-Path $agentBinDirectory 'kilocode.cmd'), (Join-Path $pnpmAgentBinDirectory 'kilocode.cmd'))
$geminiPaths = @((Join-Path $agentBinDirectory 'gemini.cmd'), (Join-Path $pnpmAgentBinDirectory 'gemini.cmd'))
Write-Host 'Preparing Windows developer tools. This step can take a few minutes on the first installation.' -ForegroundColor Yellow
[void](Install-SgWingetPackage 'git.exe' 'Git.Git' $gitPaths)
[void](Install-SgWingetPackage 'gh.exe' 'GitHub.cli' $ghPaths)
[void](Install-SgWingetPackage 'fzf.exe' 'junegunn.fzf' $fzfPaths)
[void](Install-SgWingetPackage 'node.exe' 'OpenJS.NodeJS.LTS' $nodePaths)
$pnpmReady = Install-SgPnpm $npmPaths $corepackPaths $pnpmPaths
$uvReady = Install-SgWingetPackage 'uv.exe' 'astral-sh.uv' $uvPaths
if (-not $uvReady) { throw 'ShipGlows requires uv to provide a functional default Python runtime.' }
$pythonInfo = Install-SgDefaultPython $uvPaths $pythonPaths
Assert-SgEnvironmentPythonPackage $pythonInfo.Path (Join-Path $ShipglowsDir 'cli\environment')
$flutterReady = Install-SgFlutter $flutterPaths $gitPaths
$androidInfo = Install-SgAndroidToolchain $flutterReady $flutterPaths
$ideInfo = Install-SgWindowsIdeToolchains $flutterReady $flutterPaths

Write-Host ''
Write-Host 'Preparing coding-agent CLIs and MCPs (no authentication is started)...' -ForegroundColor Yellow
$initialAgentReady = @{
    Codex = Test-SgToolRuns 'codex.cmd' $codexPaths
    Claude = Test-SgToolRuns 'claude.cmd' $claudePaths
    OpenCode = Test-SgToolRuns 'opencode.cmd' $opencodePaths
    Kilo = (Test-SgToolRuns 'kilo.cmd' $kiloPaths) -or (Test-SgToolRuns 'kilocode.cmd' $kilocodePaths)
    Gemini = Test-SgToolRuns 'gemini.cmd' $geminiPaths
}
$agentReady = Install-SgMissingAgentClis (Get-SgToolPath 'npm.cmd' $npmPaths) $initialAgentReady
$codexReady = [bool]$agentReady.Codex
$claudeReady = [bool]$agentReady.Claude
$opencodeReady = [bool]$agentReady.OpenCode
$kiloResolved = Resolve-SgKiloCommand (Get-SgToolPath 'kilo.cmd' $kiloPaths) (Get-SgToolPath 'kilocode.cmd' $kilocodePaths)
$kiloReady = [bool]$agentReady.Kilo
$geminiReady = [bool]$agentReady.Gemini
if ($codexReady -and ($env:SHIPGLOWS_CODEX_PERMISSION_MODE -or $env:SHIPGLOWS_AUTONOMY_MODE)) {
    $codexConfigPath = Join-Path $env:USERPROFILE '.codex\config.toml'
    $codexPermissionMode = Resolve-SgCodexPermissionMode $codexConfigPath
    if ($codexPermissionMode -ne 'keep') { [void](Set-SgCodexPermissionMode $codexPermissionMode $codexConfigPath) }
}
$dartPath = if ($flutterReady) { Join-Path (Split-Path (Get-SgToolPath 'flutter.bat' $flutterPaths) -Parent) 'dart.bat' } else { '' }
[void]$androidInfo
$nativeNpx = Get-SgNativeNpxPath $npxPaths
$serviceInfo = Install-SgDetectedServiceClis $Workspace $dartPath (Get-SgToolPath 'npm.cmd' $npmPaths) $nativeNpx
$stackMcpDefinitions = @(Get-SgStackMcpDefinitions $serviceInfo.Needs $serviceInfo.Versions $nativeNpx)
$playwright = Install-SgPlaywrightChromiumForAgents ($codexReady -or $claudeReady -or $opencodeReady -or $kiloReady -or $geminiReady) (Get-SgToolPath 'npm.cmd' $npmPaths) $nativeNpx
$playwrightRuntime = Install-SgManagedPlaywrightRuntimes (Get-SgToolPath 'npm.cmd' $npmPaths)
$agentInfo = Install-SgAgentMcpConfigs @{ Codex=$codexReady; Claude=$claudeReady; OpenCode=$opencodeReady; Kilo=$kiloReady; Gemini=$geminiReady } $dartPath $nativeNpx $playwright $stackMcpDefinitions
$playwrightConfigured = @($agentInfo.Values | Where-Object { $_.ReadyServers -contains 'playwright' }).Count -gt 0
$playwrightPending = @($agentInfo.Values | Where-Object { $_.PendingServers -contains 'playwright' }).Count -gt 0
$playwrightInfo = [pscustomobject]@{ Installed=$playwright.Ready; McpConfigured=$playwrightConfigured; McpVerified=$playwrightConfigured -and -not $playwrightPending; ConfigPath='per-agent; readiness listed below'; ChromiumPath=$playwright.ChromiumPath }
$environmentPath = Write-SgGlobalDevelopmentEnvironment $agentInfo $playwrightInfo $playwrightRuntime $pythonInfo $flutterReady $androidInfo $ideInfo $serviceInfo (Test-SgWindowsDeveloperMode)
Write-Host "ShipGlows development environment recorded: $environmentPath" -ForegroundColor Green
$agentInstructionChanges = @(Install-SgAgentEnvironmentInstructions -UserProfile $env:USERPROFILE -AgentReady @{ Codex=$codexReady; Claude=$claudeReady; OpenCode=$opencodeReady; Kilo=$kiloReady; Gemini=$geminiReady })
if ($agentInstructionChanges.Count) { Write-Host "ShipGlows tool context installed for $($agentInstructionChanges.Count) coding agent(s)." -ForegroundColor Green }
[void](Invoke-SgProjectEnvironmentMigration (Join-Path $runtimeDir 'ShipGlows.DevServer.psm1'))

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
if($playwrightRuntime.StablePath){[void](Install-SgApplicationCommandWrapper 'playwright' 'playwright.cmd' @($playwrightRuntime.StablePath))}
if($playwrightRuntime.AgentCliPath){[void](Install-SgApplicationCommandWrapper 'playwright-cli' 'playwright-cli.cmd' @($playwrightRuntime.AgentCliPath))}
[void](Install-SgAgentShortcut 'c' 'claude')
[void](Install-SgAgentShortcut 'co' 'codex')
[void](Install-SgAgentShortcut 'cor' 'codex' @('resume'))
[void](Install-SgAgentShortcut 'oc' 'opencode')
$kiloShortcutTarget = if (Test-SgToolRuns 'kilo.cmd' $kiloPaths) { 'kilo' } else { 'kilocode' }
[void](Install-SgAgentShortcut 'kc' $kiloShortcutTarget)
[void](Install-SgShellShortcut 're' 'powershell.exe -NoLogo -NoExit -ExecutionPolicy Bypass')
[void](Install-SgShellShortcut 'ch' 'powershell.exe -NoLogo -NoExit -ExecutionPolicy Bypass -Command "Clear-History; try { $historyPath = (Get-PSReadLineOption).HistorySavePath; if ($historyPath -and (Test-Path -LiteralPath $historyPath)) { Remove-Item -LiteralPath $historyPath -Force } } catch { }; Clear-Host"')
[void](Install-SgShellShortcut 'n' 'nvim %*')
[void](Install-SgShellShortcut 'gpush' 'git push %*')
[void](Install-SgGitPushProfileShortcut)
Add-SgRuntimeToUserPath

Write-Host "ShipGlows Windows DevServer installed." -ForegroundColor Green
Write-Host "Workspace: $Workspace"
Write-Host 'Commands: s (short) or shipglows-dev'
Write-Host ''
Write-Host 'Dependency check:' -ForegroundColor Yellow
foreach ($tool in @('gum','fzf','git','gh','node','npm','pnpm','uv','flutter')) {
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
        default { @() }
    }
    $executable = switch ($tool) {
        'npm' { 'npm.cmd'; break }
        'pnpm' { 'pnpm.cmd'; break }
        'flutter' { 'flutter.bat'; break }
        default { "$tool.exe" }
    }
    if ($tool -eq 'pnpm') { $found = $pnpmReady -and (Test-SgToolRuns $executable $knownPaths) }
    else { $found = Test-SgTool $executable $knownPaths }
    if ($found) { Write-Host "  [ok]   $tool" -ForegroundColor Green }
    else { Write-Host "  [miss] $tool (install it or use the project-specific setup instructions)" -ForegroundColor Yellow }
}
Write-Host 'Run now: s'
