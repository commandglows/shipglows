# Conversation ShipGlows — masters, instances et cycles

- Source brute : `conversation-shipglows-masters-instances-et-cycles.md`
- tmux source : session `0`, fenêtre `6`, pane `0:6.1`
- Capture brute : `2026-07-29 12:50:58 UTC`
- Note : le scrollback disponible commençait au milieu d’une réponse ; aucun contenu antérieur n’était récupérable dans ce pane.

/* CONTENT ANGLES
 * Suggested title: De la checklist maître au pilotage par projet dans ShipGlows
 * Strongest angle: Séparer les méthodes réutilisables, les instances de checklist par projet et les tâches d’exécution.
 * Possible formats: internal doc, product note, architecture note, tutorial, changelog
 * Notes: La conversation établit la distinction entre SEO technique et contenu SEO, puis définit les cycles et l’historique.
 */

Diane: Je veux savoir s’il existe déjà des projets qui gèrent des cycles de vie techniques et marketing avec SEO, marketing, copywriting, performance, tâches ponctuelles, tâches constantes et tâches cycliques.

agent IA: Une recherche a comparé Linear, ClickUp, Plane et Semrush. Aucun ne fournit exactement le système recherché. Linear est bon pour les projets et cycles, ClickUp pour les tâches récurrentes et tableaux de bord, Plane pour une base open source, et Semrush pour le suivi SEO cyclique.

agent IA: Le besoin ressemble à un système de pilotage de projets, avec plusieurs natures de travail : ponctuel, récurrent, cyclique, déclenché par événement, mesuré en continu et décisionnel. Chaque projet devrait exposer sa phase, ses objectifs, ses domaines, sa progression, ses blocages et ses prochaines actions.

Diane: Le modèle s’exprimera dans l’app ShipGlows. Les fichiers Markdown doivent servir de support aux checklists afin d’être versionnés sur GitHub et utilisables aussi directement par les skills, sans passer par l’application.

agent IA: Le Markdown doit rester la source canonique. L’app ShipGlows sera une interface de projection plus agréable, et les skills consommeront les mêmes checklists. Le système existant de tâches et ses trackers ne doivent pas être remplacés.

Diane: Tous les projets ont des cycles de vie techniques et marketing. Certaines actions sont cochées une fois, d’autres sont constantes ou cycliques. Il faut savoir où en est chaque projet et quoi faire aujourd’hui ou la semaine prochaine.

agent IA: Le modèle proposé distingue les playbooks réutilisables, les checklists réutilisables, les instances concrètes par projet, les preuves exécutées et les trackers existants. Les échéances, récurrences, preuves et prochaines occurrences doivent rester traçables.

Diane: On fait déjà quelque chose de similaire avec les tâches ShipGlows. Il faut retrouver le flux existant et éviter de créer une deuxième base ou un registre parallèle.

agent IA: `shipglows_data/workflow/TASKS.md` reste le tracker technique actif, `ROADMAP.md` reste le tracker éditorial, les specs restent le registre des chantiers, et les checklists restent des contrôles de progression. Le modèle ne doit pas recopier toutes les cases dans le tracker.

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

agent IA: La checklist existante a été retrouvée dans `shipglows_data/workflow/checklists/seo-charge-referencement-web-checklist.md`, avec son playbook associé. Elle contenait déjà l’intention de recherche, les mots-clés, les clusters, l’indexabilité, les sitemaps, les données structurées, Search Console, la priorisation et les preuves.

Diane: Ici, on veut gérer le SEO technique. La création de contenu SEO et les mots-clés seront gérés dans un autre projet.

agent IA: La checklist SEO active est recentrée sur le SEO technique : périmètre et environnements, crawl, indexation, robots, sitemaps, canonicals, codes HTTP, redirections, rendu JavaScript, métadonnées techniques, données structurées, hreflang, performance, Core Web Vitals et vérification post-déploiement.

agent IA: La recherche de mots-clés, les intentions, les clusters, la stratégie éditoriale et la création de contenu sont explicitement sorties de ce périmètre.

Diane: Est-ce que le reste de l’ancienne checklist a été migré ou supprimé ?

agent IA: Il avait été retiré de la checklist technique sans être encore migré. Cette décision a ensuite été corrigée : l’ancienne matière est conservée dans une archive dédiée pour migration future.

Diane: Il ne faut pas supprimer le travail réalisé. Récupère l’ancien fichier et renomme-le comme « à migrer plus tard » pour le SEO non technique.

agent IA: L’ancienne checklist est maintenant conservée dans `shipglows_data/workflow/checklists/seo-content-strategy-a-migrer-plus-tard-checklist.md`. Elle contient les mots-clés, intentions, clusters, contenu, cannibalisation, priorisation et stratégie éditoriale. Elle est marquée `draft` et ne sert pas de checklist SEO technique active.

agent IA: Une instance projet est représentée par `templates/project_checklist_instance.md`. Elle référence la version de la master checklist, un `cycle_id`, le statut, la progression, la phase courante, le prochain contrôle, les preuves et la clôture du cycle. Un nouveau cycle crée une nouvelle instance au lieu d’effacer l’ancienne.

agent IA: Le lecteur `tools/shipglows_checklist_instance_status.py` projette une instance sans écrire dans `TASKS.md`. Le pilote SEO technique affiche une progression `2/5`, la phase `Crawl et indexation`, le prochain contrôle et un blocage lié aux preuves Search Console.

agent IA: Les validations ont réussi : tests Python du cycle de vie et des instances, tests TUI, metadata lint et vérification Git. L’intégration des instances dans le TUI et l’application ShipGlows reste la prochaine étape du chantier.
