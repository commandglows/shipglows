---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: draft
source_skill: 900-shipglows-core
scope: obsidian-plugin-workflow
owner: Diane
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/sg-development/SKILL.md
  - skills/103-sg-verify/references/verification-security-ui-runtime.md
depends_on: []
supersedes: []
evidence:
  - "2026-10-07: selectively adapted from origin/dev 4aa0c5a; no Windows Obsidian runtime or historical proof imported."
next_review: "2026-11-07"
next_step: "Validate routing and plugin behavior in a separate authorized development environment."
---

# Obsidian Plugin Workflow

Select from coherent repository evidence: an Obsidian manifest, the `obsidian`
dependency, a plugin entry point and a declared build contract. A filename or
Vite dependency alone does not establish an Obsidian surface.

## Implementation And Lifecycle

For greenfield work, use the Obsidian preset in `preferred-stacks.md`.
Inspect scripts, manifest, entry point, artifact output and supported platforms
before execution. Review current official Obsidian documentation when API or
artifact compatibility controls a decision. Existing accepted architecture
remains authoritative; this reference does not mandate a migration.

Keep commands, vault access, persistence, event registration and cleanup owned
by the Obsidian plugin lifecycle. Mount rich UI only inside a host-owned
container, retain its application handle and unmount it when the surface closes
and defensively during plugin unload. Inherit host theme variables and verify
keyboard access and the accepted desktop/mobile footprint.

## Build And Vault Boundaries

Missing or stale artifacts mean `build-required`. Only the reviewed project
build may produce them, in an environment where execution is authorized.
Inspection grants no installation or script-execution authority.

Persistent synchronization needs one explicitly declared development vault and
an approved copy operation. Never enumerate, infer or select personal vaults.
Do not invent a localhost URL for the host plugin surface.

The current branch does not implement dev's `s obsidian-lab` command or its
specialized vault-sync workflow. Do not recommend those commands as installed
capabilities. Resolve a separately authorized host-validation environment;
missing host proof remains `validation-unavailable`.

## Host Proof And Distribution

For host validation, use an approved plugin artifact with a disposable profile
and vault separate from personal state. Confirm the exact target before load.
Path separation protects personal data but is not an OS sandbox: plugin code
retains the account's permissions. Record actual host loading, the requested
interaction, runtime diagnostics and process/data cleanup independently.

Keep detection, configuration, build freshness, artifact integrity, copying,
host load, interaction, diagnostics and cleanup as separate evidence states.
Compilation or copying never proves that Obsidian loaded the plugin. A loaded
plugin with failed diagnostics does not pass verification.

Local BRAT-compatible artifacts do not authorize a tag, release, publication,
BRAT installation or community submission. Missing execution or host evidence
prevents claims that the plugin is tested, ready for users or published.
