---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-22"
created_at: "2026-08-22 06:37:00 UTC"
updated: "2026-08-22"
updated_at: "2026-08-22 06:37:00 UTC"
status: implemented-pending-verify
source_skill: 900-shipglows-core
source_model: "Codex"
scope: delegated-intent-mutation-authority
owner: Diane
user_story: "En tant qu’opératrice ShipGlows, je veux exprimer un résultat une fois puis laisser l’agent réaliser les décisions locales sûres et les continuations évidentes, afin de shipper des produits de qualité sans micro-manager le workflow."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/mutation-plan-approval.md
  - skills/references/operator-partnership-contract.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/entrypoint-routing.md
  - skills/000-shipglows/SKILL.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md
  - shipglows_data/workflow/specs/two-tier-mutation-approval-fast-path.md
depends_on:
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.12.0"
    required_status: active
supersedes:
  - "shipglows_data/workflow/specs/two-tier-mutation-approval-fast-path.md#initial-imperative-never-approves"
evidence:
  - "The métier-first autonomy spec already requires outcome ownership without lifecycle micromanagement."
  - "The operator-partnership contract already requires delegated intent and absorption of obvious local decisions."
  - "The later universal mutation gate contradicts those contracts by requiring a second approval after every initial imperative except narrow special cases."
  - "Operator decision 2026-08-22: restore durable delegated authority so quality product work does not require repeated numbered confirmations."
next_step: "/103-sg-verify delegated intent mutation authority"
---

# Delegated Intent Mutation Authority

## Status

implemented-pending-verify — the shared authority and propagation surfaces are aligned statically; focused contract and metadata proof remain deferred under `#nolocal`.

## Minimal Behavior Contract

An explicit operator imperative authorizes one bounded outcome chantier of safe local file creation and editing when the project or ShipGlows system target is resolved, the requested outcome and owner scope are clear or discoverable, the work is reversible and reviewable, unrelated changes are preserved, and no protected boundary is involved. The agent absorbs file selection, implementation mechanics, sequencing, adjacent obvious cleanup, proportional proof, and continuation through named or evident lots without asking for a second approval.

The authority persists until the outcome is delivered, the operator pauses or replaces it, or execution reaches a material change in product promise, scope, risk, data, permissions, destructive effect, external state, cost, or proof posture. `#local`, `#nolocal`, and `#ci` constrain execution posture without cancelling this authority. Questions remain reserved for operator-owned truth and material decisions.

## Protected Boundaries

Fresh explicit approval remains mandatory before deletion, overwrite or discard, destructive or irreversible action, credentials or secrets, auth or permission policy, billing or payment mutation, tenant or private-data mutation, commit or history mutation, push, pull request, publication, message, release, deployment, production mutation, dependency installation or upgrade, or other external writes.

## Pressure Scenarios

- `DIMA-OUTCOME-IMPERATIVE`: “améliore l’UX” authorizes bounded local UX edits after evidence resolves the surface; no approval menu is inserted.
- `DIMA-CONTINUE`: “continue”, “lot 3 puis 4”, and equivalent continuation retain the same chantier authority while scope and risk remain unchanged.
- `DIMA-NOLOCAL`: a clear imperative plus `#nolocal` authorizes static in-scope edits while workload execution, commits, and external effects stay forbidden.
- `DIMA-CORE-CRITIQUE`: a ShipGlows Core execution critique authorizes its bounded shared-contract repair without asking the operator to select files or repeat approval.
- `DIMA-MATERIAL-CHANGE`: a newly discovered change to product promise, security, data, cost, or materially wider scope pauses for one operator decision.
- `DIMA-PROTECTED-EFFECT`: push, deploy, deletion, credentials, permissions, production, payment, publication, or messaging still requires its dedicated fresh approval.
- `DIMA-DIRTY-WORK`: unrelated dirty paths remain untouched; overlapping dirty content is preserved or the chantier stops if safe integration is impossible.

## Acceptance Criteria

- [x] Shared mutation doctrine recognizes delegated-intent authority before the fast/full approval paths.
- [x] Router, lifecycle, partnership, packaged entrypoint, and workflow guidance no longer say that every initial imperative is insufficient.
- [x] Continuations inherit authority without numbered approval loops.
- [x] Protected boundaries retain explicit approval.
- [x] Existing Auto and supplied-link exceptions remain valid without becoming the only direct-authority paths.
- [ ] Focused pressure-scenario proof covers all seven scenarios at runtime.

## Proof Contract

Proof path: scenario-first. Under `#nolocal`, static contract and diff inspection may establish `implemented — unverified`; focused contract tests and metadata validation are deferred to the first normal verification owner.

## Current Chantier Flow

`900-shipglows-core build` identified a later approval-gate regression against the existing métier-first and operator-partnership autonomy contracts, implemented delegated-intent authority in the shared doctrine, aligned router/lifecycle/packaged/workflow surfaces, and preserved all protected-effect gates. Runtime verification is deferred under `#nolocal`.
