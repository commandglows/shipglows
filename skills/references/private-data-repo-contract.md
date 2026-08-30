---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.2.0"
project: ShipGlows
created: "2026-07-08"
updated: "2026-08-28"
status: active
source_skill: 307-sg-skills-refresh
scope: private-data-repo-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - skills/302-sg-help/SKILL.md
  - skills/305-sg-init/SKILL.md
  - skills/references/private-memory-store.md
  - /home/claude/dotfiles/install.sh
depends_on:
  - artifact: "skills/references/private-memory-store.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-08: durable private ShipGlows data lives in a separate Git repository; its original local target was ~/.shipglows/private/data."
  - "Operator decision 2026-07-08: the repository remote must be configurable per user and must not be hardcoded in ShipGlows skill doctrine."
  - "Operator decision 2026-08-11: the repository moves to ~/.shipglows/data as a sibling of runtime and design-inspiration-library."
  - "Operator decision 2026-08-28: durable private data becomes an explicit ShipGlows capability, never ambient agent context."
  - "Operator decision 2026-08-28: historical repositories remain diagnosable and explicitly migratable; unknown future schemas fail closed."
  - "Operator decision 2026-08-28: an approved external-newsletter backup may remain versioned but stays outside agent capabilities."
next_review: "2026-08-08"
next_step: "/103-sg-verify private data repo contract"
---

# Private Data Repo Contract

## Purpose

This reference defines the durable private-data repository used by ShipGlows operators.

It exists so skills can distinguish:

- public ShipGlows code and governance under `$SHIPGLOWS_ROOT`
- durable private operator data under `~/.shipglows/data/`
- short-retention private operational state that is still worth versioning under the same private repo

## Canonical Local Paths

Private parent root:

```text
${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows}
```

Durable private data repo working tree:

```text
${SHIPGLOWS_PRIVATE_DATA_DIR:-${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows}/data}
```

This path is a separate Git working tree from both `$SHIPGLOWS_ROOT` and project repositories.

## Repository Contract

- `~/.shipglows/data/` is intended to be a dedicated Git repository.
- The remote repository must be resolved from configuration, not hardcoded in shared skill doctrine.
- Preferred config variable:

```text
SHIPGLOWS_PRIVATE_DATA_REPO
```

- The CLI reads `${XDG_CONFIG_HOME:-$HOME/.config}/shipglows/private-data.env` when it exists. It accepts only declarative `KEY=value` lines for `SHIPGLOWS_PRIVATE_DATA_REPO` and `SHIPGLOWS_PRIVATE_DATA_DIR`; it must never source this file as shell code.
- Environment values override values in that local file. The local file must be a regular file, owned by the current user, and inaccessible to group and other users.
- `SHIPGLOWS_PRIVATE_DATA_DIR` is the sole canonical storage variable. `SHIPGLOWS_PRIVATE_ROOT` is a read-only compatibility alias resolved by the CLI while legacy consumers remain.
- A bootstrap or install flow may also resolve companion variables such as `SHIPGLOWS_PRIVATE_DIR`.
- Help, docs, and memory skills should describe the repository role and path, not assume one operator-specific remote value.

## Explicit Capability Contract

The repository is not automatically available to every skill or conversation.
Before a skill reads or writes durable private data, the operator must explicitly
request private-data work, name one declared namespace, and state the intended
read or write operation. The runtime reports only redacted capability state by
default; it must not reveal a private path, remote, Git identity, filename, or
content in generic context, help, logs, tests, or public evidence.

The private repository may contain a versioned data-only manifest named
`.shipglows-private-data.json`. Its schema version is `1`; it contains only a
`schema_version` and `namespaces`. Each namespace declares a repository-relative
path, a bounded retention rule, and its allowed `read` and/or `write` operations.
Unknown fields, traversal paths, undeclared namespaces, and invalid operations
fail closed. A capability grant is limited to that namespace and operation; it
does not grant access to other private data or authorize writes outside the
ordinary mutation gate.

Use the control plane explicitly:

```text
shipglows private-data status
shipglows private-data doctor
shipglows private-data capability <namespace> <read|write>
shipglows private-data connect --repo <HTTPS-or-SSH-URL> [--existing --dir <absolute-path>] [--apply]
shipglows private-data migrate --manifest <absolute-path> [--apply]
shipglows private-data open [--apply]
shipglows private-data sync <pull|push> [--apply]
```

