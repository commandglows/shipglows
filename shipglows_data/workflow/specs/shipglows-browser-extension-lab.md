---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-29"
created_at: "2026-08-29 03:21:09 UTC"
updated: "2026-08-29"
updated_at: "2026-08-29 03:21:09 UTC"
status: ready
source_skill: 100-sg-spec
source_model: gpt-5
scope: feature
owner: Diane
user_story: "En tant que développeur débutant, vibe coder ou agent, je veux importer un dépôt d'extension et ouvrir un laboratoire navigateur isolé afin de tester et déboguer l'extension sans risquer mon profil personnel."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/
  - tests/windows/
  - chrome-brat
  - ToolGlows
  - CommunityGlows
  - public documentation
depends_on: []
supersedes: []
evidence:
  - "Operator approved the reinforced Extension Lab plan on 2026-08-29."
  - "The refreshed audit confirmed Chrome BRAT unchanged and CDP loading operational."
  - "Current ShipGlows extension support is limited to one CRXJS convention."
  - "Chrome BRAT, ToolGlows and a clean CommunityGlows build loaded successfully in temporary Chromium on 2026-08-29."
next_step: "Implement the ShipGlows Core foundation"
---

# Spec: ShipGlows Browser Extension Lab

## Title

ShipGlows Browser Extension Lab

## Status

ready

## User Story

En tant que développeur débutant, vibe coder ou agent, je veux importer un dépôt d'extension et ouvrir un laboratoire navigateur isolé afin de tester et déboguer l'extension sans risquer mon profil personnel.

## Minimal Behavior Contract

À partir d'un dépôt local importé, ShipGlows détecte une extension statique ou construite, explique les préparations nécessaires, puis ouvre sur demande un Chromium jetable avec l'extension chargée. Il montre le chemin utilisé, l'identifiant obtenu et les erreurs exploitables. Si le dépôt est ambigu, non construit, non fiable ou si le navigateur ne supporte pas le chargement automatisé, ShipGlows ne lance aucun script implicitement et donne une action de récupération. Un manifeste situé à la racine doit fonctionner sans `package.json`.

## Success Behavior

- Preconditions: dépôt local lisible avec manifeste source ou artefact manifeste valide.
- Trigger: commande ou action Windows ShipGlows dédiée au laboratoire d'extensions.
- User/operator result: navigateur isolé ouvert et diagnostic explicite du projet et de l'extension.
- System effect: profil temporaire ou géré créé hors des profils personnels, puis nettoyé selon le mode choisi.
- Success proof: tests de détection et probe réel avec Chrome BRAT.
- Silent success: interdit; le chemin, le mode et l'identifiant sont visibles et sérialisables.

## Error Behavior

- Expected failures: manifeste absent/invalide, sortie non construite, commande non approuvée, Chromium indisponible, CDP incompatible, port occupé.
- User/operator response: message actionnable avec cause, chemin inspecté et prochaine action sûre.
- System effect: aucun script arbitraire exécuté et aucune mutation du profil personnel.
- Must never happen: installer silencieusement une dépendance, exécuter un script non approuvé, afficher un secret, modifier les données Chrome personnelles.
- Silent failure: interdit; code de sortie non nul et diagnostic machine-readable lorsque demandé.

## Problem

Le DevServer Windows traite surtout les sites et n'offre qu'un chemin CRXJS spécialisé. Les dépôts statiques comme Chrome BRAT et les variantes d'outils/build ne disposent pas d'un parcours commun, sûr et compréhensible.

## Solution

Introduire un contrat de détection indépendant du framework et un laboratoire Chromium isolé piloté par ShipGlows. Séparer inspection, préparation explicitement autorisée et exécution afin de conserver une frontière de confiance claire.

## Scope In

- Détection de manifestes source et de sorties construites courantes.
- Extensions statiques sans `package.json` et extensions CRXJS/Vite.
- Chromium Playwright géré, chargement CDP, diagnostics et sortie JSON.
- Parcours CLI/menu Windows, tests, CI de référence, onboarding agents et documentation publique débutant.
- Chrome BRAT, ToolGlows et CommunityGlows comme projets pilotes dans des worktrees séparés.

## Scope Out

- Publication Chrome Web Store, signature CRX et modification du profil Chrome personnel.
- Exécution automatique de scripts provenant d'un dépôt non approuvé.
- Support Firefox/Safari complet dans le premier jalon.
- Déploiement du site public ou release ShipGlows sans validation séparée.

## Constraints

- Windows/PowerShell reste la première surface.
- L'inspection est sans effet; toute préparation exécutable doit être explicite.
- Le domaine CDP expérimental doit être capability-checké.
- Les worktrees sales existants restent intacts.
- Les affirmations publiques suivent les preuves réellement obtenues.

