---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-25"
updated: "2026-11-25"
status: active
source_skill: 900-shipglows-core
scope: marketing-assets-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: low
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/marketing-assets-playbook.md
  - skills/009-sg-marketing/SKILL.md
  - skills/007-sg-content/references/content-owner-handoffs.md
  - skills/references/creative-asset-provenance-contract.md
  - skills/references/design-system-token-contract.md
  - skills/references/public-author-and-social-identity-contract.md
  - templates/marketing_assets_index.md
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.6.2"
    required_status: active
  - artifact: skills/references/creative-asset-provenance-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/public-author-and-social-identity-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-11-25: separate marketing assets in shipglows_data/marketing/assets/ from evergreen brand foundations in shipglows_data/branding/assets/."
  - "Operator decision 2026-11-25: Git LFS tracks heavy video and raw design binaries; GitHub is excluded from the default social profile pack."
next_review: "2027-02-25"
next_step: "/103-sg-verify marketing-assets-contract"
---

# Marketing Assets Contract

## Purpose And Separation Of Concerns

Define one canonical storage nomenclature, theme-fidelity gate, locale parity rule, and standardized format catalog for marketing, social, store, and video assets across all ShipGlows projects.

Keep three asset layers strictly distinct:

1. **Evergreen brand foundations** (`shipglows_data/branding/assets/`): master logos, wordmarks, icons, local fonts, mascots/illustrations, and the brand sheet. Owned by `sg-design identity`.
2. **Marketing and campaign assets** (`shipglows_data/marketing/assets/`): social profile kits, campaign visuals, store graphics, video packs, templates, and clean product source captures. Owned by `sg-design assets` (aligned with `sg-marketing` positioning/GTM and `sg-content` copy/claims).
3. **Runtime delivery copies** (`site/public/...`, `app/assets/...`): production assets served by an app or site, derived from the canonical sources above.

Ad-hoc root `artifacts/` or `docs/pr-assets/` directories containing marketing visuals are migration debt and must be consolidated into `shipglows_data/marketing/assets/`.

## Canonical Directory Structure

```text
shipglows_data/marketing/assets/
  README.md                        # artifact: marketing_assets_index (inventory, locale parity, provenance, LFS)
  sources/                         # clean versioned product screenshots and cleared source imagery
  templates/                       # HTML/CSS templates wired to project tokens & fonts + render script
  social-kit/
    shared/                        # language-neutral assets (avatars light/dark)
    en/                            # English social banners & default OG
    fr/                            # French social banners & default OG
    profiles-copy.md               # FR & EN profile bios, taglines, handles (candidate vs verified), canonical URLs
  campaigns/<YYYY-MM-slug>/        # time-bound launch or promo packs (shared/, en/, fr/)
  stores/                          # Google Play, App Store, Chrome Web Store, Product Hunt / directories
  videos/                          # FR/EN scripts, storyboards, .srt captions, thumbnails, LFS video exports
```

Create only the subdirectories needed by the project. Never reference local machine paths outside the repository (e.g., `C:/Users/...`, `~/Downloads/...`, or chat attachment directories) inside templates or manifests.

## Git And Git LFS Policy

- **Normal Git:** Markdown manifests (`README.md`, `profiles-copy.md`, scripts, storyboards), HTML/CSS templates, render scripts, `.srt` subtitle files, `.svg` vectors, and optimized `.png`/`.webp` exports.
- **Git LFS (`.gitattributes`):** Track heavy media and raw editable binaries under `shipglows_data/marketing/assets/**`:
  - Video files: `*.mp4`, `*.mov`, `*.webm`, `*.mkv`, `*.avi`
  - Heavy raw design/video project sources: `*.psd`, `*.ai`, `*.afdesign`, `*.aep`, `*.prproj`
- Before committing LFS-tracked files, verify `git lfs` is installed and `.gitattributes` rules are active at the repository root. Never force large un-tracked video binaries into plain Git history.

## Theme Fidelity Gate (Mandatory Preflight)

Before creating or regenerating any visual asset, resolve and read:

1. **Visual authority:** `shipglows_data/branding/*` (or `shipglows_data/business/branding.md` when not yet split) and `shipglows_data/technical/design-system-authority.md`.
2. **Canonical tokens and fonts:** Load the project's generated CSS token file (`site/src/styles/generated/tokens.css` or canonical token sheet) and local font files (`@font-face` pointing to repository `.woff2`/`.ttf` assets). Never approximate brand colors or silently fall back to system fonts (`Arial`, `Segoe UI`, `Trebuchet MS`).
3. **Official brand marks:** Reuse canonical logos, marks, and mascots/illustrations from `shipglows_data/branding/assets/` or `site/public/` / `site/src/assets/`.
4. **Business & claim truth:** Read `shipglows_data/business/gtm.md`, `shipglows_data/editorial/claim-register.md`, and `skills/references/public-author-and-social-identity-contract.md`. Never invent pricing, offers, endorsements, unverified handles, or unsupported claims, and never leak internal-only policies (e.g., internal trial extensions).

