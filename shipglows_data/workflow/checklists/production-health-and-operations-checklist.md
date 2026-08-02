---
artifact: checklist
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
  - shipglows_data/workflow/playbooks/production-health-and-operations-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal production master"]
next_step: "/405-sg-prod verify production health for a governed project"
---

# Checklist maître — Production et opérations

## Purpose

Contrôler la santé réelle d’un système déployé et sa capacité à être surveillé et récupéré.

## Applicability

Après déploiement, après incident ou selon une revue quotidienne/hebdomadaire adaptée au risque.

## Required Before Start

- cible et environnement de production identifiés;
- accès de lecture et fenêtre de vérification autorisés;
- parcours critiques, contacts et outils de preuve connus.

## Checklist

### Vérité de la cible

- [ ] `production-target` — La cible, version et date de déploiement sont identifiées.
- [ ] `production-health-endpoints` — Les endpoints et parcours critiques répondent correctement.
- [ ] `production-dependencies` — Les dépendances externes critiques sont vérifiées.

### Observabilité

- [ ] `production-errors-logs` — Erreurs, logs utiles et absence d’exposition sensible sont contrôlés.
- [ ] `production-metrics` — Les métriques de disponibilité, latence et ressources sont disponibles.
- [ ] `production-alerts` — Les alertes critiques ont un seuil, un propriétaire et un canal.

### Résilience

- [ ] `production-backups` — Les sauvegardes et leur rétention sont déclarées.
- [ ] `production-restore` — Un scénario de restauration ou de rollback est défini et sa preuve datée.
- [ ] `production-incident-route` — L’escalade incident et le runbook sont accessibles.
- [ ] `production-review` — La prochaine revue de santé est planifiée.

## Completion Rule

Le cycle est complet quand la cible réelle, ses parcours, son observabilité et sa récupération sont vérifiés avec preuves appropriées.

## Linked Playbook

- `../playbooks/production-health-and-operations-playbook.md`

## Exceptions

Une preuve nécessitant un accès privilégié reste `needs_review` avec propriétaire et commande/rapport attendu, sans exposer de secret.
