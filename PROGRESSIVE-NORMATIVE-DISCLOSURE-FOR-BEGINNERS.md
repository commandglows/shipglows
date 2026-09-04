# Trop de règles peuvent-elles rendre un agent moins fiable ?

> **Brouillon éditorial pour débutants — non normatif et non publié.**
>
> Cet article accompagne le document d’architecture `PROGRESSIVE-NORMATIVE-DISCLOSURE.md`. Il explique le problème sans supposer de connaissances sur ShipGlows, les agents IA ou la conception de skills.

Imagine ton premier jour de stage.

On te confie une tâche simple : renommer un document et vérifier que les liens fonctionnent encore. Avant de commencer, on te demande pourtant de lire quatre manuels, douze procédures, l’historique de toutes les erreurs commises par l’équipe et une liste de cent exceptions.

Quelque part dans ces pages se trouve sûrement la règle dont tu as besoin. Mais il y a aussi les règles pour déployer en production, gérer un incident de sécurité, publier un article, supprimer une base de données et renouveler un certificat.

Tu voulais bien faire. Maintenant, tu hésites.

Faut-il demander une autorisation avant de renommer le fichier ? Faut-il créer une branche ? Faut-il lancer tous les tests du projet ? Une ancienne procédure semble dire oui, une règle plus récente semble dire non, et un exemple décrit encore un troisième cas.

Le problème n’est pas le manque de règles. Le problème est que toutes les règles te sont présentées comme si elles étaient également importantes, ici et maintenant.

Les agents IA rencontrent exactement la même difficulté.

## Un agent ne devient pas forcément meilleur quand on lui donne plus d’instructions

Un agent travaille à partir d’un contexte : la demande de l’utilisateur, les fichiers du projet, les outils disponibles et les consignes qu’il doit respecter.

On pourrait penser qu’ajouter des instructions le rend automatiquement plus fiable. Au début, c’est souvent vrai. Une règle claire peut éviter une erreur précise.

Mais l’accumulation finit par produire l’effet inverse.

Quand un agent reçoit trop de règles en même temps, il doit déterminer :

- lesquelles concernent réellement la tâche ;
- lesquelles décrivent seulement un cas exceptionnel ;
- lesquelles sont encore actuelles ;
- lesquelles répètent une autre règle ;
- lesquelles se contredisent légèrement ;
- laquelle est prioritaire en cas de conflit.

Une grande quantité d’instructions ne garantit donc pas une bonne décision. Elle peut diluer l’attention, encourager les demandes de validation inutiles et rendre les contradictions plus difficiles à détecter.

Le sujet n’est pas seulement la taille du texte. C’est la charge de raisonnement qu’il impose.

## Pourquoi les systèmes de règles grossissent-ils autant ?

L’accumulation suit souvent un mécanisme très humain.

Un agent commet une erreur. Pour empêcher qu’elle se reproduise, on ajoute une phrase : « Toujours faire X dans cette situation. »

Quelques jours plus tard, une erreur proche apparaît dans une autre partie du système. On ajoute une seconde phrase, formulée un peu différemment. Puis on crée un test qui vérifie que cette phrase est bien présente.

Chaque correction locale semble raisonnable. Pourtant, après plusieurs mois :

- la même intention existe dans cinq documents ;
- chaque copie possède ses propres exceptions ;
- les exemples deviennent des règles implicites ;
- les anciennes justifications restent chargées avec les règles actuelles ;
- modifier une politique exige de toucher de nombreux fichiers ;
- les tests protègent parfois les mots plutôt que le comportement attendu.

On obtient un système très documenté, mais difficile à comprendre.

## L’analogie du code de la route

Un conducteur doit connaître quelques principes en permanence : respecter les autres usagers, adapter sa vitesse, suivre la signalisation et s’arrêter lorsqu’une situation devient dangereuse.

Il n’a pas besoin de réciter à chaque trajet toutes les règles concernant les convois exceptionnels, les tunnels internationaux ou le transport de matières dangereuses.

Ces règles détaillées doivent exister. Elles doivent être précises, accessibles et opposables. Mais elles deviennent utiles lorsqu’un signal concret apparaît.

Par exemple :

- un panneau active une règle particulière ;
- un véhicule spécial impose une procédure adaptée ;
- une route fermée modifie l’itinéraire normal ;
- un accident déclenche un protocole de sécurité.

