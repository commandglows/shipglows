---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-04-27"
created_at: "2026-04-27 19:34:21 UTC"
updated: "2026-05-02"
updated_at: "2026-05-02 11:46:53 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice ShipGlows qui lance des skills d'audit, diagnostic, verification et pilotage, je veux que chaque skill sache si elle peut etre source d'un chantier et comment formaliser la suite, afin que les travaux importants ne restent pas bloques dans un simple rapport de conversation."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/chantier-tracking.md
  - skills/sg-help/SKILL.md
  - skills/*/SKILL.md
  - specs/
  - templates/spec.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
depends_on:
  - artifact: "specs/specs-as-chantier-registry.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "templates/spec.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "User decision 2026-04-27: focus only on internal taxonomy and chantier process; public website taxonomy is out of scope for now."
  - "User problem 2026-04-27: audit and diagnostic skills can produce important follow-up work that remains trapped in the conversation."
  - "Repo investigation 2026-04-27: current chantier doctrine only supports obligatoire, conditionnel, and non-applicable spec tracing."
  - "Repo investigation 2026-04-27: sg-deps, sg-perf, sg-audit, sg-check, sg-test, sg-prod, sg-migrate, and sg-auth-debug are currently conditionnel but can originate new chantiers."
  - "sg-docs update 2026-05-02: sg-browser is a conditionnel/source-de-chantier skill for generic non-auth browser evidence."
next_step: "None"
---

# Spec: Skill Taxonomy and Chantier Sources

## Title

Skill Taxonomy and Chantier Sources

## Status

ready

## User Story

En tant qu'utilisatrice ShipGlows qui lance des skills d'audit, diagnostic, verification et pilotage, je veux que chaque skill sache si elle peut etre source d'un chantier et comment formaliser la suite, afin que les travaux importants ne restent pas bloques dans un simple rapport de conversation.

## Minimal Behavior Contract

Quand une skill ShipGlows termine un travail qui revele plus qu'une action immediate, elle doit determiner si son resultat est un chantier potentiel, l'indiquer explicitement dans son rapport final, et orienter vers une spec durable quand le travail necessite de la reflexion, des decisions, plusieurs etapes, ou une verification ulterieure. Si un chantier existe deja, la skill continue a tracer selon la doctrine actuelle; si aucun chantier unique n'existe mais que le rapport revele un vrai travail a suivre, elle ne doit pas ecrire au hasard dans une spec existante, mais produire un bloc `Chantier potentiel` avec titre propose, raison, severite, scope, evidence et prochaine commande `/sg-spec ...`. Le cas facile a rater est une skill `conditionnel` comme `sg-deps` ou `sg-perf`: elle ne peut pas tracer dans une spec ambigue, mais elle peut et doit recommander la creation d'un chantier quand ses findings depassent un simple fix direct.

## Success Behavior

- Preconditions: ShipGlows possede deja une doctrine de chantier dans `skills/references/chantier-tracking.md`, une matrice `obligatoire/conditionnel/non-applicable`, et des `SKILL.md` avec blocs `Chantier Tracking`.
- Trigger: une skill produit un audit, un diagnostic, une verification, une revue, ou un rapport qui contient des actions futures non triviales.
- User/operator result: le rapport final dit clairement si la skill est `source-de-chantier`, si un chantier potentiel existe, et quelle prochaine commande lancer.
- System effect: la doctrine de chantier contient une taxonomie interne augmentee; les skills concernees contiennent une instruction standard de detection de chantier potentiel; `sg-help` documente les categories.
- Success proof: lancer ou relire `sg-deps`, `sg-perf`, `sg-audit`, `sg-check` ou `sg-prod` montre un format standard qui ne laisse plus les findings critiques seulement dans la conversation.
- Silent success: not allowed; une skill source qui revele un chantier potentiel doit le dire explicitement dans le rapport.

## Error Behavior

- Expected failures: plusieurs specs candidates, aucun chantier existant, findings trop faibles pour justifier une spec, rapport incomplet, seuil de severite ambigu, skill helper non concernee.
- User/operator response: le rapport final doit dire `Chantier potentiel: oui`, `non`, ou `incertain`, avec une raison concrete et une prochaine action.
- System effect: aucune ecriture speculative dans une spec existante; aucune creation automatique de spec sans passage par `sg-spec`.
- Must never happen: rattacher un audit a la mauvaise spec, ouvrir un chantier pour chaque micro-finding, laisser un P0/P1 sans prochaine etape, confondre taxonomie publique du site et taxonomie interne du process, creer un registre parallele hors `specs/`.
- Silent failure: not allowed; si une skill source ne peut pas evaluer le chantier potentiel, elle doit indiquer la preuve manquante.

## Problem

La doctrine actuelle resout la tracabilite d'un chantier deja identifie, mais pas l'amont du probleme: beaucoup de skills decouvrent elles-memes le chantier. Un audit de dependencies, performance, code, SEO, auth ou prod peut produire des dizaines de findings. Sans mecanisme explicite, le rapport reste dans la conversation, puis l'utilisateur doit relancer manuellement `sg-spec` en reconstituant le contexte.

Cela rend le systeme incoherent: `sg-spec` sait creer un chantier, les lifecycle skills savent le suivre, mais les skills qui decouvrent le travail n'ont pas de responsabilite claire pour transformer un signal en chantier potentiel.

## Solution

Etendre la doctrine avec une seconde taxonomie interne: la categorie de tracing reste `obligatoire`, `conditionnel`, `non-applicable`, mais chaque skill recoit aussi une capacite de lifecycle, dont `source-de-chantier`. Les skills sources appliquent un seuil standard et terminent leurs rapports avec un bloc `Chantier potentiel`; quand le seuil est atteint, elles recommandent une commande `/sg-spec` pre-remplie et fournissent les elements minimaux a copier dans la future spec.

## Scope In

- Definir la taxonomie interne des skills pour le process chantier.
- Ajouter le concept `source-de-chantier` sans remplacer `obligatoire/conditionnel/non-applicable`.
- Definir les seuils qui transforment un rapport en chantier potentiel.
- Definir un bloc final standard `Chantier potentiel`.
- Classer les skills existantes entre `source-de-chantier`, `support-de-chantier`, `lifecycle`, `pilotage`, et `helper`.
- Mettre a jour `skills/references/chantier-tracking.md`.
- Mettre a jour `skills/sg-help/SKILL.md`.
- Mettre a jour les `SKILL.md` des principales sources de chantier.
- Garder `specs/` comme registre unique des chantiers.

## Scope Out

- Taxonomie commerciale ou marketing pour le site public ShipGlows.
- Design de page web, cards, filtres ou navigation de site.
- Creation automatique d'une spec depuis une skill source sans passer par `sg-spec`.
- Retroconversion de tous les anciens rapports de conversation en specs.
- Changement du format `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md`.
- Refonte complete du systeme de skills ou de marketplace.

## Constraints

- La taxonomie publique future peut differer de la taxonomie interne; cette spec ne doit pas figer le site.
- `source-de-chantier` est une capacite de process, pas une categorie exclusive: une skill peut etre `conditionnel` pour le tracing et `source-de-chantier` pour l'intake.
- Les skills ne doivent pas ecrire dans une spec ambigue.
- Les skills sources ne doivent pas noyer l'utilisateur avec une spec pour chaque finding mineur.
- Le seuil doit favoriser la tracabilite des travaux qui demandent de la reflexion, des decisions, plusieurs etapes, ou une validation.
- Les rapports doivent rester lisibles et actionnables.

## Dependencies

- Runtime: markdown, YAML frontmatter, instructions de skills ShipGlows.
- Document contracts: `specs/specs-as-chantier-registry.md`, `skills/references/chantier-tracking.md`, `templates/spec.md`.
- Metadata gaps: `skills/references/chantier-tracking.md` est encore `status: draft`; cette spec depend de sa forme actuelle et devra le mettre a jour.
- Fresh external docs: fresh-docs not needed, because the change is local to ShipGlows process and markdown skill instructions.

## Invariants

- `specs/` reste le registre global des chantiers.
- Une skill source ne cree pas de spec directement; elle recommande `sg-spec` avec assez de contexte.
- Une skill conditionnelle attachee a un chantier unique continue a tracer dans ce chantier.
- Une skill conditionnelle sans chantier unique ne trace pas dans une spec existante au hasard.
- La matrice actuelle de tracing reste valide mais devient insuffisante seule.
- Un agent frais doit pouvoir comprendre depuis la doctrine si une skill peut creer un chantier potentiel.

## Links & Consequences

- Upstream systems: `sg-spec` reste l'entree de creation durable; les sources lui fournissent titre, raison, evidence, scope et next step.
- Downstream systems: `sg-ready`, `sg-start`, `sg-verify`, `sg-end`, `sg-ship` continuent le cycle apres creation de la spec.
- Cross-cutting checks: audits, deps, perf, tests, prod, migrations et debug auth doivent evaluer le potentiel chantier a la fin du rapport.
- Operational trackers: `TASKS.md` et `AUDIT_LOG.md` peuvent rester utiles pour les audits, mais ne remplacent pas le chantier quand une vraie decision/spec est necessaire.
- Documentation impact: `sg-help` et `shipglows_data/workflow/playbooks/spec-driven-workflow.md` doivent expliquer les deux axes: tracing category et process role.

## Documentation Coherence

- `skills/references/chantier-tracking.md` doit documenter `Trace category` et `Process role` comme deux champs separes.
- `skills/sg-help/SKILL.md` doit afficher une matrice lisible des roles internes.
- `skills/sg-spec/SKILL.md` doit accepter une entree provenant d'une skill source et reprendre son contexte sans le perdre.
- Les skills sources doivent inclure le bloc `Chantier potentiel`.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md` doit expliquer le flux: source skill -> chantier potentiel -> `sg-spec` -> `sg-ready` -> `sg-start`.
- `CHANGELOG.md` doit mentionner l'ajout du role `source-de-chantier`.

## Edge Cases

- Un audit trouve un seul fix trivial: `Chantier potentiel: non`, prochaine etape directe possible.
- Un audit trouve plusieurs P2 mais aucun P0/P1: `Chantier potentiel: oui` si les corrections touchent plusieurs fichiers ou demandent arbitrage.
- `sg-deps` trouve des vulnerabilites critiques mais deux specs actives existent: ne pas ecrire dans une spec; recommander une nouvelle spec ou demander selection explicite.
- `sg-prod` revele une panne: chantier potentiel incident, meme si aucune spec n'existait.
- `sg-check` echoue sur une erreur locale mono-fichier: pas forcement chantier; orienter vers fix direct.
- `sg-test` revele un bug critique avec dossier bug: peut etre source d'un chantier bug si la correction depasse la retouche directe.
- `sg-backlog` capture une idee vague: pilotage, pas source automatique, sauf si l'utilisateur demande explicitement de cadrer en spec.
- Une skill helper comme `sg-context` ne doit pas devenir source seulement parce qu'elle lit du contexte.

## Implementation Tasks

- [x] Task 1: Etendre la doctrine chantier avec deux axes de classification
  - File: `skills/references/chantier-tracking.md`
  - Action: Ajouter la distinction `Trace category` (`obligatoire`, `conditionnel`, `non-applicable`) et `Process role` (`lifecycle`, `source-de-chantier`, `support-de-chantier`, `pilotage`, `helper`).
  - User story link: Evite de confondre "peut ecrire dans une spec existante" et "peut reveler un chantier a creer".
  - Depends on: None
  - Validate with: `rg -n "source-de-chantier|Process role|Trace category|Chantier potentiel" skills/references/chantier-tracking.md`
  - Notes: Garder la compatibilite avec les instructions existantes.

- [x] Task 2: Definir le seuil standard de chantier potentiel
  - File: `skills/references/chantier-tracking.md`
  - Action: Documenter les criteres: P0/P1, plusieurs fichiers ou domaines, decision produit/technique, migration, risque secu/data/prod, besoin de validation, travail impossible a finir en un fix direct.
  - User story link: Les skills sources savent quand recommander une spec.
  - Depends on: Task 1
  - Validate with: `rg -n "seuil|P0|P1|plusieurs fichiers|decision|validation" skills/references/chantier-tracking.md`
  - Notes: Le seuil doit aussi dire quand ne pas creer de chantier.

- [x] Task 3: Definir le bloc standard `Chantier potentiel`
  - File: `skills/references/chantier-tracking.md`
  - Action: Ajouter un format final avec `Chantier potentiel`, `Titre propose`, `Raison`, `Severite`, `Scope`, `Evidence`, `Spec recommandee`, `Prochaine etape`.
  - User story link: Les findings importants deviennent actionnables sans relire toute la conversation.
  - Depends on: Task 2
  - Validate with: `rg -n "Titre propose|Spec recommandee|Prochaine etape|Evidence" skills/references/chantier-tracking.md`
  - Notes: Le bloc doit coexister avec le bloc `Chantier`.

- [x] Task 4: Produire la matrice interne des roles pour toutes les skills
  - File: `skills/sg-help/SKILL.md`
  - Action: Ajouter une matrice `Skill | Trace category | Process role | Source threshold`.
  - User story link: Donne une vue coherente des 46 skills sans imposer une logique unique a toutes.
  - Depends on: Tasks 1-3
  - Validate with: `rg -n "Process role|source-de-chantier|support-de-chantier|pilotage|helper" skills/sg-help/SKILL.md`
  - Notes: Inclure `continue` ou documenter explicitement son statut manquant si la skill reste hors matrice actuelle.

- [x] Task 5: Mettre a jour `sg-spec` pour consommer un rapport source
  - File: `skills/sg-spec/SKILL.md`
  - Action: Ajouter l'instruction: si l'entree contient un bloc `Chantier potentiel`, reprendre titre, evidence, scope, severite et next step dans la spec.
  - User story link: La transition rapport -> spec ne perd pas le contexte.
  - Depends on: Task 3
  - Validate with: `rg -n "Chantier potentiel|Titre propose|Evidence|source-de-chantier" skills/sg-spec/SKILL.md`
  - Notes: `sg-spec` reste la seule skill qui cree la spec durable.

- [x] Task 6: Mettre a jour les sources audit et diagnostic prioritaires
  - File: `skills/sg-deps/SKILL.md`, `skills/sg-perf/SKILL.md`, `skills/sg-audit/SKILL.md`, `skills/sg-audit-code/SKILL.md`, `skills/sg-audit-design/SKILL.md`, `skills/sg-audit-a11y/SKILL.md`, `skills/sg-audit-components/SKILL.md`, `skills/sg-audit-seo/SKILL.md`, `skills/sg-audit-gtm/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-audit-translate/SKILL.md`, `skills/sg-audit-design-tokens/SKILL.md`
  - Action: Ajouter `Process role: source-de-chantier` et le bloc `Chantier potentiel` dans les instructions de rapport.
  - User story link: Les audits ne laissent plus leurs corrections majeures dans la conversation.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "source-de-chantier|Chantier potentiel" skills/sg-deps/SKILL.md skills/sg-perf/SKILL.md skills/sg-audit*/SKILL.md`
  - Notes: Les sous-audits peuvent proposer un chantier specialise; `sg-audit` peut proposer un chantier transversal.

- [x] Task 7: Mettre a jour les sources incident, verification et migration
  - File: `skills/sg-auth-debug/SKILL.md`, `skills/sg-browser/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-check/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-migrate/SKILL.md`, `skills/sg-fix/SKILL.md`
  - Action: Ajouter le role source quand les resultats depassent le fix direct; documenter les seuils spec-first.
  - User story link: Les bugs, incidents, migrations et echecs de validation deviennent des chantiers quand le risque le justifie.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "source-de-chantier|Chantier potentiel|spec-first" skills/sg-auth-debug/SKILL.md skills/sg-browser/SKILL.md skills/sg-prod/SKILL.md skills/sg-check/SKILL.md skills/sg-test/SKILL.md skills/sg-migrate/SKILL.md skills/sg-fix/SKILL.md`
  - Notes: Garder la possibilite de correction directe pour les problemes locaux.

