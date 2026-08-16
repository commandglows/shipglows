---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.6.2"
project: "ShipGlows"
created: "2026-08-07"
created_at: "2026-08-07 21:55:18 UTC"
updated: "2026-08-16"
updated_at: "2026-08-16 07:27:08 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "native-windows-devserver-astro-python-flutter"
owner: "Diane"
confidence: high
user_story: "En tant qu'operateur ShipGlows sur un Shadow PC Windows sans WSL ni virtualisation imbriquee, je veux cloner et piloter mes projets Astro, Python/FastAPI et Flutter depuis un DevServer Windows natif, afin de deplacer mon espace de developpement hors d'un VPS couteux sans perdre le cycle clone, install, start, logs, open, restart et stop."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "install-shipglows.ps1"
  - "local/install_local.ps1"
  - "cli/shipglows.sh"
  - "cli/lib.sh"
  - "cli/config.sh"
  - "cli/windows/"
  - "tests/windows/"
  - "README.md"
  - "shipglows_data/technical/operator-guides/windows-devserver.md"
  - "shipglows_data/technical/runtime-cli.md"
  - "shipglows_data/technical/installer-and-user-scope.md"
  - "shipglows_data/technical/code-docs-map.md"
  - "skills/references/agent-runtime-awareness.md"
  - "skills/sg-development/SKILL.md"
  - "skills/sg-engineering/SKILL.md"
  - "plugins/shipglows/skills/shipglows/SKILL.md"
  - "tools/sync_shipglows_public_bootstrap.sh"
  - "/home/claude/shipglows_app/site/src/generated/shipglows-installer.ps1"
  - "/home/claude/shipglows_app/site/src/pages/shipglows-script.ts"
  - "/home/claude/shipglows_app/site/tests/install/shipglowsInstaller.test.ts"
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/architecture.md"
    artifact_version: "1.8.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.7.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/runtime-cli.md"
    artifact_version: "1.0.31"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/installer-and-user-scope.md"
    artifact_version: "1.1.9"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Operator scope on 2026-08-07: the active development stacks are Astro, Python, and Flutter only."
  - "Operator constraint on 2026-08-07: Shadow PC does not permit or support the WSL/virtualization path required by the Linux CLI."
  - "Current repository evidence: install-shipglows.ps1 installs only the native Windows local tunnel layer; the complete installer remains Linux/Ubuntu-only."
  - "Current runtime evidence: cli/lib.sh couples environment lifecycle to Flox, PM2, Caddy, tmux, ss, fuser, Bash process groups, and Unix paths."
  - "Current Windows evidence: local/install_local.ps1 is verified as a native PowerShell 5.1-compatible OpenSSH/tunnel setup path."
  - "Official uv documentation confirms native Windows project environments, lock/sync behavior, and uv run process handling."
  - "Official Shadow rules prohibit unsupported virtualization software and server hosting, requiring a localhost-only interactive development contract."
  - "Operator clarification on 2026-08-07: native Windows full must be installable from the same public curl.exe endpoint already used for Windows local, Linux and Termux, and the CommandGlows ShipGlows installer page must expose that route."
  - "CommandGlows evidence: commandglows_site/src/data/scriptInstallPages.ts already defines windows-full but marks it unavailable, while /shipglows-script serves the generated PowerShell bootstrap through ?format=powershell."
  - "OWASP ASVS 5.0.0 official guidance identifies v5.0.0-1.2.5 for OS command injection and v5.0.0-5.3.2 for strict file path validation; both apply to this installer/runtime boundary."
  - "Operator-approved 2026-08-15 catalogue contract: all Windows menus share one cached linear discovery pass, select by canonical launch identity, and retain the registry as live-state authority."
  - "Official Codex, Claude Code and OpenCode documentation confirms package-managed CLI installation; Windows full keeps every coding agent as an explicit per-agent choice and does not own authentication."
next_step: "/102-sg-start native-windows-devserver-astro-python-flutter"
---

# Title

Native Windows DevServer for Astro, Python, and Flutter

# Status

Ready. The implementation contract passed the adversarial readiness review, including the public bootstrap/page consequences, Windows process safety, OWASP Security Gate and proportional proof contract. Implementation may begin; verification and Shadow proof remain pending.

# User Story

En tant qu'operateur ShipGlows sur un Shadow PC Windows sans WSL ni virtualisation imbriquee, je veux cloner et piloter mes projets Astro, Python/FastAPI et Flutter depuis un DevServer Windows natif, afin de deplacer mon espace de developpement hors d'un VPS couteux sans perdre le cycle clone, install, start, logs, open, restart et stop.

# Minimal Behavior Contract

L'operateur telecharge avec `curl.exe` le bootstrap PowerShell depuis l'endpoint public ShipGlows, choisit le mode Windows `full`, puis lance un menu ShipGlows natif dans PowerShell pour enregistrer ou cloner un depot et demarrer un projet Astro, Python/FastAPI ou Flutter Web. Le mode Windows `local` conserve l'installation des tunnels; le mode Windows `full` installe uniquement le DevServer natif et ses commandes, car les projets tournent directement sur le Shadow et sont accessibles en localhost. ShipGlows detecte le type de projet, verifie ses outils, installe ses dependances avec le gestionnaire supporte, attribue un port local libre, lance le bon processus et rend visibles son statut, son URL et ses logs. Une erreur de bootstrap, de dependance, de detection, de port ou de processus ne doit jamais etre annoncee comme un succes ni laisser un registre mensonger; elle doit conserver les sources intactes et proposer une recuperation. Le cas facile a oublier est un PID recycle ou un registre obsolete apres l'arret automatique de Shadow: ShipGlows doit revalider l'identite du processus avant toute action et reconstruire l'etat observable sans tuer un processus tiers.

# Success Behavior

- Depuis Windows PowerShell 5.1 ou PowerShell 7, l'operateur peut lancer `s` ou `shipglows-dev` sans Bash, WSL, Docker, Flox, PM2, Caddy, `sudo` ou virtualisation imbriquee. Ces commandes `.cmd` ne dependent pas du profil PowerShell; `s` est installe seulement si le nom n'est pas deja occupe.
- Le meme endpoint `https://shipglows.com/shipglows-script?format=powershell` sert l'installateur Windows local et full; sans `-InstallMode`, une console interactive demande explicitement tunnel local ou DevServer full (full recommande). `-InstallMode local|full` reste disponible pour l'automatisation; une entree non interactive sans mode preserve le fallback local historique.
- Le mode full prepare Git, GitHub CLI, Node LTS/npm, pnpm, uv et un commit Flutter stable resolu. JDK 17 et les outils Android sont user-scope; les conditions et licences Android restent des confirmations officielles explicites. En non-interactif, Android reste `pending`.
- Le dashboard decouvre les projets enregistres, affiche `running`, `stopped`, `error` ou `unknown`, le type de projet, le port et l'URL locale.
- Un clone Git reussi est place par defaut directement sous `%USERPROFILE%\ShipGlows\<repo>` et n'est enregistre qu'apres validation du chemin et du depot.
- Astro respecte le lockfile existant, installe les dependances sans migration implicite, puis expose une URL `http://127.0.0.1:<port>`.
- Python/FastAPI utilise `uv` et un environnement `.venv`; un projet avec `uv.lock` demarre en mode verrouille et echoue clairement si le lockfile est incoherent.
- Flutter Web utilise le SDK Windows, execute `flutter pub get`, puis ouvre une session terminal interactive conservant les commandes de hot reload/hot restart.
- Les actions start, stop, restart, logs et open produisent toujours un resultat visible et mettent a jour atomiquement le registre local.
- Apres extinction/reconnexion Shadow, le prochain lancement marque les anciens processus comme stale/stopped sans supprimer les projets ni cibler un PID recycle.

# Error Behavior

- Un outil absent produit une liste precise des prerequis manquants et une commande d'installation ou une action guidee; aucun projet n'est marque running.
- Un depot invalide, un chemin hors workspace non confirme, un nom dangereux ou une URL Git mal formee est refuse avant toute ecriture durable.
- Un echec de clone supprime uniquement le repertoire temporaire cree par ShipGlows; un repertoire preexistant n'est jamais ecrase ou nettoye.
- Une detection ambigue ne lance aucune commande generique. Elle affiche les fichiers reconnus et les conventions acceptees.
- Un echec d'installation conserve le projet, redirige stdout/stderr vers des logs bornes et enregistre un etat `error` recuperable.
- Une collision de port declenche une nouvelle allocation avant lancement; un port explicitement fixe dans `.shipglows.env` echoue proprement s'il est deja occupe.
- Stop/restart refuse d'agir si le PID, l'heure de creation, le chemin executable ou la signature de commande ne correspondent plus au processus enregistre.
- Un processus qui quitte pendant la fenetre de stabilite n'est pas annonce online; le message pointe vers le log d'erreur.
- Aucun token, contenu de `.env`, argument secret, URL Git avec credentials, ou variable d'environnement sensible n'est copie dans le registre ou affiche dans les diagnostics.
- La fermeture automatique de Shadow est traitee comme une perte de processus locale normale, jamais comme une raison de tenter de contourner l'extinction ou de transformer Shadow en serveur persistant.

# Problem

Le DevServer actuel est une surface serveur Linux. Son installation et son runtime reposent sur Bash, Flox, PM2, Caddy, `apt`, `systemctl`, `tmux`, `ss`, `fuser`, des groupes de processus POSIX et des chemins Unix. Le bootstrap PowerShell existant ne fournit que le tunnel OpenSSH local. Sur Shadow PC, WSL et la virtualisation imbriquee ne constituent pas une voie autorisee ou supportee, tandis que conserver un VPS uniquement pour lancer des devservers impose un cout disproportionne au stack reel de l'operateur.

# Solution

