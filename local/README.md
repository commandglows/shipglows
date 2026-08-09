# 🏠 Configuration Machine Locale

Scripts pour accéder aux applications d'un serveur ShipGlows depuis votre machine locale.

## 📋 Prérequis

### Installation des outils

**macOS :**
```bash
brew install autossh
```

**Linux (Debian/Ubuntu) :**
```bash
sudo apt install autossh
```

**Android (Termux) :**
```bash
pkg update
pkg install git openssh autossh
```

**Windows :**
Voir [README_WINDOWS.md](./README_WINDOWS.md) pour les 3 options disponibles:
- ✅ **WSL** (recommandé) - Support complet avec menu interactif
- ⚡ **PowerShell** - Simple avec OpenSSH natif
- 🔧 **Git Bash** - Environnement bash familier

## 🔧 Installation Automatique

### Installation rapide (recommandé)

**Linux / macOS / WSL / Android Termux:**
```bash
# Cloner le repo
git clone <votre-repo> ~/shipglows
cd ~/shipglows/local

# Lancer l'installation
./install.sh

# Optionnel: enregistrer directement le nouveau serveur
SHIPGLOWS_SSH_REMOTE_HOST=ubuntu@SERVER_IP ./install.sh

# Recharger le shell
source ~/.bashrc  # ou source ~/.zshrc
```

**Windows (PowerShell):**
```powershell
# Utiliser le même bootstrap public, adapté automatiquement à PowerShell
$installer = Join-Path $env:TEMP 'shipglows-install.ps1'
curl.exe -fsSL 'https://shipglows.com/shipglows-script?format=powershell' -o $installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer

# Recharger le profil
. $PROFILE

# Ouvrir un tunnel vers un port choisi
tunnel -Port 3001
```

Le script Windows vous demandera aussi de choisir entre **clé SSH / agent** et **mot de passe SSH** pour la cible `hetzner`.

Sur Android, exécutez ces commandes directement dans Termux. L'installateur
détecte Termux, utilise `~/.bashrc` et indique les dépendances `pkg` adaptées;
aucun `sudo` n'est requis.

Le parcours Android est validé sur appareil physique : après le premier
appairage par mot de passe, vous pouvez installer ou générer une clé SSH propre
au téléphone. La clé privée reste dans Termux ; une fois la vérification par
clé réussie, les tunnels suivants ne redemandent pas le mot de passe.

Le script installe automatiquement :
- ✅ Connexion distante ShipGlows si `SHIPGLOWS_SSH_REMOTE_HOST` est fourni
- ✅ Alias shell `urls`, `tunnel` (Linux/macOS/WSL/Termux)
- ✅ Helpers OAuth distants : `shipglows-mcp-login`, `shipglows-blacksmith-login`
- ✅ Helper Clerk CLI distant : `shipglows-clerk-login`
- ✅ Menu interactif pour gérer les tunnels (Linux/macOS/WSL)
- ✅ Helper PowerShell `tunnel -Port <port>` pour Windows natif
- ✅ Permissions exécutables

### Installation manuelle (optionnelle)

Si vous préférez configurer manuellement :

1. **Configuration SSH** - renseigner `SHIPGLOWS_SSH_REMOTE_HOST` et `SHIPGLOWS_SSH_REMOTE_USER`, puis relancer l'installateur local
2. **Alias** - Ajouter dans `~/.bashrc` ou `~/.zshrc` :
   ```bash
   alias urls='~/shipglows/local/local.sh'
   ```

## 🚀 Utilisation

### Commandes disponibles

```bash
urls              # Ouvrir le menu de gestion des tunnels
tunnel            # Alias identique à urls
shipglows-mcp-login vercel   # Login OAuth MCP distant (Vercel)
shipglows-mcp-login supabase # Login OAuth MCP distant (Supabase)
shipglows-mcp-login all      # Enchaîne vercel puis supabase
shipglows-clerk-login        # Login Clerk CLI distant via tunnel OAuth
shipglows-blacksmith-login   # Login Blacksmith distant via tunnel OAuth
shipglows-turso-login        # Login Turso distant via tunnel/headless
shipglows-turso-ssh contentflow-prod2 # Copie auth Turso vers le serveur + checks SQL
```