## Test Contract

### Surface

- Stack/surface: PowerShell, Node/Playwright, Chromium, documentation.
- Primary proof mode: mixed.
- Proof order: unit/contract, integration locale, navigateur isolé, revue documentation.

### Manual checklist

- Needed: yes.
- Checklist path: `shipglows_data/workflow/test-checklists/browser-extension-lab.md`.
- Required scenario coverage: statique, construit, manifeste invalide, sortie absente, capability CDP absente, refus d'exécution non approuvée.
- Exception with proof: la validation finale dans le navigateur personnel est exclue par conception.

### Required evidence stack

- Automated / unit / integration checks: tests PowerShell ciblés et tests Node du chargeur.
- Agent-run browser proof: Chrome BRAT chargé dans Chromium jetable avec identifiant observable.
- Auth/session proof: non applicable; aucun flux authentifié n'est requis.
- Contract/integration proof: sorties humaines et JSON cohérentes.
- Provider evidence: artefact GitHub Actions vérifié dans les dépôts pilotes lorsqu'ajouté.
- Device-native proof: non applicable.

## Dependencies

- Runtime: Node.js et Playwright Chromium déjà gérés par ShipGlows, avec erreur explicite s'ils sont absents.
- Document contracts: environnement ShipGlows Windows et contrats de documentation existants.
- Metadata gaps: le futur format multi-navigateur reste à versionner après le pilote Chromium.

## Invariants

- Aucun profil navigateur personnel n'est modifié.
- Aucun script du dépôt n'est exécuté pendant la seule détection.
- Les chemins sont résolus et validés avant lancement.
- Les changements étrangers restent hors commits.
- Une erreur conserve une prochaine action sûre et observable.

## Links & Consequences

- Upstream systems: import GitHub, registre DevServer, configuration projet.
- Downstream systems: menu Windows, agents, CI, guides publics, support.
- Cross-cutting checks: sécurité des chemins/processus, nettoyage, accessibilité rédactionnelle, SEO éditorial et compatibilité Windows.

## Documentation Coherence

- Ajouter un playbook agents couvrant découverte, confiance, préparation, lancement, diagnostic et arrêt.
- Mettre à jour la documentation CLI/menu et les erreurs intégrées.
- Produire un guide public débutant, un glossaire et un article d'acquisition fondés sur les preuves.
- Documenter clairement la différence entre source, `dist`, extension décompressée, manifeste et service worker.

## Edge Cases

- Plusieurs manifestes ou sorties concurrentes.
- `package.json` absent, invalide ou scripts inconnus.
- Manifest V2 obsolète ou manifeste contenant des chemins manquants.
- Répertoire avec espaces, liens symboliques ou sortie située hors du dépôt.
- Processus interrompu, profil temporaire restant, navigateur déjà fermé.
- Entrées malveillantes tentant une traversée de chemin ou une injection de commande.

## ZOMBIES Coverage

- Z: dépôt vide ou manifeste vide produit un diagnostic sans exécution.
- O: un seul manifeste racine charge directement Chrome BRAT.
- M: plusieurs candidats restent ambigus jusqu'à sélection déterministe/explicite.
- B: source présente mais `dist` absent distingue « préparation requise » de « projet invalide ».
- I: chemins, JSON, manifeste et scripts sont validés comme données, jamais interpolés comme commandes.
- E: échec de Chromium/CDP nettoie le contexte et retourne une récupération actionnable.
- S: sorties et logs expurgent tokens, variables sensibles et contenu de profil.

## OWASP Security Gate

- A03 Injection: arguments de processus structurés, aucune concaténation de commande issue du dépôt.
- A05 Security Misconfiguration: profil isolé, permissions et chemins affichés avant exécution.
- A08 Software and Data Integrity Failures: aucun install/build implicite; confiance et provenance restent explicites.
- A09 Logging Failures: diagnostics utiles mais secrets et données privées expurgés.
- Proof: tests de chemins invalides, scripts inconnus et absence de mutation du profil personnel.

## Implementation Tasks

- [ ] Task 1: créer le contrat de détection d'extension.
  - File: `cli/windows/ShipGlows.DevServer.psm1`
  - Action: détecter manifestes et artefacts sans dépendre exclusivement de CRXJS.
  - User story link: importer tout dépôt d'extension raisonnable.
  - Depends on: None.
  - Validate with: tests PowerShell ciblés.
  - Notes: préserver les projets web existants.
