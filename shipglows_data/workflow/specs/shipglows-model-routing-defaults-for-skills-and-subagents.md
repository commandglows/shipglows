---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "shipglows"
created: "2026-05-14"
created_at: "2026-05-14 10:05:37 UTC"
updated: "2026-08-13"
updated_at: "2026-08-13 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5.5"
scope: "skill-routing"
owner: "Diane"
confidence: "high"
user_story: "En tant qu'operateur ShipGlows, je veux que les skills choisissent automatiquement le modele le plus adapte pour la conversation principale et les sous-agents, afin de reduire les erreurs de routage, le cout inutile, et les changements manuels de modele."
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/704-sg-model/SKILL.md"
  - "skills/704-sg-model/references/model-routing.md"
  - "skills/sg-start/SKILL.md"
  - "skills/references/master-delegation-semantics.md"
  - "skills/references/master-workflow-lifecycle.md"
  - "skills/shipglows/SKILL.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "README.md"
depends_on:
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/architecture.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.12.4"
    required_status: "reviewed"
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Wave 20 reclassifies the unversioned model-routing runtime contract as a linked system and migrates all active paths to the 704-sg-model owner."
  - "User request 2026-05-14: GPT-5.5 should become default for transverse audits, automatic task prioritization, prompt/docs migration, business risk synthesis, and coherent TASKS/project fiche updates."
  - "User question 2026-05-14: model defaults should apply when skills launch subagents, and the main conversation should clarify whether it can choose its own model."
  - "User request 2026-05-14: gpt-5.3-codex should be explicit as the default for long implementation work."
  - "User confirmation 2026-05-14: ShipGlows generally privileges subagents, so small bounded subagent missions should have an explicit default model."
  - "skills/704-sg-model/references/model-routing.md currently routes ambiguous/high-error-cost work and requires official-source refresh for current OpenAI model availability."
  - "skills/sg-start/SKILL.md already reads model-routing.md and supports optional per-group model overrides."
  - "skills/references/master-delegation-semantics.md defines bounded sequential subagents and separates delegation from parallelism."
  - "OpenAI official GPT-5.5 model docs checked 2026-05-14: gpt-5.5 supports Responses/Chat Completions, structured outputs, file search, web search, shell, apply patch, skills, computer use, MCP, and 1M context."
next_step: "shipped"
---

# Title

ShipGlows Model Routing Defaults For Skills And Subagents

# Status

Ready; implementation applied through `sg-skill-build` on 2026-05-14.

# User Story

En tant qu'operateur ShipGlows, je veux que les skills choisissent automatiquement le modele le plus adapte pour la conversation principale et les sous-agents, afin de reduire les erreurs de routage, le cout inutile, et les changements manuels de modele.

# Minimal Behavior Contract

Quand une skill ShipGlows doit executer, deleguer, auditer, prioriser, migrer ou verifier un travail, elle doit classifier la demande, choisir un modele par defaut depuis la matrice `sg-model`, appliquer ce choix aux sous-agents quand le runtime permet un override explicite, et expliquer clairement la limite pour la conversation principale: le modele deja actif ne peut pas se remplacer lui-meme au milieu du fil; il peut seulement recommander un changement, router vers `/sg-model`, ou lancer un sous-agent avec modele choisi si la delegation est autorisee. En cas d'ambiguite, de modele indisponible ou de conflit cout/risque, la skill doit degrader vers un fallback documente ou demander une decision utilisateur. L'edge case facile a rater est de promettre un "auto-switch" du modele principal alors que seul le routage des sous-agents ou le prochain run est effectivement controlable.

# Success Behavior

- Preconditions: une demande ShipGlows arrive via `shipglows`, `sg-build`, `sg-maintain`, `sg-start`, `sg-audit*`, `sg-skill-build`, ou une skill qui peut deleguer du travail.
- Action: la skill lit la reference de routage, classe le travail par profil dominant, choisit un modele primaire, un reasoning, et des fallbacks.
- Resultat visible: le rapport ou le handoff mentionne le modele choisi quand cela change le cout, la qualite, le risque, ou le type de sous-agent.
- Effet systeme attendu: les missions de sous-agents contiennent `model` et `reasoning_effort` quand l'environnement le supporte; les skills qui ne peuvent pas changer le modele principal documentent la recommandation plutot que de simuler un changement.
- Preuve de succes: `rg` montre une seule doctrine commune pour les defaults modeles, `sg-start` et les references master l'utilisent, et les docs expliquent la difference entre modele principal, sous-agent, fallback rapide et fallback economique.

# Error Behavior

