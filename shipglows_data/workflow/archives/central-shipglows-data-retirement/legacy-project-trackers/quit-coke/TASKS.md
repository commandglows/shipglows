# Tasks — quit-coke

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Structure projet clonee depuis Claiire (102 fichiers) | ✅ done |
| ✅ | Rebranding complet : Claiire → QuitCoke | ✅ done |
| ✅ | Vercel deployment config (vercel.json, non-www → www redirect) | ✅ done |
| ✅ | Astro 6 SSR + Vue 3 + Clerk + sitemap configures | ✅ done |
| ✅ | 6 parcours definis dans `src/config/parcours.js` | ✅ done |
| ✅ | 7 sidebars navigation configurees + 3 nouvelles entrees | ✅ done |
| ✅ | Gamification config (10 badges, 6 categories) | ✅ done |
| ✅ | Middleware premium gating (Clerk + cookie fallback) | ✅ done |
| ✅ | Webhooks Polar + RevenueCat implementes | ✅ done |
| ✅ | PM2 ecosystem.config.cjs (port 3007, Doppler secrets) | ✅ done |
| ✅ | npm install + build passe (0 errors, 10.2s) | ✅ done |
| 🔴 | Acheter domaines (quit-coke.com, quit-coke.fr, arreter-la-coke.fr) | 📋 todo |
| 🔴 | Deploy sur Vercel (git push + connect project) | 📋 todo |
| 🔴 | Configurer env vars Vercel (Clerk, Polar, RevenueCat secrets) | 📋 todo |

---

## Sprint 1 — SEO & Content (DONE)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Homepage rewrite conversion-optimized (479 lignes, stats, pricing, CTA) | ✅ done |
| ✅ | SchemaOrg.astro — JSON-LD structured data (Organization, WebSite, MedicalWebPage, FAQ, Breadcrumb) | ✅ done |
| ✅ | Breadcrumbs.astro avec schema BreadcrumbList | ✅ done |
| ✅ | Page /arreter-la-cocaine — pillar SEO (877 lignes, guide complet, FAQ) | ✅ done |
| ✅ | Page /test-addiction — quiz interactif AddictionTest.vue | ✅ done |
| ✅ | Page /application — landing tracker + SobrietyCounter | ✅ done |
| ✅ | CostCalculator.vue — calculateur cout cocaine (viral) | ✅ done |
| ✅ | AddictionTest.vue — quiz 10 questions CAGE-AID | ✅ done |
| ✅ | SobrietyCounter.vue — compteur sobriete temps reel | ✅ done |
| ✅ | 5 nouvelles pages contenu (duree sevrage, symptomes, statistiques, temoignages, aide proche) | ✅ done |
| ✅ | Meta descriptions optimisees sur 10+ pages cles | ✅ done |
| ✅ | Header nav + sidebars mis a jour (Test, Tracker, Tarifs) | ✅ done |
| ✅ | robots.txt + sitemap etendus | ✅ done |

---

## Sprint 2 — Tracker & Features (DONE)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | ConsumptionTracker.vue — log quotidien, triggers, humeur, calendar heatmap (2116 lignes) | ✅ done |
| ✅ | TrackerDashboard.vue — analytics CSS-only: heatmap, trends, triggers, mood, insights (1601 lignes) | ✅ done |
| ✅ | CravingHelper.vue — bouton flottant: respiration 4-7-8, distraction, urgence (1001 lignes) | ✅ done |
| ✅ | EmailCapture.vue — lead magnet "Guide 7 jours" banner + popup (427 lignes) | ✅ done |
| ✅ | Page /tracker — onglets CSS-only Aujourd'hui + Dashboard | ✅ done |
| ✅ | Page /pricing — Free vs Premium, toggle annuel, FAQ, social proof | ✅ done |
| ✅ | CravingHelper integre dans les 2 layouts (floating sur toutes les pages) | ✅ done |
| ✅ | EmailCapture integre sur homepage | ✅ done |

---

## Sprint 3 — Conversion & Polish (DONE)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Page /mentions-legales (RGPD-ready, placeholders societe) | ✅ done |
| ✅ | Page /confidentialite (localStorage keys, services tiers, droits RGPD) | ✅ done |
| ✅ | analytics.ts — 8 event helpers (Vercel Analytics + GA4 dataLayer) | ✅ done |
| ✅ | manifest.json — PWA manifest (standalone, theme-color) | ✅ done |
| ✅ | og-image.svg — Open Graph image 1200x630 | ✅ done |
| ✅ | Meta tags manifest + OG image dans les 2 layouts | ✅ done |
| ✅ | Footer mis a jour avec liens legaux | ✅ done |
| ✅ | data-plan="premium" sur tous les CTA Premium | ✅ done |
| ✅ | Sitemap exclut pages legales/auth | ✅ done |

