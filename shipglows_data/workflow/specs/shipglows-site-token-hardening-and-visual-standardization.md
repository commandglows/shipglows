---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "ShipGlows"
created: "2026-06-11"
created_at: "2026-06-11 16:05:00 UTC"
updated: "2026-08-13"
updated_at: "2026-08-13 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "site-design-system-hardening"
user_story: "En tant qu'opératrice ShipGlows, je veux une cohérence visuelle stricte sur le site public sans valeur visuelle arbitraire, pour une identité stable, pro et cohérente."
owner: "Diane"
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "shipglows_data/technical/design-system-authority.md"
  - "shipglows_data/technical/public-site-and-content-runtime.md"
  - "site/src/styles/global.css"
  - "site/src/components/"
  - "site/src/pages/"
  - "skills/503-sg-audit-design-tokens/SKILL.md"
  - "skills/500-sg-design-from-scratch/SKILL.md"
depends_on:
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/design-system-authority.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
evidence:
  - "Wave 20 migrates the branding dependency to the canonical reviewed authority at shipglows_data/branding/branding.md."
  - "Baseline drift scan: `python3 tools/design_system_drift_check.py --root site --format markdown --warn-only --max-findings 200`."
  - "`site/src/styles/global.css` currently centralizes the most-used tokens and visual aliases via CSS variables."
  - "There is no dedicated component token helper layer yet, so shared component conventions must be defined before removing direct style literals."
  - "No production mobile app exists in this repo; scope is strictly Astro site surfaces."
supersedes: []
next_step: "/102-sg-start ShipGlows site token hardening and visual standardization"
---

# Title

ShipGlows Site Token Hardening and Visual Standardization

## Status

Ready.

This chantier enforces visual consistency for the ShipGlows public site with no quick-fix styling shortcuts. The canonical source remains `site/src/styles/global.css`, and all production UI decisions in `site/src` must consume shared tokens and component abstractions instead of ad-hoc literals.

## User Story

En tant qu'opératrice ShipGlows, je veux une règle stricte d'application du design-system sur le site public, sans valeurs visuelles arbitraires dans les pages et composants, pour garantir une identité cohérente, un rendu stable et une qualité visuelle pro sur desktop et mobile.

## Minimal Behavior Contract

Tout changement visuel d'une page, d'un composant, d'une classe partagée ou d'un style inline du site doit provenir d'une source de tokens centralisée (`site/src/styles/global.css`), avec une migration explicite quand une valeur est absente. Toute valeur visuelle hors source n'est autorisée que comme exception documentée et temporaire. En l'absence d'exception, la livraison bloque et la correction doit suivre: source token -> usage partagé -> preuve.

## Success Behavior

- If this chantier is applied on production `site/src` files, then `design_system_drift_check.py --changed --format markdown --root site` reports no hardcoded colors, spacing, typography, shadow, or motion values outside the allowed exceptions.
- If a new visual token is needed for spacing/typography/color/motion/shadows, then the token is introduced or updated in `site/src/styles/global.css` before component consumption is changed.
- If a page or component currently uses ad-hoc values, then those values are replaced by variable references or shared component classes, with no behavior regression for layout breakpoints and mobile spacing.
- If remaining legacy exceptions are necessary (e.g., third-party embed constraints), they are listed with owner and expiry in spec execution notes and design-system authority.
- If verification runs, then `pnpm --dir shipglows-site build` and the checklist prove mobile and desktop consistency for the primary pages.

## Error Behavior

- If a required token does not exist, implementation blocks until the token is added in the canonical source.
- Si une page/site n'est pas prête pour une migration complète, elle est marquée en exception explicite avec périmètre, durée et plan de suppression, et ce chantier ne peut pas passer en done tant que la liste d'exceptions n'est pas close à échéance.
- Si le drift check signale des hardcoded values non justifiées sur des écrans de production, la validation échoue et la tâche revient en implémentation.
- Si une valeur visuelle ne peut être refactorée sans casser une dépendance externe de style, la solution documente l'exception et limite volontairement le périmètre, avec preuve visuelle associée.

## Problem

Le site ShipGlows a encore une dette visuelle active: beaucoup de valeurs de couleurs, dimensions, shadows et timings sont exprimées directement dans les fichiers UI. Cela introduit des divergences entre pages, complique les évolutions design, et rend le comportement mobile non homogène.

## Solution

Renforcer la doctrine déjà introduite pour ce dépôt: établir une source canonique explicite (`site/src/styles/global.css`) + un contrat d'interdiction des bypass visuels, puis migrer progressivement les usages de valeurs directes vers des tokens et composants partagés. En parallèle, documenter les exceptions de migration et bloquer toute continuation tant que les exceptions non justifiées subsistent.

## Scope In

- Site production runtime:
  - `site/src/pages/*.astro` (home, docs, faq, skill pages, pricing, contacts, etc.)
  - `site/src/components/*.astro` and shared component styles.
- Central style layer:
  - `site/src/styles/global.css` as canonical token source.
