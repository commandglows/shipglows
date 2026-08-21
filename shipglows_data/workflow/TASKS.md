# Tasks — ShipGlows

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred
> **Priority last updated:** 2026-06-27 UTC · criteria: balanced (`impact`, `blockers`, `risk`, `high-roi`)
> **Recommended next execution target:** `install.sh` supply-chain and failure handling hardening

---

## Active product chantiers

🟠 [ShipGlows] task: Finaliser l’Atlas de protection des surfaces approuvées et sa roadmap produit | status: in_progress | area: product-atlas | id: approved-surface-protection-and-product-atlas | spec: shipglows_data/workflow/specs/approved-surface-protection-and-product-atlas.md | evidence: registre v2, overlay local, contexte redacted, import atomique, baseline Git propre et préflight intégré aux phases agents testés; validation navigateur reste à réaliser | next: rendre les raccourcis opérateur Atlas exécutables
🔴 [ShipGlows] task: Rendre exécutables les raccourcis opérateur Atlas pour Copy, Design, Fonction et Surface avec les niveaux unknown/red/bronze/silver/gold/diamond et focus | status: todo | area: product-atlas | id: atlas-operator-shortcuts | spec: shipglows_data/workflow/specs/approved-surface-protection-and-product-atlas.md | evidence: la notation est documentée, mais aucun dispatcher ne la traite encore comme une commande | next: définir le point d’entrée, les autorisations Gold/Diamond et les tests de rejet
🟠 [ShipGlows] task: Reprendre la preuve navigateur et fonctionnelle du pilote Atlas Best Fried Chicken sur un environnement dev/preview disponible | status: todo | area: product-atlas-verification | id: best-fried-chicken-atlas-browser-proof | spec: shipglows_data/workflow/specs/approved-surface-protection-and-product-atlas.md | evidence: les preuves locales existent, mais le dépôt et le serveur pilote ne sont pas disponibles dans cet environnement | next: retrouver le dépôt pilote, régénérer le contexte Atlas et exécuter le paquet de vérification différé
🟠 [ShipGlows] task: Matérialiser le validateur en lecture seule du chaînage décisionnel Atlas dans les contrats business, produit, specs et preuves | status: todo | area: product-atlas-decision-trace | id: atlas-decision-trace-validator | spec: shipglows_data/workflow/specs/approved-surface-protection-and-product-atlas.md | evidence: Task 11 est spécifiée et en attente de readiness indépendante | next: valider le contrat de trace puis implémenter l’index dérivé et ses contrôles
🟠 [ShipGlows] task: Auditer et améliorer le score de préparation IA du site ShipGlows (schémas, structure, indexabilité, vitesse, llms.txt et sitemap) | status: todo | area: site-ai-readiness | source: décision utilisateur 2026-08-08 | next: /406-sg-seo audit AI readiness

---

## Bootstrap universel

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Concevoir un bootstrap universel multi-OS (`Linux`, `macOS`, `WSL`, `Windows`) avec comportement explicite selon la plateforme | 📋 todo |
| 🔴 | Supprimer l'hypothèse implicite "`python3` déjà installé" hors `sudo ./install.sh` serveur et définir la stratégie officielle de provisioning runtime | 📋 todo |
| 🟠 | Ajouter un chemin d'installation local sans root quand possible pour les outils docs/metadata qui reposent sur Python | 📋 todo |
| 🟠 | Faire échouer les scripts avec un diagnostic précis et actionnable quand un runtime requis manque au lieu de dépendre d'erreurs secondaires | 📋 todo |
| 🟠 | Corriger la configuration Playwright MCP pour pointer le Chromium ARM64 local au lieu de Google Chrome stable absent | 🔄 in progress |
| 🟠 | Provisionner Flutter/Dart via Flox par projet (validation overrides + réparation `.flox` existants + docs/tests) | ✅ done |
| 🟠 | Documenter la matrice de bootstrap par environnement : serveur Debian/Ubuntu, poste macOS, poste Linux non-root, Windows/WSL | 📋 todo |
| 🟡 | Évaluer s'il faut fournir un wrapper unique (`bootstrap` / `doctor`) pour vérifier et installer les prérequis avant usage | 📋 todo |
| 🟡 | Vérifier que `README.md`, `AGENT.md`, `CONTEXT.md` et `GUIDELINES.md` racontent le même contrat de bootstrap | 📋 todo |

🟡 [ShipGlows] task: Porter le menu local `urls` complet vers PowerShell natif, avec une parité explicitement définie avant code | status: deferred | area: windows-local-menu | id: windows-native-urls-parity | evidence: le bootstrap Windows, OpenSSH et un tunnel manuel sont vérifiés; le menu Unix/Termux reste Bash-only | decision: utiliser provisoirement la console navigateur Hetzner pour le CLI Unix et les URLs HTTPS publiques pour les aperçus | next: spécifier les actions Windows supportées et la stratégie de QA sur Windows PowerShell 5.1

