---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "ShipGlows"
created: "2026-07-29"
created_at: "2026-07-29 00:00:00 UTC"
updated: "2026-07-29"
updated_at: "2026-07-29 00:00:00 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "public-pack-portability"
owner: "Diane"
user_story: "En tant qu'opératrice ShipGlows, je veux que chaque pack candidat puisse être évalué et exécuté depuis un environnement public sans checkout développeur implicite, afin de ne promouvoir que des packs réellement portables."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "plugins/shipglows/"
  - "plugins/shipglows/scripts/audit_shipglows_packaging.py"
  - "plugins/shipglows/scripts/stage_shipglows_pack.py"
  - "plugins/shipglows/skills/shipglows/references/pack-catalog.md"
  - "shipglows_data/technical/codex-plugin-packaging.md"
  - "skills/references/canonical-paths.md"
  - "skills/400-sg-audit/SKILL.md"
  - "skills/010-sg-technical/SKILL.md"
  - "skills/407-sg-audit-translate/SKILL.md"
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-main-plugin-and-pack-portability.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/technical/codex-plugin-packaging.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "2026-07-29 targeted packaging audit for shipglows-quality: 0 hard findings, 3 review findings."
  - "The three review findings identify source-tree assumptions in 400-sg-audit, 010-sg-technical, and 407-sg-audit-translate."
  - "The planned shipglows-quality pack currently contains source skills rather than portable plugin-local contracts."
  - "The existing shipglows-main-plugin-and-pack-portability chantier is historical and does not define the current quality-pack portability gate."
  - "The active GitHub hygiene consolidation is a separate chantier and must not be reopened or expanded by this work."
next_step: "/101-sg-ready shipglows pack portability hardening"
---

# Spec: ShipGlows Pack Portability Hardening

## Title

Rendre les packs publics réellement portables

## Status

draft

## User Story

En tant qu'opératrice ShipGlows, je veux que les packs candidats soient testés
depuis un environnement public qui ne possède pas le checkout développeur
ShipGlows, afin de pouvoir distinguer un pack publiable d'un simple snapshot
interne.

## Minimal Behavior Contract

Lorsqu'un pack est audité ou staged, le système doit identifier ses dépendances
au corpus source, aux chemins `$SHIPGLOWS_ROOT`, aux références partagées et aux
outils internes, puis produire une décision explicite par pack : portable,
portable avec bootstrap explicite, revue requise, ou non publiable. Un pack ne
peut être déclaré public-ready si son exécution suppose silencieusement
`/home/claude/shipglows`, un chemin machine, une référence absente, un réseau
non documenté ou un skill source non embarqué. L'absence d'un checkout local
doit donner un échec diagnostiquable et récupérable, jamais une réussite
silencieuse.

## Success Behavior

- Preconditions: un pack est déclaré dans le catalogue et possède une source ou un candidat staged.
- Trigger: l'opérateur lance l'audit ou le staging d'un pack depuis un chemin de travail distinct du checkout source.
- User/operator result: un rapport par pack classe chaque dépendance et donne la raison de la décision.
- System effect: le catalogue, les scripts et les références locales portent le même statut de portabilité; aucune publication n'est déclenchée automatiquement.
- Success proof: audit ciblé, staging dans un répertoire temporaire propre, validation du plugin candidat et smoke test sans `$SHIPGLOWS_ROOT` implicite.
- Silent success: non autorisée; tout statut `public-ready` doit être accompagné d'une preuve reproductible.

## Error Behavior

- Expected failures: référence partagée absente, chemin source codé en dur, variable d'environnement manquante, skill non embarqué, outil interne indisponible, réseau requis mais non déclaré.
- User/operator response: le rapport identifie la dépendance, le niveau de gravité, le correctif attendu et le mode de récupération autorisé.
- System effect: le pack reste `planned`, `review`, ou `blocked`; il n'est ni publié ni promu comme public-ready.
- Must never happen: packaging de secrets, transcriptions privées, caches, dépendances, symlinks vers le checkout local ou chemins machine non portables.
- Silent failure: non autorisée; l'audit doit retourner un résultat non vert quand l'exécution ne peut pas être reproduite hors du checkout source.

