# Conversation — project lifecycle checklist, masters et cycles — capture complète

- Captured at: `2026-07-29 12:15:22 UTC`
- tmux session: `0`
- tmux source: `current pane`
- tmux window index: `:6`
- tmux pane index: `.1`
- tmux window name: `$`
- capture mode: `scrollback`
- prompt count: `23`
- first prompt: `1`
- last prompt: `Find and fix a bug in @filename`

/home/claude/home/claude/home/claude

  ShipGlows pourra consommer plus tard.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (08:20) : fondation lifecycle implémentée, chantier
  encore partiel

  Le domaine cybersécurité est maintenant intégré de bout en
  bout :

  - contrat lifecycle et template projet ;
  - playbook + checklist cybersécurité ;
  - parser des échéances, retards, récurrences, preuves et
    pauses ;

  - projection dans le TUI ;
  - règles de routage vers TASKS.md ou ROADMAP.md ;
  - read model préparé pour la future app.

  Validations : 7 scénarios Python passés · 26 tests TUI passés ·
  11 artefacts contrôlés par le metadata lint.

  La future app n’a pas encore été modifiée : elle consommera le
  read model existant, ce qui protège la compatibilité Markdown/
  Git.

  Il reste à prouver la parité complète skills/TUI/app et à
  exécuter la checklist manuelle des 7 scénarios.

  1. ✅ Continuer avec la preuve formelle et la parité complète.
  2. 📌 Créer ensuite une vraie déclaration lifecycle pour un
     projet concret.

  3. ⏸ Mettre le chantier en pause ici.

• Context compacted


› 1


• Je poursuis avec l’option 1 : je vais formaliser la preuve de
  parité entre la source Markdown, le projection Python et le
  lecteur TUI, puis exécuter les scénarios de preuve réellement
  couverts.

──────────────────────────────────────────────────────────────────

• J’ai trouvé un écart réel à corriger avant de déclarer la
  parité : le TUI ne projetait pas encore les mêmes champs que le
  lecteur Python (notamment Evidence: none et les dates locales).
  Je vais faire converger les deux projections autour du même
  contrat et ajouter un test de parité sur la fixture canonique.

──────────────────────────────────────────────────────────────────

• Les deux lecteurs passent maintenant sur la même fixture
  canonique : 7 tests Python et 9 tests Bun/TUI sont verts. Je
  vais enregistrer cette preuve dans la checklist ; le scénario de
  routage mixte restera explicitement non exécuté, car il
  nécessite encore une preuve d’écriture contrôlée dans TASKS.md
  et ROADMAP.md.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (08:35) : preuve de parité validée, chantier encore
  partiel

  La source Markdown est maintenant projetée de façon cohérente
  par Python et le TUI.

  - 6 scénarios sur 7 sont PASS.
  - Parité vérifiée sur les IDs, états, dates, preuves,
    récurrences et éléments en retard.

  - Le domaine cybersécurité est inclus.
  - Tests : 7 Python + 28 TUI/Bun réussis.
  - Metadata lint et git diff --check réussis.
  - Le typecheck reste bloqué uniquement parce que tsc n’est pas
    installé.

  Checklist mise à jour : shipglows_data/workflow/test-checklists/
  project-lifecycle-checklist-operating-model.md

  Il reste le scénario mixed-routing : prouver qu’un même audit
  crée correctement les suivis techniques dans TASKS.md et publics
  dans ROADMAP.md.

  1. Continuer avec cette preuve de routage.
  2. Créer une déclaration lifecycle réelle pour un projet.
  3. Mettre en pause.


› jai pas compris la suite que tu proposes


• En clair, on a déjà construit le socle :

  - une déclaration Markdown par projet ;
  - des tâches SEO, marketing, performance, cybersécurité, etc. ;
  - des tâches ponctuelles ou récurrentes ;
  - une lecture Python et TUI cohérente ;
  - un suivi de ce qui est à faire aujourd’hui, cette semaine ou
    plus tard.

  La seule étape proposée ensuite est de tester un cas concret :

  > Un audit détecte deux problèmes :
  >
  > - une faille technique → tâche dans TASKS.md ;
  > - une correction de texte public → tâche dans ROADMAP.md.

  Ce test vérifie que ShipGlows sait automatiquement envoyer
  chaque action au bon endroit, sans créer une deuxième base de
  tâches.

  Donc la suite logique est :

  1. prendre un vrai projet ;
  2. créer sa déclaration lifecycle ;
  3. lui appliquer les playbooks SEO, marketing, performance et
     cybersécurité ;

  4. vérifier que les actions apparaissent correctement dans les
     trackers existants ;

  5. seulement ensuite connecter l’interface de l’application.

  Le système actuel est la mécanique interne. L’étape suivante
  consiste à l’essayer sur un vrai projet pour voir si le modèle
  correspond bien à ton usage.


