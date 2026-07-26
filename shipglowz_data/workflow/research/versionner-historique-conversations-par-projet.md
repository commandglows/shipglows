---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlowz
created: "2026-07-26"
updated: "2026-07-26"
status: reviewed
source_skill: 203-sg-research
scope: "Versionner et conserver les historiques Codex, Claude Code et agents similaires par projet"
owner: unknown
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: ["~/.claude", "~/.codex", "ShipGlowz project lifecycle", "Git"]
depends_on: []
supersedes: []
evidence:
  - "Claude Code Sessions documentation"
  - "OpenAI Codex discussions and issues on CODEX_HOME and local sessions"
  - "Open-source Claude Code history browsers"
next_step: "Prototyper un wrapper ShipGlowz avec identifiant de projet stable et export hors secrets"
---

# Recherche : historique des conversations par projet

## Résumé

Oui, c'est techniquement possible. Claude Code et Codex écrivent déjà leurs sessions localement en JSONL ; le point fragile est que l'association à un projet dépend du répertoire de travail et que les variables de configuration déplacent souvent tout le profil, pas seulement l'historique.

La solution recommandée est un archivage ShipGlowz par identifiant de projet stable : conserver les fichiers natifs dans un stockage privé hors dépôt, puis versionner dans Git un export nettoyé et éventuellement chiffré. Les liens symboliques peuvent servir de compatibilité, mais ne devraient pas être le mécanisme principal.

## Ce que font les outils

- **Claude Code** lie une session au répertoire de projet et stocke les transcripts sous `~/.claude/projects/<project>/<session-id>.jsonl`. `CLAUDE_CONFIG_DIR` permet de déplacer la racine de configuration. Les fichiers locaux sont supprimés après 30 jours par défaut, réglage modifiable via `cleanupPeriodDays`. [Documentation officielle des sessions Claude Code](https://code.claude.com/docs/en/sessions)
- **Codex** stocke les sessions CLI sous `$CODEX_HOME/sessions/YYYY/MM/DD/rollout-*.jsonl`, avec d'autres données d'état dans le même répertoire. Un mainteneur OpenAI confirme que `CODEX_HOME` est le mécanisme disponible pour déplacer ce profil. [Discussion OpenAI sur l'historique local par projet](https://github.com/openai/codex/discussions/23680), [demande de configuration projet](https://github.com/openai/codex/issues/18334)
- Le Codex Desktop et le CLI ne donnent pas toujours une vue unifiée de toutes les sessions présentes sur disque : plusieurs tickets signalent des divergences entre transcripts, base SQLite et affichage de l'application. [Issue Codex #24197](https://github.com/openai/codex/issues/24197), [Issue Codex #20864](https://github.com/openai/codex/issues/20864)

## Ce que d'autres ont déjà fait

Il existe déjà plusieurs approches communautaires :

- `claude-history`, un outil open source qui recherche, affiche, exporte et reprend des transcripts Claude Code locaux. [Dépôt GitHub](https://github.com/raine/claude-history)
- Des scripts/skills qui transforment les JSONL Claude Code en Markdown indexé par projet et par session. [Exemple de skill `/convos`](https://gist.github.com/tomfuertes/0a1956a12491312436dfbd89f0067bb9)
- Des wrappers Codex qui changent `CODEX_HOME` selon un profil ou un projet. L'approche fonctionne, mais elle isole aussi l'authentification, les logs, la configuration, les caches et l'état SQLite. [Discussion OpenAI sur Codex App et historique local](https://github.com/openai/codex/discussions/23680)

Je n'ai pas trouvé de solution officielle commune à Codex et Claude Code qui fournisse directement un historique Git versionné par projet.

## Évaluation des options

### 1. Symlinks seuls

Possible pour déplacer `~/.claude/projects` ou `~/.codex/sessions` vers un volume persistant. Ce n'est pas suffisant pour résoudre l'identité d'un projet recréé ailleurs, et cela reste dépendant d'implémentations internes susceptibles de changer. Pour Codex, déplacer seulement `sessions` peut aussi désynchroniser les index et bases d'état.

### 2. Un profil complet par projet

Lancer les outils avec un `CLAUDE_CONFIG_DIR` ou un `CODEX_HOME` calculé à partir d'un identifiant ShipGlowz stable. C'est la solution la plus directe pour conserver les historiques quand les dossiers source sont supprimés, mais il faut isoler soigneusement les secrets et accepter que chaque projet possède un état plus large que ses conversations.

### 3. Archivage et export par projet — recommandée

ShipGlowz peut créer un identifiant immuable, par exemple `project_id`, indépendant du chemin courant. Un wrapper :

1. résout le projet courant vers cet identifiant ;
2. lance Claude/Codex avec leur stockage local normal ou dédié ;
3. copie les nouvelles sessions vers un coffre privé `~/.local/share/shipglowz/conversations/<project_id>/` ;
4. génère un export Markdown/JSON normalisé, avec provider, date, session, branche et chemin historique ;
5. versionne cet export dans un dépôt privé d'archives, ou dans un dossier du projet si l'utilisateur l'autorise explicitement.

Cette approche permet de retrouver l'historique même après suppression/recréation du projet et d'ajouter ensuite d'autres agents sans dépendre de leur structure interne.

## Recommandation pour ShipGlowz

Construire un petit sous-système `agent-history` plutôt qu'un simple ensemble de symlinks :

- registre `project_id -> nom, chemins actuels, alias historiques` ;
- wrapper `sf codex` / `sf claude` qui injecte l'identité stable ;
- collecteur idempotent et en lecture seule des JSONL ;
- index SQLite local pour recherche rapide ;
- exports Markdown lisibles et JSON bruts conservés hors dépôt ;
- stockage Git privé facultatif, avec chiffrement recommandé ;
- commande de restauration/recherche après suppression d'un projet ;
- rétention configurable, notamment pour neutraliser ou allonger la purge Claude Code de 30 jours.

## Risques à traiter

Les transcripts peuvent contenir des secrets, tokens, chemins privés, variables d'environnement, résultats d'outils, données clients et code propriétaire. Il ne faut donc pas faire un `git add` automatique des JSONL natifs. Les secrets d'authentification doivent rester hors de l'archive, et l'export versionné doit proposer une redaction avant commit.

Le stockage partagé entre plusieurs processus doit aussi éviter les écritures concurrentes et les symlinks cassés. Pour Codex en particulier, les discussions publiques signalent que l'état de session, l'index et les fichiers de rollout sont liés ; il faut donc archiver le profil de manière cohérente ou reconstruire un index séparé plutôt que déplacer arbitrairement un seul sous-dossier.

## Conclusion

Le besoin est réel et déjà traité partiellement par la communauté. Le meilleur compromis pour ShipGlowz est : identifiant de projet stable + stockage d'archive privé + index/export normalisé + Git/chiffrement en option. Les symlinks peuvent être utilisés dans un prototype de transition, mais l'archive doit rester indépendante des chemins absolus et des formats internes de Codex/Claude.