## Problem

L'audit actuel du pack `shipglows-quality` ne détecte aucun hard finding, mais
signale trois dépendances de structure source dans `400-sg-audit`,
`010-sg-technical` et `407-sg-audit-translate`. Le statut `planned` ne permet
pas encore de savoir si ces skills peuvent fonctionner dans le plugin public,
dans un bootstrap sparse explicite, ou uniquement dans le dépôt interne.

Ce chantier est distinct de la consolidation GitHub sous `010-sg-technical`.
Il traite la frontière de packaging et l'exécution hors checkout; il ne change
ni les modes GitHub, ni le playbook GitHub, ni la retraite de l'ancien skill.

## Solution

Définir un contrat de portabilité par pack, renforcer l'audit pour distinguer
les dépendances acceptables des dépendances bloquantes, puis adapter ou router
les skills uniquement quand leur propriétaire et leur surface d'exécution sont
clairs. La promotion d'un pack dépendra d'un test depuis un répertoire propre
et d'une décision documentée entre bundle local, bootstrap explicite et maintien
interne.

## Scope In

- Le pack `shipglows-quality` en premier candidat, avec ses skills `400`, `010` et `407`.
- La définition des classes de portabilité et des statuts de promotion.
- L'audit, le staging, la validation et le smoke test depuis un chemin propre.
- Les références et le catalogue public nécessaires pour refléter le statut réel.
- La frontière entre contrat plugin-local, bootstrap sparse et corpus interne.
- La détection des chemins absolus, `$SHIPGLOWS_ROOT`, références absentes, outils non distribués et dépendances réseau implicites.

## Scope Out

- La consolidation GitHub fonctionnelle est traitée par le mode `github` de `010-sg-technical` dans le chantier technique principal.
- Toute modification du mode `github`, de `github-hygiene-playbook.md` ou de ses tests, sauf preuve directe d'un défaut de packaging dans ce chantier.
- La publication marketplace, le bootstrap réseau ou l'installation externe sans approbation explicite.
- La transformation automatique de tous les skills internes en skills publics.
- Le redesign du produit mono-plugin `shipglows`.
- Les packs non concernés par une preuve de dépendance; ils seront traités par lots ultérieurs.

## Constraints

- `shipglows` reste le plugin public canonique; `900-shipglows-core` reste interne.
- Le plugin public doit rester utilisable sans checkout développeur et sans réseau pour ses contrats critiques.
- Un bootstrap sparse est une voie explicite, distincte d'une portabilité autonome.
- Les scripts d'audit et de staging restent déterministes, idempotents et non destructifs.
- Aucun secret, contexte privé, cache, dépendance ou chemin machine ne doit entrer dans un candidat.
- Le travail doit préserver les changements déjà réalisés pour la consolidation GitHub.

## Dependencies

- Runtime: Python 3, plugin-creator validation, Git; Node uniquement pour la build du site si une surface publique est modifiée.
- Document contracts: `codex-plugin-packaging.md`, `canonical-paths.md`, catalogue public, stratégie de références et contrat de reporting.
- Metadata gaps: les trois review findings actuels ne disent pas encore si chaque dépendance doit être embarquée, remplacée ou routée vers le bootstrap; la readiness doit résoudre ce choix par skill.

## Invariants

- Aucun pack ne reçoit `public-ready` sur la seule absence de hard findings.
- Toute dépendance au corpus complet est soit embarquée dans le candidat, soit déclarée comme bootstrap explicite, soit classée interne/revue.
- Les références d'exécution critiques restent locales à la surface choisie.
- Le rapport de portabilité est reproductible depuis un répertoire qui n'est pas le checkout source.
- La consolidation GitHub demeure traçable et indépendante.
- Une erreur de portabilité bloque la promotion, pas la possibilité d'auditer le pack.

## Links & Consequences

- Upstream systems: catalogue des packs, skills source, références canoniques, règles de packaging et décision mono-plugin-first.
- Downstream systems: plugin candidat, cache local éventuel, site/docs de packaging et futurs workflows de publication.
- Cross-cutting checks: sécurité de contenu packagé, chemins machine, réseau, reproductibilité, metadata, build public et compatibilité d'installation.