---

## Documentation contracts

🟢 [ShipGlows] task: Nettoyer la racine documentaire et migrer les suites de test vers une architecture par ownership | status: done | area: documentation-governance-root-cleanup

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Relire et shipper les docs `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `GUIDELINES.md` après la passe de durcissement en cours | 🔄 in progress |
| 🟠 | Bootstrapper les corpus de gouvernance technique/éditoriale via `sg-init`/`sg-docs` et les intégrer au contrat `sg-build` | ✅ done |
| ✅ | Ajouter la couche de gouvernance éditoriale ShipGlows (`docs/editorial/`, Editorial Reader, claim register, page intent, schema Astro, blog-surface stop conditions) | ✅ done |
| ✅ | Ajouter au site public ShipGlows un tutoriel marketing sur les modes des skills, une page FAQ dédiée, puis renforcer le maillage interne vers ces surfaces | ✅ done |
| 🟠 | Corriger la synchronisation finale des aliases/symlinks dans `dotfiles/install.sh` pour qu'elle s'applique aussi en mode `--only=<component>` (éviter les alias/symlinks fantômes) | ✅ done |
| 🟡 | Normaliser à terme le schéma metadata si on veut éliminer la différence `linked_systems` / `linked_artifacts` | 📋 todo |

---

## Skills

🟢 [ShipGlows] task: Recommander une nouvelle conversation uniquement quand le contexte utile devient insuffisamment fiable et fournir un handoff complet | status: done | area: conversation-continuity | id: conversation-closure-and-restart-handoff | spec: shipglows_data/workflow/specs/conversation-closure-and-restart-handoff.md | verification: 44 scénarios ciblés, métadonnées, topologie et diff hygiene passent; contrôle léger aux transitions, rafraîchissement ciblé sur signal, aucune relecture exhaustive par défaut | ship_status: shipped | next: relire puis fusionner la PR de proportionnalité du contexte
🟢 [ShipGlows] task: Garantir une suite business concrète et fondée sur des preuves à la fin de chaque chantier | status: done | area: reporting-continuity | id: mandatory-business-continuity-suite | spec: shipglows_data/workflow/specs/mandatory-next-block-and-git-backed-closure.md | verification: 29 scénarios ciblés, métadonnées, JSON et diff hygiene passent; matrice de cadence et classement déterministe des audits actionnables livrés | ship_status: shipped | next: relire puis fusionner la PR ShipGlows 24 avant la revue visuelle de la PR site 13
🟢 [ShipGlows] task: Compacter les six références monolithiques en index courts et playbooks chargés par décision | status: done | area: skills-reference-compaction | id: compact-monolithic-skill-references | spec: shipglows_data/workflow/specs/compact-monolithic-skill-references.md | verification: scénarios ciblés, 52 tests, 45 métadonnées, audit de fidélité, budget, index, résolveur et sync runtime passent | ship_status: shipped | next: none
🟢 [ShipGlows] task: Ajouter un resolver déterministe pour la découverte progressive des références et restaurer le preflight d'invocation | status: done | area: skills-resource-discovery | id: shipglows-resource-resolver | spec: shipglows_data/workflow/specs/shipglows-resource-resolver.md | verification: 36 tests ciblés, métadonnées, audit, budget, sync runtime et diff hygiene passent; dette globale préexistante documentée dans la spec | ship_status: shipped | next: none
🟢 [ShipGlows] task: Exiger un choix utilisateur clair pour chaque rapport final de chantier non terminé, sans exposer skills, commandes ni étapes internes | status: done | area: user-reporting-continuity | id: unfinished-chantier-user-choice-contract | spec: shipglows_data/workflow/specs/unfinished-chantier-user-choice-contract.md | verification: 26 tests de contrat, métadonnées, audit, budget, sync runtime et diff hygiene passent | ship_status: not_shipped | next: ship when authorized
🟡 [ShipGlows] task: Réconcilier l’index des alias runtime des skills avec les noms canoniques et de compatibilité | status: deferred | area: skills-runtime-index | id: reconcile-skill-alias-index | source: excellence verification 2026-07-18 | evidence: l’écart du linter est identique sur HEAD et non bloquant pour la synchronisation runtime | next: définir le périmètre de compatibilité avant correction
🟢 [ShipGlows] task: Formaliser `008-sg-customer` en modes `audit`, `flow`, `onboarding` et `recovery` avec playbooks bornés | status: done | area: customer-skill-surface | id: formalize-sg-customer-modes-and-playbooks | spec: shipglows_data/workflow/specs/formalize-sg-customer-modes-and-playbooks.md | verification: migration locale skill/runtime/docs/publique vérifiée; CA 1-12, métadonnées, budget, sync runtime et build public passent | ship_status: shipped | next: none
🟢 [ShipGlows] task: Consolider les skills techniques sous le nouvel entrypoint public `010-sg-technical` et ses modes `audit`, `deps`, `performance`, `migrate` et `github` | status: done | area: technical-skill-surface | id: consolidate-technical-skills-under-sg-technical | spec: shipglows_data/workflow/specs/consolidate-technical-skills-under-sg-technical.md | verification: migration locale skill/runtime/docs/plugin/site vérifiée; contrats 30/30, métadonnées 17 fichiers, audit sans findings, budget conforme, sync runtime 102/102 et build Astro 82 pages | ship_status: shipped | next: none
🟢 [ShipGlows] task: Consolider `202-sg-repurpose` sous le mode `007-sg-content repurpose` | status: done | area: content-skill-surface | id: consolidate-repurpose-mode-under-sg-content | spec: shipglows_data/workflow/specs/consolidate-repurpose-mode-under-sg-content.md | verification: migration skill/runtime/documentation publique vérifiée, sans promesse d’effet de contenu en production | ship_status: shipped | next: none
🟢 [ShipGlows] task: Consolider les skills marketing sous 009-sg-marketing avec les modes market, gtm, copy et copywriting | status: done | area: marketing-skill-surface | id: consolidate-marketing-skills-under-sg-marketing | spec: shipglows_data/workflow/specs/consolidate-marketing-skills-under-sg-marketing.md | ship_status: shipped | next: none
🟢 [ShipGlows] task: Consolider la maintenance des skills dans les modes et playbooks internes de 900-shipglows-core | status: done | area: skills-maintenance-core | id: consolidate-skill-maintenance-under-shipglows-core | spec: shipglows_data/workflow/specs/consolidate-skill-maintenance-under-shipglows-core.md | ship_status: shipped | next: none
🟢 [ShipGlows] task: Ajouter un mode de statut pour les conversations Codex lie au tracker local et son playbook reutilisable | status: done | area: conversation-status-index | source: decision utilisateur 2026-07-15 | next: none
🟢 [ShipGlows] task: Ajouter un catalogue borne de roles specialistes technologiques, profils activables et references de fraicheur | status: done | area: skills-technology-roles | spec: shipglows_data/workflow/specs/technology-specialist-operator-roles.md | next: none
🟢 [ShipGlows] task: Integrer le TDD proof-first et les checklists manuelles durables dans les skills | status: done | area: skills
🟢 [ShipGlows] task: Ajouter une boucle d'audit des conversations et d'auto-evolution des skills | status: done | area: skills
🟢 [ShipGlows] task: Auditer en batch les conversations Markdown pour identifier les travers agents et router les améliorations | status: done | area: skills
🟢 [ShipGlows] task: Compacter semantiquement le Batch A des skills lifecycle (`100`, `101`, `103`, `104`, `005`) selon la taxonomie d'artefacts | status: done | area: skills | spec: shipglows_data/workflow/specs/semantic-compaction-of-core-shipglows-skills.md | next: none
🟢 [ShipGlows] task: Durcir les retours humains des skills, l'autonomie des questions, les claims de preuve et la sortie `sg-ready` | status: done | area: skills | spec: shipglows_data/workflow/specs/shipglows-skill-reporting-and-proof-hardening.md | next: /sg-ship shipglows-skill-reporting-and-proof-hardening
🟢 [ShipGlows] task: Router les preuves hébergées manquantes vers un owner concret après un verdict `partial` | status: done | area: skills | spec: shipglows_data/workflow/specs/shipglows-hosted-proof-follow-through-and-user-report-discipline.md | next: none
🟢 [ShipGlows] task: Forcer les exports et audits de conversation ShipGlows dans le repo ShipGlows | status: done | area: skills | spec: shipglows_data/workflow/specs/conversation-audit-canonical-storage-hardening.md | next: none
🟢 [ShipGlows] task: Ajouter un index numerique canonique des skills sans renommer les invocations | status: done | area: skills | spec: shipglows_data/workflow/specs/numeric-skill-code-index.md | next: /sg-ship Numeric Skill Code Index
🟢 [ShipGlows] task: Migrer les noms runtime des skills ShipGlows vers des prefixes a trois chiffres | status: done | area: skills | spec: shipglows_data/workflow/specs/three-digit-runtime-skill-names.md | next: /005-sg-ship Three Digit Runtime Skill Names
🟢 [ShipGlows] task: Autoriser `sg-start` a enchaîner une auto-verification locale bornee quand la preuve restante est sure et non destructive | status: done | area: skills | spec: shipglows_data/workflow/specs/auto-follow-through-for-local-only-sg-start-verification.md | next: /sg-ship Auto-follow-through for local-only sg-start verification
🟢 [ShipGlows] task: Renforcer les skills pour exiger et utiliser une surface diagnostics copiable dans les apps runtime | status: done | area: skills-observability | next: none
🟢 [ShipGlows] task: Compacter semantiquement le Batch C des skills specialists source (`105`, `106`, `107`, `108`, `109`) selon la taxonomie d'artefacts | status: done | area: skills | spec: shipglows_data/workflow/specs/semantic-compaction-of-source-specialist-skills.md | next: none
🟢 [ShipGlows] task: Compacter semantiquement le Batch D1 des master skills maintenance/release (`002`, `003`, `004`) selon la taxonomie d'artefacts | status: done | area: skills | spec: shipglows_data/workflow/specs/semantic-compaction-of-maintenance-and-release-master-skills.md | next: none
🟢 [ShipGlows] task: Compacter semantiquement le Batch D2 des master skills design/content/skill-build (`006`, `007`, `009`) selon la taxonomie d'artefacts | status: done | area: skills | spec: shipglows_data/workflow/specs/semantic-compaction-of-design-content-and-skill-build-master-skills.md | next: none
🟢 [ShipGlows] task: Publier un chemin d'installation marketplace repo-backed pour le plugin Codex `shipglows` et documenter l'installation sur le site ShipGlows | status: done | area: plugin-distribution | spec: shipglows_data/workflow/specs/shipglows-main-plugin-and-pack-portability.md | next: none
🟢 [ShipGlows] task: Créer et tenir un registre de hardening système des skills pour passer les 68 skills au crible sur preflight, chemins canoniques, boucle probleme->cause->prevention->contrat, operator-last-resort et risques de taille | status: done | area: skills-execution-fidelity | source: decision utilisateur 2026-06-26 | next: none
🟢 [ShipGlows] task: Compacter ou justifier explicitement la taille de `101-sg-ready` pour réduire le risque de discipline d'execution sous pression mis en evidence par l'audit des skills | status: done | area: skills-execution-fidelity | source: audit_shipglows_skills.py 2026-06-26 | next: none
🟢 [ShipGlows] task: Compacter le corpus global des skills pour repasser sous le budget agrégé `8500` sans dégrader les garde-fous d'execution | status: done | area: skills-corpus-compaction | spec: shipglows_data/workflow/specs/aggregate-skill-corpus-compaction-phase-1.md | source: skill_budget_audit.py 2026-06-27 | next: none
🟢 [ShipGlows] task: Durcir la clarté agent des frontières de rôle et du prochain owner sur les skills à plus forte ambiguïté | status: done | area: skills-agent-clarity | spec: shipglows_data/workflow/specs/agent-clarity-hardening-phase-7.md | source: decision utilisateur 2026-06-27 | next: none
🟢 [ShipGlows] task: Capitaliser les futures passes de clarté agent avec un playbook et une checklist réutilisable | status: done | area: skills-agent-clarity | spec: shipglows_data/workflow/specs/agent-clarity-pass-playbook-and-checklist.md | source: decision utilisateur 2026-06-27 | next: none
🟢 [ShipGlows] task: Durcir la clarté des handoffs publics/docs entre aide, runtime, invocation et ownership d'execution sur `302-sg-help`, la doc runtime, le README, le workflow et les cheatsheets | status: done | area: skills-agent-clarity-public-docs | spec: shipglows_data/workflow/specs/agent-clarity-public-docs-handoffs-phase-2.md | source: decision utilisateur 2026-06-28 | next: /005-sg-ship agent-clarity-public-docs-handoffs-phase-2
🟢 [ShipGlows] task: Ajouter un systeme global de navigation de code et de documentation de fonctions avec index de comportements et pilote IME WinFlowz | status: done | area: technical-docs-navigation | spec: shipglows_data/workflow/specs/shipglows-code-navigation-and-function-documentation-system.md | next: /005-sg-ship ShipGlows Code Navigation And Function Documentation System
🟢 [ShipGlows] task: Ajouter le hint `#feature:<term>` pour la navigation technique indexee et le relier aux docs help/context/behavior index | status: done | area: technical-docs-navigation | spec: shipglows_data/workflow/specs/feature-term-index-tag-spec.md | next: none
🟢 [ShipGlows] task: Automatiser le bootstrap de `shipglows_data/editorial/ROADMAP.md` pour les projets avec gouvernance editoriale applicable | status: done | area: workflow-editorial-governance | spec: shipglows_data/workflow/specs/editorial-roadmap-bootstrap-for-governed-projects.md | source: decision utilisateur 2026-07-11 | next: /005-sg-ship editorial roadmap bootstrap for governed projects
🟢 [ShipGlows] task: Compacter `205-sg-veille` en dispatcher de triage de sources avec playbooks bornés et routes propriétaires explicites | status: done | area: skills-source-triage | id: compact-205-sg-veille-source-triage-dispatcher | spec: shipglows_data/workflow/specs/compact-205-sg-veille-as-source-triage-dispatcher.md | verification: migration locale, runtime et découverte publique vérifiée; preuve déterministe, métadonnées, budget, sync, scan actif/historique et build Astro passent | ship_status: shipped | next: none

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Faire des specs le registre global des chantiers spec-first avec historique de skills | ✅ done |
| 🟠 | Ajouter la taxonomie interne des skills et les sources de chantier potentiel | ✅ done |
| 🟠 | Durable Exploration Reports for `sg-explore` | ✅ done |
| ✅ | Skill description budget compliance: audit script, descriptions compactes et checks `sg-docs`/`sg-skills-refresh` scoppés | ✅ done |
| ✅ | Patch global des skills pour résoudre les références et outils internes depuis le root canonique ShipGlows | ✅ done |
| ✅ | Créer `sg-test` pour guider les tests manuels, loguer `shipglows_data/workflow/TEST_LOG.md` et ouvrir `shipglows_data/workflow/BUGS.md` | ✅ done |
| 🟠 | Implémenter Professional Bug Management avec index compact, dossiers bug et preuves séparées | ✅ done |
| 🟠 | Durcir `sg-fix` pour exiger une trace bug durable même en fix direct, sauf exception mineure explicitement justifiée | ✅ done |
| ✅ | Créer `sg-bug` comme orchestrateur de boucle bug (`sg-test -> dossier -> sg-fix -> retest -> sg-verify -> sg-ship`) et aligner docs/help/site | ✅ done |
| ✅ | Documenter et propager le mode de développement projet (`local`, `vercel-preview-push`, `hybrid`) dans les skills de validation et de ship | ✅ done |
| ✅ | Créer `sg-browser` comme skill navigateur généraliste non-auth et l'intégrer aux routes `sg-auth-debug`, `sg-test`, `sg-prod`, `sg-fix`, `sg-start`, `sg-verify`, `sg-check`, aux specs de taxonomie/catalogue, aux README internes et au site public | ✅ done |
| 🟠 | Construire `sg-build` comme skill maître autonome (orchestrateur spec -> ready -> start -> verify -> end -> ship avec délégation bornée) | ✅ done |
| ✅ | Empêcher `sg-build` de renvoyer manuellement vers `sg-end`/`sg-ship` après vérification réussie sauf blocage explicite | ✅ done |
| ✅ | Implémenter `sg-skill-build` comme skill maître de maintenance des skills (`sg-explore si nécessaire -> sg-spec -> SKILL.md -> sg-skills-refresh -> budget audit -> sg-verify -> sg-docs/help -> sg-ship`) et aligner les surfaces publiques/docs | ✅ done |
| ✅ | Créer `sg-deploy` comme skill maître de release (`sg-check -> sg-ship -> sg-prod -> preuve -> sg-verify -> sg-changelog`) et aligner docs/help/site | ✅ done |
| ✅ | Promouvoir `sg-maintain` en skill maître de maintenance projet (`triage -> spec/ready -> délégation bornée -> verify -> ship/deploy`) et aligner docs/help/site | ✅ done |
| ✅ | Ajouter un helper partagé de synchronisation des skills Claude/Codex (`tools/shipglows_sync_skills.sh`) et l'intégrer à l'installateur, `sg-skill-build`, `sg-check`, `sg-verify` et `sg-ship` | ✅ done |
| ✅ | Ajouter un contrat partagé de rapports compacts pour les skills (`report=user` par défaut, `report=agent` explicite) et le propager aux skills lifecycle, bug et audit | ✅ done |
| ✅ | Ajouter une discipline Spec-Driven Development + Proof-First TDD/Evidence Gates aux skills d'exécution, bug, skill-build, verify et délégation | ✅ done |
| ✅ | Auditer la taxonomie des skills et compacter les descriptions de découverte sans changer les invocations, rôles ni catégories de trace | ✅ done |
| ✅ | Renforcer les questions `sg-build` en mode plan avec contexte, racine du problème, enjeu business, options et recommandation best practice | ✅ done |
| ✅ | Ajouter une cheatsheet publique et Markdown repo des master skills, supporting skills et modes d'arguments, avec page publique `sg-build` | ✅ done |
| 🟠 | Créer une skill `sg-prs` pour trier les PR GitHub ouvertes (`gh`), vérifier repo/branches/diffs/checks, regrouper Dependabot quand possible, merger les PRs vertes et fermer/commenter les PRs obsolètes selon une politique explicite | 📋 todo |

