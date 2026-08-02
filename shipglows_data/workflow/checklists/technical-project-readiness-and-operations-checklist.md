---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: technical-project-readiness-and-operations
owner: ShipGlows
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/technical-project-readiness-and-operations-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal technical master"]
next_step: "/010-sg-technical audit technical readiness for a governed project"
---

# Checklist maître — Technique projet

## Purpose

Contrôler la base technique commune d’un projet sans remplacer les checklists spécialisées.

## Applicability

Avant lancement, migration, changement d’architecture ou revue technique mensuelle.

## Required Before Start

- dépôt et environnement cible identifiés;
- architecture et surfaces déclarées;
- propriétaire technique et preuves disponibles identifiés.

## Checklist

### Périmètre et configuration

- [ ] `technical-architecture-surfaces` — Architecture, surfaces et dépendances principales sont déclarées.
- [ ] `technical-environments` — Développement, préproduction et production sont distingués.
- [ ] `technical-configuration` — Configuration, variables attendues et secrets hors dépôt sont vérifiés.

### Qualité et livraison

- [ ] `technical-build` — Le build reproductible et les commandes de vérification sont connus.
- [ ] `technical-tests` — Les tests pertinents passent ou leurs limites sont documentées.
- [ ] `technical-dependencies` — Dépendances, lockfile et alertes sont revus.
- [ ] `technical-deploy` — Le chemin de déploiement et le rollback sont documentés.

### Exploitation

- [ ] `technical-routes-integrations` — Routes critiques et intégrations sont vérifiées.
- [ ] `technical-documentation` — Documentation et runbooks techniques sont accessibles.
- [ ] `technical-review` — Findings, preuves et prochaine revue sont enregistrés.

## Completion Rule

Le cycle est complet quand la base technique est déclarée, vérifiée et documentée, et que les contrôles spécialisés ont leur propre instance ou une exception explicite.

## Linked Playbook

- `../playbooks/technical-project-readiness-and-operations-playbook.md`

## Exceptions

Un contrôle non applicable doit comporter une justification; une preuve inaccessible devient `needs_review`.
