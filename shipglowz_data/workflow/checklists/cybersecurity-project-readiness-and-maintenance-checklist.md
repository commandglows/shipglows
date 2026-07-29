---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: "cybersecurity project readiness and maintenance"
owner: "ShipFlow"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
depends_on: []
supersedes: []
evidence:
  - "Pilot checklist paired with the cybersecurity project readiness and maintenance playbook."
next_step: "/010-sg-technical audit security posture for a governed project"
---

# Checklist — Cybersécurité projet : readiness et maintenance

## Purpose

Contrôler les éléments de sécurité indispensables avant publication et lors des revues périodiques d’un projet.

## Applicability

À utiliser pour les sites, applications, APIs, intégrations, environnements de production et surfaces d’administration déclarés dans le lifecycle du projet.

## Required Before Start

- périmètre et environnement identifiés ;
- propriétaire du projet et propriétaire sécurité identifiés ;
- autorisation explicite pour toute vérification active ;
- données sensibles et contraintes de conservation recensées ;
- sources et preuves disponibles ou manquantes listées.

## Checklist

- [ ] `security-surfaces-environments` — Les surfaces publiques, privées, admin, API et CI/CD sont déclarées.
- [ ] `security-environment-separation` — Les environnements production, préproduction et développement sont séparés.
- [ ] `security-roles-permissions` — Les rôles, permissions et chemins d’administration sont documentés.
- [ ] `security-secrets-privacy` — Aucun secret, token, cookie ou donnée privée n’est présent dans Git, les artefacts publics ou les logs de preuve.
- [ ] `security-access-rotation` — La rotation et la révocation des secrets et accès critiques sont prévues.
- [ ] `security-dependencies` — Les dépendances et alertes de vulnérabilité sont revues.
- [ ] `security-exposure-transport` — Les configurations de transport, headers et règles d’exposition sont vérifiées.
- [ ] `security-integrations-inputs` — Les uploads, webhooks, redirections et intégrations sensibles ont un propriétaire et une règle de validation.
- [ ] `security-data-lifecycle` — Les données collectées, conservées et supprimées sont documentées.
- [ ] `security-backup-restore` — Les sauvegardes sont configurées et un scénario de restauration est défini.
- [ ] `security-logging` — La journalisation utile est disponible sans exposer de données sensibles.
- [ ] `security-incident-escalation` — Le canal de signalement et la procédure d’escalade incident sont connus.
- [ ] `security-findings-routing` — Chaque finding est classé, assigné et routé vers le bon tracker.
- [ ] `security-evidence-exceptions` — Chaque contrôle obligatoire possède une preuve redacted ou une exception documentée.
- [ ] `security-review-cadence` — La prochaine revue et sa cadence sont déclarées.

## Completion Rule

Cette checklist est complète seulement quand :

- les surfaces applicables sont déclarées ;
- les contrôles obligatoires sont vérifiés avec preuve ou exception approuvée ;
- les findings ouverts ont un propriétaire, une échéance et un tracker cible ;
- la prochaine occurrence récurrente est planifiée ;
- aucun secret ou contenu privé n’est copié dans les preuves.

## Linked Playbook

- `shipglowz_data/workflow/playbooks/cybersecurity-project-readiness-and-maintenance-playbook.md`

## Exceptions

- Si l’accès ou la donnée manque, noter `needs_review` ou `blocked` avec la limite exacte.
- Si le projet est en pause, conserver l’instance historique et déclarer la politique de reprise.
- Si un test actif serait nécessaire, obtenir l’autorisation et router vers le propriétaire de preuve adapté.