---

## Historical completed work

> Imported from the master tracker to keep local ShipGlows context coherent. These items are historical context, not active backlog.

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Extraction action handlers dans `lib.sh` + `shipglows.sh` réduit à 48 lignes | ✅ done |
| ✅ | Retirer ou restreindre `shipglows-inspector` et `shipglows-eruda` du layout de production | ✅ done |
| ✅ | Auditer et sécuriser `shipglows-inspector.js` (intégration upload + clé IMGBB exposée) | ✅ done |

---

## Backlog

🟢 [ShipGlows] task: Consolidate design skill surface into modes and playbooks | status: done | area: skills-design | spec: shipglows_data/workflow/specs/consolidate-design-skill-surface-into-modes-and-playbooks.md | ship_status: shipped | next: none
🟢 [ShipGlows] task: Conserver les fiches skills en anglais et l’expliquer sur le site français | status: done | area: site-i18n
🟢 [ShipGlows] task: Documenter une page OpenCode et une page KiloCode pour expliquer comment les skills ShipGlows sont découverts, invoqués et configurés selon chaque runtime, en précisant que dans OpenCode l'utilisateur écrit simplement "utilise le skill shipglows" et que `skill({ name: "shipglows" })` est un appel interne du runtime, pas une commande manuelle | status: done | area: skills-discovery | spec: shipglows_data/workflow/specs/opencode-and-kilocode-runtime-doc-pages.md | next: /005-sg-ship opencode-and-kilocode-runtime-doc-pages

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Harmoniser tous les sous-menus CLI : lettres au lieu de chiffres, `x) Cancel` unique, et comportement Cancel cohérent entre `gum` et fallback bash | ✅ done |
| 🟠 | Regrouper le menu racine ShipGlows en entrées lisibles avec sous-menus iconés (`Dashboard`, `Deploy / Start`, `Environments`, `Tools`, `System`, `Agents / ShipGlows`, `Help`) | ✅ done |
| ✅ | Aligner `sg-veille` avec la gouvernance contenu : router les idées blog/newsletter vers `sg-content`/`sg-repurpose` et signaler `surface missing: blog` quand aucune surface n'est déclarée | ✅ done |
| 🟢 | Ajouter un handoff contenu à `sg-research` et `009-sg-marketing market` quand leurs rapports recommandent des contenus publics, avec sources, claims et route vers `sg-content` | 💤 deferred |
| 🟢 | Renforcer `sg-audit` master pour charger explicitement les corpus éditorial/technique quand l'audit touche des surfaces publiques, claims ou docs mappées | 💤 deferred |
| 🟢 | Ajouter une micro-intégration `technical-docs-corpus` à `sg-content`/`sg-repurpose` quand les opportunités ou handoffs touchent des docs techniques internes | 💤 deferred |
| 🟡 | Cadrer une grille de notation éditoriale réutilisable par les skills contenu, avec critères communs et règles spécifiques par projet depuis le corpus de gouvernance — preuve sample rubric ajoutée et `sg-verify` validé | ✅ done |
| 🟢 | Étudier `models.dev` comme source externe pour actualiser la référence `sg-model` sans hardcoder prix, limites, capacités et fenêtres de contexte | 💤 deferred |
| 🟢 | Étudier OpenPostern comme inspiration pour les skills de codage et veille technologique: vendor-risk score, CVE/NVD, CISA KEV, SSL/TLS, DNS, headers HTTP, news sécurité IA et recommandations actionnables | 💤 deferred |
| 🟢 | Étudier Alpic comme inspiration pour packager, déployer, monitorer et distribuer des MCP servers / ChatGPT Apps liés aux skills ShipGlows | 💤 deferred |
| 🟢 | Idée à cadrer : créer une brique partagée de journaux opérationnels append-only (`OPERATIONS_LOG.md` / `DEPENDENCY_LOG.md`) pour tracer les runs importants sans remplacer `specs/`, `shipglows_data/workflow/bugs/`, `TASKS.md` ni `CHANGELOG.md` | 💤 deferred |
| 🟢 | Cadrer plus tard le mécanisme de synchronisation `project repo -> master` pour `shipglows_data` (symlink, copie, index généré, ingestion web app ou autre) dans une spec dédiée | 💤 deferred |
| 🟢 | Décider au niveau ShipGlows si les projets doivent séparer le backlog d'exécution (`shipglows_data/workflow/TASKS.md`) et la roadmap éditoriale/contenu dans un artefact canonique distinct, puis si validé: définir le nouvel artefact, mettre à jour la doctrine canonique, adapter les skills qui écrivent aujourd'hui dans `TASKS.md`, et prévoir la migration des projets existants | ✅ done |

