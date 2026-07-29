---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlowz
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: analytics-measurement-readiness-and-quality
owner: ShipGlowz
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglowz_data/workflow/playbooks/analytics-measurement-readiness-and-quality-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal analytics master"]
next_step: "/010-sg-technical audit analytics for a governed project"
---

# Checklist maître — Analytics

## Purpose

Vérifier que la mesure est utile, exacte, documentée et respectueuse des contraintes de données.

## Applicability

Avant lancement, après modification d’un parcours ou selon une revue mensuelle/trimestrielle.

## Required Before Start

- objectifs et décisions à mesurer déclarés;
- surfaces et événements prioritaires listés;
- outil de mesure et propriétaire identifiés;
- politique de consentement et de conservation disponible.

## Checklist

### Plan de mesure

- [ ] `analytics-objectives` — Les objectifs et décisions métier sont explicités.
- [ ] `analytics-events` — Les événements, propriétés et conversions nécessaires sont définis.
- [ ] `analytics-ownership` — Chaque métrique possède un propriétaire et une définition.

### Confidentialité et conformité

- [ ] `analytics-data-minimization` — Les données collectées sont nécessaires et minimisées.
- [ ] `analytics-consent` — Le consentement et les règles de déclenchement sont vérifiés lorsque requis.
- [ ] `analytics-retention-access` — Accès, conservation et suppression sont documentés.

### Qualité et exploitation

- [ ] `analytics-instrumentation` — Les événements se déclenchent sur les parcours attendus.
- [ ] `analytics-duplicates` — Les doublons, événements manquants et valeurs aberrantes sont contrôlés.
- [ ] `analytics-attribution` — Les limites d’attribution et de filtrage sont documentées.
- [ ] `analytics-review` — Une prochaine revue de qualité est planifiée.

## Completion Rule

Le cycle est complet quand les métriques prioritaires sont définies, les contraintes de données vérifiées, les parcours testés et les limites documentées.

## Linked Playbook

- `../playbooks/analytics-measurement-readiness-and-quality-playbook.md`

## Exceptions

Un accès ou une source indisponible est `needs_review`; aucune estimation ne doit être présentée comme une mesure vérifiée.
