---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.8.0"
project: "shipglows"
created: "2026-04-25"
updated: "2026-08-04"
status: draft
source_skill: 102-sg-start
scope: "context"
owner: "unknown"
confidence: "high"
risk_level: "medium"
security_impact: "none"
docs_impact: "yes"
linked_systems: ["cli/shipglows.sh", "cli/lib.sh", "cli/config.sh", "cli/install.sh", "local/local.sh", "skills/", "skills/references/app-blueprints.md", "skills/app-blueprints/", "shipglows_data/workflow/playbooks/spec-driven-workflow.md", "shipglows_data/technical/context-function-tree.md", "shipglows_data/editorial/content-map.md", "shipglows_data/technical/", "shipglows_data/business/project-competitors-and-inspirations.md", "shipglows_data/business/affiliate-programs.md"]
depends_on: []
supersedes: []
evidence: ["README.md", "CLAUDE.md", "shipglows_data/editorial/content-map.md", function extraction from core shell scripts, "shipglows_data/technical/* as code-proximate subsystem documentation", "Business registries added for project competitors/inspirations and affiliate programs.", "2026-07-17 DevServer startup/cache implementation: lazy atomic registry, pruned Flox discovery, parent-shell cache APIs.", "Métier-first public hierarchy and autonomous execution specification."]
next_step: "/sg-docs update shipglows_data/technical/context.md"
---

# CONTEXT

## Purpose

Ce fichier donne la carte operative minimale de ShipGlows. Il sert a gagner du temps au debut d'un nouveau thread et a orienter vers le bon sous-contexte.

## What ShipGlows Is

ShipGlows combine deux couches :

- un gestionnaire d'environnements de dev cote serveur base sur Flox, PM2, Caddy et DuckDNS
- un systeme de skills pour travail spec-first, verification, audit, documentation et shipping

## Entry Points

- `cli/shipglows.sh`: point d'entree du CLI.
- `sg codex` / `sg co`: raccourci de lancement Codex qui court-circuite le
  cleanup des environnements et ouvre une session avec MCP choisis pour ce run.
- `cli/lib.sh`: coeur des actions, validations, integrations systeme et menus.
- `cli/config.sh`: configuration centralisee et validation.
- `cli/install.sh`: bootstrap serveur et configuration de l'environnement utilisateur.
- `local/local.sh`: UX locale des tunnels SSH.
- `skills/`: workflows AI orientes taches.
- `#feature:<term>`: indice de navigation technique optionnel pour la recuperation par behavior index; ce n'est pas un langage de commande, et le texte libre reste actif.
- `skills/references/app-blueprints.md`: systeme de blueprints — squelettes de specs globales pour archetypes d'applications recurrentes, utilises par `001-sg-build` (Blueprint Gate), `100-sg-spec` (pre-remplissage de spec), et `306-sg-scaffold` (conventions de structure).
- `skills/app-blueprints/`: catalogue des blueprints disponibles.

## Repo Map

- `cli/shipglows.sh`, `cli/lib.sh`, `cli/config.sh`, `cli/install.sh`: couche serveur/CLI.
- `local/`: outils locaux d'acces a un serveur ShipGlows.
- `skills/`: skills ShipGlows pour exploration, spec, execution, verif, docs, audits.
- `tui/`: cockpit terminal optionnel en lecture seule pour projets, taches, audits, specs et diagnostics.
- `templates/`: templates d'artefacts versionnes.
- `tools/shipglows_metadata_lint.py`: linter des frontmatters ShipGlows.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`: doctrine de workflow.
- `shipglows_data/technical/metadata-migration-guide.md`: doctrine de migration metadata.
- `shipglows_data/editorial/content-map.md`: carte des surfaces de contenu, pages piliers, cocons semantiques et destinations de repurposing.
- `shipglows_data/technical/`: couche interne de documentation technique proche du code.
- `install-shipglows.sh` et `install-shipglows.ps1`: points d'entree publics stables conserves a la racine; les lanceurs runtime et outils restent sous `cli/`.
- trackers/docs legacy de racine (`TASKS.md`, `AUDIT_LOG.md`, `concurrent.md`, autres notes historiques): dette de migration ou facades de compatibilite, pas source de verite durable quand un artefact canonique existe sous `shipglows_data/`.
- `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/branding/branding.md`, `shipglows_data/business/gtm.md`: contrats business, produit et promesse publique.
- `shipglows_data/business/project-competitors-and-inspirations.md`: registre par projet des concurrents, alternatives, inspirations et anti-patterns.
- `shipglows_data/business/affiliate-programs.md`: registre par projet des affiliations, referrals, partners, disclosures et contraintes non secretes.
- `shipglows_data/technical/architecture.md`, `shipglows_data/technical/guidelines.md`: contrats structurels et techniques.

## Core Flows

### 1. Server CLI Flow

```text
cli/shipglows.sh
  -> source lib.sh
     -> declarations only; no PM2 query or Flox scan
  -> select menu frontend
  -> main()
  -> check_prerequisites()
  -> run_menu()
  -> action_* handlers
  -> env_start / env_stop / env_restart / env_remove / publish / dashboard
