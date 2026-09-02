---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.29.0"
project: ShipGlows
created: "2026-08-11"
updated: "2026-09-01"
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
  - "Le replay Obsidian du 2026-09-01 confirme la priorité de classification sur Vite, le watch sans port, les états explicites et la copie vérifiée vers un coffre de test déclaré."
  - "Le replay du 2026-09-01 confirme que la boîte à outils CLI machine génère un verrou mise limité à windows-x64 sans toucher aux lockfiles des projets."
  - "Le parcours Flutter Android du 2026-08-30 sélectionne un appareil explicite ou démarre l'AVD ShipGlows_API_36 avant une session live supervisée."
  - "Le parcours Flutter Windows du 2026-08-30 privilégie une session live supervisée et crée un raccourci Dev distinct des builds figés."
  - "Le replay ToolGlows du 2026-08-28 a corrigé la séparation des lignes du guide ENVIRONMENT.md et la comparaison des timestamps JSON PowerShell 7 qui transformait à tort un processus vivant en projet arrêté."
  - "Le parcours guidé du 2026-08-28 nomme clairement projet web, app Flutter et extension Chrome dans l'aide, le statut, le dashboard, l'enregistrement et les actions Start/Open."
  - "The 2026-08-27 installed ToolGlows replay removed a hidden 60-second clamp so extension readiness honors the caller's 90-second startup budget."
  - "The 2026-08-27 installed ToolGlows replay removed the npm-only option separator from pinned pnpm extension launches so Vite binds the requested IPv4 loopback host."
  - "The 2026-08-27 installed-runtime replay now re-registers existing projects before environment migration so registry and durable project kind remain coherent."
  - "The 2026-08-27 browser-extension adapter recognizes explicit Chrome development surfaces, honors pinned pnpm through Corepack, and records unpacked-extension guidance instead of claiming an ordinary web URL."
  - "Migrated without content loss from local/README_WINDOWS.md under the canonical documentation governance contract."
  - "PowerShell reserves gp for Get-ItemProperty; ShipGlows now installs a policy-gated add/commit/push gp profile function and a profile-independent raw gpush fallback."
  - "The Windows installer writes a static global development environment and the CLI writes one active server URL file per project."
  - "The 2026-08-14 runtime contract distinguishes direct and deferred Codex tool discovery before declaring configured Playwright unavailable."
  - "The 2026-08-15 Windows runtime registers monorepo surfaces independently and reserves their ports transactionally."
  - "The 2026-08-15 Windows project catalogue reuses one bounded scan across every menu and keeps live status authority in the registry."
  - "Native Windows full packages the reproducible-environment command so s env works from the installed runtime rather than only from a source checkout."
  - "The first live Tauri update led to explicit phase/input progress and final-state re-observation for mise, Firebase, Claude/Codex MCP, and localized Flutter diagnostics."
  - "The 2026-08-23 Windows maintainer surface clones or validates the owner repository and enforces one Codex ShipGlows entrypoint channel without accepting generic all/components as authority."
  - "The 2026-08-23 Flutter repair reconverges the managed SDK PATH on every validated rerun and separates Visual Studio C++ readiness from aggregate Flutter Windows build readiness."
  - "The 2026-08-23 stale-session repair lets the DevServer resolve a complete non-reparse ShipGlows-managed Flutter SDK even when its parent process predates the persistent PATH update."
  - "The 2026-08-24 Windows toolbox contract installs provider CLIs machine-wide while activating MCPs only in registered projects from project evidence, with generated agent files excluded locally from Git."
  - "The 2026-08-24 CommunityGlows retest made npm argv, failed-start diagnostics, durable registration ports and inferred Tauri environment status deterministic."
next_review: "2026-09-11"
next_step: "/103-sg-verify Windows operator guide"
---

# ShipGlows - Installation pour Windows

## Diagnostic de configuration après clonage

Après l'enregistrement, le clonage exécute `s env prepare` et affiche la classification. Pour `repairable`, examiner le plan JSON puis lancer la commande exacte `s env prepare-apply -ProjectPath <path> -PlanDigest <digest>` affichée par la CLI. ShipGlows n'applique jamais cette réparation automatiquement et ne fabrique pas les manifests du projet, lockfiles, `.env` ou secrets.

Quand le clone contient un plugin Obsidian sans coffre valide explicitement
déclaré, le diagnostic reste `manual` même si un manifeste ShipGlows générique
pourrait être créé. Il affiche le plugin id, les scripts, les artefacts et les
preuves de détection, puis demande `SHIPGLOWS_OBSIDIAN_VAULT` sans rechercher un
coffre sur la machine. Un chemin relatif, absent ou sans `.obsidian` reste
actionnable comme configuration invalide.

