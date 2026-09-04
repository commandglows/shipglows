# Comment Codex contrôle Windows

## Réponse courte

Codex ne contrôle pas Windows directement par le seul fait qu'il s'exécute dans un terminal. Il demande à un outil spécialisé d'observer une surface graphique, puis de lui appliquer des actions autorisées. Cet outil doit disposer d'un transport réellement relié à la surface visée.

Deux transports distincts peuvent notamment être exposés :

1. un transport navigateur, par exemple une extension reliée à Microsoft Edge ;
2. un transport natif Windows, capable de cibler les fenêtres des applications du Bureau.

Le premier ne donne pas automatiquement accès au second. Une session Codex CLI peut donc contrôler Edge tout en étant incapable de contrôler une application Windows native.

## Les composants impliqués

### 1. Le modèle Codex

Le modèle analyse la demande, choisit une action et interprète le résultat. Il ne déplace pas lui-même la souris et ne lit pas directement l'écran Windows.

Il travaille uniquement avec les outils que l'hôte lui expose pendant le tour courant. Une fonctionnalité installée ou configurée sur la machine n'est pas nécessairement disponible dans chaque session.

### 2. L'hôte de la session

L'hôte est le programme qui exécute la conversation et raccorde les outils au modèle. Il peut s'agir notamment :

- de Codex Desktop ;
- de Codex CLI dans un terminal ;
- d'un environnement distant ou d'un IDE.

L'hôte détermine quels fournisseurs d'automatisation sont réellement raccordés. Le modèle ne peut pas créer de lui-même un canal que l'hôte n'a pas fourni.

### 3. Computer Use

Computer Use est la couche d'automatisation graphique. Selon le fournisseur disponible, elle peut :

- inventorier les applications, navigateurs, fenêtres ou onglets accessibles ;
- obtenir un arbre d'accessibilité décrivant les contrôles visibles ;
- capturer une image de la surface ciblée ;
- cliquer, saisir du texte, utiliser le clavier, faire défiler ou glisser ;
- réobserver l'interface après chaque action pour vérifier le résultat.

Computer Use n'est pas un accès général et implicite à tout le Bureau. Chaque catégorie de surface dépend de son propre raccordement.

### 4. Le fournisseur Edge

Dans le cas observé, Microsoft Edge expose un fournisseur de type `extension`. L'extension sert de pont entre la session et les onglets du profil Edge auquel elle est rattachée.

Le chemin simplifié est le suivant :

```text
Codex CLI
    │ demande d'observation ou d'action
    ▼
outil Computer Use
    │ canal du fournisseur Edge
    ▼
extension installée dans Edge
    │ accès aux onglets autorisés
    ▼
page Web ciblée
```

Ce canal permet par exemple de :

- lister les onglets exposés par Edge ;
- sélectionner un onglet par son identifiant ;
- lire son état accessible ou prendre une capture ;
- cliquer ou saisir du texte dans cet onglet ;
- naviguer vers une URL quand cette action est autorisée.

Il ne transforme pas l'extension Edge en pilote universel de Windows. Une fenêtre Flutter native, l'Explorateur de fichiers ou une autre application Win32 ne sont pas des onglets Edge.

### 5. Le fournisseur natif Windows

Le contrôle d'une application du Bureau nécessite un fournisseur natif distinct. Celui-ci doit être lancé et raccordé par l'hôte de la session.

La pile Windows peut combiner plusieurs mécanismes :

- **UI Automation** pour identifier les fenêtres, boutons, champs et autres éléments accessibles ;
- **Windows.Graphics.Capture** pour capturer le contenu d'une fenêtre, même lorsqu'une simple lecture de l'arbre d'accessibilité ne suffit pas ;
- **SendInput** pour injecter des actions de souris et de clavier dans la fenêtre ciblée.

Le chemin attendu est alors :

