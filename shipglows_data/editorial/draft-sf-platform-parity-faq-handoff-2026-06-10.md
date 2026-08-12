---
artifact: editorial_draft
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: ShipGlows
created: "2026-06-10"
updated: "2026-08-12"
status: draft
source_skill: 602-sg-platform-parity
scope: draft-faq-handoff
owner: Diane
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
publication_status: draft-only
content_surfaces:
  - future_faq
  - public_skill_pages
linked_systems:
  - skills/602-sg-platform-parity/SKILL.md
  - site/src/content/skills/sg-platform-parity.md
  - shipglows_data/editorial/content-map.md
depends_on: []
supersedes: []
evidence:
  - "Wave 20 reclassifies the executable platform-parity skill as a linked runtime system and migrates its canonical path to skills/602-sg-platform-parity/SKILL.md; executable SKILL.md files are not versioned documentation dependencies."
  - "sg-platform-parity skill contract says Flutter/shared UI is not proof of product support by itself."
  - "Public skill page states that scaffolds, permissions, and roadmap language are not proof of support."
next_step: "/sg-redact or /sg-docs to turn this draft into a governed public FAQ surface"
---

# Draft FAQ Handoff: Parité Produit Avec Flutter

## Draft Status

Draft only. Do not publish as-is. Route to `sg-redact` for public FAQ copy or
to `sg-docs` if the answer belongs in operator documentation.

## Source Question

**Flutter donne une base commune, mais comment garder la parité produit entre plateformes ?**

## Draft Answer

Flutter réduit le coût d'une base commune, surtout pour l'interface et une
partie de la logique produit. Mais la parité produit ne se déduit pas du
framework. Elle se vérifie capacité par capacité, plateforme par plateforme.

Avec ShipGlows, `sg-platform-parity` part de la promesse utilisateur: qu'est-ce
que l'utilisateur doit pouvoir faire sur le web, Android, iOS, desktop ou une
autre cible déclarée ? Ensuite, la compétence compare cette promesse avec les
preuves disponibles: code partagé, chemins natifs, permissions, tests, CI,
checklists QA, documentation et claims publics.

La règle par défaut est la parité. Une différence est acceptable seulement si
elle est meilleure pour la plateforme, imposée par l'OS, le navigateur, le
store, le matériel ou une permission, ou explicitement acceptée comme
dégradation documentée. Sinon, c'est un écart à router vers le bon propriétaire:
`sg-spec`, `sg-build`, `sg-test`, `sg-verify`, `sg-docs` ou `sg-ship` selon le
cas.

Le résultat attendu n'est pas une promesse abstraite de support complet. C'est
une matrice de parité: même comportement, adaptation meilleure, adaptation
requise, dégradation acceptée, non supporté, ou preuve manquante. Quand la preuve
manque, ShipGlows doit marquer `unknown` ou `proof-gap` au lieu d'affirmer que la
plateforme est prête.

## Claim Constraints

- Ne pas dire que Flutter garantit la parité produit.
- Ne pas dire qu'une plateforme est pleinement supportée sans preuve concrète.
- Ne pas traiter un scaffold, une permission, une dépendance ou une ligne de
  roadmap comme une preuve de support.
- Ne pas promettre une conformité, une sécurité, une confidentialité ou une
  fiabilité supérieure sans audit et preuve dédiée.
- Ne pas masquer les adaptations: si l'expérience diffère, expliquer si elle est
  meilleure, requise, acceptée comme dégradée, non supportée ou encore inconnue.

## Owner Handoff

Route recommandée:

- `sg-redact`: transformer cette réponse en FAQ publique courte, avec ton de
  marque et formulation orientée utilisateur.
- `sg-docs`: intégrer la logique dans une page de documentation ou une note
  opérateur, avec liens vers la matrice de parité et les preuves attendues.

## Reusable Public Copy Candidate

Flutter aide à partager une base de code, mais ShipGlows ne considère pas cela
comme une preuve de parité produit. La parité se vérifie par capacité et par
plateforme, avec des preuves: implémentation, tests, QA, documentation et claims
publics. Les adaptations sont acceptées quand elles sont meilleures pour la
plateforme ou requises par ses contraintes. Sinon, l'écart devient une action à
router vers le bon propriétaire.
