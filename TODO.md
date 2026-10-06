https://github.com/orgs/community/discussions/200164
https://github.com/better-auth/better-auth
https://semver.org/
https://fakerjs.dev/
https://github.com/harryvondiesel-web/5-persona-advisory-board
https://github.com/millwright-labs/minto-pyramid-skill
https://github.com/cathrynlavery/diagram-design
gv[g](https://trendshift.io/)
https://github.com/vikd1000/investment-council
https://github.com/cursor/plugins/tree/main/pstack
https://img2threejs.i/

**Par rapport à ShipGlows, je les classerais comme des briques techniques complémentaires, pas comme des concurrents directs. Et tes deux liens correspondent à deux projets différents.**

| Projet | Ce qu’il propose | Rapport avec ShipGlows |
|---|---|---|
| [conveyor.run](https://conveyor.run/) → dépôt **eyolas/conveyor** | Une bibliothèque TypeScript de tâches en arrière-plan : PostgreSQL, Redis, SQLite ou mémoire, planification, retries et dépendances. | Brique potentielle pour le runner. |
| [conveyorq/conveyor](https://github.com/conveyorq/conveyor) | Un serveur distribué de tâches, avec SDK Go, TypeScript et Python, stockage PostgreSQL, distribution aux workers et dashboard technique. | Infrastructure potentielle pour répartir le travail entre plusieurs workers. |

**Entre eux, oui : ils répondent à un besoin similaire**, avec deux approches — bibliothèque intégrée à l’application et serveur dédié.

ShipGlows porte une promesse plus large : piloter des projets et des agents, conserver le contexte métier, gérer les décisions, les approbations et les preuves. Une queue pourrait servir à exécuter un audit plus tard ou à distribuer des traitements ; elle ne fournit pas cette couche produit.

**Mon avis : intéressants à garder comme références d’infrastructure, sans urgence à les intégrer.** Le premier paraît plus naturel à explorer côté TypeScript ; le second si nous avons besoin de plusieurs workers distribués. Attention pour les agents : `conveyorq` peut réexécuter une tâche après une panne, donc il faut prévenir les actions en double. Son README indique aussi que les SDK npm/PyPI ne sont pas encore publiés. [Source](https://github.com/conveyorq/conveyor#ways-to-use-it)

Analyse des pages et de la documentation, sans test d’exécution.