## Documentation Coherence

- Mettre à jour `codex-plugin-packaging.md` avec les classes et le gate de portabilité.
- Aligner le catalogue public sur le statut réel de `shipglows-quality`.
- Documenter le choix bundle/bootstrap/interne dans une matrice versionnée.
- Ne pas modifier les pages ou références GitHub sauf si un lien de packaging est devenu faux.

## Edge Cases

- Le pack passe avec `$SHIPGLOWS_ROOT` défini mais échoue quand cette variable est absente.
- Une référence est présente dans le dépôt source mais absente du plugin candidat.
- Un skill source fonctionne via un outil interne non inclus dans le plugin.
- Un chemin absolu pointe vers le checkout de l'opérateur sans être détecté comme hard finding.
- Le pack est structurellement valide mais son contrat d'exécution dépend du réseau.
- Une dépendance peut être satisfaite par bootstrap, mais le pack est présenté à tort comme autonome.
- Un pack de qualité contient `010-sg-technical github`; cette présence doit rester une dépendance packaging à évaluer, sans rouvrir le chantier de consolidation.

## Implementation Tasks

- [ ] Task 1: Définir la matrice et les statuts de portabilité par pack.
  - File: `plugins/shipglows/skills/shipglows/references/pack-portability-matrix.md`
  - Action: Décrire les classes `autonome`, `bootstrap explicite`, `revue`, `interne`, les preuves attendues et les critères de promotion.
  - User story link: rendre la décision de portabilité observable et reproductible.
  - Depends on: None
  - Validate with: metadata lint et revue des dépendances déclarées.
  - Notes: le premier cas documenté est `shipglows-quality`.

- [ ] Task 2: Étendre l'audit de packaging avec une analyse de dépendances portable/non portable.
  - File: `plugins/shipglows/scripts/audit_shipglows_packaging.py`
  - Action: distinguer les chemins source attendus, références embarquées, bootstrap documenté, réseau et chemins machine; produire des findings actionnables par pack.
  - User story link: empêcher un faux vert public-ready.
  - Depends on: Task 1
  - Validate with: tests ciblés du script sur un pack portable, un pack bootstrap et un pack bloqué.
  - Notes: conserver le mode audit read-only.

- [ ] Task 3: Ajouter le contrat de staging hors checkout source.
  - File: `plugins/shipglows/scripts/stage_shipglows_pack.py`
  - Action: garantir que le candidat staged contient seulement les fichiers autorisés et que ses références critiques résolvent sans checkout développeur implicite.
  - User story link: fournir un artefact testable par un agent frais.
  - Depends on: Task 1
  - Validate with: staging dans un répertoire temporaire propre puis validation du plugin candidat.
  - Notes: aucune suppression large ni bootstrap réseau automatique.

- [ ] Task 4: Adapter les skills du pack selon la décision de portabilité.
  - File: `skills/400-sg-audit/**`, `skills/010-sg-technical/**`, `skills/407-sg-audit-translate/**` ou contrats plugin-local correspondants.
  - Action: supprimer les hypothèses silencieuses, embarquer les contrats critiques, ou router explicitement vers le bootstrap; ne pas modifier la logique GitHub hors besoin démontré.
  - User story link: permettre une exécution correcte dans la surface choisie.
  - Depends on: Tasks 1–3
  - Validate with: audit ciblé, tests de contrat, sync runtime et test sans `$SHIPGLOWS_ROOT` implicite.
  - Notes: toute modification de skill devra rester dans le périmètre de portabilité.

- [ ] Task 5: Aligner catalogue et documentation de packaging.
  - File: `plugins/shipglows/skills/shipglows/references/pack-catalog.md`, `shipglows_data/technical/codex-plugin-packaging.md`
  - Action: publier le statut réel, la preuve exigée et la voie de récupération pour `shipglows-quality`.
  - User story link: éviter qu'un opérateur ou utilisateur confonde pack planifié et pack publiable.
  - Depends on: Tasks 1–4
  - Validate with: lint metadata, build public si pages touchées, audit pack et cohérence des liens.
  - Notes: aucune publication marketplace incluse.

