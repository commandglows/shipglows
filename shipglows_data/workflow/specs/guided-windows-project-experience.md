---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-28"
updated: "2026-08-28"
status: active
source_skill: 900-shipglows-core
source_model: "GPT-5 Codex"
scope: "guided-windows-project-experience"
owner: "Diane"
confidence: high
user_story: "En tant qu'utilisatrice de ShipGlows sous Windows, je veux comprendre immédiatement si mon dépôt est un site, une application ou une extension Chrome et connaître l'action suivante, afin de lancer et ouvrir le bon environnement sans interpréter des détails techniques internes."
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "cli/windows/ShipGlows.DevServer.psm1"
  - "cli/windows/shipglows-devserver.ps1"
  - "tests/windows/"
  - "shipglows_data/technical/runtime-cli.md"
  - "shipglows_data/technical/operator-guides/windows-devserver.md"
  - "shipglows_app/site/"
depends_on:
  - artifact: "shipglows_data/technical/runtime-cli.md"
    artifact_version: "1.29.1"
    required_status: reviewed
  - artifact: "shipglows_data/workflow/specs/native-windows-browser-extension-projects.md"
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "The installed ToolGlows replay exposed and then proved fixes for a concatenated ENVIRONMENT.md line and PowerShell 7 DateTime deserialization falsely reconciling a live extension to stopped."
  - "The Windows runtime already operates CRXJS browser extensions, but its help, menu, dashboard and registration messages expose generic project wording or internal kind names."
  - "The public ShipGlows site currently names Astro, Python and Flutter but has no user-facing Chrome extension journey."
  - "ToolGlows proved the installed start, open and stop extension path while also exposing the missing user guidance."
next_step: "Open the separate public-site product chantier for the exact bilingual website, app and Chrome-extension guidance contract."
---

# Guided Windows project experience

## Status

Implemented, published and proven through the installed runtime under the approved Core plan. The public site is an evidence and handoff surface only in this chantier; `shipglows_app` remains a separate product repository.

## Outcome contract

ShipGlows presents every supported Windows surface through one user-experience descriptor. The descriptor owns a human label, the meaning of its port, the result of Start, the action performed by Open, its relevant artifact and the next user action. Runtime code remains authoritative for execution; documentation and public copy consume the same bounded promise without widening compatibility.

| Project family | User-facing label | Port meaning | Open outcome | Next action |
| --- | --- | --- | --- | --- |
| Astro, Vite, Python | Web project | Local URL | Open the managed local URL | Use the displayed URL, then stop when finished. |
| Flutter Web | Flutter app | Managed web runtime | Open or focus the managed Chrome app session | Validate the app, then stop when finished. |
| CRXJS with `@crxjs/vite-plugin` and `dev:chrome` | Chrome extension | HMR only, not a website | Open `chrome://extensions` and the unpacked directory | Enable Developer mode, choose Load unpacked, select `dist\chrome`, then stop when finished. |

Unknown or unsupported extension stacks never inherit the CRXJS promise. ShipGlows may treat them as another supported manifest type only when that detector is valid; otherwise it reports the existing unsupported or ambiguous project error.

## Acceptance criteria

- Help visibly distinguishes web projects, apps and Chrome extensions and documents `start`, `open`, `status` and `stop` with `-ProjectPath`.
- Clone and manual registration report every detected surface with its human label and next command.
- Project pickers and the dashboard show human labels instead of raw `browser-extension`, and extension ports are labelled HMR rather than presented as a web URL.
- `open` remains selectable for a registered stopped project and returns a specific start-first recovery message instead of claiming that no project exists.
- Successful extension Start says that the Manifest V3 build is ready in `dist\chrome` and points to Open.
- Successful extension Open gives the three Chrome actions: enable Developer mode, choose Load unpacked and select the generated directory.
- Extension `ENVIRONMENT.md` records the same start/open/load/stop workflow without claiming automatic profile installation.
- Web and Flutter behavior stays executable and receives surface-appropriate wording.
- Public-site handoff names the three project families, the exact CRXJS support boundary and the manual Chrome loading boundary in both French and English.
- Existing unrelated repository changes remain untouched.

## Pressure scenarios