Ajouter un backend DevServer Windows natif, borne a Astro, Python/FastAPI et Flutter Web, qui partage les contrats utilisateur de ShipGlows mais pas les mecanismes Linux. PowerShell possede l'orchestration, un registre JSON atomique possede l'etat local, Node/pnpm, uv et Flutter possedent les environnements de projet, et Windows Terminal ou PowerShell possede les sessions interactives. Le backend Linux reste inchangé et canonique pour l'hebergement serveur.

# Scope In

- Nouveau runtime PowerShell sous `cli/windows/`, compatible Windows PowerShell 5.1 et PowerShell 7.
- Commande `.cmd` installee `shipglows-dev`, avec raccourci `s` si aucun conflit n'existe; le runtime est ajoute au `PATH` utilisateur et a la session PowerShell d'installation.
- Racine des projets par defaut `%USERPROFILE%\ShipGlows`, configurable par une variable ShipGlows dediee.
- Registre local JSON atomique sous `%LOCALAPPDATA%\ShipGlows\DevServer\registry.json`.
- Detection et lifecycle Astro avec pnpm prioritaire quand `pnpm-lock.yaml` existe, npm quand `package-lock.json` existe, et aucun changement implicite de package manager.
- Detection et lifecycle Python/FastAPI avec `uv`, `pyproject.toml`, `uv.lock`, `.python-version` et `.venv`; compatibilite bornee `requirements.txt` via un chemin uv explicite.
- Detection et lifecycle Flutter Web avec `pubspec.yaml`, dependance `flutter`, dossier `web/`, SDK Flutter Windows et terminal interactif.
- En mode `full`, reutilisation prioritaire des Flutter/Dart, JDK 17 et Android SDK externes valides sans remplacer leurs variables/PATH; sinon installation user-scope depuis des metadonnees officielles resolues, SHA-256 complet et extraction ZIP bornee rejetant traversal, liens et layouts ambigus. Un clone Flutter partiel gere est mis en quarantaine.
- Conditions Android presentees avant telechargement et licences via `sdkmanager --licenses`, sans reponse injectee; refus ou non-interactif produit un etat `pending` actionnable.
- Diagnostics bornes avec transport d'arguments exact PowerShell 5.1 pour EXE/CMD/BAT, identite PID+heure de demarrage avant arret d'arbre et readiness separee `ToolchainReady`, `LicensesReady`, `DeviceReady`; seul le marqueur Android toolchain positif exact avec licences confirmees prouve la toolchain.
- Provisioning Android automatique limite explicitement a Windows x64 avant tout telechargement. Les packages plateforme/build-tools/image sont centralises sur Android API 36. L'emulateur est propose seulement apres preuve de virtualisation imbriquee; sinon, telephone reel.
- MCP Dart/Flutter et Playwright exact-version pour les agents installes. OpenCode v2 utilise `mcp.servers`; Kilo prefere `kilo` et detecte `kilocode`. JSON/JSONC existant reste byte-identique et pending si aucun chemin natif sur n'est prouve.
- Firebase CLI, FlutterFire CLI et Supabase CLI prepares uniquement depuis un scan borne des manifests, avec version exacte resolue, code retour et executable final verifies.
- Actions dashboard, clone, register existing project, start, stop, restart, logs, open, unregister, stop all et refresh.
- Allocation de ports dans la plage ShipGlows 3000-3100 avec `Get-NetTCPConnection` et fallback .NET borne.
- Registre de processus contenant au minimum projet, type, PID, process creation time, executable path, command signature, port, status, started_at, log paths et last_error sans secret.
- Fenetre de stabilite avant annonce `running` et probe HTTP bornee pour Astro/FastAPI/Flutter Web.
- Logs stdout/stderr bornes ou rotation simple pour les processus non interactifs.
- Extension opt-in du bootstrap PowerShell pour installer la surface DevServer sans changer le comportement tunnel par defaut.
- Contrat de modes PowerShell `local|full`: `local` installe la couche tunnel existante; `full` installe le DevServer Windows natif sans tunnel automatique.
- Installation Windows depuis le meme endpoint public que Windows local, via `curl.exe` vers un fichier temporaire puis `powershell.exe -File ...`; la console interactive demande le mode et l'automatisation peut transmettre `-InstallMode full`; aucun pipe direct vers `Invoke-Expression`.
- Synchronisation byte-for-byte de `install-shipglows.ps1` vers l'artefact genere du site ShipGlows et verification anti-drift dans les deux repos.
- Publication de la variante `windows-full` EN/FR sur la page publique ShipGlows avec commande copiable, limites exactes et tests de route/contenu.
- Tests PowerShell sans dependance de test tierce obligatoire, fixtures Astro/Python/Flutter minimales et smoke reel sur Shadow.
- Documentation Windows, runtime, installateur, architecture, contexte et code-doc map.

# Scope Out

- WSL, Hyper-V, Docker Desktop, conteneurs et toute virtualisation imbriquee.
- Hebergement public ou persistant sur Shadow, exposition Internet, Caddy, DuckDNS et HTTPS public.
- Flox, Nix, PM2, `systemctl`, `tmux`, `autossh` et emulation de semantiques POSIX.
- Equivalence du menu local Unix `urls`, tunnels multiples automatiques, OAuth MCP/Clerk/Blacksmith/Turso et promotion automatique de cle SSH.
- Next.js, Nuxt, Vue, Vite generique, Expo, Dart seul, Go, Rust et autres runtimes dans la premiere version.
- Lifecycle DevServer Android persistant. L'emulateur reste conditionnel aux capacites de virtualisation du poste; un telephone reel est le fallback supporte.
- iOS, macOS et Linux desktop Flutter.
- Persistance ou resurrection automatique des processus apres arret/reboot de Shadow.
- Suppression physique des repos depuis le menu. V1 peut uniquement unregister un projet; la source reste sur disque.
- Migration automatique npm vers pnpm, requirements vers pyproject, ou modification automatique des lockfiles existants.
- Execution arbitraire d'une commande stockee dans `.shipglows.env`; ce fichier reste data-only et closed-schema.
- Portage de la TUI, du launcher Codex/MCP, des outils Blacksmith/Turso et des menus d'administration serveur.

# Constraints

- Respecter les restrictions Shadow: localhost et usage interactif de developpement uniquement; ne pas contourner l'arret automatique.
- Ne jamais modifier le comportement du CLI Linux pour obtenir une pseudo-parite Windows.
- Le bootstrap PowerShell existant reste compatible et continue d'installer le tunnel local par defaut.
- Le terme `full` est specifique a la plateforme: sous Linux il conserve la couche serveur Ubuntu; sous Windows il signifie DevServer natif pour Astro, Python/FastAPI et Flutter Web, sans tunnel automatique ni outils serveur Linux.
- L'endpoint public ne duplique pas la logique: `install-shipglows.ps1` dans le depot ShipGlows reste l'autorite et le site ShipGlows sert uniquement l'artefact genere synchronise.
- Support minimum Windows PowerShell 5.1; PowerShell 7 est supporte sans devenir obligatoire.
- Aucun module PowerShell Gallery obligatoire dans le chemin critique V1.
- Utiliser des APIs PowerShell/.NET natives pour processus, JSON, fichiers atomiques, ports et ouverture navigateur.
- Ne jamais interpoler une URL, un chemin de repo ou une valeur de config dans une chaine executee par `Invoke-Expression`.
- Utiliser des listes d'arguments et des executables resolus explicitement; traiter les manifests et scripts projet comme des donnees non fiables jusqu'au lancement volontaire.
- Tous les fichiers d'etat runtime restent dans `%LOCALAPPDATA%`; les sources et lockfiles restent dans le repo.
- Les chemins avec espaces, accents, apostrophes et longueurs Windows usuelles doivent fonctionner.
- La surface Windows doit conserver le vocabulaire utilisateur ShipGlows sans promettre la parite des moteurs Linux exclus.

# Test Contract

- Surface profile: Windows PowerShell runtime managing Astro, Python/FastAPI and Flutter Web processes.
- Proof profile: native Windows install/runtime plus public installer/page parity; no hosted application backend.
- Automated proof: PowerShell parser checks; unit-like fixture scripts for validation, framework detection, port allocation, atomic registry, stale PID protection, command construction and redaction; existing Bash tests remain green.
- Integration proof: start/health/log/stop cycles against minimal Astro and FastAPI fixtures on a Windows host; Flutter fixture runs through dependency and interactive-launch checks.
- Manual proof: execute the complete install, clone/register, start, open, hot reload, restart, stop, stale-state recovery and uninstall/unregister path on the constrained Shadow PC.
- Ordered proof path: static/parser -> fixture tests -> Windows process integration -> browser localhost checks -> Flutter interactive check -> Shadow manual checklist.
- Checklist path: `shipglows_data/workflow/test-checklists/native-windows-devserver-astro-python-flutter.md`.
- Required scenario IDs: `BOOT-FULL-01`, `BOOT-LOCAL-02`, `ASTRO-START-03`, `PYTHON-START-04`, `FLUTTER-WEB-05`, `PORT-RECOVERY-06`, `STALE-PID-07`, `REGISTRY-ATOMIC-08`, `REDACTION-09`, `PUBLIC-PARITY-10`, `SHADOW-RECONNECT-11`, `ANDROID-FULL-12`, `ANDROID-NONINTERACTIVE-13`, `ANDROID-EMULATOR-14`, `AGENT-MCP-15`, `SERVICE-CLI-16`.
- Required results: full public bootstrap installs the DevServer without a tunnel; local bootstrap remains compatible; each supported stack starts and serves localhost; process identity and registry recovery are safe; secrets are absent from logs; ShipGlows page/endpoint match the canonical script; Shadow reconnect is recoverable.
- Exception with proof: no real emulator/package/license operation runs in automated proof; acceptance, refusal, acceleration-proven, acceleration-uncertain and non-interactive branches use mocks, while the approved Shadow bootstrap supplies the real package/AVD proof.
- Exception with proof: public URL, Caddy and persistent-hosting tests are excluded by product scope and Shadow restrictions.
- Runtime observability exception: Sentry is not applicable because this is a local CLI/bootstrap with no hosted application telemetry contract; safe redacted diagnostic/log-copy behavior is required instead.
- Build-time header exception: web build-time Paris/UTC headers are not applicable to the PowerShell runtime; public ShipGlows Astro build/deployment checks remain required for the installer page and raw endpoint.