- Si la demande depend de "latest", disponibilite, pricing, ou comparaison actuelle, la skill applique la freshness gate OpenAI avant de figer le routage.
- Si le runtime ne supporte pas les sous-agents ou les model overrides, la skill continue en mode degrade seulement apres l'avoir dit clairement quand du file work ou de la validation serait normalement delegue.
- Si le choix de modele change une posture de securite, cout, donnees, production, ou action irreversible, la skill demande confirmation au lieu de choisir silencieusement le modele le plus puissant.
- Si un sous-agent echoue ou revient sans preuve, la skill principale ne doit pas considerer le modele choisi comme une validation; elle doit integrer, revalider, ou rerouter.
- Ce qui ne doit jamais arriver: promettre que la conversation principale "choisit son propre modele" au sens d'un changement runtime effectif, lancer un master skill cache dans un sous-agent, ou assigner le meme fichier writable a plusieurs sous-agents.

# Problem

ShipGlows a deja une skill `sg-model` et une reference `model-routing.md`, mais le comportement n'est pas encore assez explicite pour les nouveaux cas GPT-5.5:

- GPT-5.5 est maintenant le meilleur choix OpenAI pour les travaux transverses, ambigus, tool-heavy, et a fort cout d'erreur.
- `sg-start` peut choisir des modeles et des overrides par groupe, mais certaines sections conservent encore des defaults pre-GPT-5.5.
- Les master skills doivent savoir quand appliquer un modele aux sous-agents, quand rester sur le modele courant, et quand seulement recommander un changement.
- L'operateur a besoin d'une reponse nette: le modele principal peut raisonner sur le meilleur modele, mais ne peut pas se changer lui-meme dynamiquement dans tous les runtimes.

# Solution

Mettre a jour la doctrine ShipGlows de routage modele pour faire de GPT-5.5 le default OpenAI des travaux de pilotage, spec, audit transverse, priorisation, migration de docs/prompts, synthese de risques, et decisions a fort cout d'erreur. Les sous-agents recoivent un modele explicite quand le runtime expose cette capacite; la conversation principale expose une recommandation et des fallbacks sans promettre un auto-switch runtime.

# Scope In

