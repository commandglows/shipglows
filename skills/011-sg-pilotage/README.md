# 011-sg-pilotage

> Piloter le travail et les conversations Codex depuis une seule skill, sans mélanger les actions.

## Ce que fait la skill

`011-sg-pilotage` remplace les anciennes entrées séparées de gestion des tâches, du backlog, des priorités et des revues. Elle expose cinq modes explicites et ne charge que le playbook du mode choisi :

- `tasks` maintient le registre d’exécution local et propose la prochaine étape issue du tracker ;
- `backlog` capture, reporte, nettoie ou promeut le travail futur ;
- `priorities` classe le travail actif par impact, effort, blocages, dépendances et risque ;
- `review` reconstruit une période de travail à partir de preuves et distingue l’activité, l’implémentation, la vérification et les hypothèses ;
- `sessions` trie les conversations Codex du dépôt, renomme uniquement la conversation courante ou prépare un nettoyage prudent des anciennes sessions terminées.

## Utilisation

```text
$011-sg-pilotage tasks [focus]
$011-sg-pilotage backlog [add <idée>|defer [élément]|review|clean]
$011-sg-pilotage priorities [impact|effort|blockers|high-roi|quick-wins]
$011-sg-pilotage review [daily|weekly|sprint|release]
$011-sg-pilotage sessions [projet-ou-cwd]
$011-sg-pilotage sessions rename <todo|doing|in_progress|blocked|done>
$011-sg-pilotage sessions prune [cwd]
```

Sans mode clair, avec un mode inconnu ou avec plusieurs actions mélangées, la skill demande de choisir entre les cinq modes et ne modifie rien. `help` n’est pas un sixième mode.

## Sécurité des sessions

Les opérations `sessions` restent limitées au `cwd` absolu exact. `sessions rename` exige un statut valide avant toute lecture ou mutation et ne cible que la conversation courante. `sessions prune` commence toujours par une simulation, exclut le thread courant et exige la confirmation exacte du `cwd` avant application. Les helpers gouvernés restent propriétaires des écritures SQLite et suppressions natives.

## Limites et skills voisines

- `700-sg-explore` clarifie une idée encore floue.
- `704-sg-model` choisit le modèle ou la politique de raisonnement.
- `705-sg-conversation-audit` audite la qualité de plusieurs conversations.
- `706-continue` poursuit le chantier courant ; `102-sg-start` exécute un travail prêt.
- `308-sg-status` fournit un état en lecture seule.
- `707-name` gère l’étiquette de statusline Claude.
- `103-sg-verify` vérifie les preuves ; `104-sg-end` clôt le travail.

La skill de pilotage peut orienter vers ces propriétaires, mais ne les remplace pas.
