---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: active
source_skill: sg-development
scope: readwise-cli
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/shipglows_readwise.py
  - cli/readwise_oauth.py
  - cli/shipglows-readwise.sh
  - cli/windows/shipglows.ps1
  - cli/windows/shipglows-readwise.cmd
  - cli/install.sh
  - install-shipglows.ps1
  - cli/windows/install-devserver.ps1
  - tools/test_shipglows_readwise.py
  - tools/test_readwise_oauth.py
depends_on: []
supersedes: []
evidence:
  - "Official tools/cli documentation and @readwise/cli 0.5.10 source reviewed on 2026-10-07."
  - "2026-10-07: 25 adapter/OAuth tests passed; installed Windows and Git Bash entry points verified without Doppler."
  - "Live Readwise accepted dynamic loopback client registration and opened authorization; no account login, code exchange or refresh was completed."
next_review: "2026-11-07"
next_step: none
---

# Readwise / Reader dans la CLI ShipGlows

Readwise donne accès à la bibliothèque personnelle : documents Reader, notes et
surlignages Readwise. Parallel découvre des sources publiques ; GSC mesure la
performance SEO ; SERP observe les résultats Google. Ces rôles restent distincts.
Ne transmettez pas de notes privées à une recherche Parallel.

## Installation et première utilisation

Les installateurs ShipGlows distribuent l'entrée, sans installer automatiquement
le fournisseur ni ouvrir de session. Node.js/npm et Python 3 sont nécessaires.
`shipglows readwise` propose des entrées Windows et Bash, sans démarrer le DevServer.
`shipglows-readwise` est le lanceur équivalent installé sur PATH.

```text
shipglows readwise --help
shipglows readwise setup
shipglows readwise status
shipglows readwise login
shipglows readwise help
```

Le choix de ce projet est **Doppler : NONE** : exécutez les commandes directement,
sans `doppler run` (décision de Diane du 2026-10-07, consignée dans `AGENT.md`).
`setup` installe globalement `@readwise/cli@0.5.10` via npm avec les scripts
d'installation désactivés, puis active `readonly=true`. Il est explicite et peut
ramener une installation globale existante à cette version. En cas d'échec,
son code de sortie est conservé ; relancez après correction. L'installation du
paquet et la configuration sont deux étapes, sans rollback automatique.

`login` utilise l'adaptateur OAuth ShipGlows : il réserve un port disponible
sur `127.0.0.1` et garde le serveur ouvert pendant toute la connexion. Cette
adresse est utilisée sans changement pour enregistrer un nouveau client,
ouvrir l'autorisation dans le navigateur et échanger le code. Cela évite le
port fixe `6274` du fournisseur et répare les anciens clients enregistrés pour
ce port. PKCE S256, state aléatoire et contrôle des adresses HTTPS Readwise sont
conservés. Les redirections HTTP des requêtes authentifiées sont refusées.

Chaque tentative enregistre un nouveau client OAuth pour son port réservé ;
elle ne réutilise pas l'ancien client à redirect URI fixe. Le fichier officiel
est remplacé atomiquement seulement après réussite. Une annulation ou un échec
conserve la session précédente. Le cache des outils est invalidé après connexion.
Le callback expire après deux minutes ; les requêtes fournisseur après 30 secondes.

Alternative sans serveur OAuth local :

```text
shipglows readwise login --token
```

Dans un terminal interactif, le CLI officiel demande une saisie masquée. Obtenez
le token sur https://readwise.io/access_token et saisissez-le uniquement dans ce
terminal, jamais dans les arguments ou dans le chat. `login-with-token` accepte
aussi cette saisie interactive lorsqu'aucune variable d'environnement n'est
fournie. En exécution non interactive, `READWISE_ACCESS_TOKEN` est nécessaire.
Cette voie utilise un token d'accès personnel, pas OAuth ; le stockage officiel
reste `~/.readwise-cli.json`. Le mode readonly conserve son rôle de filtre local.

`status` ne fait aucune requête réseau :
il indique l'installation, la présence de credentials et le mode local ; il ne
prouve pas qu'une session est valide. `--version` est également sans réseau.
`help` transmet `--help` au fournisseur ; après connexion, ses commandes sont
découvertes via son serveur MCP et mises en cache par son CLI.

## Commandes utiles

```text
shipglows readwise reader-list-documents --location new
shipglows readwise reader-search-documents --query "architecture"
shipglows readwise reader-get-document-details --document-id <id>
shipglows readwise readwise-search-highlights --vector-search-term "architecture"
shipglows readwise config get readonly
```

Les commandes/options et les codes de sortie du CLI officiel sont conservés.
Les documents lus peuvent contenir des données privées ; les exports sont des
écritures locales explicites. Le lanceur n'exporte ni ne synchronise la bibliothèque.
Les commandes d'écriture officielles (sauvegarde, tags, classement) deviennent
disponibles lorsque l'utilisateur désactive le mode lecture seule et se reconnecte.
Consultez leur aide pour le schéma courant plutôt que figer une copie dans ShipGlows.

