---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-05-08"
created_at: "2026-05-08 09:59:29 UTC"
updated: "2026-05-08"
updated_at: "2026-05-08 10:20:00 UTC"
status: reviewed
source_skill: sg-build
source_model: GPT-5
scope: feature
owner: Diane
user_story: "En tant qu'operateur ShipGlows qui utilise Codex sur une machine partagee ou longue duree, je veux que les MCP Codex soient desactives par defaut et activables depuis un launcher ShipGlows interactif, afin de limiter la charge machine sans devoir taper des commandes longues."
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems:
  - install.sh
  - lib.sh
  - shipglows.sh
  - README.md
  - docs/technical/installer-and-user-scope.md
  - docs/technical/runtime-cli.md
depends_on:
  - artifact: "shipglows_data/technical/installer-and-user-scope.md"
    artifact_version: "1.0.1"
    required_status: reviewed
  - artifact: "shipglows_data/technical/runtime-cli.md"
    artifact_version: "1.0.3"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "Observed Codex startup and machine-load issue caused by multiple long-running MCP server processes for Convex and Playwright."
  - "User decision 2026-05-08: MCP should be off by default and enabled case-by-case for Codex conversations."
  - "User clarification 2026-05-08: ShipGlows must launch Codex itself from an interactive menu; it should not merely print commands for the operator to type."
  - "User clarification 2026-05-08: ShipGlows health should surface leftover local MCP process groups and stop them only with explicit confirmation."
next_step: "/sg-ship Add Codex MCP on-demand launcher"
---

# Spec: Codex MCP on-demand launcher

## Title

Codex MCP on-demand launcher

## Status

reviewed

## User Story

En tant qu'operateur ShipGlows qui utilise Codex sur une machine partagee ou longue duree, je veux que les MCP Codex soient desactives par defaut et activables depuis un launcher ShipGlows interactif, afin de limiter la charge machine sans devoir taper des commandes longues.

## Minimal Behavior Contract

ShipGlows doit enregistrer les MCP Codex utiles dans `~/.codex/config.toml` avec `enabled = false` par defaut. Quand l'operateur lance l'action Codex dans ShipGlows, l'interface doit lui permettre de choisir un repertoire et un preset ou une selection de MCP, puis remplacer le processus ShipGlows courant par `codex` avec des overrides `-c mcp_servers.<name>.enabled=true` pour cette session seulement. Si Codex est absent, si le repertoire est invalide, ou si un MCP inconnu est demande en mode CLI direct, ShipGlows doit afficher une erreur actionnable sans modifier la config globale.

## Success Behavior

- Preconditions: Codex CLI est installe ou detectable dans le `PATH`; les MCP ShipGlows sont deja enregistres dans la config Codex utilisateur.
- Trigger: l'operateur choisit l'action Codex dans le menu ShipGlows ou lance le raccourci `sg codex`.
- User/operator result: ShipGlows affiche des choix interactifs, puis ouvre directement une conversation Codex dans le terminal courant avec les MCP choisis.
- System effect: aucune conversation existante n'est fermee; la config globale reste MCP-off; seuls les overrides de la nouvelle session activent les MCP demandes.
- Success proof: `bash -n` passe, les MCP Codex installes contiennent `enabled = false`, et le launcher construit des arguments Codex scopes a la session.

## Error Behavior

- Expected failures: Codex absent, repertoire choisi inexistant, nom MCP direct invalide, annulation utilisateur.
- User/operator response: message clair et retour au shell/menu sans mutation globale.
- System effect: aucun kill de processus, aucune suppression de fichier, aucune activation persistante involontaire.
- Must never happen: fermer une conversation Codex existante; activer tous les MCP par defaut; demander a l'utilisateur de recopier une commande longue pour le flux nominal.

## Scope In

- Desactiver par defaut les MCP Codex enregistres par `install.sh`.
- Ajouter une action ShipGlows qui lance Codex avec les MCP choisis.
- Ajouter un raccourci `sg codex [mcp...]` pour le meme launcher.
- Documenter la regle MCP-off et le launcher.

## Scope Out

- Nettoyer automatiquement ou sans confirmation les anciens processus MCP deja lances.
- Reauthentifier Supabase/Vercel.
- Modifier la politique MCP Claude Code.
- Ajouter une UI graphique hors terminal.

## Invariants

- Les MCP sont actives par session, jamais globalement sans demande explicite.
- `exec codex ...` est utilise seulement au moment du lancement demande par l'operateur.
- Les noms MCP passes en CLI direct sont valides comme identifiants de config, pas interpretes par le shell.
- La config utilisateur hors blocs ShipGlows reste preservee.