› Je ne suis pas sûre que je voyais ça comme ça. Moi je croyais
  qu'on allait avoir une master checklist ou alors plusieurs
  checklists pour le SEO parce que le SEO, c'est des étapes qu'on
  connaît à l'avance qui sont dans un ordre précis. On a juste à
  les cocher. Donc je pense pas qu'on va encombrer le tracker de
  tâches avec ça. On va plutôt avoir une checklist par projet et
  savoir où on en est au niveau du SEO et on va réinitialiser les
  tâches de temps en temps pour faire un update. Tu comprends ?
  Je pense.


• Oui, je comprends mieux : j’avais trop rapproché les checklists
  du tracker de tâches.

  Le modèle voulu serait plutôt :

  - une checklist maître par domaine : SEO, cybersécurité,
    performance, copywriting, etc. ;

  - chaque projet possède une instance de ces checklists ;
  - les étapes sont ordonnées et cochables ;
  - la checklist indique la progression : 12/ twenty, étape
    actuelle, étapes bloquées, prochaine étape ;

  - les tâches ordinaires ne vont dans TASKS.md que lorsqu’il faut
    créer une action spécifique, corriger un problème ou déléguer
    quelque chose ;

  - à chaque nouveau cycle SEO, on réinitialise une nouvelle
    instance tout en conservant l’historique de la précédente.

  Donc :

  Checklist SEO du projet
    → progression structurée et persistante

  TASKS.md
    → actions exceptionnelles ou concrètes générées par la
    checklist

  Historique
    → anciennes versions/cycles de la checklist

  La suite n’est donc pas de tester davantage le routage vers
  TASKS.md. Il faut d’abord corriger le modèle pour faire des
  checklists versionnées par projet, avec des cycles et une
  progression dédiée.


› voila ! !  je pense que cest le bon modele


• Oui, on acte ce modèle.

  Le cœur de ShipGlows sera :

  1. des checklists maîtres versionnées en Markdown ;
  2. une instance de chaque checklist par projet ;
  3. une progression structurée par étapes et sous-étapes ;
  4. des cycles réinitialisables avec historique conservé ;
  5. des tâches séparées, uniquement pour les actions concrètes
     générées par la checklist.

  La prochaine étape logique est donc de refondre le contrat
  actuel autour de cette distinction, puis de créer la première
  vraie checklist maître SEO avec ses étapes ordonnées.


› je croyais qu on l'avait deja faite la checklist master seo
  fait une recherche


• Je vais vérifier d’abord dans le dépôt si une checklist maître
  SEO existe déjà, puis je te dirai exactement où elle se trouve
  et si elle correspond bien au modèle qu’on vient de valider.

──────────────────────────────────────────────────────────────────

• Tu avais raison : la checklist maître SEO existe déjà.

  Elle se trouve ici :

  - shipglows_data/workflow/checklists/seo-charge-referencement-
    web-checklist.md

  - shipglows_data/workflow/playbooks/seo-charge-referencement-
    web-playbook.md

  - skills/406-sg-seo/references/seo-audit-workflow.md

  La checklist contient déjà les grandes étapes :

  - intention de recherche ;
  - mots-clés et clusters ;
  - arborescence et maillage ;
  - titles, meta descriptions, Hn ;
  - indexabilité ;
  - duplications et cannibalisation ;
  - rendu JavaScript ;
  - sitemap ;
  - données structurées ;
  - Search Console et GA4 ;
  - priorisation ;
  - attribution aux responsables ;
  - vérification post-changement ;
  - traçabilité des preuves.

  Ce qui manque, ce n’est donc pas la checklist maître. Ce qui
  manque, c’est son utilisation par projet :

  Checklist maître SEO
          ↓
  Instance SEO du projet A
          ↓
  Progression, étapes cochées, blocages, preuves
          ↓
  Nouveau cycle SEO plus tard

  La checklist actuelle est surtout une checklist réutilisable
  d’audit. Il faut maintenant lui ajouter un format d’instance
  projet et de cycle, sans la transformer en liste de tâches.


› en fait ici on veut gerer le seo technique. en ce qui concerne
  la creation de contenu seo et mots clefs je le gererais dans un
  autre projet


