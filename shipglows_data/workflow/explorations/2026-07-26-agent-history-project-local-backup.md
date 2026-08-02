---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-26"
updated: "2026-07-26"
status: draft
source_skill: 700-sg-explore
scope: "Sauvegarde projet-locale des conversations Codex et Claude Code"
owner: unknown
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/lib.sh
  - cli/config.sh
  - shipglows_init_project
  - deploy_github_project
  - env_remove
  - Claude Code
  - Codex CLI
evidence:
  - "cli/lib.sh: shipglows_init_project prépare déjà des fichiers projet-locaux après clone"
  - "cli/lib.sh: deploy_github_project clone puis initialise et démarre le projet"
  - "cli/lib.sh: env_remove est le point de suppression du répertoire projet"
  - "Documentation officielle Claude Code sur les transcripts JSONL et CLAUDE_CONFIG_DIR"
  - "Discussions et issues OpenAI sur CODEX_HOME et les sessions Codex"
depends_on: []
supersedes: []
next_step: "/100-sg-spec agent-history project-local backup"
---

# Exploration : sauvegarder les conversations dans le projet

## Starting Question

Comment conserver toutes les conversations Codex, Claude Code et agents similaires dans le dépôt du projet, afin qu'elles survivent à la suppression du serveur qui héberge le clone local ?

## Context Read

- `cli/lib.sh` — contient le cycle de vie `deploy_github_project`, `shipglows_init_project` et `env_remove`.
- `cli/config.sh` — centralise les réglages et constitue le bon emplacement pour le chemin et le mode de sauvegarde.
- `shipglows_data/technical/context.md` — confirme que ShipGlows est propriétaire du cycle de vie des environnements et du launcher Codex.
- `shipglows_data/technical/runtime-cli.md` — indique les hotspots et les invariants de la CLI.

## Internet Research

