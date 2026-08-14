---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.4.1"
project: ShipGlows
created: "2026-08-11"
updated: "2026-08-14"
status: reviewed
source_skill: 300-sg-docs
scope: windows-devserver-operator-guide
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - install-shipglows.ps1
  - cli/windows/
  - local/install_local.ps1
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/installer-and-user-scope.md
depends_on: []
supersedes:
  - local/README_WINDOWS.md
evidence:
  - "Migrated without content loss from local/README_WINDOWS.md under the canonical documentation governance contract."
  - "PowerShell reserves gp for Get-ItemProperty; ShipGlows now installs a policy-gated add/commit/push gp profile function and a profile-independent raw gpush fallback."
  - "The Windows installer writes a static global development environment and the CLI writes one active server URL file per project."
  - "The 2026-08-14 runtime contract distinguishes direct and deferred Codex tool discovery before declaring configured Playwright unavailable."
next_review: "2026-09-11"
next_step: "/103-sg-verify Windows operator guide"
---

# ShipGlows - Installation pour Windows

## 🎯 Options d'installation

Windows offre un parcours PowerShell natif sans WSL pour les tunnels et le
développement local. WSL/Git Bash restent des alternatives facultatives, mais
ne sont pas requis par le parcours Shadow PC.

---

## ✅ Option 1: PowerShell natif (recommandé sur Shadow PC)

**Avantages:**
- ✅ Pas besoin de WSL ni de virtualisation imbriquée
- ✅ Tunnels SSH avec OpenSSH natif
- ✅ DevServer natif Astro, Python/FastAPI et Flutter Web en mode full
- ✅ Clone et registre local des dépôts directement dans `%USERPROFILE%\ShipGlows`
- ✅ Git, GitHub CLI, Node/npm, pnpm et uv installés automatiquement en mode full
- ✅ Codex, Claude Code, OpenCode et KiloCode proposés individuellement, sans installation implicite

1. **Lancer le bootstrap unique ShipGlows:**

   Le script installe automatiquement OpenSSH Client si nécessaire. Windows
   affichera une demande UAC et Windows Update doit être accessible.

   Le même endpoint public fournit automatiquement la variante PowerShell :

   ```powershell
   $installer = Join-Path $env:TEMP 'shipglows-install.ps1'
   curl.exe -fsSL 'https://shipglows.com/shipglows-script?format=powershell' -o $installer
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer
   ```

   Sans `-InstallMode`, le script demande simplement si vous voulez les tunnels
   SSH ou le DevServer local complet. Le DevServer (`full`) est recommandé pour
   cloner et lancer vos projets sur le PC Windows.

   Pour forcer une version ou un tag précis :

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -Version v1.2.3
   ```

   `-Branch`, `-Tag` et `-Ref` sont aussi acceptés comme alias.

   Le bootstrap résout la branche, le tag ou le SHA demandé vers le commit
   canonique GitHub, puis télécharge uniquement son archive publique immuable sans Git. Il installe
   automatiquement Gum dans le runtime ShipGlows pour le menu interactif,
   puis installe Git, GitHub CLI, Node LTS, pnpm et uv en mode full. Flutter
   Web et chaque agent de code (Codex, Claude Code, OpenCode, KiloCode) sont
   des choix séparés avec `non` par défaut. ShipGlows installe seulement le
   binaire choisi : chaque agent ouvre sa propre authentification officielle au
   premier lancement et ShipGlows ne lit ni ne stocke ses identifiants. Flutter
   Web est proposé séparément, car son téléchargement est plus lourd. Il ne demande ni
   `sudo`, ni WSL, ni `autossh`. Au premier accès aux dépôts privés, GitHub CLI
   ouvre son authentification officielle dans le navigateur; ShipGlows ne lit
   et ne stocke jamais le token.

   Le bootstrap teste l'exécution réelle de WSL (`wsl.exe -e sh -lc "printf ok"`)
   au lieu de considérer la seule présence de `wsl.exe` comme une preuve de
   fonctionnement. Si WSL est bloqué par la virtualisation de la VM, le
   parcours PowerShell natif est utilisé.

3. **Lancer le DevServer:**
   ```powershell
   s
   ```
   `shipglows-dev` reste disponible comme commande explicite. Ces commandes
   n'utilisent pas le profil PowerShell, donc elles fonctionnent aussi quand
   l'execution des scripts de profil est interdite.
   Les raccourcis imbriques compatibles Windows sont aussi interprétés par le
   lanceur `.cmd`, sans alias ni profil PowerShell. Par exemple, `s d` affiche
   le dashboard et `s m n` permet de choisir un projet puis ouvre un PowerShell
   enfant dans son dossier (`exit` revient au shell initial). `s h` affiche la
   liste des raccourcis disponibles. Les actions Linux liées à Flox, PM2 ou
   Caddy ne sont volontairement pas annoncées sous Windows.
   Git, GitHub CLI, Node/npm, pnpm et uv sont préparés par ShipGlows. Le dossier
   global de pnpm v11 est ajouté automatiquement au `PATH` utilisateur et la
   commande est réellement vérifiée avant d'afficher `[ok]`. Des wrappers
   `.cmd` prioritaires permettent aussi d'utiliser `npm`, `pnpm` et les agents
   lorsque Windows interdit les shims PowerShell `.ps1`. Flutter
   Web est disponible si vous avez accepté son téléchargement dans le prompt.
   Quand leurs noms ne sont pas déjà occupés, ShipGlows installe également les
   raccourcis d'agents habituels sans profil PowerShell : `c` pour Claude,
   `co` pour Codex, `cor` pour `codex resume`, `oc` pour OpenCode et `kc` pour
   KiloCode. `gpush` exécute toujours `git push`. Lorsque la politique
   PowerShell autorise les profils utilisateur, ShipGlows remplace explicitement
   l'alias natif `gp` (`Get-ItemProperty`) par une fonction `gp` qui exécute
   `git add -A`, crée un commit, puis pousse. `gp "message"` choisit le message
   du commit ; `gp` seul génère un message daté. Si une étape échoue, les
   suivantes ne sont pas lancées. Sinon `gpush` reste le raccourci compatible
   pour un push brut. Une commande
   préexistante n'est jamais remplacée silencieusement.
   Flox, PM2, Caddy et autossh sont remplacés par les commandes natives et le
   registre ShipGlows. Le backend Windows ignore entièrement `.flox` : il ne
   lit ni ses paquets, ni ses variables, ni ses hooks. Il découvre les apps à
   partir de leurs manifests natifs (`package.json`, `pubspec.yaml`, etc.).

### Vérifier l'environnement et l'URL utilisés par un agent

Le parcours `full` écrit `%USERPROFILE%\.shipglows\environment.md`. Ce fichier
global statique indique Windows, PowerShell, Codex CLI, Playwright et le
DevServer natif. Chaque projet enregistré reçoit aussi un fichier visible et
versionné `<racine-projet>\ENVIRONMENT.md`. Son bloc ShipGlows conserve le port
attribué et l'URL canonique sans écraser le reste du document. Le registre
Windows reste l'autorité pour l'état live, donc start/stop ne réécrivent pas la
documentation du projet.

Sous Windows, la priorité de port est : port demandé explicitement, variable
`SHIPGLOWS_ENV_PORT` du processus, `.shipglows.env` du projet, registre
persistant, puis premier port libre de `3000` à `3100`. Le numéro obtenu est
propre au projet. Si ShipGlows lance le projet sur `3002` alors que le dépôt
déclare `3014`, `ENVIRONMENT.md` contient `http://127.0.0.1:3002`; `3014` reste
un fallback de lancement direct. `s open` refuse un statut inactif ou un port
non attribué dans le registre.

