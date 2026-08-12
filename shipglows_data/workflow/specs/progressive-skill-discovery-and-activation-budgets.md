---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
created_at: "2026-08-12 12:42:51 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 12:59:51 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5-codex
scope: progressive-skill-discovery-and-activation-budgets
owner: Diane
confidence: high
user_story: "En tant que mainteneuse de ShipGlows, je veux que les skills publics restent facilement découvrables et que les moteurs internes chargent seulement leurs références utiles afin de réduire le contexte sans perdre les contrats critiques."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - skills/references/skill-context-budget.md
  - skills/references/resource-discovery.md
  - skills/references/skill-instruction-layering.md
  - tools/skill_budget_audit.py
  - tools/resource_resolver.py
  - tools/shipglows_sync_skills.ps1
  - tools/shipglows_sync_skills.sh
depends_on:
  - artifact: skills/references/skill-context-budget.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/resource-discovery.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "2026-08-12 source inventory: 65 skills, 7098 portable discovery characters and 9438 checkout-absolute characters against an 8500-character budget."
  - "2026-08-12 runtime inventory: 65 installed skills and 8658 lexical discovery characters; junction resolution incorrectly reports the source checkout path."
  - "2026-08-12 resolver samples: eight-result starter packs load roughly 16000 to 18500 estimated tokens because only result count is bounded."
  - "OpenAI Codex skills documentation checked on 2026-08-12: discovery initially exposes name, description, and path; full instructions load after selection."
  - "Operator approval 2026-08-12: improve skill efficiency and compact through the existing references and dependency system; dependency-graph work remains deferred."
next_step: none
---

# Title

Progressive skill discovery and activation budgets

# Status

Reviewed.

# User Story

En tant que mainteneuse de ShipGlows, je veux que les skills publics restent facilement découvrables et que les moteurs internes chargent seulement leurs références utiles afin de réduire le contexte sans perdre les contrats critiques.

# Minimal Behavior Contract

Les quatorze entrypoints publics restent implicitement découvrables. Les moteurs experts restent installés et explicitement invocables, mais ne consomment plus le contexte de découverte par défaut. L'audit sépare la mesure portable de la source, le diagnostic absolu du checkout et la mesure lexicale d'un runtime explicitement fourni. Le resolver borne aussi ses starter packs par volume estimé, en plus du nombre de résultats, et rend visibles les ressources non actives ou écartées.

# Success Behavior

- Les wrappers publics continuent à router vers leurs moteurs canoniques sans dépendre de leur présence comme siblings dans le runtime.
- Les moteurs experts sont disponibles par invocation explicite et par routage public, sans être injectés implicitement dans la liste initiale.
- Le budget source portable est invariant à la profondeur du clone; l'absolu source reste un diagnostic non bloquant.
- Un runtime explicitement audité utilise ses chemins lexicaux, sans résoudre les junctions vers la source, et peut bloquer au-dessus du seuil.
- Les starter packs respectent un plafond de tokens estimés et expliquent les ressources ignorées ou non fiables.
- Deux moteurs pilotes prouvent une compaction par décision de chargement sans perdre leurs stop conditions ni leurs preuves.

# Error Behavior

- Un catalogue inconnu, un runtime absent, un seuil invalide ou une politique d'invocation mal formée échoue avec un message actionnable.
- Un runtime au-dessus du plafond échoue sur sa propre mesure, même si la source portable passe.
- Une ressource individuelle dépassant le budget restant est ignorée et signalée; elle n'est jamais tronquée silencieusement.
- Les ressources `draft`, `unknown` ou `reviewed` restent visibles comme telles et ne sont pas présentées comme `active`.
- Une référence obligatoire manquante, un loader public cassé ou une perte de garde-fou dans un pilote fait échouer les tests ciblés.

# Problem

