# install_local.ps1 - Installation automatique pour Windows (PowerShell)
# Installe automatiquement OpenSSH Client si la fonctionnalité est absente.

param(
    [string]$RemoteHost = $(if ($env:SHIPGLOWZ_SSH_REMOTE_HOST) { $env:SHIPGLOWZ_SSH_REMOTE_HOST } else { '' }),
    [string]$RemoteUser = $(if ($env:SHIPGLOWZ_SSH_REMOTE_USER) { $env:SHIPGLOWZ_SSH_REMOTE_USER } else { '' }),
    [string]$AuthMethod = $(if ($env:SHIPGLOWZ_SSH_AUTH_METHOD) { $env:SHIPGLOWZ_SSH_AUTH_METHOD } else { '' }),
    [string]$IdentityFile = $(if ($env:SHIPGLOWZ_SSH_IDENTITY_FILE) { $env:SHIPGLOWZ_SSH_IDENTITY_FILE } else { '' })
)

$ErrorActionPreference = "Stop"

$GREEN = "`e[32m"
$BLUE = "`e[34m"
$YELLOW = "`e[33m"
$RED = "`e[31m"
$NC = "`e[0m"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SSH_CONFIG = "$env:USERPROFILE\.ssh\config"

Write-Host "${BLUE}🚀 Installation ShipGlowz - Configuration Windows${NC}"
Write-Host ""

# 1. Vérifier OpenSSH Client
Write-Host "${BLUE}1. Vérification des dépendances...${NC}"

$sshInstalled = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $sshInstalled) {
    Write-Host "${YELLOW}   OpenSSH Client absent; demande d'installation Windows...${NC}"
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
    $sshInstalled = Get-Command ssh -ErrorAction SilentlyContinue
    if (-not $sshInstalled) {
        throw 'Windows n’a pas pu installer OpenSSH Client. Vérifie Windows Update ou la politique de la machine virtuelle.'
    }
}
Write-Host "${GREEN}   ✓ OpenSSH Client installé${NC}"

Write-Host ""

# 2. Configurer SSH
Write-Host "${BLUE}2. Configuration SSH...${NC}"

# Créer le répertoire .ssh si nécessaire
$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
}

# Choisir la cible et le mode d'authentification SSH
Write-Host ""
if (-not $RemoteHost) { $RemoteHost = (Read-Host "   Hôte ou IP du serveur ShipGlowz").Trim() }
if (-not $RemoteHost) { throw 'L’hôte SSH est obligatoire.' }
if (-not $RemoteUser) { $RemoteUser = (Read-Host "   Utilisateur SSH [root]").Trim() }
if (-not $RemoteUser) { $RemoteUser = 'root' }
if (-not $AuthMethod) {
    Write-Host "${YELLOW}   a) Clé SSH / fichier IdentityFile${NC}"
    Write-Host "${YELLOW}   b) Mot de passe SSH${NC}"
    $authChoice = (Read-Host "   Choix [a/b]").Trim().ToLower()
    if ($authChoice -eq 'b' -or $authChoice -eq 'password' -or $authChoice -eq 'mot de passe') { $AuthMethod = 'password' } else { $AuthMethod = 'key' }
}
$AuthMethod = $AuthMethod.Trim().ToLower()
if ($AuthMethod -notin @('key', 'password')) { throw "Mode SSH invalide: $AuthMethod. Utilise key ou password." }
if ($AuthMethod -eq 'key' -and -not $IdentityFile) {
    $defaultIdentity = Join-Path $env:USERPROFILE '.ssh\id_ed25519'
    $identityInput = (Read-Host "   Fichier de clé SSH [$defaultIdentity]").Trim()
    $IdentityFile = if ($identityInput) { $identityInput } else { $defaultIdentity }
}
Write-Host "${GREEN}   ✓ Cible choisie: $RemoteUser@$RemoteHost ($AuthMethod)${NC}"

$shipglowzConfigDir = Join-Path $env:USERPROFILE '.shipglowz'
New-Item -ItemType Directory -Path $shipglowzConfigDir -Force | Out-Null
Set-Content -Path (Join-Path $shipglowzConfigDir 'current_connection') -Value "$RemoteUser@$RemoteHost"
Set-Content -Path (Join-Path $shipglowzConfigDir 'current_auth_method') -Value $AuthMethod
if ($AuthMethod -eq 'key') {
    Set-Content -Path (Join-Path $shipglowzConfigDir 'current_identity_file') -Value $IdentityFile
} else {
    Remove-Item -LiteralPath (Join-Path $shipglowzConfigDir 'current_identity_file') -Force -ErrorAction SilentlyContinue
}