La boîte à outils CLI installée pour toute la machine est un projet `mise`
isolé de vos dépôts. Son `mise.lock` est régénéré pour `windows-x64` après
l'installation des versions exactes ; il ne remplace ni ne modifie le lockfile
d'une application et ne déclenche aucune authentification fournisseur.

Si le diagnostic est `blocked`, le clone reste sur disque mais la commande échoue avec une erreur contextuelle. Corriger manuellement la source invalide puis relancer `s env prepare`; toute configuration existante inconnue ou invalide est préservée plutôt que remplacée.

## Runtime PowerShell

Lancez le DevServer avec `s` ou `shipglows-dev`; n'invoquez pas `shipglows-devserver.ps1` directement. La commande utilise le runtime PowerShell 7.6.5 possede par ShipGlows sans modifier l'installation systeme. La premiere installation complete en ligne peut acquerir l'archive epinglee. Le mode offline ne fonctionne qu'apres validation locale du runtime; sinon, reconnectez la machine et relancez l'installateur complet. Un echec SHA, archive, sonde, verrou ou corruption conserve le pointeur actif precedent.

## 🎯 Options d'installation

Windows offre un parcours PowerShell natif sans WSL pour les tunnels et le
développement local. WSL/Git Bash restent des alternatives facultatives, mais
ne sont pas requis par le parcours Shadow PC.

---

## ✅ Option 1: PowerShell natif (recommandé sur Shadow PC)

**Avantages:**
- ✅ Pas besoin de WSL ni de virtualisation imbriquée
- ✅ Tunnels SSH avec OpenSSH natif
- ✅ DevServer natif Astro, Vite, extensions navigateur, plugins Obsidian, Python/FastAPI et Flutter Web, plus chaîne Flutter Android, en mode full
- ✅ Clone et registre local des dépôts directement dans `%USERPROFILE%\ShipGlows`
- ✅ Git, GitHub CLI, Node/npm, pnpm et uv installés automatiquement en mode full
- ✅ Android Studio proposé pour Android/Firebase Device Streaming et Visual Studio Community C++ pour compiler Flutter Windows
- ✅ Proposition groupée des agents Codex, Claude, OpenCode, Kilo ou Gemini manquants
- ✅ Boîte à outils versionnée Firebase, FlutterFire, Convex, Vercel, Supabase, Clerk et Google Cloud installée globalement pour la machine
- ✅ MCP activés uniquement dans les projets enregistrés selon leurs manifests et preuves Git, via les formats locaux natifs de chaque agent
- ✅ WSL proposé séparément et facultativement ; Turso Cloud proposé uniquement après initialisation d’Ubuntu, sans authentification automatique

