# CLAUDE.md

Contraintes non déductibles du code. La carte d'entrée canonique est `AGENT.md` :
la lire avant toute tâche non triviale.

## Poste et exécution

- L'opératrice travaille sur Windows (PowerShell), racine
  `C:\Users\Diane\ShipGlows\shipglows`, canal `linked`. Avant tout travail
  dépendant d'un serveur ou d'un outil, lire `%USERPROFILE%\.shipglows\environment.md`.
- Serveurs et applications : uniquement via les sessions gérées `shipglows-dev` / `s`.
  Avant de toucher au DevServer Windows, lire
  `shipglows_data/technical/operator-guides/windows-devserver.md`.
- Ce projet s'exécute sans Doppler (`Doppler NONE`, voir `AGENT.md`).
- Les scripts Bash `cli/*.sh` ciblent les hôtes Linux (Flox/PM2/Caddy) ; ils ne
  décrivent pas le poste de l'opératrice.

## Avant de modifier

- `cli/lib.sh` ou `cli/*.sh` : lire `shipglows_data/technical/context-function-tree.md`
  puis `shipglows_data/technical/context.md` (invariants cache PM2, registre, sourcing
  sans sous-processus).
- Du code, un outil, une skill ou un template : lire
  `shipglows_data/technical/code-docs-map.md` ; il désigne la doc primaire et les
  vérifications ciblées à lancer.
- Une skill ou une référence chargée par les agents : lire
  `skills/references/skill-context-budget.md` et lancer
  `python tools/skill_budget_audit.py --skills-root skills`.
- Le bootstrap d'installation : lire `shipglows_data/technical/bootstrap-matrix.md`.