## ZOMBIES coverage

Flutter Android couvre zero/one/many besoins de services detectes avec scan
borne sans reparse; hote x64 ou non-x64; transport EXE/CMD/BAT avec espaces,
Unicode, guillemets et metacaracteres; archives traversal/symlink; acceleration
emulateur prouvee ou incertaine, acceptation et refus; reruns; outils partiels ou
corrompus; configuration MCP existante avec secrets; licences pending en mode
non-interactif; remplacement atomique. Aucun test n'accepte les licences,
n'active Developer Mode, n'authentifie un agent ou ne modifie un projet reel.

- Z — Zero: empty registry, no projects, missing tools, no free recorded process, absent logs.
- O — One: one valid project per supported stack, one process, one port, one log stream.
- M — Many: multiple projects, simultaneous distinct ports, stop all, repeated refresh/restart, duplicate repo names in different paths.
- B — Boundary Behaviors: ports 3000 and 3100, exhausted range, paths with spaces/Unicode, maximum reasonable log size, stale PID reuse, locked registry file.
- I — Interface definition: PowerShell to Git/Node/pnpm/uv/Flutter, registry to OS process identity, DevServer to browser, bootstrap to installed profile command.
- E — Exceptional behavior: clone failure, dependency failure, child exit, occupied port, malformed JSON, partial atomic write, missing Windows Terminal, cancelled install, Shadow shutdown.
- S — Simple Scenarios, Simple Solutions: one native backend and one closed registry; no abstraction pretending Flox/PM2 parity and no general-purpose runtime plugin system in V1.

# Dependencies

- Windows 10/11 environment supplied by Shadow PC, with Windows PowerShell 5.1 available.
- Git for Windows for clone operations; existing repos can still be registered when Git installation is unavailable. Full installs it automatically where WinGet is available.
- GitHub CLI for browser authentication and searchable private/public repository discovery; `gh` exclusively owns credentials and ShipGlows never reads or stores tokens. Full installs it automatically where WinGet is available.
- Node.js LTS/npm and pnpm for Astro. Full installs Node LTS, attempts Corepack first for pnpm, then falls back to npm global installation when Corepack cannot enable it. npm is used only when the repo owns `package-lock.json`.
- `uv` for Python version/environment/dependency ownership. Full installs it automatically through WinGet; `uv run` and `uv sync --locked` are the preferred project paths.
- Flutter SDK for Windows with web and Android support. Full installs stable into `%LOCALAPPDATA%\\ShipGlows\\flutter`; Android package/system confirmations and licenses remain explicit.
- Installed coding agents: Windows full detects Codex, Claude Code, OpenCode and Kilo (`kilocode` compatibility), then prepares Dart/Flutter and Playwright MCP without installing agents, reading credentials or starting authentication. Existing JSON/JSONC may remain explicitly pending to preserve comments and secrets.
- Windows Terminal when available; visible `powershell.exe`/`pwsh.exe` process fallback otherwise.
- Gum `0.17.0` for the native interactive menu, installed into the ShipGlows user runtime from the official Charmbracelet release after pinned SHA-256 validation; the plain PowerShell menu remains the recovery fallback.
- Existing `install-shipglows.ps1` distribution path for opt-in bootstrap integration.
- ShipGlows public distribution authority at `https://shipglows.com/shipglows-script?format=powershell`, backed by `shipglows_app/site/src/generated/shipglows-installer.ps1`.
- Fresh external docs verdict: `fresh-docs checked` on 2026-08-15 against:
  - Astral uv, `Running commands`: https://docs.astral.sh/uv/concepts/projects/run/
  - Astral uv, `Locking and syncing`: https://docs.astral.sh/uv/concepts/projects/sync/
  - Astral uv, `Working on projects`: https://docs.astral.sh/uv/guides/projects/
  - Microsoft PowerShell process documentation: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process
  - Microsoft NetTCPIP documentation: https://learn.microsoft.com/powershell/module/nettcpip/get-nettcpconnection
  - Flutter Windows installation: https://docs.flutter.dev/get-started/install/windows
  - Flutter web development: https://docs.flutter.dev/platform-integration/web/building
  - Android command-line tools repository: https://dl.google.com/android/repository/repository2-3.xml
  - Android command-line tools SHA-256 download table: https://developer.android.com/studio?hl=en
  - Android SDK terms: https://developer.android.com/studio/terms
  - Android emulator acceleration: https://developer.android.com/studio/run/emulator-acceleration
  - Adoptium API: https://api.adoptium.net/q/swagger-ui/
  - OpenCode v2 MCP servers: https://opencode.ai/v2/docs/mcp-servers
  - Kilo CLI MCP: https://kilo.ai/docs/automate/mcp/using-in-cli
  - Shadow rules and restrictions: https://support.shadow.tech/hc/en-us/articles/32731830348305-Rules-and-Restrictions-on-Shadow
- Re-check these sources during readiness/implementation if local installed versions expose a conflict.

# Invariants

- Linux runtime behavior remains unchanged unless a shared contract explicitly requires a compatible additive change.
- `install-shipglows.ps1` default behavior remains the currently verified local tunnel installation; DevServer install is explicit.
- One project maps to at most one ShipGlows-managed Windows process at a time.
- A status is derived from current OS/process/port evidence; registry text alone never proves `running`.
- Stop/restart targets a process only after matching PID plus creation time plus expected command/executable identity.
- Registry replacement is atomic and preserves the last valid snapshot after lock/write/validation failure.
- Port allocation avoids both active Windows listeners and live ports reserved by managed registry entries.
- Project paths are canonical absolute Windows paths and validated before clone, registration, process launch or unregister.
- Commands are constructed as executable plus argument arrays; `Invoke-Expression` is forbidden.
- Secrets and raw environment values never enter registry, routine logs, diagnostics or process summaries.
- Dependency installation respects repository lockfiles and never silently migrates package manager or runtime format.
- A successful start requires a live process through the stability window and, where applicable, a successful bounded localhost probe.
- No feature attempts to keep Shadow alive, expose a public service, or resurrect processes after automatic shutdown.

# Links & Consequences

- `install-shipglows.ps1` gains an explicit surface selector and archive extraction for Windows DevServer files; supply-chain validation and existing local installer extraction guarantees must remain intact.
- `tools/sync_shipglows_public_bootstrap.sh` synchronizes/checks the canonical ShipGlows site generated shell and PowerShell assets.
- `/home/claude/shipglows_app/site/src/data/installPages.ts` exposes `windows-full` in English and French, with an exact copyable `curl.exe` + `powershell.exe ... -File` command that asks for the mode; `-InstallMode full` remains the automation form.
- `/home/claude/shipglows_app/site/src/pages/shipglows-script.ts` remains the single negotiated raw endpoint; no second Windows-full route is introduced.
- `local/install_local.ps1` remains tunnel-owned and should not absorb DevServer runtime logic.
- `cli/windows/` becomes the Windows runtime authority while `cli/*.sh` remains the Linux runtime authority.
- `.shipglows.env` keeps its existing closed schema. `SHIPGLOWS_ENV_PORT` may be consumed cross-platform only after equivalent validation; `SHIPGLOWS_AUTO_REPAIR` must not authorize arbitrary remediation.
- The public product promise changes from “native Windows tunnel only” to “native Windows local DevServer for three supported stacks”; README and public installer surfaces must state exact limitations.
- Code-doc mapping must add Windows runtime and installer patterns with Windows parser/integration proof requirements.
- Existing Linux regression suites must run to prove the additive backend did not alter server semantics.
- Shadow automatic shutdown means the registry is durable but process state is ephemeral; UX and docs must teach refresh/restart rather than persistence.

# Documentation Coherence

- Update `README.md` with the Windows DevServer capability matrix, install selector, supported stacks and excluded hosting behavior.
- Update `shipglows_data/technical/operator-guides/windows-devserver.md` to separate native tunnel mode from native DevServer mode and remove the old implication that WSL is the only complete development path.
- Update `shipglows_data/technical/runtime-cli.md` with the dual-backend architecture, Windows registry/process contracts and supported framework matrix.
- Update `shipglows_data/technical/installer-and-user-scope.md` with the opt-in DevServer surface, user-scoped paths and dependency authority.
- Update `shipglows_data/technical/architecture.md`, `context.md` and `context-function-tree.md` for the new entrypoints and invariants.
- Update `shipglows_data/technical/code-docs-map.md` with `cli/windows/**`, PowerShell installer files and `tests/windows/**` validation routes.
- Add an operator checklist under `shipglows_data/workflow/test-checklists/` for real Shadow proof.
- Review public ShipGlows installer copy only after implementation proves the capability; do not publish the promise from the spec alone.
- Update the ShipGlows runtime installer page in both languages, its generated PowerShell artifact and deployment tests in the same release wave as the proven Windows full installer.
- Changelog update is required only when the implementation is ready to ship.

# Edge Cases