1. **Lancer le bootstrap unique ShipGlows:**

   Le script installe automatiquement OpenSSH Client si nécessaire. Windows
   affichera une demande UAC et Windows Update doit être accessible.

   Le même endpoint public fournit automatiquement la variante PowerShell :

   ```powershell
   $installer = Join-Path $env:TEMP 'shipglows-install.ps1'
   curl.exe -fsSL 'https://shipglows.com/shipglows-script?format=powershell' -o $installer
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer
   ```

   Sans `-InstallMode`, le script propose les tunnels SSH, le DevServer local
   complet, ou le poste mainteneur ShipGlows. Le troisième choix clone ou
   valide `%USERPROFILE%\ShipGlows\shipglows`, retire le plugin public Codex
   concurrent et relie les skills directement au clone éditable.

   Pour automatiser exactement le poste mainteneur :

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -InstallMode full -InstallSurface maintainer
   ```

   Les valeurs génériques `full`, `all`, `skills` et l’ancien alias `corpus`
   ne sélectionnent jamais ce canal propriétaire. Les utilisateurs Codex
   ordinaires conservent le plugin public.

   Pour forcer une version ou un tag précis :

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -Version v1.2.3
   ```

   `-Branch`, `-Tag` et `-Ref` sont aussi acceptés comme alias.

   Le bootstrap résout la branche, le tag ou le SHA demandé vers le commit
   canonique GitHub, puis télécharge uniquement son archive publique immuable sans Git. Il installe
   automatiquement Gum dans le runtime ShipGlows pour le menu interactif,
   puis installe Git, GitHub CLI, Node LTS, pnpm, uv et un commit Flutter résolu.
   Les installations Flutter/Dart, JDK 17 et Android SDK externes valides sont
   réutilisées sans remplacer leurs variables ni le `PATH`. Sinon JDK 17 est
   installé dans le profil utilisateur avant la présentation des conditions
   Android; les archives ZIP sont vérifiées et les packages ciblent Android 36.
   La question émulateur n'est posée que si
   l'émulateur, l'image Android 36 ou `ShipGlows_API_36` manque. Un état partiel
   propose une réparation; un état complet supprime la question. Si l'accélération
   n'est pas prouvée, ShipGlows prévient
   du risque de lenteur ou d'échec mais laisse l'opérateur choisir; une réponse
   positive installe l'émulateur, l'image Android 36 et crée `ShipGlows_API_36`
   avec une progression visible. Un téléphone réel reste l'alternative. Les licences
   Android restent à confirmer dans leur flux officiel. En non-interactif,
   `sdkmanager --licenses` est signalé comme action en attente. L'émulateur
   accéléré requiert toujours une virtualisation prouvée; sans elle, l'AVD reste
   installé mais le mode logiciel n'est qu'un diagnostic qui peut être inutilisable
   ou ne jamais terminer son démarrage. Une proposition groupée distincte liste
   ensuite uniquement les gros outils IDE manquants. Android Studio apporte l'IDE
   Android et l'accès à Firebase Device Streaming; Visual Studio Community 2022
   avec « Desktop development with C++ » apporte le compilateur Flutter Windows.
   Une installation déjà complète supprime la question et un Visual Studio partiel
   reçoit uniquement le workload manquant. La progression reste visible et aucun
   redémarrage Windows n'est automatique. L'authentification Firebase, le choix du
   projet, la facturation et la réservation d'un appareil distant restent à faire
   personnellement dans Android Studio. ShipGlows propose aussi d'ouvrir les
   paramètres Developer Mode sans modifier le registre; ce réglage est distinct
   de l'accélération de l'émulateur. Codex, Claude, OpenCode, Kilo et Gemini manquants sont proposés dans une
   question groupée, sans authentification. La boîte à outils versionnée Firebase,
   FlutterFire, Convex, Vercel, Supabase, Clerk et Google Cloud est installée au
   niveau de la machine, indépendamment des projets détectés. Dans chaque projet
   enregistré, ShipGlows déduit ensuite l'inventaire MCP de ses manifests et de
   ses preuves Git, puis écrit uniquement les configurations locales natives des
   agents installés pour Dart/Flutter, Playwright, Firebase, Convex, Clerk,
   Supabase, Vercel et GitHub officiel en lecture seule lorsque ces outils sont
   pertinents. Ces fichiers propres à la machine sont ajoutés à
   `.git/info/exclude` et ne doivent pas être commités. Les configurations de
   projet divergentes sont préservées en parcours ordinaire; le parcours
   mainteneur peut reconverger les fichiers ShipGlows enregistrés et retirer les
   anciennes entrées globales connues. Le MCP Google Cloud reste au catalogue
   jusqu'à sa sélection explicite pour un projet.
   `clerk init`, le lien d'application, les SDK projet et toute authentification
   restent explicites.
   Aucune authentification n'est démarrée. Il ne demande ni
   `sudo`, ni WSL, ni `autossh`. Au premier accès aux dépôts privés, GitHub CLI
   ouvre son authentification officielle dans le navigateur; ShipGlows ne lit
   et ne stocke jamais le token.
   Après installation, `s a` ouvre le tableau **Authentication**. Il affiche
   uniquement `connected`, `disconnected`, `unknown`, `unavailable` ou
   `project-required`, puis lance le flux officiel du CLI choisi. Les déconnexions
   demandent confirmation; ShipGlows ne lit jamais les sorties de compte ni les
   jetons. Le rapport d'environnement distingue aussi `playwright`,
   `playwright-cli`, Playwright MCP, la révision Chromium et la disponibilité motion.

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
   Le même lanceur expose `s env inspect`, `s env plan`, `s env apply`,
   `s env verify` et `s env status`. Ces commandes lisent le contrat
   reproductible du projet et délèguent les versions de Node/pnpm à `mise`;
   elles ne lancent jamais `pnpm install` automatiquement. `inspect`, `plan`,
   `verify` et `status` ne demandent aucune initialisation du DevServer.
   Sans manifest ShipGlows explicite, Windows déduit aussi Node et pnpm depuis
   `package.json`, puis Cargo et la cible Tauri depuis la structure native
   `src-tauri` (`Cargo.toml` et configuration Tauri). Un manifest Flox limité à
   Linux est affiché comme incompatible sous Windows. `plan` peut proposer
   l'acquisition de `mise` ou Rust 1.97.1 dans le toolchain ShipGlows isolé;
   `apply` exige le digest exact et un consentement explicite. MSVC, Windows SDK
   et WebView2 sont observés séparément et ne sont jamais installés implicitement.
   `verify`/`status` terminent avec le code `4` tant qu'un projet détecté n'est pas prêt. Un dossier sans
   source ni capacité gérée reste valide.
   Le DevServer consomme l'état par surface avant de réserver un port : Node et
   le gestionnaire de paquets de l'extension ou du site doivent être prêts,
   tandis qu'un Tauri bloqué reste un diagnostic indépendant. Dans un monorepo
   contenant plusieurs projets Tauri, indiquez toujours le scope exact; aucun
   premier candidat n'est choisi silencieusement. Les wrappers Rust sont actifs
   dans les nouveaux PowerShell gérés et processus agents sans modifier le profil.
   Le menu interactif principal propose `n  Navigate to a project` : il permet
   de choisir un projet puis ouvre un PowerShell enfant dans son dossier
   (`exit` revient au shell initial).
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