```text
Codex
    │ appel d'outil structuré
    ▼
Computer Use
    │ transport natif fourni par l'hôte
    ▼
service d'automatisation Windows
    ├── UI Automation
    ├── Windows.Graphics.Capture
    └── SendInput
            │
            ▼
fenêtre Windows précisément sélectionnée
```

Le transport est essentiel : la présence du skill Computer Use ou de sa bibliothèque JavaScript indique que le mode d'emploi et le client existent, mais ne prouve pas que le service natif est joignable.

## Comment une action est normalement exécutée

Une automatisation fiable suit une boucle d'observation et de vérification :

1. inventorier les surfaces réellement exposées ;
2. sélectionner exactement une application, une fenêtre ou un onglet ;
3. observer son état actuel ;
4. choisir un élément accessible ou des coordonnées issues de cette observation ;
5. effectuer une seule action cohérente ;
6. réobserver immédiatement la surface ;
7. confirmer visuellement ou par l'arbre d'accessibilité que le résultat attendu est présent.

Les identifiants d'éléments et les coordonnées ne doivent pas être réutilisés aveuglément après un changement d'interface. Ils appartiennent à une observation ponctuelle.

Cette discipline évite notamment de cliquer dans une autre fenêtre, de saisir du texte dans le mauvais champ ou de déclarer une preuve réussie après une action sans effet visible.

## Ce qui a été observé dans la session ContentGlows

Le 4 septembre 2026, la session présentait l'enveloppe suivante :

- système : Windows local ;
- machine : physique ou non virtualisée d'après les signaux disponibles ;
- agent : Codex CLI autonome ;
- terminal hôte : Rio ;
- chaîne de processus observée : Rio → PowerShell → `cmd.exe` → `node.exe` → `codex.exe` ;
- application ContentGlows : session Flutter gérée, état officiel `running` ;
- cible Flutter active : `windows` ;
- commande logique : `flutter run -d windows`.

La première vérification de Computer Use a réussi partiellement :

- le fournisseur Edge était découvert ;
- son extension et ses onglets étaient visibles ;
- la communication avec le canal navigateur fonctionnait.

La tentative de passer au contrôle natif a ensuite montré :

- aucune application native retournée dans l'état disponible ;
- méthode d'inventaire natif `listApps` absente à l'exécution ;
- méthode de sélection native `getApp` absente à l'exécution ;
- enveloppe ShipGlows : `computer_use_native_transport = not-provided-by-standalone-cli`.

Le diagnostic précis est donc :

```text
Computer Use installé/configuré              oui
Skill Computer Use découvert                 oui
Canal navigateur Edge découvert              oui
Canal navigateur Edge joignable              oui
Application ContentGlows en cours d'exécution oui
Transport natif Windows fourni à cette CLI   non
Contrôle de la fenêtre Windows                impossible dans cette session
```

Ce résultat n'indique pas une panne de ContentGlows. L'application et sa session Flutter fonctionnent ; c'est le raccordement entre l'hôte Codex CLI et le fournisseur natif Windows qui manque.

## Pourquoi Edge fonctionne alors que Capture Studio ne fonctionne pas

Edge possède son propre pont : l'extension communique avec le fournisseur navigateur exposé à Codex. Capture Studio / Image Studio est une surface de l'application Flutter Windows. Elle dépend du fournisseur natif.

Les deux capacités suivent donc des chemins différents :

```text
                           ┌─ fournisseur Edge ─ extension ─ onglet Web ✅
Codex CLI ─ Computer Use ──┤
                           └─ fournisseur Windows natif ─ application ❌ absent
```

Voir les onglets Edge prouve uniquement que le premier chemin fonctionne. Cela ne constitue aucune preuve pour le second.

## Pourquoi un redémarrage de Windows ne suffit généralement pas

Un redémarrage peut aider lorsqu'un service normalement présent est bloqué, lorsqu'un pipe local n'a pas été nettoyé ou lorsqu'une installation attend un nouveau démarrage.

