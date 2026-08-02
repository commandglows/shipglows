---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-17"
created_at: "2026-07-17 22:57:17 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 23:13:29 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "skill-instruction-compaction"
owner: "Diane"
user_story: "En tant qu’opératrice ShipGlows, je veux que 205-sg-veille transforme des sources externes en décisions de veille fiables par une activation compacte et des playbooks ciblés, afin qu’un agent distingue immédiatement le triage de source, la recherche approfondie, le contenu, les docs et les écritures de suivi."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/205-sg-veille/SKILL.md"
  - "skills/205-sg-veille/README.md"
  - "skills/205-sg-veille/references/"
  - "skills/references/source-intake-classification.md"
  - "skills/references/editorial-content-corpus.md"
  - "skills/references/task-registry-routing.md"
  - "skills/203-sg-research/SKILL.md"
  - "skills/007-sg-content/SKILL.md"
  - "skills/009-sg-marketing/SKILL.md"
  - "skills/300-sg-docs/SKILL.md"
  - "skills/309-sg-tasks/SKILL.md"
  - "skills/302-sg-help/references/help-catalog.md"
  - "shipglows-site/src/content/skills/sg-veille.md"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/task-registry-routing.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.7.0"
    required_status: draft
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.9.0"
    required_status: active
supersedes: []
evidence:
  - "2026-07-17 inspection: skills/205-sg-veille/SKILL.md is 335 lines and mixes activation, source fetching, scoring, interactive decisions, writes, file templates, and reporting."
  - "skills/references/skill-instruction-layering.md requires long skill-specific procedures to move from SKILL.md to bounded local references while retaining activation-critical routing and safety gates."
  - "Active 009 contract routes raw URL/source triage to 205, generic cited research to 203, and content lifecycle to 007."
  - "Existing 205 governance-alignment spec is ready/implemented history and preserves canonical research, project-context, editorial, and tracker-routing requirements."
  - "Active README, public skill page, and help catalog expose 205 as the source-triage owner; no identity rename is authorized."
next_step: "none"
---

# Title

Compact 205-sg-veille As Source Triage Dispatcher

# Status

ready

# User Story

En tant qu’opératrice ShipGlows, je veux que `205-sg-veille` transforme des sources externes en décisions de veille fiables par une activation compacte et des playbooks ciblés, afin qu’un agent distingue immédiatement le triage de source, la recherche approfondie, le contenu, les docs et les écritures de suivi.

# Minimal Behavior Contract

Quand l’opératrice fournit des URL ou un contenu collé, `205-sg-veille` doit choisir explicitement le mode `triage`, charger les seules références nécessaires, qualifier les sources avec le contexte projet gouverné, produire des options de décision spécifiques et attendre la décision humaine avant toute écriture durable. Il conserve les quatre axes, l’analyse concurrentielle, les contrôles marketplace/feedback et les frontières de persistance. Si la demande est une enquête citée plutôt qu’un triage, une création de contenu, de la documentation, du marketing, ou une maintenance de tracker, il route vers le propriétaire correspondant. L’edge case principal est de transformer le mode `triage` en recherche approfondie ou en backlog automatique sans décision opératrice ni surface déclarée.

# Success Behavior

- Précondition : l’opératrice lance `205-sg-veille` avec `triage <sources>` ou une entrée historique nue composée d’URL/texte ; `help` reste disponible sans playbook métier.
- Déclencheur : une ou plusieurs sources externes, un texte collé ou une continuation qui contient des décisions explicites pour un triage déjà présenté.
- Résultat opérateur : le premier écran permet de voir le mode, la source, les projets plausibles, les limites de preuve et une décision à prendre sans relire une procédure de 335 lignes.
- Effet système : les sources restent éphémères jusqu’à une décision ; après décision, seules les dérivations autorisées sont écrites dans le bon corpus, sans écraser de tracker ou de fiche.
- Preuve : l’activation compacte conserve les loaders, trace/potentiel chantier, mode routing, frontières, safety gates et validation ; les playbooks portent l’algorithme de triage et de persistance ; les scénarios déterministes passent.

# Error Behavior

