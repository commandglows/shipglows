---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.1"
project: ShipGlows
created: "2026-08-03"
created_at: "2026-08-03 23:07:13 UTC"
updated: "2026-08-03"
updated_at: "2026-08-03 23:20:44 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5
scope: skill-reference-compaction
owner: Diane
confidence: high
user_story: "En tant que mainteneuse de ShipGlows, je veux que les longues références soient chargées par décision ou mode afin que les agents trouvent le bon contrat sans charger des centaines de lignes non pertinentes."
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/008-sg-customer
  - skills/010-sg-technical
  - skills/302-sg-help
  - skills/305-sg-init
  - skills/406-sg-seo
  - skills/600-sg-local-cloud-sync
  - tools/resource_resolver.py
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/resource-discovery.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "2026-08-03 audit: six active skill-local references contain 541 to 872 lines and several independent loading decisions."
  - "Operator approval 2026-08-03: improve the concision of the monolithic references identified by the compaction audit."
next_step: none
---

# Title

Compact monolithic skill references

# Status

Ready.

# User Story

En tant que mainteneuse de ShipGlows, je veux que les longues références soient chargées par décision ou mode afin que les agents trouvent le bon contrat sans charger des centaines de lignes non pertinentes.

# Minimal Behavior Contract

Chaque skill conserve un routeur local explicite qui indique quelle ressource charger pour le mode ou la décision courante. Une requête ciblée ne charge plus un playbook monolithique couvrant des variantes étrangères à la tâche. Si une ressource attendue manque ou si le mode reste ambigu, l'agent s'arrête visiblement au lieu de reconstruire le contrat depuis un ancien fichier ou de charger toutes les variantes.

# Success Behavior

- Les six anciens fichiers deviennent des index courts ou sont remplacés par des cartes de chargement explicites dans leur skill propriétaire.
- Chaque nouveau playbook possède une responsabilité, un titre, un scope et des métadonnées découvrables.
- Les routes `file`, `project`, `global`, bootstrap, help, overlay et sync chargent seulement les ressources requises.
- Les contrats, checklists, exemples et garde-fous existants restent accessibles sans duplication normative.
- Les audits SEO restent strictement en lecture seule sans demande `fix` explicite ou chantier d'implémentation actif.

# Error Behavior

- Un lien manquant, un identifiant sémantique en collision ou une route sans ressource produit un échec de validation.
- Aucun ancien fichier actif n'est supprimé tant que ses consommateurs directs et tests n'ont pas migré ou qu'un index de compatibilité borné n'est pas justifié.
- Une réduction de lignes qui perd un garde-fou, une preuve ou une route est rejetée par les scénarios ciblés.
- Une branche d'audit qui suggère une mutation directe est corrigée pour respecter l'autorité du dispatcher au lieu d'être recopiée dans les nouveaux fichiers.

# Problem

La première passe de compaction a ramené les `SKILL.md` sous budget, mais plusieurs références locales sont devenues des monolithes de 541 à 872 lignes. Elles mélangent modes, templates, variantes d'interface, contrats backend et checklists. Le chargement progressif existe donc en théorie mais reste grossier sur ces six propriétaires.

# Solution

Découper chaque référence selon ses véritables frontières de chargement, conserver un index local court lorsque le chemin historique est encore consommé, puis mettre à jour les skills propriétaires, tests, métadonnées et ressources sémantiques. Ne pas fractionner les contrats qui doivent être compris atomiquement.

# Scope In

- `008-sg-customer`: séparer contrat d'overlay, implémentations par technologie, persistance/copy et preuve.
- `010-sg-technical`: séparer doctrine commune et modes file/project/global avec tracking/reporting partagé.
- `302-sg-help`: séparer catalogue des skills, invocation/runtime, cycles de travail et réponses rapides.
- `305-sg-init`: séparer orchestration bootstrap, templates de gouvernance, MCP/runtime et reporting.
- `406-sg-seo`: séparer doctrine commune et audits page/project/global avec tracking/reporting partagé.
- `600-sg-local-cloud-sync`: séparer UX overlay, données/merge, queue/hydratation, recovery et preuve.
- Mettre à jour uniquement les liens actifs, tests et métadonnées nécessaires à la découvrabilité.

# Scope Out

- Renommer, fusionner ou retirer des skills.
- Modifier les comportements métier publics des six propriétaires.
- Réécrire les specs ou conversations historiques qui citent les anciens chemins.
- Refondre globalement le résolveur de ressources.
- Modifier la traduction, le pilotage ou l'alias emailing.

# Constraints

- Garder chaque ressource directement atteignable depuis le `SKILL.md` ou un index local unique; aucune chaîne de références profonde.
- Ne pas dupliquer une règle normative entre l'index et les playbooks.
- Conserver les stop conditions, contrats de preuve, règles de sécurité et conséquences documentaires.
- Préserver les fichiers historiques cités par des specs closes; seuls les consommateurs actifs sont migrés.
- Utiliser `apply_patch` pour les modifications et préserver tout travail concurrent.