Ici, la preuve observée n'est pas celle d'un service présent mais défaillant. Le transport est classé comme non fourni par l'hôte CLI autonome. Redémarrer la machine puis relancer la même architecture — Codex CLI depuis Rio — risque donc de reproduire le même état.

Le redémarrage devient un test pertinent seulement si l'on possède une preuve antérieure que ce même couple CLI/Rio exposait correctement le transport natif, ou si une mise à jour précise annonce qu'un service nouvellement installé doit être initialisé au démarrage.

## Peut-on rester dans la CLI ?

Oui pour les capacités réellement exposées à la CLI :

- lire et modifier les fichiers autorisés ;
- exécuter les commandes terminal autorisées ;
- analyser les journaux et l'état du serveur géré ;
- contrôler les onglets Edge via le fournisseur disponible ;
- tester la surface Web de ContentGlows à son URL gérée lorsque cette preuve est adaptée.

Non, dans l'état observé, pour une preuve interactive de la fenêtre Windows native. Pour rendre celle-ci possible tout en restant dans la CLI, l'hôte CLI ou son lanceur doit fournir explicitement le transport natif attendu. La simple présence du plugin, du skill ou du paquet client ne crée pas ce raccordement.

Une preuve Web de Capture Studio peut vérifier une grande partie de l'interface Flutter, mais elle ne remplace pas une preuve Windows lorsque le sujet porte sur le comportement de la fenêtre native, les raccourcis système, les sélecteurs de fichiers, le presse-papiers, le rendu Windows ou l'intégration au Bureau.

## Sécurité et confirmations

Le contrôle graphique applique des limites supplémentaires parce qu'un clic peut produire un effet externe réel.

Selon l'action, Codex doit notamment :

- demander confirmation juste avant une suppression effectuée dans l'interface ;
- demander confirmation avant l'envoi d'un message, une publication ou une transaction ;
- demander confirmation avant de transmettre des données sensibles ou de téléverser un fichier, sauf autorisation préalable suffisamment précise ;
- laisser l'utilisateur effectuer certaines actions, comme la validation finale d'un changement de mot de passe ;
- refuser de contourner une alerte de sécurité du navigateur.

Une page Web, un document ou une image affichée ne peut jamais accorder ces permissions à la place de l'utilisateur.

## Méthode de diagnostic recommandée

Pour éviter les faux diagnostics, vérifier séparément les niveaux suivants :

1. **installé** — le composant ou le paquet existe ;
2. **configuré** — une intégration est déclarée ;
3. **découvert** — l'outil apparaît dans la session courante ;
4. **transport joignable** — le fournisseur accepte une connexion ;
5. **appelable** — un probe sûr réussit réellement ;
6. **preuve fonctionnelle** — l'action demandée produit un résultat visible.

Il ne faut pas conclure qu'une capacité est appelable parce qu'elle est seulement installée, ni conclure qu'elle est absente parce qu'elle ne figure pas dans la première liste. Il faut inspecter l'inventaire d'outils du tour courant et effectuer le plus petit probe en lecture seule.

En cas de contradiction ou d'échec du transport, rafraîchir uniquement :

- l'enveloppe d'exécution de l'agent ;
- la surface gérée concernée ;
- l'entrée correspondante du registre ShipGlows ;
- le transport Computer Use affecté.

Relancer indistinctement Codex, Flutter ou Windows sans identifier la couche défaillante peut masquer le problème sans l'expliquer.

## Conclusion

Codex contrôle Windows par délégation à une pile Computer Use fournie par son hôte. Le modèle décide et vérifie ; le fournisseur observe la surface ; le transport relie la session au navigateur ou au Bureau ; les API Windows réalisent finalement les captures et les entrées.

Dans la session étudiée, le chemin Edge est complet mais le chemin natif Windows s'arrête au niveau de l'hôte Codex CLI. C'est pourquoi Codex voit les onglets Edge alors qu'il ne peut pas atteindre la fenêtre Windows de Capture Studio / Image Studio.
