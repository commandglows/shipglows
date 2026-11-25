---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-25"
updated: "2026-11-25"
status: active
source_skill: 006-sg-design
scope: marketing-assets-production
owner: Diane
confidence: high
risk_level: medium
security_impact: low
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-lifecycle-routing.md
  - skills/references/marketing-assets-contract.md
  - skills/references/creative-asset-provenance-contract.md
  - templates/marketing_assets_index.md
depends_on:
  - artifact: skills/references/marketing-assets-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.6.2"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-11-25: add assets production mode to sg-design backed by marketing-assets-contract.md."
next_review: "2027-02-25"
next_step: none
---

# Marketing Assets Playbook

## Purpose

Produce, audit, and maintain theme-faithful, bilingual (FR/EN), reproducible marketing, social, store, and video asset packs under `shipglows_data/marketing/assets/`.

Load `$SHIPGLOWS_ROOT/skills/references/marketing-assets-contract.md` alongside this playbook.

## Command Grammar

`assets <social-kit|campaign|stores|video|audit|list> [scope]`

- Bare `assets`, missing subcommand, or unknown subcommand: list the valid subcommands (`social-kit`, `campaign <slug>`, `stores`, `video`, `audit`, `list`) and perform no file mutations.
- `list`: read-only inventory of `shipglows_data/marketing/assets/` and FR/EN parity status.
- `audit [scope]`: read-only audit checking canonical placement (flagging root `artifacts/` or ad-hoc asset folders), token/font fidelity, external machine paths, FR/EN parity, safe zones, claim compliance, and Git LFS rules.
- `social-kit`: generate or refresh Pack 1 (`shared/` avatars, `en/` + `fr/` banners for X, Bluesky, LinkedIn, Facebook, YouTube, default OG, and `profiles-copy.md`; never include GitHub unless explicitly requested).
- `campaign <slug>`: generate or refresh a time-bound campaign pack under `campaigns/<YYYY-MM-slug>/` across `en/` and `fr/`.
- `stores`: generate or refresh store/directory visual packs under `stores/`.
- `video`: author FR/EN scripts, storyboards, `.srt` captions, thumbnails, and register LFS-tracked video exports under `videos/`.

## Execution Workflow

1. **Theme & Truth Preflight (Mandatory):**
   - Resolve the project governance root (`shipglows_data/`).
   - Read brand & design-system authority (`shipglows_data/branding/*` or `business/branding.md`, `technical/design-system-authority.md`), canonical token stylesheet/variables, local font files, and official logos/mascots.
   - Read `business/gtm.md`, `editorial/claim-register.md`, and `$SHIPGLOWS_ROOT/skills/references/public-author-and-social-identity-contract.md` so copy respects exact offers, claims, and social profile rules.
   - Do not invent colors, fonts, prices, claims, or unverified handles.
2. **Canonical Scaffolding & Source Hygiene:**
   - Ensure `shipglows_data/marketing/assets/` exists with `README.md` (`artifact: marketing_assets_index`, initialized from `$SHIPGLOWS_ROOT/templates/marketing_assets_index.md`).
   - Copy or store clean screenshots/source imagery inside `shipglows_data/marketing/assets/sources/`. Never reference files outside the repository.
   - Verify `.gitattributes` Git LFS patterns cover video/heavy binary extensions before committing heavy assets.
3. **Reproducible Authoring:**
   - Author HTML/CSS templates in `shipglows_data/marketing/assets/templates/` consuming the project's real generated CSS tokens (`var(--...)`), local `@font-face` fonts, and canonical SVG/PNG brand assets, paired with a deterministic render script (e.g., Playwright headless screenshot awaiting `document.fonts.ready`).
   - Give each social/platform aspect ratio its own intentional composition and safe zones (never stretch or crop one banner across incompatible ratios).
   - Produce text-bearing exports atomically in both `en/` and `fr/` (with text-free icons/avatars once in `shared/`).
   - Apply `$SHIPGLOWS_ROOT/skills/references/creative-asset-provenance-contract.md` for any non-original or AI-generated elements.
4. **Mandatory Visual & Safe-Zone Proof:**
   - Visually inspect every generated raster export: confirm real web fonts loaded, exact brand palette and stroke language, WCAG AA text contrast, zero French-text overflow or clipping, and clear platform safe zones (X/Bluesky/LinkedIn avatar cutouts, Facebook mobile center, YouTube `1546×423` center).
   - Fix template issues and re-render affected assets before completion.
5. **Inventory & Validation:**
   - Update `shipglows_data/marketing/assets/README.md` and run `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/shipglows_metadata_lint.py" shipglows_data/marketing/assets/README.md`.

## Stop Conditions

- Missing or unresolved design-system/brand tokens or local fonts where brand fidelity cannot be verified.
- Unresolved product offer, claim boundary, or rights/provenance status (`creative-asset-provenance-contract.md`).
- Uninspected or visually broken/clipped renders, or missing FR/EN parity on text-bearing assets.
- Heavy video/raw binaries staged without active `.gitattributes` Git LFS tracking.
