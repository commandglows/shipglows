# ShipGlows Public Help Catalog

This reference supports the bundled public `shipglows` entrypoint. It is not a separate public skill.

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

The default public route is:

```text
$shipglows <what I want to accomplish>
```

Examples:

```text
$shipglows help me choose the right workflow
$shipglows show available packs
$shipglows explain shipglows-main
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

- `shipglows-build`: implementation lifecycle
- `shipglows-proof`: deploy, browser, auth, production, and QA proof
- `shipglows-content`: content, research, SEO, copy, GTM, and editorial workflows
- `shipglows-design`: UI, UX, design systems, accessibility, and component audits
- `shipglows-quality`: audits, dependencies, performance, migrations, and translation
- `shipglows-product`: onboarding, sync, entitlements, platform parity, exploration, backlog, priorities, and review

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

For a planned workflow:

```text
Ce workflow est prévu dans <pack>, mais il n'est pas encore bundlé dans le plugin public. Route disponible: $shipglows <instruction>. Exécution complète: nécessite le corpus complet ShipGlows ou un futur pack bundlé.
```

For "how do I install ShipGlows in Codex?":

```text
Ajoute d'abord la source marketplace ShipGlows: `codex plugin marketplace add dianedef/ShipGlows --ref main --sparse .agents/plugins --sparse plugins/shipglows`. Redémarre Codex, ouvre le répertoire des plugins, installe `shipglows`, puis commence avec `$shipglows help me choose the right workflow`.
```

For internal tools:

```text
Cet outil est interne à la maintenance de ShipGlows. Il reste hors plugin public utilisateur pour éviter de mélanger l'aide produit avec les workflows de gouvernance interne.
```
