---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-04-27"
created_at: "2026-04-27 20:01:16 UTC"
updated: "2026-05-02"
updated_at: "2026-05-02 11:46:53 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant que visiteuse du site ShipGlows qui explore le catalogue public de skills, je veux des categories de skills comprehensibles par usage et intention, afin de choisir rapidement le bon workflow sans connaitre la taxonomie interne des chantiers."
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - site/src/content.config.ts
  - site/src/content/skills/*.md
  - site/src/pages/skills/index.astro
  - site/src/pages/skills/[slug].astro
  - site/src/components/SkillCard.astro
  - site/src/pages/skill-modes.astro
depends_on:
  - artifact: "specs/skill-taxonomy-and-chantier-sources.md"
    artifact_version: "1.1.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.3.0"
    required_status: "draft"
supersedes: []
evidence:
  - "User request 2026-04-27: after shipping internal chantier taxonomy, continue with categorizing skills on the website."
  - "Previous spec explicitly scoped public website taxonomy out of the internal chantier taxonomy."
  - "Repo investigation 2026-04-27: initial public site had 48 skill pages grouped into 6 enum categories in site/src/content.config.ts."
  - "sg-docs update 2026-05-02: public catalog now has 49 skill pages after adding sg-browser as a Build & Fix skill."
  - "Repo investigation 2026-04-27: skills hub groups by categoryOrder in site/src/pages/skills/index.astro and detail pages display skill.data.category."
  - "User decision 2026-04-27: use a true public reclassification with Plan & Decide, Build & Fix, Audit & Improve, Research & Grow, Operate & Ship, Meta & Setup."
  - "User decision 2026-04-27: leave continue out of the public catalog for this chantier."
  - "sg-perf advisory 2026-04-27: recategorization has no material performance impact because Astro pages remain static and unhydrated."
next_step: "/sg-end Public skill categories"
---

# Spec: Public Skill Categories

## Title

Public Skill Categories

## Status

ready

## User Story

En tant que visiteuse du site ShipGlows qui explore le catalogue public de skills, je veux des categories de skills comprehensibles par usage et intention, afin de choisir rapidement le bon workflow sans connaitre la taxonomie interne des chantiers.

## Minimal Behavior Contract

Quand une visiteuse ouvre le hub public `/skills`, les skills doivent etre classees dans des categories orientees decision utilisateur, pas dans les roles internes de chantier. Le site doit accepter les categories via le schema Astro de contenu, grouper les pages dans un ordre editorial coherent, afficher des libelles lisibles sur le hub et les pages detail, et echouer clairement au build si une page de skill utilise une categorie non reconnue. Le cas facile a rater est de reutiliser directement `source-de-chantier`, `lifecycle`, `pilotage`, ou `helper`: ces roles sont utiles en interne, mais ils ne sont pas une taxonomie marketing ou pedagogique pour le site public.

## Success Behavior

- Preconditions: les 49 pages publiques sous `site/src/content/skills/` existent, `site/src/content.config.ts` valide leur frontmatter avec `z.enum`, et le hub `/skills` groupe les skills par `categoryOrder`.
- Trigger: une visiteuse ouvre `/skills` ou une page `/skills/[slug]`.
- User/operator result: les categories expliquent mieux l'intention de chaque skill et rendent le catalogue plus scannable.
- System effect: le schema de collection, l'ordre de categories, les frontmatter de skills et les textes du hub restent alignes.
- Success proof: `pnpm --dir shipglows-site astro check` si disponible ou `pnpm --dir shipglows-site build` dans un check dedie; a minima `rg` confirme que chaque categorie frontmatter appartient au schema et que chaque categorie du schema est presente dans `categoryOrder`.
- Silent success: not allowed; le changement doit etre visible dans le hub public et les chips de pages detail.

## Error Behavior

- Expected failures: categorie frontmatter absente du schema, categorie dans le schema absente de `categoryOrder`, categorie sans skill, skill classee dans une categorie trompeuse, ancienne categorie encore referencee dans le contenu ou les pages.
- User/operator response: Astro doit signaler les frontmatter invalides au check/build; le rapport de verification doit lister les categories sans skill ou les skills orphelines.
- System effect: aucune generation de page avec une categorie inconnue; aucune taxonomie interne ne doit apparaitre comme libelle public sans decision explicite.
- Must never happen: casser la collection Astro, perdre une page de skill, melanger taxonomie interne chantier et categorisation publique, ou publier une categorie qui rend le choix moins clair.
- Silent failure: not allowed; toute categorie non reconnue doit etre catchable par schema/check/build.

## Problem

Le catalogue public utilise aujourd'hui six categories larges: `Core Workflow`, `Audits`, `Context & Docs`, `Research & Growth`, `Operations`, et `Meta & Utility`. Elles fonctionnent, mais elles ne racontent pas encore clairement le parcours de choix d'une visiteuse: cadrer le travail, auditer, executer, produire du contenu, piloter, ou maintenir le systeme.

Le chantier interne precedent a cree une taxonomie de process (`Trace category`, `Process role`, `source-de-chantier`), mais cette taxonomie ne doit pas etre exposee telle quelle sur le site. Le site a besoin d'une taxonomie publique pedagogique.

## Solution

Definir une taxonomie publique separee des roles de chantier, puis l'appliquer au schema Astro, au hub `/skills`, et aux frontmatter des pages publiques. La taxonomie retenue est une vraie reclassification publique en six categories: `Plan & Decide`, `Build & Fix`, `Audit & Improve`, `Research & Grow`, `Operate & Ship`, et `Meta & Setup`. `continue` reste hors catalogue public pour ce chantier, car c'est une skill de reprise de conversation interne et non une page utile au choix public d'un workflow.

## Scope In

- Auditer les 49 pages publiques de skills et leurs categories actuelles.
- Appliquer la taxonomie publique retenue: `Plan & Decide`, `Build & Fix`, `Audit & Improve`, `Research & Grow`, `Operate & Ship`, `Meta & Setup`.
- Mettre a jour `site/src/content.config.ts` avec les categories retenues.
- Mettre a jour `categoryOrder` et les textes de section dans `site/src/pages/skills/index.astro`.
- Mettre a jour les frontmatter `category` sous `site/src/content/skills/*.md`.
- Verifier que les pages detail `/skills/[slug]` continuent a afficher une categorie lisible.
- Garder une separation claire avec la taxonomie interne des chantiers.

## Scope Out

- Changer la doctrine interne `Trace category` / `Process role`.
- Ajouter des filtres interactifs, recherche, tags multiples, ou navigation avancee.
- Refaire le design visuel du hub.
- Reecrire toutes les pages de skills au-dela des categories et des microcopies necessaires.
- Ajouter une page publique pour `continue`; cette skill reste volontairement hors catalogue pour ce chantier.
- Categoriser les autres skills absentes du site public.

## Constraints

- La taxonomie publique doit rester courte: idealement 5 a 7 categories.
- La taxonomie publique finale est exactement: `Plan & Decide`, `Build & Fix`, `Audit & Improve`, `Research & Grow`, `Operate & Ship`, `Meta & Setup`.
- Les libelles doivent etre comprehensibles sans connaitre ShipGlows.
- Le schema Astro doit continuer a valider strictement les categories.
- Une skill ne garde qu'une categorie principale dans cette passe; les relations restent portees par `related_skills`.
- Les noms internes `source-de-chantier`, `support-de-chantier`, `pilotage`, `helper`, `obligatoire`, `conditionnel`, `non-applicable` ne doivent pas devenir des categories publiques.
- `continue` ne doit pas etre ajoutee a `site/src/content/skills/` dans ce chantier.

## Dependencies

- Runtime: Astro 6.4.8 from `shipglows-site/pnpm-lock.yaml`, content collections, Zod schema via the existing `astro:content` collection config.
- Document contracts: `specs/skill-taxonomy-and-chantier-sources.md` pour la separation interne/public; `shipglows_data/workflow/playbooks/spec-driven-workflow.md` pour le vocabulaire workflow.
- Metadata gaps: public skill pages use the Astro content schema, not ShipGlows artifact metadata.
- Fresh external docs: fresh-docs checked. Official Astro docs say content collection schemas validate frontmatter and provide typed content querying; the Zod schema utility supports enum validation for schema fields. Sources: https://docs.astro.build/en/guides/content-collections/ and https://docs.astro.build/en/reference/modules/astro-zod/

## Invariants

- Le site public reste pedagogique et marketing, pas une copie de la taxonomie interne.
- Chaque page publique de skill garde une categorie valide.
- `site/src/content.config.ts`, `categoryOrder`, et les frontmatter restent synchronises.
- Les categories vides ne doivent pas apparaitre sur le hub.
- Les pages detail continuent a afficher la categorie via `skill.data.category`.
- Les six categories retenues doivent toutes etre presentes dans le schema et dans `categoryOrder`, dans cet ordre editorial: `Plan & Decide`, `Build & Fix`, `Audit & Improve`, `Research & Grow`, `Operate & Ship`, `Meta & Setup`.
- `continue` reste absent du catalogue public.

## Links & Consequences

- Upstream systems: `site/src/content.config.ts` definit les categories autorisees.
- Downstream systems: `site/src/pages/skills/index.astro`, `site/src/pages/skills/[slug].astro`, et `SkillCard.astro` affichent les categories.
- Cross-cutting checks: SEO/copy coherence for public labels; build/content validation for Astro collection schema; no auth/data/security impact.
- Performance consequence: none material. The affected Astro pages remain static, no client hydration is added, no third-party script is added, and the existing collection grouping stays bounded to 49 public skill pages.

## Documentation Coherence

- `site/src/pages/skills/index.astro` doit expliquer la nouvelle logique de categories et utiliser les six libelles publics retenus.
- `site/src/pages/skill-modes.astro` doit rester coherent si elle decrit comment choisir une skill.
- `CHANGELOG.md` doit mentionner la reorganisation du catalogue public si l'implementation est faite.
- La spec interne `skill-taxonomy-and-chantier-sources.md` reste separee; ne pas la modifier sauf si elle doit pointer vers ce chantier comme suite publique.

## Edge Cases

- Une categorie renommee reste presente dans des frontmatter: le build doit echouer ou `rg` doit la trouver avant ship.
- Une skill comme `sg-fix` peut etre a la fois workflow et diagnostic; elle doit recevoir la categorie la plus utile pour le choix public, pas toutes ses facettes.
- `continue` existe comme skill interne mais n'a pas de page publique actuelle; ne pas l'ajouter dans ce chantier.
- Les categories publiques peuvent differer de la taxonomie de process sans etre contradictoires.
- Les pages detail affichent seulement une chip; un libelle trop long peut degrader l'UI.
- Une skill peut sembler appartenir a deux categories; choisir la categorie la plus utile pour une visiteuse qui cherche quoi faire maintenant, pas la categorie qui decrit le mieux son role interne.

## Target Classification Map

| Category | Public intent | Skills |
|----------|---------------|--------|
| `Plan & Decide` | Clarifier, cadrer, prioriser ou choisir avant de modifier le repo. | `sg-backlog`, `sg-context`, `sg-explore`, `sg-model`, `sg-priorities`, `sg-ready`, `sg-spec`, `sg-review` |
| `Build & Fix` | Entrer dans l'execution concrete, corriger, tester ou creer des fichiers. | `sg-auth-debug`, `sg-browser`, `sg-fix`, `sg-scaffold`, `sg-start`, `sg-test` |
| `Audit & Improve` | Inspecter la qualite, trouver les risques, verifier ou ameliorer un systeme existant. | `sg-audit`, `sg-audit-a11y`, `sg-audit-code`, `sg-audit-components`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-design`, `sg-audit-design-tokens`, `sg-audit-gtm`, `sg-audit-seo`, `sg-audit-translate`, `sg-deps`, `sg-perf`, `sg-verify` |
| `Research & Grow` | Produire, enrichir ou transformer de l'information utile au contenu, au marche ou a la croissance. | `sg-enrich`, `sg-market-study`, `sg-redact`, `sg-repurpose`, `sg-research`, `sg-veille` |
| `Operate & Ship` | Garder le projet exploitable, documente, verifie, deploye et pret a etre livre. | `sg-check`, `sg-changelog`, `sg-docs`, `sg-end`, `sg-migrate`, `sg-prod`, `sg-ship`, `sg-status`, `sg-tasks` |
| `Meta & Setup` | Installer, expliquer ou maintenir le systeme ShipGlows lui-meme. | `name`, `sg-design-playground`, `sg-help`, `sg-init`, `sg-resume`, `sg-skills-refresh` |

`continue` is intentionally absent from this map and must remain absent from the public catalog in this chantier.

## Implementation Tasks

- [x] Task 1: Inventorier la distribution actuelle
  - File: `site/src/content/skills/*.md`
  - Action: Lister les 49 pages, categories actuelles, et skills eventuellement absentes du site public.
  - User story link: Evite de changer les categories sans comprendre le catalogue.
  - Depends on: None
  - Validate with: `for c in "Core Workflow" Audits "Context & Docs" "Research & Growth" Operations "Meta & Utility"; do rg -l "^category: \"$c\"" site/src/content/skills/*.md | wc -l; done`
  - Notes: `continue` est absent du site public dans l'etat inspecte.

- [x] Task 2: Appliquer la taxonomie publique retenue au contrat de categorie
  - File: `site/src/content.config.ts`, `site/src/pages/skills/index.astro`
  - Action: Utiliser exactement `Plan & Decide`, `Build & Fix`, `Audit & Improve`, `Research & Grow`, `Operate & Ship`, `Meta & Setup`, dans cet ordre editorial.
  - User story link: Rend le hub lisible par intention de travail.
  - Depends on: Task 1
  - Validate with: `rg -n "Plan & Decide|Build & Fix|Audit & Improve|Research & Grow|Operate & Ship|Meta & Setup" site/src/content.config.ts site/src/pages/skills/index.astro`
  - Notes: Ne pas reutiliser les noms internes ni les anciennes categories publiques.

- [x] Task 3: Mettre a jour le schema Astro
  - File: `site/src/content.config.ts`
  - Action: Remplacer le `z.enum` des categories par les libelles retenus.
  - User story link: Garantit que les frontmatter restent strictement valides.
  - Depends on: Task 2
  - Validate with: `rg -n "Plan & Decide|Build & Fix|Audit & Improve|Research & Grow|Operate & Ship|Meta & Setup" site/src/content.config.ts`
  - Notes: L'ordre du `z.enum` doit correspondre a l'ordre editorial du hub.

- [x] Task 4: Reclasser les pages publiques de skills
  - File: `site/src/content/skills/*.md`
  - Action: Mettre a jour chaque frontmatter `category` selon `Target Classification Map`.
  - User story link: Chaque skill apparait dans le bon rayon du catalogue.
  - Depends on: Task 3
  - Validate with: `rg -n '^category: "(Core Workflow|Audits|Context & Docs|Research & Growth|Operations|Meta & Utility)"' shipglows-site/src/content/skills/*.md` returns no matches, then `pnpm --dir shipglows-site build`.
  - Notes: Garder une categorie principale par skill; ne pas creer `shipglows-site/src/content/skills/continue.md`.

- [x] Task 5: Aligner le hub public
  - File: `site/src/pages/skills/index.astro`
  - Action: Mettre a jour `categoryOrder` et les textes de section pour expliquer les nouvelles categories.
  - User story link: La visiteuse comprend comment choisir la bonne skill.
  - Depends on: Tasks 2-4
  - Validate with: `rg -n "categoryOrder|Plan & Decide|Build & Fix|Audit & Improve|Research & Grow|Operate & Ship|Meta & Setup" site/src/pages/skills/index.astro`
  - Notes: Pas de refonte design.

- [x] Task 6: Verifier l'affichage des pages detail
  - File: `site/src/pages/skills/[slug].astro`, `site/src/components/SkillCard.astro`
  - Action: Confirmer que les nouveaux libelles tiennent dans les chips et cartes; ajuster microcopy seulement si necessaire.
  - User story link: Les categories restent visibles sans casser l'UI.
  - Depends on: Tasks 3-5
  - Validate with: `pnpm --dir shipglows-site build`
  - Notes: Si le build est trop long, au minimum lancer le check Astro disponible ou un scan de schema.

- [ ] Task 7: Mettre a jour le changelog
  - File: `CHANGELOG.md`
  - Action: Ajouter une entree courte sur la reorganisation du catalogue public de skills.
  - User story link: Rend visible le changement de site public.
  - Depends on: Tasks 3-6
  - Validate with: `rg -n "skill catalog|categories|skills" CHANGELOG.md`
  - Notes: A faire pendant `sg-end` si l'implementation suit le flux normal.

## Acceptance Criteria

- [ ] AC 1: Given le hub `/skills`, when une visiteuse scanne les sections, then les categories decrivent des intentions publiques et non des roles internes de chantier.
- [ ] AC 2: Given une page `site/src/content/skills/*.md`, when son frontmatter est lu, then `category` appartient au `z.enum` de `site/src/content.config.ts`.
- [ ] AC 3: Given `site/src/pages/skills/index.astro`, when `categoryOrder` est lu, then chaque categorie autorisee y figure une seule fois dans un ordre coherent.
- [ ] AC 4: Given une ancienne categorie retiree, when on lance un scan, then elle n'apparait plus dans les frontmatter ni dans les textes publics sauf historique justifie.
- [ ] AC 5: Given les roles internes `source-de-chantier`, `lifecycle`, `pilotage`, `helper`, when on scanne le site public, then ils ne sont pas utilises comme categories publiques.
- [ ] AC 6: Given le build/check du site, when il est lance, then aucune page de skill ne casse la collection Astro.
- [ ] AC 7: Given la taxonomie retenue, when on lit le schema et le hub, then les seules categories publiques sont `Plan & Decide`, `Build & Fix`, `Audit & Improve`, `Research & Grow`, `Operate & Ship`, `Meta & Setup`.
- [ ] AC 8: Given la skill interne `continue`, when on inspecte `site/src/content/skills/`, then aucune page publique `continue.md` n'a ete creee pour ce chantier.
- [ ] AC 9: Given les 49 pages publiques existantes, when on compare leur `category` a `Target Classification Map`, then chaque skill est classee dans la categorie cible indiquee.

## Test Strategy

- Unit: None, because this is content/schema taxonomy.
- Integration: `pnpm --dir shipglows-site build` after implementation.
- Manual: Review `/skills` grouping and one representative detail page per category.
- Regression: `rg` scans for category schema/order/frontmatter alignment, absence of internal role labels as public categories, absence of old public category names in frontmatter, and absence of `shipglows-site/src/content/skills/continue.md`.

## Risks

- Security impact: none, because no auth/data/runtime secrets are touched.
- Product/data/performance risk: medium public-copy risk; confusing categories can make the catalog worse. Mitigation: use the approved six-category map and verify every public skill against `Target Classification Map`.
- Performance impact: none material, because this remains static Astro content with no added hydration, network fetching, third-party script, or heavy client work.
- Maintenance risk: category schema and frontmatter can drift. Mitigation: strict `z.enum` and build/check before ship.

## Execution Notes

- Read first: `shipglows-site/src/content.config.ts`, `shipglows-site/src/pages/skills/index.astro`, `shipglows-site/src/pages/skills/[slug].astro`, `shipglows-site/src/components/SkillCard.astro`, representative `shipglows-site/src/content/skills/*.md`.
- Validate with: `pnpm --dir shipglows-site build`, `rg -n '^category:' shipglows-site/src/content/skills/*.md`, `rg -n '^category: "(Core Workflow|Audits|Context & Docs|Research & Growth|Operations|Meta & Utility)"' shipglows-site/src/content/skills/*.md`, `test ! -f shipglows-site/src/content/skills/continue.md`.
- Stop conditions: if implementation discovers a public skill page not listed in `Target Classification Map`, pause and update the spec before recategorizing it; if Astro docs conflict with the schema approach, reroute.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-27 20:01:16 UTC | sg-spec | GPT-5 Codex | Created spec for public skill categories | draft | /sg-ready Public skill categories |
| 2026-04-27 20:02:53 UTC | continue | GPT-5 Codex | Routed from shipped internal taxonomy chantier to public skill categories chantier | routed | /sg-ready Public skill categories |
| 2026-04-27 20:09:47 UTC | sg-ready | GPT-5 Codex | Reviewed readiness of public skill categories spec; blocked on unresolved public taxonomy and catalog scope decisions | not ready | /sg-spec Public skill categories |
| 2026-04-27 20:28:15 UTC | sg-ready | GPT-5 Codex | Re-ran readiness gate without new product decisions; spec remains blocked on taxonomy and catalog-scope choices | not ready | /sg-spec Public skill categories |
| 2026-04-27 20:31:18 UTC | sg-perf | GPT-5 Codex | Audited performance impact of public skill category recategorization on Astro catalog pages | advisory | /sg-spec Public skill categories |
| 2026-04-27 20:31:55 UTC | sg-ready | GPT-5 Codex | Re-ran readiness after perf advisory; no product decision resolved, spec remains not ready | not ready | /sg-spec Public skill categories |
| 2026-04-27 21:10:38 UTC | sg-spec | GPT-5 Codex | Integrated user decision: true public reclassification, exact six-category taxonomy, continue excluded, target classification map added | draft updated | /sg-ready Public skill categories |
| 2026-04-27 21:20:15 UTC | sg-ready | GPT-5 Codex | Validated final public taxonomy, target classification map, Astro schema/build validation plan, docs coherence, and security scope | ready | /sg-start Public skill categories |
| 2026-04-27 21:28:30 UTC | sg-start | GPT-5 Codex | Implemented public category reclassification across schema, hub ordering/copy, and 48 skill frontmatters; validated with Astro build | implemented | /sg-verify Public skill categories |
| 2026-04-27 22:22:48 UTC | sg-verify | GPT-5 Codex | Verified user-story delivery, schema/order/frontmatter alignment, and classification map against spec; no blocking risk found | verified | /sg-end Public skill categories |
| 2026-04-27 22:26:00 UTC | sg-docs | GPT-5 Codex | Audited documentation coherence for public category reclassification; confirmed hub/docs alignment and identified changelog entry still pending | advisory | /sg-end Public skill categories |
| 2026-04-27 22:35:25 UTC | sg-ship | GPT-5 Codex | Quick shipped public category reclassification changes for iteration after lightweight checks and bug gate | shipped | /sg-end Public skill categories |

## Current Chantier Flow

- `sg-spec`: done, final taxonomy and classification map defined.
- `sg-ready`: ready.
- `sg-start`: implemented.
- `sg-verify`: verified.
- `sg-end`: not launched.
- `sg-ship`: shipped.

Next step: `/sg-end Public skill categories`