• Oui, c’est une distinction importante.

  Dans ShipGlows, la checklist SEO devra couvrir uniquement le SEO
  technique :

  - crawlabilité et indexation ;
  - robots.txt, sitemap, canonicals ;
  - codes HTTP, redirections et erreurs ;
  - structure des URLs ;
  - rendu JavaScript ;
  - métadonnées techniques ;
  - données structurées ;
  - hreflang et internationalisation ;
  - maillage technique ;
  - performance et Core Web Vitals ;
  - Search Console, logs et monitoring ;
  - vérification après mise en production.

  Elle ne devra pas gérer :

  - la recherche de mots-clés ;
  - les intentions de recherche ;
  - les clusters ;
  - la stratégie éditoriale ;
  - la rédaction ou l’optimisation de contenu.

  La checklist existante mélange actuellement ces deux périmètres.
  Il faudra donc la réorienter vers une checklist maître
  technical-seo, tandis que ton autre projet gérera la partie
  contenu SEO et mots-clés.

  Le modèle deviendra donc :

  Projet
  ├── Checklist SEO technique
  ├── Checklist cybersécurité
  ├── Checklist performance
  └── Projet séparé : stratégie et contenu SEO

  Les checklists techniques suivront l’état du projet et ses
  cycles. Le projet contenu aura ses propres cycles éditoriaux et
  ses propres checklists.


› exact


■ Conversation interrupted - tell the model what to do
differently. Something went wrong? Hit `/feedback` to report the
issue.


› exact $001-sg-build tu peux avancer ?


• J’utilise $001-sg-build pour continuer le chantier existant. Je
  vais corriger le périmètre SEO vers le SEO technique, préserver
  la checklist maître existante, puis créer le modèle d’instance
  par projet et de cycles réinitialisables.

──────────────────────────────────────────────────────────────────

• La recherche confirme que la checklist maître existait, mais
  elle mélangeait SEO technique et stratégie de contenu. Je vais
  donc la conserver comme artefact canonique, la recentrer sur le
  SEO technique, et ajouter le format d’instance projet/cycle
  autour d’elle.

──────────────────────────────────────────────────────────────────

• Le modèle est maintenant posé. Pour qu’il soit réellement
  utilisable par l’application, j’ajoute le petit lecteur
  d’instances : il calculera la progression d’un cycle, la phase
  courante, les contrôles bloquants et le prochain contrôle, sans
  écrire dans TASKS.md.

──────────────────────────────────────────────────────────────────

• Le pilote fonctionne : une instance SEO technique affiche 2/5,
  la phase courante Crawl et indexation, le prochain contrôle et
  le blocage Search Console. Le lecteur ne génère aucune tâche
  automatiquement. Je termine par la vérification globale et la
  mise à jour de la trace du chantier.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (08:47) : modèle corrigé et pilote SEO technique
  implémentés

  J’ai avancé dans le bon sens :

  - La checklist maître SEO existante est maintenant limitée au
    SEO technique.

  - Les mots-clés, la stratégie éditoriale et la création de
    contenu sont explicitement hors périmètre.

  - Ajout d’un modèle d’instance par projet et par cycle :
    templates/project_checklist_instance.md

  - Ajout du lecteur de progression : tools/
    shipglows_checklist_instance_status.py

  - Pilote SEO technique : progression 2/5, phase courante,
    prochain contrôle et blocage visibles.

  - Le lecteur ne transforme pas les cases non cochées en tâches
    dans TASKS.md.

  - 9 tests Python, 28 tests TUI et metadata lint réussis.

  La checklist maître est ici : shipglows_data/workflow/
  checklists/seo-charge-referencement-web-checklist.md

  La prochaine étape est de faire apparaître ces instances et leur
  progression dans le TUI puis dans l’app ShipGlows.

  1. Continuer l’intégration dans l’interface.
  2. Créer une vraie instance SEO technique pour un projet réel.
  3. Mettre en pause.

• Context compacted


› $000-shipglows termine librement sauf si tu as des questions


• J’utilise 000-shipglows comme point d’entrée, puis je poursuis
  le chantier déjà engagé sous 001-sg-build. Je vais terminer
  l’intégration lisible des instances de checklist, vérifier la
  cohérence du modèle, puis te rendre un état propre sans commit
  ni push.

──────────────────────────────────────────────────────────────────

• Le modèle est maintenant cohérent sur le fond. Je fais la
  dernière passe utile : l’interface doit afficher la progression
  d’une instance SEO comme une projection de la checklist, sans la
  mélanger aux tâches. Je corrige aussi la distinction entre le
  statut du fichier et le statut de progression, qui sinon prête à
  confusion.

──────────────────────────────────────────────────────────────────

