---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: maintenance-freshness-and-dependency-operations
owner: ShipGlows
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/checklists/maintenance-freshness-and-dependency-operations-checklist.md
depends_on: []
supersedes: []
evidence: ["Initial transversal maintenance master"]
next_step: "/002-sg-maintain review maintenance for a governed project"
---

# Playbook — Maintenance : fraîcheur et upkeep

## Purpose

Préserver dans le temps la sécurité, la santé, la documentation et la qualité d’un projet sans recréer sa checklist.

## Applicability

Tout projet actif, avec une cadence hebdomadaire, mensuelle, trimestrielle ou déclenchée par événement.

## Inputs

Dépendances, alertes, changements récents, incidents, documentation, sauvegardes, contrôles de sécurité et propriétaires.

## Execution Order

1. Ouvrir la revue selon la cadence et le cycle.
2. Contrôler dépendances, sécurité, production, contenu et documentation applicables.
3. Classer les écarts et créer uniquement les follow-ups nécessaires.
4. Vérifier les corrections et archiver les preuves.
5. Créer le prochain cycle sans modifier l’historique.

## Decision Gates

- Une routine récurrente reste active après sa complétion.
- Un changement de cadence ne réécrit pas les cycles historiques.
- Les suivis techniques, éditoriaux et incidents restent dans leurs trackers respectifs.

## Outputs

Instance clôturée, preuves, tâches/follow-ups routés, exceptions et prochaine occurrence.

## Linked Checklists

- `../checklists/maintenance-freshness-and-dependency-operations-checklist.md`

## Failure Modes

Checklist réinitialisée, dépendance ignorée, documentation périmée, tâche dupliquée ou routine clôturée définitivement après un seul passage.
