---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlowz
created: "2026-07-09"
updated: "2026-07-28"
status: active
source_skill: 009-sg-skill-build
scope: task-registry-routing
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglowz_data/workflow/TASKS.md
  - shipglowz_data/editorial/ROADMAP.md
  - skills/205-sg-veille/SKILL.md
  - skills/009-sg-marketing/SKILL.md
  - skills/406-sg-seo/SKILL.md
  - skills/309-sg-tasks/SKILL.md
  - skills/references/operational-record-format.md
depends_on:
  - artifact: "skills/references/operational-record-format.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "shipglowz_data/editorial/README.md"
    artifact_version: "1.3.0"
    required_status: reviewed
supersedes: []
evidence:
  - "User decision 2026-07-09: separate editorial/content follow-ups from technical execution tasks."
  - "Current content and audit skills still point public-content recommendations at workflow/TASKS.md."
  - "Project lifecycle contract adds cybersecurity as a domain whose implementation findings route to the execution tracker."
next_review: "2026-08-09"
next_step: "/103-sg-verify task-registry-routing"
---

# Task Registry Routing

## Purpose

Choose the correct operational tracker when a skill needs to persist a durable follow-up.

This reference does not replace chantier specs. It only decides which tracker receives a task record after the work or audit has already been analyzed.

## Canonical Trackers

Use these files:

- Execution backlog: `shipglowz_data/workflow/TASKS.md`
- Editorial roadmap: `shipglowz_data/editorial/ROADMAP.md`

Both are operational trackers. Neither one is a chantier registry. Neither one gets ShipGlowz metadata frontmatter.

## Routing Rule

Write to `shipglowz_data/workflow/TASKS.md` when the follow-up is primarily about:

- code, runtime, build, deployment, tests, auth, infrastructure, dependencies, migrations, or bug repair
- implementation of a technical system, automation, or operational script
- governed internal docs or skill-contract maintenance
- product behavior changes that require engineering work
- cybersecurity posture, access control, secrets, dependency exposure, incident readiness, or security remediation

Write to `shipglowz_data/editorial/ROADMAP.md` when the follow-up is primarily about:

- public content creation or revision
- source repurposing, public docs, FAQ, public skill pages, case studies, or audience email sequences
- content angles, messaging experiments, copy improvements, conversion messaging, or SEO-content opportunities
- editorial follow-through from veille, research, repurpose packs, copy audits, copywriting audits, or content-focused SEO findings

## Mixed Findings

If one source produces both kinds of work, split it:

- create one execution record in `shipglowz_data/workflow/TASKS.md`
- create one editorial record in `shipglowz_data/editorial/ROADMAP.md`

Use shared fields such as `source`, `surface`, `spec`, `area`, `next`, or `paired` so the relationship stays visible.

Do not collapse mixed work into one ambiguous record.

Cybersecurity findings follow the same split: implementation and remediation go to `TASKS.md`; public guidance, security education, or copy claims go to `ROADMAP.md` only when the corresponding public surface is declared.

## Surface Gate

Do not write an editorial roadmap item that implies an undeclared surface exists.

Examples:

- If the next step is a blog post but no blog/article surface is declared, report `surface missing: blog`.
- If the next step is a newsletter or social series and the project has not declared that surface, route through the content lifecycle or docs governance first.

The roadmap tracks approved or governable editorial follow-up, not imaginary surfaces.

## Ownership

- `309-sg-tasks` owns execution tracker maintenance.
- Content-owner and content-source skills own editorial-roadmap writes when their output creates public/editorial follow-up.
- `007-sg-content` remains the lifecycle router for content work; it does not need to own every roadmap mutation itself, but downstream owner skills must respect this split.

## Write Safety

Before writing either tracker:

1. load `skills/references/operational-record-format.md`
2. treat earlier snapshots as informational only
3. re-read the target file from disk immediately before editing
4. apply the smallest possible patch
5. stop and ask if the anchor stays ambiguous after one recompute

## Examples

Editorial:

```text
🟠 [ShipGlowz] task: Publish a public guide explaining how operators keep project pitches current for ShipGlowz | status: todo | area: editorial-docs | surface: blog | source: repurpose-pack
```

Execution:

```text
🟠 [ShipGlowz] task: Add tracker-routing support for editorial roadmap writes across content audit skills | status: todo | area: workflow-editorial-governance | spec: shipglowz_data/workflow/specs/workflow-vs-editorial-roadmap-split.md
```

## Maintenance Rule

Update this reference when ShipGlowz changes tracker ownership, adds a new operational tracker class, or reassigns editorial/task-writing responsibility across skills.
