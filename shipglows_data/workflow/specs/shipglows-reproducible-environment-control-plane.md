---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-08-16"
created_at: "2026-08-16 16:48:28 UTC"
updated: "2026-08-16"
updated_at: "2026-08-16 19:36:46 UTC"
status: active
source_skill: sg-spec
source_model: GPT-5 Codex
scope: cross-platform reproducible development environment control plane
owner: Diane
user_story: "En tant que fondatrice utilisant des agents sur plusieurs stacks et plateformes, je veux déclarer les capacités de développement attendues puis laisser ShipGlows choisir, orchestrer et vérifier les moteurs adaptés, afin de reconstruire un environnement sans dupliquer les gestionnaires de paquets ni confondre installation et disponibilité réelle."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/lib.sh
  - cli/install.sh
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.MobileToolchain.psm1
  - cli/windows/ShipGlows.DevServer.psm1
  - install-shipglows.sh
  - install-shipglows.ps1
  - shipglows_data/technical/architecture.md
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/installer-and-user-scope.md
  - shipglows_data/technical/operator-guides/windows-devserver.md
  - .shipglows.env
depends_on:
  - artifact: shipglows_data/business/product.md
    artifact_version: "1.4.0"
    required_status: reviewed
  - artifact: shipglows_data/technical/architecture.md
    artifact_version: "1.12.1"
    required_status: reviewed
  - artifact: shipglows_data/technical/runtime-cli.md
    artifact_version: "1.12.0"
    required_status: reviewed
  - artifact: shipglows_data/technical/guidelines.md
    artifact_version: "1.7.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Current Unix runtime provisions and launches project tools through Flox, while the native Windows installer implements Flutter, JDK, Android, Playwright, agent CLI and MCP convergence directly in PowerShell."
  - "Repository search on 2026-08-16 found no mise, WinGet Configuration or Dev Container backend integration and no shared desired/resolved/observed environment contract."
  - "Official Nix documentation distinguishes declarative isolated inputs from complete bit-for-bit reproducibility: https://reproducible.nixos.org/"
  - "Official Flox documentation defines versioned manifest and lock files for macOS, Linux and WSL 2 rather than native Windows: https://flox.dev/docs/concepts/environments and https://flox.dev/docs/install-flox/install"
  - "Official mise documentation defines project tools, environment, tasks and optional exact-version/checksum lockfiles including Windows platform entries: https://mise.jdx.dev/walkthrough.html and https://mise.jdx.dev/dev-tools/mise-lock.html"
  - "Microsoft documents WinGet Configuration as desired-state setup with validate, test and configure operations: https://learn.microsoft.com/windows/package-manager/winget/configure"
  - "The Development Container Specification defines portable metadata for containerized development environments without replacing the host: https://containers.dev/overview"
  - "Operator decision 2026-08-16: ShipGlows should orchestrate proven platform engines instead of rebuilding their package-management and lockfile responsibilities."
  - "Tasks 1-3 foundation proof: strict schema/state/plan/executor contracts plus Bash, PowerShell and the complete Windows contract suite passed without an active backend."
  - "Independent sg-verify proof hardened untrusted capability handling, bounded reads and probes, private atomic state, stale locks, attestation privacy, semantic corruption handling, no-bytecode inspect, and unconditional no-backend apply refusal."
  - "Task 5 regression-first proof introduced a missing-module failure before the Windows mise backend, structured runner, semantic apply grammar and isolated PowerShell fixture were implemented."
  - "Official mise installation docs retain `winget install jdx.mise` as a supported Windows route: https://mise.jdx.dev/installing-mise.html#windows-winget"
  - "Official mise exec docs define `--` as the command argv separator and avoid shell-session mutation: https://mise.jdx.dev/cli/exec.html"
  - "Official lockfile docs define exact versions, platform URLs/checksums where supported, strict locked mode and core backend integrity limits: https://mise.jdx.dev/dev-tools/mise-lock.html"
  - "Official safe/offline/cache docs define MISE_SAFE, MISE_OFFLINE, prefer-offline behavior and installed directories rather than downloads as the supported offline retention boundary: https://mise.jdx.dev/continuous-integration.html#running-against-untrusted-config-safe-mode and https://mise.jdx.dev/configuration/settings.html#offline and https://mise.jdx.dev/directories.html"
  - "Official mise configuration docs define inherited global/system configuration, local variants and MISE_OVERRIDE_CONFIG_FILENAMES; the pilot strips inherited MISE controls, selects only mise.toml and rejects alternate repository configuration: https://mise.jdx.dev/configuration.html"
  - "Official mise demo documents direct project-local Node plus pnpm ownership through `[tools] node` and `pnpm`, avoiding a Corepack hook surface: https://mise.jdx.dev/demo"
  - "Independent Task 5 verification reproduced arbitrary external PATH executable trust, executable drift, inherited environment leakage and incomplete mise cascade isolation before bounded hardening; all source contracts and the complete Windows suite then passed without live provider execution."
next_step: "Keep native Windows provider readiness and installed-runtime packaging open until separately approved real evidence exists"
---

# Spec: ShipGlows Reproducible Environment Control Plane

🟠 [ShipGlows] spec: ShipGlows Reproducible Environment Control Plane | status: active | path: shipglows_data/workflow/specs/shipglows-reproducible-environment-control-plane.md | next: approve real provider and installed-runtime proof separately

## Title

ShipGlows Reproducible Environment Control Plane

## Status

Active. Tasks 1-3 and the Task 5 source/injected-fixture pilot are independently verified at standard depth; real WinGet/mise/Node provider smoke, installed Windows runtime packaging, other adapters and legacy-code migration remain outside this execution.

## User Story

En tant que fondatrice utilisant des agents de développement sur Windows, Unix et plusieurs stacks, je veux décrire les capacités nécessaires à un projet puis laisser ShipGlows sélectionner les moteurs adaptés et vérifier le résultat réel, afin qu'un humain ou un agent puisse reconstruire et comprendre son environnement sans réécrire Nix, Flox, mise, WinGet Configuration ou Dev Containers.

## Minimal Behavior Contract