## Authentification automatisée

Pour une connexion sans navigateur, fournissez `READWISE_ACCESS_TOKEN` depuis
l'environnement local choisi pour cet usage, puis lancez :

```text
shipglows readwise login-with-token
```

ShipGlows transmet le token sur stdin au CLI officiel, jamais dans les arguments.
Les arguments positionnels sont refusés pour cette commande. Aucun secret n'est
créé par l'intégration. OAuth reste disponible avec `shipglows readwise login`.

Le CLI officiel ne lit pas cette variable directement : le pont est fourni par
ShipGlows. Le fournisseur persiste ensuite les credentials, la configuration et
le cache des outils dans `~/.readwise-cli.json`.
Ce fichier doit rester privé et hors Git ; OAuth ne signifie pas stockage en
coffre Doppler. Le mode readonly est un filtre local des outils du fournisseur,
pas un scope OAuth restreint ni une sandbox ShipGlows. Le TUI officiel permet
aussi de changer ce mode. `setup` est le point d'activation de ce défaut ; un CLI
préinstallé utilisé sans `setup` conserve sa configuration existante.

## Architecture et validation

`cli/shipglows_readwise.py` gère aide, setup, état expurgé, authentification par
stdin et délégation. `cli/readwise_oauth.py` gère uniquement la connexion navigateur
avec un port loopback réservé par le système. Les opérations de bibliothèque
et le renouvellement de session restent dans le CLI officiel ; les sessions
OAuth ShipGlows utilisent son format de configuration. Aucun paquet global
n'est modifié et `setup` n'efface pas le correctif maintenu dans ce dépôt.
Sous Windows, les shims npm sont résolus vers leurs entrées Node pour conserver
les arguments sans passage par `cmd.exe`. Les deux installateurs embarquent le
même adaptateur. Le lanceur Bash résout ses liens symboliques avant de l'appeler.

Tests : `python -m unittest tools.test_shipglows_readwise tools.test_readwise_oauth`.
Ils utilisent des transports/processus simulés et des fichiers temporaires :
aucune bibliothèque personnelle ni connexion fournisseur n'est nécessaire.
Le smoke réel doit couvrir setup, version, status et les deux entrées installées.
La lecture authentifiée demeure une preuve distincte après connexion utilisateur.

### État vérifié au 2026-10-07

- **Correctif local** : le port fixe 6274, réservé par Windows dans la plage
  6236–6335, est remplacé par un listener loopback dynamique dans ShipGlows.
- **Tests** : 25 tests réussis couvrent callback HTTP local, PKCE, state, erreurs,
  annulation, remplacement du client et conservation de la session/configuration.
- **Exécution** : paquet officiel 0.5.10 installé, lecture seule activée,
  lanceurs Windows vérifiés, entrée Bash exécutée sous Git Bash Windows ;
  l'installation native Linux n'a pas été vérifiée.
- **Fournisseur** : Readwise a accepté les clients enregistrés pour les ports
  dynamiques 5223 et 2193. La page d'autorisation s'est ouverte et a été confirmée
  par l'opérateur. Les tentatives ont expiré sans callback, sans remplacer la session.
- **Limite** : la connexion au compte est différée par l'opérateur en raison de
  ses conditions d'accès. Aucun échange de code réel, session authentifiée,
  renouvellement ni lecture de bibliothèque n'est validé. Il ne s'agit pas d'une
  nouvelle erreur de port ; les conditions commerciales du fournisseur n'ont
  pas été vérifiées dans cette intervention.

Ne relancez pas automatiquement le navigateur et ne remplacez pas cette preuve
manquante par une demande d'achat. Quand l'opérateur reprend la connexion,
exécutez `shipglows readwise login`, puis vérifiez le callback, la sauvegarde
de session et sa réutilisation par le CLI officiel. Le token est une alternative
explicite, pas la correction du port OAuth. L'historique est conservé dans
[BUG-2026-10-07-001](../workflow/bugs/BUG-2026-10-07-001.md).

## Références et maintenance

- [CLI officiel](https://docs.readwise.io/tools/cli)
- [MCP et CLI](https://docs.readwise.io/tools)
- [Source officielle](https://github.com/readwiseio/readwise-cli)

Lors d'un changement de version, vérifiez stdin pour `login-with-token`, le chemin
de configuration, le comportement readonly, les shims npm et les codes de sortie.
Vérifiez aussi la compatibilité du format de session avec le renouvellement
officiel et les métadonnées OAuth utilisées par l'adaptateur loopback maintenu.
Actualisez ensemble la version dans l'adaptateur, cette documentation et les tests.
