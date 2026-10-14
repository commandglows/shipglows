---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-14"
updated: "2026-10-14"
status: active
source_skill: 400-sg-audit
scope: audit-verdict-contract
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-blocked-and-audit.md
  - skills/400-sg-audit/references/audit-scope-and-routing.md
  - "shipglows_app runner/src/skills/auditVerdict.ts (shipglows.audit-verdict.v1)"
depends_on:
  - artifact: "skills/references/reporting-blocked-and-audit.md"
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "2026-10-14: the ShipGlows app Cockpit and Contrôle showed no audit result because audit runs ended with free-form reports only."
next_review: "2027-01-14"
next_step: none
---

# Audit Verdict Contract

## Purpose

The ShipGlows app records an audit result in its Cockpit only from a
machine-readable verdict. This contract defines that verdict so every audit
owner states its result the same way. A run without a verdict still completes;
the app simply shows the audit as not concluded.

## When To Emit

Emit exactly one verdict block, as the very last element of the final message,
when the invocation asks for a `shipglows-verdict` block or names a health
dimension scope such as `seo: 406-sg-seo audit`. The ShipGlows app runner asks
for it on every audit it launches. Otherwise the block is optional.

The block never replaces the report: write the findings-first report required
by the reporting owner, then the block. Keep the block even in `report=user`.

## Format

A fenced code block whose info string is `shipglows-verdict`, containing one
JSON object and nothing else:

```shipglows-verdict
{"schemaVersion":"shipglows.audit-verdict.v1","dimension":"seo","status":"warning","summary":"2 pages without a meta description; no blocking issue.","findingCount":2,"blockingCount":0}
```

- `schemaVersion`: always `shipglows.audit-verdict.v1`.
- `dimension`: the dimension named by the scope; never another one. Owners and
  dimensions are listed in `audit-scope-and-routing.md`.
- `status`: one of `healthy`, `warning`, `critical`, `unknown` (see below).
- `summary`: one plain line, at most 280 characters, in the user's active
  language; the outcome and its most important finding.
- `findingCount`, `blockingCount`: optional non-negative integers;
  `blockingCount` never exceeds `findingCount`.
- `skillVersion`: optional skill version string.

No other key is accepted. An invalid block is ignored by the runner.

## Status Mapping

Map the audit report result to `status`:

- clear, nothing needs action: `healthy`.
- issues, none blocking release: `warning`.
- at least one finding that blocks release, a security exposure, or a live
  production outage: `critical`.
- blocked, partial, or not enough evidence to conclude: `unknown`. Never report
  `healthy` for an audit that could not inspect its scope.

## Safety

The summary is stored and displayed. Never include secrets, tokens,
credentials, personal data, raw logs, file contents, or internal paths. A
summary that looks like a credential is rejected.
