# ShipGlows — Master Tasks

## Dashboard

| Project | Status | Top Priority |
|---------|--------|--------------|
| ContentFlow | 🔄 in progress | 🔴 Continue design-token centralization, then dual-mode AI runtime |
| ShipGlows | 🔄 in progress | 🟠 Harden `install.sh` supply-chain and failure handling |
| shipglows_app | 🔄 in progress | 🔴 Ready `shipglows-github-managed-clone-indexer.md`, then implement the read-only projection indexer boundary |
| TubeFlow App | 🔄 in progress | Valider Firebase Auth + Convex + YouTube OAuth sur le déploiement Vercel/Convex |
| WinFlowzApp | 🔄 in progress | 🟠 Ship verified persistent local clipboard fallback, then Android IME clipboard/device QA |
| Zikflow | 🔄 in progress | 🔴 Finaliser la V1 Flutter jouable (audio temps réel + validation release) |
| replayglowz | 🔄 in progress | Evaluate transcript worker latency only if `/transcribe` becomes an operational bottleneck |
| notefinderz | 🔄 in progress | Run `/sg-prod notefinderz` against the live site, then resume English editorial recovery |

## replayglowz

**Stack**: Flutter web app, Astro 6 marketing site, FastAPI transcript worker | **Phase**: Brand migration and hardening

**Top priority**: Evaluate transcript worker latency only if `/transcribe` becomes an operational bottleneck.

### Audit: Perf

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Remove unused `replayglowz_site/public/professional-headshot-*.png` payloads that were copied into every static build despite having no source references | ✅ done |
| ✅ | Remove global `lenis` smooth-scroll dependency and layout script so the Astro site build emits no client JavaScript chunks | ✅ done |
| ✅ | Batch `youtube:fetchPlaylistItems` calls in `syncAllPlaylists` instead of waiting for each playlist sync sequentially | ✅ done |
| ✅ | Defer the all-notes subscription on `VideosScreen` until the Notes view is active | ✅ done |
| ✅ | Self-host/subset the Google and Cal Sans font stack to remove remaining render-blocking remote font CSS | ✅ done |
| ✅ | Retire legacy domain/URL compatibility variables from the app build and OAuth runtime (`TUBEFLOW_*`, `NEXT_PUBLIC_*`) so `REPLAYGLOWZ_APP_URL`, `CONVEX_URL`, `GOOGLE_CLIENT_ID` are the only supported names | ✅ done |
| 🟡 | Evaluate transcript worker preflight/download duplication if `/transcribe` latency becomes an operational bottleneck | 📋 todo |

### Audit: Perf (2026-05-18 — Score: B)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Defer `convex_bridge.js` and `flutter_bootstrap.js` in `replayglowz_app/web/index.html` so third-party loading does not block first paint | ✅ done |
| 🟠 | Reduce per-row note filtering overhead in `notes_screen.dart` by normalizing search query once per build | ✅ done |
| 🟠 | Make web Convex subscriptions adaptive (fast initial poll, exponential backoff on stable/error cycles) to reduce unnecessary polling overhead | ✅ done |

## nantes-gratuit

**Stack**: Astro 6, Flutter 3.41, Supabase Auth/Postgres/Storage | **Phase**: Setup

**Top priority**: Créer le projet Supabase réel, appliquer le schéma et valider le flux auth + ajout de spot.

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Créer le projet Supabase réel, appliquer `supabase/schema.sql` et valider le flux auth + ajout de spot | ✅ done |
| 🟡 | Valider Google/Apple OAuth end-to-end avec comptes réels avant ouverture publique | 📋 todo |
| 🟠 | Créer la page pilier "Spots gratuits à Nantes" | ✅ done |
| 🟠 | Créer la page "Pourquoi Nantes Gratuit" | ✅ done |
| 🟠 | Créer la page "Aide alimentaire gratuite à Nantes" | ✅ done |
| 🟠 | Créer la page "Objets gratuits et ressourceries à Nantes" | ✅ done |
| 🟠 | Créer la page "Sorties gratuites à Nantes" | ✅ done |
| 🟠 | Créer la page "Toilettes, eau, wifi et lieux utiles gratuits à Nantes" | ✅ done |
| 🟠 | Créer la page "Accès aux droits et permanences gratuites à Nantes" | ✅ done |
| 🟠 | Créer la page "Charte de vérification" | ✅ done |

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Corriger le chemin de signalement photo sensible: empêcher `submit_report` de marquer une photo sensible comme quarantined sans suppression Storage publique, et traiter `hide`/`delete`/`quarantine` photo via Edge Function avec suppression du fichier public avant succès | ✅ done |
| ✅ | Aligner les inserts d'audit Edge Functions sur le schéma `moderation_actions.snapshot_before/snapshot_after` | ✅ done |
| ✅ | Corriger le mapping Flutter des RPC publiques (`spot_id`, `photo_id`, `comment_id`, `public_storage_path`) pour éviter IDs `null` et URLs photo cassées | ✅ done |
| 🟠 | Valider en environnement Supabase réel/local `supabase db reset`, RLS, Storage public/quarantine et Edge Functions photo/modération/suppression compte | ✅ done |
| 🟡 | Ajouter une vérification Deno (`deno check`/format ou CI Supabase Functions) car `deno` est absent de l'environnement local actuel | ✅ done |
| 🟡 | Masquer ou login-gater les actions contributives visibles sur une fiche spot pour les visiteurs non connectés au lieu de laisser l'échec arriver côté RPC | 📋 todo |


---

## tubeflow_lab

**Stack**: Python transcript worker, FastAPI, Flox, PM2, yt-dlp, faster-whisper | **Phase**: Runtime stabilized

**Top priority**: Add smoke tests for `/health` and `/transcribe`

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Repair Flox worker runtime so healthcheck reports all required binaries and Python packages | ✅ done |
| ✅ | Rebuild the worker virtualenv on Flox Python 3.12 + FFmpeg 8 | ✅ done |
| ✅ | Update standalone docs, changelog, and project task tracker | ✅ done |
| ✅ | Add configurable warning thresholds, optional hard caps, and concurrency guardrails before worker transcription jobs start | ✅ done |
| 🟠 | Investigate YouTube anti-bot extraction failures on some videos | ✅ done |
| 🟡 | Add a stable strategy for bot-gated YouTube downloads (cookies / per-request auth) | ✅ done |
| 🟡 | Expose queue depth / active job metrics in structured logs | ✅ done |
| 🟡 | Add a repeatable smoke test for `/health` and `/transcribe` | 📋 todo |

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Patch `requests` to >= 2.33.0 and smoke-test OpenAI/Deepgram transcript calls; CVE-2026-25645 is limited-use but affects a direct HTTP package in the worker | 📋 todo |
| 🟡 | Add a reproducible Python vulnerability scan in CI or a managed tool environment; local `pip-audit` direct mode worked, but full transitive resolution is blocked by missing `python3-venv` and no lockfile | 📋 todo |
| 🟡 | Add a Python lock or hash strategy so the worker image is reproducible beyond top-level `requirements.txt` pins | 📋 todo |
| 🟡 | Review major-version updates for FastAPI, Uvicorn, OpenAI Python SDK, and FunASR under `/sg-migrate` before changing worker dependencies | 📋 todo |

---

## notefinderz

**Stack**: Astro 6 SSR, Vue 3, Clerk, Convex, Vercel, npm | **Phase**: Production verification and editorial backlog

**Top priority**: Run `/sg-prod notefinderz` against the live site, then resume English editorial recovery.

### Active

🟠 [notefinderz] task: Run production verification for shipped Astro/Vercel and performance hardening changes | status: todo | area: ship | id: nf-prod-verify-2026-05
🟠 [notefinderz] task: Rewrite the English source copy before resuming French localization | status: todo | area: editorial | id: nf-editorial-source-copy
🟠 [notefinderz] task: Prioritize English rewrites for homepage and strategic app pages | status: todo | area: editorial | id: nf-editorial-top-pages

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Upgrade `@clerk/astro` to a patched range and verify middleware-protected auth routes; `npm audit` reports critical route-protection bypasses in direct Clerk packages and transitives | ✅ done |
| 🔴 | Plan and implement Astro/Vercel migration path for advisories that require major upgrades: `astro` 6.x, `@astrojs/vercel` 10.x, and `@astrojs/vue` 6.x; use `/sg-migrate` before changing majors | ✅ done |
| 🟠 | Patch current-major packages where available (`@clerk/astro` 2.17.11, `astro` 5.18.1, `@astrojs/vercel` 9.0.5, `postcss` 8.5.14, Vue/Convex/Svix minors) and rerun `npm audit`, `npm run check`, and `npm run build` | ✅ done |
| 🟠 | Add dependency update automation (`dependabot` or `renovate`) covering npm and GitHub Actions, with review required for major upgrades and auth/deploy packages | ✅ done |
| 🟡 | Add runtime/package-manager pins (`engines.node`, `packageManager`, `.nvmrc`, and Vercel runtime) to align on Node 22.12+ and npm lockfile installs | ✅ done |
| 🟡 | Clean dependency hygiene: remove unused `prop-types`, declare or remove app/config imports for `@tanstack/vue-query`, `vite`, `@vitejs/plugin-react-swc`, and `lovable-tagger`, and confirm `@clerk/types` type-only usage | ✅ done |
| 🟡 | Document license posture for transitive LGPL packages from image/build tooling and add the project license field if the repo is redistributed | ✅ done |

---

## gocharbon

**Stack**: Astro 5, Vue 3, UnoCSS, Markdown | **Phase**: Content clusters

