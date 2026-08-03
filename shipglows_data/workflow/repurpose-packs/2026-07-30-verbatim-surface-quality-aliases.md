---
artifact: verbatim_archive
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-30"
updated: "2026-07-30"
status: draft
source_skill: 007-sg-content
scope: surface-quality-aliases
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: no
source_type: conversation
source_ref: "Four immediately preceding user/assistant messages before $007-sg-content repurpose verbatim 4"
linked_systems:
  - shipglows_data/workflow/specs/approved-surface-protection-and-product-atlas.md
depends_on: []
supersedes: []
evidence:
  - "Four immediately preceding user/assistant messages preserved verbatim at the operator's request."
next_step: "None; verbatim preservation only."
---

# Verbatim Archive

User message 1

Ça veut dire qu'on pourrait avoir des meilleurs alias pour l'utilisateur, par exemple gold, diamond, bronze, plutôt que de dire fluid review etc

Assistant message 2

Oui, c’est plus intuitif pour l’utilisateur. On peut utiliser des niveaux « précieux » comme interface, tout en gardant des statuts techniques internes.

Je proposerais :

| Alias utilisateur | Signification |
|---|---|
| `:bronze` | Base validée, mais encore facilement modifiable |
| `:silver` | Surface stable, modification avec avertissement |
| `:gold` | Surface parfaite, dimension protégée par défaut |
| `:diamond` | Surface intouchable, modification ou renouvellement soumis à approbation explicite |

Exemples :

```text
sg-design :bronze bfc.home.hero
sg-copy :gold bfc.home.hero
sg-design :diamond bfc.navigation.header
sg-surface :gold bfc.checkout.payment
```

La commande la plus forte serait :

```text
sg-surface :diamond bfc.home.hero
```

Cela protégerait simultanément :

- le copywriting ;
- le design ;
- la structure ;
- le comportement.

En interne, on conserverait les statuts précis (`fluid`, `stable`, `protected`, `needs_review`) pour que le système reste rigoureux. Les niveaux bronze/silver/gold/diamond seraient simplement les alias courts et agréables à utiliser.

User message 3

Mais je pense qu'il faut aussi qu'on ait des aliases pour les trucs que je trouve vraiment nuls. Comme ça ça indique à l'IA les endroits où je voudrais qu'elle se concentre, parce que, par exemple, sur telle partie du site, voilà, pour l'instant rien n'est apprécié.

Assistant message 4

Oui, il faut aussi pouvoir exprimer explicitement : « cette zone ne me plaît pas, concentre-toi dessus ».

Je proposerais une échelle complète :

| Alias | Signification |
|---|---|
| `:red` | Mauvais ou rejeté, à retravailler en priorité |
| `:rough` | Brouillon ou solution temporaire |
| `:bronze` | Correct, mais encore améliorable |
| `:silver` | Stable et satisfaisant |
| `:gold` | Parfait, protégé |
| `:diamond` | Intouchable sans validation explicite |

Exemples :

```text
sg-design :red bfc.home.hero
sg-copy :rough bfc.menu.catalog
sg-design :gold bfc.navigation.header
sg-surface :diamond bfc.checkout.payment
```

Une zone `:red` signifie :

- l’IA peut proposer une refonte ;
- elle doit la traiter comme une priorité ;
- elle ne doit pas préserver aveuglément l’existant ;
- elle doit quand même respecter les invariants fonctionnels, sécurité, accessibilité et design system.

On pourrait aussi ajouter une commande de priorité sans changer le niveau de qualité :

```text
sg-focus bfc.home.hero
```

Mais je pense que `:red` suffit pour commencer : il indique à la fois que la zone est faible et qu’elle mérite de l’attention.

