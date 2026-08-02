---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlowz
created: "2026-06-23"
updated: "2026-08-02"
status: draft
source_skill: 001-sg-build
scope: app-blueprints-index
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
depends_on: []
supersedes: []
evidence:
  - "2026-08-02 auth reference audit: local Flutter blueprint updated with the validated Clerk native Android bridge contract."
  - "2026-08-02 registry check: historical blueprint source repository is unavailable; local cache remains the checked source."
next_review: "2026-08-15"
next_step: "Republish the flutter-crud-content blueprint repository and compare it with the local cache"
linked_systems:
  - skills/references/app-blueprints.md
  - skills/app-blueprints/
---

# App Blueprints Registry

Blueprints are global spec skeletons for recurring app archetypes. Each blueprint lives in its own GitHub repo so it survives independently of ShipGlowz.

## Available Blueprints

| ID | Name | Source Repo | Keywords |
|---|---|---|---|
| `flutter-crud-content` | Flutter CRUD Content App | https://github.com/dianedefores/shipflow-blueprint-flutter-crud-content | content, crud, carnet, gestion, flutter, mobile |

## Résolution

Le Blueprint Gate (dans `001-sg-build`) résout chaque blueprint dans cet ordre :
1. Cache local : `$SHIPFLOW_ROOT/skills/app-blueprints/<id>/blueprint.md`
2. Clone depuis `source.repo` si le cache local n'existe pas
3. Aucun blueprint si les deux échouent

### Maintenance note

`flutter-crud-content` is currently available in the ShipGlowz local cache at
version `1.2.0`, including the validated Clerk native Android bridge contract.
The historical `source.repo` URL is currently unavailable on GitHub; do not
silently replace the local cache with a fresh clone until the blueprint repo is
republished and its contents are checked against the cache.

## Ajouter un Blueprint

1. Créer un repo GitHub `shipflow-blueprint-<id>`
2. Y pousser le `blueprint.md` + éventuels `references/`
3. Ajouter une entrée dans ce registre + créer le dossier local

## Contrat système complet

Voir `$SHIPFLOW_ROOT/skills/references/app-blueprints.md`.
