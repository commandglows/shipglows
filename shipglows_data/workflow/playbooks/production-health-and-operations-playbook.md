---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: production-health-and-operations
owner: ShipGlows
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/checklists/production-health-and-operations-checklist.md
depends_on: []
supersedes: []
evidence: ["Initial transversal production master"]
next_step: "/405-sg-prod verify production health for a governed project"
---

# Playbook — Production : santé et opérations

## Purpose

Vérifier la vérité de l’environnement de production, sa santé, son observabilité et sa capacité de récupération.

## Applicability

Tout site, application, API, worker ou intégration déployé et accessible par des utilisateurs ou systèmes externes.

## Inputs

Cible de déploiement, URL/endpoint, logs, métriques, alertes, dépendances, sauvegardes et contacts d’escalade.

## Execution Order

1. Identifier la cible et le périmètre réellement déployé.
2. Vérifier disponibilité, routes critiques et dépendances.
3. Vérifier erreurs, logs, métriques et alertes.
4. Vérifier sauvegarde, rollback et propriétaires.
5. Documenter les écarts et planifier la prochaine revue.

## Decision Gates

- La vérité de production doit être prouvée sur la cible réelle.
- Une alerte sans propriétaire ou runbook est incomplète.
- Une restauration non testée reste une hypothèse.

## Outputs

Rapport de santé, preuves runtime, findings routés, état de récupération et prochaine revue.

## Linked Checklists

- `../checklists/production-health-and-operations-checklist.md`

## Failure Modes

Vérification uniquement en local, logs absents, alerte silencieuse, rollback théorique ou dépendance critique non déclarée.
