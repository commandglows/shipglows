---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.2"
project: ShipGlows
created: "2026-08-26"
created_at: "2026-08-26 07:42:21 UTC"
updated: "2026-08-26"
updated_at: "2026-08-26 08:28:18 UTC"
status: reviewed
source_skill: sg-development
source_model: GPT-5 Codex
scope: independent Windows WSL bootstrap and Turso Cloud CLI consumer
owner: Diane
user_story: "En tant qu'opératrice Windows, je veux que ShipGlows puisse préparer WSL indépendamment puis installer le CLI Turso Cloud seulement lorsque mon Ubuntu est prêt, afin d'utiliser ContentGlows sans rendre WSL obligatoire ni confier mes identifiants ou migrations à l'installateur."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.WslTurso.psm1
  - cli/install-turso-cloud.sh
  - install-shipglows.ps1
  - shipglows_data/technical/installer-and-user-scope.md
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/operator-guides/windows-devserver.md
depends_on:
  - artifact: shipglows_data/technical/installer-and-user-scope.md
    artifact_version: "2.24.0"
    required_status: reviewed
  - artifact: shipglows_data/technical/runtime-cli.md
    artifact_version: "1.23.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Microsoft documents wsl --install as requiring an administrator PowerShell, supporting -d and --no-launch, and potentially requiring a restart: https://learn.microsoft.com/windows/wsl/install and https://learn.microsoft.com/windows/wsl/basic-commands"
  - "Turso documents that its Cloud CLI on Windows requires WSL: https://docs.turso.tech/cli/installation"
  - "Turso Cloud CLI v1.0.32 publishes Linux x86_64 and arm64 archives but no native Windows archive: https://github.com/tursodatabase/turso-cli/releases/tag/v1.0.32"
  - "The official v1.0.32 checksums were independently downloaded and matched before implementation: x86_64 c35acbcad8e2e7a32580fe380adc4658d3032ddc56d25396b9b123aa4a704107; arm64 672f29e8f77b4c30a5f31c04fe0d5636d29fb1bb5be1137c40234bb2e76c2150."
  - "Operator decision 2026-08-26: WSL installation is an independent optional ShipGlows capability; Turso is a separate consumer that may proceed only when WSL and an initialized Ubuntu user are ready."
  - "Deterministic PowerShell and Git Bash fixtures passed for WSL states/consent/elevation/restart, Turso gating/version/checksum/architecture/atomicity/idempotence, and closed execution boundaries."
  - "The complete Windows DevServer contract passed with installed-runtime packaging proof and no real WSL or Turso installation."
next_step: "Run the separately approved exact-SHA operator smoke, stopping before any automatic restart or Turso authentication"
---

# Spec: Windows WSL and Turso Cloud bootstrap

🟢 [ShipGlows] spec: Windows WSL and Turso Cloud bootstrap | status: reviewed | path: shipglows_data/workflow/specs/windows-wsl-and-turso-cloud-bootstrap.md | next: run the approved exact-SHA operator smoke and stop before restart or authentication

## Objective

Let the native ShipGlows Windows installer independently inspect and, after explicit consent, install WSL with Ubuntu. Let the same installer separately offer the correct Turso Cloud CLI only after WSL and the Ubuntu user are ready. Neither capability is mandatory for installing ShipGlows.

## Minimal behavior contract

- WSL and Turso have separate state, consent, execution and result records.
- Declining WSL never blocks the rest of ShipGlows and never implies declining or accepting future consumers.
- Turso never triggers WSL installation. When WSL is not ready it remains pending with a precise next action.
- Non-interactive execution inspects only and never installs WSL or Turso.
- WSL installation uses only the fixed official `wsl.exe --install -d Ubuntu --no-launch` operation with visible elevation.
- A restart or first Ubuntu launch is reported as pending; ShipGlows resumes by re-inspecting on its next run.
- Creating the first Linux username and password remains an interactive Ubuntu-owned step.
- Turso installation runs only a bundled, fixed installer through an initialized Ubuntu distribution.
- Turso uses the pinned official Cloud CLI release, verifies the architecture-specific SHA-256, installs in `~/.local/bin`, and verifies the reported version.
- Turso installation never runs authentication, database creation, token creation, a migration, a database shell, or a user-supplied command.

## State model

### WSL

- `absent`: WSL is not operational; installation may be offered.
- `platform_only`: WSL responds but no Ubuntu distribution is registered; Ubuntu installation may be offered.
- `ubuntu_uninitialized`: Ubuntu exists but no non-root default user is registered; the operator must launch Ubuntu and create credentials.
- `ready`: Ubuntu has an initialized non-root default user and may host consumers.
- `pending_restart`: the last official install result requires or may require a Windows restart before reliable inspection.
- `error`: observation was contradictory or failed for a reason that is not equivalent to absence.

### Turso Cloud CLI

- `blocked_by_wsl`: WSL is not `ready`; no Turso mutation is allowed.
- `absent`: WSL is ready and the pinned CLI is not observed.
- `outdated`: a different Turso CLI version is observed.
- `ready`: `~/.local/bin/turso --version` proves the pinned Cloud CLI version.
- `error`: the bounded probe or verified installer failed.

## Security and recovery contract

- All executable names and arguments are closed constants; no browser or caller supplies a path, distribution, URL, command or shell fragment.
- The WSL elevation prompt is visible. Cancellation is a normal non-success result.
- The bundled Turso installer accepts no arbitrary URL or command and selects only `x86_64` or `aarch64`.
- Downloads go to a private temporary directory. Extraction selects only the expected `turso` member.
- The previous valid `~/.local/bin/turso` remains untouched until checksum, extraction and version verification succeed; replacement is atomic on the destination filesystem.
- No credential or Turso identity is read, written or logged.
- Rerunning after success is idempotent. Rerunning after restart or Ubuntu initialization resumes from observed state without a custom privileged resume task.

## Acceptance proofs

- Deterministic PowerShell fixtures cover absent WSL, platform-only WSL, uninitialized Ubuntu, ready Ubuntu, refusal, UAC cancellation, restart result and Turso gating.
- Deterministic Bash fixtures cover x86_64 and arm64 selection, checksum refusal, version refusal, successful atomic installation and a no-change second run.
- Packaging contracts prove the module and bundled installer are present in source and installed runtime payloads.
- Static checks prove there is no Turso authentication, database operation, migration command, generic shell executor or unpinned `latest` download.
- Existing Windows and Unix contract suites remain green.

## Explicit exclusions

- Performing a real WSL installation, restart or Ubuntu first-run during this implementation chantier.
- Installing or authenticating Turso on the operator machine during this implementation chantier.
- Running ContentGlows migrations or changing its database configuration.
- Installing the different native `tursodatabase/turso` local-database CLI.
- Exposing WSL, Turso or shell execution to the SaaS/browser capability contract.

## Skill Run History

- 2026-08-26 — `sg-development`: used to define the implementation boundary, explicit failure behavior, deterministic proof requirements and delivery hygiene.

## Current Chantier Flow

1. Verify official WSL and Turso contracts and pin supply-chain evidence — complete.
2. Implement the independent WSL state/consent/execution module — complete.
3. Implement the pinned Turso Cloud CLI consumer and Linux installer — complete.
4. Integrate packaging and interactive Windows flow — complete.
5. Add deterministic adversarial tests and operator documentation — complete.
6. Run the repository proof set and review the diff — complete.
7. Commit and push the approved branch — complete.
