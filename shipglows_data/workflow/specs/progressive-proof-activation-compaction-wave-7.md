---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 16:20:00 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 16:24:19 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: progressive-proof-activation-compaction-wave-7
owner: Diane
confidence: high
user_story: "As a ShipGlows maintainer, I want manual and browser proof skills to load detailed evidence procedures progressively without weakening human-proof truth, environment routing, production safety, or redaction."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/107-sg-test
  - skills/108-sg-browser
  - skills/103-sg-verify
depends_on:
  - artifact: shipglows_data/workflow/specs/progressive-contract-activation-compaction-wave-6.md
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "107 body measured ~2.6k tokens plus ~2.2k local workflow."
  - "108 body measured ~3.1k tokens plus ~1.9k local evidence reference."
next_step: "/005-sg-ship progressive proof activation compaction wave 7"
---

# Title

Progressive proof activation compaction — wave 7

# Status

Reviewed.

# User Story

As a ShipGlows maintainer, I want manual and browser proof skills to load detailed evidence procedures progressively without weakening human-proof truth, environment routing, production safety, or redaction.

# Minimal Behavior Contract

`107` never invents or logs a manual result before user/tool evidence and owns durable QA/bug records. `108` proves one non-auth browser-visible objective with a safe read-only default and reroutes auth, deployment discovery, durable QA, unsafe mutations, and code repair. Detailed scenario, evidence, record, and report procedures load only after their gate.

# Success Behavior

- `107` body <=1,500 tokens; scenario pack precedes record/report pack.
- `108` body <=1,700 tokens; proof pack precedes report/routing pack.
- Human-only, auth, deploy, unsafe-action, redaction, preview, and production gates remain activation-critical.
- Compatibility reference paths remain present but non-eager.

# Error Behavior

Missing evidence remains `not run`; missing target/runtime blocks browser proof; unsafe production actions require approval; missing packs block rather than fall back to memory.

# Scope In

- `skills/107-sg-test/**`
- `skills/108-sg-browser/**`
- focused tests, this spec, refresh log

# Scope Out

- auth, deploy, fix, or browser tooling implementation
- shared doctrine, graph, preflight, public routing, installed catalog

# Constraints

- At most one local pack before the first substantive action.
- No local-reference chaining.
- Preserve exact reporting and consumer markers.

# Test Contract

Scenario-first tests for no-evidence, preview unavailable, auth reroute, production mutation, redaction, checklist, retest, diagnostics, evidence mismatch, and reporting compatibility.

# Dependencies

Wave 6 reviewed; fresh-docs not needed for local instruction packaging.

# Invariants

- Human validation is never fabricated or replaced by technical evidence when required.
- Browser proof is objective-bounded and read-only by default.
- Secrets, sessions, private payloads, HAR, PII, and sensitive screenshots are not persisted.

# Links & Consequences

Consumers include `003`, `005`, `006`, `008`, `010`, `103`, and public métier wrappers.

# Documentation Coherence

Update this spec and refresh log only.

# Edge Cases

- Tool evidence exists without user reply.
- Preview-push change is only local.
- Auth wall appears during non-auth browser proof.
- Screenshot and accessibility snapshot disagree.
- Production interaction could send, buy, delete, publish, or mutate data.

# Implementation Tasks

- [x] Compact `107` with direct scenario and record/report packs.
- [x] Compact `108` with direct proof and report/routing packs.
- [x] Add owner scenario contracts and validate consumers.

# Acceptance Criteria

- [x] Token targets and first-action pack limits pass.
- [x] Critical proof/safety/routing/redaction invariants remain local and tested.
- [x] Compatibility references remain non-eager.
- [x] Metadata, fidelity, budget, sync, and diff checks pass.

# Test Strategy

Owner tests, consumer contracts, then metadata/fidelity/budget/runtime sync.

# Risks

Over-compaction could permit false pass claims, unsafe production mutation, or misroute auth/deploy/manual evidence.

# Execution Notes

Keep verdict boundaries and stop conditions local. Move formats, matrices, and durable record mechanics to direct leaf packs.

# Open Questions

None.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 16:20:00 | 100-sg-spec | create | Wave 7 proof compaction contract created. |
| 2026-08-12 16:20:00 | 101-sg-ready | review | Ready: proof truth, safety, routing, and redaction invariants are explicit. |
| 2026-08-12 16:22:00 | 102-sg-start | execute | Compacted 107 and 108 into direct progressive proof packs with compatibility indexes. |
| 2026-08-12 16:23:00 | 900-shipglows-core | refresh | Restored conditional email, runtime, diagnostics, Sentry, reporting, and safety authorities. |
| 2026-08-12 16:24:19 | 103-sg-verify | verify | Owner and consumer contracts, metadata, fidelity, budget, and Codex runtime sync passed. |
| 2026-08-12 16:24:19 | 104-sg-end | close | Wave 7 closed as reviewed with ship as the next lifecycle owner. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
