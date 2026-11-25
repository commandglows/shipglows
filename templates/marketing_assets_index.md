---
artifact: marketing_assets_index
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "<project>"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: 006-sg-design
scope: marketing-assets
owner: "Diane"
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/branding/
  - shipglows_data/technical/design-system-authority.md
  - shipglows_data/business/gtm.md
  - shipglows_data/editorial/claim-register.md
evidence:
  - "Initialized from templates/marketing_assets_index.md under skills/references/marketing-assets-contract.md."
depends_on: []
supersedes: []
next_review: "YYYY-MM-DD"
next_step: "/sg-design assets audit"
---

# Marketing Assets Index — <Project>

Canonical directory for marketing, social, store, and video assets. Evergreen brand foundations (master logos, fonts, icons, illustrations) remain in `shipglows_data/branding/assets/`.

## Theme & Truth Sources

- Brand & visual authority: `<path>`
- Token stylesheet / authority: `<path>`
- Local fonts: `<path>`
- GTM & claim limits: `shipglows_data/business/gtm.md`, `shipglows_data/editorial/claim-register.md`

## Pack 1 — Social Profile Kit (`social-kit/`)

| Asset | Dimensions | Shared / EN / FR | Status |
| --- | --- | --- | --- |
| Avatar (light & dark) | `1000×1000` | `shared/` | pending |
| X header | `1500×500` | `en/`, `fr/` | pending |
| Bluesky header | `1500×500` | `en/`, `fr/` | pending |
| LinkedIn cover | `1128×191` | `en/`, `fr/` | pending |
| Facebook cover | `1640×624` | `en/`, `fr/` | pending |
| YouTube banner | `2560×1440` (`1546×423` safe) | `en/`, `fr/` | pending |
| Open Graph default | `1200×630` | `en/`, `fr/` | pending |
| Profile copy sheet | Markdown | `social-kit/profiles-copy.md` | pending |

## Campaigns, Stores & Videos

| Category | Path | Locales | Storage (Git / Git LFS) | Notes |
| --- | --- | --- | --- | --- |
| Sources | `sources/` | shared | Git | Clean versioned screenshots |
| Templates | `templates/` | shared | Git | Reproducible render pipeline |

## Regeneration

Document the exact reproducible command from repository root to regenerate templates and exports.

## Git LFS Policy

Heavy video exports (`*.mp4`, `*.mov`, `*.webm`, `*.mkv`, `*.avi`) and raw editable sources (`*.psd`, `*.ai`, `*.afdesign`, `*.aep`, `*.prproj`) under `shipglows_data/marketing/assets/**` are tracked via `.gitattributes` Git LFS rules.