- Sans source ni continuation reconnue, demander une seule entrée selon `question-contract`; ne pas ouvrir une session de triage fictive.
- Si une source, un projet, une surface éditoriale, une ancre d’écriture, une claim-sensitive action ou une décision préalable est insuffisamment prouvée, afficher le gap, garder la source non persistée ou router vers son owner ; ne pas inventer de projet, de blog, de contenu ou de tâche.
- Si une URL est inaccessible, si une page marketplace/feedback requise est indisponible, ou si les sources divergent, consigner la limite et ne pas transformer l’incertitude en score affirmatif.
- Si la continuation ne peut pas être reliée sans ambiguïté au triage visible dans la conversation, demander le choix ou relancer `triage`; ne pas conserver d’état caché dans un nouveau fichier.
- Ne doivent jamais arriver : recherche multi-source sans route vers `203`, rédaction/publication par `205`, écritures éditoriales dans `TASKS.md`, écritures techniques dans `ROADMAP.md`, exposition de source privée ou écrasement d’un rapport/fichier `tools.md` depuis un snapshot périmé.

# Problem

Le contrat actuel de `205-sg-veille` fonctionne fonctionnellement, mais son corps d’activation réunit six responsabilités : découverte de contexte projet, extraction/fetch, qualification et scoring, dialogue décisionnel, persistance, et format détaillé de rapport. À environ 335 lignes, il dilue les signaux de routage essentiels et rend plus facile le franchissement des propriétaires voisins. La veille est particulièrement exposée : une URL brute peut être confondue avec une mission de recherche (`203`), une proposition de contenu (`007`), une analyse marketing (`009`), une mise à jour documentaire (`300`) ou un suivi de tracker (`309`).

Le problème n’est pas un manque de modes. Créer des modes `research`, `content`, `docs`, `backlog` ou `marketing` serait une régression de propriété. À l’inverse, séparer un hypothétique mode `apply` nécessiterait un état de session durable non contracté. Une architecture plus riche augmenterait le triage au lieu de le réduire.

# Solution

Transformer `205-sg-veille` en dispatcher métier compact qui expose seulement les modes publics nécessaires :

| Mode | Entrée | Rôle | Résultat / limite |
| --- | --- | --- | --- |
| `triage <sources>` | URL, ensemble d’URL, texte collé, ou continuation de décisions contextualisée | Classer, contextualiser, scorer et faire décider les sources de veille | Peut produire des handoffs et les écritures autorisées après décision ; ne mène pas une étude approfondie ou une production de contenu. |
| `help` | aucune cible | Expliquer les entrées, étapes et owners voisins | Ne charge aucun playbook substantiel et ne lit/écrit aucune source. |
| entrée nue compatible | URL/texte sans préfixe | Résolution par défaut vers `triage` pour préserver les prompts et public docs existants | L’activation signale le mode résolu ; elle ne crée ni seconde identité publique ni mode implicite. |

Une réponse de décision à une question de triage reste une **continuation de `triage`**, non un troisième mode : elle peut exécuter uniquement ce que le playbook de persistance autorise, après relecture du fichier cible. Les étapes longues migrent dans deux références locales : une pour intake/qualification/décision, une pour persistance/rapport. Les références partagées conservent leur autorité actuelle ; aucun nouveau contrat global ne doit être créé sans preuve de réutilisabilité.

# Scope In

- Compacter `skills/205-sg-veille/SKILL.md` en contrat d’activation indépendant, lisible au premier écran et conforme à `skill-instruction-layering`.
- Créer `skills/205-sg-veille/references/triage-playbook.md` pour la découverte de contexte, extraction, fetch, source/marketplace/customer-feedback analysis, quatre axes, scoring, concurrent detection, questions et chemins de reroute.
- Créer `skills/205-sg-veille/references/persistence-and-reporting-playbook.md` pour les décisions, écritures sûres, rapport/`tools.md`, content/task tracker split, redaction et rendu français.
- Préserver `name: 205-sg-veille`, son répertoire, argument hint, `disable-model-invocation`, ses URLs/public discovery et toutes les routes existantes qui restent exactes.
- Mettre à jour uniquement les documents de découverte rendus matériellement inexacts par les nouveaux modes/chemins : README, page publique, help catalog, routeur ou docs techniques trouvés par le scan actif.
- Ajouter une preuve de contrat déterministe (test Python ciblé ou scénario statique équivalent existant) qui vérifie les modes, loaders, frontières et handoffs, plutôt qu’un simple contrôle de mots isolés.
- Scanner les références actives et historiques pour identifier les `sg-veille` legacy, mais ne modifier que les consommateurs actifs qui portent une promesse devenue fausse.

# Scope Out

