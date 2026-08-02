# Conversation — masters, instances et cycles

> Capture nettoyée depuis la fenêtre disponible. Le panneau commençait déjà au milieu d’une réponse ; les lignes antérieures n’étaient plus présentes dans le scrollback récupérable.

agent IA: La réponse précédente établissait déjà le principe suivant : chaque domaine peut avoir son propre master, ses instances par projet et ses cycles. `TASKS.md` reste réservé aux actions concrètes, pas au suivi global des contrôles. Un domaine applicable sans master défini doit apparaître comme `needs_review`, jamais comme terminé. La capture brute conserve ce fragment initial ainsi que les sorties détaillées.

Diane: Est-ce que tu peux m'expliquer c'est quoi le master, les instances par projet et les cycles ? Je n'ai pas compris.

agent IA: 🧱 CHANTIER (local) : comprendre le modèle 🎯 VERDICT (17:56) : expliqué Imagine une recette de cuisine : précis. période donnée. Exemple avec le SEO technique : Le master contient les étapes générales : 1. Vérifier robots.txt 2. Vérifier le sitemap 3. Vérifier les balises importantes 4. Vérifier les erreurs 404 5. Vérifier les performances 6. Vérifier l’indexation Pour le projet site-restaurant, on crée une instance : site-restaurant-seo-2026-07.md Elle indique : Le cycle correspond à une exécution de la checklist : On ne réinitialise jamais l’ancienne instance. On en crée une nouvelle, afin de conserver l’historique. Donc : Master SEO technique ↓ Projet A — cycle lancement — terminé Projet A — cycle mensuel août — en cours Projet B — cycle lancement — bloqué Les tâches ne contiennent que les actions concrètes découvertes pendant le contrôle, par exemple : > Corriger la redirection de /ancienne-page. La checklist répond à : « où en est le domaine ? » La tâche répond à : « quelle action précise faut-il exécuter ? »

Diane: Bien vu ! Tu peux terminer la rédaction des autres masters s'il te plaît. Si tu veux, utilise des agents en parallèle.

agent IA: Oui. Je vais compléter les masters manquants par domaine, en gardant un master par responsabilité et en séparant clairement les contrôles techniques des contrôles marketing, copywriting et contenu. Je n’utiliserai pas de parallélisme improvisé : les lots ne sont pas indépendants tant que le contrat commun n’est pas stabilisé, et je garderai une structure homogène pour que l’app puisse tous les lire de la même manière.

agent IA: Je vais créer les paires playbook + checklist master pour les domaines encore absents : performance, analytics, marketing, copywriting, contenu éditorial, production et maintenance. Le contenu SEO restera explicitement séparé du SEO technique. Chaque master aura des identifiants stables, une règle de complétion et une cadence applicable.

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (17:59) : masters rédigés J’ai ajouté les 7 paires playbook + checklist master manquantes : Chaque master possède : Le SEO technique reste limité à crawl, indexation, rendu, métadonnées et performance technique. Les mots-clés, la stratégie éditoriale et la création de contenu restent séparés. Validation passée : 17 fichiers metadata lintés, 9 tests Python réussis, git diff --check réussi. Les masters marketing, copywriting et contenu sont des premières versions opérationnelles : ils pourront être affinés lorsqu’ils seront utilisés sur un vrai projet. Suite logique : 1. Créer les premières instances pour un projet réel. 2. Ajouter les masters dans l’interface de statut du projet. 3. Faire la vérification finale du chantier.

Diane: 1

agent IA: Je lance la première étape : créer les premières instances à partir des masters. Je vais d’abord repérer le projet gouverné déjà présent dans le dépôt et ses domaines déclarés, puis générer les instances sans inventer de progression ni cocher de contrôles.

agent IA: 🚧 CHANTIER (local) : premières instances de projet 🎯 VERDICT (18:01) : choix du projet requis Le registre contient plusieurs projets. Je recommande de commencer par jarrettelacoke.fr, car il possède déjà le périmètre le plus complet : technique, design, copy, SEO, GTM, dépendances et performance. 1. jarrettelacoke.fr — recommandé 2. nantes-gratuit 3. Un autre projet du registre — indique-moi son nom Dès que le projet est choisi, je créerai ses instances par domaine avec tous les contrôles à not_started, sans inventer de progression.

