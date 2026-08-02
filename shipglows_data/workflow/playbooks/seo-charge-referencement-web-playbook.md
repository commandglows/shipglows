---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-07-28"
status: reviewed
source_skill: 203-sg-research
scope: "playbook maître SEO technique"
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
  - "La fiche metier SEO requiert un noyau commun de diagnostic, technique, contenu, mesure et coordination transverse."
  - "Le rapport de recherche du 2026-06-27 identifie 4 familles operatoires et recommande une decomposition en sous-specialites."
next_step: "/007-sg-content repurpose <source> ou /300-sg-docs pour diffuser le playbook et sa checklist"
---

# Playbook maître — SEO technique

## Purpose

Playbook transverse pour auditer, corriger et maintenir la fondation SEO technique d’un site ou d’un produit.

La recherche de mots-clés, les intentions de recherche, la stratégie éditoriale et la création de contenu sont hors périmètre et relèvent d’un autre projet.

## Applicability

Utiliser ce playbook quand il faut:

- auditer un site ou ses surfaces indexables;
- prioriser des corrections techniques;
- préparer une migration, une mise en ligne ou une refonte technique;
- suivre les effets dans Search Console, analytics, crawl ou logs;
- cadrer un agent spécialisé en SEO technique.

## Operating Model

Le travail se découpe en 3 responsabilités techniques:

- `seo-audit-analyst`
- `seo-technical-implementer`
- `seo-performance-reporter`

Un agent generaliste ne doit pas tout melanger. Le bon enchainement est:

1. déclarer le périmètre et les environnements;
2. contrôler crawl, indexation et architecture;
3. contrôler rendu, balises, données structurées et internationalisation;
4. contrôler performance et signaux de production;
5. corriger ou spécifier les changements;
6. recontrôler, prouver et archiver le cycle.

## Inputs

- URL, page, site ou corpus cible;
- objectif business;
- contexte produit et surfaces indexables;
- donnees Search Console, analytics, crawl, logs ou exports disponibles;
- contraintes techniques, CMS, routing, internationalisation ou schema;
- historique des changements SEO connus.

## Execution Order

### 1. Scope and environment

- définir les environnements et surfaces indexables;
- distinguer production, préproduction et développement;
- noter les contraintes de langue, pays, device, routing et framework.

### 2. Diagnostic technique

- verifier indexabilite, crawlabilite et canonicals;
- inspecter les balises générées, canonicals, liens et données structurées;
- relever les problèmes de duplication d’URL, rendu ou couverture;
- identifier les pages importantes, orphelines ou inaccessibles.

### 3. Prioritization

- classer les findings par severite, effort et impact business;
- distinguer corrections immédiates et chantiers structurels;
- séparer correction technique, preuve manquante et limite d’accès aux données.

### 4. Implementation guidance

- spécifier les changements de routing, métadonnées, schema, maillage ou infrastructure;
- écrire des consignes actionnables pour le responsable technique;
- definir les verifications post-fix.

### 5. Verification

- refaire un crawl ou une inspection cible;
- contrôler les signaux Search Console, analytics, crawl ou logs;
- valider la cohérence entre routes, métadonnées et données structurées;
- confirmer qu’aucune règle d’indexation ou performance n’a été cassée.

### 6. Documentation

- consigner hypotheses, preuves, decisions et resultats;
- garder la trace des changements SEO deployes;
- transformer les findings repetables en checklist ou backlog.

## Decision Gates

- `ready` si le perimetre, les donnees et l'objectif business sont clairs;
- `blocked` si les signaux d'indexation, d'acces ou de gouvernance manquent;
- `needs review` si les conclusions reposent sur des donnees partielles;
- `done` seulement apres verification et documentation.

## Outputs

- diagnostic SEO structure;
- backlog priorise;
- recommandations techniques;
- plan de verification;
- note de synthese pour agent ou humain.

## Linked Checklists

- `shipglows_data/workflow/checklists/seo-charge-referencement-web-checklist.md`

## Failure Modes

- traiter le SEO comme un seul bloc abstrait;
- confondre indexation, contenu et conversion;
- recommander une correction sans preuve;
- oublier le contexte business;
- produire une checklist non executable;
- laisser le resultat vivre seulement dans la conversation.