• La projection fonctionne maintenant : une instance affiche son
  cycle, son avancement, sa phase courante, son prochain contrôle
  et ses blocages dans la vue Lifecycle, tandis que TASKS.md reste
  réservé aux actions concrètes. Les tests Python et TUI passent ;
  je termine par la validation documentaire et la mise à jour du
  chantier.

──────────────────────────────────────────────────────────────────

• La validation fonctionnelle et documentaire est verte. Le seul
  contrôle non exécutable reste le typecheck TUI, déjà limité par
  l’environnement : le binaire tsc n’est pas installé localement ;
  je n’installe rien automatiquement pour ne pas modifier
  l’environnement du projet. Je fais encore l’état final du
  chantier et je m’arrête proprement.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (14:??) : partiellement terminé

  Le modèle est en place :

  - checklist master SEO technique séparée du SEO contenu ;
  - instances par projet et par cycle, versionnées en Markdown ;
  - progression, phase, prochain contrôle et preuves ;
  - tâches séparées des contrôles ;
  - projection intégrée au TUI et au read-model de l’app ;
  - cyber sécurité conservée comme domaine distinct.

  ✅ Tests Python : 9 réussis · TUI : 29 réussis · metadata lint
  et diff valides.
  ⚠️  Typecheck non exécuté : tsc absent de l’environnement. Aucun
  commit ni push effectué.

  1. ✅ Continuer avec la création d’une vraie instance SEO pour
     un projet.

  2. 🧭 Réorienter vers l’interface applicative.
  3. ⏸ Mettre en pause.


› $000-shipglows termine librement sauf si tu as des questions


• Je reprends le chantier sans te redemander de choix. Je vérifie
  l’état réel laissé par la passe précédente, puis je clôture ce
  qui peut l’être proprement ; la seule limite connue est le
  typecheck si l’environnement n’a toujours pas tsc.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (15:51) : terminé fonctionnellement

  Le modèle est finalisé : masters Markdown, instances par projet/
  cycle, progression SEO technique, preuves, historique, cyber
  sécurité et projection TUI/app séparée des tâches.

  ✅ 29 tests TUI · 9 tests Python · metadata lint · diff validés.
  ⚠️  Seule limite : tsc n’est pas installé localement. Aucun commit
  ni push effectué.


› Je veux bien mais moi tu me parles de SEO. Mais il n'y a pas
  que le SEO qu'on gère. On avait dit depuis le début qu'il y
  avait d'autres dimensions.


• Tu as raison : j’ai présenté le pilote SEO comme si c’était le
  produit final. Le modèle cible doit être transversal ; le SEO
  technique n’est qu’une checklist parmi d’autres. Je vais
  corriger le vocabulaire et les artefacts pour que l’interface et
  le read-model affichent les domaines actifs par projet, pas
  seulement le SEO.

──────────────────────────────────────────────────────────────────

• Tu as raison. J’ai confondu le pilote utilisé pour valider le
  système avec le système complet.

  Le modèle est bien transversal et prévoit notamment :

  - technique ;
  - cybersécurité ;
  - SEO technique ;
  - performance ;
  - analytics ;
  - marketing ;
  - copywriting ;
  - lancement ;
  - production ;
  - maintenance.

  J’ai corrigé la documentation et ajouté une preuve TUI avec deux
  domaines distincts : SEO technique et cybersécurité. Le système
  n’est donc plus câblé autour du SEO ; il projette toutes les
  instances trouvées dans chaque projet.

  Ce qui reste à construire progressivement, ce sont les masters
  détaillés de performance, marketing, copywriting, etc. Je ne
  vais pas inventer leurs contrôles sans les définir correctement.

• Context compacted


› $000-shipglows exactement reflechis y


• Je reprends le problème au niveau du modèle global, pas au
  niveau d’une checklist SEO isolée. Je route ce chantier vers
  001-sg-build, puis je vais vérifier que les dimensions sont
  réellement représentées comme des domaines indépendants, avec
  leurs propres masters et instances, sans polluer le tracker de
  tâches.

──────────────────────────────────────────────────────────────────

• Le point faible est identifié : le contrat cite bien plusieurs
  domaines, mais la documentation ne distingue pas encore
  clairement « domaine pris en charge par l’architecture » et «
  master déjà défini ». Je corrige cette ambiguïté maintenant,
  sans inventer de fausses étapes marketing ou performance et sans
  transformer TASKS.md en miroir des checklists.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (17:55) : modèle transversal clarifié

  Tu as raison : le SEO n’est qu’un domaine parmi d’autres.

  Le modèle couvre maintenant séparément :

  - technique
  - cybersécurité
  - SEO technique
  - performance
  - analytics
  - marketing
  - copywriting
  - contenu
  - lancement
  - production
  - maintenance

  Chaque domaine pourra avoir son propre master, ses instances par
  projet et ses cycles. TASKS.md restera réservé aux actions
  concrètes, pas au suivi global des contrôles.

  J’ai aussi ajouté la règle importante : un domaine applicable
  sans master défini apparaît comme needs_review, jamais comme
  terminé.

  Vérifications passées : 9 tests Python, 29 tests TUI, metadata
  lint et git diff --check.

  Le chantier reste partiel tant que les masters détaillés ne sont
  pas tous écrits. Suite possible :

  1. Définir le master performance.
  2. Définir les masters marketing/copywriting.
  3. Passer à la vérification formelle du modèle actuel.