Diane: ok

agent IA: Je prends jarrettelacoke.fr comme projet cible, conformément à la recommandation précédente. Je vérifie d’abord son corpus de gouvernance et ses surfaces réellement déclarées, puis je crée les instances dans son projet, toutes initialisées à not_started.

agent IA: 🚧 CHANTIER (local) : premières instances de projet 🎯 VERDICT (18:03) : projet inaccessible Le projet recommandé jarrettelacoke.fr correspond à /home/ claude/quit-coke, mais ce dossier n’existe pas dans l’environnement actuel. Je ne peux donc pas créer ses instances au mauvais endroit. 1. Tu me redonnes le chemin actuel du projet. 2. Tu choisis un projet présent dans cet environnement. 3. Tu m’autorises à créer une fiche d’instance ShipGlows provisoire uniquement dans ce dépôt, sans la rattacher à un vrai projet.

Diane: on la deja choisi oui

agent IA: Tu as raison : le projet choisi est bien jarrettelacoke.fr. Le problème n’est pas le choix, c’est que son chemin enregistré /home/claude/quit-coke n’est pas présent dans l’environnement actuel. Je garde donc ce projet comme cible et je ne te le redemanderai pas. Dès que le dépôt est accessible, je créerai ses instances initiales par domaine, toutes en not_started.

Diane: Il est déjà accessible sur le serveur et on a déjà créé les instances normalement dans une autre conversation. Regarde.

agent IA: Je vais vérifier les emplacements réellement disponibles sur le serveur, y compris les autres corpus shipglows_data et les instances déjà créées, au lieu de me fier à l’ancien registre de projets. Je chercherai par project_id, nom de domaine et cycle_id pour retrouver la conversation précédente dans les artefacts.

agent IA: Oui, tu avais raison : les instances ont déjà été créées dans une autre conversation. Je les ai retrouvées ici : /home/claude/jarretelacoke/shipglows_data/workflow/checklist- instances/ Il y en a déjà 7, toutes pour le cycle launch-2026-07 : Elles sont bien initialisées à 0/total, sans contrôles cochés artificiellement. Il reste seulement à normaliser/créer les instances pour : 🧱 CHANTIER (local) : retrouver les instances jarretelacoke.fr 🎯 VERDICT (18:05) : instances existantes retrouvées

Diane: vazy

agent IA: J’ai retrouvé les 7 instances existantes. Je complète maintenant les quatre lanes manquantes, sans recréer celles qui existent déjà : SEO technique, cybersécurité, lancement et technique. Pour la lane technique, je vais utiliser un master technique explicite afin de ne pas détourner la checklist de lancement.

agent IA: La recherche confirme que la conversation précédente a bien créé 7 instances dans le bon dépôt : /home/claude/jarretelacoke. Je complète les quatre manquantes et je vais aussi normaliser les identifiants stables des masters concernés, car c’est nécessaire pour que les instances restent lisibles par l’app et historisables.

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (18:10) : instances complétées Tu avais raison : les 7 instances existaient déjà dans /home/ claude/jarretelacoke. J’ai ajouté les 4 manquantes : Le projet possède maintenant 11 instances pour le cycle launch- 2026-07. Aucun contrôle n’a été coché artificiellement. Le parser confirme pour chaque instance : Le modèle est maintenant prêt pour commencer l’exécution réelle des contrôles sur jarretelacoke.fr.


Diane: comment vas t elle se passer cette execution?

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (18:22) : l’exécution se fera par contrôles successifs, projet par projet Le fonctionnement sera le suivant : 1. On choisit un projet et un cycle Exemple : jarretelacoke.fr — cycle launch-2026-07. 2. Chaque domaine possède sa propre instance Technique, cybersécurité, SEO technique, performance, analytics, marketing, copywriting, contenu, production, maintenance et lancement. 3. On exécute les contrôles dans l’ordre prévu Pour chaque contrôle, on vérifie concrètement le projet : 4. On conserve la preuve dans l’instance Markdown Par exemple : 5. Le prochain contrôle devient automatiquement visible L’outil peut alors répondre : 6. Les tâches restent séparées Une checklist constate l’état du projet. Elle ne remplit pas le tracker avec toutes ses cases. Si un contrôle révèle qu’il faut corriger quelque chose, on crée une tâche concrète : > Corriger le robots.txt de jarretelacoke.fr Une fois la tâche terminée, on revient dans la checklist et on valide le contrôle avec sa preuve. 7. Les cycles récurrents créent une nouvelle instance On ne réinitialise pas l’ancienne checklist. Par exemple : L’historique reste donc traçable. Pour jarretelacoke.fr, l’exécution réelle commencera maintenant par le premier contrôle de chaque instance. Les 11 instances sont prêtes, mais aucune case n’a été cochée artificiellement : chaque validation devra être faite à partir du code, de la configuration, du site et des preuves disponibles.

