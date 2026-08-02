---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: performance-project-readiness-and-monitoring
owner: ShipGlows
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/checklists/performance-project-readiness-and-monitoring-checklist.md
depends_on: []
supersedes: []
evidence: ["Initial transversal performance master"]
next_step: "/010-sg-technical audit performance for a governed project"
---

# Playbook — Performance projet : readiness et monitoring

## Purpose

Mesurer la performance utile au projet, fixer des budgets, corriger les régressions et conserver des preuves comparables.

## Applicability

Sites, applications, APIs et parcours dont la vitesse, la consommation de ressources ou la stabilité influencent l’expérience ou le coût.

## Inputs

Surfaces et parcours prioritaires, appareils et réseaux cibles, métriques disponibles, seuils acceptés, baseline et accès aux environnements.

## Execution Order

1. Déclarer périmètre, parcours et conditions de mesure.
2. Capturer une baseline reproductible.
3. Définir budgets et seuils d’alerte.
4. Identifier les goulots et prioriser les corrections.
5. Re-mesurer avant/après.
6. Planifier le contrôle récurrent et archiver la preuve.

## Decision Gates

- Une comparaison sans conditions identiques est insuffisante.
- Une régression au-dessus du seuil devient une tâche technique.
- Une métrique indisponible reste `needs_review`, jamais un pass implicite.

## Outputs

Baseline, mesures avant/après, budgets, findings routés, exception documentée et prochaine date de revue.

## Linked Checklists

- `../checklists/performance-project-readiness-and-monitoring-checklist.md`

## Failure Modes

Métriques non reproductibles, optimisation d’un écran non représentatif, absence de budget, ou conclusion basée uniquement sur un score synthétique.
