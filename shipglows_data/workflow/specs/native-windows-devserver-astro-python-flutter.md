---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: "ShipGlows"
created: "2026-08-07"
created_at: "2026-08-07 21:55:18 UTC"
updated: "2026-08-07"
updated_at: "2026-08-08 00:25:00 UTC"
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
  - "local/README_WINDOWS.md"
  - "shipglows_data/technical/runtime-cli.md"
  - "shipglows_data/technical/installer-and-user-scope.md"
  - "shipglows_data/technical/code-docs-map.md"
  - "tools/sync_shipglows_public_bootstrap.sh"
  - "/home/claude/commandglows/commandglows_site/src/generated/shipglows-installer.ps1"
  - "/home/claude/commandglows/commandglows_site/src/pages/shipglows-script.ts"
  - "/home/claude/commandglows/commandglows_site/src/data/scriptInstallPages.ts"
  - "/home/claude/commandglows/commandglows_site/tests/deployment/shipglowsInstaller.test.ts"
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
    artifact_version: "1.0.24"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/installer-and-user-scope.md"
    artifact_version: "1.1.0"
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

- Depuis Windows PowerShell 5.1 ou PowerShell 7, l'operateur peut lancer `shipglows-dev` sans Bash, WSL, Docker, Flox, PM2, Caddy, `sudo` ou virtualisation imbriquee.
- Le meme endpoint `https://www.commandglows.com/shipglows-script?format=powershell` sert l'installateur Windows local et full; `-InstallMode full` installe uniquement le DevServer natif, tandis que l'absence de mode preserve le comportement local historique.
- Le dashboard decouvre les projets enregistres, affiche `running`, `stopped`, `error` ou `unknown`, le type de projet, le port et l'URL locale.
- Un clone Git reussi est place par defaut sous `%USERPROFILE%\ShipGlows\workspace\<repo>` et n'est enregistre qu'apres validation du chemin et du depot.
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
- Commande installee `shipglows-dev`, avec alias court `sgdev` si aucun conflit n'existe.
- Workspace par defaut `%USERPROFILE%\ShipGlows\workspace`, configurable par une variable ShipGlows dediee.
- Registre local JSON atomique sous `%LOCALAPPDATA%\ShipGlows\DevServer\registry.json`.
- Detection et lifecycle Astro avec pnpm prioritaire quand `pnpm-lock.yaml` existe, npm quand `package-lock.json` existe, et aucun changement implicite de package manager.
- Detection et lifecycle Python/FastAPI avec `uv`, `pyproject.toml`, `uv.lock`, `.python-version` et `.venv`; compatibilite bornee `requirements.txt` via un chemin uv explicite.
- Detection et lifecycle Flutter Web avec `pubspec.yaml`, dependance `flutter`, dossier `web/`, SDK Flutter Windows et terminal interactif.
- Actions dashboard, clone, register existing project, start, stop, restart, logs, open, unregister, stop all et refresh.
- Allocation de ports dans la plage ShipGlows 3000-3100 avec `Get-NetTCPConnection` et fallback .NET borne.
- Registre de processus contenant au minimum projet, type, PID, process creation time, executable path, command signature, port, status, started_at, log paths et last_error sans secret.
- Fenetre de stabilite avant annonce `running` et probe HTTP bornee pour Astro/FastAPI/Flutter Web.
- Logs stdout/stderr bornes ou rotation simple pour les processus non interactifs.
- Extension opt-in du bootstrap PowerShell pour installer la surface DevServer sans changer le comportement tunnel par defaut.
- Contrat de modes PowerShell `local|full`: `local` installe la couche tunnel existante; `full` installe le DevServer Windows natif sans tunnel automatique.
- Installation Windows full depuis le meme endpoint public que Windows local, via `curl.exe` vers un fichier temporaire puis `powershell.exe -File ... -InstallMode full`; aucun pipe direct vers `Invoke-Expression`.
- Synchronisation byte-for-byte de `install-shipglows.ps1` vers l'artefact genere CommandGlows et verification anti-drift dans les deux repos.
- Activation de la variante `windows-full` EN/FR sur la page publique CommandGlows avec commande copiable, limites exactes et tests de route/contenu.
- Tests PowerShell sans dependance de test tierce obligatoire, fixtures Astro/Python/Flutter minimales et smoke reel sur Shadow.
- Documentation Windows, runtime, installateur, architecture, contexte et code-doc map.