```

### 2. Environment Lifecycle

```text
project path
  -> validate_project_path
  -> detect_project_type
  -> init_flox_env
  -> detect_dev_command
  -> find_available_port
  -> PM2 start/update
  -> invalidate_after_pm2_mutation
  -> atomic registry_update or lazy ensure_registry
  -> refresh user-mode Caddy routes from online PM2 apps
  -> dashboard / health / publish
```

### 3. Local Tunnel Flow

```text
local/local.sh
  -> select connection
  -> fetch remote session identity
  -> inspect active remote ports (PM2 + Flutter Web tmux registry)
  -> start_tunnels / stop_tunnels / show_status
```

### 4. Flutter Web Interactive Flow

```text
lib.sh::action_flutter_web
  -> select Flutter project
  -> ensure project Flox runtime
  -> start flutter run -d web-server inside tmux
  -> record port in SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE
  -> send r/R to tmux for hot reload / hot restart
```

### 5. Skill Workflow

```text
shipglows -> public métier owner -> clarification only when material ->
project -> product -> surface -> feature -> spec or bounded contract ->
implementation -> proof -> documentation reflection -> closure
```

La surface publique comprend le routeur `shipglows` et treize métiers :

- Créer : `sg-development`, `sg-design`, `sg-experience`
- Qualité : `sg-bug`, `sg-engineering`, `sg-maintenance`
- Publier : `sg-release`
- Développer l’audience : `sg-content`, `sg-marketing`, `sg-seo`
- Gouverner : `sg-docs`
- Organiser : `sg-planning`, `sg-help`

Les noms numériques restent des moteurs internes. Les propriétaires publics les
choisissent et les enchaînent sans demander à l’opérateur de micro-manager le
workflow. `sg-content` possède les docs et contenus publics ; `sg-docs` possède
la documentation interne, la gouvernance et les métadonnées. `sg-engineering`
possède aussi les moteurs internes de sync, accès/entitlements et parité.

Avant de questionner, le propriétaire consulte les contrats et le code utiles.
Il ne pose qu’une question numérotée à la fois, uniquement quand une décision
business, de périmètre, de sécurité, d’autorisation ou d’effet externe manque.
Une fois le besoin exécutable par un agent frais, il le mène de A à Z ; les
choix de playbook, de moteur, de structure de code, de validation et de handoff
restent internes.

`sg-development` utilise l’actuel moteur `001-sg-build`. Son Blueprint Gate
cherche un blueprint correspondant à la requête et pré-remplit architecture,
stack, modèles et routes pour les moteurs aval (`100-sg-spec`,
`306-sg-scaffold`).

Workflow legacy (sans blueprint) :
```text
sg-explore -> exploration_report -> sg-spec -> sg-ready -> sg-start -> sg-verify -> sg-end
```

Fast paths existent aussi :

- `sg-fix` pour bug-first
- `sg-start` pour tache petite et claire
- `sg-docs metadata` pour migration frontmatter

### 6. Codex MCP Launcher Flow

```text
sg codex OR menu MCP / Codex launcher
  -> choose workspace
  -> choose MCP preset or custom MCPs
  -> exec codex -C <workspace> -c mcp_servers.<name>.enabled=true