- [Manage sessions - Claude Code Docs](https://code.claude.com/docs/en/sessions) — consulté le 2026-07-26 — emplacement JSONL, association au répertoire, `CLAUDE_CONFIG_DIR` et rétention.
- [Codex App: keep conversation history within project directory](https://github.com/openai/codex/discussions/23680) — consulté le 2026-07-26 — `CODEX_HOME` comme solution actuelle, avec déplacement de l'état complet.
- [Make the location of project-scoped `.codex` directory customizable](https://github.com/openai/codex/issues/18334) — consulté le 2026-07-26 — distinction entre configuration projet et données utilisateur sensibles.
- [claude-history](https://github.com/raine/claude-history) — consulté le 2026-07-26 — preuve d'un écosystème communautaire de lecture/export des transcripts.

## Problem Framing

Le serveur est un clone de travail temporaire. La source de survie est le dépôt GitHub/GitLab du projet, pas le disque serveur. Les conversations natives sont cependant stockées dans les répertoires utilisateur de Claude/Codex et peuvent être purgées ou perdre leur rattachement si le clone est recréé à un autre chemin.

Le besoin est donc une **copie projet-locale de toutes les sessions**, synchronisée avec le dépôt distant. Ce n'est pas une sauvegarde centrale ShipGlows et ce n'est pas seulement un symlink.

## Option Space

### Option A: collecteur ShipGlows projet-local

- Summary: `shipglows_init_project` crée `.agent-history/`; un collecteur copie les nouvelles sessions depuis les emplacements natifs vers ce dossier.
- Pros: ne déplace pas l'état interne des agents; fonctionne avec plusieurs providers; secrets séparables; contrôle central dans la CLI.
- Cons: nécessite une synchronisation périodique ou un hook; une session active peut perdre ses dernières lignes si le serveur disparaît brutalement avant la copie.

### Option B: profils natifs directement dans le projet

- Summary: lancer Claude avec `CLAUDE_CONFIG_DIR` et Codex avec `CODEX_HOME` sous `.agent-history/`, en gardant l'authentification hors Git.
- Pros: les écritures arrivent immédiatement dans le projet; récupération native potentiellement plus directe.
- Cons: ces variables déplacent aussi une partie de la configuration, de l'état, des index, des logs et des caches; Codex relie plusieurs fichiers et bases; risque élevé de committer un secret ou un état instable.

### Option C: symlinks des répertoires natifs

- Summary: faire pointer `~/.claude/projects/...` et/ou `~/.codex/sessions` vers `.agent-history/`.
- Pros: peu de code initial.
- Cons: dépend des chemins encodés par les agents; risque de casser les index; difficile à rendre multi-provider et idempotent; ne crée pas de commit/push Git.

## Comparison

| Critère | Collecteur | Profils natifs | Symlinks |
| --- | --- | --- | --- |
| Toutes les conversations | Oui après sync | Oui si profil complet | Partiel/dépendant du format |
| Survit au serveur supprimé | Oui si push Git réussi | Oui si push Git réussi | Oui seulement si correctement committé |
| Risque secrets | Contrôlable | Élevé | Élevé |
| Fragilité aux mises à jour agents | Faible à moyenne | Moyenne à élevée | Élevée |
| Intégration CLI | `init`, `env_start`, `env_remove` | wrapper de lancement | gestion de liens |

## Emerging Recommendation

Choisir l'Option A avec un mode de synchronisation projet-local :

```text
clone GitHub
  -> shipglows_init_project
      -> créer .agent-history/
      -> créer manifest provider/projet
  -> ouvrir Codex/Claude
      -> sync périodique des sessions
      -> git add/commit/push contrôlé
  -> env_remove
      -> sync final obligatoire
      -> commit/push final
      -> suppression du clone
```

Le dossier pourrait contenir les JSONL bruts sous `.agent-history/raw/<provider>/` et un index léger. Les fichiers d'authentification, cookies, clés et credentials doivent être exclus par conception. Le push automatique doit être configurable et échouer de manière visible s'il ne peut pas confirmer la sauvegarde distante.

Le collecteur devrait associer les sessions au projet via le chemin courant, le dépôt Git distant et un identifiant enregistré dans `.agent-history/manifest.json`, afin de retrouver les anciens transcripts après un nouveau clone.

### Interaction avec `309-sg-tasks sessions prune`

La skill `309-sg-tasks` confirme que `sessions prune` est un outil de
nettoyage de l'index et du stockage des sessions Codex, pas un mécanisme de
sauvegarde. Il ne cible que les sessions `DONE - ...` inactives depuis plus de
30 jours, commence par un aperçu, exige le projet absolu exact lors de
l'application, exclut la conversation courante et ne modifie pas le tracker.

Cela donne une règle d'intégration importante : le prune doit être exécuté
après la collecte projet-locale, jamais avant. Le flux CLI pourrait donc être :

```text
collect native sessions -> archive .agent-history/ -> push confirmé
  -> sessions prune éventuel
```

La sauvegarde ne doit pas dépendre des titres `DONE - ...`, ni de `TASKS.md` :
elle doit conserver toutes les conversations collectées, y compris celles
encore ouvertes ou non renommées. `sessions prune` devient ainsi un
consommateur du mécanisme de sauvegarde, avec un garde-fou empêchant de
supprimer une session locale tant que sa copie projet et son push distant ne
sont pas confirmés.

## Non-Decisions

- Le format final des exports lisibles n'est pas décidé.
- Le push à chaque message, à intervalle fixe ou seulement aux événements CLI n'est pas décidé.
- Le point exact d'appel de `sessions prune` dans le cycle CLI n'est pas décidé; il doit être postérieur à une collecte et à une confirmation de push.
- Le choix utilisateur est désormais une branche Git dédiée dans le dépôt du projet; la CLI sera responsable de la restaurer au déploiement, sans mélanger les transcripts avec la branche applicative.
- La politique de rétention locale des transcripts natifs n'est pas décidée.
- L'intégration exacte avec les autres agents n'est pas décidée.

## Rejected Paths

- Stockage uniquement dans `~/.local/share/shipglows` — ne survit pas à la suppression du serveur.
- Commit des profils complets Codex/Claude — mélange probable de sessions, logs, index et secrets.
- Symlink seul — trop dépendant des chemins et structures internes des providers.

## Risks And Unknowns

- Les transcripts peuvent contenir des secrets, du code privé ou des données client ; une redaction automatique complète est difficile.
- Un commit/push automatique peut interrompre ou polluer le travail Git du projet ; il faut une branche, un commit conventionnel ou une politique explicite.
- Les JSONL peuvent être volumineux et augmenter rapidement la taille du dépôt.
- La suppression doit refuser de continuer si la sync finale et le push n'ont pas été confirmés, sauf option forcée explicitement.
- Les sessions ouvertes doivent être copiées sans lire un fichier partiellement écrit de manière incohérente.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none persisted
- Redactions applied: none required
- Notes: l'exploration décrit les risques sans conserver de tokens, cookies, chemins privés de transcripts ou données client.

## Decision Inputs For Spec

- User story seed: « En supprimant un serveur, je veux pouvoir cloner le projet et retrouver toutes les conversations des agents. »
- Scope in seed: intégration CLI au clone/init/start/remove; copie projet-locale; validation du push distant; Codex et Claude en premier.
- Scope out seed: interface web de recherche; synchronisation multi-machines temps réel; migration rétroactive complète avant preuve du flux neuf.
- Invariants/constraints seed: ne jamais committer auth/cookies; sync finale avant suppression; pas de build ou changement runtime nécessaire; comportement idempotent; sauvegarde sur une branche dédiée restaurée par la CLI.
- Validation seed: tests shell sur manifest, collecte, exclusion secrets, dry-run, échec de push, suppression protégée; test réel clone -> session -> push -> suppression -> reclone.

## Handoff

- Recommended next command: `/100-sg-spec agent-history project-local backup`
- Why this next step: la direction est suffisamment claire pour formaliser le contrat, les choix de synchronisation et les garde-fous avant modification de `cli/lib.sh`.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-07-26 | Sauvegarde des conversations dans le projet | Lecture du cycle de vie CLI, des réglages et recherche des contrats provider | Point d'intégration identifié dans init/sync/remove; collecteur recommandé | Formaliser une spec puis implémenter avec dry-run et preuve de restauration |