Quand un projet contient un manifeste ShipGlows valide ou des manifestes natifs reconnus, `shipglows env plan` construit sans mutation un état désiré normalisé, résout chaque capacité vers un backend compatible et affiche les actions, consentements, coûts et limites. Après confirmation explicite, `shipglows env apply` exécute uniquement le plan approuvé à travers les backends propriétaires, puis `shipglows env verify` observe les binaires, versions, chemins, services, appareils et capacités d'agent pour produire une attestation expurgée. Un manifeste invalide, un backend absent, une source non fiable, une licence refusée, une authentification manquante ou une observation contradictoire laisse la capacité `pending`, `blocked` ou `degraded` sans faux succès ni remplacement silencieux de la configuration existante. Le cas facile à manquer est un outil présent dans le terminal de l'utilisateur mais absent du processus de l'agent qui doit l'appeler. Le fichier `.shipglows.env` existant reste propriétaire des politiques opérationnelles du runtime comme l'auto-réparation; il n'est ni remplacé ni dupliqué dans le manifeste de capacités.

## Success Behavior

- Preconditions: projet local résolu, manifeste optionnel validé, manifestes natifs traités comme données non fiables jusqu'à validation, plateforme et architecture détectées, aucune opération privilégiée encore commencée.
- Trigger: l'opérateur ou un agent autorisé lance `shipglows env inspect`, `plan`, `apply`, `verify` ou `status` depuis le projet.
- User/operator result: une vue unique explique les capacités demandées, le backend retenu, les actions automatiques, les confirmations nécessaires, les preuves observées et la prochaine action de chaque capacité.
- System effect: le plan et l'observation machine lisibles par programme sont écrits dans l'état utilisateur ShipGlows; le résumé sans secret est reflété dans l'`ENVIRONMENT.md` géré du projet; les manifestes et lockfiles natifs ne changent que lorsque le backend et le plan approuvé en sont explicitement propriétaires.
- Success proof: schéma validé, plan déterministe à entrées identiques, tests d'adaptateurs, application jetable, seconde application sans changement, diagnostics depuis un shell utilisateur et un processus agent, attestation sans secret et diff borné des fichiers propriétaires.
- Silent success: interdit; chaque capacité termine avec un état, une preuve, un horodatage et une source, ou une raison explicite empêchant `ready`.

## Error Behavior

- Expected failures: manifeste absent ou invalide, référence native absente, backend non installé, version non résoluble, somme de contrôle manquante, réseau indisponible, archive dangereuse, privilège insuffisant, licence ou configuration refusée, authentification absente, timeout, installation partielle, drift, outil visible dans un shell mais pas dans l'agent, matériel ou virtualisation indisponible, backend concurrent propriétaire de la même capacité.
- User/operator response: diagnostic localisé par capacité, mutation réalisée ou non, éléments préservés, commande ou action humaine suivante et différence entre état désiré, résolu et observé.
- System effect: aucun autre backend n'est essayé silencieusement après l'échec d'un backend approuvé; les écritures temporaires sont nettoyées; un état partiel reste récupérable et le prochain plan part de l'observation réelle.
- Must never happen: accepter une licence, démarrer une authentification, modifier une permission, écraser une configuration utilisateur, exécuter un manifeste non validé, enregistrer un secret, déclarer `ready` à partir de la seule présence d'un fichier ou appliquer un plan différent de celui approuvé.
- Silent failure: interdit; un code non nul, timeout, sortie contradictoire ou preuve périmée produit un état non-ready et une explication expurgée.

## Problem

ShipGlows possède aujourd'hui deux architectures d'environnement divergentes. Unix s'appuie sur Flox pour les outils et PM2/Caddy pour l'exécution. Windows détecte, télécharge, installe et diagnostique directement de nombreuses dépendances dans un installateur PowerShell. Cette implémentation a révélé les vrais besoins — PATH, SDK mobiles, navigateurs versionnés, agents, MCP, licences, IDE et matériel — mais elle duplique aussi des responsabilités déjà mieux couvertes par des gestionnaires de versions, des moteurs de desired state et des standards de conteneurs.

Il n'existe pas de contrat commun permettant de distinguer ce qu'un projet demande, ce que ShipGlows a résolu et ce qui fonctionne réellement. Un outil peut donc être installé mais invisible pour l'agent, un émulateur présent mais inutilisable, ou une configuration appliquée sans preuve de capacité.

## Solution

Créer un plan de contrôle ShipGlows à quatre responsabilités seulement: normaliser l'intention du projet, résoudre chaque capacité vers le meilleur backend disponible, orchestrer les consentements et les frontières de propriété, puis observer et attester le résultat. Les moteurs existants conservent leurs formats, lockfiles, caches et mécanismes d'installation. ShipGlows ajoute un manifeste mince de capacités et de références, pas un nouveau catalogue de paquets.

## Architecture Decision

### Decision

ShipGlows adopte un **thin control plane** plutôt qu'un gestionnaire de paquets universel.

- `shipglows.environment.json` exprime les capacités attendues et référence les manifestes natifs.
- Une représentation intermédiaire normalisée existe en mémoire et dans l'état utilisateur, mais n'est pas une seconde source de vérité versionnée.
- Flox, mise, WinGet Configuration et Dev Containers conservent leurs manifestes et lockfiles.
- Les installations spécialisées non couvertes par un backend restent des adaptateurs ShipGlows bornés, observables et remplaçables.
- La capacité `ready` vient de l'observation, jamais du succès déclaré par l'installation seule.

### Why

- Réutilise les catalogues, lockfiles, vérifications d'intégrité et écosystèmes existants.
- Préserve les forces distinctes de chaque plateforme sans réduire le contrat au plus petit dénominateur commun.
- Permet une migration progressive du PowerShell existant plutôt qu'une réécriture totale.
- Donne aux agents un langage stable pour comprendre les capacités et leurs preuves.
- Maintient l'environnement comme capacité d'exécution subordonnée à la promesse principale de ShipGlows: mieux décider, exécuter et prouver.

### Rejected alternatives

- **Un gestionnaire ShipGlows de paquets et versions:** rejeté car il duplique Nix/Flox/mise et crée une charge de supply chain disproportionnée.
- **Un backend unique sur toutes les plateformes:** rejeté car Flox n'est pas natif Windows et les conteneurs ne possèdent pas le matériel ou les workloads de l'hôte.
- **Continuer avec deux installateurs impératifs sans contrat commun:** rejeté car la dérive, les diagnostics et les capacités agents resteraient incohérents.
- **Tout placer dans Dev Containers:** rejeté pour les outils GUI/hôte, Android, USB, virtualisation et builds Windows natifs.

## Manifest Contract

### Canonical project file