- Rafraichir `skills/704-sg-model/references/model-routing.md` pour integrer GPT-5.5 comme default premium courant.
- Mettre a jour `skills/sg-model/SKILL.md` pour distinguer selection conversationnelle, selection de sous-agent, et recommandation de prochain run.
- Mettre a jour `skills/sg-start/SKILL.md` pour aligner les defaults simples sur GPT-5.5 pour l'ambigu, le transverse, l'audit, la priorisation, les migrations docs/prompts, et les syntheses risque business.
- Etendre `skills/references/master-delegation-semantics.md` avec une regle de mission subagent: modele et reasoning doivent etre explicites quand disponibles.
- Mettre a jour `skills/references/master-workflow-lifecycle.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `README.md`, et `shipglows_data/technical/skill-runtime-and-lifecycle.md` si necessaire pour documenter les limites d'auto-selection.
- Conserver les fallbacks rapides/economiques pour eviter GPT-5.5 sur les petits deltas.

# Scope Out

- Ne pas implementer un nouveau runtime d'execution de modeles.
- Ne pas modifier les APIs OpenAI ou l'installation Codex.
- Ne pas forcer GPT-5.5 pour toutes les taches.
- Ne pas permettre le lancement de master skills caches dans des sous-agents.
- Ne pas toucher aux prix ou benchmarks non verifies hors docs officielles.

# Constraints

- Les fichiers ShipGlows-owned se resolvent depuis `${SHIPGLOWS_ROOT:-$HOME/shipglows}`.
- Les specs restent sous `shipglows_data/workflow/specs/`.
- Les master skills gardent le direct main-thread handoff; elles ne doivent pas etre executees comme sous-agents caches depuis `shipglows`.
- Les sous-agents ne sont autorises que si le runtime le permet et si la delegation respecte les write sets.
- Les claims OpenAI actuels doivent s'appuyer sur docs officielles ou OpenAI Docs MCP.
- Le changement doit rester documentaire/contractuel; aucune commande destructive, aucun commit, aucun deploy.

# Dependencies

- `skills/704-sg-model/references/model-routing.md`: matrice provider-aware a mettre a jour.
- `skills/sg-start/SKILL.md`: consommateur principal du routage avant implementation.
- `skills/references/master-delegation-semantics.md`: doctrine de sous-agents, delegation sequentielle, parallelisme.
- `skills/references/master-workflow-lifecycle.md`: skeleton partage pour model/topology routing.
- `skills/shipglows/SKILL.md`: router principal; doit garder la limite "pas de master skill cache en subagent".
- OpenAI official docs: GPT-5.5 model page and model catalog checked via official OpenAI docs fallback on 2026-05-14; verdict `fresh-docs checked`.

# Invariants

- `sg-model` reste une aide de decision, pas un mega-orchestrateur.
- `sg-start` choisit le modele avant le code.
- `shipglows` route en main-thread et ne lance pas de master skill dans un sous-agent.
- Un modele plus puissant ne remplace pas la readiness, la spec, ou la validation.
- Les fallbacks cout/vitesse restent visibles.

# Links & Consequences

- Les audits transverses et maintenances multi-projets devraient utiliser GPT-5.5 par defaut quand l'erreur de priorisation coute cher.
- Les sous-agents de lecture, audit, docs, migration ou implementation peuvent recevoir des modeles differents si leurs missions ont des profils differents.
- Les sous-agents ou runs d'implementation longue doivent utiliser `gpt-5.3-codex` par defaut quand le profil dominant est code multi-fichiers, refactor, debugging difficile, ou execution terminal-heavy.
- Les petites missions bornees en sous-agent doivent utiliser `gpt-5.4-mini` par defaut; les micro-edits code/UI ciblées utilisent `gpt-5.3-codex-spark`.
- Les petites corrections locales doivent rester sur `gpt-5.4-mini`, `gpt-5.3-codex-spark`, ou equivalent Claude rapide.
- Les docs publiques et internes doivent expliquer que "choisir son modele" dans la conversation principale signifie recommander/dispatcher, pas toujours changer le runtime actif.

# Documentation Coherence

Docs a aligner:

- `README.md`: expliquer les defaults modeles et la difference main conversation vs sous-agent.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`: mettre a jour le flux `sg-model -> sg-start`.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md`: ajouter la regle de routage modele comme contrat technique.
- `CHANGELOG.md`: noter le durcissement des defaults et la clarification auto-switch.
- Eventuellement `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`: ajouter un exemple court pour `shipglows ...` et `/sg-model ...`.

# Edge Cases

- Runtime sans subagents: la skill doit decrire le mode degrade.
- Runtime avec subagents mais sans override de modele: la mission inclut la recommandation, mais ne pretend pas l'appliquer.
- Demande petite mais formulee avec GPT-5.5: respecter la preference utilisateur si explicite, sinon proposer downgrade.
- Demande multi-projets sans write sets: GPT-5.5 peut analyser, mais parallelisme reste bloque sans `Execution Batches`.
- Docs OpenAI indisponibles: utiliser fallback officiel deja consulte si recent; sinon marquer `fresh-docs gap`.
- User demande "le modele choisit son propre modele": repondre que le choix est possible comme decision de routage, pas comme mutation garantie du modele courant.

# Implementation Tasks

- [ ] Tache 1 : Mettre a jour la matrice de routage OpenAI.
  - Fichier : `skills/704-sg-model/references/model-routing.md`
  - Action : Faire de `gpt-5.5` le default OpenAI pour spec, architecture, audits transverses, priorisation, migrations docs/prompts, synthese risques business, computer/tool-heavy et high-error-cost; garder `gpt-5.4-mini`/`gpt-5.3-codex-spark` pour rapide/economique.
  - User story link : choisit automatiquement le modele adapte.
  - Depends on : none
  - Validate with : `sed -n '1,120p' skills/704-sg-model/references/model-routing.md`
  - Notes : Ne pas inventer de prix; mentionner freshness date et source officielle.

- [ ] Tache 2 : Clarifier `sg-model` comme routeur de decision et non runtime switcher.
  - Fichier : `skills/sg-model/SKILL.md`
  - Action : Ajouter une section qui distingue `current conversation recommendation`, `subagent override when available`, et `next-run/user model change`.
  - User story link : repond a la question "est-ce que le modele peut choisir son propre modele ?"
  - Depends on : Tache 1
  - Validate with : `rg -n "current conversation|subagent|override|next-run|auto-switch" skills/sg-model/SKILL.md`
  - Notes : Garder le rapport court et decisionnel.

- [ ] Tache 3 : Aligner `sg-start` sur GPT-5.5 pour les travaux transverses.
  - Fichier : `skills/sg-start/SKILL.md`
  - Action : Remplacer les defaults ambigus/high-error-cost vers `gpt-5.5`, ajouter exemples audits/priorisation/migrations docs/prompts/risques business, et garder `gpt-5.3-codex` pour implementation agentique.
  - User story link : applique les bons defaults au lancement d'execution.
  - Depends on : Tache 1
  - Validate with : `rg -n "gpt-5\\.5|audits transverses|priorisation|prompts|risques" skills/sg-start/SKILL.md`
  - Notes : Ne pas faire de GPT-5.5 le default des petites taches.

- [ ] Tache 4 : Ajouter un contrat de mission modele pour sous-agents.
  - Fichier : `skills/references/master-delegation-semantics.md`
  - Action : Exiger dans chaque mission subagent un `model`, un `reasoning effort` ou alias, un fallback, et une phrase indiquant si l'override est applique ou seulement recommande.
  - User story link : les skills lancees en sous-agent utilisent les modeles adaptes.
  - Depends on : Tache 1
  - Validate with : `rg -n "model|reasoning|fallback|override" skills/references/master-delegation-semantics.md`
  - Notes : Ne pas affaiblir les regles de write ownership.

- [ ] Tache 5 : Mettre a jour la doctrine lifecycle.
  - Fichier : `skills/references/master-workflow-lifecycle.md`
  - Action : Ajouter une etape explicite "model and topology routing" qui applique `sg-model` avant les sous-agents et expose les limites d'auto-switch du modele principal.
  - User story link : coherence des master skills.
  - Depends on : Tache 4
  - Validate with : `rg -n "model.*topology|auto-switch|subagent" skills/references/master-workflow-lifecycle.md`
  - Notes : Garder la reference concise.

- [ ] Tache 6 : Documenter le comportement pour l'operateur.
  - Fichiers : `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`
  - Action : Ajouter une explication courte: le modele courant peut recommander et router; les sous-agents peuvent recevoir des overrides si runtime disponible; sinon l'operateur lance le prochain run avec le modele recommande.
  - User story link : l'operateur comprend quoi attendre.
  - Depends on : Taches 2-5
  - Validate with : `rg -n "GPT-5\\.5|sous-agent|subagent|auto-switch|model routing" README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/technical/skill-runtime-and-lifecycle.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`
  - Notes : Eviter les promesses produit non supportees par le runtime.

- [ ] Tache 7 : Ajouter l'entree changelog.
  - Fichier : `CHANGELOG.md`
  - Action : Noter les defaults GPT-5.5, les overrides subagents, et la clarification "pas d'auto-switch garanti du main model".
  - User story link : tracabilite des decisions.
  - Depends on : Taches 1-6
  - Validate with : `sed -n '1,80p' CHANGELOG.md`
  - Notes : Respecter le format existant.

# Acceptance Criteria

- [ ] CA 1 : Given une demande d'audit transverse multi-repos, when `sg-model` ou un master skill classe la tache, then `gpt-5.5` est le modele OpenAI primaire recommande avec reasoning `high` ou `medium` selon risque.
- [ ] CA 2 : Given une petite correction locale reversible, when `sg-start` choisit le modele, then il garde un modele rapide/economique au lieu de forcer GPT-5.5.
- [ ] CA 3 : Given une execution multi-agent avec groupes disjoints, when une mission subagent est formulee, then elle contient modele, reasoning/alias, fallback, owned files, forbidden files, validations, et stop conditions.
- [ ] CA 4 : Given un runtime sans override de modele subagent, when la skill delegue ou degrade, then le rapport dit que le modele est recommande mais non applique automatiquement.
- [ ] CA 5 : Given une conversation principale deja lancee sur un modele, when l'utilisateur demande si elle peut choisir son modele, then la doc repond qu'elle peut recommander/router mais pas garantir un changement runtime du modele courant.
- [ ] CA 6 : Given une demande qui depend de disponibilite/pricing/latest OpenAI, when la skill fixe une recommandation, then la freshness gate officielle est mentionnee ou le gap est explicite.
- [ ] CA 7 : Given une demande de parallelisme, when aucun `Execution Batches` ready ne definit les write sets, then les sous-agents paralleles restent bloques meme si GPT-5.5 pourrait mieux raisonner.
- [ ] CA 8 : Given une implementation longue, multi-fichiers, refactor, hard bug, ou boucle terminal-heavy, when `sg-model` ou `sg-start` choisit le modele Codex/OpenAI, then `gpt-5.3-codex` est le modele primaire par defaut.
- [ ] CA 9 : Given une petite mission bornee en sous-agent, when aucun profil specialise ne s'applique, then `gpt-5.4-mini` est le modele Codex/OpenAI par defaut.

# Test Strategy

- Static review:
  - `rg -n "gpt-5\\.5|gpt-5\\.4-mini|gpt-5\\.3-codex|subagent|override|auto-switch" skills README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
