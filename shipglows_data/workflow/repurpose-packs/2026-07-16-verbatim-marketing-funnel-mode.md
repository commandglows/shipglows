---
artifact: verbatim_archive
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-16"
updated: "2026-07-16"
status: draft
source_skill: 202-sg-repurpose
scope: marketing-funnel-mode
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

Oui : il faut introduire `funnel`, mais comme mode, pas comme nouvelle skill.

Renommer directement `copywriting` en `funnel` serait trompeur : le copywriting travaille le message d’une offre ; le funnel travaille le parcours complet — étapes, CTA, friction, preuves, analytics et handoffs.

Je proposerais donc :

| Besoin | Mode marketing |
|---|---|
| Demande, concurrence, monétisation | `market` |
| Positionnement et readiness globale | `gtm` |
| Parcours de conversion complet | `funnel` |
| Clarté, ton, microcopy, friction locale | `copy` |
| Offre, persona, objections, preuves, persuasion | `offer` |

`offer` remplacerait le nom `copywriting` : il décrit mieux le résultat recherché et évite la confusion avec `copy`.

Exemples :

```text
/009-sg-marketing copy pricing
/009-sg-marketing offer landing-page
/009-sg-marketing funnel signup-to-paid
/009-sg-marketing gtm global
```

Donc : pas de skill Funnel isolée. Un mode `funnel`, avec son playbook dédié, et un mode `offer` pour l’actuel copywriting. C’est plus lisible et ça évite de recréer exactement la fragmentation qu’on cherche à réduire.
