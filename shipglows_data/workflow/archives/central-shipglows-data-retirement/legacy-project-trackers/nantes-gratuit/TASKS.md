# Tasks — nantes-gratuit

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Créer le projet Supabase réel et appliquer `supabase/schema.sql` | ✅ done |
| 🔴 | Configurer `SUPABASE_URL` et `SUPABASE_ANON_KEY` pour les runs Flutter | 🔄 in progress |
| 🟠 | Définir l'URL de callback magic link mobile/web dans Supabase Auth | 🔄 in progress |
| 🟠 | Choisir la stratégie de déploiement du site Astro | 📋 todo |

---

## App Collaborative

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Ajouter une vraie carte géolocalisée des spots nantais | 🔄 in progress |
| 🟠 | Brancher l'upload photo dans le formulaire d'ajout de spot | 🔄 in progress |
| 🟠 | Ajouter les statuts de vérification communautaire dans l'interface | 🔄 in progress |
| 🟡 | Ajouter filtres par catégorie, quartier et niveau de fiabilité | 📋 todo |
| 🟡 | Préparer la modération des signalements et spots obsolètes | 🔄 in progress |

---

## Site et Contenu

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Créer la page pilier "Spots gratuits à Nantes" | ✅ done |
| 🟠 | Créer la page "Pourquoi Nantes Gratuit" | ✅ done |
| 🟠 | Créer la page "Aide alimentaire gratuite à Nantes" | ✅ done |
| 🟠 | Créer la page "Objets gratuits et ressourceries à Nantes" | ✅ done |
| 🟠 | Créer la page "Sorties gratuites à Nantes" | ✅ done |
| 🟠 | Créer la page "Toilettes, eau, wifi et lieux utiles gratuits à Nantes" | ✅ done |
| 🟠 | Créer la page "Accès aux droits et permanences gratuites à Nantes" | ✅ done |
| 🟠 | Créer la page "Charte de vérification" | ✅ done |
| 🟡 | Ajouter metadata SEO, sitemap et robots si le site devient public | 📋 todo |
| 🟡 | Créer une page contributeur pour expliquer comment proposer un spot | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | Étudier une API publique ou open data nantaise pour préremplir certains lieux utiles | 💤 deferred |
| 🟢 | Tester un partenariat local avec une ressourcerie, bibliothèque ou association | 💤 deferred |
| 🟢 | Ajouter analytics respectueux de la vie privée après validation du MVP | 💤 deferred |

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

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Corriger le chemin de signalement photo sensible: empêcher `submit_report` de marquer une photo sensible comme quarantined sans suppression Storage publique, et traiter `hide`/`delete`/`quarantine` photo via Edge Function avec suppression du fichier public avant succès | ✅ done |
| ✅ | Aligner les inserts d'audit Edge Functions sur le schéma `moderation_actions.snapshot_before/snapshot_after` | ✅ done |
| ✅ | Corriger le mapping Flutter des RPC publiques (`spot_id`, `photo_id`, `comment_id`, `public_storage_path`) pour éviter IDs `null` et URLs photo cassées | ✅ done |
| 🟠 | Valider en environnement Supabase réel/local `supabase db reset`, RLS, Storage public/quarantine et Edge Functions photo/modération/suppression compte | ✅ done |
| 🟡 | Ajouter une vérification Deno (`deno check`/format ou CI Supabase Functions) car `deno` est absent de l'environnement local actuel | ✅ done |
| 🟡 | Masquer ou login-gater les actions contributives visibles sur une fiche spot pour les visiteurs non connectés au lieu de laisser l'échec arriver côté RPC | 📋 todo |
