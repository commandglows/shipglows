---
artifact: decision_record
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-08-26"
updated: "2026-08-26"
status: reviewed
source_skill: sg-docs
scope: "provider-agnostic-source-ingestion-with-readwise-reader-pilot"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
decision: "ShipGlows separates source acquisition from source analysis, preserves Mail Intelligence as an inactive fallback, and pilots Readwise Reader as the first replaceable source-provider adapter."
rationale: "The local Gmail/Maildir/notmuch path provides strong local control but duplicates mature capture, reading, organization, search, and export capabilities while imposing authentication, scheduling, parsing, indexing, and UI maintenance. Reader supplies a broader source desk and official MCP, CLI, API, and export surfaces, while ShipGlows already owns provider-neutral source classification and project routing."
consequences: "New source work targets a provider-neutral SourceEnvelope boundary and a Reader adapter. Existing Mail Intelligence code remains recoverable but receives no feature investment during the pilot. Reader is never the canonical owner of project derivatives, and raw source material remains outside public repositories."
evidence:
  - "Operator decision on 2026-08-26: put the custom email code aside, preserve it for possible reuse, and advance a provider-agnostic integration with Readwise Reader."
  - "Local review on 2026-08-19 found Mail Intelligence conceptually sound but not operational in the inspected environment and carrying unresolved idempotence, path, dependency, scheduling, and test debt."
  - "Fresh official Readwise documentation checked on 2026-08-26 confirms full-document MCP access, semantic and full-text search, Reader mutations, Markdown CLI access, a CLI read-only mode, incremental API listing, newsletter forwarding, and full-library export."
depends_on:
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/private-memory-store.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
next_step: "/100-sg-spec provider-agnostic source ingestion and Readwise Reader adapter pilot"
---

# Provider-Agnostic Source Ingestion With Readwise Reader Pilot

## Decision

ShipGlows adopts a provider-neutral boundary between source acquisition and source analysis.

`SourceEnvelope` and `SourceAnalysis` remain the stable internal contracts. Gmail, Maildir, Reader, a pasted document, a URL fetcher, or a future provider must enter through an adapter and must not leak provider-specific identifiers, authentication, storage, mutation, or parsing behavior into classification and downstream skills.

Readwise Reader is the first pilot adapter for competitor newsletters, RSS, web articles, PDFs, EPUBs, videos, podcasts, highlights, and notes. Reader owns capture, reading, highlighting, source organization, and its hosted library. ShipGlows owns explicit intake authorization, classification, project routing, transformation, durable derivatives, and governance.

Mail Intelligence is preserved in its current repositories as an inactive fallback. It is not deleted, migrated, or presented as the primary intake path. During the Reader pilot it receives only security-critical or preservation work, not new features. Reactivation requires a new comparison against the then-current Reader pilot evidence and an explicit decision.

## Provider-Neutral Boundary

Every source adapter must produce a bounded envelope with:

- provider name and provider-owned source identifier;
- stable ShipGlows `source_key` derived by adapter code;
- source type, title, author or publisher, canonical URL when available, timestamps, and language;
- bounded readable content or an authorized transient content retrieval handle;
- source provenance, tags, and operator intent hints;
- content hash or provider update marker for idempotence;
- explicit mutation capabilities and a default `mutation_policy=never`.

Analysis, routing, and project-owned output must not depend on Reader locations, Gmail labels, IMAP folders, Maildir paths, MCP tool names, or another provider vocabulary.

## Reader Pilot Contract

The first pilot uses a small, explicit queue rather than synchronizing the whole Reader library:

1. The operator captures and reads material in Reader.
2. A dedicated tag such as `shipglows-ready` authorizes intake.
3. A read-only CLI or API adapter retrieves only authorized documents and emits `SourceEnvelope` records.
4. Existing source-intake classification proposes project, angle, owner skill, risks, and next action.
5. The operator approves the destination and transformation.
6. The selected project owns the durable derivative.
7. Only after durable handoff may an explicitly authorized integration mark the Reader document processed or move it to archive.

Use MCP for interactive search and operator-visible triage. Prefer the CLI in read-only mode or the API for deterministic automation and auditability. Do not grant broad write capabilities merely because the MCP exposes them.

## Data And Security Boundaries

- Reader is a third-party hosted copy and index of the material added to it; do not route sensitive personal, customer, credential, legal, medical, or one-time-use inbox material there by default.
- Raw source bodies do not enter public ShipGlows or project repositories.
- Access tokens and OAuth state remain outside governance artifacts and repositories.
- Agents receive the smallest selected source set, not unrestricted library context by default.
- A source is evidence, not an editable project artifact. Source metadata, tags, notes, and highlights may change; transformed content belongs in the governed destination project.
- Full-library Markdown/file export is the portability and recovery requirement for the pilot, not permission to create a second ungoverned permanent source archive.

## Pilot Success Gate

The pilot may become the default intake path only after proving:

- reliable arrival and readable parsing across representative newsletters and other chosen source types;
- stable deduplication across repeated reads and provider updates;
- one explicit authorization boundary from Reader to ShipGlows;
- traceability from each derivative to its Reader source identifier and URL;
- read-only agent access by default and bounded reviewed mutations;
- successful full-library export and a documented recovery path;
- no raw source leakage into public or versioned governance artifacts.

Failure of the pilot does not automatically reactivate Mail Intelligence. It triggers a new provider and adapter comparison using the preserved local implementation as one option.

## Rationale

The system's differentiating value is turning heterogeneous evidence into governed project decisions and derivatives. Capture, reading, highlighting, feed management, source parsing, and cross-device library UX are commodity capabilities better delegated when a mature provider offers usable portability and agent access.

Provider neutrality prevents this convenience decision from turning Reader into ShipGlows architecture. It also preserves the ability to add a local filesystem adapter, a direct web adapter, or a repaired Mail Intelligence adapter later.

## Consequences

- The ready email-adapter spec must return to draft because its Maildir and IMAP-first triggers no longer describe the selected pilot.
- A new or revised spec must define `SourceProviderAdapter`, Reader mapping, authorization tags, idempotence, error handling, export and recovery proof, and mutation gates.
- Mail Intelligence remains useful historical implementation evidence, not current default architecture.
- A paid Reader account and hosted-data trust boundary become explicit pilot dependencies.
- Reader-specific behavior must pass the Freshness Gate before implementation or verification.

## Alternatives Considered

### Continue Mail Intelligence as the primary path

Rejected for the pilot because it requires continued ownership of Gmail authentication, Maildir synchronization, indexing, scheduling, MIME and HTML parsing, search, review UI, and cross-device reading behavior.

### Integrate Reader directly into downstream skills

Rejected because it would couple source classification and project outputs to one vendor, repeat provider logic across skills, and make future migration costly.

### Replace the local code immediately

Rejected because the Reader pilot is not yet proven and the local implementation retains useful privacy, recovery, and architecture evidence.
