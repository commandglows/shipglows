---
artifact: reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
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
depends_on:
  - artifact: skills/references/design-inspiration-library.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Synthetic-only schemas and sample required by the ready sales-page-reference-library spec."
next_review: "2026-08-15"
next_step: "/103-sg-verify sales-page-reference-library"
---

# Design Inspiration Schemas

This directory contains the public schema contract and synthetic example for the private design-inspiration corpus. It must never contain captured third-party text, screenshots, private corpus indexes, or real reference records.

- `record.schema.yaml`: required shape of each private `record.yaml`.
- `index.schema.yaml`: required shape of the private corpus `index.yaml`.
- `sample-record.yaml`: synthetic `https://example.invalid/...` example only.

The schemas use a compact JSON-Schema-like YAML vocabulary (`type`, `required`, `properties`, `enum`, and `items`). The capture tool is authoritative for writing the current schema and validates required fields before committing a bundle.

Lifecycle status progresses from `candidate` to operator-reviewed `approved`, or to `rejected`, `blocked`, or `removed`. `capture_status` describes capture evidence independently. Artifact checksums are SHA-256 and cover only files that exist; failed records must use `null` paths and must not fabricate artifacts.

Validate with:

```bash
rg -n "capture_status|rights|checksum|candidate|approved|record.yaml|index.yaml" skills/references/design-inspiration
python3 -m unittest tools.test_capture_design_inspiration
```
