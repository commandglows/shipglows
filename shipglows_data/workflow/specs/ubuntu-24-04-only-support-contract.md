---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: ShipGlows
created: "2026-04-28"
created_at: "2026-04-28 16:44:09 UTC"
updated: "2026-08-11"
updated_at: "2026-08-11 22:30:00 UTC"
status: draft
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: migration
owner: "ShipGlows maintainer"
user_story: "En tant que mainteneuse de dotfiles et ShipGlows, je veux que le produit annonce et enforce une seule cible Linux officiellement supportee, Ubuntu 24.04 LTS, afin de reduire l'ambiguite produit, limiter les branches de maintenance et eviter de promettre des environnements non tenus."
risk_level: high
confidence: high
security_impact: none
docs_impact: yes
linked_systems:
  - "/home/ubuntu/dotfiles/README.md"
  - "/home/ubuntu/dotfiles/bootstrap.sh"
  - "/home/ubuntu/dotfiles/install.sh"
  - "/home/ubuntu/dotfiles/lib.sh"
  - "/home/ubuntu/dotfiles/CLAUDE.md"
  - "/home/ubuntu/dotfiles/BUSINESS.md"
  - "/home/ubuntu/dotfiles/CONTEXT.md"
  - "/home/ubuntu/dotfiles/PRODUCT.md"
  - "/home/ubuntu/shipglows/README.md"
  - "/home/ubuntu/shipglows/install.sh"
  - "/home/ubuntu/shipglows/local/README.md"
  - "/home/ubuntu/shipglows/shipglows_data/technical/operator-guides/windows-devserver.md"
  - "/home/ubuntu/shipglows/local/install_local.ps1"
  - "/home/ubuntu/shipglows/TASKS.md"
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "GUIDELINES.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "dotfiles/PRODUCT.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "README.md"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes: []
evidence:
  - "dotfiles/README.md currently markets the repository as multi-platform and still lists Windows, Linux/Codespaces, and Termux install paths."
  - "dotfiles/bootstrap.sh says 'Fresh Ubuntu 24.04 LTS Servers' but only checks for /etc/os-release and x86_64/arm64, not Ubuntu 24.04 specifically."
  - "dotfiles/lib.sh still detects linux, macos, and windows, with x86_64, arm64, and armv7 architectures."
  - "dotfiles/install.sh still contains macOS/Homebrew and Debian-family generic installation branches, plus multiple ARM64 download paths."
  - "ShipGlows README and local tunnel docs still expose generic Linux, macOS, Windows, WSL, and ARM-related guidance."
  - "ShipGlows TASKS.md still contains a universal multi-OS bootstrap roadmap that conflicts with the new narrower support promise."
  - "dotfiles/README.md points to docs/installation/*.md files that are absent from the inspected checkout, creating an additional documentation truth gap."
next_step: "/sg-spec ubuntu-24-04-only-support-contract"
---

# Spec: Ubuntu 24.04 LTS As The Only Supported Linux Contract

## Title

Ubuntu 24.04 LTS as the only supported Linux contract

## Status

draft

## User Story

En tant que mainteneuse de dotfiles et ShipGlows, je veux que le produit annonce et enforce une seule cible Linux officiellement supportee, Ubuntu 24.04 LTS, afin de reduire l'ambiguite produit, limiter les branches de maintenance et eviter de promettre des environnements non tenus.

## Minimal Behavior Contract

Le bootstrap principal, les README, les guides d'installation et les scripts d'installation doivent raconter la meme chose: la cible Linux officiellement supportee est Ubuntu 24.04 LTS, et toute autre plateforme ou variante doit etre soit retiree de la promesse, soit relabellee comme non supportee ou experimentale sans ambiguity. Quand l'installation tourne sur un OS, une version, ou une architecture hors contrat officiel, le systeme doit le dire clairement avant d'aller loin, avec un message qui distingue "non supporte officiellement", "non encore pris en charge", et "possible plus tard". Le cas facile a rater est celui d'un code path qui fonctionne encore par heritage, par exemple ARM64, Windows local tunnel, Termux ou macOS, et qui continue de faire croire au support parce qu'il n'est ni bloque ni declassifie dans la doc.

## Success Behavior