- [ ] Task 2: construire le chargeur Chromium isolé.
  - File: `cli/windows/` et ressource Node dédiée.
  - Action: charger un répertoire unpacked, produire diagnostics humains/JSON et nettoyer le profil.
  - User story link: tester sans risque pour le profil personnel.
  - Depends on: Task 1.
  - Validate with: Chrome BRAT en contexte jetable.
  - Notes: capability-checker CDP et fallback actionnable.
- [ ] Task 3: intégrer le parcours CLI et menu Windows.
  - File: `cli/windows/shipglows-dev.ps1` et modules associés.
  - Action: proposer inspect/start/status/stop adaptés aux extensions.
  - User story link: parcours guidé pour débutants et agents.
  - Depends on: Tasks 1-2.
  - Validate with: tests de commandes et snapshots de messages.
  - Notes: conserver les commandes web existantes.
- [ ] Task 4: préparer les dépôts pilotes et CI.
  - File: worktrees dédiés Chrome BRAT, ToolGlows et CommunityGlows.
  - Action: ajouter contrats/scripts/workflows minimaux nécessaires sans absorber les changements étrangers.
  - User story link: prouver plusieurs architectures réelles.
  - Depends on: Tasks 1-3.
  - Validate with: artefacts et chargements isolés.
  - Notes: commits/pushes distincts par dépôt.
- [ ] Task 5: livrer onboarding agents et contenu débutant.
  - File: documentation interne et publique résolue par la cartographie documentaire.
  - Action: playbook, glossaire, guide cinq minutes, erreurs et contenu d'acquisition.
  - User story link: rendre le laboratoire utilisable sans expertise extension.
  - Depends on: comportements stabilisés des Tasks 1-4.
  - Validate with: contrôle des liens/commandes et revue des affirmations contre les preuves.
  - Notes: aucun « one click » non prouvé.

## Acceptance Criteria

- [ ] AC 1: un dépôt statique Manifest V3 sans `package.json` est reconnu.
- [ ] AC 2: une extension construite avec sortie configurable est reconnue sans convention CRXJS obligatoire.
- [ ] AC 3: Chrome BRAT se charge automatiquement dans un Chromium isolé et son identifiant est retourné.
- [ ] AC 4: manifeste invalide, sortie absente et capacité CDP absente donnent des erreurs actionnables.
- [ ] AC 5: la détection seule n'exécute aucun script et aucun flux ne modifie un profil personnel.
- [ ] AC 6: les agents disposent d'une sortie stable et d'un playbook autonome.
- [ ] AC 7: un novice dispose d'un parcours cinq minutes, d'un glossaire et d'exemples réels.
- [ ] AC 8: CI et dépôts pilotes prouvent les modes statique et construit.

## Test Strategy

- Unit: fonctions PowerShell de détection/validation et module Node du chargeur.
- Integration: commandes CLI contre fixtures statique, construite et invalide.
- Manual: ouverture du popup, observation du service worker et revue du parcours débutant.

## Risks

- Security impact: élevé car des dépôts externes et processus navigateur sont concernés; réduit par séparation inspection/exécution et profil isolé.
- Product/data/performance risk: confusion entre source et artefact, dérive CDP expérimentale et téléchargement Playwright; messages et capability checks réduisent ces risques.

## Execution Notes

- Read first: `cli/windows/ShipGlows.DevServer.psm1`, `cli/windows/shipglows-dev.ps1`, tests Windows et documentation runtime.
- Validate with: tests ciblés, `git diff --check`, probe Chrome BRAT, puis contrôles de documentation.
- Stop conditions: besoin de modifier un profil personnel, d'exécuter silencieusement un dépôt, de mélanger un worktree sale ou de publier/déployer.
- Execution batches: Core/spec; chargeur/tests; dépôts pilotes; onboarding interne; contenu public. Les écritures parallèles exigent des chemins non chevauchants.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-29 03:21:09 UTC | 700-sg-explore | gpt-5 | Refreshed repository and runtime evidence | reviewed | Formalize implementation contract |
| 2026-08-29 03:21:09 UTC | 100-sg-spec | gpt-5 | Created and adversarially reviewed Extension Lab spec | ready | Implement Core foundation |
| 2026-08-29 03:42:00 UTC | 102-sg-start | gpt-5 | Implemented Core loader, three repository pilots, CI artifacts and onboarding | implemented | Verify remaining behavioral scenarios |

## Current Chantier Flow

- `sg-spec`: done, ready contract created from approved plan.
- `sg-ready`: passed through adversarial contract review; no material open question.
- `sg-start`: implemented for detection, isolated loading, CI artifacts and onboarding.
- `sg-verify`: not launched.
- `sg-end`: not launched.
- `sg-ship`: milestone delivery pending.

Next step: implement the ShipGlows Core foundation.
