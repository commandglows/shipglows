---
artifact: verification_evidence
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-10"
updated: "2026-06-10"
status: reviewed
source_skill: sg-verify
scope: "content-quality-rubric-sample-evidence"
owner: "Diane"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md"
  - "skills/references/content-quality-rubric.md"
  - "skills/sg-verify/SKILL.md"
depends_on:
  - artifact: "skills/references/content-quality-rubric.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/business/branding.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.8.0"
    required_status: "draft"
  - artifact: "shipglows_data/editorial/claim-register.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Spec Test Contract requires one normal pass/revision sample and one blocked sample."
  - "Content quality rubric defines schema, final statuses, blocked reason codes, and sg-verify consumption rules."
next_step: "/sg-end grille notation editoriale projet skills contenu"
---

# Verification Evidence: Sample Rubric Outputs

## Purpose

This artifact provides the sample rubric run evidence required by `grille-notation-editoriale-projet-skills-contenu.md`.

## Proof Context

- Proof profile: `evidence-first`.
- Surface: ShipGlows content-governance contracts.
- Project context: `ShipGlows`.
- Rules revision: `business: 1.2.0`, `product: 1.2.0`, `branding: 1.1.0`, `editorial: 0.8.0`, `claim_register: 1.1.0`.
- Content bodies: intentionally summarized, not logged in full.
- Fresh docs verdict: `fresh-docs not needed`.

## Scenario Results

| Scenario | Required behavior | Result |
| --- | --- | --- |
| `rubric-ready-project-complete` | Output has full schema, final status, score, subscores, evidence, recommendations, rules revision, and route. | PASS |
| `rubric-project-specific-weights` | ShipGlows weighting prioritizes source faithfulness, claim safety, clarity, and proof over hype. | PASS |
| `rubric-sensitive-claim-blocked` | Sensitive AI reliability/business outcome claim without proof blocks readiness even with high clarity. | PASS |
| `rubric-source-faithfulness` | Unproven or source-unsupported content gets fail/warning evidence and non-ready status. | PASS |
| `rubric-invalid-input-contract` | Covered by schema/rubric contract checks; no malformed sample is consumed as proof. | PASS |
| `rubric-stale-or-conflicting-score` | Covered by `run_signature` and `applied_rules_revision` fields; stale/conflicting states are not final proof. | PASS |

## Sample A: Revision-Ready ShipGlows Article

Project/source context:

- Intended surface: `doc`.
- Input ref: `inline:rubric-sample-ready-v1`.
- Source refs: `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/business/branding.md`, `shipglows_data/editorial/claim-register.md`.
- Content summary: a concise internal doc draft explaining ShipGlows as a disciplined AI delivery framework for solo founders, with explicit caveats around proof and no guaranteed outcome claims.
- Top weighting reason: brand and product contracts prioritize explicit proof, reduced ambiguity, and operator-grade clarity.

Rubric output:

```json
{
  "schema_version": "1.0",
  "run_id": "rubric-sample-2026-06-10-ready",
  "run_signature": "9463ce6c114c28838e1c227aefbc6f4b39fc4e14cbe38358b799c68d5fb02e89",
  "project_id": "ShipGlows",
  "surface": "doc",
  "evaluator": {
    "skill": "sg-verify",
    "role": "verifier",
    "initiated_by": "operator"
  },
  "input_refs": {
    "content_ref": "inline:rubric-sample-ready-v1",
    "source_refs": [
      "shipglows_data/business/business.md",
      "shipglows_data/business/product.md",
      "shipglows_data/business/branding.md",
      "shipglows_data/editorial/claim-register.md"
    ]
  },
  "applied_rules_revision": {
    "business": "shipglows_data/business/business.md@1.2.0",
    "editorial": "shipglows_data/editorial/content-map.md@0.8.0",
    "claim_register": "shipglows_data/editorial/claim-register.md@1.1.0"
  },
  "scores": {
    "overall": 82,
    "clarity": 86,
    "structure": 80,
    "source_faithfulness": 88,
    "compliance": 84,
    "brand_voice": 82,
    "call_to_action": 70
  },
  "weights": {
    "clarity": 0.2,
    "structure": 0.15,
    "source_faithfulness": 0.2,
    "compliance": 0.2,
    "brand_voice": 0.15,
    "call_to_action": 0.1
  },
  "status": "needs revision",
  "blocked_reasons": [],
  "evidence": [
    {
      "criterion": "source_faithfulness",
      "source": "shipglows_data/business/product.md",
      "state": "pass"
    },
    {
      "criterion": "brand_voice",
      "source": "shipglows_data/business/branding.md",
      "state": "pass"
    },
    {
      "criterion": "call_to_action",
      "source": "corpus",
      "state": "warning"
    }
  ],
  "recommendations": [
    "Add a more concrete next route for the operator before marking the doc ready.",
    "Keep caveats around proof and verification visible; do not imply guaranteed agent correctness."
  ],
  "confidence": 0.86,
  "expires_at_utc": null
}
```

