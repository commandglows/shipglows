---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-04-27"
created_at: "2026-04-27 09:23:02 UTC"
updated: "2026-04-27"
updated_at: "2026-04-27 12:49:04 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice ShipGlows qui lance plusieurs skills sur plusieurs chantiers, je veux que chaque spec se documente elle-meme avec les skills lancees, leur statut, leur modele et la prochaine etape, afin de savoir rapidement ou en est un chantier sans relire l'historique de conversation."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - specs/
  - templates/spec.md
  - skills/*/SKILL.md
  - skills/sg-help/SKILL.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows_data/technical/metadata-migration-guide.md
  - README.md
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.3.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/metadata-migration-guide.md"
    artifact_version: "0.2.0"
    required_status: "draft"
  - artifact: "README.md"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes: []
evidence:
  - "User decision 2026-04-27: the global registry should be the specs folder, not a separate tracker."
  - "User decision 2026-04-27: add the GPT model used to launch/create the spec in metadata."
- "User decision 2026-04-27: this concerns every skill, but every skill does not necessarily write into a spec."
- "User clarification 2026-04-27: this spec was created before the chantier registry tracker existed, so it should be migrated into the new registry shape and execution should continue."
  - "Repo investigation 2026-04-27: shipglows_data/workflow/playbooks/spec-driven-workflow.md and shipglows_data/technical/metadata-migration-guide.md currently have status draft."
  - "Repo investigation 2026-04-27: TASKS.md, AUDIT_LOG.md, and PROJECTS.md are operational trackers; specs are durable ShipGlows artifacts."
next_step: "None"
---

# Spec: Specs as Chantier Registry

## Title

Specs as Chantier Registry

## Status

ready

## User Story

En tant qu'utilisatrice ShipGlows qui lance plusieurs skills sur plusieurs chantiers, je veux que chaque spec se documente elle-meme avec les skills lancees, leur statut, leur modele et la prochaine etape, afin de savoir rapidement ou en est un chantier sans relire l'historique de conversation.

## Minimal Behavior Contract

Quand une skill travaille sur un chantier spec-first, elle doit lire la spec du chantier, ajouter ou mettre a jour une trace concise de son passage quand sa categorie l'exige, puis terminer son report avec un bloc standard `Chantier`. Ce bloc doit indiquer la skill courante, le chantier, le flux courant, ce qui reste a faire, la prochaine etape et un verdict qui repete la skill active quand le chantier est applicable. Si aucune spec ne correspond au chantier, la skill ne cree pas de registre parallele: elle indique `Chantier: non applicable` ou `Chantier: non trace`, explique pourquoi, puis oriente vers `sg-spec` ou vers une selection explicite de spec. Le cas facile a rater est celui d'une skill transverse, par exemple audit, docs, perf ou deps: elle concerne bien la doctrine globale, mais elle ne doit ecrire dans une spec que si son run est rattache a un chantier identifiable.

## Success Behavior

- Preconditions: un chantier spec-first possede un fichier dans `specs/` avec frontmatter ShipGlows, ou la skill est lancee dans un contexte qui permet d'identifier clairement cette spec.
- Trigger: n'importe quelle skill ShipGlows est lancee et produit un report final.
- User/operator result: le report final contient toujours un bloc `Chantier`, sauf justification explicite de non-applicabilite pour les skills purement informatives ou hors chantier.
- System effect: pour les categories obligatoires et conditionnelles applicables, la spec du chantier contient une section persistante `Skill Run History` et un resume courant `Current Chantier Flow`.
- Success proof: ouvrir la spec suffit pour voir les skills applicables lancees, l'heure UTC, le modele, le resultat et la prochaine etape; ouvrir `sg-help` ou la doc workflow suffit pour connaitre la matrice obligatoire, conditionnel, non-applicable.
- Silent success: not allowed; chaque passage de skill sur un chantier spec-first doit etre visible dans la spec ou explicitement signale comme non trace/non applicable dans le report.

## Error Behavior

- Expected failures: spec introuvable, plusieurs specs candidates, skill hors chantier, categorie non applicable, fichier de spec non modifiable, metadata manquante pendant migration, conflit entre statut courant et action demandee.
- User/operator response: le report doit nommer le probleme, dire si la trace a ete ecrite ou non, et donner la prochaine action concrete.
- System effect: aucune creation de registre global separe; aucune modification de `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md` pour ce suivi de flux.
- Must never happen: historique de skill invente, trace ecrite dans la mauvaise spec, statut `ready` ou `done` annonce sans preuve, perte de metadata existante, duplication incontrolee de sections, absence de bloc `Chantier` sans justification.
- Silent failure: not allowed; si la trace n'a pas pu etre ecrite, le report final doit le dire.

## Problem

ShipGlows contient deja beaucoup de skills et plusieurs trackers operationnels. Quand l'utilisatrice lance `sg-spec`, `sg-ready`, `sg-start`, `sg-verify` et d'autres skills dans plusieurs conversations, elle perd vite la vue du flux: quelle skill a deja tourne, dans quel modele, a quelle heure, avec quel resultat, et quelle est la suite.

Un registre global dedie resoudrait une partie du probleme, mais il ajouterait une source de verite supplementaire a maintenir. La decision produit est donc de faire du dossier `specs/` le registre global des chantiers. Toutes les skills doivent connaitre cette doctrine, mais toutes ne doivent pas forcement ecrire dans une spec: certaines tracent toujours, certaines tracent seulement quand un chantier est identifiable, et certaines justifient la non-applicabilite.

## Solution

Ajouter au schema de spec ShipGlows des metadata de modele (`source_model`, puis `run_model` dans l'historique) et une section persistante `Skill Run History`. Definir une matrice obligatoire, conditionnel, non-applicable pour tous les `skills/*/SKILL.md`. Adapter les skills selon leur categorie pour qu'elles finissent leurs reports avec un bloc standard `Chantier`; les skills applicables tracent leur passage dans la spec et les autres expliquent explicitement pourquoi elles ne tracent pas.

## Scope In

- Definir `specs/` comme registre global des chantiers spec-first.
- Ajouter les champs metadata de modele aux specs creees par `sg-spec`.
- Ajouter une section standard `Skill Run History` dans chaque spec de chantier.
- Ajouter un bloc final standard `Chantier` dans les reports de skills.
- Inventorier explicitement tous les `skills/*/SKILL.md` existants avant implementation.
- Classer toutes les skills en obligatoire, conditionnel ou non-applicable.
- Appliquer les instructions par categorie a toutes les skills, avec des edits individuels pour les lifecycle skills principales.
- Documenter la doctrine dans l'aide et la doc workflow.

## Scope Out

- Creer un nouveau fichier registre global distinct de `specs/`.
- Imposer une ecriture dans la spec aux runs hors chantier quand aucune spec ne porte le changement.
- Convertir `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md` en artefacts metadata.
- Reprendre retroactivement tout l'historique des anciennes conversations.
- Changer le systeme d'installation ou de decouverte des skills.
- Modifier les skills dans cette passe de correction de spec.

## Constraints

- `TASKS.md`, `AUDIT_LOG.md` et `PROJECTS.md` restent des trackers operationnels sans frontmatter obligatoire.
- La spec reste la source de verite du chantier uniquement pour les travaux spec-first.
- Le tracking doit etre lisible en markdown sans outil dedie.
- Les skills ne doivent pas inventer des etapes passees non prouvees par la spec, le report courant ou des fichiers existants.
- Les edits de spec doivent etre append-only ou cibles pour eviter d'effacer le contrat du chantier.
- Le modele doit etre trace avec la meilleure information disponible; si le runtime ne fournit pas l'identifiant exact, utiliser une valeur explicite comme `unknown`, `GPT-5 Codex` ou le nom fourni par l'operateur.
- Le bloc `Chantier` est obligatoire dans les reports de skills sauf si la skill est non interactive ou ne produit pas de report utilisateur; dans ce cas la non-applicabilite doit etre documentee dans la matrice.

## Dependencies

- Runtime: markdown, YAML frontmatter, skills ShipGlows existantes.
- Document contracts: `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/technical/metadata-migration-guide.md`, `README.md`.
- Dependency status alignment: `shipglows_data/workflow/playbooks/spec-driven-workflow.md` is currently `status: draft` with `artifact_version: "0.3.0"`; `shipglows_data/technical/metadata-migration-guide.md` is currently `status: draft` with `artifact_version: "0.2.0"`; this spec therefore requires `draft` for both instead of incorrectly requiring `active`.
- Metadata debt: `README.md` has no ShipGlows frontmatter in the inspected state, so this spec records `artifact_version: "unknown"` and `required_status: "unknown"` rather than inventing an active status.
- Fresh external docs: fresh-docs not needed, because the change is local to ShipGlows markdown conventions and skill instructions.

## Invariants

- Une spec doit rester implementable par un agent frais sans relire l'historique de conversation.
- Le tracking de skill ne remplace pas les sections contractuelles: user story, behavior contract, tasks, acceptance criteria et risks restent obligatoires.
- Une skill hors chantier ne doit pas creer de fausse continuite spec-first.
- Le verdict final d'une skill applicable doit nommer la skill courante, par exemple `Verdict sg-ready: ready`.
- La prochaine etape doit etre une commande ShipGlows executable ou une phrase explicite disant qu'aucune action n'est requise.
- Chaque `skills/*/SKILL.md` doit etre couvert par l'inventaire et par la matrice, meme si son resultat est `non-applicable`.

## Links & Consequences

- Upstream systems: `sg-spec` cree les specs et doit initialiser les metadata et l'historique; `sg-ready` doit lire cet historique avant de statuer.
- Downstream systems: `sg-start`, `sg-verify`, `sg-end` et `sg-ship` doivent pouvoir afficher le flux du chantier depuis la spec.
- Cross-cutting skills: audits, docs, checks, fixes, migrations, content and research skills must emit a `Chantier` block when they report to the user, but only write to a spec when the active run is attached to a concrete chantier.
- Informational skills: status/help/resume/model/context style skills may be non-applicable for spec writes, but their reports must not obscure the chantier state when they are invoked inside a chantier flow.
- Compatibility: les specs existantes sans `Skill Run History` doivent rester valides pendant migration, mais les nouvelles specs doivent l'avoir.

## Documentation Coherence

- `templates/spec.md` doit montrer les nouveaux champs `created_at`, `updated_at`, `source_model` et la section `Skill Run History`.
- `skills/sg-spec/SKILL.md` doit creer ces champs et cette section.
- `skills/sg-ready/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/sg-verify/SKILL.md`, `skills/sg-end/SKILL.md` et `skills/sg-ship/SKILL.md` doivent decrire leur mise a jour obligatoire de l'historique quand une spec est presente.
- Toutes les autres `skills/*/SKILL.md` doivent etre inventoriees et classees pour savoir si elles appliquent le bloc final `Chantier` en obligatoire, conditionnel ou non-applicable.
- `skills/sg-help/SKILL.md` doit expliquer la doctrine: `specs/` est le registre global des chantiers spec-first.
- `README.md` ou `shipglows_data/workflow/playbooks/spec-driven-workflow.md` doit documenter la lecture du flux depuis une spec.
- `CHANGELOG.md` doit mentionner la nouvelle tracabilite des chantiers.

## Edge Cases

- Une skill est lancee avec un titre qui matche plusieurs specs: elle doit demander ou choisir explicitement la spec la plus pertinente avec justification avant toute ecriture.
- Une skill est lancee hors spec-first: elle affiche `Chantier: non applicable` et ne modifie aucune spec.
- Une skill conditionnelle est lancee sur un chantier identifiable: elle doit appliquer le bloc `Chantier` et tracer selon la matrice.
- Une ancienne spec n'a pas `Skill Run History`: la premiere skill spec-driven ajoute la section sans modifier les anciennes decisions.
- Le modele exact n'est pas visible: la trace utilise `unknown` ou le nom runtime disponible, sans bloquer le chantier.
- `sg-ready` est lance deux fois: l'historique garde deux lignes avec heures et resultats distincts.
- `sg-start` implemente partiellement: la ligne d'historique doit dire `partial`, pas `done`.
- Une spec est en `ready` mais une execution revele un gap: `sg-start` ou `sg-verify` trace le gap et renvoie vers `sg-spec` ou `sg-ready`.

## Implementation Tasks

- [x] Task 1: Mettre a jour le template de spec
  - File: `templates/spec.md`
  - Action: Ajouter `created_at`, `updated_at`, `source_model`, puis une section `Skill Run History` avec colonnes Date UTC, Skill, Model, Action, Result, Next step.
  - User story link: Permet aux nouvelles specs de s'auto-documenter des leur creation.
  - Depends on: None
  - Validate with: `rg -n "source_model|Skill Run History|created_at|updated_at" templates/spec.md`
  - Notes: Garder un template lisible et compatible avec les specs existantes.

- [x] Task 2: Inventorier tous les fichiers de skills existants
  - File: `skills/*/SKILL.md`
  - Action: Lister tous les `skills/*/SKILL.md`, confirmer le nombre total, puis produire une matrice d'application couvrant chaque skill une seule fois avec categorie `obligatoire`, `conditionnel` ou `non-applicable`.
  - User story link: Garantit que le chantier concerne bien toutes les skills sans imposer une ecriture spec a toutes.
  - Depends on: Task 1
  - Validate with: `find skills -maxdepth 2 -name SKILL.md | sort`
  - Notes: L'inventaire inspecte le contenu des skills en lecture avant toute modification; aucune skill ne doit rester hors matrice.

- [x] Task 3: Documenter la matrice globale d'application
  - File: `skills/sg-help/SKILL.md`
  - Action: Ajouter la doctrine `specs/` comme registre global et publier la matrice issue de Task 2: obligatoire pour lifecycle spec-first, conditionnel pour skills rattachees a un chantier, non-applicable pour helpers purement informatifs ou sans report de chantier.
  - User story link: Donne a l'utilisatrice une regle unique pour savoir quelle skill trace quoi.
  - Depends on: Task 2
  - Validate with: `rg -n "registre global|specs/|obligatoire|conditionnel|non-applicable|Skill Run History" skills/sg-help/SKILL.md`
  - Notes: La matrice doit rester courte mais exhaustive; les listes de skills peuvent etre groupees par categorie.

- [x] Task 4: Adapter `sg-spec` pour initialiser la trace de chantier
  - File: `skills/sg-spec/SKILL.md`
  - Action: Exiger les metadata de modele dans le frontmatter et ajouter une premiere ligne `sg-spec` dans `Skill Run History` lors de l'enregistrement.
  - User story link: L'utilisatrice sait quand la spec a ete creee et avec quel modele.
  - Depends on: Tasks 1-3
  - Validate with: `rg -n "source_model|Skill Run History|created_at|updated_at|Verdict sg-spec|Chantier" skills/sg-spec/SKILL.md`
  - Notes: Ne pas demander un modele exact si l'environnement ne l'expose pas; imposer une valeur explicite.

- [x] Task 5: Adapter `sg-ready` pour lire et mettre a jour le flux
  - File: `skills/sg-ready/SKILL.md`
  - Action: Lire `Skill Run History`, ajouter une ligne `sg-ready`, et terminer le report par le bloc `Chantier` avec `Verdict sg-ready: ...`.
  - User story link: L'utilisatrice voit si la readiness gate a deja ete lancee et avec quel resultat.
  - Depends on: Tasks 3-4
  - Validate with: `rg -n "Skill Run History|Verdict sg-ready|Chantier" skills/sg-ready/SKILL.md`
  - Notes: Si la spec est not ready, `Next step` doit renvoyer vers `sg-spec` ou une correction precise.

- [x] Task 6: Adapter `sg-start` pour tracer execution et statut partiel
  - File: `skills/sg-start/SKILL.md`
  - Action: Quand une spec est utilisee, ajouter une ligne `sg-start` avec result `implemented`, `partial`, `blocked` ou `rerouted`, puis inclure `Verdict sg-start: ...` dans le bloc `Chantier`.
  - User story link: L'utilisatrice sait si l'implementation a commence ou reste a faire.
  - Depends on: Task 5
  - Validate with: `rg -n "Skill Run History|Verdict sg-start|partial|blocked|Chantier" skills/sg-start/SKILL.md`
  - Notes: Ne pas tracer dans une spec si l'execution directe n'est pas rattachee a un chantier.

- [x] Task 7: Adapter `sg-verify` pour tracer la verification
  - File: `skills/sg-verify/SKILL.md`
  - Action: Quand une spec de chantier est identifiee, ajouter une ligne `sg-verify` avec result `verified`, `not verified`, `partial` ou `blocked`, puis terminer par `Verdict sg-verify: ...`.
  - User story link: Le flux de chantier montre si la promesse utilisateur a ete verifiee.
  - Depends on: Task 6
  - Validate with: `rg -n "Verdict sg-verify|Skill Run History|Chantier|verified|blocked" skills/sg-verify/SKILL.md`
  - Notes: Cette task ne modifie que `sg-verify`; ne pas coupler avec cloture ou shipping.

- [x] Task 8: Adapter `sg-end` pour tracer la cloture de chantier
  - File: `skills/sg-end/SKILL.md`
  - Action: Quand une spec de chantier est identifiee, ajouter une ligne `sg-end` avec result `closed`, `deferred`, `blocked` ou `not applicable`, puis terminer par `Verdict sg-end: ...`.
  - User story link: Le flux de chantier montre si le travail a ete clos sans confondre cloture et shipping.
  - Depends on: Task 7
  - Validate with: `rg -n "Verdict sg-end|Skill Run History|Chantier|closed|deferred|blocked" skills/sg-end/SKILL.md`
  - Notes: Cette task ne modifie que `sg-end`.

- [x] Task 9: Adapter `sg-ship` pour tracer le shipping
  - File: `skills/sg-ship/SKILL.md`
  - Action: Quand une spec de chantier est identifiee, ajouter une ligne `sg-ship` avec result `shipped`, `not shipped`, `blocked` ou `skipped checks`, puis terminer par `Verdict sg-ship: ...`.
  - User story link: Le flux de chantier montre si la livraison a ete effectuee et avec quel niveau de verification.
  - Depends on: Task 8
  - Validate with: `rg -n "Verdict sg-ship|Skill Run History|Chantier|shipped|blocked" skills/sg-ship/SKILL.md`
  - Notes: Cette task ne modifie que `sg-ship`.

- [x] Task 10: Appliquer la doctrine aux skills conditionnelles par categorie
  - File: `skills/*/SKILL.md`
  - Action: Pour toutes les skills classees `conditionnel` dans Task 2, ajouter l'instruction de bloc final `Chantier` et la regle d'ecriture spec seulement quand un chantier unique est identifie; pour les skills `non-applicable`, documenter la justification de non-ecriture si elles produisent un report.
  - User story link: Toutes les skills sont couvertes sans bruit inutile dans les specs.
  - Depends on: Tasks 2-3
  - Validate with: `rg -n "Chantier|non applicable|Skill Run History" skills/*/SKILL.md`
  - Notes: Les lifecycle skills deja couvertes par Tasks 4-9 ne doivent pas etre reeditees en doublon ici; cette task applique les categories restantes.

- [x] Task 11: Documenter la doctrine dans le workflow public interne
  - File: `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Action: Expliquer que `specs/` est le registre global des chantiers et que chaque spec garde son historique de skill runs; inclure la regle obligatoire, conditionnel, non-applicable.
  - User story link: Permet de retrouver la regle sans ouvrir les skills.
  - Depends on: Task 10
  - Validate with: `rg -n "Skill Run History|registre global des chantiers|specs/|conditionnel|non-applicable" shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Notes: Ne pas transformer la doc en manuel exhaustif.

- [x] Task 12: Ajouter une entree changelog
  - File: `CHANGELOG.md`
  - Action: Ajouter une entree concise sur l'auto-tracabilite des specs, le modele source et la matrice toutes skills.
  - User story link: Trace le changement de doctrine ShipGlows.
  - Depends on: Tasks 1-11
  - Validate with: `head -80 CHANGELOG.md`
  - Notes: Ne pas revendiquer l'implementation complete avant validation.

## Acceptance Criteria

- [ ] AC 1: Given une nouvelle spec creee par `sg-spec`, when elle est enregistree, then son frontmatter contient `source_model`, `created_at` et `updated_at`.
- [ ] AC 2: Given une nouvelle spec creee par `sg-spec`, when elle est ouverte, then elle contient une section `Skill Run History` avec une ligne initiale pour `sg-spec`.
- [ ] AC 3: Given l'implementation commence, when Task 2 est executee, then tous les fichiers retournes par `find skills -maxdepth 2 -name SKILL.md | sort` sont presents exactement une fois dans la matrice obligatoire/conditionnel/non-applicable.
- [ ] AC 4: Given une skill classee `obligatoire` est lancee sur une spec, when son report final est lu, then il contient un bloc `Chantier`, une ligne d'historique spec et `Verdict <skill>: ...`.
- [ ] AC 5: Given une skill classee `conditionnel` est lancee sur un chantier identifiable, when son report final est lu, then elle applique le bloc `Chantier` et trace selon la matrice.
- [ ] AC 6: Given une skill classee `conditionnel` est lancee hors chantier, when son report final est lu, then elle ne modifie aucune spec et indique `Chantier: non applicable` ou `Chantier: non trace` avec justification.
- [ ] AC 7: Given une skill classee `non-applicable` est lancee, when son report final est lu, then elle n'ecrit pas dans une spec et sa non-applicabilite est couverte par la matrice.
- [ ] AC 8: Given une spec existante sans historique, when `sg-ready` est lance dessus, then la skill ajoute ou demande l'ajout de `Skill Run History` sans effacer les sections contractuelles.
- [ ] AC 9: Given `sg-ready` a statue sur une spec, when le report final est lu, then il contient `Verdict sg-ready: ...` et un bloc `Chantier` avec la prochaine etape.
- [ ] AC 10: Given `sg-start` implemente seulement une partie du chantier, when il trace son passage, then le resultat est `partial` ou equivalent et la prochaine etape reste explicite.
- [ ] AC 11: Given l'utilisatrice veut savoir si `sg-ready`, `sg-start`, `sg-verify`, `sg-end` ou `sg-ship` a deja ete lance, when elle ouvre la spec du chantier, then l'information est visible sans relire la conversation.
- [ ] AC 12: Given `shipglows_data/workflow/playbooks/spec-driven-workflow.md` and `shipglows_data/technical/metadata-migration-guide.md` remain `status: draft`, when `/sg-ready` evaluates this spec, then `depends_on.required_status` matches `draft` and does not falsely require `active`.

## Test Strategy

- Unit: verifier par `rg` que les nouvelles instructions existent dans les skills et templates modifies.
- Inventory: verifier que le nombre de lignes de la matrice correspond au nombre de fichiers retournes par `find skills -maxdepth 2 -name SKILL.md | sort`.
- Integration: creer une spec de test, simuler les passages `sg-spec` puis `sg-ready`, et verifier que l'historique reste append-only et lisible.
- Category regression: lancer ou relire une skill obligatoire, une conditionnelle et une non-applicable pour confirmer que le bloc `Chantier` et l'ecriture spec suivent la matrice.
- Manual: ouvrir une spec reelle et confirmer que le bloc final de report indique la skill courante, le flux, les choses restantes et la prochaine etape.
- Regression: verifier que `TASKS.md`, `AUDIT_LOG.md` et `PROJECTS.md` ne recoivent pas de frontmatter ou de suivi de skill runs.

## Risks

- Security impact: none, because the change concerns local markdown metadata and skill reporting only.
- Product risk: trop de skills pourraient ecrire dans les specs et les rendre bruyantes; mitigation par matrice obligatoire/conditionnel/non-applicable.
- Data risk: une skill pourrait tracer dans la mauvaise spec si le matching est ambigu; mitigation par selection explicite ou stop condition.
- Maintenance risk: mettre a jour toutes les skills d'un coup peut creer des formulations incoherentes; mitigation par template de bloc final commun.
- Readiness risk: si la matrice n'inventorie pas tous les `skills/*/SKILL.md`, le chantier reste ambigu; mitigation par Task 2 et AC 3.

## Execution Notes

- Read first: `templates/spec.md`, `skills/sg-spec/SKILL.md`, `skills/sg-ready/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/sg-verify/SKILL.md`, `skills/sg-end/SKILL.md`, `skills/sg-ship/SKILL.md`.
- Then read: `skills/sg-help/SKILL.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/technical/metadata-migration-guide.md`, `README.md`.
- Inventory command: `find skills -maxdepth 2 -name SKILL.md | sort`.
- Initial observed inventory on 2026-04-27: `skills/name/SKILL.md`, `skills/sg-audit-a11y/SKILL.md`, `skills/sg-audit-code/SKILL.md`, `skills/sg-audit-components/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-audit-design-tokens/SKILL.md`, `skills/sg-audit-design/SKILL.md`, `skills/sg-audit-gtm/SKILL.md`, `skills/sg-audit-seo/SKILL.md`, `skills/sg-audit-translate/SKILL.md`, `skills/sg-audit/SKILL.md`, `skills/sg-auth-debug/SKILL.md`, `skills/sg-backlog/SKILL.md`, `skills/sg-changelog/SKILL.md`, `skills/sg-check/SKILL.md`, `skills/sg-context/SKILL.md`, `skills/sg-deps/SKILL.md`, `skills/sg-design-playground/SKILL.md`, `skills/sg-docs/SKILL.md`, `skills/sg-end/SKILL.md`, `skills/sg-enrich/SKILL.md`, `skills/sg-explore/SKILL.md`, `skills/sg-fix/SKILL.md`, `skills/sg-help/SKILL.md`, `skills/sg-init/SKILL.md`, `skills/sg-market-study/SKILL.md`, `skills/sg-migrate/SKILL.md`, `skills/sg-model/SKILL.md`, `skills/sg-perf/SKILL.md`, `skills/sg-priorities/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-ready/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-repurpose/SKILL.md`, `skills/sg-research/SKILL.md`, `skills/sg-resume/SKILL.md`, `skills/sg-review/SKILL.md`, `skills/sg-scaffold/SKILL.md`, `skills/sg-ship/SKILL.md`, `skills/sg-skills-refresh/SKILL.md`, `skills/sg-spec/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/sg-status/SKILL.md`, `skills/sg-tasks/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-veille/SKILL.md`, `skills/sg-verify/SKILL.md`.
- Suggested baseline categories for Task 2: obligatoire: `sg-spec`, `sg-ready`, `sg-start`, `sg-verify`, `sg-end`, `sg-ship`; conditionnel: audit, docs, check, fix, deps, perf, migrate, scaffold, content, research, backlog/task/status-adjacent skills when tied to a concrete chantier; non-applicable: pure help/discovery/session utility runs unless a chantier is explicitly active.
- Implementation approach: start with the template and `sg-spec`, then update the spec-driven lifecycle skills one file at a time, then apply the category matrix to the remaining skills.
- Suggested final report block:

```text
## Chantier