🟢 [ShipGlows] task: Évaluer models.dev comme registre externe optionnel pour `sg-model` | status: deferred | area: model-routing | source: veille utilisateur https://models.dev/ 2026-06-10
🟢 [ShipGlows] task: Évaluer OpenPostern comme pattern pour enrichir `sg-veille`, `010-sg-technical deps`, `010-sg-technical audit` et les skills de codage avec scoring vendor-risk et signaux sécurité actionnables | status: deferred | area: tech-watch-security-skills | source: veille utilisateur https://betalist.com/startups/openpostern et https://openpostern.com/ 2026-06-10
🟢 [ShipGlows] task: Évaluer Alpic comme référence d'infrastructure MCP/ChatGPT Apps pour packaging, déploiement, monitoring, sécurité et distribution de skills ou serveurs MCP ShipGlows | status: deferred | area: mcp-app-distribution | source: veille utilisateur https://alpic.ai/ et https://alpic.ai/blog/deploy-chatgpt-apps-on-alpic 2026-06-10
🟢 [ShipGlows] task: Explorer si un index SQL opérationnel peut remplacer utilement une partie de `shipglows_data` sans dégrader la source de vérité documentaire | status: deferred | area: operational-data-architecture | source: recherche Bunny Database 2026-06-12 | next: /700-sg-explore SQL operational index over shipglows_data
🟢 [ShipGlows] task: Réévaluer plus tard les redondances entre profils nommés et focus tags puis supprimer les doublons de gouvernance si le runtime profils les remplace proprement | status: deferred | area: operator-profiles-governance | source: décision utilisateur 2026-06-28 | next: après implémentation runtime des profils
🟠 [ShipGlows] task: Formaliser la sémantique stable de la convention `%Profile`, ses règles d'interaction avec les focus tags et sa visibilité de handoff/reporting, sans prétendre à une primitive runtime native Codex ni créer de pseudo-runtime maison opaque | status: todo | area: operator-profiles-governance | source: décision utilisateur 2026-06-28 | next: /100-sg-spec named profile convention semantics
🟢 [ShipGlows] task: Cadrer par spec la séparation éventuelle entre backlog d'exécution et roadmap éditoriale multi-projets, avec inventaire des skills impactés, règles d'écriture, emplacements canoniques et stratégie de migration | status: done | area: workflow-editorial-governance | source: décision utilisateur 2026-07-07 | spec: shipglows_data/workflow/specs/workflow-vs-editorial-roadmap-split.md | next: /103-sg-verify workflow vs editorial roadmap split
🟠 [ShipGlows] task: Créer un client OAuth Desktop Google, télécharger son fichier JSON et autoriser le profil GSC local en lecture seule | status: todo | area: seo-gsc-auth | source: décision utilisateur 2026-08-10 | spec: shipglows_data/workflow/specs/google-search-console-api-cli.md | next: créer les identifiants OAuth Desktop dans Google Cloud Console puis lancer le consentement GSC

