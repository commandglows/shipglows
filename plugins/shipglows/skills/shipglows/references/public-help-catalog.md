# ShipGlows Public Help Catalog

This reference supports the bundled public `shipglows` entrypoint. It is not a
separate public skill. The default vocabulary is métiers: the operator names an
outcome, ShipGlows chooses the lifecycle and packaging engines.

## Public Surface

Start with one route:

```text
$shipglows <what I want to accomplish>
```

To reload the local development context before server or browser work:

```text
$shipglows context
```

This reads the global ShipGlows development environment, the current project's visible `ENVIRONMENT.md`, and its live DevServer registry entry. It reports the exact active URL, the relevant mobile and Windows toolchain state and exact next action, and distinguishes Playwright or Firebase Device Streaming configuration from tools and devices callable in the current turn.

| Domain | Public métier | Owns the outcome |
| --- | --- | --- |
| Create | `sg-development` | Product behavior from intent to verified implementation |
| Create | `sg-design` | Interfaces, design systems, accessibility, visual audits, inspiration, and animation |
| Create | `sg-experience` | Customer journeys, activation, trust, support, and recovery |
| Quality | `sg-bug` | Reproduce, fix, retest, prove, and close a defect |
| Quality | `sg-engineering` | Architecture, code quality, performance, dependencies, sync, access, and platform parity |
| Quality | `sg-maintenance` | Existing-product upkeep and hygiene |
| Publish | `sg-release` | Release readiness, deployment truth, and post-release proof |
| Grow audience | `sg-content` | Public docs, guides, README, FAQ, landing pages, editorial content, and email |
| Grow audience | `sg-marketing` | Market understanding, positioning, GTM, messaging, and persuasion |
| Grow audience | `sg-seo` | Organic-search audits, launches, monitoring, and fixes |
| Govern | `sg-docs` | Internal architecture, governance, metadata, context, and agent documentation |
| Organize | `sg-planning` | Tasks, backlog, priorities, reviews, and portfolio/session steering |
| Organize | `sg-help` | Workflow, métier, mode, and prompt guidance |

`shipglows` is the universal router. It resolves the métier without making the
operator select internal lifecycle stages. A request may cross métiers, but one
public owner remains accountable for the observable outcome.

## Public Boundaries

- `sg-docs` is internal documentation; `sg-content` owns public docs and content.
- `sg-seo` remains a distinct métier, even when it collaborates with content or marketing.
- Sync, data access, entitlements, and platform parity belong to `sg-engineering`; they are not a public data skill.
- A project can contain several products. ShipGlows resolves `project -> product -> surface -> feature` before changing work when that distinction matters.

## Availability Language

Public métier names describe the desired outcome. Their actual execution may be
bundled, partial, planned, or available from the complete corpus. Never imply
that a planned pack is executable in the installed plugin.

## Current Public Plugin

Bundled now:

- `shipglows`: public entrypoint, help, pack router, packaging audit route, and complete-corpus setup guidance
- local plugin references for pack catalog, reference strategy, public help, and `shipglows-main` portability
- packaging audit and complete-corpus setup scripts for local development and approved setup flows

Not bundled now:

- a separate public help skill
- the full internal ShipGlows numbered skill tree
- internal ShipGlows Core operator audits
- optional pack plugins
- private governance, local project memory, transcripts, or machine-specific paths

## Public Pack Status Words

- `bundled now`: usable from the installed plugin in the current Codex session.
- `partial`: the pack has at least one bundled public capability, but the full workflow is not available yet.
- `planned`: named in the roadmap, not yet executable as a bundled plugin capability.
- `internal-first`: useful for ShipGlows maintainers, not a default public user surface.
- `requires complete corpus`: the workflow needs the optional ShipGlows source corpus before it can run beyond public help/routing.

## Recommended User Route

Examples:

```text
$shipglows help me choose the right workflow
$shipglows show available packs
$shipglows I need to fix a checkout regression
$shipglows prepare the next release
$shipglows improve onboarding for our mobile app
$shipglows explain how to install ShipGlows
$shipglows install complete ShipGlows corpus
```

Do not ask users to manually install many separate plugins as the default experience.

## Workflow Availability

### Available Immediately

- Explain the one-plugin model.
- Explain how to add the ShipGlows marketplace source and install the plugin.
- Show the pack catalog and roadmap.
- Explain why a workflow is bundled, partial, planned, or requires the complete corpus.
- Audit packaging readiness when a local ShipGlows source corpus exists.
- Offer the complete-corpus setup script when the user explicitly wants broader local ShipGlows capabilities.

### Partial: `shipglows-main`

`shipglows-main` is the first public pack target.

Bundled now:

- public help and routing through `shipglows`
- public intent routing for `spec`, `ready`, `start`, `verify`, `check`, and `fix` in partial mode

Still planned:

- complete spec creation workflow with ShipGlows tracking files
- complete readiness gate with internal references
- complete execution/start workflow with ShipGlows workflow state
- complete verification workflow with internal proof contracts
- complete checks and bug-fix loops with ShipGlows tools and bug memory

When a user asks for one of these workflows, use the bundled public intent contract first. Continue in public partial mode when possible, and require the complete ShipGlows corpus only when the workflow needs internal tracking, references, tools, or bug memory.

### Planned Packs

Packs are delivery modules behind the public métiers, not choices the operator
must memorize. See `pack-catalog.md` for their portability status and numeric
engine composition.

### Internal-First

`shipglows-governance` and ShipGlows Core style workflows are for ShipGlows maintainers first. They should not be presented as the default public user plugin surface.

## Complete Corpus Route

The complete ShipGlows corpus is optional.

Use it when:

- the user asks for all ShipGlows skills
- a requested workflow needs unbundled skills
- packaging work needs local source inspection
- the user accepts a local source checkout

Before running any setup, require explicit approval for network access and the target directory. The public plugin must remain useful for help and routing without this setup.

## Answer Patterns

For "what can I do now?":

```text
Tu peux utiliser ShipGlows maintenant pour l'aide, le catalogue des packs, la stratégie de packaging, et l'installation optionnelle du corpus complet. Les workflows spec/build/verify sont encore en portage public.
```

For a métier whose required pack is not yet bundled:

```text
Le métier <métier> est bien reconnu, mais son module d'exécution n'est pas encore bundlé dans ce plugin. Route disponible : $shipglows <objectif>. L'exécution complète nécessite le corpus ShipGlows ou un futur pack bundlé.
```

For "how do I install ShipGlows in Codex?":

```text
Ajoute d'abord la source marketplace ShipGlows: `codex plugin marketplace add commandglows/shipglows --ref main --sparse .agents/plugins --sparse plugins/shipglows`. Redémarre Codex, ouvre le répertoire des plugins, installe `shipglows`, puis commence avec `$shipglows help me choose the right workflow`.
```

For internal tools:

```text
Ce moteur est interne à ShipGlows. Il reste hors du catalogue métier pour éviter de mélanger le résultat attendu avec les étapes techniques qui le produisent.
```
