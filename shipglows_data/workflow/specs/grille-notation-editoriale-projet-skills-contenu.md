---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-05-24"
created_at: "2026-05-24 22:15:52 UTC"
updated: "2026-06-10"
updated_at: "2026-06-10 18:23:15 UTC"
status: ready
source_skill: sg-spec
source_model: "unknown"
scope: "content-governance-feature"
owner: "Diane"
user_story: "En tant qu'utilisatrice ShipGlows qui produit, repurpose, audite ou vérifie des contenus pour plusieurs projets, je veux une grille de notation éditoriale partagée mais paramétrée par projet, afin que les skills contenu donnent un score et un feedback structuré cohérents sans créer une skill par projet."
confidence: "high"
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/sg-content/SKILL.md"
  - "skills/sg-repurpose/SKILL.md"
  - "skills/sg-redact/SKILL.md"
  - "skills/sg-enrich/SKILL.md"
  - "skills/sg-audit-copy/SKILL.md"
  - "skills/sg-audit-copywriting/SKILL.md"
  - "skills/sg-audit-seo/SKILL.md"
  - "skills/sg-verify/SKILL.md"
  - "skills/references/editorial-content-corpus.md"
  - "shipglows_data/editorial/content-map.md"
  - "shipglows_data/editorial/claim-register.md"
  - "shipglows_data/editorial/page-intent-map.md"
  - "shipglows_data/editorial/editorial-update-gate.md"
  - "shipglows_data/workflow/evidence/content-quality-rubric-sample-run.md"
  - "shipglows_data/business/business.md"
  - "shipglows_data/business/product.md"
  - "shipglows_data/business/branding.md"
  - "shipglows_data/business/gtm.md"
depends_on:
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.8.0"
    required_status: "draft"
  - artifact: "shipglows_data/editorial/claim-register.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/sg-content/SKILL.md"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes: []
evidence:
  - "Veille 2026-05-24: Essay Grader AI shows a useful rubric + score + structured feedback pattern."
  - "User decision 2026-05-24: integrate structured feedback and project-specific scoring rules inside content skills instead of creating one skill per project."
  - "shipglows_data/workflow/TASKS.md now tracks: cadrer une grille de notation éditoriale réutilisable par les skills contenu, avec critères communs et règles spécifiques par projet."
  - "shipglows_data/workflow/research/tools.md records Essay Grader AI as inspiration for editorial rubric scoring."
  - "shipglows_data/workflow/evidence/content-quality-rubric-sample-run.md records a schema-complete sample rubric output and rejection scenarios for duplicate, conflicting, and stale score states."
next_step: "/sg-ship"
---

# Spec: Grille de notation éditoriale projet pour les skills contenu

## Title

Grille de notation éditoriale projet pour les skills contenu

## Status

Ready.

La direction produit est décidée et l'implémentation a déjà été lancée. La spec est prête après ajout du `Test Contract` obligatoire : `sg-verify` peut maintenant distinguer les preuves requises, les exceptions et les résultats attendus du gate éditorial.

## User Story

En tant qu'utilisatrice ShipGlows qui produit, repurpose, audite ou vérifie des contenus pour plusieurs projets, je veux une grille de notation éditoriale partagée mais paramétrée par projet, afin que les skills contenu donnent un score et un feedback structuré cohérents sans créer une skill par projet.

## Minimal Behavior Contract

Quand un skill contenu doit évaluer, améliorer, valider ou préparer la publication d'un contenu, il charge une grille commune de critères éditoriaux, puis applique les pondérations et contraintes du projet cible depuis `shipglows_data/business/*` et `shipglows_data/editorial/*`; il produit un score lisible, des sous-scores par critère, des blocages éventuels, et un feedback actionnable relié aux règles projet. En cas de contexte projet insuffisant, de surface éditoriale absente, ou de claim sensible non prouvé, il doit dégrader la confiance, signaler le blocage et éviter toute validation faussement positive. L'edge case facile à rater est un score générique qui récompense un bon texte mais ignore que le projet exige une voix, une promesse, une prudence médicale, une fraîcheur locale, ou une preuve différente.

## Success Behavior