---

## Contenu

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Comprendre : 9 pages (7 originales + statistiques + temoignages) | ✅ done |
| ✅ | Sevrage : 8 pages (6 originales + duree + symptomes) | ✅ done |
| ✅ | Reconstruction : 9 pages | ✅ done |
| ✅ | Prevention : 9 pages (8 originales + aide proche) | ✅ done |
| ✅ | Meta descriptions SEO optimisees sur toutes les pages cles | ✅ done |
| ✅ | Enrichissement contenu : 33 articles ecrits (88K mots, 150+ sources) | ✅ done |
| 🟠 | Formations : creer fichiers socle/ (4 modules) | 📋 todo |
| 🟠 | Formations : creer fichiers debutant/ (7 modules) | 📋 todo |
| 🟠 | Formations : creer fichiers avance/ (7 modules) | 📋 todo |
| 🟡 | Creer les pages premium `/membres/formations/` | 📋 todo |

---

## Auth & Billing

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Clerk auth optionnel avec fallback cookie | ✅ done |
| ✅ | Polar webhook handler (`/api/webhooks/polar`) | ✅ done |
| ✅ | RevenueCat webhook handler (`/api/webhooks/revenuecat`) | ✅ done |
| ✅ | Member access sync dans Clerk metadata | ✅ done |
| 🔴 | Creer produits Polar (mensuel 9.99€, annuel 79.99€) | 📋 todo |
| 🟠 | Tester flow Clerk login/signup sur quit-coke.com | 📋 todo |
| 🟡 | Tester webhooks Polar en staging | 📋 todo |
| 🟡 | Tester webhooks RevenueCat en staging | 📋 todo |

---

## Launch

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Acheter domaines (quit-coke.com, quit-coke.fr, arreter-la-coke.fr) | 📋 todo |
| 🔴 | Deploy sur Vercel + configurer DNS | 📋 todo |
| 🔴 | Configurer env vars Vercel | 📋 todo |
| 🟠 | Google Search Console (verifier + soumettre sitemap) | 📋 todo |
| 🟠 | Remplir placeholders mentions-legales (societe, SIRET) | 📋 todo |
| 🟠 | Ajouter tag GA4 en production | 📋 todo |
| 🟡 | Bing Webmaster Tools | 📋 todo |
| 🟡 | Creer profils sociaux (Instagram, TikTok, YouTube) | 📋 todo |

---

## Sprint 4 — Community & AI (NEXT)

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | CommunityWall.vue — mur anonyme encouragements/milestones | 📋 todo |
| 🟡 | AI Coach integration (Claude API) | 📋 todo |
| 🟢 | Push notifications (cravings, streaks) | 💤 deferred |
| 🟢 | App mobile iOS/Android (RevenueCat) | 💤 deferred |
| 🟢 | Version anglaise (EN expansion — 4.8M US users) | 💤 deferred |
| 🟢 | PECAN application (remboursement digital therapeutics France) | 💤 deferred |

---

## Project Stats (2026-03-21)

| Metric | Value |
|--------|-------|
| Vue components | 8 |
| Astro pages | 20 |
| Content pages (MD) | 40 |
| Content word count | 88,702 |
| Total source files | 108 |
| Total lines of code | 17,676 |
| Build errors | 0 |
| Build time | 10.2s |

---

## Audit Findings
> Last audit: 2026-03-21 — Overall: [C+]