- Contract sanity:
  - Lire `skills/704-sg-model/references/model-routing.md` et verifier que chaque profil a primary, reasoning, fast fallback, cheap fallback.
  - Lire `skills/sg-start/SKILL.md` et verifier que les defaults simples ne contredisent pas la matrice.
  - Lire `skills/references/master-delegation-semantics.md` et verifier que la mission subagent reste bornee.
- Manual scenarios:
  - "audit transverse multi-repos" -> GPT-5.5.
  - "fix local typo" -> fast/cheap.
  - "implementation multi-file ready spec" -> `gpt-5.3-codex` ou equivalent implementation-heavy.
  - "long implementation / refactor / hard debugging" -> `gpt-5.3-codex`.
  - "small bounded subagent mission" -> `gpt-5.4-mini`.
  - "conversation peut choisir son modele ?" -> reponse nuancee auto-switch vs subagent override.

# Risks

- Risque cout: GPT-5.5 peut devenir trop utilise si les heuristiques ne preservent pas les fallbacks.
- Risque execution: promettre un override modele que le runtime ne supporte pas.
- Risque workflow: confondre delegation sequentielle et parallelisme.
- Risque securite: donner a un sous-agent puissant des surfaces authentifiees ou destructives sans consentement.
- Risque docs: dupliquer la matrice dans trop de fichiers et creer du drift.