L'installateur maintient un bloc borné dans `%USERPROFILE%\.codex\AGENTS.md`,
sans wrapper Codex ni remplacement de vos autres instructions. Les apps et
connecteurs ChatGPT ne sont pas des outils Codex CLI. Le tour Codex courant
reste l'autorité, mais son inventaire comprend les outils visibles directement
et son catalogue différé ou recherchable lorsqu'il existe.

Pour recadrer un agent en cas de doute, utilisez :

```text
$shipglows context
```

Ce mode lit `%USERPROFILE%\.shipglows\environment.md`, le fichier
`ENVIRONMENT.md` du projet et son état live dans le registre. Il ne lance aucun
serveur. Avant de classer Playwright, il recherche aussi le namespace
`mcp__playwright__*` dans `ALL_TOOLS`, `tool_search` ou la surface équivalente,
puis utilise une sonde read-only minimale. S'il est configuré mais reste
introuvable après cette découverte, le mode le signale comme configuré mais non
exposé au lieu de dire qu'il est absent.

4. **Ou exécuter le script d'installation depuis une copie existante:**
   ```powershell
   cd local
   .\install_local.ps1
   ```

   En mode `full`, seul le DevServer natif est installé : aucun tunnel n'est
   nécessaire pour les projets lancés directement sur le Shadow. Le mode
   `local` reste disponible séparément si vous devez ouvrir un tunnel SSH.

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
   ssh -N -L 3001:localhost:3001 shipglows
   ```

---

## 🔧 Option 2: Git Bash (facultatif)

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
   ssh -N -L 3001:localhost:3001 shipglows
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
| Menu interactif | ✅ | ✅ Gum natif | ❌ |
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
ssh -N -L 3001:localhost:3001 shipglows

# Tunnel en arrière-plan (PowerShell)
Start-Job -ScriptBlock { ssh -N -L 3001:localhost:3001 shipglows }
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
Host shipglows
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
