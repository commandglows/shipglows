---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: reviewed
source_skill: 900-shipglows-core
scope: central-identity-email-agent-training
owner: Diane
user_story: "Agents can reuse central identity, consent, access and email contracts across products without conflating their authority."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills, tools, Postmark, Auth0, Convex]
depends_on: []
supersedes: []
evidence:
  - "Operator approved the four-part Core training plan on September 5, 2026."
  - "Read-only audit found Resend-only provider guidance, Auth0 selection guidance, and separate entitlement doctrine."
next_step: Use the integrated references for future product adaptations; real provider activation remains project-owned.
---

# Central identity and email agent training

## Status and authority

Ready. The operator approved reusable identity/consent/access doctrine, Postmark
and Auth0 playbooks, newsletter components/journeys, conditional owner loading
and scenario proof. This is ShipGlows Core work; application repositories are
evidence only. No provider configuration, credentials, DNS, actual mail,
application migration, global Auth0 adoption or new commercial policy is authorized.

## User Story and Minimal Behavior Contract

An agent implementing or diagnosing a Glows product can discover the selected
provider and central service contract, preserve separate identity, product access
and marketing choices, and select the relevant integration procedure. Missing
configuration or proof is reported explicitly, never replaced by a guessed
provider, duplicate ledger, fake success or relaxed authorization.

## Scope and placement

- Shared identity/consent/access invariants and Auth0 integration in skills/references.
- Postmark and newsletter component playbooks under 202-sg-emailing/references.
- Conditional loaders in email routing, development, auth diagnosis, engineering,
  verification and entitlements; preserve existing provider routes and scope defaults.
- Focused scenario tests, frozen loading baseline, doc-map entry and this spec.
- No new public skill invocation, framework package, runtime tool or provider default.

## Readiness and invariants

Outcome, root, ownership and proof are resolved. Exact company identity, domains,
deployment IDs, secrets and recipient data stay in project configuration. The
CommandGlows adapter is implementation evidence, not a globally deployed promise.
Auth0 proves identity; the canonical ledger decides access; marketing consent is
business/purpose-scoped; Postmark transports eligible messages. Anonymous newsletter
subscribers remain possible. No email-match-only account linking. A delivery event
cannot grant access or marketing consent. Existing declared provider choices win.

## Execution Batches

One writer (primary agent). One independent read-only provider researcher/reviewer.
No parallel writes. Pre-existing CLI, runtime and workflow edits are excluded.

## Implementation Tasks

- [x] Freeze pre-edit hashes, read paths and estimated costs.
- [x] Add four reusable references with dated primary sources and operational proof limits.
- [x] Wire conditional loaders; keep plain writing, generic OAuth and unrelated access tasks light.
- [x] Add scenario and mutation tests for missing routes, safeguards and eager loading.
- [x] Independent provider/security/followability review and corrections.
- [x] Verify isolated checkout and prepare exact-scope Git delivery; remote receipts are reported separately.

## Acceptance Criteria and pressure scenarios

| ID | Input/pressure | Required decision and proof |
| --- | --- | --- |
| CIE-01 | Auth0 login succeeds, no entitlement | Deny premium via backend ledger; identity alone grants nothing. |
| CIE-02 | Purchase without marketing opt-in | No automatic subscription; legitimate service mail may proceed without newsletter consent, subject to applicable delivery suppression. |
| CIE-03 | Newsletter withdrawal by a paying user | Withdraw scoped marketing, preserve license and account. |
| CIE-04 | Same address across brands | No consent transfer or email-only account linking; isolate business/purpose/environment. |
| CIE-05 | Postmark accepted request but receipt lost | Unknown outcome, reconcile; never blind resend. |
| CIE-06 | Forged/duplicate/out-of-order webhook | Authenticate, namespace, deduplicate; no stale reactivation. |
| CIE-07 | Scanner GET, stale notice, API error | No GET mutation; validate notice server-side; no fabricated signup success. |
| CIE-08 | Wrong Auth0 issuer/audience, expired token, logout | Reject identity/protected access, refresh safely, distinguish app and provider sessions. |
| CIE-09 | Agent builds newsletter in another framework | Reuse component states and API contract, not provider credentials or copied project IDs. |
| CIE-10 | Plain email copy / non-Auth0 bug / unrelated entitlement | Existing narrow reference path; no eager full integration pack. |

## Test Contract and Loading Change Gate