### Choisir le bon parcours : site, app, extension Chrome ou plugin Obsidian

ShipGlows détecte la surface exécutable à partir de ses manifests, puis affiche
un libellé compréhensible dans `s help`, `s status`, le dashboard et les
sélecteurs. Après un clone ou un enregistrement manuel, la CLI donne directement
la prochaine commande à lancer.

| Votre projet | Ce que ShipGlows affiche | Parcours |
| --- | --- | --- |
| Site Astro/Vite ou API Python/FastAPI | `Web project` et `URL :<port>` | Start prépare le serveur, Open ouvre l'URL locale. |
| Application Flutter Web | `Flutter app` et `App :<port>` | Start prépare la session gérée, Open ouvre la session Chrome visible avec le cycle Flutter. |
| Extension Chrome CRXJS | `Chrome extension`, `HMR :<port>` et `dist\chrome` | Start construit Manifest V3 et lance HMR, Open ouvre le gestionnaire Chrome et le dossier à charger. |
| Plugin Obsidian | `Obsidian plugin` avec son état, sans URL ni port | Start lance le script watch déclaré puis copie les artefacts dans le coffre explicitement configuré; Open rappelle le rechargement manuel. |

Le parcours complet et copiable est :

```powershell
s start -ProjectPath "C:\chemin\du\projet"
s status -ProjectPath "C:\chemin\du\projet"
s open -ProjectPath "C:\chemin\du\projet"
s stop -ProjectPath "C:\chemin\du\projet"
```

Le menu interactif propose les mêmes actions, avec `Open / load project`. Si
Open reçoit un projet arrêté, ShipGlows explique son type et redonne la commande
Start exacte au lieu de laisser croire qu'une URL manque.

Pour une extension Chrome, le port affiché sert au HMR : ce n'est pas l'adresse
d'un site. Après Open, activez **Developer mode** dans `chrome://extensions`,
choisissez **Load unpacked**, puis sélectionnez `dist\chrome`. ShipGlows ouvre
les deux emplacements utiles, mais n'installe jamais silencieusement l'extension
dans votre profil personnel. La détection automatique actuelle couvre les
projets qui déclarent `@crxjs/vite-plugin` et un script `dev:chrome`; les autres
stacks d'extension ne sont pas annoncées comme prises en charge sans preuve.

Pour un plugin Obsidian, ShipGlows affiche les preuves de détection, l'id du
plugin, les scripts `dev`/`watch`/`start` et `build`, ainsi que `main.js`,
`manifest.json` et l'éventuel `styles.css`. Sans coffre déclaré, l'état reste
`detected` et Start indique exactement la configuration manquante. La réussite
du build et de la copie peut devenir `ready`, mais le chargement réel dans
Obsidian reste `validation-unavailable` jusqu'à votre validation manuelle.

### Monorepos, registre et Flutter Web

Le DevServer détecte Astro, Vite, les extensions navigateur, les plugins Obsidian, Python/FastAPI et Flutter Web à partir des
manifests et signaux de framework, jamais à partir d'un nom de dossier imposé.
Une racine de dépôt ou un monorepo enregistré explicitement peut donc produire
plusieurs surfaces. Chacune possède sa propre entrée de registre, son nom
qualifié, ses journaux et son `ENVIRONMENT.md`. Les surfaces HTTP ont leur port
persistant; un plugin Obsidian n'en réserve aucun.

