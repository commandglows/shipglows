---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: "ShipGlows"
created: "2026-06-18"
created_at: "2026-06-18 21:13:04 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 14:20:26 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "workflow-hygiene-hard-gate"
owner: "Diane"
user_story: "En tant qu'operatrice ShipGlows, je veux que les agents et audits bloquent mecaniquement les artefacts locaux, secrets et sorties transitoires mal ignores avant implementation, checks ou ship, afin d'eviter les commits sales, les faux signaux de verification, et la fuite de fichiers locaux."
confidence: high
risk_level: high
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/102-sg-start/SKILL.md"
  - "skills/105-sg-check/SKILL.md"
  - "skills/005-sg-ship/SKILL.md"
  - "skills/400-sg-audit/SKILL.md"
  - "skills/010-sg-technical/SKILL.md"
  - "skills/010-sg-technical/references/technical-audit-playbook.md"
  - "skills/900-shipglows-core/SKILL.md"
  - "tools/audit_shipglows_skills.py"
  - "tools/audit_gitignore_hygiene.py"
  - ".gitignore"
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
supersedes: []
evidence:
  - "Current ShipGlows worktree on 2026-06-18 shows `.gitignore` modified while tracked transient artifacts under `site/.playwright-mcp/` are deleted, proving repo-hygiene drift can coexist with ordinary work."
  - "At spec creation on 2026-06-18, the former 401-sg-audit-code workflow checked only `.env` presence in `.gitignore`, which was too narrow for generated local-tool outputs and tracked transient artifacts."
  - "005-sg-ship currently runs a secret pre-stage check but has no dedicated hard mechanical gate for broad `.gitignore`/transient-artifact hygiene."
  - "102-sg-start and 105-sg-check currently rely on general guardrails and check interpretation, not a shared machine-readable repo-hygiene verdict."
next_step: "/101-sg-ready shipglows_data/workflow/specs/shipglows-gitignore-and-repo-hygiene-hard-gates-for-agents-and-audits.md"
---

## Title

ShipGlows Gitignore and Repo Hygiene Hard Gates for Agents and Audits

## Status

Draft. Intended to be implementation-ready after `/101-sg-ready` without widening scope beyond the named skills, one mechanical tool, and scenario-first audit coverage.

## User Story

En tant qu'opératrice ShipGlows, je veux que les skills d'exécution, de checks, de ship et d'audit détectent puis bloquent mécaniquement les artefacts locaux, secrets et sorties transitoires mal ignorées avant qu'un agent implémente, valide ou pousse, afin d'éviter les commits pollués, les faux verdicts "green", et les fuites de fichiers locaux.

Acteur principal: opératrice ShipGlows qui délègue à `102-sg-start`, `105-sg-check`, `005-sg-ship`, `900-shipglows-core`, `400-sg-audit`, ou `$010-sg-technical audit <target>`.

Déclencheur: un agent s'apprête à implémenter, lancer des checks, auditer ou shipper dans un repo contenant soit des patterns `.gitignore` insuffisants, soit des fichiers transitoires/secrets déjà suivis ou non ignorés.

Résultat observable: le skill concerné refuse de continuer avec un verdict explicite et une sortie mécanique listant les chemins, la règle violée, et la commande de remédiation ou le prochain owner skill.

## Minimal Behavior Contract

Avant toute implémentation, check, audit de conformité, ou ship, ShipGlows doit exécuter un contrôle mécanique de repo hygiene qui détecte les artefacts locaux/secrets/transitoires mal ignorés ou déjà suivis, puis bloque la progression dans `102-sg-start`, `105-sg-check`, et `005-sg-ship` tant que l'état n'est pas assaini ou explicitement inclus dans le scope de la spec. L'edge case facile à rater est un repo techniquement "fonctionnel" dont les checks passent alors que des sorties locales comme `.playwright-mcp`, `.codebase-mcp`, `.env`, caches Python ou autres artefacts de machine polluent l'index, masquent un vrai problème `.gitignore`, ou risquent une fuite au push.

## Success Behavior