### Menu interactif

Le menu offre :
- 🚀 **Démarrer une session** - Prépare automatiquement l'accès aux projets actifs
- 📋 **Afficher les URLs** - Liste toutes les URLs localhost disponibles
- 🛑 **Terminer la session** - Ferme tous les accès en cours
- 📊 **Statut** - Vérifie l'état des tunnels actifs
- 🔄 **Redémarrer** - Redémarre tous les tunnels
- 🔑 **Installer une clé SSH sur ce serveur** - Remplace une connexion par mot de passe par une clé propre à cet appareil
- 🔐 **Authentifications distantes** - Regroupe MCP Codex, Clerk CLI, Blacksmith et Turso

Le sous-menu **Authentifications distantes** lance les flows OAuth ou headless
côté serveur et crée les tunnels nécessaires depuis la machine locale. Clerk CLI
et Blacksmith ne sont pas des logins MCP Codex; ils restent donc des entrées
dédiées dans ce sous-menu.
Si vous tapez quand même `blacksmith` dans le sous-menu MCP custom par erreur,
ShipGlows bascule vers le tunnel Blacksmith dédié au lieu de chercher un MCP
Codex nommé `blacksmith`.

Au démarrage, le menu affiche un scan animé pendant la recherche d'identité de session distante. Pour le désactiver dans un terminal lent ou automatisé :

```bash
SHIPGLOWS_NO_ANIMATION=1 urls
```

### Pourquoi le tunnel OAuth existe

Quand Codex tourne sur un serveur distant, le process `codex mcp login <provider>` écoute son callback OAuth sur le serveur. Le navigateur, lui, s'ouvre sur votre machine locale et essaie de joindre `127.0.0.1:<port>/callback`. Sans tunnel, `127.0.0.1` désigne votre machine locale, pas le serveur distant.

Clerk CLI et Blacksmith ont le même problème avec `clerk auth login` et
`blacksmith auth login`: leur callback localhost tourne sur le serveur, tandis
que le navigateur est local. Utilisez donc `urls` puis `Authentifications
distantes`, ou les commandes locales
`shipglows-clerk-login` et `shipglows-blacksmith-login`, au lieu de lancer ces
commandes directement dans une session SSH distante.

Le problème n'est pas OAuth lui-même. Le problème est le routage: le navigateur local doit pouvoir rejoindre le listener de callback qui tourne sur le serveur distant.

```text
Navigateur local
  -> http://127.0.0.1:PORT/callback
  -> tunnel SSH ephemere -L PORT:127.0.0.1:PORT
  -> serveur distant
  -> codex mcp login <provider>
  -> provider OAuth officiel
```

Le port change a chaque tentative OAuth. `shipglows-mcp-login` extrait donc le port frais depuis la sortie de Codex, crée le tunnel après extraction, ouvre ou affiche l'URL OAuth, puis ferme le tunnel quand le flow se termine. Les tokens OAuth restent gérés par Codex et le provider sur le serveur distant; ShipGlows ne lit pas et ne stocke pas ces tokens.

`shipglows-blacksmith-login` n'utilise pas Codex MCP. Il réutilise seulement le
même mécanisme réseau de tunnel callback. Il vérifie que le CLI Blacksmith
existe sur le serveur, détecte seulement la présence de
`~/.blacksmith/credentials`, et ne lit jamais le token.

