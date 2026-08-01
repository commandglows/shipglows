# ShipGlowz - Installation pour Windows

## 🎯 Options d'installation

Windows offre **3 options** pour utiliser ShipGlowz localement:

---

## ✅ Option 1: WSL (alternative Linux)

**Avantages:**
- ✅ Meilleure compatibilité avec les outils Linux
- ✅ Support complet de autossh
- ✅ Expérience identique à Linux/macOS
- ✅ Menu interactif disponible

**Installation:**

1. **Installer WSL:**
   ```powershell
   wsl --install
   ```
   Redémarrez votre ordinateur si nécessaire.

2. **Lancer WSL et installer les dépendances:**
   ```bash
   sudo apt update
   sudo apt install autossh git
   ```

3. **Cloner le repo et installer:**
   ```bash
   curl -fsSL https://www.winflowz.com/shipglowz-script | SHIPGLOWZ_INSTALL_MODE=local sh
   ```

4. **Utiliser les tunnels:**
   ```bash
   urls      # ou tunnel
   ```

---

## ⚡ Option 2: PowerShell Natif (sans WSL)

**Avantages:**
- ✅ Pas besoin de WSL
- ✅ Utilise OpenSSH natif de Windows
- ✅ Simple et rapide

**Limitations:**
- ❌ Pas de autossh (tunnels manuels)
- ❌ Pas de menu interactif

**Installation:**

1. **Lancer le bootstrap unique ShipGlowz:**

   Le script installe automatiquement OpenSSH Client si nécessaire. Windows
   affichera une demande UAC et Windows Update doit être accessible.

   Le même endpoint public fournit automatiquement la variante PowerShell :

   ```powershell
   $installer = Join-Path $env:TEMP 'shipglowz-install.ps1'
   curl.exe -fsSL 'https://www.winflowz.com/shipglowz-script?format=powershell' -o $installer
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer
   ```

   Pour forcer une version ou un tag précis :

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -Version v1.2.3
   ```

   `-Branch`, `-Tag` et `-Ref` sont aussi acceptés comme alias.

   Le bootstrap télécharge l'archive publique ShipGlowz sans Git, installe
   OpenSSH si nécessaire, puis lance l'installation locale native. Il ne
   demande ni Git, ni `sudo`, ni WSL, ni `autossh`.

3. **Ou exécuter le script d'installation depuis une copie existante:**
   ```powershell
   cd local
   .\install_local.ps1
   ```

   Le script vous demande aussi de choisir le mode SSH:
   - **Clé SSH / fichier de clé** si vous utilisez `authorized_keys`
   - **Mot de passe SSH** si le serveur autorise encore l'authentification par mot de passe

4. **Créer des tunnels SSH:**

   **Méthode simple:**
   ```powershell
   .\start-tunnel.ps1 -Port 3001
   ```

   **Avec alias (après rechargement du profil):**
   ```powershell
   tunnel 3001
   ```

   **Tunnel manuel:**
   ```powershell
   ssh -N -L 3001:localhost:3001 shipglowz
   ```

---

## 🔧 Option 3: Git Bash

**Avantages:**
- ✅ Environnement bash familier
- ✅ Git inclus

**Limitations:**
- ❌ Pas de autossh
- ❌ Compatibilité limitée avec certains scripts

**Installation:**

1. **Git Bash est optionnel:**
   Le parcours PowerShell ci-dessus n'utilise pas Git. Cette section ne sert
   que si vous souhaitez utiliser Git Bash manuellement.

2. **Lancer Git Bash et créer des tunnels manuels:**
   ```bash
   ssh -N -L 3001:localhost:3001 shipglowz
   ```

---

## 🔑 Configuration SSH (Toutes les options)

### Générer une clé SSH

**PowerShell ou Git Bash:**
```bash
ssh-keygen -t ed25519 -C "votre_email@example.com"
```

**Emplacement par défaut:**
- Windows: `C:\Users\VotreNom\.ssh\id_ed25519`
- WSL: `~/.ssh/id_ed25519` (dans le système WSL)

### Ajouter la clé au serveur

Le parcours automatisé `Installer une clé SSH sur ce serveur` est disponible avec le menu Bash sous WSL. La version PowerShell native conserve pour l'instant le parcours manuel ci-dessous.

**PowerShell:**
```powershell
# Copier la clé publique dans le presse-papiers
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | clip

