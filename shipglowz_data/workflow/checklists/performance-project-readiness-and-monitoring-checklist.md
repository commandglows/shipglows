---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlowz
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: performance-project-readiness-and-monitoring
owner: ShipGlowz
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglowz_data/workflow/playbooks/performance-project-readiness-and-monitoring-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal performance master"]
next_step: "/010-sg-technical audit performance for a governed project"
---

# Checklist maître — Performance projet

## Purpose

Vérifier que la performance est mesurée, pilotée et maintenue par preuves.

## Applicability

Avant lancement, après changement important, puis selon une revue hebdomadaire ou mensuelle adaptée au projet.

## Required Before Start

- parcours et surfaces prioritaires déclarés;
- appareil, réseau, région et environnement de mesure définis;
- baseline et seuils attendus disponibles;
- propriétaire des corrections identifié.

## Checklist

### Périmètre et baseline

- [ ] `performance-scope-surfaces` — Les surfaces et parcours prioritaires sont déclarés.
- [ ] `performance-scope-conditions` — Les conditions de mesure sont reproductibles.
- [ ] `performance-baseline` — Une baseline datée existe pour chaque parcours prioritaire.

### Budgets et mesures

- [ ] `performance-budgets` — Les budgets de chargement, poids, latence ou consommation sont définis.
- [ ] `performance-user-metrics` — Les métriques utilisateur pertinentes sont suivies.
- [ ] `performance-runtime-metrics` — Les métriques runtime, erreurs et ressources sont suivies lorsque pertinent.
- [ ] `performance-mobile` — Le scénario mobile ou appareil contraint est couvert.

### Correction et suivi

- [ ] `performance-findings` — Les régressions sont classées, assignées et routées vers `TASKS.md`.
- [ ] `performance-before-after` — Chaque correction importante possède une preuve avant/après comparable.
- [ ] `performance-review-cadence` — La prochaine revue et son déclencheur sont déclarés.

## Completion Rule

Le cycle est complet quand les parcours applicables sont mesurés, les seuils sont connus, les écarts sont routés et la preuve de comparaison est archivée.

## Linked Playbook

- `../playbooks/performance-project-readiness-and-monitoring-playbook.md`

## Exceptions

Toute métrique indisponible doit être notée avec sa limite, son propriétaire et une date de reprise.
