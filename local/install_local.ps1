# ShipGlowz native Windows local installer.
# This file is intentionally valid PowerShell without WSL, Bash, or sudo.

[CmdletBinding()]
param(
    [string]$RemoteHost = $(if ($env:SHIPGLOWZ_SSH_REMOTE_HOST) { $env:SHIPGLOWZ_SSH_REMOTE_HOST } else { '' }),
    [string]$RemoteUser = $(if ($env:SHIPGLOWZ_SSH_REMOTE_USER) { $env:SHIPGLOWZ_SSH_REMOTE_USER } else { '' }),
    [string]$AuthMethod = $(if ($env:SHIPGLOWZ_SSH_AUTH_METHOD) { $env:SHIPGLOWZ_SSH_AUTH_METHOD } else { '' }),
    [string]$IdentityFile = $(if ($env:SHIPGLOWZ_SSH_IDENTITY_FILE) { $env:SHIPGLOWZ_SSH_IDENTITY_FILE } else { '' })
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Info([string]$Message) { Write-Host $Message -ForegroundColor Cyan }
function Write-Success([string]$Message) { Write-Host $Message -ForegroundColor Green }
function Write-WarningMessage([string]$Message) { Write-Host $Message -ForegroundColor Yellow }
function Write-ErrorMessage([string]$Message) { Write-Host $Message -ForegroundColor Red }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sshDir = Join-Path $env:USERPROFILE '.ssh'
$sshConfigPath = Join-Path $sshDir 'config'

Write-Info 'ShipGlowz - native Windows local installation'
Write-Host ''

# WSL is optional. Presence of wsl.exe is not enough: execute a real command.
$wslCommand = Get-Command wsl.exe -ErrorAction SilentlyContinue
if ($wslCommand) {
    $wslProbeOutput = (& wsl.exe -e sh -lc 'printf ok' 2>$null | Out-String).Trim()
    if ($LASTEXITCODE -eq 0 -and $wslProbeOutput -eq 'ok') {
        Write-Info 'WSL is available, but native Windows mode remains selected.'
    } else {
        Write-WarningMessage 'WSL is detected but unusable on this machine; using native Windows local mode.'
    }
} else {
    Write-Info 'WSL is not installed; using native Windows local mode.'
}

# 1. Install Windows OpenSSH Client when it is missing.
Write-Info '1. Checking Windows OpenSSH Client...'
$sshCommand = Get-Command ssh.exe -ErrorAction SilentlyContinue
if (-not $sshCommand) {
    Write-WarningMessage 'OpenSSH Client is missing; Windows will request administrator approval.'
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        $argumentList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
        if ($RemoteHost) { $argumentList += @('-RemoteHost', $RemoteHost) }
        if ($RemoteUser) { $argumentList += @('-RemoteUser', $RemoteUser) }
        if ($AuthMethod) { $argumentList += @('-AuthMethod', $AuthMethod) }
        if ($IdentityFile) { $argumentList += @('-IdentityFile', $IdentityFile) }
        $elevated = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList $argumentList
        exit $elevated.ExitCode
    }

    Add-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0' | Out-Host
    $sshCommand = Get-Command ssh.exe -ErrorAction SilentlyContinue
    if (-not $sshCommand) {
        throw 'Windows could not install OpenSSH Client. Check Windows Update or the virtual machine policy.'
    }
}
Write-Success '   OpenSSH Client is available.'
Write-Host ''

# 2. Configure the SSH host entry.
Write-Info '2. Configuring SSH...'
New-Item -ItemType Directory -Path $sshDir -Force | Out-Null

if (-not $RemoteHost) { $RemoteHost = (Read-Host '   ShipGlowz server host or IP').Trim() }
if (-not $RemoteHost) { throw 'The SSH host is required.' }
if (-not $RemoteUser) { $RemoteUser = (Read-Host '   SSH user [root]').Trim() }
if (-not $RemoteUser) { $RemoteUser = 'root' }

if (-not $AuthMethod) {
    Write-Host '   a) SSH key / IdentityFile' -ForegroundColor Yellow
    Write-Host '   b) SSH password' -ForegroundColor Yellow
    $authChoice = (Read-Host '   Choice [a/b]').Trim().ToLowerInvariant()
    if ($authChoice -eq 'b' -or $authChoice -eq 'password') { $AuthMethod = 'password' } else { $AuthMethod = 'key' }
}
$AuthMethod = $AuthMethod.Trim().ToLowerInvariant()
if ($AuthMethod -notin @('key', 'password')) { throw "Invalid SSH authentication mode: $AuthMethod. Use key or password." }

if ($AuthMethod -eq 'key' -and -not $IdentityFile) {
    $defaultIdentity = Join-Path $sshDir 'id_ed25519'
    $identityInput = (Read-Host "   SSH key file [$defaultIdentity]").Trim()
    $IdentityFile = if ($identityInput) { $identityInput } else { $defaultIdentity }
}
Write-Success "   SSH target: $RemoteUser@$RemoteHost ($AuthMethod)"

$shipglowzConfigDir = Join-Path $env:USERPROFILE '.shipglowz'
New-Item -ItemType Directory -Path $shipglowzConfigDir -Force | Out-Null
Set-Content -Path (Join-Path $shipglowzConfigDir 'current_connection') -Value "$RemoteUser@$RemoteHost" -Encoding UTF8
Set-Content -Path (Join-Path $shipglowzConfigDir 'current_auth_method') -Value $AuthMethod -Encoding UTF8
if ($AuthMethod -eq 'key') {
    Set-Content -Path (Join-Path $shipglowzConfigDir 'current_identity_file') -Value $IdentityFile -Encoding UTF8
} else {
    Remove-Item -LiteralPath (Join-Path $shipglowzConfigDir 'current_identity_file') -Force -ErrorAction SilentlyContinue
}