- Preconditions: un utilisateur arrive par `dotfiles/README.md`, `shipglows/README.md`, ou par le bootstrap `dotfiles/bootstrap.sh`.
- Trigger: il lit la doc publique ou lance le bootstrap/install principal.
- User/operator result: il comprend rapidement qu'Ubuntu 24.04 LTS est la seule cible Linux supportee aujourd'hui, et qu'aucune promesse officielle n'est faite pour Windows, macOS, Termux, WSL, Debian generique, ou Linux ARM tant qu'une nouvelle decision produit n'a pas ete prise.
- System effect: les surfaces d'entree publiques, les docs internes de reference et les scripts d'installation convergent vers ce contrat unique; les branches de compatibilite hors contrat sont soit retirees, soit gatees explicitement.
- Success proof: un audit texte de `README.md`, `bootstrap.sh`, `install.sh`, `CLAUDE.md`, `CONTEXT.md`, `BUSINESS.md`, `PRODUCT.md`, `local/README*.md` et `TASKS.md` ne laisse plus de promesse contradictoire sur les plateformes ou architectures supportees.
- Silent success: not allowed; un environnement hors contrat doit produire un diagnostic explicite, pas un comportement opportuniste qui laisse croire a un support stable.

## Error Behavior

- Expected failures: execution on non-Ubuntu Linux, Ubuntu non-24.04, ARM64 where the contract is x86_64-only, stale docs that still mention Windows/Termux/macOS, missing referenced docs, or local tunnel docs still advertising WSL/Windows.
- User/operator response: le message doit dire si l'environnement est bloque, declassifie comme non supporte, ou seulement hors promesse officielle, et pointer vers la prochaine action concrete.
- System effect: l'installation doit s'arreter tot ou demander un override explicite selon la politique retenue, plutot que de continuer silencieusement sur un environnement que le produit ne veut plus assumer.
- Must never happen: revendiquer Ubuntu 24.04 LTS comme seule cible tout en laissant des docs d'installation actives pour Windows, Termux, macOS, WSL, Debian generique, ou ARM Linux sans disclaimer explicite.
- Silent failure: not allowed; si une doc ou un code path reste hors alignement, cela doit etre visible dans les rapports de verification et la spec.

## Problem

Le produit a maintenant une decision de scope claire: sur Linux, une seule version officiellement supportee doit etre assumee, Ubuntu 24.04 LTS. Pourtant, l'etat actuel du code et de la documentation raconte encore une histoire beaucoup plus large.

Dans `dotfiles`, la promesse publique reste multi-plateforme avec Windows, Linux/Codespaces et Termux. Le code detecte toujours macOS, Windows, Debian generique et plusieurs architectures Linux, y compris ARM. `bootstrap.sh` affiche deja "Ubuntu 24.04 LTS" mais sans verifier reellement la distribution ni la version. Dans `ShipGlows`, les README et les docs `local/` continuent d'exposer Linux/macOS/WSL/Windows, et le backlog mentionne encore un bootstrap multi-OS comme trajectoire officielle.

Le risque n'est pas seulement cosmetique. Tant que la promesse produit, les docs d'installation et les garde-fous runtime divergent, vous continuez a:
- attirer des usages hors scope que vous ne voulez plus supporter,
- conserver du code mort ou du code heritage qui ressemble a du support actif,
- brouiller la responsabilite entre "ca marche peut-etre encore" et "nous le supportons officiellement",
- augmenter le cout de maintenance et de triage, surtout sur ARM Linux et les workflows locaux Windows/WSL.

## Solution

Traiter ce changement comme une migration de contrat produit, pas comme une simple retouche de README. Le chantier doit:
- redefinir la promesse publique et interne autour d'Ubuntu 24.04 LTS,
- introduire des garde-fous d'installation qui alignent le runtime sur cette promesse,
- classifier les chemins hors contrat en trois categories claires: retire, non supporte officiellement, ou experimental/parked,
- nettoyer le backlog et la documentation pour qu'ils ne contredisent plus la decision de scope.

Le principe directeur est simple: tout ce qui reste dans le repo n'est pas forcement supporte, mais tout ce qui est visible depuis les surfaces officielles doit refleter exactement le contrat decide.

## Scope In

