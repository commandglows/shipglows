---
artifact: technical_specification
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-09-15"
updated: "2026-09-15"
status: proposed
source_skill: sg-planning
scope: cross-platform-cli
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/terminal-tui.md
  - shipglows_data/technical/installer-and-user-scope.md
depends_on: []
supersedes: []
evidence:
  - "Discussion du 2026-09-15 sur l'evolution de la CLI Linux historique vers une surface multiplateforme."
next_review: "2026-12-15"
next_step: none
---

# Spec high-level : CLI multiplateforme avec Cobra

## Statut et intention

Cette note conserve une direction d'architecture pour une future evolution. Elle ne lance pas d'implementation, de migration, de remplacement de la CLI existante, ni de changement de runtime.

La CLI historique a ete creee d'abord pour Linux et possede davantage de fonctionnalites que la surface Windows actuelle. La portabilite doit donc preserver la richesse Linux et ajouter des implementations Windows la ou elles ont un sens, sans imposer une fausse parite technique.

## Objectif

Fournir une meme experience de commande et un meme contrat de configuration sur Linux et Windows, tout en permettant a chaque systeme d'utiliser ses propres mecanismes : `systemd`, permissions et sockets cote Linux ; services Windows, PowerShell et processus Windows cote Windows.

## Direction retenue

Utiliser Cobra, bibliotheque Go, comme couche de commandes : noms, sous-commandes, flags, aide, completion et codes de sortie.

Cobra ne constitue pas une interface graphique. Une interface terminal interactive eventuelle serait une couche separee, par exemple Bubble Tea, et resterait optionnelle.

```text
Commande utilisateur
        |
        v
CLI Cobra : contrat, aide, flags, erreurs
        |
        v
Services et contrats communs
        |
        +-- implementation Linux
        +-- implementation Windows
```

## Contrat de portabilite

Le code commun doit contenir la logique metier, la configuration, le modele d'etat, les erreurs normalisees, les logs et les appels vers les services partageables.

Le code specifique a la plateforme doit rester derriere des interfaces explicites, par exemple :

```go
type ServiceManager interface {
    Start() error
    Stop() error
    Status() (Status, error)
}
```

Les implementations peuvent utiliser les fichiers Go `//go:build linux` et `//go:build windows`. Une fonctionnalite sans equivalent fiable sur une plateforme doit etre marquee comme specifique a cette plateforme ou retourner une erreur explicite et actionnable.

## Classification des fonctionnalites

- Communes : `status`, `doctor`, configuration, affichage d'etat, logs, appels API et gestion des projets.
- Linux natives : integration `systemd`, permissions Unix, sockets Unix, outils et comportements specifiques deja presentes dans la CLI historique.
- Windows natives : services Windows, PowerShell, chemins Windows, registry et gestion des processus Windows.
- Optionnelles : menus, selection clavier, suivi temps reel et tableau de bord terminal via une couche TUI distincte.

La parite attendue est une parite de contrat et d'intention, pas une identite d'implementation ni une promesse que chaque commande existe sur chaque OS.

## Surface de commandes ciblee

Les noms definitifs restent a confirmer, mais la surface devrait conserver les intentions existantes et les rendre coherentes, par exemple :

```text
shipglows service start|stop|status
shipglows project ...
shipglows doctor
shipglows config ...
```

Les commandes existantes Linux sont une source de compatibilite prioritaire. Aucun renommage ou retrait ne doit etre presume par cette note.

## Migration envisagee, sans engagement de calendrier

1. Cartographier les commandes et comportements actuels de la CLI Linux et les besoins Windows.
2. Introduire un binaire Cobra qui preserve les commandes existantes et leurs codes de sortie.
3. Extraire les contrats communs sans deplacer immediatement les implementations fiables.
4. Brancher Linux sur ses implementations natives et Windows sur ses adaptateurs actuels.
5. Migrer progressivement les scripts ou wrappers lorsque l'equivalence comportementale est prouvee.
6. Ajouter une TUI seulement si un besoin utilisateur distinct le justifie.

## Contraintes et invariants

- Aucun bypass d'authentification ou de configuration declaree par le projet.
- Les secrets restent dans l'environnement ou le gestionnaire prevu ; la CLI ne les affiche pas.
- Les erreurs doivent distinguer commande inconnue, configuration invalide, permission refusee, service indisponible et fonctionnalite non supportee.
- Les sorties machine et humaines doivent etre distinguables, par exemple avec `--json` et une sortie lisible par defaut.
- Les scripts et integrations Linux existants restent compatibles pendant la transition.
- Les preuves Linux, Windows, local managed runtime et production restent declarees separement.

## Hors perimetre

- Implementation immediate de Cobra.
- Remplacement immediat de la CLI Linux.
- Refonte du DevServer Windows.
- Interface graphique desktop.
- Obligation d'utiliser Bubble Tea.
- Promesse de parite fonctionnelle complete avant inventaire des commandes existantes.

## Criteres de decision pour une future implementation

- L'inventaire des commandes Linux existantes est complet et leurs contrats sont preserves.
- Les commandes communes ont des codes de sortie et des erreurs documentes.
- Chaque fonctionnalite dependante de l'OS est derriere un adaptateur identifiable.
- Un binaire Linux et un binaire Windows peuvent etre construits depuis le meme module Go sans conditionnement manuel externe.
- La completion et l'aide sont generees pour Bash/Zsh et PowerShell.
- Les tests de contrat communs sont separes des tests d'integration Linux et Windows.

## Decisions a reprendre plus tard

- Nom exact du module Go et emplacement dans le depot.
- Liste canonique et compatibilite des commandes Linux.
- Format de sortie machine (`json`, `ndjson` ou autre).
- Politique de versionnement et de compatibilite CLI.
- Necessite reelle d'une TUI et choix de sa bibliotheque.
- Strategie d'installation et de mise a jour pour Linux et Windows.