# Préparer le bloc de configuration SSH sans service ssh-agent obligatoire
if ($authMethod -eq "password") {
    $sshAuthBlock = @"

# ShipGlowz - Serveur distant
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

# ShipGlowz - Serveur distant
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

# Ajouter ou remplacer la configuration SSH
$sshConfigContent = ""
if (Test-Path $SSH_CONFIG) {
    $sshConfigContent = Get-Content -Raw -Path $SSH_CONFIG
}

$sshHostPattern = '(?ms)^\s*Host\s+shipglowz\b.*?(?=^\s*Host\s+\S|\z)'
if ($sshConfigContent -match $sshHostPattern) {
    $updatedConfig = [regex]::Replace($sshConfigContent, $sshHostPattern, $sshAuthBlock.TrimStart())
    Set-Content -Path $SSH_CONFIG -Value $updatedConfig
    Write-Host "${GREEN}   ✓ Configuration SSH mise à jour${NC}"
} else {
    Add-Content -Path $SSH_CONFIG -Value $sshAuthBlock
    Write-Host "${GREEN}   ✓ Configuration SSH ajoutée${NC}"
}

Write-Host ""

# 3. Créer un script de tunnel
Write-Host "${BLUE}3. Création du script de tunnel...${NC}"

$tunnelScriptPath = "$SCRIPT_DIR\start-tunnel.ps1"
$tunnelScriptContent = @"
# start-tunnel.ps1 - Démarrer un tunnel SSH
# Usage: .\start-tunnel.ps1 -Port 3001

param(
    [Parameter(Mandatory=`$true)]
    [int]`$Port
)

Write-Host "🔗 Démarrage du tunnel SSH pour le port `$Port..."
Write-Host "URL locale: http://localhost:`$Port"
Write-Host ""
Write-Host "Appuyez sur Ctrl+C pour arrêter le tunnel"
Write-Host ""

ssh -N -L ${Port}:localhost:${Port} shipglowz
"@

Set-Content -Path $tunnelScriptPath -Value $tunnelScriptContent
Write-Host "${GREEN}   ✓ Script de tunnel créé: start-tunnel.ps1${NC}"

Write-Host ""

# 4. Ajouter au PATH (optionnel)
Write-Host "${BLUE}4. Configuration des raccourcis...${NC}"

$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$aliasBlock = @"

# ShipGlowz - Alias pour tunnels SSH
function tunnel { param([int]`$Port) & "$tunnelScriptPath" -Port `$Port }
"@

if (-not (Select-String -Path $profilePath -Pattern "Ship(Flow|Glowz) - Alias" -Quiet)) {
    Add-Content -Path $profilePath -Value $aliasBlock
    Write-Host "${GREEN}   ✓ Alias ajouté au profil PowerShell${NC}"
} else {
    Write-Host "${YELLOW}   ⚠ Alias déjà présent dans le profil PowerShell${NC}"
}

Write-Host ""

# 5. Résumé
Write-Host "${GREEN}✅ Installation terminée !${NC}"
Write-Host ""
Write-Host "${BLUE}📋 Utilisation:${NC}"
Write-Host ""
Write-Host "   ${YELLOW}Méthode 1: Via script direct${NC}"
Write-Host "   ${GREEN}.\start-tunnel.ps1 -Port 3001${NC}"
Write-Host ""
Write-Host "   ${YELLOW}Méthode 2: Via alias (après redémarrage PowerShell)${NC}"
Write-Host "   ${GREEN}tunnel 3001${NC}"
Write-Host ""
Write-Host "   ${YELLOW}Méthode 3: Tunnel SSH manuel${NC}"
Write-Host "   ${GREEN}ssh -N -L 3001:localhost:3001 hetzner${NC}"
Write-Host ""
Write-Host "${YELLOW}⚠  Pour activer les alias, rechargez votre profil PowerShell:${NC}"
Write-Host "   ${BLUE}. `$PROFILE${NC}"
Write-Host "   ${YELLOW}ou${NC} fermez et rouvrez PowerShell"
Write-Host ""

# 6. Test de connexion SSH
Write-Host "${BLUE}🚀 Test de connexion SSH:${NC}"
try {
    $sshTestArgs = @("-o", "ConnectTimeout=5")
    if ($authMethod -eq "password") {
        $sshTestArgs += @(
            "-o", "BatchMode=no",
            "-o", "PreferredAuthentications=password,keyboard-interactive",
            "-o", "PubkeyAuthentication=no",
            "-o", "KbdInteractiveAuthentication=yes",
            "-o", "NumberOfPasswordPrompts=1"
        )
    } else {
        $sshTestArgs += @("-o", "BatchMode=yes")
    }

    $sshTest = & ssh @sshTestArgs shipglowz "echo OK" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "${GREEN}   ✓ Connexion SSH au serveur OK${NC}"
        Write-Host ""
        Write-Host "${GREEN}   Vous pouvez maintenant utiliser: ${BLUE}tunnel 3001${NC}"
    } else {
        throw "SSH connection failed"
    }
} catch {
    Write-Host "${YELLOW}   ⚠ Impossible de se connecter au serveur${NC}"
    if ($authMethod -eq "password") {
        Write-Host "${YELLOW}   Vérifiez que le mot de passe SSH est autorisé sur le serveur et que le compte root peut se connecter.${NC}"
    } else {
        Write-Host "${YELLOW}   Vérifiez que votre clé SSH est configurée:${NC}"
        Write-Host ""
        Write-Host "   ${BLUE}1. Générer une clé SSH (si pas déjà fait):${NC}"
        Write-Host "      ${GREEN}ssh-keygen -t ed25519 -C 'your_email@example.com'${NC}"
        Write-Host ""
        Write-Host "   ${BLUE}2. Copier la clé publique:${NC}"
        Write-Host "      ${GREEN}Get-Content `$env:USERPROFILE\.ssh\id_ed25519.pub | clip${NC}"
        Write-Host "      ${YELLOW}(La clé est maintenant dans le presse-papiers)${NC}"
        Write-Host ""
        Write-Host "   ${BLUE}3. Ajouter la clé sur le serveur:${NC}"
        Write-Host "      ${GREEN}ssh $RemoteUser@$RemoteHost${NC}"
        Write-Host "      ${YELLOW}Collez votre clé publique dans ~/.ssh/authorized_keys${NC}"
    }
}

Write-Host ""
Write-Host "${BLUE}💡 Le parcours natif Windows fonctionne sans WSL.${NC}"
