---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipGlows
created: "2026-07-30"
created_at: "2026-07-30 14:59:56 UTC"
updated: "2026-07-30"
updated_at: "2026-07-30 15:09:46 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: truthful-recurrence-claims-in-user-reports
owner: Diane
user_story: "En tant qu'opératrice ShipGlows, je veux que les rapports distinguent une réparation prouvée dans son contexte d'une prévention universelle réellement démontrée, afin de pouvoir décider sans recevoir de promesse de non-récidive injustifiée."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/spec-driven-development-discipline.md
  - skills/references/skill-instruction-layering.md
  - skills/900-shipglows-core/SKILL.md
  - tools/test_reporting_contract.py
  - tools/audit_shipglows_skills.py
  - tools/skill_budget_audit.py
  - tools/shipglows_sync_skills.sh
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.10.1"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.1"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Pressure scenario SSRP-013 recurrence-claim-boundary: a repair locally tested for one root cause/context was reported as if it prevented recurrence generally."
  - "The current shared reporting contract requires truthful validation and limits, but has no explicit boundary between a local repair claim and a universal non-recurrence claim."
  - "The current reporting-contract regression suite covers format, concise validation, and unfinished chantier choices, but not recurrence-claim scope or the required proof for guarantees."
  - "Implementation evidence: SSRP-013 now binds local-repair scope, universal-claim rejection, proofless invariants, and covered invariants in the shared contract and deterministic regression suite."
  - "Independent 103 verification replayed all SSRP-013 variants against the shared boundary and confirmed the regression asserts the linked scope, invariant, and focused-mechanical-proof gate rather than isolated words."
next_step: "none — local closure is recorded; commit and push are explicitly not authorized"
---

# Title

Truthful Recurrence Claims in User Reports

# Status

Closed locally — independent 103 verification replayed the four `SSRP-013`
variants against the final shared contract and deterministic regression.
Contract, metadata, audit, budget, runtime sync, and diff checks passed.
Documentation reflection: `updated` — the canonical shared reporting doctrine
and its deterministic regression were aligned. This closes the local contract
change only: no commit or push occurred, and the checks do not prove an
operational prevention invariant for every future project or runtime.

# User Story

En tant qu'opératrice ShipGlows, je veux que les rapports distinguent une réparation prouvée dans son contexte d'une prévention universelle réellement démontrée, afin de pouvoir décider sans recevoir de promesse de non-récidive injustifiée.

# Minimal Behavior Contract

Lorsqu'un rapport explique une réparation, il indique d'abord ce qui est prouvé pour la cause et le contexte effectivement testés, puis les conditions connues dans lesquelles le problème peut encore réapparaître. Les formulations « pour toujours », « garanti », « ne se reproduira pas » ou une équivalence sémantique ne sont permises que si un invariant préventif couvre exactement le périmètre revendiqué et qu'une preuve mécanique démontre cet invariant. Si l'une de ces deux conditions manque, le rapport reste borné au résultat vérifié et nomme la limite sans fabriquer une garantie.

# Success Behavior

- Une réparation locale validée est annoncée comme réparée pour sa cause, son environnement et sa preuve observés, sans extrapolation à d'autres projets, configurations ou changements futurs.
- Un rapport qui évalue le risque de récidive énonce les conditions connues qui pourraient le réintroduire lorsque ces conditions sont identifiables.
- Une promesse universelle n'est autorisée que lorsque l'invariant préventif est explicite, couvre le même périmètre que la promesse, et possède une preuve mécanique exécutée.
- La réponse reste concise et adaptée à la langue active de l'opératrice; la précision de périmètre ne devient pas une matrice technique en `report=user`.

# Error Behavior

- Sans invariant couvrant le périmètre revendiqué, le rapport ne dit pas ou n'implique pas que l'incident est définitivement impossible.
- Sans preuve mécanique de l'invariant, le rapport ne transforme pas une intention, une convention ou une vérification locale en garantie.
- Si la cause racine ou les conditions de récidive restent inconnues, le rapport décrit cette incertitude et ne conclut pas à la prévention.
- Les preuves génériques (lint, build, audit global) ne suffisent pas à elles seules à justifier une non-récidive universelle du scénario observé.

# Problem

