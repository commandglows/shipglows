---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-08-12"
status: active
source_skill: 010-sg-technical
scope: technical-mode-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/010-sg-technical/SKILL.md]
depends_on: []
supersedes: []
evidence:
  - "The owning contract preserves direct, independent technical modes."
next_step: "/103-sg-verify compact technical activation baseline"
---

# Technical Router

Choose one route before loading procedures:

| Need | Route | Direct playbook |
| --- | --- | --- |
| Code, architecture, security, reliability, integrity, tests | `010-sg-technical audit [target]` | protocol + one audit target branch |
| Supply chain, licenses, lockfiles, registries | `010-sg-technical deps [global]` | `dependency-audit-playbook.md` |
| Bundle, rendering, CWV, caching, data/backend efficiency | `010-sg-technical performance [target]` | `performance-audit-playbook.md` |
| Breaking major upgrade | `010-sg-technical migrate [package@version]` | `migration-playbook.md` |
| Branch, PR, or Dependabot hygiene | `010-sg-technical github [...]` | `github-hygiene-playbook.md` |
| Local-cloud state, access/entitlements, platform parity | `sync`, `access`, `parity` | named internal engine in `SKILL.md` |

Default only to an unambiguous current project. Broad audit, checks, hosted truth, SEO, and translation retain their adjacent owners. `help` loads none; a valid substantive mode loads exactly one playbook (audit protocol plus one target branch). Ambiguity or a missing leaf blocks or asks one focused question. Label evidence and never infer mutation authority from findings.
