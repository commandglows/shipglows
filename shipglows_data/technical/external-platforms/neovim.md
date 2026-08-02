---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 300-sg-docs
scope: external-platform-neovim
owner: Diane
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/references/operator-roles/neovim-specialist.md
  - /home/claude/dotfiles/nvim/
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    required_status: draft
supersedes: []
evidence:
  - "Neovim official documentation checked 2026-07-12: user manual, Lua guide, Lua API, and API contract."
  - "Local dotfiles evidence: nvim/MyNeovim, nvim/MyNeovimTermux, lazy-lock.json, and shell integration scripts."
next_review: "2026-08-12"
next_step: "/300-sg-docs technical audit"
---

# Neovim Platform Note

## Purpose

This note is the global ShipGlows reference for Neovim configuration, Lua plugins, LSP, Treesitter, headless validation, and the local dotfiles profiles.

It does not replace Neovim documentation. It records the sources and the local rules agents should apply before changing Neovim configuration.

## Source Map

| Need | Primary source |
| --- | --- |
| Documentation index | https://neovim.io/doc/user/ |
| Lua guide | https://neovim.io/doc/user/lua-guide.html |
| Lua API | https://neovim.io/doc/user/lua.html |
| RPC/API contract | https://neovim.io/doc/user/api.html |
| Plugin manager | https://github.com/folke/lazy.nvim |

Freshness evidence on 2026-07-12:

- Neovim documents Lua 5.1 as the stable embedded Lua interface.
- The official Lua guide separates configuration guidance from the lower-level API reference.
- The API contract treats new API functions as optional extensions and requires clients to account for compatibility.
- `lazy.nvim` remains the local plugin-management reference for the dotfiles configuration.

## ShipGlows Decision Rules

- Preserve the separation between `nvim/MyNeovim` and `nvim/MyNeovimTermux`.
- Prefer small Lua modules and explicit plugin specs over hidden side effects.
- Do not use private or underscore-prefixed Neovim APIs in plugin/config code.
- Preserve the lockfile when changing plugins; update it intentionally and review the resulting diff.
- Treat plugin configuration as executable code: validate syntax, loadability, and the relevant runtime path.
- Keep Termux lightweight; do not reintroduce excluded web, MCP, or agent tooling into the Termux profile.
- Keep credentials, tokens, and machine-specific paths out of versioned Neovim config.

## Local Configuration Map

- `nvim/MyNeovim/` — primary workstation profile.
- `nvim/MyNeovimTermux/` — Android/Termux profile.
- `nvim/MyNeovim/lazy-lock.json` — pinned plugin revisions.
- `nvim/shell-integration.sh` — shell integration entrypoint.
- `nvim/README.md` and `nvim/FILES.md` — local configuration documentation.

## Validation

```bash
nvim --headless -u NONE -c 'qa'
nvim --headless -u nvim/MyNeovim/init.lua -c 'qa'
git diff -- nvim/MyNeovim/lazy-lock.json
```

Use a focused plugin or Lua smoke test when the changed module depends on a plugin runtime. Do not treat a syntax-only check as proof that plugin setup succeeds.

## Reader Checklist

- profile changed -> verify the correct workstation vs Termux target
- plugin changed -> inspect `lazy-lock.json` and run a headless load check
- keymap/autocmd changed -> test the affected command or event
- LSP/Treesitter changed -> verify the relevant executable/parser is available
- shell integration changed -> check both the script and the resulting shell behavior

## Maintenance Rule

Update this note when Neovim changes its Lua/API compatibility contract, when the dotfiles profile layout changes, or when the local plugin-management and validation policy changes.