- Workspace or project path contains spaces, Unicode, apostrophes, parentheses or a drive letter with different casing.
- Repo already exists, clone destination is non-empty, or two repos share the same basename.
- `pnpm-lock.yaml` and `package-lock.json` both exist; fail as ambiguous instead of choosing silently.
- Astro is declared only in devDependencies, or the `dev` script wraps Astro with additional arguments.
- `pyproject.toml` exists without `uv.lock`; initial sync may create one only with explicit visible notice and must not silently dirty a repo in locked mode.
- Legacy Python project has only `requirements.txt`; install into `.venv` with uv without claiming lockfile reproducibility.
- FastAPI app is `main:app` or `app.main:app`; any other import target fails with an actionable convention message in V1.
- Flutter project lacks `web/`, browser support, or a compatible SDK; do not mutate platforms automatically without confirmation.
- Windows Terminal is absent; launch a visible PowerShell fallback for Flutter.
- A process forks a child and the parent exits; status must not attach blindly to an unrelated child.
- PID is reused after Shadow shutdown or reboot.
- Registry JSON is empty, truncated, schema-incompatible, locked by another process or replaced concurrently.
- Port becomes occupied between allocation and process bind; detect failed stability/probe and retry once with a new port only when the project did not request a fixed port.
- Browser opens before server readiness; open only after stability/probe success.
- Stop is requested twice; second stop is idempotent and reports already stopped.
- User closes the interactive Flutter terminal manually; refresh transitions the project to stopped/error with logs or recovery guidance.
- Git remote embeds credentials; redact before display and never persist the credential-bearing URL.
- Shadow disconnects or automatically shuts down during install/start; partial state remains recoverable and no keepalive bypass is attempted.

# Implementation Tasks

- [ ] Task 1: Define the native Windows runtime contract and state schema
  - File: `cli/windows/ShipGlows.DevServer.psm1`, `cli/windows/README.md`
  - Action: Define constants, supported project kinds, registry schema/version, canonical paths, status values, redaction rules and public function boundaries before lifecycle code.
  - User story link: Establishes a durable Windows-native foundation independent of Linux-only tools.
  - Depends on: None.
  - Validate with: PowerShell parser check plus fixture assertions for schema defaults and path resolution.
  - Notes: No generic plugin architecture in V1.

- [ ] Task 2: Implement safe project and process primitives
  - File: `cli/windows/ShipGlows.DevServer.psm1`
  - Action: Add path/URL/name validation, atomic JSON load/write, lock handling, redaction, port discovery, process identity capture, stale-state reconciliation and safe stop semantics.
  - User story link: Makes lifecycle operations reliable after Shadow shutdown and protects unrelated processes.
  - Depends on: Task 1.
  - Validate with: Fixtures for malformed paths/URLs, concurrent registry access, stale PID reuse, occupied/exhausted ports and idempotent stop.
  - Notes: Forbid `Invoke-Expression`; compare PID, creation time and command identity.

- [ ] Task 3: Implement supported project detection and dependency preparation
  - File: `cli/windows/ShipGlows.DevServer.psm1`
  - Action: Detect Astro from parsed `package.json`, Python/FastAPI from supported manifests/entrypoints and Flutter from parsed `pubspec.yaml` plus `web/`; resolve package tools and preparation commands without mutating package-manager choice.
  - User story link: Lets the operator use the three actual stacks without Flox.
  - Depends on: Tasks 1-2.
  - Validate with: Table-driven project fixtures covering valid, missing, conflicting and ambiguous manifests.
  - Notes: Parse JSON/YAML through safe parsers or bounded field readers; do not grep arbitrary command strings.

- [ ] Task 4: Implement process launch, health, logs and lifecycle
  - File: `cli/windows/ShipGlows.DevServer.psm1`
  - Action: Build argument arrays, prepare dependencies, start redirected non-interactive processes, launch Flutter in a visible terminal, run stability/HTTP probes, rotate logs, and implement start/stop/restart/stop-all/refresh.
  - User story link: Provides the core start, logs, restart and stop loop.
  - Depends on: Tasks 1-3.
  - Validate with: Windows integration tests for child exit, port bind, health probe, logs, repeated stop and stale registry recovery.
  - Notes: Never report running before evidence; retain Flutter interactivity.

- [ ] Task 5: Build the PowerShell DevServer menu and commands
  - File: `cli/windows/shipglows-devserver.ps1`, `cli/windows/ShipGlows.DevServer.psm1`
  - Action: Add dashboard, clone, register, start, stop, restart, logs, open, unregister, stop-all and refresh flows with recoverable cancel/back behavior.
  - User story link: Restores the familiar ShipGlows operator loop on native Windows.
  - Depends on: Tasks 1-4.
  - Validate with: Scripted non-interactive command smoke plus manual Windows Terminal keyboard/navigation checklist.
  - Notes: Prefer the bundled, checksum-verified Windows Gum binary for choices and inputs; keep labels in the operator language where existing ShipGlows localization permits and retain the plain PowerShell menu as a recovery fallback.

- [ ] Task 6: Add native Windows local/full bootstrap modes
  - File: `install-shipglows.ps1`, `cli/windows/install-devserver.ps1`
  - Action: Add `InstallMode local|full` with environment fallback, where default/local preserves the existing tunnel installation and full installs only the native DevServer. Download/extract only authorized Windows files, validate archive structure and hashes, check dependencies and install user-profile commands.
  - User story link: Makes setup possible on Shadow without WSL or admin-heavy Linux installation.
  - Depends on: Tasks 1-5.
  - Validate with: Parser checks, local/full mode fixtures, download-only fixture, archive traversal rejection, default/local regression and real Shadow full install using the public curl.exe command.
  - Notes: Dependency installation requiring UAC or network must remain explicit and recoverable.

- [ ] Task 7: Publish Windows full through the canonical ShipGlows endpoint and page
  - File: `tools/sync_shipglows_public_bootstrap.sh`, `/home/claude/shipglows_app/site/src/generated/shipglows-installer.ps1`, `/home/claude/shipglows_app/site/tests/install/shipglowsInstaller.test.ts`, `/home/claude/shipglows_app/site/tests/install/bootstrapParity.test.ts`
  - Action: Retarget bootstrap synchronization to the canonical ShipGlows site checkout, keep `/shipglows-script?format=powershell` as the raw endpoint, expose an available `windows-full` selector in EN/FR and publish the exact file-download command that asks for the mode; retain `-InstallMode full` for automation.
  - User story link: Gives the operator the same one-page public installation path used by Linux, Termux and Windows local.
  - Depends on: Task 6.
  - Validate with: Sync `--check`, byte comparison, ShipGlows installer/route unit tests, Astro build check, hosted endpoint body check and browser selector proof.
  - Notes: Do not pipe downloaded PowerShell into `iex`; download to a temporary file, then execute it explicitly.

- [ ] Task 8: Add automated Windows fixtures and regression coverage
  - File: `tests/windows/devserver-unit.ps1`, `tests/windows/devserver-integration.ps1`, `tests/windows/fixtures/`
  - Action: Cover detection, registry, paths, ports, process identity, command arguments, redaction, lifecycle and bootstrap compatibility without requiring Pester.
  - User story link: Prevents the native mode from becoming a fragile one-machine script.
  - Depends on: Tasks 1-7.
  - Validate with: Windows PowerShell 5.1 and PowerShell 7 runs; existing Linux CLI/bootstrap test suites.
  - Notes: Integration tests must clean only their own temporary workspace and processes.

- [ ] Task 9: Prove the three supported stacks on Shadow
  - File: `shipglows_data/workflow/test-checklists/native-windows-devserver-astro-python-flutter.md`
  - Action: Execute the public `curl.exe` Windows full install, clone/register, dependency preparation, start, browser open, logs, hot reload, restart, stop, stale-state recovery and unregister for Astro, FastAPI and Flutter Web.
  - User story link: Proves the actual migration target rather than only PowerShell syntax.
  - Depends on: Tasks 1-8.
  - Validate with: Completed checklist with versions, observable URLs/statuses and redacted failure evidence.
  - Notes: No public binding, real package/license/emulator/device or shutdown bypass test. Android proof remains mocked until target validation.

- [ ] Task 10: Align technical and operator documentation
  - File: `README.md`, `shipglows_data/technical/operator-guides/windows-devserver.md`, `shipglows_data/technical/runtime-cli.md`, `shipglows_data/technical/installer-and-user-scope.md`, `shipglows_data/technical/architecture.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/context-function-tree.md`, `shipglows_data/technical/code-docs-map.md`
  - Action: Document dual backends, exact capability matrix, install path, state locations, limitations, Shadow posture, proof commands and documentation update mapping.
  - User story link: Gives the operator an honest migration and recovery path.
  - Depends on: Tasks 1-9.
  - Validate with: Metadata lint, link/path checks, capability-claim comparison against completed tests and documentation map review.
  - Notes: Do not claim Windows parity beyond the three proven stacks.

# Acceptance Criteria