---

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Harden `local/dev-tunnel.sh` SSH target and identity validation so saved config cannot be interpreted as SSH options or malformed key paths | ✅ done |
| ✅ | Make `local/dev-tunnel.sh` session and PM2 SSH failures fail soft enough to show actionable local errors under `set -e` | ✅ done |
| ✅ | Validate PM2 ports, stop on duplicate remote ports before mutating tunnels, and check local port occupancy before `autossh` launch | ✅ done |
| ✅ | Replace broad `pkill -f "autossh.*$REMOTE_HOST"` guidance with managed tunnel PID selection and `local/dev-tunnel.sh --stop` | ✅ done |
| ✅ | Add a polished animated SSH sonar scan loader to `local/local.sh` so startup remote checks no longer look frozen | ✅ done |
| ✅ | Corriger la validation et l'affichage Termux du prompt serveur SSH local (`BUG-2026-05-02-002`) | ✅ done |
| ✅ | Corriger la résolution des noms simples de clés SSH locales (`BUG-2026-05-02-003`) | ✅ done |
| ✅ | Remplacer l'IP opérateur par une IP de documentation et purger l'historique GitHub récent (`BUG-2026-05-02-004`) | ✅ done |
| 🟠 | Rendre les alertes de cleanup disque explicites quand `/` est en pression critique (`BUG-2026-05-04-001`) | 🔄 in progress |
| ✅ | Corriger le raccourci CLI `sg u` et harmoniser les retours `x`/`Esc`/Backspace dans les sous-menus (`BUG-2026-05-04-002`) | ✅ done |
| 🟠 | Consolidate duplicated tunnel lifecycle logic between `local/dev-tunnel.sh` and `local/local.sh` so the interactive menu inherits the same validation, collision handling, and managed stop behavior | 📋 todo |
| 🔴 | Harden `install.sh` supply-chain and failure handling: replace live `curl | bash`/direct downloads with pinned, verified install steps and strict failure behavior | 🔄 in progress |
| 🟡 | Corriger la détection de commande dev quand un projet Flutter contient un `package.json` uniquement Convex (`BUG-2026-05-04-004`) | 🔄 in progress |
| 🟡 | Empêcher ShipGlows de créer des symlinks `TASKS.md` dans les projets et garder le tracking dans `shipglows_data` (`BUG-2026-05-05-001`) | 🔄 in progress |
| 🟠 | Local MCP OAuth tunnel login: commande `shipglows-mcp-login`, intégration menu local, alias install, tests de validation et docs | ✅ done |
| 🟠 | Split `lib.sh` hotspots around environment lifecycle, publishing, dashboard, inspector, and metadata helpers to reduce the 5,900+ line blast radius | 📋 todo |
| 🟡 | Resolve the `site` production dependency advisory for Astro (`GHSA-j687-52p2-xcff`) through a planned Astro upgrade/migration | 📋 todo |
| 🟡 | Fix `tests/cli/json-error-handling.sh` so the PM2 jq parsing fixture passes or is explicitly skipped with an accurate reason | 📋 todo |
| ✅ | Validate DuckDNS publish inputs, encode DuckDNS update requests, harden secret writes, and remove the default public ImgBB upload key | ✅ done |
| ✅ | Restore the Astro docs page build by moving dynamic GitHub URLs into frontmatter and escaping shell-style `${...}` text | ✅ done |
| ✅ | Corriger la latence du menu ShipGlows et bloquer les auto-sélections dangereuses dans Health/cleanup (`BUG-2026-05-08-001`, `BUG-2026-05-08-002`) | ✅ done |

