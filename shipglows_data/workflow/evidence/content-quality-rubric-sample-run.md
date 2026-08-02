---
artifact: verification_evidence
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-10"
created_at: "2026-06-10 11:20:00 UTC"
updated: "2026-06-10"
updated_at: "2026-06-10 11:20:00 UTC"
status: reviewed
source_skill: sg-verify
source_model: "gpt-5"
scope: "content-quality-rubric-sample-run"
owner: "Diane"
confidence: "high"
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/references/content-quality-rubric.md"
  - "skills/sg-verify/SKILL.md"
  - "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md"
depends_on:
  - artifact: "skills/references/content-quality-rubric.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md"
    artifact_version: "1.0.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Sample run validates the standard output schema, final-status handling, and rejection behavior required by the editorial score gate."
next_step: "/sg-verify grille notation editoriale projet skills contenu with sample rubric run evidence"
---

# Content Quality Rubric Sample Run Evidence

## Purpose

This artifact proves that the shared content quality rubric can produce a schema-complete editorial score and that `sg-verify` has concrete examples for rejecting non-final or incoherent score states.

The sample uses governance/documentation refs only. It does not include private article body text, secrets, cookies, tokens, or unnecessary personal data.

## Valid Final Rubric Output

```json
{
  "schema_version": "1.0",
  "run_id": "cq-20260610-shipglows-rubric-sample-001",
  "run_signature": "sha256:11d6ca3f34a0cfd6e0f02db9254bb833dfc029d1f70dfa893fc7a74cc901ad61",
  "project_id": "ShipGlows",
  "surface": "article",
  "evaluator": {
    "skill": "sg-audit-copy",
    "role": "auditor",
    "initiated_by": "operator"
  },
  "input_refs": {
    "content_ref": "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md",
    "source_refs": [
      "skills/references/content-quality-rubric.md",
      "shipglows_data/business/business.md",
      "shipglows_data/business/product.md",
      "shipglows_data/business/branding.md",
      "shipglows_data/business/gtm.md",
      "shipglows_data/editorial/content-map.md",
      "shipglows_data/editorial/claim-register.md"
    ]
  },
  "applied_rules_revision": {
    "business": "shipglows_data/business/*@1.2.0",
    "editorial": "shipglows_data/editorial/content-map.md@0.8.0",
    "claim_register": "shipglows_data/editorial/claim-register.md@1.1.0"
  },
  "scores": {
    "overall": 82,
    "clarity": 86,
    "structure": 84,
    "source_faithfulness": 88,
    "compliance": 74,
    "brand_voice": 78,
    "call_to_action": 73
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
  "blocked_reasons": [
    {
      "code": "needs proof",
      "message": "The article-level recommendation should cite one source or internal decision record before being treated as publishable.",
      "required_action": "Add a source reference or downgrade the claim wording before publication."
    }
  ],
  "evidence": [
    {
      "criterion": "schema completeness",
      "source": "skills/references/content-quality-rubric.md",
      "state": "pass"
    },
    {
      "criterion": "project rules applied",
      "source": "shipglows_data/business/* and shipglows_data/editorial/*",
      "state": "pass"
    },
    {
      "criterion": "claim support",
      "source": "shipglows_data/editorial/claim-register.md",
      "state": "warning"
    },
    {
      "criterion": "workflow final status",
      "source": "skills/references/content-quality-rubric.md",
      "state": "pass"
    }
  ],
  "recommendations": [
    "Keep the shared rubric as the only source of scoring statuses and blocked reason codes.",
    "Before publication, attach a source or internal decision record for the recommendation that depends on claim evidence.",
    "Keep the owner skill report concise: overall score, top two blockers, and next action."
  ],
  "confidence": 0.84,
  "expires_at_utc": "2026-07-10T11:20:00Z"
}
```

Verification interpretation:

- Schema: complete.
- Signature: deterministic for `project_id`, `surface`, `content_ref`, `source_refs`, and `applied_rules_revision`.
- Status: final and valid for workflow decisions.
- Ship-readiness: not cleanly verified because `needs proof` is a blocking criterion; the correct downstream result is `needs revision`, not `ready`.

## Rejection Scenarios

These scenarios are not valid verification proof. They exist to prove the gate can reject unsafe or non-final score outputs.

### duplicate_in_progress

```json
{
  "schema_version": "1.0",
  "run_id": "cq-20260610-shipglows-rubric-sample-duplicate",
  "run_signature": "sha256:11d6ca3f34a0cfd6e0f02db9254bb833dfc029d1f70dfa893fc7a74cc901ad61",
  "project_id": "ShipGlows",
  "surface": "article",
  "evaluator": {
    "skill": "sg-content",
    "role": "producer",
    "initiated_by": "workflow"
  },
  "input_refs": {
    "content_ref": "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md",
    "source_refs": [
      "skills/references/content-quality-rubric.md"
    ]
  },
  "applied_rules_revision": {
    "business": "shipglows_data/business/*@1.2.0",
    "editorial": "shipglows_data/editorial/content-map.md@0.8.0",
    "claim_register": "shipglows_data/editorial/claim-register.md@1.1.0"
  },
  "scores": {
    "overall": 0,
    "clarity": 0,
    "structure": 0,
    "source_faithfulness": 0,
    "compliance": 0,
    "brand_voice": 0,
    "call_to_action": 0
  },
  "weights": {
    "clarity": 0.2,
    "structure": 0.15,
    "source_faithfulness": 0.2,
    "compliance": 0.2,
    "brand_voice": 0.15,
    "call_to_action": 0.1
  },
  "status": "duplicate_in_progress",
  "blocked_reasons": [
    {
      "code": "duplicate_in_progress",
      "message": "An active evaluation already exists for this run signature.",
      "required_action": "Wait for cq-20260610-shipglows-rubric-sample-001 or explicitly supersede it."
    }
  ],
  "evidence": [
    {
      "criterion": "one active evaluation per signature",
      "source": "skills/references/content-quality-rubric.md",
      "state": "fail"
    }
  ],
  "recommendations": [
    "Reject as verification proof because the status is recoverable and non-final."
  ],
  "confidence": 0.7,
  "expires_at_utc": "2026-06-10T12:20:00Z"
}
```