# Test Contract

Proof path: `scenario-first`.

Surface: local Markdown skill contracts. Proof profile: automated contract and discovery checks only. Proof order: focused owner tests → resource-resolver scenarios → metadata and global skill audits → runtime sync check. Manual proof and checklist path are not applicable because no rendered or external behavior changes.

- Scénarios de sélection: une intention ciblée retourne le playbook propriétaire pertinent sans résultats étrangers dominants.
- Scénarios de complétude: chaque section normative de l'ancien fichier existe exactement une fois dans la nouvelle architecture.
- Scénarios de rupture: un nouveau fichier manquant ou un lien actif obsolète fait échouer un test ciblé.
- Contrôles mécaniques: tests propriétaires, résolveur, audit de fidélité, budget, métadonnées, index et sync runtime.

# Dependencies

- Références ShipGlows locales uniquement; `fresh-docs not needed`.
- `tools/resource_resolver.py` et ses métadonnées actuelles.
- Tests de contrat existants pour les six skills.

# Invariants

- Le nom, la description, les modes publics et l'autorité métier des six skills ne changent pas.
- Une requête spécialisée ne doit pas nécessiter le chargement de toutes les variantes.
- Les résultats d'audit, de bootstrap, d'aide, d'onboarding et de sync gardent leurs exigences de preuve et de reporting.
- Les anciens chemins restent soit actifs comme index courts, soit entièrement migrés avec preuve d'absence de consommateurs actifs.
- Security impact: none, because this chantier changes local instruction packaging only and introduces no auth, data, network, secret, permission, or runtime-product behavior.

# Links & Consequences

- Les owner `SKILL.md`, tests de contrat, `400-sg-audit`, playbooks de lancement et documentation technique peuvent contenir des liens actifs.
- Le résolveur dépend des frontmatters, titres, scopes, `linked_systems` et `source_skill` des nouveaux fichiers.
- La distribution Claude/Codex doit rester synchronisée après l'ajout de ressources locales.

# Documentation Coherence

Mettre à jour les descriptions internes des références dans les six owner skills. Aucun changement public n'est attendu puisque les modes, noms et promesses restent identiques. Mettre à jour README ou pages publiques uniquement si un chemin interne y est exposé comme contrat actif.

# Edge Cases

- Un gros fichier peut être atomique malgré sa taille; ne le diviser que si deux décisions de chargement existent réellement.
- Les exemples Vue et Flutter peuvent partager un contrat tout en ayant des implémentations séparées.
- Les modes global/project/page réutilisent une doctrine commune sans la copier.
- Les templates bootstrap volumineux peuvent devenir des ressources dédiées sans devenir des skills.
- Un index de compatibilité ne doit pas inviter l'agent à charger toutes ses cibles.

# Implementation Tasks

- [x] Tâche 1 : Inventorier les sections, consommateurs actifs et tests de chaque monolithe.
  - Fichiers : les six références, leurs owner skills et les tests associés.
  - Action : produire une matrice source → nouvelle ressource et figer les scénarios de sélection.
  - User story link : garantit qu'aucune règle n'est perdue.
  - Depends on : none.
  - Validate with : `rg` ciblé et inventaire des headings.

- [x] Tâche 2 : Découper les playbooks par décision de chargement.
  - Fichiers : `skills/{008-sg-customer,010-sg-technical,302-sg-help,305-sg-init,406-sg-seo,600-sg-local-cloud-sync}/references/*.md`.
  - Action : créer les ressources bornées, transformer les anciens monolithes en index courts lorsque nécessaire et éliminer les duplications normatives.
  - User story link : réduit le contexte chargé par une requête ciblée.
  - Depends on : Tâche 1.
  - Validate with : comparaison des sections et seuils de taille ciblés.

- [x] Tâche 3 : Mettre à jour les routeurs et consommateurs actifs.
  - Fichiers : les six `SKILL.md`, tests propriétaires et liens actifs découverts.
  - Action : documenter précisément quand charger chaque ressource; préserver les chemins historiques seulement comme index bornés.
  - User story link : rend le découpage effectivement découvrable.
  - Depends on : Tâche 2.
  - Validate with : tests propriétaires et recherches d'anciens liens.

- [x] Tâche 4 : Prouver la découvrabilité et la fidélité.
  - Fichiers : métadonnées des nouvelles références et tests ciblés.
  - Action : vérifier les intentions représentatives, collisions, dépendances et erreurs de ressource manquante.
  - User story link : empêche une fragmentation silencieuse.
  - Depends on : Tâche 3.
  - Validate with : tests du résolveur, audit de fidélité, metadata lint et budget audit.

