---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-11"
created_at: "2026-06-11 16:05:00 UTC"
updated: "2026-06-11"
updated_at: "2026-06-11 16:05:00 UTC"
status: draft
source_skill: sg-start
scope: "workflow"
owner: "Diane"
proof_profile: "automated -> browser/manual"
stack_profile: "astro"
target_scope: "shipglows-site-token-hardening-and-visual-standardization"
confidence: medium
risk_level: medium
security_impact: "none"
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md"
  - "shipglows_data/technical/design-system-authority.md"
  - "shipglows_data/technical/guidelines.md"
  - "site/src/styles/global.css"
  - "site/src/pages/"
  - "site/src/components/"
evidence: []
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
next_step: "/103-sg-verify ShipGlows site token hardening and visual standardization"
---

# Manual Test Checklist: ShipGlows Site Token Hardening and Visual Standardization

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DS-SITE-TOKENS-001 | site-styles | Baseline and post-change site styles use canonical tokens from `site/src/styles/global.css` | yes | Les valeurs visuelles de production (`color`, `spacing`, `typography`, `shadow`, `radius`, `transition`) sont des aliases/variables du fichier canonical ou des exceptions explicitement répertoriées. | NOT_RUN | not run | N/A | Exécuter `python3 tools/design_system_drift_check.py --root site --changed --format markdown`. | |
| DS-SITE-RESPONSIVE-001 | site-pages | Layout principal responsive reste cohérent sur desktop/mobile après migration | yes | Les pages clés gardent structure, espacement, lisibilité et comportement de grille sans rupture visuelle majeure. | NOT_RUN | not run | N/A | Exécuter build et revue responsive ciblée sur les pages listées dans les tâches. | |
| DS-SITE-MOBILE-UX-001 | site-mobile | Validation mobile de boutons/espacements/targets sur écrans étroits | yes | Les cibles tactiles restent utilisables, sans densité excessive, avec espacements préservés et contraste lisible. | NOT_RUN | not run | N/A | Vérifier un passage manuel 360px sur pages clés (`index`, `docs`, `faq`, `pricing`). | |
