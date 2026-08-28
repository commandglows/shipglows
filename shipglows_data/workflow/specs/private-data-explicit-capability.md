---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-28"
updated: "2026-08-28"
status: reviewed
source_skill: 900-shipglows-core
scope: explicit-private-data-capability
owner: Diane
user_story: "As a ShipGlows operator, I want my private data repository to be available through an explicit, bounded capability so agents can work with approved private data without treating it as global context."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-private/
  - skills/603-sg-private/
  - skills/references/private-data-repo-contract.md
  - cli/private-data.sh
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/shipglows-devserver.ps1
  - tools/
  - shipglows_data/technical/runtime-cli.md
depends_on:
  - artifact: skills/references/private-data-repo-contract.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/canonical-runtime-and-private-roots.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Audit 2026-08-28: durable private-data storage is documented and Unix configuration resolves it, but skills have no explicit data capability and CLI parity is incomplete."
  - "Operator approval 2026-08-28: connect the private repository to ShipGlows skills and CLI without implicit context or automatic synchronization."
  - "Live replay 2026-08-28: the historical Windows checkout was repaired from four upstream path-portability commits, adopted explicitly, migrated to schema 1, and verified without exposing newsletter content."
  - "Installed-runtime proof 2026-08-28: redacted status and doctor are healthy, projects/read is granted, mail-source/read is refused, and the full Windows DevServer contract passes with a process-local Windows module path."
next_step: "Use the first bounded declared namespace workflow and preserve these regression fixtures before any schema 2 proposal."
---

# Spec: Explicit Private-Data Capability

## Outcome

ShipGlows exposes one explicit private-data capability. It reports only redacted
availability by default, requires the operator to name a bounded private intent
before a skill reads or writes the repository, and keeps Git synchronization
operator-triggered.

## Scope

- Add a versioned manifest inside the private repository describing approved
  namespaces, retention, and whether an operation may read or write them.
- Extend the private-data contract and `sg-private` with a dedicated durable-data
  route distinct from machine-local pointer memory.
- Add equivalent Unix and Windows `status`, `doctor`, `connect`, `open`, and
  explicit Git synchronization behavior.
- Return redacted capability status to ShipGlows context/help consumers.
- Add synthetic fixtures and tests for access boundaries, manifest validation,
  Git-state refusal, and public-output redaction.

## Non-Goals

- Loading private repository contents into every Codex or ShipGlows run.
- Copying private data into public Git, plugin bundles, logs, fixtures, or docs.
- Storing secrets, credentials, raw mail, cookies, OAuth artifacts, or keys.
- Background, scheduled, or implicit Git fetch/pull/push.
- Replacing project-owned governed documentation with private records.

## Invariants

- A private-data action starts only from an explicit operator request and a
  declared namespace; repository presence alone grants no content access.
- Default status contains state/capabilities only, never a remote, path, file
  name, content, or Git identity.
- The manifest is data-only, size-bounded, schema-versioned, and rejects unknown
  fields, unsafe relative paths, missing retention, or unknown namespaces.
- Reads remain bounded to the selected manifest namespace; writes require the
  ordinary mutation gate and a clean repository state.
- Synchronization is a separate explicit action and refuses conflicts, staged
  changes, untracked files, or ambiguous remotes.
- Public source contains only generic contracts, schemas, tooling, and synthetic
  fixtures.

## Proof Path

Scenario-first for skills/governance and test-first for runtime parsers. Pressure
scenarios: absent repository, malformed manifest, explicit read request,
undeclared namespace, write without approval, dirty Git worktree, ahead/behind
status, Windows-incompatible path, and output redaction.

## Implementation Tasks

- [x] Task 1: Define the private-data manifest schema and shared contract.
  - Owner: private-data contract.
  - Proof: synthetic valid/invalid manifest tests and anti-leak scan.
- [x] Task 2: Add the explicit `sg-private data` route and its intent boundary.
  - Owner: `sg-private` / `603-sg-private`.
  - Proof: routing and pressure-scenario checks showing pointer memory remains separate.
- [x] Task 3: Implement redacted private-data status and doctor commands on Unix.
  - Owner: CLI runtime.
  - Proof: shell tests covering absent, configured, invalid, and dirty states.
- [x] Task 4: Implement the matching Windows DevServer commands.
  - Owner: native Windows runtime.
  - Proof: PowerShell contract tests and static DevServer contract.
- [x] Task 5: Implement guarded open/connect/sync operations.
  - Owner: CLI runtime.
  - Proof: no automatic Git mutation; sync refuses unsafe Git states.
- [x] Task 6: Update help, runtime documentation, code/docs map, and packaging boundary.
  - Owner: governance.
  - Proof: metadata, invocation graph, docs mapping, and staged anti-leak checks.
- [x] Task 7: Preserve repository compatibility across ShipGlows generations.
  - Owner: private-data runtime and migration contract.
  - Proof: synthetic legacy/current/future fixtures, explicit migration, existing-clone adoption, and platform-neutral Windows path checks.

## Acceptance Criteria

- An operator can determine whether the private capability is available without
  revealing private repository metadata in a normal status output.
- A skill cannot treat the repository as ambient context; an explicit data intent
  and manifest namespace are both required.
- Unix and Windows expose the same conceptual lifecycle and fail closed on an
  invalid configuration or repository state.
- A sync never occurs as an installation, startup, status, or skill side effect.
- Synthetic tests prove the private/public boundary and no real private data is
  needed for validation.
