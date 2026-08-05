---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-05"
created_at: "2026-08-05 17:10:00 UTC"
updated: "2026-08-05"
updated_at: "2026-08-05 18:05:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "installer-distribution-boundaries"
owner: "Diane"
user_story: "En tant qu'utilisateur ShipGlows, je veux installer la CLI/runtime, le plugin Codex ou le corpus de skills selon mon runtime, afin de ne pas télécharger ni activer des skills dont je n'ai pas besoin."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "install-shipglows.sh"
  - "cli/install.sh"
  - "local/install.sh"
  - "plugins/shipglows/"
  - ".opencode/skills/shipglows/"
  - ".agents/skills/shipglows/"
  - "tools/shipglows_sync_skills.sh"
  - "README.md"
  - "shipglows_data/technical/codex-plugin-packaging.md"
depends_on:
  - artifact: "shipglows_data/workflow/specs/ai-agent-install-ownership-and-autonomous-permissions.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/technical/codex-plugin-packaging.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "2026-08-05 inspection: install-shipglows.sh performs a full Git clone before selecting runtime components."
  - "2026-08-05 inspection: cli/install.sh calls configure_skills whenever ai-runtime is enabled, linking skills into both Claude and Codex."
  - "Codex has a repo-backed shipglows plugin; OpenCode and KiloCode expose repository-local compatible shims."
  - "Operator decision 2026-08-05: durable private data is already isolated in a private repository and is consumed by the CLI through its existing contract."
  - "Operator decision 2026-08-05: separate runtime/CLI installation from skills distribution; Codex is plugin-first."
next_step: "Synchronize the separately deployed website bootstrap before advertising its endpoint."
---

# Spec: Runtime Installer and Skill Distribution Separation

## Title

Séparer l'installation runtime des skills ShipGlows

## Status

verified locally; separate public website bootstrap remains to be synchronized

## User Story

En tant qu'utilisateur ShipGlows, je veux installer la CLI/runtime, le plugin
Codex ou le corpus de skills selon mon runtime, afin de ne pas télécharger ni
activer des skills dont je n'ai pas besoin.

## Minimal Behavior Contract

L'installation publique sélectionne une surface explicite. Le chemin runtime
installe seulement les fichiers nécessaires à la CLI, aux tunnels, à la
configuration et à la TUI éventuelle; il ne récupère ni ne lie les skills. Le
chemin Codex dirige vers le plugin public sans créer de copie de skills. Le
chemin corpus est explicite et fournit les skills publiques et shims requis par
OpenCode, KiloCode, Claude ou les mainteneurs. Une installation existante reste
réparable sans effacer de checkout, skill ou configuration utilisateur.

## Success Behavior

- Preconditions: Git, curl et bash sont disponibles ou installables; le dépôt public est accessible.
- Trigger: l'utilisateur lance l'installateur public avec le choix implicite runtime ou une surface explicite.
- User/operator result: la sortie indique clairement la surface installée et comment obtenir une autre surface.
- System effect: le checkout runtime utilise Git sparse checkout; aucun lien `~/.codex/skills` ou `~/.claude/skills` n'est créé sauf demande explicite de corpus.
- Success proof: test d'installation isolé vérifiant les chemins sparse, tests de synchronisation, validation du plugin et inspection des liens utilisateur.
- Silent success: non autorisée; chaque installation doit imprimer la surface et les composants activés.

## Error Behavior

- Expected failures: Git trop ancien pour sparse checkout, checkout existant incomplet, composant corpus demandé mais chemins absents, collision de liens utilisateur, plugin Codex indisponible.
- User/operator response: message actionnable qui identifie la surface non installée et la commande/option de reprise correspondante.
- System effect: aucune suppression de checkout existant, aucun lien de skill créé partiellement, aucun bootstrap réseau implicite depuis le plugin.
- Must never happen: installation par défaut de toutes les skills pour un utilisateur Codex, écrasement d'un checkout non Git, copie de données privées, ou activation automatique d'un plugin/compte externe.
- Silent failure: non autorisée; un fallback vers un clone complet doit être annoncé comme bloquant ou explicitement approuvé, jamais effectué en arrière-plan.

## Problem

Le bootstrap clone aujourd'hui tout le dépôt avant de savoir si l'utilisateur
veut la CLI, le plugin Codex ou le corpus de skills. Ensuite, la couche IA lie
les skills à Claude et Codex par défaut. Cette structure duplique le plugin
Codex, augmente le téléchargement runtime et rend floue la différence entre
installation de CLI et distribution des skills.

## Solution

Introduire une sélection de surface d'installation et un checkout sparse
runtime par défaut. Conserver le plugin comme voie Codex, réserver la
synchronisation de skills à une demande corpus explicite, et documenter
OpenCode/KiloCode comme consommateurs du corpus public et de leurs shims.

## Scope In