## Atomic Locale Parity (FR / EN)

- **Language-neutral assets** (text-free icons/avatars) live once under `shared/` with no duplicate `-fr`/`-en` copies.
- **Text-bearing assets** are produced atomically across all declared public project locales (typically `fr` and `en`), named `<asset>-en.<ext>` and `<asset>-fr.<ext>` in `en/` and `fr/`.
- French copy is typically 15–25% longer than English: verify every French render explicitly for line wrapping, padding, contrast, and zero clipping/overflow.

## Standardized 4-Pack Format Catalog

### Pack 1 — Social Profile Kit (`social-kit/`)

Note: **GitHub is excluded** from the default social profile pack unless a project explicitly requests a repository social preview.

| Asset ID | Dimensions | Safe Zone & Layout Rule | Locale Scope |
| --- | --- | --- | --- |
| `avatar-light` / `avatar-dark` | `1000×1000` (1:1) | Brand mark centered within inner 80% circular safe zone; readable down to 32×32 px | `shared/` |
| `x-header` | `1500×500` (3:1) | Keep bottom-left 420×180 px free of key text/logo (profile avatar overlay) | `en/`, `fr/` |
| `bluesky-header` | `1500×500` (3:1) | Keep bottom-left avatar zone clear; crisp hierarchy on desktop and mobile crop | `en/`, `fr/` |
| `linkedin-cover` | `1128×191` (~5.9:1) | Company/product page banner; keep left 260 px clear for logo overlay; optional personal cover `1584×396` only when explicitly requested | `en/`, `fr/` |
| `facebook-cover` | `1640×624` | All essential text/marks inside central `1240×460` mobile+desktop safe zone | `en/`, `fr/` |
| `youtube-banner` | `2560×1440` (16:9) | Full TV canvas decorated; ALL text, logos, and key marks strictly inside centered `1546×423` universal safe zone | `en/`, `fr/` |
| `og-default` | `1200×630` | Default site/social link preview; high contrast, bold headline, brand mark, canonical domain | `en/`, `fr/` |
| `profiles-copy.md` | Markdown | Display name, candidate/verified handles, 160-char short bio, long bio, canonical URLs | `fr` + `en` |

### Pack 2 — Campaign & Social Posts (`campaigns/<YYYY-MM-slug>/`)

| Asset ID | Dimensions | Notes |
| --- | --- | --- |
| `post-square` | `1080×1080` (1:1) | LinkedIn, Instagram, Facebook, X feed |
| `post-portrait` | `1080×1350` (4:5) | High-visibility mobile feed (LinkedIn, Instagram) |
| `post-landscape` | `1200×630` / `1600×900` | X, Bluesky, LinkedIn link cards |
| `story-vertical` | `1080×1920` (9:16) | Stories, Reels, TikTok, Shorts; keep top 250 px and bottom 350 px clear of platform UI |
| `youtube-thumb` | `1280×720` (16:9) | Max 3–5 words, high contrast; keep bottom-right timestamp corner clear |
| `carousel-slide` | `1080×1350` (4:5) | Numbered slide series (`slide-01`..`slide-NN`) |

### Pack 3 — Stores & Launch Directories (`stores/`)

- **Google Play:** icon `512×512`, feature graphic `1024×500`, phone/tablet screenshots.
- **App Store:** platform-required iPhone/iPad/macOS screenshot sets.
- **Chrome Web Store:** small promo `440×280`, marquee `1400×560`, screenshots `1280×800`.
- **Product Hunt / Directories:** gallery cards `1270×760`, thumbnail `240×240`.

### Pack 4 — Videos (`videos/`)

- **Formats:** `16:9` (`1920×1080`) for demos/YouTube/landing; `9:16` (`1080×1920`) for Shorts/Reels/TikTok; optional `1:1` (`1080×1080`).
- **Required companion artifacts in Git:** `script-en.md` / `script-fr.md`, `storyboard.md`, `.srt` caption tracks, custom thumbnails (`1280×720` or cover frame), and `README.md` ledger entries pointing to the Git LFS video files.

## Visual Proof And Provenance Gate

- Render HTML/CSS templates via headless browser only after `document.fonts.ready` resolves.
- Visually inspect every generated raster export before completion: verify exact web fonts loaded, exact token palette, WCAG AA contrast, safe zones, zero text clipping, and FR/EN alignment.
- Apply `skills/references/creative-asset-provenance-contract.md` whenever adopting stock, third-party, screenshot, or AI-generated material.
