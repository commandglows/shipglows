# PlaisirSurprise — Task Backlog

### Maintenance (2026-05-04)

**Fixed:**
- [x] Upgrade Astro 6 + Tailwind 4 build stack, remove `@astrojs/tailwind`, and clear the Astro dependency audit blocker.

---

### Audit: UX & Conversion (2026-03-10)

**Fixed:**
- [x] Post-booking success screen avec CTA membre (création compte + sign in) — FR + EN
- [x] Auth buttons → icônes uniquement (UserRound / LayoutDashboard) — header plus épuré
- [x] Dashboard link ajouté dans le footer (FR + EN)
- [x] Header nav links: `text-cream-muted` → `text-cream/80` — meilleure lisibilité
- [x] DashboardApp refactorisé: `DashboardSignedIn` extrait comme composant dédié
- [x] i18n: `booking.successSubtitle`, `booking.successCta`, `booking.successSignIn` (FR + EN)

**Remaining:**
- [ ] 🟠 Dashboard: badge temps réel sur l'icône LayoutDashboard (nb messages non lus)
- [ ] 🟠 Mobile nav: menu hamburger / drawer — liens nav cachés sur mobile actuellement
- [ ] 🟡 Admin panel UI: approbation / rejet / régénération d'itinéraires

---

### Audit: Légal & Analytics (2026-03-10)

**Fixed:**
- [x] PostHog analytics injecté dans Layout (production uniquement)
- [x] Content protection (copy/paste/right-click/Ctrl+C) sur Layout + pages bio
- [x] Pages politique de confidentialité: `/confidentialite` et `/en/privacy`

**Remaining:**
- [ ] 🟠 `sitemap.xml`: ajouter `/confidentialite`, `/en/privacy`, `/quiz`
- [ ] 🟡 robots.txt: vérifier que `/dashboard` n'est pas indexé
- [ ] 🟡 Lighthouse audit après injection PostHog (impact perf)
- [ ] 🟡 OG images pour les pages /bio (FR + EN)

---

### Audit: Experience Engine Backend (2026-03-07)

**Fixed:**
- [x] Venue pipeline: Google Maps + Foursquare + scoring + cache 7j
- [x] Itinéraires: GPT-4o structured output → draft → approbation admin → actif
- [x] Paiement: Stripe Checkout (REST) → webhook → déblocage chat
- [x] Chat concierge: reveals scriptés + GPT-4o freeform
- [x] Admin: CRUD itinéraires, SLA 24h

**Remaining:**
- [ ] 🔴 Env vars Convex: `GOOGLE_MAPS_API_KEY`, `FOURSQUARE_API_KEY`, `OPENAI_API_KEY`, `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`
- [ ] 🔴 Tests d'intégration (10.1–10.6) — nécessitent un déploiement Convex live
- [ ] 🟠 Stripe payment flow: test end-to-end (checkout → webhook → déverouillage chat)
- [ ] 🟠 Chat concierge: tester le mode freeform GPT-4o
- [ ] 🟡 Page teaser / countdown pour le reveal d'expérience