# Scope Out

- WSL, Hyper-V, Docker Desktop, conteneurs et toute virtualisation imbriquee.
- Hebergement public ou persistant sur Shadow, exposition Internet, Caddy, DuckDNS et HTTPS public.
- Flox, Nix, PM2, `systemctl`, `tmux`, `autossh` et emulation de semantiques POSIX.
- Equivalence du menu local Unix `urls`, tunnels multiples automatiques, OAuth MCP/Clerk/Blacksmith/Turso et promotion automatique de cle SSH.
- Next.js, Nuxt, Vue, Vite generique, Expo, Dart seul, Go, Rust et autres runtimes dans la premiere version.
- Emulateur Android. Les builds APK Windows sans emulateur sont un chantier separe et ne font pas partie du DevServer V1.
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
- L'endpoint public ne duplique pas la logique: `install-shipglows.ps1` dans ShipGlows reste l'autorite et CommandGlows sert uniquement l'artefact genere synchronise.
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
- Required scenario IDs: `BOOT-FULL-01`, `BOOT-LOCAL-02`, `ASTRO-START-03`, `PYTHON-START-04`, `FLUTTER-WEB-05`, `PORT-RECOVERY-06`, `STALE-PID-07`, `REGISTRY-ATOMIC-08`, `REDACTION-09`, `PUBLIC-PARITY-10`, `SHADOW-RECONNECT-11`.
- Required results: full public bootstrap installs the DevServer without a tunnel; local bootstrap remains compatible; each supported stack starts and serves localhost; process identity and registry recovery are safe; secrets are absent from logs; CommandGlows page/endpoint match the canonical script; Shadow reconnect is recoverable.
- Exception with proof: Android emulator is excluded because Shadow does not support the required nested virtualization; no emulator test is required.
- Exception with proof: public URL, Caddy and persistent-hosting tests are excluded by product scope and Shadow restrictions.
- Runtime observability exception: Sentry is not applicable because this is a local CLI/bootstrap with no hosted application telemetry contract; safe redacted diagnostic/log-copy behavior is required instead.
- Build-time header exception: web build-time Paris/UTC headers are not applicable to the PowerShell runtime; public CommandGlows Astro build/deployment checks remain required for the installer page and raw endpoint.

## ZOMBIES coverage

- Z — Zero: empty registry, no projects, missing tools, no free recorded process, absent logs.
- O — One: one valid project per supported stack, one process, one port, one log stream.
- M — Many: multiple projects, simultaneous distinct ports, stop all, repeated refresh/restart, duplicate repo names in different paths.
- B — Boundary Behaviors: ports 3000 and 3100, exhausted range, paths with spaces/Unicode, maximum reasonable log size, stale PID reuse, locked registry file.
- I — Interface definition: PowerShell to Git/Node/pnpm/uv/Flutter, registry to OS process identity, DevServer to browser, bootstrap to installed profile command.
- E — Exceptional behavior: clone failure, dependency failure, child exit, occupied port, malformed JSON, partial atomic write, missing Windows Terminal, cancelled install, Shadow shutdown.
- S — Simple Scenarios, Simple Solutions: one native backend and one closed registry; no abstraction pretending Flox/PM2 parity and no general-purpose runtime plugin system in V1.

# Dependencies