Le bon système ne supprime donc pas les règles détaillées. Il organise leur activation.

## La question centrale

Le problème peut être résumé ainsi :

> **Quelles règles un agent doit-il connaître en permanence pour agir correctement, et quelles règles précises peut-il ne charger qu’au moment où un signal concret indique qu’elles deviennent pertinentes ?**

Cette question évite un faux choix.

Nous ne sommes pas obligés de choisir entre :

- des consignes courtes mais vagues ;
- des consignes précises mais omniprésentes.

Nous pouvons conserver une doctrine générale concise et rendre les exigences détaillées consultables à la demande.

## Une doctrine, ce n’est pas un manuel complet

Une doctrine donne une direction générale pour les situations ordinaires.

Dans un système d’agents, elle pourrait ressembler à ceci :

1. Cherche à produire le résultat demandé en utilisant les informations disponibles.
2. Ne sollicite l’utilisateur que lorsqu’une véritable décision change le résultat, la portée ou le risque.
3. Préserve les travaux qui ne t’appartiennent pas.
4. Consulte la règle spécialisée lorsqu’un signal sensible apparaît.
5. Vérifie le résultat de manière proportionnée avant de conclure.

Ces cinq idées couvrent une grande partie du travail courant. Elles n’expliquent pas comment gérer chaque cas difficile, et ce n’est pas leur rôle.

Le détail doit rester ailleurs, prêt à être chargé lorsqu’il devient nécessaire.

## La divulgation progressive des règles

Cette approche peut être appelée **divulgation normative progressive**.

Le principe est simple : montrer à l’agent le bon niveau de précision au bon moment.

Le système peut être organisé en quatre étages faciles à comprendre.

### 1. Le socle

Le socle contient les quelques principes que tout agent doit connaître. Il reste court, stable et cohérent.

### 2. Les signaux

Les signaux permettent de reconnaître une situation spéciale.

Quelques exemples :

- l’action peut supprimer des données ;
- la tâche concerne la production ;
- des secrets ou des permissions sont impliqués ;
- une dépense peut être engagée ;
- plusieurs branches Git contiennent des changements différents ;
- une affirmation publique manque de preuve ;
- deux documents revendiquent le même rôle ;
- une information technique peut avoir changé récemment.

Un signal n’explique pas toute la procédure. Il dit simplement : « Attention, une règle spécialisée doit être consultée. »

### 3. L’index

L’index associe chaque signal à une source précise.

Il fonctionne comme le sommaire d’un manuel ou le moteur de recherche d’une base documentaire. Si la tâche implique une suppression, l’agent trouve le contrat sur les actions destructrices. Si elle implique Git, il charge la politique Git du dépôt.

L’index évite que chaque skill répète toutes les règles.

### 4. Les règles spécialisées

Les règles spécialisées conservent toute la précision nécessaire : préconditions, exceptions, étapes, preuves et situations de blocage.

Elles peuvent être longues lorsqu’un domaine l’exige, car elles ne sont chargées que pour les tâches concernées.

## Exemple : renommer un document

Prenons une demande simple : « Renomme ce fichier pour que son titre soit plus clair. »

Avec un système surchargé, l’agent pourrait lire les règles de déploiement, de sécurité, de branches, de publication, de traduction et de rapport final avant de toucher au fichier.

Avec la divulgation progressive :

1. La doctrine lui dit de poursuivre le résultat demandé.
2. Il vérifie que le fichier est identifié et que le renommage ne supprime aucun contenu.
3. Il recherche les liens qui pourraient être cassés.
4. Aucun signal sensible n’apparaît.
5. Il renomme, vérifie et livre.

Le système reste sûr, mais la tâche n’est pas encombrée par des règles étrangères à son objectif.

## Exemple : supprimer une branche Git

Cette fois, l’agent trouve une branche ancienne.

Le mot « supprimer » et l’existence possible de commits uniques activent une règle spécialisée.

Cette règle peut demander de vérifier :

- à quel travail la branche appartient ;
- si une pull request existe ;
- si les commits sont déjà intégrés ;
- si un autre worktree ou processus utilise la branche ;
- si la branche contient du travail unique ;
- si sa suppression est un petit nettoyage sûr ou une décision ambiguë.

Une branche propre, fusionnée et sans commit unique peut être nettoyée automatiquement. Une branche contenant du travail non intégré doit être conservée et signalée.

La doctrine générale reste courte. La précision apparaît exactement au moment utile.

