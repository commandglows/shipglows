---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 900-shipglows-core
scope: decision-quality-implementation-discipline
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/decision-quality-contract.md
  - skills/*/SKILL.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "2.0.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 15 extracts conditional implementation pressure detail from the mandatory decision core without changing its quality bar."
  - "Fast repair pressure repeatedly requires explicit root-cause, owner-boundary, mitigation, and proof discipline."
next_review: "2026-09-12"
next_step: "/103-sg-verify decision-quality implementation discipline"
---

# Decision Quality Implementation Discipline

## Activation Boundary

Load this leaf directly when implementation, repair, refactoring, migration, mitigation, dependency/tool selection, or verification faces shortcut pressure. Apply `decision-quality-contract.md` first. This leaf does not load or select other conditional leaves.

## Durable Implementation Sequence

1. Establish the accepted outcome and applicable correctness, safety, performance, durability, and proof requirements.
2. Diagnose the root cause and canonical owner boundary before writing.
3. Prefer replacement of a weak structure or repeated burden over an additive exception.
4. Implement the smallest complete professional change at that boundary.
5. Prove success behavior, error behavior, affected edge cases, and the absence of the bypass that caused the defect.
6. Update the owning contract or documentation when future execution depends on the decision.

A green generic check is insufficient when the failure involved ownership, structure, security, design coherence, migration, external behavior, or a specific pressure scenario.

## Forbidden Shortcut Patterns

Do not:

- patch a symptom while leaving the known root cause active;
- bypass a shared abstraction, owner skill, governance contract, migration, or required lifecycle gate;
- weaken tests, integrity controls, security posture, accessibility, or proof to make a command pass;
- introduce an unexplained exception that future agents cannot distinguish from the intended architecture;
- call a mitigation, partial proof, compatibility shim, or environment-specific bypass complete;
- choose a hand-rolled domain mechanism merely because a maintained official or established solution requires more work.

## Targeted Edit Discipline

Targeted edits protect the worktree and review surface; they do not lower solution quality. Change the intended row, function, module, or file when the correct owner is known, avoid stale whole-file rewrites and unrelated churn, and keep the diff connected to the accepted outcome.

Expand scope only when root-cause evidence proves that the complete fix crosses the initial boundary. If expansion changes product behavior, security, data handling, permissions, destructive behavior, material cost, or external effects, return to the applicable gate in the core contract.

## Tools And Dependencies

Prefer current, maintained, proven libraries, framework features, platform APIs, and official provider paths for security, cryptography, authentication, migrations, parsing, accessibility, observability, performance measurement, and other mature domains. Verify current external behavior through the documentation freshness gate when it can have changed.

Do not add a tool because it is fashionable or available. It must replace manual work, fragility, ambiguity, drift, or maintenance cost without weakening the decision baseline.

## Mitigation Contract

When an immediate mitigation is genuinely necessary, name it as `mitigation`, bound its scope and risk, preserve or improve safety, record the durable owner and follow-up proof, and report the result as partial or blocked where completion evidence is absent. Convenience alone never justifies a temporary path.

## Pressure Proof

Verification must fail or report partial when the result works only because it bypasses root cause, owner boundaries, durable structure, or required proof. The focused scenario must reproduce the original pressure and show why the durable path now wins.