### Audit: Perf (2026-04-29) — Score: B

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Load the public site fonts asynchronously in [site/src/layouts/BaseLayout.astro](/home/ubuntu/shipglows/site/src/layouts/BaseLayout.astro:24) so the Google Fonts stylesheet no longer blocks first paint | ✅ done |
| ✅ | Reduce compositor cost in [site/src/styles/global.css](/home/ubuntu/shipglows/site/src/styles/global.css:105) by gating blur effects behind `@supports` and lowering the blur radius on glass panels | ✅ done |
| ✅ | Defer below-the-fold layout and paint work on long static pages via `content-visibility` in [site/src/styles/global.css](/home/ubuntu/shipglows/site/src/styles/global.css:283) | ✅ done |
| ✅ | Prune heavyweight directories from [lib.sh](/home/ubuntu/shipglows/lib.sh:2233) project resolution scans and replace remote PM2 Python parsing with Node in [local/local.sh](/home/ubuntu/shipglows/local/local.sh:415) and [local/dev-tunnel.sh](/home/ubuntu/shipglows/local/dev-tunnel.sh:260) | ✅ done |
| 🟠 | Self-host the marketing site fonts or move to a local-first stack to eliminate the remaining cross-origin font dependency after the non-blocking preload patch | ✅ done |
| 🟡 | Consolidate duplicated remote PM2/tunnel parsing logic between [local/local.sh](/home/ubuntu/shipglows/local/local.sh:415) and [local/dev-tunnel.sh](/home/ubuntu/shipglows/local/dev-tunnel.sh:260) so future perf and failure-handling fixes do not drift | ✅ done |