## Exemple : publier une affirmation

Un agent prépare un article et veut écrire : « Cette méthode élimine définitivement les erreurs. »

Le caractère absolu de la phrase active un signal lié aux affirmations publiques. La règle spécialisée demande alors une preuve correspondant exactement à la promesse.

Sans preuve suffisante, l’agent doit reformuler : « Cette méthode réduit certains risques observés dans les scénarios testés. »

Encore une fois, la règle détaillée n’avait aucune raison d’être chargée pendant un simple renommage de fichier. Elle devient indispensable au moment où une promesse publique est formulée.

## Pourquoi cette architecture peut être plus sûre

Réduire le texte toujours chargé peut sembler dangereux. Pourtant, une architecture bien conçue améliore souvent la sécurité.

Une règle unique est plus facile à maintenir que cinq copies. Lorsqu’elle change, il n’est pas nécessaire de retrouver toutes ses reformulations.

Un déclencheur explicite est aussi plus fiable qu’une longue procédure chargée « au cas où ». L’agent sait pourquoi il consulte la règle et quelle décision elle doit l’aider à prendre.

Enfin, les conflits deviennent visibles. Si deux contrats répondent au même signal, le problème d’autorité peut être corrigé au lieu d’être caché dans des paragraphes éloignés.

La concision n’est donc pas l’absence de gouvernance. C’est une meilleure distribution de la gouvernance.

## Une seule source par règle

Pour éviter les contradictions, chaque exigence précise doit avoir un propriétaire clair.

Les autres documents peuvent dire : « Si cette situation apparaît, consulte cette règle. » Ils ne devraient pas réécrire la règle avec leurs propres mots.

Prenons une consigne imaginaire : « Une branche contenant des commits uniques ne doit pas être supprimée automatiquement. »

Si cette phrase existe dans huit fichiers, huit versions peuvent évoluer. L’une ajoutera une exception, une autre conservera l’ancienne formulation, et une troisième utilisera un mot ambigu.

Si elle possède une source canonique unique :

- l’index sait où la trouver ;
- les skills savent quand l’activer ;
- les tests savent quel comportement vérifier ;
- les mainteneurs savent quel fichier modifier.

## Tester les décisions, pas seulement les phrases

Un test qui recherche une phrase exacte répond à la question : « Ces mots sont-ils encore présents ? »

Mais la vraie question est : « L’agent prend-il la bonne décision ? »

Un meilleur test décrit une situation.

### Scénario sûr

Une branche appartient au chantier, sa pull request est fusionnée, aucun commit unique ne subsiste et aucun processus ne l’utilise. L’agent doit la nettoyer sans demander une validation inutile.

### Scénario ambigu

Une branche n’a pas de pull request connue et contient deux commits absents de la branche principale. L’agent doit la préserver et expliquer ce qui manque pour décider.

Ces deux scénarios protègent le comportement sans imposer que la même longue phrase soit copiée partout.

Les tests textuels restent utiles pour quelques éléments stables : un nom de champ, une commande, un identifiant ou une mention de sécurité obligatoire. Ils ne devraient pas devenir une seconde politique cachée.

## Faut-il supprimer toutes les répétitions ?

Non.

Certaines règles méritent d’être répétées, notamment lorsqu’une erreur pourrait exposer des secrets, supprimer des données ou modifier la production.

Mais la répétition doit être intentionnelle.

On devrait pouvoir expliquer :

- pourquoi la règle doit apparaître à plusieurs endroits ;
- quelle source reste canonique ;
- comment les copies restent synchronisées ;
- quel risque justifie cette redondance.

Une répétition de sécurité contrôlée est différente de plusieurs paraphrases qui évoluent indépendamment.

## Les pièges à éviter

### Tout mettre dans un document géant

Centraliser toutes les règles dans un seul fichier résout partiellement la question de la source, mais pas celle de la charge cognitive. Si le fichier entier est toujours chargé, le problème reste le même.

### Raccourcir les skills sans regarder leurs dépendances

Un skill de dix lignes peut charger cinq documents de cent lignes. Sa taille visible est faible, mais son coût réel reste élevé.

### Créer un identifiant pour chaque phrase

Les identifiants sont utiles pour relier une règle à ses tests. Ils deviennent nuisibles lorsqu’ils ajoutent une nouvelle bureaucratie sans clarifier l’autorité.