## Acceptance Criteria

- [ ] AC 1: Given `shipglows-quality` is audited from the repository, when the packaging audit runs, then each source-tree assumption is classified with an explicit remediation or disposition.
- [ ] AC 2: Given a staged candidate is created outside the source checkout, when plugin validation runs, then the candidate contains no developer-only absolute path, symlink, secret, cache, dependency directory, or private context.
- [ ] AC 3: Given `$SHIPGLOWS_ROOT` is unset and no developer checkout is available, when a candidate is exercised, then it either executes from bundled contracts or returns an explicit bootstrap-required/blocked result.
- [ ] AC 4: Given a critical shared reference is absent from the candidate, when the audit runs, then the pack cannot be marked `public-ready`.
- [ ] AC 5: Given a pack depends on the sparse checkout, when its status is reported, then it is labeled bootstrap explicite and is not described as autonomous.
- [ ] AC 6: Given the GitHub consolidation is already complete, when portability work is implemented, then no GitHub mode/playbook behavior changes without a separately evidenced packaging defect.
- [ ] AC 7: Given the quality pack has passed its portability gate, when the catalog is read, then its status and proof command match the audit output.

## Test Strategy

- Unit: tests for path/reference classification, allowed packaging paths, status calculation, and report stability.
- Integration: stage and validate `shipglows-quality` from a clean temporary directory; compare source and candidate manifests.
- Manual: inspect the candidate with `$SHIPGLOWS_ROOT` unset and verify the operator-facing disposition without publishing or network bootstrap.

## Test Contract

### Surface

- Stack/surface: Python packaging tooling, Markdown skill contracts, Codex plugin bundle.
- Primary proof mode: mixed.
- Proof order (if applicable): automated, contract, manual.

### Manual checklist

- Needed: yes
- Checklist path: `shipglows_data/workflow/test-checklists/shipglows-pack-portability-hardening.md`
- Required scenario coverage: clean-path staging, unset `$SHIPGLOWS_ROOT`, missing reference, bootstrap-required pack, forbidden packaged path.
- Exception with proof: none; manual clean-path confirmation is required for public-ready.

### Required evidence stack

- Automated / unit / integration checks: `python3 plugins/shipglows/scripts/audit_shipglows_packaging.py --pack shipglow-quality --json`; focused packaging contract tests; plugin validation; `git diff --check`.
- Agent-run browser proof: none, unless public site copy changes.
- Auth/session proof (`sf-auth-debug`): none.
- Contract/integration proof: source/candidate manifest comparison and reference-resolution report.
- Provider evidence: none; no publication or marketplace mutation.
- Device-native proof: none.

## Risks

- Security impact: yes; packaging can leak private corpus data or create unsafe implicit network/filesystem behavior. Mitigate with allowlists, clean-path tests, no-publication gate, and forbidden-content scans.
- Product/data/performance risk: a false portable status damages trust; a false blocked status delays useful distribution. Mitigate with explicit classes, per-pack evidence, and reversible staging.

## Execution Notes

- Read first: `shipglows_data/technical/codex-plugin-packaging.md`, `skills/references/canonical-paths.md`, current pack catalog, and the targeted packaging audit output.
- Validate with: targeted packaging audit, clean-path staging, plugin validation, focused contract tests, metadata lint, and `103-sg-verify` excellence pass.
- Stop conditions: missing portability decision, unsafe packaged content, hidden network/bootstrap requirement, destructive bootstrap request, or evidence that would require reopening the GitHub consolidation.

## Open Questions

None for readiness. The implementation must decide per finding whether the correct disposition is bundle-local, explicit bootstrap, internal-only, or blocked, using the evidence required by the matrix.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-29 00:00:00 UTC | 100-sg-spec | GPT-5 Codex | Created a dedicated portability-hardening chantier from the targeted `shipglows-quality` packaging audit. | draft | /101-sg-ready shipglows pack portability hardening |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: not launched.
- `102-sg-start`: not launched.
- `103-sg-verify`: not launched.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: `/101-sg-ready shipglows pack portability hardening`