- Re-cadrer la promesse produit et d'installation de `dotfiles` autour d'Ubuntu 24.04 LTS comme seule cible Linux officiellement supportee.
- Aligner la promesse produit et la doc de `ShipGlows` sur cette meme decision quand elles parlent de bootstrap, d'installation ou d'environnements supports.
- Ajouter un vrai gate runtime dans `dotfiles/bootstrap.sh` pour verifier la distribution, la version, et l'architecture selon la politique retenue.
- Decider explicitement la politique architecture pour Ubuntu 24.04:
  - `x86_64 only`, ou
  - `x86_64 + arm64`, mais alors documente comme supporte,
  - ou `arm64 experimental/non supported officially`.
- Decider le sort des chemins Windows, macOS, WSL, Termux et local tunnel:
  - suppression,
  - depublication,
  - ou conservation avec disclaimer "hors support officiel".
- Nettoyer les docs de reference internes (`CLAUDE.md`, `CONTEXT.md`, `BUSINESS.md`, `PRODUCT.md`, `TASKS.md`) pour qu'elles racontent la meme strategie.
- Traiter les liens de doc cassants ou absents dans `dotfiles/README.md`.
- Produire une terminologie standard pour "supported", "unsupported", "experimental", "later", et "legacy path kept in repo".

## Scope Out

- Implementer maintenant un support officiel Windows ou macOS.
- Refaire toute l'architecture d'installation de ShipGlows au-dela des points necessaires a l'alignement de promesse.
- Garantir qu'aucun script heritage hors contrat ne fonctionne plus jamais; l'objectif immediat est le contrat et la lisibilite, pas l'eradication complete de tout code historique.
- Reorganiser tous les dossiers du repo uniquement pour esthetique.
- Supprimer dans cette spec tout le code historique si une phase de deprecation explicite est preferée.

## Constraints

- La promesse publique doit etre plus etroite que la surface de code heritage si necessaire, mais jamais plus large.
- Si un chemin hors support reste dans le repo pour convenance ou futur usage, il doit etre traite comme heritage ou experimental, pas comme support officiel implicite.
- Le bootstrap principal doit echouer tot sur un environnement hors contrat, sauf si un override explicite et documente est introduit.
- Les docs internes doivent distinguer verite produit, verite technique, et backlog futur; `TASKS.md` ne doit pas contredire le contrat courant.
- La migration doit etre faisable sans casser la capacite du mainteneur a developper plus tard un support Windows/macOS; on retire la promesse, pas la possibilite strategique future.
- Les messages d'erreur d'installation doivent etre actionnables et precis, avec OS, version, architecture, contrat attendu, et statut du run.

## Dependencies

- Runtime:
  - Bash and `/etc/os-release` parsing in `dotfiles/bootstrap.sh` and `dotfiles/lib.sh`
  - existing install orchestration in `dotfiles/install.sh`
  - existing ShipGlows root installer in `shipglows/install.sh`
- Document contracts:
  - `shipglows/BUSINESS.md` `artifact_version: 1.1.0`, `status: reviewed`
  - `shipglows/PRODUCT.md` `artifact_version: 1.1.0`, `status: reviewed`
  - `shipglows/GUIDELINES.md` `artifact_version: 1.0.0`, `status: reviewed`
  - `dotfiles/PRODUCT.md` `artifact_version: 1.0.0`, `status: reviewed`
- Metadata gaps:
  - `dotfiles/README.md` and `shipglows/README.md` currently have no ShipGlows frontmatter, so artifact version and status remain `unknown` in this spec.
- Fresh external docs:
  - fresh-docs not needed for the contract definition itself; the work is local to repo promises, installation policy, and runtime gating rather than to a changing framework API.

## Invariants

- Ubuntu 24.04 LTS remains the only Linux target officially promised after this migration unless a later spec expands scope.
- A repo surface can remain present without being officially supported, but it must be labeled accordingly.
- The official bootstrap entrypoint must not silently accept a broader OS matrix than the docs promise.
- Support status must be defined independently for OS, version, and architecture; "Linux" alone is too vague.
- Product docs, operator docs, and installer behavior must agree on the same support contract.

## Links & Consequences

- Upstream systems:
  - product positioning and support promise in `dotfiles/README.md` and `shipglows/README.md`
  - install entrypoint in `dotfiles/bootstrap.sh`
  - OS/arch detection in `dotfiles/lib.sh`
