---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-01"
updated: "2026-09-01"
status: active
source_skill: 010-sg-technical
scope: dead-code-and-obsolescence-audit
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/SKILL.md
  - skills/010-sg-technical/references/technical-audit-protocol.md
  - skills/010-sg-technical/references/technical-project-audit.md
  - skills/references/code-navigation-and-function-docs.md
  - skills/references/skill-invocation-registry.json
depends_on:
  - artifact: skills/references/code-navigation-and-function-docs.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/clean-code-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator approval 2026-09-01: technical code audits must systematically assess unused and obsolete code, integrate governed navigation context, and distinguish the application graph from the ShipGlows activation graph."
next_review: "2027-03-01"
next_step: none
---

# Dead Code And Obsolescence Audit

## Purpose And Trigger

Use this contract for project or global authored-code audits. Also use it for a file, directory, diff, or PR audit when the request explicitly names unused, unreachable, obsolete, legacy, compatibility, deprecation, or cleanup concerns.

The outcome is an evidence-backed inventory of code that is unused, unreachable, superseded, or retained without a current contract. It is not permission to delete findings. Dynamic loading, reflection, generated registration, framework conventions, external consumers, migrations, rollback paths, and bounded compatibility can make apparently unused code necessary.

## Context And Graph Boundary

When governed navigation exists, orient the audit in this order before broad discovery:

1. `shipglows_data/technical/context.md` for system surfaces;
2. `shipglows_data/technical/context-function-tree.md` for entrypoints and feature trees;
3. `shipglows_data/technical/code-docs-map.md` for path ownership and proof routing;
4. mapped behavior indexes or domain models for dynamic or ambiguous behavior.

Missing navigation is a coverage limit, not evidence that code is dead. Stale mappings are documentation drift and support an obsolescence finding only after source and runtime evidence agree.

Build or derive a bounded **application reachability graph** for the declared source scope. Its nodes may include entrypoints, modules, symbols, routes, commands, jobs, generated registries, feature flags, dependencies, tests, migrations, and public exports; its edges come from imports, calls, registrations, configuration, code generation, framework discovery, runtime dispatch, or documented external consumption.

This application graph is independent from ShipGlows' `skill-invocation-registry.json` and `resource_dependency_graph.py`, which validate skill ownership and reference activation only. Never use a valid ShipGlows activation graph as evidence that application code is reachable.

## Evidence Lanes

Select tools already declared by the project or available from its language ecosystem. Do not install scanners merely to complete an audit. Prefer compiler, analyzer, linter, package-manager, framework, and build-system evidence over lexical matching.

Assess every applicable lane:

- unused imports, variables, parameters, private members, exports, files, modules, packages, assets, routes, jobs, commands, and feature flags;
- unreachable branches, impossible states, orphaned registrations, superseded adapters, duplicate implementations, and stale compatibility paths;
- deprecated APIs or domain concepts still consumed, obsolete platform/version branches, expired migrations, and fallbacks whose removal criterion has passed;
- public or cross-package exports with no in-repository consumer, treating external consumption as unresolved until package/API evidence proves otherwise;
- tests, fixtures, snapshots, documentation mappings, and generated artifacts that reference retired behavior or keep it apparently alive;
- Git history only as supporting evidence for age, replacement, or removal intent; age alone never proves obsolescence.

Combine at least two independent evidence classes before classifying a removal candidate as confirmed, for example static reachability plus framework/build evidence, or zero consumers plus an explicit replacement/removal contract. A text search alone is discovery evidence.

## Dynamic And Compatibility Challenge

Before confirming a finding, challenge it against reflection, dependency injection, plugin discovery, serialization names, string-based routing, templates, native bridges, conditional imports, build variants, code generation, scheduled execution, external APIs, CLI entrypoints, rollback, data migrations, and supported-version compatibility.

Classify each candidate as:

- `confirmed unused`: no supported reachability or external contract remains, with corroborating evidence;
- `confirmed obsolete`: a current contract or replacement makes the path invalid or unnecessary, with removal conditions satisfied;
- `likely unused`: strong static evidence but dynamic or external consumption is not fully disproved;
- `retained intentionally`: current compatibility, rollback, migration, platform, or external-consumer contract is named with owner and removal criterion;
- `unknown`: evidence cannot safely distinguish live from dead.

## Coverage Verdict

Report a separate `Dead/Obsolete Code Gate` with:

`declared scope · context coverage · entrypoint inventory · application graph · language/tool evidence · dynamic challenge · external-consumer challenge · candidate classification · test/build corroboration`

Use exactly one coverage verdict:

- `complete for declared scope`: all declared source roots and supported entrypoint classes were inventoried, the applicable analyzers completed, dynamic/external challenges were resolved, and corroborating proof passed;
- `partial`: useful lanes ran but one or more source roots, entrypoints, analyzers, dynamic paths, build variants, or external consumers remain uncovered;
- `not proven`: evidence is too weak or failed before trustworthy reachability conclusions.

Never translate `complete for declared scope` into universal or future-proof completeness. List exclusions such as generated, vendored, ignored, platform-specific, or externally consumed code. A clean lint, successful build, passing tests, graph generation, sampled review, or absence of text matches cannot alone prove that no dead or obsolete code exists.

## Remediation Boundary

Audit remains read-only. For every proposed removal, record the evidence, user or maintenance impact, dynamic/compatibility challenge, smallest removal surface, required tests/build variants, rollback considerations, and documentation mapping. Group mutually dependent removals; do not mix speculative cleanup with confirmed candidates or silently delete compatibility tombstones.