La recherche est volontairement bornée à quatre niveaux dans le workspace et
trois niveaux sous une racine de projet. Elle ignore les dossiers cachés, les
dépendances, les caches et les sorties de build. Une structure plus profonde ou
sans manifest reconnaissable doit être enregistrée par sa surface exécutable ;
ShipGlows ne prétend pas reconnaître toutes les conventions de monorepo.

Le dashboard et tous les sélecteurs réutilisent le même catalogue. Un scan
linéaire alimente un index non autoritaire en mémoire et dans
`%LOCALAPPDATA%\ShipGlows\DevServer\project-index.json`. Le dernier index valide
s'affiche immédiatement, même après cinq minutes ; le menu le rafraîchit alors
et réconcilie les processus live en arrière-plan, puis adopte le résultat au
prochain affichage. Le premier rendu n'attend donc pas WMI/CIM ; chaque action
de cycle de vie revalide toujours son processus avant mutation. `Refresh` force un
scan synchrone. Clone, register et unregister conservent l'index utilisable mais
le marquent à rafraîchir. Les dates sont écrites au format invariant round-trip,
compatible PowerShell 5.1/Core et indépendant de la locale. Un index corrompu,
incompatible ou lié à un autre workspace est refusé et reconstruit atomiquement
avant usage. Le registre reste la seule
autorité pour le statut live, le port, les journaux et l'identité du processus.

Les commandes d'aide et de sortie évitent le chargement complet du DevServer.
Les modules d'authentification et les outils GitHub/update sont chargés seulement
quand leur action est ouverte.

Les noms affichés sont les chemins de lancement relatifs au workspace, avec `/`
comme séparateur. La navigation n'affiche que ce nom ; les autres actions peuvent
ajouter statut, type et port. La ligne choisie est toujours résolue vers le
`launchPath` canonique exact, puis le manifest est revérifié avant l'action.
Un `package.json` web sans `scripts.dev` n'est pas une surface lançable. Un
plugin Obsidian peut être détecté avec un script `build` seul, mais Start reste
`build-required` tant qu'aucun script long `dev`, `watch` ou `start` n'est déclaré.

La sélection et la réservation d'un port utilisent le même verrou interprocessus
que l'écriture du registre. Deux démarrages concurrents ne peuvent donc pas
réserver le même port pour deux surfaces. La migration d'une ancienne entrée
racine vers sa surface se fait par chemin exécutable et préserve les métadonnées
d'un processus dont l'identité est encore vérifiée.

Lors de l'enregistrement, un port valide déjà présent dans `ENVIRONMENT.md` est
hydraté directement dans le registre s'il n'appartient à aucune autre surface ;
une collision reste à `0` et le fichier durable est réconcilié. Pour npm, un
`package-lock.json` ou `npm-shrinkwrap.json` sélectionne exactement `npm ci` et l'absence de lock
`npm install`. L'installation ne s'exécute que si le digest des manifests/locks
a changé, si le manager/les arguments diffèrent ou si les artefacts du framework
et du gestionnaire manquent ; un état versionné par projet, verrouillé
et remplacé atomiquement après succès seulement si les entrées sont restées
stables pendant l'installation, est conservé sous le runtime DevServer.
Le serveur est créé via WMI hors de l'arbre de handles du CLI :
un appelant qui capture stdout/stderr reçoit donc EOF après la readiness, tandis
que le serveur continue d'écrire dans ses logs durables. Avant de lancer l'enfant,
le wrapper s'assigne à un Job Object Windows nommé avec `KILL_ON_JOB_CLOSE` ; un
échec de création ou d'assignation bloque le lancement. Il reste vivant tant qu'un
descendant du job existe, même si un parent Node court a utilisé detached/unref puis
a quitté. Dans ce wrapper, un `Start-Process`
attendant le serveur redirige nativement stdout/stderr : les logs restent lisibles
sans encodage UTF-16/NUL et le wrapper reste propriétaire jusqu'au stop. Le token Flutter reste dans son
fichier owner-only et n'est pas encodé dans la commande. Le wrapper et le lancement
Flutter réutilisent exclusivement le PowerShell Core portable validé par ShipGlows,
sans recherche dans `PATH`. Si un processus Astro
ou Vite meurt avant d'être prêt, ShipGlows
arrête l'attente immédiatement, conserve une fin de stderr bornée et expurgée,
enregistre l'état `error` et renvoie un échec à la commande appelante. Stop termine
le Job Object exact et ne publie `stopped` qu'après disparition prouvée de l'identité
et du service ; sinon le registre reste inchangé et l'erreur est visible. Un stop
déjà accompli reste idempotent et efface toute erreur live obsolète.

