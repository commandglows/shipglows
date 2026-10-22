---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-09-01"
updated: "2026-10-20"
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
  - tools/orphan_reference_audit.py
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
  - "Operator request 2026-10-20: detect orphan ShipGlows skill documentation automatically and add an approved removal lane after the read-only audit."
  - "Operator decision 2026-10-20: every removal candidate first passes a value triage (reconnect, then merge, then delete) so useful content is rewired instead of lost."
next_review: "2027-03-01"
next_step: none
---

# Dead Code And Obsolescence Audit

## Purpose And Trigger

Use this contract for project or global authored-code audits. Also use it for a file, directory, diff, or PR audit when the request explicitly names unused, unreachable, obsolete, legacy, compatibility, deprecation, cleanup, or removal concerns, including orphan documentation.

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

For the ShipGlows corpus itself, `tools/orphan_reference_audit.py` derives the documentation reachability graph: every Markdown file under `skills/` except entrypoints, reached from live tracked files (contracts, registries, CLI, tools, root docs) through conservative basename or stem mentions. It classifies `orphan` (no inbound mention), `weak` (only tests, fixtures, logs, changelogs, or archives mention it), and `unreachable` (only other unreached candidates mention it). Its output is discovery evidence for this contract, never deletion proof. A document whose triage verdict is `retain` records `orphan_policy: retain` and a one-line `orphan_reason` in its frontmatter so later runs count it as retained instead of re-reporting it.

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

## Removal Execution Lane

Deletion is a separate, operator-approved step that follows a completed audit. It never runs inside the audit and never on `likely unused`, `retained intentionally`, or `unknown` candidates. Unreachable is not worthless: an orphan or weak candidate is a wiring or value question before it is a deletion.

0. **Value triage (mandatory).** Read each candidate in full and decide, in this order, the first outcome that applies:
   - `reconnect`: the content is current, correct, and useful to an existing owner but its loader or caller is missing. Wire it where it belongs (owner skill loader, registry gate, import, route) instead of deleting it.
   - `merge`: the content is useful but overlaps a canonical artifact or is too small to stand alone. Absorb its non-redundant value into that target, then retire the source.
   - `retain`: it serves an external consumer, rollback, migration, or audit-evidence contract. Record the owner and removal criterion. Git history already preserves removed content, so "might be useful someday" or a wish to archive is never a `retain` reason.
   - `delete`: only when it is stale, wrong, superseded, or fully covered elsewhere, with that reason written per candidate.
   The triage verdict and its one-line reason are part of the approval packet; `reconnect` and `merge` outcomes are applied before any deletion.
1. **Approval packet.** Present only `confirmed unused` and `confirmed obsolete` candidates whose triage verdict is `delete` or a post-`merge` retirement, grouped by dependency, each with its evidence, impact, and the exact paths or symbols to remove. Deleting files or behavior is an irreversible-class action: wait for explicit operator approval of the listed set; approval covers that set only.
2. **Preserve before removing.** For documentation, apply the Migration Preservation Rule of `skills/300-sg-docs/references/core-governance.md`: absorb any non-redundant content into its canonical target or record its intentional rejection first.
3. **Remove the whole trace.** In the same change, remove the target plus everything that only kept it apparently alive: tests and fixtures asserting its existence, registry or activation entries, documentation mappings, `linked_systems`, and `depends_on` edges. A `weak` document is removed together with the tests that are its only consumers.
4. **Reversible mutation.** Use `git rm` (or source edits) on the current branch in one dedicated commit whose message lists each removed path and its classification, so the removal stays revertable as a unit. Never empty a trash, purge history, or delete untracked operator files.
5. **Post-removal proof.** Re-run the discovery that produced the candidates (for the ShipGlows corpus, `orphan_reference_audit.py` and `audit_shipglows_skills.py` for dangling loaders) and confirm no new missing reference or unreachable candidate appeared. For code, the build, test, or analyzer runs named in the approval packet are the corroboration; for documentation-only removals, reference integrity is the proof.
6. **Report** reconnected and merged items, removed paths, preserved content, remaining candidates, and the commit that can revert the removal.