- `GUIDE-CLONE-EXTENSION`: a novice clones ToolGlows and immediately learns that a Chrome extension was detected and that Start is next.
- `GUIDE-OPEN-STOPPED`: Open on a stopped extension says to start that named project first; it never says that no project was discovered.
- `GUIDE-HMR-NOT-URL`: an extension port is labelled HMR and is never presented as a browsable project URL.
- `GUIDE-START-TO-OPEN`: successful extension Start points to Open and the fresh unpacked artifact.
- `GUIDE-OPEN-TO-LOAD`: Open explains Developer mode, Load unpacked and the exact generated directory.
- `GUIDE-NO-UNIVERSAL-CLAIM`: WXT, Plasmo or an incomplete CRXJS package never receives a universal Chrome-extension support claim.
- `GUIDE-SITE-PARITY`: the later public-site implementation carries the same project families and boundaries in French and English.

## Exact public-site product handoff

This handoff belongs to the separate `shipglows_app/site` product chantier; Core
does not mutate that repository.

- Home and `/shipglows`: replace the Astro/Python/Flutter-only impression with
  three explicit outcomes: websites, applications and Chrome extensions. Keep
  the promise about guidance and repeatable local environments, not universal
  framework compatibility.
- `/docs`: add a Windows project lifecycle guide with the same four copyable
  commands as the CLI. Explain that Status reports the project family and next
  action, and that Open on a stopped project routes back to Start.
- Chrome-extension guide: state the current automatic boundary exactly as
  CRXJS plus `@crxjs/vite-plugin` plus `dev:chrome`; label the assigned port as
  HMR rather than a page URL; finish with Developer mode, Load unpacked and
  `dist\chrome`.
- `/faq`: answer why an extension has no normal local URL, whether ShipGlows
  installs it automatically (no), and what to do when Open says the project is
  stopped.
- French copy baseline: “ShipGlows vous guide pour lancer vos sites, vos apps
  et vos extensions Chrome dans un environnement local reproductible.”
- English copy baseline: “ShipGlows guides you through running websites, apps,
  and Chrome extensions in a repeatable local environment.”
- Verification: bilingual route/content tests must assert all three project
  families, the CRXJS boundary, HMR-not-URL wording, the manual profile boundary
  and exact lifecycle commands; then run the site check and production build.

## Proof contract

- A focused PowerShell user-guidance regression exercises descriptors, dashboard/status, registration, stopped Open recovery and Chrome steps.
- The existing browser-extension regression protects detection, pnpm launch, readiness and environment behavior.
- PowerShell parser, metadata lint and `git diff --check` cover the changed source and documentation.
- The complete Windows DevServer contract runs because shared CLI presentation and action dispatch change.
- After ordinary push, the official development-branch installer is replayed and the installed CLI proves help, status, start, open and stop with ToolGlows.
- Public-site implementation proof is deferred to its own repository and must include bilingual content tests, check and build.

## Current chantier flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| Specification | complete | Outcome, compatibility boundary, scenarios and proof path are explicit. |
| Readiness | complete | Core/site ownership boundary and unrelated dirty scope are resolved. |
| Implementation | complete | The canonical descriptor now drives help, registration, status, dashboard, Start, Open and project environment guidance. |
| Verification | complete | Focused regressions, parser, metadata, diff, the complete Windows contract and installed ToolGlows help/status/start/open/stop all pass. |
| Closure | complete | Runtime and operator documentation are aligned and the exact separate public-site handoff is recorded. |
| Delivery | complete | Core implementation and live-found fixes are committed and pushed only on `codex/development-runtime`. |

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-28 00:20 UTC | 900-shipglows-core | GPT-5 Codex | Audited CLI and public-site guidance in parallel, resolved the DX/product boundary and formalized the approved cross-surface user journey. | Ready for scenario-first implementation. | Add the focused failing guidance contract, then implement the shared descriptor and consumers. |
| 2026-08-28 01:15 UTC | 900-shipglows-core | GPT-5 Codex | Added the shared project-experience descriptor, user-guided lifecycle output, focused regression and mapped Core documentation. | Focused checks and the complete Windows DevServer contract pass. | Push the bounded Core milestone and replay the official installer with ToolGlows. |
| 2026-08-28 01:55 UTC | 900-shipglows-core | GPT-5 Codex | Replayed the official branch installer, fixed the concatenated project-environment guidance and normalized process start identity across PowerShell JSON representations. | Installed help, stopped recovery, Start, running Status, Open, Stop, listener extinction and process extinction pass on ToolGlows at `c3f985c`. | Hand the exact bilingual public-site contract to the separate product chantier. |