- Renommer, supprimer, aliaser ou réattribuer l’identité `205-sg-veille`.
- Absorber `203-sg-research`, `007-sg-content`, `009-sg-marketing`, `300-sg-docs`, `309-sg-tasks`, `406-sg-seo`, `emailing`, `200-sg-redact` ou `201-sg-enrich`.
- Changer les quatre axes de scoring, la règle concurrent, les règles marketplace/feedback, la source de vérité projet, les règles de chantier, ou les limites de persistance, sauf correction précisément prouvée par un contrat supérieur.
- Construire une base d’état de triage, un cache public de sources, une watchlist globale, ou une nouvelle couche de tracker.
- Modifier des rapports de veille historiques, les archives de migration ou les anciennes specs seulement parce qu’ils nomment un ancien chemin/nom.
- Réaliser une veille, écrire des tickets réels, créer du contenu, commit ou push.

# Constraints

- L’activation doit conserver : `Canonical Paths`, `Trace category: conditionnel`, `Process role: source-de-chantier`, le chargement de `chantier-tracking` et `reporting-contract`, l’évaluation de `Chantier potentiel`, la langue française du rendu, la source de vérité `shipglows_data/` locale, et les règles de sécurité/redaction.
- `SKILL.md` doit contenir les modes, loaders conditionnels, boundaries/reroutes, non-négociables de décision/persistance et validations ; les formats, matrices, procédures, exemples et branches longues vont dans les playbooks locaux.
- Le mode `triage` charge `source-intake-classification` pour des sources externes/ambiguës et charge les contrats projet minimaux déterminés par la classification ; il ne relit pas tout le portfolio par défaut.
- Une action publique, content/claim/surface charge `editorial-content-corpus` ; une écriture de suivi charge `task-registry-routing` et `operational-record-format` selon leur contrat.
- `203` reçoit la question de recherche claire et la mission de sources citées ; `205` peut seulement collecter le minimum de preuve requis pour classer une source ou justifier une décision, puis handoff.
- `007` reçoit les transformations/publications de contenu ; `009` reçoit les audits/études marketing explicitement demandés ; `300` reçoit la création/mise à jour documentaire ; `309` garde l’entretien général du tracker, sans être absorbé par une écriture de veille autorisée.
- La documentation runtime/public ne reçoit pas de frontmatter ShipGlows interne ; les artefacts gouvernés locaux oui.
- Fresh external docs : `fresh-docs not needed`, car le chantier ne modifie aucune intégration/provider/framework et ne spécifie que des contrats locaux. Les futures sources de veille restent soumises à la fraîcheur propre à leur sujet.
- Exception observabilité : modification de documentation/contrats de skill uniquement ; aucun runtime, Sentry ou en-tête de build n’est concerné.

# Test Contract

- Surface : activation de skill, playbooks locaux, routage de propriétaires, découverte README/public/help et doctrine de persistance.
- proof_profile: `scenario-first` + deterministic contract check + fresh activation/playbook boundary review.
- proof_order: source-transfer inventory -> focused deterministic scenarios -> metadata/budget/runtime/active-scan checks -> public build only if public content changes -> independent boundary review.
- required_scenario_ids: `VEILLE-MODE-BARE-COMPAT`, `VEILLE-EMPTY-QUESTION`, `VEILLE-HELP-NO-SIDE-EFFECT`, `VEILLE-RAW-NOT-RESEARCH`, `VEILLE-MARKETPLACE-THREE-LAYERS`, `VEILLE-CONTENT-SURFACE-GATE`, `VEILLE-SPLIT-PERSISTENCE`, `VEILLE-CONTINUATION-NO-HIDDEN-STATE`, `VEILLE-CHANTIER-POTENTIAL`, `VEILLE-OWNER-BOUNDARY`.
- required_results: every required scenario and deterministic check passes; metadata lint, budget audit, runtime sync, active/historical scan, and `git diff --check` exit `0`; public build passes when a public surface changes, otherwise the recorded no-build rationale names the unchanged surface. Any unmet result blocks verification.
- Automated proof available: metadata lint, `skill_budget_audit`, runtime sync, focused contract test, validation of touched public/frontmatter surfaces, and active/historical scans.
- Manual proof required: adversarial boundary review for each required scenario, reading the dispatcher alone then only its selected playbook; no LLM-behavior claim is accepted without scenario and contract anchors.
- Exception-with-proof : si un scénario ne peut pas être automatisé, le test doit référencer les ancres du dispatcher et du playbook, nommer l’inférence humaine restante et empêcher une conclusion de compatibilité globale.
- Exception-without-proof : none.