## Audit Findings
<!-- Populated by /sg-audit — dated sections with Fixed: / Remaining: -->
🟠 [ShipGlows] task: Migrer les valeurs visuelles hardcodees du site ShipGlows vers des design tokens semantiques centralises dans `site/src/styles/global.css` et leurs usages partages | status: todo | area: site-design-system | spec: shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md | next: /102-sg-start ShipGlows site token hardening and visual standardization
🟠 [ShipGlows] task: Completer le socle des design tokens ShipGlows avec palette semantique, surfaces et motion pour le site public | status: todo | area: site-design-tokens | spec: shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md | next: /102-sg-start ShipGlows site token hardening and visual standardization
🟡 [ShipGlows] task: Justifier explicitement le mode unique du theme site dans la gouvernance ou ajouter une couverture multi-mode et une architecture de preference coherente | status: todo | area: site-theme-architecture | spec: shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md | next: /102-sg-start ShipGlows site token hardening and visual standardization

### Audit: Deps

🟠 [ShipGlows] task: Remediate the site Astro advisory with the planned major upgrade path | status: todo | area: site-deps | next: /010-sg-technical migrate astro@6
🟡 [ShipGlows] task: Add a committed lockfile and pin the tui toolchain for reproducible dependency audits | status: todo | area: tui-deps | next: bun install --lockfile-only