- Downstream systems:
  - onboarding expectations for new machines and servers
  - support load and bug triage
  - future Windows/macOS planning, which must now be represented as roadmap or backlog, not current support
- Consequences on code:
  - some branches may become dead code or "legacy but retained" code after the contract narrows
  - ARM-specific download logic and Windows/macOS docs become explicit decision points instead of accidental support
- Consequences on documentation:
  - missing `docs/installation/*.md` references in `dotfiles/README.md` become unacceptable once the README is the canonical promise surface
- Consequences on operations:
  - maintainers need an override strategy for personal/off-contract use, or an explicit "unsupported means at your own risk" posture

## Documentation Coherence

- `dotfiles/README.md` must become the public source of truth for support status and install entrypoints.
- `dotfiles/CLAUDE.md`, `BUSINESS.md`, `CONTEXT.md`, and `PRODUCT.md` must stop describing the repo as multi-platform unless the wording is explicitly historical or future-looking.
- `shipglows/README.md` must stop implicitly broadening the support matrix through generic bootstrap language.
- `shipglows/local/README.md` and `shipglows_data/technical/operator-guides/windows-devserver.md` must be either:
  - removed from official onboarding,
  - re-scoped as legacy/local-only/unsupported,
  - or retained behind an explicit disclaimer.
- `shipglows/TASKS.md` must stop presenting multi-OS bootstrap as current product direction if the decision is now single-target Ubuntu.
- Any doc links kept in `dotfiles/README.md` must resolve in the repo, or be removed/replaced during the same migration.

## Edge Cases

- Ubuntu 24.04 on ARM64:
  - if supported, it must be explicitly promised and tested;
  - if not supported, bootstrap must say so even if some binaries still happen to exist.
- Ubuntu 22.04 or Debian 12:
  - they may be close technically, but must still be treated as outside official support if the contract is 24.04 only.
- Existing maintainer workflows on Windows/WSL/macOS:
  - these may still be used privately, but the product must not present them as supported to users.
- Codespaces:
  - if kept in docs, they need a clear support label because they are Linux-like but not identical to a fresh Ubuntu 24.04 host.
- Hidden support via generic phrasing:
  - phrases like "Linux/Codespaces", "Linux local machines", or "Debian/Ubuntu" are contract leaks and must be eliminated or narrowed.
- Heritage scripts with valid code:
  - code presence alone must not be mistaken for support status.

## Implementation Tasks

- [ ] Task 1: Define the support contract and terminology
  - File: `shipglows/specs/ubuntu-24-04-only-support-contract.md`
  - Action: freeze the exact contract language for OS, version, architecture, and off-contract paths, including whether Ubuntu 24.04 ARM64 is officially supported.
  - User story link: gives the whole migration one unambiguous target instead of ad hoc wording changes.
  - Depends on: None
  - Validate with: spec review confirms one explicit answer for OS, version, architecture, and status labels.
  - Notes: This is the product decision that all later tasks consume.

- [ ] Task 2: Rewrite dotfiles public onboarding to match the new contract
  - File: `/home/ubuntu/dotfiles/README.md`
  - Action: replace multi-platform marketing and install sections with an Ubuntu 24.04 LTS-first story, remove or relabel Windows/Termux references, and fix or remove broken docs links.
  - User story link: ensures the first user-facing surface does not overpromise unsupported environments.
  - Depends on: Task 1
  - Validate with: `rg -n "Windows|Termux|Linux/Codespaces|macOS|WSL|Debian/Ubuntu" /home/ubuntu/dotfiles/README.md`
  - Notes: If legacy paths remain mentioned, each mention must be clearly labeled non supported or later.

- [ ] Task 3: Align dotfiles internal contract docs with the narrowed promise
  - File: `/home/ubuntu/dotfiles/CLAUDE.md`, `/home/ubuntu/dotfiles/BUSINESS.md`, `/home/ubuntu/dotfiles/CONTEXT.md`, `/home/ubuntu/dotfiles/PRODUCT.md`
  - Action: remove multi-platform support claims as current truth and restate the repository mission around Ubuntu 24.04 LTS support only, with any future platform work framed as backlog.
  - User story link: prevents internal docs from reintroducing broader support assumptions during future edits.
  - Depends on: Task 1
  - Validate with: `rg -n "Windows|Termux|macOS|multi-platform|Linux/Codespaces" /home/ubuntu/dotfiles/{CLAUDE.md,BUSINESS.md,CONTEXT.md,PRODUCT.md}`
  - Notes: Technical history may remain if clearly marked as historical or legacy.

