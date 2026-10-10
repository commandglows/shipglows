---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-10-07"
status: active
source_skill: 102-sg-start
scope: design-inspiration-schemas
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/design-inspiration-library.md
  - tools/capture_design_inspiration.py
  - skills/references/design-inspiration-motion-evidence-contract.md
depends_on:
  - artifact: skills/references/design-inspiration-library.md
    artifact_version: "2.3.0"
    required_status: active
  - artifact: skills/references/design-inspiration-motion-evidence-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Synthetic-only schemas and sample required by the ready sales-page-reference-library spec."
  - "2026-08-15 optional motion evidence extends new private records without placing a WebM in this public schema directory."
next_review: "2026-11-07"
next_step: "Review motion evidence after its first approved synthetic capture."
---

# Design Inspiration Schemas

This directory contains the public schema contract and synthetic example for the private design-inspiration corpus. It must never contain captured third-party text, screenshots, private corpus indexes, or real reference records.

- `record.schema.yaml`: required shape of each private `record.yaml`.
- `index.schema.yaml`: required shape of the private corpus `index.yaml`.
- `sample-record.yaml`: synthetic `https://example.invalid/...` example only.

The sample records `motion.status: not_requested` and contains no video. New
private captures always write the bounded motion block; legacy schema-version
`1.0` records without it remain readable. A successful private motion capture
uses `motion.webm`, SHA-256, no audio, and the fixed initial/scroll/top sequence
from `design-inspiration-motion-evidence-contract.md`.

The schemas use a compact JSON-Schema-like YAML vocabulary (`type`, `required`, `properties`, `enum`, and `items`). The capture tool is authoritative for writing the current schema and validates required fields before committing a bundle.

Lifecycle status progresses from `candidate` to operator-reviewed `approved`, or to `rejected`, `blocked`, or `removed`. `capture_status` describes static capture evidence independently from optional motion status. Artifact checksums are SHA-256 and cover only files that exist; failed records must use `null` paths and must not fabricate artifacts. Real WebM files belong only in the private Git LFS corpus.

Validate with:

```bash
rg -n "capture_status|rights|checksum|candidate|approved|record.yaml|index.yaml" skills/references/design-inspiration
python3 -m unittest tools.test_capture_design_inspiration
```
