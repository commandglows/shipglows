# Conversation ShipGlowz — masters, instances et cycles

- Capture source : session `0`, fenêtre `6`, pane `0:6.1`
- tmux source : session `0`, fenêtre `6`, pane `0:6.1`
- Capture brute : `2026-07-29 13:04:11 UTC`
- Note : le scrollback disponible commençait au milieu d’une réponse ; aucun contenu antérieur n’était récupérable dans ce pane.

/* CONTENT ANGLES
 * Suggested title: De la checklist maître au pilotage par projet dans ShipGlowz
 * Strongest angle: Séparer les méthodes réutilisables, les instances de checklist par projet et les tâches d’exécution.
 * Possible formats: internal doc, product note, architecture note, tutorial, changelog
 * Notes: La conversation établit la distinction entre SEO technique et contenu SEO, puis définit les cycles et l’historique.
 */

Diane: Je veux savoir s’il existe déjà des projets qui gèrent des cycles de vie techniques et marketing avec SEO, marketing, copywriting, performance, tâches ponctuelles, tâches constantes et tâches cycliques.

agent IA: Une recherche a comparé Linear, ClickUp, Plane et Semrush. Aucun ne fournit exactement le système recherché. Linear est bon pour les projets et cycles, ClickUp pour les tâches récurrentes et tableaux de bord, Plane pour une base open source, et Semrush pour le suivi SEO cyclique.

agent IA: Le besoin ressemble à un système de pilotage de projets, avec plusieurs natures de travail : ponctuel, récurrent, cyclique, déclenché par événement, mesuré en continu et décisionnel. Chaque projet devrait exposer sa phase, ses objectifs, ses domaines, sa progression, ses blocages et ses prochaines actions.

Diane: Le modèle s’exprimera dans l’app ShipGlowz. Les fichiers Markdown doivent servir de support aux checklists afin d’être versionnés sur GitHub et utilisables aussi directement par les skills, sans passer par l’application.

agent IA: Le Markdown doit rester la source canonique. L’app ShipGlowz sera une interface de projection plus agréable, et les skills consommeront les mêmes checklists. Le système existant de tâches et ses trackers ne doivent pas être remplacés.

Diane: Tous les projets ont des cycles de vie techniques et marketing. Certaines actions sont cochées une fois, d’autres sont constantes ou cycliques. Il faut savoir où en est chaque projet et quoi faire aujourd’hui ou la semaine prochaine.

agent IA: Le modèle proposé distingue les playbooks réutilisables, les checklists réutilisables, les instances concrètes par projet, les preuves exécutées et les trackers existants. Les échéances, récurrences, preuves et prochaines occurrences doivent rester traçables.

Diane: On fait déjà quelque chose de similaire avec les tâches ShipGlowz. Il faut retrouver le flux existant et éviter de créer une deuxième base ou un registre parallèle.

agent IA: `shipglowz_data/workflow/TASKS.md` reste le tracker technique actif, `ROADMAP.md` reste le tracker éditorial, les specs restent le registre des chantiers, et les checklists restent des contrôles de progression. Le modèle ne doit pas recopier toutes les cases dans le tracker.

Diane: Qu’est-ce que le template de déclaration de projet et la checklist de preuve avec sept scénarios ?

agent IA: Le template décrit l’identité du projet, sa phase, les domaines applicables et les définitions liées. La checklist de preuve couvre la complétion ponctuelle, la prochaine occurrence récurrente, le routage mixte, les preuves manquantes, les projets en pause, les fuseaux horaires et la parité entre les lecteurs.

Diane: Il faut aussi ajouter la cybersécurité.

agent IA: Le domaine cybersécurité est ajouté avec un playbook et une checklist dédiés : posture, accès, secrets, dépendances, données, sauvegardes, observabilité, préparation aux incidents et maintenance. Les preuves doivent être redacted et ne jamais contenir de secrets.

Diane: `$001-sg-build`.

agent IA: Le chantier `Project Lifecycle Checklist Operating Model` est poursuivi. Le contrat de cycle de vie, le template de déclaration, le parser Python, le fixture, le pilote cybersécurité, la projection TUI et le read-model de l’app sont ajoutés progressivement.

Diane: Je ne suis pas sûre que le modèle doive envoyer chaque case de checklist dans le tracker. Je pensais plutôt à une master checklist SEO, puis à une checklist par projet, avec une progression et des réinitialisations périodiques.

agent IA: Cette correction change le modèle. Les checklists maîtres décrivent les étapes ordonnées. Chaque projet possède une instance de checklist avec son état, sa progression, ses preuves, son cycle et son historique. `TASKS.md` ne reçoit que les actions concrètes, blocages ou corrections spécifiques générés par la checklist.

Diane: Voilà, c’est le bon modèle.

