# Installation Run Trace

Date UTC: 2026-04-28

Conventions du 2026-04-28 : les prochaines exécutions de scripts d'installation utilisent des dossiers non-cachés en kebab-case : `install-logs/` pour les logs bruts et `install-reports/` pour les rapports Markdown.

Note: `.install-runs/` est un dossier historique utilisé pour les premières traces manuelles de bootstrap. Il ne doit plus être utilisé par les scripts.

Context:
- Goal: run current install scripts as-is to bootstrap the server aggressively, then record failures and follow-up work.
- Order: ShipGlows first, dotfiles second.
- Effective shell user observed before run: `ubuntu` with sudo group membership.
- This trace records install behavior; it is not an implementation spec.

## Runs

| Time UTC | Repo | Command | Status | Log | Notes |
|---|---|---|---|---|---|
| 2026-04-28 14:37 UTC | ShipGlows | `sudo ./install.sh` | completed | `.install-runs/shipglows-20260428T143731Z.log` | Installed/verified Node, PM2, Vercel, Convex, Clerk, Supabase, Flox, gh, PyYAML, Caddy; configured root, `opc`, and `ubuntu`. |
| 2026-04-28 14:39 UTC | dotfiles | `./install.sh` | completed with warnings | `.install-runs/dotfiles-20260428T143900Z.log` | Installed many tools, Claude Code, Codex, MCP config, shell aliases. Initial Neovim/Bat/PATH issues were found. |
| 2026-04-28 14:48 UTC | dotfiles | `USER_LOCAL_MODE=true ./install.sh --only=shell-integration` | completed | `.install-runs/dotfiles-pathfix-20260428T144800Z.log` | Added user-local PATH block to `.bashrc`. |
| 2026-04-28 14:50 UTC | dotfiles | `USER_LOCAL_MODE=true ./install.sh --only=neovim` | completed | `.install-runs/dotfiles-neovimfix-20260428T145000Z.log` | Installed Neovim and Bat into `~/.local/bin`; final tool summary OK. |

## Findings

| Time UTC | Repo | Severity | Finding | Corrected now? | Follow-up |
|---|---|---|---|---|---|
| 2026-04-28 14:38 UTC | ShipGlows | low | `npm warn deprecated tar@7.5.7` during Vercel CLI install. Install still completed. | no | Recheck whether this is only a transitive npm warning from the current Vercel release. |
| 2026-04-28 14:38 UTC | ShipGlows | expected/spec gap | Current script configured root + every `/home/*` user (`opc`, `ubuntu`) automatically. | no | Covered by `INSTALLATION-OWNERSHIP-SPEC.md` and `specs/install-user-targeting.md`. |
| 2026-04-28 14:42 UTC | dotfiles | medium | Neovim printed `Permission denied` for `/opt/nvim` and `/usr/local/bin/nvim`, but the script still printed success. | yes | Reran Neovim in `USER_LOCAL_MODE=true`; also a script bug remains: false success should be fixed later. |
| 2026-04-28 14:42 UTC | dotfiles | medium | `bat installation failed` in the main dotfiles run. | yes | Reran with `USER_LOCAL_MODE=true --only=neovim`; dependency phase installed `bat` into `~/.local/bin`. |
| 2026-04-28 14:42 UTC | dotfiles | low | `fzf installation may have failed` even though `/home/ubuntu/.local/bin/fzf` exists after install. | partially | Tool is available after PATH fix; script detection/health messaging should be reviewed. |
| 2026-04-28 14:44 UTC | dotfiles | medium | Dotfiles called cloned `~/shipglows/install.sh` without sudo, so ShipGlows printed root-required error. | no | Covered by ownership spec: dotfiles should not silently run ShipGlows installer, or must call an explicit handoff. |
| 2026-04-28 14:45 UTC | dotfiles | low | Starship has no arm64 musl prebuilt path; script installed Rust and compiled from source. | yes | No action required for this server; keep as expected slow path for arm64. |
| 2026-04-28 14:48 UTC | dotfiles | medium | `~/.local/bin` was not in `.bashrc` after the first run, so user-local tools were installed but not immediately discoverable after shell reload. | yes | Reran shell integration with `USER_LOCAL_MODE=true`; `.bashrc` now includes `~/.local/bin` and `~/.npm-global/bin`. |

