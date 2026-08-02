---
artifact: checklist
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
  - shipglows_data/workflow/playbooks/maintenance-freshness-and-dependency-operations-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal maintenance master"]
next_step: "/002-sg-maintain review maintenance for a governed project"
---

# Checklist maître — Maintenance et fraîcheur

## Purpose

S’assurer qu’un projet reste maintenable, sécurisé, documenté et opérationnel dans le temps.

## Applicability

Revue récurrente d’un projet actif ou revue déclenchée par changement, incident ou alerte.

## Required Before Start

- dernier cycle et prochaine échéance connus;
- changements, incidents et alertes depuis la dernière revue disponibles;
- propriétaires des domaines applicables déclarés.

## Checklist

### Santé technique

- [ ] `maintenance-dependencies` — Dépendances, versions obsolètes et alertes sont revues.
- [ ] `maintenance-security` — Les contrôles sécurité et accès critiques sont réévalués.
- [ ] `maintenance-production` — Santé, logs, sauvegardes et alertes de production sont contrôlés.
- [ ] `maintenance-performance` — Les régressions de performance connues sont revues.

### Fraîcheur des surfaces

- [ ] `maintenance-docs` — Documentation, runbooks et références techniques sont à jour.
- [ ] `maintenance-content` — Les contenus et pages publiques à réviser sont identifiés.
- [ ] `maintenance-analytics` — La qualité des mesures et événements est réévaluée lorsque applicable.

### Clôture et suite

- [ ] `maintenance-findings` — Chaque écart est assigné et routé vers le bon tracker.
- [ ] `maintenance-evidence` — Les contrôles vérifiés disposent d’une preuve sans donnée sensible.
- [ ] `maintenance-next-cycle` — La prochaine occurrence et ses conditions sont déclarées.

## Completion Rule

Le cycle est complet quand les domaines applicables sont revus, les écarts routés, les preuves archivées et la prochaine occurrence créée sans écraser l’historique.

## Linked Playbook

- `../playbooks/maintenance-freshness-and-dependency-operations-playbook.md`

## Exceptions

Un projet en pause conserve son dernier cycle, sa raison de pause et sa politique de reprise; il ne génère pas silencieusement de nouvelles tâches.
