---
artifact: operations_ledger
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-04-27"
updated: "2026-04-27"
status: active
schema_version: "1.0.0"
owner: Diane
source_of_truth: append_only
write_tool: /home/claude/shipglowz/tools/append_shipglows_event.py
scope: "operations, checks, verification, and lifecycle events"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
source_skill: "002-sg-maintain"
evidence: []
depends_on: []
supersedes: []
next_step: "/002-sg-maintain audits"
---

# ShipGlows Operations Ledger

Append-only machine-readable events for operations, checks, verification, and lifecycle transitions.

## Parser Contract

- Events are fenced YAML blocks wrapped by `<!-- shipglows:event start -->` and `<!-- shipglows:event end -->`.
- Do not edit existing event blocks in place.
- Append only through `/home/claude/shipglowz/tools/append_shipglows_event.py`.
- Empty ledger is valid.

## Events

No events yet.
