---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-04-25"
updated: "2026-04-29"
status: reviewed
source_skill: sg-spec
scope: install
owner: Diane
user_story: "En tant qu'utilisateur ShipGlows sur Codex CLI, je veux voir le nom de conversation et l'état du contexte directement dans l'interface, afin de garder le bon fil de travail et d'anticiper la compaction sans quitter mon flux."
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - install.sh
  - README.md
  - CHANGELOG.md
depends_on: []
supersedes: []
evidence:
  - "Spec migrated after implementation during ShipGlows metadata adoption"
next_step: "/sg-verify Codex TUI defaults"
---

Title
Codex TUI: afficher le nom de conversation et le contexte dans ShipGlows

Status
reviewed

User Story
En tant qu'utilisateur ShipGlows sur Codex CLI, je veux voir le nom de conversation et l'état du contexte directement dans l'interface, afin de garder le bon fil de travail et d'anticiper la compaction sans quitter mon flux.

Problem
ShipGlows configure aujourd'hui la status line pour Claude Code via `~/.claude/settings.json`, mais n'applique pas de configuration équivalente pour Codex TUI. Résultat: le repère de conversation et la visibilité du contexte ne sont pas standardisés après installation.

Solution
Étendre l'installation ShipGlows pour appliquer une configuration Codex TUI idempotente et non destructive, avec:
- `tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]`.
- `tui.terminal_title = ["spinner", "thread", "project"]`.
- une documentation claire des réglages et du fallback via `/statusline` et `/title`.

Scope In
- Ajout d'une étape de configuration Codex TUI dans `install.sh`.
- Mise à jour de la documentation utilisateur ShipGlows.
- Validation bash syntax + vérification de comportement idempotent sur un `config.toml` existant.

Scope Out
- Refonte visuelle complète du TUI Codex.
- Développement d'un renderer custom de status line (non supporté comme script arbitraire côté Codex).
- Modification des scripts `.claude/statusline-*`.
- Support de versions Codex legacy qui ne supportent pas `/statusline` ou `/title`.

Constraints
- Conserver le comportement existant de `configure_statusline` pour Claude.
- Ne pas casser un `~/.codex/config.toml` existant.
- Garantir une écriture idempotente (réinstallation sans duplication).
- Respecter les conventions shell du repo (bash + fonctions petites + opérations sûres).
- Éviter toute dépendance nouvelle non nécessaire.

Dependencies
- Bash
- Outils shell de base (`grep`, `sed`, `awk`, `mv`, `cp`, `mkdir`)
- `jq` (déjà utilisé côté `.claude/settings.json`, pas requis pour TOML Codex)
- Codex CLI avec support `tui.status_line` et `tui.terminal_title`

Invariants
- `install.sh` reste exécutable de bout en bout pour root + utilisateurs `/home/*`.
- Les symlinks skills `.codex/skills` existants restent inchangés.
- La configuration Claude (`.claude/settings.json`) reste configurée comme aujourd'hui.
- Aucune suppression destructive de fichiers utilisateur.

Links & Consequences
- `install.sh` est l'entrypoint d'installation: toute modification impacte la configuration initiale de tous les utilisateurs.
- L'écriture de `~/.codex/config.toml` influence le CLI, l'IDE extension et le desktop app (config partagée).
- Un mauvais merge TOML peut empêcher Codex de démarrer correctement; il faut une stratégie d'upsert robuste.
- La doc README doit rester alignée avec le comportement réel de l'installateur.

Edge Cases
- `~/.codex/config.toml` absent.
- `~/.codex/config.toml` présent avec un bloc `[tui]` déjà défini.
- Clés déjà présentes en forme pointée (`tui.status_line = ...`) ou tabulaire (`[tui]` + `status_line = ...`).
- Réinstallation multiple (pas de duplication de lignes ni corruption).
- Utilisateur sans `jq` (la partie Codex doit continuer de fonctionner même si la partie Claude ne peut pas être patchée automatiquement).
- Items indisponibles selon version Codex: fallback documenté vers `/statusline` et `/title`.

Implementation Tasks
- [ ] Tâche 1 : Ajouter une fonction dédiée de configuration Codex TUI
  - Fichier : `install.sh`
  - Action : Créer `configure_codex_tui()` appelée depuis `setup_user()`, qui prépare `~/.codex/config.toml` si absent puis applique les clés `tui.status_line` et `tui.terminal_title`.
  - User story link : Garantit l'affichage du contexte et du nom de conversation sans setup manuel post-install.
  - Depends on : aucune
  - Validate with : `bash -n install.sh`
  - Notes : Implémenter en mode idempotent avec bloc géré ShipGlows et remplacement sécurisé.

- [ ] Tâche 2 : Définir une stratégie d'upsert TOML non destructive
  - Fichier : `install.sh`
  - Action : Ajouter une logique qui évite les duplications et ne casse pas la config existante: suppression/refresh d'un bloc géré ShipGlows, sans toucher aux autres sections utilisateur.
  - User story link : Évite de perdre la config personnelle tout en imposant des defaults utiles.
  - Depends on : Tâche 1
  - Validate with : exécution de l'installateur deux fois sur un HOME de test et diff stable
  - Notes : Préférer un bloc explicitement délimité `# >>> shipglows codex tui >>>` / `# <<< shipglows codex tui <<<`.

