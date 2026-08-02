---
artifact: checklist
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
  - shipglows_data/workflow/playbooks/content-publication-and-editorial-operations-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal content operations master"]
next_step: "/007-sg-content audit editorial publication for a governed project"
---

# Checklist maître — Contenu et publication éditoriale

## Purpose

Vérifier qu’un contenu est utile, exact, relu, publiable et maintenable.

## Applicability

Articles, guides, FAQ, documentation publique, pages éditoriales et mises à jour.

## Required Before Start

- brief, audience et destination identifiés;
- sources et statut de vérification déclarés;
- propriétaire éditorial et relecteur identifiés.

## Checklist

### Préparation

- [ ] `content-brief-audience` — Le brief, l’audience et l’objectif sont définis.
- [ ] `content-source-register` — Les sources et leur niveau de vérification sont enregistrés.
- [ ] `content-angle-structure` — L’angle et la structure répondent à un besoin réel.

### Production et revue

- [ ] `content-accuracy` — Les faits, citations et chiffres sont vérifiés.
- [ ] `content-usefulness` — Le contenu apporte une réponse ou une action utile.
- [ ] `content-editorial-quality` — Ton, structure, lisibilité et accessibilité sont relus.
- [ ] `content-links-media` — Liens, médias, références et attributs sont contrôlés.

### Publication et maintenance

- [ ] `content-destination` — La destination éditoriale et les relations avec les autres contenus sont déclarées.
- [ ] `content-publish-proof` — La version publiée et sa date sont vérifiées.
- [ ] `content-refresh-owner` — Un propriétaire et une prochaine date de révision existent.

## Completion Rule

Le cycle est complet quand le contenu est vérifié, relu, publié sur la bonne surface et rattaché à une maintenance future.

## Linked Playbook

- `../playbooks/content-publication-and-editorial-operations-playbook.md`

## Exceptions

Un contenu exploratoire peut rester non publié, mais son statut, ses limites et son prochain propriétaire doivent être explicites.