`shipglows-clerk-login` n'utilise pas Codex MCP non plus. Il lance `clerk auth
login` sur le serveur, ouvre ou affiche l'URL Clerk dans votre navigateur local,
puis vérifie le résultat avec `clerk whoami`. Les identifiants restent gérés par
la CLI Clerk sur le serveur; ShipGlows ne lit pas le fichier de configuration ni
le token.

Blacksmith SSH Access est séparé de ce tunnel OAuth. Il sert à se connecter à
un runner Blacksmith pendant qu'un job GitHub Actions est encore actif ou retenu
par VM retention. La commande SSH se récupère dans le step `Setup runner` du
job, et seul l'utilisateur GitHub qui a déclenché le job peut se connecter.
L'option locale `Host *.vm.blacksmith.sh` dans `~/.ssh/config` est seulement un
confort pour les hôtes éphémères; elle n'installe pas le CLI Blacksmith.

### Turso sur serveur distant

Pour faire le login Turso côté serveur depuis votre navigateur local, utilisez :

```bash
shipglows-turso-login
```

Ou via le menu :

```bash
urls
# puis o) Authentifications distantes
# puis t) Turso - Login et checks
# puis l) Login Turso distant
```

Si Turso n'est disponible que dans un environnement Flox projet côté serveur :

```bash
shipglows-turso-login --project-dir /home/<user>/<projet>
```

Le helper lance `turso auth login --headless` sur le serveur, ouvre ou affiche
l'URL dans votre navigateur local, puis vous demande de revenir au terminal. Si
Turso affiche un token/code JWT dans le navigateur, collez-le dans cette invite:
ShipGlows l'envoie au CLI officiel côté serveur via `turso config set token`
avant de vérifier `turso auth whoami`. Turso ne suit pas toujours le même modèle
callback que Blacksmith/Supabase; le mode headless est le chemin remote officiel.
Un mode callback avancé reste disponible avec `shipglows-turso-login
--browser-callback`, mais ce n'est pas le défaut.

Pour transférer une session Turso CLI déjà authentifiée depuis le poste local
vers le serveur ShipGlows configuré sans refaire le login distant, utilisez :

```bash
shipglows-turso-ssh contentflow-prod2
```

Le helper copie `~/.config/turso` vers `~/.config/turso` sur le serveur via
SSH/SCP, verrouille les permissions, lance `turso auth whoami`, puis vérifie
les tables `jobs`, `CustomerPersona`, `UserSettings`, `Project` et
`UserProviderCredential` si un nom de base est fourni. Il ne lit pas et
n'affiche pas les tokens Turso.

Si Turso n'est disponible que dans un environnement Flox projet côté serveur :

```bash
shipglows-turso-ssh --project-dir /home/<user>/<projet> contentflow-prod2
```

Résumé mental:
- Codex distant lance le login.
- Le navigateur local reçoit l'autorisation.
- Le tunnel SSH relie les deux uniquement pendant le callback.
- ShipGlows nettoie le tunnel ensuite.

### Configurer ou changer de serveur

Le script utilise `~/.shipglows/current_connection` comme chemin canonique. Si vous avez un ancien état local sous `~/.shipglows`, il est relu et migré automatiquement. Après une migration serveur, configurez la nouvelle cible depuis la machine locale avec le menu:

```bash
urls
```

Choisissez `c) Configurer nouveau serveur`, entrez une IP valide, un domaine avec un point, un alias SSH déjà défini dans `~/.ssh/config`, ou directement `user@host`, puis l'utilisateur SSH si nécessaire. Le menu propose ensuite deux modes: clé SSH/agent ou mot de passe SSH. Si vous restez en mode clé et que votre clé a un nom spécial, entrez aussi son chemin (`~/.ssh/ma-cle`, par exemple) ou un nom simple comme `oracle.key`. Laissez le champ vide pour utiliser la configuration SSH normale. Le menu teste la connexion et enregistre la cible pour `urls`, `tunnel` et `shipglows-mcp-login`.

En mode mot de passe, ShipGlows demande le mot de passe à l'ouverture de la première connexion, puis conserve une session SSH locale réutilisable pendant huit heures. Les tunnels et les logins OAuth s'y attachent sans redemander le mot de passe. Le mot de passe n'est jamais enregistré dans `~/.shipglows`.

Après une connexion par mot de passe réussie, le menu propose d'installer une clé SSH. Vous pouvez sélectionner une clé privée locale existante ou laisser ShipGlows générer une clé Ed25519 dédiée. Dans les deux cas, seule la clé publique est envoyée au serveur et ajoutée sans remplacer les entrées existantes de `~/.ssh/authorized_keys`.

ShipGlows teste ensuite une nouvelle connexion qui interdit le mot de passe et ne réutilise pas la session SSH précédente. La connexion enregistrée ne passe en mode clé que si ce test réussit. En cas d'échec, le mode mot de passe reste actif et récupérable.

Après cette preuve, ShipGlows ajoute une entrée gérée dans `~/.ssh/config` pour
l'hôte concerné. Les commandes directes utilisent donc la même clé :

```bash
ssh utilisateur@serveur
mosh utilisateur@serveur
```

Si la configuration SSH locale est un lien symbolique ou ne peut pas être
modifiée, ShipGlows le signale et affiche la commande `ssh -i` de récupération.

Utilisez une clé différente sur chaque appareil. Il ne faut pas synchroniser ou copier une clé privée entre le PC principal, un laptop ou un téléphone : chaque appareil installe sa propre clé publique, ce qui permet de révoquer un appareil sans casser les autres accès.

La clé dédiée générée par le menu est sans passphrase afin de fonctionner avec les tunnels `autossh` non interactifs. Son fichier privé reste local sous `~/.ssh/` avec des permissions restrictives. Pour utiliser une clé existante protégée par passphrase, chargez-la d'abord dans l'agent :

```bash
ssh-add ~/.ssh/ma-cle
```

Cette fonctionnalité ne modifie pas `/etc/ssh/sshd_config` et ne désactive jamais automatiquement l'authentification par mot de passe du serveur.

Si vous êtes connecté au serveur distant et ne connaissez plus l'IP publique à utiliser, ouvrez le menu ShipGlows distant et choisissez `c) Local Setup`.

La clé SSH n'a pas besoin d'avoir un nom standard si le menu connaît son chemin ou si `~/.ssh/config` sait déjà quelle clé utiliser. Pour un nom simple sans `/`, ShipGlows cherche dans le dossier courant, dans `~/.ssh/`, puis dans votre dossier home, et sauvegarde ensuite le chemin absolu trouvé. Pour promouvoir la connexion actuelle plus tard, relancez `urls` puis choisissez `k) Installer une clé SSH sur ce serveur`. Le même enregistrement est utilisé par les tunnels d'applications et par les logins distants.

### Workflow

```bash
# Sur votre machine locale
urls              # Ouvre le menu interactif
# Choisir option 1 pour démarrer les tunnels
```

Le système :
- ✅ Détecte automatiquement tous les projets PM2 actifs et les sessions Flutter Web `tmux` sur le serveur configuré
- ✅ Récupère leurs ports
- ✅ Crée des tunnels SSH pour chaque port
- ✅ Affiche les URLs accessibles (localhost:3000, etc.)
- ✅ Maintient les tunnels actifs en arrière-plan

### Synchronisation automatique

La synchronisation démarre automatiquement avec la session. Le serveur émet un
signal lorsqu'un cycle PM2 change ; le poste local garde alors une seule connexion
SSH en attente et relance les tunnels uniquement lorsque l'état serveur change.
Elle s'arrête automatiquement quand la session est terminée.

L'intervalle de reconnexion peut être ajusté avec
`SHIPGLOWS_TUNNEL_WATCH_INTERVAL` (60 secondes par défaut).

### Accéder aux applications

Ouvrez votre navigateur :
- `http://localhost:3000` (projet sur port 3000)
- `http://localhost:3001` (projet sur port 3001)
- etc.