- Given un repo avec artefacts transitoires suivis ou non ignorés, when `102-sg-start` initialise son exécution, then il stoppe avant toute modification non triviale et route vers une remédiation d'hygiène ou vers une spec existante qui possède explicitement ce nettoyage.
- Given un repo avec règles `.gitignore` manquantes pour des sorties locales connues, when `105-sg-check` lance son pass de confiance, then il renvoie un verdict bloquant avec la liste des patterns/path concernés avant d'interpréter le repo comme "green".
- Given un repo sale avant commit/push, when `005-sg-ship` prépare le stage, then il bloque le ship même si `skip-check` est demandé, car la gate d'hygiène fait partie des préconditions de sécurité et de confiance, pas des checks optionnels.
- Given un audit interne ShipGlows, when `900-shipglows-core` ou `$010-sg-technical audit <target>` inspecte les skills/workflows, then l'audit produit un finding scenario-first si un skill lifecycle manque la gate mécanique ou si le workflow d'audit reste limité au seul check `.env`.
- Given un repo propre ou un chantier où les chemins transitoires sont explicitement dans le scope de travail, when le tool renvoie `clean` ou un allowlist contractuel valide, then les skills continuent normalement et reportent que la gate d'hygiène a été satisfaite.

## Error Behavior

- Si le tool ne peut pas déterminer le repo root, lire `.gitignore`, ou inspecter l'état Git de manière sûre, le skill doit reporter `blocked` avec la cause technique au lieu de supposer un repo propre.
- Si un artefact secret ou local sensible est détecté (`.env`, clés, credentials machine, exports locaux, caches de tooling contenant des données privées), le skill ne doit ni le stage automatiquement ni l'exposer en sortie brute au-delà de ce qui est nécessaire pour l'identifier.
- Si un chemin semble transitoire mais est volontairement versionné pour une raison documentée, le système doit permettre une exception explicite et vérifiable, pas une inférence silencieuse.
- Si l'audit retourne seulement des remarques stylistiques de `.gitignore` sans risque sécurité/propreté concret, les skills lifecycle ne doivent pas être bloqués; seules les classes `hard` doivent être bloquantes.

## Problem

ShipGlows a déjà des garde-fous sur la qualité, la preuve et le ship, mais il manque un contrat mécanique central pour la hygiene `.gitignore` et repo-local. Aujourd'hui, un repo peut garder des artefacts transitoires suivis ou des sorties locales non ignorées tout en laissant `102-sg-start`, `105-sg-check`, ou `005-sg-ship` continuer avec trop de confiance. Le résultat est double:

1. risque sécurité et confidentialité: fichiers `.env`, credentials, exports locaux ou caches de tooling peuvent entrer dans l'index ou rester visibles dans un diff;
2. risque opératoire: un check ou un audit peut conclure "green" alors que le repo contient du bruit local, des suppressions de sorties transitoires déjà trackées, ou des patterns `.gitignore` incomplets qui dégradent les futures sessions agentiques.

La preuve locale capturée le 2026-06-18 confirmait le problème: la worktree contenait une modification de `.gitignore` et des suppressions de fichiers `site/.playwright-mcp/*.yml`, signe qu'un outillage local avait déjà produit des artefacts suivis ou mal nettoyés. En parallèle, l'ancien `401-sg-audit-code` ne vérifiait mécaniquement que `.env` dans `.gitignore`, ce qui était trop étroit.

## Solution

Introduire une gate mécanique unique `tools/audit_gitignore_hygiene.py`, puis l'imposer explicitement dans `102-sg-start`, `105-sg-check`, et `005-sg-ship`. Le tool doit produire un verdict structuré et conservateur (`clean`, `hard`, `review`, `style`) à partir de l'état Git, de `.gitignore`, et d'un jeu minimal de règles ShipGlows pour artefacts locaux/transitoires/sensibles. Les skills lifecycle traitent `hard` comme bloquant, `review` comme finding à reporter ou à auditer selon le contexte, et `style` comme non bloquant.

