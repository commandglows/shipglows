---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-09-04"
updated: "2026-09-04"
status: reviewed
source_skill: 900-shipglows-core
scope: webextension-api-contract
owner: Diane
confidence: high
user_story: "En tant qu'opératrice ShipGlows, je veux que les agents choisissent et prouvent les WebExtension APIs de façon portable, minimale et sûre afin que les extensions fonctionnent réellement sur les navigateurs déclarés."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/webextension-api-contract.md
  - skills/references/browser-extension-lab.md
  - skills/references/preferred-stacks.md
  - skills/sg-development/SKILL.md
  - skills/103-sg-verify/references/verification-security-ui-runtime.md
depends_on: []
supersedes: []
evidence:
  - "Operator approved creation of the WebExtension API playbook on 2026-09-04."
  - "Operator approved the adopt-now, use-when-needed, and experimental API classification on 2026-09-04."
next_step: "Merge PR #135 into dev after required CI passes."
---

# WebExtension API contract

## Outcome

Agents designing browser extensions select portable, least-privileged, restart-safe WebExtension APIs and prove the actual capability instead of treating build or extension loading as behavioral proof.

## Scope

- Add one shared API design and proof contract.
- Link it from extension creation, stack selection, isolated Lab proof, and runtime verification.
- Cover compatibility, service-worker lifecycle, messaging, storage, permissions, injection, specialized APIs, freshness, and capability-specific evidence.
- Classify API choices as adopt now, use when needed, or experimental, with fallback and proof requirements.
- Preserve existing stack and Lab ownership; do not change runtime code, dependencies, store publication, or browser profiles.

## Proof path

Scenario-first: the `WEBEXT-API-*` pressure scenarios plus a focused contract test must prevent Chromium-only selection, worker-global persistence, broad permission, untrusted messaging, unsafe injection, and generic load-as-behavior proof.

## ZOMBIES coverage

- Z: missing API support or denied permission retains a usable recovery state.
- O: one supported API has one bounded adapter and observable outcome.
- M: several browsers and contexts require an explicit compatibility matrix and separated boundaries.
- B: worker restarts, storage quotas, rule limits, and tab lifecycle are challenged.
- I: messages, page-world data, host patterns, and native/provider boundaries are validated.
- E: absent receivers, revoked access, unsupported APIs, and failed storage are explicit.
- S: secrets, private pages, remote code, broad access, and personal profiles remain excluded.

## Current chantier flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| Specification | complete | Outcome, scope, exclusions, pressure scenarios, and proof are bounded. |
| Readiness | complete | Canonical placement and consumers are resolved; unrelated dirty work is excluded. |
| Implementation | complete | Shared contract, consumer links, and adoption tiers added. |
| Verification | complete | Focused contract tests, metadata lint, dependency graph, and diff check passed for the adoption-tier extension. |
| Closure | complete | Internal skill documentation is aligned; no existing public/editorial promise changed. |
| Delivery | in progress | Commit `c202fc1` is pushed on the isolated branch and PR #135 targets `dev`; push the verified adoption-tier follow-up. |

## Skill Run History

| Date UTC | Skill | Action | Result | Next step |
| --- | --- | --- | --- | --- |
| 2026-09-04 | sg-engineering | Audited extension references and current official WebExtension guidance. | Existing stack/Lab coverage confirmed; API doctrine gap identified. | Create the shared contract. |
| 2026-09-04 | 900-shipglows-core | Added shared WebExtension API doctrine, consumer routing, and scenario-first contract coverage. | Implemented locally. | Run focused verification. |
| 2026-09-04 | 103-sg-verify | Ran focused contract, metadata, budget, skill audit, dependency graph, diff, and linked runtime-sync checks. | Verified locally; all checks passed. | Persist on the appropriate integration branch without absorbing unrelated work. |
| 2026-09-04 | 900-shipglows-core | Added the approved adopt-now, use-when-needed, and experimental classification with API examples and fallback boundaries. | Implemented locally. | Rerun focused verification and update PR #135. |
| 2026-09-04 | 103-sg-verify | Re-ran the focused contract, metadata, dependency-graph, and diff checks for the adoption tiers. | Verified locally; all checks passed. | Commit and push the follow-up to PR #135. |
