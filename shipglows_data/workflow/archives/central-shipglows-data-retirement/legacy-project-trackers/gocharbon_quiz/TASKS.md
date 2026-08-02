# Tasks — gocharbon_quiz

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Documenter et valider les variables d'environnement critiques (`MONGO_URL`, `DB_NAME`, `EXPO_PUBLIC_BACKEND_URL`) pour pouvoir lancer le frontend et le backend ensemble | 📋 todo |
| 🟠 | Vérifier que toutes les URLs de recommandations pointent vers des pages ou dossiers réels de `gocharbon.fr` avant mise en circulation du lead magnet | ✅ done |

---

## Funnel GoCharbon

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Renforcer la solidité du funnel entre le quiz et `gocharbon`: fiabiliser les destinations, clarifier le parcours de sortie et mesurer la conversion réelle | 🔄 in progress |
| 🔴 | Clarifier la destination business après quiz: page de cours, dossier thématique ou page de capture sur `gocharbon` selon la catégorie et le score | ✅ done |
| 🟠 | Ajouter un CTA OAuth web dans Profile, injecter les `SUPABASE_*` au build Vercel et valider le flow E2E navigateur | 🔄 in progress |
| 🟠 | Ajouter un tracking minimal du funnel de sortie (quiz démarré, quiz terminé, CTA affiché, CTA cliqué) pour mesurer la conversion vers `gocharbon` | 📋 todo |
| ✅ | Revoir le wording des écrans résultat et profil pour vendre la suite d'apprentissage GoCharbon plutôt qu'un simple lien externe | ✅ done |
| 🟠 | Vérifier que chaque URL de recommandation backend correspond à une vraie page active sur `gocharbon.fr` et définir un fallback si une destination manque | ✅ done |

---

## Produit Quiz

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Auditer la banque de questions et les explications pour s'assurer qu'elles renforcent l'autorité pédagogique de GoCharbon | 📋 todo |
| 🟡 | Définir si la capture de lead doit rester implicite via clic sortant ou devenir explicite via email/compte avant accès aux recommandations | 📋 todo |
| 🟡 | Réduire les dépendances backend non utilisées pour simplifier la maintenance du projet quiz | 📋 todo |
| 🟠 | Créer une visée guidée simplifiée (< 5 cartes) pour l'utilisateur pressé: message court + parcours rapide vers publication de contenu, sans perdre l'orientation funnel | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | Préparer une déclinaison web publique du quiz pour acquisition SEO si `gocharbon` doit l'héberger directement | 💤 deferred |
| 🟢 | Tester des recommandations plus personnalisées selon erreurs récurrentes et niveau utilisateur | 💤 deferred |

### Audit: Design (2026-04-14)

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Ajouter un mode `prefers-reduced-motion` pour atténuer les animations de score, shake et transitions du quiz/résultats | ✅ done |
| 🟠 | Supprimer les troncatures `numberOfLines` trop agressives sur les contenus pédagogiques longs pour éviter de couper questions, explications et recommandations | 📋 todo |
| 🟡 | Continuer l'harmonisation typographique des micro-labels restants (`leaderboard`, badges, pastilles secondaires) pour rester cohérent partout à 14px+ quand possible | 📋 todo |
| 🟡 | Ajouter des états d'erreur utilisateur plus explicites sur les écrans principaux au lieu de simples `console.error` silencieux | ✅ done |

### Audit: Design (2026-04-18)

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | ~~`TouchableOpacity` non importé dans `leaderboard.tsx` (ligne 37) → crash garanti sur l'écran erreur classement~~ | ✅ done |
| 🟠 | ~~`textTertiary` (#6C6C75) échoue WCAG AA (~3.98:1) sur fond `bg` — bumpé à #8A8A93 (~5.77:1)~~ | ✅ done |
| 🟠 | ~~Annoncer le timer du quiz aux lecteurs d'écran (`accessibilityRole="timer"` + `accessibilityLiveRegion` + `announceForAccessibility` à t=5s)~~ | ✅ done |
| 🟠 | ~~`optText numberOfLines={2}` → `{3}` pour absorber les réponses françaises longues sans casser la mise en page flex-end~~ | ✅ done |
| 🟡 | Dérive du spacing: tokens `S` exportés dans `theme/colors.ts`; sections clés normalisées (home catGrid 10→8, dailyCard/modeRow 12→16, profile statsRow/xpCard 14→16) — reste à propager au quiz screen | 🔄 in progress |
| 🟡 | ~~Typographie micro-labels: `tabLabel` 11→12, `dailyBadgeText`/`catText`/`statLbl`/`rankLevel` 12→14, `badgeName` 12→13, `qCount` 13→14, `explanationText` 14→15, `courseLbl` 12→13~~ | ✅ done |
| 🟡 | ~~Border-radius normalisés sur échelle 8/16/24: tokens `R` exportés; 10→8 (badges, letters, myRankBadge), 14→16 (cards, pills), 18→16, 20→24 (catCard/xpBadge/qpBtn). Géométries de cercles (avatars, timer) conservées.~~ | ✅ done |
| 🟡 | ~~Boutons secondaires/récupération unifiés: `retryBtn`/`backBtn`/`errBtn` alignés sur paddingH 24, paddingV 14, borderRadius 16, fontSize 16, fontWeight 800 sur home/profile/leaderboard/quiz/results. CTA primaires gardent le 3D Duolingo; `homeBtn`/`shareBtn` gardent surface+border.~~ | ✅ done |
| 🟡 | ~~`ActivityIndicator` remplacés par skeletons animés (`src/components/Skeleton.tsx` avec pulse opacity + `prefers-reduced-motion`) sur home/leaderboard/profile. Quiz/results gardent `ActivityIndicator` car transitionnels.~~ | ✅ done |
| 🟢 | ~~Quick wins polish: tutoiement `dailyTitle` (vos→tes), textShadow sur texte blanc au-dessus du gradient daily card, `accessibilityRole="progressbar"` sur barre de progression quiz + XP profil, `accessibilityLabel` composite sur `rankItem`, `scoreLabel` letterSpacing 2→1.5 (spec), `xpBadge` a11y label~~ | ✅ done |

### Audit: Copywriting (2026-04-19)

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Introduire dès l'accueil la promesse complète du produit : tester son niveau puis trouver la bonne suite sur GoCharbon, pour ne plus paraître comme un quiz autonome | ✅ done |
| ✅ | Transformer l'écran résultat en écran de décision : diagnostic, raison de la recommandation, bénéfice attendu et CTA principal vers GoCharbon ; rejouer devient secondaire | ✅ done |
| ✅ | Personnaliser la recommandation finale selon catégorie, score et erreurs fréquentes, au lieu d'un simple lien générique | ✅ done |
| ✅ | Ajouter un CTA alternatif léger pour les utilisateurs pas prêts à sortir immédiatement (sauvegarder la ressource, recevoir la suite, revenir plus tard) | ✅ done |
| ✅ | Réaligner profil, notifications et partage sur la progression d'apprentissage plutôt que sur le streak ou le classement seuls | ✅ done |
| 🔴 | Réduire les signaux de "mini-jeu autonome" quand ils concurrencent la marque mère et le bénéfice business | 📋 todo |

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

## Audit Findings
<!-- Populated by /sg-audit — dated sections added automatically:

### Audit: [Domain] (YYYY-MM-DD)

**Fixed:**
- [x] Issue resolved

**Remaining:**
- [ ] 🔴 Blocker still open
- [ ] 🟠 High-priority finding
-->