# Se connecter au serveur
ssh root@SERVER_IP

# Sur le serveur, ajouter la clé
echo "COLLEZ_VOTRE_CLE_ICI" >> ~/.ssh/authorized_keys
```

**WSL / Git Bash:**
```bash
# Copier manuellement la clé
cat ~/.ssh/id_ed25519.pub

# Se connecter et ajouter
ssh root@SERVER_IP
echo "COLLEZ_VOTRE_CLE_ICI" >> ~/.ssh/authorized_keys
```

Créez une paire différente sur chaque appareil et ne copiez jamais le fichier privé entre Windows, WSL ou un autre poste. Seul le contenu du fichier `.pub` doit être ajouté au serveur.

---

## 📊 Comparaison des options

| Fonctionnalité | WSL | PowerShell | Git Bash |
|----------------|-----|------------|----------|
| Tunnels automatiques (autossh) | ✅ | ❌ | ❌ |
| Menu interactif | ✅ | ❌ | ❌ |
| Simplicité | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| Compatibilité scripts | ✅ 100% | ⭐ 70% | ⭐ 80% |
| Performance | ✅ Excellent | ✅ Excellent | ✅ Bon |

---

## 🚀 Utilisation

### WSL (avec menu)
```bash
urls                  # Ouvre le menu interactif
```

### PowerShell
```powershell
# Démarrer un tunnel
.\start-tunnel.ps1 -Port 3001

# Ou avec alias (après rechargement)
tunnel 3001

# Arrêter: Ctrl+C dans la fenêtre du tunnel
```

### Tunnel SSH manuel (toutes options)
```bash
# Tunnel simple
ssh -N -L 3001:localhost:3001 shipglowz

# Tunnel en arrière-plan (PowerShell)
Start-Job -ScriptBlock { ssh -N -L 3001:localhost:3001 shipglowz }
```

---

## 🆘 Dépannage

### "Permission denied (publickey)"

**Solution:** Votre clé SSH n'est pas configurée sur le serveur.
Si vous avez choisi le mode mot de passe dans `install_local.ps1`, ce message indique plutôt que le serveur n'autorise pas le mot de passe ou que le compte SSH n'est pas correct.

1. Vérifiez que vous avez une clé SSH:
   ```powershell
   dir $env:USERPROFILE\.ssh\id_ed25519.pub
   ```

2. Si elle n'existe pas, créez-la:
   ```powershell
   ssh-keygen -t ed25519
   ```

3. Ajoutez-la au serveur (voir section Configuration SSH)

### "ssh: command not found" (PowerShell)

**Solution:** relancez le bootstrap PowerShell : il installe automatiquement
OpenSSH Client avec élévation UAC. Si Windows Update est bloqué par la VM,
l'installation de la fonctionnalité devra être autorisée par l'administrateur.

La commande manuelle `Add-WindowsCapability` reste un dépannage réservé aux
machines où l'élévation automatique ou Windows Update est bloqué.

### Le tunnel se ferme automatiquement

**Solution:** Utilisez des paramètres de keep-alive.

Ajoutez dans `~/.ssh/config` (ou `C:\Users\VotreNom\.ssh\config`):
```
Host shipglowz
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### WSL: "autossh: command not found"

**Solution:**
```bash
sudo apt update
sudo apt install autossh
```

---

## 💡 Conseils

1. **Pour les développeurs:** WSL offre la meilleure expérience
2. **Pour un usage occasionnel:** PowerShell est plus simple
3. **Gardez vos tunnels actifs:** Les tunnels SSH peuvent s'interrompre. Utilisez autossh (WSL) ou relancez manuellement (PowerShell)
4. **Sécurité:** Ne partagez jamais votre clé privée (`id_ed25519`), seulement la clé publique (`id_ed25519.pub`)

---

## 🔗 Ressources

- **WSL Documentation:** https://aka.ms/wsl
- **OpenSSH pour Windows:** https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
- **Git for Windows:** https://git-scm.com/download/win