En parallèle, étendre la couverture scenario-first dans `900-shipglows-core`, `400-sg-audit`, et `$010-sg-technical audit <target>` via `skills/010-sg-technical/references/technical-audit-playbook.md` pour que l'absence de gate, le scope trop étroit des checks `.gitignore`, ou le passage abusif d'un repo sale soient auditables et vérifiables.

## Scope In

- Créer `tools/audit_gitignore_hygiene.py` comme helper mécanique repo-level pour détecter:
  - chemins sensibles non ignorés ou suivis par erreur;
  - sorties locales/transitoires connues non ignorées;
  - artefacts transitoires déjà suivis dans Git;
  - insuffisances `.gitignore` produisant un risque sécurité ou propreté de repo.
- Ajouter une gate bloquante dans `skills/102-sg-start/SKILL.md` avant implémentation significative.
- Ajouter une gate bloquante dans `skills/105-sg-check/SKILL.md` avant de déclarer un pass de checks techniquement fiable.
- Ajouter une gate bloquante dans `skills/005-sg-ship/SKILL.md` avant stage/commit/push, non contournable via `skip-check`.
- Ajouter une couverture scenario-first dans `skills/900-shipglows-core/SKILL.md` et/ou `tools/audit_shipglows_skills.py` pour vérifier la présence de la gate et classifier les écarts.
- Étendre `skills/400-sg-audit/SKILL.md`, `skills/010-sg-technical/SKILL.md`, et `skills/010-sg-technical/references/technical-audit-playbook.md` afin que `$010-sg-technical audit <target>` traite repo hygiene / `.gitignore` comme axe d'audit explicite, pas comme sous-ligne `.env` isolée.
- Prévoir une sortie machine lisible (`--format json|markdown|text`) et des exit codes stables pour que les skills puissent consommer le verdict sans parser des phrases fragiles.

## Scope Out

- Aucun nettoyage automatique global de tous les repos ShipGlows.
- Aucune modification automatique de `.gitignore` par le tool lui-même.
- Aucun élargissement de scope vers `310-sg-github-hygiene`; cette spec traite l'hygiène repo locale et la gate agentique, pas la dérive GitHub/branches.
- Aucun secret scan exhaustif type DLP ni classification heuristique large de tous les binaires du repo.
- Aucune réécriture des autres skills non cités.
- Aucun changement aux projets applicatifs externes; la première implémentation vise la discipline ShipGlows et ses audits.
- Aucune suppression forcée de fichiers utilisateur hors chantier explicite.

## Constraints

- Le tool doit être conservateur: bloquer seulement les cas à risque concret (`hard`) et éviter les faux positifs massifs.
- Le contrat doit respecter la dirty worktree existante: ne jamais annuler ni reclasser silencieusement des modifications utilisateur.
- Les règles de sortie doivent rester lisibles et actionnables par des skills sans raisonnement caché.
- Les exceptions doivent être explicites, locales et vérifiables; pas de bypass implicite basé sur le nom du fichier seul.
- La gate de `005-sg-ship` doit rester active même en mode `skip-check`, car elle protège le stage/push lui-même.
- Fresh external docs: not needed; le comportement visé est local à ShipGlows, Git, et nos skills.

## Contracts

- Tool verdict contract:
  - `clean`: aucun finding bloquant ni review.
  - `hard`: blocage lifecycle/check/ship; liste des chemins, type de risque, et remédiation courte.
  - `review`: non bloquant pour audit/reporting, mais doit produire un finding explicite; peut devenir bloquant seulement si le skill audit ou la spec en cours le demande.
  - `style`: amélioration facultative de lisibilité `.gitignore`, jamais bloquante seule.
- Tool interface contract:
  - `python3 tools/audit_gitignore_hygiene.py --format json`
  - exit `0` = `clean`
  - exit `1` = `review` ou `style` sans `hard`
  - exit `2` = `hard`
  - exit `3` = tool blocked / internal error / repo unreadable
