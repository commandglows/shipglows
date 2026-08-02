---
artifact: repurpose_pack
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 202-sg-repurpose
scope: verbatim-conversation-archive
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
source_type: conversation
source_ref: "Two immediately preceding assistant responses about specialist roles and technical references"
linked_systems:
  - skills/references/operator-roles/
  - shipglows_data/technical/external-platforms/
next_step: "/200-sg-redact when turning this archive into a blog article"
depends_on:
  - artifact: "skills/references/repurpose-pack-storage.md"
    required_status: active
supersedes: []
evidence:
  - "Verbatim preservation requested explicitly by the operator."
---

# Archive verbatim — rôles spécialistes et références techniques

## Réponse 1 — verbatim

Oui, c’est fait ✅

Ajouté :

- [Référence technique Neovim](</home/claude/shipglowz/shipglows_data/technical/external-platforms/neovim.md>)
- [Rôle Neovim Specialist](</home/claude/shipglowz/skills/references/operator-roles/neovim-specialist.md>)
- [Profil activable](</home/claude/shipglowz/shipglows_data/business/agent-profiles/neovim-specialist.md>)

Activation possible avec :

```text
%Neovim
%NeovimSpecialist
profile=neovim-specialist
```

Le rôle couvre maintenant :

- Lua et API Neovim ;
- plugins et `lazy.nvim` ;
- séparation workstation/Termux ;
- LSP, Treesitter, keymaps et autocmds ;
- validation headless ;
- lockfile et compatibilité.

La référence est basée sur la documentation officielle Neovim — [documentation générale](https://neovim.io/doc/user/), [guide Lua](https://neovim.io/doc/user/lua-guide.html), [API](https://neovim.io/doc/user/api.html) — et sur la configuration réelle du dépôt dotfiles.

✅ Metadata lint passé sur les 6 fichiers concernés.

## Réponse 2 — verbatim

Oui, mais pas pour chaque technologie.

Une référence technique répond à :

> “Quelle est la documentation fiable et quelles règles techniques sont valides ?”

Un rôle spécialiste répond à :

> “Comment dois-je analyser cette demande avec cette expertise, quelles erreurs détecter et quel workflow choisir ?”

Pour Neovim, le rôle est utile car il ajoute :

- la distinction workstation / Termux ;
- les skills à privilégier ;
- les validations attendues ;
- les pièges locaux du dépôt dotfiles ;
- une activation explicite avec `%Neovim`.

En revanche, créer un rôle `Vercel Specialist` uniquement parce qu’il existe `vercel.md` serait probablement inutile si la référence technique suffit.

Règle simple :

```text
Référence seule :
technologie utilisée de façon standard.

Référence + rôle :
technologie fréquente, complexe, ou avec des règles locales fortes.
```

Les meilleurs candidats sont donc Neovim, Python, Bash, Astro et peut-être Termux. Pas besoin de transformer toute la documentation technique en catalogue de rôles.
