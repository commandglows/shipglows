---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: ready
source_skill: 100-sg-spec
scope: core-loading-regression-prevention
user_story: "Core preserves minimal sufficient loading and protections when maintaining instructions."
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - tools/skill_activation_budget.py
depends_on: []
supersedes: []
evidence:
  - "Operator approved prevention pass: oui validation. Local only, no commit/push."
next_step: "Implement and verify the approved loading regression gate."
---

# Core Loading Regression Prevention

Ready: approved scope, write ownership and scenario-first proof resolved. Preserve
all earlier dirty pilot changes. Main owns Core and existing audit/maintenance/
refresh packs, budget documentation, registry assertions and prevention tests.
A delegated worker owns only the existing budget evaluator and its tests.
Independent review is read-only. No public invocation, resolver replacement,
application change, installation, commit or push.

Before changing a loader, trigger, shared normative reference or protective
clause, inspect affected scenario reads and freeze comparable costs/depth. This
applies even when the edited file gets smaller. Keep a short visible Core gate;
load details from the existing budget contract only on that trigger.

Proof: inject broad eager read, deeper cascade, omitted mandatory ledger read,
and removed safety clause. Budget checks and separately maintained required-read/
protection assertions must reject them. Never generate independent requirements
from the reads being tested. No automatic prose parser or universal conformance
claim. Preserve all existing budgets; independently review prose-to-ledger mapping.

ZOMBIES: absent optional requirements preserve compatibility; malformed/duplicate
requirements fail; one/multiple reads; omission despite file existence; depth and
cost boundaries; protection removal; no fake complete-task cost. Fresh-docs not
needed: repository-owned Python and instruction semantics only.

Acceptance: no unexplained regression; no budget increase or safety omission to
make a test pass. Necessary increases require explicit reviewed justification and
operator arbitration. Unmeasured changed paths need a bounded scenario, not a
whole-corpus read. Documentary dependencies never imply full-body reads.

Documentation: update existing budget and mapped runtime/code-docs references.
Editorial unchanged: no public command or promise change. Completion is local
implementation/proof, never remote delivery. Record verification below.

## Verification and delivery

84 tests passed across six focused suites: Core prevention, Core owner contract,
activation accounting, common paths, prior pilot and invocation compatibility.
Injected eager read, token-neutral deeper cascade, missing mandatory read and
removed mutation gate are rejected. Required-read witnesses remain independent
human/agent-reviewed assertions, not derived from the tested ledger or metadata.

All ten scenario budgets pass without ceiling changes. Compared with the preceding
local wave, Core help 10,791 -> 10,778; unchanged read-only Core audit 20,183 ->
20,249. The 66-token increase is explained by its visible audit change-trigger
instruction; the approved ceiling and minimum reduction still hold. Common-path
costs are unchanged. A proposed loading-change audit must also count the budget
policy it activates; these readonly audit figures do not certify that other branch.

Independent review caught the initially ineffective cascade fixture (it did not
exceed the ceiling), a duplicate unittest class import and loss of explicit sole
lifecycle ownership. All were corrected before the passing run. The reviewer also
confirmed that ordinary help/unchanged readonly audit need no new policy read;
proposed loading changes do. Added help exclusion proof and explicit before-change
wording. No universal natural-language understanding or complete corpus coverage
is claimed. Uncovered changed paths require their own bounded scenario/review.

Documentation updated: existing budget policy, runtime/lifecycle and code-docs map.
Editorial not impacted: no public invocation, product promise or public surface
change. Changelog internal-only. No new router, registry or skill file. Existing
pilot changes preserved. Local implementation and focused proof complete; no
commit, push, deployment or formal remote closure. HEAD remains
65d3fc1791370ab7a2668014ce7b2338bde11d75 on main.