### Supprimer des détails importants au nom de la simplicité

Une règle spécialisée peut rester longue si le risque l’exige. L’objectif n’est pas de rendre tout le dépôt court. L’objectif est de ne charger que ce qui aide la décision actuelle.

### Transformer chaque incident en exception permanente

Quand les exceptions se multiplient, il faut parfois revoir la règle générale. Ajouter indéfiniment des correctifs locaux peut masquer une mauvaise abstraction.

## Comment améliorer un système existant ?

Il ne faut pas tout réécrire d’un coup.

Une migration prudente peut suivre plusieurs étapes.

### Étape 1 : observer

Choisir quelques tâches représentatives et noter toutes les règles réellement chargées. Lesquelles ont aidé ? Lesquelles étaient inutiles ? Lesquelles se répétaient ?

### Étape 2 : regrouper par intention

Rassembler les règles qui parlent du même sujet, même lorsqu’elles utilisent des mots différents : autonomie, validation, Git, sécurité, preuves, documentation ou continuité.

### Étape 3 : identifier le propriétaire

Pour chaque exigence, décider quel document doit devenir la source canonique et quels autres documents doivent seulement pointer vers lui.

### Étape 4 : définir les signaux

Écrire les conditions observables qui rendent chaque règle pertinente. Une règle sans déclencheur fiable risque d’être soit toujours chargée, soit oubliée.

### Étape 5 : préserver les comportements

Créer des scénarios qui décrivent les décisions attendues avant de déplacer ou supprimer les textes existants.

### Étape 6 : migrer un domaine pilote

Commencer par un domaine riche en répétitions, puis comparer la charge de contexte et les décisions avant et après la migration.

### Étape 7 : avancer progressivement

Chaque vague doit être vérifiable, réversible et suffisamment petite pour que les régressions restent compréhensibles.

## Comment savoir si le système s’améliore ?

Il faut mesurer autre chose que le nombre de lignes supprimées.

Quelques indicateurs utiles :

- combien de règles sont chargées pour une tâche ordinaire ;
- combien de références sont ouvertes sans signal pertinent ;
- combien d’exigences possèdent plusieurs propriétaires ;
- combien de tests vérifient un comportement plutôt qu’une phrase ;
- combien de fichiers doivent changer lorsqu’une politique évolue ;
- combien de contradictions restent non résolues ;
- combien de situations sensibles activent correctement leur protection ;
- combien de validations inutiles sont demandées à l’utilisateur.

Une migration réussie ne se contente pas de réduire le contexte. Elle doit maintenir ou améliorer les bonnes décisions.

## Le rôle du stagiaire dans cette réflexion

Un regard débutant est particulièrement utile.

Une personne qui connaît déjà tout le système complète naturellement les informations manquantes et reconnaît les anciennes formulations. Un stagiaire voit plus directement les problèmes d’organisation :

- « Je ne sais pas quel document fait autorité. »
- « Ces deux règles semblent identiques, mais pas tout à fait. »
- « Je ne comprends pas pourquoi cette procédure est nécessaire ici. »
- « Je trouve la règle, mais pas ce qui doit la déclencher. »
- « Le test vérifie une phrase, pas le résultat. »

Ces remarques ne prouvent pas que la documentation est mauvaise. Elles révèlent les endroits où le système dépend trop de connaissances implicites.

## Le résultat recherché

À terme, un agent ou un nouveau membre de l’équipe devrait pouvoir comprendre rapidement :

- les quelques principes qui gouvernent toutes les tâches ;
- les signaux qui indiquent une situation particulière ;
- l’endroit unique où trouver la règle détaillée ;
- la priorité entre plusieurs règles ;
- la preuve attendue avant de conclure.

Il ne devrait pas avoir à lire toute l’organisation pour renommer un document. Mais lorsqu’il touche à la production, aux données ou à une action irréversible, il devrait retrouver immédiatement toutes les précautions nécessaires.

Voilà l’équilibre recherché : **moins de bruit permanent, sans perdre la précision au moment où elle compte**.

## La question à garder en tête

Si tu devais revoir un système de skills demain, commence par cette question :

> **Quelles règles l’agent doit-il connaître tout le temps, et quelles règles peut-il découvrir seulement lorsqu’un signal concret les rend utiles ?**

Si toutes les règles doivent être lues tout le temps, l’architecture ne fait probablement pas encore assez bien la différence entre doctrine, détection et procédure.