- [ ] Tâche 3 : Choisir et fixer les items par défaut
  - Fichier : `install.sh`
  - Action : Définir les listes par défaut dans le bloc géré: `tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]` et `tui.terminal_title = ["spinner", "thread", "project"]`.
  - User story link : Rend immédiatement visibles les signaux demandés par l'utilisateur.
  - Depends on : Tâche 2
  - Validate with : inspection du `~/.codex/config.toml` généré et vérification en session Codex
  - Notes : Si `thread` n'est pas disponible sur une version Codex donnée, fallback documenté: configuration interactive via `/title`.

- [ ] Tâche 4 : Intégrer la fonction dans le flux utilisateur global
  - Fichier : `install.sh`
  - Action : Appeler `configure_codex_tui` dans `setup_user()` avec la même couverture que les autres steps (root + users de `/home`).
  - User story link : Applique la configuration à tous les comptes dès l'installation.
  - Depends on : Tâche 1
  - Validate with : run d'installation sur environnement de test + vérification des homes configurés
  - Notes : Conserver ordre logique et ownership fixes déjà en place.

- [ ] Tâche 5 : Documenter le comportement et le fallback utilisateur
  - Fichier : `README.md`
  - Action : Ajouter une section “Codex TUI defaults” décrivant ce que ShipGlows configure automatiquement et comment ajuster via `/statusline` et `/title`.
  - User story link : Permet à l'utilisateur de comprendre et d'ajuster rapidement.
  - Depends on : Tâches 3 et 4
  - Validate with : relecture doc + cohérence avec le comportement réel de `install.sh`
  - Notes : Mentionner explicitement que Codex ne supporte pas une status line scriptable arbitraire comme Claude.

- [ ] Tâche 6 : Ajouter une note de maintenance dans le changelog
  - Fichier : `CHANGELOG.md`
  - Action : Ajouter une entrée Unreleased décrivant la nouvelle config Codex TUI auto-appliquée.
  - User story link : Traçabilité du changement pour les futures sessions.
  - Depends on : Tâches 4 et 5
  - Validate with : section Unreleased cohérente et concise
  - Notes : Format Keep a Changelog déjà utilisé dans le repo.

Acceptance Criteria
- [ ] CA 1 : Given une installation ShipGlows neuve, when l'installateur termine, then `~/.codex/config.toml` contient `tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]` et `tui.terminal_title = ["spinner", "thread", "project"]`.
- [ ] CA 2 : Given une config Codex existante, when l'installateur est relancé, then la config utilisateur hors bloc ShipGlows est préservée et aucun doublon n'est créé.
- [ ] CA 3 : Given un utilisateur multi-compte (root + users `/home`), when `install.sh` s'exécute, then chaque home reçoit la config Codex TUI.
- [ ] CA 4 : Given la doc README, when un utilisateur lit la section Codex, then il comprend les defaults et la procédure d'ajustement via `/statusline` et `/title`.
- [ ] CA 5 : Given un contexte où les identifiants varient selon version Codex, when l'utilisateur ne voit pas l'item attendu, then la doc fournit un fallback non ambigu pour corriger en interactif.

Test Strategy
- Unit/syntax:
  - `bash -n install.sh`
- Integration (local test HOME):
  - exécuter `install.sh` dans un environnement de test utilisateur
  - vérifier création/MAJ de `~/.codex/config.toml`
  - relancer `install.sh` et confirmer idempotence (pas de duplication)
- Manual:
  - lancer Codex CLI
  - exécuter `/status` pour confirmer contexte
  - vérifier footer + titre terminal en session active

Risks
- Risque TOML: duplication de clés ou format invalide peut dégrader le démarrage Codex.
- Risque compatibilité: certains identifiants d'items peuvent changer selon versions.
- Risque UX: imposer des defaults peut surprendre un utilisateur ayant déjà customisé son TUI.
- Impact sécurité: none (changement de config locale uniquement), mitigated by écriture non destructive et ownership correct.

Execution Notes
- Lire d'abord : `install.sh`
- Lire ensuite : `README.md`
- Vérifier cohérence historique : `CHANGELOG.md`
- Référence comportement actuel Claude : `.claude/statusline-starship.sh`
- Ordre recommandé :
  - implémenter `configure_codex_tui`
  - brancher dans `setup_user`
  - valider idempotence
  - mettre à jour README + CHANGELOG
- Commandes de validation minimales :
  - `bash -n install.sh`
  - `rg -n "configure_codex_tui|tui\\.status_line|tui\\.terminal_title" install.sh`
- Stop conditions / reroute :
  - si gestion fiable de TOML devient trop risquée en bash pur, rerouter vers approche conservative (doc + fallback `/statusline`/`/title`) au lieu de merger agressivement la config.

Open Questions
- none
