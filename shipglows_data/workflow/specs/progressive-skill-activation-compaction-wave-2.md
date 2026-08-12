---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 13:30:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 13:43:00 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5-codex
scope: progressive-skill-activation-compaction-wave-2
owner: Diane
confidence: high
user_story: "En tant que mainteneuse de ShipGlows, je veux que les moteurs ship, bug, check et scaffold chargent uniquement le playbook utile à leur décision afin de réduire le contexte tout en conservant leurs garde-fous critiques."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/003-sg-bug
  - skills/005-sg-ship
  - skills/105-sg-check
  - skills/306-sg-scaffold
  - skills/references/skill-instruction-layering.md
  - tools/
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.3.0"
    required_status: active
  - artifact: skills/references/skill-context-budget.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: shipglows_data/workflow/specs/progressive-skill-discovery-and-activation-budgets.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "2026-08-12 read-only audit: 003=4618, 005=4574, 105=3300 and 306=4071 estimated body tokens, with no local references."
  - "The four bodies mix activation-critical decisions with procedural matrices, examples, report templates, and shared doctrine already available through references."
  - "Operator continuation 2026-08-12: proceed with the next efficiency and compaction wave; full dependency graph and installed-inventory overage remain deferred."
next_step: none
---

# Title

Progressive skill activation compaction — wave 2

# Status

Reviewed.

# User Story

En tant que mainteneuse de ShipGlows, je veux que les moteurs ship, bug, check et scaffold chargent uniquement le playbook utile à leur décision afin de réduire le contexte tout en conservant leurs garde-fous critiques.

# Minimal Behavior Contract

Chaque `SKILL.md` reste un contrat d'activation autonome : mission, scope, modes, décisions, références conditionnelles, stops, validation et reporting restent visibles. Les procédures, matrices, exemples et rapports détaillés sont déplacés dans au plus trois références locales bornées. Une invocation normale ne charge pas les playbooks de modes étrangers.

# Success Behavior

- `003`, `005`, `105` et `306` conservent noms, modes, owners, handoffs et consommateurs actuels.
- Chaque corps charge au plus une référence locale avant sa première action substantielle.
- Les règles sécurité, preuve, mutation, ship, visuel, auth, design et claims restent locales lorsqu'elles doivent bloquer avant chargement.
- Les références locales mappent vers les doctrines partagées sans les recopier.
- Des tests dédiés prouvent taille, loaders conditionnels, stops et absence des longues duplications.

# Error Behavior

- Une référence absente, un loader ambigu, une perte de chaîne de sécurité ou un dépassement de la cible échoue mécaniquement.
- `nofix` ne mute jamais; un check vert ne devient pas une preuve produit.
- Un bug visuel sans validation rendue humaine ne devient jamais fixed/closed.
- Un ship avec secret, check rouge ou bug high/critical non autorisé s'arrête.
- Un scaffold sans exemples/blueprint/autorité suffisante n'invente ni authz, tenant, claim, design ou comportement privilégié.

# Scope In

- Compaction progressive de `003-sg-bug`, `005-sg-ship`, `105-sg-check`, `306-sg-scaffold`.
- Une à trois références locales conditionnelles par moteur.
- Tests contractuels dédiés et adaptation minimale des tests consommateurs.
- Refresh log, metadata lint, audits, budget et sync runtime.

# Scope Out

- Budget de l'inventaire installé complet.
- Graphe ou manifeste global de dépendances.
- Renommage, fusion, suppression ou modification du catalogue public.
- Refonte des owners `104-sg-end`, `405-sg-prod`, `106/107/108/109`.
- Compaction d'autres skills ou des grandes références partagées.

# Constraints

- Références conditionnelles d'un seul niveau; aucun chainage profond.
- Ne pas déplacer hors du corps une règle requise avant toute mutation.
- Ne pas recopier `reporting-contract`, `project-development-mode`, `preview-proof-routing`, `spec-driven-development-discipline` ou `design-system-token-contract`.
- Préserver les chaînes exactes déjà vérifiées par les tests consommateurs.
- Utiliser des lots d'écriture sans chevauchement et un intégrateur unique.

# Test Contract

Proof path: `scenario-first`.

- `SHIP-QUICK-NOT-FULL`, `SHIP-SECRET-STOP`, `SHIP-BUG-GATE`, `SHIP-PREVIEW-HANDOFF`.
- `BUG-ONE-WORK-ITEM`, `BUG-VISUAL-PROOF`, `BUG-STATE-ROUTING`, `BUG-HIGH-RISK-SHIP`.
- `CHECK-NOFIX`, `CHECK-THREE-CYCLES`, `CHECK-PREVIEW-GAP`, `CHECK-NOT-PRODUCT-PROOF`.
- `SCAFFOLD-PROJECT-FIRST`, `SCAFFOLD-NO-AUTH-INVENTION`, `SCAFFOLD-DESIGN-STOP`, `SCAFFOLD-SAFE-SHELL`.
- `ACTIVATION-SIZE`: 003 ≤2300, 005 ≤1600, 105 ≤1500, 306 ≤1400 estimated body tokens.