- Précondition : un contenu source, brouillon, page, article, doc ou sortie de repurposing existe, et le projet cible peut être résolu.
- Déclencheur : `sg-content`, `sg-repurpose`, `sg-redact`, `sg-enrich`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-seo` ou `sg-verify` demande une évaluation qualitative.
- Résultat opérateur : le rapport contient un score global, des scores par axe, les critères qui ont pesé le plus, les corrections prioritaires, et les preuves ou manques de preuve.
- Effet système attendu : aucun contenu n'est publié, ship, ou marqué prêt sans statut qualité explicite quand le workflow demande une validation éditoriale.
- Preuve de succès : les tests ou checks ciblés confirment que la grille commune existe, que les skills l'utilisent, et que les règles projet peuvent varier sans dupliquer une skill.
- Succès silencieux : interdit. La notation doit être observable dans le rapport ou dans une structure de sortie standard.

## Error Behavior

- Si le projet cible est ambigu, demander une décision ou marquer `project context unresolved`; ne pas appliquer une grille arbitraire.
- Si le projet n'a pas de corpus éditorial ou business exploitable, appliquer seulement les critères communs, réduire la confiance, et recommander `/sg-docs editorial` ou `/sg-init` selon le manque.
- Si une surface blog/article/newsletter/social demandée est absente, reporter `surface missing: <surface>` et ne pas créer de chemin.
- Si un claim sensible est détecté sans preuve suffisante, produire un `Claim Impact Plan` ou un blocage `needs proof` / `claim mismatch` / `blocked`.
- Si le contenu obtient un score global correct mais échoue sur un critère bloquant du projet, le statut final doit rester `blocked` ou `needs revision`.
- Si la grille ou les règles projet sont incohérentes, le skill doit expliquer la contradiction et éviter de valider le contenu.
- Si le contexte projet est incohérent ou non autorisé, statut `blocked`, message `project context unauthorized`, aucun score final.
- Si une évaluation est relancée sur un même contenu sans changement détectable, le skill rejette en replay et renvoie `duplicate_in_progress` avec l'identifiant du run actif.
- Si `surface`, `project_id`, `run_signature` ou `evaluator.skill` échouent la normalisation, statut `blocked`, code `invalid_input_contract`.
- Si une erreur partielle survient avant génération du score, statut `needs retry`; aucune sortie ne peut être consommée par `sg-verify`.
- Si deux sorties existent pour la même signature avec des statuts incompatibles, statut `blocked`, code `conflicting_score_state`, résolution manuelle ou rerun canonique par `sg-content`.

## Problem

Les skills contenu ShipGlows peuvent déjà router, rédiger, repurpose, enrichir, auditer et vérifier des contenus. Il manque toutefois une façon commune de répondre à la question : "Est-ce que ce contenu est bon pour ce projet précis ?"

Sans brique partagée, chaque skill risque de noter selon ses propres critères, ou de produire des retours vagues. À l'inverse, créer une skill par projet créerait une explosion de maintenance et déplacerait la vérité projet hors du corpus de gouvernance.

## Solution

Ajouter une couche partagée de notation éditoriale qui sépare trois niveaux :

1. Critères communs ShipGlows : clarté, structure, actionnabilité, cohérence avec la source, preuves, CTA, lisibilité, SEO quand applicable, sécurité des claims.
2. Règles projet : audience, ton, promesse, non-objectifs, contraintes de marque, GTM, surfaces éditoriales, claim register et risques métier.
3. Sortie standard : score global, sous-scores, statut, feedback priorisé, corrections obligatoires, preuves manquantes, et prochaine route ShipGlows.

Cette couche doit être consommée par les skills contenu existants. Elle ne doit pas devenir une nouvelle skill autonome par projet.

## Output Schema

Toute évaluation doit produire la sortie machine suivante, utilisée par les owner skills et par `sg-verify`:

```json
{
  "schema_version": "1.0",
  "run_id": "<uuid-or-stable-run-id>",
  "run_signature": "<hash of project_id + surface + content_ref + source_refs + rules_revision>",
  "project_id": "<string>",
  "surface": "<blog|article|doc|newsletter|social|other>",
  "evaluator": {
    "skill": "<sg-content|sg-repurpose|sg-redact|sg-enrich|sg-audit-copy|sg-audit-copywriting|sg-audit-seo|sg-verify>",
    "role": "<producer|auditor|verifier>",
    "initiated_by": "<operator|workflow|unknown>"
  },
  "input_refs": {
    "content_ref": "<path|artifact|inline>",
    "source_refs": ["<path|artifact|url|none>"]
  },
  "applied_rules_revision": {
    "business": "<artifact or version>",
    "editorial": "<artifact or version>",
    "claim_register": "<artifact or version>"
  },
  "scores": {
    "overall": 0,
    "clarity": 0,
    "structure": 0,
    "source_faithfulness": 0,
    "compliance": 0,
    "brand_voice": 0,
    "call_to_action": 0
  },
  "weights": {
    "clarity": "<float 0-1>",
    "structure": "<float 0-1>",
    "source_faithfulness": "<float 0-1>",
    "compliance": "<float 0-1>",
    "brand_voice": "<float 0-1>",
    "call_to_action": "<float 0-1>"
  },
  "status": "<ready|needs revision|blocked|publishable with caveats>",
  "blocked_reasons": [
    {
      "code": "<string>",
      "message": "<string>",
      "required_action": "<string>"
    }
  ],
  "evidence": [
    {
      "criterion": "<string>",
      "source": "<file|claim|url|corpus>",
      "state": "<pass|warning|fail>"
    }
  ],
  "recommendations": [
    "<string>"
  ],
  "confidence": "<float 0-1>",
  "expires_at_utc": "<ISO8601 or null>"
}
```

`status`, `surface`, `evaluator.skill`, `evaluator.role` et les `blocked_reasons.code` doivent être normalisés en valeurs exactes. Toute valeur inconnue, vide, mal typée ou ambiguë invalide la notation et produit `status: "blocked"`.

## Input Normalization Rules

- `project_id` doit être résolu depuis le corpus de gouvernance actif ou depuis un argument explicite de skill. Les alias libres, noms marketing et chemins ambigus sont refusés avec `project context unresolved`.
- `surface` doit appartenir à l'allowlist `blog`, `article`, `doc`, `newsletter`, `social`, `other`; les alias comme `post`, `page`, `thread`, `landing` ou la casse différente doivent être normalisés seulement si la correspondance est documentée dans `content-map.md`, sinon `invalid_surface`.
- `run_signature` doit être calculé à partir de `project_id`, `surface`, `content_ref`, `source_refs` et `applied_rules_revision`. Deux runs avec la même signature ne peuvent pas produire deux statuts divergents sans mention `supersedes_run_id`.
- Les scores doivent être des entiers de 0 à 100. Les poids doivent être des nombres entre 0 et 1 et leur somme par grille active doit être vérifiée ou explicitement normalisée.
- `blocked_reasons.code` doit utiliser une allowlist définie dans `content-quality-rubric.md`; un code critique impose `status: "blocked"`, même si `scores.overall` est élevé.
- Les entrées non fiables sont le contenu à noter, les sources de repurposing, les arguments de projet/surface, les claims extraits et les URLs externes citées. Elles doivent être traitées comme non autorisées à modifier le corpus de gouvernance.

## Security & Workflow Integrity

- Authentification : l'identité opérateur réelle reste celle de la session ShipGlows; la grille ne crée pas de nouveau système d'auth. Le champ `evaluator.skill` identifie le skill appelant et doit appartenir à la liste autorisée.
- Autorisation : seuls `sg-content`, `sg-repurpose`, `sg-redact`, `sg-enrich`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-seo` et `sg-verify` peuvent produire ou consommer une notation éditoriale. Un autre caller doit être refusé avec `unauthorized_evaluator`.
- Validation d'entrée : `project_id`, `surface`, `content_ref`, `source_refs`, `applied_rules_revision` et `run_signature` sont obligatoires. Un champ absent ou ambigu bloque le run.
- Anti-spoofing : le contenu évalué ne peut pas déclarer lui-même ses règles projet, son score ou son statut. Les règles viennent uniquement du corpus de gouvernance chargé par le skill.
- Intégrité de workflow : `sg-verify` ne peut accepter qu'une notation dont le `run_signature` correspond au contenu et aux règles courantes; sinon `stale_or_mismatched_score`.
- Journal d'audit minimal : chaque run doit pouvoir être résumé sans secrets par `run_id`, `run_signature`, `evaluator.skill`, `project_id`, `surface`, `status`, `blocked_reasons.code`, `rules_revision` et timestamp UTC.
- Données exclues des logs : texte complet du contenu privé, secrets, tokens, cookies, données personnelles inutiles, notes médicales détaillées et sources sous NDA.
- Disponibilité et abus : un skill ne doit lancer qu'une évaluation par signature active. Les boucles de scoring ou fan-out multi-projets sont hors scope et doivent être bloquées.
- Reprise/retry : si le run échoue après chargement partiel des règles mais avant notation, le statut récupérable est `needs retry`. Si un run actif existe pour la même signature, le second run renvoie `duplicate_in_progress` avec le `run_id` actif.
- Conflit inter-skills : si deux owner skills produisent une notation pour le même `run_signature`, la notation la plus récente ne remplace l'ancienne que si elle indique `supersedes_run_id` et si les règles appliquées sont identiques ou plus récentes. Sinon `conflicting_score_state`.

