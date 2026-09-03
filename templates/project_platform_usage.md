---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.3.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: sg-docs
scope: "platform-usage-[provider]"
owner: "[owner]"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/technical/external-platforms/[provider].md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/[provider].md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence: []
next_review: "YYYY-MM-DD"
next_step: "/sg-docs technical audit"
---

# [Provider] Project Usage

## Purpose

Document how this project, monorepo, app, or package actually uses `[provider]`. This file must live under the canonical governance root at `shipglows_data/technical/platforms/[provider].md`; in monorepos, that means the monorepo root, not each app/package subdirectory.

This is the local usage contract, not a copy of vendor docs.

Use the global provider note for general source links and ShipGlows rules:

- `shipglows_data/technical/external-platforms/[provider].md`

## Usage Summary

- Provider role:
- Project/provider identifier:
- Applies to paths:
- Environments used:
- Validation surface:
- Owner:
- Last verified:

## Local Configuration

| Item | Value or rule | Secret? | Notes |
| --- | --- | --- | --- |
| Production branch |  | no |  |
| Preview branches/custom envs |  | no |  |
| Provider plan |  | no | Use `unknown` rather than inference |
| Plan capability reason |  | no | Name the required outcome; included credit is not a usage target |
| Build machine policy |  | no | Prefer the economical default until measured evidence justifies more |
| Build concurrency policy |  | no | Record queue policy and business justification |
| Spend posture and owner |  | no | Never store billing identifiers or payment data |
| Deployment protection |  | no | Never store bypass material |
| Firewall/WAF review state |  | no | Record policy, not sensitive traffic evidence |
| Paid add-ons |  | no | Disabled by default unless a named outcome justifies recurring cost |
| Domains/callback origins |  | no | Use public origins only when safe |
| Build command |  | no |  |
| Output/runtime expectation |  | no |  |
| Required env var keys |  | keys only | Never record values |

## Runtime And Integration Notes

- Auth/callback behavior:
- API/webhook behavior:
- Storage/cache/CDN behavior:
- Logs/observability route:
- MCP/CLI/dashboard evidence route:

## Invariants

- [Rule that must remain true for this project.]

## Failure Modes

- [Provider-specific failure] -> [Expected diagnosis or owner skill route.]

## Security Notes

- Do not store secrets, tokens, raw provider logs, cookies, private URLs, or customer data here.
- Record environment variable keys only, never values.
- Summarize sensitive provider evidence with redaction.

## Validation

```bash
[project-specific provider verification command or "manual provider proof required"]
```

## Reader Checklist

- Provider-related code/config changed -> review this usage note.
- Provider docs or releases changed -> compare against the global provider note and this usage note.
- Project validation surface changes -> update this note before treating checks as authoritative.

## Maintenance Rule

Update this doc when provider configuration, environments, domains, callbacks, validation surface, build/runtime behavior, evidence route, or security assumptions change.