- [x] Tâche 5 : Synchroniser et documenter la livraison.
  - Fichiers : runtime links et documents actifs seulement si impact confirmé.
  - Action : exécuter la sync, l'audit final et enregistrer le résultat du chantier.
  - User story link : rend l'architecture disponible dans les runtimes.
  - Depends on : Tâche 4.
  - Validate with : `tools/shipglows_sync_skills.sh --check --all`.

# Acceptance Criteria

- [x] CA1 : Given une tâche ciblée appartenant à l'un des six propriétaires, when son mode est sélectionné, then le `SKILL.md` indique une ressource bornée correspondant à cette décision.
- [x] CA2 : Given les six références initialement supérieures à 500 lignes, when la migration est terminée, then aucun fichier actif résultant ne combine plusieurs modes indépendants uniquement pour conserver l'ancien monolithe.
- [x] CA3 : Given les sections normatives initiales, when la matrice de transfert est vérifiée, then chaque section est conservée exactement une fois ou explicitement retirée comme duplication obsolète.
- [x] CA4 : Given une ressource absente ou un lien actif périmé, when les tests ciblés s'exécutent, then la validation échoue visiblement.
- [x] CA5 : Given les intentions représentatives des six domaines, when le résolveur produit un starter pack, then une ressource du propriétaire correct apparaît dans les premiers résultats avec une raison explicable.
- [x] CA6 : Given la migration complète, when les audits globaux s'exécutent, then fidélité, budget, métadonnées, index et runtime sync passent sans régression.
- [x] CA7 : Given une requête SEO d'audit sans autorisation de correction, when le playbook est chargé, then aucune branche ne permet de modifier directement le projet.

# Test Strategy

1. Ajouter ou adapter des tests de contrat pour les cartes de chargement et l'existence de chaque ressource.
2. Exécuter les tests propres aux six skills et au résolveur.
3. Exécuter `audit_shipglows_skills.py`, `skill_budget_audit.py`, metadata lint et skill-code-index lint.
4. Exécuter la sync runtime complète puis son mode `--check`.
5. Comparer les headings et règles critiques avant/après avec des scans ciblés.

# Risks

- Perte silencieuse d'une règle enfouie dans un monolithe.
- Trop grand nombre de micro-fichiers sans décision de chargement claire.
- Résolveur dominé par des mots génériques comme `audit`, `quality` ou `project`.
- Tests trop liés aux anciens noms de fichiers plutôt qu'au comportement.
- Duplication temporaire entre index et playbooks qui recrée le coût de contexte.

# Execution Notes

- Lire d'abord les six owner skills, les six monolithes et les tests directement associés.
- Utiliser un index court par ancien chemin seulement lorsqu'un consommateur actif ou une compatibilité de runtime le justifie.
- Préférer 3 à 5 ressources cohérentes par propriétaire plutôt qu'un fichier par heading.
- Ne pas modifier de promesse publique ni de mode pendant ce chantier.
- Stopper si une section ne peut être assignée à une autorité unique sans modifier le comportement métier.

# Open Questions

None. L'opératrice a approuvé la compaction des six références identifiées par l'audit.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-03 23:07:13 UTC | 100-sg-spec | gpt-5 | Création du contrat de compaction des six références monolithiques. | draft | Revue de readiness |
| 2026-08-03 23:07:13 UTC | 900-shipglows-core | gpt-5 | Audit initial, sélection des cibles et lancement de la cartographie déléguée. | in_progress | Revue de readiness |
| 2026-08-03 23:07:13 UTC | 101-sg-ready | gpt-5 | Revue structurelle et adversariale; ajout du scénario d'autorité SEO, du contrat de preuve et de l'impact sécurité explicite. | ready | Implémentation |
| 2026-08-03 23:16:23 UTC | 102-sg-start | gpt-5.6-terra | Split des six références en index bornés et ressources directes; routeurs, test scenario-first et sécurité lecture seule SEO mis à jour. | implemented | 103-sg-verify |
| 2026-08-03 23:18:50 UTC | 900-shipglows-core refresh | gpt-5 | Revue conservative des six propriétaires, complétude, duplication, sélection ciblée et journaux de refresh. | refreshed | 103-sg-verify |
| 2026-08-03 23:18:50 UTC | 103-sg-verify | gpt-5 | Vérification standard: scénarios, 52 tests, 45 métadonnées, fidélité, budget, index, résolveur et sync runtime. | verified | 104-sg-end |
| 2026-08-03 23:18:50 UTC | 104-sg-end | gpt-5 | Critères clos, tracker et changelog alignés; aucune documentation publique impactée. | closed | 005-sg-ship |
| 2026-08-03 23:20:44 UTC | 005-sg-ship | gpt-5 | Commit `52048c2` poussé sur `origin/main`; périmètre validé et livré. | shipped | none |

# Current Chantier Flow

- `100-sg-spec`: complete — spec créée.
- `101-sg-ready`: ready.
- `102-sg-start`: complete — références découpées et validations locales passées.
- `103-sg-verify`: verified.
- `104-sg-end`: complete.
- `005-sg-ship`: shipped.