## Scope In

- Créer une référence partagée décrivant la grille de notation éditoriale, son format de sortie et sa logique de pondération.
- Ajouter un contrat d'utilisation dans `sg-content` pour router les workflows contenu vers cette grille quand la qualité éditoriale doit être évaluée.
- Intégrer la grille dans les owner skills pertinents : `sg-repurpose`, `sg-redact`, `sg-enrich`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-seo`.
- Définir comment `sg-verify` peut consommer un score éditorial quand une spec ou un workflow l'exige.
- Définir les sources de règles projet sans créer de fichiers par projet obligatoires au départ.
- Documenter les stop conditions : contexte projet absent, surface manquante, claim sensible, score bloquant.
- Prévoir au moins deux exemples de profils de notation : un projet pédagogique/actionnable type GoCharbon, et un projet santé/addiction ou trust-sensitive type Quit Coke.

## Scope Out

- Créer une skill par projet.
- Créer un produit de scoring ContentGlowz complet ou une API backend.
- Modifier des contenus publics existants.
- Créer une interface dashboard, base de données, score persistant ou analytics.
- Créer une surface blog/article/newsletter/social manquante.
- Publier automatiquement des contenus selon le score.
- Ajouter des claims publics sur une qualité garantie des contenus.

## Constraints

- La vérité projet reste dans `shipglows_data/`, pas dans des prompts codés en dur.
- Les critères spécifiques doivent être déduits des contrats existants : `business`, `product`, `branding`, `gtm`, `content-map`, `claim-register`, `page-intent-map`, `public-surface-map`.
- La grille doit tolérer les projets sans gouvernance complète en dégradant la confiance plutôt qu'en inventant.
- Les scores ne remplacent pas le jugement éditorial ; ils orientent la révision et les gates.
- Les claims santé, addiction, finance, conformité, sécurité, privacy, IA fiable, pricing, savings et business outcomes doivent être traités comme critères bloquants ou à preuve.
- La sortie doit être lisible par un humain et réutilisable par un agent.
- Aucune dépendance externe n'est requise pour la première version.
- Les règles projet utilisées doivent être issues d'un artefact versionné (business/content/claim). En cas de version inconnue, status = `blocked` avec `project rules missing`.
- Le caller, le project_id et la surface doivent être explicites dans la sortie; toute sortie sans provenance déclenche rejet.
- Aucun skill consommateur ne peut recalculer localement ses propres statuts ou codes de blocage hors de la référence commune; il doit charger `content-quality-rubric.md`.
- Le succès d'une notation ne peut jamais publier, ship ou modifier un contenu public par lui-même; il produit seulement une décision observable pour le workflow.

## Test Contract

- `surface`: ShipGlows content-governance contracts, with no browser UI, public page, API, database migration, auth flow, provider integration, or external runtime dependency.
- `proof_profile`: mixed contract/manual proof. Mechanical proof verifies the shared rubric reference, skill wiring, metadata, and sync state. Manual proof verifies at least two representative rubric outputs because the core value is qualitative and project-aware.
- `proof_order`: metadata lint -> targeted `rg` contract checks -> skill budget audit -> skill sync check -> manual rubric-output review -> `sg-verify` final gate.
- `checklist_path`: `shipglows_data/workflow/test-checklists/grille-notation-editoriale-projet-skills-contenu.md` if the manual sample review is repeated or delegated; otherwise the sample evidence can be recorded directly in the `sg-verify` report.
- `required_scenario_ids`:
  - `rubric-ready-project-complete`: a content draft for a project with usable business/editorial corpus returns a global score, sub-scores, status, recommendations, evidence, confidence, `run_id`, `run_signature`, `project_id`, `surface`, `evaluator`, and `applied_rules_revision`.
  - `rubric-project-specific-weights`: two project contexts with different brand/risk profiles produce different weighting, blocking, or recommendation behavior without changing the calling skill.
  - `rubric-sensitive-claim-blocked`: a sensitive health, addiction, finance, compliance, privacy, AI reliability, pricing, savings, or business-outcome claim without sufficient proof returns `blocked`, `needs proof`, or an equivalent blocking code even when clarity and structure scores are high.
  - `rubric-source-faithfulness`: a repurposed output that adds a claim absent from its source is blocked or marked `needs revision` on source-faithfulness.
  - `rubric-invalid-input-contract`: invalid or ambiguous `surface`, `project_id`, `run_signature`, `evaluator.skill`, or project rules returns `blocked` with the precise normalized code, and no consumable quality score.
  - `rubric-stale-or-conflicting-score`: a stale, mismatched, duplicate, concurrent, or conflicting score is rejected by `sg-verify` as non-final proof.
- `required_results`:
  - Contract checks prove `skills/references/content-quality-rubric.md` exists and names the output schema, status allowlist, blocking codes, project-rule sources, score fields, evidence fields, replay/concurrency behavior, and sensitive-claim rules.
  - Owner skills prove they load or reference the shared rubric instead of duplicating local scoring logic.
  - `sg-verify` proves it refuses missing, stale, recoverable, conflicting, or blocking rubric states when a spec or workflow declares the editorial quality gate.
  - Manual sample evidence includes one normal pass or revision case and one blocked case. Each sample must show the project/source context used, the applied rules revision, the status, the top blocking or weighting reason, and the next route.
  - The final verification report must separate required results, optional observations, and exceptions.
- `optional_results`:
  - A reusable checklist artifact can be created if the same sample scenarios need repeated manual review across future content-skill changes.
  - A public site build is optional and only applies if `site/src/content/**` or a public documentation page changes.
- `exception_with_proof`:
  - Browser, auth, provider, API, database, migration, payment, analytics, and device proofs are non-applicable because this chantier changes local ShipGlows skill/docs contracts only. The proof is the absence of touched runtime app paths plus `fresh-docs not needed`.
  - Unit tests are non-applicable for v1 because the change is contract/documentation-only; the replacement proof is metadata lint, skill sync, targeted contract checks, and sample rubric-output review.
- `exception_without_proof`:
  - A missing sample rubric output is not an acceptable exception. It keeps `sg-verify` partial because the feature can look mechanically wired while failing the project-aware scoring behavior.
  - A missing `run_signature`, `applied_rules_revision`, `evaluator.skill`, `project_id`, or normalized `surface` is not an acceptable exception for a consumed score.
- `sf-verify_consumption_rule`: `sg-verify` may pass this chantier only when mechanical checks pass and at least one acceptable sample proves the rubric output can be consumed or rejected according to the scenarios above.

## Dependencies

- `skills/references/editorial-content-corpus.md` pour le chargement des corpus éditoriaux.
- `shipglows_data/editorial/content-map.md` pour les surfaces.
- `shipglows_data/editorial/claim-register.md` pour les claims sensibles.
- `shipglows_data/business/business.md`, `product.md`, `branding.md`, `gtm.md` pour les règles projet.
- Skills owner : `sg-content`, `sg-repurpose`, `sg-redact`, `sg-enrich`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-seo`, `sg-verify`.
- Fresh external docs verdict : `fresh-docs not needed`, car le chantier porte sur des contrats locaux ShipGlows et n'introduit pas de SDK, API, framework ou fournisseur externe.

## Invariants

- Une seule architecture de notation pour tous les projets.
- Les règles projet sont des entrées de la grille, pas des forks de skill.
- Un score global ne peut pas masquer un critère bloquant.
- Le feedback doit être actionnable : chaque faiblesse majeure doit proposer une correction concrète ou une route ShipGlows.
- La grille doit distinguer `needs revision`, `blocked`, `publishable with caveats`, et `ready`.
- Les surfaces absentes restent absentes jusqu'à décision explicite.
- La sortie ne doit jamais inventer de preuve, de testimonial, de chiffre, de promesse médicale ou de garantie.
- Une notation sans `run_id`, `run_signature`, `evaluator`, `project_id`, `surface` et `applied_rules_revision` est invalide.
- Un critère bloquant critique prévaut toujours sur le score global, les pondérations et les recommandations.
- Une sortie marquée `needs retry`, `duplicate_in_progress`, `conflicting_score_state` ou `stale_or_mismatched_score` ne peut jamais être consommée comme preuve de qualité par `sg-verify`.

## Links & Consequences

- `sg-content` gagne un rôle plus clair de gate qualité en fin de lifecycle contenu.
- `sg-repurpose` peut vérifier que ses outputs restent source-faithful et adaptés au projet cible.
- `sg-redact` et `sg-enrich` peuvent demander une auto-évaluation structurée avant de proposer une version finale.
- `sg-audit-copy`, `sg-audit-copywriting` et `sg-audit-seo` peuvent converger vers un format de scoring comparable.
- `sg-verify` peut vérifier une condition de spec du type "score éditorial prêt et aucun critère bloquant".
- Les projets sensibles comme santé/addiction nécessitent des règles plus strictes sur preuves, ton, claims et sécurité utilisateur.
- Les projets locaux ou événementiels nécessitent des critères de fraîcheur, précision géographique et utilité pratique.

## Documentation Coherence

À mettre à jour pendant l'implémentation :

- Nouvelle référence partagée de grille éditoriale dans `skills/references/`.
- `skills/sg-content/SKILL.md` pour décrire quand la grille est invoquée.
- Skills owner listés dans le scope pour consommer ou produire la sortie standard.
- `shipglows_data/editorial/content-map.md` si la surface "content quality rubric" doit être déclarée comme règle éditoriale interne.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` si la nouvelle référence devient une brique de lifecycle officielle.
- Public docs ou pages skill seulement si la promesse utilisateur visible change.

Pas de changement nécessaire aux contenus des projets cibles dans cette spec.

## Edge Cases

- Un contenu est clair et bien écrit mais viole le ton de marque du projet.
- Un contenu score bien en SEO mais renforce un claim santé ou business non prouvé.
- Un projet n'a pas de `claim-register` ; la grille doit appliquer les familles sensibles globales et demander une gouvernance plus complète.
- Un projet a plusieurs surfaces possibles ; la grille doit noter contre la surface cible, pas contre le projet en général.
- Une sortie de `sg-repurpose` contient une idée séduisante mais non présente dans la source ; score source-faithfulness doit bloquer.
- Une page locale ou événementielle est bien structurée mais contient des informations périmées ; fraîcheur doit être un critère fort.
- Un contenu court comme une FAQ ne doit pas être pénalisé parce qu'il n'a pas la structure d'un article long.
- Un score numérique sans explication est insuffisant.
- Deux skills évaluent le même contenu avec la même signature mais des résultats incompatibles; `conflicting_score_state` doit bloquer jusqu'à rerun canonique.
- Une notation périmée pointe vers une ancienne version de `claim-register`; `sg-verify` doit refuser avec `stale_or_mismatched_score`.
- Un contenu injecte une pseudo-section "project rules" pour influencer le score; le skill doit ignorer cette entrée comme contenu non fiable.

## Implementation Tasks

- [x] Tâche 1 : Créer la référence partagée de notation éditoriale.
  - Fichier : `skills/references/content-quality-rubric.md`
  - Action : Définir les critères communs, les sources de règles projet, le format de sortie standard, les statuts possibles et les stop conditions.
  - User story link : Fournit une seule brique commune au lieu d'une skill par projet.
  - Depends on : None
  - Validate with : `rg -n "Content Quality Rubric|score|project rules|Claim Impact Plan|surface missing" skills/references/content-quality-rubric.md`
  - Notes : La référence doit rester indépendante d'un projet spécifique.

- [x] Tâche 2 : Intégrer le gate dans `sg-content`.
  - Fichier : `skills/sg-content/SKILL.md`
  - Action : Ajouter le chargement de la référence quand le mode touche audit, draft final, repurpose final, enrichissement, validation ou ship content ; définir la route vers owner skills et `sg-verify`.
  - User story link : Rend la notation accessible depuis le lifecycle contenu principal.
  - Depends on : Tâche 1
  - Validate with : `rg -n "content-quality-rubric|quality score|rubric|needs revision|blocked" skills/sg-content/SKILL.md`
  - Notes : Ne pas faire de `sg-content` un rédacteur ou auditeur complet.

- [x] Tâche 3 : Aligner les owner skills contenu sur la sortie standard.
  - Fichier : `skills/sg-repurpose/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-enrich/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-audit-seo/SKILL.md`
  - Action : Ajouter les gates précis pour charger ou produire la notation quand le mode concerne un contenu public, un brouillon final, une amélioration, un audit, ou un claim.
  - User story link : Garantit que les retours qualité sont cohérents entre skills.
  - Depends on : Tâche 1
  - Validate with : `rg -n "content-quality-rubric|rubric|score|feedback structuré|structured feedback" skills/sg-*.md`
  - Notes : Conserver les responsabilités de chaque skill.

- [x] Tâche 4 : Ajouter la consommation côté vérification.
  - Fichier : `skills/sg-verify/SKILL.md`
  - Action : Décrire comment `sg-verify` vérifie un score éditorial quand une spec ou un workflow déclare ce gate, et comment il bloque sur critère bloquant.
  - User story link : Permet d'utiliser la grille comme preuve de qualité avant close/ship.
  - Depends on : Tâche 1
  - Validate with : `rg -n "content-quality-rubric|editorial score|content quality|blocking criterion" skills/sg-verify/SKILL.md`
  - Notes : Ne pas rendre le score obligatoire pour tous les ships.

- [x] Tâche 5 : Documenter la brique dans les contrats techniques/editoriaux.
  - Fichier : `shipglows_data/editorial/content-map.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`
  - Action : Ajouter la référence comme brique interne de gouvernance contenu, ses consommateurs et ses triggers.
  - User story link : Préserve la découvrabilité pour un agent frais.
  - Depends on : Tâches 1-4
  - Validate with : `python3 tools/shipglows_metadata_lint.py shipglows_data/editorial/content-map.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
  - Notes : Public docs uniquement si les pages visibles changent.

- [x] Tâche 6 : Valider l'ensemble et synchroniser les skills.
  - Fichier : `skills/`, `skills/references/`, `shipglows_data/`
  - Action : Exécuter les audits et checks ciblés, corriger les incohérences, puis préparer le handoff vers `/sg-verify`.
  - User story link : Prouve que la nouvelle brique est utilisable et cohérente.
  - Depends on : Tâches 1-5
  - Validate with : `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`, `tools/shipglows_sync_skills.sh --check --all`, `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md skills/references/content-quality-rubric.md shipglows_data/editorial/content-map.md shipglows_data/technical/skill-runtime-and-lifecycle.md`
  - Notes : Ajouter `pnpm --dir shipglows-site build` seulement si les pages publiques ou runtime content changent.

## Acceptance Criteria

- [ ] CA 1 : Given un contenu final à valider pour un projet avec corpus complet, when un skill contenu invoque la grille, then le rapport contient un score global, des sous-scores, un statut, et un feedback priorisé relié aux règles du projet.
- [ ] CA 2 : Given deux projets avec marques et risques différents, when le même type de contenu est évalué, then les pondérations et blocages peuvent différer sans changer de skill.
- [ ] CA 3 : Given un contenu avec claim sensible non prouvé, when la grille l'évalue, then le statut est `blocked` ou `needs proof` même si les autres critères sont bons.
- [ ] CA 4 : Given un projet sans corpus éditorial complet, when la grille l'évalue, then la confiance est réduite et le rapport recommande le bootstrap documentaire approprié.
- [ ] CA 5 : Given une surface demandée absente, when un contenu est évalué pour cette surface, then le rapport signale `surface missing` et ne propose pas de publication.
- [ ] CA 6 : Given une sortie de repurposing qui invente un claim non présent dans la source, when elle est notée, then source-faithfulness bloque ou demande révision.
- [x] CA 7 : Given une spec exige un gate de qualité éditoriale, when `sg-verify` vérifie le chantier, then il peut lire le statut de notation et bloquer sur critère bloquant.
- [x] CA 8 : Given les skills sont synchronisés, when les validations ShipGlows sont lancées, then budget audit, runtime sync, metadata lint et checks ciblés passent ou rapportent un blocage précis.
- [ ] CA 9 : Given une entrée avec `surface`, `project_id`, `run_signature` ou `evaluator.skill` invalide, when la grille est invoquée, then le statut est `blocked` avec `invalid_input_contract` ou le code précis correspondant.
- [x] CA 10 : Given deux runs concurrents avec la même signature, when le second démarre avant la fin du premier, then il retourne `duplicate_in_progress` et ne produit pas de score concurrent.
- [x] CA 11 : Given une notation ancienne dont les règles projet ne correspondent plus au corpus courant, when `sg-verify` la lit, then il bloque avec `stale_or_mismatched_score`.

## Test Strategy

- Unit : aucune unité runtime requise pour la première version, car le changement est contractuel et documentaire.
- Contract checks : `rg` ciblés sur la référence et les skills pour vérifier présence des gates, statuts et formats de sortie.
- Metadata : `python3 tools/shipglows_metadata_lint.py` sur la spec et les documents modifiés.
- Skill runtime : `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` et `tools/shipglows_sync_skills.sh --check --all`.
- Manual review : relire deux exemples de notation dans la référence, dont un projet sensible et un projet contenu/SEO, pour vérifier qu'ils n'encouragent pas un score générique.
- Public build : `pnpm --dir shipglows-site build` seulement si une page publique ou `shipglows-site/src/content/**` est modifiée.

## Risks

- Risque de sur-scoring : un score numérique peut donner une fausse confiance. Mitigation : statut bloquant et explication obligatoire.
- Risque de duplication : chaque skill pourrait reformuler la grille. Mitigation : référence unique dans `skills/references/content-quality-rubric.md`.
- Risque de claims sensibles : un contenu peut être convaincant mais juridiquement ou médicalement dangereux. Mitigation : claim register et familles sensibles globales.
- Risque de complexité : trop de critères rendraient les rapports inutilisables. Mitigation : critères communs compacts + feedback priorisé.
- Risque de gouvernance absente : certains projets n'ont pas encore de corpus complet. Mitigation : confidence downgrade + route `/sg-docs editorial` ou `/sg-init`.
- Risque de contournement inter-skill : un owner skill pourrait produire un statut sans la grille commune. Mitigation : schéma obligatoire, `evaluator.skill` allowlist et vérification `sg-verify`.
- Risque de replay/concurrence : deux évaluations peuvent diverger pour le même contenu. Mitigation : `run_signature`, `duplicate_in_progress`, `supersedes_run_id` et `conflicting_score_state`.
- Risque de fuite dans les logs : les contenus ou sources sensibles pourraient être consignés. Mitigation : audit minimal sans texte complet, secrets ni données personnelles inutiles.

## Execution Notes

- Lire d'abord `skills/sg-content/SKILL.md`, `skills/references/editorial-content-corpus.md`, `shipglows_data/editorial/content-map.md`, `shipglows_data/editorial/claim-register.md`, puis les owner skills.
- Implémenter la référence commune avant de modifier les skills consommateurs.
- Garder les changements de skills courts : ils doivent charger/produire la grille, pas dupliquer toute la doctrine.
- Ne pas créer de fichier par projet. Les exemples peuvent montrer comment déduire des règles projet depuis le corpus.
- Sécurité minimale : vérifier ordre d'exécution (`project context` -> `surface` -> `rules` -> scoring), rejeter les appels non autorisés et empêcher les doubles soumissions concurrentes.
- Implémenter la référence comme source unique des statuts, codes de blocage, allowlists et règles de normalisation. Les owner skills ne doivent pas recopier ces listes localement.
- Ajouter dans la référence une table des codes : `project context unresolved`, `invalid_surface`, `project rules missing`, `needs proof`, `claim mismatch`, `invalid_input_contract`, `unauthorized_evaluator`, `duplicate_in_progress`, `needs retry`, `conflicting_score_state`, `stale_or_mismatched_score`.
- Lors de l'intégration dans `sg-verify`, refuser toute notation sans `run_signature` cohérente ou avec `status` récupérable/non final.
- Stop condition : si l'implémentation révèle qu'un projet a besoin de nouvelles surfaces éditoriales, créer une spec dédiée plutôt que l'inclure ici.
- Stop condition : si une page publique est modifiée, appliquer l'Editorial Update Plan et le build Astro.
- Fresh external docs : `fresh-docs not needed`.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-24 22:15:52 UTC | sg-spec | unknown | Created draft spec from sg-veille Essay Grader AI intake and operator decision to build one shared project-aware editorial scoring rubric for content skills. | draft saved | /sg-ready grille notation editoriale projet skills contenu |
| 2026-05-25 09:30:10 UTC | sg-ready | unknown | Reviewed draft against Definition of Ready criteria. | not ready | /sg-spec grille notation editoriale projet skills contenu |
| 2026-05-26 19:37:46 UTC | sg-ready | unknown | Re-reviewed DoR against updated schema/security constraints and task traceability requirements. | not ready | /sg-spec grille notation editoriale projet skills contenu |
| 2026-05-26 19:40:17 UTC | sg-spec | unknown | Updated the reviewed spec to close sg-ready gaps on authz, input normalization, audit logging, retry/replay and inter-skill conflict behavior. | reviewed | /sg-ready grille notation editoriale projet skills contenu |
| 2026-05-26 19:43:39 UTC | sg-ready | unknown | Validated readiness after schema, security, input normalization, retry/replay and inter-skill conflict behavior were specified. | ready | /sg-start grille notation editoriale projet skills contenu |
| 2026-05-26 19:49:19 UTC | sg-start | gpt-5.3-codex | Implemented shared content quality rubric, owner-skill integration, verification consumption rules, and governance docs wiring; ran required checks. | implemented | /sg-verify grille notation editoriale projet skills contenu |
| 2026-05-28 18:19:33 UTC | sg-verify | unknown | Verified rubric reference, owner-skill wiring, metadata, runtime skill sync, and governance docs; runtime rubric output scenarios remain unproven. | partial | /sg-verify grille notation editoriale projet skills contenu with sample rubric run evidence |
| 2026-05-28 18:26:47 UTC | sg-verify | unknown | Re-ran verification and confirmed mechanical checks still pass; no sample rubric run evidence was found for the runtime editorial score gate. | partial | /sg-verify grille notation editoriale projet skills contenu with sample rubric run evidence |
| 2026-05-29 14:35:37 UTC | sg-ready | unknown | Re-checked the already-started spec against the current Definition of Ready. | not ready | /sg-spec grille notation editoriale projet skills contenu ajouter Test Contract |
| 2026-05-29 14:42:48 UTC | sg-spec | unknown | Added the mandatory Test Contract covering proof profile, proof order, required scenarios, required results, and acceptable/non-acceptable exceptions for the editorial rubric gate. | reviewed | /sg-ready grille notation editoriale projet skills contenu |
| 2026-05-30 20:26:00 UTC | sg-ready | unknown | Re-checked the spec after Test Contract update against structure, user-story alignment, metadata, language doctrine, adversarial, security and test-contract gates. | ready | /sg-verify grille notation editoriale projet skills contenu with sample rubric run evidence |
| 2026-06-01 21:40:04 UTC | sg-end | unknown | Attempted closure after route from shipglows end; kept chantier open because sg-verify remains partial and sample rubric output evidence is still missing. | deferred | /sg-verify grille notation editoriale projet skills contenu with sample rubric run evidence |
| 2026-06-10 11:20:00 UTC | sg-verify | gpt-5 | Added sample rubric run evidence with schema-complete final output and rejection scenarios for duplicate, conflicting, and stale score states. | verified | /sg-end grille notation editoriale projet skills contenu |
| 2026-06-10 12:22:53 UTC | sg-end | gpt-5 | Closed the chantier after verified sample rubric evidence, tracker update, and changelog entry. | closed | /sg-ship |
| 2026-06-10 17:31:09 UTC | sg-verify | unknown | Re-verified rubric reference, owner-skill wiring, metadata, runtime skill sync, and sample rubric evidence for revision and blocked-sensitive-claim scenarios. | verified | /sg-ship |
| 2026-06-10 18:17:23 UTC | sg-build | gpt-5 | Documented how to discover and use the project-aware editorial scoring gate from README, launch/help docs, public skill pages, public mode cheatsheet, and editorial governance gates. | implemented | /sg-verify grille notation editoriale projet docs |
| 2026-06-10 18:20:46 UTC | sg-verify | gpt-5 | Verified the docs/content discovery layer for the project-aware editorial scoring gate with metadata lint, targeted contract search, skill budget audit, and Astro build proof. | verified | /sg-ship |
| 2026-06-10 18:23:15 UTC | sg-ship | gpt-5 | Quick-shipped the verified docs/content discovery layer for project-aware editorial scoring. | shipped | None |

## Current Chantier Flow

- `sg-spec`: reviewed; `Test Contract` added.
- `sg-ready`: ready.
- `sg-start`: implemented.
- `sg-verify`: verified; mechanical checks, sample rubric proof, docs discovery, and public site build proof are present.
- `sg-end`: closed.
- `sg-build`: docs/content alignment implemented after closure so operators can discover how to use the scoring gate.
- `sg-ship`: shipped.

Next step: None