Une correction locale peut être réelle et correctement validée tout en restant insuffisante pour affirmer qu'un incident ne pourra plus jamais se reproduire. Le contrat de reporting actuel demande de signaler les limites et les preuves, mais ne force pas explicitement la séparation entre « réparation prouvée dans ce contexte » et « garantie préventive couvrant un périmètre plus large ». Cette lacune laisse possible une formulation trop absolue, qui réduit indûment la visibilité de l'opératrice sur le risque résiduel et peut être répétée par d'autres skills ou dans de futurs projets.

# Solution

Ajouter au contrat partagé de reporting une règle de frontière des claims de récidive, avec un scénario de pression `SSRP-013 recurrence-claim-boundary`. La règle doit imposer une formulation bornée pour toute réparation locale, réserver les promesses universelles à un invariant préventif de périmètre égal et à sa preuve mécanique, puis verrouiller ce comportement dans le test de contrat de reporting. Les skills continuent de charger le contrat partagé; aucun duplicat de doctrine ne doit être ajouté dans chaque `SKILL.md` sauf nécessité d'activation démontrée.

# Scope In

- La doctrine partagée des rapports utilisateurs concernant les claims de réparation, de récidive et de garantie.
- La définition explicite de `SSRP-013 recurrence-claim-boundary`, ses variantes négatives et son état de preuve attendu.
- La couverture déterministe dans `tools/test_reporting_contract.py` de la règle, de ses mots/équivalents à risque et de l'exigence invariant + preuve mécanique.
- La validation proportionnée de la cohérence du contrat, de l'audit de skills, du budget et de la synchronisation runtime.

# Scope Out

- Modifier un projet applicatif, ses sources, sa configuration PM2, ses règles ESLint ou ses rapports historiques.
- Déclarer rétroactivement qu'une réparation déjà livrée est garantie universellement.
- Interdire toute affirmation de réparation validée localement ou exiger une preuve mécanique impossible pour annoncer ce résultat borné.
- Réécrire les playbooks de chaque skill ou créer un nouveau système d'invariants hors de la doctrine de reporting.
- Commit, push, publication de plugin ou modification de la frontière public/interne.

# Constraints

- Le propriétaire le plus réutilisable est `skills/references/reporting-contract.md`; appliquer la règle de layering shared-reference-first.
- La règle doit distinguer le périmètre factuel (« ce qui a été prouvé ») du périmètre de la promesse (« ce qui ne peut plus arriver ») sans les confondre.
- Une preuve mécanique doit tester ou vérifier l'invariant préventif pertinent; elle ne peut pas être seulement un audit de forme ou une validation générique sans lien causal.
- Les rapports ne doivent pas exposer de secrets, de logs sensibles, de données clients ou de détails inutiles pour démontrer le périmètre.

# Test Contract

Proof path: `scenario-first`, complété par des contrôles mécaniques ciblés.

1. `SSRP-013 local-repair`: une réparation PM2/lint locale testée doit être rapportée comme valable dans son contexte et nommer les conditions de récidive connues; elle ne peut pas devenir « fixée pour toujours ».
2. `SSRP-013 unsupported-guarantee`: sans invariant préventif couvrant le périmètre annoncé, toute formulation absolue (« garanti », « ne se reproduira pas », « pour toujours ») est refusée par le contrat/test.
3. `SSRP-013 proofless-invariant`: un invariant seulement déclaré mais non prouvé mécaniquement ne permet pas une garantie universelle.
4. `SSRP-013 covered-invariant`: lorsque l'invariant préventif, son périmètre et sa preuve mécanique sont tous présents, le contrat autorise un claim de prévention exactement borné à ce périmètre.
5. Régression: les règles existantes de format, de concision, de preuves, de limites et de choix de chantier conservent leur comportement.

# Dependencies

- `skills/references/reporting-contract.md` — source canonique des rapports utilisateurs; le changement doit y vivre avant toute adaptation locale.
- `skills/references/spec-driven-development-discipline.md` — définit la preuve scenario-first et interdit de conclure depuis une preuve générique non liée au comportement revendiqué.
- `skills/references/skill-instruction-layering.md` — impose le choix du niveau partagé, puis une adaptation locale seulement si elle est réellement activation-critique.
- Fresh external docs: `fresh-docs not needed`; le changement porte sur des contrats et outils ShipGlows locaux, sans dépendance à une API, un framework ou un fournisseur externe.

# Invariants

