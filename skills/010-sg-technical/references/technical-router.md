---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 010-sg-technical
scope: technical-mode-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Ready consolidation spec defines four exact technical modes and independent adjacent owners."
next_step: "/103-sg-verify consolidate technical skills under sg-technical"
---

# Technical Router

Use this reference to choose one mode before loading any substantive playbook.

| Operator need | Exact route | Selected playbook |
| --- | --- | --- |
| Code correctness, architecture, security, trust boundaries, reliability, data integrity, or test posture | `010-sg-technical audit [target]` | `technical-audit-playbook.md` |
| Vulnerabilities, supply chain, licenses, drift, lockfiles, registries, scripts, or package config | `010-sg-technical deps [global]` | `dependency-audit-playbook.md` |
| Bundle, loading, rendering, CWV readiness, fetching, caching, database/backend efficiency | `010-sg-technical performance [target]` | `performance-audit-playbook.md` |
| Breaking framework/package major upgrade | `010-sg-technical migrate [package@version]` | `migration-playbook.md` |

Default only to an unambiguous current project. `audit` accepts file, directory, diff, PR, project, or `global`; `performance` accepts file, project, or `global`; `deps` accepts a project/workspace or `global`; `migrate` accepts one package target or runs major-candidate discovery. A patch/minor update belongs to the dependency or maintenance lane, not migration.

Do not choose a technical mode for a broad cross-domain audit (`400-sg-audit`), proportional checks (`105-sg-check`), live/hosted truth (`405-sg-prod`), SEO (`406-sg-seo`), or translation/i18n (`407-sg-translate`). Performance evidence may support SEO or production owners, but never replaces their decision or proof.

Lazy-load invariant: one invocation selects zero playbooks for `help` and exactly one playbook for a valid substantive mode. A missing playbook, ambiguous target, or cross-mode request blocks selection or asks one focused question; it never loads several procedures.

Evidence labels are mandatory: static readiness, local measurement, browser measurement, hosted/runtime evidence, production evidence, official-source migration contract, or named proof gap. Read-only modes cannot transition to mutation from findings alone.