agent IA: You’re continuing from this point in a new conversation

Diane: on lancera les cycles tous les combien de temps a ton.avis? cest configurable ?

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (18:27) : oui, la cadence sera configurable par domaine et par projet Je recommande cette base : Domaine Cadence recommandée ━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ Production / santé du site hebdomadaire Maintenance / dépendances mensuelle Cybersécurité mensuelle + après incident ou changement sensible Performance mensuelle + après modification importante Analytics mensuelle SEO technique trimestrielle + après refonte ou changement technique Marketing / copywriting à chaque campagne ou lancement Contenu éditorial selon le calendrier éditorial Lancement une seule fois, puis contrôle post-lancement Technique à chaque évolution importante ou avant une mise en production Il faut distinguer deux choses : Par exemple : seo-technical-launch-2026-07 seo-technical-quarterly-2026-Q4 seo-technical-quarterly-2027-Q1 Le modèle est donc configurable avec une cadence par instance ou par domaine : cadence: quarterly next_cycle: 2026-10-01 trigger_events: Aujourd’hui, les cycles sont configurables manuellement via les fichiers Markdown. L’automatisation du calendrier — rappels, création automatique de la prochaine instance et affichage “à faire cette semaine” — sera une fonction de l’application ShipGlows à ajouter ensuite.

Diane: très bien.

agent IA: Parfait. Le modèle retenu est donc : La prochaine étape logique sera d’ajouter officiellement ces paramètres de cadence aux templates Markdown et à l’instance de jarretelacoke.fr.

Diane: oui

agent IA: Je vais intégrer la cadence et les déclencheurs dans les templates, puis les appliquer à l’instance de jarretelacoke.fr. Je m’appuie sur le workflow 001-sg-build pour garder les cycles compatibles avec le modèle existant, sans créer de tâches artificielles.


agent IA: J’ai vérifié le contrat existant : il prévoit déjà les cadences au niveau des contrôles, mais pas encore une déclaration claire de cadence au niveau d’une instance de projet. Je vais donc ajouter cette couche sans modifier le suivi des tâches ni la logique des contrôles.



agent IA: La cadence est maintenant déclarée à deux niveaux : dans le projet (politique par domaine) et dans chaque instance (cadence, date d’ancrage, fuseau, déclencheurs, prochaine revue). J’applique maintenant ces paramètres au cycle de jarretelacoke.fr, puis je vérifie que les lecteurs les exposent correctement.

agent IA: 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model 🎯 VERDICT (18:35) : cadences configurables ajoutées C’est fait pour jarretelacoke.fr : La configuration actuelle prévoit notamment : copywriting et maintenance : mensuelle ; migration, refonte, changement de dépendance, etc. Les 11 instances sont reconnues par le parser et restent à 0/ total, sans progression inventée. La création automatique des prochains cycles et les rappels seront ajoutés ensuite dans l’interface ShipGlows.

Diane: $800-tmux-capture-conversation capture et verifie

agent IA: J’utilise 800-tmux-capture-conversation pour capturer le panneau tmux courant, puis je vérifierai le Markdown produit (présence, lisibilité de base et absence de troncature évidente). Je commence par afficher la destination et le contenu détecté avant l’écriture.

agent IA: Le plan détecté est : workflow/conversations/conversation-800-tmux-capture- conversation-capture-et-verifie-20260728-200056.md Je lance l’écriture et la vérification avec cette destination ?

Diane: ok

agent IA: Je capture maintenant le panneau validé, puis je contrôle le fichier généré et sa structure Markdown.

Diane: verifie que la convest