| Pri | Task | Domain | Status |
|-----|------|--------|--------|
| 🔴 | Wire Polar checkout URL into Premium CTA buttons — revenue is currently zero | GTM | 📋 todo |
| 🔴 | Create /cgv page (CGV legally required for paid services in France) | GTM | 📋 todo |
| 🔴 | Add server-side rate limiting on /api/coach (Anthropic budget exposure) | Code | ✅ done |
| 🔴 | Add server-side rate limiting on /api/newsletter (email abuse vector) | Code | ✅ done |
| 🔴 | Sanitize/validate `context` param in /api/coach (prompt injection) | Code | ✅ done |
| 🔴 | Fill placeholder fields in mentions-legales.astro ([Nom], [SIRET], [Adresse]...) | Copy | 📋 todo |
| 🔴 | Replace [email] placeholder in confidentialite.astro (RGPD contact) | Copy | 📋 todo |
| 🔴 | Add /arreter-la-cocaine to header nav (top SEO page is orphan) | SEO | ✅ done |
| 🔴 | Switch to output: 'static' (prerender by default in Astro 6) | Perf | ✅ done |
| 🔴 | Fix Node engine mismatch: package.json requires >=24, runtime is 22 | Deps | ✅ done |
| 🟠 | Fix footer links /a-propos + /contact (404 on every page) | Design | ✅ done |
| 🟠 | Convert og-image.svg to PNG 1200x630 (SVG broken on social platforms) | SEO | 📋 todo |
| 🟠 | Replace dev debug content on /compte with user-facing dashboard | Design | ✅ done |
| 🟠 | Replace dev text on /connexion fallback with user-friendly message | Copy | ✅ done |
| 🟠 | Create premium formation content or disable empty /membres/formations/ dirs | GTM | 📋 todo |
| 🟠 | Add security headers (CSP, X-Frame-Options, HSTS) via vercel.json | Code | ✅ done |
| 🟠 | Fix RevenueCat webhook: use timingSafeEqual + fail closed when env unset | Code | ✅ done |
| 🟠 | Create .env.example documenting all 8+ env vars | Code | ✅ done |
| 🟠 | Add test framework (Vitest) + tests for critical paths (webhooks, auth, middleware) | Code | 📋 todo |
| 🟠 | Remove fabricated social proof ("+2000 personnes" + fake testimonials) | Copy | ✅ done |
| 🟠 | Add French accents throughout all .astro/.vue/.md files | Copy | 📋 todo |
| 🟠 | Add content to empty formations/index.md | Copy | ✅ done |
| 🟠 | Pass FAQ data to SchemaOrg on 4 pages with FAQ sections | SEO | ✅ done (layout wired, pages need faq prop) |
| 🟠 | Add author/E-E-A-T signals to MedicalWebPage schema (YMYL health content) | SEO | ✅ done |
| 🟠 | Shorten 6 page titles to <60 chars | SEO | ✅ done |
| 🟠 | Wire analytics tracking functions (6/8 wired in Vue components + pricing) | GTM | ✅ done |
| 🟠 | Add cookie consent banner | GTM | 📋 todo |
| 🟠 | Remove abandoned broken-link-checker (2018, 4 vulns) | Deps | ✅ done |
| 🟠 | Remove unused sharp dependency (25MB) | Deps | ✅ done |
| 🟠 | Pin @diane-winflowz/gamification to commit hash (supply chain risk) | Deps | ✅ done |
| 🟠 | Change GamificationBar from client:load to client:idle on both layouts | Perf | ✅ done |
| 🟠 | Fix drip API N+1 email sending (use batch or parallel) | Perf | ✅ done |
| 🟠 | Add caching headers for public SSR pages | Perf | ✅ done |
| 🟠 | Add field-sizing: content to 3 textareas (ConsumptionTracker, AICoach, CommunityWall) | Design | ✅ done |
| 🟠 | Add apple-touch-icon (180x180 PNG) | Design | 📋 todo |
| 🟡 | Fix bio.astro canonical domain (arreter-la-coke.fr → www.arreter-la-coke.fr) | SEO | ✅ done |
| 🟡 | Add packageManager field to package.json | Deps | 📋 todo |
| 🟡 | Add dependabot.yml for dependency automation | Deps | 📋 todo |
| 🟡 | Remove unused deps: nanoid, title-case, glob | Deps | 📋 todo |
| 🟡 | Change AddictionTest, TrackerDashboard, CommunityWall, AICoach to client:idle/visible | Perf | 📋 todo |
| 🟡 | Add Astro prefetch for prev/next content navigation | Perf | 📋 todo |
| 🟡 | Guard scroll-behavior: smooth with prefers-reduced-motion | Perf | ✅ done |
| 🟡 | Standardize CTA text across pages ("Essayer Premium gratuitement") | Copy | 📋 todo |
| 🟡 | Fix duplicate BreadcrumbList schema (SchemaOrg + Breadcrumbs both emit) | SEO | ✅ done |
| 🟡 | Add pubDate to all content doc frontmatter | SEO | 📋 todo |
