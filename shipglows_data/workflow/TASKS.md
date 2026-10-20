# Tasks — ShipGlows

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred
> **Priority last updated:** 2026-06-27 UTC · criteria: balanced (`impact`, `blockers`, `risk`, `high-roi`)
> **Recommended next execution target:** remediate the Astro production advisory (`GHSA-j687-52p2-xcff`) through the planned migration

---

## Active product chantiers

🟠 [ShipGlows] task: Spécifier et piloter l’ingestion de sources agnostique avec Readwise Reader comme premier adaptateur, une sélection explicite `shipglows-ready`, un accès agent read-only par défaut et une preuve d’export/récupération | status: todo | area: source-intelligence | id: provider-agnostic-source-ingestion-readwise-pilot | decision: shipglows_data/technical/decisions/provider-agnostic-source-ingestion-with-readwise-reader-pilot.md | source: décision opératrice 2026-08-26 | next: réviser la spec d’analyse de sources autour du contrat d’adaptateur et du pilote Reader
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
| 🟠 | Documenter la matrice de bootstrap par environnement : serveur Debian/Ubuntu, poste macOS, poste Linux non-root, Windows/WSL | 📋 todo |
| 🟡 | Évaluer s'il faut fournir un wrapper unique (`bootstrap` / `doctor`) pour vérifier et installer les prérequis avant usage | 📋 todo |
| 🟡 | Vérifier que `README.md`, `AGENT.md`, `CONTEXT.md` et `GUIDELINES.md` racontent le même contrat de bootstrap | 📋 todo |

🟡 [ShipGlows] task: Porter le menu local `urls` complet vers PowerShell natif, avec une parité explicitement définie avant code | status: deferred | area: windows-local-menu | id: windows-native-urls-parity | evidence: le bootstrap Windows, OpenSSH et un tunnel manuel sont vérifiés; le menu Unix/Termux reste Bash-only | decision: utiliser provisoirement la console navigateur Hetzner pour le CLI Unix et les URLs HTTPS publiques pour les aperçus | next: spécifier les actions Windows supportées et la stratégie de QA sur Windows PowerShell 5.1

---