- Bootstrap sparse du runtime public sans `skills/` ni corpus de gouvernance par défaut.
- Option explicite de corpus de skills, avec sync Claude/Codex seulement dans cette option.
- Chemins documentés pour plugin Codex et shims OpenCode/KiloCode.
- Réparation sûre d'un checkout existant lors d'un changement de surface.
- Mise à jour des tests, README et contrat de packaging.

## Scope Out

- Création ou migration du dépôt privé; il existe déjà et reste hors périmètre.
- Publication de packs optionnels individuels.
- Refactor fonctionnel des skills, de leurs modes ou de leurs contrats.
- Installation automatique du plugin Codex dans le compte utilisateur.
- Suppression d'historique Git ou migration de données déjà isolées.

## Constraints

- `commandglows/shipglows` reste le dépôt public canonique.
- Codex est plugin-first; le plugin ne déclenche jamais seul un clone ou une mise à jour réseau.
- OpenCode/KiloCode peuvent nécessiter le corpus public, mais seulement après choix explicite.
- La CLI conserve l'accès au dépôt privé via son contrat existant, sans copier ce dépôt dans le checkout public.
- Les installations existantes et modifications locales doivent être préservées.
- Aucun secret, transcript, cache ou donnée privée ne peut entrer dans le checkout sparse public.

## Dependencies

- Runtime: Git avec sparse checkout, bash, curl; plugin Codex pour le parcours plugin. Fresh-docs checked: la documentation officielle Git (2.55.0, consultée le 2026-08-05) confirme `git sparse-checkout set` en mode cone pour sélectionner des répertoires et déconseille les motifs non-cone; Git local 2.43.0 expose `set`.
- Document contracts: contrat de packaging, contrat de dépôt privé, sync de skills et guides OpenCode/KiloCode.
- Metadata gaps: None; l'opératrice a confirmé que le dépôt privé est déjà disponible pour la CLI.

## Invariants

- Une installation runtime par défaut ne contient pas `skills/`, `shipglows_data/`, `.opencode/` ou `.agents/skills/`.
- Une installation Codex n'installe pas de liens de skills en doublon.
- Une installation corpus inclut uniquement le corpus public nécessaire et conserve les données privées hors dépôt.
- Le choix de surface est observable dans la sortie et le rapport d'installation.
- Un checkout existant non Git n'est jamais remplacé.
- Les liens de skills existants restent inchangés tant que le corpus n'est pas explicitement demandé.

## Links & Consequences

- Upstream systems: dépôt public CommandGlows, plugin marketplace, installateur Unix, CLI et scripts de sync.
- Downstream systems: `~/.codex`, `~/.claude`, OpenCode/KiloCode, répertoires runtime et checkouts sparse.
- Cross-cutting checks: réseau, droits filesystem, sécurité des données, réversibilité, documentation et non-régression des installations serveur.

## Documentation Coherence

- Le README distingue clairement runtime, plugin Codex et corpus de skills.
- Le contrat de packaging décrit le bootstrap corpus comme optionnel, non comme dépendance du runtime.
- Les guides OpenCode et KiloCode expliquent quand le corpus public est requis.
- Les exemples d'environnement et la sortie de l'installateur utilisent `commandglows/shipglows`.

## Edge Cases

- Un utilisateur a déjà un clone complet avec des modifications locales.
- Un utilisateur runtime demande ultérieurement le corpus de skills.
- Un utilisateur a déjà des liens Codex/Claude vers une ancienne installation.
- Git sparse checkout est indisponible ou échoue après création du checkout.
- OpenCode/KiloCode est installé mais le corpus n'a pas été demandé.
- Le plugin Codex est installé mais la CLI runtime ne l'est pas, ou inversement.

## Implementation Tasks

- [x] Task 1: Ajouter le contrat de surfaces runtime, plugin et corpus au bootstrap.
  - File: `install-shipglows.sh`
  - Action: parser une option/environnement de surface, sélectionner les chemins sparse nécessaires et rendre le défaut runtime explicite.
  - User story link: éviter le clone implicite des skills.
  - Depends on: None
  - Validate with: tests shell de sélection de mode et inspection de la liste sparse.
  - Notes: le corpus reste une opt-in explicite.

- [x] Task 2: Découpler la synchronisation des skills de la couche IA générale.
  - File: `cli/install.sh`
  - Action: n'appeler `configure_skills` que lorsque le corpus est explicitement demandé; afficher la disposition installée.
  - User story link: éviter les copies Codex/Claude en doublon.
  - Depends on: Task 1
  - Validate with: tests de script et sync runtime ciblée.
  - Notes: les paramètres IA/MCP restent indépendants des skills.

- [x] Task 3: Ajouter les tests d'installation runtime/corpus.
  - File: `tests/install/bootstrap-mode-selection.sh` et test ciblé additionnel si nécessaire.
  - Action: prouver la sélection runtime par défaut, corpus opt-in, traitement d'un checkout existant et absence de fallback clone complet.
  - User story link: rendre la frontière durable.
  - Depends on: Tasks 1–2
  - Validate with: exécution des tests shell isolés.
  - Notes: ne lance pas de clone réseau réel dans les tests unitaires.