Flutter Web démarre silencieusement dans un Chrome headless dédié et contrôlé
par Flutter. Le registre ne passe à `running` qu'après les événements machine
`app.start` puis `app.started` ; une réponse HTTP ou TCP seule ne prouve pas que
l'application a exécuté `main()`. L'action Open remplace cette session headless
par un Chrome visible toujours contrôlé par Flutter, afin de conserver le hot
reload. Start et Restart restent silencieux et recréent une session headless
gérée ; aucun navigateur ne s'ouvre avant l'action explicite Open.

L'onglet ouvert par Open est volontairement une session de développement
spéciale, avec son profil ShipGlows isolé. Ouvrir manuellement la même URL dans
Vivaldi ou dans un autre navigateur crée un client secondaire : le premier
chargement peut fonctionner, mais Flutter ne garantit pas son cycle DDC après
un rechargement. Pour tester et recharger l'application avec le hot reload,
utilisez donc Open et conservez l'URL exacte `http://127.0.0.1:<port>` ; ShipGlows
n'ouvre ni ne recommande l'alias `localhost` pour cette session.

Un petit superviseur persistant conserve le canal machine Flutter après la fin
de la commande CLI. Les modifications `*.dart` sous `lib/` sont regroupées sur
une fenêtre calme de 500 ms puis déclenchent `app.restart` en mode hot reload.
Le canal local n'accepte que reload, stop et open, avec l'identité secrète du
lancement, une taille et des délais bornés ; il n'exécute aucune commande libre.
La commande explicite `s reload -ProjectPath <path>` cible uniquement une session
Flutter gérée déjà `running` et vérifie l'identité du processus, du daemon et de
`appId` avant d'envoyer `app.restart` en hot reload. Elle affiche `reload
succeeded`, `reload failed` ou `reload unavailable`. Demandée pendant
`starting` ou `building`, elle échoue sans arrêter la compilation. Ce reload Dart
ne relance ni CMake ni MSVC et reste distinct d'un hot restart ou d'un Restart
DevServer complet.

Chaque lancement Chrome reçoit un profil ShipGlows unique. Stop et Restart ne
recherchent un éventuel navigateur orphelin qu'avec le chemin exact de ce profil
et ne terminent jamais Chrome par son seul nom. Le mode historique `web-server`,
qui exige une connexion manuelle compatible avec Dart Debug, reste disponible
uniquement avec `SHIPGLOWS_FLUTTER_DEVICE=web-server` dans `.shipglows.env`.

### Flutter Windows en développement

Sur Windows, une application Flutter qui contient une cible `windows/` utilise par défaut une session supervisée `flutter run -d windows`. Cette session est la boucle normale de développement : elle conserve les logs, recharge les changements Dart et empêche les lancements concurrents. L'attente reste `starting` ou `building` tant que des événements `app.progress` valides entretiennent une lease de 300 secondes, bornée par un plafond total de 600 secondes ; seul le `app.started` correspondant établit `running`. Un daemon mort ou une progression silencieuse atteint toujours un échec déterministe et nettoyé. Au premier démarrage réussi, ShipGlows crée le raccourci Bureau `ShipGlows - <Projet> - Dev`, qui démarre la session ou réutilise celle déjà active.

Le fichier `.shipglows.env` peut forcer `SHIPGLOWS_FLUTTER_DEVICE=windows`, `android`, `chrome` ou `web-server`. Les raccourcis `Windows - Local` et `Windows - CI` restent réservés aux builds figés validés : releases et contrôles ciblés du packaging, des plugins natifs ou du démarrage sans Flutter attaché.

### Flutter Android en développement

`SHIPGLOWS_FLUTTER_DEVICE=android` active la même session live supervisée pour Android. `SHIPGLOWS_FLUTTER_DEVICE_ID=<id>` sélectionne explicitement un téléphone ou un émulateur connecté. Sans identifiant explicite, ShipGlows réutilise un appareil Android disponible ; si aucun n’est prêt, il démarre `ShipGlows_API_36`, attend que Flutter expose son identifiant, puis lance `flutter run -d <device-id>`. Le raccourci Dev réutilise ensuite cette session et conserve les logs ainsi que le hot reload.

Les APK et AAB restent des sorties de release ou de validation autonome ciblée : installation, permissions, notifications, services, plugins natifs et comportement sans Flutter attaché. Ils ne remplacent pas la boucle de développement live.

### Vérifier l'environnement et l'URL utilisés par un agent

Le parcours `full` écrit `%USERPROFILE%\.shipglows\environment.md`. Ce fichier
global statique indique Windows, PowerShell, Codex CLI, Python, Flutter/Dart,
l'état de la toolchain/licences/device Android, du package émulateur, de l'AVD
et de son accélération,
ainsi que la prochaine action Android,
Android Studio, le compilateur Flutter Windows, l'état Firebase Device Streaming,
Playwright et le DevServer natif. Chaque surface enregistrée reçoit aussi un fichier visible et
versionné `<racine-surface>\ENVIRONMENT.md`. Son bloc ShipGlows conserve le port
attribué et l'URL canonique sans écraser le reste du document. Le registre
Windows reste l'autorité pour l'état live, donc start/stop ne réécrivent pas la
documentation du projet.
Pour une extension, le bloc remplace l'URL de page par le port HMR et
`dist\chrome`, puis rappelle le parcours Start, Open, Developer mode, Load
unpacked et Stop. Un agent ou une opératrice reprenant le dépôt retrouve ainsi
la même prochaine action que dans la CLI.

Pour un plugin Obsidian, ce bloc indique qu'URL et port ne s'appliquent pas. Il
rappelle le script watch, la cible explicite et la validation manuelle; le
registre conserve les états live `running`, `ready` et
`validation-unavailable` sans réécrire le document à chaque cycle.

Une réconciliation ou réinstallation qui lit temporairement le port `0` dans
le registre conserve un port valide déjà inscrit dans `ENVIRONMENT.md`. Au
prochain démarrage, ce port durable est réutilisé avec la même réservation
transactionnelle qu'un port demandé explicitement; il n'est remplacé par
`pending first ShipGlows start` que lorsqu'aucune affectation n'existe encore.

Un SDK Flutter géré et déjà valide reconverge son répertoire `bin` dans le
`PATH` utilisateur et dans le processus d'installation à chaque relance. Le
DevServer résout aussi directement ce SDK géré lorsque le terminal ou l'agent
parent a été ouvert avant la mise à jour du `PATH`; il exige alors les binaires
Flutter et Dart complets et refuse les chemins de réanalyse. Le superviseur
relit de même le `CHROME_EXECUTABLE` persistant lorsque la variable du processus
parent est absente, puis réapplique sa contrainte au cache Playwright géré. Le
rapport distingue le workload Visual Studio Desktop C++ de la disponibilité
Flutter Windows complète, qui exige aussi Flutter/Dart et Developer Mode. Si
Flutter remplace temporairement son cache Dart, attendre la fin de l'opération
bornée puis revalider les commandes ; l'absence instantanée de `dart.exe` ne
prouve pas à elle seule une corruption durable.

Le bloc géré porte le schéma explicite
`shipglows-project-environment/v2`. Un ancien bloc ShipGlows sans version est
considéré comme `legacy/v0` puis migré automatiquement lors d'un enregistrement,
d'un démarrage ou de la réconciliation de l'installateur. Le contenu placé hors
des marqueurs ShipGlows est conservé. Un schéma futur inconnu, des marqueurs
incomplets ou plusieurs blocs provoquent un refus sans réécriture du fichier.

Sous Windows, la priorité de port des surfaces HTTP est : port demandé explicitement, variable
`SHIPGLOWS_ENV_PORT` du processus, `.shipglows.env` du projet, port durable de
`ENVIRONMENT.md`, registre persistant, puis premier port libre de `3000` à
`3100`. Quand le registre ne porte aucun port, `ENVIRONMENT.md` est consulté
avant l'allocation libre. Le numéro obtenu est
propre à la surface. Si ShipGlows lance la surface sur `3002` alors que le dépôt
déclare `3014`, `ENVIRONMENT.md` contient `http://127.0.0.1:3002`; `3014` reste
un fallback de lancement direct. `s open` refuse un statut inactif ou un port
non attribué dans le registre. Cette priorité ne s'applique pas aux plugins
Obsidian, dont Start refuse un port explicite.