`connect` is a dry plan until `--apply`; applying it accepts only an explicit
credential-free HTTPS or SSH URL, delegates authentication to Git, and writes
the local configuration only after the clone succeeds. `--existing --dir`
adopts only a clean existing clone whose `origin` exactly matches that URL.
`open` is also a dry plan until `--apply`, which opens the configured
repository in the local file manager without printing its path. `status`,
`doctor`, and a sync call without `--apply` never synchronize. Sync
requires an explicit direction and `--apply`, a clean working tree, and one
configured upstream; it uses only fast-forward pull or ordinary push and refuses
unsafe repository states rather than repairing or mutating them implicitly.

## Compatibility And Migration Contract

- A Git repository without a manifest is generation `legacy`: status reports
  `migration_required`, doctor fails, and no namespace capability is granted.
- Schema `1` is the current generation. A structurally invalid schema is
  `invalid`; a different integer schema version is `unsupported`. Both fail
  closed and are never silently interpreted as current.
- `migrate --manifest` validates a complete current-schema proposal and the
  declared on-disk namespace directories. It is a dry plan until `--apply`,
  requires a clean legacy repository, and writes the manifest atomically.
- Before advancing the current schema, preserve synthetic fixtures for the
  current generation, the last supported legacy generation, malformed data,
  and an unknown future generation. Migration is explicit and idempotent;
  ordinary status, startup, installation, and skill discovery never migrate.
- Every tracked Git path must be portable to Windows. Reserved names, trailing
  dots/spaces, and `: * ? " < > |` fail doctor even on non-Windows hosts.

## Storage Contract

Use this repository for private, operator-managed data that benefits from versioning and backup, including some short-retention operational state when rollback or recovery value is real.

Examples:

- declarative mail-management state such as `mail-admin/`
- short-retention mail review queues such as `mail-intake/`
- an explicitly approved backup of third-party public newsletters under `mail-source/`, kept outside the capability manifest by default
- project fiches under `projects/`
- short-retention, redacted source-routing records under `source-cache/` while a project is still unknown
- private analysis reports that should remain outside public repositories

Do not use this repository for:

- secrets, tokens, OAuth client files, cookies, SSH keys, or credentials
- throwaway caches with no recovery value
- large temporary exports that would create noisy churn without operator leverage
- public governance artifacts that belong in a project repository or `$SHIPGLOWS_ROOT`
- operator, customer, private-correspondence, or credential-bearing email archives

## Separation Rules

- Durable private memory belongs in `~/.shipglows/data/`.
- Short-retention operational state may also live under `~/.shipglows/data/` when versioning materially improves operator safety or recovery.
- The important distinction is not "versioned vs not versioned" but durable reference state vs short-retention working state.
- Working-state folders must declare their own cleanup policy so the private repo does not become an unbounded archive.
- `source-cache/` is pre-assignment working state, not the canonical home of a source-derived asset. Once a project is chosen, write the durable pack, email sequence, or other derivative to that project's governed repository.
- `mail-source/` may be versioned only for an explicitly approved third-party public-newsletter backup containing no operator/customer correspondence or credentials. It remains separate from `mail-intake/` and outside agent capabilities unless a later explicit data-policy decision declares a narrower namespace.

## Clone Contract

Only the explicit `private-data connect --apply` command or a separately approved
bootstrap, install, or repair flow may clone the repository.

When such a flow owns setup:

- ensure the private parent directory exists
- never clone from ambient configuration during generic startup or skill discovery
- update the working tree cautiously if it already exists as a Git repo
- stop and report when the target path exists but is not a Git repo, unless an explicit migration contract says how to repair it

Non-bootstrap skills should not clone or mutate the repo just to answer a question or write a one-off artifact unless their owner contract explicitly allows it.

## Validation

Validate after edits with:

```bash
python3 tools/shipglows_metadata_lint.py skills/references/private-data-repo-contract.md skills/references/private-memory-store.md skills/300-sg-docs/SKILL.md skills/302-sg-help/SKILL.md skills/305-sg-init/SKILL.md
rg -n "private-data-repo-contract|SHIPGLOWS_PRIVATE_DATA_REPO|SHIPGLOWS_PRIVATE_DATA_DIR|\\.shipglows/data|mail-intake" skills/references skills/300-sg-docs/SKILL.md skills/302-sg-help/SKILL.md skills/305-sg-init/SKILL.md
bash tests/cli/private-data-config.sh
```
