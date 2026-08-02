---
artifact: audit_report
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: "shipglows"
created: "2026-07-11"
updated: "2026-07-13"
status: draft
source_skill: "102-sg-start"
scope: "repo-doc-governance-refresh-phase-2"
owner: "claude"
confidence: "high"
risk_level: "medium"
security_impact: "none"
docs_impact: "yes"
domains: ["documentation-governance", "technical-docs", "workflow"]
issue_counts: {"high": 0, "medium": 0, "low": 0}
linked_systems:
  - "README.md"
  - "AGENT.md"
  - "shipglows_data/technical/README.md"
  - "shipglows_data/technical/runtime-cli.md"
  - "shipglows_data/workflow/audits/2026-06-30-repo-doc-governance-refresh.md"
depends_on:
  - artifact: "shipglows_data/workflow/audits/2026-06-30-repo-doc-governance-refresh.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Root Markdown inventory and consumer search executed on 2026-07-11 from /home/claude/shipglows."
  - "The repository worktree already contained unrelated user changes; shared files were not rewritten."
  - "The four phase-2 debt files were compared with current canonical technical, editorial, and workflow surfaces before classification."
  - "Reverification on 2026-07-13 confirmed five direct root Markdown paths, canonical workflow artifacts, archived historical notes, repaired central routes, and a valid AGENTS.md compatibility symlink."
  - "The 2026-07-13 300-sg-docs follow-up expanded the inventory to top-level documentary directories, migrated root specs/research/archive/docs/bugs, and strengthened the topology audit against this drift."
  - "The 2026-07-13 test-layout follow-up moved all seven root test suites under ownership-based tests/ directories, renamed opaque priority suites, and updated active commands."
next_step: "/005-sg-ship shipglows documentation governance cleanup phase 2"
---

# Repo Documentation Governance Refresh Phase 2

## Purpose

Record the ownership decisions, consumer evidence, preservation status, and remaining migration debt for the root documentation pass. This audit is the durable checklist for `DOC-ROOT-01` through `DOC-ROOT-07`.

## Execution Contract

- Proof path: `evidence-first`.
- Root inventory command: `find . -maxdepth 1 -name '*.md' -printf '%f\\n' | sort`; this includes regular files and compatibility symlinks.
- Consumer search: `rg -n '<filename-or-stem>' --glob '!node_modules/**' --glob '!.git/**' --glob '!shipglows-site/.astro/**' .`.
- Mutation rule: no source file is reduced or deleted unless its non-redundant content is preserved in a named canonical target and the diff is reviewed.
- Worktree rule: files already modified before this run are not rewritten without a file-specific review.

## Root Inventory And Decisions

| Root artifact | Family | Consumers found | Canonical target | Verdict | Preservation / action |
| --- | --- | --- | --- | --- | --- |
| `AGENT.md` | entrypoint | README, technical maps, agent workflows | root entrypoint | `keep-root` | Canonical agent entrypoint; no mutation. |
| `AGENTS.md` | compatibility | agent tooling convention | `AGENT.md` | `compat-facade` | Valid symlink to `AGENT.md`; preserve as compatibility alias. |
| `CLAUDE.md` | bootstrap/instructions | agent runtime | root instructions | `keep-root` | Tool-native entrypoint; no migration. |
| `README.md` | public/operator surface | broad repository links | root README | `keep-root` | Public/operator overview; existing worktree modification treated as pre-existing. |
| `CHANGELOG.md` | public history | release readers | root changelog | `keep-root` | Public project changelog; no migration. |

## Top-Level Documentary Surfaces