- [ ] AC01: Given a Shadow PC with WSL unavailable, when the operator installs the explicit DevServer surface, then `shipglows-dev` launches under native Windows PowerShell without Bash, WSL, Flox, PM2 or Caddy.
- [ ] AC01a: Given the public Windows installer endpoint, when the operator downloads it with `curl.exe`, runs `powershell.exe -NoProfile -ExecutionPolicy Bypass -File <installer>` and chooses full, then only the native DevServer is installed from the resolved public ShipGlows commit; no tunnel setup is invoked. `-InstallMode full` remains equivalent for automation.
- [ ] AC02: Given an Astro repo with one supported lockfile, when start is selected, then dependencies are installed with that package manager, a free port is assigned, the process survives the stability window and the localhost URL answers.
- [ ] AC03: Given a Python/FastAPI repo with `pyproject.toml` and a current `uv.lock`, when start is selected, then `uv sync --locked`/`uv run` owns `.venv`, the supported app target starts and the URL answers.
- [ ] AC04: Given a supported legacy `requirements.txt` project, when start is selected, then uv prepares an isolated `.venv`, the limitation is visible and the system does not claim lockfile reproducibility.
- [ ] AC05: Given a Flutter project with web support, when start is selected, then Flutter opens in an interactive terminal on the assigned localhost port and hot reload/restart remains available.
- [ ] AC06: Given multiple running supported projects, when the dashboard refreshes, then each has a distinct port and evidence-derived status without repeated full dependency installation.
- [ ] AC07: Given an occupied fixed port, when start is selected, then launch is blocked with the owning port reported and no partial running state is persisted.
- [ ] AC08: Given an automatically selected port is raced by another process before bind, when startup fails, then ShipGlows retries once on another free port or returns a recoverable error without false success.
- [ ] AC09: Given Shadow shut down and Windows reused a recorded PID, when refresh or stop runs, then ShipGlows rejects the stale identity and never stops the unrelated process.
- [ ] AC10: Given a child exits during startup, when the stability window ends, then status is `error`, the URL is not advertised and the relevant log path is shown.
- [ ] AC11: Given a malformed/truncated registry and an existing last-known-valid snapshot, when DevServer starts, then it preserves/reloads the valid state or fails visibly without overwriting it.
- [ ] AC12: Given a path with spaces and Unicode, when a project is registered and started, then executable and arguments remain correctly separated and the project lifecycle succeeds.
- [ ] AC13: Given a Git URL containing credentials or a project environment containing secrets, when diagnostics/log summaries are displayed, then credentials and secret values are absent.
- [ ] AC14: Given the operator invokes stop twice, when the project is already stopped, then the second call is idempotent and does not target another process.
- [ ] AC15: Given the default `install-shipglows.ps1` invocation in an interactive Windows console, when no mode is supplied, then the installer asks for tunnel local or recommended DevServer full; non-interactive no-mode calls retain the local fallback.
- [ ] AC15a: Given the ShipGlows EN or FR runtime page, when Windows and full are selected, then the option is available and copies the public `curl.exe` download plus PowerShell execution command that asks for the mode; Windows local remains available separately and explicit `-InstallMode full` remains documented for automation.
- [x] AC15b: Given a public deployment, when `/shipglows-script?format=powershell` is fetched, then its body is byte-identical to canonical `install-shipglows.ps1` and contains the tested local/full mode contract.
- [ ] AC16: Given an unsupported framework or ambiguous Python entrypoint, when start is selected, then no generic command executes and the operator receives an actionable supported-contract message.
- [ ] AC17: Given the first implementation is complete, when existing Linux CLI/bootstrap tests run, then no Linux server lifecycle regression is introduced.
- [ ] AC18: Given documentation is prepared for release, when capability claims are checked against the Shadow checklist, then only Astro, supported Python/FastAPI conventions and Flutter Web are advertised.
- [ ] AC19: Given Shadow disconnects or shuts down, when ShipGlows is relaunched, then it reconciles ephemeral process state and never attempts persistence, public hosting or an automatic-shutdown bypass.
- [ ] AC20: Given a Windows full installation on x86-64, when Gum is absent, then the installer downloads the pinned official Windows release, validates its SHA-256 checksum, installs it inside the ShipGlows runtime without requiring PATH or WinGet, and the DevServer uses its interactive chooser; when installation fails, the PowerShell fallback remains usable.
- [ ] AC21: Given Git or GitHub CLI is absent during Windows full installation, when WinGet is available, then both are installed automatically; when the operator selects GitHub browsing, official browser authentication is offered if needed, up to 200 accessible private/public repositories are searchable through Gum, and the selected repository is cloned without ShipGlows reading or storing credentials.
- [ ] AC22: Given PowerShell profile execution is blocked, when Windows full installation completes and `s` is unclaimed, then the current and new shells resolve `s.cmd`, which launches the DevServer through `powershell.exe -NoProfile -ExecutionPolicy Bypass`; `shipglows-dev` remains available if `s` is already claimed.
- [ ] AC23: Given the public Windows PowerShell bootstrap is launched without `-InstallMode` from an interactive console, when the installer starts, then it requires an explicit `1`, `2`, or `0` before downloading files; empty input repeats the prompt and never starts an installation, while explicit mode arguments and the non-interactive local fallback remain deterministic.
- [ ] AC24: Given Windows full on a fresh or existing x64 host, when Android preparation runs, then validated external Flutter/Dart, JDK 17 and Android SDK locations are reused without replacing their environment ownership; missing tools use hardened managed installs, Android 36 coordinates and explicit official terms/licenses. Only managed installs update JAVA_HOME/ANDROID_HOME/ANDROID_SDK_ROOT/PATH. Refusal, non-x64 and non-interactive runs remain pending, and `%USERPROFILE%\.shipglows\environment.md` records Flutter/Dart presence, Android toolchain/license/device readiness and the exact next action. Mock proof passes; real host proof remains required.
- [ ] AC25: Given an interactive Windows x64 host, when Android preparation runs, then ShipGlows asks the sole emulator question even if acceleration is uncertain, discloses that uncertainty before the choice, and never substitutes a phone decision. A complete existing emulator, exact Android 36 image, and named AVD skip the question and emulator provisioning downloads; a partial state offers repair. Acceptance installs missing components with visible progress and creates or reuses the named AVD without overwriting its state, then records package, AVD and acceleration readiness separately; the software-only command is diagnostic and never establishes device readiness without `adb`/Flutter proof. Refusal and non-interactive runs install nothing. Mock proof and real Shadow install/failure/idempotent-rerun proof pass; accelerated-device proof remains required on a capable host.
- [ ] AC26: Given installed agents, when MCP preparation runs, then OpenCode v2 uses `mcp.servers`, Kilo prefers `kilo` with explicit `kilocode` compatibility, `.jsonc` is resolved before `.json`, Playwright requires an exact resolved version plus a runnable Chromium executable, and an existing non-converged config remains byte-identical and pending. Mock/static proof passes; real agent proof remains required.
- [ ] AC27: Given the PATH-backed Windows `s.cmd` launcher, when the operator invokes a supported Linux-style menu path such as `s d`, `s e`, or `s m n`, then the native PowerShell frontend resolves only Windows-equivalent actions without loading `$PROFILE`; `s m n` selects a registered project and opens a child PowerShell in its directory, unsupported Flox/PM2/Caddy paths fail with `s h` guidance, and existing long-form actions retain their behavior.
- [ ] AC28: Given installed coding agents and unclaimed short names, when wrappers are prepared, then `c`, `co`, `cor`, `oc` and `kc` forward safely; `kc` targets official `kilo` first and only falls back to detected `kilocode` compatibility. Existing command owners remain preserved. Static proof passes; target proof remains required.
- [x] AC29: Given zero, one, or many supported Windows surfaces, including homonymous leaf folders, when dashboard or a project action opens, then one bounded linear scan feeds a five-minute memory/persistent catalogue; labels are unique workspace-relative launch paths, selection resolves the exact canonical launch identity, the live registry wins status conflicts, and refresh or clone/register/unregister safely rebuilds or invalidates non-authoritative cache state.
- [ ] AC30: Given unregister is selected, when the operator confirms, then only the registry entry is removed and the repository remains on disk.
- [x] AC31: Given an interactive Windows x64 full install, when Android Studio or the Flutter Windows compiler is missing, then ShipGlows makes one grouped proposal that names only the missing outcomes. Acceptance installs current Android Studio through the official WinGet package and Visual Studio Community 2022 with `Microsoft.VisualStudio.Workload.NativeDesktop` plus recommended components, preserves the existing Flutter/JDK/Android SDK/AVD, shows progress and forbids automatic restart. A valid complete host skips the question; a partial Visual Studio host receives only the missing workload; refusal and non-interactive execution install nothing and remain pending. `%USERPROFILE%\.shipglows\environment.md` records Android Studio, Flutter Windows C++ and Firebase Device Streaming readiness separately. ShipGlows never authenticates Firebase, chooses a project, changes billing or reserves a remote device. Fixtures, parser/static proof and real Shadow installation pass; first-launch Firebase UI confirmation remains operator-owned.
- [x] AC32: Given a ShipGlows context, development, or engineering request that depends on Flutter, Android, Windows desktop, or Firebase Device Streaming, when a user-facing or expert skill chooses a route, then it loads the shared runtime-awareness contract and reports the recorded toolchain state plus exact next action. It keeps SDK, license, AVD, acceleration, device, IDE, hosted-device configuration, discovery, and callability distinct; an unaccelerated AVD without a ready device is never called runnable; Firebase authentication, project, billing, and reservation remain user-owned. Source skills, the bundled public plugin, and every produced Windows environment field pass one focused scenario contract.

# Test Strategy

1. Run PowerShell parser validation for every `.ps1` and `.psm1` on Windows PowerShell 5.1 and PowerShell 7.
2. Run table-driven fixture tests for validation, stack detection, command arguments, ports, registry atomicity, redaction and stale PID identity.
3. Run process integration tests in a unique temporary workspace with explicit cleanup and verify no foreign process is stopped.
4. Start minimal Astro and FastAPI fixtures, wait for bounded HTTP health, inspect logs, restart and stop.
5. Launch Flutter Web in a visible terminal, prove URL readiness and manually trigger hot reload/restart.
6. Exercise bootstrap default/local/full surfaces, including malformed archive/traversal rejection and interrupted install recovery.
7. Synchronize canonical bootstrap artifacts into the ShipGlows site, run installer/route tests and prove the EN/FR Windows full selector.
8. Fetch the hosted PowerShell endpoint, compare its body with the canonical script and run the downloaded full installer on Shadow.
9. Run current Bash syntax and focused Linux CLI/bootstrap suites to prove additive platform separation.
10. Complete the real Shadow checklist, including shutdown/stale registry recovery on a later session.
11. Run metadata lint and documentation map checks before readiness/ship claims.
12. Exercise the Windows catalogue fixtures for zero/one/many and homonymous surfaces, schema/workspace/scanner/TTL boundaries, corruption, moved paths, identity normalization, concurrent index writers, and five-run cold/warm performance medians.