## 🔄 Workflow typique

1. **Sur votre machine locale :** `./dev-tunnel.sh`
2. **SSH sur le serveur (avec mosh) :** `mosh "$(cat ~/.shipglows/current_connection)"`
3. **Démarrer les projets :** `dev-start`
4. **Dans votre navigateur :** Ouvrir `localhost:PORT`

## 🐛 Dépannage

### OAuth MCP: `connection refused` ou `connection reset`

Ce message arrive quand le callback OAuth `127.0.0.1:<port>` n'est pas routé vers le serveur distant.
Utilisez la commande locale `shipglows-mcp-login <provider>`: elle extrait automatiquement le port OAuth courant, crée le tunnel local temporaire, puis le ferme en fin de flow. Les aliases `shipglows-*` restent acceptés pour compatibilité.

Ne réutilisez pas un port d'une tentative précédente: l'URL OAuth est périssable et le port peut changer à chaque relance. Si le script indique que SSH est inaccessible, retournez dans `urls`, choisissez `c) Configurer nouveau serveur`, vérifiez l'IP, l'utilisateur SSH et, si nécessaire, le chemin de la clé ou la méthode d'authentification.

### Blacksmith: callback localhost `connection refused`

N'utilisez pas `blacksmith auth login` directement dans une session SSH distante.
Depuis votre machine locale, lancez `urls`, puis choisissez `b) Login
Blacksmith (distant)`. Le menu lance Blacksmith sur le serveur, extrait le port
callback courant, ouvre le tunnel SSH temporaire, puis ouvre ou affiche l'URL
officielle Blacksmith dans votre navigateur local.

