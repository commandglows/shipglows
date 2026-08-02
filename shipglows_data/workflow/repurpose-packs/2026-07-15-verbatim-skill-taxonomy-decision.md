---
artifact: verbatim_archive
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: draft
source_skill: 202-sg-repurpose
scope: skill-taxonomy-decision
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

🎯 VERDICT (2026-07-15 18:40) : je choisirais les gros routeurs, avec des micro-playbooks — pas des micro-skills.

Une skill doit être une porte publique avec une responsabilité et un cycle de vie. Une micro-tâche n’a pas besoin d’être une skill : c’est un mode, un playbook, une référence ou un outil.

Donc oui, la surface visible pourrait essentiellement être :

```text
000 router
001 build
002 maintain
003 bug
004 deploy
005 ship
006 design
007 content
008 end-user
009 skill-build
```

Puis, par exemple :

```text
/design audit ui
/design audit tokens
/design audit components
/design system
/design playground
```

Le point crucial : `design` ne doit pas devenir un énorme `SKILL.md`. Il reste un contrat court qui reconnaît le mode et charge seulement le playbook concerné. Les actuels `500–504` deviennent des playbooks internes de `006`, donc la finesse opérationnelle reste intacte sans encombrer la découverte.

La bonne séparation serait :

- Skill : propriétaire public, route, garde-fous, preuve.
- Mode : micro-intention invoquée sous ce propriétaire.
- Playbook/référence : procédure détaillée chargée à la demande.
- Outil : exécution mécanique.
- Profil : expertise/lunette (`%Flutter`, `%SEO`, etc.), sans nouveau cycle de vie.

Aujourd’hui, les 69 skills mélangent ces cinq niveaux. C’est pourquoi on a l’impression d’un système à la fois très détaillé et difficile à mémoriser. Les micro-skills seraient justifiées seulement si elles avaient une autorité, un risque ou une réutilisation réellement indépendante — sinon, elles doivent redevenir des modes.
