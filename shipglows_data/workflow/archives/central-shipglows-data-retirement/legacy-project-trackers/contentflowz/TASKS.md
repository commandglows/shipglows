# Tasks — ContentFlowz

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Review project structure and configure environment | ✅ done |

---

## Analytics & Privacy

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Replace PostHog with cookie-free Content Flows analytics script in Layout.astro | ✅ done |
| ✅ | Rewrite privacy page for cookie-free analytics (no opt-out UI needed) | ✅ done |
| ✅ | Add "Cookie-Free Analytics" feature card in Features.astro | ✅ done |
| ✅ | Update startup-journey to reference Content Flows Analytics instead of PostHog | ✅ done |

---

## Platform Docs

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Add analytics enable/disable docs to connect-your-website guide | ✅ done |
| ✅ | Add Social Listening, Content Quality Scoring, Link Previews to platform index | ✅ done |
| ✅ | Create social-listening.md platform doc | ✅ done |
| ✅ | Create content-quality-scoring.md platform doc | ✅ done |
| ✅ | Create link-previews.md platform doc | ✅ done |
| ✅ | Add Clerk web auth routes (`/sign-in`, `/sign-up`, `/launch`) and app handoff CTAs | ✅ done |
| ✅ | Add `BRANDING.md` and lock French language rules (tu + accents) in project docs | ✅ done |
| 🟡 | Review new platform docs for accuracy and completeness | 📋 todo |

---

## Landing Page (from audit)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | R1 — Connect Pricing buttons to Polar.sh checkout URLs | 📋 todo |
| ✅ | R2 — Add "Problem" section before the solution in Hero | ✅ done |
| 🟠 | R3 — Add product visuals (screenshots/mockup of swipe UI) | 📋 todo |
| ✅ | R4 — Replace fake testimonials with honest "Who It's For" personas | ✅ done |
| ✅ | R5 — Replace Hero stats with value-oriented metrics | ✅ done |
| ✅ | R6 — Clean up Footer dead links | ✅ done |
| ✅ | R7 — Harmonize brand naming "ContentFlowz" everywhere | ✅ done |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | Replace emoji robot with a real logo | 💤 deferred |
| 🟢 | Decide language target (FR vs EN) and align pricing/copy | 💤 deferred |
| 🟢 | Add visual "Integrations" section (platform logos) | 💤 deferred |
| 🟢 | Add risk reversal / guarantee copy ("14 jours gratuits") | 💤 deferred |
| 🟢 | Add sample report / public demo of agent output | 💤 deferred |
| 🟢 | Evaluate Robolly as a template-based image/PDF generation layer for ContentFlow assets (social cards, blog visuals, OG images, batch creatives) (added 2026-04-18) | 💤 deferred |
| 🟢 | Commit and push current uncommitted changes | 📋 todo |

---

## Audit: SEO (2026-04-06)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Create `robots.txt` with sitemap reference | ✅ done |
| ✅ | Create `404.astro` error page with proper noindex | ✅ done |
| ✅ | Add custom meta description to homepage | ✅ done |
| ✅ | Add FAQPage JSON-LD schema to FAQ component | ✅ done |
| ✅ | Add WebSite + SearchAction JSON-LD to Layout | ✅ done |
| ✅ | Add BreadcrumbList JSON-LD to BlogPost layout | ✅ done |
| ✅ | Add favicon.svg | ✅ done |
| ✅ | Add OG default image placeholder | ✅ done |
| ✅ | Add font preload for render-blocking mitigation | ✅ done |
| ✅ | Remove unused font weight 300 from Google Fonts request | ✅ done |
| 🔴 | Generate real OG image (1200x630 JPG/PNG) — social platforms don't support SVG | 📋 todo |
| ✅ | Add Blog link to homepage Navbar | ✅ done |
| ✅ | Route content collections beyond blog/ (37 .md files were orphaned — now registered) | ✅ done |
| ✅ | Add `<meta name="robots" content="index, follow">` explicit default | ✅ done |
| ✅ | Improve blog image alt text (descriptive prefix added) | ✅ done |
| ✅ | Add structured data for Pricing (Product/Offer schema) | ✅ done |
| ✅ | Create page routes for non-blog collections (6 collections: ai-agents, platform, seo-strategy, startup-journey, technical-optimization, tutorials) | ✅ done |
| ✅ | Make BlogPost layout collection-aware (breadcrumbs, related posts, back link) | ✅ done |

---

## Audit: Code (2026-04-06)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | OG default image pointed to SVG — changed to JPG | ✅ done |
| ✅ | SearchAction schema referenced non-existent search — removed | ✅ done |
| ✅ | FAQ component duplicated data 2x (array + HTML) — now uses loop | ✅ done |
| ✅ | tsconfig: `base` → `strict` mode | ✅ done |
| ✅ | Content config: register all 8 collections (was only blog + docs) | ✅ done |
| 🟠 | Pricing buttons are `<button>` with no action — needs Polar.sh URLs (R1) | 📋 todo |
| 🟡 | No tests exist for any component or page | 📋 todo |
| ✅ | No `.env.example` file — created | ✅ done |
| ✅ | Blog tag pages linked (`/blog/tag/...`) — route created | ✅ done |
| ✅ | Security headers added via `vercel.json` (X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy) | ✅ done |