# Execution Notes

- Lire d'abord:
  - `skills/704-sg-model/references/model-routing.md`
  - `skills/sg-model/SKILL.md`
  - `skills/sg-start/SKILL.md`
  - `skills/references/master-delegation-semantics.md`
  - `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
- Approche:
  1. Mettre a jour la source unique `model-routing.md`.
  2. Aligner les consumers (`sg-model`, `sg-start`, master delegation/lifecycle).
  3. Mettre a jour les docs operateur.
  4. Ajouter changelog.
  5. Verifier par `rg` que les anciens defaults ambigus ne contredisent pas GPT-5.5.
- Contraintes:
  - Ne pas ajouter de package.
  - Ne pas toucher aux scripts runtime.
  - Ne pas changer les regles de subagent autorisees par le runtime.
  - Ne pas modifier les fichiers dirty non lies sauf si la tache les cible explicitement.
- Fresh external docs:
  - OpenAI GPT-5.5 docs officielles consultees 2026-05-14.
  - Verdict: `fresh-docs checked`.
- Stop conditions:
  - Si une doc officielle contredit la dispo GPT-5.5, revenir a `sg-model` et demander decision.
  - Si la mise a jour exige un changement de runtime Codex/Claude non documentaire, creer une nouvelle spec.
  - Si des fichiers dirty non lies recouvrent les memes lignes, stopper et demander arbitrage.

# Open Questions

- None. Assumption retenue: ShipGlows doit automatiser le routage modele pour les sous-agents quand disponible, et documenter explicitement que la conversation principale ne peut pas garantir son propre auto-switch runtime.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-14 10:05:37 | sg-spec | GPT-5.5 | Created spec for ShipGlows GPT-5.5/default model routing across skills and subagents | Draft saved | /sg-ready shipglows-model-routing-defaults-for-skills-and-subagents |
| 2026-05-14 18:08:05 | sg-ready | GPT-5.5 | Reviewed structure, metadata, behavior contract, task ordering, docs impact, runtime limits, and security posture | ready | /sg-skill-build shipglows-model-routing-defaults-for-skills-and-subagents |
| 2026-05-14 18:08:05 | sg-skill-build | GPT-5.5 | Updated model routing, skill contracts, master delegation/lifecycle references, operator docs, and changelog | implemented | /sg-verify shipglows-model-routing-defaults-for-skills-and-subagents |
| 2026-05-14 18:10:26 | sg-verify | GPT-5.5 | Verified acceptance criteria by metadata lint, diff check, model-routing grep checks, skill budget audit, runtime link checks, and Astro build | verified | /sg-ship shipglows-model-routing-defaults-for-skills-and-subagents |
| 2026-05-14 19:16:37 | sg-ship | GPT-5.5 | Added explicit gpt-5.3-codex long-implementation default, reran checks, and prepared bounded commit/push | shipped | none |
| 2026-05-14 20:56:37 | sg-ship | GPT-5.5 | Added explicit gpt-5.4-mini default for small bounded subagent missions and reran targeted checks | shipped | none |

# Current Chantier Flow

- sg-spec: done
- sg-ready: ready
- sg-start: not applicable; implemented through sg-skill-build
- sg-verify: verified
- sg-end: not launched
- sg-ship: shipped

Prochaine commande: none.