## Required Scenarios

| ID | Given | When | Then |
| --- | --- | --- | --- |
| `VEILLE-MODE-BARE-COMPAT` | une URL brute | l’opératrice lance `205-sg-veille <URL>` | le dispatcher résout `triage`, charge le playbook intake et conserve la compatibilité de prompt sans créer une seconde identité publique. |
| `VEILLE-EMPTY-QUESTION` | aucune entrée | le skill est lancé | il charge `question-contract` et demande une seule entrée ; aucun playbook de fetch/persistance ne s’exécute. |
| `VEILLE-HELP-NO-SIDE-EFFECT` | `help` | le dispatcher répond | les deux modes et les routes voisines sont expliqués, sans analyse, lecture de source ni écriture. |
| `VEILLE-RAW-NOT-RESEARCH` | une page concurrente sans question d’étude arrêtée | `triage` | elle est résumée/scorée et propose un benchmark ou `203`; `205` ne synthétise pas une recherche longue citée. |
| `VEILLE-MARKETPLACE-THREE-LAYERS` | AppSumo ou marketplace similaire | la source est classée | le playbook demande la page offre, le site officiel et un feedback/Q&A si disponible ; les divergences restent visibles. |
| `VEILLE-CONTENT-SURFACE-GATE` | une décision suggère un article | le projet n’a pas la surface déclarée | sortie `surface missing: blog` et route `007`/`300`, sans tâche éditoriale fictive. |
| `VEILLE-SPLIT-PERSISTENCE` | une source crée un suivi technique et éditorial | la décision est explicite | deux destinations correctes sont considérées selon `task-registry-routing`, après relecture/minimal patch ; elles ne sont pas fusionnées. |
| `VEILLE-CONTINUATION-NO-HIDDEN-STATE` | réponse de décision sans triage identifiable | une continuation arrive | le skill demande de relier le choix ou de relancer `triage`; aucun fichier de session/global state n’est créé. |
| `VEILLE-CHANTIER-POTENTIAL` | findings multi-domaines nécessitant décision produit | le triage se termine sans chantier unique | un bloc `Chantier potentiel` complet route vers `100`, sans écrire dans une spec ambiguë. |
| `VEILLE-OWNER-BOUNDARY` | demande « rédige/publie/audite/maintient » | mode triage actif | la demande est reroutée vers 007/009/300/309/203 selon la responsabilité, sans extension silencieuse de 205. |

# Dependencies

- `skills/references/skill-instruction-layering.md` : distribution activation/playbook et compaction.
- `skills/references/source-intake-classification.md` : qualification initiale, projet/angle/owner et limites de cache.
- `skills/references/editorial-content-corpus.md` : surfaces, claims, routes `007`, gate éditorial.
- `skills/references/task-registry-routing.md` et `skills/references/operational-record-format.md` : destination et écriture minimale des suivis.
- `skills/references/question-contract.md` : question d’entrée et décisions de triage.
- `skills/references/chantier-tracking.md` et `skills/references/reporting-contract.md` : trace et rapport.
- `skills/203-sg-research/SKILL.md`, `skills/007-sg-content/SKILL.md`, `skills/009-sg-marketing/SKILL.md`, `skills/300-sg-docs/SKILL.md`, `skills/309-sg-tasks/SKILL.md` : contrats voisins à préserver, pas dépendances d’implémentation.

# Invariants

- `205-sg-veille` reste le propriétaire de triage de sources externes, pas un master de recherche, contenu, marketing, documentation ou pilotage.
- Seuls `triage` et `help` sont des modes publics ; une entrée nue reste compatible avec `triage`, et une réponse de décision est une continuation contextualisée.
- Les quatre axes restent exactement : contenu, architecture, concurrence & inspiration, opportunité collab.
- Le score reste une aide de triage explicable, jamais une mesure de vérité ou une permission d’écrire.
- Une source est classée avant d’être persistée ; une décision explicite précède les écritures et un fichier cible est relu immédiatement avant patch.
- Les entrées projet, contenu, produit et claim proviennent du corpus gouverné local pertinent ; les trackers/archives/mémoires ne deviennent pas une vérité concurrente.
- Les fiches/rapports de veille n’exposent jamais de secrets, cookies, tokens, texte privé, PII, captures sensibles ou cache public de source brute.
- Toute référence active aux identifiants et routes `205-sg-veille` demeure correcte ; les références historiques restent historiques, explicitement conservées et non réécrites.

