---
artifact: audit_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-11"
created_at: "2026-06-11 14:15:28 UTC"
updated: "2026-06-11"
updated_at: "2026-06-11 14:15:28 UTC"
status: reviewed
source_skill: 102-sg-start
source_model: "GPT-5 Codex"
scope: "cross-project design-system authority inventory"
owner: "Diane"
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
domains:
  - design
  - docs
  - governance
issue_counts:
  critical: 0
  high: 6
  medium: 2
linked_systems:
  - "shipglows_data/workflow/specs/audit-design-system-authority-all-projects.md"
  - "skills/references/design-system-token-contract.md"
  - "tools/design_system_drift_check.py"
depends_on:
  - artifact: "shipglows_data/workflow/specs/audit-design-system-authority-all-projects.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Project discovery under /home/claude using .git and shipglows_data markers."
  - "Authority detection checked shipglows_data/technical/design-system-authority.md and nested app authority markers."
  - "Warn-only drift scans ran with /home/claude/shipglows/tools/design_system_drift_check.py."
next_step: "/103-sg-verify audit-design-system-authority-all-projects"
---

# Design-System Authority Audit - All Projects

## Scope

Read-only inventory of product UI/app projects visible under `/home/claude` on 2026-06-11. The goal is to determine whether each project has a canonical design-system authority declaration and whether the current code likely contains visual drift that must be governed before future UI work.

Non-product/tooling repos such as `.fzf` and `dotfiles` were not treated as product UI targets.

## Verdict

The doctrine is not yet consistently enforced across the server.

Two projects have an authority artifact visible:

- `shipglows`: authority present and shipped in the current repo; still has existing drift candidates in the public site.
- `temu`: authority file exists locally, but it is untracked in git and the repo has active dirty UI work; treat as not fully shipped/compliant until that project is verified and shipped.

Six UI/app projects are missing a shipped design-system authority:

- `contentglowz`
- `gocharbon`
- `replayglowz`
- `shipglows_app`
- `socialglowz`
- `winflowz`

## Matrix

| Project | UI/App evidence | Authority status | Token/theme candidates | Drift scan | Dirty state | Priority | Recommended route |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `contentglowz` | Astro site, Flutter app, Remotion worker | missing | `contentglowz_app/lib/presentation/theme/app_theme_tokens.dart`, `app_theme.dart`, `contentglowz_theme.json`, `tools/check_design_tokens.mjs`, existing spec `centraliser-design-tokens-contentflow-app-site.md` | 286 files, 2010 findings | dirty app/auth/runtime files | P1 | `300-sg-docs` create authority, then `503-sg-audit-design-tokens`; avoid edits until dirty scope is owned |
| `winflowz` | Astro site, Flutter app, Tailwind config | missing | `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart`, `app_theme.dart`, specs for settings/design system and keyboard themes | 591 files, 1506 findings | clean at scan time | P1 | `300-sg-docs` authority with site/app scoped entries, then `503`/`504` |
| `shipglows_app` | Astro site, Flutter app | missing | `app/lib/presentation/theme/app_theme.dart`, `app_theme_preference.dart`, theme tests | 163 files, 1190 findings | dirty app diagnostics/build files | P1 | `300-sg-docs` authority, confirm monorepo/root governance, then token audit |
| `socialglowz` | Vite app, Astro site, Tailwind config | missing | `src/stores/theme.ts`, `themeAuto.ts`, `useTheme.ts`, `ThemeSwitch.vue` | 197 files, 1474 findings | dirty setup/native/webview files plus untracked cache/diagnostics | P1 | `300-sg-docs` authority, then classify brand/social-network color exceptions |
| `replayglowz` | Astro site, Flutter app | missing | `replayglowz_app/lib/app/theme.dart`, theme tests | 184 files, 621 findings | dirty workflow artifacts | P2 | `300-sg-docs` authority, then migrate site/app scope |
| `gocharbon` | Astro site | missing | mostly theme-toggle/content-topic files; no obvious central token authority | 103 files, 1064 findings | clean at scan time | P2 | `500-sg-design-from-scratch` or `300-sg-docs` after confirming actual token source |
| `temu` | Vite app | present locally, untracked | `shipglows_data/technical/design-system-authority.md`, canonical page alignment spec | 67 files, 427 findings | dirty UI and workflow files; authority untracked | P2 | finish/verify/ship existing authority and active redesign scope before calling compliant |
| `shipglows` | Astro site, TUI package | present and shipped | `shipglows_data/technical/design-system-authority.md`, token contract/tooling | 49 files, 183 findings | dirty unrelated spec plus this chantier | P3/control | use as doctrine control; later clean site drift separately |

## Findings

