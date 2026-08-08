[CmdletBinding()]
param(
    [string]$ShipglowsDir = (Join-Path $env:USERPROFILE 'shipglows'),
    [string]$Workspace = (Join-Path $env:USERPROFILE 'ShipGlows\workspace'),
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$sourceDir = Join-Path $ShipglowsDir 'cli\windows'
$runtimeDir = Join-Path $env:USERPROFILE 'ShipGlows\bin'
$gumVersion = '0.17.0'
$gumSha256 = 'B2BE80531C6BABC8D4E0E6CA95773D58118A2E1582AE006AACE08DBC55503072'
New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
New-Item -ItemType Directory -Path $Workspace -Force | Out-Null

$launcher = Join-Path $runtimeDir 'shipglows-devserver.ps1'
Copy-Item -LiteralPath (Join-Path $sourceDir 'ShipGlows.DevServer.psm1') -Destination $runtimeDir -Force
Copy-Item -LiteralPath (Join-Path $sourceDir 'shipglows-devserver.ps1') -Destination $launcher -Force

function Update-SgProcessPath {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = @($machinePath, $userPath) -join ';'
}

function Add-SgUserPathEntry([string]$Directory) {
    if ([string]::IsNullOrWhiteSpace($Directory)) { return }
    $currentUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @($currentUserPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $alreadyPresent = $false
    foreach ($entry in $entries) {
        if ($entry.TrimEnd('\') -ieq $Directory.TrimEnd('\')) { $alreadyPresent = $true; break }
    }
    if (-not $alreadyPresent) {
        $nextPath = @($Directory) + $entries
        [Environment]::SetEnvironmentVariable('Path', ($nextPath -join ';'), 'User')
    }
    Update-SgProcessPath
}

function Add-SgRuntimeToUserPath { Add-SgUserPathEntry $runtimeDir }

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
        Write-Warning "The command 's' is already used by $($existing.Source). ShipGlows kept the non-conflicting command: shipglows-dev."
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

function Install-SgWingetPackage([string]$Name, [string]$PackageId, [string[]]$KnownPaths = @()) {
    if (Test-SgTool $Name $KnownPaths) {
        Write-Host "$Name is already installed." -ForegroundColor Green
        return $true
    }
    $winget = Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $winget) {
        Write-Warning "WinGet is unavailable; $Name could not be installed automatically."
        return $false
    }
    try {
        Write-Host "Installing $Name..." -ForegroundColor Cyan
        Write-Host 'Please wait and keep this window open. WinGet can take several minutes and may appear idle while Windows completes the installation.' -ForegroundColor Yellow
        & $winget.Source install --id $PackageId --exact --source winget --accept-package-agreements --accept-source-agreements --silent | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "$Name installation returned exit code $LASTEXITCODE." }
        Update-SgProcessPath
        if (-not (Test-SgTool $Name $KnownPaths)) { throw "$Name was installed but is not discoverable yet." }
        Write-Host "$Name installed." -ForegroundColor Green
        return $true
    } catch {
        Write-Warning "$Name could not be installed automatically: $($_.Exception.Message)"
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
        Write-Warning 'Gum automatic installation currently requires 64-bit Windows; the PowerShell menu will remain available.'
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
        Write-Warning "Gum could not be installed automatically: $($_.Exception.Message) The PowerShell menu will remain available."
        return $false
    } finally {
        if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Install-SgPnpm([string[]]$NpmPaths, [string[]]$CorepackPaths, [string[]]$PnpmPaths) {
    if (Test-SgTool 'pnpm.cmd' $PnpmPaths) {
        Write-Host 'pnpm is already installed.' -ForegroundColor Green
        return $true
    }

    $npm = Get-SgToolPath 'npm.cmd' $NpmPaths
    if (-not $npm) {
        Write-Warning 'pnpm could not be installed because npm is unavailable.'
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
                if (Test-SgTool 'pnpm.cmd' $PnpmPaths) {
                    Write-Host 'pnpm installed with Corepack.' -ForegroundColor Green
                    return $true
                }
            } else {
                Write-Warning 'Corepack could not enable pnpm here; using the npm fallback.'
            }
        }

        Write-Host 'Installing pnpm with npm fallback...' -ForegroundColor Cyan
        & $npm install --global pnpm@latest | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "pnpm installation returned exit code $LASTEXITCODE." }
        Update-SgProcessPath
        if (-not (Test-SgTool 'pnpm.cmd' $PnpmPaths)) { throw 'pnpm was installed but is not discoverable yet.' }
        Write-Host 'pnpm installed.' -ForegroundColor Green
        return $true
    } catch {
        Write-Warning "pnpm could not be installed automatically: $($_.Exception.Message)"
        return $false
    }
}

function Install-SgFlutter([string[]]$FlutterPaths, [string[]]$GitPaths) {
    if (Test-SgTool 'flutter.bat' $FlutterPaths) {
        Write-Host 'Flutter Web SDK is already installed.' -ForegroundColor Green
        return $true
    }

    Write-Host ''
    Write-Host 'Flutter Web SDK is optional and is a larger download.' -ForegroundColor Yellow
    $answer = (Read-Host 'Install Flutter Web SDK now? [y/N]').Trim().ToLowerInvariant()
    if ($answer -notin @('y', 'yes', 'o', 'oui')) {
        Write-Host 'Flutter Web SDK skipped. Rerun the full installer when you need it.' -ForegroundColor Yellow
        return $false
    }

    $git = Get-SgToolPath 'git.exe' $GitPaths
    if (-not $git) {
        Write-Warning 'Flutter Web SDK could not be installed because Git is unavailable.'
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
        Write-Warning "Flutter Web SDK could not be installed automatically: $($_.Exception.Message)"
        return $false
    }
}

Install-SgCommandWrappers
[void](Install-SgGum)
$programFiles = [Environment]::GetFolderPath('ProgramFiles')
$programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
$gitPaths = @((Join-Path $programFiles 'Git\cmd\git.exe'), (Join-Path $programFilesX86 'Git\cmd\git.exe'))
$ghPaths = @((Join-Path $programFiles 'GitHub CLI\gh.exe'), (Join-Path $programFilesX86 'GitHub CLI\gh.exe'))
$nodePaths = @((Join-Path $programFiles 'nodejs\node.exe'), (Join-Path $programFilesX86 'nodejs\node.exe'))
$npmPaths = @((Join-Path $programFiles 'nodejs\npm.cmd'), (Join-Path $programFilesX86 'nodejs\npm.cmd'))
$corepackPaths = @((Join-Path $programFiles 'nodejs\corepack.cmd'), (Join-Path $programFilesX86 'nodejs\corepack.cmd'), (Join-Path $env:APPDATA 'npm\corepack.cmd'))
$pnpmPaths = @((Join-Path $env:APPDATA 'npm\pnpm.cmd'))
$uvPaths = @((Join-Path $env:USERPROFILE '.local\bin\uv.exe'), (Join-Path $env:USERPROFILE '.cargo\bin\uv.exe'))
$flutterPaths = @((Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.bat'), (Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.exe'))
Write-Host 'Preparing Windows developer tools. This step can take a few minutes on the first installation.' -ForegroundColor Yellow
[void](Install-SgWingetPackage 'git.exe' 'Git.Git' $gitPaths)
[void](Install-SgWingetPackage 'gh.exe' 'GitHub.cli' $ghPaths)
[void](Install-SgWingetPackage 'node.exe' 'OpenJS.NodeJS.LTS' $nodePaths)
[void](Install-SgPnpm $npmPaths $corepackPaths $pnpmPaths)
[void](Install-SgWingetPackage 'uv.exe' 'astral-sh.uv' $uvPaths)
[void](Install-SgFlutter $flutterPaths $gitPaths)

if (-not $SkipProfile) {
    $profilePath = $PROFILE
    $profileDir = Split-Path -Parent $profilePath
    if (-not (Test-Path -LiteralPath $profileDir -PathType Container)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    $marker = '# ShipGlows DevServer (managed)'
    $existing = if (Test-Path -LiteralPath $profilePath -PathType Leaf) { Get-Content -LiteralPath $profilePath -Raw } else { '' }
    if ($existing -notlike "*$marker*") {
        $block = @"

$marker
function shipglows-dev { & '$launcher' @args }
"@
        Add-Content -LiteralPath $profilePath -Value $block -Encoding UTF8
    }
}

Write-Host "ShipGlows Windows DevServer installed." -ForegroundColor Green
Write-Host "Workspace: $Workspace"
Write-Host 'Commands: s (short) or shipglows-dev'
Write-Host ''
Write-Host 'Dependency check:' -ForegroundColor Yellow
foreach ($tool in @('gum','git','gh','node','npm','pnpm','uv','flutter')) {
    if ($tool -eq 'gum' -and (Test-Path -LiteralPath (Join-Path $runtimeDir 'gum.exe') -PathType Leaf)) {
        Write-Host "  [ok]   gum" -ForegroundColor Green
        continue
    }
    $knownPaths = switch ($tool) {
        'git' { $gitPaths; break }
        'gh' { $ghPaths; break }
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
    $found = Test-SgTool $executable $knownPaths
    if ($found) { Write-Host "  [ok]   $tool" -ForegroundColor Green }
    else { Write-Host "  [miss] $tool (install it or use the project-specific setup instructions)" -ForegroundColor Yellow }
}
Write-Host 'Run now: s'