## Documentation contracts

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Relire et shipper les docs `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `GUIDELINES.md` après la passe de durcissement en cours | 🔄 in progress |
| 🟡 | Normaliser à terme le schéma metadata si on veut éliminer la différence `linked_systems` / `linked_artifacts` | 📋 todo |

---

## Skills

🟡 [ShipGlows] task: Réconcilier l’index des alias runtime des skills avec les noms canoniques et de compatibilité | status: deferred | area: skills-runtime-index | id: reconcile-skill-alias-index | source: excellence verification 2026-07-18 | evidence: l’écart du linter est identique sur HEAD et non bloquant pour la synchronisation runtime | next: définir le périmètre de compatibilité avant correction

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Créer une skill `sg-prs` pour trier les PR GitHub ouvertes (`gh`), vérifier repo/branches/diffs/checks, regrouper Dependabot quand possible, merger les PRs vertes et fermer/commenter les PRs obsolètes selon une politique explicite | 📋 todo |

---

## Historical completed work

> Imported from the master tracker to keep local ShipGlows context coherent. These items are historical context, not active backlog.

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | Ajouter un handoff contenu à `sg-research` et `009-sg-marketing market` quand leurs rapports recommandent des contenus publics, avec sources, claims et route vers `sg-content` | 💤 deferred |
| 🟢 | Renforcer `sg-audit` master pour charger explicitement les corpus éditorial/technique quand l'audit touche des surfaces publiques, claims ou docs mappées | 💤 deferred |
| 🟢 | Ajouter une micro-intégration `technical-docs-corpus` à `sg-content`/`sg-repurpose` quand les opportunités ou handoffs touchent des docs techniques internes | 💤 deferred |
| 🟢 | Étudier `models.dev` comme source externe pour actualiser la référence `sg-model` sans hardcoder prix, limites, capacités et fenêtres de contexte | 💤 deferred |
| 🟢 | Étudier OpenPostern comme inspiration pour les skills de codage et veille technologique: vendor-risk score, CVE/NVD, CISA KEV, SSL/TLS, DNS, headers HTTP, news sécurité IA et recommandations actionnables | 💤 deferred |
| 🟢 | Étudier Alpic comme inspiration pour packager, déployer, monitorer et distribuer des MCP servers / ChatGPT Apps liés aux skills ShipGlows | 💤 deferred |
| 🟢 | Idée à cadrer : créer une brique partagée de journaux opérationnels append-only (`OPERATIONS_LOG.md` / `DEPENDENCY_LOG.md`) pour tracer les runs importants sans remplacer `specs/`, `shipglows_data/workflow/bugs/`, `TASKS.md` ni `CHANGELOG.md` | 💤 deferred |
| 🟢 | Cadrer plus tard le mécanisme de synchronisation `project repo -> master` pour `shipglows_data` (symlink, copie, index généré, ingestion web app ou autre) dans une spec dédiée | 💤 deferred |

🟢 [ShipGlows] task: Évaluer models.dev comme registre externe optionnel pour `sg-model` | status: deferred | area: model-routing | source: veille utilisateur https://models.dev/ 2026-06-10
🟢 [ShipGlows] task: Évaluer OpenPostern comme pattern pour enrichir `sg-veille`, `010-sg-technical deps`, `010-sg-technical audit` et les skills de codage avec scoring vendor-risk et signaux sécurité actionnables | status: deferred | area: tech-watch-security-skills | source: veille utilisateur https://betalist.com/startups/openpostern et https://openpostern.com/ 2026-06-10
🟢 [ShipGlows] task: Évaluer Alpic comme référence d'infrastructure MCP/ChatGPT Apps pour packaging, déploiement, monitoring, sécurité et distribution de skills ou serveurs MCP ShipGlows | status: deferred | area: mcp-app-distribution | source: veille utilisateur https://alpic.ai/ et https://alpic.ai/blog/deploy-chatgpt-apps-on-alpic 2026-06-10
🟢 [ShipGlows] task: Explorer si un index SQL opérationnel peut remplacer utilement une partie de `shipglows_data` sans dégrader la source de vérité documentaire | status: deferred | area: operational-data-architecture | source: recherche Bunny Database 2026-06-12 | next: /700-sg-explore SQL operational index over shipglows_data
🟢 [ShipGlows] task: Réévaluer plus tard les redondances entre profils nommés et focus tags puis supprimer les doublons de gouvernance si le runtime profils les remplace proprement | status: deferred | area: operator-profiles-governance | source: décision utilisateur 2026-06-28 | next: après implémentation runtime des profils
🟠 [ShipGlows] task: Formaliser la sémantique stable de la convention `%Profile`, ses règles d'interaction avec les focus tags et sa visibilité de handoff/reporting, sans prétendre à une primitive runtime native Codex ni créer de pseudo-runtime maison opaque | status: todo | area: operator-profiles-governance | source: décision utilisateur 2026-06-28 | next: /100-sg-spec named profile convention semantics
🟠 [ShipGlows] task: Créer un client OAuth Desktop Google, télécharger son fichier JSON et autoriser le profil GSC local en lecture seule | status: todo | area: seo-gsc-auth | source: décision utilisateur 2026-08-10 | spec: shipglows_data/workflow/specs/google-search-console-api-cli.md | next: créer les identifiants OAuth Desktop dans Google Cloud Console puis lancer le consentement GSC

---

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Rendre les alertes de cleanup disque explicites quand `/` est en pression critique (`BUG-2026-05-04-001`) | 🔄 in progress |
| 🟠 | Consolidate duplicated tunnel lifecycle logic between `local/dev-tunnel.sh` and `local/local.sh` so the interactive menu inherits the same validation, collision handling, and managed stop behavior | 📋 todo |
| 🟡 | Corriger la détection de commande dev quand un projet Flutter contient un `package.json` uniquement Convex (`BUG-2026-05-04-004`) | 🔄 in progress |
| 🟡 | Empêcher ShipGlows de créer des symlinks `TASKS.md` dans les projets et garder le tracking dans `shipglows_data` (`BUG-2026-05-05-001`) | 🔄 in progress |
| 🟠 | Split `lib.sh` hotspots around environment lifecycle, publishing, dashboard, inspector, and metadata helpers to reduce the 5,900+ line blast radius | 📋 todo |
| 🟡 | Resolve the `site` production dependency advisory for Astro (`GHSA-j687-52p2-xcff`) through a planned Astro upgrade/migration | 📋 todo |
| 🟡 | Fix `tests/cli/json-error-handling.sh` so the PM2 jq parsing fixture passes or is explicitly skipped with an accurate reason | 📋 todo |

### Audit: Perf (2026-04-29) — Score: B

## Audit Findings
<!-- Populated by /sg-audit — dated sections with Fixed: / Remaining: -->
🟠 [ShipGlows] task: Migrer les valeurs visuelles hardcodees du site ShipGlows vers des design tokens semantiques centralises dans `site/src/styles/global.css` et leurs usages partages | status: todo | area: site-design-system | spec: shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md | next: /102-sg-start ShipGlows site token hardening and visual standardization
🟠 [ShipGlows] task: Completer le socle des design tokens ShipGlows avec palette semantique, surfaces et motion pour le site public | status: todo | area: site-design-tokens | spec: shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md | next: /102-sg-start ShipGlows site token hardening and visual standardization
🟡 [ShipGlows] task: Justifier explicitement le mode unique du theme site dans la gouvernance ou ajouter une couverture multi-mode et une architecture de preference coherente | status: todo | area: site-theme-architecture | spec: shipglows_data/workflow/specs/shipglows-site-token-hardening-and-visual-standardization.md | next: /102-sg-start ShipGlows site token hardening and visual standardization

### Audit: Deps

🟠 [ShipGlows] task: Remediate the site Astro advisory with the planned major upgrade path | status: todo | area: site-deps | next: /010-sg-technical migrate astro@6
🟡 [ShipGlows] task: Add a committed lockfile and pin the tui toolchain for reproducible dependency audits | status: todo | area: tui-deps | next: bun install --lockfile-only
