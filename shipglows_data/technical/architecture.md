---
artifact: architecture_context
metadata_schema_version: "1.0"
artifact_version: "1.13.0"
project: "shipglows"
created: "2026-04-26"
updated: "2026-08-16"
status: reviewed
source_skill: manual
scope: architecture
owner: "unknown"
confidence: high
risk_level: medium
linked_systems:
  - "cli/shipglows.sh"
  - "cli/lib.sh"
  - "cli/config.sh"
  - "cli/install.sh"
  - "cli/windows/"
  - "cli/environment/"
  - "install-shipglows.ps1"
  - "local/local.sh"
  - "skills/"
  - "templates/"
  - "tools/shipglows_metadata_lint.py"
  - "tests/"
external_dependencies:
  - "Flox"
  - "PM2"
  - "Caddy"
  - "DuckDNS"
  - "SSH"
  - "Node.js/pnpm"
  - "uv"
  - "Flutter"
invariants:
  - "PM2 cache must be invalidated after state mutations"
  - "Project paths must be validated and absolute"
  - "ShipGlows artifact docs must use versioned metadata"
  - "Project governance artifacts must live under project-local shipglows_data/ subdirectories"
  - "UI projects must declare a design-system authority before visual implementation changes"
  - "Environment intent, planning, observation, and backend execution remain separate states; only an approved executable backend may mutate tools"
security_impact: yes
docs_impact: yes
evidence:
  - "Core files and function tree extracted from the repo"
  - "CLAUDE.md documents PM2 caching, port allocation, idempotence, and validation rules"
  - "2026-05-11 decision record project-governance-layout formalizes root-vs-shipglows_data placement."
  - "2026-06-11 design-system authority contract separates brand direction from code-level token/theme authority."
  - "Operator clarification 2026-07-13 distinguishes canonical governance records from root QA/bug, public-reference, and inactive archive surfaces."
  - "Operator decision 2026-07-13 moves useful repository history into shipglows_data/workflow/archives and rejects a root archive surface."
  - "Operator decision 2026-07-13 rejects root docs and bug workflow exceptions in favor of one canonical shipglows_data corpus."
  - "Operator decision 2026-07-13 flattens the single-child templates/artifacts hierarchy into templates/."
  - "The 2026-08-16 environment foundation adds one strict cross-platform capability contract, deterministic plans, and redacted private observations without activating a package-manager backend."
  - "The 2026-08-16 source pilot activates only Windows mise plus project-local Node 24 and pnpm 10 behind approval-digest validation and an injectable structured runner; the Best Fried Chicken provider smoke proves that bounded cycle while every other backend/capability remains fail-closed."
depends_on:
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-05-26"
next_step: "/sg-docs audit shipglows_data/technical/architecture.md"
---

# Architecture Context

## System Shape

ShipGlows has two connected layers:

- a runtime control layer with a Linux server backend and a native Windows local-development backend
- a documentation and workflow layer for AI-assisted execution discipline

The repo is not split into small services. It is centered around shell-based orchestration plus Markdown artifact governance.

### Reproducible environment control plane

`cli/environment/` is a thin, Python-standard-library control plane above native environment engines. It owns the ShipGlows capability vocabulary and keeps three truths distinct:

- desired state comes from a strict `shipglows.environment.json`, the closed runtime-policy allowlist in `.shipglows.env`, and recognized native manifest references;
- resolved state is a deterministic, digest-bound plan whose operations expose ownership and effects;
- observed state is fresh process evidence stored atomically and redacted in the user-private ShipGlows state directory.

The first executable source pilot recognizes only an explicit Windows `mise.toml` containing the code-free `[tools] node = "24"` and `pnpm = "10"` shape plus exact `mise.lock` Windows artifact entries. Missing mise produces a distinct approval-gated `jdx.mise` WinGet acquisition operation; a fresh plan is required before tool installation. Existing mise installs are observed rather than adopted, each missing tool is installed by its own fixed `mise --locked install <tool>` operation, and ownership is proven with `mise --locked which <tool>` before every structured user/agent `mise --locked exec -- <tool> --version` probe. When `package.json#packageManager` exists it must equal the exact locked pnpm version. ShipGlows never runs `pnpm install` in this pilot, activates shims globally, edits a profile, rewrites persistent `PATH`, or takes ownership of global Node or pnpm.

The backend boundary reconstructs fixed argv after validating the complete semantic plan, approval digest, current source digests, safe config shape, exact lock entries, backend version, and official package identity. Repository command names and manifest strings never become executable input. The runner is injectable for fixture proof and uses `shell=False` in the OS implementation. It removes inherited `MISE_*` controls from the child only, supplies its own safe/config/offline controls, preserves `PATH`, rejects alternate project mise configuration and refuses a backend executable resolved inside the repository. Windows App Execution Alias and fresh WinGet package discovery are resolved through canonical package roots rather than arbitrary PATH entries. Outside that exact pilot, `apply` retains the foundation's `no_active_backend` refusal. The source pilot is not yet packaged into the installed native Windows runtime; the approved Best Fried Chicken smoke acquired mise and converged locked Node 24.19.0 plus pnpm 10.34.5 without dependency installation, profile/PATH mutation, commit or push.

## Entry Points

- `cli/shipglows.sh` for the main CLI.
- `local/local.sh` for local SSH tunnel operations.
- `cli/install.sh` for server bootstrap and user environment setup.
- `install-shipglows.sh` and `install-shipglows.ps1` as stable public bootstrap URLs.
- `cli/windows/shipglows-devserver.ps1` and `cli/windows/ShipGlows.DevServer.psm1` for native Windows local project control.
- `skills/*/SKILL.md` plus templates and linter for workflow execution.

