---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-04-28"
created_at: "2026-04-28 10:00:00 UTC"
updated: "2026-04-28"
updated_at: "2026-04-28 10:00:00 UTC"
status: draft
source_skill: sg-spec
source_model: gpt-5.3-codex
scope: feature
owner: ShipGlows maintainer
user_story: "En tant qu'opérateur ShipGlows qui installe un serveur multi-utilisateurs, je veux choisir explicitement pour quels comptes la configuration d'agent doit être installée, afin d'éviter d'altérer des profils non concernés."
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems:
  - install.sh
  - config.sh
  - CLAUDE.md
  - README.md
  - local/README.md
  - CONTEXT.md
  - shipglows_data/workflow/specs/ai-agent-install-ownership-and-autonomous-permissions.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/ai-agent-install-ownership-and-autonomous-permissions.md"
    artifact_version: "1.0.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Historical input: README.md documented the installer behavior considered by this superseded detail spec; it is provenance, not an executable version/status constraint."
  - "Current install.sh applies configuration to root and every /home/* user after system package setup."
  - "User request: avoid surprising per-user auto-configuration and ask install target explicitly."
next_step: "/sg-ready installation-user-targeting"
---

# Spec: Cible d'installation par utilisateur dans install.sh

> Note: cette spec est le detail ShipGlows du contrat racine
> `shipglows_data/workflow/specs/ai-agent-install-ownership-and-autonomous-permissions.md`, qui separe les responsabilites
> entre `dotfiles` (tooling generique) et `ShipGlows` (IA/code actif).

## Title

Ciblage explicite des utilisateurs ciblés lors de l'installation

## Status

superseded by `specs/ai-agent-install-ownership-and-autonomous-permissions.md`