- Lifecycle contract:
  - `102-sg-start`, `105-sg-check`, `005-sg-ship` doivent arrêter ou rerouter sur exit `2` ou `3`.
  - `skip-check` ne contourne pas cette gate dans `005-sg-ship`.
  - Un chantier explicitement centré sur `.gitignore` ou nettoyage repo peut continuer si la spec identifie ces fichiers comme surface owned.
- Audit contract:
  - `900-shipglows-core` et les audits code doivent pouvoir prouver, par scénario, qu'un skill lifecycle sans gate d'hygiène est un finding.

## Test Contract

- `surface`: ShipGlows skills, audit workflows, and one local Python helper.
- `proof_profile`: scenario-first plus mechanical CLI checks.
- `proof_order`:
  1. définir les scénarios repo-hygiene et leurs verdicts attendus;
  2. implémenter le tool mécanique;
  3. brancher `102`, `105`, `005` sur les exit codes;
  4. étendre `900`, `400`, `401`, et le workflow d'audit code;
  5. valider par scénarios + `rg` ciblé + audits outils.
- `checklist_path`: `shipglows_data/workflow/test-checklists/gitignore-repo-hygiene.md`
- `required_scenario_ids`:
  - `GIH-001 tracked transient artifact blocks ship`
  - `GIH-002 missing ignore pattern blocks checks`
  - `GIH-003 start gate blocks implementation on dirty transient state`
  - `GIH-004 explicit hygiene chantier allows scoped continuation`
  - `GIH-005 ship skip-check still enforces hygiene gate`
  - `GIH-006 audit-core flags missing lifecycle hygiene gate`
  - `GIH-007 audit-code reports more than env-only gitignore coverage`
- `required_results`:
  - `102-sg-start` refuses non-owned implementation when `hard` hygiene findings exist.
  - `105-sg-check` cannot report green technical confidence with `hard` hygiene findings.
  - `005-sg-ship` cannot stage/push with `hard` hygiene findings, even with `skip-check`.
  - `900-shipglows-core` and code audits can prove the gate exists and classify regressions.
  - Tool output is machine-readable and stable enough for skill automation.
- `exception_with_proof`:
  - A repo-specific intentional tracked transient file may pass only if the skill/spec cites the allowlist rule or documented exception.
  - A `review` finding may continue in lifecycle work only when no `hard` finding exists and the report names the residual hygiene debt.
- `exception_without_proof`: not allowed for lifecycle gate bypass.

## Dependencies

- `skills/references/decision-quality-contract.md@1.2.0`
- `skills/references/chantier-tracking.md@0.5.0`
- `skills/references/reporting-contract.md@1.4.0`
- `skills/102-sg-start/SKILL.md`
- `skills/105-sg-check/SKILL.md`
- `skills/005-sg-ship/SKILL.md`
- `skills/900-shipglows-core/SKILL.md`
- `skills/400-sg-audit/SKILL.md`
- `skills/010-sg-technical/SKILL.md`
- `skills/010-sg-technical/references/technical-audit-playbook.md`
- `tools/audit_shipglows_skills.py`
- `git` CLI and repo metadata (`git status`, `git ls-files`, `git check-ignore`)

## Invariants

- ShipGlows ne doit jamais présenter un repo sale/transitoire comme "green" sans au minimum un finding explicite.
- Aucun skill ne doit shipper un secret, cache local, ou sortie outillage sensible par omission de `.gitignore`.
- Les audits doivent rester findings-first et distinguer clairement risque sécurité/propreté (`hard`) et dette de style.
- Le tool mécanique ne doit pas muter le repo; il audite et classe seulement.
- Les exceptions doivent être documentées et traçables, jamais implicites.

## Links & Consequences

- Durcit directement les garde-fous de `102`, `105`, et `005`.
- Donne à `900-shipglows-core` un axe d'audit plus robuste que la simple revue textuelle des contracts.
- Étend le mode `$010-sg-technical audit <target>` au-delà de la ligne `.env` dans `.gitignore`.
- Réduit les faux signaux de "repo clean enough" avant commit, verify, ou audit.
- Peut imposer des mises à jour ciblées de `.gitignore` dans les futurs chantiers, mais cette spec n'en exécute aucune.