**Top priority**: Relire et polisher les 5 parcours pilotes avant ouverture Search Console

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Cluster Copywriting — 14 articles (pillar + 13 spokes, ~25 400 mots) | ✅ done |
| ✅ | Tag "Copywriting" dans tagHierarchy.ts | ✅ done |
| ✅ | Maillage interne cross-cluster (6 articles modifiés) | ✅ done |
| ✅ | Réécrire article Tugan Bara — portrait complet (parcours, méthode, analyse) | ✅ done |
| ✅ | Réécrire article RX — avis honnête (contenu, prix, pour/contre, alternatives) | ✅ done |
| 🟠 | Réécrire "le copywriting qui hypnotise" (brouillon YouTube) | 📋 todo |
| 🟡 | Supprimer "direct response marketing prédateur" (remplacé) | 📋 todo |
| 🟡 | Réécrire ou supprimer "maîtrisez l'art de la persuasion" | 📋 todo |
| 🟡 | Passe éditoriale qualité sur les 14 articles du cluster | 📋 todo |
| ✅ | Cocon Documents Business — structure 9 fichiers (pilier + 8 fiches, metadata prêtes) | ✅ done |
| ✅ | Rédiger contenu PRD (source : framework 6 Dimensions, v0-product-requirement-evaluation) | ✅ done |
| ✅ | Rédiger contenu Lean Canvas | ✅ done |
| ✅ | Rédiger contenu Cahier des Charges | ✅ done |
| ✅ | Rédiger contenu Pitch Deck | ✅ done |
| ✅ | Rédiger contenu Executive Summary | ✅ done |
| ✅ | Rédiger contenu Roadmap Produit | ✅ done |
| ✅ | Rédiger contenu User Stories | ✅ done |
| ✅ | Rédiger contenu One-Pager | ✅ done |
| ✅ | Rédiger page pilier Documents Business (vue d'ensemble + maillage) | ✅ done |
| ✅ | Audit SEO complet (27 fixes code + 13 doublons draftés + 97 thin content triés) | ✅ done |
| 🔴 | Supprimer, passer en draft ou réécrire le contenu anglais inutile encore live (19 tutos EN puis 166 contenus EN/mixtes retirés, scan résiduel = 0) | ✅ done |
| 🔴 | Réduire le lancement `parcours` à 5 fiches pilotes (`freelance`, `tests-utilisateurs-remuneres`, `e-commerce`, `createur-contenu`, `formation`) pour concentrer la première distribution Google | ✅ done |
| 🔴 | Canonicaliser `parcours` pour ne garder qu'une seule URL indexable par fiche (29 variantes EN/FR) | ✅ done |
| 🟡 | Remapper les liens internes restants après le sweep EN / retrait des alias `parcours` | ✅ done |
| 🟠 | Verrouiller le périmètre indexable pour un lancement Search Console limité au cluster `parcours` (homepage + fiches + pages légales indexables; le reste en `noindex, follow`, avec filtre sitemap aligné) | ✅ done |
| 🟠 | Sortir réellement du build les sections hors lancement (`blog`, `outils`, `tutos`, `quiz`, `progression`, `bio`, `methodologie`, `api`, `feed`) avec un mode `parcours-only` et une purge post-build du `dist` | ✅ done |
| 🟡 | Vérifier en build le sitemap, `robots.txt` et le périmètre final livré avant ouverture Search Console | ✅ done |
| ✅ | Stabiliser le build après réécriture massive (compatibilité `pubDate` string/Date + correction d’erreurs frontmatter invalides) | ✅ done |
| 🟢 | Retirer les fichiers de coordination de lot non suivis (`BUILD.md`, `CONTENT_TRIAGE.md`) | ✅ done |
| 🔴 | Relire à la main les 5 parcours pilotes et corriger tout ce qui n'est pas carré, efficace, fidèle ou légitime | 📋 todo |
| 🔴 | Polisher le design et la perception qualité sur la homepage, `/parcours` et les 5 fiches pilotes | 📋 todo |
| 🟠 | Ouvrir la propriété Search Console et soumettre le sitemap limité une fois les 5 parcours pilotes validés | 📋 todo |
| 🟡 | Étendre ensuite progressivement la surface indexable `parcours` fiche par fiche, après relecture et validation manuelle | 📋 todo |
| 🟡 | Garder les 94 fichiers `to_decide/` hors build (dossier racine, en dehors de `src/data` et `src/content`) | ✅ done |
| 🟠 | Remplacer l'image placeholder `astro.jpeg` sur ~2300 fichiers | 📋 todo |
| 🟠 | Réécrire ~100+ descriptions génériques d'outils ("Découvre X : outil français…") | ✅ done |
| 🟠 | Chantier `OpenAI freshness audit GoCharbon` (lot A/B + validation + traçabilité spec) | ✅ done |
| 🟡 | 📝 Article "Comment estimer le coût de ton app en 5 min avec l'IA" — source: https://costgpt.ai/ (veille 2026-04-04) | 📋 todo |
| 🟡 | 📝 Article "Painkiller vs Vitamin : la méthode pour valider une idée startup" — source: https://painkillerideas.com/ (veille 2026-04-04) | 📋 todo |
| 🟡 | 📝 Guide "Facturation électronique obligatoire 2026 : quelle PDP choisir ?" — source: https://www.impots.gouv.fr/je-consulte-la-liste-des-plateformes-agreees (veille 2026-04-04) | 📋 todo |
| 🟡 | 📝 Article portrait "Funbooker : la marketplace française du loisir" (SAS 339K€, modèle, paiements ANCV) — source: https://www.funbooker.com/ (veille 2026-04-04) | 📋 todo |

### Audit: Deps (2026-04-27)

- [x] ✅ Chantier `dependency security stabilization` terminé (`/sg-start`, 2026-04-27).
- [x] 🔴 Corriger les advisories `pnpm audit` sans upgrade majeur automatique: critic/high passés de `1/19` à `0/0`; reste `8 moderate` + `3 low` (majoritairement chaîne Astro 5, à traiter via `/sg-migrate astro@6`).
- [x] 🟠 Résoudre la dérive de gestionnaire: `package-lock.json` supprimé, `pnpm-lock.yaml` conservé source de vérité.
- [x] 🟠 Ajouter une automatisation de mises à jour dépendances (`dependabot` ou `renovate`) couvrant npm/pnpm et GitHub Actions, avec revue humaine pour les majors.
- [x] 🟠 Trancher le risque licence: `astro-breadcrumbs@3.3.3` retiré et remplacé par un fil d'Ariane local.
- [x] 🟡 Épingler la version runtime Node (`engines`, `.nvmrc` ou `.node-version`) et aligner CI/déploiement.
- [x] 🟡 Vérifier puis supprimer ou reclasser les dépendances directes probablement inutilisées: `@vitejs/plugin-vue`, `@eliancodes/brutal-ui`, `gsap` supprimées.
- [x] 🟡 Documenter la provenance/licence de `@diane-winflowz/gamification` et surveiller le tarball GitHub direct sans checksum SRI classique (doc + alias de build ajoutés).
- [x] 🟡 Remplacer ou assumer `lucide-astro`, signalé deprecated par `pnpm outdated` (assumé temporairement; migration non-bloquante vers `@lucide/astro` à planifier).
- [x] 🟡 Nettoyer la configuration active: `astro.config.mjs` confirmée active, `astro.config.ts` supprimé.
- [x] sg-deps audit (2026-05-24): 0 critical / 0 high / 0 moderate / 0 low after non-major fixes; remaining major-lane follow-up: `eslint` 10.x, `satori` 0.26.x, `lucide-astro` deprecation.

---

## jarrettelacoke.fr (site)

**Stack**: Astro 6, Vue 3, Clerk, Polar, RevenueCat, TypeScript | **Phase**: Launch-ready

**Top priority**: Configurer la prod Vercel (env vars + DNS), finaliser le légal et brancher les paiements

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Configurer le domaine canonique `jarrettelacoke.fr` et retirer les anciens noms produit des tâches actives | 📋 todo |
| 🔴 | Deploy sur Vercel (git push + connect project) | ✅ done |
| 🔴 | Configurer env vars Vercel minimales (`PUBLIC_APP_URL`, Resend, `CRON_SECRET`, puis services optionnels) | 📋 todo |
| 🔴 | Creer produits Polar (mensuel 9.99, annuel 79.99) | 📋 todo |
| 🟠 | I18n shell site FR/EN/ES — infrastructure en place dans le repo, mais publication publique volontairement limitée au français pour le lancement | ✅ done |
| 🟢 | Remettre EN/ES en ligne après relecture éditoriale complète et validation produit ; d'ici là, les locales restent hors build public | 💤 deferred |
| 🟠 | Refonte mobile du shell et de l'accueil (header, hero, cartes, CTA) | ✅ done |
| 🟠 | Améliorer le dark theme du tracker et des surfaces app pour un rendu sombre cohérent | ✅ done |
| 🟠 | Corriger les warnings Astro de build (conflits `/questions/[slug]` + accès headers en prerender) | ✅ done |
| 🟠 | Repositionner `/coach` et `/communaute` en aperçus honnêtes sur le site (coach bientôt, communauté prototype local) | ✅ done |
| ✅ | Recentrer la promesse du futur coach en assistant de recentrage immédiat avec limites explicites sur `/coach`, `/application`, `/communaute` et les contenus FR qui l'introduisent | ✅ done |
| 🟡 | Étendre la passe mobile à `/pricing` et `/application` pour harmoniser les pages de conversion | 📋 todo |
| 🟠 | Google Search Console (verifier site + submit sitemap) | 📋 todo |
| 🟠 | Remplir placeholders mentions-legales (societe, SIRET, adresse) | 📋 todo |
| ✅ | Enrichir contenu 4 sections (33 articles, 88K mots, 150+ sources) | ✅ done |
| 🟠 | Creer fichiers formations premium (18 modules) | 📋 todo |
| 🟠 | Ajouter tag GA4 en production | 📋 todo |
| 🟡 | Community wall component (Sprint 4) — prototype local remis en ligne, backend live encore absent | 🔄 in progress |
| ✅ | Décision produit coach — ne pas relancer un "coach personnel" large ; cadrer la future brique comme un assistant de recentrage immédiat avec limites claires | ✅ done |
| 🟡 | Assistant de recentrage immédiat (Sprint 4) — spécifier une V1 honnête avec garde-fous, escalade humaine et réponses bornées avant implémentation | 📋 todo |
| 🟡 | Brancher le community wall sur un vrai backend multi-utilisateur avec modération | 📋 todo |
| 🟡 | Implémenter l'assistant de recentrage V1 dans l'application une fois la spec produit/sécurité validée | 💤 deferred |
| 🟡 | App mobile iOS/Android via RevenueCat | 💤 deferred |
| 🟡 | Version anglaise (EN expansion) | 💤 deferred |

### Audit (2026-03-21 — Overall: C+)

| Pri | Task | Domain |
|-----|------|--------|
| 🔴 | Wire Polar checkout + create CGV page | GTM |
| 🔴 | Rate limit /api/coach + /api/newsletter + fix prompt injection | Code |
| 🔴 | Fill legal placeholders (mentions-legales, confidentialite) | Copy |
| 🔴 | Add /arreter-la-cocaine to nav (orphan SEO page) | SEO |
| 🔴 | Switch to hybrid/prerender for 50+ static pages | Perf |
| 🔴 | Fix Node engine mismatch (>=24 vs runtime 22) | Deps |
| 🟠 | Security headers, RevenueCat webhook fix, .env.example, tests | Code |
| 🟠 | Dead footer links, textareas field-sizing, apple-touch-icon | Design |
| 🟠 | Remove fake social proof, add accents, formation content | Copy |
| 🟠 | FAQ schema, E-E-A-T author signals, shorten titles, PNG og:image | SEO |
| 🟠 | Wire analytics events, cookie consent | GTM |
| 🟠 | Remove sharp/broken-link-checker, pin gamification dep | Deps |
| 🟠 | GamificationBar client:idle, drip batch, caching headers | Perf |

### Audit: SEO (2026-04-27 — Overall: B+)

> Base technique AEO/SEO renforcée le 2026-04-27: `llms.txt`, `llms-full.txt`, règles IA explicites, `Person` schema, `meta author`, `SpeakableSpecification`, `hreflang` normalisé, et `lastmod` rétabli sur 179 URLs du sitemap. Les risques restants sont surtout éditoriaux, E-E-A-T et social preview.

| Pri | Task | Domain | Status |
|-----|------|--------|--------|
| 🟠 | Réécrire les `<title>` et meta descriptions trop courts ou trop longs sur les pages FR publiques prioritaires (`/`, `/arreter-la-cocaine`, hubs `comprendre`/`sevrage`/`prevention`/`reconstruction`, parcours, pages légales indexables), puis étendre la passe au reste du corpus | SEO | 📋 todo |
| 🟠 | Ajouter des citations primaires et des repères de fraîcheur visibles sur les pages YMYL les plus sensibles (`/comprendre/statistiques-cocaine-france`, santé, sevrage, urgence) pour renforcer E-E-A-T et l’extraction IA | SEO | 📋 todo |
| 🟠 | Ouvrir Google Search Console sur la prod, soumettre `sitemap-index.xml`, puis demander l’indexation de `/`, `/arreter-la-cocaine`, `/test-addiction` et `/questions` | SEO | 📋 todo |
| 🟠 | Relire et réécrire les passages EN/ES les plus visibles encore trop traduits littéralement avant une relance internationale pour éviter les signaux de qualité faibles hors FR | Translate | 📋 todo |
| 🟡 | Ajouter un vrai profil auteur public pour Diane (`sameAs`, bio éditoriale, légitimité/source de compétence) afin de compléter le `Person` schema déjà branché | SEO | 📋 todo |
| 🟡 | Remplacer `public/og-image.svg` par une image sociale PNG 1200x630 pour maximiser la compatibilité des aperçus | SEO | 📋 todo |
| 🟡 | Restructurer les intros et les premiers paragraphes/H2 des pages piliers pour répondre plus directement à la requête dans les 200 premiers mots et faciliter l’extraction AEO/GEO | SEO | 📋 todo |

### Audit: Accessibility (2026-03-26 — Overall: C-)

| Pri | Task | Domain |
|-----|------|--------|
| ✅ | Replace fake tab pattern on `/tracker` with keyboard-accessible tabs or plain buttons/panels | Design |
| ✅ | Add modal focus management to `CravingHelper.vue` (initial focus, trap, restore focus) | Design |
| ✅ | Add proper labels and live announcements to `AICoach.vue` | Design |
| 🟠 | Add programmatic labels and selection state to `ConsumptionTracker.vue` controls | Design |
| ✅ | Add real labels to placeholder-only form fields in `EmailCapture.vue` and `CommunityWall.vue` | Design |
| 🟡 | Harden visible focus styling where custom inputs override browser outlines | Design |
| 🟡 | Review mobile nav disclosure semantics in `SiteHeader.astro` | Design |

### Audit: Design (2026-04-18 — Overall: C→B-)

| Pri | Task | Domain |
|-----|------|--------|
| 🟠 | Add a visible swipe affordance or pagination hint on the mobile horizontal scrollers (`stats-grid`, `explore-grid`, `parcours-grid`) so extra cards are discoverable without guesswork | Design |
| 🟠 | Run a real-device QA pass for the floating mobile helpers (`GamificationBar`, `CookieConsent`, `CravingHelper`) on 320–390px widths to validate overlap, safe-area spacing, and keyboard behavior | Design |
| 🟡 | Create `BRANDING.md` so future design audits can measure mobile/UI choices against an explicit brand system instead of layout only | Design |

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Upgrade `@clerk/astro` to a patched 3.0.x range to close GHSA-vqx2-fgx2-5wq9 route-protection bypass and refresh transitive `@clerk/shared` / `@clerk/backend` advisories | ✅ done |
| 🟠 | Upgrade compatible Astro/Vite/PostCSS-related packages within the current major range (`astro`, `@astrojs/vercel`, `@astrojs/sitemap`, Vue patch updates) and rerun `npm audit`, `npm run check`, and `npm run build` | ✅ done |
| 🟠 | Add dependency update automation (`dependabot` or `renovate`) covering npm and GitHub Actions with human review for majors | ✅ done |
| 🟡 | Add `packageManager` to `package.json` or align docs/tooling if the project should use pnpm; current committed lockfile is npm while CLAUDE.md says pnpm | ✅ done |
| 🟡 | Document license posture for transitive Sharp/libvips LGPL packages used by Astro image tooling | ✅ done |

### Audit: Copy (2026-04-19 — Homepage conversion)

| Pri | Task | Domain |
|-----|------|--------|
| ✅ | Ajouter une preuve de confiance concrète sur la home (questions en ligne, parcours gratuit, confidentialité locale) pour soutenir la promesse avant la bascule vers l'application | Copy |
| ✅ | Harmoniser `/application` et `/pricing` sur le split site gratuit → application → Premium | Copy |
| 🟠 | Vérifier dans l'analytics que la nouvelle home envoie bien plus de clics vers `/questions`, `/parcours/arreter` et `/application` que vers des sorties secondaires | GTM |
| 🟡 | Revoir la place du bandeau email sur la home s'il concurrence encore les nouvelles portes d'entrée contenu / application | Copy |

---

## NoCocaïne (Flutter app)

**Stack**: Flutter 3.41, Riverpod 3, GoRouter, Dio, SharedPreferences | **Phase**: App Store submission + UX polish

**Top priority**: Tester sur vrai appareil iOS + coller privacy URL dans App Store Connect

### Release Blockers (2026-04-18)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Fix la regression `AppSwipeScope` introduite par le refactor du pager (`more_tabbed_screen.dart`, `tracker_screen.dart`) pour que `flutter analyze lib test pubspec.yaml` repasse au vert | ✅ done |
| 🟡 | Nettoyer les infos d'analyse restantes dans `lib/bootstrap.dart` (packages `source_maps`, `source_map_stack_trace`, `stack_trace`) | ✅ done |
| 🟡 | Remplacer le placeholder App Store URL dans `lib/config/cocaine_config.dart` quand la fiche App Store existe | 📋 todo |

### App Store Submission Checklist

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Privacy policy + CGU — ecran in-app FR/EN/ES | ✅ done |
| 🔴 | Privacy policy web — section app mobile sur jarrettelacoke.fr/confidentialite | ✅ done |
| 🔴 | CFBundleName corrige → NoCocaïne | ✅ done |
| 🔴 | Sentry DSN configure dans Doppler | ✅ done |
| 🔴 | Localisation FR/EN/ES complete (176 const → getters trilingues) | ✅ done |
| 🔴 | Coller URL privacy policy dans App Store Connect | 📋 todo |
| ✅ | UX polish — retroactive entry, UI sizing, header, check-in widget, morning ritual fixes | ✅ done |
| 🟠 | Tester sur vrai appareil iOS avant soumission | 📋 todo |
| 🟡 | Ecrire des tests (un seul widget_test.dart template) | 📋 todo |

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Remove or replace unused discontinued `flutter_markdown` dependency (`flutter pub get --dry-run` reports replacement: `flutter_markdown_plus`) | ✅ done |
| 🟡 | Remove unused direct/codegen dependencies after a quick analyzer pass: `cupertino_icons`, `flutter_animate`, `freezed`, `freezed_annotation`, `json_annotation`, `json_serializable`, and `build_runner` if no generated model flow is intended | ✅ done |
| 🟡 | Add dependency update automation for pub, npm, GitHub Actions, and Gradle plugin surfaces | ✅ done |
| 🟡 | Plan `sentry_flutter` 9.x as `/sg-migrate` work; it remains the only direct major dependency migration after the cleanup pass | 📋 todo |

> **Contexte** : Audit gamification complet (2026-03-21). L'app tombe dans le PBL Trap — gamification concentrée sur CD2 (badges/niveaux par articles lus), les 7 autres Core Drives sous-exploités. Proxy désaligné : on mesure les articles lus au lieu de la guérison réelle.
> **Principe directeur** : La gamification doit mesurer et célébrer la guérison réelle, pas l'engagement dans l'app. Éthique = P0 (population vulnérable).

### P0 — Système de rechute compassionnel (CRITIQUE ÉTHIQUE)

> **Pourquoi P0** : La pensée binaire ("j'ai tout perdu") est un facteur de rechute connu. Le streak sans filet est l'anti-pattern le plus dangereux pour cette population.

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Grace period automatique — 1 jour de conso légère ne casse pas le streak | ✅ done |
| 🔴 | Streak freeze gagnable — après 14 jours clean, +1 streak freeze | ✅ done |
| 🔴 | "Longest streak" toujours visible même après reset | ✅ done |
| 🔴 | Taux de réussite (%) en complément du streak — "Ce mois : 93% clean" | ✅ done |
| 🔴 | Messages compassionnels de rechute — "Un détour, pas un retour à zéro" | ✅ done |
| 🔴 | Message de retour bienveillant — "Content de te revoir. Tes progrès sont intacts." | ✅ done |
| 🟠 | Streak recovery — restaurer un streak récemment perdu (< 48h) | ✅ done |
| 🟠 | Adapter SobrietyState provider pour supporter grace period + freeze | ✅ done |

### P1 — Badges de compétence (alignement de purpose)

> **Pourquoi P1** : Remplacer les badges de volume (articles lus) par des badges liés à la guérison réelle. Loi de Goodhart : quand on mesure les articles lus, les articles lus deviennent l'objectif.

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Refonte modèle Badge — conditions basées sur tracker data (cravings résistés, jours clean, triggers identifiés) | ✅ done |
| 🔴 | Badge "Analyseur" — identifié ses 3 triggers principaux (via données tracker) | ✅ done |
| 🔴 | Badge "Résilient" — résisté à 10 cravings | ✅ done |
| 🔴 | Badge "Maître de soi" — 30 jours consécutifs clean | ✅ done |
| 🟠 | Badge "Stratège" — créé 3 stratégies personnelles dans le toolkit | ✅ done |
| 🟠 | Badge "Économe" — 500€ économisés | ✅ done |
| 🟠 | Badge "Vainqueur du [trigger]" — résisté 5x au trigger le plus fréquent | ✅ done |
| 🟠 | Badge "Traversée" — atteint le Jour 90 | ✅ done |
| 🟡 | Conserver les badges de lecture existants mais les pondérer moins | ✅ done |
| 🟡 | Système de tiers par badge (bronze/argent/or) pour cravings résistés | ✅ done |

### P1 — Carte du Voyage (narrative + CD1 Epic Meaning)

> **Pourquoi P1** : L'utilisateur vit un voyage héroïque de reconstruction cérébrale. L'app le traite comme un compteur. La carte aligne la progression sur la neurobiologie réelle du sevrage.

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Concevoir les 6 zones visuelles (Tempête → Sommet) avec couleurs + messages | ✅ done |
| 🔴 | Modèle RecoveryZone — zone calculée depuis quitDate + currentDay | ✅ done |
| 🔴 | Écran Carte — vue map/chemin avec position actuelle et zones traversées | ✅ done |
| 🟠 | Transition visuelle entre zones — animation + message de passage | ✅ done |
| 🟠 | Intégrer les milestones existants dans les zones de la carte | ✅ done |
| 🟠 | Remplacer le système de niveaux (Curieux→Libéré) par la progression géographique | 📋 todo |
| 🟡 | Icônes et illustrations par zone (adapter au thème existant) | ✅ done |
| 🟡 | Lier les leçons du curriculum aux zones correspondantes | ✅ done |

### P1 — Toolkit Personnel (CD3 Creativity + CD4 Ownership)

> **Pourquoi P1** : L'utilisateur doit "construire" quelque chose qui lui appartient. L'effet IKEA crée de l'attachement. Le toolkit a un transfert direct vers la vie réelle (KB-21).

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Modèle ToolkitItem — technique, date débloquée, fois utilisée, efficacité notée | ✅ done |
| 🔴 | Provider toolkitProvider — gestion état + persistence SharedPreferences | ✅ done |
| 🔴 | Écran Toolkit — liste des outils débloqués avec stats d'utilisation | ✅ done |
| 🟠 | Lier les leçons au déblocage d'outils (ex: leçon 4-7-8 → outil "Respiration") | ✅ done |
| 🟠 | Tracker "J'ai utilisé un outil" dans le check-in quotidien | ✅ done |
| 🟠 | Notation d'efficacité par outil (★1-5) après utilisation | ✅ done |
| 🟠 | Section "Ma stratégie personnelle" — texte libre éditable | ✅ done |
| 🟡 | Lier le toolkit au Craving Modal — proposer les outils les mieux notés en premier | ✅ done |
| 🟡 | Pont vers la vie réelle : "Cet outil est à toi pour toujours, même sans l'app" | ✅ done |

### P2 — Rituels quotidiens enrichis (Hook Model + CD7)

> **Pourquoi P2** : Transformer le check-in de "collecte de données" en rituel de conscience. Ajouter variabilité (Variable Reward) pour maintenir l'engagement.

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Intention matinale (optionnel) — "Quel est ton plus grand risque aujourd'hui ?" | ✅ done |
| 🟠 | Réflexion du soir (optionnel) — "De quoi es-tu fier aujourd'hui ?" | ✅ done |
| 🟠 | Journal de fierté — accumulation des réflexions positives, consultable | ✅ done |
| 🟠 | Récompense variable post check-in — tantôt insight, tantôt stat, tantôt encouragement | ✅ done |
| 🟠 | Widgets matin/soir contextuels selon l'heure locale sur Today | ✅ done |
| 🟠 | Thème automatique lever/coucher du soleil basé sur la localisation réelle | ✅ done |
| 🟠 | Mode zen renforcé en vraie variante d’expérience sobre (Today, Carte, Tracker, Dashboard, compteur, quêtes et notifications) | ✅ done |
| 🟠 | Compacter Today : intégrer l'objectif dans la bande de stats, fusionner la leçon du jour avec la carte de phase, durcir le Today zen et corriger la copie FR associée | ✅ done |
| 🟡 | Enrichir check-in — "As-tu utilisé un outil de ton toolkit aujourd'hui ?" | ✅ done |
| 🟡 | Rétrospective hebdomadaire automatique — résumé de la semaine en 3 stats clés | ✅ done |
| 🟡 | Tester sur vrai appareil la permission localisation et le basculement soleil du thème Auto | 📋 todo |
| 🟡 | Tester sur vrai appareil le mode zen complet (Today, Carte, Tracker, Dashboard, compteur, notifications) | 📋 todo |

### P2 — Preuve sociale anonyme (CD5 sans compétition)

> **Pourquoi P2** : L'isolement aggrave l'addiction. La preuve sociale anonyme combat ce sentiment sans les risques du social (honte, compétition). JAMAIS de leaderboard.

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | API ou estimation locale — "X personnes se battent comme toi aujourd'hui" | ✅ done |
| 🟠 | Message après check-in clean — "Tu fais partie des X personnes qui ont résisté" | ✅ done |
| 🟡 | Message après craving résisté — "X personnes ont utilisé le 4-7-8 à cette heure" | ✅ done |
| 🟡 | Message milestone — "X personnes ont atteint le Jour 30 ce mois-ci" | ✅ done |
| 🟡 | Privacy-first : chiffres agrégés uniquement, aucune donnée individuelle | ✅ done |

### P2 — Coach IA enrichi par gamification

> **Pourquoi P2** : Le coach a accès aux données tracker mais ignore le toolkit, la carte, les badges, le journal de fierté. Ces données enrichissent drastiquement la personnalisation.

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Enrichir contexte coach — toolkit utilisé, zone carte, badges proches, journal fierté | ✅ done |
| 🟠 | Coach peut rappeler les victoires passées du journal de fierté | ✅ done |
| 🟡 | Coach contextualise avec la zone — "Tu es dans La Montagne, les cravings sont normaux ici" | ✅ done |
| 🟡 | Coach célèbre les badges proches — "Plus que 2 cravings résistés pour ton badge Résilient" | ✅ done |

### P3 — Échafaudage progressif (long terme)

> **Pourquoi P3** : La meilleure gamification rend l'utilisateur autonome. L'intensité de la gamification doit diminuer à mesure que l'habitude se forme (concept Vygotsky, KB-21).

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | Phase 1 (mois 1-2) — gamification intensive, célébrations fréquentes | ✅ done |
| 🟡 | Phase 2 (mois 3-6) — gamification dégressive, feedback moins fréquent | ✅ done |
| 🟡 | Phase 3 (mois 6+) — gamification minimale, l'utilisateur vient par choix | ✅ done |
| 🟡 | Message de graduation (Jour 90+) — "Tu n'as plus besoin de nous. Et c'est magnifique." | ✅ done |
| 🟡 | Réduction automatique des notifications selon la phase | ✅ done |
| 🟢 | Rétrospective trimestrielle — résumé d'impact vie réelle, pas de métriques in-app | 💤 deferred |
| 🟢 | Mode zen — toggle pour désactiver toute gamification | ✅ done |

### Audit Gamification (2026-03-22 — Octalysis: 65→278/800 — IMPLÉMENTÉ)

| Core Drive | Avant | Après | Ce qui a été fait |
|---|---|---|---|
| CD1 Epic Meaning | 3 | 7 | Carte du Voyage (6 zones neuro), narrative héroïque, graduation J90 |
| CD2 Accomplishment | 5 | 7 | 9 badges compétence + tiers bronze/argent/or + clean day badges |
| CD3 Creativity | 3 | 7 | Toolkit personnel (8 outils + custom), notation, rituels quotidiens |
| CD4 Ownership | 3 | 7 | Toolkit "à toi", journal de fierté, stratégies perso |
| CD5 Social | 1 | 4 | Preuve sociale anonyme, community pulse, zéro compétition |
| CD6 Scarcity | 2 | 4 | Outils débloqués progressivement, zones à traverser |
| CD7 Unpredictability | 2 | 5 | Variable rewards, badge Phoenix secret, récompenses post check-in |
| CD8 Loss/Avoidance | 2 | 5 | Grace period, streak recovery, messages compassionnels, mode zen |

**Cible post-implémentation** : 278/800 (score 4x, équilibré sur 8 drives)

### Curriculum de micro-leçons progressives

> **Objectif** : Contenu éducatif délivré progressivement, jour après jour, adapté à la phase de récupération. Chaque leçon = 2-3 min, 3 cartes swipables, 1 takeaway actionnable.

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Infrastructure — modèle Lesson, LessonCard, curriculum list, providers | ✅ done |
| ✅ | Semaine 1 (Sevrage, jours 0-6) — 7 leçons : nettoyage corps, sommeil, 72h, alimentation, irritabilité, exercice, prep semaine 1 | ✅ done |
| ✅ | Semaine 2 (Cerveau, jours 7-12) — 6 leçons : dopamine, circuit récompense, mémoire, neurotransmetteurs, cortex préfrontal, neuroplasticité | ✅ done |
| ✅ | Semaines 3-4 (Déclencheurs, jours 14-27) — 11 leçons : patterns, stress, ennui, pression sociale, fatigue, émotions, travail, alcool/soirées, réseau de soutien, solitude | ✅ done |
| ✅ | Semaines 5-8 (Autorégulation, jours 28-55) — 9 leçons : 1 mois, émotions, pensées auto, distorsions cognitives, habitudes, PAWS, auto-compassion, purpose, mindfulness | ✅ done |
| ✅ | Semaines 9-12 (Reconstruction, jours 60-85) — 6 leçons : plaisir naturel, relations, identité, confiance, finances, prep jour 90 | ✅ done |
| ✅ | Semaine 13+ (Maintenance, jours 90-270) — 5 leçons : 90j milestone, 4 mois, 5 mois, 6 mois, 9 mois | ✅ done |
| ✅ | Leçons contextuelles — 9 leçons liées à des triggers spécifiques (Stress, Ennui, Fête, Alcool, Entourage, Émotions, Fatigue, Solitude, Travail) | ✅ done |
| ✅ | Étendre au-delà de 270 jours — leçons année 1 (jours 300, 330, 365) | ✅ done |
| 🟡 | Leçons spéciales rechute — contenu déclenché après un épisode de consommation | 📋 todo |
| 🟡 | Audio/narration — version audio des leçons pour accessibilité | 💤 deferred |

**Total actuel : 47 leçons couvrant 365 jours (1 an complet) avec 0 jour sans contenu dans les 4 premières semaines.**

### Corrections techniques (2026-03-22)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Fix `valueOrNull` → `.value` pour Riverpod 3 (tracker_provider.dart) | ✅ done |
| 🔴 | Fix `Badge` ambiguous import (Flutter Material vs app model) | ✅ done |
| 🔴 | Fix 44 erreurs d'analyse liées au refactor multi-substance (TrackerEntry TSO fields, providers, screens) | ✅ done |

### i18n Flutter App (2026-03-28)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Système i18n complet — classe Fr avec locale dynamique, supportedLocales (fr, en, es) | ✅ done |
| 🔴 | Traductions françaises complètes pour tous les widgets Today (~1960 lignes) | ✅ done |
| 🔴 | Préférence de langue dans settings (system/fr/en/es) + providers Riverpod | ✅ done |
| 🔴 | Fichiers iOS InfoPlist.strings pour en, fr, es | ✅ done |
| 🟠 | Rebranding "No Cocaine" → "NoCocaïne" dans configs plateforme | ✅ done |
| 🟠 | Nettoyage repo : suppression 100+ fichiers articles/SEO/specs du repo Flutter | ✅ done |
| 🟡 | Traductions anglaises complètes (en.dart) | 📋 todo |
| 🟡 | Traductions espagnoles complètes (es.dart) | 📋 todo |

### Tracker — Quantite precise & reduction des risques (2026-03-29)

> **Objectif** : Passer d'un suivi vague (peu/moyen/beaucoup) a un suivi precis (prises + grammes + mode) avec education contextuelle et detection d'escalade.

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Nombre de prises (1-5) + poids en grammes (0.5g-10g) remplacant peu/moyen/beaucoup | ✅ done |
| 🟠 | Mode de consommation (sniffe, fume, injecte, oral) + education contextuelle | ✅ done |
| 🟠 | Detection d'escalade + alerte rouge dans RecoveryInsights | ✅ done |
| 🟠 | Smart defaults : options non-utilisees derriere "+" apres 4+ entrees | ✅ done |
| 🟠 | Nettoyage champs heroine/opioides de TrackerEntry | ✅ done |
| 🟡 | Tester sur appareil les 3 selecteurs et le bouton "+" | 📋 todo |
| 🟡 | Graphique d'evolution du mode dans le dashboard | 📋 todo |
| 🟡 | Alerter le coach IA du mode injection pour adapter ses reponses | 📋 todo |

### Contenu educatif & site (2026-04-06)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Relier les 48 micro-lecons aux articles jarrettelacoke.fr (deepReadUrl) | ✅ done |
| 🟠 | Relier les 39 cartes de recentrage aux articles du site (siteArticleUrl) | ✅ done |
| 🟠 | Debloquer les 16 modules formations vers le contenu du site | ✅ done |
| 🟡 | Traduire les cartes de recentrage en francais | ✅ done |
| 🟠 | Migrer toutes les strings hardcodees vers Fr class (i18n complet) | ✅ done |
| 🟡 | Ajouter des cartes supplementaires basees sur les 87 articles /questions/ | 📋 todo |

### Content / SEO / Promotion (2026-03-26)

> **Objectif** : Clarifier et vendre la methode produit. Focus sur les mecanismes differenciants de l'app, pas seulement sur les symptomes ou la sobriete abstraite.

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Structurer le cluster "mecanismes de l'app" autour de "reintroduire du reel" | 🔄 in progress |
| 🟠 | Produire une page pilier de vente expliquant la methode Quit Coke sans jugement | ✅ done |
| 🟠 | Produire 6 pages/articles marketing sur les mecanismes produit (reel, tracking, preparation, cout reel, preuves de changement, autonomie progressive) | ✅ done |
| 🟡 | Passe editoriale finale sur le nouveau cluster marketing (angles, CTA, coherence de marque) | 📋 todo |
| 🟡 | Definir l'ordre de publication et le maillage entre articles symptomes et pages mecanismes | 📋 todo |
| 🟡 | Rediger metas SEO, OG et snippets sociaux pour les nouvelles pages | 📋 todo |
| 🟡 | Transformer la page pilier en vraie landing page marketing web | 📋 todo |
| 🟢 | Rediger une page concept sur "la prochaine bonne action" | 📋 todo |
| 🟢 | Rediger une page concept sur "friction honnete" | 📋 todo |
| 🟢 | Rediger une page concept sur "autonomie progressive" | 📋 todo |
| 🟢 | Explorer une version cluster / guide sur "sortir du tunnel" pendant un craving | 📋 todo |

### Backlog produit — concepts a explorer plus tard

> **Note** : Ces idees ne sont pas a implementer dans cette conversation. On les garde visibles pour un futur chantier produit.

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | Explorer un "sas de deceleration" avant l'enregistrement d'une consommation (attends 10 secondes, revenir aux cartes, appeler quelqu'un, continuer quand meme) | 💤 deferred |
| 🟢 | Explorer un pattern de "friction honnete" pour ralentir une action sensible sans hostilite ni impression de manipulation | 💤 deferred |
| 🟢 | Explorer une "derniere marche avant l'acte" comme ecran intermediaire avant une action a fort cout | 💤 deferred |
| 🟢 | Explorer un systeme de "memoire anti-oubli" qui remonte automatiquement le cout reel avant un moment fragile | 💤 deferred |
| 🟢 | Explorer des micro-messages "sortir du tunnel" dans le flow SOS | 💤 deferred |
| 🟢 | Explorer un mode "rendre le cout visible" (corps, sommeil, argent, lendemain, relations) dans les parcours de crise | 💤 deferred |

### Multi-flavor : cocaïne + héroïne (2 apps, 1 codebase)

> **Architecture** : Flutter flavors — 2 entry points, 2 build targets, 2 listings store, 1 codebase partagé.
> **PECAN** : uniquement pour héroïne (TSO = dossier solide). Cocaïne = B2C seul.
> **Cross-promo** : bandeau dans chaque app vers l'app sœur.

#### Étape 1-3 — Architecture multi-tenant (cœur du système)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Créer SubstanceConfig (classe abstraite — contrat par flavor) | ✅ done |
| 🔴 | Créer CocaineConfig (extraire valeurs existantes de constants.dart) | ✅ done |
| 🔴 | Créer HeroinConfig (config héroïne + badges + zones + curriculum) | ✅ done |
| 🔴 | Créer substanceConfigProvider (Riverpod, injectable au démarrage) | ✅ done |
| 🔴 | Créer main_cocaine.dart + main_heroin.dart (entry points) | ✅ done |
| 🔴 | Refactor app.dart (QuitCokeApp → QuitApp, lit config dynamiquement) | ✅ done |
| 🔴 | Refactor main.dart (backward compatible, utilise nouveau système) | ✅ done |

#### Étape 4 — Adapter les models

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | TrackerEntry : ajouter champs TSO optionnels (tsoType, tsoDoseMg, mode) | ✅ done |
| 🔴 | UserProfile : ajouter substance + tsoType + tsoDoseMg | ✅ done |
| 🟠 | Badge : extraire quitCokeBadges dans CocaineConfig | 📋 todo |
| 🟠 | Lesson : séparer schema (partagé) du contenu (par config) | 📋 todo |
| 🟠 | RecoveryZone : séparer schema du contenu (par config) | 📋 todo |

#### Étape 5-6 — Providers & Screens

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Refactor tous les providers : lire substanceConfigProvider au lieu d'AppConstants | 📋 todo |
| 🟠 | Screens : remplacer textes hardcodés par config.daysWithoutLabel etc. | 📋 todo |
| 🟠 | TrackerForm : afficher champs TSO si config.hasTSO | 📋 todo |

#### Notifications personnalisables & Cloud sync (2026-04-03)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Notifications personnalisables — heure check-in, mode custom, deep-link | ✅ done |
| 🟠 | Convex Auth — email/password provider, authTables, schema | ✅ done |
| 🟠 | Data sync — SyncService push/pull, userData Convex table, snapshot JSON | ✅ done |
| 🟠 | Auth UI — écran sign in/up, auth provider, account section | ✅ done |
| 🟡 | Configurer ConvexConfig.deploymentUrl en production | 📋 todo |
| 🟡 | Configurer AUTH_SECRET pour Convex Auth | 📋 todo |
| 🟡 | Tester flow auth complet sur device réel | 📋 todo |

#### Étape 7-8 — Localisation & Notifications

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Split fr.dart → fr_base.dart + fr_cocaine.dart + fr_heroin.dart | 📋 todo |
| 🟡 | NotificationService : channel ID dynamique via config | 📋 todo |

#### Étape 9 — Build flavors (Android + iOS)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Android build.gradle.kts : ajouter productFlavors cocaine + heroin | 📋 todo |
| 🟠 | iOS : créer schemes QuitCoke + QuitHero avec Bundle IDs distincts | 📋 todo |
| 🟡 | Assets par flavor (icônes, splash) | 📋 todo |

#### Étape 10 — Contenu héroïne

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Écrire curriculum héroïne complet (~50 leçons, ~1500 lignes) | 📋 todo |
| 🟡 | CrossPromoCard widget (bandeau vers l'app sœur) | 📋 todo |

### Produit / SOS / Feedback

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Ajouter une carte feedback dans le deck SOS et un point d'entrée settings (texte local + audio local) | ✅ done |
| 🟠 | Refaire visuellement le deck SOS outils en vraies cartes Tinder / jeu, swipe-only, avec stack visible | ✅ done |
| 🟠 | Intégrer le bloc phase/timeline dans le SOS sans drawer séparé, avec actions rondes en haut et détail inline | ✅ done |
| 🟠 | Améliorer la lisibilité mobile de la barre dopamine compacte (textes, pourcentages, hauteurs de barres) | ✅ done |
| 🟠 | Deck SOS : retirer le compteur de cartes, reboucler en continu et empêcher le panneau détail de déborder de la carte sur mobile | ✅ done |
| 🟠 | Stabiliser et tester sur appareil le flow SOS swipeable (deck sans onglets, timeline inline, sorties, enregistrement, cartes custom, rendu Tinder) | 🔄 in progress |
| 🟠 | Faire évoluer le feedback app vers un vrai flux admin serveur (texte + audio uploadés, allowlist email, vue de lecture interne) | ✅ done |
| 🟠 | Redéployer le frontend Flutter/web pour activer en live le nouveau flux feedback admin et son écran interne | 📋 todo |
| 🟠 | Tester sur vrai appareil les permissions micro et la qualité du feedback vocal | 📋 todo |
| 🟠 | Ajouter un journal de regrets post-consommation / post-descente (texte + vocal) avec cartes de rappel dans le SOS | ✅ done |
| 🟠 | Faire évoluer le projet financier unique vers plusieurs projets de vie réutilisables dans le SOS | ✅ done |
| 🟠 | Tester sur vrai appareil la lecture des regrets vocaux dans le SOS et vérifier que l'effet est utile plutôt que culpabilisant | 📋 todo |

---

## quit-hero (Héroïne & Opiacés)

**Stack**: Astro 6, Vue 3, Clerk, Polar, RevenueCat, TypeScript (fork jarrettelacoke.fr) | **Phase**: Content done, SEO audited, ready to deploy

**Top priority**: Acheter domaine + deploy Vercel + configurer Clerk/Polar

### Fondation projet

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Fork jarrettelacoke.fr → quit-hero (nouveau repo, git init) | ✅ done |
| ✅ | Adapter package.json, CLAUDE.md, astro.config.mjs (jarrettelacoke.fr → quit-hero) | ✅ done |
| ✅ | Adapter toutes les pages .astro (cocaïne → opiacés, 26 fichiers) | ✅ done |
| ✅ | Adapter tous les composants Vue/Astro (24 fichiers, localStorage keys, brand) | ✅ done |
| ✅ | Adapter navigation (9 sidebars dont nouveau traitement.js) | ✅ done |
| ✅ | Adapter config/lib (auth, emails, gamification, parcours) | ✅ done |
| ✅ | Écrire section "Traitement" — 8 articles, 2 493 lignes (méthadone, Subutex, naloxone, TSO) | ✅ done |
| ✅ | Écrire section "Comprendre" — 8 articles, 1 646 lignes (neurobiologie, stats FR, entourage) | ✅ done |
| ✅ | Écrire section "Sevrage" — 9 articles, 2 518 lignes (timeline, symptômes, sevrage méthadone/Subutex) | ✅ done |
| ✅ | Écrire section "Prévention" — 10 articles, 1 097 lignes (naloxone urgence, RdR, CSAPA) | ✅ done |
| ✅ | Écrire section "Reconstruction" — 8 articles, 1 228 lignes (réinsertion, santé physique, hépatite C) | ✅ done |
| ✅ | Audit SEO complet — note A- (29 issues fixed across 35 files) | ✅ done |
| ✅ | Astro check : 0 errors, 0 warnings | ✅ done |
| ✅ | Zéro référence ancien branding restante dans le code | ✅ done |
| 🔴 | Acheter domaines (sevrage-opiaces.fr, quit-hero.com) | 📋 todo |
| 🔴 | Deploy Vercel (git push + connect project) | 📋 todo |
| 🔴 | Configurer env vars Vercel (Clerk, Polar, RevenueCat) | 📋 todo |
| 🔴 | Créer produits Polar (mensuel 9.99€, annuel 79.99€) | 📋 todo |
| 🟠 | Google Search Console + soumettre sitemap | 📋 todo |
| 🟠 | Remplir placeholders mentions-légales (société, SIRET) | 📋 todo |
| ✅ | Écrire section formations/ — 19 fichiers, 18 modules premium avec exercices | ✅ done |
| ✅ | Écrire 8 articles institutionnels (CSAPA, ALD 23, MILDECA, droits sociaux, plan national) | ✅ done |
| ✅ | Audit SEO (A-) + Audit Copy (A-) — accents corrigés, 200+ fixes | ✅ done |
| 🟡 | Composant DoseTracker.vue dédié (tracker dosage TSO spécifique) | 📋 todo |
| 🟡 | Composant NaloxoneGuide.vue (guide interactif) | 📋 todo |
| 🟡 | Ajouter accents dans les articles comprendre/ (corps du texte) | 📋 todo |

### PECAN — Préparation pré-consultant (CE QU'ON FAIT MAINTENANT)

> **Objectif** : Faire 80% du travail de fond avant d'engager un consultant (économie : 10-20 jours = €8K-30K)
> **Docs de référence** : `REGLEMENTATION-PECAN.md` + `docs/reglementaire/`

#### Phase 0A — Recherche & Référence (Semaine 1) ✅ EN COURS

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Créer REGLEMENTATION-PECAN.md (guide complet 600+ lignes) | ✅ done |
| 🔴 | Créer arborescence docs/reglementaire/ (10 dossiers) | ✅ done |
| 🔴 | Créer README.md documentation réglementaire | ✅ done |
| 🟠 | Télécharger référentiel interopérabilité ANS v1.2.2 (PDF) | ✅ done |
| 🟠 | Télécharger guide dépôt PECAN HAS (57 pages PDF) | ✅ done |
| 🟠 | Télécharger MDCG 2019-11 + rev1 2025 (qualification logiciel, Commission EU) | ✅ done |
| 🟠 | Télécharger recommandations cybersécurité ANSM (PDF) | ✅ done |
| 🟠 | Télécharger arrêté 22 avril 2024 tarifs PECAN (PDF) | ✅ done |
| 🟠 | Télécharger schéma décisionnel DMN v6 + matrice périmètre (Excel ANS) | 📋 todo |
| 🟡 | Étudier DMN ayant obtenu/demandé PECAN (Moovcare seul remboursé, Deprexis refusé) | ✅ done |
| 🟡 | Contacter G_NIUS pour rendez-vous d'orientation (gratuit) | 📋 todo |
| 🟡 | Contacter Bpifrance pour Diag Dispositif Médical (50% financé) | 📋 todo |

#### Phase 0B — Qualification & Classification (Semaine 2)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Remplir schéma décisionnel MDCG 2019-11 (→ l'app est un DM) | ✅ done |
| 🔴 | Rédiger justification classification Règle 11 (→ Classe IIa) | ✅ done |
| 🟠 | Remplir matrice analyse périmètre ANS (Excel) | 📋 todo |
| 🟠 | Définir périmètre DM (fonctionnalités IN vs OUT) | 📋 todo |

#### Phase 0C — Utilisation Prévue & Risques (Semaine 3-4)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Rédiger Intended Use (le doc le plus critique — détermine tout) | ✅ done |
| 🔴 | Rédiger analyse de risques ISO 14971 (17 risques identifiés) | ✅ done |
| 🟠 | Rédiger indications thérapeutiques | 📋 todo |
| 🟠 | Rédiger contre-indications et limitations | 📋 todo |
| 🟠 | Rédiger profil population cible (171K sous TSO) | 📋 todo |
| 🟠 | Rédiger profils utilisateurs (patient, pro santé) | 📋 todo |
| 🟠 | Rédiger mesures de maîtrise des risques | 📋 todo |
| 🟡 | Évaluation bénéfice/risque globale | 📋 todo |

#### Phase 0D — Cycle de vie logiciel & Architecture (Semaine 5-6)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Documenter architecture logicielle (stack, composants, SOUP) | ✅ done |
| 🟠 | Rédiger plan de développement logiciel (IEC 62304) | 📋 todo |
| 🟠 | Documenter gestion de configuration (Git workflow) | 📋 todo |
| 🟠 | Rédiger exigences logicielles (fonctionnelles + sécurité) | 📋 todo |
| 🟡 | Plan de vérification et validation | 📋 todo |
| 🟡 | Plan de maintenance logicielle | 📋 todo |

#### Phase 0E — RGPD & Cybersécurité (Semaine 7-8)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Créer registre des traitements RGPD (Art. 30) — 6 traitements identifiés | ✅ done |
| 🔴 | Rédiger AIPD (obligatoire pour données de santé) | 📋 todo |
| 🟠 | Analyser base légale par traitement de données | 📋 todo |
| 🟠 | Rédiger analyse de menaces cybersécurité | 📋 todo |
| 🟠 | Documenter mesures de sécurité implémentées | 📋 todo |
| 🟠 | Rechercher et comparer hébergeurs HDS (OVH, Scaleway, Clever Cloud) — comparatif fait | ✅ done |
| 🟡 | Plan de réponse aux incidents | 📋 todo |
| 🟡 | Checklist conformité HDS | 📋 todo |

#### Phase 0F — Évaluation clinique préliminaire (Semaine 9-10)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Revue de littérature : apps d'addiction + opiacés (reSET-O, ACHESS, etc.) | 📋 todo |
| 🟠 | Rédiger plan d'évaluation clinique | 📋 todo |
| 🟠 | Définir endpoints primaires et secondaires | 📋 todo |
| 🟡 | Draft protocole d'étude (RCT : app+TSO vs TSO seul) | 📋 todo |
| 🟡 | Identifier 2-3 CSAPA potentiels pour partenariat | 📋 todo |

#### Phase 0G — Pré-soumission PECAN (Semaine 11-12)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Rédiger argumentaire d'innovation (zéro DMN comparable en addictologie) | 📋 todo |
| 🟠 | Rédiger argumentaire médico-économique (coût actuel vs avec app) | 📋 todo |
| 🟠 | Compléter checklist pré-soumission ANS + HAS | 📋 todo |
| 🟡 | Contacter Organismes Notifiés pour devis (GMED, LNE, BSI, TÜV) | 📋 todo |
| 🟡 | **MILESTONE : Prêt à engager un consultant avec 80% du travail fait** | 📋 todo |

---

### PECAN — Dossier remboursement Sécu (€780/an/patient) — AVEC CONSULTANT

> **Objectif** : Obtenir le statut PECAN pour que l'app soit prescrite par les médecins et remboursée par l'Assurance Maladie.
> **Potentiel** : 500 patients = €390K/an · 5000 patients = €3.9M/an
> **Timeline estimée** : 24-30 mois total (dont 3 mois de Phase 0 déjà faite)

#### Phase 1 — Pré-requis réglementaires (Mois 1-6)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Créer structure juridique (SAS ou SASU) — nécessaire pour exploitant DMN | 📋 todo |
| 🔴 | Engager un consultant réglementaire DM / DTx (affaires réglementaires) | 📋 todo |
| 🔴 | Classifier l'app comme Dispositif Médical Numérique (classe I ou IIa) | 📋 todo |
| 🔴 | Rédiger dossier technique (documentation technique DM selon MDR 2017/745) | 📋 todo |
| 🔴 | Obtenir marquage CE — obligatoire pour PECAN | 📋 todo |
| 🟠 | Choisir hébergeur certifié HDS (Hébergement Données de Santé) — OVH, Scaleway, Azure | 📋 todo |
| 🟠 | Migrer données patient vers hébergement HDS | 📋 todo |
| 🟠 | Implémenter conformité RGPD renforcée (données de santé = sensibles) | 📋 todo |
| 🟠 | Documenter interopérabilité (standards CI-SIS, FHIR) | 📋 todo |

#### Phase 2 — Étude clinique (Mois 3-12, en parallèle)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Définir protocole d'étude clinique (efficacité du tracker TSO sur réduction dosage) | 📋 todo |
| 🔴 | Contacter 2-3 CSAPA partenaires pour l'étude (recrutement patients) | 📋 todo |
| 🔴 | Soumettre protocole au CPP (Comité de Protection des Personnes) | 📋 todo |
| 🟠 | Enregistrer l'étude sur ClinicalTrials.gov ou RIPH | 📋 todo |
| 🟠 | Recruter 50-100 patients sous TSO pour l'étude (objectif minimum) | 📋 todo |
| 🟠 | Recueillir données sur 6-12 mois (adherence, réduction dose, bien-être) | 📋 todo |
| 🟡 | Rédiger publication scientifique (résultats préliminaires) | 💤 deferred |

#### Phase 3 — Dépôt dossier PECAN (Mois 10-14)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Déposer dossier technique sur plateforme ANS Convergence | 📋 todo |
| 🔴 | Déposer dossier clinique sur plateforme HAS Sésame/Evatech | 📋 todo |
| 🔴 | Démontrer présomption d'innovation (CNEDiMTS) | 📋 todo |
| 🟠 | Préparer argumentaire médico-économique (coût TSO actuel vs avec app) | 📋 todo |
| 🟠 | Obtenir lettres de soutien de CSAPA / addictologues / Fédération Addiction | 📋 todo |
| 🟡 | Répondre aux questions complémentaires ANS/HAS | 📋 todo |

#### Phase 4 — Post-approbation PECAN (Mois 14-18)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Négocier tarif définitif avec le CEPS (dans les 6 mois post-PECAN) | 📋 todo |
| 🟠 | Déposer demande inscription LPPR (remboursement permanent) | 📋 todo |
| 🟠 | Former les CSAPA partenaires à la prescription de l'app | 📋 todo |
| 🟠 | Mettre en place facturation Assurance Maladie (circuit Sécu) | 📋 todo |
| 🟡 | Scaler : démarcher les 400+ CSAPA de France | 📋 todo |
| 🟡 | Pitcher les mutuelles complémentaires (40% du remboursement) | 📋 todo |

### Partenariats & Growth

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Contacter Fédération Addiction (900 structures adhérentes) | 📋 todo |
| 🟠 | Contacter OFDT pour visibilité / données | 📋 todo |
| 🟠 | Contacter Drogues Info Service pour référencement | 📋 todo |
| 🟡 | Contenu YouTube (neuroscience méthadone, témoignages) | 💤 deferred |
| 🟡 | Contenu TikTok (mythbusting opiacés) | 💤 deferred |
| 🟡 | Version anglaise (marché US : 2M+ sous MAT) | 💤 deferred |

### Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | App mobile iOS/Android (RevenueCat) | 💤 deferred |
| 🟢 | Coach IA spécialisé opiacés (Claude API) | 💤 deferred |
| 🟢 | Communauté anonyme (mur + groupes) | 💤 deferred |
| 🟢 | Export PDF pour médecin (données tracker) | 💤 deferred |
| 🟢 | Intégration Mon Espace Santé (DMP) | 💤 deferred |

---

## ContentFlow Lab (FastAPI Backend + AI Agents)

**Stack**: Python FastAPI, CrewAI, PydanticAI, DataForSEO, Firecrawl, Exa | **Phase**: Production hardening + AI runtime V1

**Top priority**: Complete the dual-mode AI runtime implementation; keep feedback Bunny/audio validation as non-blocking follow-up

| Pri | Task | Status |
|-----|------|--------|
| ✅ | P0.2 — Rename fake agents to deterministic pipelines | ✅ done |
| ✅ | P0.3 — Remove hollow SEO tools, wire KeywordIntegrator to DataForSEO | ✅ done |
| ✅ | P0.4 — Wire Firecrawl + Exa as shared CrewAI tools | ✅ done |
| ✅ | P0.1 — Externalize all agent prompts to YAML (17 files, prompt_loader helper) | ✅ done |
| ✅ | P1.1 — Fuse 6 separate SEO Crews into one multi-agent Crew (Process.sequential) | ✅ done |
| ✅ | P1.2 — Enable allow_delegation=True on Editor, Strategy, Audience Analyst | ✅ done |
| ✅ | P1.3 — Replace str(output) with Pydantic schemas between agent stages | ✅ done |
| ✅ | Publish FastAPI backend on `api.winflowz.com` with Caddy + PM2 | ✅ done |
| ✅ | Restore Turso production connectivity and DB-backed health checks with maintained `libsql` driver | ✅ done |
| ✅ | Centraliser le lifecycle state persistant dans Turso et retirer `status.db` local comme source de vérité | ✅ done |
| ✅ | Structurer l'audit des actions (`actor_type/id/label`) pour transitions, edits et reviews | ✅ done |
| ✅ | Aligner la sélection du projet courant entre FastAPI et Flutter via `settings.defaultProjectId` comme "dernier projet ouvert" | ✅ done |
| ✅ | Exposer un vrai `POST /api/projects` et permettre l'édition `github_url` sur `PATCH /api/projects/{id}` pour la gestion multi-projets Flutter | ✅ done |
| ✅ | Ajouter des endpoints d'intégration GitHub pour piloter les pickers (projets + dossiers) côté Flutter onboarding / Drip / templates | ✅ done |
| 🔴 | Project flows selection onboarding archive — optional source URL, explicit no-selection, tri-state active project, archive/unarchive lifecycle | ✅ done |
| 🟠 | Backend persona autofill + repo understanding + user keys | ✅ done |
| 🔴 | Dual-mode AI runtime (BYOK + platform) all providers — implémenter `SPEC-dual-mode-ai-runtime-all-providers.md` | 🔄 in progress |
| 🟠 | Unified Project Asset Library — backend/client/editor asset picker slice verified; Image/Video/Audio integrations remain future work | 🔄 in progress |
| 🟠 | AI Asset Understanding Auto Tagging — understanding jobs + moderation tags + recommandations cross-project avec attribution/rights warnings (`SPEC-ai-asset-understanding-auto-tagging-2026-05-13.md`) | ✅ done |
| 🟠 | P2.1 — Add Evaluator agent with feedback loop (max 2 iterations) | 📋 todo |
| 🟡 | P2.2 — Convert Scheduler + Images pipelines to real AI agents | 📋 todo |
| 🟢 | P2.3 — Evaluate LangGraph for conditional orchestration | 💤 deferred |

### Audit: Code (2026-04-28)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Require an owned `content_record_id` for `POST /api/publish` so authenticated callers cannot publish arbitrary text outside the ContentFlow review/status lifecycle | ✅ done |
| ✅ | Decision: keep one shared Zernio API key for all connected publish accounts for now; publishing is provider-wide, not per-user tenant-isolated | ✅ done |
| ✅ | Implement `ProjectPublishAccount` (or equivalent) so each Zernio `account_id` is explicitly authorized for `userId + projectId` before `/api/publish` calls Zernio | ✅ done |
| ✅ | Add product/operator guardrails for the shared Zernio model: do not present it as tenant-isolated until project-level account scoping is implemented | ✅ done |
| ✅ | Add route regressions for project-scoped accounts, forged account refusal before provider call, local disconnect, connect state, scheduled, published and partial publish results | ✅ done |
| 🟡 | Run manual Zernio smoke with real `ZERNIO_API_KEY`, two projects, one connected social account, publish success, forged account `403`, and provider error recovery before prod rollout | 📋 todo |
| 🟡 | Modernize deprecated Pydantic v1 validators and FastAPI `regex=` query parameters surfaced by the publish-router test run | 📋 todo |

### Audit: Code (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Bound anonymous feedback audio uploads with signed max-bytes limits and request size enforcement | ✅ done |
| ✅ | Harden GitHub OAuth state consumption against replay race conditions (`UPDATE ... RETURNING` + locked fallback) | ✅ done |
| ✅ | Cap in-memory rate-limiter active client tracking to prevent unbounded growth under broad IP churn | ✅ done |
| ✅ | Enforce `USER_SECRETS_MASTER_KEY` on GitHub integration store operations and run startup rotation for legacy plaintext tokens | ✅ done |
| 🟠 | Roll out `USER_SECRETS_MASTER_KEY` in all deployed environments so GitHub integration endpoints remain available in production | 📋 todo |
| 🟡 | Add anti-automation controls for anonymous feedback upload URL issuance (captcha/challenge or stricter route-specific quotas) | 📋 todo |

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Pin backend dependencies with lockfiles (`requirements.lock`, `requirements-dev.lock`) and route production installs through the production lock | ✅ done |
| ✅ | Complete the existing `pydantic-ai` major-line migration; full local pytest and `pip-audit` are clean after moving to `pydantic-ai>=1.56.0,<2.0` | ✅ done |
| ✅ | Document isolated-runtime strategy for excluded STORM/Reels integrations (`knowledge-storm`, `instagrapi`) if those flows remain product-critical | ✅ done |
| ✅ | Resolve the default `crewai`/`litellm` resolver conflict without lowering the LiteLLM security floor | ✅ done |
| ✅ | Establish project-scoped license inventory and review unknown license metadata for `libsql` | ✅ done |


---

## ContentFlow App (Flutter)

**Stack**: Flutter 3.41, Riverpod, GoRouter, Dio, flutter_card_swiper | **Phase**: Phase 11 — Offline sync V2 shipped

**Top priority**: Continue design-token centralization, then complete the secondary i18n pass

> **Concept** : Content approval pipeline — l'IA génère du contenu (articles, social, newsletters, vidéo scripts, reels), l'utilisateur swipe pour publier (Instagram-like UX).
> **Backend** : Python FastAPI existant (19 agents CrewAI/PydanticAI) à `/home/claude/contentflow_lab/`

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Scaffold Flutter (web + Android), clean architecture, Riverpod, GoRouter | ✅ done |
| ✅ | Feed swipeable (droite=publish, gauche=skip, haut=edit) + content cards | ✅ done |
| ✅ | Editor (markdown preview + inline edit), History, Settings, Calendar | ✅ done |
| ✅ | Onboarding 3 pages (projet GitHub, types contenu + fréquence, résumé) | ✅ done |
| ✅ | Weekly Ritual screen (psychology engine input → narrative synthesis) | ✅ done |
| ✅ | Persona list + editor (demographics, pain points, goals) | ✅ done |
| ✅ | Content Angles screen (AI-generated, sélection, trigger generation) | ✅ done |
| ✅ | API service branché sur /api/status/content, /api/psychology/* avec mock fallback | ✅ done |
| ✅ | Vérifier endpoints FastAPI + ContentItem mapping + test_server.py E2E | ✅ done |
| ✅ | Skeleton loaders, first-launch onboarding redirect, body versioning | ✅ done |
| ✅ | Intégration Zernio/LATE API (publication multi-plateforme) — backend + Flutter | ✅ done |
| ✅ | Persona language model editor (vocabulary, objections) | ✅ done |
| ✅ | Scheduling datetime picker + section "Ready to Schedule" | ✅ done |
| ✅ | GitHub Actions workflow build APK + Web | ✅ done |
| ✅ | Retirer les artefacts Flutter web `contentflow_app/build` du suivi Git et laisser Vercel reconstruire `build/web` | ✅ done |
| 🟠 | Finish Android APK CI setup: enable Blacksmith app on the repo, add `CLERK_PUBLISHABLE_KEY`, trigger the first run, download/install the APK, and verify logs via CLI | 📋 todo |
| ✅ | Angles — vraie persona picker + contexte narratif du ritual | ✅ done |
| ✅ | Content update — feedback UI (retour bool, snackbar erreur) | ✅ done |
| ✅ | Personas refresh après save (ref.invalidate) | ✅ done |
| ✅ | Ritual → lastNarrativeProvider persisté entre écrans | ✅ done |
| ✅ | Mapper vrais accountId Zernio dans Settings | ✅ done |
| ✅ | Settings channels — état connecté/non connecté depuis /api/publish/accounts | ✅ done |
| ✅ | Approve → publish — messages de succès/erreur alignés sur le résultat réel | ✅ done |
| ✅ | Contrat schedule aligné (PATCH Flutter ↔ FastAPI) | ✅ done |
| ✅ | Spec architecture cible Astro + Flutter + FastAPI + Clerk | ✅ done |
| ✅ | FastAPI auth Clerk foundation + /api/me + /api/bootstrap | ✅ done |
| ✅ | Projects router — remplacement de default-user + ownership checks | ✅ done |
| ✅ | Migrer settings / creator-profile / personas dans FastAPI | ✅ done |
| ✅ | Content ownership backend — routes status/content filtrées par projets possédés | ✅ done |
| ✅ | Flutter auth abstraction — session/token provider + interceptor Dio | ✅ done |
| ✅ | Flutter bootstrap réel — gate d'entrée branché sur session + `/api/bootstrap` | ✅ done |
| ✅ | Démo onboarding figée — repo public prérempli + données lecture seule pour tous les visiteurs | ✅ done |
| ✅ | Clerk UI Flutter/Web — écran login/signup headless + récupération bearer token | ✅ done |
| ✅ | Auth Clerk réelle — remplacement du faux état local par restauration session Clerk | ✅ done |
| ✅ | Flutter branché sur `/api/settings`, `/api/personas`, `/api/creator-profile` | ✅ done |
| ✅ | Onboarding réel — création workspace via FastAPI | ✅ done |
| ✅ | Gestion centralisée des `401` + suppression des fallbacks mock privés | ✅ done |
| ✅ | Phase 5 — Unified Content Pipeline (SEO, short, social agents + scheduler + idea pool) | ✅ done |
| ✅ | Phase 6 — DataForSEO Integration (client, provider, 4 niveaux ingestion, 3 gaps bouchés) | ✅ done |
| 🟠 | Configurer credentials DataForSEO en prod (Doppler) | 📋 todo |
| ✅ | Remplacer le form auth maison par l'UI Clerk officielle + afficher un vrai diagnostic si le SDK bloque au chargement | ✅ done |
| ✅ | Externaliser l'auth web vers ContentFlow Site + handoff sécurisé vers Flutter web via FastAPI | ✅ done |
| ✅ | Vérifier runtime Clerk réel — clé publishable, login, bootstrap, persistance session | ✅ done |
| ✅ | Remplacer l'auth web Flutter beta par ClerkJS officiel sur le domaine app (`/sign-in`, `/sso-callback`, Google direct) | ✅ done |
| ✅ | Corriger le callback OAuth Clerk web pour finaliser la session sur `/sso-callback` avant de revenir vers `/#/entry` | ✅ done |
| ✅ | Empêcher l'onboarding workspace quand aucune session Clerk valide n'est présente | ✅ done |
| ✅ | Distinguer session Clerk, disponibilité FastAPI et bootstrap workspace avec un état d'accès central + mode dégradé | ✅ done |
| ✅ | Rendre les pannes backend visibles dans l'UI (entry diagnostics, shell dégradé, uptime/settings) au lieu de faux messages de reconnexion | ✅ done |
| ✅ | Empêcher les redirections vers `/entry` pendant les vérifications de session en arrière-plan (retour d'onglet) | ✅ done |
| 🔴 | Stabiliser la reprise mobile/web sans mouvement d'UI: aucun jump vers `/entry` ni reroutage visible lors du retour d'app (checks uniquement en arrière-plan) | ✅ done |
| ✅ | Afficher clairement l'état de session dans Settings (email connecté + bouton logout) pour éviter l'ambiguïté sur l'auth active | ✅ done |
| ✅ | Feedback Admin v1 côté Flutter — soumission texte/audio, historique local léger, écran admin in-app, accès anonyme depuis l'entry screen | ✅ done |
| ✅ | Localisation app EN/FR — préférence de langue (système/anglais/français) + couverture FR sur les écrans shell, debug et drip | ✅ done |
| ✅ | Système de thème complet — light/dark/system persisté, réglage utilisateur et palette éditoriale partagée | ✅ done |
| ✅ | Purger les couleurs hard-codées des écrans Flutter pour rendre le mode clair réellement cohérent | ✅ done |
| 🟠 | Implémenter `SPEC-content-editor-multiformat` (toolbar riche universelle Markdown-backed + tests) | 🔄 in progress |
| 🟡 | Finaliser les vérifications feedback restantes: stockage audio S3-compatible, URLs signées de lecture admin et validation admin connectée | 📋 todo |
| ✅ | OAuth flow channels via Zernio | ✅ done |
| ✅ | Landing page produit (Astro) | ✅ done |

| 🟠 | Stripe Billing (auth Clerk stabilisée, reste le branchement checkout) | 📋 todo |
| ✅ | Mobile UX audit — bottom nav redesign (5-tab + More sheet), responsive typography, touch targets, layout fixes | ✅ done |
| ✅ | Rebrand `ContentFlowz` → `ContentFlow` dans l'app Flutter, package Android, manifests web, scripts et docs | ✅ done |
| ✅ | Gestion multi-projets alignée sur le backend réel : écran `Projects`, switcher global, dernier projet ouvert persisté via settings | ✅ done |
| 🔴 | Project flows selection onboarding archive — source URL optionnelle, no-selection explicite persistante, actions archive/unarchive cohérentes | ✅ done |
| ✅ | Fiche projet enrichie avec la config repo détectée (framework, dossiers de contenu, sources configurées) et retrait des actions archive/unarchive non supportées | ✅ done |
| ✅ | Ajouter un accès direct au rituel dans le menu mobile "More" pour augmenter la fréquence de remplissage | ✅ done |
| 🔴 | Publier les plans Drip avec heure aléatoire dans une plage horaire (plage début/fin par plan) | ✅ done |
| ✅ | Clarifier l’étape 3 du wizard Drip (explications détaillées clustering: dossier, tags frontmatter, auto, aucun + rôle de “pillars” et “satellites”) | ✅ done |
| ✅ | Ajouter un sélecteur de dossier source Drip depuis le projet actif (réutilisation `content_directories`) pour éviter la saisie manuelle | ✅ done |
| ✅ | Clarifier l’étape 4 du wizard Drip (méthode de contrôle, publication, option “draft flag”, mode sécurisé GSC, rebuild manuel/automatique et randomisation d’horaire dans une plage) | ✅ done |
| ✅ | Ajouter la gestion de clé OpenRouter dans Settings (lecture/enregistrement/validation/suppression) | ✅ done |
| 🟡 | Firebase push, error handling polish | 🔄 in progress — couche de diagnostics centralisée + copie d'erreurs/logs déployée; push mobile reste à brancher |
| 🟠 | Ajouter une vraie section compte dans Settings (lien gestion Clerk / mot de passe / providers connectés) au lieu d'un simple état de session | 📋 todo |
| 🟠 | Passe i18n complémentaire sur les écrans secondaires encore partiellement en anglais | 🔄 in progress |
| ✅ | Reconnect the Vercel `contentflow_app` project to `diane-defores/contentflow` and verify the current or next `main` SHA deploys the Flutter web app | ✅ done |
| 🟢 | App Store, offline mode, image preview, teleprompter | 💤 deferred |
| ✅ | Mode offline maintenu : accès shell authentifié conservé quand FastAPI est indisponible | ✅ done |
| ✅ | Cache persistant + état stale + replay queue local pour mutations sûres | ✅ done |
| ✅ | Réconciliation `tempId -> realId` et orchestration de dépendances de queue | ✅ done |
| ✅ | Badges de sync et visibilité des états (pending/retrying/paused/dependency/failed) | ✅ done |
| 🟡 | 🔍 Analyser SEOJuice comme concurrent/complément — automatisation SEO + GEO pour le pipeline contenu — source: https://seojuice.com/ (veille 2026-04-04) | 📋 todo |
| 🟡 | 📝 Contenu : intégrer insights GEO (AI Search Optimization) dans les rapports ContentFlow — source: https://seojuice.com/ (veille 2026-04-04) | 📋 todo |
| 🟡 | 🏗️ Étudier intégration SEOJuice API/snippet pour optimisation SEO automatique du contenu généré — source: https://seojuice.com/ (veille 2026-04-04) | 📋 todo |
| 🟡 | 🏗️ Soumettre ContentFlow sur AI Tools Directory comme canal de distribution — source: https://aitoolsdirectory.com/ (veille 2026-04-04) | 📋 todo |
| 🟡 | 🏗️ Étudier patterns agents autonomes DoAnything (sous-agents, self-reflection, smart pacing) pour CrewAI — source: https://www.doanything.com/ (veille 2026-04-04) | 📋 todo |

### Privacy Capture Roadmap

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Run readiness gates for Android, Web, and Windows privacy capture specs before implementation | 📋 todo |
| ✅ | Create a shared cross-platform privacy capture contract for metadata, review states, temp-file rules, disclosure copy, and backend-safe payloads | ✅ done |
| ✅ | Specify the post-production review flow for privacy captures: preview, manual correction, review acknowledgement, flattened export, and share gating | ✅ done |
| ✅ | Explore macOS privacy capture feasibility with ScreenCaptureKit, Vision, Core Image/Metal, and AVAssetWriter | ✅ done |
| ✅ | Create a cross-platform QA matrix for privacy capture: scroll, OCR misses, photos/faces, protected content, temp files, export, and browser/OS/device coverage | ✅ done |
| 🟡 | Draft legal/UX copy for best-effort disclosure and review acknowledgement, then route to legal/product review before hard-coding | 📋 todo |
| 🟡 | Decide implementation order after readiness: likely Android screenshot/privacy metadata first, then Android recording, then Web MVP, then Windows | 📋 todo |
| 🟢 | Keep iOS and Linux as exploration-only until product priority or customer demand justifies specs | 💤 deferred |

### Audit: Code (2026-04-28)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Replace web-auth diagnostic `innerHTML` rendering with text-node construction on `/sign-in`, `/sign-up`, and `/sso-callback` | ✅ done |
| ✅ | Make `ApiService.publishContent` require `contentRecordId` to match the backend publish authorization contract | ✅ done |
| ✅ | Move publishing account selection to the active project: Settings binds Zernio accounts to `userId + projectId`, not a global platform list | ✅ done |
| 🟠 | Add a browser regression test that loads `/sso-callback?redirect_url=<img...>` and asserts diagnostics render as text, not HTML | 📋 todo |
| 🟡 | Add a Flutter unit test around `publishContent` payload construction with required `contentRecordId` | 📋 todo |

### Audit: Code (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Remove `FEEDBACK_ADMIN_EMAILS` from Flutter web build defines to avoid exposing admin allowlist identities in client bundles | ✅ done |
| ✅ | Switch feedback-admin UI visibility to authenticated-session discovery while keeping backend `403` as the authorization source of truth | ✅ done |
| ✅ | Add backend capability probe-driven feedback-admin visibility (`/api/feedback/admin/capability`) to avoid optimistic UI exposure for non-admin users | ✅ done |
| 🟡 | Add CI checks for `flutter analyze` plus targeted auth/offline regression tests | 📋 todo |

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Plan and execute major upgrades for core packages (`flutter_riverpod`, `go_router`, `google_fonts`, `riverpod_annotation`, `riverpod_generator`) with regression matrix | ✅ done |
| 🟠 | Replace or mitigate discontinued transitive build packages (`build_resolvers`, `build_runner_core`) by upgrading the generator stack | ✅ done |
| 🟡 | Remove or justify likely unused dependencies (`cached_network_image`, `responsive_framework`, `cupertino_icons`, annotations if codegen stays unused) | 📋 todo |
| ✅ | Add dependency update automation baseline (`.github/dependabot.yml` for pub + GitHub Actions) | ✅ done |
| ✅ | Pin Flutter toolchain version (`.fvmrc` -> 3.41.7) for reproducible dependency resolution | ✅ done |
| ✅ | Bring active ShipGlows app documentation metadata and technical governance into lint compliance | ✅ done |

### Audit: Design (2026-04-21 — Feed mobile page — Overall: C→B)

| Pri | Task | Domain |
|-----|------|--------|
| ✅ | Remplacer les cartes vides du feed par une composition responsive mobile-first (CTA empilés, cartes pleine largeur, stats sans débordement) | Design |
| 🟠 | Valider sur vrai appareil le header mobile du feed avec `ProjectPickerAction` lorsque le nom du projet est très long et qu’un bulk action est présent | Design |
| 🟡 | Revoir plus tard la version mobile du feed “avec cartes à swiper” pour confirmer que la zone d’actions basse ne gêne pas les petits écrans 320–360px | Design |

### Audit: Design Tokens (2026-05-10)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Éliminer les valeurs littérales restantes hors design tokens sur le périmètre Flutter prioritaire (scan: 128 findings sur `app_theme.dart`, `app_shell.dart`, `entry`, `feed`, `settings`, `auth`) | 🔄 in progress |
| 🟠 | Supprimer les couleurs directes restantes dans `app_theme.dart` (`const Color(...)` et variantes alpha) en dérivant depuis `AppThemeTokens`/`ColorScheme` | 📋 todo |
| 🟠 | Stabiliser l’échelle typographique et spacing mobile (ratios incohérents entre `text*` et `spacing*`) avec une règle unique documentée | 📋 todo |

### Audit: Copywriting (2026-05-10 — App entry homepage — Overall: C+)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Repositionner `/entry` comme page de reprise/récupération pour utilisateurs existants et réserver la promesse produit complète aux pages onboarding/feed où la valeur est visible | ✅ done |
| 🟠 | Aligner les claims amont du site (`swipe to publish`, `6x more content`, `0 platforms to manage`, automatisation) avec les limites réelles app: human review, publish externe partiel, mode dégradé borné | ✅ done |
| 🟡 | Ajouter un CTA alternatif plus léger et rassurant depuis l’entry/sign-in pour les nouveaux visiteurs: démo guidée, aperçu onboarding, ou explication claire de ce qui se passe après Google | ✅ done |
| 🟡 | Déplacer les preuves opérationnelles trop techniques (`Auth`, `API`, `Workspace`) vers une preuve orientée résultat utilisateur: reprise de travail, état de sync compréhensible, diagnostic copiable en cas de blocage | ✅ done |

---

## ContentFlow Site (Astro)

**Stack**: Astro 6.1, Markdown content collections | **Phase**: Astro 6 cleanup shipped; Vercel post-ship verification pending

**Top priority**: Verify post-cleanup Vercel build logs use `npm@11.12.1`, then re-audit the marketing site.

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Replace PostHog with cookie-free Content Flows analytics | ✅ done |
| ✅ | Rewrite privacy page for cookie-free analytics | ✅ done |
| ✅ | Add Cookie-Free Analytics feature card | ✅ done |
| ✅ | Add 3 new platform docs (social listening, quality scoring, link previews) | ✅ done |
| ✅ | Ajouter le flux d'auth web Clerk (`/sign-in`, `/sign-up`, `/launch`) et les CTA vers l'app Flutter | ✅ done |
| ✅ | Rediriger l'auth marketing vers l'app domain et retirer le handoff site → app comme chemin principal | ✅ done |
| ✅ | Ajouter un guide de marque (`BRANDING.md`) et verrouiller les règles de langue FR dans la doc projet | ✅ done |
| 🔴 | Migrate `contentflow_site` from Astro 5 to Astro 6 using the ready spec | ✅ done |
| 🟠 | Validate static build output, sitemap, `robots.txt`, content routes, SEO metadata, and auth handoff pages after migration | ✅ done |
| 🟠 | Verify post-cleanup Vercel build logs use `npm@11.12.1` after ship | 📋 todo |
| ✅ | Reconnect the Vercel `contentflow_site` project to `diane-defores/contentflow` and verify the current or next `main` SHA deploys the Astro site | ✅ done |
| 🔴 | R1 — Connect Pricing buttons to Polar.sh checkout URLs | 📋 todo |
| ✅ | R2 — Add "Problem" section before solution in Hero | ✅ done |
| 🟠 | R3 — Add product visuals (screenshots/mockup) | 📋 todo |
| ✅ | R4 — Replace fake testimonials with "Who It's For" personas | ✅ done |
| ✅ | R5 — Replace Hero stats with value metrics | ✅ done |
| ✅ | R6 — Clean up Footer dead links | ✅ done |
| ✅ | R7 — Harmonize "ContentFlow" naming everywhere | ✅ done |
| ✅ | Bring active ShipGlows site documentation metadata, technical governance, and editorial governance into lint compliance | ✅ done |

### Audit: Code (2026-04-28)

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | Add a static redirect/auth smoke check covering `/sign-in`, `/sign-up`, and `/launch` so future handoff edits preserve same-origin app redirects and noindex metadata | 📋 todo |

### Audit: Code (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Wire Pricing CTA buttons to actionable links (app sign-in with plan hints) | ✅ done |
| ✅ | Add env-based Polar checkout wiring for Creator/Pro (`POLAR_CREATOR_CHECKOUT_URL`, `POLAR_PRO_CHECKOUT_URL`) with safe fallback links | ✅ done |
| 🟠 | Set deployed `POLAR_CREATOR_CHECKOUT_URL` and `POLAR_PRO_CHECKOUT_URL` values to activate final paid checkout destinations | 📋 todo |
| 🟡 | Add a static check to fail builds when pricing CTA elements are rendered without actionable `href` values | 📋 todo |

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Upgrade lockfile to `astro@5.18.1` chain and apply `npm audit fix` (10 findings -> 1 moderate remaining) | ✅ done |
| 🔄 | Add automated dependency updates + security gate (Dependabot added; CI `npm audit` threshold still pending) | 🔄 in progress |
| 🟡 | Review LGPL transitive libs from sharp (`@img/sharp-libvips-*`) for deployment/commercial license compliance | 📋 todo |
| ✅ | Pin Node/npm in `package.json` (`engines` + `packageManager`) for reproducible builds | ✅ done |
| 🟡 | Track install-time scripts from transitive dependencies (`esbuild` postinstall) in CI trust policy | 📋 todo |

### Audit: SEO (2026-04-06)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Generate real OG image (1200x630 JPG/PNG) — SVG placeholder not supported by social | 📋 todo |
| ✅ | Add Blog link to homepage Navbar | ✅ done |
| ✅ | Route content collections beyond blog/ (37 orphaned .md files — 6 collections routed) | ✅ done |
| ✅ | Improve blog image alt text (descriptive prefix) | ✅ done |
| ✅ | Add Product/Offer structured data for Pricing | ✅ done |

### Audit: Copywriting (2026-04-06)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Ajouter preuve sociale ("Built by a solo founder" dans Hero) | ✅ done |
| ✅ | CTA produit dans chaque article blog (CtaBanner component) | ✅ done |
| ✅ | Réordonner homepage : Who It's For AVANT Pricing | ✅ done |
| ✅ | Réduire Features de 10 à 5 bénéfices en langage client | ✅ done |
| 🟠 | Framer pricing en valeur + toggle annuel | 📋 todo |
| ✅ | Éliminer jargon technique (CrewAI, DataForSEO, OAuth) → bénéfices client | ✅ done |
| ✅ | CTA post-FAQ (ClosingCta component) | ✅ done |

### Audit: Design (2026-04-07)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Add hamburger mobile menu + skip nav + focus styles + prefers-reduced-motion | ✅ done |
| ✅ | Fluid typography: clamp() on all headings, fix pure vw values | ✅ done |
| ✅ | FAQ aria-expanded + Privacy/404 Navbar+Footer consistency | ✅ done |
| ✅ | Blog pages use different nav/footer — unify with Navbar/Footer | ✅ done |
| ✅ | Hardcoded colors outside design system | ✅ done |
| ✅ | Extract duplicate button styles to global (`.btn-primary`, `.btn-secondary`) | ✅ done |
| ✅ | Extract duplicate `.container`/`.section-header` styles to global | ✅ done |

### Audit: Design Tokens (2026-05-10)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Activer un vrai système light/dark côté site: les design tokens dark sont définis dans `contentflow_theme.json` mais le runtime Astro publie uniquement des variables light | 📋 todo |
| 🔴 | Migrer les valeurs visuelles littérales restantes dans composants/layouts/pages Astro vers les design tokens (`font-size`, spacing, motion, surfaces) — scan courant: 401 findings | 🔄 in progress |
| 🟠 | Nettoyer les design tokens orphelins (`--button-*`, `--space-mobile-*`, `--breakpoint-*`, etc.) et verrouiller la nomenclature sémantique | 📋 todo |

### Audit: Code (2026-04-07)

| Sev | Issue | Status |
|-----|-------|--------|
| 🔴 | 12 routers with no auth | ✅ done |
| 🔴 | Shell injection in publishing/tech audit tools | ✅ done |
| 🔴 | Global exception handler leaks str(exc) | ✅ done |
| 🟠 | Bare except: clauses | ✅ done |
| 🟠 | Drip router hardcoded user_id | ✅ done |
| 🟠 | CORS regex too broad | ✅ done |
| 🟠 | In-memory state (deployment, templates routers) | 📋 todo |
| 🟠 | Loose dependency pins in requirements.txt | ✅ done |
| 🟠 | God file: internal_linking_tools.py (3512 lines) | ✅ done |
| 🟡 | No CI/CD pipeline | 📋 todo |
| 🟡 | No structured logging | ✅ done |
| 🟡 | No rate limiting | ✅ done |

---

## gamification

**Stack**: Vue 3, TypeScript, Vite | **Phase**: Knowledge base + visuels

**Top priority**: Générer les visuels des articles via MCP (Kroki + AntV Charts)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Knowledge base gamification (22 articles, ~14K lignes) | ✅ done |
| ✅ | Enrichir composables (useStreak, useBadges) + créer useLevel, useQuests, useDailyRewards | ✅ done |
| ✅ | Skill audit gamification ShipGlows | ✅ done |
| ✅ | Installer MCP visuels (AntV Charts + Kroki) | ✅ done |
| ✅ | Générer illustrations statiques SVG (9 SVG: spectre éthique, radar, hook, fogg, pyramides, etc.) | ✅ done |
| ✅ | Générer diagrammes de données (radar Octalysis, pyramide mesure, continuum SDT) | ✅ done |
| 🟡 | Créer outils interactifs Vue (EthicsCanvas, AlignmentDiagnostic, ServiceAudit) | 📋 todo |
| 🟡 | Créer animations pédagogiques SVG+CSS (échafaudage, Hook Model, hedonic curve) | 📋 todo |
| 🟡 | Site web Astro pour publier la knowledge base | 📋 todo |
| 🟢 | Build et publier la lib gamification sur npm | 💤 deferred |

---

## ShipGlows (CLI)

**Stack**: Bash, gum, PM2, Caddy, Flox | **Phase**: Active dev — UX refactor

**Top priority**: Migrer les anciens artefacts ShipGlows existants vers le frontmatter metadata strict

| Pri | Task | Status |
|-----|------|--------|
| ✅ | RAM monitoring dans header (Free: 59G \| Mem: 21G) + cache system | ✅ done |
| ✅ | System Monitor (RAM overview, barre visuelle, alerts, top processes, long-running) | ✅ done |
| ✅ | Merger System Monitor dans Health Check (h) au menu principal | ✅ done |
| ✅ | Remplacer tous les numéros par des lettres (main + advanced menu) | ✅ done |
| ✅ | Dashboard : uptime par app + détection idle (24h+) + proposer stop direct | ✅ done |
| ✅ | Config RAM : SHIPGLOWS_MEM_WARN_GB, SHIPGLOWS_PROCESS_LONG_RUNNING_HOURS, SHIPGLOWS_MONITOR_TOP_N | ✅ done |
| ✅ | Refactor dual-mode : menu_gum.sh (gum style + read -sn1) / menu_bash.sh (echo+read) | ✅ done |
| ✅ | Extraction action handlers dans lib.sh + shipglows.sh réduit à 48 lignes | ✅ done |
| ✅ | ui_choose adaptatif : gum choose (≤5 items) / gum filter (>5 items) | ✅ done |
| ✅ | Flush stdin + pause sans gum input (fix touches résiduelles) | ✅ done |
| ✅ | Aplatir le sous-menu "More Options" (G) → toutes les commandes dans le menu principal | ✅ done |
| ✅ | Retirer `npm build` des pre-checks de sg-ship et sg-verify (build reste dans sg-check uniquement) | ✅ done |
| ✅ | Refresh 2025-2026 state of the art : sg-audit-seo (AEO/GEO + llms.txt + INP + schemas AI) | ✅ done |
| ✅ | Refresh 2025-2026 state of the art : sg-audit-design (container queries, :has, view transitions, OKLCH, AI-gen smells) | ✅ done |
| ✅ | Refresh 2025-2026 state of the art : sg-audit-copy (AI-slop blacklist EN+FR, trust signals, AEO/GEO copy, CRO 2026) | ✅ done |
| ✅ | Refresh 2025-2026 state of the art : sg-enrich (AI Visibility Layer, E-E-A-T checklist, schema matrix) | ✅ done |
| ✅ | Créer sg-skills-refresh — skill méta pour refresh mensuel des skills + REFRESH_LOG.md | ✅ done |
| ✅ | Refonte du workflow spec-driven V3 (`sg-spec`, `sg-ready`, `sg-start`, `sg-verify`) + archivage de la doc obsolète racine + README aligné | ✅ done |
| ✅ | Ajouter `sg-model` + enrichir `sg-start` avec routing de modèle et orchestration multi-agent | ✅ done |
| ✅ | Créer `sg-test` pour guider les tests manuels, loguer `TEST_LOG.md` et ouvrir `BUGS.md` | ✅ done |
| ✅ | Formaliser la doctrine ShipGlows des contrats de décision, metadata versionnées, docs business techniques, cohérence documentaire et sécurité dans README/workflow/changelog | ✅ done |
| ✅ | Skill description budget compliance: audit script, descriptions compactes et checks `sg-docs`/`sg-skills-refresh` scoppés | ✅ done |
| ✅ | Patch global des skills pour résoudre les références et outils internes depuis le root canonique ShipGlows | ✅ done |
| 🟠 | Faire des specs le registre global des chantiers spec-first avec historique de skills | ✅ done |
| 🟠 | Ajouter la taxonomie interne des skills et les sources de chantier potentiel | ✅ done |

| 🟠 | Ajouter un validateur metadata ShipGlows machine-checkable pour specs, docs business, audits, reviews et rapports | ✅ done |
| 🟠 | Créer et aligner les templates d'artefacts ShipGlows sur les structures attendues par les skills (`spec`, business/brand, audits, verify/ready, review, research, decision records) | ✅ done |
| 🟠 | Durable Exploration Reports for `sg-explore` | ✅ done |
| ✅ | Ajouter la couche de gouvernance éditoriale ShipGlows (`docs/editorial/`, Editorial Reader, claim register, page intent, schema Astro, blog-surface stop conditions) | ✅ done |
| 🟠 | Bootstrapper les corpus de gouvernance technique/éditoriale via `sg-init`/`sg-docs` et les intégrer au contrat `sg-build` | ✅ done |
| 🟠 | Migrer les anciens artefacts ShipGlows officiels (`BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md`, `specs/*.md`) vers le frontmatter metadata strict sans casser les schémas applicatifs | ✅ done |
| 🟡 | Écrire un guide de migration metadata/versioning pour adopter ShipGlows dans un projet existant | ✅ done |
| 🟡 | Ajouter une baseline sécurité centrale ShipGlows (`SECURITY.md` ou doc équivalente) couvrant auth, permissions, secrets, logs, multi-tenant, données et abus | 📋 todo |
| 🟡 | Tester un flow complet réel `sg-spec -> sg-ready -> sg-start -> sg-verify -> sg-end -> sg-ship` sur une petite feature pilote | 📋 todo |
| 🟡 | Vérifier toutes les skills générant de la documentation business pour garantir le frontmatter et le versioning par défaut | 📋 todo |
| 🟡 | Aligner `skills/sg-help/SKILL.md` et les docs restantes sur le workflow spec-driven V3 et la boucle de remédiation de `sg-verify` | 📋 todo |
| 🟠 | Durcir `sg-fix` pour exiger une trace bug durable même en fix direct, sauf exception mineure explicitement justifiée | ✅ done |
| 🟠 | Corriger la configuration Playwright MCP pour pointer le Chromium ARM64 local au lieu de Google Chrome stable absent | 🔄 in progress |
| ✅ | Créer `sg-browser` comme skill navigateur généraliste non-auth et l'intégrer aux routes `sg-auth-debug`, `sg-test`, `sg-prod`, `sg-fix`, `sg-start`, `sg-verify`, `sg-check`, aux specs de taxonomie/catalogue, aux README internes et au site public | ✅ done |
| 🟠 | Construire `sg-build` comme skill maître autonome (orchestrateur spec -> ready -> start -> verify -> end -> ship avec délégation bornée) | ✅ done |
| ✅ | Empêcher `sg-build` de renvoyer manuellement vers `sg-end`/`sg-ship` après vérification réussie sauf blocage explicite | ✅ done |
| 🟠 | Implémenter `sg-skill-build` comme skill maître de maintenance des skills (`sg-spec -> SKILL.md -> sg-skills-refresh -> budget audit -> sg-verify -> sg-docs/help -> sg-ship`) et aligner les surfaces publiques/docs | ✅ done |
| ✅ | Créer `sg-deploy` comme skill maître de release (`sg-check -> sg-ship -> sg-prod -> preuve -> sg-verify -> sg-changelog`) et aligner docs/help/site | ✅ done |
| ✅ | Promouvoir `sg-maintain` en skill maître de maintenance projet (`triage -> spec/ready -> délégation bornée -> verify -> ship/deploy`) et aligner docs/help/site | ✅ done |
| ✅ | Créer `sg-bug` comme orchestrateur de boucle bug (`sg-test -> dossier -> sg-fix -> retest -> sg-verify -> sg-ship`) et aligner docs/help/site | ✅ done |
| ✅ | Ajouter un contrat partagé de rapports compacts pour les skills (`report=user` par défaut, `report=agent` explicite) et le propager aux skills lifecycle, bug et audit | ✅ done |
| ✅ | Ajouter une discipline Spec-Driven Development + Proof-First TDD/Evidence Gates aux skills d'exécution, bug, skill-build, verify et délégation | ✅ done |
| ✅ | Renforcer les questions `sg-build` en mode plan avec contexte, racine du problème, enjeu business, options et recommandation best practice | ✅ done |
| ✅ | Ajouter une cheatsheet publique et Markdown repo des master skills, supporting skills et modes d'arguments, avec page publique `sg-build` | ✅ done |
| 🟠 | Créer une skill `sg-prs` pour trier les PR GitHub ouvertes (`gh`), vérifier repo/branches/diffs/checks, regrouper Dependabot quand possible, merger les PRs vertes et fermer/commenter les PRs obsolètes selon une politique explicite | 📋 todo |
| 🟠 | Harden `install.sh` supply-chain and failure handling: replace live `curl \| bash`/direct downloads with pinned, verified install steps and strict failure behavior | 🔄 in progress |
| 🟠 | Flutter/Dart Flox provisioning for ShipGlows projects (runtime install, override validation, existing `.flox` repair path, docs/tests) | ✅ done |
| 🟠 | Local MCP OAuth tunnel login: commande `shipglows-mcp-login`, intégration menu local, alias install, tests de validation et docs | 🔄 in progress |
| ✅ | Corriger le raccourci CLI `sg u` et harmoniser les retours `x`/`Esc`/Backspace dans les sous-menus (`BUG-2026-05-04-002`) | ✅ done |
| 🟠 | Split `lib.sh` hotspots around environment lifecycle, publishing, dashboard, inspector, and metadata helpers to reduce the 5,900+ line blast radius | 📋 todo |
| 🟡 | Resolve the `site` production dependency advisory for Astro (`GHSA-j687-52p2-xcff`) through a planned Astro upgrade/migration | 📋 todo |
| 🟡 | Fix `test_priority3.sh` so the PM2 jq parsing fixture passes or is explicitly skipped with an accurate reason | 📋 todo |
| 🟠 | Harmoniser tous les sous-menus CLI : lettres au lieu de chiffres, `x) Cancel` unique, et comportement Cancel cohérent entre `gum` et fallback bash | ✅ done |
| 🟠 | Regrouper le menu racine ShipGlows en entrées lisibles avec sous-menus iconés (`Dashboard`, `Deploy / Start`, `Environments`, `Tools`, `System`, `Agents / ShipGlows`, `Help`) | ✅ done |
| ✅ | Documenter et propager le mode de développement projet (`local`, `vercel-preview-push`, `hybrid`) dans les skills de validation et de ship | ✅ done |
| ✅ | Validate DuckDNS publish inputs, encode DuckDNS update requests, harden secret writes, and remove the default public ImgBB upload key | ✅ done |
| ✅ | Restore the Astro docs page build by moving dynamic GitHub URLs into frontmatter and escaping shell-style `${...}` text | ✅ done |
| 🟠 | Vérifier que gum s'installe proprement via install.sh sur Debian/Ubuntu/Alpine | 📋 todo |
| 🟡 | Vidéo YouTube : démo ShipGlows pour la communauté | 💤 deferred |
| 🟢 | Aligner `sg-veille` avec la gouvernance contenu : router les idées blog/newsletter vers `sg-content`/`sg-repurpose` et signaler `surface missing: blog` quand aucune surface n'est déclarée | 💤 deferred |
| 🟢 | Ajouter un handoff contenu à `sg-research` et `sg-market-study` quand leurs rapports recommandent des contenus publics, avec sources, claims et route vers `sg-content` | 💤 deferred |
| 🟢 | Renforcer `sg-audit` master pour charger explicitement les corpus éditorial/technique quand l'audit touche des surfaces publiques, claims ou docs mappées | 💤 deferred |
| 🟢 | Ajouter une micro-intégration `technical-docs-corpus` à `sg-content`/`sg-repurpose` quand les opportunités ou handoffs touchent des docs techniques internes | 💤 deferred |
| 🟢 | Cadrer plus tard le mécanisme de synchronisation `project repo -> master` pour `shipglows_data` (symlink, copie, index généré, ingestion web app ou autre) dans une spec dédiée | 💤 deferred |

### Audit: Code (2026-04-29) — Score: B

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
| 🟠 | Consolidate duplicated tunnel lifecycle logic between `local/dev-tunnel.sh` and `local/local.sh` so the interactive menu inherits the same validation, collision handling, and managed stop behavior | 📋 todo |

### Audit: Perf (2026-04-29) — Score: B

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Load the public site fonts asynchronously in `site/src/layouts/BaseLayout.astro` so the Google Fonts stylesheet no longer blocks first paint | ✅ done |
| ✅ | Reduce compositor cost in `site/src/styles/global.css` by gating blur effects behind `@supports` and lowering the blur radius on glass panels | ✅ done |
| ✅ | Defer below-the-fold layout and paint work on long static pages via `content-visibility` in `site/src/styles/global.css` | ✅ done |
| ✅ | Prune heavyweight directories from `lib.sh` project resolution scans and replace remote PM2 Python parsing with Node in `local/local.sh` and `local/dev-tunnel.sh` | ✅ done |
| 🟠 | Self-host the marketing site fonts or move to a local-first stack to eliminate the remaining cross-origin font dependency after the non-blocking preload patch | ✅ done |
| 🟡 | Consolidate duplicated remote PM2/tunnel parsing logic between `local/local.sh` and `local/dev-tunnel.sh` so future perf and failure-handling fixes do not drift | ✅ done |

---

## dotfiles

**Stack**: Bash, Symlinks, Termux/Codespaces | **Phase**: Maintenance

**Top priority**: Finish Termux local secret hardening and safe managed symlink replacement in the dotfiles installer

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Termux properties config + symlink dans termux.sh | ✅ done |
| ✅ | Tmux prefix C-a → C-w + double status bar | ✅ done |
| ✅ | MCP servers : secrets → env vars (DFS, PostHog, Firecrawl) | ✅ done |
| ✅ | install.sh : TPM auto-install + Codex config symlink | ✅ done |
| 🟠 | Harden Termux local secret handling: silent input, shell-safe env serialization, and `0600` permissions for generated Shell-GPT config | ✅ done |
| 🟠 | Stop destructive replacement of existing user config targets when dotfiles manages first-party config symlinks; unknown files should be backed up, not deleted | ✅ done |
| 🟠 | MCP shared secrets/OAuth broker for Claude + Codex : définir `mcp/run-mcp <server>` comme wrapper unique, étendre `mcp/mcp-servers.json` avec `envFrom`/`secretProvider`/`authCache`, générer les entrées Codex via le wrapper au lieu d'écrire des secrets dans TOML, injecter seulement les env vars nécessaires par serveur, réutiliser les caches OAuth (`~/.mcp-auth` ou helper `mcp-remote`) sans copier les refresh tokens, prévoir dry-run + tests fake HOME + audit logs sans valeurs sensibles | 📋 todo |
| 🟡 | Ajouter colors.properties dans dotfiles/termux/ (choix du thème) | 📋 todo |

### Audit: Code (2026-04-28) — Score: C

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Remove `eval` from Claude MCP stdio registration and from `parallel_run` | ✅ fixed |
| ✅ | Stop copying `/root/.ssh/id_ed25519` into newly created non-root users | ✅ fixed |
| 🟠 | Harden Termux local secret handling: silent input, shell-safe env serialization, and `0600` permissions for generated Shell-GPT config | ✅ done |
| 🟠 | Stop destructive replacement of existing user config targets when dotfiles manages first-party config symlinks; unknown files should be backed up, not deleted | ✅ done |
| 🟡 | Add a non-network installer smoke test that exercises `--dry-run`, `--only=mcp`, and symlink sync behavior under a temporary `HOME` | 📋 todo |
| 🟡 | Replace remote install-script pipes with downloaded, pinned, checksum-verified artifacts where upstream releases make that practical | 📋 todo |

---

## winflowz

**Stack**: Astro, Starlight, React, Vue, Clerk, Polar | **Phase**: Content clusters

**Top priority**: Fix blog template — rendre le body markdown (Content component inutilisé)

🟡 [winflowz] task: Consolidate SITE and PUBLIC_SITE_URL into one canonical site URL env | status: todo | area: env-cleanup | id: wf-site-url-env-single-source

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Cluster Termux — données 114 thèmes extraites | ✅ done |
| ✅ | Composant React TermuxThemePreview (island) | ✅ done |
| ✅ | Page outil /termux-themes (FR+EN) | ✅ done |
| ✅ | Article guide personnalisation Termux (FR+EN) | ✅ done |
| ✅ | Article thèmes Termux (FR+EN) | ✅ done |
| ✅ | Overhaul FR + EN training content across all 8 modules | ✅ done |
| ✅ | Remove PostHog analytics and sendBeacon tracking | ✅ done |
| ✅ | Update cookie consent + privacy policy to essential-only | ✅ done |
| ✅ | Consolidate CONTENU/ source Markdown to match published lessons | ✅ done |
| ✅ | Build dedicated Windows sales-page funnel (FR `/fr/maitrise-windows` + EN `/windows-mastery`) and route main landing CTAs into it | ✅ done |
| ✅ | Create funnel strategy assets plus FR/EN campaign email drafts for the Windows offer | ✅ done |
| ✅ | Corriger les claims publics de la home et des surfaces SEO/i18n (métriques formation, AppSumo, pricing, FAQ) | ✅ done |
| 🟠 | Fix blog template — rendre le body markdown (Content component inutilisé) | 📋 todo |
| 🟠 | Connect the new Windows sales funnel to actual newsletter / email automation flow | ✅ done |
| 🟠 | Decide and implement a direct purchase CTA from the sales page instead of routing through the course hub | ✅ done |
| 🟡 | Maillage interne articles Termux ↔ formations | 📋 todo |
| 🟡 | Images cardImage pour les articles Termux | 📋 todo |

### Audit: Code (2026-04-07) — Score: C+

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Clerk webhook: add svix signature verification + proxy to Convex HTTP | ✅ fixed |
| ✅ | Convert public Convex mutations to internalMutation (polar.ts, users.ts) | ✅ fixed |
| ✅ | API key generation: replace Math.random() with crypto.getRandomValues() | ✅ fixed |
| ✅ | Route translation drift: align routing.ts, i18n/config.ts, fr/routes.json | ✅ fixed |
| ✅ | CSP connect-src: add Convex/Clerk/Polar domains, remove unsafe-eval | ✅ fixed |
| ✅ | convex/http.ts: add Polar signature verification, fix empty catch | ✅ fixed |
| ✅ | CORS: make origin environment-aware (not hardcoded localhost) | ✅ fixed |
| ✅ | Middleware: remove unnecessary `as any` casts | ✅ fixed |
| 🟠 | `as never` casts on ConvexHttpClient calls (courseGating.ts, checkout.ts) — needs codegen | 📋 todo |
| 🟠 | Add CLERK_WEBHOOK_SECRET env var to Vercel + Convex deployment | 📋 todo |
| 🟠 | Point Clerk webhooks to Convex HTTP endpoint or Astro proxy | 📋 todo |
| 🟠 | Zero test files — write tests for courseGating, webhooks, checkout | 📋 todo |
| 🟡 | Duplicate cn() utility (lib/cn.ts + lib/utils.ts) — consolidate | 📋 todo |
| 🟡 | Duplicate Button component (ui/button.tsx vs react/ui/button.tsx) | 📋 todo |
| 🟡 | Convex client singleton in lib/convex.ts never used (4 ad-hoc instantiations) | 📋 todo |
| 🟡 | COURSE_ENTITLEMENT duplicated in courseGating.ts and convex/http.ts | 📋 todo |
| 🟡 | Dead deps: @astrojs/vue, @types/cors, astro-vtbot — remove | 📋 todo |
| 🟡 | Both astro-compress AND astro-compressor installed — pick one | 📋 todo |
| 🟡 | No .env.example file | ✅ done |
| 🟡 | Harmoniser les CTA catalogue (`beta` / `coming_soon`) pour supprimer les impasses commerciales | ✅ done |
| 🟡 | Mettre à jour README, GUIDELINES et la doc d'environnement pour refléter le funnel réel | ✅ done |
| 🟡 | In-memory rate limiting useless on Vercel serverless | 📋 todo |
| 🟡 | No structured logging or error tracking | 📋 todo |

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Remediate public Astro/Vercel security advisories: `path-to-regexp` ReDoS via `@astrojs/vercel`, Astro `define:vars` XSS, `@astrojs/node` SSRF/DoS/cache-poisoning advisories | ✅ done |
| 🟠 | Plan an Astro adapter/framework migration under `/sg-migrate` before major upgrades (`astro` 5→6, `@astrojs/vercel` 9→10, `@astrojs/node` 9→10, Clerk/Preline/Tailwind ecosystem majors) | ✅ done |
| 🟠 | Restore reproducible installs: commit or intentionally replace `pnpm-lock.yaml`, add `packageManager`, and pin Node runtime via `engines` or `.node-version` | 🔄 in progress |
| 🟡 | Add dependency update automation for pnpm and GitHub Actions with reviewed security updates, not silent major auto-merges | 📋 todo |
| 🟡 | Remove or justify likely-unused direct dependencies after manual verification: `@heroicons/react`, `@polar-sh/astro`, `@preline/accordion`, `@types/cors`, `@vercel/nft`, `astro-compress`, `astro-compressor`, `astro-vtbot`, `globby`, `html-minifier-terser`, `lucide-react`, `sharp-ico`, `@phosphor-icons/web`, and formatting-only packages | 📋 todo |
| 🟡 | Resolve dependency hygiene: choose one Astro compression package, document Preline Fair Use license fit, and add a project license declaration | 📋 todo |

---

## tubeflow

**Stack**: Next.js 16, React 19, Convex, Clerk, Turborepo, TypeScript | **Phase**: Active dev — transcripts + feed UX

**Top priority**: Vérifier le déploiement/configuration du worker transcript de bout en bout

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Système de transcripts multi-provider avec versioning, réglages fournisseurs, secrets chiffrés et worker Python | ✅ done |
| ✅ | Feed de secours depuis les abonnements YouTube quand les playlists sont vides | ✅ done |
| ✅ | Mode liste du feed avec préférence persistée | ✅ done |
| ✅ | Opt-out analytics sur `/privacy` | ✅ done |
| ✅ | Retirer ou restreindre `shipglows-inspector` et `shipglows-eruda` du layout de production | ✅ done |
| ✅ | Auditer et sécuriser `shipglows-inspector.js` (intégration upload + clé IMGBB exposée) | ✅ done |
| ✅ | Fix : vidéo non retirée de l'UI après swipe-delete sur page playlist — reload manuel requis (optimistic UI) | ✅ done |
| ✅ | Fix : hook `usePaginatedVideos` ne réagit pas aux changements backend (hide/delete) — state local figé | ✅ done |
| ✅ | Regrouper tous les swipe actions à droite (trailing) — un seul sens de swipe pour la clarté | ✅ done |
| ✅ | Bouton swipe « Ajouter à la playlist » sur le feed avec modal de sélection playlist | ✅ done |
| ✅ | Bouton « Ajouter à la playlist » dans la toolbar de la page Play | ✅ done |
| ✅ | Swipe Delete sur le feed — supprime la vidéo de toutes les playlists YouTube + hide | ✅ done |
| 🟠 | Vérifier le déploiement/configuration du worker transcript de bout en bout | 📋 todo |
| 🟠 | Ajouter une vraie vérification sur la génération de transcript, le switch de provider et les cas d'échec | 📋 todo |
| 🟠 | Moderniser les integrations OpenAI de TubeFlow (payload transcript + Structured Outputs summaries + docs/tests) | 🔄 in progress |
| 🟠 | Vue « résumé texte » du feed — carte avec thumbnail petit + résumé 1-5 phrases (UI only, sans données pour l'instant) | 📋 todo |
| 🟡 | Clarifier le périmètre de l'app native par rapport au web pour le prochain jalon | 📋 todo |
| 🟡 | 🔍 Benchmark Claras vs TubeFlow — features, pricing, UX, chat IA, export agents — source: https://www.meetclaras.com/ (veille 2026-04-04) | 📋 todo |
| 🟢 | Étendre les workflows transcript/study à l'app native une fois le web stabilisé | 💤 deferred |

---

## tubeflow-app (Flutter)

**Stack**: Flutter, Riverpod, GoRouter, Convex, Firebase Auth | **Phase**: Audit + stabilisation

**Top priority**: Valider Firebase Auth, Convex et YouTube OAuth sur le déploiement Vercel/Convex

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Fail explicitly when CONVEX_URL is not set (was silently using placeholder URL) | ✅ done |
| ✅ | Wire router to actual screen widgets (was using _Placeholder for all routes) | ✅ done |
| ✅ | Remove pubspec.lock from .gitignore (must be committed for reproducible builds) | ✅ done |
| ✅ | Surface bootstrap failures to user (was silently swallowed) | ✅ done |
| ✅ | Extract duplicated _parseColor() into shared color_utils.dart | ✅ done |
| ✅ | Add security headers to vercel.json (X-Frame-Options, CSP, etc.) | ✅ done |
| ✅ | Consolidate all Convex mutation calls through mutations.dart helpers | ✅ done |
| ✅ | Replace beta-Clerk auth with Firebase Auth and Firebase ID tokens for Convex | ✅ done |
| 🟠 | Implement feedback collection + admin review flow (text/audio, Convex storage, admin allowlist) | ✅ done |
| 🟠 | Realign Flutter web YouTube auth to a full-redirect OAuth flow (remove popup path) | 🔄 in progress |
| 🟠 | Verify Firebase Auth + Convex bootstrap and YouTube OAuth end-to-end on the deployed environment | 🔄 in progress |
| 🟠 | Persist playlist reorder and complete playlist-detail navigation actions | 📋 todo |
| 🟠 | Add automated coverage for auth/bootstrap/OAuth critical paths and run it in CI | 📋 todo |
| 🟡 | Add CSP/HSTS hardening headers in `vercel.json` | 📋 todo |
| 🟡 | Tighten Dart analyzer settings (`strict-casts`, `strict-inference`, `strict-raw-types`) | 📋 todo |
| 🟡 | Create and readiness-check a dependency update spec before changing `pubspec.yaml` / `pubspec.lock` | 📋 todo |
| 🟡 | Run a dependency audit/outdated check and capture upgrade risks, breaking changes, and test coverage | ✅ done |
| 🟡 | Add tests (zero test coverage currently) | 📋 todo |

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Remove beta auth packages `clerk_flutter` / `clerk_auth` and replace the disabled path with stable Firebase Auth | ✅ done |
| ✅ | Remove unused Flutter codegen packages: `riverpod_annotation`, `build_runner`, and `riverpod_generator` | ✅ done |
| ✅ | Upgrade direct non-beta dependencies to latest resolvable versions, including `go_router`, `sentry_flutter`, and `flutter_lints` | ✅ done |

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Harden YouTube OAuth helper parsing/origin handling to avoid malformed-cookie crashes and ambiguous forwarded headers | ✅ done |
| ✅ | Wire no-op taps in Videos/Playlists/Notes screens to real routes | ✅ done |
| ✅ | Mark OAuth redirects as non-cacheable (`Cache-Control: no-store`) | ✅ done |
| ✅ | Replace `PlayScreen` placeholders with real player/transcript plumbing and implement queue/options actions | ✅ done |


---

## socialflow (WisprFlow)

**Stack**: Tauri 2, Vue 3, Kotlin (Android WebView), Rust, Pinia, Convex Auth | **Phase**: Active dev — Android app

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Fix Messenger redirect loop (Facebook→messages boucle infinie) | ✅ done |
| ✅ | Fix cookie/banner scripts auto-clicking non-cookie dialogs (Messenger restore history) | ✅ done |
| ✅ | DESKTOP_VIEWPORT_SCRIPT — viewport 500px pour Messenger, 980px pour les autres desktop UA | ✅ done |
| ✅ | switchToMessenger() — interception Facebook→messages + fb-messenger:// deep links | ✅ done |
| ✅ | Backup export Android — sauvegarde directe dans AppData (bypass SAF dialog bloquant) | ✅ done |
| ✅ | Bouton Copier l'erreur dans le dialogue backup | ✅ done |
| ✅ | Capabilities FS — permissions read/write/mkdir/readdir + scope AppData | ✅ done |
| ✅ | Couleurs pastels tiles réseau (tileBg restauré) | ✅ done |
| ✅ | URL Messenger → facebook.com/messages (messenger.com discontinué) | ✅ done |
| ✅ | Text zoom natif WebView (slider settings) — range 75-200%, settings.textZoom API | ✅ done |
| ✅ | Dark mode natif WebView (algorithmicDarkening) — signal dark branché du thème app jusqu’au contenu WebView + fallback Facebook dédié | ✅ done |
| ✅ | Fix Android backup "command not found" — register plugin commands in build.rs + capabilities | ✅ done |
| 🟡 | Tester le backup export/import end-to-end sur Android après fix capabilities | 📋 todo |
| ✅ | Bottom bar Android non synchronisée avec le profil actif — sync déplacée de `NetworkWebviewHost.vue` (non monté depuis le dashboard) vers `App.vue` persistant | ✅ done |
| ✅ | Tap sound inaudible — SoundPool + bundled `assets/sounds/click.wav` routé via USAGE_MEDIA (indépendant du setting "Touch sounds") | ✅ done |
| ✅ | Onboarding première installation — guide pas-à-pas + choix profil/réseaux | ✅ done |
| ✅ | Onboarding relançable depuis Settings — bouton "Revoir le tutoriel" | ✅ done |
| ✅ | Signup drawer / nudge — erreur compacte avec bouton Copier + troncature des messages longs | ✅ done |
| ✅ | Android WebView uploads — `onShowFileChooser` branché au picker SAF pour accéder aux photos/fichiers lors des posts/messages Facebook | ✅ done |
| ✅ | Logs debug Android enrichis — navigation Facebook, schémas custom, file chooser params/résultats, UA mode pour diagnostiquer stories/uploads | ✅ done |
| ✅ | Popup menu bottom bar — toggle dark mode + slider taille du texte directement depuis les webviews | ✅ done |
| ✅ | Stories Facebook mobile — message explicite quand le flux est indisponible au lieu d’un dismiss silencieux du prompt d’app | ✅ done |
| ✅ | WhatsApp Web désactivé — loader infini après pairing (IndexedDB non persistée + userAgentData mismatch); doc de réactivation dans `docs/whatsapp-web-integration.md` | ✅ done |
| ✅ | Convex Auth backend linked to dev deployment — `npx convex dev` generated `.env.local`, users schema made auth-compatible, and signing keys (`JWT_PRIVATE_KEY` + `JWKS`) configured via `@convex-dev/auth` | ✅ done |
| ✅ | Convex sync overhaul — profils, comptes SocialFlow, custom links, filtre amis, profil actif et préférences clés sont maintenant synchronisés via le cloud | ✅ done |
| ✅ | Auth bootstrap + password sign-in hydration — au login / redémarrage, l’état cloud hydrate réellement l’app avec politique cloud-priority; fix du mode sombre non restauré après réinstallation | ✅ done |
| 🟠 | UX première synchronisation après connexion — afficher une pop-up guidée pendant l’hydratation cloud (données reçues, données appliquées, redémarrage, application prête) | 🔄 in progress |
| ✅ | Documenter l'architecture du repo et l'inventaire des doublons restants dans `docs/repo-architecture-audit.md` | ✅ done |
| 🟠 | Supprimer les copies mortes sous `src/ui/setup/pages/SocialFlow/` (`services/*`, `config/gmail.ts`, `stores/mockData/gmailMock.ts`) après vérification finale des imports | 📋 todo |
| 🟠 | Clarifier la frontière `src/` vs `src/ui/setup/pages/SocialFlow/` — sortir les types métier partagés de `SocialFlow/types` et unifier les primitives dupliquées (`feed`, `common`, `dateFormatter`, `facebookMock`) | 📋 todo |
| ✅ | Site FR/EN mis à jour — `features`, `faq` et `pricing` expliquent clairement ce qui est synchronisé via le cloud et ce qui reste local (cookies/sessions) | ✅ done |
| ✅ | File de sync Convex durable — les écritures cloud sont persistées localement, rejouées automatiquement (focus/réseau/visibilité/timer) et flushées avant l’hydratation cloud | ✅ done |
| ✅ | Profil par défaut local-only — le placeholder `Profile 1` n’est plus synchronisé tant qu’il n’a pas été réellement personnalisé, évitant de polluer les comptes existants | ✅ done |
| ✅ | Dark mode Android WebView branché jusqu’au contenu web — tentative native (`FORCE_DARK`/algorithmic darkening) + hint `prefers-color-scheme` pour pousser les réseaux vers leur thème sombre | ✅ done |
| ✅ | Stabiliser le dark mode Facebook mobile — fallback dédié, alignement du thème natif et réapplications sûres pendant les redirects gardent maintenant `m.facebook.com` en sombre sur appareil | ✅ done |
| 🟠 | Fermer le menu popup de la barre basse Android au tap/clic extérieur pendant la navigation webview | 🔄 in progress |
| 🟡 | Persistance IndexedDB + localStorage par profil — débloque WhatsApp, Telegram (MTProto), Discord (token en localStorage) | 📋 todo |
| 🟠 | Vérifier signup/signin Convex Auth end-to-end sur le bon dev deployment et supprimer le lien local vers un ancien deployment si inutile | 🔄 in progress |
| 🟠 | Ajouter la capture caméra Android au file chooser WebView (`capture`) puis re-tester le flux Story Facebook sur appareil | 📋 todo |
| 🟠 | Vérifier sur appareil si le fallback CSS/JS de zoom texte modifie réellement Facebook mobile, sinon renforcer l’approche | 📋 todo |

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Upgrade `vue-i18n` to `>=11.1.2` and verify FR/EN signup, settings, onboarding, and auth copy; fixed to `vue-i18n@11.4.0`, `typecheck:core` passes | ✅ done |
| ✅ | Remediate build-chain high advisories by updating compatible patch/minor packages first: `vite`, `sass`/`immutable`, `tailwindcss`/`sucrase`/`glob`, `web-ext` transitives, and ESLint minimatch/brace-expansion paths | ✅ done |
| ✅ | Review runtime reachability of `pinia-plugin-persistedstate` transitive `tar` advisories; fixed via compatible `@nuxt/kit` override | ✅ done |
| ✅ | Add dependency update automation covering npm/pnpm, GitHub Actions, and Rust/Cargo, with manual review for majors | ✅ done |
| ✅ | Add a checked-in Node runtime pin aligned with CI Node 20/24 policy | ✅ done |
| ✅ | Revisit `.npmrc` (`shamefully-hoist=true`, `strict-peer-dependencies=false`) and document why peer/integrity weakening is still required | ✅ done |
| 🟡 | Declare the project license in `package.json` and `src-tauri/Cargo.toml`; production license summary could not be generated because pnpm reported a missing package index | 📋 todo |
| 🟠 | Remaining `pnpm audit` findings require migration decisions: Rollup 2 via CRX/pluginutils, `serialize-javascript@6` via Workbox, Vite 5/esbuild line, `vue-template-compiler` via old `vue-tsc`, and `uuid@8` via `web-ext`/`node-notifier` | 📋 todo |
| 🟡 | Add `cargo-audit` or `cargo-deny` to CI/local audit workflow; RustSec posture is currently documented but not fully scanner-proven | 📋 todo |

### Audit: Code (2026-04-28, score C+)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Enforce active-account ownership + network matching in `convex/socialAccounts.ts:setActive` so a user cannot persist an invalid active pointer | ✅ done |
| ✅ | Align signup-nudge cooldown with the documented 30-day behavior in `src/composables/useSignupNudge.ts` | ✅ done |
| ✅ | Add automated coverage for auth bootstrap, Convex hydration, cloud-sync replay, and profile/account switching; Vitest + Convex invariant tests now run locally and in CI | ✅ done |
| 🟠 | Reduce repo convention drift between `src/` and `src/ui/setup/pages/SocialFlow/`; duplicated `services`, `types`, `feed/common`, and mock-data paths still make fixes easy to miss on one surface | 📋 todo |
| ✅ | Add stricter server-side validation for cloud-backed payloads (`customLinks`, `profiles`, `settings`) with URL-scheme, length, and invariant checks proportionate to the trust boundary | ✅ done |
| ✅ | Tighten the remaining type-safety gaps in auth/cloud/Convex modules; touched critical auth/cloud/Convex files now pass lint without `any` warnings | ✅ done |

### Audit: Deps (2026-04-30, score B-)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Track or mitigate `uuid@8.3.2` via `web-ext@10.1.0 -> node-notifier@10.0.1`; production `pnpm audit --prod` is clean, but Firefox extension lint/build tooling still carries the moderate advisory | ✅ done |
| 🟠 | Plan `/sg-migrate` for deprecated and major-line tracks before changing them: `@primevue/themes` -> `@primeuix/themes`, PrimeVue 3 -> 4, `unplugin-vue-router`/Vue Router 4 -> Vue Router 5, Vite 8, Tailwind 4, Pinia 3, TypeScript 6, and ESLint 10 | ✅ done |
| 🟡 | Remove or explicitly justify unused/stale direct deps: `@primevue/themes`, `@tailwindcss/forms`, `@iconify-json/{carbon,lucide,mdi,svg-spinners}`, `get-installed-browsers`, `prettier-plugin-tailwindcss`, `unplugin-imagemin`, `vuefire`, `webext-bridge`, and deprecated `@types/eslint__js` | ✅ done |
| 🟡 | Declare `semver` as a direct dev dependency for `scripts/vue-tsc-fixed.cjs` or remove the dead script; current execution would rely on transitive hoisting | ✅ done |
| 🟡 | Declare project licenses in `package.json` and `src-tauri/Cargo.toml`, then review unknown-license packages `atomically`, `get-installed-browsers`, and `stubborn-fs` | ✅ done |
| 🟡 | Document why the 31 package overrides remain necessary and add `cargo-audit` or `cargo-deny` to CI/local audit workflow; RustSec posture is now scanner-proven with visible accepted native warnings | ✅ done |

---

## plaisirsurprise

**Stack**: Astro 6, Tailwind CSS 4, React, Convex, Clerk | **Phase**: Early dev

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Upgrade Astro 6 + Tailwind 4 build stack and clear the Astro dependency audit blocker | ✅ done |
| 🟡 | 🏗️ Étudier stack paiement Funbooker (ANCV, Illicado, Apple Pay, Google Pay, PayPal) pour intégration — source: https://www.funbooker.com/ (veille 2026-04-04) | 📋 todo |

---

## tubeflow-site

**Stack**: Astro 6, Tailwind CSS 4, Lenis | **Phase**: Full site migrated

**Top priority**: Real logo/favicon + OG image + connect auth

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Migrate landing page from Next.js (v0-winflowz-landing) to Astro | ✅ done |
| ✅ | Set up Tailwind CSS 4 with dark theme tokens | ✅ done |
| ✅ | Port all animations (Framer Motion → CSS + IntersectionObserver) | ✅ done |
| ✅ | Add Lenis smooth scroll, navbar hover pill, micro-animations | ✅ done |
| ✅ | Replace placeholder "Apex" copy with real TubeFlow product content | ✅ done |
| ✅ | Migrate remaining homepage sections (Problem, Solution, Benefits, Testimonials, Newsletter) | ✅ done |
| ✅ | Migrate features, pricing, compare, blog, terms, privacy pages with i18n content | ✅ done |
| ✅ | SEO: Open Graph, Twitter Card, canonical URLs, JSON-LD structured data | ✅ done |
| ✅ | Blog with Astro content collections (3 posts + index + dynamic routes) | ✅ done |
| ✅ | Footer links pointing to real pages | ✅ done |
| 🔴 | Add real logo and favicon + OG image | 📋 todo |
| 🔴 | Connect CTA buttons to Clerk auth (signup/signin flows) | 📋 todo |
| 🟠 | Add real testimonial images (replace gradient placeholders) | 📋 todo |
| 🟠 | i18n support (FR translations from apps/web) | 📋 todo |
| 🟡 | RSS feed for blog (/blog/feed.xml) | 📋 todo |
| 🟡 | Create BUSINESS.md and BRANDING.md for copywriting context | 📋 todo |

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Patch Astro/PostCSS XSS advisories by updating the lockfile to Astro >= 6.1.6 and PostCSS >= 8.5.10, then run `npm run build` | 📋 todo |
| 🟡 | Move build-only packages (`astro`, `@tailwindcss/vite`, `tailwindcss`, `tw-animate-css`) to `devDependencies` unless runtime deployment requires production install semantics | 📋 todo |
| 🟡 | Add package manager pinning (`packageManager`) and Dependabot/Renovate coverage for npm and GitHub Actions | 📋 todo |

---

## gocharbon_quiz

**Stack**: Flutter 3.41, Dart 3.11, FastAPI, MongoDB, Convex | **Phase**: Design polish shipped (A-)

**Top priority**: Renforcer le funnel quiz → gocharbon.fr (destinations, CTA, tracking)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Renforcer la solidité du funnel entre le quiz et `gocharbon`: fiabiliser les destinations, clarifier le parcours de sortie et mesurer la conversion réelle | 🔄 in progress |
| 🔴 | Clarifier la destination business après quiz: page de cours, dossier thématique ou page de capture sur `gocharbon` selon la catégorie et le score | ✅ done |
| 🟠 | Ajouter un CTA OAuth web dans Profile, injecter les `SUPABASE_*` au build Vercel et valider le flow E2E navigateur | 🔄 in progress |
| 🟠 | Ajouter un tracking minimal du funnel de sortie (quiz démarré, quiz terminé, CTA affiché, CTA cliqué) pour mesurer la conversion vers `gocharbon` | 📋 todo |
| 🟠 | Revoir le wording des écrans résultat et profil pour vendre la suite d'apprentissage GoCharbon plutôt qu'un simple lien externe | ✅ done |
| 🟠 | Auditer la banque de questions et les explications pour s'assurer qu'elles renforcent l'autorité pédagogique de GoCharbon | 📋 todo |

### Audit: Design (2026-04-14)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | ~~Ajouter un mode `prefers-reduced-motion` pour atténuer les animations de score, shake et transitions du quiz/résultats~~ | ✅ done |
| 🟠 | Supprimer les troncatures `numberOfLines` trop agressives sur les contenus pédagogiques longs pour éviter de couper questions, explications et recommandations | 🔄 in progress |
| 🟡 | ~~Continuer l'harmonisation typographique des micro-labels (tabLabel/dailyBadge/catText/statLbl/rankLevel/badgeName/qCount/explanationText/courseLbl bumpés)~~ | ✅ done |
| 🟡 | ~~Ajouter des états d'erreur utilisateur plus explicites sur les écrans principaux au lieu de simples `console.error` silencieux~~ | ✅ done |

### Audit: Design (2026-04-18/19)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | ~~Bug `TouchableOpacity` non importé dans `leaderboard.tsx` (crash écran erreur)~~ | ✅ done |
| 🟠 | ~~WCAG AA: `textTertiary` #6C6C75 → #8A8A93 (3.98:1 → 5.77:1)~~ | ✅ done |
| 🟠 | ~~Timer quiz a11y: `accessibilityRole="timer"` + `announceForAccessibility` à t=5s~~ | ✅ done |
| 🟠 | ~~`optText numberOfLines` 2 → 3 pour réponses FR longues~~ | ✅ done |
| 🟡 | ~~Tokens spacing/radius (`S`, `R`) exportés + normalisation radii 10/12/14/18/20 → 8/16/24~~ | ✅ done |
| 🟡 | ~~Boutons retry/back/err unifiés (paddingH 24, paddingV 14, radius 16, fontSize 16)~~ | ✅ done |
| 🟡 | ~~Skeletons animés (`src/components/Skeleton.tsx`) sur home/leaderboard/profile~~ | ✅ done |
| 🟢 | ~~Quick wins polish: tutoiement dailyTitle, textShadow gradient, progressbar a11y (quiz + XP profil), rankItem a11y composite, scoreLabel letterSpacing 1.5, xpBadge a11y~~ | ✅ done |

### Audit: Copywriting (2026-04-19)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Introduire dès l'accueil la promesse complète du produit : tester son niveau puis trouver la bonne suite sur GoCharbon, pour ne plus paraître comme un quiz autonome | ✅ done |
| ✅ | Transformer l'écran résultat en écran de décision : diagnostic, raison de la recommandation, bénéfice attendu et CTA principal vers GoCharbon ; rejouer devient secondaire | ✅ done |
| ✅ | Personnaliser la recommandation finale selon catégorie, score et erreurs fréquentes, au lieu d'un simple lien générique | ✅ done |
| ✅ | Ajouter un CTA alternatif léger pour les utilisateurs pas prêts à sortir immédiatement (sauvegarder la ressource, recevoir la suite, revenir plus tard) | ✅ done |
| ✅ | Réaligner profil, notifications et partage sur la progression d'apprentissage plutôt que sur le streak ou le classement seuls | ✅ done |
| 🟡 | Réduire les signaux de "mini-jeu autonome" quand ils concurrencent la marque mère et le bénéfice business | 🔄 in progress |
| 🟡 | Réduire les signaux de "mini-jeu autonome" quand ils concurrencent la marque mère et le bénéfice business | 📋 todo |

### Audit: Code (2026-04-26)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | ~~Bloquer les soumissions de quiz avec réponses dupliquées, catégories invalides, modes invalides ou payloads hors bornes sur FastAPI et Convex~~ | ✅ done |
| 🟠 | ~~Protéger les endpoints legacy de push token, notification de test et seed par secret utilisateur ou clé admin~~ | ✅ done |
| 🟠 | Ajouter une CI minimale pour `flutter analyze`, `flutter test`, `backend_convex npm run typecheck`, `backend_convex npm run validate:content:expo` et tests backend ciblés | 📋 todo |
| 🟡 | Décider si l'exposition de `correct_answer` dans `/api/questions` est acceptable pour un quiz lead magnet ou si le feedback doit passer par un endpoint de correction serveur | 📋 todo |
| 🟡 | Remplacer les contrats `BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md` en brouillon/faible confiance par des versions reviewées avant de scorer A en cohérence produit/sécurité | 📋 todo |
| 🟡 | Réduire la dérive entre FastAPI legacy et Convex: recommandations plus riches côté FastAPI que Convex, endpoints notifications différents, tests de parité absents | 📋 todo |

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Mettre à jour les dépendances backend vulnérables directes: `litellm` vers une version corrigée, `starlette`/`fastapi` sur une paire compatible, `pymongo`/`motor`, et `python-multipart >=0.0.26` | 📋 todo |
| 🟠 | Réduire `backend/requirements.txt` aux packages réellement utilisés par `server.py`, `recommendations.py` et les tests; déplacer `black`, `flake8`, `mypy`, `pytest` hors dépendances runtime | 📋 todo |
| 🟡 | Remplacer ou justifier `ecdsa` / `python-jose`, car `ecdsa` reste signalé pour side-channel crypto sans correctif prévu | 📋 todo |
| 🟡 | Planifier les mises à jour Flutter compatibles: `go_router` patch, `supabase_flutter` minor, et `share_plus` major via `/sg-migrate` si nécessaire | 📋 todo |
| 🟡 | Supprimer ou justifier `cupertino_icons` si l'app Flutter n'utilise pas les icônes Cupertino | 📋 todo |
| 🟡 | Ajouter Dependabot ou Renovate pour `pub`, pip, npm Convex et GitHub Actions, avec revue manuelle des majors | 📋 todo |
| 🟡 | Épingler la version runtime Node/Python et documenter Flutter 3.41.7 / Dart 3.11.5 comme toolchain attendue | 📋 todo |
| 🟡 | Ajouter une vérification CI de dépendances (`flutter pub outdated`, `pip-audit --no-deps`, `npm audit` Convex, lockfile presence) pour éviter la régression | 📋 todo |

---

## WinFlowzApp

**Stack**: Flutter 3.41, backend-agnostic stores, Firebase Auth/Firestore first adapter, GoRouter, Riverpod, Android native overlay | **Phase**: Firebase backend-agnostic migration in progress

**Top priority**: Ship verified persistent local clipboard fallback, then Android IME clipboard/device QA

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Migrate the repo to a Flutter multi-platform baseline with Supabase-first docs and schema | ✅ done |
| ✅ | Add the initial Supabase migration and RLS smoke test scaffold | ✅ done |
| ✅ | Add Supabase migration lint to CI | ✅ done |
| ✅ | Run the verification gate end-to-end: `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`, `flutter build web` | ✅ done |
| ✅ | Add first-run onboarding, Android back-tab navigation, permission explanations and non-blocking backend diagnostic copy in Settings | ✅ done |
| ✅ | Create Firebase CLI/OIDC workflow for Firestore rules/indexes deploy in hosted CI | ✅ done — run `25636532417` Firestore job `75249317806` green, revalidated after IAM hardening in run `25636936089` Firestore job `75250395805` |
| ✅ | Archive Supabase target docs and point active backend execution to Firebase/backend-agnostic spec | ✅ done |
| ✅ | Reorganize root migration/metadata docs into `shipglows_data` canonical structure and migrate path references | ✅ done |
| 🟠 | Detach Supabase runtime target path (`task 7`) while preserving legacy compile compatibility until parity decision | ✅ done — Supabase removed from active bootstrap/providers/diagnostics; legacy adapters/tests kept for compatibility |
| 🟠 | Build Android IME WinFlowzApp Keyboard end-to-end: native keyboard, Settings bridge, privacy gate, clipboard, media, schema, docs, Android device QA | 🔄 in progress — custom swipe-corner keyboard, Settings bridge, privacy gate, native panels, docs, persistent local clipboard fallback/search/copy and Dart checks implemented; Android physical-device clipboard/IME QA still required |
| ✅ | Run the required Android-current manual platform pass and document non-Android limits | ✅ done — Android remains the only current runtime target; capability/permission limits documented; web local speech disabled; Android real-device QA remains tracked under overlay/IME tasks |
| 🟡 | Expand automated coverage beyond the template test for auth gate, repositories, and sync/error flows | 📋 todo |
| 🟡 | Revisit README/docs wording after verification so they reflect shipped behavior rather than migration intent | ✅ done — documentation now references canonical paths in `shipglows_data` |

### Audit: Design

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Validate Appearance sync against Firebase under offline/error/account-switch cases and surface pending/error status in Settings instead of swallowing persistence failures | 📋 todo |
| 🟠 | Unify product language across Auth, Settings, Shell, and CRUD surfaces so a single session does not mix French and English labels, actions, and destructive prompts | 📋 todo |
| 🟠 | Raise global button/icon minimum targets and review dense Settings controls so key actions do not default to 34-36 px hit areas | 📋 todo |
| 🟡 | Refactor typography tokens into named text roles or bundled specs (`size + line-height + tracking`) instead of a loose t-shirt scale spread across `AppTypography` and `_textTheme` | 📋 todo |
| 🟡 | Add reduced-motion handling for non-trivial motion and interaction feedback instead of relying only on raw duration/curve tokens | 📋 todo |
| 🟡 | Add a Flutter design playground/storybook screen for token inspection across light/dark modes | 📋 todo |
| 🟡 | Review wide desktop-biased dialog widths and encoded status strings in keyboard/settings flows for better responsive readability | 📋 todo |

---

## ext---toolflowz

**Stack**: Vite, Vue 3, TypeScript, pnpm, browser extension | **Phase**: Store-review hardened

**Top priority**: Split the all-page content-script bundle and expand security regression tests

### Audit: Deps

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Patch the direct/runtime and build-server CVEs without jumping majors: `vue-i18n` >=11.1.2, Vite >=6.4.2, PostCSS >=8.5.10, then rerun `pnpm audit` and extension builds | ✅ done |
| 🔴 | Remove unused `vuefire` or prove Firebase is intentionally used; current install pulls critical `protobufjs` and vulnerable `undici` through `vuefire -> firebase` | ✅ done |
| 🟠 | Patch dev/test/packaging transitive risks in `jsdom/form-data`, `web-ext/node-forge`, `@playwright/test`, `sass/immutable`, and Vite plugins pulling `h3`, `tar`, `svgo`, `rollup`, `minimatch`, and `defu` | ✅ done |
| 🟠 | Clean dependency hygiene after type/build verification: remove unused PrimeVue 4 packages (`@primevue/core`, `@primevue/icons`) from a PrimeVue 3 app, redundant `@types/*`, and unused config-only packages flagged by depcheck | 📋 todo |
| 🟠 | Add dependency governance: `.nvmrc` or `engines`, `packageManager`, Dependabot/Renovate, and review `.npmrc` settings (`shamefully-hoist=true`, `strict-peer-dependencies=false`) | 🔄 in progress — `engines`, `packageManager`, overrides note, and `.npmrc` review done; update automation still open |
| 🟡 | Route breaking upgrades through `/sg-migrate`: PrimeVue 3→4, Vite 6→8, Vitest 0.34→4, Pinia 2→3, Vue Router 4→5, TypeScript 5→6, Tailwind 3→4, FormKit 1→2, web-ext 8→10 | 📋 todo |
| 🟠 | Resolve global `pnpm run typecheck` failures outside the dependency-security chantier, then rerun build/audit/typecheck together | ✅ done |

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Bundle PrimeVue/PrimeIcons styles locally instead of loading `cdn.jsdelivr.net` from the content script and theme store | ✅ done |
| ✅ | Replace direct project `innerHTML`/`v-html` insertion paths with DOM construction, plain text rendering, or sanitized fragments for reader/Gmail/feed/changelog surfaces | ✅ done |
| ✅ | Add Firefox `data_collection_permissions.required: ["none"]` so manifest lint no longer flags missing data-collection disclosure | ✅ done |
| 🟠 | Design a narrower permission model for `manifest.config.ts`: redundant `host_permissions`, `scripting`, `activeTab`, and `webNavigation` removed; static `<all_urls>` content-script match intentionally remains for the toolbar product model | ✅ done |
| 🟠 | Configure or remove FormKit's bundled icon CDN fallback so packaged extension code cannot fetch `https://cdn.jsdelivr.net/npm/@formkit/icons...` at runtime, or prove the fallback is unreachable | ✅ done |
| 🟠 | Replace the single 800x800 `src/assets/logo.png` manifest icon mapping with correctly sized 16/24/32/128 assets for Firefox review | ✅ done |
| 🟡 | Split or lazy-load heavy content-script dependencies; the built all-page content script is still about 886 KB minified | 📋 todo |
| 🟡 | Add meaningful tests for bridge payload validation, reader sanitizer behavior, Better Gmail DOM insertion, and manifest/store-review policy checks | 🔄 in progress — manifest permission/icon/dependency policy tests added; bridge/sanitizer/Gmail tests remain |
| 🟡 | Add ShipGlows metadata contracts (`BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md`) or migrate existing docs into the expected schema so future audits are not capped by proof gaps | 📋 todo |

---

## shipglows

**Stack**: Bash CLI, PM2/Caddy/Flox helpers, Codex skills, metadata linting, documentation workflow | **Phase**: Framework hardening

**Top priority**: Rendre le bootstrap réellement universel au-delà du seul `install.sh` serveur

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Concevoir un bootstrap universel multi-OS (`Linux`, `macOS`, `WSL`, `Windows`) avec comportement explicite selon la plateforme | 📋 todo |
| 🔴 | Supprimer l'hypothèse implicite "`python3` déjà installé" hors `sudo ./install.sh` serveur et définir la stratégie officielle de provisioning runtime | 📋 todo |
| 🟠 | Ajouter un chemin d'installation local sans root quand possible pour les outils docs/metadata qui reposent sur Python | 📋 todo |
| 🟠 | Faire échouer les scripts avec un diagnostic précis et actionnable quand un runtime requis manque au lieu de dépendre d'erreurs secondaires | 📋 todo |
| 🟠 | Documenter la matrice de bootstrap par environnement : serveur Debian/Ubuntu, poste macOS, poste Linux non-root, Windows/WSL | 📋 todo |
| 🟡 | Évaluer s'il faut fournir un wrapper unique (`bootstrap` / `doctor`) pour vérifier et installer les prérequis avant usage | 📋 todo |
| 🟠 | Relire et shipper les docs `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `GUIDELINES.md` après la passe de durcissement en cours | 🔄 in progress |
| 🟠 | Public skill categories — reclassifier le catalogue public en `Plan & Decide`, `Build & Fix`, `Audit & Improve`, `Research & Grow`, `Operate & Ship`, `Meta & Setup` | ✅ done |
| ✅ | Ajouter au site public ShipGlows un tutoriel sur les modes des skills, une page FAQ dédiée, et le maillage interne correspondant depuis les surfaces marketing/docs | ✅ done |
| 🟠 | Implémenter Professional Bug Management avec index compact, dossiers bug et preuves séparées | ✅ done |

---

## shipglows_app

**Stack**: Flutter, Riverpod, Firebase/Firestore projection specs, GitHub App target, Vercel | **Phase**: Read-only projection foundation

**Top priority**: Run `/sg-ready` on `shipglows-github-managed-clone-indexer.md`, then implement the managed clone/indexer boundary only after the ready gate passes.

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Canonical foundational coherence gate for Firebase/GitHub/Firestore/runner/dashboard specs | ✅ done |
| ✅ | Supabase WIP archived and translated into Firebase/Firestore projection contracts; Supabase is not the active target | ✅ done |
| ✅ | Firestore data model documentation, pure Dart contracts, path builders, validators, and targeted tests | ✅ done |
| 🔴 | Run `/sg-ready` for `shipglows-github-managed-clone-indexer.md` so the managed clone/indexer boundary can move from draft to implementation-ready | 📋 todo |
| 🔴 | Implement the GitHub managed clone/indexer slice after readiness: server-side access-check contract, local/fake runner, projection DTOs, stale/deleted/parse-failed tests | 📋 todo |
| 🟠 | Ready the deferred foundational specs for auth/GitHub access, project onboarding, dashboard read-only projection, and Markdown artifact governance | 📋 todo |
| 🟡 | Verify and close `shipglows-legacy-file-migration-tracker.md`, then decide whether to close the parent legacy fusion chantier | 📋 todo |
| 🟢 | Refondre la façade publique de ShipGlows App dans `site/` (copie de la structure TubeFlow) en conservant le design et en réécrivant le contenu | ✅ done |


## Backlog (Ideas Parking Lot)

| Pri | Project | Task | Status |
|-----|---------|------|--------|
| 🟢 | ContentFlow Lab | Evaluate Robolly as a template-based image/PDF generation layer for ContentFlow visuals (social cards, thumbnails, OG images, batch creatives) (added 2026-04-18) | 💤 deferred |
| 🟢 | winflowz | Evaluate Vovsoft AI Automator as a Windows-first local companion for training demos and learner exercises (scheduled prompts, Ollama workflows, batch prompt runs) (added 2026-04-18) | 💤 deferred |
| 🟢 | winflowz | Re-evaluate OpenAuth as a possible self-hosted suite identity provider replacement for Clerk/Auth0, only if it is no longer beta and has mature user management, operations, security, monitoring and production references; review in 2028 (added 2026-05-17) | 💤 deferred until 2028 |
| 🟡 | NoCocaïne | Repenser l'entree `Formations` de la page Plus ; ce n'est pas une destination de premier niveau. Option A: la descendre dans une section `Ressources`. Option B: l'integrer au parcours d'apprentissage (Today / Carte) (added 2026-04-18) | ✅ done |
| 🟡 | NoCocaïne | Demanteler la page `Succes` de la page Plus ; badges de progression reintegres dans Carte, entree retiree de Plus et ancienne route redirigee vers Carte (completed 2026-04-19) | ✅ done |
| 🟡 | NoCocaïne | Demanteler la page `Defis hebdomadaires` de la page Plus ; reintegrer la feature dans Today (carte / detail), puis supprimer l'entree et la page dediee (added 2026-04-18) | ✅ done |
| 🟠 | NoCocaïne | Empêcher les scrollbars fantômes sur l'écran Today et Dashboard quand le contenu ne déborde pas (added 2026-04-20) | ✅ done |
| 🟡 | NoCocaïne | Repositionner `Ma boite a outils` ; garder la feature et probablement la page, mais la laisser cote Plus / Personnalisation comme espace de gestion a froid. SOS doit seulement consommer ces outils, pas devenir leur back-office (added 2026-04-18) | 🔄 in progress |
| 🟡 | NoCocaïne | Demanteler la page `Journal de fierte` de la page Plus ; garder la feature, la laisser vivre d'abord dans Today via le rituel du soir, et si besoin conserver seulement une vue d'historique secondaire accessible depuis ce flow (added 2026-04-19) | 💤 deferred |
| 🟡 | NoCocaïne | Repositionner `Journal de reflexion` ; garder la feature, mais sortir la page des entrees fortes de Plus et la rendre accessible d'abord depuis le flow post-consommation, le tracker ou un sous-espace d'historique / reflexion personnel (added 2026-04-19) | 💤 deferred |
| 🟠 | jarrettelacoke.fr | Réécrire les contenus publics qui prescrivent encore un coach live alors que `/coach` n'est plus qu'un aperçu “bientôt” ; réaligner CTA, FAQ et maillage interne sur les outils réellement disponibles (added 2026-04-19) | ✅ done |
| 🟠 | jarrettelacoke.fr | Purger le drift de marque vers `NoCocaïne` dans les articles publics FR, les CTA et les clusters SEO restants (added 2026-04-19) | 💤 deferred |
| 🟠 | jarrettelacoke.fr | Réaligner la promesse “communauté” entre homepage / application et `/communaute` ; ne plus vendre comme brique active ce qui n'est aujourd'hui qu'un prototype local (added 2026-04-19) | ✅ done |
| 🟠 | jarrettelacoke.fr | Réaligner la promesse `Premium` avec la réalité produit ; soit remettre un vrai gating, soit arrêter de présenter le dashboard analytics comme exclusif si `/tracker` l'expose déjà (added 2026-04-19) | 💤 deferred |
| 🟡 | jarrettelacoke.fr | Ramener `CommunityWall` dans la palette du design system et supprimer la couleur violette hardcodée hors tokens du site (added 2026-04-19) | 💤 deferred |
| 🟠 | jarrettelacoke.fr | Passe SEO titres FR ≤60 caractères + métadonnées centralisées (`content-metadata.mjs`, `dateModified` JSON-LD/sitemap) sur 85 articles questions (completed 2026-04-19) | ✅ done |
| 🟠 | jarrettelacoke.fr | Refonte homepage conversion + funnel `/application` & `/pricing` aligné site gratuit → application → Premium (completed 2026-04-19) | ✅ done |
| 🟠 | jarrettelacoke.fr | Documentation produit ajoutée (`BRANDING.md`, `BUSINESS.md`, `README.md`, `docs/API.md`) pour cadrer brand system, personas et surface API (completed 2026-04-19) | ✅ done |
| 🟠 | jarrettelacoke.fr | Centraliser toutes les tailles de police en tokens fluides (`--fs-xs` → `--fs-hero`) ; bumper le corps de texte sur mobile et réduire légèrement les titres ; sweep 29 fichiers (completed 2026-04-20) | ✅ done |
- [x] sg-deps migration (2026-05-25): gocharbon major deps lane executed (`eslint@10.4.0`, `satori@0.26.0`, `vue@3.5.34`); audit remains clean (0 critical/0 high/0 moderate/0 low); remaining incompatibility to resolve: replace/update `eslint-plugin-jsx-a11y` for ESLint 10.