Le schéma v1 existant est accepté puis migré par le même mécanisme d'écriture borné.

Une extension CRXJS n'est reconnue que si elle déclare `@crxjs/vite-plugin` et
expose explicitement `dev:chrome`. ShipGlows conserve son lockfile, honore une version exacte de pnpm
via Corepack, transmet le port HMR réservé, puis attend un Manifest V3 frais dans
un dossier Chrome pris en charge. `s open` ouvre le gestionnaire d'extensions et
le dossier non empaqueté; le chargement dans un profil personnel reste une action
explicite de l'opératrice.
Avec pnpm, les options `--host` et `--port` sont transmises directement au script;
le séparateur supplémentaire reste réservé au chemin npm.
La disponibilité d'une extension respecte le budget de démarrage de 90 secondes
demandé par le lanceur; elle ne le tronque plus silencieusement à 60 secondes.

Un plugin Obsidian est reconnu avant le fallback Vite quand `manifest.json`
porte `id`, `name`, `version` et `minAppVersion`, que le paquet dépend de
`obsidian`, qu'un `main.ts`, `src/main.ts` ou `main.js` existe et qu'un workflow
`dev`, `watch`, `start` ou `build` est déclaré. Pour activer l'installation,
créez dans la racine du plugin un `.shipglows.env` explicite :