`shipglows.environment.json` vit à la racine de gouvernance du projet et peut être versionné. Il contient uniquement de l'intention portable, des contraintes et des références explicites. Il ne contient ni secret, token, consentement, état observé, chemin personnel absolu, URL privée credentialée ou copie d'un lockfile natif. Le format JSON est retenu pour permettre un parseur strict identique avec la bibliothèque standard Python, sans moteur de templates, tags YAML ou dépendance de parsing supplémentaire.

### Version 1 shape

```json
{
  "schema": "shipglows.environment/v1",
  "project": {"id": "example", "name": "Example"},
  "capabilities": {
    "tools": [
      { "id": "node", "constraint": "24" },
      { "id": "pnpm", "constraint": "10" },
      { "id": "python", "constraint": ">=3.13,<3.15" }
    ],
    "targets": [
      {"id": "flutter-web"},
      {"id": "android", "platforms": ["windows", "unix"]},
      {"id": "windows-desktop", "platforms": ["windows"]}
    ],
    "agents": [{"id": "codex"}, {"id": "claude"}],
    "integrations": [{"id": "playwright"}, {"id": "github"}]
  },
  "backends": {
    "unix": { "flox": ".flox/env/manifest.toml" },
    "windows": {
      "mise": "mise.toml",
      "winget_configuration": ".config/shipglows/windows.dsc.yaml"
    },
    "container": { "devcontainer": ".devcontainer/devcontainer.json" }
  },
  "policies": {
    "native_host_required": true,
    "consent": "explicit",
    "secrets": "redact"
  }
}
```

### Schema rules

- `schema` is mandatory and rejects unknown major versions.
- Capability IDs use a registry owned by ShipGlows; unknown IDs fail closed but remain visible in diagnostics.
- Version constraints express intent; exact resolved versions remain in native lockfiles or the resolution state.
- Backend paths are project-relative, normalized, cannot escape the project root and cannot cross a reparse point or symlink outside it.
- Unknown fields are rejected in v1 unless placed under a namespaced `extensions` object.
- Platform-specific intent may refine a capability but may not silently remove a portable security or consent policy.
- The manifest references secrets by provider/key name only; it never stores or resolves secret values during `inspect` or `plan`.

## State Model

### Desired

Normalized intent obtained from the ShipGlows manifest, explicit native references and bounded project detection. Each fact retains source path, source digest, precedence and whether it was explicit or inferred.

### Resolved

Concrete plan for the current platform: backend, exact operation, target version or native lock entry, privilege level, network requirement, estimated download class, consent requirement, ownership, rollback/cleanup behavior and verification probe. The plan has a stable digest; `apply` refuses if inputs changed after approval.

### Observed

Read-only evidence from the actual consumer surface: executable and version, resolved path, environment source, service health, SDK diagnostic, device/AVD state, MCP callability, authentication status without identity secrets, relevant timestamps and probe result.

### Capability statuses

- `ready`: current evidence proves the requested capability for the named consumer.
- `pending`: a safe automatic step or explicit human action remains.
- `blocked`: no authorized or supported path can currently satisfy the capability.
- `degraded`: a fallback works but does not satisfy the full desired contract.
- `drifted`: observed state no longer matches the resolved plan or evidence expired.
- `not_applicable`: the capability is intentionally irrelevant on this platform, with reason.
- `unknown`: observation could not establish a trustworthy state; never treated as ready.

## Ownership And Precedence

1. Explicit `shipglows.environment.json` capability intent.
2. Explicit references to native manifests.
3. Native lockfiles as version and integrity authority for their backend.
4. Existing `.shipglows.env` operational runtime policy, only for its closed allowlisted keys; it cannot declare tools, backends, versions or credentials.
5. Bounded detection of project manifests as suggestions requiring plan visibility.
6. Existing valid external tool installations as observed candidates, never automatically taken over.

ShipGlows must not rewrite a user-owned native manifest merely to match detection. A generated or ShipGlows-owned native file is clearly marked, written atomically and changed only by its adapter. Conflicting owners for one capability block planning until one owner wins by explicit policy.

## Backend Responsibilities

| Backend | Owns | Does not own | Initial migration role |
| --- | --- | --- | --- |
| Flox | Unix project packages, variables, activation and services declared in `.flox` | native Windows host, GUI workloads, accounts, consent | preserve existing Linux behavior behind the adapter interface |
| mise | project CLI/runtime versions, environment variables, tasks and optional lockfile | Windows applications, drivers, IDE workloads, device state | first replacement target for generic Windows runtime downloads |
| WinGet Configuration | trusted Windows packages and desired machine settings expressible through reviewed resources | project lockfiles, secrets, agent callability, hardware proof | converge Git, IDEs and machine prerequisites after explicit trust review |
| Dev Containers | containerized tools, features, ports and editor metadata | host USB, acceleration, GUI ownership, Windows-native build toolchain | opt-in backend for projects whose declared targets fit the boundary |
| ShipGlows native adapter | orchestration gaps with no suitable backend, consent sequencing and verification | general package catalog or duplicate lockfile | temporarily retain Android/Flutter/Playwright/agent logic, then shrink |

## Backend Bootstrap Contract

- The Python control-plane core and read-only `inspect` remain usable when no optional backend is installed.
- Backend CLI availability is itself an observed capability with owner, version, path and installation policy.
- A missing backend produces a visible plan operation; it never triggers an installer during `inspect` or silently during `verify`.
- Windows installs mise only after an explicit plan through the official `jdx.mise` WinGet package documented by mise; the implementation refreshes the package identity and trust evidence before use.
- The Windows pilot invokes `mise exec` with structured arguments rather than requiring a PowerShell profile or global activation. Shims may be observed, but profile mutation is outside the pilot.
- Unix preserves Flox installation under the current server/bootstrap owner until a later migration proves a safer backend-bootstrap abstraction.
- WinGet Configuration and Dev Container providers are observed as existing machine capabilities; installing/enabling their host prerequisites is a separate explicit plan effect.
- Backend versions may have minimum constraints for features, but ShipGlows does not freeze a backend indefinitely when its official support model recommends compatible current releases. The resolved plan records the exact executable version used.

## Command And UX Contract

- `shipglows env inspect`: read sources and observation without network or mutation.
- `shipglows env plan`: resolve a deterministic plan; network metadata reads are allowed only through pinned/official authorities and are reported.
- `shipglows env apply`: require an exact non-stale plan digest and explicit approval for mutation; group separate legal, authentication, privilege and high-download confirmations.
- `shipglows env verify`: probe each declared consumer and refresh observed state without installing or authenticating.
- `shipglows env status`: render the last desired/resolved/observed comparison and mark stale evidence.
- `s env ...` may expose the same commands after collision review; no shell-profile dependency is required.

