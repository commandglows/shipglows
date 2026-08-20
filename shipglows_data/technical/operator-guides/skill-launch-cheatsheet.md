---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "2.5.0"
project: ShipGlows
created: "2026-05-04"
updated: "2026-08-20"
status: reviewed
source_skill: 900-shipglows-core
scope: skill-launch-cheatsheet
owner: unknown
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - skills/000-shipglows/SKILL.md
  - skills/302-sg-help/SKILL.md
  - skills/references/skill-code-index.md
  - skills/references/question-contract.md
  - skills/references/operator-partnership-contract.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
depends_on: []
supersedes:
  - docs/skill-launch-cheatsheet.md
evidence:
  - "Métier-first public hierarchy and autonomous execution specification."
  - "Current runtime skill inventory and operator collaboration contracts."
  - "Operator decision 2026-08-16: expose current-project hygiene and the safe hygiene git alias."
  - "Operator decision 2026-08-20: expose a global autonomous credit-window mode that always defers local workloads, plus an independent nolocal execution policy for operator-selected work."
  - "Operator refinement 2026-08-20: auto optimizes useful value rather than token burn, recommends useful subagents, stays inside its launch root, and never self-activates Fast."
next_step: "/103-sg-verify public skill catalogue"
---

# Skill Launch Cheatsheet

ShipGlows has a small public surface for choosing work, and a larger internal
engine surface that performs it. Start from the métier, not a numeric code.

## Default Route

Use `shipglows <instruction>` when you do not want to choose a métier. It
resolves the target as far as repository evidence allows, asks only for a
material missing decision, then hands the same conversation to the owner. It
does not leave the operator to invoke the next internal step.

Two global execution modes refine that default:

- `shipglows auto [scope or horizon]` autonomously selects safe work already
  grounded in roadmap, planning, specs, architecture, security, or compliance
  evidence. After safety and authority eligibility, it prioritizes durable
  value per wall-clock minute. It freezes the launch root, coordinates claims
  across concurrent conversations, and recommends subagents when independent
  useful missions exist. It always implies `nolocal`, continues past
  individually blocked candidates, and reports every edit as
  `implemented — unverified`.
- `shipglows nolocal <objective>` keeps the objective and normal métier owner
  selected by the operator, but defers builds, tests, lint, typechecks,
  installation, servers, browsers/devices, containers, migrations, commits,
  pushes, deployments, and external writes. It grants no additional mutation
  authority.

Both modes may read and edit in-scope files and inspect Git status/diffs. `auto`
has no local override and cannot guarantee an exact credit balance because the
runtime may not expose one. It chooses model effort for task quality, never to
burn credits. It uses Fast only when the client already proves it active; enable
it before invocation with `/fast on` when desired.

`mode=excellence` can be set explicitly in `103-sg-verify` requests.
A non-ambiguous natural-language request for excellence maps to `excellence`
(`demande naturelle non ambiguë`) and may return `verified_with_excellence_gaps`
or `excellent`.

The target model is:

```text
project -> product -> surface -> feature
```

A project can contain several products. A product can have several surfaces.
Ask which one is meant only when repository evidence cannot safely resolve it.

## Public Skills

The public catalogue contains the router plus thirteen métier entrypoints.

One exception stays direct: deterministic micro-edits with no domain judgment use focused validation and do not activate a métier lifecycle.
They own the outcome from clarification through appropriate implementation,
proof, documentation reflection, and closure. Shipping, deployment, external
publication, secrets, destructive actions, and device-only proof still require
their normal explicit safeguards.

## Veille, concurrent, inspiration

Une URL peut être précédée d'un mot-clé court :

- `veille <URL>` : analyser la source ; elle n'est pas ajoutée automatiquement au registre.
- `concurrent <URL>` : ajouter la référence au registre interne des concurrents après vérification de la source et des doublons.
- `inspiration <URL>` : ajouter la référence au registre interne des inspirations selon les mêmes contrôles.
- `veille concurrent <URL>` ou `veille inspiration <URL>` : la veille prime ; la source est analysée avant toute décision de conservation.

Ajoute `prix`, `comparatif`, `positionnement`, `recommandation` ou `roadmap` si tu attends une analyse approfondie plutôt qu'un simple enregistrement.

| Domain | Public skill | Owns | Current internal engine(s) |
| --- | --- | --- | --- |
| Router | `shipglows` | Natural-language routing, auto credit windows, nolocal policy, and direct handoff | `000-shipglows`, `708-sg-auto` |
| Créer | `sg-development` | Product, feature, app, code, and site delivery | `001-sg-build` |
| Créer | `sg-design` | Visual system, interface, accessibility, and motion | `006-sg-design` |
| Créer | `sg-experience` | Journeys, activation, onboarding, trust, and recovery | `008-sg-customer` |
| Qualité | `sg-bug` | Observed defects through repair and proof | `003-sg-bug` |
| Qualité | `sg-engineering` | Architecture, dependencies, performance, migration, sync, access, and parity | `010-sg-technical`, `600`, `601`, `602` |
| Qualité | `sg-maintenance` | Recurring upkeep, drift, security posture, and hygiene | `002-sg-maintain` |
| Publier | `sg-release` | Release confidence, deployment, and live proof | `004-sg-deploy` |
| Développer l’audience | `sg-content` | Public documentation and content: docs, FAQ, landing pages, articles, email | `007-sg-content` |
| Développer l’audience | `sg-marketing` | Market, positioning, GTM, and persuasive copy | `009-sg-marketing` |
| Développer l’audience | `sg-seo` | Search audits, launches, monitoring, and fixes | `406-sg-seo` |
| Gouverner | `sg-docs` | Internal documentation, architecture, governance, and metadata | `300-sg-docs` |
| Organiser | `sg-planning` | Tasks, backlog, priorities, reviews, and sessions | `011-sg-pilotage` |
| Organiser | `sg-help` | Orientation, modes, doctrine, and public/expert discovery | `302-sg-help` |