# Links & Consequences

- Une activation plus petite améliore l’adhérence de l’agent, mais les playbooks deviennent des dépendances de première classe : leurs frontmatters, liens et validation doivent être maintenus.
- La page publique et README ne doivent pas promettre des « tâches dans le master TASKS » ni une recherche profonde si le dispatcher impose un autre owner.
- Le catalogue help et le routeur `000` doivent continuer à envoyer une URL brute à `205` lorsqu’un triage est le besoin primaire ; aucune page active ne doit présenter `205` comme l’owner d’une recherche générique.
- Les références aux anciennes identités `sg-veille` dans archives et specs servent de preuve historique. Elles ne sont corrigées que si une surface active les lit comme route actuelle.

# Documentation Coherence

- Revoir `skills/205-sg-veille/README.md`, `shipglows-site/src/content/skills/sg-veille.md`, `skills/302-sg-help/references/help-catalog.md`, le routeur/public catalog actif et `README.md` seulement si l’un affiche des arguments, résultats, routes ou persistance désormais faux.
- Conserver la page publique en langage orienté opératrice : elle décrit le triage et les handoffs sans exposer les playbooks internes ou promettre des écritures automatiques.
- Ne pas modifier docs/public/help par réflexe : documenter `not impacted because ...` pour chaque surface scannée et non touchée.
- Si une référence active au format historique `sg-veille` doit changer, préserver l’exemple/intention mais ne réintroduire ni compatibilité identitaire ni alias obsolète.

# Edge Cases

- Plusieurs URL : les fetches peuvent être parallélisés uniquement en lecture après le contrat de délégation ; synthèse, question, décision et écritures restent séquentielles.
- Texte collé ambigu : le skill peut demander un but qui affecte owner/projet/claim, pas demander inutilement une liste de détails déjà découvrables.
- Concurrent utile pour plusieurs projets : conserver les scores justifiés ; ne pas choisir arbitrairement un seul projet ni déclencher toutes les actions possibles.
- Une décision « creuser » : route vers `203-sg-research` avec question et sources, plutôt que de réimplémenter sa synthèse.
- Une décision content mêlée à une action technique : appliquer la séparation `ROADMAP`/`TASKS` sans masquer le lien entre les deux.
- `tools.md` contient déjà l’URL : mettre à jour seulement la fiche ciblée après relecture ; sinon append autorisé, jamais rewrite complet.
- Un chantier actif unique : écrire seulement la trace autorisée par `chantier-tracking`; l’évaluation de potentiel ne crée pas une seconde spec.
- Une URL contient des paramètres sensibles : redacter avant rapport durable et ne pas afficher le secret dans une option de triage.

# Implementation Tasks

- [x] Task 1: Freeze the dispatcher contract and active/historical inventory.
  - Files: `shipglows_data/workflow/specs/compact-205-sg-veille-as-source-triage-dispatcher.md`; read-only inventory across `README.md`, `AGENT.md`, `skills/**`, `shipglows-site/**`, `.agents/**`, `.opencode/**`, and `shipglows_data/**`.
  - Action: Record the two public modes, bare-input compatibility, continuation semantics, owner matrix, exact active references to update, and historical references to preserve.
  - User story link: Prevents compaction from becoming an identity or ownership migration.
  - Depends on: None.
  - Validate with: `rg -n -i "205-sg-veille|sg-veille|veille" README.md AGENT.md skills shipglows-site .agents .opencode shipglows_data | sort` captured/reviewed before edits; classify each hit active, generated, compatibility, or historical.
  - Notes: Treat `shipglows_data/workflow/archives/**` and closed/older specs as historical unless an active runtime/doc surface consumes them.

- [x] Task 2: Create the compact 205 activation dispatcher.
  - File: `skills/205-sg-veille/SKILL.md`.
  - Action: Preserve identity/frontmatter and activation-critical loaders; add `Instruction Layering`, mission, explicit `triage`/`help` detection, bare-input compatibility, conditional loader map, boundaries/reroutes, local safety/stop conditions, and validation. Remove detailed procedures/templates to local playbooks.
  - User story link: An agent can select the correct next action without retaining a large mixed workflow body.
  - Depends on: Task 1.
  - Validate with: targeted contract test plus `rg -n "Instruction Layering|Mission|Mode Detection|triage|help|source-intake-classification|Chantier potentiel|Boundaries|203-sg-research|007-sg-content|009-sg-marketing|300-sg-docs|309-sg-tasks|Validation" skills/205-sg-veille/SKILL.md`.
  - Notes: Do not enforce a cosmetic line number; budget quality and first-screen followability are the proof.