- Windows 10/11 environment supplied by Shadow PC, with Windows PowerShell 5.1 available.
- Git for Windows for clone operations; existing repos can still be registered when Git installation is unavailable.
- Node.js LTS and pnpm for Astro. npm is used only when the repo owns `package-lock.json`.
- `uv` for Python version/environment/dependency ownership. `uv run` and `uv sync --locked` are the preferred project paths.
- Flutter SDK for Windows with web support and a browser available on the Shadow desktop.
- Windows Terminal when available; visible `powershell.exe`/`pwsh.exe` process fallback otherwise.
- Existing `install-shipglows.ps1` distribution path for opt-in bootstrap integration.
- CommandGlows public distribution authority at `https://www.commandglows.com/shipglows-script?format=powershell`, backed by `commandglows_site/src/generated/shipglows-installer.ps1`.
- Fresh external docs verdict: `fresh-docs checked` on 2026-08-07 against:
  - Astral uv, `Running commands`: https://docs.astral.sh/uv/concepts/projects/run/
  - Astral uv, `Locking and syncing`: https://docs.astral.sh/uv/concepts/projects/sync/
  - Astral uv, `Working on projects`: https://docs.astral.sh/uv/guides/projects/
  - Microsoft PowerShell process documentation: https://learn.microsoft.com/powershell/module/microsoft.powershell.management/start-process
  - Microsoft NetTCPIP documentation: https://learn.microsoft.com/powershell/module/nettcpip/get-nettcpconnection
  - Flutter Windows installation: https://docs.flutter.dev/get-started/install/windows
  - Flutter web development: https://docs.flutter.dev/platform-integration/web/building
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
- `tools/sync_shipglows_public_bootstrap.sh` must stop targeting the retired WinGlowz layout and synchronize/check the canonical CommandGlows generated shell and PowerShell assets.
- `/home/claude/commandglows/commandglows_site/src/data/scriptInstallPages.ts` changes `windows-full` from unavailable to available in English and French, with an exact copyable `curl.exe` + `powershell.exe ... -InstallMode full` command.
- `/home/claude/commandglows/commandglows_site/src/pages/shipglows-script.ts` remains the single negotiated raw endpoint; no second Windows-full route is introduced.
- `local/install_local.ps1` remains tunnel-owned and should not absorb DevServer runtime logic.
- `cli/windows/` becomes the Windows runtime authority while `cli/*.sh` remains the Linux runtime authority.
- `.shipglows.env` keeps its existing closed schema. `SHIPGLOWS_ENV_PORT` may be consumed cross-platform only after equivalent validation; `SHIPGLOWS_AUTO_REPAIR` must not authorize arbitrary remediation.
- The public product promise changes from “native Windows tunnel only” to “native Windows local DevServer for three supported stacks”; README and public installer surfaces must state exact limitations.
- Code-doc mapping must add Windows runtime and installer patterns with Windows parser/integration proof requirements.
- Existing Linux regression suites must run to prove the additive backend did not alter server semantics.
- Shadow automatic shutdown means the registry is durable but process state is ephemeral; UX and docs must teach refresh/restart rather than persistence.

# Documentation Coherence

- Update `README.md` with the Windows DevServer capability matrix, install selector, supported stacks and excluded hosting behavior.
- Update `local/README_WINDOWS.md` to separate native tunnel mode from native DevServer mode and remove the old implication that WSL is the only complete development path.
- Update `shipglows_data/technical/runtime-cli.md` with the dual-backend architecture, Windows registry/process contracts and supported framework matrix.
- Update `shipglows_data/technical/installer-and-user-scope.md` with the opt-in DevServer surface, user-scoped paths and dependency authority.
- Update `shipglows_data/technical/architecture.md`, `context.md` and `context-function-tree.md` for the new entrypoints and invariants.
- Update `shipglows_data/technical/code-docs-map.md` with `cli/windows/**`, PowerShell installer files and `tests/windows/**` validation routes.
- Add an operator checklist under `shipglows_data/workflow/test-checklists/` for real Shadow proof.
- Review public CommandGlows installer copy only after implementation proves the capability; do not publish the promise from the spec alone.
- Update the CommandGlows ShipGlows installer page in both languages, its generated PowerShell artifact and deployment tests in the same release wave as the proven Windows full installer.
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
  - Notes: Keep labels in the operator language where existing ShipGlows localization permits; do not depend on Gum.

- [ ] Task 6: Add native Windows local/full bootstrap modes
  - File: `install-shipglows.ps1`, `cli/windows/install-devserver.ps1`
  - Action: Add `InstallMode local|full` with environment fallback, where default/local preserves the existing tunnel installation and full installs only the native DevServer. Download/extract only authorized Windows files, validate archive structure and hashes, check dependencies and install user-profile commands.
  - User story link: Makes setup possible on Shadow without WSL or admin-heavy Linux installation.
  - Depends on: Tasks 1-5.
  - Validate with: Parser checks, local/full mode fixtures, download-only fixture, archive traversal rejection, default/local regression and real Shadow full install using the public curl.exe command.
  - Notes: Dependency installation requiring UAC or network must remain explicit and recoverable.

