---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-12"
created_at: "2026-06-12 20:33:21 UTC"
updated: "2026-06-12"
updated_at: "2026-06-12 20:40:49 UTC"
status: draft
source_skill: sg-start
scope: "workflow"
owner: "Diane"
proof_profile: "automated -> browser/manual"
stack_profile: "astro"
target_scope: "shipglows-home-mobile-navigation-and-hero-hardening"
confidence: medium
risk_level: medium
security_impact: "none"
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/specs/shipglows-home-mobile-navigation-and-hero-hardening.md"
  - "shipglows_data/technical/design-system-authority.md"
  - "site/src/components/NavBar.astro"
  - "site/src/components/Hero.astro"
  - "site/src/styles/global.css"
evidence: []
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-home-mobile-navigation-and-hero-hardening.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
next_step: "/103-sg-verify ShipGlows home mobile navigation and hero hardening"
---

# Manual Test Checklist: ShipGlows Home Mobile Navigation and Hero Hardening

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SF-HOME-NAV-001 | home-nav | Le menu mobile remplace le wrap desktop par un hamburger accessible | yes | Sur viewport mobile, le bouton ouvre/ferme les liens, l'état est explicite, et la nav reste praticable sur `/` et `/fr/`. | PASS | 2026-06-12 20:39:56 UTC | Playwright mobile proof on `http://127.0.0.1:4327/` then `/fr/`; menu toggle opened, links visible, and FR locale navigation reachable after z-index fix. | Vérifié après correction du panneau mobile qui passait sous le hero. | |
| SF-HOME-HERO-001 | home-hero | Le hero mobile garde une hiérarchie forte sans titre surdimensionné | yes | Le `h1` respire, les CTA restent lisibles et la première vue ne paraît pas écrasée par le texte. | PASS | 2026-06-12 20:39:56 UTC | Playwright mobile snapshot on `/fr/` plus shared EN/FR component proof. | Hiérarchie mobile validée visuellement sur 390px; pas de collision CTA observée dans les snapshots EN/FR. | |
| SF-HOME-MOBILE-001 | home-mobile | Espacements, ombres et profondeur paraissent plus professionnels sur mobile | yes | La topbar, le hero, les cartes et les sections ont une profondeur cohérente et des espacements tactiles crédibles. | PASS | 2026-06-12 20:40:49 UTC | `npm run build` PASS; browser proof PASS; drift-check command from site root returns `0 file scanned`, while monorepo-root flags the canonical token file baseline rather than a scoped regression. | Preuve mobile/builde ok. Limite connue: `design_system_drift_check.py --changed` n'isole pas correctement le cas `site/` imbriqué + fichier canonique `global.css`. | |