# Risks

- High: Windows process trees and PID reuse differ from POSIX process groups; an unsafe stop implementation could terminate unrelated work. Mitigation: compound identity checks, bounded ownership and adversarial fixtures.
- High: Building commands as strings creates injection and quoting vulnerabilities. Mitigation: executable resolution plus argument arrays; forbid `Invoke-Expression`.
- High: The public bootstrap downloads executable PowerShell. Mitigation: retain exact archive-entry validation, commit resolution/hash evidence and opt-in installation.
- Medium: Astro/Python conventions vary across repos. Mitigation: support only explicit V1 conventions, fail closed on ambiguity and expand only from proven project fixtures.
- Medium: Flutter interactive lifecycle does not map cleanly to redirected background processes. Mitigation: visible terminal ownership and registry reconciliation rather than simulated stdin control.
- Medium: Shadow can shut down automatically, interrupting installs and processes. Mitigation: atomic state, temporary clone directories, recoverable dependency operations and no persistence promise.
- Medium: uv or Flutter behavior may change. Mitigation: freshness gate, version capture in test evidence and official-doc recheck during readiness.
- Medium: Windows PowerShell 5.1 and PowerShell 7 differ in JSON/process behavior. Mitigation: target the common subset and prove both runtimes.
- Low: Removing Flox weakens cross-machine runtime isolation. Mitigation: lockfiles, `.venv`, declared versions, preflight mismatch errors and honest documentation.
- Compliance: localhost development might still be interpreted differently from server hosting by Shadow. Mitigation: no public bind, no persistent hosting, no shutdown bypass, and operator confirmation with Shadow support if usage terms remain unclear.

# OWASP Security Gate

- Top 10:2025 categories considered: A02 Security Misconfiguration (localhost-only binding and no persistence bypass), A03 Software Supply Chain Failures (public bootstrap, resolved commit, generated artifact drift and dependency lockfiles), A05 Injection (PowerShell argument construction, repo paths, Git URLs and manifest-derived commands), A06 Insecure Design (mode separation, stale-process handling and no arbitrary command schema), A08 Software or Data Integrity Failures (archive-entry validation, commit resolution, hashes and atomic registry), A09 Security Logging and Alerting Failures (redacted actionable diagnostics), and A10 Mishandling of Exceptional Conditions (cancel, timeout, partial install, child exit, stale state and recovery).
- Trust/data boundaries: ShipGlows public raw endpoint -> local temporary PowerShell file -> explicit PowerShell process; Git archive/repository metadata -> detection logic; project manifests and lockfiles -> bounded command builders; managed child process -> local registry/logs; local user is the only intended initiator. No remote tenant or authenticated API boundary exists in the DevServer runtime.
- Selected ASVS v5.0.0 requirements: `v5.0.0-1.2.5` for parameterized/context-safe OS command calls and `v5.0.0-5.3.2` for strict validation/sanitization of file paths. Public artifact provenance and dependency supply-chain controls are covered by the ShipGlows commit/archive/hash contract and are not claimed as complete ASVS coverage.
- Proof: adversarial tests reject `Invoke-Expression`, shell-string interpolation, archive traversal, unsafe paths, credential-bearing URLs, malformed manifests, stale PID identities and secret-bearing logs; bootstrap tests compare canonical/generated bodies and validate resolved commit/archive entries.
- Residual gap: the V1 contract does not provide Authenticode signing, endpoint attestation beyond HTTPS plus resolved commit/archive/hash checks, or a Windows Defender/SmartScreen acceptance proof. The release proof must state this limitation and must not claim a signed installer or full supply-chain certification.

# Execution Notes

- Read first: `install-shipglows.ps1`, `local/install_local.ps1`, `cli/lib.sh` around project detection/lifecycle, `shipglows_data/technical/runtime-cli.md`, and `shipglows_data/technical/installer-and-user-scope.md`.
- Implement platform separation first. Do not source, translate or invoke the Bash runtime from PowerShell.
- Use one PowerShell module for reusable logic and one thin entrypoint/menu script. Split further only after tests reveal a real ownership boundary.
- Keep the V1 registry schema versioned and internal. Do not make project manifests depend on Windows-only state.
- Reuse the existing `.shipglows.env` parser contract only for allowlisted non-executable keys; preserve unknown-key failure.
- Prefer `127.0.0.1` bindings on Shadow. `0.0.0.0`, firewall rules, port forwarding and public exposure are outside scope.
- Use `uv run --locked` when `uv.lock` exists. Do not create/update a lockfile silently during ordinary start.
- For Astro, honor the repo lockfile and existing dev script; inject the port through documented CLI arguments/environment without rewriting Astro config in V1.
- For Flutter, use a visible terminal process and reconcile state after manual closure. Do not emulate `tmux` attach semantics.
- Keep install dependency actions explicit. Detection and guidance may be automatic; UAC/network/package installation requires visible consent in the installer flow.
- Implementation stop conditions: a required process identity cannot be proven safely; PowerShell 5.1 compatibility would require string evaluation; Shadow proof needs public hosting; a stack requires unsupported custom command execution; official docs conflict with the planned runtime behavior.
- Public bootstrap command contract: download, inspectable temporary file, explicit PowerShell execution. The documented interactive form is equivalent to `$installer = Join-Path $env:TEMP 'shipglows-install.ps1'; curl.exe -fsSL 'https://shipglows.com/shipglows-script?format=powershell' -o $installer; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer`; `-InstallMode full` remains the deterministic automation suffix.
- Security implementation gate: preserve `v5.0.0-1.2.5` and `v5.0.0-5.3.2` evidence in tests/review; do not weaken to a string-evaluated command path or broad recursive deletion to simplify Windows behavior.
- Documentation Freshness Gate verdict: `fresh-docs checked`; re-evaluate local installed versions before implementation.

# Open Questions

