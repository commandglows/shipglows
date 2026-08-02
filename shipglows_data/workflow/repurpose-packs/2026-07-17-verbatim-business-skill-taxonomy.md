---
artifact: verbatim_archive
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: draft
source_skill: 202-sg-repurpose
scope: business-skill-taxonomy
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: no
source_type: conversation
source_ref: "Immediately preceding assistant message before /202-sg-repurpose verbatim 1"
linked_systems:
  - skills/
depends_on: []
supersedes: []
evidence:
  - "Conversation message preserved verbatim at the operator's request."
next_step: "None; verbatim preservation only."
---

# Verbatim Archive

Assistant message 1

Oui, je comprends : `audit` ne doit pas être une famille métier. C’est une action, donc un mode à l’intérieur de la skill qui possède réellement le sujet.

Je viserais cette carte :

- `design` : design system, UX, accessibilité, audits UI.
- `content` : rédaction, enrichissement, réemploi, qualité éditoriale et traduction.
- `marketing` : marché, GTM, copy et copywriting.
- `seo` : audit SEO, lancement, suivi et corrections SEO.
- `technical` : qualité du code, dépendances, performance, migrations, production.
- `customer` : parcours, activation, onboarding, confiance et friction.

Ainsi, `400-sg-audit` disparaîtrait comme surface publique : il ne resterait qu’un verbe/mode (`technical audit code`, `seo audit`, `design audit`, etc.).

Pour l’i18n, je ferais une séparation nette : la qualité de traduction appartient à `content`, tandis que la synchronisation des clés, locales, fallbacks et chaînes manquantes appartient à `technical`. L’actuelle skill mélange ces deux réalités.

Le prochain chantier que je proposerais devient donc : définir cette taxonomie cible et redistribuer la tranche `400–407`, plutôt que la compacter artificiellement sous `audit`.
