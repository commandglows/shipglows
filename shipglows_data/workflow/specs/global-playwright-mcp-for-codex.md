---
artifact: specification
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-13"
status: reviewed
source_skill: sg-engineering
scope: global-playwright-mcp-for-codex
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
user_story: "En tant qu'utilisatrice de Codex CLI, je veux que l'installation complète de ShipGlows configure un Playwright MCP global et fonctionnel, afin que tous mes projets disposent des preuves navigateur sans configuration locale."
linked_systems:
  - install-shipglows.ps1
  - cli/windows/install-devserver.ps1
  - cli/install.sh
  - skills/references/playwright-mcp-runtime.md
  - shipglows_data/technical/installer-and-user-scope.md
  - tests/windows/
  - tests/install/
depends_on:
  - artifact: "skills/references/playwright-mcp-runtime.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/windows-bootstrap-development-workflow.md"
    artifact_version: "2.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-08-12: Playwright MCP must be a user-global Codex CLI capability on native Windows, without project mutation."
  - "Codex CLI 0.147.0 locally exposes mcp add/get/list/remove and JSON inspection through mcp get."
  - "Microsoft Playwright MCP documents Codex stdio registration through npx and supports headless Chromium."
  - "The existing Linux installer already owns a Playwright MCP block and preserves a Linux ARM64 Chromium invariant."
  - "Windows remote installs from commit 25b1dcda480c918ee9210a547ebd0b11cf6db2c9 completed twice with an unchanged Codex config SHA-256 on the idempotent pass."
  - "A fresh Codex CLI 0.147.0 process used only Playwright MCP against http://localhost:3001 and collected navigation, accessibility, screenshot, console, and 1055 successful network requests."
next_step: "Review and merge pull request, then reinstall from main"
---

# Global Playwright MCP for Codex CLI

## User Story

En tant qu'utilisatrice de Codex CLI, je veux qu'une installation complète de
ShipGlows configure Playwright MCP au niveau de mon profil utilisateur, afin que
tous mes projets puissent utiliser les preuves navigateur sans dépendance ni
configuration ajoutée dans leurs dépôts.

## Architecture Decisions

- Playwright MCP est configuré automatiquement en mode `full` lorsque Codex,
  Node et `npx` sont disponibles. Il n'est pas ajouté au mode tunnel `local`.
- Sur Windows, la commande MCP utilise le chemin absolu résolu de `npx.cmd` ;
  elle ne dépend jamais de `npx.ps1` ni de la politique PowerShell.
- La configuration utilise `@playwright/mcp@latest`. Une réinstallation
  ShipGlows est la politique gouvernée de réparation et de mise à jour.
- Chromium est téléchargé pendant l'installation, avec la commande Playwright
  provenant du paquet MCP sélectionné. L'installation ne doit pas annoncer une
  capacité prête si le navigateur manque.
- La table utilisateur `mcp_servers.playwright` est la seule configuration MCP
  Codex possédée par ce composant. ShipGlows peut la créer ou la remplacer de
  manière atomique, mais conserve toutes les autres tables et clés TOML.
- Playwright est `enabled = true` afin d'être disponible dans tout projet après
  redémarrage de Codex CLI. Les autres MCP conservent leur politique existante.
- Aucun manifeste, cache, paquet ou fichier Playwright n'est écrit dans un dépôt
  applicatif. Le cache navigateur reste dans le scope utilisateur Playwright.
- Linux x64 et ARM64 restent pris en charge. ARM64 ne sélectionne jamais Google
  Chrome stable : un Chromium Playwright existant est utilisé par chemin absolu,
  sinon le fallback reste `--browser chromium --headless --no-sandbox`.
- macOS n'est pas ajouté à ce chantier faute d'installeur ShipGlows macOS
  correspondant ; la configuration stdio reste portable mais non revendiquée.

## Success Behavior

- Une installation Windows `full` avec Codex, Node et `npx.cmd` configure un
  serveur MCP `playwright` global, activé, headless et basé sur Chromium.
- `codex mcp list` et `codex mcp get playwright --json` reflètent la commande
  absolue et les arguments possédés par ShipGlows.
- Une seconde installation ne duplique pas la table, ne crée pas de changement
  inutile et conserve toutes les autres configurations utilisateur.
- Une configuration Playwright absente ou divergente est réparée sans supprimer
  les autres MCP ni les options Codex.
- Le Chromium compatible est installé avant le verdict de succès.
- Après redémarrage de Codex CLI, le MCP peut naviguer vers un localhost, lire
  l'arbre d'accessibilité, capturer une image et rapporter console et réseau.

