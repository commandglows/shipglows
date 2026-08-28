---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-28"
updated: "2026-08-28"
status: ready
source_skill: 900-shipglows-core
scope: feature
owner: Diane
user_story: "En tant qu'operatrice Windows, je veux voir immediatement l'etat de ShipGlows et savoir si son runtime doit etre mis a jour sans ralentir mon DevServer."
confidence: high
risk_level: medium
security_impact: low
docs_impact: yes
linked_systems:
  - cli/windows/
  - install-shipglows.ps1
  - tests/windows/
  - shipglows_data/technical/runtime-cli.md
depends_on: []
supersedes: []
evidence:
  - "Operator approval 2026-08-28: reproduce the Linux status panel on Windows with cached ShipGlows release status."
next_step: "Implement and verify Windows runtime status"
---

# Statut runtime ShipGlows Windows

## Status

ready

## Behavior Contract

Le tableau de bord Windows affiche `ShipGlows vX.Y.Z` sans attendre le reseau. Il lit le dernier cache valide, puis lance au plus un controle cache en arriere-plan. Vert signifie version installee a jour; orange signifie patch ou source liee plus recente; rouge signifie une version mineure ou majeure manquee. Une mise a jour disponible affiche la commande `s update`.

`shipglows-version.json` est la source de verite SemVer du runtime. L'installateur la copie dans le runtime et enregistre la version avec le commit source dans `.shipglows-install.json`. Une panne reseau conserve le dernier cache; elle ne bloque ni le menu ni les actions de projet.

## Scope

In: menu/dashboard Windows, cache local atomique, verrou de rafraichissement, metadonnees de version, installateur, tests et documentation. Out: auto-update, changement de canal, telemetrie, collecte de donnees et runtime Linux.

## Acceptance Criteria

- [x] Premier rendu sans attente reseau avec cache absent ou ancien.
- [x] Cache atomique et un seul refresher actif.
- [x] Vert/orange/rouge et le message `s update` sont verifies.
- [x] Le payload Windows et son etat installe contiennent la version canonique.
- [x] Les contrats Windows et tests cibles passent.

## ZOMBIES Coverage

- Z: cache absent et version installee absente restent explicites.
- O: version egale est verte.
- M: plusieurs lancements partagent un verrou de refresh.
- B: patch est orange; minor/major est rouge.
- I: manifest source, cache local et etat installe ont des schemas bornes.
- E: timeout ou echec reseau conserve le dernier cache sans bloquer le menu.

## Test Strategy

Test-first pour la comparaison SemVer et le cache via fixtures PowerShell, puis contrats statiques de packaging. Evidence-first pour le rendu du menu installe apres bootstrap de la branche publiee.

## Current Chantier Flow

- spec: ready
- implementation: done
- verification: passed
- delivery: pending
