---
artifact: affiliate_program_registry
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: "ShipGlows"
created: "2026-05-11"
updated: "2026-08-13"
status: draft
source_skill: sg-docs
scope: "affiliate-programs"
owner: "unknown"
confidence: medium
risk_level: medium
target_projects: "ShipGlows and project-local ShipGlows governance corpora"
program_statuses: "candidate, applied, active, paused, rejected, retired"
disclosure_policy: "Affiliate usage must be visible where links or recommendations can generate compensation."
secrets_policy: "Do not store passwords, private API keys, payout credentials, tax details, or private affiliate tokens in this file."
security_impact: yes
docs_impact: yes
evidence:
  - "User requested a formal file for affiliate programs used."
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.3.0"
    required_status: reviewed
supersedes: []
next_review: "2026-09-13"
next_step: "/sg-docs audit affiliate programs"
---

# Affiliate Programs

## Purpose

Ce registre conserve les programmes d'affiliation, referral ou partner utilises par projet. Il sert a garder une trace claire des partenaires, des surfaces ou les liens sont utilises, des obligations de disclosure, du statut du programme et des contraintes de securite.

Ce fichier ne doit jamais contenir de secret, mot de passe, token prive, information fiscale, coordonnee bancaire ou identifiant sensible. Les secrets restent dans un gestionnaire de mots de passe ou un coffre adapte; ce registre peut seulement pointer vers l'emplacement non secret.

## When To Use

- Ajout d'un lien affilie dans une page, un article, une newsletter, une doc, une video ou une ressource.
- Choix d'un programme partenaire pour monetisation ou recommandation.
- Audit GTM, pricing, claims, SEO, disclosure ou conformite.
- Verification qu'un lien public est encore autorise, utile et correctement declare.

## Required Rules

- Toute recommandation remuneree doit avoir une disclosure claire sur la surface concernee.
- Noter les conditions importantes : pays couverts, duree du cookie, commission, restrictions de marque, limitations de contenu.
- Ne pas recommander un outil seulement parce qu'il paie une commission; noter le fit produit et le risque de confiance.
- Verifier regulierement les conditions officielles, car les programmes d'affiliation changent.
- Archiver les programmes retires au lieu de supprimer l'historique si des pages publiques les mentionnaient.

## Status Values

- `candidate`: programme repere, pas encore utilise.
- `applied`: candidature envoyee, en attente.
- `active`: programme accepte et utilise ou pret a etre utilise.
- `paused`: programme suspendu temporairement.
- `rejected`: programme refuse ou abandonne avant usage.
- `retired`: programme anciennement utilise, a ne plus ajouter.

## Program Registry

| Project | Program | Partner | URL | Category | Status | Commission model | Disclosure required | Public surfaces | Credential pointer | Evidence date | Owner | Next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ShipGlows | _No active program yet_ |  |  |  | candidate |  | yes |  | password manager / non-secret pointer only | 2026-05-11 | unknown | Add first reviewed programs |

## Entry Template

### [Project] - [Program Name]

- Partner:
- Official URL:
- Product category:
- Status: `candidate | applied | active | paused | rejected | retired`
- Commission model:
- Cookie / attribution window:
- Payout constraints:
- Geographic constraints:
- Disclosure required: `yes | no | unknown`
- Approved public surfaces:
- Credential pointer: `[non-secret location only]`
- Fit rationale:
- Trust risk:
- Last reviewed:
- Owner:
- Next action:

## Maintenance Rule

Update this file whenever a project adds, removes, pauses, reviews, or publicly uses an affiliate, referral, partner, sponsorship, or revenue-share program.
