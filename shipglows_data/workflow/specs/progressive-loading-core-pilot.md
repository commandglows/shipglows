---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-04"
updated: "2026-09-05"
status: ready
source_skill: 100-sg-spec
scope: progressive-loading-core-pilot
user_story: "An agent loads the minimum sufficient instructions for Core help and audit while preserving authority and proof."
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/skill_activation_budget.py
  - skills/references/skill-invocation-registry.json
depends_on: []
supersedes: []
evidence:
  - "Operator approved the bounded local pilot after the read-only audit; no commit or push authorized."
next_step: "Operator review of the local pilot; generalization and Git delivery are not authorized."
---

# Progressive Loading Core Pilot

## User Story And Minimal Behavior

A fresh agent handling Core help or a skill audit must select only the instructions
needed for its current decision, including authority, evidence and reporting gates.
The existing registry and budget tool describe the entire declared path, rather
than calling a terminal engine profile the total activation budget. Missing files,
invalid read edges, cycles and budget violations are visible failures. Advisory
search results and metadata dependencies never become mandatory reads by inference.

## Scope And Authority

Approved: local instrumentation, Core help/audit entry and routing compaction,
shared reporting and targeted reference placement, focused tests and documentation.
No commits, pushes, installations, deployment, new router, new registry, broad
skill rewrite or changes to dependency/Auto workflows. Preserve dirty work.
Canonical baseline: 65d3fc1791370ab7a2668014ce7b2338bde11d75, clean main.

## Design And Acceptance

- Extend activation_profiles with explicitly reviewed scenario read edges, stages,
  triggers and reasons; SKILL directives remain runtime authority.
- Count full UTF-8 text using ceil(characters/4), unique paths once; report real
  supplied trace repetitions separately. Do not claim billing or live agent proof.
- Core help and natural-language skill audit must reduce the comparable complete
  declared cost by at least 40%; help and audit baselines from the audit were
  conservative lower bounds (17994 and 27963). Freeze a complete baseline before
  edits and record additions/assumptions; never silently relabel the lower bound.
- Maximum depth after engine selection: two read edges on the pilot paths.
- Dependencies retain version/status/cycle validation independently of reads.
- Dependency audit remains a non-mutated witness. Shared reporting changes must
  preserve evidence, authority, unfinished choices and closure reflection gates.
- New leaves need a distinct decision trigger; examples/history are cold.

## Ordered Tasks And Test Contract

1. Freeze baseline and define pressure scenarios before contract edits.
2. Add scenario/trace accounting and failure tests in the existing Python tool.
3. Compact owner selection and reporting, preserving canonical paths and detailed
   procedures at directly selected leaves.
4. Add registry scenarios and focused structural/behavioral contract checks.
5. Run budget, invocation/resource graph, metadata, affected consumer tests and
   runtime link checks. Independently review changed contracts against baseline.
6. Record actual proof and limits; keep all edits local for operator review.

Pressure scenarios: HELP-NO-PACK; AUDIT-NO-WRITE; BOUNDED-NO-LIFECYCLE;
MISSING-REFERENCE-STOP; MATERIAL-EXPANSION-STOP; PROOF-GAP-HONEST;
REPORT-AUDIT-CHOICE; REPORT-CLOSURE-REFLECTIONS; ADVISORY-NOT-REQUIRED.
ZOMBIES: empty/malformed scenarios; one path; multiple/repeated paths; exact/over
budget and depth boundaries; CLI/registry interface; missing/cyclic/escaping paths;
small deterministic fixtures. No browser/provider/UI proof: no such surface changes.

## Links & Consequences

Shared reporting consumers must still find all conditional requirements. Registry
schema extensions must not change legacy invocation preflight. No changes to
resolver ranking, Git authority, security rules, model policy or public identities.
Rollback is the owned local diff; never reset unrelated files.

## Implementation Excellence Gate

Classification: Python infrastructure/domain accounting and Markdown contracts.
Reuse existing estimator, registry and stdlib; explicit errors, path containment,
no network or mutation during audits. Frontend/backend: not applicable.
Fresh-docs not needed: behavior is repository-owned, no external API change.

## Documentation Coherence

Update skill-context-budget, instruction-layering and mapped skill runtime docs.
Preserve reporting start/closure procedure in direct leaves and historical evidence
outside activation. Editorial: no public promise or page change. Changelog:
internal-only; no publication or delivery claim.

## Execution Notes

Readiness: ready after target, approval, proof, invariants and write ownership review.
Parent owns contracts, registry, scenario proof and docs. Delegated instrumentation
owns only tools/skill_activation_budget.py and its existing test file.