- [x] Task 3: Extract intake and decision procedure into a bounded local playbook.
  - File: `skills/205-sg-veille/references/triage-playbook.md`.
  - Action: Move source extraction, URL/pasted-text handling, project-context selection, marketplace/feedback reflexes, four-axis scoring, competitor detection, content/product gates, French summary shape, question construction, sequential decision loop, delegation read-only rule, reroutes, and source-safe boundaries.
  - User story link: Keeps detailed high-quality triage available only after mode selection.
  - Depends on: Task 2.
  - Validate with: metadata lint and scenario anchors `VEILLE-MODE-BARE-COMPAT`, `VEILLE-MARKETPLACE-THREE-LAYERS`, `VEILLE-CONTENT-SURFACE-GATE`, and `VEILLE-OWNER-BOUNDARY`.
  - Notes: Link shared references rather than duplicating their doctrine; no external fetch implementation detail is required in the activation body.

- [x] Task 4: Extract decision execution, persistence, and reporting procedure into a bounded local playbook.
  - File: `skills/205-sg-veille/references/persistence-and-reporting-playbook.md`.
  - Action: Define continuation recognition, explicit-decision requirement, target re-read/recompute/minimal-patch protocol, report and `tools.md` formats, deduplication/update semantics, `TASKS`/`ROADMAP` split, research report target, content handoff, redaction, French report, chantier potential, and report-mode detail.
  - User story link: Preserves safe concrete actions without giving the dispatcher hidden mutable state.
  - Depends on: Task 3.
  - Validate with: metadata lint and scenario anchors `VEILLE-SPLIT-PERSISTENCE`, `VEILLE-CONTINUATION-NO-HIDDEN-STATE`, and `VEILLE-CHANTIER-POTENTIAL`.
  - Notes: The playbook must state that an unresolved/ambiguous decision stops safely; it does not invent an `apply` mode.

- [x] Task 5: Add deterministic contract proof and validate the compacted skill.
  - Files: a narrowly scoped existing-or-new test under `tools/` following repository test conventions; `skills/205-sg-veille/SKILL.md`; both local playbooks.
  - Action: Assert the two mode contract, bare compatibility, required references/load conditions, prohibited owner drift, source-safe persistence boundaries, and presence of scenario anchors. Run the full skill consistency suite after the focused test.
  - User story link: Makes the compaction regression-detectable rather than relying on prose review.
  - Depends on: Tasks 2-4.
  - Validate with: `python3 -m unittest <focused_205_contract_test>`; `python3 tools/shipglows_metadata_lint.py skills/205-sg-veille shipglows_data/workflow/specs/compact-205-sg-veille-as-source-triage-dispatcher.md`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `tools/shipglows_sync_skills.sh --check --all`.
  - Notes: Resolve the exact test module by inspecting active `tools/test_*skill*` conventions before implementation; do not invent a duplicate framework.

- [x] Task 6: Align active discovery/docs and prove no stale active route remains.
  - Files: `skills/205-sg-veille/README.md`, `shipglows-site/src/content/skills/sg-veille.md`, `skills/302-sg-help/references/help-catalog.md`, and only active router/catalog/doc surfaces identified by Task 1.
  - Action: Update only material route/mode/output claims; retain public identity and clear neighboring owners. Record unchanged active surfaces with a reason in verification evidence.
  - User story link: Operators discover the same contract that agents execute.
  - Depends on: Task 5.
  - Validate with: focused active-reference `rg` scan; metadata lint for governed Markdown; JSON/content-schema check if an active catalog requires it; `pnpm --dir shipglows-site build` only if public page content changes.
  - Notes: Never mutate archive/history hits merely to make a stale-name scan empty.

# Acceptance Criteria