› Est-ce que tu peux m'expliquer c'est quoi le master, les
  instances par projet et les cycles ? Je n'ai pas compris.


• 🧱 CHANTIER (local) : comprendre le modèle
  🎯 VERDICT (17:56) : expliqué

  Imagine une recette de cuisine :

  - Le master est la recette officielle.
  - L’instance par projet est la recette utilisée pour un projet
    précis.

  - Le cycle est une nouvelle réalisation de cette recette à une
    période donnée.

  Exemple avec le SEO technique :

  Le master contient les étapes générales :

  1. Vérifier robots.txt
  2. Vérifier le sitemap
  3. Vérifier les balises importantes
  4. Vérifier les erreurs 404
  5. Vérifier les performances
  6. Vérifier l’indexation

  Pour le projet site-restaurant, on crée une instance :

  site-restaurant-seo-2026-07.md

  Elle indique :

  - les contrôles terminés ;
  - ceux qui restent ;
  - les preuves ;
  - les blocages ;
  - la progression, par exemple 4/6.

  Le cycle correspond à une exécution de la checklist :

  - launch-2026-07 : contrôle avant publication ;
  - monthly-2026-08 : contrôle mensuel ;
  - quarterly-2026-Q4 : contrôle trimestriel.

  On ne réinitialise jamais l’ancienne instance. On en crée une
  nouvelle, afin de conserver l’historique.

  Donc :

  Master SEO technique
          ↓
  Projet A — cycle lancement — terminé
  Projet A — cycle mensuel août — en cours
  Projet B — cycle lancement — bloqué

  Les tâches ne contiennent que les actions concrètes découvertes
  pendant le contrôle, par exemple :

  > Corriger la redirection de /ancienne-page.

  La checklist répond à : « où en est le domaine ? »
  La tâche répond à : « quelle action précise faut-il exécuter ? »


› Bien vu ! Tu peux terminer la rédaction des autres masters s'il
  te plaît. Si tu veux, utilise des agents en parallèle.


• Oui. Je vais compléter les masters manquants par domaine, en
  gardant un master par responsabilité et en séparant clairement
  les contrôles techniques des contrôles marketing, copywriting et
  contenu. Je n’utiliserai pas de parallélisme improvisé : les
  lots ne sont pas indépendants tant que le contrat commun n’est
  pas stabilisé, et je garderai une structure homogène pour que
  l’app puisse tous les lire de la même manière.

──────────────────────────────────────────────────────────────────

• Je vais créer les paires playbook + checklist master pour les
  domaines encore absents : performance, analytics, marketing,
  copywriting, contenu éditorial, production et maintenance. Le
  contenu SEO restera explicitement séparé du SEO technique.
  Chaque master aura des identifiants stables, une règle de
  complétion et une cadence applicable.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (17:59) : masters rédigés

  J’ai ajouté les 7 paires playbook + checklist master
  manquantes :

  - performance
  - analytics
  - marketing
  - copywriting
  - contenu éditorial
  - production
  - maintenance

  Chaque master possède :

  - son périmètre ;
  - ses étapes ordonnées ;
  - ses contrôles avec identifiants stables ;
  - sa règle de complétion ;
  - ses exceptions ;
  - sa cadence et ses preuves attendues.

  Le SEO technique reste limité à crawl, indexation, rendu,
  métadonnées et performance technique. Les mots-clés, la
  stratégie éditoriale et la création de contenu restent séparés.

  Validation passée : 17 fichiers metadata lintés, 9 tests Python
  réussis, git diff --check réussi.

  Les masters marketing, copywriting et contenu sont des premières
  versions opérationnelles : ils pourront être affinés lorsqu’ils
  seront utilisés sur un vrai projet.

  Suite logique :

  1. Créer les premières instances pour un projet réel.
  2. Ajouter les masters dans l’interface de statut du projet.
  3. Faire la vérification finale du chantier.


› 1