Interactive menus project the same plan and state model. Non-interactive mode never infers consent, license acceptance, authentication, elevation or fallback ownership.

## Persistence Contract

- Project source: `<project-root>/shipglows.environment.json`, `.shipglows.env` for its non-overlapping legacy runtime-policy keys, and referenced native manifests.
- Private machine state: `%LOCALAPPDATA%/ShipGlows/Environment/` on Windows and `${XDG_STATE_HOME:-~/.local/state}/shipglows/environment/` on Unix.
- State keys: canonical project identity plus platform and architecture; paths are normalized and compared case-insensitively on Windows.
- Stored records: source digests, plan digest, backend versions, timestamps, statuses and redacted probe summaries.
- Human attestation: project `ENVIRONMENT.md`, generated from observed state and safe next actions; it contains no credentials, private callback URLs, tokens, raw provider output or full environment-variable dumps.
- Writes are atomic, bounded and lock-protected. Corruption preserves the bad file for diagnosis, fails closed and allows reconstruction from source plus fresh observation.
- State is cache and evidence, not project intent. Deleting it loses observation history but does not alter native manifests or installed tools.

## Consent, Authentication And Secrets

- Package installation consent never implies acceptance of third-party licenses.
- ShipGlows may launch an official interactive license or authentication flow only after telling the operator which provider and capability require it.
- ShipGlows never pre-answers license prompts, authenticates as the user, captures passwords/tokens or marks auth ready from CLI presence.
- Auth state records only provider, consumer, status, evidence timestamp and safe account hint when the provider exposes one intentionally.
- Secret references name an external owner or environment key; values remain with the provider, OS credential store or user-selected secret manager.
- MCP configuration is treated as environment state, but configs with unknown schemas, JSONC, secrets or foreign ownership are preserved and become `pending` unless a proven native CLI can converge them safely.

## Scope In

- Thin environment manifest and schema.
- Desired/resolved/observed state model and capability vocabulary.
- Backend adapter contract for Flox, mise, WinGet Configuration, Dev Containers and bounded native adapters.
- Plan digest, approval, apply, verify, status and redacted attestation contracts.
- Project/machine/user/agent ownership and precedence.
- Windows, Unix, Flutter/Android, Windows desktop, Playwright, MCP and coding-agent scenarios.
- Migration phases, compatibility strategy, rollback and deletion criteria for redundant installer code.
- Automated contract, adapter, security and integration proof.

## Scope Out

- Implementing the complete control plane in one change.
- Building a ShipGlows package registry, resolver, binary cache or lockfile format.
- Replacing native manifests with generated ShipGlows copies.
- Supporting every package manager, IDE, cloud workstation or container service in v1.
- Automatic authentication, license acceptance, billing, account/project selection or secret migration.
- Guaranteed bit-for-bit builds, identical operating systems, universal portability or fully hermetic environments.
- Making Flox native on Windows or forcing WSL/containers onto projects requiring the native host.
- Changing the primary business positioning of ShipGlows; environment operations remain an execution capability.

## Constraints

- Existing Flox projects and current Windows installations must continue to work during migration.
- Each phase is independently releasable and reversible; the legacy path remains until parity proof for its owned capability passes.
- Backend outputs and manifests are untrusted input until schema, path, provenance and command boundaries are validated.
- Optional backend acquisition is an explicit plan operation with official authority, privilege and rollback metadata; no backend self-installs while resolving another capability.
- No adapter constructs shell command strings from manifest values. Use structured arguments and bounded processes with timeouts.
- Native files and user config are preserved by default; adoption of ownership is explicit and recoverable.
- Plan creation is read-only. Apply never recomputes a materially different plan after approval.
- A backend may satisfy one capability while another backend satisfies another; one capability has one active owner per platform.
- Current official documentation is rechecked during each backend implementation and migration.

## Dependencies

- Runtime: Python 3 standard library owns strict JSON parsing, normalization, hashing, redaction and state serialization; thin PowerShell 5.1+ and Bash entrypoint adapters own native process/environment integration; backend CLIs are required only when selected.
- Document contracts: product context 1.4.0, architecture 1.10.0, runtime CLI current draft and installer/user-scope current reviewed contract.
- External authorities: official Nix, Flox, mise, Microsoft WinGet/DSC and Development Container Specification documentation.
- Metadata gaps: `runtime-cli.md` and some installer docs may change before implementation; readiness must record their exact versions and implementation must refresh them before editing.

## Invariants

- ShipGlows orchestrates; native backends retain package, lockfile and execution semantics.
- Desired intent, resolved plan and observed evidence remain distinguishable in storage, API and UI.
- `ready` always names the consumer and requires a successful current probe.
- No secret, credential, raw token, private URL or full environment dump enters manifests, plans, attestations, logs or diagnostics.
- No license, authentication, elevation, billing or provider-project choice is inferred.
- A stale plan cannot be applied; a changed source digest requires a new plan and approval.
- Existing valid external installations remain externally owned unless the operator explicitly adopts a managed path.
- Project paths never escape the resolved project root; machine-state paths never escape the canonical ShipGlows state root.
- `.shipglows.env` remains the closed-schema authority for existing runtime policies and cannot redefine a capability, backend, version or secret handled by the environment manifest.
- Unsupported platform/capability pairs fail visibly; they never fall back to a semantically different target.
- Legacy installers are removed only after replacement parity, rollback and fresh-host proof exist for their capabilities.

## Links & Consequences

- Upstream systems: project manifests, `.flox`, `mise.toml`, lockfiles, WinGet Configuration documents, `.devcontainer`, current installers, agent configuration and provider CLIs.
- Downstream systems: Windows DevServer menus, Linux runtime lifecycle, generated environment docs, agent instructions, install reports, project discovery, support documentation and future public explanation.
- Cross-cutting checks: path and command injection, supply-chain provenance, secrets, consent, auth, Windows execution policy, reparse points, cross-platform parity, timeout/cancellation, cache invalidation and public claim boundaries.
- Product consequence: a fresh agent can distinguish missing setup from unavailable tooling without requiring the operator to rediscover the machine state.
- Maintenance consequence: custom installation code must shrink as adapter parity is proven; the control plane fails the structure-replacement gate if it merely adds another layer without removing duplication.