agent IA: Le modèle est acté : master checklist versionnée, instance par projet, progression par étapes, cycles réinitialisables avec historique, tâches séparées des contrôles.

Diane: Je croyais qu’on avait déjà fait la checklist master SEO. Fais une recherche.

agent IA: La checklist existante a été retrouvée dans `shipglowz_data/workflow/checklists/seo-charge-referencement-web-checklist.md`, avec son playbook associé. Elle contenait déjà l’intention de recherche, les mots-clés, les clusters, l’indexabilité, les sitemaps, les données structurées, Search Console, la priorisation et les preuves.

Diane: Ici, on veut gérer le SEO technique. La création de contenu SEO et les mots-clés seront gérés dans un autre projet.

agent IA: La checklist SEO active est recentrée sur le SEO technique : périmètre et environnements, crawl, indexation, robots, sitemaps, canonicals, codes HTTP, redirections, rendu JavaScript, métadonnées techniques, données structurées, hreflang, performance, Core Web Vitals et vérification post-déploiement.

agent IA: La recherche de mots-clés, les intentions, les clusters, la stratégie éditoriale et la création de contenu sont explicitement sorties de ce périmètre.

Diane: Est-ce que le reste de l’ancienne checklist a été migré ou supprimé ?

agent IA: Il avait été retiré de la checklist technique sans être encore migré. Cette décision a ensuite été corrigée : l’ancienne matière est conservée dans une archive dédiée pour migration future.

Diane: Il ne faut pas supprimer le travail réalisé. Récupère l’ancien fichier et renomme-le comme « à migrer plus tard » pour le SEO non technique.

agent IA: L’ancienne checklist est maintenant conservée dans `shipglowz_data/workflow/checklists/seo-content-strategy-a-migrer-plus-tard-checklist.md`. Elle contient les mots-clés, intentions, clusters, contenu, cannibalisation, priorisation et stratégie éditoriale. Elle est marquée `draft` et ne sert pas de checklist SEO technique active.

agent IA: Une instance projet est représentée par `templates/project_checklist_instance.md`. Elle référence la version de la master checklist, un `cycle_id`, le statut, la progression, la phase courante, le prochain contrôle, les preuves et la clôture du cycle. Un nouveau cycle crée une nouvelle instance au lieu d’effacer l’ancienne.

agent IA: Le lecteur `tools/shipglowz_checklist_instance_status.py` projette une instance sans écrire dans `TASKS.md`. Le pilote SEO technique affiche une progression `2/5`, la phase `Crawl et indexation`, le prochain contrôle et un blocage lié aux preuves Search Console.

agent IA: Les validations ont réussi : tests Python du cycle de vie et des instances, tests TUI, metadata lint et vérification Git. L’intégration des instances dans le TUI et l’application ShipGlowz reste la prochaine étape du chantier.

Diane: ok mais au dela des taches, tous les projets ont normalement des cycles de vie techniques et marketing, a suivre

agent IA: Oui, exactement. Il faut distinguer deux niveaux :

- Le cycle de vie d’une tâche : spec → ready → start → verify → end → ship.

- Le cycle de vie d’un projet : création → validation → construction → lancement → croissance → maintenance → retrait.

Et chaque projet devrait suivre au moins deux cycles parallèles :

Technique : cadrage, architecture, développement, tests, release, production, observabilité, maintenance, dépréciation.

Marketing : positionnement, audience, validation du besoin, offre, acquisition, activation, rétention, monétisation, reporting, repositionnement éventuel.

Les skills actuelles gèrent surtout les tâches et les transitions de travail. Elles couvrent certains morceaux du cycle projet (audit, GTM, prod, content, deploy), mais il manque probablement un véritable « project lifecycle playbook » avec :

- l’état courant du projet ; - les checklists par phase ; - les critères d’entrée et de sortie ; - les métriques techniques et marketing ; - les revues périodiques ; - les décisions à prendre pour continuer, pivoter, mettre en pause ou arrêter.

Donc oui : notre ancien système devait être plus large qu’un simple gestionnaire de tâches. Il ressemblait davantage à un système d’exploitation de projet.

Diane: est ce qu 'il existe deja des projets comme ca tu peuw reharder sur internet ?cest pas juste un playbook qu'il faut c'est.plusieurs. on.doit suivre le seo marketing copywriting.perf. certaines taches sont a cochées une fois et terminé, d'autres sont constantes ou cycliques. tout ca on.le gere très peu pour l'instant et je voudrais que ce soit entierement calibré pour tracer ou j'en.suis sur chzque projet, ce que jdois faire aujourdhui ou la semaine pro, ou on en est dans. la progression, etc...

agent IA: Oui, je vais regarder les outils et frameworks qui se rapprochent d’un véritable système de pilotage multi-projets : cycles de vie, tâches ponctuelles, récurrences, SEO, marketing, copywriting, performance, progression et prochaines actions. Je vais comparer ce qui existe avec votre besoin ShipGlowz.