## Documentation Coherence

- Mettre à jour les skills ciblés et, si nécessaire, `shipglows_data/technical/skill-runtime-and-lifecycle.md` si ce document décrit les gates lifecycle/check/ship sans mention d'hygiène repo mécanique.
- Mettre à jour `CHANGELOG.md` pendant `104-sg-end`/`005-sg-ship` si le comportement des skills change matériellement.
- Aucun doc externe/public requis tant que le changement reste interne au fonctionnement ShipGlows.

## Edge Cases

- Repo avec `.env.example` volontairement tracké mais `.env` local non ignoré.
- Repo avec artefacts transitoires déjà suivis historiquement; le tool doit classer le risque sans auto-nettoyer.
- Chantier dédié au nettoyage `.gitignore` où la présence de ces fichiers est précisément la surface à traiter.
- Monorepo avec plusieurs `.gitignore`; le tool doit partir du repo root Git et rapporter clairement le fichier source de la règle manquante.
- Repo sans `.gitignore`; verdict `hard`.
- Repo non Git ou état Git inaccessible; verdict `blocked`/exit `3`.
- Output local d'un outil nouveau non encore connu du tool; classer au moins en `review` si observable via chemins sensibles/transitoires génériques, sinon ne pas prétendre à une couverture parfaite.

## Implementation Tasks

- [ ] Task 1: Define the mechanical hygiene checker
  - File: `tools/audit_gitignore_hygiene.py`
  - Action: Implement a read-only CLI that inspects Git state, `.gitignore`, tracked transient paths, and conservative secret/local-output patterns, then emits stable verdicts and exit codes.
  - User story link: Gives every lifecycle skill the same mechanical truth source before implementation/check/ship.
  - Depends on: none.
  - Validate with: `python3 tools/audit_gitignore_hygiene.py --format json`

- [ ] Task 2: Add the start hard gate
  - File: `skills/102-sg-start/SKILL.md`
  - Action: Require the hygiene tool before significant implementation, define block/reroute behavior, and document the explicit scoped-exception path for hygiene-owned specs.
  - User story link: Prevents implementation on top of a repo state that will later poison checks or ship.
  - Depends on: Task 1.
  - Validate with: `rg -n "audit_gitignore_hygiene|repo hygiene|gitignore|hard gate|scoped exception" skills/102-sg-start/SKILL.md`

- [ ] Task 3: Add the check hard gate
  - File: `skills/105-sg-check/SKILL.md`
  - Action: Run the hygiene tool before interpreting technical checks, block `hard`, report `review/style`, and avoid "green" claims when hygiene is unsafe.
  - User story link: Prevents false technical confidence from a polluted repo.
  - Depends on: Task 1.
  - Validate with: `rg -n "audit_gitignore_hygiene|repo hygiene|gitignore|green" skills/105-sg-check/SKILL.md`

- [ ] Task 4: Add the ship hard gate
  - File: `skills/005-sg-ship/SKILL.md`
  - Action: Enforce the hygiene tool before stage/commit/push, keep it active under `skip-check`, and route hard failures before any `git add`.
  - User story link: Prevents polluted or sensitive files from reaching commit/push.
  - Depends on: Task 1.
  - Validate with: `rg -n "audit_gitignore_hygiene|skip-check|git add|hard gate|repo hygiene" skills/005-sg-ship/SKILL.md`

- [ ] Task 5: Add scenario-first audit coverage to ShipGlows core
  - File: `skills/900-shipglows-core/SKILL.md`
  - Action: Introduce explicit pressure scenarios proving that missing lifecycle hygiene gates are `hard` or `review` findings instead of stylistic comments only.
  - User story link: Makes the governance gap auditable and prevents regressions in future skill rewrites.
  - Depends on: Tasks 2-4.
  - Validate with: `rg -n "gitignore|repo hygiene|scenario-first|pressure scenario|hard" skills/900-shipglows-core/SKILL.md`