- [x] Task 8: Classer les skills de contenu, recherche et pilotage
  - File: `skills/sg-market-study/SKILL.md`, `skills/sg-veille/SKILL.md`, `skills/sg-research/SKILL.md`, `skills/sg-docs/SKILL.md`, `skills/sg-enrich/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-repurpose/SKILL.md`, `skills/sg-review/SKILL.md`, `skills/sg-priorities/SKILL.md`, `skills/sg-backlog/SKILL.md`, `skills/sg-tasks/SKILL.md`
  - Action: Assigner `source-de-chantier`, `support-de-chantier`, ou `pilotage` selon le role; ajouter le bloc seulement aux vraies sources.
  - User story link: Les rapports strategiques ou contenus peuvent ouvrir un chantier quand il y a une vraie suite a formaliser.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "Process role|source-de-chantier|support-de-chantier|pilotage|Chantier potentiel" skills/sg-market-study/SKILL.md skills/sg-veille/SKILL.md skills/sg-research/SKILL.md skills/sg-docs/SKILL.md skills/sg-enrich/SKILL.md skills/sg-redact/SKILL.md skills/sg-repurpose/SKILL.md skills/sg-review/SKILL.md skills/sg-priorities/SKILL.md skills/sg-backlog/SKILL.md skills/sg-tasks/SKILL.md`
  - Notes: Eviter de transformer chaque idee de backlog en chantier.

- [x] Task 9: Documenter les helpers et lifecycle non sources
  - File: `skills/sg-context/SKILL.md`, `skills/sg-model/SKILL.md`, `skills/sg-help/SKILL.md`, `skills/sg-status/SKILL.md`, `skills/sg-resume/SKILL.md`, `skills/sg-explore/SKILL.md`, `skills/name/SKILL.md`, `skills/continue/SKILL.md`, `skills/sg-ready/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/sg-verify/SKILL.md`, `skills/sg-end/SKILL.md`, `skills/sg-ship/SKILL.md`
  - Action: Confirmer leur role `helper` ou `lifecycle`, et documenter quand ils doivent router vers une source ou vers `sg-spec` au lieu de devenir source eux-memes.
  - User story link: Les skills ne se sentent plus perdues apres execution: chacune connait sa responsabilite.
  - Depends on: Task 4
  - Validate with: `rg -n "Process role|helper|lifecycle|source-de-chantier" skills/sg-context/SKILL.md skills/sg-model/SKILL.md skills/sg-help/SKILL.md skills/sg-status/SKILL.md skills/sg-resume/SKILL.md skills/sg-explore/SKILL.md skills/name/SKILL.md skills/continue/SKILL.md skills/sg-ready/SKILL.md skills/sg-start/SKILL.md skills/sg-verify/SKILL.md skills/sg-end/SKILL.md skills/sg-ship/SKILL.md`
  - Notes: `continue` avait une categorie chantier manquante pendant l'investigation; il faut la normaliser ou l'exclure explicitement.

- [x] Task 10: Mettre a jour le workflow spec-driven
  - File: `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Action: Ajouter le flux `source skill -> Chantier potentiel -> sg-spec -> sg-ready -> sg-start -> sg-verify -> sg-end/sg-ship`.
  - User story link: Rend le processus transmissible a un agent frais.
  - Depends on: Tasks 1-9
  - Validate with: `rg -n "Chantier potentiel|source skill|source-de-chantier|sg-spec" shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Notes: Ne pas inclure la taxonomie du site public.

- [x] Task 11: Ajouter la validation de coherence
  - File: `skills/sg-verify/SKILL.md`
  - Action: Ajouter un check de coherence: toute skill modifiee doit avoir `Trace category` et `Process role`; les sources doivent avoir le bloc `Chantier potentiel`.
  - User story link: Evite les regressions quand de nouvelles skills sont ajoutees.
  - Depends on: Tasks 1-10
  - Validate with: `rg -n "Trace category|Process role|Chantier potentiel" skills/sg-verify/SKILL.md`
  - Notes: Si un script de lint metadata existe ou devient necessaire, le proposer comme suivi, pas comme precondition.

- [x] Task 12: Ajouter l'entree changelog
  - File: `CHANGELOG.md`
  - Action: Documenter l'ajout de la taxonomie interne et du role `source-de-chantier`.
  - User story link: Garde une trace du changement de processus ShipGlows.
  - Depends on: Tasks 1-11
  - Validate with: `rg -n "source-de-chantier|Chantier potentiel|skill taxonomy" CHANGELOG.md`
  - Notes: Entree courte, orientee process.

## Acceptance Criteria

- [x] AC 1: Given une skill existante, when on lit sa section chantier, then elle expose ou herite clairement d'une `Trace category` et d'un `Process role`.
- [x] AC 2: Given `sg-deps` trouve des vulnerabilites critiques sans chantier unique, when son rapport final est produit, then il ne modifie aucune spec existante et affiche `Chantier potentiel: oui` avec une commande `/sg-spec`.
- [x] AC 3: Given `sg-perf` trouve seulement une optimisation mineure locale, when son rapport final est produit, then il peut afficher `Chantier potentiel: non` avec raison.
- [x] AC 4: Given `sg-audit` trouve plusieurs problemes P1/P2 transverses, when son rapport final est produit, then il propose un titre de chantier transversal et les evidences principales.
- [x] AC 5: Given une skill source est lancee dans un chantier unique existant, when elle termine, then elle conserve le bloc `Chantier` existant et peut ajouter `Chantier potentiel: non` si le travail reste dans le chantier courant.
- [x] AC 6: Given `sg-spec` recoit un bloc `Chantier potentiel`, when elle cree la spec, then elle reprend le titre, la raison, le scope, la severite et les evidences dans la nouvelle spec.
- [x] AC 7: Given une skill helper comme `sg-context`, when elle est lancee, then elle ne se declare pas source et ne propose pas de chantier hors demande explicite.
- [x] AC 8: Given une nouvelle skill est ajoutee plus tard, when `sg-verify` ou la checklist de coherence est appliquee, then l'absence de `Trace category` ou `Process role` est signalee.

## Test Strategy

- Unit: None, because this is a markdown/process change unless a lint script is added later.
- Integration: Run `rg` validations from the implementation tasks across modified skills and docs.
- Manual: Review one lifecycle skill, one source skill, one support/pilotage skill, and one helper skill to confirm the final reports have the expected routing.
- Regression: Re-run `/sg-ready Skill taxonomy and chantier sources` before implementation, then `/sg-verify` after changes.

## Risks

- Security impact: none, because this is process metadata and reporting. Indirectly, better source detection should improve security follow-up for deps/auth/prod findings.
- Product/data/performance risk: medium process risk; too many source prompts could create noise. Mitigation: threshold requires severity, multi-step work, decision, risk, or validation need.
- Maintenance risk: 46 skills can drift. Mitigation: add both `Trace category` and `Process role` to the standard skill header and verify them.

## Execution Notes

- Read first: `skills/references/chantier-tracking.md`, `skills/sg-help/SKILL.md`, `specs/specs-as-chantier-registry.md`, `templates/spec.md`.
- Then inspect representative sources: `skills/sg-deps/SKILL.md`, `skills/sg-perf/SKILL.md`, `skills/sg-audit/SKILL.md`, `skills/sg-check/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-browser/SKILL.md`.
- Suggested taxonomy baseline:
  - `lifecycle`: `sg-spec`, `sg-ready`, `sg-start`, `sg-verify`, `sg-end`, `sg-ship`.
  - `source-de-chantier`: `sg-deps`, `sg-perf`, all audits, `sg-auth-debug`, `sg-browser`, `sg-prod`, `sg-check`, `sg-test`, `sg-migrate`, `sg-fix`, `sg-market-study`, `sg-veille`, maybe `sg-research` when it produces implementation decisions.
  - `support-de-chantier`: `sg-docs`, `sg-enrich`, `sg-redact`, `sg-repurpose`, `sg-scaffold`, `sg-changelog`, `sg-design-playground`, `sg-skills-refresh`.
  - `pilotage`: `sg-tasks`, `sg-backlog`, `sg-priorities`, `sg-review`, maybe `continue`.
  - `helper`: `sg-context`, `sg-model`, `sg-help`, `sg-status`, `sg-resume`, `sg-explore`, `name`.
- Validate with: `for f in skills/*/SKILL.md; do skill=$(basename "$(dirname "$f")"); printf "%s\t" "$skill"; rg -n "Category:|Process role:|source-de-chantier|Chantier potentiel" "$f"; done`
- Stop conditions: if adding `Process role` to every skill creates too much duplication, centralize the matrix in `chantier-tracking.md` and require each skill to reference it; if a skill's role is ambiguous, classify conservatively as `support-de-chantier` until usage proves it should be a source.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-27 19:34:21 UTC | sg-spec | GPT-5 Codex | Created spec for skill taxonomy and chantier sources | draft | /sg-ready Skill taxonomy and chantier sources |
| 2026-04-27 19:36:56 UTC | sg-ready | GPT-5 Codex | Evaluated readiness for skill taxonomy and chantier sources | ready | /sg-start Skill taxonomy and chantier sources |
| 2026-04-27 19:37:42 UTC | sg-ready | GPT-5 Codex | Re-evaluated readiness for skill taxonomy and chantier sources | ready | /sg-start Skill taxonomy and chantier sources |
| 2026-04-27 19:47:42 UTC | sg-start | GPT-5 Codex | Implemented skill taxonomy and chantier source instructions; left changelog entry to end/ship flow | partial | /sg-verify Skill taxonomy and chantier sources |
| 2026-04-27 19:51:36 UTC | sg-verify | GPT-5 Codex | Verified skill taxonomy and chantier sources; fixed changelog and spec metadata gap during verification | verified | /sg-end Skill taxonomy and chantier sources |
| 2026-04-27 19:53:05 UTC | sg-end | GPT-5 Codex | Closed skill taxonomy and chantier sources after verified implementation | closed | /sg-ship Skill taxonomy and chantier sources |
| 2026-04-27 19:59:25 UTC | sg-ship | GPT-5 Codex | Shipped skill taxonomy and chantier source changes | shipped | None |

## Current Chantier Flow

- `sg-spec`: done, draft spec created.
- `sg-ready`: ready.
- `sg-start`: implemented; taxonomy, source intake, docs, verification hooks, and changelog are complete.
- `sg-verify`: verified.
- `sg-end`: closed.
- `sg-ship`: shipped.

Next step: None