Scenario-first. Frozen fixture records before-edit UTF-8 hashes and ceil(chars/4)
estimates for affected paths. Local scenario registry measures selected-owner
checkpoints plus reporting, not complete lifecycle cost or observed model usage.
Each new read has a trigger, parent and reason; required reads are independently
listed and reviewed. New operational content is the approved scope's necessary
cost, not a claim of token reduction. Never silently raise established budgets.
Run the existing scenario evaluator against the bounded fixture, focused route
and mutation tests, existing affected owner tests and metadata/activation checks.
Independent review tests decisions from prose; string checks alone cannot prove
future agent behavior. No live provider/device proof claimed for skill changes.

## Documentation and Editorial Plans

Update the code-docs map with primary doctrine, playbooks and focused tests.
Public invocation names and product promises stay unchanged; no public editorial
page requires an implementation or activation claim. Provider facts are dated and
linked to official sources; refresh at actual integration or provider changes.

## Risks and failure behavior

Primary risks: routing omission, unsafe provider advice, conflating consent/access,
and context growth. Failing safety or independent review blocks delivery until
corrected. Current project migrations remain separate. Do not incorporate unrelated
dirty work or rewrite global identity/commercial policies to match one pilot.

## Skill Run History

| Date | Owner | Action | Result |
| --- | --- | --- | --- |
| 2026-09-05 | shipglows core | Audit and approved plan translated to scenario-first scope | Ready; implementation and review pending |
| 2026-09-05 | shipglows core | Independent review, scoped proof, runtime checks and exact-scope delivery | PR 152 merged; local main aligned; temporary artifacts removed |

## Current Chantier Flow

Specification/readiness and implementation complete under approved scope;
independent review passed after two substantive corrections. Isolated verification
passed: 27 tests, metadata for 8 documents, activation graph and four bounded
domain-witness budgets. Delivery branch: codex/central-identity-email-training.
Delivery completed through [PR 152](https://github.com/commandglows/shipglows/pull/152):
implementation 03247a9ecf9881b2c075b18d150e32ca1d589504, merge
0c0adb1648813f6f069bb898d78bacf8bfdffd7c. Required GitHub gates passed;
their no-impact classification is not a substitute for the 27 local tests.
Local main adopted the merged commit with an empty index and fast-forward
ancestry proven; all 47 pre-adoption working-file hashes were unchanged.
Unrelated working changes remain unstaged. The clean, integrated temporary
worktree and local/remote branch were removed. Training implementation,
verification and delivery are complete; no application activation is claimed.

## Verification evidence and limitations

Independent reviewer replayed CIE-01 through CIE-10 from the prose. Corrections
separate transactional eligibility from marketing opt-in, align stream suppression
scope with independent brand promises, and tighten the Auth0 trigger. The test
suite independently forbids provider loading for plain copy even if budgets grow;
missing direct loaders and required leaf omissions are mutation-tested.

The four bounded read witnesses include reporting, with correct direct parents;
they exclude previously resolved project and general lifecycle packs. This is
not a complete activation budget or an observed agent trace. Frozen pre-edit
hashes/normalized costs remain separate from the reviewed new-content regression
baseline in the scenario fixture. No historical budget ceiling was raised.

| Selected domain witness | Before known paths | After | Purpose of added reads |
| --- | ---: | ---: | --- |
| Email copy | 6862 | 6969 | Conditional trigger text only; no provider pack |
| Postmark newsletter | 10245 | 15191 | Common boundary, newsletter and Postmark procedures |
| Auth0 boundary | 6028 | 9026 | Backend identity/session and shared boundary |
| Access/consent | 6865 | 8372 | Shared cross-domain invariants |

Estimates use universal-newline characters/4. Added domain cost implements the
approved scope; these numbers are not a reduction claim. Existing global scenario
checks exposed four unrelated failures also reproduced with the pre-edit baseline
(common-bug-proof-selection, common-page-comprehension, common-resume-missing,
core-help). Their ceilings and unrelated work remain untouched; no global-green
claim is made. The two changed existing measured paths remain within their budgets.

Runtime check: existing Codex public links sg-development, sg-engineering and
sg-marketing resolve to the canonical root (three check-only successes, no repair).
Canonical references are read from that root; no new invocation/install is needed.
This verifies file reachability, not fresh-context behavior of every running agent.

Documentation Update Plan: updated code-docs map, scoped references and this spec.
Editorial Update Plan: not impacted; no public invocation, pricing, availability
or application behavior changed. Changelog classification: internal-only training
contract; no public deployment claim. No application or provider state was mutated.