`sg-content` owns documentation written for an audience. `sg-docs` owns the
internal corpus that lets projects and agents operate safely.

Use `shipglows hygiene` for a comprehensive, non-mutating audit of the current
project and one grouped correction proposal. Multi-project hygiene is deferred.
For manual Git hygiene, use `shipglows git` for the read-only dashboard,
`shipglows git reconcile` to review merge candidates, and
`shipglows git clean` to remove proven merged branches and worktrees. These are
Codex skill routes, not PowerShell or shell commands. `shipglows hygiene git`
is the exact safe alias of `shipglows git clean`, never native `git clean`.

Animation uses `sg-design animation <audit|design|implement|tune> [scope]`.
GSAP is optional and must pass project-fit, accessibility, reduced-motion,
performance, and proof gates.

## Clarify Once, Then Deliver

Each public métier follows the same operator contract:

1. Inspect existing project, product, surface, and feature evidence first.
2. Ask one numbered question only when a missing business, scope, safety, or
   external-effect decision would change the work.
3. Do not ask the operator to choose code structure, references, lifecycle
   engines, validation commands, or subagent topology.
4. Once a fresh agent could execute safely, continue A-to-Z under the owner
   métier. Internal handoffs are the agent’s responsibility.
5. Return only for a real decision, permission, secret, destructive effect, or
   proof that genuinely requires the operator.

For a substantial change, the owner creates and validates a durable spec. For a
clear bounded task, it records a compact execution contract and proceeds.

For quality checks, excellence mode can be requested with explicit intent:
`... excellence ...` or `... 103-sg-verify` with `mode=excellence`. This does
not replace specialist audits and does not replace unqualified specialist work.

`103-sg-verify` does not replace an expert/specialist audit (`ne remplace pas un audit spécialiste`).

## Expert / Internal Engines

For short Codex invocation, use an expert alias instead of the numeric engine
name. These are router shortcuts to canonical public skill modes, not shell
commands and not a second workflow taxonomy:

```text
shipglows core <instruction>
shipglows build <instruction>
shipglows verify <instruction>
shipglows status
shipglows resume <instruction>
shipglows ship <instruction>
```

The complete alias map is maintained in
`skills/references/expert-mode-aliases.md`. Resolution follows
`public owner -> owner mode -> internal engine`; `verify` preserves explicit
specialist ownership and `core` alone changes the context to ShipGlows-system
maintenance. Numeric names remain valid for exact runtime lookup and
compatibility.

Numeric names remain valid runtime engines and are intentionally not the
default catalogue. Use `sg-help expert` for their complete list and exact
modes. Typical internal lanes include:

- lifecycle and proof: `100-sg-spec`, `101-sg-ready`, `102-sg-start`,
  `103-sg-verify`, `104-sg-end`, `005-sg-ship`, `105-sg-check`,
  `107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, `405-sg-prod`
- content engines: `200-sg-redact`, `201-sg-enrich`, `202-sg-emailing`,
  `203-sg-research`, `205-sg-veille`
- helpers and context: `301-sg-context`, `303-sg-resume`, `304-sg-changelog`,
  `305-sg-init`, `306-sg-scaffold`, `308-sg-status`, `700-sg-explore`,
  `704-sg-model`, `706-continue`, `707-name`, `708-sg-auto`
- ShipGlows maintenance only: `900-shipglows-core`

Numeric codes are still a precise runtime lookup. They are not a second public
taxonomy and should not be required for normal operation.

## Examples

```text
shipglows Ajoute une animation accessible sur le site marketing
shipglows auto until=18:00
shipglows nolocal Implémente le prochain chantier prêt sans lancer ses validations
sg-engineering Prépare la synchronisation locale/cloud de ce produit
sg-content Mets à jour la FAQ publique après ce changement
sg-docs Mets à jour la documentation interne de cette architecture
sg-help expert
```

Named profiles (`%Victoire`, `%Ariane`) and focus tags (`#SEO`, `#docs`) alter
the decision posture or emphasis; they do not replace the métier owner.

## Runtime Note

In Codex or Claude-style runtimes, invoke the visible public skill name. In
OpenCode or KiloCode, request ShipGlows in natural language or use the runtime
picker. Internal calls such as `skill({ name: "shipglows" })` are runtime
implementation details, not instructions for the operator.