## Implementation Tasks

- [x] Task 1: Desactiver les MCP Codex par defaut dans l'installateur
  - File: `install.sh`
  - Action: changer les blocs `configure_codex_*_mcp` pour ecrire `enabled = false` sauf opt-in explicite documente.
  - Validate with: `bash -n install.sh`

- [x] Task 2: Ajouter le launcher Codex interactif dans le runtime CLI
  - File: `lib.sh`
  - Action: ajouter selection de repertoire, presets MCP, selection custom, validation des noms MCP, puis `exec codex -C <dir> -c ...`.
  - Validate with: `bash -n lib.sh`

- [x] Task 3: Ajouter le raccourci CLI
  - File: `lib.sh`, `shipglows.sh`
  - Action: permettre `sg codex` et `sg codex supabase playwright` sans casser les raccourcis menu existants.
  - Validate with: `bash -n shipglows.sh lib.sh`

- [x] Task 4: Mettre a jour la documentation utilisateur et technique
  - File: `README.md`, `docs/technical/installer-and-user-scope.md`, `docs/technical/runtime-cli.md`
  - Action: expliquer MCP-off par defaut, activation par launcher, et limite sur les conversations deja ouvertes.
  - Validate with: relecture et recherches ciblees.

- [x] Task 5: Ajouter un cleanup MCP confirme au menu Health
  - File: `lib.sh`, `docs/technical/runtime-cli.md`
  - Action: detecter les groupes de processus MCP locaux, les afficher avec provider/RAM/uptime/parent Codex, puis stopper uniquement le groupe choisi apres confirmation.
  - Validate with: `bash -n lib.sh`; dry-run cleanup.

## Acceptance Criteria

- [x] AC 1: Given une installation ShipGlows, when `~/.codex/config.toml` est genere, then les MCP Codex ShipGlows sont enregistres avec `enabled = false` par defaut.
- [x] AC 2: Given l'operateur ouvre ShipGlows, when il choisit l'action Codex et un preset MCP, then ShipGlows lance directement Codex avec les MCP choisis sans imprimer une commande a recopier.
- [x] AC 3: Given `sg codex supabase playwright`, when le raccourci est lance, then Codex recoit uniquement les overrides Supabase et Playwright pour cette session.
- [x] AC 4: Given une conversation Codex existante, when le launcher est utilise, then ShipGlows ne ferme pas cette conversation et ne tue aucun MCP existant.
- [x] AC 5: Given la documentation, when un utilisateur lit la section Codex, then il comprend que les MCP sont off par defaut et activables via l'action ShipGlows.
- [x] AC 6: Given des processus MCP locaux restent actifs, when l'operateur ouvre Health -> MCP process cleanup, then ShipGlows liste les groupes detectes et ne stoppe qu'un groupe confirme sans tuer de processus Codex.

## Test Strategy

- Syntax: `bash -n install.sh lib.sh shipglows.sh`
- Focused config proof: inspect `enabled = false` in generated install blocks.
- Focused launcher proof: dry-run by reading constructed code path and using `codex mcp list -c ...` behavior already confirmed locally.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-08 09:59:29 UTC | sg-build | GPT-5 | Created ready spec for Codex MCP-off default and on-demand ShipGlows launcher. | ready | /sg-start Codex MCP on-demand launcher |
| 2026-05-08 10:09:32 UTC | sg-build | GPT-5 | Implemented Codex MCP-off installer defaults, interactive ShipGlows launcher, CLI shortcut, and docs. | implemented | /sg-verify Codex MCP on-demand launcher |
| 2026-05-08 10:09:32 UTC | sg-build | GPT-5 | Verified Bash syntax, dry-run launcher arguments, MCP override behavior, metadata, and documentation coherence. | verified | /sg-ship Add Codex MCP on-demand launcher |
| 2026-05-08 10:20:00 UTC | sg-build | GPT-5 | Added Health menu MCP process detection and confirmed cleanup by process group, refusing groups that contain Codex. | implemented | /sg-verify MCP process cleanup |

## Current Chantier Flow

- `sg-spec`: done, ready spec created by sg-build mini-lifecycle.
- `sg-ready`: passed by direct user decision and low ambiguity.
- `sg-start`: done, implementation complete.
- `sg-verify`: done, targeted checks passed.
- `sg-end`: not launched.
- `sg-ship`: not launched.

Next step: `/sg-ship Add Codex MCP on-demand launcher`