- [ ] AC 1: Given an agent reads only `skills/205-sg-veille/SKILL.md`, when it receives empty, `help`, bare source, or `triage` input, then it selects the correct route and knows which local playbook to load without parsing a long operational procedure.
- [ ] AC 2: Given a bare URL or pasted text, when the dispatcher resolves it, then it preserves historical invocation compatibility by entering `triage`; it does not create a second public identity or an undocumented mode.
- [ ] AC 3: Given `help`, when it responds, then it has no research, fetch, tracker, report, source-cache, or chantier side effect.
- [ ] AC 4: Given a source requiring detailed cited investigation, content lifecycle, marketing audit, docs change, or tracker maintenance, when it is classified, then `205` routes to `203`, `007`, `009`, `300`, or `309` respectively and does not perform their core work.
- [ ] AC 5: Given a competitor or marketplace source, when triaged, then the preserved playbook demands appropriate product/official/feedback layers where available, scores conservatively against governed project context, and marks source disagreement/limits.
- [ ] AC 6: Given a public-content recommendation, when no declared surface exists, then no invented editorial task is written and the output is `surface missing: blog` with an owner route.
- [ ] AC 7: Given a user decision produces technical and editorial work, when persistence runs, then the two records follow the canonical split and target-re-read/minimal-patch protocol.
- [ ] AC 8: Given a decision continuation lacks unambiguous prior triage context, when it arrives, then no durable action occurs and the operator receives the smallest contextual recovery question.
- [ ] AC 9: Given the compaction implementation is complete, when the deterministic contract test, metadata lint, budget audit, sync check, active-reference scan, and applicable public build run, then they pass; any pre-existing unrelated baseline is distinguished from a regression.
- [ ] AC 10: Given active and historical hits are scanned, when documentation alignment ends, then active routes are coherent and historical references are preserved rather than rewritten by bulk replacement.

# Test Strategy

1. Read the compact activation in isolation and run `VEILLE-MODE-BARE-COMPAT`, `VEILLE-EMPTY-QUESTION`, and `VEILLE-HELP-NO-SIDE-EFFECT` against its mode map.
2. Read only the selected triage playbook and run source/marketplace/content/owner scenarios; verify it points to shared doctrine rather than copying it.
3. Read only the persistence playbook and run continuation, split-write, redaction, and chantier scenarios; verify its write safety protocol is actionable.
4. Run focused deterministic contract proof that fails if a mandatory mode/loader/owner boundary is removed or an unauthorized public mode appears.
5. Run metadata lint, budget audit, runtime sync, and targeted active/historical scans.
6. Build the public site only if its content changed; otherwise record the no-build reason.
7. Perform an adversarial boundary review: ask whether a fresh agent could mistake `205` for `203`, `007`, `009`, `300`, or `309. If yes, return to the activation contract rather than adding another mode.

# Risks

- High: over-compaction removes an activation-critical redaction, project-context or write-safety guard. Mitigation: deterministic scenario anchors and a first-screen manual review.
- High: new modes duplicate `203`, `007`, `009`, `300` or `309. Mitigation: exactly two public modes and explicit forbidden drift in both dispatcher and tests.
- Medium: a documentation scan updates historical material indiscriminately. Mitigation: active/historical classification inventory before docs edits.
- Medium: an overly literal line-count target produces an unreadable dispatcher. Mitigation: use the budget audit and followability gate, not a hard line cap.
- Medium: persistence move loses the target re-read/minimal patch protection. Mitigation: scenario/test explicitly require it in the persistence playbook.

# Execution Notes

Read first, in order:

1. `skills/205-sg-veille/SKILL.md` and its public README/page.
2. `skills/references/skill-instruction-layering.md`, `source-intake-classification.md`, `editorial-content-corpus.md`, `task-registry-routing.md`, and `operational-record-format.md`.
3. Owner contracts: `203`, `007`, `009`, `300`, `309`; then `302` catalog and `000` router references that are active.
4. Existing governance-alignment/history spec and current recent commit history for 205.

Implementation order is Task 1 -> dispatcher -> triage playbook -> persistence playbook -> deterministic proof -> active docs. Keep all edits in one sequential ownership batch; no parallel write batches are authorized. A shared-reference change is out of scope unless the implementation finds a concrete repeated doctrine gap that cannot be safely expressed in the local playbooks; stop and create a follow-up recommendation rather than silently widening this chantier.

Validation must use the canonical `shipglows_*` tool names actually present in `tools/`; if legacy `shipglows_*` names appear in old specs/history, treat them as historical command text, not commands to copy.

# Open Questions