## Documentation Coherence

- Update `shipglows_data/technical/architecture.md` when the control plane foundation lands.
- Update `shipglows_data/technical/runtime-cli.md` for commands, persistence and Linux/Windows adapter behavior.
- Update `shipglows_data/technical/installer-and-user-scope.md` and the Windows operator guide as ownership migrates.
- Update `README.md`, public install pages and claim register only after a capability is implemented and proven; the spec and editorial draft must not become shipped-product claims.
- Update `AGENTS.md`/environment guidance only when the attestation path and consumer contract are implemented.
- Add an architecture decision record when the manifest schema and first backend graduate from experimental to supported.

## Edge Cases

- No ShipGlows manifest but one valid native manifest.
- Existing `.shipglows.env` with valid runtime keys, unknown keys, or an attempted capability/version declaration.
- Empty manifest, unknown schema, unknown capability or duplicate capability IDs.
- Nested monorepo with parent and child manifests and different backend ownership.
- Windows path case differences, spaces, Unicode, junctions and reparse-point escape.
- Flox manifest present on Windows native but only WSL is available.
- mise installed but the requested tool backend lacks a Windows artifact or checksum.
- WinGet Configuration requires elevation, restart, Store access or an unavailable DSC resource.
- Dev Container manifest exists but Docker/provider is absent or the target requires host Android/Windows capabilities.
- Existing external JDK/Flutter/SDK is valid while persistent environment variables point elsewhere.
- Tool version is correct in an interactive shell but wrong or absent in the agent process.
- Playwright package and Chromium cache revisions diverge.
- Android SDK and AVD exist but acceleration is unavailable; real or hosted devices remain alternatives, not equivalent silent fallbacks.
- License accepted after an earlier refusal, authentication expires, or MCP schema changes between plan and verify.
- Concurrent `plan`, `apply` and `verify` processes for the same project.
- Network disappears after metadata resolution but before download.
- Apply is interrupted after one backend succeeds and before another begins.
- State file is truncated, evidence is stale, clock moves backwards or backend output uses an unexpected locale/encoding.

## ZOMBIES Coverage

- Z — zero manifest/native sources yields an explicit unmanaged observation, never an empty ready state.
- O — one tool capability through one backend proves the smallest complete inspect-plan-apply-verify cycle.
- M — many capabilities/backends test ordering, ownership conflicts, partial success, parallel observation and deterministic plans.
- B — schema versions, path roots, timeout/download limits, evidence age and platform boundaries are tested below/at/above limits.
- I — manifest/backend, backend/process, process/agent, human/consent and state/attestation interfaces have named inputs, outputs and owners.
- E — invalid input, denial, timeout, stale plan, corruption, restart requirement, partial install and recovery fail closed.
- S — the first implementation slice supports one generic tool on Windows through mise plus read-only observation; broader adapters follow only after this cycle is proven.

## Implementation Tasks

- [x] Task 1: Freeze the environment domain model and schemas.
  - File: `cli/environment/schemas/shipglows-environment-v1.schema.json`, `cli/environment/*.py`, `tests/environment/schema-contract.py`.
  - Action: Define manifest, normalized desired state, resolved plan, observed evidence, capability statuses, plan digest and redaction schema in Python standard-library modules without executing a backend; ingest `.shipglows.env` only through its existing allowlist and reject overlap.
  - User story link: gives all platforms and agents one unambiguous vocabulary.
  - Depends on: none.
  - Validate with: `python tests/environment/schema-contract.py` and `python tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/shipglows-reproducible-environment-control-plane.md`.
  - Notes: JSON decoding uses only Python's standard library; reject duplicate JSON keys, non-finite numbers, unknown fields and unsupported schema majors.

- [x] Task 2: Implement read-only discovery, normalization and state persistence.
  - File: new environment core module, Windows/Unix entrypoint adapters, disposable state fixtures.
  - Action: Resolve project identity, read explicit and native sources, apply precedence, generate desired state, store atomic redacted records and render the future `ENVIRONMENT.md` attestation block inside private state without mutating tools or the project file.
  - User story link: agents can understand current intent and observation before installation.
  - Depends on: Task 1.
  - Validate with: `python tests/environment/state-contract.py`, `powershell.exe -NoProfile -File tests/windows/environment-observation.ps1` and `bash tests/runtime/environment-observation.sh`.
  - Notes: no network in inspect; bounded traversal only.

- [x] Task 3: Add deterministic planning and approval-bound apply orchestration.
  - File: environment planner/executor modules and CLI/menu integration.
  - Action: Build per-capability operations, digest all plan inputs, classify consent/privilege/network/download effects and refuse stale plans; the foundation keeps `apply` fail-closed until a later task adds a separately verified executable adapter, cleanup and resumable observation.
  - User story link: makes environment changes reviewable and prevents hidden mutations.
  - Depends on: Tasks 1-2.
  - Validate with: `python tests/environment/plan-contract.py` and `python tests/environment/executor-contract.py`.
  - Notes: apply uses structured process invocation and never evaluates manifest strings.

- [ ] Task 4: Wrap existing Flox behavior behind the backend contract.
  - File: `cli/lib.sh`, Flox adapter and existing runtime tests.
  - Action: Preserve current environment-root/launch-path semantics, discovery and activation while exposing plan/apply/verify operations and observed evidence.
  - User story link: Unix gains the shared control plane without losing its proven runtime.
  - Depends on: Tasks 1-3.
  - Validate with: `bash tests/runtime/flox-provisioning.sh && bash tests/runtime/environment-flox-adapter.sh`.
  - Notes: do not rewrite Flox manifests or lockfiles outside Flox commands.