• Je lance la première étape : créer les premières instances à
  partir des masters. Je vais d’abord repérer le projet gouverné
  déjà présent dans le dépôt et ses domaines déclarés, puis
  générer les instances sans inventer de progression ni cocher de
  contrôles.

──────────────────────────────────────────────────────────────────

• 🚧 CHANTIER (local) : premières instances de projet
  🎯 VERDICT (18:01) : choix du projet requis

  Le registre contient plusieurs projets. Je recommande de
  commencer par jarrettelacoke.fr, car il possède déjà le
  périmètre le plus complet : technique, design, copy, SEO, GTM,
  dépendances et performance.

  1. jarrettelacoke.fr — recommandé
  2. nantes-gratuit
  3. Un autre projet du registre — indique-moi son nom

  Dès que le projet est choisi, je créerai ses instances par
  domaine avec tous les contrôles à not_started, sans inventer de
  progression.


› ok


• Je prends jarrettelacoke.fr comme projet cible, conformément à
  la recommandation précédente. Je vérifie d’abord son corpus de
  gouvernance et ses surfaces réellement déclarées, puis je crée
  les instances dans son projet, toutes initialisées à
  not_started.

──────────────────────────────────────────────────────────────────

• 🚧 CHANTIER (local) : premières instances de projet
  🎯 VERDICT (18:03) : projet inaccessible

  Le projet recommandé jarrettelacoke.fr correspond à /home/
  claude/quit-coke, mais ce dossier n’existe pas dans
  l’environnement actuel. Je ne peux donc pas créer ses instances
  au mauvais endroit.

  1. Tu me redonnes le chemin actuel du projet.
  2. Tu choisis un projet présent dans cet environnement.
  3. Tu m’autorises à créer une fiche d’instance ShipGlows
     provisoire uniquement dans ce dépôt, sans la rattacher à un
     vrai projet.


› on la deja choisi oui


• Tu as raison : le projet choisi est bien jarrettelacoke.fr.

  Le problème n’est pas le choix, c’est que son chemin
  enregistré /home/claude/quit-coke n’est pas présent dans
  l’environnement actuel. Je garde donc ce projet comme cible et
  je ne te le redemanderai pas.

  Dès que le dépôt est accessible, je créerai ses instances
  initiales par domaine, toutes en not_started.


› Il est déjà accessible sur le serveur et on a déjà créé les
  instances normalement dans une autre conversation. Regarde.


• Je vais vérifier les emplacements réellement disponibles sur le
  serveur, y compris les autres corpus shipglows_data et les
  instances déjà créées, au lieu de me fier à l’ancien registre de
  projets. Je chercherai par project_id, nom de domaine et
  cycle_id pour retrouver la conversation précédente dans les
  artefacts.

──────────────────────────────────────────────────────────────────

• Oui, tu avais raison : les instances ont déjà été créées dans
  une autre conversation.

  Je les ai retrouvées ici :

  /home/claude/jarretelacoke/shipglows_data/workflow/checklist-
  instances/

  Il y en a déjà 7, toutes pour le cycle launch-2026-07 :

  - performance
  - analytics
  - marketing
  - copywriting
  - contenu
  - production
  - maintenance

  Elles sont bien initialisées à 0/total, sans contrôles cochés
  artificiellement.

  Il reste seulement à normaliser/créer les instances pour :

  - technique
  - cybersécurité
  - SEO technique
  - lancement

  🧱 CHANTIER (local) : retrouver les instances jarretelacoke.fr
  🎯 VERDICT (18:05) : instances existantes retrouvées


› vazy


• J’ai retrouvé les 7 instances existantes. Je complète maintenant
  les quatre lanes manquantes, sans recréer celles qui existent
  déjà : SEO technique, cybersécurité, lancement et technique.
  Pour la lane technique, je vais utiliser un master technique
  explicite afin de ne pas détourner la checklist de lancement.

──────────────────────────────────────────────────────────────────

• La recherche confirme que la conversation précédente a bien créé
  7 instances dans le bon dépôt : /home/claude/jarretelacoke. Je
  complète les quatre manquantes et je vais aussi normaliser les
  identifiants stables des masters concernés, car c’est nécessaire
  pour que les instances restent lisibles par l’app et
  historisables.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (18:10) : instances complétées

  Tu avais raison : les 7 instances existaient déjà dans /home/
  claude/jarretelacoke.

  J’ai ajouté les 4 manquantes :

  - technique — 0/10
  - cybersécurité — 0/15
  - SEO technique — 0/28
  - lancement — 0/9

  Le projet possède maintenant 11 instances pour le cycle launch-
  2026-07. Aucun contrôle n’a été coché artificiellement.

  Le parser confirme pour chaque instance :

  - cycle correct ;
  - progression 0/total ;
  - statut not_started ;
  - prochain contrôle identifiable ;
  - aucun blocage inventé.

  Le modèle est maintenant prêt pour commencer l’exécution réelle
  des contrôles sur jarretelacoke.fr.

