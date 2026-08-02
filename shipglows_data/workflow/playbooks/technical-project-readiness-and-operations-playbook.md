---
artifact: playbook
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
  - shipglows_data/workflow/checklists/technical-project-readiness-and-operations-checklist.md
depends_on: []
supersedes: []
evidence: ["Initial transversal technical master"]
next_step: "/010-sg-technical audit technical readiness for a governed project"
---

# Playbook — Technique : readiness et opérations

## Purpose

Vérifier qu’un projet possède une base technique exploitable, documentée et maintenable avant son lancement.

## Applicability

Sites, applications, APIs et intégrations avant lancement, migration ou revue technique mensuelle.

## Inputs

Architecture, environnements, dépôt, dépendances, surfaces, déploiement, observabilité et propriétaires.

## Execution Order

1. Déclarer architecture, surfaces et environnements.
2. Vérifier build, tests, dépendances et configuration.
3. Vérifier déploiement, routes critiques et intégrations.
4. Vérifier documentation, observabilité et récupération.
5. Router les écarts puis planifier le cycle suivant.

## Decision Gates

- Un environnement non déclaré reste `needs_review`.
- Un contrôle technique non prouvé ne peut pas être considéré comme vérifié.
- Les contrôles spécialisés restent dans leurs propres masters : sécurité, SEO, performance et production.

## Outputs

État technique, preuves, findings routés, exceptions et prochaine revue.

## Linked Checklists

- `../checklists/technical-project-readiness-and-operations-checklist.md`

## Failure Modes

Configuration implicite, dépendance non suivie, build non reproductible, documentation absente ou correction locale sans recontrôle.