- [x] Task 5: Pilot mise with project-local Node 24 and pnpm 10 on Windows.
  - File: mise adapter, Windows installer/DevServer integration and isolated fixtures.
  - Action: Detect mise or propose the official `jdx.mise` WinGet package as a separate approved operation, then resolve and install project-local Node 24 and pnpm 10 through `mise.toml`/`mise.lock`; invoke both tools through `mise exec`, reconcile an existing `package.json#packageManager` with the exact pnpm lock, observe both tools from PowerShell and an agent-like child process, preserve external installations, and leave the global Node/pnpm used by ShipGlows and agent CLIs under their current owners.
  - User story link: proves delegation can replace custom runtime installation without weakening PATH diagnostics.
  - Depends on: Tasks 1-3.
  - Validate with: `powershell.exe -NoProfile -File tests/windows/environment-mise-adapter.ps1` covering clean/partial/external/conflicting PATH hosts, exact lock, checksum/provenance when available, offline cache, rerun and rollback.
  - Notes: the pilot proves project-local tool ownership only; it must not replace or remove machine-global Node/pnpm paths required by installers or agent CLIs, run `pnpm install`, edit a PowerShell profile, or rely on implicit shell activation.
  - Result: implemented in the source control plane with a structured injectable runner, exact code-free Node/pnpm config and lock grammar, optional exact `packageManager` reconciliation, isolated inherited configuration, rejection of repository-resolved executables, distinct acquisition/replan boundary, fixed per-tool install argv, PowerShell and agent-child `mise exec` evidence, offline installed-cache semantics and fail-closed recovery. Automated proof used fakes only; no provider/platform readiness claim is made from those fixtures.

- [ ] Task 6: Add a trusted WinGet Configuration machine adapter.
  - File: WinGet adapter, generated/referenced configuration validation and Windows fixtures.
  - Action: Support show/validate/test/plan before configure, enforce trust review, separate elevation/restart and preserve user-owned configurations.
  - User story link: moves machine setup out of custom PowerShell while keeping consent visible.
  - Depends on: Tasks 1-3 and Task 5 proof.
  - Validate with: `powershell.exe -NoProfile -File tests/windows/environment-winget-configuration-adapter.ps1` with official resource fixtures, untrusted path, changed digest, elevation denial, restart pending, unavailable resource and second-run convergence.
  - Notes: never run a repository-provided configuration merely because it exists.

- [ ] Task 7: Add opt-in Dev Container observation and execution.
  - File: Dev Container adapter and representative project fixtures.
  - Action: Validate referenced `devcontainer.json`, expose supported features/requirements and refuse host-native capabilities that the container cannot own.
  - User story link: reuses the open standard where isolation fits without hiding host gaps.
  - Depends on: Tasks 1-3.
  - Validate with: `python tests/environment/devcontainer-adapter-contract.py` plus one disposable container-ready web-project smoke when a provider is available.
  - Notes: no implicit Docker/provider installation in this task.

- [ ] Task 8: Migrate specialized Windows capabilities behind adapters.
  - File: `cli/windows/ShipGlows.MobileToolchain.psm1`, `install-devserver.ps1`, MCP/Playwright modules and environment adapters.
  - Action: Convert Flutter, Android, Visual Studio, Playwright, MCP and agent readiness to desired/resolved/observed capabilities while retaining bounded native installers only where no backend is suitable.
  - User story link: turns current Windows proof into shared, truthful capability state.
  - Depends on: Tasks 1-6.
  - Validate with: `powershell.exe -NoProfile -File tests/windows/mobile-toolchain.ps1`, `powershell.exe -NoProfile -File tests/windows/codex-playwright-mcp.ps1` and `bash tests/windows/devserver-contract.sh`, extended with fresh, existing, partial, corrupt, license-refused, auth-pending, no-acceleration and agent-PATH scenarios.
  - Notes: no capability loses current recovery behavior during migration.

- [ ] Task 9: Remove redundant installation paths after parity proof.
  - File: legacy installer functions, docs, tests and compatibility shims identified by ownership inventory.
  - Action: Delete only code whose replacement has fresh-host, existing-host, rollback and second-run proof; keep compatibility diagnostics for one documented transition window.
  - User story link: ensures the control plane reduces maintenance rather than adding another layer.
  - Depends on: Tasks 4-8 and independent parity verification.
  - Validate with: dead-path/static contract, full platform suites, installer smoke matrix, documentation search and diff review.
  - Notes: removal is a separate destructive approval scope when exact targets are known.

- [ ] Task 10: Align technical and public documentation after supported behavior ships.
  - File: architecture, runtime CLI, installer guides, README, public install pages and claim register.
  - Action: Document implemented commands, ownership and limits; keep experimental or unsupported backends out of public availability claims.
  - User story link: users and agents receive accurate setup and recovery guidance.
  - Depends on: each corresponding implemented and verified slice.
  - Validate with: metadata lint, link/claim scan, site build and public route observation when published.
  - Notes: documentation follows verified slices rather than announcing the complete future architecture.

## Acceptance Criteria