- Une réparation prouvée n'est jamais étendue au-delà de sa cause, son contexte et ses vérifications observés.
- Un claim de non-récidive universelle exige un invariant préventif dont le périmètre est au moins égal à celui du claim.
- Un invariant ne justifie un claim universel que si une preuve mécanique ciblée a été exécutée et réussie.
- Une incertitude causale ou une preuve absente reste visible dans le rapport; elle n'est pas masquée par une formulation confiante.
- La doctrine reste partagée et concise; elle ne duplique pas une longue taxonomie de wording dans des skills locaux.

# Links & Consequences

- Toutes les skills qui chargent `reporting-contract.md` héritent de la frontière sans nécessiter une migration textuelle générale, sauf un point d'activation distinct identifié pendant l'implémentation.
- `900-shipglows-core` peut s'appuyer sur cette règle lors des audits de récidive et des outputs d'amélioration système, mais ne doit pas la présenter comme une garantie d'autonomie du skill.
- Les correctifs projet restent autorisés et peuvent être signalés comme validés; la différence est l'obligation de rendre explicite leur périmètre et leur risque résiduel.
- Le test de contrat devient le mécanisme de régression principal; l'audit global et le budget/sync sont complémentaires mais ne prouvent pas seuls `SSRP-013`.

# Documentation Coherence

Mettre à jour uniquement la documentation de reporting partagée et, si le test rend une nouvelle expression de contrat observable, son commentaire/docstring. Les rapports historiques, documents publics, plugins et guides de projets ne sont pas réécrits dans ce chantier.

# Edge Cases

- Une correction élimine une collision de port dans une configuration donnée: elle peut être annoncée comme stable sur l'instance observée, mais pas comme prévention de toutes les crash loops des autres configurations ou projets.
- Un linter exclut un dossier généré: le lint est réparé pour le dossier couvert, mais un futur générateur hors de cette règle peut recréer une erreur; le rapport doit le dire si cette condition est connue.
- Une validation mécanique n'observe que la présence de mots dans une doctrine: elle ne suffit pas à elle seule à prouver l'invariant d'un système opérationnel; le test doit vérifier le lien explicite invariant + périmètre + preuve.
- Une garantie est limitée explicitement à un seul sous-système et possède un invariant testé pour ce sous-système: la formulation peut rester précise, sans être gonflée en promesse pour « tous les projets futurs ».
- Des équivalents linguistiques ou une paraphrase (« aucun risque de retour », « définitivement résolu ») ne doivent pas contourner la règle fondée sur la portée du claim.

# Implementation Tasks

- [x] Task 1: Définir la frontière partagée des claims de récidive.
  - Files: `skills/references/reporting-contract.md`.
  - Action: ajouter une règle compacte, ses conditions invariant + couverture de périmètre + preuve mécanique, les formulations interdites sans ces conditions, et `SSRP-013 recurrence-claim-boundary`.
  - User story link: rend visible la différence entre une réparation vérifiée et une garantie.
  - Depends on: none.
  - Validate with: revue de la règle contre les quatre scénarios du Test Contract.

- [x] Task 2: Ajouter la régression mécanique scenario-first.
  - Files: `tools/test_reporting_contract.py`.
  - Action: créer des assertions ciblées qui échouent si la doctrine perd la réparation bornée, les conditions de garantie ou le scénario `SSRP-013`; ne pas simuler une garantie avec de simples assertions de mots isolés.
  - User story link: empêche qu'une future simplification de wording supprime la frontière.
  - Depends on: Task 1.
  - Validate with: `python3 tools/test_reporting_contract.py`.

- [x] Task 3: Vérifier la compatibilité et la portée.
  - Files: `skills/references/reporting-contract.md`, `tools/test_reporting_contract.py`.
  - Action: relire les règles existantes de preuve, limites, concision et chantier pour confirmer qu'elles restent compatibles; modifier un `SKILL.md` seulement si une vérification d'activation montre que le contrat partagé ne peut pas être chargé par les surfaces concernées.
  - User story link: applique la prévention aux futurs projets sans dupliquer une règle fragile.
  - Depends on: Tasks 1-2.
  - Validate with: focused `rg` plus la suite de reporting complète.