- Design-system governance:
  - Validation and enforcement in `shipglows_data/technical/design-system-authority.md`.
- Evidence and proof:
  - Test checklist creation and execution in `shipglows_data/workflow/test-checklists/shipglows-site-token-hardening-and-visual-standardization.md`.
- Validation commands:
  - `python3 tools/design_system_drift_check.py --root site --changed --format markdown`
  - `pnpm --dir shipglows-site build`

## Scope Out

- Aucune application mobile native/Flutter dans ce chantier (repo-level site only).
- Réécriture d'algorithmes métier, de copy marketing globale, ou de stratégie de produit.
- Refactorings globaux de thème d'astro si la stack change sans demande design explicite.
- Corrections de contenu textuel hors styling/branding/structure visuelle.

## Constraints

- Interdire les valeurs visuelles (couleurs, espacement, typographie, ombres, radii, motion) en dehors de la source canonique ou d'une exception explicitement validée.
- Ne pas créer de nouvelles constantes visuelles locales si une classe de style partagée peut la couvrir.
- `design_system_drift_check.py --changed --format markdown` devient la preuve machine minimale de non-regression visuelle.
- Touch target et espacement tactiles doivent rester cohérents avec les bonnes pratiques WCAG 2.2 AA applicables au contexte public.

## Dependencies

- `shipglows_data/technical/design-system-authority.md`
- `skills/references/design-system-token-contract.md`
- `site/src/styles/global.css`
- `site/src/components/`
- `site/src/pages/`
- `skills/503-sg-audit-design-tokens/SKILL.md`
- `tools/design_system_drift_check.py`
- `pnpm --dir shipglows-site build`

## Invariants

- Le site ShipGlows conserve une source de vérité visuelle unique pour les décisions de design.
- Les changements de style se font par token/variable puis consommation, pas par duplication locale.
- Les exceptions temporaires doivent être finies, explicitement rattachées au chantier et suivies avec un plan de suppression.
- La doctrine de langue demeure : contrat interne en anglais quand utile, texte utilisateur en français naturel.

## Links & Consequences

Upstream:
- Design doctrine via `shipglows_data/technical/design-system-authority.md` and `skills/references/design-system-token-contract.md`.

Downstream:
- `site/src/pages` and `site/src/components` inherit and apply the same canonical visual rules.
- `shipglows` spec-driven docs and public claims can remain intact unless copy/layout changes extend user-facing meaning.
- `103-sg-verify` and `005-sg-ship` use `design_system_drift_check.py` output as a hard gate for this chantier.

## Documentation Coherence

- Mettre à jour `shipglows_data/technical/design-system-authority.md` si la source canonique ou les exceptions légitimes changent.
- Mettre à jour les docs de surface seulement si des pages changent de rôle, d'intention ou de promesse visuelle.
- Conserver le découpage page/surface existant dans `shipglows_data/technical/public-site-and-content-runtime.md`.

## Edge Cases

- Composants tiers avec classes visuelles non alignables immédiatement.
- Fallback/compatiblité si un composant dépend d'une valeur visuelle fixée pour une API tierce.
- Incohérence desktop/mobile due à des valeurs de taille héritées.
- Pages à forte densité textuelle qui semblent stables visuellement mais qui ne respectent pas un token unifié.
- Différences de thème si un navigateur ne charge pas correctement les variables CSS du layout global.

## Implementation Tasks

- [ ] Tâche 1: Verrouiller la doctrine pour le site public
  - Fichiers: `shipglows_data/technical/design-system-authority.md`, `shipglows_data/technical/guidelines.md`
  - Action: confirmer que la source canonique est `site/src/styles/global.css`, définir les exceptions autorisées et valider les garde-fous de bypass visuel.
  - Validate with: revue de docs + l'existence de règles de gouvernance alignées.

- [ ] Tâche 2: Cartographier les usages visuels non-autorisés sur le site
  - Fichiers: `site/src/styles/global.css`, composants clés dans `site/src/pages` et `site/src/components`
  - Action: produire la liste des valeurs visuelles non tokenisées actuelles, classées par sévérité et surface.
  - Validate with: `python3 tools/design_system_drift_check.py --root site --format markdown --warn-only`.

- [ ] Tâche 3: Définir ou enrichir les tokens canoniques
  - Fichiers: `site/src/styles/global.css`
  - Action: déplacer les valeurs de répétition fréquente (spacing, radius, couleur de texte/fond, shadow, motion) dans des variables/aliases stables, avec noms semantiques.
  - Validate with: revue frontmatter de spec + grep ciblé sur usages directs.

- [ ] Tâche 4: Remplacer les hardcodes dans les composants partagés
  - Fichiers: `site/src/components/*.astro`
  - Action: remplacer les valeurs visuelles locales par des classes/utilisations de tokens centralisés.
  - Depends on: Tâche 3.
  - Validate with: `python3 tools/design_system_drift_check.py --root site --changed --format markdown`.

