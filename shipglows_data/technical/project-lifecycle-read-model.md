---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: "project lifecycle read model"
owner: Diane
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - templates/project_lifecycle.md
  - skills/references/project-lifecycle-checklist-contract.md
  - tools/shipglows_project_lifecycle_status.py
  - tui/src/sources/lifecycle.ts
  - tui/src/sources/checklistInstances.ts
  - templates/project_checklist_instance.md
  - shipglows_data/workflow/checklist-instances/
  - shipglows_data/workflow/TASKS.md
  - shipglows_data/editorial/ROADMAP.md
depends_on:
  - artifact: "skills/references/project-lifecycle-checklist-contract.md"
    artifact_version: "0.3.0"
    required_status: draft
supersedes: []
evidence:
  - "Lifecycle and checklist-instance parser fixtures and TUI reader tests pass on 2026-07-28."
next_step: "/103-sg-verify project-lifecycle-checklist-operating-model"
next_review: "2026-08-28"
---

# Project Lifecycle Read Model

## Purpose

Définir les données que le TUI, les skills et la future app ShipGlows doivent afficher à partir de la déclaration lifecycle Markdown. Ce document décrit une projection en lecture seule ; il ne crée pas une base de données ni un tracker parallèle.

## Source Authority

Les sources versionnées sont la déclaration `project_lifecycle.md`, ses tables `Lifecycle Items`, et les instances de checklist sous `workflow/checklist-instances/`. Les readers peuvent calculer une projection en cache, mais doivent pouvoir revenir au Markdown et conserver les identifiants stables.

## Project Overview

- `project_id`
- `project_name`
- `repository`
- `lifecycle_phase`
- `last_review`
- `next_review`
- `overall_readiness`
- `operator_timezone`

## Domain Cards

Chaque domaine déclaré expose :

- `domain`
- `applies`
- `owner_role`
- `status`
- `progress`
- `open_required_count`
- `next_due_at`
- `evidence_gap_count`
- `blocker_count`

Pour toute checklist ordonnée, `progress`, `current_phase`, `next_control`, `blocked_controls` et `cycle_id` proviennent de l’instance du projet. Ils ne sont pas reconstruits depuis `TASKS.md`.

Le modèle est transversal : il peut suivre `technical`, `cybersecurity`, `seo`, `marketing`, `copywriting`, `performance`, `analytics`, `launch`, `production`, `maintenance`, ainsi que d’autres domaines déclarés. Dans ce projet, `seo` désigne uniquement le SEO technique ; les mots-clés, la stratégie éditoriale et la création de contenu sont un projet séparé.

Le domaine `cybersecurity` doit rester distinct du champ documentaire `security_impact`.

## Queues And Timeline

La projection expose les instances par identifiant stable dans les files :

- `today`
- `this_week`
- `next_week`
- `overdue`
- `blocked`
- `next_review`

Chaque instance conserve `item_id`, `instance_id`, `type`, `domain`, `state`, `due_at`, `cadence`, `tracker_route`, `evidence`, `next_action` et les diagnostics éventuels.

Une instance de checklist conserve en plus `checklist_id`, `checklist_version`, `cycle_id`, `cycle_kind`, `progress`, `current_phase`, `next_control`, `blocked_controls`, `status_counts` et les contrôles ordonnés. Une instance terminée est archivée ; un nouveau cycle reçoit un nouvel identifiant.

## History And Recurrence

- Une tâche `one_time` vérifiée reste vérifiée jusqu’à réouverture ou retrait.
- Une tâche `recurring` vérifiée clôt l’instance courante et expose l’occurrence suivante.
- Les instances historiques ne sont pas supprimées lors d’un changement de cadence.
- Une pause suspend les nouvelles occurrences récurrentes et conserve une politique de reprise visible.

## Evidence And Security

- Une instance obligatoire sans preuve ne peut pas être `verified`.
- Les pointeurs de preuve sont relatifs, redacted et dépourvus de secrets, tokens, cookies ou logs privés.
- Les valeurs Markdown sont des données ; l’app ne doit jamais les exécuter comme commandes.
- Une erreur de parsing, un doublon, une cadence invalide ou une surface non déclarée reste visible comme diagnostic.

## Routing

- `technical_task` → `shipglows_data/workflow/TASKS.md`
- `editorial_task` → `shipglows_data/editorial/ROADMAP.md`
- `chantier` → `shipglows_data/workflow/specs/`
- `proof` → `shipglows_data/workflow/test-checklists/` ou la preuve nommée

Les contrôles non terminés restent dans l’instance. Seuls les problèmes d’implémentation concrets générés par un contrôle vont dans `TASKS.md`, avec référence au `control_id`.

L’app peut proposer une action ou ouvrir la source, mais ne doit pas écrire dans un tracker sans passer par les règles de routage et de déduplication existantes.

## Compatibility Gate

Avant toute UI lifecycle complète, vérifier :

- parité des IDs, états, échéances et diagnostics entre parser Python, TUI et adapter app ;
- compatibilité avec les projets qui n’ont pas encore de déclaration lifecycle ;
- absence de doublon avec `TASKS.md`, `ROADMAP.md` ou `workflow/specs/` ;
- preuve manuelle des scénarios requis de la checklist opératoire.