- [x] Task 4: Exécuter les validations ShipGlows proportionnées.
  - Files: no new implementation file expected.
  - Action: exécuter les preuves de contrat et de cohérence après la revue de diff; déclarer toute limite restante plutôt que conclure à une non-récidive universelle.
  - User story link: fournit une décision opératrice fondée sur une preuve réelle.
  - Depends on: Tasks 1-3.
  - Validate with: commandes listées dans Test Strategy et `git diff --check`.

# Acceptance Criteria

- [x] AC 1: Given `SSRP-013 local-repair`, when une réparation n'a été prouvée que pour une cause/contextes observés, then le contrat exige un rapport borné et les conditions connues de récidive plutôt qu'une promesse absolue.
- [x] AC 2: Given une formulation « pour toujours », « garanti », « ne se reproduira pas » ou équivalente, when le périmètre du claim dépasse celui de l'invariant préventif, then le contrat la refuse.
- [x] AC 3: Given un invariant préventif de portée suffisante mais sans preuve mécanique ciblée exécutée, when le rapport est produit, then il n'affirme pas de non-récidive universelle.
- [x] AC 4: Given un invariant préventif de portée suffisante et une preuve mécanique ciblée réussie, when le rapport produit un claim de prévention, then ce claim reste limité au périmètre couvert et cite la preuve de façon concise.
- [x] AC 5: Given l'exécution de `tools/test_reporting_contract.py`, when la doctrine de frontière est supprimée ou affaiblie, then la suite échoue de manière déterministe.
- [x] AC 6: Given les contrôles globaux de cohérence ShipGlows, when le changement est terminé, then audit, budget et sync restent passants, sans que leur succès soit présenté comme la preuve unique de non-récidive.
- [x] AC 7: Given les rapports de correctifs futurs, when ils suivent le contrat partagé, then ils peuvent dire « réparé et validé dans ce contexte » sans être forcés de promettre « jamais ».

# Independent Verification (103-sg-verify)

- AC 1 (`local-repair`): verified against the contract's required bounded
  result, observed cause/context, and known recurrence conditions.
- AC 2 (`unsupported-guarantee`): verified that an absolute claim is refused
  without a preventive invariant whose scope covers the claim; semantic
  equivalents are included as scope-based signals, not a word-only filter.
- AC 3 (`proofless-invariant`): verified that an asserted invariant without
  focused mechanical proof cannot authorize a universal non-recurrence claim.
- AC 4 (`covered-invariant`): verified that the allowed prevention claim needs
  the invariant, scope, and focused mechanical proof together, and remains
  bounded to that covered scope.
- AC 5: `python3 -m unittest tools.test_reporting_contract` passed 15 tests.
  Its `SSRP-013` regression checks the linked local scope, invariant coverage,
  focused mechanical proof, generic-proof limit, and all four variants; it is
  not merely an isolated prohibited-word scan.
- AC 6: metadata lint (spec and shared reference), skill audit, budget audit,
  all-runtime sync, and `git diff --check` passed. They are complementary
  coherence proof only, not proof of an operational invariant.
- AC 7: verified by the shared boundary's explicit allowance for a bounded
  local repair report; no universal claim is required or implied.

Verification result: `verified` for the shared reporting-contract guardrail.
Residual limit: a future project follows this prevention rule only when its
reporting path loads the shared contract; no local/static verification can
prove every future runtime invariant.

# Test Strategy

- `python3 tools/test_reporting_contract.py` pour les scénarios `SSRP-013` et les régressions de reporting existantes.
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/truthful-recurrence-claims-in-user-reports.md` pour l'artefact de spec, puis les artefacts Markdown modifiés lors de l'implémentation.
- `python3 tools/audit_shipglows_skills.py` pour la cohérence d'exécution générale, comme preuve complémentaire uniquement.
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` pour préserver la lisibilité des contrats.
- `tools/shipglows_sync_skills.sh --check --all` pour vérifier la synchronisation runtime.
- Focused `rg` de `SSRP-013`, `invariant`, `scope`, `mechanical proof`, et des formulations absolues sur le contrat et les tests.
- `git diff --check` et revue manuelle du diff pour exclure les changements hors scope.

# Risks

