---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 300-sg-docs
scope: design-inspiration-library-server-migration-checklist
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/design-inspiration-library-server-migration-playbook.md
  - skills/references/design-inspiration-library.md
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/design-inspiration-library-server-migration-playbook.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Companion execution control for the 2026-08-07 private design inspiration corpus migration playbook."
next_step: "Complete during a server move; retain only redacted proof outside the private corpus."
---

# Design Inspiration Library Server Migration Checklist

## Purpose

Confirm that a new server can safely read and synchronize the private design/copy inspiration corpus.

## Applicability

Use with the linked playbook during new-server provisioning, corpus repair, or an approved repository rotation.

## Required Before Start

- [ ] Private Git access is authorized for the current server user.
- [ ] The intended corpus remote is available through a private channel.
- [ ] The public ShipGlows checkout is present and its capture tool is runnable.
- [ ] The target disk has capacity for the current Git LFS media corpus.

## Checklist

### Git LFS

- [ ] `git --version` succeeds.
- [ ] `git lfs version` succeeds for the server user.
- [ ] `git lfs install --skip-repo` has completed.

### Corpus Checkout

- [ ] The corpus is cloned under the configured private parent directory.
- [ ] `git lfs pull` completed after cloning.
- [ ] The corpus is not inside the public ShipGlows repository or a plugin/cache directory.
- [ ] The checkout has an `origin` remote and a clean `git status --short`.

### Synchronization Safety

- [ ] The local `shipglows.inspirationOriginFingerprint` matches the effective origin URL.
- [ ] `full-page.webp`, `thumbnail.webp`, and segment paths report `filter: lfs` through `git check-attr`.
- [ ] `git lfs ls-files` is readable; an empty output is accepted only for an empty or metadata-only corpus.
- [ ] `git push --dry-run origin HEAD` succeeds.
- [ ] No remote URL, credentials, cookies, or source-derived content was copied into public documentation or logs.

### Functional Proof

- [ ] The synthetic fixture capture succeeds outside the real corpus.
- [ ] The real corpus responds to read-only `--list`.
- [ ] No real source page was added only to test the migration.

### Handoff

- [ ] The local corpus path and completion date are recorded privately.
- [ ] Any pending private Git access or LFS issue has an owner before the old server is retired.
- [ ] For a removal/purge migration, the replacement repository and deletion steps follow the library contract.

## Completion Rule

Complete only when Git LFS, the private checkout, its verified origin, and a dry-run push have all passed, with no source-derived asset exposed outside the private corpus.

## Linked Playbook

- [design-inspiration-library-server-migration-playbook.md](../playbooks/design-inspiration-library-server-migration-playbook.md)

## Exceptions

- If GitHub/private Git access is not yet available, keep the restored corpus local and mark synchronization pending; do not use a public substitute.
- An intentional new remote after a justified purge requires a new fingerprint and fresh dry-run proof.