None. The requested architecture is sufficiently bounded: exact public modes are deliberately limited to `triage` and `help`, and all other apparent modes are owner reroutes or continuation semantics.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-07-17 22:57:17 UTC | 100-sg-spec | GPT-5 Codex | Inspected the complete 205 contract, active README/public/help/owner routes, shared source/editorial/tracker contracts, relevant prior specs, and recent 205 history; created this bounded compaction spec. | draft created; ready gate required | `/101-sg-ready Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 22:58:42 UTC | 101-sg-ready | GPT-5 Codex | Strict adversarial readiness review of the two-mode dispatcher, owner boundaries, persistence/redaction invariants, active docs scan, and deterministic proof contract. | not ready; Test Contract lacks the required explicit proof-profile/order/results fields, and `Alias comportemental` conflicts with the required bare-input compatibility wording. | `/100-sg-spec Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:00:27 UTC | 101-sg-ready | GPT-5 Codex | Re-ran the strict readiness gate after the bounded proof-contract amendment; confirmed `proof_profile`, `proof_order`, `required_scenario_ids`, and `required_results` are explicit and metadata lint passes. | not ready; the bare-input compatibility row, required scenario, and AC 2 still use the prohibited `alias` wording, so a fresh agent could retain the rejected identity-alias model. | `/100-sg-spec Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:01:22 UTC | 101-sg-ready | GPT-5 Codex | Final strict rerun after the second wording amendment; confirmed the required scenario and AC 2 now describe default `triage` and no second public identity. | not ready; the bare-input compatibility row in the public mode table still says `alias identitaire`, leaving one rejected compatibility formulation in an activation-critical contract surface. | `/100-sg-spec Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:02:09 UTC | 101-sg-ready | GPT-5 Codex | Final strict readiness review after the remaining mode-table amendment; validated the proof contract, default `triage` bare-input semantics, ownership boundaries, static observability exception, security/redaction controls, and implementation ordering. | ready | `/102-sg-start Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:08:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the compact two-mode dispatcher, local triage and persistence playbooks, deterministic scenario proof, and only materially changed active README/public discovery copy; classified help/router/root docs as not impacted. | implemented; focused proof, metadata, budget, runtime sync, public site build, active/history scan, and diff check passed | `/103-sg-verify Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:08:00 UTC | 900-shipglows-core | GPT-5 Codex | Performed conservative post-build refresh review of 205: retained identity and owner routes, confirmed fresh-docs not needed, recorded the targeted refresh. | refresh recorded; verification/closure not performed | `/103-sg-verify Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:10:14 UTC | 103-sg-verify | GPT-5 Codex | mode=standard independent verification: reviewed dispatcher/playbook boundaries and active/historical references; corrected the stale public README `watchlist` promise; reran deterministic proof, metadata lint, budget audit, runtime sync, diff check, and the public Astro build with pnpm 11.8.0. | verified | `/104-sg-end Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:11:33 UTC | 104-sg-end | GPT-5 Codex | Closed the verified local skill/runtime/public-discovery migration by synchronizing the canonical spec, task registry, and evidence-bounded changelog entry; no commit, push, deployment, source triage, or product outcome is claimed. | closed | `/005-sg-ship Compact 205-sg-veille As Source Triage Dispatcher` |
| 2026-07-17 23:13:29 UTC | 005-sg-ship | GPT-5 Codex | Ran the focused 205 contract proof and runtime visibility check, isolated the verified chantier from unrelated work, then committed and pushed the bounded dispatcher, playbooks, documentation, test, and closure records. | shipped | none |

# Current Chantier Flow

| Skill | Status | Notes |
| --- | --- | --- |
| 100-sg-spec | done | Durable draft created with two-mode architecture, owner boundaries, proof scenarios, documentation scan, and no open material decision. |
| 101-sg-ready | ready | Required proof contract and all three bare-input compatibility surfaces now specify default `triage` with no second public identity or undocumented mode. |
| 102-sg-start | implemented | Compact dispatcher, local playbooks, deterministic contract, and materially affected discovery copy completed; no closure claimed. |
| 103-sg-verify | verified | Standard verification passed: bounded two-mode identity, owner/persistence/redaction contracts, active/history scans, deterministic proof, metadata, budget, sync, diff, and public build are evidenced. |
| 104-sg-end | closed | Canonical spec, task registry, and changelog record the verified local skill/runtime/public-discovery migration without a ship, deployment, or source-triage outcome claim. |
| 005-sg-ship | shipped | Bounded repository-delivery handoff completed after focused proof and runtime visibility checks. |