- [ ] Task 6: Extend audit entrypoints and code-audit workflow
  - File: `skills/400-sg-audit/SKILL.md`
  - Action: Mention repo hygiene / `.gitignore` gate presence as a valid source finding in global/project audits.
  - User story link: Lets broad audits surface systemic hygiene gaps before they become ship incidents.
  - Depends on: Tasks 2-5.
  - Validate with: `rg -n "gitignore|repo hygiene|hygiene gate" skills/400-sg-audit/SKILL.md`

- [ ] Task 7: Extend the technical audit mode contract
  - File: `skills/010-sg-technical/SKILL.md`
  - Action: Add repo-hygiene and `.gitignore` coverage to the code audit mission/rules where appropriate.
  - User story link: Makes code audits detect this class of workflow-security failure.
  - Depends on: Tasks 2-5.
  - Validate with: `rg -n "gitignore|repo hygiene|transient|secret" skills/010-sg-technical/SKILL.md`

- [ ] Task 8: Replace env-only checklist coverage with scenario-first repo-hygiene coverage
  - File: `skills/010-sg-technical/references/technical-audit-playbook.md`
  - Action: Expand the security/configuration checklist from `.env`-only to broader repo-hygiene cases, with required scenarios and classification guidance.
  - User story link: Prevents audits from missing non-env transient or local-output leaks.
  - Depends on: Task 7.
  - Validate with: `rg -n "\\.gitignore|repo hygiene|tracked transient|GIH-" skills/010-sg-technical/references/technical-audit-playbook.md`

- [ ] Task 9: Integrate the mechanical checker into ShipGlows skill auditing
  - File: `tools/audit_shipglows_skills.py`
  - Action: Add checks or scenarios ensuring targeted lifecycle skills reference the hygiene tool and preserve the blocking semantics.
  - User story link: Gives one repeatable meta-audit for ongoing contract drift.
  - Depends on: Tasks 2-8.
  - Validate with: `python3 tools/audit_shipglows_skills.py`

- [ ] Task 10: Add the manual scenario checklist artifact
  - File: `shipglows_data/workflow/test-checklists/gitignore-repo-hygiene.md`
  - Action: Record scenario IDs, setup, expected verdicts, and proof capture order for `103-sg-verify`.
  - User story link: Makes verification deterministic for a fresh agent.
  - Depends on: Tasks 1-9.
  - Validate with: `test -f shipglows_data/workflow/test-checklists/gitignore-repo-hygiene.md`

## Acceptance Criteria

- [ ] AC 1: Given a repo with tracked `site/.playwright-mcp/*.yml` or equivalent transient outputs, when `005-sg-ship` runs, then it stops before `git add` and reports a `hard` hygiene failure with the offending paths.
- [ ] AC 2: Given a repo with `.env` or other sensitive local credential files not ignored, when `102-sg-start`, `105-sg-check`, or `005-sg-ship` runs, then the skill blocks and does not claim success/green/ship.
- [ ] AC 3: Given a repo with missing ignore patterns for known local-tool outputs, when `105-sg-check` runs, then it cannot finish with a clean technical-confidence verdict until the hygiene issue is resolved or explicitly owned by the chantier.
- [ ] AC 4: Given a spec whose scope is specifically repo-hygiene cleanup, when `102-sg-start` runs, then it may continue despite the dirty hygiene surface, but only after explicitly naming that owned exception in the execution/report contract.
- [ ] AC 5: Given `skip-check` in `005-sg-ship`, when `hard` hygiene findings exist, then ship is still blocked because hygiene gating is not an optional check lane.
- [ ] AC 6: Given `900-shipglows-core` or `tools/audit_shipglows_skills.py` audits a lifecycle skill missing the hygiene gate, then it emits a deterministic finding tied to at least one `GIH-*` scenario.
- [ ] AC 7: Given `$010-sg-technical audit <target>` runs on a project with unsafe transient or secret local outputs, then the audit can report a finding even when `.env` is not the only issue.
- [ ] AC 8: Given a clean repo with no unsafe hygiene findings, when the tool runs, then it returns `clean`, exit `0`, and does not block normal lifecycle flow.

## Test Strategy