| Surface | Contract role | Verdict | Action / proof |
| --- | --- | --- | --- |
| `shipglows_data/` | canonical governance and workflow corpus | `keep-root` | Canonical owner. |
| `docs/` | legacy mixed documentation surface | `migrate-to-canonical` | Conversations moved to `shipglows_data/workflow/conversations/`, explorations to `shipglows_data/workflow/explorations/`, and operator guides to `shipglows_data/technical/operator-guides/`; root directory removed. |
| `archive/` | legacy historical surface | `migrate-to-canonical` | Useful history moved to `shipglows_data/workflow/archives/repository-history/`; conversations moved to `shipglows_data/workflow/conversations/`; duplicate, generated, empty-facade, and scratch material deleted; root directory removed. |
| `bugs/` | legacy bug workflow surface | `migrate-to-canonical` | Dossiers moved to `shipglows_data/workflow/bugs/`; root directory removed and producer contracts updated. |
| `specs/` | legacy governance source | `migrate-to-canonical` | `frp-preview-tunnel-poc.md` moved to `shipglows_data/workflow/specs/`; the empty source directory is removed. |
| `research/` | legacy governance source | `migrate-to-canonical` | Both research reports moved to `shipglows_data/workflow/research/`; the empty source directory is removed. |
| `shipglows_data/workflow/conversations/` | raw conversation capture output | `canonical` | Explicit destination contract in `800-tmux-capture-conversation`; downstream cleaned/audited records may separately live under `shipglows_data/workflow/`. |
| `shipglows_data/workflow/explorations/` | exploration report output | `canonical` | Explicit destination selected by the `700-sg-explore` contract. |

## Migrated And Archived Decisions

| Former root artifact | Final target | Verdict | Final proof |
| --- | --- | --- | --- |
| `shipglows-metadata-migration-guide.md` and legacy `shipglows-metadata-migration-guide.md` | `shipglows_data/technical/metadata-migration-guide.md` | `migrate-to-canonical` | Root aliases are absent; README, AGENT, context, and code-docs map use the canonical path. |
| `shipglows-spec-driven-workflow.md` and legacy `shipglows-spec-driven-workflow.md` | `shipglows_data/workflow/playbooks/spec-driven-workflow.md` | `migrate-to-canonical` | Root aliases are absent; README, AGENT, context, and code-docs map use the canonical path. |
| `ECOSYSTEM-AND-PORTS.md` | `shipglows_data/technical/runtime-cli.md` plus `shipglows_data/workflow/archives/repository-history/root-documentation/ECOSYSTEM-AND-PORTS.md` | `archived` | Current runtime route is in README; historical source is preserved inside the canonical archive corpus. |
| `FAQ.md` | `shipglows_data/workflow/archives/repository-history/root-documentation/FAQ.md` | `archived` | Historical internal guidance is preserved separately from the site-owned public FAQ. |
| `INSTALL-REPORT-TEMPLATE.md` | `shipglows_data/workflow/templates/INSTALL-REPORT-TEMPLATE.md` | `migrate-to-canonical` | Canonical template exists and the former root alias is absent. |
| `INSTALL-RUN-TRACE.md` | `shipglows_data/workflow/audits/2026-04-28-install-run-trace.md` | `archived` | Historical trace exists at the dated canonical audit path and the former root alias is absent. |
| `INSTALLATION-OWNERSHIP-SPEC.md` | canonical workflow spec plus `shipglows_data/workflow/archives/repository-history/root-documentation/` preservation | `archived` | Active references use the canonical spec; historical source remains canonically archived. |
| `TASKS.md` and `AUDIT_LOG.md` | `shipglows_data/workflow/` | `archived` | Empty root facades are absent; canonical trackers remain active. |
| `concurrent.md` | `shipglows_data/workflow/concurrent.md` | `archived` | Root facade is absent and the workflow note remains canonical. |
| `conversation-shipglows-questions-contextuelles-des-skills.md` | `shipglows_data/workflow/conversations/` | `migrate-to-owned-surface` | Raw conversation capture moved to the destination owned by the conversation workflow. |

## Required Scenario Results

### DOC-ROOT-01

The direct root inventory is five Markdown paths: four regular files (`AGENT.md`, `CHANGELOG.md`, `CLAUDE.md`, `README.md`) and one compatibility symlink (`AGENTS.md -> AGENT.md`). The top-level documentary-surface inventory separately classifies `shipglows_data/` and the migrated legacy sources `archive/`, `bugs/`, `docs/`, `specs/`, and `research/`.

### DOC-ROOT-02

The four named phase-2 debts have explicit decisions and consumer evidence:

- `ECOSYSTEM-AND-PORTS.md`: current behavior is routed to `shipglows_data/technical/runtime-cli.md`; historical content is archived and indexed.
- `FAQ.md`: historical internal guidance is archived without conflation with the site-owned public FAQ.
- `INSTALL-REPORT-TEMPLATE.md`: canonical workflow template exists under `shipglows_data/workflow/templates/`; no root alias remains.
- `INSTALL-RUN-TRACE.md`: canonical historical evidence exists under the dated workflow audit path; no root alias remains.