- [ ] AC 1: Given a valid v1 JSON manifest, when inspect runs, then desired capabilities retain source, precedence and platform applicability without network or mutation.
- [ ] AC 2: Given an unknown schema, parsing stops; given an unknown capability ID, inspection and planning retain an explicit `unknown` diagnostic and no backend or repository-named executable is invoked.
- [ ] AC 3: Given a backend reference path, when it escapes the project root directly, through `..`, symlink or Windows reparse point, then it is rejected before reading or execution.
- [ ] AC 4: Given identical trusted inputs and platform facts, when plan runs twice, then operation order, ownership and digest are identical.
- [ ] AC 5: Given any source, lock, backend version or platform fact changes after approval, when apply starts, then the stale digest is rejected and no operation runs.
- [ ] AC 6: Given non-interactive execution, when a license, auth, elevation, restart, destructive adoption or material fallback is required, then the capability remains pending without inferred consent.
- [ ] AC 7: Given one backend operation fails, when later operations depend on it, then they do not run; independent completed capabilities remain observed and the recovery plan is explicit.
- [ ] AC 8: Given an existing valid external tool, when it satisfies the desired constraint, then ShipGlows reuses it as externally owned and does not persistently replace its environment variables or PATH.
- [ ] AC 9: Given a tool is visible to the user shell but absent or different in an agent child process, when verify runs, then user readiness and agent readiness differ rather than collapsing to ready.
- [ ] AC 10: Given a Flox project with nested environment roots, when normalized, then current environment-root/launch-path ownership and ambiguity safeguards remain unchanged.
- [ ] AC 11: Given mise owns a Windows tool, when apply succeeds and verify runs, then its lock/resolution authority remains mise and ShipGlows records only references and observed proof.
- [ ] AC 12: Given a WinGet Configuration document, when trust or digest review is missing, then configure cannot run even if validate/test would succeed.
- [ ] AC 13: Given a Dev Container project requiring an Android emulator or Windows desktop build, when the host capability is absent, then the container is not presented as satisfying it.
- [ ] AC 14: Given Android SDK, image and AVD exist without acceleration, when verify runs, then emulator capability is degraded or blocked while real/hosted device alternatives remain explicit.
- [ ] AC 15: Given Playwright package and Chromium revisions differ, when verify runs, then motion/browser readiness is non-ready even if both executables exist.
- [ ] AC 16: Given a license refusal or expired authentication, when verify runs, then no secret or raw provider output is stored and the exact human next action is visible.
- [ ] AC 17: Given JSON, JSONC or agent configuration has unknown ownership or secrets, when convergence is not provable through a native CLI, then bytes remain unchanged and the MCP capability is pending.
- [ ] AC 18: Given state corruption or concurrent writers, when state is read or updated, then no partial record is trusted, source intent remains intact and reconstruction is possible.
- [ ] AC 19: Given observed evidence exceeds its capability-specific age, when status runs, then it becomes drifted/unknown until verify refreshes it.
- [ ] AC 20: Given any manifest, plan, log or attestation output, when secret canaries, private URLs and credential-shaped values are introduced in fixtures, then all public/project outputs redact or reject them.
- [ ] AC 21: Given a migrated capability, when the legacy implementation is considered for removal, then fresh-host, existing-host, partial-host, rollback and second-run parity must all pass first.
- [ ] AC 22: Given the control plane foundation lands, when docs are reviewed, then architecture/runtime guidance reflects implemented behavior while public surfaces do not claim future backends.
- [ ] AC 23: Given zero capability declarations and zero supported native manifests, when inspect runs, then it reports an unmanaged environment and does not generate an empty ready attestation.
- [ ] AC 24: Given many backends claim one capability, when precedence cannot select one explicit owner, then planning blocks rather than merging their mutations.
- [ ] AC 25: Given an interrupted apply, when plan/status runs again, then it starts from observed state and never assumes either full rollback or full success.
- [ ] AC 26: Given `.shipglows.env`, when it contains its existing allowed runtime-policy keys, then those policies remain effective without duplication; capability/version/backend keys are rejected as outside that file's ownership.
- [ ] AC 27: Given mise is absent on Windows, when planning the Node pilot, then ShipGlows shows a distinct official `jdx.mise` WinGet acquisition operation; Node installation cannot start until that operation is approved and mise is observed.
- [ ] AC 28: Given mise and Node are ready, when an agent-like child process runs the project tool, then ShipGlows proves it through `mise exec` without depending on a PowerShell profile or global shim activation.

## Test Strategy

- Unit: schema, path, normalization, precedence, status, redaction, digest, freshness and backend-contract tests with no network or machine mutation.
- Integration: disposable project/state roots; fake bounded process runner; fixture outputs in English and French; PowerShell 5.1 and Bash syntax/behavior; actual backend CLIs only in isolated opt-in jobs.
- Platform: Windows x64 clean/existing/partial/corrupt hosts; Linux Flox fixtures; WSL boundary; one container-capable project; separate agent-like child processes.
- Supply chain: exact metadata authority, checksums/signatures/provenance when offered, safe archive extraction, no mutable `latest` execution in persisted plans and changed-metadata rejection.
- Migration: characterize every legacy capability before adapter work; prove parity before routing default; retain rollback; remove only in a later exact scope.
- Manual: official license flows, UAC/elevation, restart, Android real/hosted device, acceleration and provider authentication remain explicit manual evidence where automation would exceed authority.

## Test Contract

### Surface

- Stack/surface: PowerShell, Bash, cross-platform CLI, files, external package/configuration backends and agent processes.
- Primary proof mode: mixed.
- Proof order: contract/schema -> unit fixtures -> adapter integration -> disposable platform smoke -> manual consent/device/provider evidence -> independent verification.

### Manual checklist

- Needed: yes.
- Checklist path: `shipglows_data/workflow/test-checklists/reproducible-environment-control-plane.md` to be created with the first implementation slice, not during spec authoring.
- Required scenario coverage: Windows fresh/existing/partial; Unix existing Flox; stale plan; license refusal/acceptance; auth pending; agent PATH mismatch; Android local/no acceleration; container host gap; rerun convergence.
- Exception with proof: no implementation task may claim complete platform readiness solely from mocks; mocked tests prove orchestration, while machine/provider/device claims require their named evidence.

### Required evidence stack

- Automated / unit / integration checks: exact commands are defined per implementation task and added to the checklist when the owning files exist.
- Agent-run browser proof: only for public docs or browser-dependent readiness after the relevant slice is implemented.
- Auth/session proof: provider-owned interactive flows; ShipGlows observes safe status only and never captures credentials.
- Contract/integration proof: official schema/CLI docs plus fixture and process-boundary tests for each backend.
- Provider evidence: official backend CLI output from a disposable or operator-approved environment.
- Device-native proof: Android emulator/real/hosted device and Flutter Windows build scenarios when those capabilities migrate.

## OWASP Security Gate

- Categories considered: A02 Security Misconfiguration, A03 Software Supply Chain Failures, A05 Injection, A06 Insecure Design, A07 Authentication Failures, A08 Software or Data Integrity Failures, A09 Security Logging and Alerting Failures and A10 Mishandling of Exceptional Conditions.
- Trust/data boundaries: repository manifests -> parser; official metadata -> resolver; plan -> privileged/backend process; provider CLI -> auth state; environment/process -> attestation; user-owned config -> adapter.
- Selected ASVS: not claimed at spec stage; implementation security tests map concrete file, command, update and secret-handling controls before any compliance wording.
- Proof: strict schemas, path containment, structured process arguments, exact plan digest, provenance/checksum validation, secret canaries, redacted diagnostics, fail-closed exceptional paths and explicit consent tests.
- Residual gap and owner: each backend implementation owns a current official-doc review and threat-model delta; no aggregate security or compliance claim follows from these controls.

## Risks

- Security impact: high because the system may install executable software, change machine state, launch privileged processes and inspect authentication/configuration. Mitigations are strict input boundaries, official authorities, explicit approvals, redaction, least ownership and backend-specific proof.
- Product risk: a large manifest could become a second package manager or confuse users. The thin intent/reference rule and native ownership prevent duplication.
- Migration risk: routing through adapters can regress working installations. Characterization, opt-in pilots, parity gates and per-capability rollback protect the transition.
- Performance risk: repeated full discovery or doctor commands can slow menus. Bounded observation, capability-specific freshness and shared cache prevent unbounded rescans without treating stale evidence as current.
- Portability risk: the common schema may erase important platform details. Namespaced extensions and explicit `not_applicable`/host-required policies preserve them.
- Supply-chain risk: backend metadata, packages, installers and configs are external input. Exact plans, digests, provenance where available and no silent mutable execution reduce exposure.
- Privacy risk: environment diagnostics can leak usernames, paths or account hints. Attestations use redaction and minimum necessary evidence.
- Operational risk: a partially applied multi-backend plan cannot always roll back external installers. The system records per-operation observation and replans from reality rather than pretending transactional rollback.