## Current Chantier Flow

100-sg-spec -> 101-sg-ready: ready -> 102-sg-start: implemented locally ->
103-sg-verify: local mechanical proof and bounded fresh help replay passed.
Local pilot delivered for review; no commit, push or ship authority.

## Skill Run History

| Date | Skill | Result |
| --- | --- | --- |
| 2026-09-04 | 100-sg-spec | Approved pilot made autonomous and bounded. |
| 2026-09-04 | 101-sg-ready | Ready; no unresolved material direction; no commit/push. |

## Local Verification Evidence (2026-09-05)

| Declared scenario | Comparable baseline | Current | Reduction | Depth after selection |
| --- | ---: | ---: | ---: | ---: |
| core-help, including next-outcome fallback | 17994 | 10790 | 40.04% | 2 |
| core-skill-audit, unfinished improvement choice | 37064 | 20182 | 45.55% | 2 |
| engineering-deps-witness | 27480 | 22634 | 17.63% | 2 |

Baseline ledgers and hashes independently recomputed at the frozen commit.
Core help has only six estimated tokens of margin under its current absolute gate;
future growth must fail the budget or receive a separately justified revision.

- 261 tests passed across 21 affected suites: scenario accounting, reporting,
  ownership/routing, proportionality, context/toolchain, Auto/nolocal, Core,
  fidelity/excellence/approval, resource graph/resolver and legacy activation budgets.
- Invocation graph valid: 15 public owners, 53 owned experts, 86 edges.
- Profiled document graph valid: 151 artifacts, 129 dependencies, zero cycles.
- Discovery unchanged: 1545/8500 portable characters, no hard warnings.
- Changed Markdown metadata lint passed (12 files); diff whitespace check passed.
- Independent baseline-to-diff review found and prompted repairs for legacy
  nolocal loading, already-selected routing, special-context recursion, report mode
  and timestamp/choice rules. Follow-up review found no additional lost invariant.
- Dependency engine/playbook and public catalogue match the original commit.
- Installed source identity: 15/15 Codex and 15/15 Claude public links target the
  canonical source. Official Bash --check --all fails with invalid skill name on
  this Windows host; its unchanged Python list producer emits CRLF. Native identity
  verification is the equivalent local evidence, not a claim that Bash check passed.

Implementation Excellence Gate: pass for the authored Python and contract scope;
input/path errors fail visibly; no new dependency/network or mutation in audits.
Documentation: updated (budget/layering, mapped runtime documentation, code-docs map,
scenario source/baseline/spec). Editorial alignment: not impacted; public identities,
commands and outcome promises unchanged. Opportunity: not assessed. Changelog:
internal-only; no publication claim. Delivery: local working tree, no commit/push.

## Remaining Measurement Limits

Declared scenario costs are not billed tokens or actual model execution traces.
They exclude startup system/skill-discovery context, tool output and task evidence.
A supplied trace only estimates observed full-file events. Depth is the declared
first-read hierarchy, not physical navigation. The pilot does not certify every
runtime branch, all-skill activation, or the absolute 5000/6000 aspirational targets.

## Fresh-Context Help Replay

A separate fresh context followed `shipglows core help` from the current wrapper,
without reading the audit or scenario ledger. It reported the exact eight canonical
full-file reads declared by the scenario, zero repeats and no procedural pack.
The supplied trace measures 10790 unique estimated tokens, zero repeated tokens.
Record: shipglows_data/workflow/reviews/progressive-loading-core-help-trace.json.
Host environment/configuration reads, inherited instructions and tool outputs are
listed separately and excluded; no provider-billed token claim is made.

The bounded replay forbade searching/starting another task. It therefore could not
exercise the full tracker/audit fallback after help; it returned a conditional
operator continuation. The existing mandatory SUITE doctrine still creates that
scope tension. This observation limits the replay, not the measured eight-file
trace, and does not authorize changing continuation doctrine in this pilot.
The trace is agent-reported real reading, not an automated capture of tool events.

| Date | Verification | Result |
| --- | --- | --- |
| 2026-09-05 | 103-sg-verify | 261 tests, graphs, budgets, metadata, native links and independent review passed; Bash sync limitation recorded. |
| 2026-09-05 | Fresh help replay | Eight canonical full reads, no repeats; bounded-help limitation recorded. |

The approved local implementation and its proof are complete. Remaining choices
concern operator review, possible wider measurements/generalization, or explicit
Git delivery; none is silently included in this approval.