- [ ] Task 4: Enforce the OS/version gate in the bootstrap entrypoint
  - File: `/home/ubuntu/dotfiles/bootstrap.sh`
  - Action: add explicit checks for `ID=ubuntu`, `VERSION_ID=24.04`, and the chosen architecture policy; fail early with a precise unsupported-environment message.
  - User story link: converts the product promise into actual runtime behavior.
  - Depends on: Task 1
  - Validate with: dry runs or shell tests covering Ubuntu 24.04 supported path and non-Ubuntu / non-24.04 rejection path.
  - Notes: Decide whether an override env var exists for maintainer-only unsupported runs.

- [ ] Task 5: Decide and implement the legacy-runtime policy in dotfiles install code
  - File: `/home/ubuntu/dotfiles/lib.sh`, `/home/ubuntu/dotfiles/install.sh`
  - Action: either remove unsupported platform branches from active flow or guard them behind explicit unsupported/legacy conditions, especially macOS, Windows, Debian-generic, and ARM-specific branches.
  - User story link: avoids accidental support through surviving code paths.
  - Depends on: Task 4
  - Validate with: `rg -n "Darwin|windows|debian|arm64|aarch64|armv7|brew|Termux" /home/ubuntu/dotfiles/{lib.sh,install.sh}`
  - Notes: The goal is contract alignment first; full deletion is optional if legacy paths are fenced clearly.

