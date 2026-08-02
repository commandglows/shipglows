---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: marketing-go-to-market-readiness
owner: ShipGlows
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/marketing-go-to-market-readiness-playbook.md
depends_on: []
supersedes: []
evidence: ["Initial transversal marketing master"]
next_step: "/009-sg-marketing gtm audit for a governed project"
---

# Checklist maître — Marketing / go-to-market

## Purpose

Vérifier qu’un projet peut être présenté, distribué et appris auprès d’une audience définie.

## Applicability

Avant lancement, campagne, repositionnement ou revue mensuelle/trimestrielle.

## Required Before Start

- audience et problème prioritaire déclarés;
- offre et objectif business définis;
- canaux envisagés listés;
- preuves disponibles séparées des hypothèses.

## Checklist

### Audience et positionnement

- [ ] `marketing-audience` — L’audience prioritaire et son problème sont précis.
- [ ] `marketing-positioning` — La différence avec les alternatives est formulée.
- [ ] `marketing-offer` — L’offre, le bénéfice et l’action attendue sont cohérents.

### Distribution et preuve

- [ ] `marketing-channels` — Chaque canal a une audience, un message et une hypothèse.
- [ ] `marketing-proof` — Les témoignages, chiffres et claims ont une source ou sont qualifiés.
- [ ] `marketing-funnel` — Le parcours découverte → activation → conversion est décrit.

### Apprentissage

- [ ] `marketing-measurement` — Les événements et indicateurs de décision sont liés à `analytics`.
- [ ] `marketing-experiment` — Le prochain test possède une hypothèse, une durée et un critère de décision.
- [ ] `marketing-review` — La prochaine revue et les décisions attendues sont planifiées.

## Completion Rule

Le cycle est complet quand audience, offre, canal, preuve et mesure sont cohérents, et qu’un apprentissage suivant est planifié.

## Linked Playbook

- `../playbooks/marketing-go-to-market-readiness-playbook.md`

## Exceptions

Une hypothèse non validée reste une hypothèse; elle ne doit pas être transformée en claim public vérifié.
