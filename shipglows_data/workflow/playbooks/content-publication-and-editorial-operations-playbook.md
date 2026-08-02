---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: content-publication-and-editorial-operations
owner: ShipGlows
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/checklists/content-publication-and-editorial-operations-checklist.md
depends_on: []
supersedes: []
evidence: ["Initial transversal content operations master"]
next_step: "/007-sg-content audit editorial publication for a governed project"
---

# Playbook — Contenu : publication et opérations éditoriales

## Purpose

Faire passer une idée ou une source à une publication utile, exacte, relue et maintenable.

## Applicability

Articles, guides, pages éditoriales, FAQ, documentation publique et opérations de mise à jour.

## Inputs

Brief, audience, sources, angle, statut éditorial, exigences de relecture, liens internes et date de révision.

## Execution Order

1. Qualifier sujet, audience et source.
2. Définir angle, structure et critères de qualité.
3. Rédiger et enrichir avec sources traçables.
4. Relire exactitude, utilité, ton, liens et accessibilité.
5. Publier, indexer dans la carte éditoriale et planifier la maintenance.

## Decision Gates

- Une source non vérifiée reste non vérifiée.
- La stratégie de mots-clés et l’intention SEO éditoriale sont pilotées ici ou dans le projet marketing, jamais dans le master SEO technique.
- Une publication sans propriétaire de mise à jour n’est pas durable.

## Outputs

Contenu versionné, sources, statut de revue, destination éditoriale, liens et prochaine date de maintenance.

## Linked Checklists

- `../checklists/content-publication-and-editorial-operations-checklist.md`

## Failure Modes

Source absente, paraphrase trompeuse, contenu sans audience, doublon éditorial, liens cassés ou publication sans date de révision.