• Context compacted


› comment vas t elle se passer cette execution?


• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (18:22) : l’exécution se fera par contrôles
  successifs, projet par projet

  Le fonctionnement sera le suivant :

  1. On choisit un projet et un cycle
     Exemple : jarretelacoke.fr — cycle launch-2026-07.

  2. Chaque domaine possède sa propre instance
     Technique, cybersécurité, SEO technique, performance,
     analytics, marketing, copywriting, contenu, production,
     maintenance et lancement.

  3. On exécute les contrôles dans l’ordre prévu

     Pour chaque contrôle, on vérifie concrètement le projet :
      - not_started : pas encore vérifié ;
      - in_progress : vérification en cours ;
      - done : preuve trouvée et contrôle validé ;
      - blocked : impossible d’avancer, avec explication ;
      - not_applicable : contrôle non pertinent pour ce projet.

  4. On conserve la preuve dans l’instance Markdown

     Par exemple :

     - [x] `technical-architecture-surfaces`
       - status: done
       - evidence: `docs/architecture.md`, inspection du dépôt
       - checked_at: 2026-07-28

  5. Le prochain contrôle devient automatiquement visible

     L’outil peut alors répondre :
      - progression : 4/10 ;
      - contrôle actuel : technical-dependency-hygiene ;
      - prochain contrôle : technical-runtime-verification ;
      - blocage éventuel ;
      - dernière preuve ajoutée.

  6. Les tâches restent séparées

     Une checklist constate l’état du projet. Elle ne remplit pas
     le tracker avec toutes ses cases.

     Si un contrôle révèle qu’il faut corriger quelque chose, on
     crée une tâche concrète :

     > Corriger le robots.txt de jarretelacoke.fr

     Une fois la tâche terminée, on revient dans la checklist et
     on valide le contrôle avec sa preuve.

  7. Les cycles récurrents créent une nouvelle instance

     On ne réinitialise pas l’ancienne checklist. Par exemple :
      - launch-2026-07 : cycle de lancement ;
      - maintenance-2026-08 : cycle mensuel suivant ;
      - seo-technical-2026-Q4 : nouvel audit technique.

     L’historique reste donc traçable.

  Pour jarretelacoke.fr, l’exécution réelle commencera maintenant
  par le premier contrôle de chaque instance. Les 11 instances
  sont prêtes, mais aucune case n’a été cochée artificiellement :
  chaque validation devra être faite à partir du code, de la
  configuration, du site et des preuves disponibles.


› on lancera les cycles tous les combien de temps a ton.avis?
  cest configurable ?


• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (18:27) : oui, la cadence sera configurable par
  domaine et par projet

  Je recommande cette base :

   Domaine                       Cadence recommandée
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Production / santé du site    hebdomadaire
  ────────────────────────────  ──────────────────────────────────
   Maintenance / dépendances     mensuelle
  ────────────────────────────  ──────────────────────────────────
   Cybersécurité                 mensuelle + après incident ou
                                 changement sensible
  ────────────────────────────  ──────────────────────────────────
   Performance                   mensuelle + après modification
                                 importante
  ────────────────────────────  ──────────────────────────────────
   Analytics                     mensuelle
  ────────────────────────────  ──────────────────────────────────
   SEO technique                 trimestrielle + après refonte ou
                                 changement technique
  ────────────────────────────  ──────────────────────────────────
   Marketing / copywriting       à chaque campagne ou lancement
  ────────────────────────────  ──────────────────────────────────
   Contenu éditorial             selon le calendrier éditorial
  ────────────────────────────  ──────────────────────────────────
   Lancement                     une seule fois, puis contrôle
                                 post-lancement
  ────────────────────────────  ──────────────────────────────────
   Technique                     à chaque évolution importante ou
                                 avant une mise en production

  Il faut distinguer deux choses :

  - la checklist de lancement, exécutée une fois ;
  - les contrôles cycliques, recréés à chaque nouvelle période.

  Par exemple :

  seo-technical-launch-2026-07
  seo-technical-quarterly-2026-Q4
  seo-technical-quarterly-2027-Q1

  Le modèle est donc configurable avec une cadence par instance ou
  par domaine :

  cadence: quarterly
  next_cycle: 2026-10-01
  trigger_events:
    - major_release
    - domain_migration
    - redesign

  Aujourd’hui, les cycles sont configurables manuellement via les
  fichiers Markdown. L’automatisation du calendrier — rappels,
  création automatique de la prochaine instance et affichage “à
  faire cette semaine” — sera une fonction de l’application
  ShipGlows à ajouter ensuite.