### Le script ne trouve pas de ports

Vérifiez que PM2 tourne sur le serveur, ou qu'une session Flutter Web a été lancée depuis `sg` :
```bash
ssh "$(cat ~/.shipglows/current_connection)" "pm2 list"
ssh "$(cat ~/.shipglows/current_connection)" "tmux ls"
```

Pour Flutter Web, lancez côté serveur `sg`, puis `Flutter Web - tmux hot reload`
et `Start session`. Le tunnel local lira le port enregistré si la session
`tmux` est encore active.

### Les tunnels ne se créent pas

Vérifiez la configuration SSH :
```bash
ssh "$(cat ~/.shipglows/current_connection)" "echo Connection OK"
```

Si le tunnel est créé mais que `localhost:<port>` ne répond pas, l'app distante
peut encore être en build. C'est fréquent avec un wrapper PM2 Flutter Web qui
fait `flutter pub get`, `flutter build web --release`, puis seulement ensuite
lance le serveur Node. PM2 affiche alors le process `online` avant que le port
applicatif soit prêt.

Attendez les marqueurs de fin dans les logs PM2, puis relancez les tunnels :

```bash
pm2 logs contentflow_app --lines 50
```

Marqueurs typiques :

```text
✓ Built build/web
... serving on http://localhost:3050
```

Si le menu indique qu'aucun tunnel actif n'a été trouvé et que vous voulez voir
les processus SSH bruts pour diagnostiquer, relancez-le en mode debug :

```bash
SHIPGLOWS_DEBUG=1 urls
```

### MCP provider absent

Si `shipglows-mcp-login vercel` ou `shipglows-mcp-login supabase` indique que le provider n'existe pas côté distant, ajoutez-le d'abord sur le serveur:

```bash
codex mcp add vercel --url https://mcp.vercel.com
codex mcp add supabase --url https://mcp.supabase.com/mcp
```

### Clerk CLI: callback localhost `connection refused`

N'utilisez pas `clerk auth login` directement dans une session SSH distante.
Depuis votre machine locale, lancez `urls`, puis choisissez `o) Authentifications
distantes`, puis `k) Login Clerk CLI`, ou lancez directement:

```bash
shipglows-clerk-login
```

Si la CLI Clerk n'est pas installée côté serveur, installez-la d'abord avec
`npm install -g clerk`, `brew install clerk/stable/clerk` ou
`curl -fsSL https://clerk.com/install | bash`.

### Port déjà utilisé localement

Arrêtez le processus qui utilise le port ou modifiez la configuration PM2 sur le serveur.

## 📝 Notes

- Les tunnels restent actifs même si vous fermez le terminal
- `autossh` recrée automatiquement les tunnels en cas de déconnexion
- Les ports sont mappés 1:1 (port distant 3000 → port local 3000)
