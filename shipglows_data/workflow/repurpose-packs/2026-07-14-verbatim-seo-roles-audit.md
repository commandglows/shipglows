---
artifact: repurpose_pack
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-14"
updated: "2026-07-14"
status: reviewed
source_skill: 202-sg-repurpose
scope: "verbatim archive of SEO roles audit conversation"
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: no
source_type: conversation
source_ref: "immediately preceding two conversation messages, 2026-07-14"
linked_systems:
  - shipglows_data/workflow/playbooks/seo-charge-referencement-web-playbook.md
  - shipglows_data/workflow/checklists/seo-charge-referencement-web-checklist.md
depends_on: []
supersedes: []
evidence:
  - "Verbatim preservation of the two conversation messages immediately preceding the archival command."
next_step: none
---

# Verbatim Archive

## Message 1 - User

```text
verifie au niveau des roles car il.me semble qu'on en a deja fait une partie $300-sg-docs
```

## Message 2 - Assistant

```text
Oui, tu avais raison : la base existe déjà et elle est cohérente.

- Le rôle invocable `SEO Specialist` est en place. Il sert à arbitrer l’intention de recherche, la découvrabilité et la cohérence page/contenu/claim. [Rôle SEO](/home/claude/shipglowz/skills/references/operator-roles/seo-specialist.md:34)
- Son profil d’activation existe aussi : `%SEO-specialist` ou `profile=seo-specialist`. [Profil](/home/claude/shipglowz/shipglows_data/business/agent-profiles/seo-specialist.md:33)
- Le métier complet de chargé de référencement est déjà découpé en quatre sous-spécialités : audit, implémentation technique, stratégie de contenu et reporting. [Playbook](/home/claude/shipglowz/shipglows_data/workflow/playbooks/seo-charge-referencement-web-playbook.md:44)
- La checklist transverse existe également, avec les contrôles d’intention, indexation, crawl, maillage, données structurées, GA4/Search Console, priorisation et vérification. [Checklist](/home/claude/shipglowz/shipglows_data/workflow/checklists/seo-charge-referencement-web-checklist.md:53)

Le point à retenir : `SEO Specialist` n’est pas censé être toute la fiche métier. C’est une posture de décision. Le playbook et la checklist portent la couverture opérationnelle complète. C’est une bonne séparation : on peut invoquer un spécialiste SEO sans faire croire qu’un seul agent exécute indistinctement audit, technique, contenu et analytics.

Les cinq artefacts ont passé le lint de métadonnées et la topologie documentaire est conforme. Aucun changement n’était nécessaire.

## Chantier

non applicable: audit documentaire ponctuel, sans chantier SEO unique identifié.

Verdict final: couverture SEO existante confirmee et validee  
Horodatage du verdict: 2026-07-14 17:49 Paris time
```
