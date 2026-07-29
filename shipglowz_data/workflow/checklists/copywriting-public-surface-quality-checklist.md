---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlowz
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: copywriting-public-surface-quality
owner: ShipGlowz
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglowz_data/workflow/playbooks/copywriting-public-surface-quality-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal copywriting master"]
next_step: "/009-sg-marketing copywriting audit for a governed project"
---

# Checklist maître — Copywriting

## Purpose

Contrôler la clarté, la crédibilité et l’efficacité des textes d’une surface publique.

## Applicability

Landing page, onboarding, pricing, FAQ, email, documentation ou parcours de conversion.

## Required Before Start

- surface, audience et action attendue identifiées;
- promesse et preuves approuvées disponibles;
- voix de marque et contraintes de contenu connues.

## Checklist

### Clarté et structure

- [ ] `copy-audience-context` — Le texte s’adresse à une audience et un contexte précis.
- [ ] `copy-value-proposition` — Le problème, le bénéfice et la différence sont compréhensibles.
- [ ] `copy-information-hierarchy` — La hiérarchie permet de comprendre rapidement la page.
- [ ] `copy-cta` — Le CTA indique une action claire et cohérente.

### Confiance et exactitude

- [ ] `copy-proof` — Les claims importants possèdent une preuve ou une qualification.
- [ ] `copy-objections` — Les objections et conditions importantes sont traitées.
- [ ] `copy-consistency` — Le texte est cohérent avec le produit, l’offre et la marque.

### Qualité de publication

- [ ] `copy-accessibility` — Le texte reste compréhensible, lisible et accessible.
- [ ] `copy-localization` — Les variantes linguistiques sont synchronisées lorsqu’elles existent.
- [ ] `copy-review` — La version, le relecteur et la prochaine revue sont enregistrés.

## Completion Rule

Le cycle est complet quand la surface est claire pour son audience, que ses claims sont justifiés et que sa publication est traçable.

## Linked Playbook

- `../playbooks/copywriting-public-surface-quality-playbook.md`

## Exceptions

Une preuve ou une traduction manquante est un blocage explicite ou `needs_review`, pas une validation implicite.