- [ ] Task 7: Publish Windows full through the canonical CommandGlows endpoint and page
  - File: `tools/sync_shipglows_public_bootstrap.sh`, `/home/claude/commandglows/commandglows_site/src/generated/shipglows-installer.ps1`, `/home/claude/commandglows/commandglows_site/src/data/scriptInstallPages.ts`, `/home/claude/commandglows/commandglows_site/tests/deployment/shipglowsInstaller.test.ts`, `/home/claude/commandglows/commandglows_site/tests/deployment/shipglowsRoutes.test.ts`
  - Action: Retarget bootstrap synchronization to the canonical CommandGlows checkout, keep `/shipglows-script?format=powershell` as the raw endpoint, expose an available `windows-full` selector in EN/FR and publish the exact file-download command ending in `-InstallMode full`.
  - User story link: Gives the operator the same one-page public installation path used by Linux, Termux and Windows local.
  - Depends on: Task 6.
  - Validate with: Sync `--check`, byte comparison, CommandGlows installer/route unit tests, Astro build check, hosted endpoint body check and browser selector proof.
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
  - Notes: No public binding, emulator or shutdown bypass test.

- [ ] Task 10: Align technical and operator documentation
  - File: `README.md`, `local/README_WINDOWS.md`, `shipglows_data/technical/runtime-cli.md`, `shipglows_data/technical/installer-and-user-scope.md`, `shipglows_data/technical/architecture.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/context-function-tree.md`, `shipglows_data/technical/code-docs-map.md`
  - Action: Document dual backends, exact capability matrix, install path, state locations, limitations, Shadow posture, proof commands and documentation update mapping.
  - User story link: Gives the operator an honest migration and recovery path.
  - Depends on: Tasks 1-9.
  - Validate with: Metadata lint, link/path checks, capability-claim comparison against completed tests and documentation map review.
  - Notes: Do not claim Windows parity beyond the three proven stacks.

# Acceptance Criteria

- [ ] AC01: Given a Shadow PC with WSL unavailable, when the operator installs the explicit DevServer surface, then `shipglows-dev` launches under native Windows PowerShell without Bash, WSL, Flox, PM2 or Caddy.
- [ ] AC01a: Given the public Windows installer endpoint, when the operator downloads it with `curl.exe` and runs `powershell.exe -NoProfile -ExecutionPolicy Bypass -File <installer> -InstallMode full`, then only the native DevServer is installed from the resolved public ShipGlows commit; no tunnel setup is invoked.
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
- [ ] AC15: Given the default `install-shipglows.ps1` invocation, when no DevServer surface is selected, then the existing native tunnel installation behavior remains unchanged.
- [ ] AC15a: Given the CommandGlows EN or FR ShipGlows page, when Windows and full are selected, then the option is available and copies the public `curl.exe` download plus `-InstallMode full` execution command; Windows local remains available separately.
- [ ] AC15b: Given a public deployment, when `/shipglows-script?format=powershell` is fetched, then its body is byte-identical to canonical `install-shipglows.ps1` and contains the tested local/full mode contract.
- [ ] AC16: Given an unsupported framework or ambiguous Python entrypoint, when start is selected, then no generic command executes and the operator receives an actionable supported-contract message.
- [ ] AC17: Given the first implementation is complete, when existing Linux CLI/bootstrap tests run, then no Linux server lifecycle regression is introduced.
- [ ] AC18: Given documentation is prepared for release, when capability claims are checked against the Shadow checklist, then only Astro, supported Python/FastAPI conventions and Flutter Web are advertised.
- [ ] AC19: Given Shadow disconnects or shuts down, when ShipGlows is relaunched, then it reconciles ephemeral process state and never attempts persistence, public hosting or an automatic-shutdown bypass.
- [ ] AC20: Given unregister is selected, when the operator confirms, then only the registry entry is removed and the repository remains on disk.

# Test Strategy