- [ ] Tâche 5: Traiter les pages les plus critiques
  - Fichiers: `site/src/pages/index.astro`, `site/src/pages/docs.astro`, `site/src/pages/faq.astro`, `site/src/pages/skill-modes.astro`, `site/src/pages/pricing.astro`
  - Action: remplacer les styles locaux non-autorisés dans les grilles/sections et harmoniser les composants visuels.
  - Depends on: Tâche 4.
  - Validate with: `pnpm --dir shipglows-site build`.

- [ ] Tâche 6: Vérifier la couverture mobile-first
  - Fichiers: toutes les zones de landing/home/footer/docs/cards mentionnées ci-dessus
  - Action: confirmer spacing, densité, cibles tactiles et lisibilité sur points de rupture mobile.
  - Validate with: revue manuelle ciblée + scenarios du checklist.

- [ ] Tâche 7: Exécuter la preuve de conformité chantier
  - Fichiers: `shipglows_data/workflow/test-checklists/shipglows-site-token-hardening-and-visual-standardization.md`
  - Action: renseigner les scénarios requis et passer en `PASS`/`BLOCKED` selon la preuve réelle.
  - Validate with: `103-sg-verify`.

## Acceptance Criteria

- [ ] AC-1: Après migration, `design_system_drift_check.py --root site --changed --format markdown` ne signale pas de hardcoded visuel non justifié dans les fichiers changés de `site/src`.
- [ ] AC-2: Les nouvelles décisions visuelles pour le site proviennent de variables dans `site/src/styles/global.css` (ou exception déclarée dans la spec/authority).
- [ ] AC-3: Les pages ciblées conservent un comportement layout stable sur `max-width` et points de rupture mobile.
- [ ] AC-4: La doctrine anti-quick-fix est documentée et appliquée via l'autorité de design-system et les tâches du chantier.
- [ ] AC-5: Le checklist contient les 3 scénarios requis avec proof pointers.
- [ ] AC-6: `shipglows_data/technical/design-system-authority.md` reste aligné avec le périmètre site de ce chantier.

## Test Contract

- surface: site public (Astro), composants et styles partagés.
- proof_profile: automated-first + visual/manual sampling.
- proof_order:
  1. `python3 tools/design_system_drift_check.py --root site --format markdown --warn-only`
  2. `python3 tools/design_system_drift_check.py --root site --changed --format markdown`
  3. `pnpm --dir shipglows-site build`
  4. Scenarios checklist.
- checklist_path: `shipglows_data/workflow/test-checklists/shipglows-site-token-hardening-and-visual-standardization.md`
- required_scenario_ids:
  - DS-SITE-TOKENS-001
  - DS-SITE-RESPONSIVE-001
  - DS-SITE-MOBILE-UX-001
- required_results:
  - no unapproved hardcoded visual values in scoped changed files
  - mobile-friendly sections remain usable at 360px
  - central token references are preferred for production visuals
- exception_with_proof: Aucun.
- exception_without_proof: Aucun.

## Test Strategy

- `python3 tools/design_system_drift_check.py --root site --format markdown --warn-only --max-findings 200`
- `python3 tools/design_system_drift_check.py --root site --changed --format markdown`
- `pnpm --dir shipglows-site build`
- Revue responsive manuelle sur les pages principales `/`, `/docs`, `/faq`, `/pricing`, `/skill-modes`.
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md shipglows_data/workflow/test-checklists/shipglows-site-token-hardening-and-visual-standardization.md`

## Risks

- `medium` — Dette visuelle importante: trop de composants et pages peuvent dépasser la capacité d'un chantier simple.
- `medium` — Faux positifs de l'analyseur; le tri peut ralentir si les exceptions ne sont pas centralisées proprement.
- `low` — Régression visuelle locale si la migration se limite aux tokens sans revue du rendu.

## Execution Notes

- Lire d'abord:
  - `shipglows_data/technical/design-system-authority.md`
  - `shipglows_data/technical/public-site-and-content-runtime.md`
  - `site/src/styles/global.css`
  - `site/src/layouts/*`
- Utiliser une séquence stricte:
  1) source token, 2) refactor composant/page, 3) validation.
- Ne pas créer d'exception ad hoc dans une PR; toute exception doit être ajoutée à l'autorité du chantier.
- Stop immédiat si la migration dégrade la lisibilité mobile ou introduit un target trop dense.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-11 16:05:00 UTC | 100-sg-spec | GPT-5 Codex | create | ready | /101-sg-ready ShipGlows site token hardening and visual standardization |
| 2026-06-11 16:05:00 UTC | 101-sg-ready | GPT-5 Codex | readiness-check | ready | /102-sg-start ShipGlows site token hardening and visual standardization |
| 2026-06-12 20:44:44 UTC | 503-sg-audit-design-tokens | GPT-5 Codex | audit | issues found | /102-sg-start ShipGlows site token hardening and visual standardization |

## Current Chantier Flow

- 100-sg-spec: done
- 101-sg-ready: done
- 102-sg-start: not launched
- 103-sg-verify: not launched
- 104-sg-end: not launched
- 005-sg-ship: not launched