### P1 - Missing authority despite existing tokens

`contentglowz`, `winflowz`, `shipglows_app`, and `socialglowz` already have theme/token-like files or theme infrastructure, but no shipped `shipglows_data/technical/design-system-authority.md`. This is the highest-risk pattern because future agents may see local tokens but still choose the wrong canonical source or add local one-off values.

### P1 - Dirty project states block safe remediation

`contentglowz`, `shipglows_app`, `socialglowz`, and `temu` currently have dirty worktrees. This audit did not inspect ownership of those changes deeply enough to edit safely. Any remediation in those repos must start by reading current dirty state and either attaching to the owning chantier or explicitly excluding unrelated changes.

### P2 - Drift scans show large migration debt

Every scanned UI project produced drift candidates. These scans are intentionally conservative and include expected exceptions such as SVG colors, platform dimensions, email HTML, or brand/social-network colors. They are still useful as a migration inventory and should be reviewed after authority files define allowed exceptions.

### P2 - Monorepo/nested governance needs explicit handling

`shipglows_app`, `contentglowz`, `replayglowz`, and `winflowz` mix site/app surfaces. Their authority files should live at the repo governance root with scoped entries for site/app unless a standalone subproject exception is documented.

### P2 - `temu` is not fully compliant until shipped

`temu` has a visible authority file, but it is untracked and surrounded by active UI redesign changes. Treat `temu` as an in-progress remediation, not a stable control, until that repo is verified and shipped.

## Recommended Order

1. `contentglowz`: highest risk because it already has app/site tokens plus dirty auth/runtime work.
2. `winflowz`: broad app/site token surface and many design-system-related specs already exist.
3. `shipglows_app`: close to ContentGlowz architecture, likely easy to standardize after authority.
4. `socialglowz`: needs authority plus explicit brand/social-network color exception policy.
5. `replayglowz`: clear site/app split, smaller drift count.
6. `gocharbon`: likely needs from-scratch authority or token creation because central token source is not obvious.
7. `temu`: verify/ship current authority and redesign work, then audit components.
8. `shipglows`: control project; clean public site drift later.

## Project Routes

- `contentglowz`: `/300-sg-docs technical design-system-authority contentglowz`, then `/503-sg-audit-design-tokens contentglowz`.
- `winflowz`: `/300-sg-docs technical design-system-authority winflowz`, then `/503-sg-audit-design-tokens winflowz`.
- `shipglows_app`: `/300-sg-docs technical design-system-authority shipglows_app`, then `/503-sg-audit-design-tokens shipglows_app`.
- `socialglowz`: `/300-sg-docs technical design-system-authority socialglowz`, then `/503-sg-audit-design-tokens socialglowz`.
- `replayglowz`: `/300-sg-docs technical design-system-authority replayglowz`, then `/503-sg-audit-design-tokens replayglowz`.
- `gocharbon`: `/500-sg-design-from-scratch gocharbon tokens-only` if no central token source is confirmed; otherwise `/300-sg-docs technical design-system-authority gocharbon`.
- `temu`: `/103-sg-verify temu-canonical-page-design-system-alignment`, then `/005-sg-ship` inside `temu` if scoped and safe.

## Evidence Commands

Discovery:

```bash
find /home/claude -maxdepth 3 -name .git -type d -print
find /home/claude -maxdepth 4 -type d -name shipglows_data -print
```

Authority/token scan:

```bash
find <project> -maxdepth 5 \( -iname '*token*' -o -iname '*theme*' -o -iname '*design*system*' \)
```

Drift scans:

```bash
python3 /home/claude/shipglows/tools/design_system_drift_check.py --format markdown --warn-only
```

Summary counts:

- `contentglowz`: 286 files, 2010 findings.
- `gocharbon`: 103 files, 1064 findings.
- `replayglowz`: 184 files, 621 findings.
- `shipglows_app`: 163 files, 1190 findings.
- `socialglowz`: 197 files, 1474 findings.
- `winflowz`: 591 files, 1506 findings.
- `temu`: 67 files, 427 findings.
- `shipglows`: 49 files, 183 findings.

## Proof Gaps

- The drift checker is a broad heuristic. Counts are migration signals, not defect counts.
- This report did not inspect every candidate token file fully.
- This report did not create or edit product project authority files.
- This report did not run browser/mobile screenshots, because no visual implementation is being claimed.
- Dirty project states were recorded but not resolved.

## Next Step

Run `103-sg-verify` on `shipglows_data/workflow/specs/audit-design-system-authority-all-projects.md`, then choose the first remediation project. The strongest first target is `contentglowz`, but `winflowz` is cleaner if the operator wants a lower-friction first remediation.
