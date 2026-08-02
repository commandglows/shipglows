---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-06-11"
created_at: "2026-06-11 18:20:00 UTC"
updated: "2026-06-11"
updated_at: "2026-06-12 04:02:18 UTC"
status: draft
source_skill: sg-start
scope: "app-site-token-hardening-and-visual-standardization"
owner: "Diane"
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/specs/winflowz-app-site-token-hardening-and-visual-standardization.md"
  - "shipglows_data/technical/design-system-authority.md"
  - "winflowz_app/lib/core/theme/winflowz_theme_tokens.dart"
  - "winflowz_app/lib/core/theme/app_theme.dart"
  - "winflowz_site/src/assets/styles/global.css"
  - "/home/claude/shipglows/tools/design_system_drift_check.py"
depends_on:
  - artifact: "shipglows_data/workflow/specs/winflowz-app-site-token-hardening-and-visual-standardization.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence: []
next_step: "/107-sg-test WinFlowz app/site token hardening and visual standardization"
proof_profile: "automated -> build -> manual"
stack_profile: "flutter + astro"
target_scope: "winflowz-app-site-token-hardening-and-visual-standardization"
---

# Manual Test Checklist: WinFlowz App/Site Token Hardening and Visual Standardization

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WFZ-APP-TOKENS-001 | app-tokens | Migration app screens/widgets to canonical theme tokens | yes | Les fichiers app modifiés consomment les abstractions `WinFlowzThemeTokens`/`App*` et ne contiennent pas de literals visuels non autorisés. | PASS | 2026-06-12 03:58:56 UTC | flutter analyze | Exécuter `cd /home/claude/winflowz && flutter analyze` puis vérifier visuellement les changements de screens/widgets ciblés. | |
| WFZ-SITE-TOKENS-001 | site-tokens | Migration site components/pages to token variables | yes | Les fichiers site changés (layouts/components/pages) utilisent `global.css`, `--` vars ou alias `tailwind.config.mjs`, pas de #hex/arbitraires non documentés. | PASS | 2026-06-12 03:58:56 UTC | design_system_drift_check(site, changed) | Exécuter `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/winflowz/winflowz_site --changed --format markdown`. | |
| WFZ-MOBILE-001 | mobile-ux | Validation mobile app+site (360px / touch targets) | yes | Les écrans critiques restent lisibles, espacés, avec cibles tactiles exploitables. | NOT_RUN | not run | N/A | Vérifier manuellement une page site (`index`, composant clé) et 2 screens app (`settings`, `feed` ou équivalent). | |