- Unit-like CLI coverage for `tools/audit_gitignore_hygiene.py` using fixture repos or controlled temp directories.
- Scenario-first skill validation by targeted `rg` plus meta-audit in `tools/audit_shipglows_skills.py`.
- Manual proof through `shipglows_data/workflow/test-checklists/gitignore-repo-hygiene.md` for the blocker paths and scoped exception path.
- Regression check that `005-sg-ship skip-check` still enforces hygiene.
- Regression check that code audit workflow no longer treats `.gitignore` as env-only.

## Risks

- False positives if the rule set is too broad, especially for intentionally versioned fixture files.
- False negatives if the initial rule set knows only a narrow set of local-tool outputs.
- Skill wording drift if the mechanical tool exists but one lifecycle skill stops calling it.
- Operator frustration if the block message is vague or does not name the exact remediation route.
- Hidden monorepo complexity if nested ignore files or multiple package roots are not handled clearly.

## Rollout

1. Land `tools/audit_gitignore_hygiene.py` with stable exit codes and fixture-level proof.
2. Wire `102-sg-start`, `105-sg-check`, and `005-sg-ship` to the tool and ship the blocker semantics first.
3. Extend `900-shipglows-core`, `400-sg-audit`, `$010-sg-technical audit <target>`, and its technical-audit playbook with `GIH-*` scenarios.
4. Verify with `103-sg-verify` using the dedicated checklist and meta-audit.
5. Close with `104-sg-end` only after runtime docs/changelog coherence is either updated or explicitly marked not needed.

## Commands

```bash
python3 tools/audit_gitignore_hygiene.py --format text
python3 tools/audit_gitignore_hygiene.py --format json
python3 tools/audit_shipglows_skills.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --all
rg -n "audit_gitignore_hygiene|repo hygiene|gitignore" skills/102-sg-start/SKILL.md skills/105-sg-check/SKILL.md skills/005-sg-ship/SKILL.md skills/900-shipglows-core/SKILL.md skills/400-sg-audit/SKILL.md skills/010-sg-technical/SKILL.md skills/010-sg-technical/references/technical-audit-playbook.md
```

## Execution Notes

- Read first: `skills/102-sg-start/SKILL.md`, `skills/105-sg-check/SKILL.md`, `skills/005-sg-ship/SKILL.md`, `skills/900-shipglows-core/SKILL.md`, `skills/010-sg-technical/SKILL.md`, and `skills/010-sg-technical/references/technical-audit-playbook.md` before executing `$010-sg-technical audit <target>`.
- Implement the tool before changing skill wording so the contracts can reference a real command, exit code map, and output format.
- Keep the first version conservative and focused on high-confidence findings: tracked transient outputs, missing `.gitignore`, known secret/local files, and obviously unsafe local-tool directories.
- Do not auto-edit `.gitignore`, `git rm`, or clean the worktree from inside the tool; routing and lifecycle ownership must stay explicit.
- Stop if the desired rule set expands into a generic secret scanner or full GitHub hygiene suite; that belongs to a different chantier.
- Validation order after edits: hygiene tool fixtures or temp-repo checks, targeted `rg`, `python3 tools/audit_shipglows_skills.py`, `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`, then `tools/shipglows_sync_skills.sh --check --all`.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-18 21:13:04 UTC | 100-sg-spec | GPT-5 Codex | Created a ready-to-implement spec for hard `.gitignore` and repo-hygiene gates across lifecycle skills, a mechanical checker, and scenario-first audit coverage | drafted | /101-sg-ready shipglows_data/workflow/specs/shipglows-gitignore-and-repo-hygiene-hard-gates-for-agents-and-audits.md |

## Current Chantier Flow

- 100-sg-spec: drafted
- 101-sg-ready: pending
- 102-sg-start: pending
- 103-sg-verify: pending
- 104-sg-end: pending
- 005-sg-ship: pending
- Next step: `/101-sg-ready shipglows_data/workflow/specs/shipglows-gitignore-and-repo-hygiene-hard-gates-for-agents-and-audits.md`