```

Les MCP Codex restent desactives par defaut dans `~/.codex/config.toml`; le
launcher active uniquement les MCP demandes pour la nouvelle session.

## Technical Decisions

- PM2 est la source d'etat d'execution. Le cache PM2 doit etre invalide apres mutation.
- Le sourcing de `cli/lib.sh` reste paresseux : aucun `pm2 jlist`, `registry_sync` ou scan Flox avant qu'une action en ait besoin.
- `scan_flox_projects` est l'unique proprietaire de la decouverte Flox et prune chaque `.flox` trouve; `ensure_registry` fournit ensuite l'index noms/paths persistant.
- Les caches qui doivent survivre entre deux appels utilisent les APIs a variable de destination dans le shell parent; les wrappers stdout restent des surfaces de compatibilite.
- Le registre environnement est ecrit par fichier temporaire voisin + validation + `mv` atomique, avec verrou borne et conservation du dernier snapshot valide.
- Caddy local est gere par ShipGlows en mode utilisateur et suit l'etat PM2:
  start rafraichit les routes, stop/stop-all l'arrete quand aucune app PM2
  n'est online. Le service systeme Caddy est legacy/public et ne doit pas rester
  actif sans app PM2.
- L'allocation de port doit eviter collisions runtime et collisions PM2 cachees.
- Les operations destructives doivent rester idempotentes.
- Les paths projet doivent etre absolus et valides.
- Les docs ShipGlows actives doivent avoir un frontmatter versionne.
- La racine du repo ne doit pas redevenir une deuxieme couche de gouvernance active; quand une doc canonique existe sous `shipglows_data/`, la version racine doit etre supprimee ou reduite a une facade explicite.
- Les changements de code mappes par `shipglows_data/technical/code-docs-map.md` doivent produire un `Documentation Update Plan` ou une justification no-impact.
- `shipglows_data/editorial/content-map.md` doit rester structurel : surfaces, roles, clusters et regles de mise a jour, pas backlog editorial.
- Les focus tags ne sont pas de simples rappels de contexte : ils peuvent biaiser le owner skill, la surface d'artefact et la posture d'execution sur le tour courant.
- Les trackers operationnels (`TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`) ne recoivent pas de frontmatter.
- Les contenus runtime applicatifs gardent leur propre schema de frontmatter.

## Invariants

- Appeler `invalidate_pm2_cache` apres `start`, `stop`, `delete`, `restart` ou tout changement PM2.
- Invalider ensemble PM2, registre et index noms/paths via `invalidate_after_pm2_mutation` apres une mutation runtime.
- Ne pas parser la structure JS/JSON a coups de grep si une voie fiable existe deja.
- Ne pas editer manuellement des fichiers regeneres comme les configs d'ecosystem runtime.
- Ne pas transformer une passe metadata en rewrite complet de documentation.
- Un succes utilisateur doit etre observable ; un echec doit etre observable ou recuperable, sauf justification explicite.

## Hotspots

- `lib.sh::env_start`: plus gros noeud fonctionnel.
- `lib.sh::scan_flox_projects`, `ensure_registry`, `environment_index_load`: chemin critique paresseux pour les selecteurs d'environnement.
- `lib.sh::env_start` et `init_flox_env`: auto-install Node avec guidage package manager quand `npm` est detecte, et chemin de migration pnpm optionnel.
- `lib.sh::show_dashboard`: aggregation d'etat.
- `lib.sh::deploy_github_project`: deploy depuis GitHub.
- `lib.sh::action_publish`: integration Caddy + DuckDNS.
- `local/local.sh::main`: UX locale complete pour tunnels.
- `lib.sh::action_flutter_web`: session Flutter Web interactive en tmux et hot reload.
- `tui/`: lecture consolidee de `shipglows_data/workflow/*`, diagnostics, specs, et filtres multi-projets.
- `skills/300-sg-docs/SKILL.md`: logique de migration metadata et audit documentaire.
- `skills/references/entrypoint-routing.md`: routeur canonique, y compris les implications d'execution des focus tags.
- `shipglows_data/technical/code-docs-map.md`: fichier partage qui mappe code, docs primaires, validations et triggers de mise a jour.

## Where To Edit What

- Changer le comportement de lancement d'app : `cli/lib.sh` autour de `env_start`, `detect_project_type`, `detect_dev_command`, `fix_port_config`.
- Changer le dashboard ou la sante : `cli/lib.sh` autour de `show_dashboard`, `health_check_all`, `diagnose_app_errors`.
- Changer le launcher Codex ou les presets MCP : `cli/lib.sh` autour de `action_codex_launcher`, puis `cli/install.sh` si les defaults Codex changent.
- Changer la publication web : `cli/lib.sh` autour de `action_publish`.
- Changer les tunnels locaux : `local/local.sh` et `local/dev-tunnel.sh`.
- Changer le mode Flutter Web interactif : `cli/lib.sh` autour de `action_flutter_web`, puis `local/remote-helpers.sh` si le tunnel doit découvrir de nouveaux ports.
- Changer le workflow d'agent : `skills/` + `shipglows_data/workflow/playbooks/spec-driven-workflow.md`.
- Changer les regles metadata : `skills/300-sg-docs/SKILL.md`, `tools/shipglows_metadata_lint.py`, `shipglows_data/technical/metadata-migration-guide.md`, `templates/`.
- Changer la documentation technique proche du code : `shipglows_data/technical/code-docs-map.md` puis le doc primaire dans `shipglows_data/technical/`.
- Changer l'UI shell (sélecteurs, menus, headers) : `cli/lib.sh` autour des primitives `ui_choose`, `ui_filter_choose`, `ui_text_center`, `ui_list_filter`, `ui_traffic_color`.
- Changer la decouverte ou les caches DevServer : `cli/lib.sh` autour de `scan_flox_projects`, `ensure_registry`, `pm2_data_load`, `environment_index_load` et `invalidate_after_pm2_mutation`.
- Changer la TUI (dashboard, filtres, tri, statuts) : `tui/src/statusMaps.ts` (mappings partagés), `tui/src/sources/` (lecture/parsing), `tui/src/viewModels/dashboard.ts` (logique de vue), `tui/src/views/dashboardView.ts` (rendu).
- Changer la cartographie editoriale, les destinations de contenu ou les cocons semantiques : `shipglows_data/editorial/content-map.md`, puis `shipglows-site/src/pages/docs.astro` ou les surfaces concernees.
- Changer le positionnement, l'audience ou le scope produit : `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md`.
- Changer les concurrents, alternatives, inspirations marche, anti-patterns ou notes de differenciation par projet : `shipglows_data/business/project-competitors-and-inspirations.md`.
- Changer les programmes d'affiliation, referral, sponsorship, partner ou disclosure commerciale : `shipglows_data/business/affiliate-programs.md`.
- Changer la structure technique globale : `shipglows_data/technical/architecture.md`, `shipglows_data/technical/guidelines.md`, puis `lib.sh` ou les scripts concernes.

## Read First By Task

- CLI principal : `CLAUDE.md`, `shipglows_data/technical/context-function-tree.md`, `cli/shipglows.sh`, `cli/lib.sh`.
- Install / bootstrap : `cli/install.sh`, `cli/config.sh`, `README.md`.
- Skill / workflow : `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, puis la skill cible.
- Metadata docs : `shipglows_data/technical/metadata-migration-guide.md`, `skills/300-sg-docs/SKILL.md`, `tools/shipglows_metadata_lint.py`.
- Docs techniques / code change : `shipglows_data/technical/code-docs-map.md`, puis le doc primaire mappe.
- Tunnels / acces local : `local/README.md`, `local/local.sh`, `local/dev-tunnel.sh`.
- Produit / business / site : `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/branding/branding.md`, `shipglows_data/business/gtm.md`, puis les registres `shipglows_data/business/project-competitors-and-inspirations.md` et `shipglows_data/business/affiliate-programs.md` si la tache touche marche, inspirations, differenciation ou monetisation partenaire.
- Contenu / repurposing : `shipglows_data/editorial/content-map.md`, `007-sg-content repurpose <source>`, puis la surface cible.
- Architecture / conventions : `shipglows_data/technical/architecture.md`, `shipglows_data/technical/guidelines.md`, `CLAUDE.md`.

## Linked Docs

- [AGENT.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/AGENT.md)
- [CLAUDE.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/CLAUDE.md)
- [README.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/README.md)
- [context-function-tree.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/technical/context-function-tree.md)
- [content-map.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/editorial/content-map.md)
- [technical/README.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/technical/README.md)
- [technical/code-docs-map.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/technical/code-docs-map.md)
- [shipglows_data/workflow/playbooks/spec-driven-workflow.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/workflow/playbooks/spec-driven-workflow.md)
- [shipglows_data/technical/metadata-migration-guide.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/technical/metadata-migration-guide.md)
- [business/business.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/business/business.md)
- [business/product.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/business/product.md)
- [business/branding.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/branding/branding.md)
- [business/gtm.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/business/gtm.md)
- [business/project-competitors-and-inspirations.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/business/project-competitors-and-inspirations.md)
- [business/affiliate-programs.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/business/affiliate-programs.md)
- [technical/architecture.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/technical/architecture.md)
- [technical/guidelines.md](${SHIPGLOWS_ROOT:-$HOME/shipglows}/shipglows_data/technical/guidelines.md)

## Maintenance Rule

Mettre a jour `shipglows_data/technical/context.md` quand un changement modifie :

- les entry points reels
- un flux technique majeur
- les hotspots
- un invariant critique
- la destination officielle des docs de contexte
- la carte `shipglows_data/technical/code-docs-map.md` ou les docs techniques primaires
- les surfaces de contenu ou regles de repurposing officielles