Le budget actuel mélange le coût portable du catalogue et la longueur absolue du chemin du checkout. Il suit les junctions du runtime vers la source, ce qui produit un faux dépassement de 9438 caractères alors que le runtime lexical mesure 8658. En parallèle, la compaction des corps n'agit pas sur ce budget de découverte, et le resolver peut charger plus de 18000 tokens dans un starter pack pourtant limité à huit résultats. Plusieurs longs moteurs répètent aussi des contrats déjà présents dans leurs références.

# Solution

Appliquer la divulgation progressive sur trois niveaux indépendants : catalogue public implicite, moteurs experts explicites, puis références conditionnelles bornées. Étendre les outils existants plutôt que créer un nouveau graphe. Utiliser la politique runtime `allow_implicit_invocation`, le registre public existant, des loaders canoniques depuis `$SHIPGLOWS_ROOT`, une mesure de budget explicite et un plafond de tokens pour les packs. Valider le modèle sur `704-sg-model` et `706-continue` avant toute compaction plus large.

# Scope In

- Politique d'invocation implicite/explicite pour les 14 wrappers publics et les 51 moteurs experts.
- Loaders publics indépendants de la disposition du catalogue runtime.
- Audit de découverte catalogué, portable et runtime lexical.
- Plafond de volume pour les résultats de `resource_resolver.py`, avec état et exclusions visibles.
- Compaction pilote de `704-sg-model` et `706-continue` par références conditionnelles existantes ou bornées.
- Tests de contrat, documentation technique active, metadata lint et refresh log.

# Scope Out

- Construire ou visualiser un graphe complet de dépendances.
- Retirer ou supprimer les moteurs experts installés.
- Modifier le plafond de 8500 caractères pour masquer un dépassement.
- Compacter l'ensemble des skills longs ou scinder toutes les références supérieures à 5000 tokens.
- Imposer `active` à toutes les ressources historiques ou valider maintenant les versions imbriquées de chaque dépendance.
- Modifier les comportements métier publics.

# Constraints

- Préserver les invocations explicites `$skill` et le routage par les wrappers publics.
- Ne pas remplacer en masse les références d'activation critiques par des identifiants sémantiques.
- Compter une ressource partagée une seule fois dans un pack.
- Ne pas parser la prose conditionnelle pour fabriquer un pseudo-graphe.
- Préserver les sorties CLI existantes lorsque possible et ajouter des libellés non ambigus.
- Utiliser des lots d'écriture sans chevauchement et préserver les modifications concurrentes.

# Test Contract

Proof path: `scenario-first`.

- `DISCOVERY-CATALOG`: public, expert et all sélectionnent exactement les ensembles du registre.
- `DISCOVERY-PATH-INVARIANT`: deux clones de profondeurs différentes produisent le même verdict portable.
- `DISCOVERY-DIAGNOSTIC`: l'absolu source est rapporté sans bloquer le verdict portable.
- `DISCOVERY-RUNTIME-PATH`: un runtime explicite est mesuré lexicalement et bloque réellement au-dessus du seuil.
- `DISCOVERY-POLICY`: les wrappers publics sont implicites; les experts sont explicites mais restent installables et invocables.
- `RESOURCE-TOKEN-BOUND`: le pack respecte nombre et tokens, déduplique et rapporte les exclusions.
- `RESOURCE-STATUS`: le statut réel est affiché; `draft`, `unknown` et `reviewed` ne deviennent pas silencieusement `active`.
- `PILOT-COMPACTION`: les routes, stops, validations et rapports de 704/706 restent présents après extraction.

# Dependencies

- Registre existant `skills/references/skill-invocation-registry.json` comme autorité de catalogue.
- Politique `agents/openai.yaml` supportée par le runtime Codex local.
- Résolveur et audits existants, sans nouveau package Python.
- Documentation OpenAI fraîche pour les contraintes de découverte; architecture ShipGlows locale pour le reste.

# Invariants

- Les 14 entrypoints publics restent inchangés en nom, promesse et modes.
- Les 51 moteurs experts restent installés et explicitement accessibles.
- Les diagnostics de corps, métadonnées, descriptions et références restent appliqués à tous les skills audités, même si certains ne sont pas implicitement découverts.
- Les stop conditions, preuves, limites d'autorité et contrats de reporting des pilotes restent au même niveau ou deviennent plus explicites.
- Security impact: none, because the change affects local instruction discovery, packaging, and read-only analysis; it introduces no auth, secret, permission, or product-data behavior.