## Error Behavior

- Codex absent : diagnostic explicite et Playwright MCP ignoré sans faux succès.
- Node absent : diagnostic explicite avant toute modification de configuration.
- `npx.cmd` absent sous Windows : diagnostic explicite ; aucun fallback vers
  `npx.ps1`.
- Échec du téléchargement Chromium : l'installation Playwright est signalée
  incomplète et la configuration MCP n'est pas annoncée comme prête.
- TOML illisible ou impossible à préserver : sauvegarde conservée et arrêt de la
  mutation Playwright ; aucun écrasement global du fichier.
- Configuration utilisateur concurrente : écriture atomique et remplacement
  limité à la table Playwright.

## Scope In

- Installation globale Codex Playwright MCP sous Windows natif.
- Alignement Linux de l'activation et de la disponibilité Chromium sans casser
  l'invariant ARM64.
- Helpers d'inspection, de remplacement atomique et de vérification.
- Tests Windows et Linux de génération, idempotence, préservation et erreurs.
- Documentation canonique de l'installeur et doctrine runtime Playwright.
- Installation distante de la branche, réinstallation idempotente, preuve MCP
  réelle, push et pull request.

## Scope Out

- Modification d'un projet utilisateur.
- Installation de Google Chrome stable sur Linux ARM64.
- Connexion à une session Chrome existante ou à l'extension Chrome.
- Gestion d'identifiants, cookies ou profils persistants du navigateur.
- Fusion sur `main` avant revue de la pull request.

## Invariants

- Le profil Codex reste un fichier utilisateur partagé ; toute clé étrangère au
  bloc Playwright est préservée byte-for-byte autant que le remplacement borné
  le permet.
- La commande Windows enregistrée est un fichier `.cmd` absolu existant.
- Un seul bloc `mcp_servers.playwright` existe après chaque installation.
- Le navigateur est installé dans le cache utilisateur, jamais dans le projet.
- Une preuve statique ne remplace pas l'installation distante et le test MCP
  après redémarrage du CLI.

## Proof Path

Approche `test-first` pour la configuration et `evidence-first` pour
l'installation globale et le navigateur réel.

- Tests contractuels PowerShell : absent, valide, divergent, autres MCP,
  configuration vide, Node/npx manquants et seconde exécution.
- Parsing de chaque PowerShell modifié et `bash -n` pour le shell.
- Test Linux ARM64 synthétique vérifiant l'absence de Chrome stable.
- Installation Windows fraîche depuis l'archive distante de la branche.
- Réinstallation Windows et comparaison des configurations préservées.
- `codex mcp list`, `codex mcp get playwright --json` et présence Chromium.
- Nouveau processus Codex CLI, puis navigation localhost, snapshot
  d'accessibilité, capture, console et réseau.
- `git diff --check` et lints de métadonnées.

## ZOMBIES Coverage

- Zero : aucun `config.toml`, aucun cache Chromium, aucune entrée Playwright.
- One : une entrée valide réinstallée sans changement fonctionnel.
- Many : plusieurs MCP et clés Codex étrangères restent conservés.
- Boundaries : chemin Windows avec espaces, guillemets TOML et table suivante.
- Interfaces : Codex CLI, Node, `npx.cmd`, cache Playwright et archive GitHub.
- Exceptions : outils manquants, téléchargement échoué, TOML invalide et config
  Playwright partiellement héritée.
- Simple : un composant global, une table possédée, un navigateur Chromium.

## Acceptance Criteria

- [x] AC1 : Windows `full` configure Playwright MCP global et activé lorsque les
  prérequis sont disponibles.
- [x] AC2 : la commande Windows utilise le chemin absolu de `npx.cmd`.
- [x] AC3 : Chromium est installé pendant l'installation ou le run échoue de
  manière explicite sans annoncer Playwright prêt.
- [x] AC4 : la réinstallation est idempotente et préserve les autres entrées du
  profil Codex.
- [x] AC5 : l'absence de Codex, Node ou npx produit un diagnostic ciblé.
- [x] AC6 : Linux ARM64 conserve Chromium et ne retombe jamais sur Chrome stable.
- [x] AC7 : aucun dépôt utilisateur n'est modifié.
- [x] AC8 : un nouveau Codex CLI peut fournir navigation, accessibilité,
  capture, console et réseau sur `http://localhost:3001`.
- [x] AC9 : la branche distante passe l'installation fraîche et la
  réinstallation Windows avant ouverture de la PR.

## Current Chantier Flow

- Specification: reviewed.
- Implementation: complete.
- Verification: complete.
- Remote branch installation: complete.
- Pull request: pending.
