---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: reporting-agent-handoff
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/context-quality-contract.md
  - skills/references/conversation-continuity-contract.md
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from reporting-contract.md in wave 13."
  - "Operator approval 2026-08-21: a fresh-conversation handoff is stabilized, truthful about runtime capability, and self-contained."
next_review: "2026-11-12"
next_step: none
---

# Reporting Agent Handoff

Load only for explicit `report=agent`, `handoff`, `verbose`, or `full-report`.

Include the information the receiving agent needs to continue safely:

- the `Context Capsule` from `context-quality-contract.md`, or an exact governed pointer plus qualified deltas; preserve evidence states and source pointers without reinterpretation;

- resolved work item and scope;
- files changed and ownership boundaries;
- commands run and validation matrix;
- evidence references and proof limits;
- detailed phase/gate state;
- documentation/editorial impact;
- unresolved risks with concrete owner/action;
- full chantier trace metadata when relevant.

For delegated executable work retain `topology`, `agents_dispatched`, `model_status`, applicable `read_only_batch_matrix` or `write_execution_batches`, and `integration_result`. Count only agents directly dispatched successfully by the signing orchestrator; nested agents belong to their parent's receipt.

Agent mode may expose internal owners and commands, but must still be concise enough to operate and must never dump secrets, cookies, tokens, private logs, raw provider payloads, or unnecessary bulk output. A downstream skill emits this detail only when the caller explicitly requested agent mode.

When the receiving agent will run in a new operator-started conversation, apply the conversation-continuity contract already selected by the reporting owner. Apply its stabilization gate and emit its copyable restart prompt; never imply that Codex created, closed, or restarted the conversation itself.