# Links & Consequences

- Les scripts de sync doivent copier les `agents/openai.yaml` et vérifier la cohérence public/expert sans nécessairement nettoyer les experts.
- Les wrappers doivent charger les moteurs depuis la racine canonique du dépôt afin de survivre à un runtime public-only futur.
- Les sorties d'audit peuvent être consommées par la documentation, les tests et la CI; les anciens champs utiles doivent rester reconnaissables.
- Le resolver reste un outil d'aide à la découverte, pas une autorité qui rend automatiquement une ressource normative.

# Documentation Coherence

Mettre à jour `skill-context-budget.md` avec les mesures 2026-08-12 et la distinction découverte/activation. Mettre à jour `resource-discovery.md` avec le plafond count+tokens et les statuts. Mettre à jour `skill-instruction-layering.md` pour la politique public implicite/expert explicite. Référencer les nouveaux tests dans la documentation technique uniquement si la carte de code active l'exige.

# Edge Cases

- Runtime construit par junction, symlink ou copie physique.
- Chemins Windows de profondeurs différentes et séparateurs différents.
- Skill sans `agents/openai.yaml`, fichier présent sans bloc `policy`, ou valeur non booléenne.
- Catalogue public contenant un alias ou moteur manquant sur disque.
- Ressource unique plus grande que le plafond total.
- Résultats partageant une même référence ou présentant des statuts historiques non normalisés.
- Invocation directe d'un expert explicit-only puis chargement d'un wrapper public.

# Implementation Tasks

- [x] Tâche 1 : rendre l'audit de découverte catalogué et fidèle au runtime.
  - Fichiers : `tools/skill_budget_audit.py`, `tools/test_skill_budget_audit.py`.
  - Action : séparer diagnostics source, estimation portable et runtime lexical; prendre en compte le catalogue et la politique d'invocation.
  - Validate with : scénarios DISCOVERY et compatibilité CLI.

- [x] Tâche 2 : rendre les packs de ressources bornés et explicables.
  - Fichiers : `tools/resource_resolver.py`, `tools/test_resource_resolver.py`.
  - Action : ajouter un budget de tokens, dédupliquer et exposer statuts/exclusions sans construire de graphe.
  - Validate with : RESOURCE-TOKEN-BOUND et RESOURCE-STATUS.

- [x] Tâche 3 : appliquer la politique de divulgation progressive.
  - Fichiers : `skills/*/agents/openai.yaml`, wrappers publics et test de contrat dédié.
  - Action : wrappers implicites, experts explicit-only, loaders via `$SHIPGLOWS_ROOT`.
  - Validate with : inventaire 14/51, tests de sélection et sync.

- [x] Tâche 4 : compacter les deux moteurs pilotes.
  - Fichiers : `skills/704-sg-model`, `skills/706-continue`, références et tests associés.
  - Action : garder le contrat de décision local et charger les détails par mode; supprimer les duplications avec les références maîtres.
  - Validate with : PILOT-COMPACTION et comparaison de taille/contrats.

- [x] Tâche 5 : aligner les références actives et exécuter la preuve globale.
  - Fichiers : trois références techniques, `skills/REFRESH_LOG.md`, cartes de code seulement si requises.
  - Action : documenter les métriques, limites et décisions puis exécuter audits, tests et sync.
  - Validate with : metadata lint, audits globaux, tests unitaires et `git diff --check`.

# Execution Batches

- Batch A — discovery audit: `tools/skill_budget_audit.py`, `tools/test_skill_budget_audit.py`.
- Batch B — bounded resolver: `tools/resource_resolver.py`, `tools/test_resource_resolver.py`.
- Batch C — invocation policy: `skills/*/agents/openai.yaml`, public wrapper loaders, dedicated policy contract test.
- Batch D — pilots: `skills/704-sg-model/**`, `skills/706-continue/**`, dedicated pilot tests; starts after A-C stabilize.
- Batch E — integration docs: shared references, spec, refresh log and global validation; owned by the parent agent.

