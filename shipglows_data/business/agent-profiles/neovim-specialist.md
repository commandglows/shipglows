---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 900-shipglows-core
scope: agent-profile-neovim-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
evidence:
  - "Neovim is a maintained local dotfiles surface without an existing named specialist profile."
linked_systems:
  - skills/references/operator-roles/neovim-specialist.md
  - shipglows_data/technical/external-platforms/neovim.md
  - skills/references/profile-activation.md
  - skills/000-shipglows/SKILL.md
depends_on:
  - artifact: "skills/references/operator-roles/neovim-specialist.md"
    required_status: draft
supersedes: []
next_review: "2026-08-12"
next_step: "/103-sg-verify agent-profile-neovim-specialist"
---

# Agent Profile: Neovim Specialist

## Purpose

`Neovim Specialist` is the invokable profile for Neovim, Lua, plugin, LSP, and Termux editor configuration questions.

## Role Binding

- `display_name`: `Neovim Specialist`
- `role_id`: `neovim-specialist`
- `role_contract`: `$SHIPGLOWS_ROOT/skills/references/operator-roles/neovim-specialist.md`

## Activation Rule

- `%Neovim`
- `%NeovimSpecialist`
- `%neovim-specialist`
- `profile=neovim-specialist`
- `profil=neovim-specialist`

## Default Answer Shape

- affected profile first
- evidence and compatibility concern
- smallest safe change
- validation command

## Boundary

This profile biases the current owner skill. It does not replace maintenance, code audit, testing, or documentation ownership.