- [x] Task 4: Aligner la documentation publique et runtime.
  - File: `README.md`, `shipglows_data/technical/codex-plugin-packaging.md`, guides OpenCode/KiloCode.
  - Action: publier les trois chemins et leurs limites sans demander aux utilisateurs Codex de cloner le corpus.
  - User story link: rendre le bon choix compréhensible avant installation.
  - Depends on: Tasks 1–3
  - Validate with: scans de cohérence, metadata lint et build de site si une page site est impactée.
  - Notes: ne pas modifier le dépôt privé.

## Acceptance Criteria

- [ ] AC 1: Given no distribution surface is supplied, when the bootstrap runs, then it checks out only runtime paths and reports `runtime`.
- [ ] AC 2: Given `corpus` is explicitly selected, when the bootstrap runs, then the public skills and compatible shims are available without private data.
- [ ] AC 3: Given the AI runtime is enabled without the corpus, when user setup runs, then it does not create or modify Claude/Codex skill links.
- [ ] AC 4: Given Codex users follow public onboarding, when they install ShipGlows, then the documented default is the plugin rather than a repository clone.
- [ ] AC 5: Given OpenCode or KiloCode needs repository-local skills, when the corpus path is selected, then the relevant public shim and skills are present.
- [ ] AC 6: Given an existing Git checkout has local changes, when the installer reruns, then it preserves the checkout and explains any surface upgrade instead of overwriting it.
- [ ] AC 7: Given a bootstrap cannot create the requested sparse checkout, when it fails, then it exits with a clear recovery message and does not fall back silently to a full clone.

## Test Strategy

- Unit: shell parsing and sparse path selection.
- Integration: isolated fake Git fixture for runtime and corpus paths; targeted skill-sync checks.
- Manual: verify a Codex plugin-only journey without checkout and an OpenCode/KiloCode corpus journey from a clean temporary target.

## Test Contract

### Surface

- Stack/surface: Bash installers, Git sparse checkout, Codex plugin, compatible skill shims.
- Primary proof mode: mixed.
- Proof order (if applicable): automated, contract/integration, manual.

### Manual checklist

- Needed: yes
- Checklist path: `shipglows_data/workflow/test-checklists/runtime-installer-and-skill-distribution-separation.md`
- Required scenario coverage: runtime default, corpus opt-in, Codex plugin-only, OpenCode/KiloCode corpus, existing modified checkout.
- Exception with proof: external plugin installation remains opt-in and is validated structurally rather than mutating the operator's active Codex config.

### Required evidence stack

- Automated / unit / integration checks: installer shell tests, `bash -n`, plugin validation, runtime sync checks and `git diff --check`.
- Agent-run browser proof: none unless public site install pages change.
- Auth/session proof (`sg-auth-debug`): none.
- Contract/integration proof: sparse-checkout path list and user skill-link inspection.
- Provider evidence: GitHub repository only; no external publication mutation required.
- Device-native proof: none.

## Risks

- Security impact: yes; an incorrect surface can expose private content or modify user skill links unexpectedly. Mitigate with public path allowlists, explicit opt-in, no silent fallback and clean-path tests.
- Product/data/performance risk: a sparse checkout missing runtime assets can break installation; mitigate with exact path tests and safe existing-checkout behavior.

## Execution Notes

- Read first: installer scripts, sync helper, plugin packaging contract, OpenCode/KiloCode guides and existing installation tests.
- Validate with: focused shell tests, plugin validation, sparse path proof, metadata lint, and excellence verification.
- Stop conditions: unknown required runtime path, request to overwrite a non-Git checkout, data-private boundary contradiction, or a required external installation action without approval.

## Open Questions

None. The operator approved runtime/plugin/corpus separation and confirmed the private repository already covers CLI private-data needs.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-05 17:10:00 UTC | 100-sg-spec | GPT-5 Codex | Created the dedicated installer/runtime and skills-distribution separation contract. | draft | /101-sg-ready runtime installer and skill distribution separation |
| 2026-08-05 17:20:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed structure, scope, security boundary, Git sparse-checkout evidence, task ordering and proof contract. | ready | /102-sg-start runtime installer and skill distribution separation |
| 2026-08-05 17:45:00 UTC | 102-sg-start | GPT-5 Codex | Implemented explicit runtime, corpus and Codex-plugin surfaces; gated skill synchronization; added sparse-contract tests and aligned documentation. | implemented | /103-sg-verify mode=excellence runtime installer and skill distribution separation |
| 2026-08-05 18:05:00 UTC | 103-sg-verify | GPT-5 Codex | Excellence verification: 43 installer regressions, syntax, plugin manifest, metadata and public skill-sync checks pass; all four disposable runtime/manual scenarios pass. The separately deployed public website bootstrap is still stale and needs its own release. | partial | Synchronize the website bootstrap and verify the public endpoint before advertising it. |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented.
- `103-sg-verify`: partial; local, structural and isolated-runtime proof pass; public website endpoint remains stale.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: synchronize the public website bootstrap, then verify its served endpoint before advertising it.