## Execution Notes

- Read first: this spec; `shipglows_data/technical/architecture.md`; `runtime-cli.md`; `installer-and-user-scope.md`; Windows DevServer guide; `cli/lib.sh` Flox boundaries; Windows mobile, Playwright, DevServer and installer modules; current official backend docs.
- Validate with: begin every task regression-first; run focused schema/adapter tests, existing Linux/Windows suites, metadata lint, secret scan, `git diff --check` and platform smoke proportional to the claimed capability.
- Stop conditions: manifest semantics require a second package resolver; a backend lacks safe native invocation; ownership conflict is unresolved; current docs contradict the plan; a migration cannot preserve external configuration; a test would accept licenses/auth/elevation; exact removal targets lack parity proof; public copy would present an experimental backend as shipped.
- Implementation sequence: Tasks 1-3 establish the control plane, Tasks 4-7 prove replaceable adapters, Task 8 migrates specialized Windows truth, Task 9 removes redundancy, Task 10 aligns only shipped documentation.
- Branching: each implementation slice uses a clean dedicated branch or worktree unless the operator explicitly approves another safe scope; this spec creation does not stage or commit the current editorial roadmap change.

## Open Questions

None. Node 24 plus pnpm 10 form the fixed first mise pilot for project-local ownership; existing global Node and pnpm installations used by ShipGlows and coding-agent CLIs remain outside that pilot.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-16 16:48:28 UTC | sg-spec | GPT-5 Codex | Created the cross-platform control-plane contract from current Unix/Windows behavior, official backend documentation and the approved thin-orchestration decision. | Draft spec created with no unresolved product decision. | /sg-ready ShipGlows Reproducible Environment Control Plane |
| 2026-08-16 16:56:18 UTC | sg-ready | GPT-5 Codex | Reviewed user-story fit, strict JSON manifest, `.shipglows.env` ownership, backend bootstrap, platform boundaries, security, ZOMBIES coverage, ordered tasks and proof contract; fixed the stale runtime-doc dependency, parser ambiguity and mise pilot ambiguity. | Ready: no material product, platform, security, ownership or proof ambiguity remains for the foundation slice. | /sg-start ShipGlows Reproducible Environment Control Plane |
| 2026-08-16 17:03:09 UTC | sg-start | GPT-5 Codex | Started the approved foundation slice for Tasks 1-3 with test-first proof and no active backend or machine mutation. | In progress: schema/state/plan tests precede implementation. | Implement Tasks 1-3 |
| 2026-08-16 17:16:27 UTC | sg-start | GPT-5 Codex | Implemented the strict manifest contract, bounded discovery, atomic redacted private state, deterministic digest-bound planning, safe no-backend apply refusal and thin source CLI adapters. | Tasks 1-3 implemented; focused contracts and the complete Windows suite pass. Installed Windows packaging and every executable backend remain explicitly deferred. | /sg-verify Tasks 1-3 foundation |
| 2026-08-16 17:48:36 UTC | sg-verify | GPT-5 Codex | Independently reviewed Tasks 1-3, added regression-first adversarial coverage and hardened process, input, state, locking, attestation and apply boundaries. | Verified at standard depth: five environment contracts, Unix/PowerShell adapters and the complete Windows suite pass; source-only packaging and all executable backends remain deferred. | Plan the first executable backend |
| 2026-08-16 18:15:06 UTC | sg-start | GPT-5.6 Codex | Implemented the separately approved Task 5 source pilot regression-first with official mise semantics, an injectable structured runner, exact lock ownership and fixture-only Windows/agent proof. | Implemented and locally auto-verified: the pilot is executable only for the narrow approval-digest-bound Windows mise/Node 24 grammar; every real install, provider smoke and installed-runtime packaging action remained untouched. | Independent Task 5 verification; opt-in provider smoke remains manual |
| 2026-08-16 18:25:43 UTC | sg-start | GPT-5.6 Codex | Hardened Task 5 against inherited/alternate mise configuration and repository-resolved executables, then ran the complete source proof stack. | Local auto-verification passed, including all environment contracts, Unix/PowerShell adapters, PowerShell 5.1 parsing and the complete Windows DevServer contract; real provider execution remains unclaimed. | Independent Task 5 verification; opt-in provider smoke remains manual |
| 2026-08-16 18:53:01 UTC | sg-verify | GPT-5.6 Codex | Independently reproduced and repaired arbitrary external executable trust, approval-to-runner executable drift, inherited environment leakage and incomplete mise cascade isolation; rechecked current official mise semantics and the complete source proof stack. | Verified at standard depth for the Task 5 source/injected-fixture pilot only; executable path plus SHA-256 proves approved identity, not official provenance, and native provider/installed-runtime readiness remains open. | Separately approve a real disposable provider smoke and packaging proof before any shipped-readiness claim. |
| 2026-08-16 19:36:46 UTC | sg-engineering | GPT-5.6 Codex | Extended the approved Task 5 source pilot from Node-only ownership to explicit Node 24 plus pnpm 10 ownership, exact dual lock semantics, optional `packageManager` reconciliation, independent fixed install operations and dual-consumer evidence. | Regression-first pnpm proof, all environment contracts, Unix/PowerShell adapters and the complete Windows suite pass; no real provider, dependency install, global tool, installed runtime, commit or push was touched. | Keep real provider and packaging proof separately approval-gated. |

## Current Chantier Flow

- `sg-spec`: done, draft spec created.
- `sg-ready`: done, ready for implementation.
- `sg-start`: done for Tasks 1-3 and implemented for the separately approved Task 5 source pilot, including Node 24 plus pnpm 10.
- `sg-verify`: done at standard depth for Tasks 1-3 and for the Task 5 source/injected-fixture pilot; pnpm regression proof is integrated, while native provider and installed-runtime proof remain open.
- `sg-end`: not launched.
- `sg-ship`: not launched.

Next step: keep any real WinGet/mise/Node smoke and installed-runtime packaging as separate explicitly approved proof before claiming native Windows readiness.