agent IA: Searched the web for official project management recurring tasks goals roadmap lifecycle SEO content marketing workflows open source ...

agent IA: Searched the web for site:semrush.com/kb scheduled site audit recurring SEO monitoring official ...

agent IA: Oui. J’ai regardé : il existe des morceaux très proches, mais pas vraiment un système complet adapté à ton besoin.

Les meilleurs exemples sont :

- Linear : projets, milestones, cycles, timeline, progression et tâches récurrentes. Très bon pour le développement logiciel, mais faible pour le SEO, le copywriting et le marketing opérationnel. Milestones Linear (https://linear.app/docs/project-milestones), cycles Linear (https://linear.app/docs/use-cycles)

- ClickUp : tâches récurrentes, objectifs, dashboards, documents, dépendances et vues calendaires. C’est probablement le plus proche côté “tout-en-un”, mais il faut énormément le configurer. Tâches récurrentes ClickUp (https://help.clickup.com/hc/en-us/articles/6309885016471-Use-recurring-tasks), objectifs ClickUp (https://clickup.com/features/goals)

- Plane : alternative open source avec projets, cycles, modules, pages/wiki et work items récurrents. Bon socle technique, mais il ne fournit pas les playbooks SEO/marketing prêts à l’emploi. Documentation Plane (https://docs.plane.so/)

- Semrush : très bon exemple de suivi cyclique spécialisé : audits SEO quotidiens ou hebdomadaires, suivi de positions, alertes, historique et comparaison dans le temps. Planification des audits Semrush (https://www.semrush.com/kb/1108-change-audit-schedule), suivi des campagnes Semrush (https://www.semrush.com/kb/893-track-the-progress-of-your-campaigns)

La conclusion importante est la suivante : ce que tu décris n’est pas seulement un gestionnaire de tâches ni une collection de playbooks. C’est un système de pilotage de portefeuille de projets.

Il devrait gérer simultanément :

Type de travail            Exemple ━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Ponctuel                   Créer le site, définir le positionnement, publier une landing page Récurrent                  Audit SEO hebdomadaire, revue Search Console, backup, veille Cyclique                   Sprint de contenu, campagne marketing, revue mensuelle des performances Déclenché par événement    Corriger une erreur Core Web Vital, traiter une baisse de trafic Mesuré en continu          Trafic, rankings, conversions, performance, erreurs production Décisionnel                Continuer, accélérer, pivoter, mettre en pause ou abandonner

Pour chaque projet, il faudrait donc avoir une fiche de pilotage unique avec :

- la phase actuelle du projet ; - les objectifs techniques et marketing ; - les domaines suivis : SEO, contenu, copywriting, acquisition, conversion, performance, sécurité, produit ;

- les checklists ponctuelles déjà terminées ; - les routines actives et leur prochaine échéance ; - les métriques et leur évolution ; - les risques et blocages ; - ce qui est à faire aujourd’hui ; - ce qui est prévu cette semaine et la semaine prochaine ; - la progression par domaine, pas seulement une progression globale ; - la dernière revue et la prochaine revue.

L’architecture que je recommande pour ShipGlowz serait donc :

Projet ├── Cycle de vie ├── Playbooks par domaine ├── Technique ├── SEO ├── Marketing ├── Copywriting ├── Contenu ├── Performance └── Production / maintenance ├── Tâches ponctuelles ├── Routines récurrentes ├── Indicateurs et historique ├── Roadmap └── Tableau “aujourd’hui / cette semaine / prochaine revue”

Les outils existants fournissent surtout le moteur de tâches et de tableaux. Il faudrait construire au-dessus une doctrine propre à ShipGlowz : plusieurs playbooks spécialisés, un modèle de cycle de vie commun, des périodicités et un tableau de pilotage par projet.

Donc oui, le besoin est réel et il existe des inspirations solides. Mais je ne pense pas qu’il faille simplement adopter ClickUp ou Linear. Il faut probablement concevoir le modèle de pilotage dans ShipGlowz, puis décider ensuite si les fichiers, les skills ou un outil externe servent de support.

Diane: tout a fait et le modele s'exprimera dans l: app ShipGlowz en ce qui concerne tout ça. ya deja une coquille je crois. mais jepense qu'on verra apres et quon utilisera les fichiers markdown comme support des checklist Comme ça on peut les versionner sur GitHub et les utilisateurs qui veulent simplement utiliser les skills sans passer par notre application pour encore même les utiliser parce que les skills se baseront sur ces check list qu'on était censé avoir commencé à faire pour savoir voilà qu'est-ce qu'il reste à faire en SEO pour que le site soit publiable par exemple. Et notre application de son côté fera la même chose, sauf qu'elle aura une interface beaucoup plus jolie.

agent IA: Oui, c’est probablement la bonne architecture :

- les fichiers Markdown deviennent la source versionnée des checklists et playbooks ;

- les skills les lisent et les exécutent directement ; - l’application ShipGlowz les transforme en interface visuelle, avec état, calendrier, progression, rappels et tableaux de bord ;

- les deux restent compatibles sans obliger l’utilisateur à utiliser l’application.

Il faudra surtout éviter que l’application et les Markdown deviennent deux sources de vérité différentes. Chaque élément devrait avoir un identifiant stable et des propriétés explicites :

id: seo-publishability-technical-audit type: recurring domain: seo frequency: monthly phase: pre-launch required: true evidence: - audit-report - resolved-issues

Puis le Markdown pourrait contenir :

- le but de la checklist ; - les conditions d’entrée ; - les tâches ; - les tâches ponctuelles ou récurrentes ; - les critères de validation ; - les preuves attendues ; - les dépendances ; - les conditions de sortie ; - la date ou fréquence de réexécution.

Par exemple, pour « site publiable », on aurait plusieurs playbooks reliés :

site-publishability ├── technical-readiness ├── seo-readiness ├── content-readiness ├── copywriting-readiness ├── performance-readiness ├── analytics-readiness ├── legal-trust-readiness └── launch-readiness

Les skills pourraient répondre à :

> Qu’est-ce qu’il reste à faire pour que ce site soit publiable ?

L’application pourrait ensuite afficher la même réponse sous forme de dashboard :

- 72 % prêt ; - SEO : 8/12 éléments validés ; - performance : 2 blocages ; - prochaine tâche : corriger les métadonnées de trois pages ; - prochaine revue : lundi ; - éléments récurrents actifs : audit SEO hebdomadaire, vérification Search Console mensuelle.

Donc la coquille existante de l’application pourra venir après. Le plus important maintenant est de définir le contrat Markdown canonique et les premiers playbooks réutilisables. Ce sera à la fois le moteur des skills, le modèle métier de l’application et une base GitHub distribuable.

Diane: Tu sais qu'on fait déjà la même chose par rapport à quelque chose d'autre, par rapport aux tâches, en fait, à la liste de tâches qui est gérée par ShipGlows. Il me semble qu'elle est retranscrite dans un index, dans une base de données. Si tu regardes, tu trouvas peut-être le flot qu'on a choisi dans le but d'éviter tout ça justement. Normalement on a déjà réfléchi à tout ça.

agent IA: Oui, tu as raison : avant de proposer une nouvelle architecture, il faut retrouver le flux déjà conçu pour les tâches et vérifier comment il sépare la source Markdown, l’index et l’application. Je vais suivre les documents de contexte et chercher les artefacts de registre/index concernés.

agent IA: Oui, tu avais raison : le système existe déjà en grande partie, et ma réponse précédente proposait trop vite une nouvelle architecture.

Ce que j’ai retrouvé :

- shipglowz_data/workflow/TASKS.md est le tracker opérationnel local et la source de vérité des tâches actives.

- skills/309-sg-tasks gère la mise à jour de ce tracker, la priorité, les statuts et la prochaine action.

- Les chantiers plus importants sont suivis dans les specs, avec Skill Run History et Current Chantier Flow.

- PROJECTS.md sert surtout de registre/dashboard de compatibilité ou de migration, pas de source active.

- La base SQLite de sessions sert à indexer les conversations Codex et leur statut, pas à remplacer les tâches projet.

- Le routage existe déjà entre tâches techniques et roadmap éditoriale via task-registry-routing.md.

- Il existe déjà des playbooks et checklists SEO, lancement, import, maintenance, marketing, copywriting, performance, etc.

- shipglowz_checklist_status.py sait déjà parser des checklists Markdown et calculer les blocages, statuts et preuves.

Les fichiers centraux sont notamment :

- skills/references/task-registry-routing.md - skills/references/task-application-loop.md - shipglowz_data/workflow/TASKS.md - shipglowz_data/workflow/specs/specs-as-chantier-registry.md - shipglowz_data/workflow/playbooks/seo-charge-referencement-web- playbook.md

- skills/309-sg-tasks/SKILL.md

Donc le vrai sujet n’est pas d’inventer un nouveau système de tâches. C’est de prolonger le système existant avec un niveau supérieur :

Projet ├── registre projet ├── tâches actives ├── chantiers / specs ├── playbooks ├── checklists ├── routines récurrentes ├── métriques └── prochaine action

La bonne suite serait de faire un audit précis de ce qui existe déjà, puis de définir comment les checklists de cycle de vie — SEO, marketing, copywriting, performance, publication, maintenance — se branchent sur TASKS.md, les specs et l’application ShipGlowz.

Il faut donc préserver le flux choisi et compléter ses capacités, pas créer un deuxième système parallèle.

Diane: $000-shipglowz vazy

agent IA: Je route ça vers 001-sg-build, parce qu’on parle d’un chantier produit/ workflow non trivial : auditer le flux existant puis formaliser l’extension “cycles de vie + checklists récurrentes” sans créer de registre parallèle. Je garde TASKS.md, les specs et les trackers existants comme base, et je vais d’abord produire le cadrage exploitable avant toute modification.

agent IA: L’audit confirme le point important : la séparation existe déjà (playbook = méthode, checklist = contrôle réutilisable, test-checklist = preuve exécutée, TASKS.md = travail actif, specs/ = chantier). Je formalise donc un chantier de raccordement des cycles de vie projet à cette architecture, sans ajouter de base ou de registre concurrent.

agent IA: Le premier contrat durable est créé dans shipglowz_data/workflow/specs/. Il reprend explicitement les décisions déjà présentes : pas de nouvelle base, pas de remplacement de TASKS.md, séparation playbook/checklist/ preuve, et projection future vers le TUI puis l’app. Je passe maintenant la readiness gate avant d’envisager l’implémentation.

agent IA: La readiness passe : le contrat est suffisamment précis pour un agent frais, sans décision produit ou technique bloquante. Le lint metadata et le diff check sont propres. Je le marque prêt pour l’exécution du premier lot : contrat de données, template projet, puis fixtures de récurrence et de routage.

agent IA: Je commence par le premier lot réellement utile : le contrat partagé et le template de déclaration de cycle de vie. C’est la pièce qui permettra ensuite aux skills, au TUI et à l’app de lire les mêmes identifiants, cadences et états. Le parser et l’interface viendront après cette base.

agent IA: Le premier lot est en place et vérifié : contrat partagé, template de déclaration projet et checklist de preuve avec 7 scénarios obligatoires. Le parser existant la lit correctement et expose les 7 éléments encore NOT_RUN, donc il ne prétend pas que le système est déjà validé. Je trace cette progression comme une implémentation partielle et je laisse la prochaine étape sur le parser de projection.

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (00:00) : implémentation partielle

Le système existant est maintenant prolongé sans créer de registre parallèle :

- contrat partagé des cycles de vie ; - template de déclaration projet ; - checklist de preuve avec 7 scénarios ; - compatibilité avec TASKS.md, ROADMAP.md, specs/ et les playbooks existants ;

- lint metadata et parsing de checklist validés.

Fichiers ajoutés :

- skills/references/project-lifecycle-checklist-contract.md - templates/project_lifecycle.md - shipglowz_data/workflow/specs/project-lifecycle-checklist-operating- model.md

- shipglowz_data/workflow/test-checklists/project-lifecycle-checklist- operating-model.md

La prochaine pièce est le parser qui calculera automatiquement : aujourd’hui, cette semaine, semaine prochaine, retard, prochaine revue, récurrences et routage vers les trackers. L’application ShipGlowz viendra ensuite consommer ce même modèle.

agent IA: Context compacted

Diane: C'est quoi le template de déclaration de projet et c'est quoi la check list de preuve avec 7 scénarios ?

agent IA: Je vais te montrer précisément à quoi servent ces deux fichiers, et comment ils s’insèrent dans le flux existant de ShipGlowz.

agent IA: Le template de déclaration de projet est le fichier :

templates/project_lifecycle.md

Il sert à déclarer, pour chaque projet :

- son identité et sa phase : discovery, build, launch, operate, paused… - les domaines concernés : technique, SEO, marketing, copywriting, performance, analytics, etc.

- les playbooks et checklists applicables ; - le responsable et la cadence de suivi ; - une projection dérivée : à faire aujourd’hui, cette semaine, la semaine prochaine, en retard, bloqué ;

- les règles de routage vers TASKS.md, ROADMAP.md, les specs ou les preuves.

Ce n’est donc pas encore la liste des tâches concrètes d’un projet. C’est sa carte de pilotage lifecycle, à remplir projet par projet.

La checklist avec 7 scénarios est :

shipglowz_data/workflow/test-checklists/project-lifecycle-checklist- operating-model.md

Elle sert à vérifier que le futur système fonctionne correctement :

1. Une tâche ponctuelle reste terminée après validation. 2. Une tâche récurrente clôture l’occurrence actuelle et crée la suivante. 3. Un audit peut produire des actions techniques et éditoriales aux bons endroits.

4. Une tâche obligatoire sans preuve ne peut pas être considérée comme vérifiée.

5. Un projet en pause suspend correctement ses échéances. 6. Les dates fonctionnent correctement avec les fuseaux horaires. 7. Les skills, le lecteur TUI et la future app voient exactement les mêmes données.

Actuellement, ces 7 scénarios sont NOT_RUN. Ce ne sont pas encore les checklists SEO ou marketing elles-mêmes : ce sont les tests de fonctionnement du modèle qui permettra ensuite de les gérer.

En résumé :

project_lifecycle.md = déclaration et configuration d’un projet.

workflow/checklists/ = checklists métier réutilisables, par exemple SEO.

workflow/test-checklists/ = preuves que le système et ses comportements fonctionnent.

TASKS.md et ROADMAP.md = exécution opérationnelle réelle, que le lifecycle ne remplace pas.

Diane: bien. quelle est la suite ?  ya le domaine de la cyber sécurité aussi qu'on.doit ajouter

agent IA: Oui, la cybersécurité doit être un domaine canonique. Je poursuis le chantier en l’ajoutant au contrat, au template et aux règles de progression, puis je vérifierai qu’il n’existe pas déjà une autre nomenclature contradictoire. J’utilise le flux de build ShipGlowz pour garder cette évolution compatible avec les trackers actuels.

agent IA: Je retiens cybersecurity comme identifiant canonique, affiché « cybersécurité ». C’est préférable à security, qui est déjà utilisé dans ShipGlowz comme champ de niveau d’impact (security_impact) et pourrait créer une confusion entre un domaine de travail et un attribut de risque.

agent IA: Le domaine est maintenant intégré au vocabulaire et au template. Je mets aussi à jour la spec pour que la sécurité soit traitée comme une vraie dimension de progression — pas seulement comme un champ de risque — puis je valide la cohérence documentaire.

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (00:00) : domaine cybersécurité ajouté

Le domaine canonique est maintenant cybersecurity, affiché « cybersécurité ». Il est distinct de security_impact, qui indique seulement le niveau de risque d’un document.

Il est ajouté dans :

- le contrat lifecycle ; - le template de déclaration projet ; - la spec et ses règles de progression.

La suite logique est :

1. Construire le parser qui calcule aujourd’hui, cette semaine, la semaine prochaine, les retards, les échéances et les récurrences.

2. Ajouter les premiers couples playbook/checklist : - cybersécurité avant publication ; - revue périodique des dépendances et vulnérabilités ; - secrets, accès et permissions ; - sauvegarde et récupération ; - préparation incident.

3. Tester que les résultats sont identiques pour les skills, le TUI et la future app.

4. Brancher ensuite les vues ShipGlowz.

Le point important : on n’ajoute pas encore un nouveau tracker. Les actions cybersécurité concrètes iront dans TASKS.md, tandis que les contrôles récurrents resteront définis dans les checklists versionnées.

Diane: ca me plait $001-sg-build

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model

Je continue le chantier actif. La prochaine brique est le parser de projection : il lira une déclaration Markdown versionnée et produira une vue déterministe des échéances, retards, récurrences, blocages et routages, sans créer de registre parallèle.

agent IA: Le format source restera éditable en Markdown : j’ajoute une table canonique Lifecycle Items dans le template, puis un lecteur Python sans dépendance externe. Cela permet aux skills de fonctionner directement depuis GitHub et donne à l’app un read model stable plus tard.

agent IA: Le premier test a révélé un problème de chargement du module quand le test est lancé depuis la racine (tools/ n’est pas automatiquement dans sys.path). Je corrige uniquement ce branchement de test, puis je relance le parser et ses fixtures.

agent IA: Le parser fonctionne maintenant sur les cas de base. Je renforce deux règles importantes avant de le considérer comme une vraie brique : les retards doivent rester visibles dans la vue de la semaine, et un projet en pause doit suspendre les routines récurrentes sans perdre leur historique ni leur politique de reprise.

agent IA: Le parser est validé sur 7 scénarios : ponctuel, récurrent, preuve manquante, fuseau horaire, doublons, projet en pause et visibilité des retards. Je poursuis directement avec le pilote cybersécurité, puisqu’il est maintenant suffisamment cadré pour être ajouté sans décision produit supplémentaire.

agent IA: Le pilote cybersécurité est ajouté et validé avec la même séparation playbook/checklist que le SEO. Le prochain bloc est l’intégration de la projection dans les lecteurs existants, sans modifier leurs responsabilités ni faire de l’app une nouvelle source de vérité.

agent IA: L’intégration TUI a trouvé une incompatibilité de rétrocompatibilité : les fixtures existantes ne contiennent pas encore de bloc lifecycle. Je rends ce bloc optionnel pour les anciens projets, tout en le consommant dès qu’il existe. Les tests de lecture existants restent ainsi valables.

agent IA: Le TUI consomme désormais la même déclaration lifecycle et affiche la phase, les contrôles par domaine, les retards, les preuves manquantes et les routines suspendues. Les tests TUI passent ; la vérification TypeScript dédiée reste limitée par l’absence de tsc installé localement, mais Bun compile et exécute les 26 tests. Je termine la cohérence de routage des skills avant le handoff app.

agent IA: Le routage est cohérent : les findings cybersécurité vont dans le tracker technique, les éventuels contenus publics dans la roadmap éditoriale, et une récurrence ne ferme que son instance datée. Je prépare maintenant le contrat de read model que l’app ShipGlowz pourra consommer plus tard.

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (08:20) : fondation lifecycle implémentée, chantier encore partiel

Le domaine cybersécurité est maintenant intégré de bout en bout :

- contrat lifecycle et template projet ; - playbook + checklist cybersécurité ; - parser des échéances, retards, récurrences, preuves et pauses ; - projection dans le TUI ; - règles de routage vers TASKS.md ou ROADMAP.md ; - read model préparé pour la future app.

Validations : 7 scénarios Python passés · 26 tests TUI passés · 11 artefacts contrôlés par le metadata lint.

La future app n’a pas encore été modifiée : elle consommera le read model existant, ce qui protège la compatibilité Markdown/Git.

Il reste à prouver la parité complète skills/TUI/app et à exécuter la checklist manuelle des 7 scénarios.

1. ✅ Continuer avec la preuve formelle et la parité complète. 2. 📌 Créer ensuite une vraie déclaration lifecycle pour un projet concret.

3. ⏸ Mettre le chantier en pause ici.

agent IA: Context compacted

Diane: 1

agent IA: Je poursuis avec l’option 1 : je vais formaliser la preuve de parité entre la source Markdown, le projection Python et le lecteur TUI, puis exécuter les scénarios de preuve réellement couverts.

agent IA: J’ai trouvé un écart réel à corriger avant de déclarer la parité : le TUI ne projetait pas encore les mêmes champs que le lecteur Python (notamment Evidence: none et les dates locales). Je vais faire converger les deux projections autour du même contrat et ajouter un test de parité sur la fixture canonique.

agent IA: Les deux lecteurs passent maintenant sur la même fixture canonique : 7 tests Python et 9 tests Bun/TUI sont verts. Je vais enregistrer cette preuve dans la checklist ; le scénario de routage mixte restera explicitement non exécuté, car il nécessite encore une preuve d’écriture contrôlée dans TASKS.md et ROADMAP.md.

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (08:35) : preuve de parité validée, chantier encore partiel

La source Markdown est maintenant projetée de façon cohérente par Python et le TUI.

- 6 scénarios sur 7 sont PASS. - Parité vérifiée sur les IDs, états, dates, preuves, récurrences et éléments en retard.

- Le domaine cybersécurité est inclus. - Tests : 7 Python + 28 TUI/Bun réussis. - Metadata lint et git diff --check réussis. - Le typecheck reste bloqué uniquement parce que tsc n’est pas installé.

Checklist mise à jour : shipglowz_data/workflow/test-checklists/project- lifecycle-checklist-operating-model.md

Il reste le scénario mixed-routing : prouver qu’un même audit crée correctement les suivis techniques dans TASKS.md et publics dans ROADMAP.md.

1. Continuer avec cette preuve de routage. 2. Créer une déclaration lifecycle réelle pour un projet. 3. Mettre en pause.

Diane: jai pas compris la suite que tu proposes

agent IA: En clair, on a déjà construit le socle :

- une déclaration Markdown par projet ; - des tâches SEO, marketing, performance, cybersécurité, etc. ; - des tâches ponctuelles ou récurrentes ; - une lecture Python et TUI cohérente ; - un suivi de ce qui est à faire aujourd’hui, cette semaine ou plus tard.

La seule étape proposée ensuite est de tester un cas concret :

> Un audit détecte deux problèmes : > > - une faille technique → tâche dans TASKS.md ; > - une correction de texte public → tâche dans ROADMAP.md.

Ce test vérifie que ShipGlowz sait automatiquement envoyer chaque action au bon endroit, sans créer une deuxième base de tâches.

Donc la suite logique est :

1. prendre un vrai projet ; 2. créer sa déclaration lifecycle ; 3. lui appliquer les playbooks SEO, marketing, performance et cybersécurité ;

4. vérifier que les actions apparaissent correctement dans les trackers existants ;

5. seulement ensuite connecter l’interface de l’application.

Le système actuel est la mécanique interne. L’étape suivante consiste à l’essayer sur un vrai projet pour voir si le modèle correspond bien à ton usage.

Diane: Je ne suis pas sûre que je voyais ça comme ça. Moi je croyais qu'on allait avoir une master checklist ou alors plusieurs checklists pour le SEO parce que le SEO, c'est des étapes qu'on connaît à l'avance qui sont dans un ordre précis. On a juste à les cocher. Donc je pense pas qu'on va encombrer le tracker de tâches avec ça. On va plutôt avoir une checklist par projet et savoir où on en est au niveau du SEO et on va réinitialiser les tâches de temps en temps pour faire un update. Tu comprends ? Je pense.

agent IA: Oui, je comprends mieux : j’avais trop rapproché les checklists du tracker de tâches.

Le modèle voulu serait plutôt :

- une checklist maître par domaine : SEO, cybersécurité, performance, copywriting, etc. ;

- chaque projet possède une instance de ces checklists ; - les étapes sont ordonnées et cochables ; - la checklist indique la progression : 12/ twenty, étape actuelle, étapes bloquées, prochaine étape ;

- les tâches ordinaires ne vont dans TASKS.md que lorsqu’il faut créer une action spécifique, corriger un problème ou déléguer quelque chose ;

- à chaque nouveau cycle SEO, on réinitialise une nouvelle instance tout en conservant l’historique de la précédente.

Donc :

Checklist SEO du projet → progression structurée et persistante

TASKS.md → actions exceptionnelles ou concrètes générées par la checklist

Historique → anciennes versions/cycles de la checklist

La suite n’est donc pas de tester davantage le routage vers TASKS.md. Il faut d’abord corriger le modèle pour faire des checklists versionnées par projet, avec des cycles et une progression dédiée.

agent IA: You’re continuing from this point in a new conversation

Diane: $007-sg-content capture-full-conversation

Je veux récupérer toute la conversation ShipGlowz visible dans ce pane, en remontant le plus haut possible dans le scrollback.

La capture précédente a ciblé le mauvais pane. Le bon pane était : - session tmux : 0 - fenêtre : 6 - pane : 0:6.1

Ne capture pas le pane 0:7.1.

Commence par vérifier que le début contient bien nos échanges sur : - les masters ; - les instances par projet ; - les cycles ; - les domaines SEO, cybersécurité, marketing, copywriting, performance, etc.

Capture tout le scrollback disponible, sans résumer ni nettoyer. Conserve le fichier brut dans : shipglowz_data/workflow/conversations/

Ne remplace aucun fichier existant. Crée un nouveau fichier horodaté.

Après la capture, vérifie : 1. le premier message récupéré ; 2. le dernier message ; 3. le nombre de lignes ; 4. que la conversation ne commence pas au milieu d’une réponse si le scrollback permet de remonter plus haut.

Après cette capture, utilise seulement :

$007-sg-content clean-transcript <chemin-du-fichier>

pour obtenir la version lisible Diane: / agent IA:. Ne lance pas le nettoyage avant d’avoir conservé la version brute.

agent IA: J’utilise 007-sg-content en mode capture-full-conversation, avec le captureur tmux interne 800. Je vais d’abord vérifier les règles de capture et le pane 0:6.1, puis conserver une copie brute horodatée avant tout nettoyage.

agent IA: Explored agent IA: Résultat : Read canonical-paths.md, shipglowz-owned-preflight.md, content- router.md, SKILL.md (800-tmux-capture-conversation skill), SKILL.md (801- clean- conversation-transcript skill), reporting-contract.md, capture_tmux_conversation.sh

agent IA: Ran tmux list-windows -t 0 -F '#{window_index} #{window_name} #{window_panes} #{window_active}' && tmux list-panes -t 0:6 -F '#{session_name}:#{window_index}.#{pane_index} #{pane_title} … +2 lines agent IA: Résultat : 1 bibli 1 0 rg-landingp 1 0 … +6 lines (ctrl + t to view transcript) 0:6.1 ⠏ 019fadf8-edcc-70c1-b8c0-b748966e8859 | shipglowz 1 0:6.1 $ ⠏ 019fadf8-edcc-70c1-b8c0-b748966e8859 | shipglowz

agent IA: Le pane demandé existe bien : 0:6.1, fenêtre 6, pane 1. Je vérifie maintenant son début et la présence des échanges sur les masters, instances, cycles et domaines avant d’écrire le fichier brut.

agent IA: Ran tmux capture-pane -t 0:6.1 -p -J -S - | head -n 140; tmux capture-pane -t 0:6.1 -p -J -S - | rg -n -i 'master|instance|cycle|seo| cybersécurité|cybersecurity|marketing|copywriting|performance' | head … +1 lines └ , performance, tâches ponctuelles, tâches constantes et tâches … +179 lines (ctrl + t to view transcript) cybersécurité et 163:    séparation SEO technique/contenu sont présents.

agent IA: Ran SHIPFLOW_ROOT=/home/claude/shipglowz skills/800-tmux-capture-conversation/scripts/ capture_tmux_conversation.sh --preset shipflow --session 0 --tab 6 … +1 lines agent IA: Résultat : Title: Conversation 000-shipglowz - vazy Destination: /home/claude/shipglowz/shipglowz_data/workflow/ … +8 lines (ctrl + t to view transcript) Neovim command: cd /home/claude/shipglowz/shipglowz_data/workflow/ conversations && nvim conversation-000-shipglowz-vazy-20260729-130406.md

Diane: Use /skills to list available skills

gpt-5.6-luna medium · main · Context 77% left · ~/shipglowz