---

## Audit: Copywriting (2026-04-06)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Connecter CTAs Pricing à un checkout réel (Polar.sh) — R1 | 📋 todo |
| ✅ | Ajouter preuve sociale ("Built by a solo founder. Bootstrapped." dans Hero) | ✅ done |
| ✅ | Ajouter CTA produit dans BlogPost.astro (CtaBanner après chaque article) | ✅ done |
| ✅ | Réordonner homepage : Testimonials AVANT Pricing | ✅ done |
| ✅ | Réduire Features de 10 à 5 bénéfices en langage client | ✅ done |
| 🟠 | Framer pricing en valeur ("freelance = 500€, ContentFlow = 19€") + toggle annuel | 📋 todo |
| ✅ | Éliminer jargon : CrewAI, DataForSEO, OAuth, topical mesh → bénéfices client | ✅ done |
| ✅ | Ajouter CTA post-FAQ (ClosingCta avant Footer) | ✅ done |
| 🟡 | Section transformation Before/After visuelle | 📋 todo |
| 🟡 | CTA léger pour indécis (newsletter signup ou free resource) | 📋 todo |
| ✅ | Supprimer liens sociaux morts (#) du Footer | ✅ done |

---

## Audit: Design (2026-04-07)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Add hamburger mobile menu (nav-links hidden on mobile with no alternative) | ✅ done |
| ✅ | Add skip navigation link | ✅ done |
| ✅ | Add `:focus-visible` styles globally (WCAG 2.4.11) | ✅ done |
| ✅ | Add `prefers-reduced-motion` media query | ✅ done |
| ✅ | Replace media-query font-size stepping with `clamp()` (7 components) | ✅ done |
| ✅ | Fix pure `vw` in `clamp()` preferred values → `rem + vw` (BlogPost, blog index) | ✅ done |
| ✅ | Add `aria-expanded` + `aria-controls` to FAQ accordion | ✅ done |
| ✅ | Add Navbar + Footer to Privacy page (was bare layout) | ✅ done |
| ✅ | Add Navbar + Footer to 404 page (was bare layout) | ✅ done |
| ✅ | Add `aria-hidden` to decorative rotating words + `aria-label` summary | ✅ done |
| ✅ | Blog pages use different nav/footer than landing — unify with Navbar/Footer components | ✅ done |
| ✅ | Hardcoded colors outside design system (`#dbeafe`, `#fef3c7`, `#92400e`) | ✅ done |
| ✅ | Button styles duplicated in Hero.astro + ClosingCta.astro — extract to global | ✅ done |
| ✅ | `.container` class redefined in every component — extract to global style | ✅ done |
| ✅ | `.section-header` pattern duplicated in 5 components — extract to global | ✅ done |
| ✅ | No apple-touch-icon configured | ✅ done |
| 🟡 | Emoji robot logo — replace with real SVG logo for brand credibility | 📋 todo |
| 🟡 | Global `a { text-decoration: none }` removes underlines from all links | 📋 todo |

---

## Audit Findings
<!-- Populated by /shipglows-audit — dated sections added automatically -->

### Audit Landing Page (2026-04-02)

**Score actuel : 4/10 conversion, 6/10 lisibilite technique**

#### Critiques (bloquent la conversion)

##### R1 — Connecter les boutons Pricing a Polar.sh
**Effort : 15 min | Impact : CRITIQUE**

Les 3 boutons de la section Pricing (`src/components/Pricing.astro`) sont des `<button>` sans `href`. Aucun lien vers Polar.sh, vers l'app, ou vers un formulaire. Un visiteur convaincu ne peut pas s'inscrire.

- [ ] Recuperer les URLs de checkout Polar.sh pour les 3 plans (Free 0€, Creator 19€, Pro 49€)
- [ ] Remplacer les `<button>` par des `<a>` pointant vers les checkouts Polar.sh
- [ ] Ajouter un tracking d'evenement sur chaque clic (pour analytics)

**Fichier :** `src/components/Pricing.astro`

##### R2 — Ajouter une section "Probleme" avant la solution
**Effort : 2h | Impact : TRES ELEVE**

La page commence directement par la solution ("AI creates your articles") sans jamais nommer le probleme. Le visiteur ne se reconnait pas. Il faut reconnaitre la douleur avant de presenter le remede.

- [ ] Creer un composant `Problem.astro` (ou integrer dans le Hero)
- [ ] Contenu type : "You have 100 ideas. Zero published. Writing takes hours. Scheduling takes hours. Each platform needs a different format. You end up posting nothing."
- [ ] Transition vers la solution : "ContentFlowz fixes this."
- [ ] Placer avant ou dans le Hero, au-dessus du fold

**Fichier a creer :** `src/components/Problem.astro`
**Fichier a modifier :** `src/pages/index.astro`

##### R3 — Ajouter des visuels du produit (screenshots/mockup)
**Effort : 3-4h | Impact : ELEVE**

Le concept "swipe to publish" est le differenciateur principal. Il est 100% verbal, zero visuel. Le visiteur doit imaginer ce que c'est. La regle "show don't tell" est completement violee.

- [ ] Capturer des screenshots de l'app Flutter (meme en beta)
- [ ] Creer un mockup telephone avec l'interface de swipe si l'app n'est pas prete
- [ ] Ajouter dans la section Hero ou juste apres
- [ ] Optionnel : GIF ou courte video du flow de swipe

**Fichier a modifier :** `src/components/Hero.astro` ou nouveau composant `ProductDemo.astro`

#### Elevees (credibilite)

##### R4 — Remplacer les faux temoignages
**Effort : 1h | Impact : ELEVE**

La section "Testimonials" (`src/components/Testimonials.astro`) contient des use cases deguises en citations. Aucun vrai nom, aucune photo, aucun logo client. C'est un red flag pour la credibilite.

- [ ] Option A : Supprimer la section jusqu'a avoir de vrais utilisateurs
- [ ] Option B : Renommer honnetement en "Who It's For" avec des descriptions de personas
- [ ] Ne JAMAIS inventer de faux temoignages avec des prenoms fictifs

**Fichier :** `src/components/Testimonials.astro`

##### R5 — Remplacer les stats du Hero par des metriques de valeur
**Effort : 1h | Impact : MOYEN-ELEVE**

"6 content formats / 7 channels / 23 agents" = des specs techniques. Le visiteur veut des benefices.

- [ ] Remplacer par des metriques orientees resultat : "5 min/jour" / "6x plus de contenu" / "0 plateformes a gerer"
- [ ] Garder le format 3 stats mais changer le contenu

**Fichier :** `src/components/Hero.astro`

#### Moyennes (polish)

##### R6 — Nettoyer le footer (liens morts)
**Effort : 30 min | Impact : MOYEN**

Les liens /docs, /api, /guides, /about, /careers, /contact, /terms, /security n'existent pas. Impression de site inacheve.

- [ ] Supprimer tous les liens vers des pages inexistantes
- [ ] Ne garder que les liens fonctionnels (/blog, /privacy, #pricing, etc.)

**Fichier :** `src/components/Footer.astro`

##### R7 — Harmoniser le naming "ContentFlowz"
**Effort : 1h | Impact : MOYEN**

"Content Flows" (avec espace) et "ContentFlowz" (avec Z) utilises alternativement dans le code et le contenu. Inconsistance de marque.

- [ ] Choisir la forme officielle : "ContentFlowz"
- [ ] Appliquer partout : navbar, hero, footer, meta title, meta description, schema.org, copyright
- [ ] Mettre a jour le nom dans `src/layouts/Layout.astro` (schema.org dit "Content Flows")

**Fichiers :** `src/components/Navbar.astro`, `src/components/Footer.astro`, `src/layouts/Layout.astro`

#### Autres points a traiter (backlog)

- [ ] Logo : remplacer l'emoji robot par un vrai logo pour un SaaS a 49€/mois
- [ ] Langue : la page est en anglais mais les prix sont en euros — decider la cible (FR ou EN) et etre coherent
- [ ] Ajouter une section "Integrations" visuelle (logos des plateformes supportees)
- [ ] Ajouter une garantie / risk reversal ("14 jours gratuits, annulez quand vous voulez")
- [ ] Ajouter un "Sample Report" ou demo publique montrant un output reel des agents

### Audit: Code (2026-04-28)

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | Add a static redirect/auth smoke check covering `/sign-in`, `/sign-up`, and `/launch` so future handoff edits preserve same-origin app redirects and noindex metadata | 📋 todo |

### Audit: Code (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Wire Pricing CTA buttons to actionable links (app sign-in with plan hint query params) | ✅ done |
| ✅ | Add env-based Polar checkout wiring for Creator/Pro (`POLAR_CREATOR_CHECKOUT_URL`, `POLAR_PRO_CHECKOUT_URL`) with safe fallback links | ✅ done |
| 🟠 | Set deployed `POLAR_CREATOR_CHECKOUT_URL` and `POLAR_PRO_CHECKOUT_URL` values to activate final paid checkout destinations | 📋 todo |
| 🟡 | Add a static check so builds fail when pricing CTA elements are rendered without `href` | 📋 todo |

### Audit: Deps (2026-04-27)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Upgrade lockfile to `astro@5.18.1` chain and apply `npm audit fix` (10 findings -> 1 moderate remaining) | ✅ done |
| 🔄 | Add automated dependency updates + security gate (Dependabot added; CI `npm audit` threshold still pending) | 🔄 in progress |
| 🟡 | Review LGPL transitive libs from sharp (`@img/sharp-libvips-*`) for deployment/commercial license compliance | 📋 todo |
| ✅ | Pin Node/npm in `package.json` (`engines` + `packageManager`) for reproducible builds | ✅ done |
| 🟡 | Track install-time scripts from transitive dependencies (`esbuild` postinstall) in CI trust policy | 📋 todo |
