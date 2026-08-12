[CmdletBinding()]
param(
    [string]$ShipglowsDir = (Join-Path $env:USERPROFILE '.shipglows'),
    [string]$Workspace = (Join-Path $env:USERPROFILE 'ShipGlows'),
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$sourceDir = Join-Path $ShipglowsDir 'cli\windows'
$runtimeDir = Join-Path $ShipglowsDir 'bin'
$gumVersion = '0.17.0'
$gumSha256 = 'B2BE80531C6BABC8D4E0E6CA95773D58118A2E1582AE006AACE08DBC55503072'
New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
New-Item -ItemType Directory -Path $Workspace -Force | Out-Null
$defaultHiddenRoot = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.shipglows')).TrimEnd('\')
if ([IO.Path]::GetFullPath($ShipglowsDir).TrimEnd('\') -eq $defaultHiddenRoot) {
    $installRootItem = Get-Item -LiteralPath $ShipglowsDir -Force
    $installRootItem.Attributes = $installRootItem.Attributes -bor [IO.FileAttributes]::Hidden
}

function Write-SgInstallerWarning([string]$Message) {
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

$launcher = Join-Path $runtimeDir 'shipglows-devserver.ps1'
Copy-Item -LiteralPath (Join-Path $sourceDir 'ShipGlows.DevServer.psm1') -Destination $runtimeDir -Force
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

function Remove-SgLegacyVisibleRuntime {
    if ([IO.Path]::GetFullPath($ShipglowsDir).TrimEnd('\') -ne $defaultHiddenRoot) { return }
    $legacyRoot = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE 'ShipGlows')).TrimEnd('\')
    $legacyBin = Join-Path $legacyRoot 'bin'
    $currentUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $keptPathEntries = @($currentUserPath -split ';' | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and
        -not ([IO.Path]::GetFullPath($_).TrimEnd('\') -eq $legacyBin)
    })
    [Environment]::SetEnvironmentVariable('Path', ($keptPathEntries -join ';'), 'User')
    foreach ($technicalDirectory in @('bin', 'cli', 'local')) {
        $legacyPath = Join-Path $legacyRoot $technicalDirectory
        if (Test-Path -LiteralPath $legacyPath) {
            Remove-Item -LiteralPath $legacyPath -Recurse -Force
            Write-Host "Removed legacy visible ShipGlows runtime: $legacyPath" -ForegroundColor DarkGray
        }
    }
    $legacyWorkspace = Join-Path $legacyRoot 'workspace'
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

    if (Test-Path Function:gp) {
        Write-SgInstallerWarning "The PowerShell function 'gp' already exists. ShipGlows preserved it; gpush remains available."
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
    $withoutManagedBlock = [regex]::Replace($existing, $managedPattern, '').TrimEnd()
    $managedBlock = @'
# >>> ShipGlows Git shortcuts >>>
if (Test-Path Alias:gp) { Remove-Item Alias:gp -Force -ErrorAction SilentlyContinue }
function global:gp { & git push @args }
# <<< ShipGlows Git shortcuts <<<
'@
    $next = if ($withoutManagedBlock) {
        $withoutManagedBlock + [Environment]::NewLine + [Environment]::NewLine + $managedBlock + [Environment]::NewLine
    } else {
        $managedBlock + [Environment]::NewLine
    }
    Set-Content -LiteralPath $profilePath -Value $next -Encoding UTF8
    Write-Host "PowerShell shortcut installed: gp -> git push (active in new shells)." -ForegroundColor Green
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

function Install-SgOptionalAgent([string]$DisplayName, [string]$CommandName, [string]$PackageName, [string[]]$KnownPaths, [string[]]$PnpmPaths, [string[]]$NpmPaths, [string]$CompatibilityNote = '', [switch]$AllowInstallScripts) {
    if (Test-SgToolRuns $CommandName $KnownPaths) {
        Write-Host "$DisplayName is already installed." -ForegroundColor Green
        return $true
    }

    if ([Console]::IsInputRedirected) {
        Write-Host "$DisplayName skipped because this is a non-interactive installation. Rerun the full installer to choose optional agents." -ForegroundColor Yellow
        return $false
    }

    Write-Host ''
    Write-Host "$DisplayName is optional." -ForegroundColor Yellow
    if ($CompatibilityNote) { Write-Host $CompatibilityNote -ForegroundColor DarkYellow }
    Write-Host "ShipGlows only installs the CLI. Authentication happens when you first run $CommandName; ShipGlows never asks for or stores credentials." -ForegroundColor DarkGray
    $answer = (Read-Host "Install $DisplayName now? [y/N]").Trim().ToLowerInvariant()
    if ($answer -notin @('y', 'yes')) {
        Write-Host "$DisplayName skipped. Rerun the full installer when you want it." -ForegroundColor Yellow
        return $false
    }

    $pnpm = Get-SgToolPath 'pnpm.cmd' $PnpmPaths
    $npm = Get-SgToolPath 'npm.cmd' $NpmPaths
    if (-not $pnpm -and -not $npm) {
        Write-SgInstallerWarning "$DisplayName could not be installed because neither pnpm nor npm is available."
        return $false
    }

    try {
        if ($pnpm -and -not $AllowInstallScripts) {
            Write-Host "Installing $DisplayName with pnpm. This can take a few minutes; keep this window open..." -ForegroundColor Cyan
            & $pnpm add --global $PackageName | Out-Host
            if ($LASTEXITCODE -eq 0) {
                Update-SgProcessPath
                if (Test-SgToolRuns $CommandName $KnownPaths) {
                    Write-Host "$DisplayName installed." -ForegroundColor Green
                    return $true
                }
            }
            Write-SgInstallerWarning "pnpm could not make $DisplayName available here; trying the npm fallback."
        }

        if (-not $npm) { throw "$DisplayName was not discoverable after pnpm and npm is unavailable." }
        Write-Host "Installing $DisplayName with npm fallback. This can take a few minutes; keep this window open..." -ForegroundColor Cyan
        if ($AllowInstallScripts) {
            & $npm install --global "--allow-scripts=$PackageName" $PackageName | Out-Host
        } else {
            & $npm install --global $PackageName | Out-Host
        }
        if ($LASTEXITCODE -ne 0) { throw "$DisplayName installation returned exit code $LASTEXITCODE." }
        Update-SgProcessPath
        if (-not (Test-SgToolRuns $CommandName $KnownPaths)) { throw "$DisplayName was installed but its version check failed." }
        Write-Host "$DisplayName installed." -ForegroundColor Green
        return $true
    } catch {
        Write-SgInstallerWarning "$DisplayName could not be installed automatically: $($_.Exception.Message)"
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
        { $_ -in @('', 'ask') } { break }
        default {
            Write-SgInstallerWarning "Unknown SHIPGLOWS_CODEX_PERMISSION_MODE value '$requested'; the existing Codex configuration was kept."
            return 'keep'
        }
    }

    if ([Console]::IsInputRedirected) {
        Write-Host 'Codex permission configuration kept because this is a non-interactive installation. Set SHIPGLOWS_CODEX_PERMISSION_MODE=workspace or full to automate it.' -ForegroundColor Yellow
        return 'keep'
    }

    $current = Get-SgCodexPermissionModeFromConfig $ConfigPath
    $defaultChoice = if ($current -eq 'full') { '2' } else { '1' }
    Write-Host ''
    Write-Host 'Codex permissions' -ForegroundColor Yellow
    Write-Host '  1) Workspace access (recommended): edit projects, ask before leaving the workspace or using restricted access.'
    Write-Host '  2) Full access: no sandbox and no approval prompts. Use only with trusted repositories.'
    Write-Host '  0) Keep the existing Codex configuration unchanged.'
    if ($current) { Write-Host "Current mode: $current" -ForegroundColor DarkGray }
    while ($true) {
        $answer = (Read-Host "Choose 0, 1, or 2 [$defaultChoice]").Trim()
        if (-not $answer) { $answer = $defaultChoice }
        switch ($answer) {
            '0' { return 'keep' }
            '1' { return 'workspace' }
            '2' { return 'full' }
            default { Write-Host 'Enter 0, 1, or 2.' -ForegroundColor Yellow }
        }
    }
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
    if ($existing) {
        $backupPath = "$ConfigPath.shipglows-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $ConfigPath -Destination $backupPath
        Write-Host "Existing Codex configuration backed up to $backupPath" -ForegroundColor DarkGray
    }
    [IO.File]::WriteAllText($ConfigPath, $next, [Text.UTF8Encoding]::new($false))
    Write-Host "Codex permissions configured: $Mode." -ForegroundColor Green
    return $true
}

function Install-SgFlutter([string[]]$FlutterPaths, [string[]]$GitPaths) {
    if (Test-SgTool 'flutter.bat' $FlutterPaths) {
        Write-Host 'Flutter Web SDK is already installed.' -ForegroundColor Green
        return $true
    }

    Write-Host ''
    Write-Host 'Flutter Web SDK is optional and is a larger download.' -ForegroundColor Yellow
    $answer = (Read-Host 'Install Flutter Web SDK now? [y/N]').Trim().ToLowerInvariant()
    if ($answer -notin @('y', 'yes')) {
        Write-Host 'Flutter Web SDK skipped. Rerun the full installer when you need it.' -ForegroundColor Yellow
        return $false
    }

    $git = Get-SgToolPath 'git.exe' $GitPaths
    if (-not $git) {
        Write-SgInstallerWarning 'Flutter Web SDK could not be installed because Git is unavailable.'
        return $false
    }

    $flutterDirectory = Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter'
    $flutterBin = Join-Path $flutterDirectory 'bin'
    $flutterBatch = Join-Path $flutterBin 'flutter.bat'
    try {
        if (-not (Test-Path -LiteralPath $flutterDirectory -PathType Container)) {
            Write-Host 'Downloading Flutter stable. This can take several minutes; keep this window open...' -ForegroundColor Cyan
            & $git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $flutterDirectory | Out-Host
            if ($LASTEXITCODE -ne 0) { throw "Flutter download returned exit code $LASTEXITCODE." }
        }
        if (-not (Test-Path -LiteralPath $flutterBatch -PathType Leaf)) {
            throw "Flutter was not found in $flutterDirectory. The existing folder was left untouched."
        }

        Add-SgUserPathEntry $flutterBin
        & $flutterBatch config --enable-web | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "Flutter Web configuration returned exit code $LASTEXITCODE." }
        Write-Host 'Flutter Web SDK installed and web support enabled.' -ForegroundColor Green
        return $true
    } catch {
        Write-SgInstallerWarning "Flutter Web SDK could not be installed automatically: $($_.Exception.Message)"
        return $false
    }
}

Remove-SgLegacyVisibleRuntime
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
$flutterPaths = @((Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.bat'), (Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.exe'))
$agentBinDirectory = Join-Path $env:APPDATA 'npm'
$pnpmAgentBinDirectory = Join-Path $env:LOCALAPPDATA 'pnpm\bin'
$claudePaths = @((Join-Path $agentBinDirectory 'claude.cmd'), (Join-Path $pnpmAgentBinDirectory 'claude.cmd'))
$codexPaths = @((Join-Path $agentBinDirectory 'codex.cmd'), (Join-Path $pnpmAgentBinDirectory 'codex.cmd'))
$opencodePaths = @((Join-Path $agentBinDirectory 'opencode.cmd'), (Join-Path $pnpmAgentBinDirectory 'opencode.cmd'))
$kilocodePaths = @((Join-Path $agentBinDirectory 'kilocode.cmd'), (Join-Path $pnpmAgentBinDirectory 'kilocode.cmd'))
Write-Host 'Preparing Windows developer tools. This step can take a few minutes on the first installation.' -ForegroundColor Yellow
[void](Install-SgWingetPackage 'git.exe' 'Git.Git' $gitPaths)
[void](Install-SgWingetPackage 'gh.exe' 'GitHub.cli' $ghPaths)
[void](Install-SgWingetPackage 'fzf.exe' 'junegunn.fzf' $fzfPaths)
[void](Install-SgWingetPackage 'node.exe' 'OpenJS.NodeJS.LTS' $nodePaths)
$pnpmReady = Install-SgPnpm $npmPaths $corepackPaths $pnpmPaths
[void](Install-SgWingetPackage 'uv.exe' 'astral-sh.uv' $uvPaths)
[void](Install-SgFlutter $flutterPaths $gitPaths)

Write-Host ''
Write-Host 'Optional coding agents' -ForegroundColor Yellow
Write-Host 'Each agent is a separate choice. Press Enter to skip an agent.' -ForegroundColor DarkGray
$codexReady = Install-SgOptionalAgent 'Codex CLI' 'codex.cmd' '@openai/codex' $codexPaths $pnpmPaths $npmPaths
[void](Install-SgOptionalAgent 'Claude Code CLI' 'claude.cmd' '@anthropic-ai/claude-code' $claudePaths $pnpmPaths $npmPaths -CompatibilityNote 'On native Windows, Claude Code uses the Git for Windows terminal environment.' -AllowInstallScripts)
[void](Install-SgOptionalAgent 'OpenCode CLI' 'opencode.cmd' 'opencode-ai' $opencodePaths $pnpmPaths $npmPaths -CompatibilityNote 'Native Windows support may vary by OpenCode release.' -AllowInstallScripts)
[void](Install-SgOptionalAgent 'KiloCode CLI' 'kilocode.cmd' '@kilocode/cli' $kilocodePaths $pnpmPaths $npmPaths -AllowInstallScripts)
if ($codexReady) {
    $codexConfigPath = Join-Path $env:USERPROFILE '.codex\config.toml'
    $codexPermissionMode = Resolve-SgCodexPermissionMode $codexConfigPath
    if ($codexPermissionMode -ne 'keep') { [void](Set-SgCodexPermissionMode $codexPermissionMode $codexConfigPath) }
}

Write-Host ''
Write-Host 'Installing PowerShell-safe application commands...' -ForegroundColor Yellow
[void](Disable-SgBlockedPowerShellShim 'npm' $npmPaths)
[void](Disable-SgBlockedPowerShellShim 'npx' $npxPaths)
[void](Disable-SgBlockedPowerShellShim 'corepack' $corepackPaths)
[void](Disable-SgBlockedPowerShellShim 'pnpm' $pnpmPaths)
[void](Disable-SgBlockedPowerShellShim 'codex' $codexPaths)
[void](Disable-SgBlockedPowerShellShim 'claude' $claudePaths)
[void](Disable-SgBlockedPowerShellShim 'opencode' $opencodePaths)
[void](Disable-SgBlockedPowerShellShim 'kilocode' $kilocodePaths)
[void](Install-SgApplicationCommandWrapper 'npm' 'npm.cmd' $npmPaths)
[void](Install-SgApplicationCommandWrapper 'npx' 'npx.cmd' $npxPaths)
[void](Install-SgApplicationCommandWrapper 'corepack' 'corepack.cmd' $corepackPaths)
[void](Install-SgApplicationCommandWrapper 'pnpm' 'pnpm.cmd' $pnpmPaths)
[void](Install-SgApplicationCommandWrapper 'codex' 'codex.cmd' $codexPaths)
[void](Install-SgApplicationCommandWrapper 'claude' 'claude.cmd' $claudePaths)
[void](Install-SgApplicationCommandWrapper 'opencode' 'opencode.cmd' $opencodePaths)
[void](Install-SgApplicationCommandWrapper 'kilocode' 'kilocode.cmd' $kilocodePaths)
[void](Install-SgAgentShortcut 'c' 'claude')
[void](Install-SgAgentShortcut 'co' 'codex')
[void](Install-SgAgentShortcut 'cor' 'codex' @('resume'))
[void](Install-SgAgentShortcut 'oc' 'opencode')
[void](Install-SgAgentShortcut 'kc' 'kilocode')
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
