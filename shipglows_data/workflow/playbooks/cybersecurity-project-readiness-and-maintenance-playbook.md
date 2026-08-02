---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: "cybersecurity project readiness and maintenance"
owner: "ShipGlows"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
depends_on: []
supersedes: []
evidence:
  - "Added as the first reusable cybersecurity lifecycle pilot for project launch and ongoing maintenance."
next_step: "/010-sg-technical audit security posture for a governed project"
---

# Playbook — Cybersécurité projet : readiness et maintenance

## Purpose

Fournir une séquence réutilisable pour vérifier la posture de cybersécurité d’un projet avant publication, puis maintenir cette posture pendant son exploitation.

Ce playbook organise les contrôles et les preuves. Il ne remplace pas une expertise d’incident, un test d’intrusion autorisé, une revue conformité ou une décision de risque explicite.

## Applicability

Utiliser lors de :

- la création ou l’import d’un projet ;
- la préparation d’une mise en ligne ;
- une revue périodique de sécurité ;
- une modification d’authentification, de permissions, de dépendances ou de données ;
- un signal de vulnérabilité ou d’exposition.

## Inputs

- surfaces et environnements concernés ;
- données traitées et niveau de sensibilité ;
- mécanismes d’authentification et d’autorisation ;
- dépendances et fournisseur d’hébergement ;
- accès disponibles pour la vérification ;
- politique de sauvegarde, journalisation et réponse incident ;
- contraintes de confidentialité et preuves déjà existantes.

## Execution Order

### 1. Périmètre et exposition

- déclarer les surfaces publiques, privées, API, admin et CI/CD ;
- distinguer production, préproduction, développement et données locales ;
- identifier les points d’entrée, intégrations et flux de données ;
- noter les accès ou informations manquants comme limites, jamais comme validations.

### 2. Identités, accès et secrets

- vérifier les rôles, permissions et chemins d’administration ;
- confirmer que les secrets ne sont pas versionnés ou exposés dans les logs ;
- vérifier la rotation, la révocation et la séparation des environnements ;
- confirmer que les actions sensibles sont protégées côté serveur ou fournisseur autoritatif.

### 3. Code, dépendances et configuration

- rechercher les alertes de dépendances et versions non maintenues ;
- vérifier les configurations de production, headers et règles de transport ;
- contrôler les surfaces d’upload, de webhook, de redirection et d’intégration ;
- documenter les exceptions acceptées et leur date d’expiration.

### 4. Données, sauvegardes et observabilité

- identifier les données collectées, conservées et supprimées ;
- vérifier que les sauvegardes sont configurées et récupérables ;
- contrôler la présence de journaux utiles sans y exposer de secrets ou données privées ;
- définir les alertes, propriétaires et seuils de réaction pertinents.

### 5. Préparation incident et décision

- documenter le canal de signalement et le propriétaire de l’escalade ;
- définir les premières actions sûres : contenir, préserver les preuves, révoquer, restaurer ;
- classer les findings par sévérité, exploitabilité, impact et effort ;
- router les corrections vers `TASKS.md`, les specs ou le registre de preuve selon leur nature.

### 6. Vérification et maintenance

- conserver une preuve redacted et datée pour chaque contrôle requis ;
- effectuer la revue récurrente selon la cadence déclarée ;
- créer une nouvelle instance pour chaque période, sans écraser l’historique ;
- réouvrir le contrôle après une modification matérielle ou un signal nouveau.

## Decision Gates

- `ready` : périmètre, propriétaires, preuves et risques acceptés sont explicites ;
- `needs_review` : une surface, une donnée ou une preuve importante est inconnue ;
- `blocked` : une correction ou un accès autorisé est indispensable ;
- `verified` : les contrôles requis sont exécutés avec preuve ou exception documentée ;
- `retired` : la surface ou le contrôle n’est plus applicable, avec raison conservée.

## Outputs

- checklist cybersécurité complétée ;
- findings priorisés et routés ;
- pointeurs de preuve redacted ;
- prochaine date de revue ;
- politique de reprise si le projet est en pause.

## Linked Checklists

- `shipglows_data/workflow/checklists/cybersecurity-project-readiness-and-maintenance-checklist.md`

## Failure Modes

- considérer l’absence de signal comme une preuve de sécurité ;
- scanner ou tester une cible sans autorisation explicite ;
- stocker des secrets, tokens ou logs privés dans les preuves Git ;
- confondre `security_impact` du document avec le domaine `cybersecurity` du projet ;
- fermer une revue récurrente sans créer l’occurrence suivante ;
- transformer un finding sécurité en simple checkbox sans propriétaire ni échéance.