### DOC-ROOT-03

The workflow artifacts are preserved under canonical workflow paths without root facades. `ECOSYSTEM-AND-PORTS.md` and `FAQ.md` are preserved under `shipglows_data/workflow/archives/repository-history/root-documentation/`; current runtime documentation uses `shipglows_data/technical/runtime-cli.md`. The archive migration ledger records every preserved or intentionally deleted source.

### DOC-ROOT-04

The later integrator pass updated `README.md`, `AGENT.md`, `shipglows_data/technical/context.md`, and `shipglows_data/technical/code-docs-map.md` to use canonical workflow and metadata-guide paths. The governance follow-up also aligned `architecture.md`, canonical-path rules, project/documentation governance rules, and the canonical repository-history index. README routes current port/PM2 behavior to `shipglows_data/technical/runtime-cli.md` and historical context to `shipglows_data/workflow/archives/`.

### DOC-ROOT-05

- `AGENTS.md` remains a symlink to `AGENT.md`.
- The audit, canonical install artifacts, README, AGENT, context, technical index, and code-docs map pass targeted ShipGlows metadata validation.
- Former root paths for the four named phase-2 debts are absent; repository searches resolve surviving mentions to canonical or archive paths, historical audits, or explicit migration evidence.
- The unrelated worktree change in `skills/references/private-data-repo-contract.md` remains outside this verification and was not modified.

### DOC-ROOT-06

- Root `docs/` is absent.
- Conversation captures and exploration reports are under their canonical workflow families.
- OpenCode, KiloCode, focus-tag, and skill-launch guides are indexed under `shipglows_data/technical/operator-guides/`.
- Capture scripts, tests, plugin bootstrap, README, and public-site links use the canonical paths; the deprecated `docs` capture preset resolves to the canonical conversation destination without recreating `docs/`.

### DOC-ROOT-07

- Root `bugs/`, `BUGS.md`, and `TEST_LOG.md` are absent.
- Bug dossiers, the bug triage view, and the QA log are preserved under `shipglows_data/workflow/`.
- Bug, fix, test, verify, deploy, ship, and artifact-template contracts use canonical workflow paths.
- The topology audit and metadata guard reject recreation of the legacy root surfaces.

## Follow-up Actions

1. Keep `shipglows_data/workflow/audits/2026-04-28-install-run-trace.md` historical; update only if future install evidence requires a new dated trace.
2. Completed: repaired the three stale test contracts. Config/logging/cache passes `25/25`, Flox provisioning passes `22/22`, and project tracking passes `15/15` with a new idempotence assertion.
3. Completed: audited the six root CLI compatibility launchers. `shipglows.sh`, `lib.sh`, `config.sh`, and `install.sh` retain active compatibility consumers; the two unconsumed root `shipglows_devserver_*` facades were removed and canonical `cli/` references were preserved.

## 103-sg-verify Follow-up Findings

- The phase-2 documentation scenarios pass: governance topology is compliant, all 12 topology tests pass, all 4 conversation-storage tests pass, metadata lint passes, and legacy documentary surfaces remain absent.
- Repository-root test placement debt was resolved by moving seven useful suites under ownership-based `tests/` subdirectories and replacing opaque priority names with behavior-based names.
- `tests/cli/config-logging-cache.sh` now uses canonical logging variables, fails closed on assertion errors, and passes `25/25`.
- `tests/cli/json-error-handling.sh` targets canonical `cli/lib.sh` instead of the root compatibility facade and passes `33/33`.
- `tests/runtime/flox-provisioning.sh` uses canonical override and session-name contracts and passes `22/22`.
- `tests/governance/project-tracking-init.sh` targets `shipglows_init_project`, validates actual symlink removal, and passes `15/15`; `shipglows_init_project` now returns success explicitly when no changes are needed.
- All seven relocated suites now pass, and the two unconsumed root devserver compatibility facades are absent.

## Stop Conditions Encountered

- The initial execution stopped on pre-existing modifications to shared central files; a later bounded integrator pass completed the canonical route updates.
- `ECOSYSTEM-AND-PORTS.md` required separation of current runtime truth from historical examples; current truth is canonical and the historical source is archived.
- `FAQ.md` could not safely become the public FAQ; archiving preserved it without creating a competing editorial source.

