---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: ready
source_skill: 100-sg-spec
scope: progressive-loading-common-paths
user_story: "An operator uses shipglows with ordinary language and the agent loads only the instructions needed for its next decision."
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/question-contract.md
  - skills/references/operator-partnership-contract.md
  - skills/references/skill-invocation-registry.json
  - shipglows_data/technical/progressive-loading-common-paths-baseline.md
depends_on: []
supersedes: []
evidence:
  - "Operator approved the common-path clarification plan with validé after the six-path read-only audit."
next_step: "Verify the approved local second wave; no commit or push."
---

# Common-Path Progressive Loading

## Approved scope and readiness

Local second wave, separate from the existing Core pilot. Reuse the router,
registry, estimator and scenario/trace machinery. Compact question and partnership
entry contracts; keep authority, source/proof limits and conditional triggers
visible. Extract only greenfield question detail and cold examples/history.
Clarify advisory selection-doctrine links, explicit router preflight and the
continuation playbook’s unknown-outcome question, and align three encountered reporting
consumers (300, 011, 900) with explicit-only agent mode. No new routing system,
public invocation, application change, wholesale métier rewrite or Git delivery.

Readiness: target, approved authority, measurable checkpoints, protective invariants
and independent write ownership resolved. Preserve all pre-existing pilot changes
on main at 65d3fc1791370ab7a2668014ce7b2338bde11d75. The baseline for this wave is
the dirty post-pilot tree, frozen with per-file hashes before these edits, not HEAD.

## Execution batches and proof

- Main: question core/leaves, bounded router wording, spec, mapped docs,
  affected consumer adaptation and integration checks.
- Scenario agent: registry additions, seven-checkpoint test suite and baseline doc.
- Partnership agent: partnership core and cold scenario leaf only.
- Reporting agent: the three named owner clauses and focused reporting test.
- Independent reviewer/replayer: read-only, no application actions or external writes.

Pressure cases: exact documentation alignment; exact local non-UI verification;
reproducible bug with unknown cause; material feature with no approved plan;
page comprehension before redesign; unique ready continuation; missing continuation
target. Negative cases: accidental cold read, missing required reference, material
scope expansion, unapproved mutation, false closure and implicit agent reporting.

Use scenario-first proof. ZOMBIES: zero target, one ready target, multiple plausible
targets; exact/over budget boundaries; explicit invocation interface; missing
references; no fabricated project execution. Reuse existing accounting failure
tests instead of a second simulator. Fresh-docs not needed: repository-owned
instruction semantics, no external API or dependency change.

## Acceptance

- Missing-target clarification checkpoint: at least 25% below 25,562 estimated
  tokens, same protective decisions and reporting obligations.
- Direct docs and verification routing checkpoints: no increase above 4,436.
- Existing Core help/audit gates continue to pass without raised ceilings.
- No new cascade: depth cannot exceed its revalidated baseline. Bug proof already
  requires depth three (evidence -> development mode -> delivery policy, and
  evidence -> proof discipline -> ZOMBIES); other new paths stay at most two.
  The former universal two-edge statement was an incomplete measurement, corrected
  without flattening edges or weakening loaders. Earlier reads and total unique
  costs remain included; this is not physical navigation telemetry.
- Seven fixtures cover six families plus the missing-target variant. Do not claim
  first-decision costs are complete execution/closure costs. Record assumptions,
  conditional omissions, baseline hashes and stage increments.
- Questions remain proactive for useful product nuance, exceptional for technical
  supervision, and never grant mutation authority. Keep greenfield platform/stack,
  governing-source recovery, evidence and public-claim safeguards discoverable.
- Metadata dependencies validate documents; advisory links do not imply full reads.
  Only explicit runtime triggers load specialized detail. No sibling cascades.

## Documentation and delivery

Update runtime/lifecycle documentation, budget/layering policy and code-docs map.
Editorial: no public identity, command, feature or promise change. Local proof only;
no deployment or application runtime evidence is needed or claimed. No commit,
push, branch cleanup, installation or publication in this approval.

## Current flow

Approved plan -> ready bounded execution -> local contract changes -> verification.
Record actual checks and independent review below; do not infer completion from
registry structural validity or wording-only assertions.

## Local verification results

The initial common-path bug and feature ledgers omitted explicit loaders. Source
review corrected both sides of the comparison before acceptance: bug 20,920 ->
23,641 baseline (delivery policy and ZOMBIES), feature 37,202 -> 40,827 baseline
(UI design-system contract). Their original incomplete totals remain in the
registry and evidence document. The principal clarification baseline is unchanged.

| Scenario | Revalidated baseline | Current estimate | Reduction | Depth |
| --- | ---: | ---: | ---: | ---: |
| common-bug-proof-selection | 23641 | 23630 | 0.05% | 3 |
| common-docs-direct | 4436 | 4425 | 0.25% | 1 |
| common-feature-approval | 40827 | 34374 | 15.81% | 1 |
| common-page-comprehension | 19520 | 19509 | 0.06% | 1 |
| common-resume-missing | 25562 | 19115 | 25.22% | 1 |
| common-resume-ready | 12523 | 12518 | 0.04% | 1 |
| common-verify-direct | 4436 | 4425 | 0.25% | 1 |
| core-help | 17994 | 10791 | 40.03% | 2 |
| core-skill-audit | 37064 | 20183 | 45.55% | 2 |
| engineering-deps-witness | 27480 | 22634 | 17.63% | 2 |

The two first-read contracts keep authority, useful product questions, technical
restraint, governing-source recovery and proof limits. Greenfield detail and cold
question scenarios were compared verbatim with the original. Partnership examples
and history are cold; unique initiative and safety rules remain in its core.

Independent review and fresh-context route replay:
`shipglows_data/workflow/reviews/progressive-loading-common-paths-replay.md`.
That receipt retains the initial missed preflight and shortened continuation path,
then the follow-up corrections. This is decision evidence, not universal agent
compliance, six isolated sessions or completed application executions.

Mechanical evidence: all ten scenario budgets pass; profiled dependency graph
151 artifacts / 129 dependencies / zero cycles; separate changed-reference closure
valid with six dependencies / zero cycles; invocation graph 15 public owners /
53 experts / 86 edges. Metadata lint passed on eleven changed governed artifacts.
Discovery 1,545 / 8,500 portable characters, zero hard violations/warnings.
Installed public source identities verified natively: 15/15 .agents and 15/15
.claude links point to the canonical checkout. No installation was needed. The
prior Bash sync limitation was not represented as a new successful Bash check.

Two unrelated pre-existing assertions in `test_daily_construction_contract`
remain failing: literal wording in 005-sg-ship and 104-sg-end. Both files match
HEAD and lacked those exact markers before this wave. They were not edited or
excluded silently from a claimed full-repository pass; only affected suites are
certified here.

Documentation Update Plan: updated mapped runtime/lifecycle, budget/layering,
code-docs map, baseline and replay evidence. Editorial Update Plan: not impacted;
no public command, identity, surface, availability or product promise changed.
Opportunity: not assessed. Changelog: internal-only contract-loading improvement.
Delivery is local-only; no commit, push, installation, deployment or clean remote
closure claimed. All prior pilot changes remain present.

Final focused verification: 182 tests passed across 19 affected suites, zero
failures/errors. Final `git diff --check` passed. Main and HEAD remained unchanged;
all task changes are unstaged local files. Approved local implementation and
verification are complete; remote delivery is outside this scope.