1. Run PowerShell parser validation for every `.ps1` and `.psm1` on Windows PowerShell 5.1 and PowerShell 7.
2. Run table-driven fixture tests for validation, stack detection, command arguments, ports, registry atomicity, redaction and stale PID identity.
3. Run process integration tests in a unique temporary workspace with explicit cleanup and verify no foreign process is stopped.
4. Start minimal Astro and FastAPI fixtures, wait for bounded HTTP health, inspect logs, restart and stop.
5. Launch Flutter Web in a visible terminal, prove URL readiness and manually trigger hot reload/restart.
6. Exercise bootstrap default/local/full surfaces, including malformed archive/traversal rejection and interrupted install recovery.
7. Synchronize canonical bootstrap artifacts into CommandGlows, run installer/route tests and prove the EN/FR Windows full selector.
8. Fetch the hosted PowerShell endpoint, compare its body with the canonical script and run the downloaded full installer on Shadow.
9. Run current Bash syntax and focused Linux CLI/bootstrap suites to prove additive platform separation.
10. Complete the real Shadow checklist, including shutdown/stale registry recovery on a later session.
11. Run metadata lint and documentation map checks before readiness/ship claims.

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
- Trust/data boundaries: CommandGlows public raw endpoint -> local temporary PowerShell file -> explicit PowerShell process; Git archive/repository metadata -> detection logic; project manifests and lockfiles -> bounded command builders; managed child process -> local registry/logs; local user is the only intended initiator. No remote tenant or authenticated API boundary exists in the DevServer runtime.
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
- Public bootstrap command contract: download, inspectable temporary file, explicit PowerShell execution. The documented full form is equivalent to `$installer = Join-Path $env:TEMP 'shipglows-install.ps1'; curl.exe -fsSL 'https://www.commandglows.com/shipglows-script?format=powershell' -o $installer; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -InstallMode full`.
- Security implementation gate: preserve `v5.0.0-1.2.5` and `v5.0.0-5.3.2` evidence in tests/review; do not weaken to a string-evaluated command path or broad recursive deletion to simplify Windows behavior.
- Documentation Freshness Gate verdict: `fresh-docs checked`; re-evaluate local installed versions before implementation.

# Open Questions

None. The operator has fixed the platform constraint (native Windows on Shadow), supported stacks (Astro, Python, Flutter), and desired outcome (local workspace plus DevServer lifecycle). Package-level choices, file structure and process mechanics are implementation-owned. Any later request for public hosting, custom project commands, Android emulator/build support or framework expansion requires a separate scope decision.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-07 21:55:18 UTC | 100-sg-spec | GPT-5 Codex | Created the full native Windows DevServer contract for Astro, Python/FastAPI and Flutter Web from operator constraints, current Linux/PowerShell code evidence and official runtime documentation. | Draft created; adversarial self-review integrated; readiness and Windows implementation proof pending. | Review readiness for `native-windows-devserver-astro-python-flutter`. |
| 2026-08-07 22:18:16 UTC | 100-sg-spec | GPT-5 Codex | Extended the contract so native Windows full is installed through the canonical CommandGlows curl.exe/PowerShell endpoint and exposed by the existing EN/FR installer selector. | Draft updated with local/full semantics, cross-repo synchronization, public route/page tasks and hosted/Shadow acceptance proof. | Re-run readiness review against the expanded cross-repo scope. |
| 2026-08-08 00:25:00 UTC | 101-sg-ready | GPT-5 Codex | Completed adversarial readiness review and added the required OWASP Security Gate for public PowerShell bootstrap, process command construction, path validation and artifact integrity. | Ready; implementation, Windows host proof, hosted endpoint proof and closure remain pending. | Start the bounded implementation wave. |
| 2026-08-08 04:18:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the native PowerShell DevServer module/entrypoint, full Windows bootstrap extraction, launcher/profile installer, public EN/FR windows-full commands, CommandGlows generated PowerShell parity, and static/test contracts. | ShipGlows static contract passed; CommandGlows targeted tests 96/96 and Astro check 0 errors/1 hint; native PowerShell parser and Shadow runtime proof remain pending. | Run the Windows Parser/Smoke matrix and hosted endpoint proof. |
| 2026-08-08 04:25:00 UTC | 102-sg-start | GPT-5 Codex | Corrected the Windows mode boundary after operator review: `full` now installs only the local DevServer; `local` remains the optional SSH tunnel path. Updated bootstrap branching, public notes, README and acceptance criteria. | Static revalidation pending; no tunnel is invoked by the full branch. | Re-run public tests and Windows Parser/Smoke matrix. |

# Current Chantier Flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| 100-sg-spec | complete | Full implementation contract saved with scope, exclusions, security invariants, ZOMBIES coverage and proof plan. |
| 101-sg-ready | complete | Spec is ready after structure, security, freshness, cross-repo and proof-contract review. |
| 102-sg-start | complete | Native runtime, full bootstrap, launcher, public commands, docs and static contracts are implemented locally. |
| 103-sg-verify | in_progress | Verify Windows PowerShell 5.1 behavior, Shadow reconnect/port recovery and public artifact deployment parity. |
| 104-sg-end | pending | Close only after real Shadow proof and documentation coherence. |
| 005-sg-ship | pending | Commit/push remains separately authorized. |