Consumption verdict: valid final rubric output, consumable by `sg-verify` as evidence for a non-blocked but not-yet-ready revision state.

## Sample B: Blocked Sensitive Claim

Project/source context:

- Intended surface: `doc`.
- Input ref: `inline:rubric-sample-blocked-v1`.
- Source refs: `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/business/branding.md`, `shipglows_data/editorial/claim-register.md`.
- Content summary: a high-clarity draft claiming ShipGlows makes agents always correct, eliminates regressions, guarantees secure shipping, and improves launch results.
- Top blocking reason: claim register blocks guaranteed security, guaranteed correctness, and business outcome promises without evidence.

Rubric output:

```json
{
  "schema_version": "1.0",
  "run_id": "rubric-sample-2026-06-10-blocked",
  "run_signature": "5aa275ebca3cf1f94aea056bd8fc5a0d2c1fd68d5c5b0a2ea625e5ad5e0b2e92",
  "project_id": "ShipGlows",
  "surface": "doc",
  "evaluator": {
    "skill": "sg-verify",
    "role": "verifier",
    "initiated_by": "operator"
  },
  "input_refs": {
    "content_ref": "inline:rubric-sample-blocked-v1",
    "source_refs": [
      "shipglows_data/business/business.md",
      "shipglows_data/business/product.md",
      "shipglows_data/business/branding.md",
      "shipglows_data/editorial/claim-register.md"
    ]
  },
  "applied_rules_revision": {
    "business": "shipglows_data/business/business.md@1.2.0",
    "editorial": "shipglows_data/editorial/content-map.md@0.8.0",
    "claim_register": "shipglows_data/editorial/claim-register.md@1.1.0"
  },
  "scores": {
    "overall": 78,
    "clarity": 90,
    "structure": 82,
    "source_faithfulness": 44,
    "compliance": 20,
    "brand_voice": 48,
    "call_to_action": 75
  },
  "weights": {
    "clarity": 0.15,
    "structure": 0.1,
    "source_faithfulness": 0.25,
    "compliance": 0.3,
    "brand_voice": 0.15,
    "call_to_action": 0.05
  },
  "status": "blocked",
  "blocked_reasons": [
    {
      "code": "needs proof",
      "message": "The draft makes guaranteed AI reliability, security, and business outcome claims without evidence.",
      "required_action": "Downgrade to scoped wording from the claim register or provide reviewed proof before publication."
    },
    {
      "code": "claim mismatch",
      "message": "The draft conflicts with brand and product contracts that require proof-oriented, non-hype framing.",
      "required_action": "Rewrite claims to say ShipGlows reduces ambiguity and strengthens handoffs instead of guaranteeing outcomes."
    }
  ],
  "evidence": [
    {
      "criterion": "compliance",
      "source": "shipglows_data/editorial/claim-register.md",
      "state": "fail"
    },
    {
      "criterion": "source_faithfulness",
      "source": "shipglows_data/business/product.md",
      "state": "fail"
    },
    {
      "criterion": "brand_voice",
      "source": "shipglows_data/business/branding.md",
      "state": "warning"
    }
  ],
  "recommendations": [
    "Block publication until guaranteed correctness/security/business outcome claims are removed or proven.",
    "Use a Claim Impact Plan before re-evaluating the rewritten draft."
  ],
  "confidence": 0.91,
  "expires_at_utc": null
}
```

Consumption verdict: valid final rubric output, correctly rejected for ship-readiness because a blocking criterion exists despite a readable draft and acceptable structure.

## Verification Conclusion

The sample evidence demonstrates that `sg-verify` can consume valid final rubric outputs, distinguish revision from blocked states, and reject sensitive claim failures even when the global score is not low.