🟢 [ShipGlows] task: Empêcher les scans DevServer de descendre dans le contenu des répertoires `.flox` et rendre la synchronisation du registre lazy ou stale-aware | status: done | area: runtime-cli-perf | id: devserver-startup-flox-prune | spec: shipglows_data/workflow/specs/devserver-ui-centralization.md | evidence: scanner borné et registre lazy, atomique et stale-safe vérifiés; médianes source 0.13s et s x 0.19s | next: /005-sg-ship Optimize DevServer startup, caches, and shell UI
🟢 [ShipGlows] task: Réutiliser le registre ou un cache persistant pour les listes d'environnements et supprimer le second scan perdu dans un sous-shell | status: done | area: runtime-cli-perf | id: devserver-environment-cache | spec: shipglows_data/workflow/specs/devserver-ui-centralization.md | evidence: caches parent-shell et découverte unique vérifiés; médianes s m n 0.31s et s m r 0.58s | next: /005-sg-ship Optimize DevServer startup, caches, and shell UI
🟢 [ShipGlows] task: Mesurer puis borner le quiet drain TTY pour les raccourcis directs sans réintroduire de fuite de touches | status: done | area: runtime-cli-perf | id: devserver-tty-drain | spec: shipglows_data/workflow/specs/devserver-ui-centralization.md | evidence: attente fixe de 120ms supprimée; drain buffered-input et sélection/annulation gum et Bash validés en vrai TTY | next: /005-sg-ship Optimize DevServer startup, caches, and shell UI