Skill courante: sg-ready
Chantier: specs/[slug].md
Trace spec: ecrite | non ecrite | non applicable
Flux:
- sg-spec: done
- sg-ready: ready
- sg-start: not launched
- sg-verify: not launched
- sg-end: not launched
- sg-ship: not launched

Reste a faire:
- [item]

Prochaine etape:
- /sg-start [title]

Verdict sg-ready:
- ready
```

- Validate with: `rg -n "Skill Run History|source_model|Verdict sf-|Chantier|obligatoire|conditionnel|non-applicable" specs/specs-as-chantier-registry.md`.
- Stop conditions: if matching the correct spec is ambiguous, ask the user instead of writing a trace; if a skill is unrelated to a chantier, report non-applicable instead of creating a trace.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-27 09:23:02 UTC | sg-spec | GPT-5 Codex | Created spec for specs-as-chantier-registry | draft | /sg-ready Specs as chantier registry |
| 2026-04-27 09:54:52 UTC | sg-ready | GPT-5 Codex | Readiness gate for specs-as-chantier-registry | not ready | /sg-spec Specs as chantier registry |
| 2026-04-27 10:19:20 UTC | sg-spec | GPT-5.5 high | Updated spec after readiness gaps: all-skills doctrine, inventory task, split lifecycle tasks, draft dependency alignment | draft updated | /sg-ready Specs as chantier registry |
| 2026-04-27 10:45:19 UTC | sg-ready | GPT-5 Codex | Readiness gate for specs-as-chantier-registry | ready | /sg-start Specs as chantier registry |
| 2026-04-27 12:25:09 UTC | sg-start | GPT-5 Codex | Implemented chantier registry doctrine across template, lifecycle skills, all-skills matrix, and workflow docs | partial | /sg-verify Specs as chantier registry |
| 2026-04-27 12:37:31 UTC | sg-start | GPT-5 Codex | Migrated this pre-registry spec into the chantier tracker shape and added changelog entry | implemented | /sg-verify Specs as chantier registry |
| 2026-04-27 12:38:10 UTC | sg-verify | GPT-5 Codex | Verified template, lifecycle skills, all-skills matrix, docs, changelog, metadata, and whitespace checks | verified | /sg-end Specs as chantier registry |
| 2026-04-27 12:42:21 UTC | sg-end | GPT-5 Codex | Closed chantier after verified implementation and tracker updates | closed | /sg-ship Specs as chantier registry |
| 2026-04-27 12:44:52 UTC | sg-repurpose | GPT-5 Codex | Repurposed chantier registry work into README and public website docs, FAQ, and lifecycle skill pages | docs updated | /sg-ship Specs as chantier registry |
| 2026-04-27 12:49:04 UTC | sg-ship | GPT-5 Codex | Shipped chantier registry implementation, docs, and website updates | shipped | None |

## Current Chantier Flow

- `sg-spec`: done, draft spec created; updated after readiness gaps on 2026-04-27 10:19:20 UTC.
- `sg-ready`: ready on 2026-04-27 10:45:19 UTC.
- `sg-start`: implemented on 2026-04-27 12:37:31 UTC; this pre-registry spec was migrated into the chantier tracker shape and the changelog entry was added.
- `sg-verify`: verified on 2026-04-27 12:38:10 UTC.
- `sg-end`: closed on 2026-04-27 12:42:21 UTC.
- `sg-ship`: shipped on 2026-04-27 12:49:04 UTC.

Next step: None