- Une interdiction basée seulement sur une liste de mots peut manquer des paraphrases ou bloquer une phrase correctement bornée. Mitigation: définir la règle par périmètre/invariant/preuve et utiliser les mots comme signaux, pas comme unique sémantique.
- Une exigence trop lourde pourrait empêcher de communiquer une réparation réelle. Mitigation: les claims locaux restent permis avec leur preuve et leurs limites; seules les promesses universelles ont la barre renforcée.
- Un audit global passant pourrait être mal interprété comme preuve de prévention. Mitigation: lier explicitement le claim universel à une preuve mécanique ciblée de l'invariant.
- Une adaptation dans chaque skill provoquerait de la dérive. Mitigation: changer le contrat partagé et ne toucher une activation locale qu'après preuve de nécessité.

# Execution Notes

- Lire avant implémentation: `skills/references/reporting-contract.md`, `skills/references/spec-driven-development-discipline.md`, `skills/references/skill-instruction-layering.md`, `tools/test_reporting_contract.py`, puis les surfaces qui chargent le contrat si un doute d'activation subsiste.
- Commencer par écrire/renforcer les scénarios de test de sorte qu'ils capturent le claim abusif observé; ne pas conclure depuis une simple recherche textuelle ou l'audit générique.
- Préserver les changements non liés déjà présents dans le worktree ShipGlows; le chantier n'autorise ni commit ni push.
- Produire après implémentation l'output d'amélioration système: problème observé, cause système, règle de prévention, proposition contrat/tooling, avec `SSRP-013` comme preuve de pression.

# Open Questions

None. Le comportement attendu est entièrement déterminé par la critique opératrice: réparer correctement dans un contexte doit être communiqué comme tel; une non-récidive universelle exige un invariant couvrant le périmètre et une preuve mécanique.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-30 14:59:56 UTC | 100-sg-spec | GPT-5 Codex | Created the scenario-first implementation contract for truthful recurrence claims after the operator challenged an unjustified permanence implication. | drafted; readiness has not been evaluated | `/101-sg-ready truthful recurrence claims in user reports` |
| 2026-07-30 15:02:49 UTC | 101-sg-ready | GPT-5 Codex | Reviewed the bounded shared reporting-contract change against `SSRP-013`, proof scope, and global-guarantee conditions. | ready; implementation may change only the shared reporting contract and its deterministic regression test | `/102-sg-start truthful recurrence claims in user reports` |
| 2026-07-30 15:05:32 UTC | 102-sg-start | GPT-5 Codex | Added the reusable reporting boundary and scenario-first regression; manually replayed local-repair, unsupported-guarantee, proofless-invariant, and covered-invariant against the final text. | implemented; contract, metadata, audit, budget, runtime sync, and diff checks passed | `/103-sg-verify truthful recurrence claims in user reports` |
| 2026-07-30 15:07:47 UTC | 103-sg-verify | GPT-5 Codex (independent delegated verification) | Replayed `SSRP-013` local-repair, unsupported-guarantee, proofless-invariant, and covered-invariant against the shared boundary; confirmed the deterministic test captures the scope + invariant + focused-mechanical-proof relationship rather than isolated words. | verified; 15 reporting tests, metadata, audit, budget, all-runtime sync, and diff checks passed; no operational invariant for every future runtime is claimed | `/104-sg-end truthful recurrence claims in user reports` |
| 2026-07-30 15:09:46 UTC | 104-sg-end | GPT-5 Codex (delegated closure) | Applied closure and documentation-reflection guards in `Résumé seulement` mode; recorded the shared reporting doctrine and deterministic regression as aligned documentation. | closed locally; no tracker or changelog write, commit, push, publication, or runtime-universality claim | `none — shipping is explicitly not authorized` |

# Current Chantier Flow

| Stage | Status | Note |
|-------|--------|------|
| 100-sg-spec | completed | Drafted the bounded shared-contract repair, scenarios, scope, tasks, and proof ladder. |
| 101-sg-ready | completed | Ready: `SSRP-013` defines the local-repair boundary, and universal claims require a scope-matched preventive invariant plus focused mechanical proof. |
| 102-sg-start | completed | Added `SSRP-013` to the shared reporting contract and its deterministic regression coverage; implementation proof passed. |
| 103-sg-verify | verified | Independently replayed all four `SSRP-013` variants; the focused regression and complementary coherence checks passed. This verifies the shared reporting guardrail, not every future runtime invariant. |
| 104-sg-end | completed | Closed locally in `Résumé seulement` mode. Documentation reflection: `updated` — the shared reporting doctrine and deterministic regression are aligned; no material documentation debt remains. |
| 005-sg-ship | not authorized | No commit or push is authorized by this chantier; local closure is not shipment. |