## Validation Evidence

```text
python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/audits/2026-07-11-repo-doc-governance-refresh-phase-2.md shipglows_data/workflow/templates/INSTALL-REPORT-TEMPLATE.md shipglows_data/workflow/audits/2026-04-28-install-run-trace.md README.md AGENT.md shipglows_data/technical/context.md shipglows_data/technical/README.md shipglows_data/technical/code-docs-map.md
ShipGlows metadata lint passed: 6 file(s) checked.

2026-07-13 governance-topology follow-up:
python3 -m unittest tools.test_audit_project_governance_topology
Ran 10 tests - OK

python3 tools/audit_project_governance_topology.py .
Governance topology: compliant
Canonical corpus: present

python3 tools/shipglows_metadata_lint.py <14 touched governed artifacts>
ShipGlows metadata lint passed: 14 file(s) checked.

git diff --check
passed

test ! -e AGENTS.md || { test -L AGENTS.md && test "$(readlink AGENTS.md)" = "AGENT.md"; }
passed

find . -maxdepth 1 -name '*.md' -printf '%f\\t%y\\t%l\\n' | sort
AGENT.md, AGENTS.md -> AGENT.md, CHANGELOG.md, CLAUDE.md, README.md

Top-level ownership result:
archive/ absent; bugs/ absent; docs/ absent; specs/ absent; research/ absent; useful history retained under shipglows_data/workflow/archives/; active documentation and workflow records retained under canonical shipglows_data families.

2026-07-13 DOC-ROOT-06/07 validation:
python3 tools/audit_project_governance_topology.py .
Governance topology: compliant

python3 -m unittest tools.test_audit_project_governance_topology
Ran 12 tests - OK

bash tests/workflow/conversation-storage.sh
Conversation audit storage tests: 4 passed, 0 failed

python3 tools/shipglows_metadata_lint.py <16 governed migration artifacts>
ShipGlows metadata lint passed: 16 file(s) checked.

Preservation comparison against HEAD before migration:
4 conversation captures, 5 exploration reports, and 3 bug dossiers are byte-identical.
BUGS.md and TEST_LOG.md preserve their records with only canonical path substitutions.
The 4 operator guides preserve their bodies with migration metadata, canonical-path substitutions, and two repaired guide links.

Migration preservation diff:
The FRP spec body is unchanged; only migration metadata, the current skill identifier, and the previously missing required confidence field changed.
Both research report bodies are unchanged; only updated dates and current 203-sg-research identifiers changed.
Archive migration proof: 15 of 16 preserved historical files are byte-identical to their pre-migration blobs; `plan_migration.md` differs only by a final newline normalization. Two conversation captures were moved without content changes. Deleted compatibility symlinks resolve to canonical workflow artifacts; all other deletions are classified in the repository-history ledger.

Final root-architecture verification on 2026-07-13:
all seven ownership-based Bash suites pass (`25/25`, `68/68`, `33/33`, `15/15`, `22/22`, runtime sync, and `4/4` conversation storage); 12 topology unit tests pass; governance topology, Bash syntax, metadata lint, skill runtime sync `270/270`, and `git diff --check` pass; no root `test_*.sh` or root devserver facade remains.

Historical SHA-256 comparison from the parent of migration commit f1f90b7:
ECOSYSTEM-AND-PORTS.md = shipglows_data/workflow/archives/repository-history/root-documentation/ECOSYSTEM-AND-PORTS.md = ab9793a75005124f230eff087faddacba7d1ca24f9093bb4ec649c86011bca6b
FAQ.md = shipglows_data/workflow/archives/repository-history/root-documentation/FAQ.md = 1579c94d5a7518a5f7ecec950884a9a1a22a6c93053091cb1c314bb31f463c87
INSTALL-REPORT-TEMPLATE.md = shipglows_data/workflow/templates/INSTALL-REPORT-TEMPLATE.md = b272a20733634f04ea277c85d79ee978ccd5aab0d3af94dc1ee134bdfb8ff24d
INSTALL-RUN-TRACE.md = shipglows_data/workflow/audits/2026-04-28-install-run-trace.md = beae689b0b1b32a6167f544b19cf133d76d20dc2e91b57aa70eea25e8a88a731
```