# Acceptance Criteria

- [x] CA1 : Given the source tree at two checkout depths, when the portable audit runs, then both verdicts and totals are identical.
- [x] CA2 : Given a runtime root containing junctioned skills, when runtime discovery is audited, then lexical runtime paths are counted and a real overage fails.
- [x] CA3 : Given the catalog registry, when discovery policy is inspected, then exactly 14 public wrappers are implicit and 51 expert skills are explicit-only.
- [x] CA4 : Given an explicit expert invocation or a public wrapper route, when the engine is needed, then its canonical `SKILL.md` remains reachable.
- [x] CA5 : Given ranked resource results above the token cap, when a starter pack is emitted, then the selected unique resources fit the cap and skipped items are reported with status and size.
- [x] CA6 : Given `704-sg-model` or `706-continue`, when a supported mode executes, then only its bounded playbook is required and all safety, validation, and reporting contracts remain enforceable.
- [x] CA7 : Given the full modified tree, when focused and global checks run, then metadata, references, budget, selection, sync and diff checks pass without unrelated regressions.

# Test Strategy

1. Écrire les tests de scénario avant ou avec chaque changement de comportement.
2. Exécuter les tests ciblés des batches A-C, puis le contrat des pilotes.
3. Mesurer avant/après découverte et activation des pilotes.
4. Exécuter les suites ShipGlows pertinentes, metadata lint, skill audits et sync check.
5. Vérifier manuellement les sorties CLI, loaders canoniques et invocations explicites.

# Risks

- Une politique explicit-only peut réduire le routage implicite si un wrapper public ne couvre pas une intention historique.
- Un loader canonique dépend de `$SHIPGLOWS_ROOT`; l'absence de racine doit produire un arrêt visible.
- Un plafond de tokens trop bas peut exclure une référence essentielle; les références obligatoires restent hors du pack advisory.
- Une estimation par caractères n'est pas un tokeniseur exact; elle doit rester déterministe et documentée.
- La compaction peut déplacer du texte sans réduire le coût si la nouvelle référence devient obligatoire trop tôt.

# Execution Notes

- Les batches A-C sont sans chevauchement et peuvent être exécutés en parallèle après cette readiness review.
- Ne pas modifier `internal_catalog.include_all_runtime_skills` dans ce chantier : installation et découverte implicite sont deux axes distincts.
- Garder les quatre experts encore non rattachés au registre expert; leur rattachement relève du futur graphe/taxonomie.
- Une référence obligatoire est comptée séparément d'un starter pack advisory.
- Stopper avant tout nettoyage d'installation ou suppression d'alias.

# Open Questions

- La mesure d'activation généralisée nécessitera-t-elle plus tard un petit manifeste explicite par skill ? Décision différée après les deux pilotes.
- Quel catalogue expert minimal devra être installé par défaut une fois les loaders canoniques prouvés ? Hors périmètre actuel.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-12 12:42:51 | 100-sg-spec | create | Spec créée à partir des mesures de découverte, d'activation et de l'accord opérateur. |
| 2026-08-12 12:42:51 | 101-sg-ready | review | Ready : problème, solution, scénarios, dépendances, risques, sécurité, docs et lots d'exécution sont explicites. |
| 2026-08-12 12:50:00 | 102-sg-start | execute | Lots A-D intégrés : audit catalogué, resolver borné, politique 14/51, loaders canoniques et pilotes 704/706. |
| 2026-08-12 12:57:00 | 103-sg-verify | verify | 67 tests ciblés, audits 65 skills, metadata lint, référence checks, budget implicite 1712/8500 et sync Codex 14/14 passent. |
| 2026-08-12 12:59:51 | 104-sg-end | close | Documentation active et refresh log alignés; le graphe complet et la compaction de la vague suivante restent des chantiers distincts. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end (completed)`