• You’re continuing from this point in a new conversation


› pour :    Le fichier ShipGlows est maintenant nettoyé :
    shipglows_data/workflow/conversations/conversation-800-tmux-
    capture-conversation-capture-et-verifie-20260728-200056.md

    Il contient uniquement les échanges Diane: et agent IA:. La
  version brute est conservée ici :
  shipglows_data/workflow/conversations/conversation-800-tmux-
    capture-conversation-capture-et-verifie-20260728-200056-
  raw.md

  tu peux remonter un peu plus haut maintenant ou pas j'aimerais
  récupérer toute la conv ?  $007-sg-content capture conversation


• J’utilise 007-sg-content en mode capture-full-conversation, avec
  800-tmux-capture-conversation comme implémentation interne. Je
  vais remonter la fenêtre de capture, produire une version
  complète, puis vérifier que le fichier contient bien toute la
  conversation et conserver la version brute.

• Ran for f in "skills/references/canonical-paths.md" "skills/
  │ references/shipglows-owned-preflight.md" "skills/references/
  │ chantier-tracking.md" "skills/references/
  │ … +5 lines
  └ ===== skills/references/canonical-paths.md
    ---
    … +1137 lines (ctrl + t to view transcript)
    output-file.md
    ```

• Ran sed -n '1,280p' skills/800-tmux-capture-conversation/
  │ scripts/capture_tmux_conversation.sh; echo '--- existing
  │ files'; ls -l shipglows_data/workflow/conversations/
  │ … +2 lines
  └ #!/usr/bin/env bash
    set -euo pipefail
    … +285 lines (ctrl + t to view transcript)
    conversation-800-tmux-capture-conversation-capture-et-verifie-
    20260728-200056.md

• Explored
  └ Read capture_tmux_conversation.sh

• Ran SHIPGLOWS_ROOT=/home/claude/shipglows
  │ skills/800-tmux-capture-conversation/scripts/
  │ capture_tmux_conversation.sh --dry-run
  └ Title: Conversation 000-shipglows - termine librement sauf si
    tu as des questions
    … +13 lines (ctrl + t to view transcript)
    conversation-000-shipglows-termine-librement-sauf-si-tu-as-des
    -questions-20260729-121446.md

• Ran echo '--- tmux'; tmux show-options -g history-limit; echo
  │ '--- current pane lines/prompts'; tmux capture-pane -t 0:6.1
  │ -p -J -S - | wc -l; tmux capture-pane -t 0:6.1 -p -J -S - |
  │ … +7 lines
  └ --- tmux
    history-limit 2000000
    … +53 lines (ctrl + t to view transcript)
      Vérifications passées : 9 tests Python, 29 tests TUI,
    metadata

• Ran tmux list-windows -a -F '#{session_name}:#{window_index}
  │ #{window_name} active=#{window_active}
  │ pane=#{pane_current_command}'
  └ 0:1 bibli active=0 pane=node
    0:2 rg-landingp active=0 pane=node
    … +3 lines (ctrl + t to view transcript)
    0:6 $ active=1 pane=node
    0:7 ticket active=0 pane=node

• Ran SHIPGLOWS_ROOT=/home/claude/shipglows
  │ skills/800-tmux-capture-conversation/scripts/
  │ capture_tmux_conversation.sh --tab 7 --dry-run
  └ Title: Conversation 300-sg-docs - update
    Destination: /home/claude/best-fried-chicken/shipglows_data/
    … +9 lines (ctrl + t to view transcript)
    shipglows_data/workflow/conversations && nvim
    conversation-300-sg-docs-update-20260729-121505.md

──────────────────────────────────────────────────────────────────

• J’ai vérifié le contexte tmux : la fenêtre actuellement active
  contient 23 messages utilisateur, alors que l’ancienne capture
  n’en contenait que 14. Je vais capturer cette fenêtre complète
  dans le corpus ShipGlows, puis générer une version nettoyée
  séparée afin de ne pas écraser l’archive précédente.

• Explored
  └ Read SKILL.md (801-clean-conversation-transcript skill)
    List scripts
    Search clean|usage|python|destination|CONTENT ANGLES in
801-clean-
           conversation-transcript

• Working (9s • esc to interrupt)

 
› Find and fix a bug in @filename
 
  gpt-5.6-luna medium · main · Context 85% left · ~/shipglows

/home/claude/home/claude/home/claude