- [ ] Task 6: Align ShipGlows top-level installation narrative
  - File: `/home/ubuntu/shipglows/README.md`
  - Action: tighten installation wording so ShipGlows does not implicitly broaden the support matrix inherited from dotfiles, and clarify what environment the main install flow assumes.
  - User story link: keeps the framework repo from contradicting the installer repo.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "Linux|Windows|macOS|WSL|ARM|bootstrap" /home/ubuntu/shipglows/README.md`
  - Notes: Mention generic Linux only if immediately constrained by Ubuntu 24.04 support wording.

- [ ] Task 7: Re-scope or de-publish ShipGlows local Windows and multi-OS tunnel docs
  - File: `/home/ubuntu/shipglows/local/README.md`, `/home/ubuntu/shipglows/shipglows_data/technical/operator-guides/windows-devserver.md`, `/home/ubuntu/shipglows/local/install_local.ps1`
  - Action: decide whether these are archived, labeled unsupported, or removed from official surfaces, and update wording accordingly.
  - User story link: stops local helper docs from acting like supported product surfaces.
  - Depends on: Task 1
  - Validate with: `rg -n "Windows|WSL|macOS|PowerShell|Git Bash" /home/ubuntu/shipglows/local/README.md /home/ubuntu/shipglows/shipglows_data/technical/operator-guides/windows-devserver.md /home/ubuntu/shipglows/local/install_local.ps1`
  - Notes: Code can remain if product wants a private maintainer path, but support status must be explicit.

- [ ] Task 8: Clean the ShipGlows backlog so it reflects the current contract
  - File: `/home/ubuntu/shipglows/TASKS.md`
  - Action: replace or reframe multi-OS bootstrap roadmap items so they no longer read as active current support direction.
  - User story link: avoids re-opening the support matrix by accident through planning artifacts.
  - Depends on: Task 1
  - Validate with: `rg -n "multi-OS|macOS|Windows|WSL|Debian/Ubuntu" /home/ubuntu/shipglows/TASKS.md`
  - Notes: Future platform expansion can stay as deferred roadmap, not as present contract.

- [ ] Task 9: Document the support taxonomy once and reuse it everywhere
  - File: `/home/ubuntu/dotfiles/README.md`, `/home/ubuntu/shipglows/README.md`, optional dedicated policy doc
  - Action: define standard labels such as `Supported`, `Unsupported`, `Experimental`, `Legacy path kept in repo`, and apply them consistently.
  - User story link: gives users and maintainers the same vocabulary for interpreting platform references.
  - Depends on: Task 1
  - Validate with: manual review confirms identical terminology across the touched docs.
  - Notes: This reduces future drift more than ad hoc prose edits.

- [ ] Task 10: Verify the migrated contract end-to-end
  - File: touched docs and install scripts across both repos
  - Action: run a contract audit after edits to ensure no official surface still claims multi-platform support and that the bootstrap rejects off-contract environments as designed.
  - User story link: proves the promise and the runtime now match.
  - Depends on: Tasks 2-9
  - Validate with: repo-wide searches plus targeted manual installer checks.
  - Notes: Include search for broken `docs/` links in dotfiles as part of this verification.

## Acceptance Criteria

- [ ] AC1: `dotfiles/README.md` clearly states that Ubuntu 24.04 LTS is the only officially supported Linux target.
- [ ] AC2: `shipglows/README.md` does not widen that support promise through generic Linux or local multi-OS language without disclaimer.
- [ ] AC3: `dotfiles/bootstrap.sh` rejects non-Ubuntu or non-24.04 environments before running the full install flow.
- [ ] AC4: The architecture policy for Ubuntu 24.04 is explicit and consistent across docs and runtime checks.
- [ ] AC5: No official onboarding surface still presents Windows, macOS, Termux, WSL, or Debian-generic install instructions as current support.
- [ ] AC6: Any remaining legacy scripts or docs for off-contract environments are clearly labeled unsupported, experimental, archived, or maintainer-only.
- [ ] AC7: `dotfiles` internal contract docs no longer describe the repo mission as current multi-platform support.
- [ ] AC8: `shipglows/TASKS.md` no longer reads as if a universal multi-OS bootstrap is the active product contract.
- [ ] AC9: Broken `docs/...` references in `dotfiles/README.md` are either restored or removed.
- [ ] AC10: A repo-wide search for `Windows`, `Termux`, `macOS`, `WSL`, `Linux/Codespaces`, `Debian/Ubuntu`, and `arm64` leaves only intentional, labeled references.

## Test Strategy

- Static verification:
  - repo-wide `rg` scans in both repos for platform and architecture wording
  - link sanity check for doc references in `dotfiles/README.md`
- Runtime verification:
  - manual run on Ubuntu 24.04 supported environment
  - manual or mocked rejection checks for Ubuntu non-24.04 and non-Ubuntu Linux
- Contract verification:
  - compare public docs, internal docs, and runtime guard behavior against the same support taxonomy

## Risks

- Product risk: high if the contract remains half-migrated, because users will continue to interpret surviving legacy instructions as promises.
- Operational risk: medium if maintainers still rely privately on off-contract environments and no override or deprecation posture is defined.
- Documentation risk: high because broken links and stale install guides can silently reintroduce old support claims.
- Change-management risk: medium because some code branches may still be useful later, creating pressure to keep them visible without proper disclaimers.

## Execution Notes

- Recommended execution order:
  1. decide OS/version/arch contract,
  2. update public promise,
  3. add bootstrap/runtime guard,
  4. clean internal docs and backlog,
  5. fence or relabel legacy paths,
  6. run verification searches and installer checks.
- Prefer wording changes before code deletion when the support taxonomy is still being finalized.
- If an unsupported maintainer override is needed, it should be explicit, opt-in, and documented as outside official support.

## Open Questions

- Is Ubuntu 24.04 ARM64 officially supported, unofficially tolerated, or explicitly unsupported?
- Are GitHub Codespaces still part of the official story, or should they be removed from the support promise as well?
- Should Windows/macOS/WSL/Termux helper files be archived now, or simply de-published and labeled legacy?
- Do you want a maintainer-only escape hatch to run installs on unsupported environments, or should the gate be hard?

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-28 16:44:09 UTC | sg-spec | GPT-5 Codex | Created cross-repo support-contract migration spec | draft | /sg-ready ubuntu-24-04-only-support-contract |
| 2026-04-28 16:51:36 UTC | sg-ready | GPT-5 Codex | Evaluated readiness for cross-repo support-contract migration | not ready | /sg-spec ubuntu-24-04-only-support-contract |

## Current Chantier Flow

- sg-spec: completed - spec created in draft with code and documentation evidence from `dotfiles` and `ShipGlows`
- sg-ready: not ready - blocking product decisions remain around ARM, Codespaces, legacy local docs, and unsupported-environment overrides
- sg-start: pending
- sg-verify: pending
- sg-end: pending
- sg-ship: pending