```dotenv
SHIPGLOWS_OBSIDIAN_VAULT=C:\chemin\absolu\vers\le-coffre
SHIPGLOWS_OBSIDIAN_SYNC_MODE=copy
```

Le coffre doit déjà exister et contenir `.obsidian`. ShipGlows ne recherche ni
ne sélectionne aucun coffre personnel, et refuse les liens de réanalyse sur le
coffre, `.obsidian`, le dossier cible et les artefacts. Un Start explicite lance
le script watch déclaré sans options HTTP, attend un `main.js` frais, puis copie
atomiquement et vérifie par SHA-256 `main.js`, `manifest.json` et l'éventuel
`styles.css` dans `.obsidian/plugins/<plugin-id>`. Il ne supprime pas les fichiers
supplémentaires déjà présents dans cette cible. `s open` ne pilote pas Obsidian :
il affiche le dossier synchronisé et demande de recharger ou d'activer le plugin
manuellement.

La réinstallation du runtime repasse aussi les projets déjà enregistrés dans le
détecteur courant avant de migrer leur bloc d'environnement. Le registre et
`ENVIRONMENT.md` ne peuvent ainsi pas conserver deux types de projet différents
après l'ajout d'un adaptateur plus précis.

Pour Flutter, `.shipglows.env` accepte aussi
`SHIPGLOWS_DART_DEFINE_FILE=<chemin-relatif>` afin de transmettre durablement un
fichier JSON ou `.env` existant avec `--dart-define-from-file`, sans inscrire son
contenu dans les journaux. Le chemin doit rester dans le projet. Ce fichier de
valeurs peut être ignoré par Git lorsqu'il contient des secrets ; seule sa
référence appartient à la politique ShipGlows.

L'installateur maintient un bloc borné dans le fichier global natif de chaque
agent détecté : `%USERPROFILE%\.codex\AGENTS.md`,
`%USERPROFILE%\.claude\CLAUDE.md`, `%USERPROFILE%\.config\opencode\AGENTS.md`
et `%USERPROFILE%\.config\kilo\AGENTS.md`. Il ne remplace pas vos autres
instructions et n'enveloppe aucune commande. Ce bloc renvoie vers le fichier
d'environnement dynamique, demande de préférer un outil spécialisé réellement
appelable et rappelle d'inspecter l'inventaire direct puis différé ou recherchable.
Les apps et connecteurs ChatGPT ne sont pas automatiquement des outils CLI.

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
## Tauri Android on Windows

When a Tauri Android project is detected, the full installer separately offers
the reusable ShipGlows baseline: exact Rust and Android targets through an
isolated `mise` environment, plus the exact NDK through `sdkmanager`. Older or
incomplete projects remain untouched and become `migration_required`; an optional
Codex handoff opens only after explicit confirmation.

The installed `cargo`, `rustc`, and `rustup` wrappers reproduce ShipGlows's safe
isolated `mise` environment; they neither require nor modify global `mise trust`.

The generated Gradle project may omit `buildToolsVersion` and `ndkVersion`; in
that case the validated host packages remain authoritative and no migration is
invented. An explicit incompatible project value still produces a migration
difference. During `s u`, the active phase and elapsed operation stay visible,
`[input]` identifies every point where the installer is waiting for you, and
`[continue] Answer received` marks the restart. Phase duration excludes that wait.
Current trusted Windows `mise` output starts with its calendar version
(`2026.8.2 windows-x64 (...)`); warnings on separate lines do not invalidate it.