if ($AuthMethod -eq 'password') {
    $sshAuthBlock = @"

# ShipGlowz - remote server
Host shipglowz
    HostName $RemoteHost
    User $RemoteUser
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
    PreferredAuthentications password,keyboard-interactive
    PubkeyAuthentication no
    KbdInteractiveAuthentication yes
    NumberOfPasswordPrompts 1
"@
} else {
    $sshAuthBlock = @"

# ShipGlowz - remote server
Host shipglowz
    HostName $RemoteHost
    User $RemoteUser
    IdentityFile $IdentityFile
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
"@
}

$sshConfigContent = if (Test-Path -LiteralPath $sshConfigPath) { Get-Content -Raw -Path $sshConfigPath } else { '' }
$sshHostPattern = '(?ms)^\s*Host\s+shipglowz\b.*?(?=^\s*Host\s+\S|\z)'
if ($sshConfigContent -match $sshHostPattern) {
    $updatedConfig = [regex]::Replace($sshConfigContent, $sshHostPattern, $sshAuthBlock.TrimStart())
    Set-Content -Path $sshConfigPath -Value $updatedConfig -Encoding UTF8
    Write-Success '   SSH configuration updated.'
} else {
    Add-Content -Path $sshConfigPath -Value $sshAuthBlock -Encoding UTF8
    Write-Success '   SSH configuration added.'
}
Write-Host ''

# 3. Generate a valid PowerShell tunnel script.
Write-Info '3. Creating the SSH tunnel script...'
$tunnelScriptPath = Join-Path $scriptDir 'start-tunnel.ps1'
$tunnelScriptContent = @'
# ShipGlowz SSH tunnel helper.
# Usage: .\start-tunnel.ps1 -Port 3001

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [int]$Port
)

Write-Host "Starting SSH tunnel for port $Port..." -ForegroundColor Cyan
Write-Host "Local URL: http://localhost:$Port"
Write-Host 'Press Ctrl+C to stop the tunnel.'

& ssh.exe -N "-L$($Port):localhost:$($Port)" shipglowz
exit $LASTEXITCODE
'@
Set-Content -Path $tunnelScriptPath -Value $tunnelScriptContent -Encoding UTF8
Write-Success "   Tunnel script created: $tunnelScriptPath"
Write-Host ''

# 4. Add a safe PowerShell function to the current user's profile.
Write-Info '4. Configuring the tunnel shortcut...'
$profilePath = $PROFILE
$profileParent = Split-Path -Parent $profilePath
if ($profileParent) { New-Item -ItemType Directory -Path $profileParent -Force | Out-Null }
if (-not (Test-Path -LiteralPath $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }

$profileTunnelPath = $tunnelScriptPath.Replace("'", "''")
$aliasBlock = @'

# ShipGlowz - SSH tunnel alias
$tunnelScriptPath = '__SHIPGLOWZ_TUNNEL_SCRIPT_PATH__'
function tunnel {
    param([int]$Port)
    & $tunnelScriptPath -Port $Port
}
'@
$aliasBlock = $aliasBlock.Replace('__SHIPGLOWZ_TUNNEL_SCRIPT_PATH__', $profileTunnelPath)

if (-not (Select-String -Path $profilePath -Pattern 'Ship(Flow|Glowz)' -Quiet)) {
    Add-Content -Path $profilePath -Value $aliasBlock -Encoding UTF8
    Write-Success '   PowerShell tunnel function added to the profile.'
} else {
    Write-WarningMessage '   A ShipGlowz profile entry already exists; it was left unchanged.'
}
Write-Host ''

# 5. Summary.
Write-Success 'ShipGlowz native Windows setup completed.'
Write-Host ''
Write-Host 'Usage:' -ForegroundColor Cyan
Write-Host "   & '$tunnelScriptPath' -Port 3001" -ForegroundColor Green
Write-Host '   tunnel 3001  (after reloading the PowerShell profile)' -ForegroundColor Green
Write-Host '   . $PROFILE  (reload the profile)' -ForegroundColor Yellow
Write-Host ''

# 6. Test the configured SSH host without mutating the remote server.
Write-Info '6. Testing the SSH connection...'
try {
    $sshTestArgs = @('-o', 'ConnectTimeout=5')
    if ($AuthMethod -eq 'password') {
        $sshTestArgs += @('-o', 'BatchMode=no', '-o', 'PreferredAuthentications=password,keyboard-interactive', '-o', 'PubkeyAuthentication=no', '-o', 'KbdInteractiveAuthentication=yes', '-o', 'NumberOfPasswordPrompts=1')
    } else {
        $sshTestArgs += @('-o', 'BatchMode=yes')
    }

    & ssh.exe @sshTestArgs shipglowz 'echo OK' 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'SSH connection failed.' }
    Write-Success '   SSH connection to the server is OK.'
} catch {
    Write-WarningMessage '   SSH connection could not be verified.'
    if ($AuthMethod -eq 'password') {
        Write-WarningMessage '   Check that password authentication is enabled and the SSH user is correct.'
    } else {
        Write-WarningMessage "   Check that the public key for $IdentityFile is installed on the server."
    }
}

Write-Host ''
Write-Success 'Native Windows mode works without WSL, Bash, sudo, or autossh.'