| 2026-04-28 15:00 UTC | Codex/ShipGlows skills | medium | ShipGlows skills were present in repo but missing from /home/ubuntu/.codex/skills and /home/ubuntu/.claude/skills; Codex only saw system skills. | yes | Recreated 50 symlinks for ubuntu; installer should be fixed to verify/link and report count. |

| 2026-04-28 15:10 UTC | ShipGlows/install.sh | medium | Installer did not verify skill symlinks and could report a user as configured even if Codex/Claude skills were absent. | yes | Patched configure_skills to link only valid SKILL.md directories, verify Claude/Codex links, report counts, and mark user setup with warnings on failure. Tested against a temp home: 49 Claude + 49 Codex skills linked. |
| 2026-04-28 17:21 UTC | ShipGlows/install.sh | low | A legacy `skills/references` symlink in `.claude/skills` and `.codex/skills` still pointed to the removed uppercase repo path after the repo rename. This was a local rename residue, not a failing skill install. | yes | Removed both stale symlinks and patched `configure_skills` to clean that legacy entry before linking valid skills. Recheck: 49 Claude + 49 Codex skill files, 0 broken links. |
| 2026-04-28 | dotfiles/install.sh | medium | Running dotfiles as non-root with sudo available exposed two installer bugs: Neovim wrote to `/opt/nvim` and `/usr/local/bin/nvim` without sudo, and `bat`/`lsd`/`gh` paths called an undefined `run_with_sudo` helper. | yes | Added `run_with_sudo` as an alias to the existing privilege wrapper, routed Neovim system-path writes through that wrapper, and added privilege-scope logging. |
| 2026-04-28 | ShipGlows/install.sh | info | Running ShipGlows without root applies no partial install: it exits before system dependencies and all-user configuration. | yes | Root-check logs now list the skipped root-only scope: Node.js system install, global npm CLIs, Supabase binary, PM2 systemd startup, Flox .deb, apt tools, GitHub CLI, PyYAML, Caddy, `/etc/dokploy/compose`, and all-user ShipGlows config. |
| 2026-04-28 | docs + installers | info | The root/non-root explanation from the install investigation needed to be reusable for operators, not only present in chat. | yes | Added install privilege sections to ShipGlows and dotfiles README, expanded the ownership spec communication contract, added runtime privilege-scope console/log messages, and changed dotfiles to print the `sudo ~/shipglows/install.sh` handoff instead of relaunching ShipGlows non-root. Editorial site/hub/FAQ surfaces were intentionally not touched. |

## Root vs non-root install scope

ShipGlows is intentionally root-only. If launched without root, it stops before applying system changes. A successful root run adds or verifies: Node.js, PM2, Vercel CLI, Convex CLI, Clerk CLI, Supabase CLI, Flox, GitHub CLI, Caddy, Python3/PyYAML, git/curl/jq/fuser/ss, PM2 startup, `/etc/dokploy/compose`, and ShipGlows config for root plus regular `/home/*` users.

dotfiles is user-first. In non-root user-local mode it can install or configure: `~/.local/bin`, `~/.npm-global`, npm CLIs, shell aliases/PATH, MCP config, app config symlinks, fonts, fzf, zoxide, yazi, Starship fallback build, Claude/Codex user config. Without sudo/root it cannot install apt/dpkg packages or write `/opt`, `/usr/local/bin`, `/etc`, system services, or create/configure another sudo user.

On this server, the important distinction is:
- ShipGlows was already run successfully with `sudo` at 2026-04-28 14:37 UTC, so the main root-only ShipGlows dependencies are present.
- dotfiles was run as `ubuntu`, not root. Because `ubuntu` had sudo access, most apt/system parts were allowed, but the old dotfiles code still failed Neovim and bat due to script bugs. Neovim and bat were then corrected by the user-local rerun at 14:50 UTC.
- Passing dotfiles itself through root would additionally enable the interactive non-root user creation/provisioning branch: create a dev user, copy root SSH keys, add it to sudo, set PATH in that user's `.bashrc`, and run a limited dotfiles setup for that user. It would not be the preferred normal mode for daily user dotfiles, because most config is meant to land in the target user's home.
