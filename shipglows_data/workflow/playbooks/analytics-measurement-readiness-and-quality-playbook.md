---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: analytics-measurement-readiness-and-quality
owner: ShipGlows
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/checklists/analytics-measurement-readiness-and-quality-checklist.md
depends_on: []
supersedes: []
evidence: ["Initial transversal analytics master"]
next_step: "/010-sg-technical audit analytics for a governed project"
---

# Playbook — Analytics : mesure et qualité

## Purpose

Rendre les décisions mesurables sans collecter plus de données que nécessaire ni exposer de données sensibles.

## Applicability

Tout projet ayant des objectifs d’acquisition, activation, conversion, usage, rétention ou support mesurables.

## Inputs

Objectifs, événements métier, surfaces, consentement, politique de données, outils autorisés et propriétaires.

## Execution Order

1. Déclarer objectifs et événements utiles.
2. Vérifier la base légale, le consentement et la minimisation.
3. Implémenter les événements et paramètres nécessaires.
4. Tester collecte, attribution et qualité.
5. Documenter les limites et planifier une revue.

## Decision Gates

- Aucun événement ne doit être collecté sans finalité et propriétaire.
- Une donnée non fiable ne doit pas alimenter une décision présentée comme certaine.
- Toute donnée personnelle ou sensible non nécessaire est un finding de sécurité/confidentialité.

## Outputs

Plan de mesure, matrice événements, preuves de test, limites connues et prochaine revue.

## Linked Checklists

- `../checklists/analytics-measurement-readiness-and-quality-checklist.md`

## Failure Modes

Événements orphelins, doublons, consentement contourné, paramètres excessifs, ou dashboards sans définition métier.
