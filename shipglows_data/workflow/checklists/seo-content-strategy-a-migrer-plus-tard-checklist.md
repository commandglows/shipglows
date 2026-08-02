---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-07-28"
status: draft
source_skill: 203-sg-research
scope: "SEO non technique — à migrer plus tard vers le projet contenu"
owner: "ShipGlows"
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
depends_on:
  - artifact: "shipglows_data/workflow/research/charge-referencement-web-competences.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Archive de migration conservant la checklist SEO transverse originale avant la séparation SEO technique / contenu SEO."
next_step: "Migrer cette matière dans le projet de stratégie et de contenu SEO lorsqu’il sera ouvert."
---

# Archive à migrer plus tard — SEO non technique

> Cette checklist conserve le travail SEO transverse historique. Elle n’est pas la checklist active de SEO technique et ne doit pas être utilisée comme telle avant migration vers le projet contenu SEO.

## Purpose

Checklist réutilisable pour contrôler la stratégie SEO, le contenu, la mesure et la priorisation d’un chantier.

## Applicability

Utiliser dans le futur projet de contenu SEO pour :

- stratégie de mots-clés et clusters ;
- intentions de recherche ;
- arborescence éditoriale et cocons ;
- optimisation de pages et contenu ;
- priorisation et coordination éditoriale ;
- mesure et suivi de performance SEO.

## Required Before Start

- objectif business clair ;
- page, site ou corpus identifié ;
- données disponibles ou manquantes notées ;
- propriétaire du chantier identifié ;
- contexte business et produit lu si disponible ;
- source de vérité pour les décisions définie.

## Checklist conservée

- [ ] L’intention de recherche principale est identifiée.
- [ ] Les mots-clés ou clusters cibles sont documentés.
- [ ] L’arborescence, la profondeur de clic et le maillage sont compris.
- [ ] Les titles, meta descriptions et Hn sont passés en revue.
- [ ] L’indexabilité est vérifiée : robots, noindex, canonical, status codes.
- [ ] Les duplications ou cannibalisations sont notées.
- [ ] Le rendu JS ou le crawl ne bloque pas les pages importantes.
- [ ] Les sitemaps et la couverture d’indexation sont contrôlés.
- [ ] Les données structurées utiles sont identifiées.
- [ ] Les signaux Search Console et GA4 sont disponibles ou le manque est noté.
- [ ] Les findings sont classés par impact business et effort.
- [ ] Chaque recommandation est affectée à un owner : technique, contenu, design, produit ou analytics.
- [ ] Un plan de vérification post-changement est défini.
- [ ] Les hypothèses et preuves sont tracées.

## Completion Rule

Cette checklist est complète seulement quand :

- les actions prioritaires sont soit exécutées, soit clairement assignées ;
- les risques SEO majeurs sont documentés ;
- la vérification post-changement est définie ;
- le résultat est rangé dans le corpus du projet contenu SEO.

## Migration Notes

- Les contrôles purement techniques doivent rester dans [la checklist SEO technique](seo-charge-referencement-web-checklist.md).
- Les contrôles de mots-clés, intentions, contenu et stratégie seront repris dans une future checklist maître du projet contenu SEO.
- Ne pas supprimer cette archive lors de la création de cette future checklist : elle sert de source de migration et d’historique.

## Exceptions

- Si le chantier est purement exploratoire, noter `incomplete by design`.
- Si la donnée manque, noter la preuve absente au lieu de forcer une conclusion.