None. The operator has fixed the platform constraint (native Windows on Shadow), supported stacks (Astro, Python, Flutter), and desired outcome (local workspace plus DevServer lifecycle and Flutter Android preparation). Package-level choices, file structure and process mechanics are implementation-owned. Any later request for public hosting, custom project commands, persistent Android device lifecycle or framework expansion requires a separate scope decision.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-07 21:55:18 UTC | 100-sg-spec | GPT-5 Codex | Created the full native Windows DevServer contract for Astro, Python/FastAPI and Flutter Web from operator constraints, current Linux/PowerShell code evidence and official runtime documentation. | Draft created; adversarial self-review integrated; readiness and Windows implementation proof pending. | Review readiness for `native-windows-devserver-astro-python-flutter`. |
| 2026-08-07 22:18:16 UTC | 100-sg-spec | GPT-5 Codex | Extended the contract so native Windows full is installed through the canonical CommandGlows curl.exe/PowerShell endpoint and exposed by the existing EN/FR installer selector. | Draft updated with local/full semantics, cross-repo synchronization, public route/page tasks and hosted/Shadow acceptance proof. | Re-run readiness review against the expanded cross-repo scope. |
| 2026-08-08 00:25:00 UTC | 101-sg-ready | GPT-5 Codex | Completed adversarial readiness review and added the required OWASP Security Gate for public PowerShell bootstrap, process command construction, path validation and artifact integrity. | Ready; implementation, Windows host proof, hosted endpoint proof and closure remain pending. | Start the bounded implementation wave. |
| 2026-08-08 04:18:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the native PowerShell DevServer module/entrypoint, full Windows bootstrap extraction, launcher/profile installer, public EN/FR windows-full commands, CommandGlows generated PowerShell parity, and static/test contracts. | ShipGlows static contract passed; CommandGlows targeted tests 96/96 and Astro check 0 errors/1 hint; native PowerShell parser and Shadow runtime proof remain pending. | Run the Windows Parser/Smoke matrix and hosted endpoint proof. |
| 2026-08-08 04:25:00 UTC | 102-sg-start | GPT-5 Codex | Corrected the Windows mode boundary after operator review: `full` now installs only the local DevServer; `local` remains the optional SSH tunnel path. Updated bootstrap branching, public notes, README and acceptance criteria. | Static revalidation pending; no tunnel is invoked by the full branch. | Re-run public tests and Windows Parser/Smoke matrix. |
| 2026-08-08 13:10:00 UTC | 005-sg-ship | GPT-5 Codex | Shipped the bounded ShipGlows bootstrap semantics and the matching CommandGlows public PowerShell artifact/page commit. | Both `main` branches pushed; ShipGlows static contract and CommandGlows 96 targeted tests passed, Astro check has 0 errors and 1 existing hint; Vercel propagation and Shadow runtime proof remain pending. | Confirm the hosted endpoint, then run the Shadow full-install smoke. |
| 2026-08-08 13:10:00 UTC | 004-sg-deploy | GPT-5 Codex | Started release proof for the public Windows full bootstrap after both scoped commits reached their `main` branches. | Partial: production endpoint was still serving the prior artifact on first poll; no deployed claim yet. | Poll the matching Vercel deployment and verify the live artifact. |
| 2026-08-08 13:12:00 UTC | 004-sg-deploy | GPT-5 Codex | Verified the CommandGlows production endpoint and install page after Vercel propagation. | Deployed: cache-busted public PowerShell artifact matches the generated file byte-for-byte; production page exposes Windows full and its DevServer command. Shadow PowerShell runtime smoke remains pending. | Run the full install on Shadow and report its output. |
| 2026-08-08 13:27:00 UTC | 106-sg-fix | GPT-5 Codex | Diagnosed the first Shadow full-install failure under PowerShell StrictMode: the `windows` directory pipeline was unwrapped after `@(...)`, so a single result had no `.Count` property. Wrapped the complete pipeline as an array and clarified full-mode messages. | Static regression contract and CommandGlows targeted tests 96/96 pass; Shadow retest and republish remain pending. | Ship both bounded fixes, verify the live artifact, then rerun the Shadow install. |
| 2026-08-08 13:29:00 UTC | 004-sg-deploy | GPT-5 Codex | Published and verified the PowerShell StrictMode array fix through the production CommandGlows endpoint. | Deployed: cache-busted endpoint contains the wrapped pipeline and matches the generated PowerShell artifact byte-for-byte. | Rerun the exact full-install command on Shadow. |
| 2026-08-08 13:34:00 UTC | 106-sg-fix | GPT-5 Codex | Diagnosed the Shadow parser failure in `Get-SgCommandSignature`: PowerShell interpreted `$Kind:` and `$Port:` as scoped-variable syntax. Delimited both interpolations with `${...}` and added a static regression scan for interpolated variables followed by colons. | Static Windows contract, metadata lint and diff check pass; native Shadow parser retest remains pending. | Push the ShipGlows commit, then rerun the full installer against the new resolved commit. |
| 2026-08-08 14:05:00 UTC | 106-sg-fix | GPT-5 Codex | Diagnosed the first launcher runtime failure on Windows PowerShell 5.1: `New-Item` does not expose `-LiteralPath` there. Switched directory creation to `-Path` and disabled the non-blocking unapproved-verb import warning. | Static contract now rejects `New-Item -LiteralPath`; Shadow runtime retest and push remain pending. | Push the module fix, rerun full installation, then launch the DevServer directly. |
| 2026-08-08 14:20:00 UTC | 106-sg-fix | GPT-5 Codex | Diagnosed the menu error-handler failure after the dashboard rendered: the launcher called module-owned `Write-SgInfo`, `Write-SgWarn`, and `Write-SgError`, but those functions were not exported. Exported all three and added a focused module-contract assertion. | Static Windows contract passes; Shadow menu retest remains pending. | Push the module, refresh the full installation, then exercise menu choices. |
| 2026-08-08 14:49:00 UTC | 001-sg-build | GPT-5 Codex | Added an autonomous native Windows Gum installation and Gum-backed action/project/input selectors. The official x86-64 release is pinned, SHA-256 verified and installed beside the launcher without WinGet or PATH changes; the PowerShell frontend remains the recovery path. | Static Windows contract and archive checksum proof pass; Windows PowerShell 5.1 runtime proof remains pending on Shadow. | Publish the bounded change, reinstall full on Shadow, and verify Gum rendering plus fallback behavior. |
| 2026-08-08 15:42:00 UTC | 103-sg-verify | GPT-5 Codex | Recorded operator-supplied Shadow PowerShell 5.1 evidence for commit `e5d11c723cee42f97471e923bfae44a72a35b911`: full mode downloaded the native files, installed Gum 0.17.0 automatically, and reported Gum available without a restart. | Automatic Gum installation on the target Shadow host is proven; interactive chooser rendering and supported-stack lifecycle proof remain pending. | Launch the direct bypass entrypoint and verify the Gum chooser in WezTerm. |
| 2026-08-08 17:37:42 UTC | 001-sg-build | GPT-5 Codex | Added Windows full installation of Git and GitHub CLI through WinGet plus a Gum-backed GitHub repository browser. Authentication uses the official `gh` browser flow and clone uses `gh repo clone`; ShipGlows does not inspect tokens. | Static contract and documentation validation pending; Shadow installation/auth/private clone proof remains pending. | Validate, publish, reinstall on Shadow, then authenticate and clone one private repository. |
| 2026-08-08 17:52:00 UTC | 106-sg-fix | GPT-5 Codex | Recorded successful Shadow installation of Git and GitHub CLI and corrected the misleading silent wait: WinGet output is now visible and the installer explicitly warns that first-time package installation can take several minutes without closing the window. | Target installation of Gum, Git and gh is proven; the clearer progress UX and private repository browser still need Shadow runtime confirmation. | Publish the UX correction, then launch the menu and browse one private repository. |
| 2026-08-08 18:15:00 UTC | 001-sg-build | GPT-5 Codex | Replaced the profile-dependent Windows launcher with PATH-backed `.cmd` commands. `shipglows-dev` is always installed and `s` is installed when unclaimed; both invoke the launcher with the required no-profile execution-policy bypass. | Static contract pending; target proof requires a full refresh and direct `s` invocation on Shadow. | Validate, publish, rerun full installation, then execute `s`. |
| 2026-08-08 18:35:00 UTC | 001-sg-build | GPT-5 Codex | Added a guided Windows install-mode choice when no explicit mode is supplied: SSH tunnels or recommended local DevServer. Explicit `-InstallMode` remains the non-interactive/automation override and noninteractive no-mode calls retain local fallback. | Static, public bootstrap parity and deployment validation pending; Shadow interactive prompt proof remains pending. | Synchronize the public artifact, publish the site command, then run the simple Windows command on Shadow. |
| 2026-08-08 18:55:30 UTC | 001-sg-build | GPT-5 Codex | Extended Windows full provisioning with Node LTS/npm, pnpm through Corepack plus npm fallback, and uv; added an explicit optional Flutter Web stable-SDK download that enables web support in user scope. | Static contract, public documentation and Shadow installation proof pending. | Validate, publish, rerun full installation, then confirm the optional Flutter choice. |
| 2026-08-08 19:13:00 UTC | 106-sg-fix | GPT-5 Codex | Fixed the interactive PowerShell bootstrap parameter failure: an empty default was rejected by `ValidateSet` before the mode prompt. The parameter is now omitted when absent, with a post-resolution allowlist for environment values. | Static contract, generated PowerShell parity and CommandGlows installer tests 96/96 pass; Shadow interactive retest remains pending. | Publish both scoped fixes, then rerun the public install command on Shadow. |
| 2026-08-09 10:47:57 UTC | 106-sg-fix | GPT-5 Codex | Removed ShipGlows's obsolete managed PowerShell profile function during full installation. PATH-backed `s.cmd` and `shipglows-dev.cmd` already launch with `-NoProfile`, so the installer now removes only its old block instead of recreating it. | Static contract pending; Shadow PowerShell profile retest remains pending. | Publish, rerun the full installer, then open a normal PowerShell session. |
| 2026-08-09 10:49:54 UTC | 106-sg-fix | GPT-5 Codex | Corrected the PowerShell 5.1 parameter model after target evidence showed that `ValidateSet` still rejected an omitted string parameter. The mode now uses only the explicit post-resolution allowlist, which accepts omission and rejects unsupported values. | Static contract and generated public artifact parity pass; Shadow interactive retest remains pending. | Publish both artifacts, then rerun the public install command on Shadow. |
| 2026-08-09 11:12:37 UTC | 001-sg-build | GPT-5 Codex | Added individual opt-in prompts for Codex, Claude Code, OpenCode and KiloCode to Windows full. The installer skips agents on Enter or non-interactive execution, delegates first-run authentication to the selected CLI, and uses npm only as a recovery fallback when pnpm cannot expose the global command. | Static contract and Windows parser proof pending; Shadow prompt/install proof remains pending. | Validate, publish, then rerun full installation on Shadow and choose the wanted agents. |
| 2026-08-09 11:25:22 UTC | 003-sg-bug | GPT-5 Codex | Reproduced the unattended mode selection from operator evidence: empty input was explicitly mapped to full. Removed that default from the canonical and generated bootstraps; empty input now repeats the prompt until 1, 2, or 0 is entered. | Regression test failed before the repair and passes after it; ShipGlows `aa9d9c8` and CommandGlows `f8494e2` are pushed, and the production bootstrap matches the canonical file byte-for-byte. Shadow retest remains pending. | Retest an empty answer on Shadow, then enter the intended mode explicitly. |
| 2026-08-09 11:32:55 UTC | 003-sg-bug | GPT-5 Codex | Diagnosed the false pnpm-ready report from Shadow evidence: only the Corepack shim was detected while pnpm v11's configured global bin directory was absent from PATH. Added global-bin discovery/PATH repair, executable version checks, pnpm-agent path discovery, and scoped npm install-script permission for selected agent fallbacks. | Regression contract and metadata validation pending; Windows/Shadow pnpm and agent command retest remain pending. | Validate, publish, rerun full once, then verify pnpm and the selected agents in a fresh PowerShell session. |
| 2026-08-09 12:05:50 UTC | 003-sg-bug | GPT-5 Codex | Diagnosed the remaining Shadow failure: pnpm configuration was queried before its bin path became active, and ordinary PowerShell command resolution selected blocked npm-generated `.ps1` shims ahead of working `.cmd` launchers. Reordered pnpm PATH preparation and added priority managed `.cmd` wrappers for npm-family and agent commands. | Regression contract pending; Shadow retest remains required because the execution-policy behavior is host-specific. | Validate, publish, rerun full once, then invoke the ordinary command names without `.cmd` suffixes. |
| 2026-08-09 12:16:34 UTC | 003-sg-bug | GPT-5 Codex | Accepted real Shadow target proof for the pnpm global-bin repair and PowerShell-safe wrappers: the full installer reports every dependency ready, then ordinary `pnpm`, `codex`, and `claude` commands run successfully without changing the host execution policy. | AC24 and AC25 are proven. AC26 remains partially open until ordinary `opencode` and `kilocode` command names are exercised; access-denied warnings for protected npm/npx PowerShell shims were non-fatal because managed application wrappers were installed. | Run `opencode --version` and `kilocode --version`, then continue the native DevServer checklist with `s`. |
| 2026-08-09 12:19:18 UTC | 003-sg-bug | GPT-5 Codex | Accepted the final Shadow target proof for ordinary agent command resolution: `opencode --version` returned `1.18.15` and `kilocode --version` returned `7.4.20`, completing the previously proven pnpm, Codex and Claude command set. | AC26 is proven on the execution-policy-restricted Shadow host. Version commands were evidence-only checks and are not activation or runtime prerequisites. | Continue the broader native DevServer checklist with `s`; no further agent-command repair is required. |
| 2026-08-09 12:34:07 UTC | 001-sg-build | GPT-5 Codex | Added a profile-independent Windows shortcut resolver for the native equivalents of the Linux menu paths, including interactive dashboard/start/restart/stop/logs actions and `s m n` project navigation through a child PowerShell. | Implementation and documentation updated; focused static contract and real Shadow shortcut proof remain pending. | Run focused validation, publish the bounded files, refresh the Shadow installation, then exercise `s h` and `s m n`. |
| 2026-08-09 12:35:37 UTC | 005-sg-ship | GPT-5 Codex | Prepared the bounded Windows shortcut resolver, focused regression contract and aligned operator/technical documentation for iterative shipping. | Windows static contract, metadata lint and diff check pass; bug risk is not assessed beyond the unique chantier, and native PowerShell/Shadow proof remains pending. | Push the scoped commit, reinstall full from that commit on Shadow, then run `s h` and `s m n`. |
| 2026-08-09 12:48:27 UTC | 001-sg-build | GPT-5 Codex | Restored the established AI-agent convenience mappings on native Windows with collision-safe `.cmd` wrappers: `c`, `co`, `cor`, `oc`, and `kc`. | Implementation and docs updated; focused contract and native Shadow proof remain pending. | Validate, publish, reinstall full on Shadow, then invoke each short command with a bounded version/help argument. |
| 2026-08-09 12:49:24 UTC | 005-sg-ship | GPT-5 Codex | Prepared the bounded agent-shortcut wrappers, collision guard, regression assertions and aligned Windows documentation for iterative shipping. | Windows static contract, metadata lint and diff check pass; native PowerShell/Shadow command proof remains pending. | Push the scoped commit, reinstall full from that commit on Shadow, then verify `c`, `co`, `cor`, `oc`, and `kc`. |
| 2026-08-09 12:52:54 UTC | 300-sg-docs | GPT-5 Codex | Consolidated the native Windows story across architecture, runtime, installer ownership, context/function navigation, code-to-doc routing, README, and the active chantier. | Documentation now distinguishes Linux server and Windows local backends, records full-mode tools and agent choices, and explains profile-independent wrappers and shortcuts. Validation pending; AC27/AC28 remain target-proof gaps rather than documented-as-verified behavior. | Run governance, metadata, link/contract and public-claim coherence checks, then ship the bounded documentation update. |
| 2026-08-09 12:55:18 UTC | 005-sg-ship | GPT-5 Codex | Prepared the bounded Windows documentation consolidation for iterative shipping after internal and public owner alignment. | Governance topology, metadata lint for eight artifacts, Windows static contract, focused code-to-claim scans, AGENTS compatibility and diff check pass. Native Shadow proof for AC27/AC28 remains outside this docs-only release. | Push the scoped documentation commit; continue target shortcut verification separately. |
| 2026-08-09 15:40:00 UTC | sg-content | GPT-5 Codex + delegated agents | Aligned the public CommandGlows EN/FR installer copy with the native Windows full runtime, added a secondary Windows DevServer path to the ShipGlows Codex install pages, and declared the external bootstrap pages in editorial governance. | Public copy now distinguishes plugin and runtime installation, documents optional agents and profile-independent commands, and scopes Ubuntu root requirements away from Windows. AC27/AC28 remain pending real Shadow proof. | Validate both Astro sites, targeted installer tests, metadata, links, and canonical/generated PowerShell parity before release. |
| 2026-08-12 09:09:57 UTC | 602-sg-platform-parity | GPT-5 Codex | Closed a bounded Windows lifecycle parity tranche: Flox-root discovery with native launch-target adaptation, persistent/configured ports, manifest variables, auto-discovered dashboard, safe unregister, process signatures across npm/pnpm/uv/Flutter, and bounded log rotation. | PowerShell 5.1 parsing and the Windows static contract pass; `gocharbon` remains running on its persistent port 3002; reversible unregister preserved `communityglows` sources. FastAPI and Flutter runtime smoke proof remain pending. | Continue native fixture and Shadow proof for FastAPI, Flutter, stale PID recovery and log rotation boundaries. |
| 2026-08-12 09:25:00 UTC | 103-sg-verify | GPT-5 Codex | Recorded native FastAPI `requirements.txt` proof: `uv` created then reused `.venv`, FastAPI returned HTTP 200 on `127.0.0.1:32111`, and `stop` released the port and reset the tracked PID to `0`; stale-PID recovery was also exercised without terminating an unverified process. | FastAPI lifecycle and stale-PID safety are proven. Flutter runtime smoke and log-rotation boundary proof remain pending. | Continue Flutter Web and log-rotation boundary proof. |
| 2026-08-12 09:46:00 UTC | 602-sg-platform-parity | GPT-5 Codex | Completed the Windows command-navigation parity correction: every interactive project selector now offers `0 Back to menu`; the root menu names `0 Quit ShipGlows`, and Escape no longer terminates the interactive menu. | PowerShell parser and Windows static contract pass. Remaining gaps are lifecycle proof for Flutter Web and log-rotation boundaries, plus deliberate Windows adaptations for Linux-only Flox runtime, PM2 and Caddy flows. | Continue the remaining runtime proof. |
| 2026-08-12 10:12:00 UTC | 602-sg-platform-parity | GPT-5 Codex | Audited the Linux menu surface against the native Windows DevServer. | Direct lifecycle parity remains incomplete for environment rename, start-all and restart-all. Linux server-administration, PM2/Caddy, tunnel, tmux, Flutter hot-reload, session/identity, MCP/Turso/Blacksmith, system maintenance and Rust/Go/Dart support are not present in the Windows scope. | Decide which remaining portable lifecycle commands should be implemented next. |
| 2026-08-15 19:19:35 UTC | 900-shipglows-core | GPT-5 Codex | Replaced repeated Windows project discovery with a shared identity-based catalogue, five-minute atomic cache, action-specific picker projections, and safe invalidation/revalidation. | Regression-first catalogue suite and full Windows contract pass; final workspace benchmark medians are 902.05 ms cold and 31.96 ms warm. Runtime installation and live user registry were not modified. | Integrate through the parent chantier without commit or push. |
| 2026-08-16 01:04:46 UTC | 103-sg-verify mode=excellence | GPT-5 Codex | Reverified the published Shadow emulator correction, then identified and bounded the remaining rerun-friction and durable-trace gaps. Added complete/partial emulator provisioning state so a complete rerun skips the question and a partial state offers repair. | Regression-first emulator-state proof and the full Windows contract pass; real main/runtime rerun proof remains pending before publication. | Validate metadata and runtime behavior, publish the bounded correction, then reinstall from main without an emulator prompt or provisioning download. |
| 2026-08-16 01:12:44 UTC | 103-sg-verify mode=excellence | GPT-5 Codex | Reinstalled the full Windows runtime from the published validation branch on the real Shadow host with its existing emulator, exact image, and AVD. | The installer reported the complete existing state, skipped the emulator question and provisioning download, retained `toolchain=True`, `licenses=True`, `device=False`, and completed successfully. | Publish the proven commit to main, reinstall from main, and verify source/runtime parity. |
| 2026-08-16 01:17:06 UTC | 103-sg-verify mode=excellence | GPT-5 Codex | Reinstalled the full Windows runtime from published `main` after the fast-forward. | Main resolved to `0d9c549`; the installer again skipped the complete emulator state without prompting or provisioning, Android readiness remained truthful, and the full install completed successfully. | Verify source/runtime parity and remove the temporary validation branch. |
| 2026-08-16 07:04:11 UTC | sg-development | GPT-5 Codex | Added a grouped Windows IDE proposal, installed Android Studio and Visual Studio Community 2022 with native desktop C++, then reinstalled the published runtime from `main`. | Fixtures, PowerShell 5.1 parsing, the full Windows contract, metadata and diff checks pass. Real `flutter doctor -v` reports no issues; the published rerun skips both complete IDEs and records Firebase Device Streaming as user-owned pending state. | Confirm source/runtime parity; optionally perform the operator-confirmed Android Studio first-launch and Firebase UI check without automating authentication. |
| 2026-08-16 07:23:11 UTC | 900-shipglows-core | GPT-5 Codex | Connected the Windows mobile/desktop environment fields to the shared runtime contract, context modes, development and engineering owners, expert engines, and bundled public plugin. | Six focused consumer scenarios, 76 relevant skill contracts, the full Windows suite, metadata, budget, packaging, execution-fidelity, diff, and changed-line secret checks pass. The isolated Windows runtime-sync fixture remains non-portable because CRLF reaches its Bash skill-name validator; no live skill links were changed. | Publish the dedicated branch for integration without touching the concurrent local `main`. |

# Current Chantier Flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| 100-sg-spec | complete | Full implementation contract saved with scope, exclusions, security invariants, ZOMBIES coverage and proof plan. |
| 101-sg-ready | complete | Spec is ready after structure, security, freshness, cross-repo and proof-contract review. |
| 102-sg-start | complete | Native runtime, full bootstrap, launcher, shared cached project catalogue, public commands, docs and static contracts are implemented locally. |
| 103-sg-verify | in_progress | PowerShell 5.1 parsing, isolated catalogue/cache fixtures, workspace performance, discovered dashboard, persistent Astro port, safe unregister, FastAPI lifecycle and stale-PID recovery are proven; installed-runtime catalogue proof, Flutter and log-rotation boundaries remain. |
| 104-sg-end | pending | Close only after real Shadow proof and documentation coherence. |
| 005-sg-ship | complete | ShipGlows and CommandGlows scoped commits are pushed to their respective `main` branches. |