## Runtime Boundaries

- Runtime control lives in shell/PowerShell orchestration and external tools rather than in a long-running application server.
- On Linux, process truth lives in PM2, environment isolation in Flox, and optional public exposure in Caddy/DuckDNS.
- A Linux Flox environment root and its application launch path are distinct runtime identities. Nested Flox roots own their subtrees; ambiguous sibling applications are never selected implicitly.
- On Windows, process truth lives in a user-local atomic JSON registry plus revalidated process identity; Node/pnpm, uv, and Flutter own project runtimes, and services bind only to localhost.
- Windows `.cmd` entrypoints own profile-independent command resolution; Linux-only server components are not emulated.
- Workflow governance lives in Markdown artifacts, skills, and metadata validation.

## Major Components

- `cli/lib.sh`: main orchestration library and the largest functional hotspot.
- `cli/config.sh`: configuration source and validation layer.
- `local/`: local access and tunnel management.
- `cli/windows/`: native PowerShell DevServer, registry/process lifecycle, launcher, developer-tool setup, and collision-safe command wrappers.
- `skills/`: task-specific workflows and governance behavior.
- `templates/`: normalized artifact structures.
- `tools/shipglows_metadata_lint.py`: executable metadata contract validator.
- `tests/`: executable regression suites grouped by owning subsystem (`cli`, `governance`, `runtime`, `skills`, and `workflow`).

## Data And Control Flows

- CLI flow: `cli/shipglows.sh` -> `cli/lib.sh` -> menu actions -> PM2/Flox/Caddy operations.
- Native Windows flow: `install-shipglows.ps1` -> `cli/windows/install-devserver.ps1` -> PATH-backed `.cmd` launcher -> PowerShell frontend/module -> localhost project process and atomic registry.
- Local tunnel flow: `local/local.sh` -> SSH connection selection -> remote state inspection -> tunnel lifecycle.
- Doc/workflow flow: skills -> templates -> markdown artifacts -> metadata lint -> verification.

## Data And State

- PM2 state is cached locally for responsiveness and must be invalidated after mutations.
- The Linux environment registry records `environment_root` and `launch_path`; PM2 uses the latter as its working directory while Flox activates from the former.
- Secrets and connection state are stored separately from the main workflow docs.
- Decision state is carried in versioned Markdown artifacts, not in operational trackers.

## External Dependencies

- On Linux, Flox isolates runtimes, PM2 owns running process state, and Caddy/DuckDNS expose optional public URLs.
- On Windows, Node/pnpm, uv, and Flutter own supported project runtimes; Gum owns the preferred interactive selector, while Git/GitHub CLI own repository operations and authentication.
- SSH supports remote access and local tunnel flows.

## Invariants

- PM2 mutation without cache invalidation is a correctness bug.
- Unsafe project paths are rejected rather than normalized optimistically.
- Generated or runtime-managed config should not be hand-edited as source of truth.
- Workflow docs are treated as contracts; trackers are not.

## Documentation Architecture

- ShipGlows documentation is split into stable layers to keep runtime work and public/user-facing messaging independent:

  - `shipglows_data/technical/architecture.md`, `shipglows_data/technical/guidelines.md`, `shipglows_data/technical/context.md`, `AGENT.md`: global doctrine and topology contracts.
  - `shipglows_data/technical/design-system-authority.md`: project UI authority for canonical token/theme/component/layout/motion sources.
  - `shipglows_data/technical/` and `shipglows_data/workflow/specs/`: subsystem technical contracts and durable workflow contracts.
  - Editorial/public pages under `shipglows_data/editorial/` and `shipglows-site/`: public messaging, onboarding surfaces, and operator guides.

- Project root Markdown is intentionally narrow. `README.md`, `AGENT.md`, `AGENTS.md` as a compatibility symlink, optional `CLAUDE.md`, and optional public `CHANGELOG.md` may stay at the root. Bug dossiers, bug triage, QA logs, specs, research, reviews, audits, verification reports, conversations, explorations, and operator guides belong under their canonical `shipglows_data/` families.

- Useful inactive history belongs under `shipglows_data/workflow/archives/` and is never active doctrine. Root `archive/`, `bugs/`, `docs/`, `specs/`, and `research/` are migration sources.

- Legacy root files such as `BUSINESS.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `GUIDELINES.md`, `TASKS.md`, or `AUDIT_LOG.md` are migration sources only. They are not compliant final locations once the project adopts the `shipglows_data/` corpus.

- Internal contracts remain in English by default (`SKILL.md`, metadata schema fields, stable headings, checks, and acceptance criteria). User-facing interaction (status updates, prompts, final responses, help copy) follows the operator’s active language.

- `Documentation Update Plan` applies to any behavior-changing wave that modifies behavior or documented contracts. The plan must:
  - identify impacted docs with owners from `shipglows_data/technical/code-docs-map.md`,
  - update the owning artifact before final verification,
  - keep doc roles exclusive (architecture, technical module, workflow, editorial).

- Non-compliance triggers are:
  - touching architecture/technical doctrine without updating owning doctrine files,
  - adding claims that affect trust/safety/legal/security/business outcomes without claim-register evidence,
  - mixing internal English contracts with user-facing French in the same artifact.

## Hotspots

- `lib.sh::env_start`
- `lib.sh::show_dashboard`
- `lib.sh::deploy_github_project`
- `lib.sh::action_publish`
- `local/local.sh::main`

## Known Constraints

- The centralization of logic in `lib.sh` speeds iteration but increases blast radius.
- The architecture depends on shell scripting, so structural clarity depends heavily on docs and function indexing.
- Context and decision artifacts are necessary because the codebase mixes runtime orchestration and workflow doctrine in one repo.