Expected `sg-verify` result: reject with `duplicate_in_progress`.

### conflicting_score_state

```json
{
  "schema_version": "1.0",
  "run_id": "cq-20260610-shipglows-rubric-sample-conflict",
  "run_signature": "sha256:11d6ca3f34a0cfd6e0f02db9254bb833dfc029d1f70dfa893fc7a74cc901ad61",
  "project_id": "ShipGlows",
  "surface": "article",
  "evaluator": {
    "skill": "sg-audit-copywriting",
    "role": "auditor",
    "initiated_by": "operator"
  },
  "input_refs": {
    "content_ref": "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md",
    "source_refs": [
      "skills/references/content-quality-rubric.md"
    ]
  },
  "applied_rules_revision": {
    "business": "shipglows_data/business/*@1.2.0",
    "editorial": "shipglows_data/editorial/content-map.md@0.8.0",
    "claim_register": "shipglows_data/editorial/claim-register.md@1.1.0"
  },
  "scores": {
    "overall": 94,
    "clarity": 95,
    "structure": 92,
    "source_faithfulness": 96,
    "compliance": 93,
    "brand_voice": 95,
    "call_to_action": 91
  },
  "weights": {
    "clarity": 0.2,
    "structure": 0.15,
    "source_faithfulness": 0.2,
    "compliance": 0.2,
    "brand_voice": 0.15,
    "call_to_action": 0.1
  },
  "status": "conflicting_score_state",
  "blocked_reasons": [
    {
      "code": "conflicting_score_state",
      "message": "The same signature already has an incompatible final output and no explicit supersedes_run_id.",
      "required_action": "Create a superseding run with a newer rules revision or resolve the conflict manually."
    }
  ],
  "evidence": [
    {
      "criterion": "replay conflict",
      "source": "skills/references/content-quality-rubric.md",
      "state": "fail"
    }
  ],
  "recommendations": [
    "Reject as verification proof because the state is conflict-only and cannot validate ship-readiness."
  ],
  "confidence": 0.76,
  "expires_at_utc": "2026-06-10T12:20:00Z"
}
```

Expected `sg-verify` result: reject with `conflicting_score_state`.

### stale_or_mismatched_score

```json
{
  "schema_version": "1.0",
  "run_id": "cq-20260610-shipglows-rubric-sample-stale",
  "run_signature": "sha256:stale-rules-revision-example",
  "project_id": "ShipGlows",
  "surface": "article",
  "evaluator": {
    "skill": "sg-verify",
    "role": "verifier",
    "initiated_by": "workflow"
  },
  "input_refs": {
    "content_ref": "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md",
    "source_refs": [
      "skills/references/content-quality-rubric.md"
    ]
  },
  "applied_rules_revision": {
    "business": "shipglows_data/business/*@old",
    "editorial": "shipglows_data/editorial/content-map.md@old",
    "claim_register": "shipglows_data/editorial/claim-register.md@old"
  },
  "scores": {
    "overall": 88,
    "clarity": 90,
    "structure": 85,
    "source_faithfulness": 90,
    "compliance": 84,
    "brand_voice": 87,
    "call_to_action": 86
  },
  "weights": {
    "clarity": 0.2,
    "structure": 0.15,
    "source_faithfulness": 0.2,
    "compliance": 0.2,
    "brand_voice": 0.15,
    "call_to_action": 0.1
  },
  "status": "stale_or_mismatched_score",
  "blocked_reasons": [
    {
      "code": "stale_or_mismatched_score",
      "message": "The signature and applied rules revision do not match the current governance corpus.",
      "required_action": "Re-run the rubric against the current project rules."
    }
  ],
  "evidence": [
    {
      "criterion": "signature freshness",
      "source": "skills/references/content-quality-rubric.md",
      "state": "fail"
    }
  ],
  "recommendations": [
    "Reject as verification proof and require a fresh run."
  ],
  "confidence": 0.78,
  "expires_at_utc": "2026-06-10T12:20:00Z"
}
```

Expected `sg-verify` result: reject with `stale_or_mismatched_score`.

## Verification Summary

- Valid final run present: yes.
- Required schema fields present: yes.
- Project-aware rules revisions present: yes.
- Recoverable/non-final rejection examples present: yes.
- Sensitive-content logging avoided: yes.
- Clean publication readiness proven: no. The valid sample intentionally returns `needs revision` because `needs proof` remains unresolved.