# Dependencies

- Shared lifecycle, delegation, reporting, proof, development-mode and design-system references already active.
- Existing consumers and tests discovered by repository search.
- No external documentation required; this is local instruction packaging.

# Invariants

- Explicit invocation and public-wrapper routing remain unchanged.
- `003` owns one bug work item; `005` owns bounded Git ship; `105` owns technical checks; `306` owns pattern-based scaffolding.
- Commit/push/check success never upgrades product, security, visual, auth or production proof.
- Security impact: none, because this changes local instruction packaging only and preserves or strengthens existing safety stops.

# Links & Consequences

- `test_reporting_contract.py`, `test_bug_proof_fidelity_contract.py` and `test_master_delegation_contract.py` constrain exact sections or phrases.
- `004-sg-deploy` depends on `105 nofix`; `001-sg-build` depends on the scaffold blueprint handoff.
- Runtime sync must expose the new local references through canonical source directories.

# Documentation Coherence

Update only the refresh log and this spec unless a public promise changes. No README, catalog or public-help change is expected.

# Edge Cases

- Multiple dirty repos, detached branch, no upstream, nothing to commit, rejected push.
- Multiple bug IDs, missing/divergent bug index, preview-only proof, auth/crash routes.
- Monorepo without target, missing package manager, unknown Vercel mode, third failed repair cycle.
- Blueprint contradicting project examples, UI without design authority, ambiguous API, public pricing claims, multi-tenant data.

# Implementation Tasks

- [x] Compact `005-sg-ship` into activation contract plus execution, full-close and report-evidence references.
- [x] Compact `003-sg-bug` into activation contract plus state, evidence and closure references.
- [x] Compact `105-sg-check` and `306-sg-scaffold` with at most two references each.
- [x] Run refresh review, focused tests, metadata lint, fidelity/budget audits and runtime sync.
- [x] Close and publish the wave only after all evidence passes.

# Execution Batches

- Batch A — `skills/005-sg-ship/**`, `tools/test_005_sg_ship_contract.py`, minimal `test_reporting_contract.py` adaptation.
- Batch B — `skills/003-sg-bug/**`, `tools/test_003_sg_bug_contract.py`; preserve shared consumer tests unchanged when possible.
- Batch C — `skills/105-sg-check/**`, `skills/306-sg-scaffold/**`, their two dedicated new tests.
- Batch D — integration docs, global validation, closure and publication; parent agent only.

# Acceptance Criteria

- [x] All four activation bodies meet their target without losing local critical gates.
- [x] Each mode loads only its relevant local playbook and no more than one before first action.
- [x] Existing consumer tests and four new owner contracts pass.
- [x] New references pass metadata lint and remain directly reachable from the owner body.
- [x] Skill fidelity, implicit discovery budget, reference checks, sync and diff checks pass.
- [x] No public routing, inventory-overage or dependency-graph behavior changes.

# Test Strategy

1. Add owner scenario contracts alongside each compaction.
2. Run owner and known consumer tests per batch.
3. Integrate and measure actual before/after body estimates.
4. Run global skill audits, metadata lint, reference checks and Codex public sync.

# Risks

- Thin routers can hide safety gates that must execute before loading a reference.
- Always-loading all new references would move rather than reduce context.
- Shared references are already large; local refs must map decisions rather than duplicate doctrine.
- Exact-string consumer tests can mask semantic loss if only phrases are preserved; owner scenarios must cover behavior.

# Execution Notes

- Batch agents may edit only their declared owners and tests.
- Preserve unrelated main-branch changes and current canonical root `$HOME/.shipglows/runtime`.
- Full dependency graph and installed-catalog remediation remain separate future work.

# Open Questions

- Whether the next wave should split the large shared references will be decided after measuring these four paths.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 13:30:00 | 100-sg-spec | create | Wave-2 contract created from three parallel read-only audits. |
| 2026-08-12 13:30:00 | 101-sg-ready | review | Ready: bounded owners, pressure scenarios, critical invariants, tests and non-overlapping write batches are explicit. |
| 2026-08-12 13:38:00 | 102-sg-start | execute | Three prepared write batches compacted four owners and added conditional references plus scenario contracts. |
| 2026-08-12 13:41:00 | 900-shipglows-core | refresh | Followability review preserved activation-local stops, direct loaders and owner boundaries; seven missing reference metadata blocks were repaired. |
| 2026-08-12 13:42:00 | 103-sg-verify | verify | 83 integrated tests, 11 metadata artifacts, 65-skill fidelity audit, implicit budget 1712/8500 and Codex sync 14/14 pass. |
| 2026-08-12 13:43:00 | 104-sg-end | close | Wave closed with no public routing, catalog or dependency-graph change. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
